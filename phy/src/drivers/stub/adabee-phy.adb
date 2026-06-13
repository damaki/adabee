--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Real_Time;

package body AdaBee.PHY
  with SPARK_Mode => Off
is

   Symbol_Rate : constant := 4_800; --  Slowest symbol rate in IEEE 802.15.4

   PHY_State    : State_Kind := Off;
   PHY_Channel  : RF_Channel_Number := 0;
   PHY_CCA_Mode : CCA_Mode_Kind := ALOHA;
   PHY_Tx_Power : RF_Power_dBm := 0;

   PHY_Rx_Filters : Filter_Array := All_Packets_Allowed_Filter
   with Atomic;

   function Supported_Channels return Channel_Boolean_Array
   is (Channel_Boolean_Array'(0 => True, others => False));

   function Channel_Supported (Channel : RF_Channel_Number) return Boolean
   is (Channel = 0);

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

   function Get_Device_ID return Bits_64
   is (0);

   function Current_State return State_Kind
   is (PHY_State);

   procedure Go_Idle is
   begin
      PHY_State := Idle;
   end Go_Idle;

   procedure Turn_On is
   begin
      PHY_State := Sleeping;
   end Turn_On;

   procedure Turn_Off is
   begin
      PHY_State := Off;
   end Turn_Off;

   procedure Enter_Sleep is
   begin
      PHY_State := Sleeping;
   end Enter_Sleep;

   procedure Exit_Sleep is
   begin
      PHY_State := Exiting_Sleep;
   end Exit_Sleep;

   function Symbols_Duration
     (Nb_Symbols : Symbol_Count) return AdaBee.Time_Units.Time_Span
   is (Time_Units.Time_Span (Nb_Symbols) / Symbol_Rate);

   function Symbol_Time (T : Time_Units.Time) return Symbol_Count is
      use type Interfaces.Unsigned_64;

      Modulus : constant :=
        ((Symbol_Count'Last + 1) * 1_000_000) / Symbol_Rate;

      T_US   : constant Bits_64 := Bits_64 (T / Time_Units.Time'Small);
      Result : Bits_64;
   begin
      Result := ((T_US mod Modulus) * Symbol_Rate) / 1_000_000;
      return Symbol_Count (Result);
   end Symbol_Time;

   function Packet_Duration
     (Length : Packet_Length_Number) return AdaBee.Time_Units.Time_Span
   is (Symbols_Duration (Symbol_Count (Length)));

   function Max_Wakeup_Duration return AdaBee.Time_Units.Time_Span
   is (0.001);

   function Max_Tx_Prepare_Time_No_CCA return AdaBee.Time_Units.Time_Span
   is (0.001);

   function Max_Tx_Prepare_Time_CCA return AdaBee.Time_Units.Time_Span
   is (0.001);

   function Max_Rx_Prepare_Time return AdaBee.Time_Units.Time_Span
   is (0.001);

   procedure Wait_For_Events
     (Events : out Event_Flags_Array;
      Filter : Event_Flags_Array := [others => True])
   is
      pragma Unreferenced (Events);
      pragma Unreferenced (Filter);
   begin
      loop
         delay until Ada.Real_Time.Time_Last;
      end loop;
   end Wait_For_Events;

   procedure Wait_For_Event (Event : Event_Kind) is
      pragma Unreferenced (Event);
   begin
      loop
         delay until Ada.Real_Time.Time_Last;
      end loop;
   end Wait_For_Event;

   function Get_Events return Event_Flags_Array
   is ([others => False]);

   function Is_Event_Set (Event : Event_Kind) return Boolean
   is (False);

   procedure Send_User_Event is
   begin
      null;
   end Send_User_Event;

   procedure Clear_Event (Event : Event_Kind) is
      pragma Unreferenced (Event);
   begin
      null;
   end Clear_Event;

   procedure Clear_All_Events is
   begin
      null;
   end Clear_All_Events;

   procedure Read_Clock (Now : out Radio_Clock_Time_Range) is
   begin
      Now := 0.0;
   end Read_Clock;

   procedure Set_Alarm
     (Alarm : Alarm_Number; Trigger_At : AdaBee.Time_Units.Time) is
   begin
      null;
   end Set_Alarm;

   procedure Cancel_Alarm (Alarm : Alarm_Number) is
   begin
      null;
   end Cancel_Alarm;

   procedure Transmit_Now (Packet : Byte_Array; Ignore_CCA : Boolean := False)
   is
      pragma Unreferenced (Packet);
      pragma Unreferenced (Ignore_CCA);
   begin
      PHY_State := Transmitting;
   end Transmit_Now;

   procedure Transmit_Delayed
     (Packet     : Byte_Array;
      Tx_Time    : AdaBee.Time_Units.Time;
      Ignore_CCA : Boolean := False)
   is
      pragma Unreferenced (Packet);
      pragma Unreferenced (Tx_Time);
      pragma Unreferenced (Ignore_CCA);
   begin
      PHY_State := Transmitting;
   end Transmit_Delayed;

   procedure Finish_Transmit is
   begin
      null;
   end Finish_Transmit;

   procedure Get_Tx_Timestamps (Timestamps : out Packet_Timestamps) is
   begin
      Timestamps := (Preamble_Start => 0.0, SFD => 0.0, Payload_End => 0.0);
   end Get_Tx_Timestamps;

   procedure Start_CCA_Scan is
   begin
      PHY_State := CCA_Scan_Active;
   end Start_CCA_Scan;

   procedure Start_CCA_Scan_Delayed (CCA_Begin_Time : AdaBee.Time_Units.Time)
   is
      pragma Unreferenced (CCA_Begin_Time);
   begin
      PHY_State := CCA_Scan_Active;
   end Start_CCA_Scan_Delayed;

   procedure Finish_CCA_Scan is
   begin
      null;
   end Finish_CCA_Scan;

   procedure Get_CCA_Result (CCA_Result : out CCA_Result_Kind) is
   begin
      CCA_Result := Busy;
   end Get_CCA_Result;

   procedure Receive_Now
     (Rx_End_Time  : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last;
      SFD_Deadline : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last)
   is
      pragma Unreferenced (Rx_End_Time);
      pragma Unreferenced (SFD_Deadline);
   begin
      PHY_State := Receiving;
   end Receive_Now;

   procedure Receive_Delayed
     (Rx_Begin_Time : AdaBee.Time_Units.Time;
      Rx_End_Time   : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last;
      SFD_Deadline  : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last)
   is
      pragma Unreferenced (Rx_Begin_Time);
      pragma Unreferenced (Rx_End_Time);
      pragma Unreferenced (SFD_Deadline);
   begin
      PHY_State := Receiving;
   end Receive_Delayed;

   procedure Finish_Receive is
   begin
      null;
   end Finish_Receive;

   function Packet_Received return Boolean
   is (False);

   procedure Get_Received_Packet
     (Packet   : out Byte_Array;
      Length   : out Packet_Length_Number;
      Metadata : out Receive_Metadata) is
   begin
      --  Should never be possible to call this since Packet_Received is always
      --  False
      raise Program_Error;
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

   procedure Start_ED_Scan (Duration : AdaBee.Time_Units.Time_Span) is
      pragma Unreferenced (Duration);
   begin
      PHY_State := ED_Scan_Active;
   end Start_ED_Scan;

   procedure Finish_ED_Scan is
   begin
      null;
   end Finish_ED_Scan;

   procedure Get_ED_Scan_Result (Max_ED : out ED_Range) is
   begin
      Max_ED := ED_Range'First;
   end Get_ED_Scan_Result;

end AdaBee.PHY;
