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

package NRF52840.GPIOTE is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   subtype TASKS_OUT_TASKS_OUT_Field is NRF52840.Bit;

   --  Description collection[n]: Task for writing to pin specified in
   --  CONFIG[n].PSEL. Action on pin is configured in CONFIG[n].POLARITY.
   type TASKS_OUT_Register is record
      --  Write-only.
      TASKS_OUT     : TASKS_OUT_TASKS_OUT_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_OUT_Register use record
      TASKS_OUT     at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_SET_TASKS_SET_Field is NRF52840.Bit;

   --  Description collection[n]: Task for writing to pin specified in
   --  CONFIG[n].PSEL. Action on pin is to set it high.
   type TASKS_SET_Register is record
      --  Write-only.
      TASKS_SET     : TASKS_SET_TASKS_SET_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_SET_Register use record
      TASKS_SET     at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_CLR_TASKS_CLR_Field is NRF52840.Bit;

   --  Description collection[n]: Task for writing to pin specified in
   --  CONFIG[n].PSEL. Action on pin is to set it low.
   type TASKS_CLR_Register is record
      --  Write-only.
      TASKS_CLR     : TASKS_CLR_TASKS_CLR_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_CLR_Register use record
      TASKS_CLR     at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_IN_EVENTS_IN_Field is NRF52840.Bit;

   --  Description collection[n]: Event generated from pin specified in
   --  CONFIG[n].PSEL
   type EVENTS_IN_Register is record
      EVENTS_IN     : EVENTS_IN_EVENTS_IN_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_IN_Register use record
      EVENTS_IN     at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_PORT_EVENTS_PORT_Field is NRF52840.Bit;

   --  Event generated from multiple input GPIO pins with SENSE mechanism
   --  enabled
   type EVENTS_PORT_Register is record
      EVENTS_PORT   : EVENTS_PORT_EVENTS_PORT_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_PORT_Register use record
      EVENTS_PORT   at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   --  Write '1' to enable interrupt for IN[0] event
   type INTENSET_IN0_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_IN0_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for IN[0] event
   type INTENSET_IN0_Field_1 is
     (--  Reset value for the field
      INTENSET_IN0_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_IN0_Field_1 use
     (INTENSET_IN0_Field_Reset => 0,
      Set => 1);

   --  INTENSET_IN array
   type INTENSET_IN_Field_Array is array (0 .. 7) of INTENSET_IN0_Field_1
     with Component_Size => 1, Size => 8;

   --  Type definition for INTENSET_IN
   type INTENSET_IN_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  IN as a value
            Val : NRF52840.Byte;
         when True =>
            --  IN as an array
            Arr : INTENSET_IN_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 8;

   for INTENSET_IN_Field use record
      Val at 0 range 0 .. 7;
      Arr at 0 range 0 .. 7;
   end record;

   --  Write '1' to enable interrupt for PORT event
   type INTENSET_PORT_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_PORT_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for PORT event
   type INTENSET_PORT_Field_1 is
     (--  Reset value for the field
      INTENSET_PORT_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_PORT_Field_1 use
     (INTENSET_PORT_Field_Reset => 0,
      Set => 1);

   --  Enable interrupt
   type INTENSET_Register is record
      --  Write '1' to enable interrupt for IN[0] event
      IN_k          : INTENSET_IN_Field := (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_8_30 : NRF52840.UInt23 := 16#0#;
      --  Write '1' to enable interrupt for PORT event
      PORT          : INTENSET_PORT_Field_1 := INTENSET_PORT_Field_Reset;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENSET_Register use record
      IN_k          at 0 range 0 .. 7;
      Reserved_8_30 at 0 range 8 .. 30;
      PORT          at 0 range 31 .. 31;
   end record;

   --  Write '1' to disable interrupt for IN[0] event
   type INTENCLR_IN0_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_IN0_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for IN[0] event
   type INTENCLR_IN0_Field_1 is
     (--  Reset value for the field
      INTENCLR_IN0_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_IN0_Field_1 use
     (INTENCLR_IN0_Field_Reset => 0,
      Clear => 1);

   --  INTENCLR_IN array
   type INTENCLR_IN_Field_Array is array (0 .. 7) of INTENCLR_IN0_Field_1
     with Component_Size => 1, Size => 8;

   --  Type definition for INTENCLR_IN
   type INTENCLR_IN_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  IN as a value
            Val : NRF52840.Byte;
         when True =>
            --  IN as an array
            Arr : INTENCLR_IN_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 8;

   for INTENCLR_IN_Field use record
      Val at 0 range 0 .. 7;
      Arr at 0 range 0 .. 7;
   end record;

   --  Write '1' to disable interrupt for PORT event
   type INTENCLR_PORT_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_PORT_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for PORT event
   type INTENCLR_PORT_Field_1 is
     (--  Reset value for the field
      INTENCLR_PORT_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_PORT_Field_1 use
     (INTENCLR_PORT_Field_Reset => 0,
      Clear => 1);

   --  Disable interrupt
   type INTENCLR_Register is record
      --  Write '1' to disable interrupt for IN[0] event
      IN_k          : INTENCLR_IN_Field := (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_8_30 : NRF52840.UInt23 := 16#0#;
      --  Write '1' to disable interrupt for PORT event
      PORT          : INTENCLR_PORT_Field_1 := INTENCLR_PORT_Field_Reset;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENCLR_Register use record
      IN_k          at 0 range 0 .. 7;
      Reserved_8_30 at 0 range 8 .. 30;
      PORT          at 0 range 31 .. 31;
   end record;

   --  Mode
   type CONFIG_MODE_Field is
     (--  Disabled. Pin specified by PSEL will not be acquired by the GPIOTE module.
      Disabled,
      --  Event mode
      Event,
      --  Task mode
      Task_k)
     with Size => 2;
   for CONFIG_MODE_Field use
     (Disabled => 0,
      Event => 1,
      Task_k => 3);

   subtype CONFIG_PSEL_Field is NRF52840.UInt5;
   subtype CONFIG_PORT_Field is NRF52840.Bit;

   --  When In task mode: Operation to be performed on output when OUT[n] task
   --  is triggered. When In event mode: Operation on input that shall trigger
   --  IN[n] event.
   type CONFIG_POLARITY_Field is
     (--  Task mode: No effect on pin from OUT[n] task. Event mode: no IN[n] event
--  generated on pin activity.
      None,
      --  Task mode: Set pin from OUT[n] task. Event mode: Generate IN[n] event when
--  rising edge on pin.
      LoToHi,
      --  Task mode: Clear pin from OUT[n] task. Event mode: Generate IN[n] event
--  when falling edge on pin.
      HiToLo,
      --  Task mode: Toggle pin from OUT[n]. Event mode: Generate IN[n] when any
--  change on pin.
      Toggle)
     with Size => 2;
   for CONFIG_POLARITY_Field use
     (None => 0,
      LoToHi => 1,
      HiToLo => 2,
      Toggle => 3);

   --  When in task mode: Initial value of the output when the GPIOTE channel
   --  is configured. When in event mode: No effect.
   type CONFIG_OUTINIT_Field is
     (--  Task mode: Initial value of pin before task triggering is low
      Low,
      --  Task mode: Initial value of pin before task triggering is high
      High)
     with Size => 1;
   for CONFIG_OUTINIT_Field use
     (Low => 0,
      High => 1);

   --  Description collection[n]: Configuration for OUT[n], SET[n] and CLR[n]
   --  tasks and IN[n] event
   type CONFIG_Register is record
      --  Mode
      MODE           : CONFIG_MODE_Field := NRF52840.GPIOTE.Disabled;
      --  unspecified
      Reserved_2_7   : NRF52840.UInt6 := 16#0#;
      --  GPIO number associated with SET[n], CLR[n] and OUT[n] tasks and IN[n]
      --  event
      PSEL           : CONFIG_PSEL_Field := 16#0#;
      --  Port number
      PORT           : CONFIG_PORT_Field := 16#0#;
      --  unspecified
      Reserved_14_15 : NRF52840.UInt2 := 16#0#;
      --  When In task mode: Operation to be performed on output when OUT[n]
      --  task is triggered. When In event mode: Operation on input that shall
      --  trigger IN[n] event.
      POLARITY       : CONFIG_POLARITY_Field := NRF52840.GPIOTE.None;
      --  unspecified
      Reserved_18_19 : NRF52840.UInt2 := 16#0#;
      --  When in task mode: Initial value of the output when the GPIOTE
      --  channel is configured. When in event mode: No effect.
      OUTINIT        : CONFIG_OUTINIT_Field := NRF52840.GPIOTE.Low;
      --  unspecified
      Reserved_21_31 : NRF52840.UInt11 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for CONFIG_Register use record
      MODE           at 0 range 0 .. 1;
      Reserved_2_7   at 0 range 2 .. 7;
      PSEL           at 0 range 8 .. 12;
      PORT           at 0 range 13 .. 13;
      Reserved_14_15 at 0 range 14 .. 15;
      POLARITY       at 0 range 16 .. 17;
      Reserved_18_19 at 0 range 18 .. 19;
      OUTINIT        at 0 range 20 .. 20;
      Reserved_21_31 at 0 range 21 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  GPIO Tasks and Events
   type GPIOTE_Peripheral is record
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is configured in CONFIG[n].POLARITY.
      TASKS_OUT_0 : aliased TASKS_OUT_Register;
      pragma Volatile_Full_Access (TASKS_OUT_0);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is configured in CONFIG[n].POLARITY.
      TASKS_OUT_1 : aliased TASKS_OUT_Register;
      pragma Volatile_Full_Access (TASKS_OUT_1);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is configured in CONFIG[n].POLARITY.
      TASKS_OUT_2 : aliased TASKS_OUT_Register;
      pragma Volatile_Full_Access (TASKS_OUT_2);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is configured in CONFIG[n].POLARITY.
      TASKS_OUT_3 : aliased TASKS_OUT_Register;
      pragma Volatile_Full_Access (TASKS_OUT_3);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is configured in CONFIG[n].POLARITY.
      TASKS_OUT_4 : aliased TASKS_OUT_Register;
      pragma Volatile_Full_Access (TASKS_OUT_4);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is configured in CONFIG[n].POLARITY.
      TASKS_OUT_5 : aliased TASKS_OUT_Register;
      pragma Volatile_Full_Access (TASKS_OUT_5);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is configured in CONFIG[n].POLARITY.
      TASKS_OUT_6 : aliased TASKS_OUT_Register;
      pragma Volatile_Full_Access (TASKS_OUT_6);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is configured in CONFIG[n].POLARITY.
      TASKS_OUT_7 : aliased TASKS_OUT_Register;
      pragma Volatile_Full_Access (TASKS_OUT_7);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it high.
      TASKS_SET_0 : aliased TASKS_SET_Register;
      pragma Volatile_Full_Access (TASKS_SET_0);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it high.
      TASKS_SET_1 : aliased TASKS_SET_Register;
      pragma Volatile_Full_Access (TASKS_SET_1);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it high.
      TASKS_SET_2 : aliased TASKS_SET_Register;
      pragma Volatile_Full_Access (TASKS_SET_2);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it high.
      TASKS_SET_3 : aliased TASKS_SET_Register;
      pragma Volatile_Full_Access (TASKS_SET_3);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it high.
      TASKS_SET_4 : aliased TASKS_SET_Register;
      pragma Volatile_Full_Access (TASKS_SET_4);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it high.
      TASKS_SET_5 : aliased TASKS_SET_Register;
      pragma Volatile_Full_Access (TASKS_SET_5);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it high.
      TASKS_SET_6 : aliased TASKS_SET_Register;
      pragma Volatile_Full_Access (TASKS_SET_6);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it high.
      TASKS_SET_7 : aliased TASKS_SET_Register;
      pragma Volatile_Full_Access (TASKS_SET_7);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it low.
      TASKS_CLR_0 : aliased TASKS_CLR_Register;
      pragma Volatile_Full_Access (TASKS_CLR_0);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it low.
      TASKS_CLR_1 : aliased TASKS_CLR_Register;
      pragma Volatile_Full_Access (TASKS_CLR_1);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it low.
      TASKS_CLR_2 : aliased TASKS_CLR_Register;
      pragma Volatile_Full_Access (TASKS_CLR_2);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it low.
      TASKS_CLR_3 : aliased TASKS_CLR_Register;
      pragma Volatile_Full_Access (TASKS_CLR_3);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it low.
      TASKS_CLR_4 : aliased TASKS_CLR_Register;
      pragma Volatile_Full_Access (TASKS_CLR_4);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it low.
      TASKS_CLR_5 : aliased TASKS_CLR_Register;
      pragma Volatile_Full_Access (TASKS_CLR_5);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it low.
      TASKS_CLR_6 : aliased TASKS_CLR_Register;
      pragma Volatile_Full_Access (TASKS_CLR_6);
      --  Description collection[n]: Task for writing to pin specified in
      --  CONFIG[n].PSEL. Action on pin is to set it low.
      TASKS_CLR_7 : aliased TASKS_CLR_Register;
      pragma Volatile_Full_Access (TASKS_CLR_7);
      --  Description collection[n]: Event generated from pin specified in
      --  CONFIG[n].PSEL
      EVENTS_IN_0 : aliased EVENTS_IN_Register;
      pragma Volatile_Full_Access (EVENTS_IN_0);
      --  Description collection[n]: Event generated from pin specified in
      --  CONFIG[n].PSEL
      EVENTS_IN_1 : aliased EVENTS_IN_Register;
      pragma Volatile_Full_Access (EVENTS_IN_1);
      --  Description collection[n]: Event generated from pin specified in
      --  CONFIG[n].PSEL
      EVENTS_IN_2 : aliased EVENTS_IN_Register;
      pragma Volatile_Full_Access (EVENTS_IN_2);
      --  Description collection[n]: Event generated from pin specified in
      --  CONFIG[n].PSEL
      EVENTS_IN_3 : aliased EVENTS_IN_Register;
      pragma Volatile_Full_Access (EVENTS_IN_3);
      --  Description collection[n]: Event generated from pin specified in
      --  CONFIG[n].PSEL
      EVENTS_IN_4 : aliased EVENTS_IN_Register;
      pragma Volatile_Full_Access (EVENTS_IN_4);
      --  Description collection[n]: Event generated from pin specified in
      --  CONFIG[n].PSEL
      EVENTS_IN_5 : aliased EVENTS_IN_Register;
      pragma Volatile_Full_Access (EVENTS_IN_5);
      --  Description collection[n]: Event generated from pin specified in
      --  CONFIG[n].PSEL
      EVENTS_IN_6 : aliased EVENTS_IN_Register;
      pragma Volatile_Full_Access (EVENTS_IN_6);
      --  Description collection[n]: Event generated from pin specified in
      --  CONFIG[n].PSEL
      EVENTS_IN_7 : aliased EVENTS_IN_Register;
      pragma Volatile_Full_Access (EVENTS_IN_7);
      --  Event generated from multiple input GPIO pins with SENSE mechanism
      --  enabled
      EVENTS_PORT : aliased EVENTS_PORT_Register;
      pragma Volatile_Full_Access (EVENTS_PORT);
      --  Enable interrupt
      INTENSET    : aliased INTENSET_Register;
      pragma Volatile_Full_Access (INTENSET);
      --  Disable interrupt
      INTENCLR    : aliased INTENCLR_Register;
      pragma Volatile_Full_Access (INTENCLR);
      --  Description collection[n]: Configuration for OUT[n], SET[n] and
      --  CLR[n] tasks and IN[n] event
      CONFIG_0    : aliased CONFIG_Register;
      pragma Volatile_Full_Access (CONFIG_0);
      --  Description collection[n]: Configuration for OUT[n], SET[n] and
      --  CLR[n] tasks and IN[n] event
      CONFIG_1    : aliased CONFIG_Register;
      pragma Volatile_Full_Access (CONFIG_1);
      --  Description collection[n]: Configuration for OUT[n], SET[n] and
      --  CLR[n] tasks and IN[n] event
      CONFIG_2    : aliased CONFIG_Register;
      pragma Volatile_Full_Access (CONFIG_2);
      --  Description collection[n]: Configuration for OUT[n], SET[n] and
      --  CLR[n] tasks and IN[n] event
      CONFIG_3    : aliased CONFIG_Register;
      pragma Volatile_Full_Access (CONFIG_3);
      --  Description collection[n]: Configuration for OUT[n], SET[n] and
      --  CLR[n] tasks and IN[n] event
      CONFIG_4    : aliased CONFIG_Register;
      pragma Volatile_Full_Access (CONFIG_4);
      --  Description collection[n]: Configuration for OUT[n], SET[n] and
      --  CLR[n] tasks and IN[n] event
      CONFIG_5    : aliased CONFIG_Register;
      pragma Volatile_Full_Access (CONFIG_5);
      --  Description collection[n]: Configuration for OUT[n], SET[n] and
      --  CLR[n] tasks and IN[n] event
      CONFIG_6    : aliased CONFIG_Register;
      pragma Volatile_Full_Access (CONFIG_6);
      --  Description collection[n]: Configuration for OUT[n], SET[n] and
      --  CLR[n] tasks and IN[n] event
      CONFIG_7    : aliased CONFIG_Register;
      pragma Volatile_Full_Access (CONFIG_7);
   end record
     with Volatile;

   for GPIOTE_Peripheral use record
      TASKS_OUT_0 at 16#0# range 0 .. 31;
      TASKS_OUT_1 at 16#4# range 0 .. 31;
      TASKS_OUT_2 at 16#8# range 0 .. 31;
      TASKS_OUT_3 at 16#C# range 0 .. 31;
      TASKS_OUT_4 at 16#10# range 0 .. 31;
      TASKS_OUT_5 at 16#14# range 0 .. 31;
      TASKS_OUT_6 at 16#18# range 0 .. 31;
      TASKS_OUT_7 at 16#1C# range 0 .. 31;
      TASKS_SET_0 at 16#30# range 0 .. 31;
      TASKS_SET_1 at 16#34# range 0 .. 31;
      TASKS_SET_2 at 16#38# range 0 .. 31;
      TASKS_SET_3 at 16#3C# range 0 .. 31;
      TASKS_SET_4 at 16#40# range 0 .. 31;
      TASKS_SET_5 at 16#44# range 0 .. 31;
      TASKS_SET_6 at 16#48# range 0 .. 31;
      TASKS_SET_7 at 16#4C# range 0 .. 31;
      TASKS_CLR_0 at 16#60# range 0 .. 31;
      TASKS_CLR_1 at 16#64# range 0 .. 31;
      TASKS_CLR_2 at 16#68# range 0 .. 31;
      TASKS_CLR_3 at 16#6C# range 0 .. 31;
      TASKS_CLR_4 at 16#70# range 0 .. 31;
      TASKS_CLR_5 at 16#74# range 0 .. 31;
      TASKS_CLR_6 at 16#78# range 0 .. 31;
      TASKS_CLR_7 at 16#7C# range 0 .. 31;
      EVENTS_IN_0 at 16#100# range 0 .. 31;
      EVENTS_IN_1 at 16#104# range 0 .. 31;
      EVENTS_IN_2 at 16#108# range 0 .. 31;
      EVENTS_IN_3 at 16#10C# range 0 .. 31;
      EVENTS_IN_4 at 16#110# range 0 .. 31;
      EVENTS_IN_5 at 16#114# range 0 .. 31;
      EVENTS_IN_6 at 16#118# range 0 .. 31;
      EVENTS_IN_7 at 16#11C# range 0 .. 31;
      EVENTS_PORT at 16#17C# range 0 .. 31;
      INTENSET    at 16#304# range 0 .. 31;
      INTENCLR    at 16#308# range 0 .. 31;
      CONFIG_0    at 16#510# range 0 .. 31;
      CONFIG_1    at 16#514# range 0 .. 31;
      CONFIG_2    at 16#518# range 0 .. 31;
      CONFIG_3    at 16#51C# range 0 .. 31;
      CONFIG_4    at 16#520# range 0 .. 31;
      CONFIG_5    at 16#524# range 0 .. 31;
      CONFIG_6    at 16#528# range 0 .. 31;
      CONFIG_7    at 16#52C# range 0 .. 31;
   end record;

   --  GPIO Tasks and Events
   GPIOTE_Periph : aliased GPIOTE_Peripheral
     with Import, Address => GPIOTE_Base;

end NRF52840.GPIOTE;
