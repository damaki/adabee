pragma Style_Checks (Off);

--  Copyright (c) 2010 - 2018, Nordic Semiconductor ASA
--
--  All rights reserved.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions are met:
--
--  1. Redistributions of source code must retain the above copyright notice,
--  this list of conditions and the following disclaimer.
--
--  2. Redistributions in binary form, except as embedded into a Nordic
--  Semiconductor ASA integrated circuit in a product or a software update
--  for such product, must reproduce the above copyright notice, this list
--  of conditions and the following disclaimer in the documentation and/or
--  other materials provided with the distribution.
--
--  3. Neither the name of Nordic Semiconductor ASA nor the names of its
--  contributors may be used to endorse or promote products derived from
--  this software without specific prior written permission.
--
--  4. This software, with or without modification, must only be used with a
--  Nordic Semiconductor ASA integrated circuit.
--
--  5. Any software provided in binary form under this license must not be
--  reverse engineered, decompiled, modified and/or disassembled.
--
--  THIS SOFTWARE IS PROVIDED BY NORDIC SEMICONDUCTOR ASA "AS IS" AND ANY
--  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--  WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A
--  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL NORDIC SEMICONDUCTOR
--  ASA OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
--  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
--  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
--  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
--  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--

--  This spec has been automatically generated from nrf52840.svd

pragma Restrictions (No_Elaboration_Code);

with System;

