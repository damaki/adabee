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

package NRF52840.FICR is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   --  Description collection[n]: Device identifier
   --  Description collection[n]: Encryption root, word n
   --  Description collection[n]: Identity Root, word n

   --  Device address type
   type DEVICEADDRTYPE_DEVICEADDRTYPE_Field is
     (--  Public address
      Public,
      --  Random address
      Random)
     with Size => 1;
   for DEVICEADDRTYPE_DEVICEADDRTYPE_Field use
     (Public => 0,
      Random => 1);

   --  Device address type
   type DEVICEADDRTYPE_Register is record
      --  Read-only. Device address type
      DEVICEADDRTYPE : DEVICEADDRTYPE_DEVICEADDRTYPE_Field;
      --  unspecified
      Reserved_1_31  : NRF52840.UInt31;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for DEVICEADDRTYPE_Register use record
      DEVICEADDRTYPE at 0 range 0 .. 0;
      Reserved_1_31  at 0 range 1 .. 31;
   end record;

   --  Description collection[n]: Device address n

   -----------------------------------
   -- FICR_INFO cluster's Registers --
   -----------------------------------

   --  Unspecified

   --  Device info
   type FICR_INFO_Cluster is record
      --  Part code
      PART      : aliased NRF52840.UInt32;
      --  Build code (hardware version and production configuration)
      VARIANT   : aliased NRF52840.UInt32;
      --  Package option
      PACKAGE_k : aliased NRF52840.UInt32;
      --  RAM variant
      RAM       : aliased NRF52840.UInt32;
      --  Flash variant
      FLASH     : aliased NRF52840.UInt32;
      --  Unspecified
      UNUSED8_0 : aliased NRF52840.UInt32;
      --  Unspecified
      UNUSED8_1 : aliased NRF52840.UInt32;
      --  Unspecified
      UNUSED8_2 : aliased NRF52840.UInt32;
   end record
     with Size => 256;

   for FICR_INFO_Cluster use record
      PART      at 16#0# range 0 .. 31;
      VARIANT   at 16#4# range 0 .. 31;
      PACKAGE_k at 16#8# range 0 .. 31;
      RAM       at 16#C# range 0 .. 31;
      FLASH     at 16#10# range 0 .. 31;
      UNUSED8_0 at 16#14# range 0 .. 31;
      UNUSED8_1 at 16#18# range 0 .. 31;
      UNUSED8_2 at 16#1C# range 0 .. 31;
   end record;

   --  Description collection[n]: Production test signature n

   -----------------------------------
   -- FICR_TEMP cluster's Registers --
   -----------------------------------

   subtype A_A_Field is NRF52840.UInt12;

   --  Slope definition A0
   type A_Register is record
      --  Read-only. A (slope definition) register.
      A              : A_A_Field;
      --  unspecified
      Reserved_12_31 : NRF52840.UInt20;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for A_Register use record
      A              at 0 range 0 .. 11;
      Reserved_12_31 at 0 range 12 .. 31;
   end record;

   subtype B_B_Field is NRF52840.UInt14;

   --  Y-intercept B0
   type B_Register is record
      --  Read-only. B (y-intercept)
      B              : B_B_Field;
      --  unspecified
      Reserved_14_31 : NRF52840.UInt18;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for B_Register use record
      B              at 0 range 0 .. 13;
      Reserved_14_31 at 0 range 14 .. 31;
   end record;

   subtype T_T_Field is NRF52840.Byte;

   --  Segment end T0
   type T_Register is record
      --  Read-only. T (segment end) register
      T             : T_T_Field;
      --  unspecified
      Reserved_8_31 : NRF52840.UInt24;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for T_Register use record
      T             at 0 range 0 .. 7;
      Reserved_8_31 at 0 range 8 .. 31;
   end record;

   --  Registers storing factory TEMP module linearization coefficients
   type FICR_TEMP_Cluster is record
      --  Slope definition A0
      A0 : aliased A_Register;
      pragma Volatile_Full_Access (A0);
      --  Slope definition A1
      A1 : aliased A_Register;
      pragma Volatile_Full_Access (A1);
      --  Slope definition A2
      A2 : aliased A_Register;
      pragma Volatile_Full_Access (A2);
      --  Slope definition A3
      A3 : aliased A_Register;
      pragma Volatile_Full_Access (A3);
      --  Slope definition A4
      A4 : aliased A_Register;
      pragma Volatile_Full_Access (A4);
      --  Slope definition A5
      A5 : aliased A_Register;
      pragma Volatile_Full_Access (A5);
      --  Y-intercept B0
      B0 : aliased B_Register;
      pragma Volatile_Full_Access (B0);
      --  Y-intercept B1
      B1 : aliased B_Register;
      pragma Volatile_Full_Access (B1);
      --  Y-intercept B2
      B2 : aliased B_Register;
      pragma Volatile_Full_Access (B2);
      --  Y-intercept B3
      B3 : aliased B_Register;
      pragma Volatile_Full_Access (B3);
      --  Y-intercept B4
      B4 : aliased B_Register;
      pragma Volatile_Full_Access (B4);
      --  Y-intercept B5
      B5 : aliased B_Register;
      pragma Volatile_Full_Access (B5);
      --  Segment end T0
      T0 : aliased T_Register;
      pragma Volatile_Full_Access (T0);
      --  Segment end T1
      T1 : aliased T_Register;
      pragma Volatile_Full_Access (T1);
      --  Segment end T2
      T2 : aliased T_Register;
      pragma Volatile_Full_Access (T2);
      --  Segment end T3
      T3 : aliased T_Register;
      pragma Volatile_Full_Access (T3);
      --  Segment end T4
      T4 : aliased T_Register;
      pragma Volatile_Full_Access (T4);
   end record
     with Size => 544;

   for FICR_TEMP_Cluster use record
      A0 at 16#0# range 0 .. 31;
      A1 at 16#4# range 0 .. 31;
      A2 at 16#8# range 0 .. 31;
      A3 at 16#C# range 0 .. 31;
      A4 at 16#10# range 0 .. 31;
      A5 at 16#14# range 0 .. 31;
      B0 at 16#18# range 0 .. 31;
      B1 at 16#1C# range 0 .. 31;
      B2 at 16#20# range 0 .. 31;
      B3 at 16#24# range 0 .. 31;
      B4 at 16#28# range 0 .. 31;
      B5 at 16#2C# range 0 .. 31;
      T0 at 16#30# range 0 .. 31;
      T1 at 16#34# range 0 .. 31;
      T2 at 16#38# range 0 .. 31;
      T3 at 16#3C# range 0 .. 31;
      T4 at 16#40# range 0 .. 31;
   end record;

   ----------------------------------
   -- FICR_NFC cluster's Registers --
   ----------------------------------

   subtype TAGHEADER0_NFC_MFGID_Field is NRF52840.Byte;
   --  TAGHEADER0_NFC_UD array element
   subtype TAGHEADER0_NFC_UD_Element is NRF52840.Byte;

   --  TAGHEADER0_NFC_UD array
   type TAGHEADER0_NFC_UD_Field_Array is array (1 .. 3)
     of TAGHEADER0_NFC_UD_Element
     with Component_Size => 8, Size => 24;

   --  Type definition for TAGHEADER0_NFC_UD
   type TAGHEADER0_NFC_UD_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  UD as a value
            Val : NRF52840.UInt24;
         when True =>
            --  UD as an array
            Arr : TAGHEADER0_NFC_UD_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 24;

   for TAGHEADER0_NFC_UD_Field use record
      Val at 0 range 0 .. 23;
      Arr at 0 range 0 .. 23;
   end record;

   --  Default header for NFC tag. Software can read these values to populate
   --  NFCID1_3RD_LAST, NFCID1_2ND_LAST and NFCID1_LAST.
   type TAGHEADER0_NFC_Register is record
      --  Read-only. Default Manufacturer ID: Nordic Semiconductor ASA has ICM
      --  0x5F
      MFGID : TAGHEADER0_NFC_MFGID_Field;
      --  Read-only. Unique identifier byte 1
      UD    : TAGHEADER0_NFC_UD_Field;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TAGHEADER0_NFC_Register use record
      MFGID at 0 range 0 .. 7;
      UD    at 0 range 8 .. 31;
   end record;

   --  TAGHEADER1_NFC_UD array element
   subtype TAGHEADER1_NFC_UD_Element is NRF52840.Byte;

   --  TAGHEADER1_NFC_UD array
   type TAGHEADER1_NFC_UD_Field_Array is array (4 .. 7)
     of TAGHEADER1_NFC_UD_Element
     with Component_Size => 8, Size => 32;

   --  Default header for NFC tag. Software can read these values to populate
   --  NFCID1_3RD_LAST, NFCID1_2ND_LAST and NFCID1_LAST.
   type TAGHEADER1_NFC_Register
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  UD as a value
            Val : NRF52840.UInt32;
         when True =>
            --  UD as an array
            Arr : TAGHEADER1_NFC_UD_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 32, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for TAGHEADER1_NFC_Register use record
      Val at 0 range 0 .. 31;
      Arr at 0 range 0 .. 31;
   end record;

   --  TAGHEADER2_NFC_UD array element
   subtype TAGHEADER2_NFC_UD_Element is NRF52840.Byte;

   --  TAGHEADER2_NFC_UD array
   type TAGHEADER2_NFC_UD_Field_Array is array (8 .. 11)
     of TAGHEADER2_NFC_UD_Element
     with Component_Size => 8, Size => 32;

   --  Default header for NFC tag. Software can read these values to populate
   --  NFCID1_3RD_LAST, NFCID1_2ND_LAST and NFCID1_LAST.
   type TAGHEADER2_NFC_Register
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  UD as a value
            Val : NRF52840.UInt32;
         when True =>
            --  UD as an array
            Arr : TAGHEADER2_NFC_UD_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 32, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for TAGHEADER2_NFC_Register use record
      Val at 0 range 0 .. 31;
      Arr at 0 range 0 .. 31;
   end record;

   --  TAGHEADER3_NFC_UD array element
   subtype TAGHEADER3_NFC_UD_Element is NRF52840.Byte;

   --  TAGHEADER3_NFC_UD array
   type TAGHEADER3_NFC_UD_Field_Array is array (12 .. 15)
     of TAGHEADER3_NFC_UD_Element
     with Component_Size => 8, Size => 32;

   --  Default header for NFC tag. Software can read these values to populate
   --  NFCID1_3RD_LAST, NFCID1_2ND_LAST and NFCID1_LAST.
   type TAGHEADER3_NFC_Register
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  UD as a value
            Val : NRF52840.UInt32;
         when True =>
            --  UD as an array
            Arr : TAGHEADER3_NFC_UD_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 32, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for TAGHEADER3_NFC_Register use record
      Val at 0 range 0 .. 31;
      Arr at 0 range 0 .. 31;
   end record;

   --  Unspecified
   type FICR_NFC_Cluster is record
      --  Default header for NFC tag. Software can read these values to
      --  populate NFCID1_3RD_LAST, NFCID1_2ND_LAST and NFCID1_LAST.
      TAGHEADER0 : aliased TAGHEADER0_NFC_Register;
      pragma Volatile_Full_Access (TAGHEADER0);
      --  Default header for NFC tag. Software can read these values to
      --  populate NFCID1_3RD_LAST, NFCID1_2ND_LAST and NFCID1_LAST.
      TAGHEADER1 : aliased TAGHEADER1_NFC_Register;
      pragma Volatile_Full_Access (TAGHEADER1);
      --  Default header for NFC tag. Software can read these values to
      --  populate NFCID1_3RD_LAST, NFCID1_2ND_LAST and NFCID1_LAST.
      TAGHEADER2 : aliased TAGHEADER2_NFC_Register;
      pragma Volatile_Full_Access (TAGHEADER2);
      --  Default header for NFC tag. Software can read these values to
      --  populate NFCID1_3RD_LAST, NFCID1_2ND_LAST and NFCID1_LAST.
      TAGHEADER3 : aliased TAGHEADER3_NFC_Register;
      pragma Volatile_Full_Access (TAGHEADER3);
   end record
     with Size => 128;

   for FICR_NFC_Cluster use record
      TAGHEADER0 at 16#0# range 0 .. 31;
      TAGHEADER1 at 16#4# range 0 .. 31;
      TAGHEADER2 at 16#8# range 0 .. 31;
      TAGHEADER3 at 16#C# range 0 .. 31;
   end record;

   --------------------------------------
   -- FICR_TRNG90B cluster's Registers --
   --------------------------------------

   --  NIST800-90B RNG calibration data
   type FICR_TRNG90B_Cluster is record
      --  Amount of bytes for the required entropy bits
      BYTES    : aliased NRF52840.UInt32;
      --  Repetition counter cutoff
      RCCUTOFF : aliased NRF52840.UInt32;
      --  Adaptive proportion cutoff
      APCUTOFF : aliased NRF52840.UInt32;
      --  Amount of bytes for the startup tests
      STARTUP  : aliased NRF52840.UInt32;
      --  Sample count for ring oscillator 1
      ROSC1    : aliased NRF52840.UInt32;
      --  Sample count for ring oscillator 2
      ROSC2    : aliased NRF52840.UInt32;
      --  Sample count for ring oscillator 3
      ROSC3    : aliased NRF52840.UInt32;
      --  Sample count for ring oscillator 4
      ROSC4    : aliased NRF52840.UInt32;
   end record
     with Size => 256;

   for FICR_TRNG90B_Cluster use record
      BYTES    at 16#0# range 0 .. 31;
      RCCUTOFF at 16#4# range 0 .. 31;
      APCUTOFF at 16#8# range 0 .. 31;
      STARTUP  at 16#C# range 0 .. 31;
      ROSC1    at 16#10# range 0 .. 31;
      ROSC2    at 16#14# range 0 .. 31;
      ROSC3    at 16#18# range 0 .. 31;
      ROSC4    at 16#1C# range 0 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  Factory information configuration registers
   type FICR_Peripheral is record
      --  Code memory page size
      CODEPAGESIZE   : aliased NRF52840.UInt32;
      --  Code memory size
      CODESIZE       : aliased NRF52840.UInt32;
      --  Description collection[n]: Device identifier
      DEVICEID_0     : aliased NRF52840.UInt32;
      --  Description collection[n]: Device identifier
      DEVICEID_1     : aliased NRF52840.UInt32;
      --  Description collection[n]: Encryption root, word n
      ER_0           : aliased NRF52840.UInt32;
      --  Description collection[n]: Encryption root, word n
      ER_1           : aliased NRF52840.UInt32;
      --  Description collection[n]: Encryption root, word n
      ER_2           : aliased NRF52840.UInt32;
      --  Description collection[n]: Encryption root, word n
      ER_3           : aliased NRF52840.UInt32;
      --  Description collection[n]: Identity Root, word n
      IR_0           : aliased NRF52840.UInt32;
      --  Description collection[n]: Identity Root, word n
      IR_1           : aliased NRF52840.UInt32;
      --  Description collection[n]: Identity Root, word n
      IR_2           : aliased NRF52840.UInt32;
      --  Description collection[n]: Identity Root, word n
      IR_3           : aliased NRF52840.UInt32;
      --  Device address type
      DEVICEADDRTYPE : aliased DEVICEADDRTYPE_Register;
      pragma Volatile_Full_Access (DEVICEADDRTYPE);
      --  Description collection[n]: Device address n
      DEVICEADDR_0   : aliased NRF52840.UInt32;
      --  Description collection[n]: Device address n
      DEVICEADDR_1   : aliased NRF52840.UInt32;
      --  Device info
      INFO           : aliased FICR_INFO_Cluster;
      --  Description collection[n]: Production test signature n
      PRODTEST_0     : aliased NRF52840.UInt32;
      --  Description collection[n]: Production test signature n
      PRODTEST_1     : aliased NRF52840.UInt32;
      --  Description collection[n]: Production test signature n
      PRODTEST_2     : aliased NRF52840.UInt32;
      --  Registers storing factory TEMP module linearization coefficients
      TEMP           : aliased FICR_TEMP_Cluster;
      --  Unspecified
      NFC            : aliased FICR_NFC_Cluster;
      --  NIST800-90B RNG calibration data
      TRNG90B        : aliased FICR_TRNG90B_Cluster;
   end record
     with Volatile;

   for FICR_Peripheral use record
      CODEPAGESIZE   at 16#10# range 0 .. 31;
      CODESIZE       at 16#14# range 0 .. 31;
      DEVICEID_0     at 16#60# range 0 .. 31;
      DEVICEID_1     at 16#64# range 0 .. 31;
      ER_0           at 16#80# range 0 .. 31;
      ER_1           at 16#84# range 0 .. 31;
      ER_2           at 16#88# range 0 .. 31;
      ER_3           at 16#8C# range 0 .. 31;
      IR_0           at 16#90# range 0 .. 31;
      IR_1           at 16#94# range 0 .. 31;
      IR_2           at 16#98# range 0 .. 31;
      IR_3           at 16#9C# range 0 .. 31;
      DEVICEADDRTYPE at 16#A0# range 0 .. 31;
      DEVICEADDR_0   at 16#A4# range 0 .. 31;
      DEVICEADDR_1   at 16#A8# range 0 .. 31;
      INFO           at 16#100# range 0 .. 255;
      PRODTEST_0     at 16#350# range 0 .. 31;
      PRODTEST_1     at 16#354# range 0 .. 31;
      PRODTEST_2     at 16#358# range 0 .. 31;
      TEMP           at 16#404# range 0 .. 543;
      NFC            at 16#450# range 0 .. 127;
      TRNG90B        at 16#C00# range 0 .. 255;
   end record;

   --  Factory information configuration registers
   FICR_Periph : aliased FICR_Peripheral
     with Import, Address => FICR_Base;

end NRF52840.FICR;
