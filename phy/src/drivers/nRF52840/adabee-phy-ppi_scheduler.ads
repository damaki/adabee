--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
pragma Partition_Elaboration_Policy (Sequential);

with System;

with NRF52840;       use NRF52840;
with NRF52840.RTC;   use NRF52840.RTC;
with NRF52840.TIMER; use NRF52840.TIMER;

with AdaBee.BSP.Config;
with AdaBee.Time_Units; use AdaBee.Time_Units;

--  This package provides a facility for triggering PPI events at specific
--  times and capturing timestamps when specific PPI events occur.
--
--  The scheduler uses an RTC peripheral for timekeeping, so its timing
--  accuracy depends on the accuracy of the LFCLK.
--
--  The scheduler supports two operating modes:
--   * low-power: The scheduler runs from the RTC only, with timing precision
--     of +/- 30.5 us. Only Low_Power alarms are supported in this mode.
--   * high-precision: The scheduler runs from the RTC + TIMER, with timing
--     precision of 1 us. Both Low_Power and High_Precision alarms are
--     supported in this mode.
--
--  Alarms can be used to schedule PPI events to be triggered at specific
--  times. The scheduler has 3 independent alarm channels, with each channel
--  supporting one Low_Power alarm and one High_Precision alarm. High_Precision
--  alarms can be used only while the scheduler is in High_Precision mode.
--  Low_Power alarms can be used in any mode.
--

private package AdaBee.PHY.PPI_Scheduler
  with SPARK_Mode => Off
