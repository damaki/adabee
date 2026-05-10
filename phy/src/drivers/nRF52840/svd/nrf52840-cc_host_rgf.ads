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

package NRF52840.CC_HOST_RGF is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   --  Select the source of the HW key that is used by the AES engine
   type HOST_CRYPTOKEY_SEL_HOST_CRYPTOKEY_SEL_Field is
     (--  Use device root key K_DR from CRYPTOCELL AO power domain
      K_DR,
      --  Use hard-coded RTL key K_PRTL
      K_PRTL,
      --  Use provided session key
      Session)
     with Size => 2;
   for HOST_CRYPTOKEY_SEL_HOST_CRYPTOKEY_SEL_Field use
     (K_DR => 0,
      K_PRTL => 1,
      Session => 2);

   --  AES hardware key select
   type HOST_CRYPTOKEY_SEL_Register is record
      --  Select the source of the HW key that is used by the AES engine
      HOST_CRYPTOKEY_SEL : HOST_CRYPTOKEY_SEL_HOST_CRYPTOKEY_SEL_Field :=
                            NRF52840.CC_HOST_RGF.K_DR;
      --  unspecified
      Reserved_2_31      : NRF52840.UInt30 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for HOST_CRYPTOKEY_SEL_Register use record
      HOST_CRYPTOKEY_SEL at 0 range 0 .. 1;
      Reserved_2_31      at 0 range 2 .. 31;
   end record;

   --  This register is the K_PRTL lock register. When this register is set,
   --  K_PRTL can not be used and a zeroed key will be used instead. The value
   --  of this register is saved in the CRYPTOCELL AO power domain.
   type HOST_IOT_KPRTL_LOCK_HOST_IOT_KPRTL_LOCK_Field is
     (--  K_PRTL can be selected for use from register HOST_CRYPTOKEY_SEL
      Disabled,
      --  K_PRTL has been locked until next power-on reset (POR). If K_PRTL is
--  selected anyway, a zeroed key will be used instead.
      Enabled)
     with Size => 1;
   for HOST_IOT_KPRTL_LOCK_HOST_IOT_KPRTL_LOCK_Field use
     (Disabled => 0,
      Enabled => 1);

   --  This write-once register is the K_PRTL lock register. When this register
   --  is set, K_PRTL can not be used and a zeroed key will be used instead.
   --  The value of this register is saved in the CRYPTOCELL AO power domain.
   type HOST_IOT_KPRTL_LOCK_Register is record
      --  This register is the K_PRTL lock register. When this register is set,
      --  K_PRTL can not be used and a zeroed key will be used instead. The
      --  value of this register is saved in the CRYPTOCELL AO power domain.
      HOST_IOT_KPRTL_LOCK : HOST_IOT_KPRTL_LOCK_HOST_IOT_KPRTL_LOCK_Field :=
                             NRF52840.CC_HOST_RGF.Disabled;
      --  unspecified
      Reserved_1_31       : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for HOST_IOT_KPRTL_LOCK_Register use record
      HOST_IOT_KPRTL_LOCK at 0 range 0 .. 0;
      Reserved_1_31       at 0 range 1 .. 31;
   end record;

   --  Lifecycle state value. This field is write-once per reset.
   type HOST_IOT_LCS_LCS_Field is
     (--  CC310 operates in debug mode
      Debug,
      --  CC310 operates in secure mode
      Secure)
     with Size => 3;
   for HOST_IOT_LCS_LCS_Field use
     (Debug => 0,
      Secure => 2);

   --  This field is read-only and indicates if CRYPTOCELL LCS has been
   --  successfully configured since last reset
   type HOST_IOT_LCS_LCS_IS_VALID_Field is
     (--  A valid LCS is not yet retained in the CRYPTOCELL AO power domain
      Invalid,
      --  A valid LCS is successfully retained in the CRYPTOCELL AO power domain
      Valid)
     with Size => 1;
   for HOST_IOT_LCS_LCS_IS_VALID_Field use
     (Invalid => 0,
      Valid => 1);

   --  Controls lifecycle state (LCS) for CRYPTOCELL subsystem
   type HOST_IOT_LCS_Register is record
      --  Lifecycle state value. This field is write-once per reset.
      LCS           : HOST_IOT_LCS_LCS_Field := NRF52840.CC_HOST_RGF.Secure;
      --  unspecified
      Reserved_3_7  : NRF52840.UInt5 := 16#0#;
      --  This field is read-only and indicates if CRYPTOCELL LCS has been
      --  successfully configured since last reset
      LCS_IS_VALID  : HOST_IOT_LCS_LCS_IS_VALID_Field :=
                       NRF52840.CC_HOST_RGF.Invalid;
      --  unspecified
      Reserved_9_31 : NRF52840.UInt23 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for HOST_IOT_LCS_Register use record
      LCS           at 0 range 0 .. 2;
      Reserved_3_7  at 0 range 3 .. 7;
      LCS_IS_VALID  at 0 range 8 .. 8;
      Reserved_9_31 at 0 range 9 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  CRYPTOCELL HOST_RGF interface
   type CC_HOST_RGF_Peripheral is record
      --  AES hardware key select
      HOST_CRYPTOKEY_SEL  : aliased HOST_CRYPTOKEY_SEL_Register;
      pragma Volatile_Full_Access (HOST_CRYPTOKEY_SEL);
      --  This write-once register is the K_PRTL lock register. When this
      --  register is set, K_PRTL can not be used and a zeroed key will be used
      --  instead. The value of this register is saved in the CRYPTOCELL AO
      --  power domain.
      HOST_IOT_KPRTL_LOCK : aliased HOST_IOT_KPRTL_LOCK_Register;
      pragma Volatile_Full_Access (HOST_IOT_KPRTL_LOCK);
      --  This register holds bits 31:0 of K_DR. The value of this register is
      --  saved in the CRYPTOCELL AO power domain. Reading from this address
      --  returns the K_DR valid status indicating if K_DR is successfully
      --  retained.
      HOST_IOT_KDR0       : aliased NRF52840.UInt32;
      --  This register holds bits 63:32 of K_DR. The value of this register is
      --  saved in the CRYPTOCELL AO power domain.
      HOST_IOT_KDR1       : aliased NRF52840.UInt32;
      --  This register holds bits 95:64 of K_DR. The value of this register is
      --  saved in the CRYPTOCELL AO power domain.
      HOST_IOT_KDR2       : aliased NRF52840.UInt32;
      --  This register holds bits 127:96 of K_DR. The value of this register
      --  is saved in the CRYPTOCELL AO power domain.
      HOST_IOT_KDR3       : aliased NRF52840.UInt32;
      --  Controls lifecycle state (LCS) for CRYPTOCELL subsystem
      HOST_IOT_LCS        : aliased HOST_IOT_LCS_Register;
      pragma Volatile_Full_Access (HOST_IOT_LCS);
   end record
     with Volatile;

   for CC_HOST_RGF_Peripheral use record
      HOST_CRYPTOKEY_SEL  at 16#1A38# range 0 .. 31;
      HOST_IOT_KPRTL_LOCK at 16#1A4C# range 0 .. 31;
      HOST_IOT_KDR0       at 16#1A50# range 0 .. 31;
      HOST_IOT_KDR1       at 16#1A54# range 0 .. 31;
      HOST_IOT_KDR2       at 16#1A58# range 0 .. 31;
      HOST_IOT_KDR3       at 16#1A5C# range 0 .. 31;
      HOST_IOT_LCS        at 16#1A60# range 0 .. 31;
   end record;

   --  CRYPTOCELL HOST_RGF interface
   CC_HOST_RGF_Periph : aliased CC_HOST_RGF_Peripheral
     with Import, Address => CC_HOST_RGF_Base;

end NRF52840.CC_HOST_RGF;
