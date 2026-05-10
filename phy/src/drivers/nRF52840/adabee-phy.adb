--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Interrupts.Names;
with System;

with NRF52840;       use NRF52840;
with NRF52840.EGU;   use NRF52840.EGU;
with NRF52840.FICR;  use NRF52840.FICR;
with NRF52840.PPI;   use NRF52840.PPI;
with NRF52840.RADIO; use NRF52840.RADIO;

with AdaBee.BSP.Config;
with AdaBee.BSP.Conversions; use AdaBee.BSP.Conversions;
with AdaBee.BSP.HFCLK_Control;
with AdaBee.PHY.PPI_Scheduler;

package body AdaBee.PHY
  with SPARK_Mode => Off
is
   use Interfaces;

   subtype Supported_RF_Channel_Number is RF_Channel_Number range 11 .. 26;
   --  Set of channels supported by this IEEE 802.15.4 O-QPSK PHY

   --===========--
   -- Constants --
   --===========--

   ITU_T_CRC_Polynomial : constant := 16#1_1021#;

   Symbol_Rate : constant := 62_500;
   --  Symbol rate of the radio

   Nb_SHR_Symbols : constant := 10;
   --  Number of symbols in the SHR field (preamble + SFD)

   Nb_PHR_Symbols : constant := 2;
   --  Number of symbols in the PHR field.

   Nb_Symbols_Per_Octet : constant := 2;
   --  Number of symbols per octet (4 bits per symbol)

   ED_RSSIOFFS : constant := -92;
   --  Offset value when converting between hardware-reported value and dBm
   --
   --  See Section 6.20.15.11 of nRF52840 PS v1.11

   ED_RSSISCALE : constant := 4;
   --  Scaling value when converting between hardware-reported value and dBm
   --
   --  See Section 6.20.15.11 of nRF52840 PS v1.11

   SHR_Duration : constant AdaBee.Time_Units.Time_Span :=
     Time_Units.Time_Span (Nb_SHR_Symbols) / Symbol_Rate;
   --  Duration of the SHR field (preamble + SFD) on air = 160 us

   PHR_Duration : constant AdaBee.Time_Units.Time_Span :=
     Time_Units.Time_Span (Nb_PHR_Symbols) / Symbol_Rate;
   --  Duration of the PHR field on air = 32 us

   TXRU_Duration : constant AdaBee.Time_Units.Time_Span := 40.0e-6;
   --  The radio's Tx ramp-up time, in microseconds.
   --
   --  This assumes the radio is using fast ramp-up.
   --
   --  See Section 6.20.15.8 of the nRF52840 PS v1.11

   RXRU_Duration : constant AdaBee.Time_Units.Time_Span := 40.0e-6;
   --  The radio's Rx ramp-up time, in microseconds.
   --
   --  This assumes the radio is using fast ramp-up.
   --
   --  See Section 6.20.15.8 of the nRF52840 PS v1.11

   RX_TX_Turnaround_Duration : constant AdaBee.Time_Units.Time_Span := 40.0e-6;
   --  Tx-to-Rx turnaround time, in microseconds.
   --
   --  See Section 6.20.15.8 of the nRF52840 PS v1.11

   CCA_Duration : constant AdaBee.Time_Units.Time_Span := 8.0 / Symbol_Rate;
   --  Duration of a CCA scan.
   --
   --  The CCA scan is performed over 8 symbols

   Tx_Power_Table :
     constant array (RF_Power_dBm) of NRF52840.RADIO.TXPOWER_TXPOWER_Field :=
       (-256 .. -21 => Neg40dBm,
        -20 .. -17  => Neg20dBm,
        -16 .. -13  => Neg16dBm,
        -12 .. -9   => Neg12dBm,
        -8 .. -5    => Neg8dBm,
        -4 .. -1    => Neg4dBm,
        0 .. 1      => Val_0dBm,
        2           => Pos2dBm,
        3           => Pos3dBm,
        4           => Pos4dBm,
        5           => Pos5dBm,
        6           => Pos6dBm,
        7           => Pos7dBm,
        8 .. 255    => Pos8dBm);
   --  Lookup table mapping tx power in dBm to the TXPOWER register value.
   --
   --  The dBm value is interpreted as a maximum allowed transmit power, so
   --  we map the TXPOWER values to avoid exceeding this value. For example,
   --  a requested power of -10 dBm will be mapped to Neg12dBm since the next
   --  step would be Neg8dBm which is higher than the requested -10 dBm.

   CCA_Mode_Table :
     constant array (CCA_Mode_Kind) of NRF52840.RADIO.CCACTRL_CCAMODE_Field :=
       (Energy_Above_Threshold                       => EdMode,
        Carrier_Sense_Only                           => CarrierMode,
        Carrier_Sense_And_Energy_Above_Treshold      => CarrierAndEdMode,
        Carrier_Sense_Or_Energy_Above_Treshold       => CarrierOrEdMode,
        ALOHA                                        => EdMode,
        HRP_UWB_Preamble_Sense_SHR                   => CarrierMode,
        HRP_UWB_Preamble_Sense_Multipliexed_Preamble => CarrierMode);
   --  Lookup table mapping CCA_Mode_Kind to the CCAMODE field

   --=====================--
   -- Radio Packet Layout --
   --=====================--

   --  This defines the layout of a packet that is compatible with the
   --  radio's EasyDMA peripheral.
   --
   --  This structure assumes that the PCNF0 register is configured as follows:
   --  S0LEN = 0
   --  S1LEN = 0
   --  LFLEN = 8

   type Radio_Packet_Length_Number is range 0 .. 127 with Size => 7;

   type Radio_Packet is record
      Length   : Radio_Packet_Length_Number; --  Bits 0..6 of PHR
      Reserved : NRF52840.Bit;               --  Bit 7 of PHR
      Payload  : Byte_Array (1 .. Maximum_Packet_Length + 1);
   end record
   with Size => 129 * 8;

   for Radio_Packet use
     record
       Length   at 0 range 0 .. 6;
       Reserved at 0 range 7 .. 7;
       Payload  at 0 range 8 .. (129 * 8) - 1;
     end record;

   --===============--
   -- Private State --
   --===============--

   PHY_API_State : State_Kind := Off;
   --  Keeps track of which state the PHY API is in

   PHY_Channel  : Supported_RF_Channel_Number := 11
   with Atomic;

   PHY_CCA_Mode : CCA_Mode_Kind := ALOHA
   with Atomic;

   PHY_Tx_Power : RF_Power_dBm := 0
   with Atomic;

   PHY_Packet_Buffer : Radio_Packet :=
     (Length => 0, Reserved => 0, Payload => (others => 0));
   --  Buffer used with the RADIO's EasyDMA

   PHY_Rx_Filters : Filter_Array := All_Packets_Allowed_Filter
   with Atomic;

   --===============================--
   -- Local Subprogram Declarations --
   --===============================--

   procedure Power_On_Radio;
   --  Turns on the radio (via the RADIO.POWER register) and configures it for
   --  IEEE 802.15.4 mode.
   --
   --  This also puts the PPI_Scheduler into High_Precision mode.

   procedure Apply_PHY_Config;
   --  Apply the current PHY_Config to the RADIO_Periph registers.

   procedure Prepare_Transmit (Packet : Byte_Array; Ignore_CCA : Boolean)
   with Pre => Packet'Length <= Maximum_Packet_Length;
   --  Load a packet into the PHY packet buffer and configure the RADIO
   --  for a transmit operation. Also clears the Operation_Complete event flag.

   procedure Prepare_Receive;
   --  Configure the RADIO for a receive operation.
   --
   --  Also clears the Operation_Complete event flag.

   procedure Clear_Receive_Interrupts_And_Alarms;
   --  Disable the interrupts & alarms used during reception

   procedure Clear_Transmit_Interrupts_And_Alarms;
   --  Disable the interrupts & alarms used during transmission

   procedure Prepare_CCA_Scan;
   --  Configure the RADIO for a CCA (without transmitting afterwards).
   --
   --  Also clears the Operation_Complete event flag.

   procedure Set_Rx_Window_End_Alarm (Rx_End_Time : AdaBee.Time_Units.Time);
   --  Configures a high precision alarm in the PPI scheduler to trigger
   --  an EGU interrupt to trigger RADIO.TASKS_DISABLE at the specified
   --  Rx_End_Time.
   --
   --  If the specified Rx_End_Time has already passed, then the RADIO is
   --  disabled immediately.

   procedure Set_SFD_Deadline_Alarm
     (SFD_Deadline : AdaBee.Time_Units.Time; Already_Expired : out Boolean);
   --  Configures a high precision alarm in the PPI scheduler to trigger
   --  an EGU interrupt at the specified time.

   procedure Cancel_Current_Operation;
   --  Cancels any ongoing transmit, receive, or ED scan operation by disabling
   --  the RADIO and disabling the relevant interrupts.

   procedure Get_Packet_Timestamps
     (Timestamps : out Packet_Timestamps; Length : Packet_Length_Number);
   --  Read the SFD timestamp from the radio driver and derive the packet
   --  start/sfd/end timestamps from it.

   procedure Enable_PPI (Channel : Natural; EEP : UInt32; TEP : UInt32)
   with Inline, Pre => Channel in PPI_Periph.CH'Range;
   --  Configure a PPI channel's EEP and TEP, then enable the channel

   procedure Disable_PPI (Channel : Natural)
   with Inline, Pre => Channel in PPI_Periph.CH'Range;
   --  Disable a PPI channel

   function To_FREQUENCY (Channel : Supported_RF_Channel_Number) return UInt7
   is (UInt7 (5 + 5 * (Channel - 11)));
   --  Convert a channel number to its frequency in MHz, offset by -2400 MHz.
   --
   --  For example, To_Frequency (11) returns 5, meaning a frequency of
   --  2405 MHz.

   --=====================--
   -- Peripherals Mapping --
   --=====================--

   ---------------------------------
   -- Peripheral Register Aliases --
   ---------------------------------

   --  The register definitions generated by svd2ada were generated with
   --  --no-vfa-on-types, which implies --no-arrays so the EGU registers
   --  are defined as TASKS_TRIGGER_0, TASKS_TRIGGER_1, TASKS_TRIGGER_2, etc
   --  on instead of using arrays.
   --
   --  However, it's more convenient to use arrays and we can use a UInt32 type
   --  to get the same effect of Volatile_Full_Access for these registers.

   subtype Bit_32 is UInt32 range 0 .. 1;

   EGU_Periph : EGU_Peripheral renames BSP.Config.Radio_EGU_Periph;

   EGU_Periph_TASKS_TRIGGER : array (0 .. 15) of Bit_32
   with
     Volatile_Components,
     Size    => 16 * 32,
     Import,
     Address => EGU_Periph.TASKS_TRIGGER_0'Address;

   EGU_Periph_EVENTS_TRIGGERED : array (0 .. 15) of Bit_32
   with
     Volatile_Components,
     Size    => 16 * 32,
     Import,
     Address => EGU_Periph.EVENTS_TRIGGERED_0'Address;

   ----------------------------
   -- EGU Channel Allocation --
   ----------------------------

   --  The EGU is used to generate interrupts when certain events happen on
   --  the PPI.

   EGU_CH_HFCLK_Started : constant := 0;
   --  EGU channel used for managing HFCLK_STARTED events

   EGU_CH_User_Alarm_1 : constant := 1;
   EGU_CH_User_Alarm_2 : constant := 2;
   --  EGU channel used for the user alarm interrupts

   EGU_CH_Rx_End : constant := 3;
   --  EGU channel used when the Rx end alarm triggers

   EGU_CH_SFD_Deadline : constant := 4;
   --  EGU channel used when the SFD deadline alarm triggers

   ----------------------------
   -- PPI Channel Allocation --
   ----------------------------

   --  PPI channels used in every mode:

   PPI_CH_User_Alarm_1 : constant := BSP.Config.Radio_PPI_CH0_Idx;
   PPI_CH_User_Alarm_2 : constant := BSP.Config.Radio_PPI_CH1_Idx;

   --  Additional PPI channels used during wakeup:

   PPI_CH_Wakeup : constant := BSP.Config.Radio_PPI_CH2_Idx;

   --  Additional PPI channels used during transmit:

   PPI_CH_Tx_Delayed_TXEN : constant := BSP.Config.Radio_PPI_CH2_Idx;
   PPI_CH_Tx_FRAMESTART   : constant := BSP.Config.Radio_PPI_CH3_Idx;

   --  Additional PPI channels used during receive:

   PPI_CH_Rx_Delayed_RXEN : constant := BSP.Config.Radio_PPI_CH2_Idx;
   PPI_CH_Rx_Window_End   : constant := BSP.Config.Radio_PPI_CH3_Idx;
   PPI_CH_Rx_FRAMESTART   : constant := BSP.Config.Radio_PPI_CH4_Idx;
   PPI_CH_Rx_SFD_Deadline : constant := BSP.Config.Radio_PPI_CH5_Idx;

   --  Additional PPI channels used during CCA scanning
   --  (not combined with transmit).

   PPI_CH_CCA_Delayed_RXEN    : constant := BSP.Config.Radio_PPI_CH2_Idx;
   PPA_CH_CCA_CCAIDLE_DISABLE : constant := BSP.Config.Radio_PPI_CH3_Idx;

   --------------------------------------
   -- PPI_Scheduler Channel Allocation --
   --------------------------------------

   subtype LP_Channel_Number is PPI_Scheduler.LP_Channel_Number;
   subtype HP_Channel_Number is PPI_Scheduler.HP_Channel_Number;

   --  Scheduler low power channels used for user alarms

   PPISCH_CH_User_Alarm_1 : constant LP_Channel_Number := 0;
   PPISCH_CH_User_Alarm_2 : constant LP_Channel_Number := 1;

   --  Scheduler high precision channels used during transmit

   PPISCH_CH_Tx_Start_Delayed : constant HP_Channel_Number := 0;
   PPISCH_CH_Tx_Framestart    : constant HP_Channel_Number := 1;

   --  Scheduler high precision channels used during receive

   PPISCH_CH_Rx_Start_Delayed : constant HP_Channel_Number := 0;
   PPISCH_CH_Rx_End           : constant HP_Channel_Number := 1;
   PPISCH_CH_Rx_Framestart    : constant HP_Channel_Number := 2;
   PPISCH_CH_Rx_SFD_Deadline  : constant HP_Channel_Number := 3;

   --  Scheduler high precision channels used during CCA scanning

   PPISCH_CH_CCA_Start_Delayed : constant HP_Channel_Number := 0;

   --====================--
   -- Interrupt Handling --
   --====================--

   --  This protected object implements the interrupt handlers and any
   --  operations that need blocking behaviour or mutual exclusion between the
   --  interrupts and callers of the PHY API.

   protected Driver
     with Interrupt_Priority => System.Interrupt_Priority'Last
   is

      ----------------------
      -- Event Management --
      ----------------------

      procedure Clear_Event (Event : Event_Kind);

      procedure Clear_All_Events;

      procedure Send_User_Event;

      function Is_Event_Set (Event : Event_Kind) return Boolean;

      procedure Set_Event (Event : Event_Kind)
      with Inline;

      procedure Set_Event_Filter (Filter : Event_Flags_Array);

      entry Wait_For_Events (Events : out Event_Flags_Array);

      -------------------
      -- Sleep Helpers --
      -------------------

      procedure Clear_Sleep_Exited_Flag;
      --  Sets the Sleeping flag to True

      entry Wait_Sleep_Exited;
      --  Wait for the Sleeping flag to be set to False

      ------------------------
      -- Receive Management --
      ------------------------

      procedure Clear_Receive_Data;
      --  Clean out any internal state in preparation for a receive operation

      function Packet_Available return Boolean;
      --  Check if a packet has been received

      function Get_SFD_Time return Time_Units.Time;
      --  Get the timestamp of the SFD from the last packet received

   private

      procedure Check_Received_Packet (Allow_Rx_Reenable : Boolean);

      procedure EGU_Interrupt_Handler
      with Attach_Handler => BSP.Config.Radio_EGU_Interrupt;

      procedure RADIO_Interrupt_Handler
      with Attach_Handler => Ada.Interrupts.Names.RADIO_Interrupt;

      ----------------
      -- Event Data --
      ----------------

      Event_Flags  : Event_Flags_Array := (others => False);
      Event_Filter : Event_Flags_Array := (others => True);
      Has_Event    : Boolean := False;

      ----------------
      -- Sleep Data --
      ----------------

      Sleeping : Boolean := True;

      ----------------
      -- Tx/Rx Data --
      ----------------

      SFD_Time             : Time_Units.Time := 0.0;
      Have_Rx_Packet       : Boolean := False;
      SFD_Deadline_Reached : Boolean := False;

   end Driver;

   protected body Driver is

      -----------------
      -- Clear_Event --
      -----------------

      procedure Clear_Event (Event : Event_Kind) is
      begin
         Event_Flags (Event) := False;
         Has_Event :=
           (for some E in Event_Kind =>
              Event_Filter (E) and then Event_Flags (E));
      end Clear_Event;

      ----------------------
      -- Clear_All_Events --
      ----------------------

      procedure Clear_All_Events is
      begin
         Event_Flags := (others => False);
         Has_Event := False;
      end Clear_All_Events;

      ---------------------
      -- Send_User_Event --
      ---------------------

      procedure Send_User_Event is
      begin
         Event_Flags (User_Event) := True;
         if Event_Filter (User_Event) then
            Has_Event := True;
         end if;
      end Send_User_Event;

      ------------------
      -- Is_Event_Set --
      ------------------

      function Is_Event_Set (Event : Event_Kind) return Boolean
      is (Event_Flags (Event));

      ---------------
      -- Set_Event --
      ---------------

      procedure Set_Event (Event : Event_Kind) is
      begin
         Event_Flags (Event) := True;
         if Event_Filter (Event) then
            Has_Event := True;
         end if;
      end Set_Event;

      ----------------------
      -- Set_Event_Filter --
      ----------------------

      procedure Set_Event_Filter (Filter : Event_Flags_Array) is
      begin
         Event_Filter := Filter;
         Has_Event :=
           (for some E in Event_Kind =>
              Event_Filter (E) and then Event_Flags (E));
      end Set_Event_Filter;

      ---------------------
      -- Wait_For_Events --
      ---------------------

      entry Wait_For_Events (Events : out Event_Flags_Array) when Has_Event is
      begin
         --  Only read & clear the event if the caller wants the event,
         --  otherwise keep the event flag unchanged and set it to False in
         --  the Events array.

         for E in Event_Kind loop
            if Event_Filter (E) then
               Events (E) := Event_Flags (E);
               Event_Flags (E) := False;
            else
               Events (E) := False;
            end if;
         end loop;
      end Wait_For_Events;

      -----------------------------
      -- Clear_Sleep_Exited_Flag --
      -----------------------------

      procedure Clear_Sleep_Exited_Flag is
      begin
         Sleeping := True;
      end Clear_Sleep_Exited_Flag;

      -----------------------
      -- Wait_Sleep_Exited --
      -----------------------

      entry Wait_Sleep_Exited when not Sleeping is
      begin
         null;
      end Wait_Sleep_Exited;

      ------------------------
      -- Clear_Receive_Data --
      ------------------------

      procedure Clear_Receive_Data is
      begin
         Have_Rx_Packet := False;
         SFD_Deadline_Reached := False;
         SFD_Time := 0.0;
      end Clear_Receive_Data;

      ----------------------
      -- Packet_Available --
      ----------------------

      function Packet_Available return Boolean
      is (Have_Rx_Packet);

      ------------------
      -- Get_SFD_Time --
      ------------------

      function Get_SFD_Time return Time_Units.Time
      is (SFD_Time);

      ---------------------------
      -- Check_Received_Packet --
      ---------------------------

      procedure Check_Received_Packet (Allow_Rx_Reenable : Boolean) is
         CRC_OK     : Boolean;
         Frame_Type : Bits_8;

      begin
         --  Check against filters

         CRC_OK := RADIO_Periph.CRCSTATUS.CRCSTATUS = CRCOk;

         Frame_Type := PHY_Packet_Buffer.Payload (1) and 2#0000_0111#;

         if (PHY_Rx_Filters (Allow_Invalid_CRC) or else CRC_OK)
           and then PHY_Rx_Filters (Filter_Kind'Val (Frame_Type))
         then
            --  Packet passes the rx filters
            RADIO_Periph.TASKS_DISABLE := (TASKS_DISABLE => 1, others => <>);
            Have_Rx_Packet := True;
            Clear_Receive_Interrupts_And_Alarms;
            Set_Event (Operation_Complete);

         elsif Allow_Rx_Reenable then
            --  Packet rejected by filter. Re-enable receiver if the SFD
            --  deadline has not already passed.

            if SFD_Deadline_Reached then
               Clear_Receive_Interrupts_And_Alarms;
               Set_Event (Operation_Complete);

            else
               RADIO_Periph.EVENTS_DISABLED :=
                 (EVENTS_DISABLED => 0, others => <>);

               RADIO_Periph.EVENTS_END := (EVENTS_END => 0, others => <>);

               RADIO_Periph.EVENTS_RSSIEND :=
                 (EVENTS_RSSIEND => 0, others => <>);

               RADIO_Periph.EVENTS_FRAMESTART :=
                 (EVENTS_FRAMESTART => 0, others => <>);

               RADIO_Periph.TASKS_RSSISTOP :=
                 (TASKS_RSSISTOP => 1, others => <>);

               RADIO_Periph.TASKS_START := (TASKS_START => 1, others => <>);
            end if;
         end if;
      end Check_Received_Packet;

      ---------------------------
      -- EGU_Interrupt_Handler --
      ---------------------------

      procedure EGU_Interrupt_Handler is
      begin
         --  Check for Rx_End alarm triggered

         if EGU_Periph_EVENTS_TRIGGERED (EGU_CH_Rx_End) /= 0 then
            EGU_Periph_EVENTS_TRIGGERED (EGU_CH_Rx_End) := 0;

            if PHY_API_State = Receiving then
               RADIO_Periph.TASKS_DISABLE :=
                 (TASKS_DISABLE => 1, others => <>);

               --  A packet might have been received while this interrupt was
               --  being serviced, just before the radio was disabled.

               if RADIO_Periph.EVENTS_END.EVENTS_END /= 0 then
                  RADIO_Periph.EVENTS_END := (EVENTS_END => 0, others => <>);
                  Check_Received_Packet (Allow_Rx_Reenable => False);
               end if;

               Clear_Receive_Interrupts_And_Alarms;
               Set_Event (Operation_Complete);
            end if;
         end if;

         --  Check for SFD deadline alarm

         if EGU_Periph_EVENTS_TRIGGERED (EGU_CH_SFD_Deadline) /= 0 then
            EGU_Periph_EVENTS_TRIGGERED (EGU_CH_SFD_Deadline) := 0;

            if PHY_API_State = Receiving then
               SFD_Deadline_Reached := True;

               if RADIO_Periph.EVENTS_FRAMESTART.EVENTS_FRAMESTART = 0 then
                  --  No SFD detected before the deadline

                  RADIO_Periph.TASKS_DISABLE :=
                    (TASKS_DISABLE => 1, others => <>);
                  Clear_Receive_Interrupts_And_Alarms;
                  Set_Event (Operation_Complete);
               end if;
            end if;
         end if;

         --  Check for sleep exit

         if EGU_Periph_EVENTS_TRIGGERED (EGU_CH_HFCLK_Started) /= 0 then
            EGU_Periph_EVENTS_TRIGGERED (EGU_CH_HFCLK_Started) := 0;

            --  Unblock anyone that is blocked on Wait_Sleep_Exited

            Sleeping := False;

            --  Disable the PPI and EGU channels that were used to signal the
            --  wakeup is completed to avoid the possibility of spurious
            --  interrupts.

            Disable_PPI (Channel => PPI_CH_Wakeup);

            if PHY_API_State = Exiting_Sleep then
               Set_Event (Operation_Complete);
            end if;
         end if;

         --  Check for user alarm

         if EGU_Periph_EVENTS_TRIGGERED (EGU_CH_User_Alarm_1) /= 0 then
            EGU_Periph_EVENTS_TRIGGERED (EGU_CH_User_Alarm_1) := 0;

            Set_Event (Alarm_1_Triggered);
         end if;

         if EGU_Periph_EVENTS_TRIGGERED (EGU_CH_User_Alarm_2) /= 0 then
            EGU_Periph_EVENTS_TRIGGERED (EGU_CH_User_Alarm_2) := 0;

            Set_Event (Alarm_2_Triggered);
         end if;

      end EGU_Interrupt_Handler;

      -----------------------------
      -- RADIO_Interrupt_Handler --
      -----------------------------

      procedure RADIO_Interrupt_Handler is
      begin
         --  Capture FRAMESTART timestamp

         if RADIO_Periph.EVENTS_FRAMESTART.EVENTS_FRAMESTART /= 0 then
            RADIO_Periph.EVENTS_FRAMESTART :=
              (EVENTS_FRAMESTART => 0, others => <>);

            if PHY_API_State = Receiving then
               PPI_Scheduler.Scheduler.Get_Capture_Timestamp
                 (Channel => PPISCH_CH_Rx_Framestart, Timestamp => SFD_Time);
            elsif PHY_API_State = Transmitting then
               PPI_Scheduler.Scheduler.Get_Capture_Timestamp
                 (Channel => PPISCH_CH_Tx_Framestart, Timestamp => SFD_Time);
            end if;
         end if;

         --  Check for received packet

         if RADIO_Periph.EVENTS_END.EVENTS_END /= 0 then
            RADIO_Periph.EVENTS_END := (EVENTS_END => 0, others => <>);

            if PHY_API_State = Receiving then
               Check_Received_Packet (Allow_Rx_Reenable => True);
            end if;
         end if;

         --  Check for end of Tx/Rx

         if RADIO_Periph.EVENTS_DISABLED.EVENTS_DISABLED /= 0 then
            RADIO_Periph.EVENTS_DISABLED :=
              (EVENTS_DISABLED => 0, others => <>);

            RADIO_Periph.INTENCLR := (DISABLED => Clear, others => <>);

            if PHY_API_State = Transmitting then
               --  Disable the PPI channel used for delayed tx

               Clear_Transmit_Interrupts_And_Alarms;

               Set_Event (Operation_Complete);

            elsif PHY_API_State = CCA_Scan_Active then

               --  Disable all PPI channels used for CCA scanning

               PPI_Periph.CHENCLR :=
                 (As_Array => True,
                  Arr      =>
                    (PPI_CH_CCA_Delayed_RXEN    => Clear,
                     PPA_CH_CCA_CCAIDLE_DISABLE => Clear,
                     others                     => <>));

               --  Cancel all CCA alarms

               PPI_Scheduler.Scheduler.Cancel_High_Precision_Alarm
                 (Channel => PPISCH_CH_CCA_Start_Delayed);

               Set_Event (Operation_Complete);

            elsif PHY_API_State = ED_Scan_Active then
               Set_Event (Operation_Complete);

            end if;
         end if;

      end RADIO_Interrupt_Handler;

   end Driver;

   --========================--
   -- Subprogram Definitions --
   --========================--

   ------------------------
   -- Supported_Channels --
   ------------------------

   function Supported_Channels return Channel_Boolean_Array
   is (Channel_Boolean_Array'
         (Supported_RF_Channel_Number => True, others => False));

   -----------------------
   -- Channel_Supported --
   -----------------------

   function Channel_Supported (Channel : RF_Channel_Number) return Boolean
   is (Channel in Supported_RF_Channel_Number);

   -----------------
   -- Set_Channel --
   -----------------

   procedure Set_Channel (Channel : RF_Channel_Number) is
   begin
      PHY_Channel := Channel;
   end Set_Channel;

   -----------------
   -- Get_Channel --
   -----------------

   function Get_Channel return RF_Channel_Number
   is (PHY_Channel);

   ------------------
   -- Set_CCA_Mode --
   ------------------

   procedure Set_CCA_Mode (CCA_Mode : CCA_Mode_Kind) is
   begin
      PHY_CCA_Mode := CCA_Mode;
   end Set_CCA_Mode;

   ------------------
   -- Get_CCA_Mode --
   ------------------

   function Get_CCA_Mode return CCA_Mode_Kind
   is (PHY_CCA_Mode);

   ------------------
   -- Set_Tx_Power --
   ------------------

   procedure Set_Tx_Power (Tx_Power : RF_Power_dBm) is
   begin
      PHY_Tx_Power := Tx_Power;
   end Set_Tx_Power;

   ------------------
   -- Get_Tx_Power --
   ------------------

   function Get_Tx_Power return RF_Power_dBm
   is (PHY_Tx_Power);

   -------------------
   -- Get_Device_ID --
   -------------------

   function Get_Device_ID return Bits_64 is
   begin
      --  Use DEVICEID instead of DEVICEADDR, since DEVICEADDR is only 48-bit
      return
        Interfaces.Shift_Left (Bits_64 (FICR_Periph.DEVICEID_1), 32)
        or Bits_64 (FICR_Periph.DEVICEID_0);
   end Get_Device_ID;

   -------------------
   -- Current_State --
   -------------------

   function Current_State return State_Kind
   is (PHY_API_State);

   -------------
   -- Go_Idle --
   -------------

   procedure Go_Idle is
   begin
      if PHY_API_State = Exiting_Sleep then
         Driver.Wait_Sleep_Exited;

         Power_On_Radio;

      --  The radio is only active while the PHY is in one of these states.
      --  For all other states the radio is disabled.

      elsif PHY_API_State
            in Transmitting | Receiving | ED_Scan_Active | CCA_Scan_Active
      then
         Cancel_Current_Operation;

         --  Wait for the radio to be disabled.
         --  I.e. wait for the radio to move to the DISABLED state
         --  (from either TXDISABLE or RXDISABLE).
         --
         --  This takes max. 21 us (going from TX to DISABLED).

         loop
            exit when RADIO_Periph.STATE.STATE = Disabled;
         end loop;
      end if;

      PHY_API_State := Idle;
   end Go_Idle;

   -------------
   -- Turn_On --
   -------------

   procedure Turn_On is
   begin
      PHY_API_State := Sleeping;
      PPI_Scheduler.Scheduler.Start;
   end Turn_On;

   --------------
   -- Turn_Off --
   --------------

   procedure Turn_Off is
   begin
      PHY_API_State := Off;

      for Alarm in Alarm_Number loop
         Cancel_Alarm (Alarm);
      end loop;

      PPI_Scheduler.Scheduler.Stop;
   end Turn_Off;

   -----------------
   -- Enter_Sleep --
   -----------------

   procedure Enter_Sleep is
   begin
      PHY_API_State := Sleeping;

      RADIO_Periph.POWER := (POWER => Disabled, others => <>);

      PPI_Scheduler.Scheduler.Set_Mode (PPI_Scheduler.Low_Power);

      BSP.HFCLK_Control.HFCLK.Stop;

      Driver.Clear_Sleep_Exited_Flag;
   end Enter_Sleep;

   ----------------
   -- Exit_Sleep --
   ----------------

   procedure Exit_Sleep is
      Already_Started : Boolean;

   begin
      PHY_API_State := Exiting_Sleep;

      --  Start the HFCLK and configure an EGU interrupt to trigger when the
      --  HFCLK has finished starting so that we can power on the radio and
      --  signal to the next highest layer that the radio is ready.

      --  Clear any previous event in the EGU channel we're using

      EGU_Periph_EVENTS_TRIGGERED (EGU_CH_HFCLK_Started) := 0;

      --  Enable the EGU interrupt

      EGU_Periph.INTENSET :=
        (TRIGGERED =>
           (As_Array => True,
            Arr      => (EGU_CH_HFCLK_Started => Set, others => <>)),
         others    => <>);

      --  Configure a PPI channel to connect the HFCLK_STARTED event
      --  to the EGU's TASKS_TRIGGER.

      Enable_PPI
        (Channel => PPI_CH_Wakeup,
         EEP     => 0,
         TEP     =>
           To_UInt32
             (EGU_Periph_TASKS_TRIGGER (EGU_CH_HFCLK_Started)'Address));

      --  Start the HFCLK and set it to trigger the PPI channel when started

      BSP.HFCLK_Control.HFCLK.Start
        (EEP             => PPI_Periph.CH (PPI_CH_Wakeup).EEP,
         Already_Started => Already_Started);

      --  If the HFCLK is already running, then trigger the interrupt
      --  immediately.

      if Already_Started then
         EGU_Periph_TASKS_TRIGGER (EGU_CH_HFCLK_Started) := 1;
      end if;
   end Exit_Sleep;

   ----------------------
   -- Symbols_Duration --
   ----------------------

   function Symbols_Duration
     (Nb_Symbols : Symbol_Count) return AdaBee.Time_Units.Time_Span
   is (Time_Units.Time_Span (Nb_Symbols) / Symbol_Rate);

   -----------------
   -- Symbol_Time --
   -----------------

   function Symbol_Time (T : Time_Units.Time) return Symbol_Count is
      Modulus : constant :=
        ((Symbol_Count'Last + 1) * 1_000_000) / Symbol_Rate;

      T_US   : constant Bits_64 := Bits_64 (T / Time_Units.Time'Small);
      Result : Bits_64;
   begin
      Result := ((T_US mod Modulus) * Symbol_Rate) / 1_000_000;
      return Symbol_Count (Result);
   end Symbol_Time;

   ---------------------
   -- Packet_Duration --
   ---------------------

   function Packet_Duration
     (Length : Packet_Length_Number) return AdaBee.Time_Units.Time_Span
   is (Symbols_Duration
         (Nb_SHR_Symbols
          + Nb_PHR_Symbols
          + (Nb_Symbols_Per_Octet * Symbol_Count (Length))));

   -------------------------
   -- Max_Wakeup_Duration --
   -------------------------

   function Max_Wakeup_Duration return AdaBee.Time_Units.Time_Span
   is (0.001_500);

   --------------------------------
   -- Max_Tx_Prepare_Time_No_CCA --
   --------------------------------

   function Max_Tx_Prepare_Time_No_CCA return AdaBee.Time_Units.Time_Span
   is (TXRU_Duration + 50.0e-6); --  Allow 50us processing overhead

   -----------------------------
   -- Max_Tx_Prepare_Time_CCA --
   -----------------------------

   function Max_Tx_Prepare_Time_CCA return AdaBee.Time_Units.Time_Span
   is (RXRU_Duration + CCA_Duration + RX_TX_Turnaround_Duration + 50.0e-6);

   -------------------------
   -- Max_Rx_Prepare_Time --
   -------------------------

   function Max_Rx_Prepare_Time return AdaBee.Time_Units.Time_Span
   is (RXRU_Duration + 50.0e-6); --  Allow 50us processing overhead

   ---------------------
   -- Wait_For_Events --
   ---------------------

   procedure Wait_For_Events
     (Events : out Event_Flags_Array;
      Filter : Event_Flags_Array := (others => True)) is
   begin
      Driver.Set_Event_Filter (Filter);
      Driver.Wait_For_Events (Events);

      if Events (Operation_Complete) then
         case PHY_API_State is
            when Off
               | Sleeping
               | Idle
               | Tx_Complete
               | Rx_Complete
               | CCA_Scan_Complete
               | ED_Scan_Complete =>
               --  The Operation_Complete flag should never be set while the
               --  PHY is in one of these states.
               raise Program_Error;

            when Exiting_Sleep    =>
               PHY_API_State := Idle;
               Power_On_Radio;

            when Transmitting     =>
               PHY_API_State := Tx_Complete;

            when Receiving        =>
               PHY_API_State := Rx_Complete;

            when ED_Scan_Active   =>
               PHY_API_State := ED_Scan_Complete;

            when CCA_Scan_Active  =>
               PHY_API_State := CCA_Scan_Complete;
         end case;
      end if;
   end Wait_For_Events;

   --------------------
   -- Wait_For_Event --
   --------------------

   procedure Wait_For_Event (Event : Event_Kind) is
      Filter : Event_Flags_Array := (others => False);
      Events : Event_Flags_Array;
   begin
      Filter (Event) := True;
      Wait_For_Events (Events, Filter);
   end Wait_For_Event;

   ------------------
   -- Is_Event_Set --
   ------------------

   function Is_Event_Set (Event : Event_Kind) return Boolean
   is (Driver.Is_Event_Set (Event));

   ---------------------
   -- Send_User_Event --
   ---------------------

   procedure Send_User_Event is
   begin
      Driver.Send_User_Event;
   end Send_User_Event;

   -----------------
   -- Clear_Event --
   -----------------

   procedure Clear_Event (Event : Event_Kind) is
   begin
      Driver.Clear_Event (Event);
   end Clear_Event;

   ----------------------
   -- Clear_All_Events --
   ----------------------

   procedure Clear_All_Events is
   begin
      Driver.Clear_All_Events;
   end Clear_All_Events;

   ----------------
   -- Read_Clock --
   ----------------

   procedure Read_Clock (Now : out Radio_Clock_Time_Range) is
   begin
      if PHY_API_State = Off then
         Now := 0.0;
      else
         PPI_Scheduler.Scheduler.Read_Clock (Now);
      end if;
   end Read_Clock;

   ---------------
   -- Set_Alarm --
   ---------------

   procedure Set_Alarm
     (Alarm : Alarm_Number; Trigger_At : AdaBee.Time_Units.Time)
   is
      PPI_CH : constant Natural :=
        (case Alarm is
           when 1 => PPI_CH_User_Alarm_1,
           when 2 => PPI_CH_User_Alarm_2);

      EGU_CH : constant Natural :=
        (case Alarm is
           when 1 => EGU_CH_User_Alarm_1,
           when 2 => EGU_CH_User_Alarm_2);

      PPISCH_CH : constant PPI_Scheduler.LP_Channel_Number :=
        (case Alarm is
           when 1 => PPISCH_CH_User_Alarm_1,
           when 2 => PPISCH_CH_User_Alarm_2);

      Alarm_Event : constant Event_Kind :=
        (case Alarm is
           when 1 => Alarm_1_Triggered,
           when 2 => Alarm_2_Triggered);

      Already_Expired : Boolean;

   begin
      --  This hooks up a PPI scheduler alarm to an EGU interrupt so that we
      --  gen an interrupt at the Trigger_At time.

      --  Cancel any previous alarm

      PPI_Scheduler.Scheduler.Cancel_Low_Power_Alarm (PPISCH_CH);

      Driver.Clear_Event (Alarm_Event);

      --  Ensure event is cleared

      EGU_Periph_EVENTS_TRIGGERED (EGU_CH) := 0;

      --  Enable interrupt

      EGU_Periph.INTENSET :=
        (TRIGGERED => (As_Array => False, Val => Shift_Left (1, EGU_CH)),
         others    => <>);

      --  Configure and enable PPI

      PPI_Periph.CH (PPI_CH) :=
        (EEP => 0,
         TEP => To_UInt32 (EGU_Periph_TASKS_TRIGGER (EGU_CH)'Address));

      PPI_Periph.CHENSET := (As_Array => False, Val => 2 ** PPI_CH);

      --  Set the alarm

      PPI_Scheduler.Scheduler.Set_Low_Power_Alarm
        (Channel         => PPISCH_CH,
         Trigger_At      => Trigger_At,
         EEP_Address     => PPI_Periph.CH (PPI_CH).EEP'Address,
         Already_Expired => Already_Expired);

      if Already_Expired then
         Cancel_Alarm (Alarm);
         Driver.Set_Event (Alarm_Event);
      end if;

   end Set_Alarm;

   ------------------
   -- Cancel_Alarm --
   ------------------

   procedure Cancel_Alarm (Alarm : Alarm_Number) is
      PPI_CH : constant Natural :=
        (case Alarm is
           when 1 => PPI_CH_User_Alarm_1,
           when 2 => PPI_CH_User_Alarm_2);

      EGU_CH : constant Natural :=
        (case Alarm is
           when 1 => EGU_CH_User_Alarm_1,
           when 2 => EGU_CH_User_Alarm_2);

      PPISCH_CH : constant PPI_Scheduler.LP_Channel_Number :=
        (case Alarm is
           when 1 => PPISCH_CH_User_Alarm_1,
           when 2 => PPISCH_CH_User_Alarm_2);
   begin
      --  Disable PPI and interrupt first

      PPI_Periph.CHENCLR := (As_Array => False, Val => 2 ** PPI_CH);

      EGU_Periph.INTENCLR :=
        (TRIGGERED => (As_Array => False, Val => 2 ** EGU_CH), others => <>);

      PPI_Scheduler.Scheduler.Cancel_Low_Power_Alarm (PPISCH_CH);
   end Cancel_Alarm;

   ------------------
   -- Transmit_Now --
   ------------------

   procedure Transmit_Now (Packet : Byte_Array; Ignore_CCA : Boolean := False)
   is
   begin
      PHY_API_State := Transmitting;

      Prepare_Transmit (Packet, Ignore_CCA);

      if PHY_CCA_Mode = ALOHA or else Ignore_CCA then
         RADIO_Periph.TASKS_TXEN := (TASKS_TXEN => 1, others => <>);
      else
         RADIO_Periph.TASKS_RXEN := (TASKS_RXEN => 1, others => <>);
      end if;

   end Transmit_Now;

   ----------------------
   -- Transmit_Delayed --
   ----------------------

   procedure Transmit_Delayed
     (Packet     : Byte_Array;
      Tx_Time    : AdaBee.Time_Units.Time;
      Ignore_CCA : Boolean := False)
   is
      Already_Expired  : Boolean;
      Tx_Time_Adjusted : AdaBee.Time_Units.Time;
      TEP              : UInt32;

   begin
      PHY_API_State := Transmitting;

      Prepare_Transmit (Packet, Ignore_CCA);

      --  Adjust the Tx_Time based on the Tx ramp-up time so that the
      --  Tx_Time lines up with the start of the first symbol of the
      --  preamble.
      --
      --  If CCA is used, then also adjust by the time needed to do the CCA

      if PHY_CCA_Mode = ALOHA or else Ignore_CCA then
         Tx_Time_Adjusted :=
           AdaBee.Time_Units.Time'Base'Max (Tx_Time - TXRU_Duration, 0.0);
      else
         Tx_Time_Adjusted :=
           AdaBee.Time_Units.Time'Base'Max
             (Tx_Time
              - RXRU_Duration
              - CCA_Duration
              - RX_TX_Turnaround_Duration,
              0.0);
      end if;

      --  Configure the PPI channel to connect the alarm event (from the PPI
      --  scheduler) to the radio's TXEN task. If CCA is used, then trigger
      --  RXEN to perform CCA before transmitting.

      if PHY_CCA_Mode = ALOHA or else Ignore_CCA then
         TEP := To_UInt32 (RADIO_Periph.TASKS_TXEN'Address);
      else
         TEP := To_UInt32 (RADIO_Periph.TASKS_RXEN'Address);
      end if;

      Enable_PPI (Channel => PPI_CH_Tx_Delayed_TXEN, EEP => 0, TEP => TEP);

      PPI_Scheduler.Scheduler.Set_High_Precision_Alarm
        (Channel         => PPISCH_CH_Tx_Start_Delayed,
         Trigger_At      => Tx_Time_Adjusted,
         EEP_Address     => PPI_Periph.CH (PPI_CH_Tx_Delayed_TXEN).EEP'Address,
         Already_Expired => Already_Expired);

      if Already_Expired then

         Disable_PPI (Channel => PPI_CH_Tx_Delayed_TXEN);

         --  The transmit start time already passed, so transmit immediately
         --  if TXEN wasn't already triggered.

         if RADIO_Periph.STATE.STATE = Disabled then
            if PHY_CCA_Mode = ALOHA or else Ignore_CCA then
               RADIO_Periph.TASKS_TXEN := (TASKS_TXEN => 1, others => <>);
            else
               RADIO_Periph.TASKS_RXEN := (TASKS_RXEN => 1, others => <>);
            end if;
         end if;
      end if;
   end Transmit_Delayed;

   ---------------------
   -- Finish_Transmit --
   ---------------------

   procedure Finish_Transmit is
   begin
      if RADIO_Periph.STATE.STATE = Disabled then
         PHY_API_State := Tx_Complete;
      end if;
   end Finish_Transmit;

   -----------------------
   -- Get_Tx_Timestamps --
   -----------------------

   procedure Get_Tx_Timestamps (Timestamps : out Packet_Timestamps) is
   begin
      Get_Packet_Timestamps
        (Timestamps => Timestamps,
         Length     => Packet_Length_Number (PHY_Packet_Buffer.Length));
   end Get_Tx_Timestamps;

   --------------------
   -- Start_CCA_Scan --
   --------------------

   procedure Start_CCA_Scan is
   begin
      PHY_API_State := CCA_Scan_Active;

      Prepare_CCA_Scan;

      RADIO_Periph.TASKS_RXEN := (TASKS_RXEN => 1, others => <>);
   end Start_CCA_Scan;

   ----------------------------
   -- Start_CCA_Scan_Delayed --
   ----------------------------

   procedure Start_CCA_Scan_Delayed (CCA_Begin_Time : AdaBee.Time_Units.Time)
   is
      CCA_Time_Adjusted : AdaBee.Time_Units.Time;
      Already_Expired   : Boolean;

   begin
      PHY_API_State := CCA_Scan_Active;

      Prepare_CCA_Scan;

      --  Adjust the CCA_Begin_Time based on the Rx ramp-up time so that CCA
      --  starts at the requested time.

      CCA_Time_Adjusted :=
        AdaBee.Time_Units.Time'Base'Max (CCA_Begin_Time - RXRU_Duration, 0.0);

      --  Configure the PPI channel to connect the alarm event (from the PPI
      --  scheduler) to the radio's TXEN task. If CCA is used, then trigger
      --  RXEN to perform CCA before transmitting.

      Enable_PPI
        (Channel => PPI_CH_CCA_Delayed_RXEN,
         EEP     => 0,
         TEP     => To_UInt32 (RADIO_Periph.TASKS_RXEN'Address));

      PPI_Scheduler.Scheduler.Set_High_Precision_Alarm
        (Channel         => PPISCH_CH_CCA_Start_Delayed,
         Trigger_At      => CCA_Time_Adjusted,
         EEP_Address     =>
           PPI_Periph.CH (PPI_CH_CCA_Delayed_RXEN).EEP'Address,
         Already_Expired => Already_Expired);

      if Already_Expired then

         Disable_PPI (Channel => PPI_CH_CCA_Delayed_RXEN);

         --  The CCA start time already passed, so start CCA immediately
         --  if RXEN wasn't already triggered.

         if RADIO_Periph.STATE.STATE = Disabled then
            RADIO_Periph.TASKS_RXEN := (TASKS_RXEN => 1, others => <>);
         end if;
      end if;
   end Start_CCA_Scan_Delayed;

   ---------------------
   -- Finish_CCA_Scan --
   ---------------------

   procedure Finish_CCA_Scan is
   begin
      if RADIO_Periph.STATE.STATE = Disabled then
         PHY_API_State := CCA_Scan_Complete;
      end if;
   end Finish_CCA_Scan;

   -------------------
   -- Get_CCA_Clear --
   -------------------

   procedure Get_CCA_Result (CCA_Result : out CCA_Result_Kind) is
   begin
      CCA_Result :=
        (if RADIO_Periph.EVENTS_CCABUSY.EVENTS_CCABUSY = 0
         then Clear
         else Busy);
   end Get_CCA_Result;

   -----------------
   -- Receive_Now --
   -----------------

   procedure Receive_Now
     (Rx_End_Time  : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last;
      SFD_Deadline : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last)
   is
      Already_Expired : Boolean := False;

   begin
      PHY_API_State := Receiving;

      Prepare_Receive;

      --  Start the receiver

      RADIO_Periph.TASKS_RXEN := (TASKS_RXEN => 1, others => <>);

      if SFD_Deadline < Rx_End_Time then
         Set_SFD_Deadline_Alarm (SFD_Deadline, Already_Expired);
      end if;

      if Already_Expired then
         Cancel_Current_Operation;
         Driver.Set_Event (Operation_Complete);

      elsif Rx_End_Time < AdaBee.Time_Units.Time'Last then
         Set_Rx_Window_End_Alarm (Rx_End_Time);
      end if;
   end Receive_Now;

   ---------------------
   -- Receive_Delayed --
   ---------------------

   procedure Receive_Delayed
     (Rx_Begin_Time : AdaBee.Time_Units.Time;
      Rx_End_Time   : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last;
      SFD_Deadline  : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last)
   is
      Already_Expired        : Boolean := False;
      Rx_Begin_Time_Adjusted : AdaBee.Time_Units.Time;

   begin
      PHY_API_State := Receiving;

      Prepare_Receive;

      if SFD_Deadline < Rx_End_Time then
         Set_SFD_Deadline_Alarm (SFD_Deadline, Already_Expired);
      end if;

      if Already_Expired then
         Cancel_Current_Operation;
         Driver.Set_Event (Operation_Complete);

      else
         --  Adjust the Rx_Begin_Time based on the Rx ramp-up time so that the
         --  Rx_Begin_Time lines up to the end of the ramp-up.

         Rx_Begin_Time_Adjusted :=
           Time_Units.Time'Base'Max (Rx_Begin_Time - RXRU_Duration, 0.0);

         --  Set an alarm to start the receiver

         Enable_PPI
           (Channel => PPI_CH_Rx_Delayed_RXEN,
            EEP     => 0,
            TEP     => To_UInt32 (RADIO_Periph.TASKS_RXEN'Address));

         PPI_Scheduler.Scheduler.Set_High_Precision_Alarm
           (Channel         => PPISCH_CH_Rx_Start_Delayed,
            Trigger_At      => Rx_Begin_Time_Adjusted,
            EEP_Address     =>
              PPI_Periph.CH (PPI_CH_Rx_Delayed_RXEN).EEP'Address,
            Already_Expired => Already_Expired);

         if Already_Expired then
            if RADIO_Periph.STATE.STATE = Disabled then
               RADIO_Periph.TASKS_RXEN := (TASKS_RXEN => 1, others => <>);
            end if;
         end if;

         if Rx_End_Time < Time_Units.Time'Last then
            Set_Rx_Window_End_Alarm (Rx_End_Time);
         end if;
      end if;
   end Receive_Delayed;

   --------------------
   -- Finish_Receive --
   --------------------

   procedure Finish_Receive is
   begin
      if PHY_API_State = Receiving and then RADIO_Periph.STATE.STATE = Disabled
      then
         PHY_API_State := Rx_Complete;
      end if;
   end Finish_Receive;

   ---------------------
   -- Packet_Received --
   ---------------------

   function Packet_Received return Boolean
   is (if PHY_API_State = Rx_Complete then Driver.Packet_Available else False);

   -------------------------
   -- Get_Received_Packet --
   -------------------------

   procedure Get_Received_Packet
     (Packet   : out Byte_Array;
      Length   : out Packet_Length_Number;
      Metadata : out Receive_Metadata)
   is
      LQI_Correction_Factor : constant := 4;
      --  The LQI reported by hardware must be converted to IEEE 802.15.4
      --  range by an 8-bit saturating multiplication by 4.
      --
      --  See nRF52840 PS v1.11 Section 6.20.12.7 "Receive sequence"

      Uncorrected_LQI : LQI_Number;

   begin
      Length := Packet_Length_Number (PHY_Packet_Buffer.Length);

      --  RSSI in dBm is equal to -RSSISAMPLE

      Metadata.RSSI := -RF_Power_dBm (RADIO_Periph.RSSISAMPLE.RSSISAMPLE);
      Metadata.CRC_Valid := RADIO_Periph.CRCSTATUS.CRCSTATUS = CRCOk;

      Get_Packet_Timestamps (Metadata.Timestamps, Length);

      if Length > 2 then
         --  The LQI is appended immediately after the last received octet.
         --
         --  Note that the hardware CRC checking must be enabled, in which
         --  case the LQI replaces the CRC in the received frame.

         Uncorrected_LQI :=
           LQI_Number (PHY_Packet_Buffer.Payload (Length - 1));
      else
         Uncorrected_LQI := 0;
      end if;

      Packet (Packet'First .. Packet'First + (Length - 1)) :=
        PHY_Packet_Buffer.Payload (1 .. Length);

      --  Correct the LQI (saturating multiplication by 4)

      if Uncorrected_LQI < LQI_Number'Last / LQI_Correction_Factor then
         Metadata.LQI := Uncorrected_LQI * LQI_Correction_Factor;
      else
         Metadata.LQI := LQI_Number'Last; --  Saturate
      end if;
   end Get_Received_Packet;

   ------------------------
   -- Set_Receive_Filter --
   ------------------------

   procedure Set_Receive_Filter (Filter : Filter_Kind; Enabled : Boolean) is
   begin
      PHY_Rx_Filters (Filter) := Enabled;
   end Set_Receive_Filter;

   ----------------------------
   -- Receive_Filter_Enabled --
   ----------------------------

   function Receive_Filter_Enabled (Filter : Filter_Kind) return Boolean
   is (PHY_Rx_Filters (Filter));

   -------------------------
   -- Set_Receive_Filters --
   -------------------------

   procedure Set_Receive_Filters (Filters : Filter_Array) is
   begin
      PHY_Rx_Filters := Filters;
   end Set_Receive_Filters;

   -------------------------
   -- Get_Receive_Filters --
   -------------------------

   function Get_Receive_Filters return Filter_Array
   is (PHY_Rx_Filters);

   -------------------
   -- Start_ED_Scan --
   -------------------

   procedure Start_ED_Scan (Duration : AdaBee.Time_Units.Time_Span) is
      Num_Scans : constant Natural := Natural ((Duration / 8) * Symbol_Rate);

   begin
      PHY_API_State := ED_Scan_Active;

      Clear_Event (Operation_Complete);

      Apply_PHY_Config;

      --  Clear any previous ED events

      RADIO_Periph.EVENTS_EDEND := (EVENTS_EDEND => 0, others => <>);
      RADIO_Periph.EVENTS_EDSTOPPED := (EVENTS_EDSTOPPED => 0, others => <>);
      RADIO_Periph.EVENTS_DISABLED := (EVENTS_DISABLED => 0, others => <>);

      --  Enable interrupt at end of ED scan

      RADIO_Periph.SHORTS :=
        (READY_EDSTART => Enabled, EDEND_DISABLE => Enabled, others => <>);

      RADIO_Periph.INTENSET := (DISABLED => Set, others => <>);

      --  Start ED scan

      RADIO_Periph.EDCNT :=
        (EDCNT => EDCNT_EDCNT_Field (Num_Scans - 1), others => <>);

      RADIO_Periph.TASKS_RXEN := (TASKS_RXEN => 1, others => <>);
   end Start_ED_Scan;

   --------------------
   -- Finish_ED_Scan --
   --------------------

   procedure Finish_ED_Scan is
   begin
      if RADIO_Periph.EVENTS_EDEND.EVENTS_EDEND /= 0 then
         PHY_API_State := ED_Scan_Complete;
      end if;
   end Finish_ED_Scan;

   ------------------------
   -- Get_ED_Scan_Result --
   ------------------------

   procedure Get_ED_Scan_Result (Max_ED : out ED_Range) is
      EDLVL : Natural;

   begin
      --  Note that the nRF52840 PS v1.11 has the wrong conversion formulas.
      --
      --  See Errata 236 in section 3.44 of nRF52840 Errata v1.3

      EDLVL := Natural (RADIO_Periph.EDSAMPLE.EDLVL);
      EDLVL := Natural'Min (EDLVL * ED_RSSISCALE, 255);
      Max_ED := ED_Range (EDLVL);
   end Get_ED_Scan_Result;

   --------------------
   -- Power_On_Radio --
   --------------------

   procedure Power_On_Radio is
   begin
      EGU_Periph.INTENCLR :=
        (TRIGGERED => (As_Array => False, Val => 2 ** EGU_CH_HFCLK_Started),
         others    => <>);

      --  Now power on the radio

      RADIO_Periph.POWER := (POWER => Enabled, others => <>);

      --  Configure the radio for IEEE 802.15.4 mode

      RADIO_Periph.MODE := (MODE => Ieee802154_250Kbit, others => <>);

      RADIO_Periph.PCNF0 :=
        (LFLEN   => 8,
         --  8-bit length field
         S0LEN   => 0,
         --  S0 not used
         S1LEN   => 0,
         --  S1 not used
         S1INCL  => Automatic,
         --  Don't include S1 field if S0LEN = 0
         CILEN   => 0,
         PLEN    => Val_32bitZero,
         CRCINC  => Include,
         --  LENGTH field includes CRC
         TERMLEN => 0,
         others  => <>);

      RADIO_Periph.PCNF1 :=
        (MAXLEN  => 129,
         --  127 bytes max pkt size + 2 bytes length field
         STATLEN => 0,
         BALEN   => 0,
         ENDIAN  => Little,
         WHITEEN => Disabled,
         others  => <>);

      RADIO_Periph.MODECNF0 :=
        (RU     => Fast,
         --  Use fast ramp-up
         DTX    => Center,
         --  Must be center for IEEE 802.15.4
         others => <>);

      RADIO_Periph.CRCCNF :=
        (LEN => Two, SKIPADDR => Ieee802154, others => <>);

      RADIO_Periph.CRCPOLY := (CRCPOLY => ITU_T_CRC_Polynomial, others => <>);

      RADIO_Periph.CRCINIT := (CRCINIT => 0, others => <>);

      --  Use high precision clocks for timing

      PPI_Scheduler.Scheduler.Set_Mode (PPI_Scheduler.High_Precision);

   end Power_On_Radio;

   ----------------------
   -- Apply_PHY_Config --
   ----------------------

   procedure Apply_PHY_Config is
      CCAEDTHRES_Neg90dBm : constant := -90 - ED_RSSIOFFS;
      --  CCA ED threshold hardware value for a -90 dBm ED threshold.
      --
      --  IEEE 802.15.4-2020 Section 21.5.13 states:
      --    "The ED threshold shall correspond to a received signal power of at
      --    most –90 dBm, when applying CCA Mode 1 or CCA Mode 3, as defined
      --    in 10.2.8."

   begin
      RADIO_Periph.FREQUENCY :=
        (FREQUENCY => To_FREQUENCY (PHY_Channel),
         MAP       => Default,
         --  Channel map between 2400 .. 2500 MHz
         others    => <>);

      RADIO_Periph.CCACTRL :=
        (CCAMODE      => CCA_Mode_Table (PHY_CCA_Mode),
         CCAEDTHRES   => CCAEDTHRES_Neg90dBm,
         CCACORRTHRES => <>,
         CCACORRCNT   => <>,
         others       => <>);

      RADIO_Periph.TXPOWER :=
        (TXPOWER => Tx_Power_Table (PHY_Tx_Power), others => <>);
   end Apply_PHY_Config;

   ----------------------
   -- Prepare_Transmit --
   ----------------------

   procedure Prepare_Transmit (Packet : Byte_Array; Ignore_CCA : Boolean) is
   begin
      Apply_PHY_Config;

      PHY_Packet_Buffer.Length := Radio_Packet_Length_Number (Packet'Length);
      PHY_Packet_Buffer.Payload (1 .. Packet'Length) := Packet;

      RADIO_Periph.PACKETPTR := To_UInt32 (PHY_Packet_Buffer'Address);

      if PHY_CCA_Mode = ALOHA or else Ignore_CCA then
         --  No CCA, so immediately start transmitting when TXRU has finished,
         --  then disable the radio at the end of the packet.

         RADIO_Periph.SHORTS :=
           (READY_START => Enabled, END_DISABLE => Enabled, others => <>);
      else
         --  CCA is used, so start CCA as soon as RXRU has finished.
         --  If CCA indicates BUSY, then disable the radio.
         --  If CCA indicates CLEAR, then trigger TXEN and when TXREADY, START
         --  transmitting the packet, then DISABLE the radio at the END of the
         --  packet.
         RADIO_Periph.SHORTS :=
           (RXREADY_CCASTART => Enabled,
            CCABUSY_DISABLE  => Enabled,
            CCAIDLE_TXEN     => Enabled,
            TXREADY_START    => Enabled,
            END_DISABLE      => Enabled,
            others           => <>);
      end if;

      --  We use the DISABLED event to indicate that the transmission has
      --  finished, so ensure the event is cleared before we start.
      --  Also clear any CCA-related events.

      RADIO_Periph.EVENTS_DISABLED := (EVENTS_DISABLED => 0, others => <>);
      RADIO_Periph.EVENTS_CCAIDLE := (EVENTS_CCAIDLE => 0, others => <>);
      RADIO_Periph.EVENTS_CCABUSY := (EVENTS_CCABUSY => 0, others => <>);

      --  Only enable the interrupt sources we are interested in
      --  (DISABLED event).

      RADIO_Periph.INTENCLR :=
        (READY      => Clear,
         ADDRESS    => Clear,
         PAYLOAD    => Clear,
         END_k      => Clear,
         DISABLED   => Clear,
         DEVMATCH   => Clear,
         DEVMISS    => Clear,
         RSSIEND    => Clear,
         BCMATCH    => Clear,
         CRCOK      => Clear,
         CRCERROR   => Clear,
         FRAMESTART => Clear,
         EDEND      => Clear,
         EDSTOPPED  => Clear,
         CCAIDLE    => Clear,
         CCABUSY    => Clear,
         CCASTOPPED => Clear,
         RATEBOOST  => Clear,
         TXREADY    => Clear,
         RXREADY    => Clear,
         MHRMATCH   => Clear,
         PHYEND     => Clear,
         others     => <>);

      RADIO_Periph.INTENSET := (DISABLED => Set, others => <>);

      Clear_Event (Operation_Complete);

      --  Configure timestamp capture on FRAMESTART

      Enable_PPI
        (Channel => PPI_CH_Tx_FRAMESTART,
         EEP     => To_UInt32 (RADIO_Periph.EVENTS_FRAMESTART'Address),
         TEP     => 0);

      PPI_Scheduler.Scheduler.Prepare_Capture
        (Channel => PPISCH_CH_Tx_Framestart,
         TEP     => PPI_Periph.CH (PPI_CH_Rx_FRAMESTART).TEP);
   end Prepare_Transmit;

   ---------------------
   -- Prepare_Receive --
   ---------------------

   procedure Prepare_Receive is
   begin
      Apply_PHY_Config;

      RADIO_Periph.PACKETPTR := To_UInt32 (PHY_Packet_Buffer'Address);

      --  Clear all events that we use to trigger interrupts/tasks.

      RADIO_Periph.EVENTS_DISABLED := (EVENTS_DISABLED => 0, others => <>);
      RADIO_Periph.EVENTS_END := (EVENTS_END => 0, others => <>);
      RADIO_Periph.EVENTS_RSSIEND := (EVENTS_RSSIEND => 0, others => <>);
      RADIO_Periph.EVENTS_FRAMESTART := (EVENTS_FRAMESTART => 0, others => <>);

      EGU_Periph_EVENTS_TRIGGERED (EGU_CH_SFD_Deadline) := 0;

      --  Configure the radio to:
      --   * automatically start transmitting the packet (START task)
      --     once the ramp-up is complete (READY event); and
      --   * automatically disable the radio (DISABLE task) when the
      --     radio has received the last byte on-air (END event).
      --   * automatically stop RSSI measurement when the radio is disabled.

      RADIO_Periph.SHORTS :=
        (READY_START       => Enabled,
         ADDRESS_RSSISTART => Enabled,
         DISABLED_RSSISTOP => Enabled,
         others            => <>);

      --  Only enable the interrupt sources we are interested in
      --  (DISABLED and FRAMESTART events).

      RADIO_Periph.INTENCLR :=
        (READY      => Clear,
         ADDRESS    => Clear,
         PAYLOAD    => Clear,
         END_k      => Clear,
         DISABLED   => Clear,
         DEVMATCH   => Clear,
         DEVMISS    => Clear,
         RSSIEND    => Clear,
         BCMATCH    => Clear,
         CRCOK      => Clear,
         CRCERROR   => Clear,
         FRAMESTART => Clear,
         EDEND      => Clear,
         EDSTOPPED  => Clear,
         CCAIDLE    => Clear,
         CCABUSY    => Clear,
         CCASTOPPED => Clear,
         RATEBOOST  => Clear,
         TXREADY    => Clear,
         RXREADY    => Clear,
         MHRMATCH   => Clear,
         PHYEND     => Clear,
         others     => <>);

      RADIO_Periph.INTENSET := (FRAMESTART => Set, END_k => Set, others => <>);

      Clear_Event (Operation_Complete);

      Driver.Clear_Receive_Data;

      --  Configure timestamp capture on FRAMESTART

      Enable_PPI
        (Channel => PPI_CH_Rx_FRAMESTART,
         EEP     => To_UInt32 (RADIO_Periph.EVENTS_FRAMESTART'Address),
         TEP     => 0);

      PPI_Scheduler.Scheduler.Prepare_Capture
        (Channel => PPISCH_CH_Rx_Framestart,
         TEP     => PPI_Periph.CH (PPI_CH_Rx_FRAMESTART).TEP);
   end Prepare_Receive;

   -----------------------------------------
   -- Clear_Receive_Interrupts_And_Alarms --
   -----------------------------------------

   procedure Clear_Receive_Interrupts_And_Alarms is
   begin
      --  Disable all PPI channels used for Rx

      PPI_Periph.CHENCLR :=
        (As_Array => True,
         Arr      =>
           (PPI_CH_Rx_Delayed_RXEN => Clear,
            PPI_CH_Rx_Window_End   => Clear,
            PPI_CH_Rx_FRAMESTART   => Clear,
            others                 => <>));

      EGU_Periph.INTENCLR :=
        (TRIGGERED => (As_Array => False, Val => 2 ** EGU_CH_Rx_End),
         others    => <>);

      --  Cancel all rx alarms

      PPI_Scheduler.Scheduler.Cancel_High_Precision_Alarm
        (Channel => PPISCH_CH_Rx_Start_Delayed);

      PPI_Scheduler.Scheduler.Cancel_High_Precision_Alarm
        (Channel => PPISCH_CH_Rx_End);
   end Clear_Receive_Interrupts_And_Alarms;

   -----------------------------------------
   -- Clear_Transmit_Interrupts_And_Alarms --
   -----------------------------------------

   procedure Clear_Transmit_Interrupts_And_Alarms is
   begin
      --  Disable all PPI channels used for Rx

      PPI_Periph.CHENCLR :=
        (As_Array => True,
         Arr      =>
           (PPI_CH_Tx_Delayed_TXEN => Clear,
            PPI_CH_Tx_FRAMESTART   => Clear,
            others                 => <>));

      --  Cancel all tx alarms

      PPI_Scheduler.Scheduler.Cancel_High_Precision_Alarm
        (Channel => PPISCH_CH_Tx_Start_Delayed);
   end Clear_Transmit_Interrupts_And_Alarms;

   ----------------------
   -- Prepare_CCA_Scan --
   ----------------------

   procedure Prepare_CCA_Scan is
   begin
      Apply_PHY_Config;

      --  Clear all events that we use to trigger interrupts/tasks.

      RADIO_Periph.EVENTS_DISABLED := (EVENTS_DISABLED => 0, others => <>);
      RADIO_Periph.EVENTS_CCABUSY := (EVENTS_CCABUSY => 0, others => <>);
      RADIO_Periph.EVENTS_CCAIDLE := (EVENTS_CCAIDLE => 0, others => <>);

      RADIO_Periph.SHORTS :=
        (RXREADY_CCASTART => Enabled,
         CCABUSY_DISABLE  => Enabled,
         others           => <>);

      --  No SHORT for CCAIDLE -> DISABLE so use a PPI channel

      Enable_PPI
        (Channel => PPA_CH_CCA_CCAIDLE_DISABLE,
         EEP     => To_UInt32 (RADIO_Periph.EVENTS_CCAIDLE'Address),
         TEP     => To_UInt32 (RADIO_Periph.TASKS_DISABLE'Address));

      --  Only enable the interrupt sources we are interested in
      --  (DISABLED event).

      RADIO_Periph.INTENCLR :=
        (READY      => Clear,
         ADDRESS    => Clear,
         PAYLOAD    => Clear,
         END_k      => Clear,
         DISABLED   => Clear,
         DEVMATCH   => Clear,
         DEVMISS    => Clear,
         RSSIEND    => Clear,
         BCMATCH    => Clear,
         CRCOK      => Clear,
         CRCERROR   => Clear,
         FRAMESTART => Clear,
         EDEND      => Clear,
         EDSTOPPED  => Clear,
         CCAIDLE    => Clear,
         CCABUSY    => Clear,
         CCASTOPPED => Clear,
         RATEBOOST  => Clear,
         TXREADY    => Clear,
         RXREADY    => Clear,
         MHRMATCH   => Clear,
         PHYEND     => Clear,
         others     => <>);

      RADIO_Periph.INTENSET := (DISABLED => Set, others => <>);

      Clear_Event (Operation_Complete);
   end Prepare_CCA_Scan;

   -----------------------------
   -- Set_Rx_Window_End_Alarm --
   -----------------------------

   procedure Set_Rx_Window_End_Alarm (Rx_End_Time : AdaBee.Time_Units.Time) is
      Already_Expired : Boolean;

   begin
      EGU_Periph_EVENTS_TRIGGERED (EGU_CH_Rx_End) := 0;

      Enable_PPI
        (Channel => PPI_CH_Rx_Window_End,
         EEP     => 0,
         TEP     =>
           To_UInt32 (EGU_Periph_TASKS_TRIGGER (EGU_CH_Rx_End)'Address));

      EGU_Periph.INTENSET :=
        (TRIGGERED => (As_Array => False, Val => 2 ** EGU_CH_Rx_End),
         others    => <>);

      PPI_Scheduler.Scheduler.Set_High_Precision_Alarm
        (Channel         => PPISCH_CH_Rx_End,
         Trigger_At      => Rx_End_Time,
         EEP_Address     => PPI_Periph.CH (PPI_CH_Rx_Window_End).EEP'Address,
         Already_Expired => Already_Expired);

      --  Disable manually if the end time has already passed

      if Already_Expired then
         Cancel_Current_Operation;
         Driver.Set_Event (Operation_Complete);
      end if;
   end Set_Rx_Window_End_Alarm;

   ----------------------------
   -- Set_SFD_Deadline_Alarm --
   ----------------------------

   procedure Set_SFD_Deadline_Alarm
     (SFD_Deadline : AdaBee.Time_Units.Time; Already_Expired : out Boolean) is
   begin
      EGU_Periph_EVENTS_TRIGGERED (EGU_CH_SFD_Deadline) := 0;

      Enable_PPI
        (Channel => PPI_CH_Rx_SFD_Deadline,
         EEP     => 0,
         TEP     =>
           To_UInt32 (EGU_Periph_TASKS_TRIGGER (EGU_CH_SFD_Deadline)'Address));

      EGU_Periph.INTENSET :=
        (TRIGGERED => (As_Array => False, Val => 2 ** EGU_CH_SFD_Deadline),
         others    => <>);

      PPI_Scheduler.Scheduler.Set_High_Precision_Alarm
        (Channel         => PPISCH_CH_Rx_SFD_Deadline,
         Trigger_At      => SFD_Deadline,
         EEP_Address     => PPI_Periph.CH (PPI_CH_Rx_SFD_Deadline).EEP'Address,
         Already_Expired => Already_Expired);
   end Set_SFD_Deadline_Alarm;

   ------------------------------
   -- Cancel_Current_Operation --
   ------------------------------

   procedure Cancel_Current_Operation is
   begin

      --  Disable any interrupts

      RADIO_Periph.INTENCLR :=
        (READY      => Clear,
         ADDRESS    => Clear,
         PAYLOAD    => Clear,
         END_k      => Clear,
         DISABLED   => Clear,
         DEVMATCH   => Clear,
         DEVMISS    => Clear,
         RSSIEND    => Clear,
         BCMATCH    => Clear,
         CRCOK      => Clear,
         CRCERROR   => Clear,
         FRAMESTART => Clear,
         EDEND      => Clear,
         EDSTOPPED  => Clear,
         CCAIDLE    => Clear,
         CCABUSY    => Clear,
         CCASTOPPED => Clear,
         RATEBOOST  => Clear,
         TXREADY    => Clear,
         RXREADY    => Clear,
         MHRMATCH   => Clear,
         PHYEND     => Clear,
         others     => <>);

      --  Disable any alarms and PPI channels

      case PHY_API_State is
         when Off
            | Sleeping
            | Exiting_Sleep
            | Idle
            | Tx_Complete
            | Rx_Complete
            | CCA_Scan_Complete
            | ED_Scan_Active
            | ED_Scan_Complete =>
            null;

         when Transmitting     =>
            Clear_Transmit_Interrupts_And_Alarms;

         when Receiving        =>
            Clear_Receive_Interrupts_And_Alarms;

         when CCA_Scan_Active  =>
            PPI_Periph.CHENCLR :=
              (As_Array => True,
               Arr      =>
                 (PPI_CH_CCA_Delayed_RXEN    => Clear,
                  PPA_CH_CCA_CCAIDLE_DISABLE => Clear,
                  others                     => <>));
      end case;

      --  Disable the radio, if it isn't already

      if RADIO_Periph.STATE.STATE /= Disabled then
         RADIO_Periph.TASKS_DISABLE := (TASKS_DISABLE => 1, others => <>);
      end if;
   end Cancel_Current_Operation;

   ---------------------------
   -- Get_Packet_Timestamps --
   ---------------------------

   procedure Get_Packet_Timestamps
     (Timestamps : out Packet_Timestamps; Length : Packet_Length_Number) is
   begin
      Timestamps.SFD := Driver.Get_SFD_Time;

      Timestamps.Preamble_Start :=
        Time_Units.Time_Span'Max
          (0.0, Timestamps.SFD - SHR_Duration - PHR_Duration);

      Timestamps.Payload_End :=
        Timestamps.SFD
        + ((Time_Units.Time_Span (Length) * Nb_Symbols_Per_Octet)
           / Symbol_Rate);
   end Get_Packet_Timestamps;

   ----------------
   -- Enable_PPI --
   ----------------

   procedure Enable_PPI (Channel : Natural; EEP : UInt32; TEP : UInt32) is
   begin
      PPI_Periph.CH (Channel) := (EEP => EEP, TEP => TEP);
      PPI_Periph.CHENSET := (As_Array => False, Val => 2 ** Channel);
   end Enable_PPI;

   -----------------
   -- Disable_PPI --
   -----------------

   procedure Disable_PPI (Channel : Natural) is
   begin
      PPI_Periph.CHENCLR := (As_Array => False, Val => 2 ** Channel);

      PPI_Periph.CH (Channel) := (EEP => 0, TEP => 0);
      PPI_Periph.FORK (Channel).TEP := 0;
   end Disable_PPI;

end AdaBee.PHY;
