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

package NRF52840.TWIM is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   subtype TASKS_STARTRX_TASKS_STARTRX_Field is NRF52840.Bit;

   --  Start TWI receive sequence
   type TASKS_STARTRX_Register is record
      --  Write-only.
      TASKS_STARTRX : TASKS_STARTRX_TASKS_STARTRX_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_STARTRX_Register use record
      TASKS_STARTRX at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_STARTTX_TASKS_STARTTX_Field is NRF52840.Bit;

   --  Start TWI transmit sequence
   type TASKS_STARTTX_Register is record
      --  Write-only.
      TASKS_STARTTX : TASKS_STARTTX_TASKS_STARTTX_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_STARTTX_Register use record
      TASKS_STARTTX at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_STOP_TASKS_STOP_Field is NRF52840.Bit;

   --  Stop TWI transaction. Must be issued while the TWI master is not
   --  suspended.
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

   subtype TASKS_SUSPEND_TASKS_SUSPEND_Field is NRF52840.Bit;

   --  Suspend TWI transaction
   type TASKS_SUSPEND_Register is record
      --  Write-only.
      TASKS_SUSPEND : TASKS_SUSPEND_TASKS_SUSPEND_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_SUSPEND_Register use record
      TASKS_SUSPEND at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_RESUME_TASKS_RESUME_Field is NRF52840.Bit;

   --  Resume TWI transaction
   type TASKS_RESUME_Register is record
      --  Write-only.
      TASKS_RESUME  : TASKS_RESUME_TASKS_RESUME_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_RESUME_Register use record
      TASKS_RESUME  at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_STOPPED_EVENTS_STOPPED_Field is NRF52840.Bit;

   --  TWI stopped
   type EVENTS_STOPPED_Register is record
      EVENTS_STOPPED : EVENTS_STOPPED_EVENTS_STOPPED_Field := 16#0#;
      --  unspecified
      Reserved_1_31  : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_STOPPED_Register use record
      EVENTS_STOPPED at 0 range 0 .. 0;
      Reserved_1_31  at 0 range 1 .. 31;
   end record;

   subtype EVENTS_ERROR_EVENTS_ERROR_Field is NRF52840.Bit;

   --  TWI error
   type EVENTS_ERROR_Register is record
      EVENTS_ERROR  : EVENTS_ERROR_EVENTS_ERROR_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_ERROR_Register use record
      EVENTS_ERROR  at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_SUSPENDED_EVENTS_SUSPENDED_Field is NRF52840.Bit;

   --  Last byte has been sent out after the SUSPEND task has been issued, TWI
   --  traffic is now suspended.
   type EVENTS_SUSPENDED_Register is record
      EVENTS_SUSPENDED : EVENTS_SUSPENDED_EVENTS_SUSPENDED_Field := 16#0#;
      --  unspecified
      Reserved_1_31    : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_SUSPENDED_Register use record
      EVENTS_SUSPENDED at 0 range 0 .. 0;
      Reserved_1_31    at 0 range 1 .. 31;
   end record;

   subtype EVENTS_RXSTARTED_EVENTS_RXSTARTED_Field is NRF52840.Bit;

   --  Receive sequence started
   type EVENTS_RXSTARTED_Register is record
      EVENTS_RXSTARTED : EVENTS_RXSTARTED_EVENTS_RXSTARTED_Field := 16#0#;
      --  unspecified
      Reserved_1_31    : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_RXSTARTED_Register use record
      EVENTS_RXSTARTED at 0 range 0 .. 0;
      Reserved_1_31    at 0 range 1 .. 31;
   end record;

   subtype EVENTS_TXSTARTED_EVENTS_TXSTARTED_Field is NRF52840.Bit;

   --  Transmit sequence started
   type EVENTS_TXSTARTED_Register is record
      EVENTS_TXSTARTED : EVENTS_TXSTARTED_EVENTS_TXSTARTED_Field := 16#0#;
      --  unspecified
      Reserved_1_31    : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_TXSTARTED_Register use record
      EVENTS_TXSTARTED at 0 range 0 .. 0;
      Reserved_1_31    at 0 range 1 .. 31;
   end record;

   subtype EVENTS_LASTRX_EVENTS_LASTRX_Field is NRF52840.Bit;

   --  Byte boundary, starting to receive the last byte
   type EVENTS_LASTRX_Register is record
      EVENTS_LASTRX : EVENTS_LASTRX_EVENTS_LASTRX_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_LASTRX_Register use record
      EVENTS_LASTRX at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_LASTTX_EVENTS_LASTTX_Field is NRF52840.Bit;

   --  Byte boundary, starting to transmit the last byte
   type EVENTS_LASTTX_Register is record
      EVENTS_LASTTX : EVENTS_LASTTX_EVENTS_LASTTX_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_LASTTX_Register use record
      EVENTS_LASTTX at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   --  Shortcut between LASTTX event and STARTRX task
   type SHORTS_LASTTX_STARTRX_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_LASTTX_STARTRX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between LASTTX event and SUSPEND task
   type SHORTS_LASTTX_SUSPEND_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_LASTTX_SUSPEND_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between LASTTX event and STOP task
   type SHORTS_LASTTX_STOP_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_LASTTX_STOP_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between LASTRX event and STARTTX task
   type SHORTS_LASTRX_STARTTX_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_LASTRX_STARTTX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between LASTRX event and SUSPEND task
   type SHORTS_LASTRX_SUSPEND_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_LASTRX_SUSPEND_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between LASTRX event and STOP task
   type SHORTS_LASTRX_STOP_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_LASTRX_STOP_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut register
   type SHORTS_Register is record
      --  unspecified
      Reserved_0_6   : NRF52840.UInt7 := 16#0#;
      --  Shortcut between LASTTX event and STARTRX task
      LASTTX_STARTRX : SHORTS_LASTTX_STARTRX_Field := NRF52840.TWIM.Disabled;
      --  Shortcut between LASTTX event and SUSPEND task
      LASTTX_SUSPEND : SHORTS_LASTTX_SUSPEND_Field := NRF52840.TWIM.Disabled;
      --  Shortcut between LASTTX event and STOP task
      LASTTX_STOP    : SHORTS_LASTTX_STOP_Field := NRF52840.TWIM.Disabled;
      --  Shortcut between LASTRX event and STARTTX task
      LASTRX_STARTTX : SHORTS_LASTRX_STARTTX_Field := NRF52840.TWIM.Disabled;
      --  Shortcut between LASTRX event and SUSPEND task
      LASTRX_SUSPEND : SHORTS_LASTRX_SUSPEND_Field := NRF52840.TWIM.Disabled;
      --  Shortcut between LASTRX event and STOP task
      LASTRX_STOP    : SHORTS_LASTRX_STOP_Field := NRF52840.TWIM.Disabled;
      --  unspecified
      Reserved_13_31 : NRF52840.UInt19 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SHORTS_Register use record
      Reserved_0_6   at 0 range 0 .. 6;
      LASTTX_STARTRX at 0 range 7 .. 7;
      LASTTX_SUSPEND at 0 range 8 .. 8;
      LASTTX_STOP    at 0 range 9 .. 9;
      LASTRX_STARTTX at 0 range 10 .. 10;
      LASTRX_SUSPEND at 0 range 11 .. 11;
      LASTRX_STOP    at 0 range 12 .. 12;
      Reserved_13_31 at 0 range 13 .. 31;
   end record;

   --  Enable or disable interrupt for STOPPED event
   type INTEN_STOPPED_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_STOPPED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for ERROR event
   type INTEN_ERROR_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_ERROR_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for SUSPENDED event
   type INTEN_SUSPENDED_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_SUSPENDED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for RXSTARTED event
   type INTEN_RXSTARTED_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_RXSTARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for TXSTARTED event
   type INTEN_TXSTARTED_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_TXSTARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for LASTRX event
   type INTEN_LASTRX_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_LASTRX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for LASTTX event
   type INTEN_LASTTX_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_LASTTX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt
   type INTEN_Register is record
      --  unspecified
      Reserved_0_0   : NRF52840.Bit := 16#0#;
      --  Enable or disable interrupt for STOPPED event
      STOPPED        : INTEN_STOPPED_Field := NRF52840.TWIM.Disabled;
      --  unspecified
      Reserved_2_8   : NRF52840.UInt7 := 16#0#;
      --  Enable or disable interrupt for ERROR event
      ERROR          : INTEN_ERROR_Field := NRF52840.TWIM.Disabled;
      --  unspecified
      Reserved_10_17 : NRF52840.Byte := 16#0#;
      --  Enable or disable interrupt for SUSPENDED event
      SUSPENDED      : INTEN_SUSPENDED_Field := NRF52840.TWIM.Disabled;
      --  Enable or disable interrupt for RXSTARTED event
      RXSTARTED      : INTEN_RXSTARTED_Field := NRF52840.TWIM.Disabled;
      --  Enable or disable interrupt for TXSTARTED event
      TXSTARTED      : INTEN_TXSTARTED_Field := NRF52840.TWIM.Disabled;
      --  unspecified
      Reserved_21_22 : NRF52840.UInt2 := 16#0#;
      --  Enable or disable interrupt for LASTRX event
      LASTRX         : INTEN_LASTRX_Field := NRF52840.TWIM.Disabled;
      --  Enable or disable interrupt for LASTTX event
      LASTTX         : INTEN_LASTTX_Field := NRF52840.TWIM.Disabled;
      --  unspecified
      Reserved_25_31 : NRF52840.UInt7 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTEN_Register use record
      Reserved_0_0   at 0 range 0 .. 0;
      STOPPED        at 0 range 1 .. 1;
      Reserved_2_8   at 0 range 2 .. 8;
      ERROR          at 0 range 9 .. 9;
      Reserved_10_17 at 0 range 10 .. 17;
      SUSPENDED      at 0 range 18 .. 18;
      RXSTARTED      at 0 range 19 .. 19;
      TXSTARTED      at 0 range 20 .. 20;
      Reserved_21_22 at 0 range 21 .. 22;
      LASTRX         at 0 range 23 .. 23;
      LASTTX         at 0 range 24 .. 24;
      Reserved_25_31 at 0 range 25 .. 31;
   end record;

   --  Write '1' to enable interrupt for STOPPED event
   type INTENSET_STOPPED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_STOPPED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for STOPPED event
   type INTENSET_STOPPED_Field_1 is
     (--  Reset value for the field
      INTENSET_STOPPED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_STOPPED_Field_1 use
     (INTENSET_STOPPED_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for ERROR event
   type INTENSET_ERROR_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_ERROR_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for ERROR event
   type INTENSET_ERROR_Field_1 is
     (--  Reset value for the field
      INTENSET_ERROR_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_ERROR_Field_1 use
     (INTENSET_ERROR_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for SUSPENDED event
   type INTENSET_SUSPENDED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_SUSPENDED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for SUSPENDED event
   type INTENSET_SUSPENDED_Field_1 is
     (--  Reset value for the field
      INTENSET_SUSPENDED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_SUSPENDED_Field_1 use
     (INTENSET_SUSPENDED_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for RXSTARTED event
   type INTENSET_RXSTARTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_RXSTARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for RXSTARTED event
   type INTENSET_RXSTARTED_Field_1 is
     (--  Reset value for the field
      INTENSET_RXSTARTED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_RXSTARTED_Field_1 use
     (INTENSET_RXSTARTED_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for TXSTARTED event
   type INTENSET_TXSTARTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_TXSTARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for TXSTARTED event
   type INTENSET_TXSTARTED_Field_1 is
     (--  Reset value for the field
      INTENSET_TXSTARTED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_TXSTARTED_Field_1 use
     (INTENSET_TXSTARTED_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for LASTRX event
   type INTENSET_LASTRX_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_LASTRX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for LASTRX event
   type INTENSET_LASTRX_Field_1 is
     (--  Reset value for the field
      INTENSET_LASTRX_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_LASTRX_Field_1 use
     (INTENSET_LASTRX_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for LASTTX event
   type INTENSET_LASTTX_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_LASTTX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for LASTTX event
   type INTENSET_LASTTX_Field_1 is
     (--  Reset value for the field
      INTENSET_LASTTX_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_LASTTX_Field_1 use
     (INTENSET_LASTTX_Field_Reset => 0,
      Set => 1);

   --  Enable interrupt
   type INTENSET_Register is record
      --  unspecified
      Reserved_0_0   : NRF52840.Bit := 16#0#;
      --  Write '1' to enable interrupt for STOPPED event
      STOPPED        : INTENSET_STOPPED_Field_1 :=
                        INTENSET_STOPPED_Field_Reset;
      --  unspecified
      Reserved_2_8   : NRF52840.UInt7 := 16#0#;
      --  Write '1' to enable interrupt for ERROR event
      ERROR          : INTENSET_ERROR_Field_1 := INTENSET_ERROR_Field_Reset;
      --  unspecified
      Reserved_10_17 : NRF52840.Byte := 16#0#;
      --  Write '1' to enable interrupt for SUSPENDED event
      SUSPENDED      : INTENSET_SUSPENDED_Field_1 :=
                        INTENSET_SUSPENDED_Field_Reset;
      --  Write '1' to enable interrupt for RXSTARTED event
      RXSTARTED      : INTENSET_RXSTARTED_Field_1 :=
                        INTENSET_RXSTARTED_Field_Reset;
      --  Write '1' to enable interrupt for TXSTARTED event
      TXSTARTED      : INTENSET_TXSTARTED_Field_1 :=
                        INTENSET_TXSTARTED_Field_Reset;
      --  unspecified
      Reserved_21_22 : NRF52840.UInt2 := 16#0#;
      --  Write '1' to enable interrupt for LASTRX event
      LASTRX         : INTENSET_LASTRX_Field_1 := INTENSET_LASTRX_Field_Reset;
      --  Write '1' to enable interrupt for LASTTX event
      LASTTX         : INTENSET_LASTTX_Field_1 := INTENSET_LASTTX_Field_Reset;
      --  unspecified
      Reserved_25_31 : NRF52840.UInt7 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENSET_Register use record
      Reserved_0_0   at 0 range 0 .. 0;
      STOPPED        at 0 range 1 .. 1;
      Reserved_2_8   at 0 range 2 .. 8;
      ERROR          at 0 range 9 .. 9;
      Reserved_10_17 at 0 range 10 .. 17;
      SUSPENDED      at 0 range 18 .. 18;
      RXSTARTED      at 0 range 19 .. 19;
      TXSTARTED      at 0 range 20 .. 20;
      Reserved_21_22 at 0 range 21 .. 22;
      LASTRX         at 0 range 23 .. 23;
      LASTTX         at 0 range 24 .. 24;
      Reserved_25_31 at 0 range 25 .. 31;
   end record;

   --  Write '1' to disable interrupt for STOPPED event
   type INTENCLR_STOPPED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_STOPPED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for STOPPED event
   type INTENCLR_STOPPED_Field_1 is
     (--  Reset value for the field
      INTENCLR_STOPPED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_STOPPED_Field_1 use
     (INTENCLR_STOPPED_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for ERROR event
   type INTENCLR_ERROR_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_ERROR_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for ERROR event
   type INTENCLR_ERROR_Field_1 is
     (--  Reset value for the field
      INTENCLR_ERROR_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_ERROR_Field_1 use
     (INTENCLR_ERROR_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for SUSPENDED event
   type INTENCLR_SUSPENDED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_SUSPENDED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for SUSPENDED event
   type INTENCLR_SUSPENDED_Field_1 is
     (--  Reset value for the field
      INTENCLR_SUSPENDED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_SUSPENDED_Field_1 use
     (INTENCLR_SUSPENDED_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for RXSTARTED event
   type INTENCLR_RXSTARTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_RXSTARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for RXSTARTED event
   type INTENCLR_RXSTARTED_Field_1 is
     (--  Reset value for the field
      INTENCLR_RXSTARTED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_RXSTARTED_Field_1 use
     (INTENCLR_RXSTARTED_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for TXSTARTED event
   type INTENCLR_TXSTARTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_TXSTARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for TXSTARTED event
   type INTENCLR_TXSTARTED_Field_1 is
     (--  Reset value for the field
      INTENCLR_TXSTARTED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_TXSTARTED_Field_1 use
     (INTENCLR_TXSTARTED_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for LASTRX event
   type INTENCLR_LASTRX_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_LASTRX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for LASTRX event
   type INTENCLR_LASTRX_Field_1 is
     (--  Reset value for the field
      INTENCLR_LASTRX_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_LASTRX_Field_1 use
     (INTENCLR_LASTRX_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for LASTTX event
   type INTENCLR_LASTTX_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_LASTTX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for LASTTX event
   type INTENCLR_LASTTX_Field_1 is
     (--  Reset value for the field
      INTENCLR_LASTTX_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_LASTTX_Field_1 use
     (INTENCLR_LASTTX_Field_Reset => 0,
      Clear => 1);

   --  Disable interrupt
   type INTENCLR_Register is record
      --  unspecified
      Reserved_0_0   : NRF52840.Bit := 16#0#;
      --  Write '1' to disable interrupt for STOPPED event
      STOPPED        : INTENCLR_STOPPED_Field_1 :=
                        INTENCLR_STOPPED_Field_Reset;
      --  unspecified
      Reserved_2_8   : NRF52840.UInt7 := 16#0#;
      --  Write '1' to disable interrupt for ERROR event
      ERROR          : INTENCLR_ERROR_Field_1 := INTENCLR_ERROR_Field_Reset;
      --  unspecified
      Reserved_10_17 : NRF52840.Byte := 16#0#;
      --  Write '1' to disable interrupt for SUSPENDED event
      SUSPENDED      : INTENCLR_SUSPENDED_Field_1 :=
                        INTENCLR_SUSPENDED_Field_Reset;
      --  Write '1' to disable interrupt for RXSTARTED event
      RXSTARTED      : INTENCLR_RXSTARTED_Field_1 :=
                        INTENCLR_RXSTARTED_Field_Reset;
      --  Write '1' to disable interrupt for TXSTARTED event
      TXSTARTED      : INTENCLR_TXSTARTED_Field_1 :=
                        INTENCLR_TXSTARTED_Field_Reset;
      --  unspecified
      Reserved_21_22 : NRF52840.UInt2 := 16#0#;
      --  Write '1' to disable interrupt for LASTRX event
      LASTRX         : INTENCLR_LASTRX_Field_1 := INTENCLR_LASTRX_Field_Reset;
      --  Write '1' to disable interrupt for LASTTX event
      LASTTX         : INTENCLR_LASTTX_Field_1 := INTENCLR_LASTTX_Field_Reset;
      --  unspecified
      Reserved_25_31 : NRF52840.UInt7 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENCLR_Register use record
      Reserved_0_0   at 0 range 0 .. 0;
      STOPPED        at 0 range 1 .. 1;
      Reserved_2_8   at 0 range 2 .. 8;
      ERROR          at 0 range 9 .. 9;
      Reserved_10_17 at 0 range 10 .. 17;
      SUSPENDED      at 0 range 18 .. 18;
      RXSTARTED      at 0 range 19 .. 19;
      TXSTARTED      at 0 range 20 .. 20;
      Reserved_21_22 at 0 range 21 .. 22;
      LASTRX         at 0 range 23 .. 23;
      LASTTX         at 0 range 24 .. 24;
      Reserved_25_31 at 0 range 25 .. 31;
   end record;

   --  Overrun error
   type ERRORSRC_OVERRUN_Field is
     (--  Error did not occur
      NotReceived,
      --  Error occurred
      Received)
     with Size => 1;
   for ERRORSRC_OVERRUN_Field use
     (NotReceived => 0,
      Received => 1);

   --  NACK received after sending the address (write '1' to clear)
   type ERRORSRC_ANACK_Field is
     (--  Error did not occur
      NotReceived,
      --  Error occurred
      Received)
     with Size => 1;
   for ERRORSRC_ANACK_Field use
     (NotReceived => 0,
      Received => 1);

   --  NACK received after sending a data byte (write '1' to clear)
   type ERRORSRC_DNACK_Field is
     (--  Error did not occur
      NotReceived,
      --  Error occurred
      Received)
     with Size => 1;
   for ERRORSRC_DNACK_Field use
     (NotReceived => 0,
      Received => 1);

   --  Error source
   type ERRORSRC_Register is record
      --  Overrun error
      OVERRUN       : ERRORSRC_OVERRUN_Field := NRF52840.TWIM.NotReceived;
      --  NACK received after sending the address (write '1' to clear)
      ANACK         : ERRORSRC_ANACK_Field := NRF52840.TWIM.NotReceived;
      --  NACK received after sending a data byte (write '1' to clear)
      DNACK         : ERRORSRC_DNACK_Field := NRF52840.TWIM.NotReceived;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for ERRORSRC_Register use record
      OVERRUN       at 0 range 0 .. 0;
      ANACK         at 0 range 1 .. 1;
      DNACK         at 0 range 2 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   --  Enable or disable TWIM
   type ENABLE_ENABLE_Field is
     (--  Disable TWIM
      Disabled,
      --  Enable TWIM
      Enabled)
     with Size => 4;
   for ENABLE_ENABLE_Field use
     (Disabled => 0,
      Enabled => 6);

   --  Enable TWIM
   type ENABLE_Register is record
      --  Enable or disable TWIM
      ENABLE        : ENABLE_ENABLE_Field := NRF52840.TWIM.Disabled;
      --  unspecified
      Reserved_4_31 : NRF52840.UInt28 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for ENABLE_Register use record
      ENABLE        at 0 range 0 .. 3;
      Reserved_4_31 at 0 range 4 .. 31;
   end record;

   -----------------------------------
   -- TWIM_PSEL cluster's Registers --
   -----------------------------------

   subtype SCL_PSEL_PIN_Field is NRF52840.UInt5;
   subtype SCL_PSEL_PORT_Field is NRF52840.Bit;

   --  Connection
   type SCL_CONNECT_Field is
     (--  Connect
      Connected,
      --  Disconnect
      Disconnected)
     with Size => 1;
   for SCL_CONNECT_Field use
     (Connected => 0,
      Disconnected => 1);

   --  Pin select for SCL signal
   type SCL_PSEL_Register is record
      --  Pin number
      PIN           : SCL_PSEL_PIN_Field := 16#1F#;
      --  Port number
      PORT          : SCL_PSEL_PORT_Field := 16#1#;
      --  unspecified
      Reserved_6_30 : NRF52840.UInt25 := 16#1FFFFFF#;
      --  Connection
      CONNECT       : SCL_CONNECT_Field := NRF52840.TWIM.Disconnected;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SCL_PSEL_Register use record
      PIN           at 0 range 0 .. 4;
      PORT          at 0 range 5 .. 5;
      Reserved_6_30 at 0 range 6 .. 30;
      CONNECT       at 0 range 31 .. 31;
   end record;

   subtype SDA_PSEL_PIN_Field is NRF52840.UInt5;
   subtype SDA_PSEL_PORT_Field is NRF52840.Bit;

   --  Connection
   type SDA_CONNECT_Field is
     (--  Connect
      Connected,
      --  Disconnect
      Disconnected)
     with Size => 1;
   for SDA_CONNECT_Field use
     (Connected => 0,
      Disconnected => 1);

   --  Pin select for SDA signal
   type SDA_PSEL_Register is record
      --  Pin number
      PIN           : SDA_PSEL_PIN_Field := 16#1F#;
      --  Port number
      PORT          : SDA_PSEL_PORT_Field := 16#1#;
      --  unspecified
      Reserved_6_30 : NRF52840.UInt25 := 16#1FFFFFF#;
      --  Connection
      CONNECT       : SDA_CONNECT_Field := NRF52840.TWIM.Disconnected;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SDA_PSEL_Register use record
      PIN           at 0 range 0 .. 4;
      PORT          at 0 range 5 .. 5;
      Reserved_6_30 at 0 range 6 .. 30;
      CONNECT       at 0 range 31 .. 31;
   end record;

   --  Unspecified
   type TWIM_PSEL_Cluster is record
      --  Pin select for SCL signal
      SCL : aliased SCL_PSEL_Register;
      pragma Volatile_Full_Access (SCL);
      --  Pin select for SDA signal
      SDA : aliased SDA_PSEL_Register;
      pragma Volatile_Full_Access (SDA);
   end record
     with Size => 64;

   for TWIM_PSEL_Cluster use record
      SCL at 16#0# range 0 .. 31;
      SDA at 16#4# range 0 .. 31;
   end record;

   ----------------------------------
   -- TWIM_RXD cluster's Registers --
   ----------------------------------

   subtype MAXCNT_RXD_MAXCNT_Field is NRF52840.UInt16;

   --  Maximum number of bytes in receive buffer
   type MAXCNT_RXD_Register is record
      --  Maximum number of bytes in receive buffer
      MAXCNT         : MAXCNT_RXD_MAXCNT_Field := 16#0#;
      --  unspecified
      Reserved_16_31 : NRF52840.UInt16 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for MAXCNT_RXD_Register use record
      MAXCNT         at 0 range 0 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   subtype AMOUNT_RXD_AMOUNT_Field is NRF52840.UInt16;

   --  Number of bytes transferred in the last transaction
   type AMOUNT_RXD_Register is record
      --  Read-only. Number of bytes transferred in the last transaction. In
      --  case of NACK error, includes the NACK'ed byte.
      AMOUNT         : AMOUNT_RXD_AMOUNT_Field;
      --  unspecified
      Reserved_16_31 : NRF52840.UInt16;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for AMOUNT_RXD_Register use record
      AMOUNT         at 0 range 0 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   --  List type
   type LIST_LIST_Field is
     (--  Disable EasyDMA list
      Disabled,
      --  Use array list
      ArrayList)
     with Size => 3;
   for LIST_LIST_Field use
     (Disabled => 0,
      ArrayList => 1);

   --  EasyDMA list type
   type LIST_RXD_Register is record
      --  List type
      LIST          : LIST_LIST_Field := NRF52840.TWIM.Disabled;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for LIST_RXD_Register use record
      LIST          at 0 range 0 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   --  RXD EasyDMA channel
   type TWIM_RXD_Cluster is record
      --  Data pointer
      PTR    : aliased NRF52840.UInt32;
      --  Maximum number of bytes in receive buffer
      MAXCNT : aliased MAXCNT_RXD_Register;
      pragma Volatile_Full_Access (MAXCNT);
      --  Number of bytes transferred in the last transaction
      AMOUNT : aliased AMOUNT_RXD_Register;
      pragma Volatile_Full_Access (AMOUNT);
      --  EasyDMA list type
      LIST   : aliased LIST_RXD_Register;
      pragma Volatile_Full_Access (LIST);
   end record
     with Size => 128;

   for TWIM_RXD_Cluster use record
      PTR    at 16#0# range 0 .. 31;
      MAXCNT at 16#4# range 0 .. 31;
      AMOUNT at 16#8# range 0 .. 31;
      LIST   at 16#C# range 0 .. 31;
   end record;

   ----------------------------------
   -- TWIM_TXD cluster's Registers --
   ----------------------------------

   subtype MAXCNT_TXD_MAXCNT_Field is NRF52840.UInt16;

   --  Maximum number of bytes in transmit buffer
   type MAXCNT_TXD_Register is record
      --  Maximum number of bytes in transmit buffer
      MAXCNT         : MAXCNT_TXD_MAXCNT_Field := 16#0#;
      --  unspecified
      Reserved_16_31 : NRF52840.UInt16 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for MAXCNT_TXD_Register use record
      MAXCNT         at 0 range 0 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   subtype AMOUNT_TXD_AMOUNT_Field is NRF52840.UInt16;

   --  Number of bytes transferred in the last transaction
   type AMOUNT_TXD_Register is record
      --  Read-only. Number of bytes transferred in the last transaction. In
      --  case of NACK error, includes the NACK'ed byte.
      AMOUNT         : AMOUNT_TXD_AMOUNT_Field;
      --  unspecified
      Reserved_16_31 : NRF52840.UInt16;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for AMOUNT_TXD_Register use record
      AMOUNT         at 0 range 0 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   --  EasyDMA list type
   type LIST_TXD_Register is record
      --  List type
      LIST          : LIST_LIST_Field := NRF52840.TWIM.Disabled;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for LIST_TXD_Register use record
      LIST          at 0 range 0 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   --  TXD EasyDMA channel
   type TWIM_TXD_Cluster is record
      --  Data pointer
      PTR    : aliased NRF52840.UInt32;
      --  Maximum number of bytes in transmit buffer
      MAXCNT : aliased MAXCNT_TXD_Register;
      pragma Volatile_Full_Access (MAXCNT);
      --  Number of bytes transferred in the last transaction
      AMOUNT : aliased AMOUNT_TXD_Register;
      pragma Volatile_Full_Access (AMOUNT);
      --  EasyDMA list type
      LIST   : aliased LIST_TXD_Register;
      pragma Volatile_Full_Access (LIST);
   end record
     with Size => 128;

   for TWIM_TXD_Cluster use record
      PTR    at 16#0# range 0 .. 31;
      MAXCNT at 16#4# range 0 .. 31;
      AMOUNT at 16#8# range 0 .. 31;
      LIST   at 16#C# range 0 .. 31;
   end record;

   subtype ADDRESS_ADDRESS_Field is NRF52840.UInt7;

   --  Address used in the TWI transfer
   type ADDRESS_Register is record
      --  Address used in the TWI transfer
      ADDRESS       : ADDRESS_ADDRESS_Field := 16#0#;
      --  unspecified
      Reserved_7_31 : NRF52840.UInt25 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for ADDRESS_Register use record
      ADDRESS       at 0 range 0 .. 6;
      Reserved_7_31 at 0 range 7 .. 31;
   end record;

   -----------------------------------
   -- TWIM_PSEL cluster's Registers --
   -----------------------------------

   ----------------------------------
   -- TWIM_RXD cluster's Registers --
   ----------------------------------

   ----------------------------------
   -- TWIM_TXD cluster's Registers --
   ----------------------------------

   -----------------
   -- Peripherals --
   -----------------

   --  I2C compatible Two-Wire Master Interface with EasyDMA 0
   type TWIM_Peripheral is record
      --  Start TWI receive sequence
      TASKS_STARTRX    : aliased TASKS_STARTRX_Register;
      pragma Volatile_Full_Access (TASKS_STARTRX);
      --  Start TWI transmit sequence
      TASKS_STARTTX    : aliased TASKS_STARTTX_Register;
      pragma Volatile_Full_Access (TASKS_STARTTX);
      --  Stop TWI transaction. Must be issued while the TWI master is not
      --  suspended.
      TASKS_STOP       : aliased TASKS_STOP_Register;
      pragma Volatile_Full_Access (TASKS_STOP);
      --  Suspend TWI transaction
      TASKS_SUSPEND    : aliased TASKS_SUSPEND_Register;
      pragma Volatile_Full_Access (TASKS_SUSPEND);
      --  Resume TWI transaction
      TASKS_RESUME     : aliased TASKS_RESUME_Register;
      pragma Volatile_Full_Access (TASKS_RESUME);
      --  TWI stopped
      EVENTS_STOPPED   : aliased EVENTS_STOPPED_Register;
      pragma Volatile_Full_Access (EVENTS_STOPPED);
      --  TWI error
      EVENTS_ERROR     : aliased EVENTS_ERROR_Register;
      pragma Volatile_Full_Access (EVENTS_ERROR);
      --  Last byte has been sent out after the SUSPEND task has been issued,
      --  TWI traffic is now suspended.
      EVENTS_SUSPENDED : aliased EVENTS_SUSPENDED_Register;
      pragma Volatile_Full_Access (EVENTS_SUSPENDED);
      --  Receive sequence started
      EVENTS_RXSTARTED : aliased EVENTS_RXSTARTED_Register;
      pragma Volatile_Full_Access (EVENTS_RXSTARTED);
      --  Transmit sequence started
      EVENTS_TXSTARTED : aliased EVENTS_TXSTARTED_Register;
      pragma Volatile_Full_Access (EVENTS_TXSTARTED);
      --  Byte boundary, starting to receive the last byte
      EVENTS_LASTRX    : aliased EVENTS_LASTRX_Register;
      pragma Volatile_Full_Access (EVENTS_LASTRX);
      --  Byte boundary, starting to transmit the last byte
      EVENTS_LASTTX    : aliased EVENTS_LASTTX_Register;
      pragma Volatile_Full_Access (EVENTS_LASTTX);
      --  Shortcut register
      SHORTS           : aliased SHORTS_Register;
      pragma Volatile_Full_Access (SHORTS);
      --  Enable or disable interrupt
      INTEN            : aliased INTEN_Register;
      pragma Volatile_Full_Access (INTEN);
      --  Enable interrupt
      INTENSET         : aliased INTENSET_Register;
      pragma Volatile_Full_Access (INTENSET);
      --  Disable interrupt
      INTENCLR         : aliased INTENCLR_Register;
      pragma Volatile_Full_Access (INTENCLR);
      --  Error source
      ERRORSRC         : aliased ERRORSRC_Register;
      pragma Volatile_Full_Access (ERRORSRC);
      --  Enable TWIM
      ENABLE           : aliased ENABLE_Register;
      pragma Volatile_Full_Access (ENABLE);
      --  Unspecified
      PSEL             : aliased TWIM_PSEL_Cluster;
      --  TWI frequency. Accuracy depends on the HFCLK source selected.
      FREQUENCY        : aliased NRF52840.UInt32;
      --  RXD EasyDMA channel
      RXD              : aliased TWIM_RXD_Cluster;
      --  TXD EasyDMA channel
      TXD              : aliased TWIM_TXD_Cluster;
      --  Address used in the TWI transfer
      ADDRESS          : aliased ADDRESS_Register;
      pragma Volatile_Full_Access (ADDRESS);
   end record
     with Volatile;

   for TWIM_Peripheral use record
      TASKS_STARTRX    at 16#0# range 0 .. 31;
      TASKS_STARTTX    at 16#8# range 0 .. 31;
      TASKS_STOP       at 16#14# range 0 .. 31;
      TASKS_SUSPEND    at 16#1C# range 0 .. 31;
      TASKS_RESUME     at 16#20# range 0 .. 31;
      EVENTS_STOPPED   at 16#104# range 0 .. 31;
      EVENTS_ERROR     at 16#124# range 0 .. 31;
      EVENTS_SUSPENDED at 16#148# range 0 .. 31;
      EVENTS_RXSTARTED at 16#14C# range 0 .. 31;
      EVENTS_TXSTARTED at 16#150# range 0 .. 31;
      EVENTS_LASTRX    at 16#15C# range 0 .. 31;
      EVENTS_LASTTX    at 16#160# range 0 .. 31;
      SHORTS           at 16#200# range 0 .. 31;
      INTEN            at 16#300# range 0 .. 31;
      INTENSET         at 16#304# range 0 .. 31;
      INTENCLR         at 16#308# range 0 .. 31;
      ERRORSRC         at 16#4C4# range 0 .. 31;
      ENABLE           at 16#500# range 0 .. 31;
      PSEL             at 16#508# range 0 .. 63;
      FREQUENCY        at 16#524# range 0 .. 31;
      RXD              at 16#534# range 0 .. 127;
      TXD              at 16#544# range 0 .. 127;
      ADDRESS          at 16#588# range 0 .. 31;
   end record;

   --  I2C compatible Two-Wire Master Interface with EasyDMA 0
   TWIM0_Periph : aliased TWIM_Peripheral
     with Import, Address => TWIM0_Base;

   --  I2C compatible Two-Wire Master Interface with EasyDMA 1
   TWIM1_Periph : aliased TWIM_Peripheral
     with Import, Address => TWIM1_Base;

end NRF52840.TWIM;
