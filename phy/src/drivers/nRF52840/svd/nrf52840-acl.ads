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

package NRF52840.ACL is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   ---------------------------------
   -- ACL_ACL cluster's Registers --
   ---------------------------------

   --  Configure write and erase permissions for region n. Write '0' has no
   --  effect.
   type PERM_WRITE_Field is
     (--  Allow write and erase instructions to region n
      Enable,
      --  Block write and erase instructions to region n
      Disable)
     with Size => 1;
   for PERM_WRITE_Field use
     (Enable => 0,
      Disable => 1);

   --  Configure read permissions for region n. Write '0' has no effect.
   type PERM_READ_Field is
     (--  Allow read instructions to region n
      Enable,
      --  Block read instructions to region n
      Disable)
     with Size => 1;
   for PERM_READ_Field use
     (Enable => 0,
      Disable => 1);

   --  Description cluster[n]: Access permissions for region n as defined by
   --  start address ACL[n].ADDR and size ACL[n].SIZE
   type PERM_ACL_Register is record
      --  unspecified
      Reserved_0_0  : NRF52840.Bit := 16#0#;
      --  Configure write and erase permissions for region n. Write '0' has no
      --  effect.
      WRITE         : PERM_WRITE_Field := NRF52840.ACL.Enable;
      --  Configure read permissions for region n. Write '0' has no effect.
      READ          : PERM_READ_Field := NRF52840.ACL.Enable;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for PERM_ACL_Register use record
      Reserved_0_0  at 0 range 0 .. 0;
      WRITE         at 0 range 1 .. 1;
      READ          at 0 range 2 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   --  Unspecified
   type ACL_ACL_Cluster is record
      --  Description cluster[n]: Configure the word-aligned start address of
      --  region n to protect
      ADDR    : aliased NRF52840.UInt32;
      --  Description cluster[n]: Size of region to protect counting from
      --  address ACL[n].ADDR. Write '0' as no effect.
      SIZE    : aliased NRF52840.UInt32;
      --  Description cluster[n]: Access permissions for region n as defined by
      --  start address ACL[n].ADDR and size ACL[n].SIZE
      PERM    : aliased PERM_ACL_Register;
      pragma Volatile_Full_Access (PERM);
      --  Unspecified
      UNUSED0 : aliased NRF52840.UInt32;
   end record
     with Size => 128;

   for ACL_ACL_Cluster use record
      ADDR    at 16#0# range 0 .. 31;
      SIZE    at 16#4# range 0 .. 31;
      PERM    at 16#8# range 0 .. 31;
      UNUSED0 at 16#C# range 0 .. 31;
   end record;

   --  Unspecified
   type ACL_ACL_Clusters is array (0 .. 7) of ACL_ACL_Cluster;

   -----------------
   -- Peripherals --
   -----------------

   --  Access control lists
   type ACL_Peripheral is record
      --  Unspecified
      ACL : aliased ACL_ACL_Clusters;
   end record
     with Volatile;

   for ACL_Peripheral use record
      ACL at 16#800# range 0 .. 1023;
   end record;

   --  Access control lists
   ACL_Periph : aliased ACL_Peripheral
     with Import, Address => ACL_Base;

end NRF52840.ACL;
