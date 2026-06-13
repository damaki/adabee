--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.Time_Units;
with AdaBee.PHY_Constants;

--  @summary
--  IEEE 802.15.4 physical layer (PHY) interface.
--
--  @description
--  Services provided:
--   * Radio power management (low power modes)
--   * Alarm service for timing based on the radio clock
--   * Clear Channel Assessment (CCA)
--   * Packet transmission (with or without CCA)
--   * Packet reception
--   * Received packet filtering
--   * Delayed transmit/receive/CCA
--   * Energy detection (ED) scanning
--
--  The PHY API is state-based. In general, PHY operations can only be called
--  when the PHY API is in a specific set of allowed states, and may transition
--  the PHY to a different state. These states and transitions are expressed
--  in the contracts for each subprogram. For example, the Transmit_Now
--  procedure can can only be called while the PHY is Idle, and moves the PHY
--  to the Transmitting state. The Current_State function gets the current PHY
--  state.
--
--  Operations that take a long time (transmit, receive, CCA scan, ED scan) are
--  asynchronous. When a long-running operation is started the procedure
--  (e.g. Transmit_Now) returns immediately and the operation continues in the
--  background. The completion of the operation is signalled via the
--  Operation_Complete event. The PHY user can block until the operation has
--  completed by calling either Wait_For_Event or Wait_For_Events to wait
--  for the Operation_Complete event.
--
--  The PHY implements a clock to implement delayed transmit/receive for
--  performing these radio operations at specific times. All received packets
--  are timestamped against this clock. The clock is disabled while the PHY
--  is in the Off state, and is enabled in all other states. While the PHY is
--  in the Sleeping state, the clock is in a low-power mode with resolution of
--  ~30.5 us. While the PHY is outside the Sleeping/Off states the clock
--  has an resolution of 1 us.

package AdaBee.PHY
  with
    SPARK_Mode        => On,
    Abstract_State    =>
      ((Radio_Device with
        External => (Async_Readers, Async_Writers, Effective_Writes)),
      --  Models the radio hardware.

      (Radio_Clock with
        Synchronous,
        External => (Async_Readers, Async_Writers)),
      --  Models the radio's timebase & alarm timers.

      (Radio_Events with Synchronous, External => Async_Writers),
      --  Event flags that are set by various actors.

      Radio_State,
      --  Represents the current radio API state (Off, Sleeping,
      --  Transmitting, etc). This state is changed only by
      --  making API calls in this package.

      Packet_Info,
      --  Models the buffer used to hold information about transmitted or
      --  received packets.

      (PIB_Attributes with Synchronous),
      --  PHY PIB attributes

      (Receive_Filters with External => Async_Readers)
      --  Filters for packet reception
      ),
    Initializes       =>
      (Radio_Device,
       Radio_Clock,
       Radio_Events,
       Radio_State,
       Packet_Info,
       PIB_Attributes,
       Receive_Filters),
    Initial_Condition =>
      Current_State = Off
      and then Get_Receive_Filters = All_Packets_Allowed_Filter,
    Always_Terminates
