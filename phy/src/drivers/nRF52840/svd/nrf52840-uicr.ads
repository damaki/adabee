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

package NRF52840.UICR is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   --  Description collection[n]: Reserved for Nordic firmware design
   --  Description collection[n]: Reserved for Nordic hardware design
   --  Description collection[n]: Reserved for customer
   subtype PSELRESET_PIN_Field is NRF52840.UInt5;
   subtype PSELRESET_PORT_Field is NRF52840.Bit;

   --  Connection
   type PSELRESET_CONNECT_Field is
     (--  Connect
      Connected,
      --  Disconnect
      Disconnected)
     with Size => 1;
   for PSELRESET_CONNECT_Field use
     (Connected => 0,
      Disconnected => 1);

   --  Description collection[n]: Mapping of the nRESET function
   type PSELRESET_Register is record
      --  Pin number of PORT onto which nRESET is exposed
      PIN           : PSELRESET_PIN_Field := 16#1F#;
      --  Port number onto which nRESET is exposed
      PORT          : PSELRESET_PORT_Field := 16#1#;
      --  unspecified
      Reserved_6_30 : NRF52840.UInt25 := 16#1FFFFFF#;
      --  Connection
      CONNECT       : PSELRESET_CONNECT_Field := NRF52840.UICR.Disconnected;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for PSELRESET_Register use record
      PIN           at 0 range 0 .. 4;
      PORT          at 0 range 5 .. 5;
      Reserved_6_30 at 0 range 6 .. 30;
      CONNECT       at 0 range 31 .. 31;
   end record;

   --  Enable or disable access port protection.
   type APPROTECT_PALL_Field is
     (--  Enable
      Enabled,
      --  Disable
      Disabled)
     with Size => 8;
   for APPROTECT_PALL_Field use
     (Enabled => 0,
      Disabled => 255);

   --  Access port protection
   type APPROTECT_Register is record
      --  Enable or disable access port protection.
      PALL          : APPROTECT_PALL_Field := NRF52840.UICR.Disabled;
      --  unspecified
      Reserved_8_31 : NRF52840.UInt24 := 16#FFFFFF#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for APPROTECT_Register use record
      PALL          at 0 range 0 .. 7;
      Reserved_8_31 at 0 range 8 .. 31;
   end record;

   --  Setting of pins dedicated to NFC functionality
   type NFCPINS_PROTECT_Field is
     (--  Operation as GPIO pins. Same protection as normal GPIO pins
      Disabled,
      --  Operation as NFC antenna pins. Configures the protection for NFC operation
      NFC)
     with Size => 1;
   for NFCPINS_PROTECT_Field use
     (Disabled => 0,
      NFC => 1);

   --  Setting of pins dedicated to NFC functionality: NFC antenna or GPIO
   type NFCPINS_Register is record
      --  Setting of pins dedicated to NFC functionality
      PROTECT       : NFCPINS_PROTECT_Field := NRF52840.UICR.NFC;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#7FFFFFFF#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for NFCPINS_Register use record
      PROTECT       at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   --  Configure CPU non-intrusive debug features
   type DEBUGCTRL_CPUNIDEN_Field is
     (--  Disable CPU ITM and ETM functionality
      Disabled,
      --  Enable CPU ITM and ETM functionality (default behavior)
      Enabled)
     with Size => 8;
   for DEBUGCTRL_CPUNIDEN_Field use
     (Disabled => 0,
      Enabled => 255);

   --  Configure CPU flash patch and breakpoint (FPB) unit behavior
   type DEBUGCTRL_CPUFPBEN_Field is
     (--  Disable CPU FPB unit. Writes into the FPB registers will be ignored.
      Disabled,
      --  Enable CPU FPB unit (default behavior)
      Enabled)
     with Size => 8;
   for DEBUGCTRL_CPUFPBEN_Field use
     (Disabled => 0,
      Enabled => 255);

   --  Processor debug control
   type DEBUGCTRL_Register is record
      --  Configure CPU non-intrusive debug features
      CPUNIDEN       : DEBUGCTRL_CPUNIDEN_Field := NRF52840.UICR.Enabled;
      --  Configure CPU flash patch and breakpoint (FPB) unit behavior
      CPUFPBEN       : DEBUGCTRL_CPUFPBEN_Field := NRF52840.UICR.Enabled;
      --  unspecified
      Reserved_16_31 : NRF52840.UInt16 := 16#FFFF#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for DEBUGCTRL_Register use record
      CPUNIDEN       at 0 range 0 .. 7;
      CPUFPBEN       at 0 range 8 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   --  Output voltage from of REG0 regulator stage. The maximum output voltage
   --  from this stage is given as VDDH - VEXDIF.
   type REGOUT0_VOUT_Field is
     (--  1.8 V
      Val_1V8,
      --  2.1 V
      Val_2V1,
      --  2.4 V
      Val_2V4,
      --  2.7 V
      Val_2V7,
      --  3.0 V
      Val_3V0,
      --  3.3 V
      Val_3V3,
      --  Default voltage: 1.8 V
      DEFAULT)
     with Size => 3;
   for REGOUT0_VOUT_Field use
     (Val_1V8 => 0,
      Val_2V1 => 1,
      Val_2V4 => 2,
      Val_2V7 => 3,
      Val_3V0 => 4,
      Val_3V3 => 5,
      DEFAULT => 7);

   --  GPIO reference voltage / external output supply voltage in high voltage
   --  mode
   type REGOUT0_Register is record
      --  Output voltage from of REG0 regulator stage. The maximum output
      --  voltage from this stage is given as VDDH - VEXDIF.
      VOUT          : REGOUT0_VOUT_Field := NRF52840.UICR.DEFAULT;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#1FFFFFFF#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for REGOUT0_Register use record
      VOUT          at 0 range 0 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  User information configuration registers
   type UICR_Peripheral is record
      --  Unspecified
      UNUSED0     : aliased NRF52840.UInt32;
      --  Unspecified
      UNUSED1     : aliased NRF52840.UInt32;
      --  Unspecified
      UNUSED2     : aliased NRF52840.UInt32;
      --  Unspecified
      UNUSED3     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_0     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_1     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_2     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_3     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_4     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_5     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_6     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_7     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_8     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_9     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_10    : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_11    : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_12    : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_13    : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic firmware design
      NRFFW_14    : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_0     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_1     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_2     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_3     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_4     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_5     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_6     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_7     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_8     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_9     : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_10    : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for Nordic hardware design
      NRFHW_11    : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_0  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_1  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_2  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_3  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_4  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_5  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_6  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_7  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_8  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_9  : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_10 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_11 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_12 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_13 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_14 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_15 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_16 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_17 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_18 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_19 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_20 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_21 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_22 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_23 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_24 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_25 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_26 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_27 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_28 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_29 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_30 : aliased NRF52840.UInt32;
      --  Description collection[n]: Reserved for customer
      CUSTOMER_31 : aliased NRF52840.UInt32;
      --  Description collection[n]: Mapping of the nRESET function
      PSELRESET_0 : aliased PSELRESET_Register;
      pragma Volatile_Full_Access (PSELRESET_0);
      --  Description collection[n]: Mapping of the nRESET function
      PSELRESET_1 : aliased PSELRESET_Register;
      pragma Volatile_Full_Access (PSELRESET_1);
      --  Access port protection
      APPROTECT   : aliased APPROTECT_Register;
      pragma Volatile_Full_Access (APPROTECT);
      --  Setting of pins dedicated to NFC functionality: NFC antenna or GPIO
      NFCPINS     : aliased NFCPINS_Register;
      pragma Volatile_Full_Access (NFCPINS);
      --  Processor debug control
      DEBUGCTRL   : aliased DEBUGCTRL_Register;
      pragma Volatile_Full_Access (DEBUGCTRL);
      --  GPIO reference voltage / external output supply voltage in high
      --  voltage mode
      REGOUT0     : aliased REGOUT0_Register;
      pragma Volatile_Full_Access (REGOUT0);
   end record
     with Volatile;

   for UICR_Peripheral use record
      UNUSED0     at 16#0# range 0 .. 31;
      UNUSED1     at 16#4# range 0 .. 31;
      UNUSED2     at 16#8# range 0 .. 31;
      UNUSED3     at 16#10# range 0 .. 31;
      NRFFW_0     at 16#14# range 0 .. 31;
      NRFFW_1     at 16#18# range 0 .. 31;
      NRFFW_2     at 16#1C# range 0 .. 31;
      NRFFW_3     at 16#20# range 0 .. 31;
      NRFFW_4     at 16#24# range 0 .. 31;
      NRFFW_5     at 16#28# range 0 .. 31;
      NRFFW_6     at 16#2C# range 0 .. 31;
      NRFFW_7     at 16#30# range 0 .. 31;
      NRFFW_8     at 16#34# range 0 .. 31;
      NRFFW_9     at 16#38# range 0 .. 31;
      NRFFW_10    at 16#3C# range 0 .. 31;
      NRFFW_11    at 16#40# range 0 .. 31;
      NRFFW_12    at 16#44# range 0 .. 31;
      NRFFW_13    at 16#48# range 0 .. 31;
      NRFFW_14    at 16#4C# range 0 .. 31;
      NRFHW_0     at 16#50# range 0 .. 31;
      NRFHW_1     at 16#54# range 0 .. 31;
      NRFHW_2     at 16#58# range 0 .. 31;
      NRFHW_3     at 16#5C# range 0 .. 31;
      NRFHW_4     at 16#60# range 0 .. 31;
      NRFHW_5     at 16#64# range 0 .. 31;
      NRFHW_6     at 16#68# range 0 .. 31;
      NRFHW_7     at 16#6C# range 0 .. 31;
      NRFHW_8     at 16#70# range 0 .. 31;
      NRFHW_9     at 16#74# range 0 .. 31;
      NRFHW_10    at 16#78# range 0 .. 31;
      NRFHW_11    at 16#7C# range 0 .. 31;
      CUSTOMER_0  at 16#80# range 0 .. 31;
      CUSTOMER_1  at 16#84# range 0 .. 31;
      CUSTOMER_2  at 16#88# range 0 .. 31;
      CUSTOMER_3  at 16#8C# range 0 .. 31;
      CUSTOMER_4  at 16#90# range 0 .. 31;
      CUSTOMER_5  at 16#94# range 0 .. 31;
      CUSTOMER_6  at 16#98# range 0 .. 31;
      CUSTOMER_7  at 16#9C# range 0 .. 31;
      CUSTOMER_8  at 16#A0# range 0 .. 31;
      CUSTOMER_9  at 16#A4# range 0 .. 31;
      CUSTOMER_10 at 16#A8# range 0 .. 31;
      CUSTOMER_11 at 16#AC# range 0 .. 31;
      CUSTOMER_12 at 16#B0# range 0 .. 31;
      CUSTOMER_13 at 16#B4# range 0 .. 31;
      CUSTOMER_14 at 16#B8# range 0 .. 31;
      CUSTOMER_15 at 16#BC# range 0 .. 31;
      CUSTOMER_16 at 16#C0# range 0 .. 31;
      CUSTOMER_17 at 16#C4# range 0 .. 31;
      CUSTOMER_18 at 16#C8# range 0 .. 31;
      CUSTOMER_19 at 16#CC# range 0 .. 31;
      CUSTOMER_20 at 16#D0# range 0 .. 31;
      CUSTOMER_21 at 16#D4# range 0 .. 31;
      CUSTOMER_22 at 16#D8# range 0 .. 31;
      CUSTOMER_23 at 16#DC# range 0 .. 31;
      CUSTOMER_24 at 16#E0# range 0 .. 31;
      CUSTOMER_25 at 16#E4# range 0 .. 31;
      CUSTOMER_26 at 16#E8# range 0 .. 31;
      CUSTOMER_27 at 16#EC# range 0 .. 31;
      CUSTOMER_28 at 16#F0# range 0 .. 31;
      CUSTOMER_29 at 16#F4# range 0 .. 31;
      CUSTOMER_30 at 16#F8# range 0 .. 31;
      CUSTOMER_31 at 16#FC# range 0 .. 31;
      PSELRESET_0 at 16#200# range 0 .. 31;
      PSELRESET_1 at 16#204# range 0 .. 31;
      APPROTECT   at 16#208# range 0 .. 31;
      NFCPINS     at 16#20C# range 0 .. 31;
      DEBUGCTRL   at 16#210# range 0 .. 31;
      REGOUT0     at 16#304# range 0 .. 31;
   end record;

   --  User information configuration registers
   UICR_Periph : aliased UICR_Peripheral
     with Import, Address => UICR_Base;

end NRF52840.UICR;
