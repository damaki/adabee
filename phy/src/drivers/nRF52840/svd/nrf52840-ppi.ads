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

package NRF52840.PPI is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   ---------------------------------------
   -- PPI_TASKS_CHG cluster's Registers --
   ---------------------------------------

   subtype EN_TASKS_CHG_EN_Field is NRF52840.Bit;

   --  Description cluster[n]: Enable channel group n
   type EN_TASKS_CHG_Register is record
      --  Write-only.
      EN            : EN_TASKS_CHG_EN_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EN_TASKS_CHG_Register use record
      EN            at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype DIS_TASKS_CHG_DIS_Field is NRF52840.Bit;

   --  Description cluster[n]: Disable channel group n
   type DIS_TASKS_CHG_Register is record
      --  Write-only.
      DIS           : DIS_TASKS_CHG_DIS_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for DIS_TASKS_CHG_Register use record
      DIS           at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   --  Channel group tasks
   type PPI_TASKS_CHG_Cluster is record
      --  Description cluster[n]: Enable channel group n
      EN  : aliased EN_TASKS_CHG_Register;
      pragma Volatile_Full_Access (EN);
      --  Description cluster[n]: Disable channel group n
      DIS : aliased DIS_TASKS_CHG_Register;
      pragma Volatile_Full_Access (DIS);
   end record
     with Size => 64;

   for PPI_TASKS_CHG_Cluster use record
      EN  at 16#0# range 0 .. 31;
      DIS at 16#4# range 0 .. 31;
   end record;

   --  Channel group tasks
   type PPI_TASKS_CHG_Clusters is array (0 .. 5) of PPI_TASKS_CHG_Cluster;

   --  Enable or disable channel 0
   type CHEN_CH0_Field is
     (--  Disable channel
      Disabled,
      --  Enable channel
      Enabled)
     with Size => 1;
   for CHEN_CH0_Field use
     (Disabled => 0,
      Enabled => 1);

   --  CHEN_CH array
   type CHEN_CH_Field_Array is array (0 .. 31) of CHEN_CH0_Field
     with Component_Size => 1, Size => 32;

   --  Channel enable register
   type CHEN_Register
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  CH as a value
            Val : NRF52840.UInt32;
         when True =>
            --  CH as an array
            Arr : CHEN_CH_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 32, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CHEN_Register use record
      Val at 0 range 0 .. 31;
      Arr at 0 range 0 .. 31;
   end record;

   --  Channel 0 enable set register. Writing '0' has no effect
   type CHENSET_CH0_Field is
     (--  Read: channel disabled
      Disabled,
      --  Read: channel enabled
      Enabled)
     with Size => 1;
   for CHENSET_CH0_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Channel 0 enable set register. Writing '0' has no effect
   type CHENSET_CH0_Field_1 is
     (--  Reset value for the field
      CHENSET_CH0_Field_Reset,
      --  Write: Enable channel
      Set)
     with Size => 1;
   for CHENSET_CH0_Field_1 use
     (CHENSET_CH0_Field_Reset => 0,
      Set => 1);

   --  CHENSET_CH array
   type CHENSET_CH_Field_Array is array (0 .. 31) of CHENSET_CH0_Field_1
     with Component_Size => 1, Size => 32;

   --  Channel enable set register
   type CHENSET_Register
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  CH as a value
            Val : NRF52840.UInt32;
         when True =>
            --  CH as an array
            Arr : CHENSET_CH_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 32, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CHENSET_Register use record
      Val at 0 range 0 .. 31;
      Arr at 0 range 0 .. 31;
   end record;

   --  Channel 0 enable clear register. Writing '0' has no effect
   type CHENCLR_CH0_Field is
     (--  Read: channel disabled
      Disabled,
      --  Read: channel enabled
      Enabled)
     with Size => 1;
   for CHENCLR_CH0_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Channel 0 enable clear register. Writing '0' has no effect
   type CHENCLR_CH0_Field_1 is
     (--  Reset value for the field
      CHENCLR_CH0_Field_Reset,
      --  Write: disable channel
      Clear)
     with Size => 1;
   for CHENCLR_CH0_Field_1 use
     (CHENCLR_CH0_Field_Reset => 0,
      Clear => 1);

   --  CHENCLR_CH array
   type CHENCLR_CH_Field_Array is array (0 .. 31) of CHENCLR_CH0_Field_1
     with Component_Size => 1, Size => 32;

   --  Channel enable clear register
   type CHENCLR_Register
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  CH as a value
            Val : NRF52840.UInt32;
         when True =>
            --  CH as an array
            Arr : CHENCLR_CH_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 32, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CHENCLR_Register use record
      Val at 0 range 0 .. 31;
      Arr at 0 range 0 .. 31;
   end record;

   --------------------------------
   -- PPI_CH cluster's Registers --
   --------------------------------

   --  PPI Channel
   type PPI_CH_Cluster is record
      --  Description cluster[n]: Channel n event end-point
      EEP : aliased NRF52840.UInt32;
      --  Description cluster[n]: Channel n task end-point
      TEP : aliased NRF52840.UInt32;
   end record
     with Size => 64;

   for PPI_CH_Cluster use record
      EEP at 16#0# range 0 .. 31;
      TEP at 16#4# range 0 .. 31;
   end record;

   --  PPI Channel
   type PPI_CH_Clusters is array (0 .. 19) of PPI_CH_Cluster;

   --  Include or exclude channel 0
   type CHG_CH0_Field is
     (--  Exclude
      Excluded,
      --  Include
      Included)
     with Size => 1;
   for CHG_CH0_Field use
     (Excluded => 0,
      Included => 1);

   --  CHG_CH array
   type CHG_CH_Field_Array is array (0 .. 31) of CHG_CH0_Field
     with Component_Size => 1, Size => 32;

   --  Description collection[n]: Channel group n
   type CHG_Register
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  CH as a value
            Val : NRF52840.UInt32;
         when True =>
            --  CH as an array
            Arr : CHG_CH_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 32, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CHG_Register use record
      Val at 0 range 0 .. 31;
      Arr at 0 range 0 .. 31;
   end record;

   ----------------------------------
   -- PPI_FORK cluster's Registers --
   ----------------------------------

   --  Fork
   type PPI_FORK_Cluster is record
      --  Description cluster[n]: Channel n task end-point
      TEP : aliased NRF52840.UInt32;
   end record
     with Size => 32;

   for PPI_FORK_Cluster use record
      TEP at 0 range 0 .. 31;
   end record;

   --  Fork
   type PPI_FORK_Clusters is array (0 .. 31) of PPI_FORK_Cluster;

   -----------------
   -- Peripherals --
   -----------------

   --  Programmable Peripheral Interconnect
   type PPI_Peripheral is record
      --  Channel group tasks
      TASKS_CHG : aliased PPI_TASKS_CHG_Clusters;
      --  Channel enable register
      CHEN      : aliased CHEN_Register;
      pragma Volatile_Full_Access (CHEN);
      --  Channel enable set register
      CHENSET   : aliased CHENSET_Register;
      pragma Volatile_Full_Access (CHENSET);
      --  Channel enable clear register
      CHENCLR   : aliased CHENCLR_Register;
      pragma Volatile_Full_Access (CHENCLR);
      --  PPI Channel
      CH        : aliased PPI_CH_Clusters;
      --  Description collection[n]: Channel group n
      CHG_0     : aliased CHG_Register;
      pragma Volatile_Full_Access (CHG_0);
      --  Description collection[n]: Channel group n
      CHG_1     : aliased CHG_Register;
      pragma Volatile_Full_Access (CHG_1);
      --  Description collection[n]: Channel group n
      CHG_2     : aliased CHG_Register;
      pragma Volatile_Full_Access (CHG_2);
      --  Description collection[n]: Channel group n
      CHG_3     : aliased CHG_Register;
      pragma Volatile_Full_Access (CHG_3);
      --  Description collection[n]: Channel group n
      CHG_4     : aliased CHG_Register;
      pragma Volatile_Full_Access (CHG_4);
      --  Description collection[n]: Channel group n
      CHG_5     : aliased CHG_Register;
      pragma Volatile_Full_Access (CHG_5);
      --  Fork
      FORK      : aliased PPI_FORK_Clusters;
   end record
     with Volatile;

   for PPI_Peripheral use record
      TASKS_CHG at 16#0# range 0 .. 383;
      CHEN      at 16#500# range 0 .. 31;
      CHENSET   at 16#504# range 0 .. 31;
      CHENCLR   at 16#508# range 0 .. 31;
      CH        at 16#510# range 0 .. 1279;
      CHG_0     at 16#800# range 0 .. 31;
      CHG_1     at 16#804# range 0 .. 31;
      CHG_2     at 16#808# range 0 .. 31;
      CHG_3     at 16#80C# range 0 .. 31;
      CHG_4     at 16#810# range 0 .. 31;
      CHG_5     at 16#814# range 0 .. 31;
      FORK      at 16#910# range 0 .. 1023;
   end record;

   --  Programmable Peripheral Interconnect
   PPI_Periph : aliased PPI_Peripheral
     with Import, Address => PPI_Base;

end NRF52840.PPI;