package NRF52840.LPCOMP is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   subtype TASKS_START_TASKS_START_Field is NRF52840.Bit;

   --  Start comparator
   type TASKS_START_Register is record
      --  Write-only.
      TASKS_START   : TASKS_START_TASKS_START_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_START_Register use record
      TASKS_START   at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_STOP_TASKS_STOP_Field is NRF52840.Bit;

   --  Stop comparator
   type TASKS_STOP_Register is record
      --  Write-only.
      TASKS_STOP    : TASKS_STOP_TASKS_STOP_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_STOP_Register use record
      TASKS_STOP    at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_SAMPLE_TASKS_SAMPLE_Field is NRF52840.Bit;

   --  Sample comparator value
   type TASKS_SAMPLE_Register is record
      --  Write-only.
      TASKS_SAMPLE  : TASKS_SAMPLE_TASKS_SAMPLE_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_SAMPLE_Register use record
      TASKS_SAMPLE  at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_READY_EVENTS_READY_Field is NRF52840.Bit;

   --  LPCOMP is ready and output is valid
   type EVENTS_READY_Register is record
      EVENTS_READY  : EVENTS_READY_EVENTS_READY_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_READY_Register use record
      EVENTS_READY  at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_DOWN_EVENTS_DOWN_Field is NRF52840.Bit;

   --  Downward crossing
   type EVENTS_DOWN_Register is record
      EVENTS_DOWN   : EVENTS_DOWN_EVENTS_DOWN_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_DOWN_Register use record
      EVENTS_DOWN   at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_UP_EVENTS_UP_Field is NRF52840.Bit;

   --  Upward crossing
   type EVENTS_UP_Register is record
      EVENTS_UP     : EVENTS_UP_EVENTS_UP_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_UP_Register use record
      EVENTS_UP     at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_CROSS_EVENTS_CROSS_Field is NRF52840.Bit;

   --  Downward or upward crossing
   type EVENTS_CROSS_Register is record
      EVENTS_CROSS  : EVENTS_CROSS_EVENTS_CROSS_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_CROSS_Register use record
      EVENTS_CROSS  at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   --  Shortcut between READY event and SAMPLE task
   type SHORTS_READY_SAMPLE_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_READY_SAMPLE_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between READY event and STOP task
   type SHORTS_READY_STOP_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_READY_STOP_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between DOWN event and STOP task
   type SHORTS_DOWN_STOP_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_DOWN_STOP_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between UP event and STOP task
   type SHORTS_UP_STOP_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_UP_STOP_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between CROSS event and STOP task
   type SHORTS_CROSS_STOP_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_CROSS_STOP_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut register
   type SHORTS_Register is record
      --  Shortcut between READY event and SAMPLE task
      READY_SAMPLE  : SHORTS_READY_SAMPLE_Field := NRF52840.LPCOMP.Disabled;
      --  Shortcut between READY event and STOP task
      READY_STOP    : SHORTS_READY_STOP_Field := NRF52840.LPCOMP.Disabled;
      --  Shortcut between DOWN event and STOP task
      DOWN_STOP     : SHORTS_DOWN_STOP_Field := NRF52840.LPCOMP.Disabled;
      --  Shortcut between UP event and STOP task
      UP_STOP       : SHORTS_UP_STOP_Field := NRF52840.LPCOMP.Disabled;
      --  Shortcut between CROSS event and STOP task
      CROSS_STOP    : SHORTS_CROSS_STOP_Field := NRF52840.LPCOMP.Disabled;
      --  unspecified
      Reserved_5_31 : NRF52840.UInt27 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SHORTS_Register use record
      READY_SAMPLE  at 0 range 0 .. 0;
      READY_STOP    at 0 range 1 .. 1;
      DOWN_STOP     at 0 range 2 .. 2;
      UP_STOP       at 0 range 3 .. 3;
      CROSS_STOP    at 0 range 4 .. 4;
      Reserved_5_31 at 0 range 5 .. 31;
   end record;

   --  Write '1' to enable interrupt for READY event
   type INTENSET_READY_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_READY_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for READY event
   type INTENSET_READY_Field_1 is
     (--  Reset value for the field
      INTENSET_READY_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_READY_Field_1 use
     (INTENSET_READY_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for DOWN event
   type INTENSET_DOWN_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_DOWN_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for DOWN event
   type INTENSET_DOWN_Field_1 is
     (--  Reset value for the field
      INTENSET_DOWN_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_DOWN_Field_1 use
     (INTENSET_DOWN_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for UP event
   type INTENSET_UP_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_UP_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for UP event
   type INTENSET_UP_Field_1 is
     (--  Reset value for the field
      INTENSET_UP_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_UP_Field_1 use
     (INTENSET_UP_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for CROSS event
   type INTENSET_CROSS_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_CROSS_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for CROSS event
   type INTENSET_CROSS_Field_1 is
     (--  Reset value for the field
      INTENSET_CROSS_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_CROSS_Field_1 use
     (INTENSET_CROSS_Field_Reset => 0,
      Set => 1);

   --  Enable interrupt
   type INTENSET_Register is record
      --  Write '1' to enable interrupt for READY event
      READY         : INTENSET_READY_Field_1 := INTENSET_READY_Field_Reset;
      --  Write '1' to enable interrupt for DOWN event
      DOWN          : INTENSET_DOWN_Field_1 := INTENSET_DOWN_Field_Reset;
      --  Write '1' to enable interrupt for UP event
      UP            : INTENSET_UP_Field_1 := INTENSET_UP_Field_Reset;
      --  Write '1' to enable interrupt for CROSS event
      CROSS         : INTENSET_CROSS_Field_1 := INTENSET_CROSS_Field_Reset;
      --  unspecified
      Reserved_4_31 : NRF52840.UInt28 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENSET_Register use record
      READY         at 0 range 0 .. 0;
      DOWN          at 0 range 1 .. 1;
      UP            at 0 range 2 .. 2;
      CROSS         at 0 range 3 .. 3;
      Reserved_4_31 at 0 range 4 .. 31;
   end record;

   --  Write '1' to disable interrupt for READY event
   type INTENCLR_READY_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_READY_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for READY event
   type INTENCLR_READY_Field_1 is
     (--  Reset value for the field
      INTENCLR_READY_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_READY_Field_1 use
     (INTENCLR_READY_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for DOWN event
   type INTENCLR_DOWN_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_DOWN_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for DOWN event
   type INTENCLR_DOWN_Field_1 is
     (--  Reset value for the field
      INTENCLR_DOWN_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_DOWN_Field_1 use
     (INTENCLR_DOWN_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for UP event
   type INTENCLR_UP_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_UP_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for UP event
   type INTENCLR_UP_Field_1 is
     (--  Reset value for the field
      INTENCLR_UP_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_UP_Field_1 use
     (INTENCLR_UP_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for CROSS event
   type INTENCLR_CROSS_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_CROSS_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for CROSS event
   type INTENCLR_CROSS_Field_1 is
     (--  Reset value for the field
      INTENCLR_CROSS_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_CROSS_Field_1 use
     (INTENCLR_CROSS_Field_Reset => 0,
      Clear => 1);

   --  Disable interrupt
   type INTENCLR_Register is record
      --  Write '1' to disable interrupt for READY event
      READY         : INTENCLR_READY_Field_1 := INTENCLR_READY_Field_Reset;
      --  Write '1' to disable interrupt for DOWN event
      DOWN          : INTENCLR_DOWN_Field_1 := INTENCLR_DOWN_Field_Reset;
      --  Write '1' to disable interrupt for UP event
      UP            : INTENCLR_UP_Field_1 := INTENCLR_UP_Field_Reset;
      --  Write '1' to disable interrupt for CROSS event
      CROSS         : INTENCLR_CROSS_Field_1 := INTENCLR_CROSS_Field_Reset;
      --  unspecified
      Reserved_4_31 : NRF52840.UInt28 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENCLR_Register use record
      READY         at 0 range 0 .. 0;
      DOWN          at 0 range 1 .. 1;
      UP            at 0 range 2 .. 2;
      CROSS         at 0 range 3 .. 3;
      Reserved_4_31 at 0 range 4 .. 31;
   end record;

   --  Result of last compare. Decision point SAMPLE task.
   type RESULT_RESULT_Field is
     (--  Input voltage is below the reference threshold (VIN+ &lt; VIN-).
      Below,
      --  Input voltage is above the reference threshold (VIN+ &gt; VIN-).
      Above)
     with Size => 1;
   for RESULT_RESULT_Field use
     (Below => 0,
      Above => 1);

   --  Compare result
   type RESULT_Register is record
      --  Read-only. Result of last compare. Decision point SAMPLE task.
      RESULT        : RESULT_RESULT_Field;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for RESULT_Register use record
      RESULT        at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   --  Enable or disable LPCOMP
   type ENABLE_ENABLE_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 2;
   for ENABLE_ENABLE_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable LPCOMP
   type ENABLE_Register is record
      --  Enable or disable LPCOMP
      ENABLE        : ENABLE_ENABLE_Field := NRF52840.LPCOMP.Disabled;
      --  unspecified
      Reserved_2_31 : NRF52840.UInt30 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for ENABLE_Register use record
      ENABLE        at 0 range 0 .. 1;
      Reserved_2_31 at 0 range 2 .. 31;
   end record;

   --  Analog pin select
   type PSEL_PSEL_Field is
     (--  AIN0 selected as analog input
      AnalogInput0,
      --  AIN1 selected as analog input
      AnalogInput1,
      --  AIN2 selected as analog input
      AnalogInput2,
      --  AIN3 selected as analog input
      AnalogInput3,
      --  AIN4 selected as analog input
      AnalogInput4,
      --  AIN5 selected as analog input
      AnalogInput5,
      --  AIN6 selected as analog input
      AnalogInput6,
      --  AIN7 selected as analog input
      AnalogInput7)
     with Size => 3;
   for PSEL_PSEL_Field use
     (AnalogInput0 => 0,
      AnalogInput1 => 1,
      AnalogInput2 => 2,
      AnalogInput3 => 3,
      AnalogInput4 => 4,
      AnalogInput5 => 5,
      AnalogInput6 => 6,
      AnalogInput7 => 7);

   --  Input pin select
   type PSEL_Register is record
      --  Analog pin select
      PSEL          : PSEL_PSEL_Field := NRF52840.LPCOMP.AnalogInput0;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for PSEL_Register use record
      PSEL          at 0 range 0 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   --  Reference select
   type REFSEL_REFSEL_Field is
     (--  VDD * 1/8 selected as reference
      Ref1_8Vdd,
      --  VDD * 2/8 selected as reference
      Ref2_8Vdd,
      --  VDD * 3/8 selected as reference
      Ref3_8Vdd,
      --  VDD * 4/8 selected as reference
      Ref4_8Vdd,
      --  VDD * 5/8 selected as reference
      Ref5_8Vdd,
      --  VDD * 6/8 selected as reference
      Ref6_8Vdd,
      --  VDD * 7/8 selected as reference
      Ref7_8Vdd,
      --  External analog reference selected
      ARef,
      --  VDD * 1/16 selected as reference
      Ref1_16Vdd,
      --  VDD * 3/16 selected as reference
      Ref3_16Vdd,
      --  VDD * 5/16 selected as reference
      Ref5_16Vdd,
      --  VDD * 7/16 selected as reference
      Ref7_16Vdd,
      --  VDD * 9/16 selected as reference
      Ref9_16Vdd,
      --  VDD * 11/16 selected as reference
      Ref11_16Vdd,
      --  VDD * 13/16 selected as reference
      Ref13_16Vdd,
      --  VDD * 15/16 selected as reference
      Ref15_16Vdd)
     with Size => 4;
   for REFSEL_REFSEL_Field use
     (Ref1_8Vdd => 0,
      Ref2_8Vdd => 1,
      Ref3_8Vdd => 2,
      Ref4_8Vdd => 3,
      Ref5_8Vdd => 4,
      Ref6_8Vdd => 5,
      Ref7_8Vdd => 6,
      ARef => 7,
      Ref1_16Vdd => 8,
      Ref3_16Vdd => 9,
      Ref5_16Vdd => 10,
      Ref7_16Vdd => 11,
      Ref9_16Vdd => 12,
      Ref11_16Vdd => 13,
      Ref13_16Vdd => 14,
      Ref15_16Vdd => 15);

   --  Reference select
   type REFSEL_Register is record
      --  Reference select
      REFSEL        : REFSEL_REFSEL_Field := NRF52840.LPCOMP.Ref5_8Vdd;
      --  unspecified
      Reserved_4_31 : NRF52840.UInt28 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for REFSEL_Register use record
      REFSEL        at 0 range 0 .. 3;
      Reserved_4_31 at 0 range 4 .. 31;
   end record;

   --  External analog reference select
   type EXTREFSEL_EXTREFSEL_Field is
     (--  Use AIN0 as external analog reference
      AnalogReference0,
      --  Use AIN1 as external analog reference
      AnalogReference1)
     with Size => 1;
   for EXTREFSEL_EXTREFSEL_Field use
     (AnalogReference0 => 0,
      AnalogReference1 => 1);

   --  External reference select
   type EXTREFSEL_Register is record
      --  External analog reference select
      EXTREFSEL     : EXTREFSEL_EXTREFSEL_Field :=
                       NRF52840.LPCOMP.AnalogReference0;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EXTREFSEL_Register use record
      EXTREFSEL     at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   --  Analog detect configuration
   type ANADETECT_ANADETECT_Field is
     (--  Generate ANADETECT on crossing, both upward crossing and downward crossing
      Cross,
      --  Generate ANADETECT on upward crossing only
      Up,
      --  Generate ANADETECT on downward crossing only
      Down)
     with Size => 2;
   for ANADETECT_ANADETECT_Field use
     (Cross => 0,
      Up => 1,
      Down => 2);

   --  Analog detect configuration
   type ANADETECT_Register is record
      --  Analog detect configuration
      ANADETECT     : ANADETECT_ANADETECT_Field := NRF52840.LPCOMP.Cross;
      --  unspecified
      Reserved_2_31 : NRF52840.UInt30 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for ANADETECT_Register use record
      ANADETECT     at 0 range 0 .. 1;
      Reserved_2_31 at 0 range 2 .. 31;
   end record;

   --  Comparator hysteresis enable
   type HYST_HYST_Field is
     (--  Comparator hysteresis disabled
      Disabled,
      --  Comparator hysteresis enabled
      Enabled)
     with Size => 1;
   for HYST_HYST_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Comparator hysteresis enable
   type HYST_Register is record
      --  Comparator hysteresis enable
      HYST          : HYST_HYST_Field := NRF52840.LPCOMP.Disabled;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for HYST_Register use record
      HYST          at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  Low Power Comparator
   type LPCOMP_Peripheral is record
      --  Start comparator
      TASKS_START  : aliased TASKS_START_Register;
      pragma Volatile_Full_Access (TASKS_START);
      --  Stop comparator
      TASKS_STOP   : aliased TASKS_STOP_Register;
      pragma Volatile_Full_Access (TASKS_STOP);
      --  Sample comparator value
      TASKS_SAMPLE : aliased TASKS_SAMPLE_Register;
      pragma Volatile_Full_Access (TASKS_SAMPLE);
      --  LPCOMP is ready and output is valid
      EVENTS_READY : aliased EVENTS_READY_Register;
      pragma Volatile_Full_Access (EVENTS_READY);
      --  Downward crossing
      EVENTS_DOWN  : aliased EVENTS_DOWN_Register;
      pragma Volatile_Full_Access (EVENTS_DOWN);
      --  Upward crossing
      EVENTS_UP    : aliased EVENTS_UP_Register;
      pragma Volatile_Full_Access (EVENTS_UP);
      --  Downward or upward crossing
      EVENTS_CROSS : aliased EVENTS_CROSS_Register;
      pragma Volatile_Full_Access (EVENTS_CROSS);
      --  Shortcut register
      SHORTS       : aliased SHORTS_Register;
      pragma Volatile_Full_Access (SHORTS);
      --  Enable interrupt
      INTENSET     : aliased INTENSET_Register;
      pragma Volatile_Full_Access (INTENSET);
      --  Disable interrupt
      INTENCLR     : aliased INTENCLR_Register;
      pragma Volatile_Full_Access (INTENCLR);
      --  Compare result
      RESULT       : aliased RESULT_Register;
      pragma Volatile_Full_Access (RESULT);
      --  Enable LPCOMP
      ENABLE       : aliased ENABLE_Register;
      pragma Volatile_Full_Access (ENABLE);
      --  Input pin select
      PSEL         : aliased PSEL_Register;
      pragma Volatile_Full_Access (PSEL);
      --  Reference select
      REFSEL       : aliased REFSEL_Register;
      pragma Volatile_Full_Access (REFSEL);
      --  External reference select
      EXTREFSEL    : aliased EXTREFSEL_Register;
      pragma Volatile_Full_Access (EXTREFSEL);
      --  Analog detect configuration
      ANADETECT    : aliased ANADETECT_Register;
      pragma Volatile_Full_Access (ANADETECT);
      --  Comparator hysteresis enable
      HYST         : aliased HYST_Register;
      pragma Volatile_Full_Access (HYST);
   end record
     with Volatile;

   for LPCOMP_Peripheral use record
      TASKS_START  at 16#0# range 0 .. 31;
      TASKS_STOP   at 16#4# range 0 .. 31;
      TASKS_SAMPLE at 16#8# range 0 .. 31;
      EVENTS_READY at 16#100# range 0 .. 31;
      EVENTS_DOWN  at 16#104# range 0 .. 31;
      EVENTS_UP    at 16#108# range 0 .. 31;
      EVENTS_CROSS at 16#10C# range 0 .. 31;
      SHORTS       at 16#200# range 0 .. 31;
      INTENSET     at 16#304# range 0 .. 31;
      INTENCLR     at 16#308# range 0 .. 31;
      RESULT       at 16#400# range 0 .. 31;
      ENABLE       at 16#500# range 0 .. 31;
      PSEL         at 16#504# range 0 .. 31;
      REFSEL       at 16#508# range 0 .. 31;
      EXTREFSEL    at 16#50C# range 0 .. 31;
      ANADETECT    at 16#520# range 0 .. 31;
      HYST         at 16#538# range 0 .. 31;
   end record;

   --  Low Power Comparator
   LPCOMP_Periph : aliased LPCOMP_Peripheral
     with Import, Address => LPCOMP_Base;

end NRF52840.LPCOMP;