is

   use type System.Address;

   type Mode_Type is (Low_Power, High_Precision);

   subtype HP_Channel_Number is Natural range 0 .. 3;
   subtype LP_Channel_Number is Natural range 0 .. 2;

   type Alarm_Data is record
      Expiry_Time : Time := 0.0;
      EEP_Address : System.Address := System.Null_Address;
      Enabled     : Boolean := False;
      Scheduled   : Boolean := False;
   end record
   with Predicate => (if Enabled then EEP_Address /= System.Null_Address);

   type HP_Channel_Alarm_Data_Array is array (HP_Channel_Number) of Alarm_Data;
   type LP_Channel_Alarm_Data_Array is array (LP_Channel_Number) of Alarm_Data;

   protected Scheduler
     with Interrupt_Priority => System.Interrupt_Priority'Last
   is

      procedure Start;
      --  Start the scheduler.
      --
      --  This procedure has no effect if the scheduler is already started.

      procedure Stop;
      --  Stop the scheduler.

      procedure Read_Clock (Now : out AdaBee.Time_Units.Time);
      --  Get the current clock time
      --
      --  The time is monotonic and starts from 0.0 when the scheduler is
      --  started.

      function Mode return Mode_Type;
      --  Get the current operating mode of the timer

      procedure Set_Mode (New_Mode : Mode_Type);
      --  Change the current operating mode.
      --
      --  This procedure has no effect if the scheduler is stopped.
      --
      --  WARNING: Changing the mode from High_Precision to Low_Power will
      --  cancel any high precision alarms, and will disable the capture
      --  mechanism.

      ------------------------
      -- Event Timestamping --
      ------------------------

      --  These procedures provide a facility for timestamping an event via the
      --  PPI.
      --
      --  To timestamp an event, call Prepare_Capture to configure one of the
      --  scheduler's channels to timestamp the event. The address of a task
      --  register is output which the caller should configure to the desired
      --  PPI channel.
      --
      --  Once the event has occurred, the the timestamp can then be retrieved
      --  by calling Get_Capture_Timestamp.
      --
      --  WARNING: This event timestamping mechanism only works while the
      --  scheduler is in High_Precision mode. It is not available in Low_Power
      --  mode.

      procedure Prepare_Capture
        (Channel : HP_Channel_Number; TEP : out UInt32);
      --  Prepare the scheduler to timestamp a PPI event.
      --
      --  TEP is set to the Task Endpoint that should be timestamped when
      --  triggered.
      --
      --  This cancels any high precision alarm that has been set on the
      --  specified channel.

      procedure Get_Capture_Timestamp
        (Channel : HP_Channel_Number; Timestamp : out Time);
      --  Get the timestamp that was captured after a previous call to
      --  Prepare_Capture.
      --
      --  WARNING: The timestamp is valid only after the event has actually
      --  occurred.
      --
      --  WARNING: The timestamp should be retrieved as soon as possible after
      --  the event, though the timestamp does remain valid for one TIMER
      --  period (a little over 1h 11m), or until Prepare_Capture or Set_Alarm
      --  are called on the specified channel.

      ------------
      -- Alarms --
      ------------

      --  Alarms are used to trigger a PPI channel at a specific time.

      procedure Set_Low_Power_Alarm
        (Channel         : LP_Channel_Number;
         Trigger_At      : Time;
         EEP_Address     : System.Address;
         Already_Expired : out Boolean)
      with Pre => EEP_Address /= System.Null_Address;
      --  Configure an event to trigger at the specified time based off the
      --  Low Power clock (~30.5 us accuracy).
      --
      --  @param Channel Which alarm to set.
      --
      --  @param Trigger_At The time at which the event should be triggered.
      --
      --  @param EEP_Address The address of the Event Endpoint (EEP) register
      --         in a PPI channel to be configured. The scheduler will write to
      --         the register shortly before the Trigger_At time, then the
      --         event will be generated at the Trigger_At time.
      --
      --  @param Already_Expired This is True when the Trigger_At time has
      --         already passed, or if that time was reached before the alarm
      --         could be fully configured. The event is guaranteed to not have
      --         been triggered when this is True.

      procedure Set_High_Precision_Alarm
        (Channel         : HP_Channel_Number;
         Trigger_At      : Time;
         EEP_Address     : System.Address;
         Already_Expired : out Boolean)
      with Pre => EEP_Address /= System.Null_Address;
      --  Configure an event to trigger at the specified time based off the
      --  High Precision clock (1 us accuracy).
      --
      --  @param Channel Which alarm to set.
      --
      --  @param Trigger_At The time at which the event should be triggered.
      --
      --  @param EEP_Address The address of the Event Endpoint (EEP) register
      --         in a PPI channel to be configured. The scheduler will write to
      --         the register shortly before the Trigger_At time, then the
      --         event will be generated at the Trigger_At time.
      --
      --  @param Already_Expired This is True when the Trigger_At time has
      --         already passed, or if that time was reached before the alarm
      --         could be fully configured. The event is guaranteed to not have
      --         been triggered when this is True.

      procedure Cancel_Low_Power_Alarm (Channel : LP_Channel_Number);
      --  Cancel a previously set low power alarm.
      --
      --  Note that the alarm might have triggered before the alarm could be
      --  fully cancelled.
      --
      --  @param Channel Which alarm channel to cancel.
      --  @param Alarm_Mode Which alarm to cancel in the channel.

      procedure Cancel_High_Precision_Alarm (Channel : HP_Channel_Number);
      --  Cancel a previously set high precision alarm.
      --
      --  Note that the alarm might have triggered before the alarm could be
      --  fully cancelled.
      --
      --  @param Channel Which alarm channel to cancel.
      --  @param Alarm_Mode Which alarm to cancel in the channel.

   private

      procedure Read_RTC_Counter (Counter : out UInt24);
      --  Read the current value of the 24-bit RTC counter in ticks.
      --
      --  This updates RTC_Time_Hi if an RTC overflow is detected.

      procedure Read_RTC_Time (Now : out AdaBee.Time_Units.Time);
      --  Read the current RTC time.
      --
      --  This updates RTC_Time_Hi if an RTC overflow is detected.

      procedure Read_TIMER_Time
        (Now : out AdaBee.Time_Units.Time; Now_Ticks : out UInt32);
      --  Read the current high-precision TIMER time.

      procedure Read_TIMER_COUNTER (Counter : out UInt32)
      with Inline_Always;
      --  Read the TIMER's COUNTER register

      procedure Get_TIMER_Sync_Time
        (Sync_Time_Ticks : out UInt32; Sync_Time : out Time);
      --  Get the time of the last synchronisation event between the RTC and
      --  TIMER clocks.
      --
      --  This also detects RTC overflows and updates RTC_Time_Hi accordingly.

      procedure Enter_Low_Power_Mode;
      --  Turn off the TIMER peripheral

      procedure Enter_High_Precision_Mode;
      --  Enable the TIMER peripheral and perform initial calibration

      procedure Schedule_High_Precision_Alarm
        (Channel : HP_Channel_Number; Now : Time; Now_Ticks : UInt32);
      --  Program the TIMER peripheral to generate an event and interrupt
      --  when the specified alarm triggers.
      --
      --  This must be called ONLY when the alarm associated with the specified
      --  channel is going to expire within the next TIMER period. It must
      --  not be called for alarms that are in the very far future.

      procedure Schedule_Low_Power_Alarm (Channel : LP_Channel_Number);
      --  Program the RTC peripheral to generate an event and interrupt
      --  when the specified alarm triggers.
      --
      --  This must be called ONLY when the alarm associated with the specified
      --  channel is going to expire within the next RTC period. It must
      --  not be called for alarms that are in the very far future.

      function Earliest_Alarm_Time (Include_Scheduled : Boolean) return Time;
      --  Get the time of the earliest pending alarm.
      --
      --  If Include_Scheduled is False then only alarms that are enabled but
      --  have not yet been scheduled are considered.
      --
      --  If Include_Scheduled is True then all enabled alarms are considered.
      --
      --  If there are no matching alarms, then Time'Last is returned.

      procedure Schedule_Next_Wakeup;
      --  Schedule an RTC interrupt.
      --
      --  This schedules an interrupt to occur slightly before the next
      --  enabled but unscheduled alarm, or within one RTC period if the next
      --  alarm is further away than an RTC period about (i.e. within 8m 32s).

      procedure RTC_Interrupt_Handler
      with Attach_Handler => AdaBee.BSP.Config.PPI_Scheduler_RTC_Interrupt;
      --  Interrupt handler for the RTC IRQ
      --
      --  This handler:
      --   * checks for RTC overflows and updates RTC_Time_Hi accordingly;
      --   * schedules any alarms that will expire shortly;
      --   * schedules the next RTC interrupt.

      procedure TIMER_Interrupt_Handler
      with Attach_Handler => AdaBee.BSP.Config.PPI_Scheduler_TIMER_Interrupt;
      --  Interrupt handler for the TIMER IRQ
      --
      --  This checks for TIMER overflows and updates TIMER_Time_Hi
      --  accordingly, and cleans up any high-precision alarms that have
      --  expired.

      Started      : Boolean := False;
      Current_Mode : Mode_Type := Low_Power;
      LP_Alarms    : LP_Channel_Alarm_Data_Array := [others => <>];
      HP_Alarms    : HP_Channel_Alarm_Data_Array := [others => <>];
      RTC_Time_Hi  : AdaBee.Time_Units.Time := 0.0;

   end Scheduler;

end AdaBee.PHY.PPI_Scheduler;
