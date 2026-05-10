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

package NRF52840.AAR is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   subtype TASKS_START_TASKS_START_Field is NRF52840.Bit;

   --  Start resolving addresses based on IRKs specified in the IRK data
   --  structure
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

   --  Stop resolving addresses
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

   subtype EVENTS_END_EVENTS_END_Field is NRF52840.Bit;

   --  Address resolution procedure complete
   type EVENTS_END_Register is record
      EVENTS_END    : EVENTS_END_EVENTS_END_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_END_Register use record
      EVENTS_END    at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_RESOLVED_EVENTS_RESOLVED_Field is NRF52840.Bit;

   --  Address resolved
   type EVENTS_RESOLVED_Register is record
      EVENTS_RESOLVED : EVENTS_RESOLVED_EVENTS_RESOLVED_Field := 16#0#;
      --  unspecified
      Reserved_1_31   : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_RESOLVED_Register use record
      EVENTS_RESOLVED at 0 range 0 .. 0;
      Reserved_1_31   at 0 range 1 .. 31;
   end record;

   subtype EVENTS_NOTRESOLVED_EVENTS_NOTRESOLVED_Field is NRF52840.Bit;

   --  Address not resolved
   type EVENTS_NOTRESOLVED_Register is record
      EVENTS_NOTRESOLVED : EVENTS_NOTRESOLVED_EVENTS_NOTRESOLVED_Field :=
                            16#0#;
      --  unspecified
      Reserved_1_31      : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_NOTRESOLVED_Register use record
      EVENTS_NOTRESOLVED at 0 range 0 .. 0;
      Reserved_1_31      at 0 range 1 .. 31;
   end record;

   --  Write '1' to enable interrupt for END event
   type INTENSET_END_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_END_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for END event
   type INTENSET_END_Field_1 is
     (--  Reset value for the field
      INTENSET_END_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_END_Field_1 use
     (INTENSET_END_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for RESOLVED event
   type INTENSET_RESOLVED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_RESOLVED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for RESOLVED event
   type INTENSET_RESOLVED_Field_1 is
     (--  Reset value for the field
      INTENSET_RESOLVED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_RESOLVED_Field_1 use
     (INTENSET_RESOLVED_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for NOTRESOLVED event
   type INTENSET_NOTRESOLVED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_NOTRESOLVED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for NOTRESOLVED event
   type INTENSET_NOTRESOLVED_Field_1 is
     (--  Reset value for the field
      INTENSET_NOTRESOLVED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_NOTRESOLVED_Field_1 use
     (INTENSET_NOTRESOLVED_Field_Reset => 0,
      Set => 1);

   --  Enable interrupt
   type INTENSET_Register is record
      --  Write '1' to enable interrupt for END event
      END_k         : INTENSET_END_Field_1 := INTENSET_END_Field_Reset;
      --  Write '1' to enable interrupt for RESOLVED event
      RESOLVED      : INTENSET_RESOLVED_Field_1 :=
                       INTENSET_RESOLVED_Field_Reset;
      --  Write '1' to enable interrupt for NOTRESOLVED event
      NOTRESOLVED   : INTENSET_NOTRESOLVED_Field_1 :=
                       INTENSET_NOTRESOLVED_Field_Reset;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENSET_Register use record
      END_k         at 0 range 0 .. 0;
      RESOLVED      at 0 range 1 .. 1;
      NOTRESOLVED   at 0 range 2 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   --  Write '1' to disable interrupt for END event
   type INTENCLR_END_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_END_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for END event
   type INTENCLR_END_Field_1 is
     (--  Reset value for the field
      INTENCLR_END_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_END_Field_1 use
     (INTENCLR_END_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for RESOLVED event
   type INTENCLR_RESOLVED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_RESOLVED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for RESOLVED event
   type INTENCLR_RESOLVED_Field_1 is
     (--  Reset value for the field
      INTENCLR_RESOLVED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_RESOLVED_Field_1 use
     (INTENCLR_RESOLVED_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for NOTRESOLVED event
   type INTENCLR_NOTRESOLVED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_NOTRESOLVED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for NOTRESOLVED event
   type INTENCLR_NOTRESOLVED_Field_1 is
     (--  Reset value for the field
      INTENCLR_NOTRESOLVED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_NOTRESOLVED_Field_1 use
     (INTENCLR_NOTRESOLVED_Field_Reset => 0,
      Clear => 1);

   --  Disable interrupt
   type INTENCLR_Register is record
      --  Write '1' to disable interrupt for END event
      END_k         : INTENCLR_END_Field_1 := INTENCLR_END_Field_Reset;
      --  Write '1' to disable interrupt for RESOLVED event
      RESOLVED      : INTENCLR_RESOLVED_Field_1 :=
                       INTENCLR_RESOLVED_Field_Reset;
      --  Write '1' to disable interrupt for NOTRESOLVED event
      NOTRESOLVED   : INTENCLR_NOTRESOLVED_Field_1 :=
                       INTENCLR_NOTRESOLVED_Field_Reset;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENCLR_Register use record
      END_k         at 0 range 0 .. 0;
      RESOLVED      at 0 range 1 .. 1;
      NOTRESOLVED   at 0 range 2 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   subtype STATUS_STATUS_Field is NRF52840.UInt4;

   --  Resolution status
   type STATUS_Register is record
      --  Read-only. The IRK that was used last time an address was resolved
      STATUS        : STATUS_STATUS_Field;
      --  unspecified
      Reserved_4_31 : NRF52840.UInt28;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for STATUS_Register use record
      STATUS        at 0 range 0 .. 3;
      Reserved_4_31 at 0 range 4 .. 31;
   end record;

   --  Enable or disable AAR
   type ENABLE_ENABLE_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 2;
   for ENABLE_ENABLE_Field use
     (Disabled => 0,
      Enabled => 3);

   --  Enable AAR
   type ENABLE_Register is record
      --  Enable or disable AAR
      ENABLE        : ENABLE_ENABLE_Field := NRF52840.AAR.Disabled;
      --  unspecified
      Reserved_2_31 : NRF52840.UInt30 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for ENABLE_Register use record
      ENABLE        at 0 range 0 .. 1;
      Reserved_2_31 at 0 range 2 .. 31;
   end record;

   subtype NIRK_NIRK_Field is NRF52840.UInt5;

   --  Number of IRKs
   type NIRK_Register is record
      --  Number of Identity root keys available in the IRK data structure
      NIRK          : NIRK_NIRK_Field := 16#1#;
      --  unspecified
      Reserved_5_31 : NRF52840.UInt27 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for NIRK_Register use record
      NIRK          at 0 range 0 .. 4;
      Reserved_5_31 at 0 range 5 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  Accelerated Address Resolver
   type AAR_Peripheral is record
      --  Start resolving addresses based on IRKs specified in the IRK data
      --  structure
      TASKS_START        : aliased TASKS_START_Register;
      pragma Volatile_Full_Access (TASKS_START);
      --  Stop resolving addresses
      TASKS_STOP         : aliased TASKS_STOP_Register;
      pragma Volatile_Full_Access (TASKS_STOP);
      --  Address resolution procedure complete
      EVENTS_END         : aliased EVENTS_END_Register;
      pragma Volatile_Full_Access (EVENTS_END);
      --  Address resolved
      EVENTS_RESOLVED    : aliased EVENTS_RESOLVED_Register;
      pragma Volatile_Full_Access (EVENTS_RESOLVED);
      --  Address not resolved
      EVENTS_NOTRESOLVED : aliased EVENTS_NOTRESOLVED_Register;
      pragma Volatile_Full_Access (EVENTS_NOTRESOLVED);
      --  Enable interrupt
      INTENSET           : aliased INTENSET_Register;
      pragma Volatile_Full_Access (INTENSET);
      --  Disable interrupt
      INTENCLR           : aliased INTENCLR_Register;
      pragma Volatile_Full_Access (INTENCLR);
      --  Resolution status
      STATUS             : aliased STATUS_Register;
      pragma Volatile_Full_Access (STATUS);
      --  Enable AAR
      ENABLE             : aliased ENABLE_Register;
      pragma Volatile_Full_Access (ENABLE);
      --  Number of IRKs
      NIRK               : aliased NIRK_Register;
      pragma Volatile_Full_Access (NIRK);
      --  Pointer to IRK data structure
      IRKPTR             : aliased NRF52840.UInt32;
      --  Pointer to the resolvable address
      ADDRPTR            : aliased NRF52840.UInt32;
      --  Pointer to data area used for temporary storage
      SCRATCHPTR         : aliased NRF52840.UInt32;
   end record
     with Volatile;

   for AAR_Peripheral use record
      TASKS_START        at 16#0# range 0 .. 31;
      TASKS_STOP         at 16#8# range 0 .. 31;
      EVENTS_END         at 16#100# range 0 .. 31;
      EVENTS_RESOLVED    at 16#104# range 0 .. 31;
      EVENTS_NOTRESOLVED at 16#108# range 0 .. 31;
      INTENSET           at 16#304# range 0 .. 31;
      INTENCLR           at 16#308# range 0 .. 31;
      STATUS             at 16#400# range 0 .. 31;
      ENABLE             at 16#500# range 0 .. 31;
      NIRK               at 16#504# range 0 .. 31;
      IRKPTR             at 16#508# range 0 .. 31;
      ADDRPTR            at 16#510# range 0 .. 31;
      SCRATCHPTR         at 16#514# range 0 .. 31;
   end record;

   --  Accelerated Address Resolver
   AAR_Periph : aliased AAR_Peripheral
     with Import, Address => AAR_Base;

end NRF52840.AAR;
