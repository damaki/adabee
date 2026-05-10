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

package NRF52840.SPIS is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   subtype TASKS_ACQUIRE_TASKS_ACQUIRE_Field is NRF52840.Bit;

   --  Acquire SPI semaphore
   type TASKS_ACQUIRE_Register is record
      --  Write-only.
      TASKS_ACQUIRE : TASKS_ACQUIRE_TASKS_ACQUIRE_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_ACQUIRE_Register use record
      TASKS_ACQUIRE at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_RELEASE_TASKS_RELEASE_Field is NRF52840.Bit;

   --  Release SPI semaphore, enabling the SPI slave to acquire it
   type TASKS_RELEASE_Register is record
      --  Write-only.
      TASKS_RELEASE : TASKS_RELEASE_TASKS_RELEASE_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_RELEASE_Register use record
      TASKS_RELEASE at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_END_EVENTS_END_Field is NRF52840.Bit;

   --  Granted transaction completed
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

   subtype EVENTS_ENDRX_EVENTS_ENDRX_Field is NRF52840.Bit;

   --  End of RXD buffer reached
   type EVENTS_ENDRX_Register is record
      EVENTS_ENDRX  : EVENTS_ENDRX_EVENTS_ENDRX_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_ENDRX_Register use record
      EVENTS_ENDRX  at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_ACQUIRED_EVENTS_ACQUIRED_Field is NRF52840.Bit;

   --  Semaphore acquired
   type EVENTS_ACQUIRED_Register is record
      EVENTS_ACQUIRED : EVENTS_ACQUIRED_EVENTS_ACQUIRED_Field := 16#0#;
      --  unspecified
      Reserved_1_31   : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_ACQUIRED_Register use record
      EVENTS_ACQUIRED at 0 range 0 .. 0;
      Reserved_1_31   at 0 range 1 .. 31;
   end record;

   --  Shortcut between END event and ACQUIRE task
   type SHORTS_END_ACQUIRE_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_END_ACQUIRE_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut register
   type SHORTS_Register is record
      --  unspecified
      Reserved_0_1  : NRF52840.UInt2 := 16#0#;
      --  Shortcut between END event and ACQUIRE task
      END_ACQUIRE   : SHORTS_END_ACQUIRE_Field := NRF52840.SPIS.Disabled;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SHORTS_Register use record
      Reserved_0_1  at 0 range 0 .. 1;
      END_ACQUIRE   at 0 range 2 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
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

   --  Write '1' to enable interrupt for ENDRX event
   type INTENSET_ENDRX_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_ENDRX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for ENDRX event
   type INTENSET_ENDRX_Field_1 is
     (--  Reset value for the field
      INTENSET_ENDRX_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_ENDRX_Field_1 use
     (INTENSET_ENDRX_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for ACQUIRED event
   type INTENSET_ACQUIRED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_ACQUIRED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for ACQUIRED event
   type INTENSET_ACQUIRED_Field_1 is
     (--  Reset value for the field
      INTENSET_ACQUIRED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_ACQUIRED_Field_1 use
     (INTENSET_ACQUIRED_Field_Reset => 0,
      Set => 1);

   --  Enable interrupt
   type INTENSET_Register is record
      --  unspecified
      Reserved_0_0   : NRF52840.Bit := 16#0#;
      --  Write '1' to enable interrupt for END event
      END_k          : INTENSET_END_Field_1 := INTENSET_END_Field_Reset;
      --  unspecified
      Reserved_2_3   : NRF52840.UInt2 := 16#0#;
      --  Write '1' to enable interrupt for ENDRX event
      ENDRX          : INTENSET_ENDRX_Field_1 := INTENSET_ENDRX_Field_Reset;
      --  unspecified
      Reserved_5_9   : NRF52840.UInt5 := 16#0#;
      --  Write '1' to enable interrupt for ACQUIRED event
      ACQUIRED       : INTENSET_ACQUIRED_Field_1 :=
                        INTENSET_ACQUIRED_Field_Reset;
      --  unspecified
      Reserved_11_31 : NRF52840.UInt21 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENSET_Register use record
      Reserved_0_0   at 0 range 0 .. 0;
      END_k          at 0 range 1 .. 1;
      Reserved_2_3   at 0 range 2 .. 3;
      ENDRX          at 0 range 4 .. 4;
      Reserved_5_9   at 0 range 5 .. 9;
      ACQUIRED       at 0 range 10 .. 10;
      Reserved_11_31 at 0 range 11 .. 31;
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

   --  Write '1' to disable interrupt for ENDRX event
   type INTENCLR_ENDRX_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_ENDRX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for ENDRX event
   type INTENCLR_ENDRX_Field_1 is
     (--  Reset value for the field
      INTENCLR_ENDRX_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_ENDRX_Field_1 use
     (INTENCLR_ENDRX_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for ACQUIRED event
   type INTENCLR_ACQUIRED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_ACQUIRED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for ACQUIRED event
   type INTENCLR_ACQUIRED_Field_1 is
     (--  Reset value for the field
      INTENCLR_ACQUIRED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_ACQUIRED_Field_1 use
     (INTENCLR_ACQUIRED_Field_Reset => 0,
      Clear => 1);

   --  Disable interrupt
   type INTENCLR_Register is record
      --  unspecified
      Reserved_0_0   : NRF52840.Bit := 16#0#;
      --  Write '1' to disable interrupt for END event
      END_k          : INTENCLR_END_Field_1 := INTENCLR_END_Field_Reset;
      --  unspecified
      Reserved_2_3   : NRF52840.UInt2 := 16#0#;
      --  Write '1' to disable interrupt for ENDRX event
      ENDRX          : INTENCLR_ENDRX_Field_1 := INTENCLR_ENDRX_Field_Reset;
      --  unspecified
      Reserved_5_9   : NRF52840.UInt5 := 16#0#;
      --  Write '1' to disable interrupt for ACQUIRED event
      ACQUIRED       : INTENCLR_ACQUIRED_Field_1 :=
                        INTENCLR_ACQUIRED_Field_Reset;
      --  unspecified
      Reserved_11_31 : NRF52840.UInt21 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENCLR_Register use record
      Reserved_0_0   at 0 range 0 .. 0;
      END_k          at 0 range 1 .. 1;
      Reserved_2_3   at 0 range 2 .. 3;
      ENDRX          at 0 range 4 .. 4;
      Reserved_5_9   at 0 range 5 .. 9;
      ACQUIRED       at 0 range 10 .. 10;
      Reserved_11_31 at 0 range 11 .. 31;
   end record;

   --  Semaphore status
   type SEMSTAT_SEMSTAT_Field is
     (--  Semaphore is free
      Free,
      --  Semaphore is assigned to CPU
      CPU,
      --  Semaphore is assigned to SPI slave
      SPIS,
      --  Semaphore is assigned to SPI but a handover to the CPU is pending
      CPUPending)
     with Size => 2;
   for SEMSTAT_SEMSTAT_Field use
     (Free => 0,
      CPU => 1,
      SPIS => 2,
      CPUPending => 3);

   --  Semaphore status register
   type SEMSTAT_Register is record
      --  Read-only. Semaphore status
      SEMSTAT       : SEMSTAT_SEMSTAT_Field;
      --  unspecified
      Reserved_2_31 : NRF52840.UInt30;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SEMSTAT_Register use record
      SEMSTAT       at 0 range 0 .. 1;
      Reserved_2_31 at 0 range 2 .. 31;
   end record;

   --  TX buffer over-read detected, and prevented
   type STATUS_OVERREAD_Field is
     (--  Read: error not present
      NotPresent,
      --  Read: error present
      Present)
     with Size => 1;
   for STATUS_OVERREAD_Field use
     (NotPresent => 0,
      Present => 1);

   --  TX buffer over-read detected, and prevented
   type STATUS_OVERREAD_Field_1 is
     (--  Reset value for the field
      STATUS_OVERREAD_Field_Reset,
      --  Write: clear error on writing '1'
      Clear)
     with Size => 1;
   for STATUS_OVERREAD_Field_1 use
     (STATUS_OVERREAD_Field_Reset => 0,
      Clear => 1);

   --  RX buffer overflow detected, and prevented
   type STATUS_OVERFLOW_Field is
     (--  Read: error not present
      NotPresent,
      --  Read: error present
      Present)
     with Size => 1;
   for STATUS_OVERFLOW_Field use
     (NotPresent => 0,
      Present => 1);

   --  RX buffer overflow detected, and prevented
   type STATUS_OVERFLOW_Field_1 is
     (--  Reset value for the field
      STATUS_OVERFLOW_Field_Reset,
      --  Write: clear error on writing '1'
      Clear)
     with Size => 1;
   for STATUS_OVERFLOW_Field_1 use
     (STATUS_OVERFLOW_Field_Reset => 0,
      Clear => 1);

   --  Status from last transaction
   type STATUS_Register is record
      --  TX buffer over-read detected, and prevented
      OVERREAD      : STATUS_OVERREAD_Field_1 := STATUS_OVERREAD_Field_Reset;
      --  RX buffer overflow detected, and prevented
      OVERFLOW      : STATUS_OVERFLOW_Field_1 := STATUS_OVERFLOW_Field_Reset;
      --  unspecified
      Reserved_2_31 : NRF52840.UInt30 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for STATUS_Register use record
      OVERREAD      at 0 range 0 .. 0;
      OVERFLOW      at 0 range 1 .. 1;
      Reserved_2_31 at 0 range 2 .. 31;
   end record;

   --  Enable or disable SPI slave
   type ENABLE_ENABLE_Field is
     (--  Disable SPI slave
      Disabled,
      --  Enable SPI slave
      Enabled)
     with Size => 4;
   for ENABLE_ENABLE_Field use
     (Disabled => 0,
      Enabled => 2);

   --  Enable SPI slave
   type ENABLE_Register is record
      --  Enable or disable SPI slave
      ENABLE        : ENABLE_ENABLE_Field := NRF52840.SPIS.Disabled;
      --  unspecified
      Reserved_4_31 : NRF52840.UInt28 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for ENABLE_Register use record
      ENABLE        at 0 range 0 .. 3;
      Reserved_4_31 at 0 range 4 .. 31;
   end record;

   -----------------------------------
   -- SPIS_PSEL cluster's Registers --
   -----------------------------------

   subtype SCK_PSEL_PIN_Field is NRF52840.UInt5;
   subtype SCK_PSEL_PORT_Field is NRF52840.Bit;

   --  Connection
   type SCK_CONNECT_Field is
     (--  Connect
      Connected,
      --  Disconnect
      Disconnected)
     with Size => 1;
   for SCK_CONNECT_Field use
     (Connected => 0,
      Disconnected => 1);

   --  Pin select for SCK
   type SCK_PSEL_Register is record
      --  Pin number
      PIN           : SCK_PSEL_PIN_Field := 16#1F#;
      --  Port number
      PORT          : SCK_PSEL_PORT_Field := 16#1#;
      --  unspecified
      Reserved_6_30 : NRF52840.UInt25 := 16#1FFFFFF#;
      --  Connection
      CONNECT       : SCK_CONNECT_Field := NRF52840.SPIS.Disconnected;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SCK_PSEL_Register use record
      PIN           at 0 range 0 .. 4;
      PORT          at 0 range 5 .. 5;
      Reserved_6_30 at 0 range 6 .. 30;
      CONNECT       at 0 range 31 .. 31;
   end record;

   subtype MISO_PSEL_PIN_Field is NRF52840.UInt5;
   subtype MISO_PSEL_PORT_Field is NRF52840.Bit;

   --  Connection
   type MISO_CONNECT_Field is
     (--  Connect
      Connected,
      --  Disconnect
      Disconnected)
     with Size => 1;
   for MISO_CONNECT_Field use
     (Connected => 0,
      Disconnected => 1);

   --  Pin select for MISO signal
   type MISO_PSEL_Register is record
      --  Pin number
      PIN           : MISO_PSEL_PIN_Field := 16#1F#;
      --  Port number
      PORT          : MISO_PSEL_PORT_Field := 16#1#;
      --  unspecified
      Reserved_6_30 : NRF52840.UInt25 := 16#1FFFFFF#;
      --  Connection
      CONNECT       : MISO_CONNECT_Field := NRF52840.SPIS.Disconnected;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for MISO_PSEL_Register use record
      PIN           at 0 range 0 .. 4;
      PORT          at 0 range 5 .. 5;
      Reserved_6_30 at 0 range 6 .. 30;
      CONNECT       at 0 range 31 .. 31;
   end record;

   subtype MOSI_PSEL_PIN_Field is NRF52840.UInt5;
   subtype MOSI_PSEL_PORT_Field is NRF52840.Bit;

   --  Connection
   type MOSI_CONNECT_Field is
     (--  Connect
      Connected,
      --  Disconnect
      Disconnected)
     with Size => 1;
   for MOSI_CONNECT_Field use
     (Connected => 0,
      Disconnected => 1);

   --  Pin select for MOSI signal
   type MOSI_PSEL_Register is record
      --  Pin number
      PIN           : MOSI_PSEL_PIN_Field := 16#1F#;
      --  Port number
      PORT          : MOSI_PSEL_PORT_Field := 16#1#;
      --  unspecified
      Reserved_6_30 : NRF52840.UInt25 := 16#1FFFFFF#;
      --  Connection
      CONNECT       : MOSI_CONNECT_Field := NRF52840.SPIS.Disconnected;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for MOSI_PSEL_Register use record
      PIN           at 0 range 0 .. 4;
      PORT          at 0 range 5 .. 5;
      Reserved_6_30 at 0 range 6 .. 30;
      CONNECT       at 0 range 31 .. 31;
   end record;

   subtype CSN_PSEL_PIN_Field is NRF52840.UInt5;
   subtype CSN_PSEL_PORT_Field is NRF52840.Bit;

   --  Connection
   type CSN_CONNECT_Field is
     (--  Connect
      Connected,
      --  Disconnect
      Disconnected)
     with Size => 1;
   for CSN_CONNECT_Field use
     (Connected => 0,
      Disconnected => 1);

   --  Pin select for CSN signal
   type CSN_PSEL_Register is record
      --  Pin number
      PIN           : CSN_PSEL_PIN_Field := 16#1F#;
      --  Port number
      PORT          : CSN_PSEL_PORT_Field := 16#1#;
      --  unspecified
      Reserved_6_30 : NRF52840.UInt25 := 16#1FFFFFF#;
      --  Connection
      CONNECT       : CSN_CONNECT_Field := NRF52840.SPIS.Disconnected;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for CSN_PSEL_Register use record
      PIN           at 0 range 0 .. 4;
      PORT          at 0 range 5 .. 5;
      Reserved_6_30 at 0 range 6 .. 30;
      CONNECT       at 0 range 31 .. 31;
   end record;

   --  Unspecified
   type SPIS_PSEL_Cluster is record
      --  Pin select for SCK
      SCK  : aliased SCK_PSEL_Register;
      pragma Volatile_Full_Access (SCK);
      --  Pin select for MISO signal
      MISO : aliased MISO_PSEL_Register;
      pragma Volatile_Full_Access (MISO);
      --  Pin select for MOSI signal
      MOSI : aliased MOSI_PSEL_Register;
      pragma Volatile_Full_Access (MOSI);
      --  Pin select for CSN signal
      CSN  : aliased CSN_PSEL_Register;
      pragma Volatile_Full_Access (CSN);
   end record
     with Size => 128;

   for SPIS_PSEL_Cluster use record
      SCK  at 16#0# range 0 .. 31;
      MISO at 16#4# range 0 .. 31;
      MOSI at 16#8# range 0 .. 31;
      CSN  at 16#C# range 0 .. 31;
   end record;

   ----------------------------------
   -- SPIS_RXD cluster's Registers --
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

   --  Number of bytes received in last granted transaction
   type AMOUNT_RXD_Register is record
      --  Read-only. Number of bytes received in the last granted transaction
      AMOUNT         : AMOUNT_RXD_AMOUNT_Field;
      --  unspecified
      Reserved_16_31 : NRF52840.UInt16;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for AMOUNT_RXD_Register use record
      AMOUNT         at 0 range 0 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   --  Unspecified
   type SPIS_RXD_Cluster is record
      --  RXD data pointer
      PTR    : aliased NRF52840.UInt32;
      --  Maximum number of bytes in receive buffer
      MAXCNT : aliased MAXCNT_RXD_Register;
      pragma Volatile_Full_Access (MAXCNT);
      --  Number of bytes received in last granted transaction
      AMOUNT : aliased AMOUNT_RXD_Register;
      pragma Volatile_Full_Access (AMOUNT);
   end record
     with Size => 96;

   for SPIS_RXD_Cluster use record
      PTR    at 16#0# range 0 .. 31;
      MAXCNT at 16#4# range 0 .. 31;
      AMOUNT at 16#8# range 0 .. 31;
   end record;

   ----------------------------------
   -- SPIS_TXD cluster's Registers --
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

   --  Number of bytes transmitted in last granted transaction
   type AMOUNT_TXD_Register is record
      --  Read-only. Number of bytes transmitted in last granted transaction
      AMOUNT         : AMOUNT_TXD_AMOUNT_Field;
      --  unspecified
      Reserved_16_31 : NRF52840.UInt16;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for AMOUNT_TXD_Register use record
      AMOUNT         at 0 range 0 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   --  Unspecified
   type SPIS_TXD_Cluster is record
      --  TXD data pointer
      PTR    : aliased NRF52840.UInt32;
      --  Maximum number of bytes in transmit buffer
      MAXCNT : aliased MAXCNT_TXD_Register;
      pragma Volatile_Full_Access (MAXCNT);
      --  Number of bytes transmitted in last granted transaction
      AMOUNT : aliased AMOUNT_TXD_Register;
      pragma Volatile_Full_Access (AMOUNT);
   end record
     with Size => 96;

   for SPIS_TXD_Cluster use record
      PTR    at 16#0# range 0 .. 31;
      MAXCNT at 16#4# range 0 .. 31;
      AMOUNT at 16#8# range 0 .. 31;
   end record;

   --  Bit order
   type CONFIG_ORDER_Field is
     (--  Most significant bit shifted out first
      MsbFirst,
      --  Least significant bit shifted out first
      LsbFirst)
     with Size => 1;
   for CONFIG_ORDER_Field use
     (MsbFirst => 0,
      LsbFirst => 1);

   --  Serial clock (SCK) phase
   type CONFIG_CPHA_Field is
     (--  Sample on leading edge of clock, shift serial data on trailing edge
      Leading,
      --  Sample on trailing edge of clock, shift serial data on leading edge
      Trailing)
     with Size => 1;
   for CONFIG_CPHA_Field use
     (Leading => 0,
      Trailing => 1);

   --  Serial clock (SCK) polarity
   type CONFIG_CPOL_Field is
     (--  Active high
      ActiveHigh,
      --  Active low
      ActiveLow)
     with Size => 1;
   for CONFIG_CPOL_Field use
     (ActiveHigh => 0,
      ActiveLow => 1);

   --  Configuration register
   type CONFIG_Register is record
      --  Bit order
      ORDER         : CONFIG_ORDER_Field := NRF52840.SPIS.MsbFirst;
      --  Serial clock (SCK) phase
      CPHA          : CONFIG_CPHA_Field := NRF52840.SPIS.Leading;
      --  Serial clock (SCK) polarity
      CPOL          : CONFIG_CPOL_Field := NRF52840.SPIS.ActiveHigh;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for CONFIG_Register use record
      ORDER         at 0 range 0 .. 0;
      CPHA          at 0 range 1 .. 1;
      CPOL          at 0 range 2 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   subtype DEF_DEF_Field is NRF52840.Byte;

   --  Default character. Character clocked out in case of an ignored
   --  transaction.
   type DEF_Register is record
      --  Default character. Character clocked out in case of an ignored
      --  transaction.
      DEF           : DEF_DEF_Field := 16#0#;
      --  unspecified
      Reserved_8_31 : NRF52840.UInt24 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for DEF_Register use record
      DEF           at 0 range 0 .. 7;
      Reserved_8_31 at 0 range 8 .. 31;
   end record;

   subtype ORC_ORC_Field is NRF52840.Byte;

   --  Over-read character
   type ORC_Register is record
      --  Over-read character. Character clocked out after an over-read of the
      --  transmit buffer.
      ORC           : ORC_ORC_Field := 16#0#;
      --  unspecified
      Reserved_8_31 : NRF52840.UInt24 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for ORC_Register use record
      ORC           at 0 range 0 .. 7;
      Reserved_8_31 at 0 range 8 .. 31;
   end record;

   -----------------------------------
   -- SPIS_PSEL cluster's Registers --
   -----------------------------------

   ----------------------------------
   -- SPIS_RXD cluster's Registers --
   ----------------------------------

   ----------------------------------
   -- SPIS_TXD cluster's Registers --
   ----------------------------------

   -----------------------------------
   -- SPIS_PSEL cluster's Registers --
   -----------------------------------

   ----------------------------------
   -- SPIS_RXD cluster's Registers --
   ----------------------------------

   ----------------------------------
   -- SPIS_TXD cluster's Registers --
   ----------------------------------

   -----------------
   -- Peripherals --
   -----------------

   --  SPI Slave 0
   type SPIS_Peripheral is record
      --  Acquire SPI semaphore
      TASKS_ACQUIRE   : aliased TASKS_ACQUIRE_Register;
      pragma Volatile_Full_Access (TASKS_ACQUIRE);
      --  Release SPI semaphore, enabling the SPI slave to acquire it
      TASKS_RELEASE   : aliased TASKS_RELEASE_Register;
      pragma Volatile_Full_Access (TASKS_RELEASE);
      --  Granted transaction completed
      EVENTS_END      : aliased EVENTS_END_Register;
      pragma Volatile_Full_Access (EVENTS_END);
      --  End of RXD buffer reached
      EVENTS_ENDRX    : aliased EVENTS_ENDRX_Register;
      pragma Volatile_Full_Access (EVENTS_ENDRX);
      --  Semaphore acquired
      EVENTS_ACQUIRED : aliased EVENTS_ACQUIRED_Register;
      pragma Volatile_Full_Access (EVENTS_ACQUIRED);
      --  Shortcut register
      SHORTS          : aliased SHORTS_Register;
      pragma Volatile_Full_Access (SHORTS);
      --  Enable interrupt
      INTENSET        : aliased INTENSET_Register;
      pragma Volatile_Full_Access (INTENSET);
      --  Disable interrupt
      INTENCLR        : aliased INTENCLR_Register;
      pragma Volatile_Full_Access (INTENCLR);
      --  Semaphore status register
      SEMSTAT         : aliased SEMSTAT_Register;
      pragma Volatile_Full_Access (SEMSTAT);
      --  Status from last transaction
      STATUS          : aliased STATUS_Register;
      pragma Volatile_Full_Access (STATUS);
      --  Enable SPI slave
      ENABLE          : aliased ENABLE_Register;
      pragma Volatile_Full_Access (ENABLE);
      --  Unspecified
      PSEL            : aliased SPIS_PSEL_Cluster;
      --  Unspecified
      RXD             : aliased SPIS_RXD_Cluster;
      --  Unspecified
      TXD             : aliased SPIS_TXD_Cluster;
      --  Configuration register
      CONFIG          : aliased CONFIG_Register;
      pragma Volatile_Full_Access (CONFIG);
      --  Default character. Character clocked out in case of an ignored
      --  transaction.
      DEF             : aliased DEF_Register;
      pragma Volatile_Full_Access (DEF);
      --  Over-read character
      ORC             : aliased ORC_Register;
      pragma Volatile_Full_Access (ORC);
   end record
     with Volatile;

   for SPIS_Peripheral use record
      TASKS_ACQUIRE   at 16#24# range 0 .. 31;
      TASKS_RELEASE   at 16#28# range 0 .. 31;
      EVENTS_END      at 16#104# range 0 .. 31;
      EVENTS_ENDRX    at 16#110# range 0 .. 31;
      EVENTS_ACQUIRED at 16#128# range 0 .. 31;
      SHORTS          at 16#200# range 0 .. 31;
      INTENSET        at 16#304# range 0 .. 31;
      INTENCLR        at 16#308# range 0 .. 31;
      SEMSTAT         at 16#400# range 0 .. 31;
      STATUS          at 16#440# range 0 .. 31;
      ENABLE          at 16#500# range 0 .. 31;
      PSEL            at 16#508# range 0 .. 127;
      RXD             at 16#534# range 0 .. 95;
      TXD             at 16#544# range 0 .. 95;
      CONFIG          at 16#554# range 0 .. 31;
      DEF             at 16#55C# range 0 .. 31;
      ORC             at 16#5C0# range 0 .. 31;
   end record;

   --  SPI Slave 0
   SPIS0_Periph : aliased SPIS_Peripheral
     with Import, Address => SPIS0_Base;

   --  SPI Slave 1
   SPIS1_Periph : aliased SPIS_Peripheral
     with Import, Address => SPIS1_Base;

   --  SPI Slave 2
   SPIS2_Periph : aliased SPIS_Peripheral
     with Import, Address => SPIS2_Base;

end NRF52840.SPIS;