is

   use type AdaBee.Time_Units.Time_Span;
   use type Interfaces.Unsigned_8;

   -----------
   -- Types --
   -----------

   Maximum_Packet_Length : constant := 127;
   --  Maximum packet length supported by the PHY interface

   subtype Packet_Length_Number is Natural range 0 .. Maximum_Packet_Length;

   type RF_Power_dBm is range -256 .. 255;
   --  RF power in decibel milliwatts (dBm)

   type RF_Channel_Number is range 0 .. 72;
   --  Channel numbers supported for a subset of PHYs defined in
   --  IEEE 802.15.4-2024.

   type LQI_Number is range 0 .. 255;
   --  Link Quality Indicator

   subtype Symbol_Count is AdaBee.PHY_Constants.Symbol_Count;
   use type AdaBee.PHY_Constants.Symbol_Count;

   subtype Radio_Clock_Time_Range is
     AdaBee.Time_Units.Time range 0.0 .. (100.0 * 365.0 * 24.0 * 60.0 * 60.0);
   --  The radio clock returns time in this range.
   --
   --  Constraining the range of the radio clock helps to avoid needing
   --  explicit overflow checks when performing arithmetic on timestamps
   --  measured from the radio clock, as the radio clock's range is much much
   --  smaller than the range of the Time type. The range is still
   --  approximately 100 years, which will never be reached in practice.

   Max_Symbols_Duration : constant Time_Units.Time_Span :=
     Time_Units.Time_Span (Symbol_Count'Last)
     / 2_400.0; --  Slowest symbol rate of any PHYs in IEEE 802.15.4-2024
   --  Maximum possible duration of any Symbol_Count quantity.
   --
   --  For 2**24 - 1 symbols at the slowest symbol rate (2.4 ksym/s for FSK-A
   --  PHY mode 6) this is approximately equal to 6990 seconds (a little
   --  under two hours).

   type Packet_Timestamps is record
      Preamble_Start : Radio_Clock_Time_Range;
      --  Timestamp of the start of the packet (start of the preamble)

      SFD : Radio_Clock_Time_Range;
      --  Timestamp of the end of the SFD part of the frame

      Payload_End : Radio_Clock_Time_Range;
      --  Timestamp of the end of the packet (end of the last payload byte)
   end record
   with Predicate => Preamble_Start <= SFD and then SFD <= Payload_End;

   ------------------------
   -- PHY PIB Attributes --
   ------------------------

   type CCA_Mode_Kind is
     (Energy_Above_Threshold,
      --  CCA Mode 1

      Carrier_Sense_Only,
      --  CCA Mode 2

      Carrier_Sense_And_Energy_Above_Treshold,
      --  CCA Mode 3a (logical AND)

      Carrier_Sense_Or_Energy_Above_Treshold,
      --  CCA Mode 3b (logical OR)

      ALOHA,
      --  CCA Mode 4

      HRP_UWB_Preamble_Sense_SHR,
      --  CCA Mode 5

      HRP_UWB_Preamble_Sense_Multipliexed_Preamble
      --  CCA Mode 6
     );

   type Channel_Boolean_Array is array (RF_Channel_Number) of Boolean
   with Pack;

   function Supported_Channels return Channel_Boolean_Array
   with Global => null, Post => (for some C of Supported_Channels'Result => C);
   --  Get the set of supported channels.
   --
   --  For each RF channel in the array, a value of True indicates the channel
   --  is supported by the PHY, and False indicates the channel is not
   --  supported.
   --
   --  The PHY supports at least one channel.

   function Channel_Supported (Channel : RF_Channel_Number) return Boolean
   with
     Global => null,
     Post   => Channel_Supported'Result = Supported_Channels (Channel);
   --  Query if a specific channel number is supported by the PHY

   procedure Set_Channel (Channel : RF_Channel_Number)
   with
     Global  => (In_Out => PIB_Attributes),
     Depends => (PIB_Attributes => (PIB_Attributes, Channel)),
     Pre     => Channel_Supported (Channel);
   --  Configure the PHY to use the selected channel.

   function Get_Channel return RF_Channel_Number
   with
     Volatile_Function,
     Global => (Input => PIB_Attributes),
     Post   => Channel_Supported (Get_Channel'Result);

   procedure Set_CCA_Mode (CCA_Mode : CCA_Mode_Kind)
   with
     Global  => (In_Out => PIB_Attributes),
     Depends => (PIB_Attributes => (PIB_Attributes, CCA_Mode));

   function Get_CCA_Mode return CCA_Mode_Kind
   with Volatile_Function, Global => (Input => PIB_Attributes);

   procedure Set_Tx_Power (Tx_Power : RF_Power_dBm)
   with
     Global  => (In_Out => PIB_Attributes),
     Depends => (PIB_Attributes => (PIB_Attributes, Tx_Power));

   function Get_Tx_Power return RF_Power_dBm
   with Volatile_Function, Global => (Input => PIB_Attributes);

   ------------------
   -- PHY Identity --
   ------------------

   function Get_Device_ID return Bits_64
   with Global => null;

   ----------------------------
   -- Radio State Management --
   ----------------------------

   type State_Kind is
     (Off,
      --  The radio is off and the radio clock is off

      Sleeping,
      --  The radio is in low-power mode. The radio clock is on so alarms
      --  can be scheduled.

      Exiting_Sleep,
      --  The radio is waking up from low-power mode

      Idle,
      --  The radio is ready to start a transmit/receive operation

      Transmitting,
      --  The radio is transmitting

      Tx_Complete,
      --  The radio has finished transmitting

      Receiving,
      --  The radio is receiving

      Rx_Complete,
      --  The radio has finished receiving

      ED_Scan_Active,
      --  The radio is performing an energy detection scan

      ED_Scan_Complete,
      --  An energy detection scan is complete

      CCA_Scan_Active,
      --  A clear channel assessment (CCA) scan is active

      CCA_Scan_Complete
      --  A clear channel assessment (CCA) scan has completed
     );
   --  Set of states that the PHY can be in at any one time

   function Current_State return State_Kind
   with Inline, Global => (Input => Radio_State);
   --  Get the current state of the PHY

   procedure Go_Idle
   with
     Always_Terminates => False,
     Global            => (Input => Radio_Device, In_Out => Radio_State),
     Depends           =>
       (Radio_State => null, null => (Radio_State, Radio_Device)),
     Pre               => Current_State not in Off | Sleeping,
     Post              => Current_State = Idle;
   --  Force the PHY into the idle state.
   --
   --  This will cancel any in-progress transmit or receive operation.
   --
   --  This is a potentially blocking operation when the PHY is in the
   --  Exiting_Sleep state. If the PHY has not yet finished exiting sleep, then
   --  this procedure blocks until the wakeup is complete before switching to
   --  the Idle state.

   ----------------------
   -- Power management --
   ----------------------

   --  The PHY has two low-power states:
   --   * Off: The radio is off and the radio clock is off.
   --   * Sleeping: The radio is off but the radio clock is on.
   --
   --  To wake up the radio into the Idle state from the Off state:
   --   1. Call Turn_On.
   --   2. Call Exit_Sleep.
   --   3. Optionally wait for the Exit_Sleep_Completed event
   --      (via Wait_For_Event).
   --   4. Call Go_Idle (will block if the radio is still waking up).

   procedure Turn_On
   with
     Inline,
     Global  => (In_Out => (Radio_Device, Radio_State), Output => Radio_Clock),
     Depends =>
       (Radio_Device => Radio_Device,
        Radio_Clock  => null,
        Radio_State  => null,
        null         => Radio_State),
     Pre     => Current_State = Off,
     Post    => Current_State = Sleeping;
   --  Turn on the PHY.
   --
   --  This turns on the radio's clock so alarms can be scheduled. The radio
   --  remains in low-power sleeping mode.

   procedure Turn_Off
   with
     Inline,
     Global  => (In_Out => (Radio_Device, Radio_State), Output => Radio_Clock),
     Depends =>
       (Radio_Device => Radio_Device,
        Radio_Clock  => null,
        Radio_State  => null,
        null         => Radio_State),
     Pre     => Current_State = Sleeping,
     Post    => Current_State = Off;
   --  Turn off the PHY.
   --
   --  This turns off the radio clock. All pending alarms are cancelled.

   procedure Enter_Sleep
   with
     Inline,
     Global  => (In_Out => (Radio_Device, Radio_State, Radio_Clock)),
     Depends =>
       (Radio_Device => Radio_Device,
        Radio_Clock  => Radio_Clock,
        Radio_State  => null,
        null         => Radio_State),
     Pre     => Current_State = Idle,
     Post    => Current_State = Sleeping;
   --  Put the PHY into low-power sleep mode.
   --
   --  This turns off the radio and puts the radio clock into a low-power mode.
   --
   --  Sleep mode can only be entered when the PHY is idle.

   procedure Exit_Sleep
   with
     Inline,
     Global  => (In_Out => (Radio_Device, Radio_State, Radio_Clock)),
     Depends =>
       (Radio_Device => Radio_Device,
        Radio_Clock  => Radio_Clock,
        Radio_State  => null,
        null         => Radio_State),
     Pre     => Current_State = Sleeping,
     Post    => Current_State = Exiting_Sleep;
   --  Wake up the device from low-power sleep mode.
   --
   --  The wakeup process may take some time to finish. The PHY sets the
   --  Wakeup_Complete flag (see WSN.PHY.Events) when When the radio has
   --  finished waking up.

   -------------------
   -- Radio Timings --
   -------------------

   function Symbols_Duration
     (Nb_Symbols : Symbol_Count) return AdaBee.Time_Units.Time_Span
   with
     Inline_Always,
     Global => null,
     Post   =>
       Symbols_Duration'Result in 0.0 .. Max_Symbols_Duration
       and then (Nb_Symbols = 0) = (Symbols_Duration'Result = 0.0);
   --  Calculate the duration of a quantity of symbols based on the PHY's
   --  current symbol rate.

   function Symbol_Time (T : Time_Units.Time) return Symbol_Count
   with Global => null;

   function Packet_Duration
     (Length : Packet_Length_Number) return AdaBee.Time_Units.Time_Span
   with
     Inline,
     Global => null,
     Post   => Packet_Duration'Result in 0.0 .. Max_Symbols_Duration;
   --  Get the duration of an on-air packet

   function Max_Wakeup_Duration return AdaBee.Time_Units.Time_Span
   with
     Inline_Always,
     Global => null,
     Post   => Max_Wakeup_Duration'Result in 0.0 .. 1.0;
   --  Maximum time it should take for the PHY to finish waking up
   --  (i.e. send the Wakeup_Complete event) after calling Exit_Sleep.

   function Max_Tx_Prepare_Time_No_CCA return AdaBee.Time_Units.Time_Span
   with
     Inline_Always,
     Global => null,
     Post   => Max_Tx_Prepare_Time_No_CCA'Result in 0.0 .. 1.0;
   --  Maximum time between calling Transmit_Now and the start of the on-air
   --  preamble when CCA is not used.
   --
   --  For Transmit_Delayed, the Tx_Time should be in the future by at least
   --  this amount of time.

   function Max_Tx_Prepare_Time_CCA return AdaBee.Time_Units.Time_Span
   with
     Inline_Always,
     Global => null,
     Post   => Max_Tx_Prepare_Time_CCA'Result in 0.0 .. 1.0;
   --  Maximum time between calling Transmit_Now and the start of the on-air
   --  preamble when CCA is used.
   --
   --  For Transmit_Delayed, the Tx_Time should be in the future by at least
   --  this amount of time.

   function Max_Rx_Prepare_Time return AdaBee.Time_Units.Time_Span
   with
     Inline_Always,
     Global => null,
     Post   => Max_Rx_Prepare_Time'Result in 0.0 .. 1.0;
   --  Maximum time between calling Receive_Now to when the receiver is
   --  active.
   --
   --  For Receive_Delayed, the Rx_Time should be in the future by at least
   --  this amount of time.

   ----------------
   -- PHY Events --
   ----------------

   --  Events are used by the next higher layer to block/wait for an
   --  asynchronous PHY activity to complete. For example, to wait for a packet
   --  to be received.
   --
   --  The PHY sets event flags to True when certain events occur. For example,
   --  the Tx_Complete event flag is set when packet transmission has
   --  completed.

   type Event_Kind is
     (Operation_Complete,
      --  A wakeup, transmit, receive, or CCA/ED scan operation has completed

      Alarm_1_Triggered,
      --  Radio clock alarm #1 has triggered

      Alarm_2_Triggered,
      --  Radio clock alarm #2 has triggered

      User_Event
      --  Send_User_Event was called
     );

   type Event_Flags_Array is array (Event_Kind) of Boolean;

   procedure Wait_For_Events
     (Events : out Event_Flags_Array;
      Filter : Event_Flags_Array := [others => True])
   with
     Always_Terminates => False,
     Global            =>
       (In_Out => (Radio_Device, Radio_Events, Radio_State, Packet_Info)),
     Depends           =>
       (Radio_Events => (Radio_Events, Filter),
        Radio_Device => (Radio_Device, Radio_Events, Radio_State),
        Radio_State  => (Radio_State, Radio_Events),
        Packet_Info  => (Packet_Info, Radio_Events, Radio_State, Radio_Device),
        Events       => (Radio_Events, Filter)),
     Pre               =>
       --  Must wait for at least one event
       (for some E of Filter => E)

       --  Cannot wait for Operation_Complete or alarm events while the PHY is
       --  in a state that never sends them, unless also waiting for another
       --  event which can occur. This prevents accidentally blocking forever.
       and then
         (case Current_State is
            --  Operation_Complete and alarm events are never sent while the
            --  PHY is off.
            when Off               =>
              (for some E in Filter'Range =>
                 E
                 not in Operation_Complete
                      | Alarm_1_Triggered
                      | Alarm_2_Triggered
                 and then Filter (E)),

            --  All events are accepted while the PHY is doing an active
            --  operation.
            when Exiting_Sleep
               | Transmitting
               | Receiving
               | ED_Scan_Active
               | CCA_Scan_Active   => True,

            --  Operation_Complete is never sent while the PHY is these states
            when Sleeping
               | Idle
               | Tx_Complete
               | Rx_Complete
               | ED_Scan_Complete
               | CCA_Scan_Complete =>
              (for some E in Filter'Range =>
                 E /= Operation_Complete and then Filter (E))),
     Post              => (for some E of Events => E),
     Contract_Cases    =>
       (Current_State = Off               =>
          not Events (Operation_Complete) and then Current_State = Off,

        Current_State = Sleeping          =>
          not Events (Operation_Complete) and then Current_State = Sleeping,

        Current_State = Idle              =>
          not Events (Operation_Complete) and then Current_State = Idle,

        Current_State = Tx_Complete       =>
          not Events (Operation_Complete) and then Current_State = Tx_Complete,

        Current_State = Rx_Complete       =>
          not Events (Operation_Complete) and then Current_State = Rx_Complete,

        Current_State = ED_Scan_Complete  =>
          not Events (Operation_Complete)
          and then Current_State = ED_Scan_Complete,

        Current_State = CCA_Scan_Complete =>
          not Events (Operation_Complete)
          and then Current_State = CCA_Scan_Complete,

        Current_State = Exiting_Sleep     =>
          (if Events (Operation_Complete)
           then Current_State = Idle
           else Current_State = Exiting_Sleep),

        Current_State = CCA_Scan_Active   =>
          (if Events (Operation_Complete)
           then Current_State = CCA_Scan_Complete
           else Current_State = CCA_Scan_Active),

        Current_State = Transmitting      =>
          (if Events (Operation_Complete)
           then Current_State = Tx_Complete
           else Current_State = Transmitting),

        Current_State = Receiving         =>
          (if Events (Operation_Complete)
           then Current_State = Rx_Complete
           else Current_State = Receiving),

        Current_State = ED_Scan_Active    =>
          (if Events (Operation_Complete)
           then Current_State = ED_Scan_Complete
           else Current_State = ED_Scan_Active));
   --  Block until at least one event flag has been set.
   --
   --  This is typically used to wait for the Operation_Complete event to be
   --  set at the end of the current radio operation. When the
   --  Operation_Complete event is set, then the PHY transitions to the next
   --  state.
   --
   --  Any event flags enabled in the Filter are cleared by this procedure
   --  after they are copied to the Events array. Other events not in the
   --  Filter are unchanged.
   --
   --  @param Events The set of event flags that have occurred.
   --  @param Filter The set of events to wait for.

   procedure Wait_For_Event (Event : Event_Kind)
   with
     Always_Terminates => False,
     Global            =>
       (In_Out => (Radio_Device, Radio_Events, Radio_State)),
     Depends           =>
       (Radio_Events => (Radio_Events, Event),
        Radio_Device => (Radio_Device, Radio_Events, Radio_State),
        Radio_State  => (Radio_State, Radio_Events)),
     Pre               =>
       (case Event is
          --  Cannot wait for Operation_Complete while the PHY is in a state
          --  that will never send it.
          when Operation_Complete                    =>
            Current_State
            in Exiting_Sleep
             | Transmitting
             | Receiving
             | ED_Scan_Active
             | CCA_Scan_Active,

          --  Cannot wait for an alarm event while the PHY clock is disabled
          when Alarm_1_Triggered | Alarm_2_Triggered => Current_State /= Off,

          when others                                => True),
     Contract_Cases    =>
       (Current_State = Off               => Current_State = Off,
        Current_State = Sleeping          => Current_State = Sleeping,
        Current_State = Idle              => Current_State = Idle,
        Current_State = Tx_Complete       => Current_State = Tx_Complete,
        Current_State = Rx_Complete       => Current_State = Rx_Complete,
        Current_State = ED_Scan_Complete  => Current_State = ED_Scan_Complete,
        Current_State = CCA_Scan_Complete => Current_State = CCA_Scan_Complete,

        Current_State = Exiting_Sleep     =>
          (if Event = Operation_Complete
           then Current_State = Idle
           else Current_State = Exiting_Sleep),

        Current_State = CCA_Scan_Active   =>
          (if Event = Operation_Complete
           then Current_State = CCA_Scan_Complete
           else Current_State = CCA_Scan_Active),

        Current_State = Transmitting      =>
          (if Event = Operation_Complete
           then Current_State = Tx_Complete
           else Current_State = Transmitting),

        Current_State = Receiving         =>
          (if Event = Operation_Complete
           then Current_State = Rx_Complete
           else Current_State = Receiving),

        Current_State = ED_Scan_Active    =>
          (if Event = Operation_Complete
           then Current_State = ED_Scan_Complete
           else Current_State = ED_Scan_Active));
   --  Block until the specified event occurs
   --
   --  This is typically used to wait for the Operation_Complete event to be
   --  set at the end of the current radio operation. When the
   --  Operation_Complete event is set, then the PHY transitions to the next
   --  state.
   --
   --  All currently set event flags are cleared by this procedure after they
   --  are copied to the Events array.
   --
   --  @param Events The set of event flags that have occurred.

   function Get_Events return Event_Flags_Array
   with
     Inline,
     Volatile_Function,
     Global => (Input => Radio_Events, Proof_In => Radio_State),
     Post   =>
       --  Operation_Complete event is only set in a subset of API states
       (if Get_Events'Result (Operation_Complete)
        then
          Current_State
          in Exiting_Sleep
           | CCA_Scan_Active
           | Transmitting
           | Receiving
           | ED_Scan_Active);
   --  Get the set of currently set event flags.
   --
   --  This does not clear the events.

   function Is_Event_Set (Event : Event_Kind) return Boolean
   with
     Inline,
     Volatile_Function,
     Global => (Input => Radio_Events, Proof_In => Radio_State),
     Post =>
       --  Operation_Complete event is only set in a subset of API states
       (if Event = Operation_Complete and then Is_Event_Set'Result
        then
          Current_State
          in Exiting_Sleep
           | CCA_Scan_Active
           | Transmitting
           | Receiving
           | ED_Scan_Active);
   --  Query if an event flag is set
   --
   --  @param Event The event flag to check

   procedure Send_User_Event
   with
     Inline,
     Global  => (In_Out => Radio_Events),
     Depends => (Radio_Events => Radio_Events);
   --  Send the User_Event event.
   --
   --  This is useful to signal/unblock a task that is currently blocked by
   --  Wait_For_Event.

   procedure Clear_Event (Event : Event_Kind)
   with
     Inline,
     Global  => (In_Out => Radio_Events),
     Depends => (Radio_Events => (Radio_Events, Event));
   --  Clear a specific event flag
   --
   --  @param Event The event to clear.

   procedure Clear_All_Events
   with
     Inline,
     Global  => (Output => Radio_Events),
     Depends => (Radio_Events => null);
   --  Clear all event flags

   -----------------
   -- Radio Clock --
   -----------------

   type Alarm_Number is range 1 .. 2;

   procedure Read_Clock (Now : out Radio_Clock_Time_Range)
   with
     Inline,
     Global  => (Input => (Radio_Clock, Radio_State)),
     Depends => (Now => (Radio_Clock, Radio_State)),
     Post    => (if Current_State = Off then Now = 0.0);
   --  Read the current radio clock's time.
   --
   --  The clock is monotonic time counting the amount of time passed since the
   --  PHY was turned on.
   --
   --  If the PHY is currently off, then the time is zero.

   procedure Set_Alarm
     (Alarm : Alarm_Number; Trigger_At : AdaBee.Time_Units.Time)
   with
     Inline,
     Global  =>
       (In_Out => (Radio_Clock, Radio_Events), Proof_In => Radio_State),
     Depends =>
       (Radio_Events => (Radio_Events, Radio_Clock, Alarm, Trigger_At),
        Radio_Clock  => (Radio_Clock, Alarm, Trigger_At)),
     Pre     => Current_State /= Off;
   --  Set an alarm to trigger the Alarm_Triggered event at the specified
   --  time according to the radio clock.
   --
   --  This clears the Alarm_Triggered event on entry.
   --
   --  If the specified Trigger_At time has already passed, then the
   --  Alarm_Triggered event is set immediately.

   procedure Cancel_Alarm (Alarm : Alarm_Number)
   with
     Inline,
     Global  => (In_Out => Radio_Clock),
     Depends => (Radio_Clock => (Radio_Clock, Alarm));
   --  Cancel a previously set alarm

   ----------------------
   -- Transmit Control --
   ----------------------

   type CCA_Result_Kind is (Clear, Busy);

   --  Packets can be transmitted when the radio is in the Idle state.
   --  To transmit a packet (when the PHY is in the idle state):
   --   1. Call Transmit_Now or Transmit_Delayed.
   --   2. Call Wait_For_Event until the Operation_Complete event is set.
   --
   --  Alternatively, a polling approach can be used:
   --   1. Call Transmit_Now or Transmit_Delayed.
   --   2. Poll Event_Set (Operation_Complete) until True is returned, which
   --      indicates that packet reception has completed.
   --   3. Call Go_Idle to return to the Idle state.

   procedure Transmit_Now (Packet : Byte_Array; Ignore_CCA : Boolean := False)
   with
     Global  =>
       (Input => PIB_Attributes, In_Out => (Radio_Device, Radio_State)),
     Depends =>
       (Radio_Device => (Radio_Device, PIB_Attributes, Packet, Ignore_CCA),
        Radio_State  => null,
        null         => Radio_State),
     Pre     =>
       (Current_State = Idle
        and then Packet'Length in 1 .. Maximum_Packet_Length),
     Post    => Current_State = Transmitting;
   --  Transmit a packet now
   --
   --  If a non-ALOHA CCA mode has been configured and Ignore_CCA is false,
   --  then a CCA scan is performed immediately prior to transmitting the
   --  packet. If the CCA scan indicates the channel is clear then the packet
   --  is transmitted. Otherwise, if the CCA scan indicates the channel is
   --  busy, then the packet is not transmitted. Get_CCA_Result can be called
   --  after the transmit operation is complete to determine the result of
   --  the CCA scan and therefore whether the packet was transmitted.
   --
   --  This clears the Operation_Complete event flag on entry.
   --
   --  This procedure starts the transmit operation then returns immediately.
   --  The Operation_Complete event flag will be set when the transmit is
   --  complete.
   --
   --  @param Packet Buffer containing the packet to transmit.
   --  @param Ignore_CCA When True, the current CCA mode is ignored and the
   --    packet is always transmitted without first performing a CCA scan.

   procedure Transmit_Delayed
     (Packet     : Byte_Array;
      Tx_Time    : AdaBee.Time_Units.Time;
      Ignore_CCA : Boolean := False)
   with
     Global  =>
       (Input  => PIB_Attributes,
        In_Out => (Radio_Device, Radio_State, Radio_Clock)),
     Depends =>
       (Radio_Device =>
          (Radio_Device, PIB_Attributes, Packet, Tx_Time, Ignore_CCA),
        Radio_Clock  => (Radio_Clock, Tx_Time),
        Radio_State  => null,
        null         => Radio_State),
     Pre     => Current_State = Idle,
     Post    => Current_State = Transmitting;
   --  Transmit a packet at the specified time.
   --
   --  If the Tx_Time has already passed, then the packet is transmitted
   --  immediately.
   --
   --  This clears the Operation_Complete event flag on entry.
   --
   --  This procedure starts the transmit operation then returns immediately.
   --  The Operation_Complete event flag will be set when the transmit is
   --  complete.
   --
   --  @param Packet The PDU to transmit.
   --  @param Tx_Time The time when the radio should begin transmitting the
   --    first symbol of the preamble.
   --  @param Ignore_CCA When True, the current CCA mode is ignored and the
   --    packet is always transmitted without first performing a CCA scan.

   procedure Finish_Transmit
   with
     Global  =>
       (Input => Radio_Device, In_Out => Radio_State, Output => Packet_Info),
     Depends =>
       (Radio_State => (Radio_State, Radio_Device),
        Packet_Info => Radio_Device),
     Pre     => Current_State = Transmitting,
     Post    => (Current_State in Transmitting | Tx_Complete);
   --  Check whether the PHY has finished transmitting the packet. If so, then
   --  transition to the Tx_Complete state.

   procedure Get_Tx_Timestamps (Timestamps : out Packet_Timestamps)
   with
     Global  => (Input => Packet_Info, Proof_In => Radio_State),
     Depends => (Timestamps => Packet_Info),
     Pre     => Current_State = Tx_Complete;
   --  Get the timestamps of the
   --
   --  @param Timestamps

   ------------------------------
   -- Clear Channel Assessment --
   ------------------------------

   procedure Start_CCA_Scan
   with
     Global  =>
       (Input => PIB_Attributes, In_Out => (Radio_Device, Radio_State)),
     Depends =>
       (Radio_Device => (Radio_Device, PIB_Attributes),
        Radio_State  => null,
        null         => Radio_State),
     Pre     => Current_State = Idle,
     Post    => Current_State = CCA_Scan_Active;
   --
   --  This clears the Operation_Complete event flag on entry.
   --
   --  This procedure starts the CCA scan operation then returns immediately.
   --  The Operation_Complete event flag will be set when the CCA scan is
   --  complete.

   procedure Start_CCA_Scan_Delayed (CCA_Begin_Time : AdaBee.Time_Units.Time)
   with
     Global  =>
       (Input  => PIB_Attributes,
        In_Out => (Radio_Device, Radio_State, Radio_Clock)),
     Depends =>
       (Radio_Device => (Radio_Device, CCA_Begin_Time, PIB_Attributes),
        Radio_Clock  => (Radio_Clock, CCA_Begin_Time),
        Radio_State  => null,
        null         => Radio_State),
     Pre     => Current_State = Idle,
     Post    => Current_State = CCA_Scan_Active;
   --
   --  This clears the Operation_Complete event flag on entry.
   --
   --  This procedure starts the CCA scan operation then returns immediately.
   --  The Operation_Complete event flag will be set when the CCA scan is
   --  complete.

   procedure Finish_CCA_Scan
   with
     Global  =>
       (Input => Radio_Device, In_Out => Radio_State, Output => Packet_Info),
     Depends =>
       (Radio_State => (Radio_State, Radio_Device),
        Packet_Info => Radio_Device),
     Pre     => Current_State = CCA_Scan_Active,
     Post    => (Current_State in CCA_Scan_Active | CCA_Scan_Complete);

   procedure Get_CCA_Result (CCA_Result : out CCA_Result_Kind)
   with
     Global  => (Input => Packet_Info, Proof_In => Radio_State),
     Depends => (CCA_Result => Packet_Info),
     Pre     => Current_State in Tx_Complete | CCA_Scan_Complete;
   --  Check the result of the Clear Channel Assessment (CCA).
   --
   --  Note that if the current CCA mode is ALOHA, then this always reports
   --  that the channel is Clear.

   -----------------------
   -- Receive Filtering --
   -----------------------

   --  Receive filters can be used to only receive packets that meet the filter
   --  criteria. If the PHY receives a packet that is rejected by the filter,
   --  then it silently ignores the packet and re-enables the receiver to
   --  continue listening. This reduces the amount of processing overhead and
   --  context switching in the MAC layer as only packets that pass the filter
   --  are passed onto the MAC layer.

   type Filter_Kind is
     (
     --  These filters only allow packets with certain MAC Frame Types
     --  defined by Table 7-1 of IEEE 802.15.4-2024
     --  (i.e. checks bits 0..2 of the first octet of the packet)
     Allow_Frame_Type_Beacon,         --  2#000#
      Allow_Frame_Type_Data,           --  2#001#
      Allow_Frame_Type_Ack,            --  2#010#
      Allow_Frame_Type_MAC_Command,    --  2#011#
      Allow_Frame_Type_Reserved,       --  2#100#
      Allow_Frame_Type_Multipurpose,   --  2#101#
      Allow_Frame_Type_Frak,           --  2#110#
      Allow_Frame_Type_Extended,       --  2#111#

      Allow_Invalid_CRC,
      --  Allow packets with an invalid CRC

      Allow_Empty_Packets
      --  Allow zero-length packets
     );

   type Filter_Array is array (Filter_Kind) of Boolean with Pack;

   All_Packets_Allowed_Filter : constant Filter_Array := [others => True];
   --  Filter that allows all packets

   function Get_Receive_Filters return Filter_Array
   with Inline, Global => (Input => Receive_Filters);
   --  Get the currently configured receive filters

   procedure Set_Receive_Filter (Filter : Filter_Kind; Enabled : Boolean)
   with
     Inline,
     Global  => (In_Out => Receive_Filters, Proof_In => Radio_State),
     Depends => (Receive_Filters => (Receive_Filters, Filter, Enabled)),
     Pre     => Current_State in Off | Sleeping | Exiting_Sleep | Idle,
     Post    =>
       Get_Receive_Filters
       = (Get_Receive_Filters'Old with delta Filter => Enabled);
   --  Configure one filter criteria.
   --
   --  The other filter criteria are unchanged.
   --
   --  The receive filters cannot be changed while the the radio is actively
   --  transmitting or receiving.

   function Receive_Filter_Enabled (Filter : Filter_Kind) return Boolean
   with
     Inline,
     Global => (Input => Receive_Filters),
     Post   => Receive_Filter_Enabled'Result = Get_Receive_Filters (Filter);
   --  Check if one filter criteria is enabled

   procedure Set_Receive_Filters (Filters : Filter_Array)
   with
     Inline,
     Global  => (Output => Receive_Filters, Proof_In => Radio_State),
     Depends => (Receive_Filters => Filters),
     Pre     => Current_State in Off | Sleeping | Exiting_Sleep | Idle,
     Post    => Get_Receive_Filters = Filters;
   --  Set all receive filter criteria
   --
   --  The receive filters cannot be changed while the the radio is actively
   --  transmitting or receiving.

   ---------------------
   -- Receive Control --
   ---------------------

   --  Packet reception can be started when the radio is in the Idle state.
   --  To receive a packet:
   --   1. Call Receive_Now or Receive_Delayed.
   --   2. Call Wait_For_Event until the Operation_Complete flag is set.
   --   4. Call Packet_Received to determine whether a packet is available.
   --   5. If a packet was received, then call Get_Received_Packet to get the
   --      received packet and return back to the Idle state.
   --   6. If a packet was NOT received, then call Go_Idle to return back to
   --      the Idle state.
   --
   --  Alternatively, a polling approach can be used:
   --   1. Call Receive_Now or Receive_Delayed.
   --   2. Call Finish_Receive, then check if Current_State = Rx_Complete

   type Receive_Metadata is record
      RSSI : RF_Power_dBm;
      --  Received Signal Strength Indication of the received packet, in dBm

      LQI : LQI_Number;
      --  Link Quality Indicator of the received packet

      Timestamps : Packet_Timestamps;
      --  Timestamps of various parts of the received packet

      CRC_Valid : Boolean;
      --  True if the packet CRC is correct (CRC is in the last two octets) or
      --  False otherwise.

   end record;

   procedure Receive_Now
     (Rx_End_Time  : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last;
      SFD_Deadline : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last)
   with
     Global  =>
       (Input  => (PIB_Attributes, Receive_Filters),
        In_Out => (Radio_Device, Radio_State, Radio_Clock)),
     Depends =>
       (Radio_Device =>
          (Radio_Device,
           Rx_End_Time,
           SFD_Deadline,
           PIB_Attributes,
           Receive_Filters),
        Radio_Clock  => (Radio_Clock, Rx_End_Time, SFD_Deadline),
        Radio_State  => null,
        null         => Radio_State),
     Pre     => Current_State = Idle,
     Post    => Current_State = Receiving;
   --  Enable the receiver now
   --
   --  This enables the receiver until the specified Rx_End_Time.
   --  The Operation_Complete event is generated when either a packet is
   --  received or the specified Rx_End_Time is reached.
   --
   --  This clears the Operation_Complete event flag on entry.
   --
   --  This procedure starts the receive operation then returns immediately.
   --  The Operation_Complete event flag will be set when the receive is
   --  complete.
   --
   --  @param Rx_End_Time The time at which the receiver should be turned off.
   --  @param SFD_Deadline Abort the receive if the SFD is not received by this
   --                      time.

   procedure Receive_Delayed
     (Rx_Begin_Time : AdaBee.Time_Units.Time;
      Rx_End_Time   : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last;
      SFD_Deadline  : AdaBee.Time_Units.Time := AdaBee.Time_Units.Time'Last)
   with
     Global  =>
       (Input  => (PIB_Attributes, Receive_Filters),
        In_Out => (Radio_Device, Radio_State, Radio_Clock)),
     Depends =>
       (Radio_Device =>
          (Radio_Device,
           Rx_Begin_Time,
           Rx_End_Time,
           SFD_Deadline,
           PIB_Attributes,
           Receive_Filters),
        Radio_Clock  =>
          (Radio_Clock, Rx_Begin_Time, Rx_End_Time, SFD_Deadline),
        Radio_State  => null,
        null         => Radio_State),
     Pre     => (Current_State = Idle and then Rx_Begin_Time < Rx_End_Time),
     Post    => Current_State = Receiving;
   --  Enable the receiver at the specified time
   --
   --  This enables the receiver at the specified Rx_Begin_Time and keeps the
   --  receiver active until either a packet is received or the specified
   --  Rx_End_Time is reached, at which point an Operation_Complete event is
   --  generated.
   --
   --  This clears the Operation_Complete event flag on entry.
   --
   --  This procedure starts the receive operation then returns immediately.
   --  The Operation_Complete event flag will be set when the receive is
   --  complete.
   --
   --  @param Rx_Begin_Time The time at which the receiver should be turned on.
   --  @param Rx_End_Time The time at which the receiver should be turned off.
   --  @param SFD_Deadline Abort the receive if the SFD is not received by this
   --                      time.

   procedure Finish_Receive
   with
     Global  =>
       (Input => Radio_Device, In_Out => Radio_State, Output => Packet_Info),
     Depends =>
       (Radio_State => (Radio_State, Radio_Device),
        Packet_Info => Radio_Device),
     Pre     => Current_State = Receiving,
     Post    => (Current_State in Receiving | Rx_Complete);
   --  Check whether the PHY has finished a packet reception operation.
   --  If so, then transition to the Rx_Complete state.

   function Packet_Received return Boolean
   with
     Inline,
     Global => (Proof_In => Radio_State, Input => Packet_Info),
     Post   =>
       (if Current_State /= Rx_Complete then not Packet_Received'Result);
   --  Check if a packet has been received and is available for reading
   --
   --  @return True if a packet has been received and can be read via
   --          Get_Received_Packet. False otherwise.

   procedure Get_Received_Packet
     (Packet   : out Byte_Array;
      Length   : out Packet_Length_Number;
      Metadata : out Receive_Metadata)
   with
     Global                 =>
       (Input => Packet_Info, Proof_In => (Radio_State, Receive_Filters)),
     Depends                => ((Packet, Length, Metadata) => Packet_Info),
     Relaxed_Initialization => Packet,
     Pre                    =>
       (Current_State = Rx_Complete
        and then Packet_Received
        and then Packet'Length >= Maximum_Packet_Length),
     Post                   =>
       Packet (Packet'First .. Packet'First + Length - 1)'Initialized

       and then
         (if not Receive_Filter_Enabled (Allow_Empty_Packets) then Length > 0)

       and then
         (if not Receive_Filter_Enabled (Allow_Invalid_CRC)
          then Length >= 2 and then Metadata.CRC_Valid)

       and then
         (if Length > 0
          then
            (declare
               Frame_Type : constant Interfaces.Unsigned_8 :=
                 Packet (Packet'First) and 2#111#;
             begin
               (if not Receive_Filter_Enabled (Allow_Frame_Type_Beacon)
                then Frame_Type /= 2#000#)

               and then
                 (if not Receive_Filter_Enabled (Allow_Frame_Type_Data)
                  then Frame_Type /= 2#001#)

               and then
                 (if not Receive_Filter_Enabled (Allow_Frame_Type_Ack)
                  then Frame_Type /= 2#010#)

               and then
                 (if not Receive_Filter_Enabled (Allow_Frame_Type_MAC_Command)
                  then Frame_Type /= 2#011#)

               and then
                 (if not Receive_Filter_Enabled (Allow_Frame_Type_Reserved)
                  then Frame_Type /= 2#100#)

               and then
                 (if not Receive_Filter_Enabled (Allow_Frame_Type_Multipurpose)
                  then Frame_Type /= 2#101#)

               and then
                 (if not Receive_Filter_Enabled (Allow_Frame_Type_Frak)
                  then Frame_Type /= 2#110#)

               and then
                 (if not Receive_Filter_Enabled (Allow_Frame_Type_Extended)
                  then Frame_Type /= 2#111#)));
   --  Get the packet that was received.
   --
   --  This can only be called when the PHY is in the Rx_Complete state and
   --  has actually received a packet.
   --
   --  @param Packet Buffer to where the received packet is written.
   --  @param Length The length of the received packet in bytes.
   --  @param Metadata Information about the received packet (RSSI, LQI, etc).

   -------------------------------
   -- Energy Detection Scanning --
   -------------------------------

   type ED_Range is range 0 .. 255 with Size => 8;
   --  Energy Detection (ED) measurement value specified in Section 11.2.6 of
   --  IEEE 802.15.4-2024.
   --
   --  The minimum ED value (zero) indicates received power less than 10 dB
   --  above the lowest receiver sensitivity, in dBm.

   procedure Start_ED_Scan (Duration : AdaBee.Time_Units.Time_Span)
   with
     Global  =>
       (Input => PIB_Attributes, In_Out => (Radio_Device, Radio_State)),
     Depends =>
       (Radio_Device => (Radio_Device, Duration, PIB_Attributes),
        Radio_State  => null,
        null         => Radio_State),
     Pre     => Current_State = Idle and then Duration > 0.0,
     Post    => Current_State = ED_Scan_Active;
   --  Start an energy detection scan.
   --
   --  This clears the Operation_Complete event flag on entry.
   --
   --  @param Duration The duration of the scan.

   procedure Finish_ED_Scan
   with
     Global  =>
       (Input => Radio_Device, In_Out => Radio_State, Output => Packet_Info),
     Depends =>
       (Radio_State => (Radio_State, Radio_Device),
        Packet_Info => Radio_Device),
     Pre     => Current_State = ED_Scan_Active,
     Post    => Current_State in ED_Scan_Active | ED_Scan_Complete;
   --  Finish an energy detection scan.
   --
   --  This transitions the PHY to the ED_Scan_Complete state if the scan
   --  is complete. If the scan is still ongoing then the PHY remains in the
   --  ED_Scan_Active state and this procedure should be polled again,
   --  or use Wait_For_Event to wait for the Operation_Complete event.

   procedure Get_ED_Scan_Result (Max_ED : out ED_Range)
   with
     Global  => (Input => Packet_Info, Proof_In => Radio_State),
     Depends => (Max_ED => Packet_Info),
     Pre     => Current_State = ED_Scan_Complete;
   --  Get the energy detection scan result and transition to the Idle state.
   --
   --  @param Max_ED The maximum energy level detected during the scan, in dBm.

end AdaBee.PHY;
