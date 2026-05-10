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

package NRF52840.NFCT is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   subtype TASKS_ACTIVATE_TASKS_ACTIVATE_Field is NRF52840.Bit;

   --  Activate NFCT peripheral for incoming and outgoing frames, change state
   --  to activated
   type TASKS_ACTIVATE_Register is record
      --  Write-only.
      TASKS_ACTIVATE : TASKS_ACTIVATE_TASKS_ACTIVATE_Field := 16#0#;
      --  unspecified
      Reserved_1_31  : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_ACTIVATE_Register use record
      TASKS_ACTIVATE at 0 range 0 .. 0;
      Reserved_1_31  at 0 range 1 .. 31;
   end record;

   subtype TASKS_DISABLE_TASKS_DISABLE_Field is NRF52840.Bit;

   --  Disable NFCT peripheral
   type TASKS_DISABLE_Register is record
      --  Write-only.
      TASKS_DISABLE : TASKS_DISABLE_TASKS_DISABLE_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_DISABLE_Register use record
      TASKS_DISABLE at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_SENSE_TASKS_SENSE_Field is NRF52840.Bit;

   --  Enable NFC sense field mode, change state to sense mode
   type TASKS_SENSE_Register is record
      --  Write-only.
      TASKS_SENSE   : TASKS_SENSE_TASKS_SENSE_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_SENSE_Register use record
      TASKS_SENSE   at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_STARTTX_TASKS_STARTTX_Field is NRF52840.Bit;

   --  Start transmission of an outgoing frame, change state to transmit
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

   subtype TASKS_ENABLERXDATA_TASKS_ENABLERXDATA_Field is NRF52840.Bit;

   --  Initializes the EasyDMA for receive.
   type TASKS_ENABLERXDATA_Register is record
      --  Write-only.
      TASKS_ENABLERXDATA : TASKS_ENABLERXDATA_TASKS_ENABLERXDATA_Field :=
                            16#0#;
      --  unspecified
      Reserved_1_31      : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_ENABLERXDATA_Register use record
      TASKS_ENABLERXDATA at 0 range 0 .. 0;
      Reserved_1_31      at 0 range 1 .. 31;
   end record;

   subtype TASKS_GOIDLE_TASKS_GOIDLE_Field is NRF52840.Bit;

   --  Force state machine to IDLE state
   type TASKS_GOIDLE_Register is record
      --  Write-only.
      TASKS_GOIDLE  : TASKS_GOIDLE_TASKS_GOIDLE_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_GOIDLE_Register use record
      TASKS_GOIDLE  at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype TASKS_GOSLEEP_TASKS_GOSLEEP_Field is NRF52840.Bit;

   --  Force state machine to SLEEP_A state
   type TASKS_GOSLEEP_Register is record
      --  Write-only.
      TASKS_GOSLEEP : TASKS_GOSLEEP_TASKS_GOSLEEP_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for TASKS_GOSLEEP_Register use record
      TASKS_GOSLEEP at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_READY_EVENTS_READY_Field is NRF52840.Bit;

   --  The NFCT peripheral is ready to receive and send frames
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

   subtype EVENTS_FIELDDETECTED_EVENTS_FIELDDETECTED_Field is NRF52840.Bit;

   --  Remote NFC field detected
   type EVENTS_FIELDDETECTED_Register is record
      EVENTS_FIELDDETECTED : EVENTS_FIELDDETECTED_EVENTS_FIELDDETECTED_Field :=
                              16#0#;
      --  unspecified
      Reserved_1_31        : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_FIELDDETECTED_Register use record
      EVENTS_FIELDDETECTED at 0 range 0 .. 0;
      Reserved_1_31        at 0 range 1 .. 31;
   end record;

   subtype EVENTS_FIELDLOST_EVENTS_FIELDLOST_Field is NRF52840.Bit;

   --  Remote NFC field lost
   type EVENTS_FIELDLOST_Register is record
      EVENTS_FIELDLOST : EVENTS_FIELDLOST_EVENTS_FIELDLOST_Field := 16#0#;
      --  unspecified
      Reserved_1_31    : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_FIELDLOST_Register use record
      EVENTS_FIELDLOST at 0 range 0 .. 0;
      Reserved_1_31    at 0 range 1 .. 31;
   end record;

   subtype EVENTS_TXFRAMESTART_EVENTS_TXFRAMESTART_Field is NRF52840.Bit;

   --  Marks the start of the first symbol of a transmitted frame
   type EVENTS_TXFRAMESTART_Register is record
      EVENTS_TXFRAMESTART : EVENTS_TXFRAMESTART_EVENTS_TXFRAMESTART_Field :=
                             16#0#;
      --  unspecified
      Reserved_1_31       : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_TXFRAMESTART_Register use record
      EVENTS_TXFRAMESTART at 0 range 0 .. 0;
      Reserved_1_31       at 0 range 1 .. 31;
   end record;

   subtype EVENTS_TXFRAMEEND_EVENTS_TXFRAMEEND_Field is NRF52840.Bit;

   --  Marks the end of the last transmitted on-air symbol of a frame
   type EVENTS_TXFRAMEEND_Register is record
      EVENTS_TXFRAMEEND : EVENTS_TXFRAMEEND_EVENTS_TXFRAMEEND_Field := 16#0#;
      --  unspecified
      Reserved_1_31     : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_TXFRAMEEND_Register use record
      EVENTS_TXFRAMEEND at 0 range 0 .. 0;
      Reserved_1_31     at 0 range 1 .. 31;
   end record;

   subtype EVENTS_RXFRAMESTART_EVENTS_RXFRAMESTART_Field is NRF52840.Bit;

   --  Marks the end of the first symbol of a received frame
   type EVENTS_RXFRAMESTART_Register is record
      EVENTS_RXFRAMESTART : EVENTS_RXFRAMESTART_EVENTS_RXFRAMESTART_Field :=
                             16#0#;
      --  unspecified
      Reserved_1_31       : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_RXFRAMESTART_Register use record
      EVENTS_RXFRAMESTART at 0 range 0 .. 0;
      Reserved_1_31       at 0 range 1 .. 31;
   end record;

   subtype EVENTS_RXFRAMEEND_EVENTS_RXFRAMEEND_Field is NRF52840.Bit;

   --  Received data has been checked (CRC, parity) and transferred to RAM, and
   --  EasyDMA has ended accessing the RX buffer
   type EVENTS_RXFRAMEEND_Register is record
      EVENTS_RXFRAMEEND : EVENTS_RXFRAMEEND_EVENTS_RXFRAMEEND_Field := 16#0#;
      --  unspecified
      Reserved_1_31     : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_RXFRAMEEND_Register use record
      EVENTS_RXFRAMEEND at 0 range 0 .. 0;
      Reserved_1_31     at 0 range 1 .. 31;
   end record;

   subtype EVENTS_ERROR_EVENTS_ERROR_Field is NRF52840.Bit;

   --  NFC error reported. The ERRORSTATUS register contains details on the
   --  source of the error.
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

   subtype EVENTS_RXERROR_EVENTS_RXERROR_Field is NRF52840.Bit;

   --  NFC RX frame error reported. The FRAMESTATUS.RX register contains
   --  details on the source of the error.
   type EVENTS_RXERROR_Register is record
      EVENTS_RXERROR : EVENTS_RXERROR_EVENTS_RXERROR_Field := 16#0#;
      --  unspecified
      Reserved_1_31  : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_RXERROR_Register use record
      EVENTS_RXERROR at 0 range 0 .. 0;
      Reserved_1_31  at 0 range 1 .. 31;
   end record;

   subtype EVENTS_ENDRX_EVENTS_ENDRX_Field is NRF52840.Bit;

   --  RX buffer (as defined by PACKETPTR and MAXLEN) in Data RAM full.
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

   subtype EVENTS_ENDTX_EVENTS_ENDTX_Field is NRF52840.Bit;

   --  Transmission of data in RAM has ended, and EasyDMA has ended accessing
   --  the TX buffer
   type EVENTS_ENDTX_Register is record
      EVENTS_ENDTX  : EVENTS_ENDTX_EVENTS_ENDTX_Field := 16#0#;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_ENDTX_Register use record
      EVENTS_ENDTX  at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   subtype EVENTS_AUTOCOLRESSTARTED_EVENTS_AUTOCOLRESSTARTED_Field is
     NRF52840.Bit;

   --  Auto collision resolution process has started
   type EVENTS_AUTOCOLRESSTARTED_Register is record
      EVENTS_AUTOCOLRESSTARTED : EVENTS_AUTOCOLRESSTARTED_EVENTS_AUTOCOLRESSTARTED_Field :=
                                  16#0#;
      --  unspecified
      Reserved_1_31            : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_AUTOCOLRESSTARTED_Register use record
      EVENTS_AUTOCOLRESSTARTED at 0 range 0 .. 0;
      Reserved_1_31            at 0 range 1 .. 31;
   end record;

   subtype EVENTS_COLLISION_EVENTS_COLLISION_Field is NRF52840.Bit;

   --  NFC auto collision resolution error reported.
   type EVENTS_COLLISION_Register is record
      EVENTS_COLLISION : EVENTS_COLLISION_EVENTS_COLLISION_Field := 16#0#;
      --  unspecified
      Reserved_1_31    : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_COLLISION_Register use record
      EVENTS_COLLISION at 0 range 0 .. 0;
      Reserved_1_31    at 0 range 1 .. 31;
   end record;

   subtype EVENTS_SELECTED_EVENTS_SELECTED_Field is NRF52840.Bit;

   --  NFC auto collision resolution successfully completed
   type EVENTS_SELECTED_Register is record
      EVENTS_SELECTED : EVENTS_SELECTED_EVENTS_SELECTED_Field := 16#0#;
      --  unspecified
      Reserved_1_31   : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_SELECTED_Register use record
      EVENTS_SELECTED at 0 range 0 .. 0;
      Reserved_1_31   at 0 range 1 .. 31;
   end record;

   subtype EVENTS_STARTED_EVENTS_STARTED_Field is NRF52840.Bit;

   --  EasyDMA is ready to receive or send frames.
   type EVENTS_STARTED_Register is record
      EVENTS_STARTED : EVENTS_STARTED_EVENTS_STARTED_Field := 16#0#;
      --  unspecified
      Reserved_1_31  : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for EVENTS_STARTED_Register use record
      EVENTS_STARTED at 0 range 0 .. 0;
      Reserved_1_31  at 0 range 1 .. 31;
   end record;

   --  Shortcut between FIELDDETECTED event and ACTIVATE task
   type SHORTS_FIELDDETECTED_ACTIVATE_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_FIELDDETECTED_ACTIVATE_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between FIELDLOST event and SENSE task
   type SHORTS_FIELDLOST_SENSE_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_FIELDLOST_SENSE_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut between TXFRAMEEND event and ENABLERXDATA task
   type SHORTS_TXFRAMEEND_ENABLERXDATA_Field is
     (--  Disable shortcut
      Disabled,
      --  Enable shortcut
      Enabled)
     with Size => 1;
   for SHORTS_TXFRAMEEND_ENABLERXDATA_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Shortcut register
   type SHORTS_Register is record
      --  Shortcut between FIELDDETECTED event and ACTIVATE task
      FIELDDETECTED_ACTIVATE  : SHORTS_FIELDDETECTED_ACTIVATE_Field :=
                                 NRF52840.NFCT.Disabled;
      --  Shortcut between FIELDLOST event and SENSE task
      FIELDLOST_SENSE         : SHORTS_FIELDLOST_SENSE_Field :=
                                 NRF52840.NFCT.Disabled;
      --  unspecified
      Reserved_2_4            : NRF52840.UInt3 := 16#0#;
      --  Shortcut between TXFRAMEEND event and ENABLERXDATA task
      TXFRAMEEND_ENABLERXDATA : SHORTS_TXFRAMEEND_ENABLERXDATA_Field :=
                                 NRF52840.NFCT.Disabled;
      --  unspecified
      Reserved_6_31           : NRF52840.UInt26 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SHORTS_Register use record
      FIELDDETECTED_ACTIVATE  at 0 range 0 .. 0;
      FIELDLOST_SENSE         at 0 range 1 .. 1;
      Reserved_2_4            at 0 range 2 .. 4;
      TXFRAMEEND_ENABLERXDATA at 0 range 5 .. 5;
      Reserved_6_31           at 0 range 6 .. 31;
   end record;

   --  Enable or disable interrupt for READY event
   type INTEN_READY_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_READY_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for FIELDDETECTED event
   type INTEN_FIELDDETECTED_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_FIELDDETECTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for FIELDLOST event
   type INTEN_FIELDLOST_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_FIELDLOST_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for TXFRAMESTART event
   type INTEN_TXFRAMESTART_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_TXFRAMESTART_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for TXFRAMEEND event
   type INTEN_TXFRAMEEND_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_TXFRAMEEND_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for RXFRAMESTART event
   type INTEN_RXFRAMESTART_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_RXFRAMESTART_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for RXFRAMEEND event
   type INTEN_RXFRAMEEND_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_RXFRAMEEND_Field use
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

   --  Enable or disable interrupt for RXERROR event
   type INTEN_RXERROR_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_RXERROR_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for ENDRX event
   type INTEN_ENDRX_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_ENDRX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for ENDTX event
   type INTEN_ENDTX_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_ENDTX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for AUTOCOLRESSTARTED event
   type INTEN_AUTOCOLRESSTARTED_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_AUTOCOLRESSTARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for COLLISION event
   type INTEN_COLLISION_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_COLLISION_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for SELECTED event
   type INTEN_SELECTED_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_SELECTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt for STARTED event
   type INTEN_STARTED_Field is
     (--  Disable
      Disabled,
      --  Enable
      Enabled)
     with Size => 1;
   for INTEN_STARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Enable or disable interrupt
   type INTEN_Register is record
      --  Enable or disable interrupt for READY event
      READY             : INTEN_READY_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for FIELDDETECTED event
      FIELDDETECTED     : INTEN_FIELDDETECTED_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for FIELDLOST event
      FIELDLOST         : INTEN_FIELDLOST_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for TXFRAMESTART event
      TXFRAMESTART      : INTEN_TXFRAMESTART_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for TXFRAMEEND event
      TXFRAMEEND        : INTEN_TXFRAMEEND_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for RXFRAMESTART event
      RXFRAMESTART      : INTEN_RXFRAMESTART_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for RXFRAMEEND event
      RXFRAMEEND        : INTEN_RXFRAMEEND_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for ERROR event
      ERROR             : INTEN_ERROR_Field := NRF52840.NFCT.Disabled;
      --  unspecified
      Reserved_8_9      : NRF52840.UInt2 := 16#0#;
      --  Enable or disable interrupt for RXERROR event
      RXERROR           : INTEN_RXERROR_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for ENDRX event
      ENDRX             : INTEN_ENDRX_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for ENDTX event
      ENDTX             : INTEN_ENDTX_Field := NRF52840.NFCT.Disabled;
      --  unspecified
      Reserved_13_13    : NRF52840.Bit := 16#0#;
      --  Enable or disable interrupt for AUTOCOLRESSTARTED event
      AUTOCOLRESSTARTED : INTEN_AUTOCOLRESSTARTED_Field :=
                           NRF52840.NFCT.Disabled;
      --  unspecified
      Reserved_15_17    : NRF52840.UInt3 := 16#0#;
      --  Enable or disable interrupt for COLLISION event
      COLLISION         : INTEN_COLLISION_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for SELECTED event
      SELECTED          : INTEN_SELECTED_Field := NRF52840.NFCT.Disabled;
      --  Enable or disable interrupt for STARTED event
      STARTED           : INTEN_STARTED_Field := NRF52840.NFCT.Disabled;
      --  unspecified
      Reserved_21_31    : NRF52840.UInt11 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTEN_Register use record
      READY             at 0 range 0 .. 0;
      FIELDDETECTED     at 0 range 1 .. 1;
      FIELDLOST         at 0 range 2 .. 2;
      TXFRAMESTART      at 0 range 3 .. 3;
      TXFRAMEEND        at 0 range 4 .. 4;
      RXFRAMESTART      at 0 range 5 .. 5;
      RXFRAMEEND        at 0 range 6 .. 6;
      ERROR             at 0 range 7 .. 7;
      Reserved_8_9      at 0 range 8 .. 9;
      RXERROR           at 0 range 10 .. 10;
      ENDRX             at 0 range 11 .. 11;
      ENDTX             at 0 range 12 .. 12;
      Reserved_13_13    at 0 range 13 .. 13;
      AUTOCOLRESSTARTED at 0 range 14 .. 14;
      Reserved_15_17    at 0 range 15 .. 17;
      COLLISION         at 0 range 18 .. 18;
      SELECTED          at 0 range 19 .. 19;
      STARTED           at 0 range 20 .. 20;
      Reserved_21_31    at 0 range 21 .. 31;
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

   --  Write '1' to enable interrupt for FIELDDETECTED event
   type INTENSET_FIELDDETECTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_FIELDDETECTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for FIELDDETECTED event
   type INTENSET_FIELDDETECTED_Field_1 is
     (--  Reset value for the field
      INTENSET_FIELDDETECTED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_FIELDDETECTED_Field_1 use
     (INTENSET_FIELDDETECTED_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for FIELDLOST event
   type INTENSET_FIELDLOST_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_FIELDLOST_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for FIELDLOST event
   type INTENSET_FIELDLOST_Field_1 is
     (--  Reset value for the field
      INTENSET_FIELDLOST_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_FIELDLOST_Field_1 use
     (INTENSET_FIELDLOST_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for TXFRAMESTART event
   type INTENSET_TXFRAMESTART_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_TXFRAMESTART_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for TXFRAMESTART event
   type INTENSET_TXFRAMESTART_Field_1 is
     (--  Reset value for the field
      INTENSET_TXFRAMESTART_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_TXFRAMESTART_Field_1 use
     (INTENSET_TXFRAMESTART_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for TXFRAMEEND event
   type INTENSET_TXFRAMEEND_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_TXFRAMEEND_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for TXFRAMEEND event
   type INTENSET_TXFRAMEEND_Field_1 is
     (--  Reset value for the field
      INTENSET_TXFRAMEEND_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_TXFRAMEEND_Field_1 use
     (INTENSET_TXFRAMEEND_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for RXFRAMESTART event
   type INTENSET_RXFRAMESTART_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_RXFRAMESTART_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for RXFRAMESTART event
   type INTENSET_RXFRAMESTART_Field_1 is
     (--  Reset value for the field
      INTENSET_RXFRAMESTART_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_RXFRAMESTART_Field_1 use
     (INTENSET_RXFRAMESTART_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for RXFRAMEEND event
   type INTENSET_RXFRAMEEND_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_RXFRAMEEND_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for RXFRAMEEND event
   type INTENSET_RXFRAMEEND_Field_1 is
     (--  Reset value for the field
      INTENSET_RXFRAMEEND_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_RXFRAMEEND_Field_1 use
     (INTENSET_RXFRAMEEND_Field_Reset => 0,
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

   --  Write '1' to enable interrupt for RXERROR event
   type INTENSET_RXERROR_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_RXERROR_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for RXERROR event
   type INTENSET_RXERROR_Field_1 is
     (--  Reset value for the field
      INTENSET_RXERROR_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_RXERROR_Field_1 use
     (INTENSET_RXERROR_Field_Reset => 0,
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

   --  Write '1' to enable interrupt for ENDTX event
   type INTENSET_ENDTX_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_ENDTX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for ENDTX event
   type INTENSET_ENDTX_Field_1 is
     (--  Reset value for the field
      INTENSET_ENDTX_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_ENDTX_Field_1 use
     (INTENSET_ENDTX_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for AUTOCOLRESSTARTED event
   type INTENSET_AUTOCOLRESSTARTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_AUTOCOLRESSTARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for AUTOCOLRESSTARTED event
   type INTENSET_AUTOCOLRESSTARTED_Field_1 is
     (--  Reset value for the field
      INTENSET_AUTOCOLRESSTARTED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_AUTOCOLRESSTARTED_Field_1 use
     (INTENSET_AUTOCOLRESSTARTED_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for COLLISION event
   type INTENSET_COLLISION_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_COLLISION_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for COLLISION event
   type INTENSET_COLLISION_Field_1 is
     (--  Reset value for the field
      INTENSET_COLLISION_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_COLLISION_Field_1 use
     (INTENSET_COLLISION_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for SELECTED event
   type INTENSET_SELECTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_SELECTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for SELECTED event
   type INTENSET_SELECTED_Field_1 is
     (--  Reset value for the field
      INTENSET_SELECTED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_SELECTED_Field_1 use
     (INTENSET_SELECTED_Field_Reset => 0,
      Set => 1);

   --  Write '1' to enable interrupt for STARTED event
   type INTENSET_STARTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENSET_STARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to enable interrupt for STARTED event
   type INTENSET_STARTED_Field_1 is
     (--  Reset value for the field
      INTENSET_STARTED_Field_Reset,
      --  Enable
      Set)
     with Size => 1;
   for INTENSET_STARTED_Field_1 use
     (INTENSET_STARTED_Field_Reset => 0,
      Set => 1);

   --  Enable interrupt
   type INTENSET_Register is record
      --  Write '1' to enable interrupt for READY event
      READY             : INTENSET_READY_Field_1 :=
                           INTENSET_READY_Field_Reset;
      --  Write '1' to enable interrupt for FIELDDETECTED event
      FIELDDETECTED     : INTENSET_FIELDDETECTED_Field_1 :=
                           INTENSET_FIELDDETECTED_Field_Reset;
      --  Write '1' to enable interrupt for FIELDLOST event
      FIELDLOST         : INTENSET_FIELDLOST_Field_1 :=
                           INTENSET_FIELDLOST_Field_Reset;
      --  Write '1' to enable interrupt for TXFRAMESTART event
      TXFRAMESTART      : INTENSET_TXFRAMESTART_Field_1 :=
                           INTENSET_TXFRAMESTART_Field_Reset;
      --  Write '1' to enable interrupt for TXFRAMEEND event
      TXFRAMEEND        : INTENSET_TXFRAMEEND_Field_1 :=
                           INTENSET_TXFRAMEEND_Field_Reset;
      --  Write '1' to enable interrupt for RXFRAMESTART event
      RXFRAMESTART      : INTENSET_RXFRAMESTART_Field_1 :=
                           INTENSET_RXFRAMESTART_Field_Reset;
      --  Write '1' to enable interrupt for RXFRAMEEND event
      RXFRAMEEND        : INTENSET_RXFRAMEEND_Field_1 :=
                           INTENSET_RXFRAMEEND_Field_Reset;
      --  Write '1' to enable interrupt for ERROR event
      ERROR             : INTENSET_ERROR_Field_1 :=
                           INTENSET_ERROR_Field_Reset;
      --  unspecified
      Reserved_8_9      : NRF52840.UInt2 := 16#0#;
      --  Write '1' to enable interrupt for RXERROR event
      RXERROR           : INTENSET_RXERROR_Field_1 :=
                           INTENSET_RXERROR_Field_Reset;
      --  Write '1' to enable interrupt for ENDRX event
      ENDRX             : INTENSET_ENDRX_Field_1 :=
                           INTENSET_ENDRX_Field_Reset;
      --  Write '1' to enable interrupt for ENDTX event
      ENDTX             : INTENSET_ENDTX_Field_1 :=
                           INTENSET_ENDTX_Field_Reset;
      --  unspecified
      Reserved_13_13    : NRF52840.Bit := 16#0#;
      --  Write '1' to enable interrupt for AUTOCOLRESSTARTED event
      AUTOCOLRESSTARTED : INTENSET_AUTOCOLRESSTARTED_Field_1 :=
                           INTENSET_AUTOCOLRESSTARTED_Field_Reset;
      --  unspecified
      Reserved_15_17    : NRF52840.UInt3 := 16#0#;
      --  Write '1' to enable interrupt for COLLISION event
      COLLISION         : INTENSET_COLLISION_Field_1 :=
                           INTENSET_COLLISION_Field_Reset;
      --  Write '1' to enable interrupt for SELECTED event
      SELECTED          : INTENSET_SELECTED_Field_1 :=
                           INTENSET_SELECTED_Field_Reset;
      --  Write '1' to enable interrupt for STARTED event
      STARTED           : INTENSET_STARTED_Field_1 :=
                           INTENSET_STARTED_Field_Reset;
      --  unspecified
      Reserved_21_31    : NRF52840.UInt11 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENSET_Register use record
      READY             at 0 range 0 .. 0;
      FIELDDETECTED     at 0 range 1 .. 1;
      FIELDLOST         at 0 range 2 .. 2;
      TXFRAMESTART      at 0 range 3 .. 3;
      TXFRAMEEND        at 0 range 4 .. 4;
      RXFRAMESTART      at 0 range 5 .. 5;
      RXFRAMEEND        at 0 range 6 .. 6;
      ERROR             at 0 range 7 .. 7;
      Reserved_8_9      at 0 range 8 .. 9;
      RXERROR           at 0 range 10 .. 10;
      ENDRX             at 0 range 11 .. 11;
      ENDTX             at 0 range 12 .. 12;
      Reserved_13_13    at 0 range 13 .. 13;
      AUTOCOLRESSTARTED at 0 range 14 .. 14;
      Reserved_15_17    at 0 range 15 .. 17;
      COLLISION         at 0 range 18 .. 18;
      SELECTED          at 0 range 19 .. 19;
      STARTED           at 0 range 20 .. 20;
      Reserved_21_31    at 0 range 21 .. 31;
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

   --  Write '1' to disable interrupt for FIELDDETECTED event
   type INTENCLR_FIELDDETECTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_FIELDDETECTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for FIELDDETECTED event
   type INTENCLR_FIELDDETECTED_Field_1 is
     (--  Reset value for the field
      INTENCLR_FIELDDETECTED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_FIELDDETECTED_Field_1 use
     (INTENCLR_FIELDDETECTED_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for FIELDLOST event
   type INTENCLR_FIELDLOST_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_FIELDLOST_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for FIELDLOST event
   type INTENCLR_FIELDLOST_Field_1 is
     (--  Reset value for the field
      INTENCLR_FIELDLOST_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_FIELDLOST_Field_1 use
     (INTENCLR_FIELDLOST_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for TXFRAMESTART event
   type INTENCLR_TXFRAMESTART_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_TXFRAMESTART_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for TXFRAMESTART event
   type INTENCLR_TXFRAMESTART_Field_1 is
     (--  Reset value for the field
      INTENCLR_TXFRAMESTART_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_TXFRAMESTART_Field_1 use
     (INTENCLR_TXFRAMESTART_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for TXFRAMEEND event
   type INTENCLR_TXFRAMEEND_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_TXFRAMEEND_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for TXFRAMEEND event
   type INTENCLR_TXFRAMEEND_Field_1 is
     (--  Reset value for the field
      INTENCLR_TXFRAMEEND_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_TXFRAMEEND_Field_1 use
     (INTENCLR_TXFRAMEEND_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for RXFRAMESTART event
   type INTENCLR_RXFRAMESTART_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_RXFRAMESTART_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for RXFRAMESTART event
   type INTENCLR_RXFRAMESTART_Field_1 is
     (--  Reset value for the field
      INTENCLR_RXFRAMESTART_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_RXFRAMESTART_Field_1 use
     (INTENCLR_RXFRAMESTART_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for RXFRAMEEND event
   type INTENCLR_RXFRAMEEND_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_RXFRAMEEND_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for RXFRAMEEND event
   type INTENCLR_RXFRAMEEND_Field_1 is
     (--  Reset value for the field
      INTENCLR_RXFRAMEEND_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_RXFRAMEEND_Field_1 use
     (INTENCLR_RXFRAMEEND_Field_Reset => 0,
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

   --  Write '1' to disable interrupt for RXERROR event
   type INTENCLR_RXERROR_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_RXERROR_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for RXERROR event
   type INTENCLR_RXERROR_Field_1 is
     (--  Reset value for the field
      INTENCLR_RXERROR_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_RXERROR_Field_1 use
     (INTENCLR_RXERROR_Field_Reset => 0,
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

   --  Write '1' to disable interrupt for ENDTX event
   type INTENCLR_ENDTX_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_ENDTX_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for ENDTX event
   type INTENCLR_ENDTX_Field_1 is
     (--  Reset value for the field
      INTENCLR_ENDTX_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_ENDTX_Field_1 use
     (INTENCLR_ENDTX_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for AUTOCOLRESSTARTED event
   type INTENCLR_AUTOCOLRESSTARTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_AUTOCOLRESSTARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for AUTOCOLRESSTARTED event
   type INTENCLR_AUTOCOLRESSTARTED_Field_1 is
     (--  Reset value for the field
      INTENCLR_AUTOCOLRESSTARTED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_AUTOCOLRESSTARTED_Field_1 use
     (INTENCLR_AUTOCOLRESSTARTED_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for COLLISION event
   type INTENCLR_COLLISION_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_COLLISION_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for COLLISION event
   type INTENCLR_COLLISION_Field_1 is
     (--  Reset value for the field
      INTENCLR_COLLISION_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_COLLISION_Field_1 use
     (INTENCLR_COLLISION_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for SELECTED event
   type INTENCLR_SELECTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_SELECTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for SELECTED event
   type INTENCLR_SELECTED_Field_1 is
     (--  Reset value for the field
      INTENCLR_SELECTED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_SELECTED_Field_1 use
     (INTENCLR_SELECTED_Field_Reset => 0,
      Clear => 1);

   --  Write '1' to disable interrupt for STARTED event
   type INTENCLR_STARTED_Field is
     (--  Read: Disabled
      Disabled,
      --  Read: Enabled
      Enabled)
     with Size => 1;
   for INTENCLR_STARTED_Field use
     (Disabled => 0,
      Enabled => 1);

   --  Write '1' to disable interrupt for STARTED event
   type INTENCLR_STARTED_Field_1 is
     (--  Reset value for the field
      INTENCLR_STARTED_Field_Reset,
      --  Disable
      Clear)
     with Size => 1;
   for INTENCLR_STARTED_Field_1 use
     (INTENCLR_STARTED_Field_Reset => 0,
      Clear => 1);

   --  Disable interrupt
   type INTENCLR_Register is record
      --  Write '1' to disable interrupt for READY event
      READY             : INTENCLR_READY_Field_1 :=
                           INTENCLR_READY_Field_Reset;
      --  Write '1' to disable interrupt for FIELDDETECTED event
      FIELDDETECTED     : INTENCLR_FIELDDETECTED_Field_1 :=
                           INTENCLR_FIELDDETECTED_Field_Reset;
      --  Write '1' to disable interrupt for FIELDLOST event
      FIELDLOST         : INTENCLR_FIELDLOST_Field_1 :=
                           INTENCLR_FIELDLOST_Field_Reset;
      --  Write '1' to disable interrupt for TXFRAMESTART event
      TXFRAMESTART      : INTENCLR_TXFRAMESTART_Field_1 :=
                           INTENCLR_TXFRAMESTART_Field_Reset;
      --  Write '1' to disable interrupt for TXFRAMEEND event
      TXFRAMEEND        : INTENCLR_TXFRAMEEND_Field_1 :=
                           INTENCLR_TXFRAMEEND_Field_Reset;
      --  Write '1' to disable interrupt for RXFRAMESTART event
      RXFRAMESTART      : INTENCLR_RXFRAMESTART_Field_1 :=
                           INTENCLR_RXFRAMESTART_Field_Reset;
      --  Write '1' to disable interrupt for RXFRAMEEND event
      RXFRAMEEND        : INTENCLR_RXFRAMEEND_Field_1 :=
                           INTENCLR_RXFRAMEEND_Field_Reset;
      --  Write '1' to disable interrupt for ERROR event
      ERROR             : INTENCLR_ERROR_Field_1 :=
                           INTENCLR_ERROR_Field_Reset;
      --  unspecified
      Reserved_8_9      : NRF52840.UInt2 := 16#0#;
      --  Write '1' to disable interrupt for RXERROR event
      RXERROR           : INTENCLR_RXERROR_Field_1 :=
                           INTENCLR_RXERROR_Field_Reset;
      --  Write '1' to disable interrupt for ENDRX event
      ENDRX             : INTENCLR_ENDRX_Field_1 :=
                           INTENCLR_ENDRX_Field_Reset;
      --  Write '1' to disable interrupt for ENDTX event
      ENDTX             : INTENCLR_ENDTX_Field_1 :=
                           INTENCLR_ENDTX_Field_Reset;
      --  unspecified
      Reserved_13_13    : NRF52840.Bit := 16#0#;
      --  Write '1' to disable interrupt for AUTOCOLRESSTARTED event
      AUTOCOLRESSTARTED : INTENCLR_AUTOCOLRESSTARTED_Field_1 :=
                           INTENCLR_AUTOCOLRESSTARTED_Field_Reset;
      --  unspecified
      Reserved_15_17    : NRF52840.UInt3 := 16#0#;
      --  Write '1' to disable interrupt for COLLISION event
      COLLISION         : INTENCLR_COLLISION_Field_1 :=
                           INTENCLR_COLLISION_Field_Reset;
      --  Write '1' to disable interrupt for SELECTED event
      SELECTED          : INTENCLR_SELECTED_Field_1 :=
                           INTENCLR_SELECTED_Field_Reset;
      --  Write '1' to disable interrupt for STARTED event
      STARTED           : INTENCLR_STARTED_Field_1 :=
                           INTENCLR_STARTED_Field_Reset;
      --  unspecified
      Reserved_21_31    : NRF52840.UInt11 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for INTENCLR_Register use record
      READY             at 0 range 0 .. 0;
      FIELDDETECTED     at 0 range 1 .. 1;
      FIELDLOST         at 0 range 2 .. 2;
      TXFRAMESTART      at 0 range 3 .. 3;
      TXFRAMEEND        at 0 range 4 .. 4;
      RXFRAMESTART      at 0 range 5 .. 5;
      RXFRAMEEND        at 0 range 6 .. 6;
      ERROR             at 0 range 7 .. 7;
      Reserved_8_9      at 0 range 8 .. 9;
      RXERROR           at 0 range 10 .. 10;
      ENDRX             at 0 range 11 .. 11;
      ENDTX             at 0 range 12 .. 12;
      Reserved_13_13    at 0 range 13 .. 13;
      AUTOCOLRESSTARTED at 0 range 14 .. 14;
      Reserved_15_17    at 0 range 15 .. 17;
      COLLISION         at 0 range 18 .. 18;
      SELECTED          at 0 range 19 .. 19;
      STARTED           at 0 range 20 .. 20;
      Reserved_21_31    at 0 range 21 .. 31;
   end record;

   subtype ERRORSTATUS_FRAMEDELAYTIMEOUT_Field is NRF52840.Bit;

   --  NFC Error Status register
   type ERRORSTATUS_Register is record
      --  No STARTTX task triggered before expiration of the time set in
      --  FRAMEDELAYMAX
      FRAMEDELAYTIMEOUT : ERRORSTATUS_FRAMEDELAYTIMEOUT_Field := 16#0#;
      --  unspecified
      Reserved_1_31     : NRF52840.UInt31 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for ERRORSTATUS_Register use record
      FRAMEDELAYTIMEOUT at 0 range 0 .. 0;
      Reserved_1_31     at 0 range 1 .. 31;
   end record;

   ------------------------------------------
   -- NFCT_FRAMESTATUS cluster's Registers --
   ------------------------------------------

   --  No valid end of frame (EoF) detected
   type RX_CRCERROR_Field is
     (--  Valid CRC detected
      CRCCorrect,
      --  CRC received does not match local check
      CRCError)
     with Size => 1;
   for RX_CRCERROR_Field use
     (CRCCorrect => 0,
      CRCError => 1);

   --  Parity status of received frame
   type RX_PARITYSTATUS_Field is
     (--  Frame received with parity OK
      ParityOK,
      --  Frame received with parity error
      ParityError)
     with Size => 1;
   for RX_PARITYSTATUS_Field use
     (ParityOK => 0,
      ParityError => 1);

   --  Overrun detected
   type RX_OVERRUN_Field is
     (--  No overrun detected
      NoOverrun,
      --  Overrun error
      Overrun)
     with Size => 1;
   for RX_OVERRUN_Field use
     (NoOverrun => 0,
      Overrun => 1);

   --  Result of last incoming frame
   type RX_FRAMESTATUS_Register is record
      --  No valid end of frame (EoF) detected
      CRCERROR      : RX_CRCERROR_Field := NRF52840.NFCT.CRCCorrect;
      --  unspecified
      Reserved_1_1  : NRF52840.Bit := 16#0#;
      --  Parity status of received frame
      PARITYSTATUS  : RX_PARITYSTATUS_Field := NRF52840.NFCT.ParityOK;
      --  Overrun detected
      OVERRUN       : RX_OVERRUN_Field := NRF52840.NFCT.NoOverrun;
      --  unspecified
      Reserved_4_31 : NRF52840.UInt28 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for RX_FRAMESTATUS_Register use record
      CRCERROR      at 0 range 0 .. 0;
      Reserved_1_1  at 0 range 1 .. 1;
      PARITYSTATUS  at 0 range 2 .. 2;
      OVERRUN       at 0 range 3 .. 3;
      Reserved_4_31 at 0 range 4 .. 31;
   end record;

   --  Unspecified
   type NFCT_FRAMESTATUS_Cluster is record
      --  Result of last incoming frame
      RX : aliased RX_FRAMESTATUS_Register;
      pragma Volatile_Full_Access (RX);
   end record
     with Size => 32;

   for NFCT_FRAMESTATUS_Cluster use record
      RX at 0 range 0 .. 31;
   end record;

   --  NfcTag state
   type NFCTAGSTATE_NFCTAGSTATE_Field is
     (--  Disabled or sense
      Disabled,
      --  RampUp
      RampUp,
      --  Idle
      Idle,
      --  Receive
      Receive,
      --  FrameDelay
      FrameDelay,
      --  Transmit
      Transmit)
     with Size => 3;
   for NFCTAGSTATE_NFCTAGSTATE_Field use
     (Disabled => 0,
      RampUp => 2,
      Idle => 3,
      Receive => 4,
      FrameDelay => 5,
      Transmit => 6);

   --  NfcTag state register
   type NFCTAGSTATE_Register is record
      --  Read-only. NfcTag state
      NFCTAGSTATE   : NFCTAGSTATE_NFCTAGSTATE_Field;
      --  unspecified
      Reserved_3_31 : NRF52840.UInt29;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for NFCTAGSTATE_Register use record
      NFCTAGSTATE   at 0 range 0 .. 2;
      Reserved_3_31 at 0 range 3 .. 31;
   end record;

   --  Reflects the sleep state during automatic collision resolution. Set to
   --  IDLE by a GOIDLE task. Set to SLEEP_A when a valid SLEEP_REQ frame is
   --  received or by a GOSLEEP task.
   type SLEEPSTATE_SLEEPSTATE_Field is
     (--  State is IDLE.
      Idle,
      --  State is SLEEP_A.
      SleepA)
     with Size => 1;
   for SLEEPSTATE_SLEEPSTATE_Field use
     (Idle => 0,
      SleepA => 1);

   --  Sleep state during automatic collision resolution
   type SLEEPSTATE_Register is record
      --  Read-only. Reflects the sleep state during automatic collision
      --  resolution. Set to IDLE by a GOIDLE task. Set to SLEEP_A when a valid
      --  SLEEP_REQ frame is received or by a GOSLEEP task.
      SLEEPSTATE    : SLEEPSTATE_SLEEPSTATE_Field;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SLEEPSTATE_Register use record
      SLEEPSTATE    at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   --  Indicates if a valid field is present. Available only in the activated
   --  state.
   type FIELDPRESENT_FIELDPRESENT_Field is
     (--  No valid field detected
      NoField,
      --  Valid field detected
      FieldPresent)
     with Size => 1;
   for FIELDPRESENT_FIELDPRESENT_Field use
     (NoField => 0,
      FieldPresent => 1);

   --  Indicates if the low level has locked to the field
   type FIELDPRESENT_LOCKDETECT_Field is
     (--  Not locked to field
      NotLocked,
      --  Locked to field
      Locked)
     with Size => 1;
   for FIELDPRESENT_LOCKDETECT_Field use
     (NotLocked => 0,
      Locked => 1);

   --  Indicates the presence or not of a valid field
   type FIELDPRESENT_Register is record
      --  Read-only. Indicates if a valid field is present. Available only in
      --  the activated state.
      FIELDPRESENT  : FIELDPRESENT_FIELDPRESENT_Field;
      --  Read-only. Indicates if the low level has locked to the field
      LOCKDETECT    : FIELDPRESENT_LOCKDETECT_Field;
      --  unspecified
      Reserved_2_31 : NRF52840.UInt30;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for FIELDPRESENT_Register use record
      FIELDPRESENT  at 0 range 0 .. 0;
      LOCKDETECT    at 0 range 1 .. 1;
      Reserved_2_31 at 0 range 2 .. 31;
   end record;

   subtype FRAMEDELAYMIN_FRAMEDELAYMIN_Field is NRF52840.UInt16;

   --  Minimum frame delay
   type FRAMEDELAYMIN_Register is record
      --  Minimum frame delay in number of 13.56 MHz clocks
      FRAMEDELAYMIN  : FRAMEDELAYMIN_FRAMEDELAYMIN_Field := 16#480#;
      --  unspecified
      Reserved_16_31 : NRF52840.UInt16 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for FRAMEDELAYMIN_Register use record
      FRAMEDELAYMIN  at 0 range 0 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   subtype FRAMEDELAYMAX_FRAMEDELAYMAX_Field is NRF52840.UInt20;

   --  Maximum frame delay
   type FRAMEDELAYMAX_Register is record
      --  Maximum frame delay in number of 13.56 MHz clocks
      FRAMEDELAYMAX  : FRAMEDELAYMAX_FRAMEDELAYMAX_Field := 16#1000#;
      --  unspecified
      Reserved_20_31 : NRF52840.UInt12 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for FRAMEDELAYMAX_Register use record
      FRAMEDELAYMAX  at 0 range 0 .. 19;
      Reserved_20_31 at 0 range 20 .. 31;
   end record;

   --  Configuration register for the Frame Delay Timer
   type FRAMEDELAYMODE_FRAMEDELAYMODE_Field is
     (--  Transmission is independent of frame timer and will start when the STARTTX
--  task is triggered. No timeout.
      FreeRun,
      --  Frame is transmitted between FRAMEDELAYMIN and FRAMEDELAYMAX
      Window,
      --  Frame is transmitted exactly at FRAMEDELAYMAX
      ExactVal,
      --  Frame is transmitted on a bit grid between FRAMEDELAYMIN and FRAMEDELAYMAX
      WindowGrid)
     with Size => 2;
   for FRAMEDELAYMODE_FRAMEDELAYMODE_Field use
     (FreeRun => 0,
      Window => 1,
      ExactVal => 2,
      WindowGrid => 3);

   --  Configuration register for the Frame Delay Timer
   type FRAMEDELAYMODE_Register is record
      --  Configuration register for the Frame Delay Timer
      FRAMEDELAYMODE : FRAMEDELAYMODE_FRAMEDELAYMODE_Field :=
                        NRF52840.NFCT.Window;
      --  unspecified
      Reserved_2_31  : NRF52840.UInt30 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for FRAMEDELAYMODE_Register use record
      FRAMEDELAYMODE at 0 range 0 .. 1;
      Reserved_2_31  at 0 range 2 .. 31;
   end record;

   subtype MAXLEN_MAXLEN_Field is NRF52840.UInt9;

   --  Size of the RAM buffer allocated to TXD and RXD data storage each
   type MAXLEN_Register is record
      --  Size of the RAM buffer allocated to TXD and RXD data storage each
      MAXLEN        : MAXLEN_MAXLEN_Field := 16#0#;
      --  unspecified
      Reserved_9_31 : NRF52840.UInt23 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for MAXLEN_Register use record
      MAXLEN        at 0 range 0 .. 8;
      Reserved_9_31 at 0 range 9 .. 31;
   end record;

   ----------------------------------
   -- NFCT_TXD cluster's Registers --
   ----------------------------------

   --  Indicates if parity is added to the frame
   type FRAMECONFIG_PARITY_Field is
     (--  Parity is not added to TX frames
      NoParity,
      --  Parity is added to TX frames
      Parity)
     with Size => 1;
   for FRAMECONFIG_PARITY_Field use
     (NoParity => 0,
      Parity => 1);

   --  Discarding unused bits at start or end of a frame
   type FRAMECONFIG_DISCARDMODE_Field is
     (--  Unused bits are discarded at end of frame (EoF)
      DiscardEnd,
      --  Unused bits are discarded at start of frame (SoF)
      DiscardStart)
     with Size => 1;
   for FRAMECONFIG_DISCARDMODE_Field use
     (DiscardEnd => 0,
      DiscardStart => 1);

   --  Adding SoF or not in TX frames
   type FRAMECONFIG_SOF_Field is
     (--  SoF symbol not added
      NoSoF,
      --  SoF symbol added
      SoF)
     with Size => 1;
   for FRAMECONFIG_SOF_Field use
     (NoSoF => 0,
      SoF => 1);

   --  CRC mode for outgoing frames
   type FRAMECONFIG_CRCMODETX_Field is
     (--  CRC is not added to the frame
      NoCRCTX,
      --  16 bit CRC added to the frame based on all the data read from RAM that is
--  used in the frame
      CRC16TX)
     with Size => 1;
   for FRAMECONFIG_CRCMODETX_Field use
     (NoCRCTX => 0,
      CRC16TX => 1);

   --  Configuration of outgoing frames
   type FRAMECONFIG_TXD_Register is record
      --  Indicates if parity is added to the frame
      PARITY        : FRAMECONFIG_PARITY_Field := NRF52840.NFCT.Parity;
      --  Discarding unused bits at start or end of a frame
      DISCARDMODE   : FRAMECONFIG_DISCARDMODE_Field :=
                       NRF52840.NFCT.DiscardStart;
      --  Adding SoF or not in TX frames
      SOF           : FRAMECONFIG_SOF_Field := NRF52840.NFCT.SoF;
      --  unspecified
      Reserved_3_3  : NRF52840.Bit := 16#0#;
      --  CRC mode for outgoing frames
      CRCMODETX     : FRAMECONFIG_CRCMODETX_Field := NRF52840.NFCT.CRC16TX;
      --  unspecified
      Reserved_5_31 : NRF52840.UInt27 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for FRAMECONFIG_TXD_Register use record
      PARITY        at 0 range 0 .. 0;
      DISCARDMODE   at 0 range 1 .. 1;
      SOF           at 0 range 2 .. 2;
      Reserved_3_3  at 0 range 3 .. 3;
      CRCMODETX     at 0 range 4 .. 4;
      Reserved_5_31 at 0 range 5 .. 31;
   end record;

   subtype AMOUNT_TXD_TXDATABITS_Field is NRF52840.UInt3;
   subtype AMOUNT_TXD_TXDATABYTES_Field is NRF52840.UInt9;

   --  Size of outgoing frame
   type AMOUNT_TXD_Register is record
      --  Number of bits in the last or first byte read from RAM that shall be
      --  included in the frame (excluding parity bit).
      TXDATABITS     : AMOUNT_TXD_TXDATABITS_Field := 16#0#;
      --  Number of complete bytes that shall be included in the frame,
      --  excluding CRC, parity and framing
      TXDATABYTES    : AMOUNT_TXD_TXDATABYTES_Field := 16#0#;
      --  unspecified
      Reserved_12_31 : NRF52840.UInt20 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for AMOUNT_TXD_Register use record
      TXDATABITS     at 0 range 0 .. 2;
      TXDATABYTES    at 0 range 3 .. 11;
      Reserved_12_31 at 0 range 12 .. 31;
   end record;

   --  Unspecified
   type NFCT_TXD_Cluster is record
      --  Configuration of outgoing frames
      FRAMECONFIG : aliased FRAMECONFIG_TXD_Register;
      pragma Volatile_Full_Access (FRAMECONFIG);
      --  Size of outgoing frame
      AMOUNT      : aliased AMOUNT_TXD_Register;
      pragma Volatile_Full_Access (AMOUNT);
   end record
     with Size => 64;

   for NFCT_TXD_Cluster use record
      FRAMECONFIG at 16#0# range 0 .. 31;
      AMOUNT      at 16#4# range 0 .. 31;
   end record;

   ----------------------------------
   -- NFCT_RXD cluster's Registers --
   ----------------------------------

   --  CRC mode for incoming frames
   type FRAMECONFIG_CRCMODERX_Field is
     (--  CRC is not expected in RX frames
      NoCRCRX,
      --  Last 16 bits in RX frame is CRC, CRC is checked and CRCSTATUS updated
      CRC16RX)
     with Size => 1;
   for FRAMECONFIG_CRCMODERX_Field use
     (NoCRCRX => 0,
      CRC16RX => 1);

   --  Configuration of incoming frames
   type FRAMECONFIG_RXD_Register is record
      --  Indicates if parity expected in RX frame
      PARITY        : FRAMECONFIG_PARITY_Field := NRF52840.NFCT.Parity;
      --  unspecified
      Reserved_1_1  : NRF52840.Bit := 16#0#;
      --  SoF expected or not in RX frames
      SOF           : FRAMECONFIG_SOF_Field := NRF52840.NFCT.SoF;
      --  unspecified
      Reserved_3_3  : NRF52840.Bit := 16#0#;
      --  CRC mode for incoming frames
      CRCMODERX     : FRAMECONFIG_CRCMODERX_Field := NRF52840.NFCT.CRC16RX;
      --  unspecified
      Reserved_5_31 : NRF52840.UInt27 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for FRAMECONFIG_RXD_Register use record
      PARITY        at 0 range 0 .. 0;
      Reserved_1_1  at 0 range 1 .. 1;
      SOF           at 0 range 2 .. 2;
      Reserved_3_3  at 0 range 3 .. 3;
      CRCMODERX     at 0 range 4 .. 4;
      Reserved_5_31 at 0 range 5 .. 31;
   end record;

   subtype AMOUNT_RXD_RXDATABITS_Field is NRF52840.UInt3;
   subtype AMOUNT_RXD_RXDATABYTES_Field is NRF52840.UInt9;

   --  Size of last incoming frame
   type AMOUNT_RXD_Register is record
      --  Read-only. Number of bits in the last byte in the frame, if less than
      --  8 (including CRC, but excluding parity and SoF/EoF framing).
      RXDATABITS     : AMOUNT_RXD_RXDATABITS_Field;
      --  Read-only. Number of complete bytes received in the frame (including
      --  CRC, but excluding parity and SoF/EoF framing)
      RXDATABYTES    : AMOUNT_RXD_RXDATABYTES_Field;
      --  unspecified
      Reserved_12_31 : NRF52840.UInt20;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for AMOUNT_RXD_Register use record
      RXDATABITS     at 0 range 0 .. 2;
      RXDATABYTES    at 0 range 3 .. 11;
      Reserved_12_31 at 0 range 12 .. 31;
   end record;

   --  Unspecified
   type NFCT_RXD_Cluster is record
      --  Configuration of incoming frames
      FRAMECONFIG : aliased FRAMECONFIG_RXD_Register;
      pragma Volatile_Full_Access (FRAMECONFIG);
      --  Size of last incoming frame
      AMOUNT      : aliased AMOUNT_RXD_Register;
      pragma Volatile_Full_Access (AMOUNT);
   end record
     with Size => 64;

   for NFCT_RXD_Cluster use record
      FRAMECONFIG at 16#0# range 0 .. 31;
      AMOUNT      at 16#4# range 0 .. 31;
   end record;

   subtype NFCID1_LAST_NFCID1_Z_Field is NRF52840.Byte;
   subtype NFCID1_LAST_NFCID1_Y_Field is NRF52840.Byte;
   subtype NFCID1_LAST_NFCID1_X_Field is NRF52840.Byte;
   subtype NFCID1_LAST_NFCID1_W_Field is NRF52840.Byte;

   --  Last NFCID1 part (4, 7 or 10 bytes ID)
   type NFCID1_LAST_Register is record
      --  NFCID1 byte Z (very last byte sent)
      NFCID1_Z : NFCID1_LAST_NFCID1_Z_Field := 16#63#;
      --  NFCID1 byte Y
      NFCID1_Y : NFCID1_LAST_NFCID1_Y_Field := 16#63#;
      --  NFCID1 byte X
      NFCID1_X : NFCID1_LAST_NFCID1_X_Field := 16#0#;
      --  NFCID1 byte W
      NFCID1_W : NFCID1_LAST_NFCID1_W_Field := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for NFCID1_LAST_Register use record
      NFCID1_Z at 0 range 0 .. 7;
      NFCID1_Y at 0 range 8 .. 15;
      NFCID1_X at 0 range 16 .. 23;
      NFCID1_W at 0 range 24 .. 31;
   end record;

   subtype NFCID1_2ND_LAST_NFCID1_V_Field is NRF52840.Byte;
   subtype NFCID1_2ND_LAST_NFCID1_U_Field is NRF52840.Byte;
   subtype NFCID1_2ND_LAST_NFCID1_T_Field is NRF52840.Byte;

   --  Second last NFCID1 part (7 or 10 bytes ID)
   type NFCID1_2ND_LAST_Register is record
      --  NFCID1 byte V
      NFCID1_V       : NFCID1_2ND_LAST_NFCID1_V_Field := 16#0#;
      --  NFCID1 byte U
      NFCID1_U       : NFCID1_2ND_LAST_NFCID1_U_Field := 16#0#;
      --  NFCID1 byte T
      NFCID1_T       : NFCID1_2ND_LAST_NFCID1_T_Field := 16#0#;
      --  unspecified
      Reserved_24_31 : NRF52840.Byte := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for NFCID1_2ND_LAST_Register use record
      NFCID1_V       at 0 range 0 .. 7;
      NFCID1_U       at 0 range 8 .. 15;
      NFCID1_T       at 0 range 16 .. 23;
      Reserved_24_31 at 0 range 24 .. 31;
   end record;

   subtype NFCID1_3RD_LAST_NFCID1_S_Field is NRF52840.Byte;
   subtype NFCID1_3RD_LAST_NFCID1_R_Field is NRF52840.Byte;
   subtype NFCID1_3RD_LAST_NFCID1_Q_Field is NRF52840.Byte;

   --  Third last NFCID1 part (10 bytes ID)
   type NFCID1_3RD_LAST_Register is record
      --  NFCID1 byte S
      NFCID1_S       : NFCID1_3RD_LAST_NFCID1_S_Field := 16#0#;
      --  NFCID1 byte R
      NFCID1_R       : NFCID1_3RD_LAST_NFCID1_R_Field := 16#0#;
      --  NFCID1 byte Q
      NFCID1_Q       : NFCID1_3RD_LAST_NFCID1_Q_Field := 16#0#;
      --  unspecified
      Reserved_24_31 : NRF52840.Byte := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for NFCID1_3RD_LAST_Register use record
      NFCID1_S       at 0 range 0 .. 7;
      NFCID1_R       at 0 range 8 .. 15;
      NFCID1_Q       at 0 range 16 .. 23;
      Reserved_24_31 at 0 range 24 .. 31;
   end record;

   --  Enables/disables auto collision resolution
   type AUTOCOLRESCONFIG_MODE_Field is
     (--  Auto collision resolution enabled
      Enabled,
      --  Auto collision resolution disabled
      Disabled)
     with Size => 1;
   for AUTOCOLRESCONFIG_MODE_Field use
     (Enabled => 0,
      Disabled => 1);

   --  Controls the auto collision resolution function. This setting must be
   --  done before the NFCT peripheral is enabled.
   type AUTOCOLRESCONFIG_Register is record
      --  Enables/disables auto collision resolution
      MODE          : AUTOCOLRESCONFIG_MODE_Field := NRF52840.NFCT.Enabled;
      --  unspecified
      Reserved_1_31 : NRF52840.UInt31 := 16#1#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for AUTOCOLRESCONFIG_Register use record
      MODE          at 0 range 0 .. 0;
      Reserved_1_31 at 0 range 1 .. 31;
   end record;

   --  Bit frame SDD as defined by the b5:b1 of byte 1 in SENS_RES response in
   --  the NFC Forum, NFC Digital Protocol Technical Specification
   type SENSRES_BITFRAMESDD_Field is
     (--  SDD pattern 00000
      SDD00000,
      --  SDD pattern 00001
      SDD00001,
      --  SDD pattern 00010
      SDD00010,
      --  SDD pattern 00100
      SDD00100,
      --  SDD pattern 01000
      SDD01000,
      --  SDD pattern 10000
      SDD10000)
     with Size => 5;
   for SENSRES_BITFRAMESDD_Field use
     (SDD00000 => 0,
      SDD00001 => 1,
      SDD00010 => 2,
      SDD00100 => 4,
      SDD01000 => 8,
      SDD10000 => 16);

   subtype SENSRES_RFU5_Field is NRF52840.Bit;

   --  NFCID1 size. This value is used by the auto collision resolution engine.
   type SENSRES_NFCIDSIZE_Field is
     (--  NFCID1 size: single (4 bytes)
      NFCID1Single,
      --  NFCID1 size: double (7 bytes)
      NFCID1Double,
      --  NFCID1 size: triple (10 bytes)
      NFCID1Triple)
     with Size => 2;
   for SENSRES_NFCIDSIZE_Field use
     (NFCID1Single => 0,
      NFCID1Double => 1,
      NFCID1Triple => 2);

   subtype SENSRES_PLATFCONFIG_Field is NRF52840.UInt4;
   subtype SENSRES_RFU74_Field is NRF52840.UInt4;

   --  NFC-A SENS_RES auto-response settings
   type SENSRES_Register is record
      --  Bit frame SDD as defined by the b5:b1 of byte 1 in SENS_RES response
      --  in the NFC Forum, NFC Digital Protocol Technical Specification
      BITFRAMESDD    : SENSRES_BITFRAMESDD_Field := NRF52840.NFCT.SDD00001;
      --  Reserved for future use. Shall be 0.
      RFU5           : SENSRES_RFU5_Field := 16#0#;
      --  NFCID1 size. This value is used by the auto collision resolution
      --  engine.
      NFCIDSIZE      : SENSRES_NFCIDSIZE_Field := NRF52840.NFCT.NFCID1Single;
      --  Tag platform configuration as defined by the b4:b1 of byte 2 in
      --  SENS_RES response in the NFC Forum, NFC Digital Protocol Technical
      --  Specification
      PLATFCONFIG    : SENSRES_PLATFCONFIG_Field := 16#0#;
      --  Reserved for future use. Shall be 0.
      RFU74          : SENSRES_RFU74_Field := 16#0#;
      --  unspecified
      Reserved_16_31 : NRF52840.UInt16 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SENSRES_Register use record
      BITFRAMESDD    at 0 range 0 .. 4;
      RFU5           at 0 range 5 .. 5;
      NFCIDSIZE      at 0 range 6 .. 7;
      PLATFCONFIG    at 0 range 8 .. 11;
      RFU74          at 0 range 12 .. 15;
      Reserved_16_31 at 0 range 16 .. 31;
   end record;

   subtype SELRES_RFU10_Field is NRF52840.UInt2;
   subtype SELRES_CASCADE_Field is NRF52840.Bit;
   subtype SELRES_RFU43_Field is NRF52840.UInt2;
   subtype SELRES_PROTOCOL_Field is NRF52840.UInt2;
   subtype SELRES_RFU7_Field is NRF52840.Bit;

   --  NFC-A SEL_RES auto-response settings
   type SELRES_Register is record
      --  Reserved for future use. Shall be 0.
      RFU10         : SELRES_RFU10_Field := 16#0#;
      --  Cascade as defined by the b3 of SEL_RES response in the NFC Forum,
      --  NFC Digital Protocol Technical Specification (controlled by hardware,
      --  shall be 0)
      CASCADE       : SELRES_CASCADE_Field := 16#0#;
      --  Reserved for future use. Shall be 0.
      RFU43         : SELRES_RFU43_Field := 16#0#;
      --  Protocol as defined by the b7:b6 of SEL_RES response in the NFC
      --  Forum, NFC Digital Protocol Technical Specification
      PROTOCOL      : SELRES_PROTOCOL_Field := 16#0#;
      --  Reserved for future use. Shall be 0.
      RFU7          : SELRES_RFU7_Field := 16#0#;
      --  unspecified
      Reserved_8_31 : NRF52840.UInt24 := 16#0#;
   end record
     with Object_Size => 32, Bit_Order => System.Low_Order_First;

   for SELRES_Register use record
      RFU10         at 0 range 0 .. 1;
      CASCADE       at 0 range 2 .. 2;
      RFU43         at 0 range 3 .. 4;
      PROTOCOL      at 0 range 5 .. 6;
      RFU7          at 0 range 7 .. 7;
      Reserved_8_31 at 0 range 8 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  NFC-A compatible radio
   type NFCT_Peripheral is record
      --  Activate NFCT peripheral for incoming and outgoing frames, change
      --  state to activated
      TASKS_ACTIVATE           : aliased TASKS_ACTIVATE_Register;
      pragma Volatile_Full_Access (TASKS_ACTIVATE);
      --  Disable NFCT peripheral
      TASKS_DISABLE            : aliased TASKS_DISABLE_Register;
      pragma Volatile_Full_Access (TASKS_DISABLE);
      --  Enable NFC sense field mode, change state to sense mode
      TASKS_SENSE              : aliased TASKS_SENSE_Register;
      pragma Volatile_Full_Access (TASKS_SENSE);
      --  Start transmission of an outgoing frame, change state to transmit
      TASKS_STARTTX            : aliased TASKS_STARTTX_Register;
      pragma Volatile_Full_Access (TASKS_STARTTX);
      --  Initializes the EasyDMA for receive.
      TASKS_ENABLERXDATA       : aliased TASKS_ENABLERXDATA_Register;
      pragma Volatile_Full_Access (TASKS_ENABLERXDATA);
      --  Force state machine to IDLE state
      TASKS_GOIDLE             : aliased TASKS_GOIDLE_Register;
      pragma Volatile_Full_Access (TASKS_GOIDLE);
      --  Force state machine to SLEEP_A state
      TASKS_GOSLEEP            : aliased TASKS_GOSLEEP_Register;
      pragma Volatile_Full_Access (TASKS_GOSLEEP);
      --  The NFCT peripheral is ready to receive and send frames
      EVENTS_READY             : aliased EVENTS_READY_Register;
      pragma Volatile_Full_Access (EVENTS_READY);
      --  Remote NFC field detected
      EVENTS_FIELDDETECTED     : aliased EVENTS_FIELDDETECTED_Register;
      pragma Volatile_Full_Access (EVENTS_FIELDDETECTED);
      --  Remote NFC field lost
      EVENTS_FIELDLOST         : aliased EVENTS_FIELDLOST_Register;
      pragma Volatile_Full_Access (EVENTS_FIELDLOST);
      --  Marks the start of the first symbol of a transmitted frame
      EVENTS_TXFRAMESTART      : aliased EVENTS_TXFRAMESTART_Register;
      pragma Volatile_Full_Access (EVENTS_TXFRAMESTART);
      --  Marks the end of the last transmitted on-air symbol of a frame
      EVENTS_TXFRAMEEND        : aliased EVENTS_TXFRAMEEND_Register;
      pragma Volatile_Full_Access (EVENTS_TXFRAMEEND);
      --  Marks the end of the first symbol of a received frame
      EVENTS_RXFRAMESTART      : aliased EVENTS_RXFRAMESTART_Register;
      pragma Volatile_Full_Access (EVENTS_RXFRAMESTART);
      --  Received data has been checked (CRC, parity) and transferred to RAM,
      --  and EasyDMA has ended accessing the RX buffer
      EVENTS_RXFRAMEEND        : aliased EVENTS_RXFRAMEEND_Register;
      pragma Volatile_Full_Access (EVENTS_RXFRAMEEND);
      --  NFC error reported. The ERRORSTATUS register contains details on the
      --  source of the error.
      EVENTS_ERROR             : aliased EVENTS_ERROR_Register;
      pragma Volatile_Full_Access (EVENTS_ERROR);
      --  NFC RX frame error reported. The FRAMESTATUS.RX register contains
      --  details on the source of the error.
      EVENTS_RXERROR           : aliased EVENTS_RXERROR_Register;
      pragma Volatile_Full_Access (EVENTS_RXERROR);
      --  RX buffer (as defined by PACKETPTR and MAXLEN) in Data RAM full.
      EVENTS_ENDRX             : aliased EVENTS_ENDRX_Register;
      pragma Volatile_Full_Access (EVENTS_ENDRX);
      --  Transmission of data in RAM has ended, and EasyDMA has ended
      --  accessing the TX buffer
      EVENTS_ENDTX             : aliased EVENTS_ENDTX_Register;
      pragma Volatile_Full_Access (EVENTS_ENDTX);
      --  Auto collision resolution process has started
      EVENTS_AUTOCOLRESSTARTED : aliased EVENTS_AUTOCOLRESSTARTED_Register;
      pragma Volatile_Full_Access (EVENTS_AUTOCOLRESSTARTED);
      --  NFC auto collision resolution error reported.
      EVENTS_COLLISION         : aliased EVENTS_COLLISION_Register;
      pragma Volatile_Full_Access (EVENTS_COLLISION);
      --  NFC auto collision resolution successfully completed
      EVENTS_SELECTED          : aliased EVENTS_SELECTED_Register;
      pragma Volatile_Full_Access (EVENTS_SELECTED);
      --  EasyDMA is ready to receive or send frames.
      EVENTS_STARTED           : aliased EVENTS_STARTED_Register;
      pragma Volatile_Full_Access (EVENTS_STARTED);
      --  Shortcut register
      SHORTS                   : aliased SHORTS_Register;
      pragma Volatile_Full_Access (SHORTS);
      --  Enable or disable interrupt
      INTEN                    : aliased INTEN_Register;
      pragma Volatile_Full_Access (INTEN);
      --  Enable interrupt
      INTENSET                 : aliased INTENSET_Register;
      pragma Volatile_Full_Access (INTENSET);
      --  Disable interrupt
      INTENCLR                 : aliased INTENCLR_Register;
      pragma Volatile_Full_Access (INTENCLR);
      --  NFC Error Status register
      ERRORSTATUS              : aliased ERRORSTATUS_Register;
      pragma Volatile_Full_Access (ERRORSTATUS);
      --  Unspecified
      FRAMESTATUS              : aliased NFCT_FRAMESTATUS_Cluster;
      --  NfcTag state register
      NFCTAGSTATE              : aliased NFCTAGSTATE_Register;
      pragma Volatile_Full_Access (NFCTAGSTATE);
      --  Sleep state during automatic collision resolution
      SLEEPSTATE               : aliased SLEEPSTATE_Register;
      pragma Volatile_Full_Access (SLEEPSTATE);
      --  Indicates the presence or not of a valid field
      FIELDPRESENT             : aliased FIELDPRESENT_Register;
      pragma Volatile_Full_Access (FIELDPRESENT);
      --  Minimum frame delay
      FRAMEDELAYMIN            : aliased FRAMEDELAYMIN_Register;
      pragma Volatile_Full_Access (FRAMEDELAYMIN);
      --  Maximum frame delay
      FRAMEDELAYMAX            : aliased FRAMEDELAYMAX_Register;
      pragma Volatile_Full_Access (FRAMEDELAYMAX);
      --  Configuration register for the Frame Delay Timer
      FRAMEDELAYMODE           : aliased FRAMEDELAYMODE_Register;
      pragma Volatile_Full_Access (FRAMEDELAYMODE);
      --  Packet pointer for TXD and RXD data storage in Data RAM
      PACKETPTR                : aliased NRF52840.UInt32;
      --  Size of the RAM buffer allocated to TXD and RXD data storage each
      MAXLEN                   : aliased MAXLEN_Register;
      pragma Volatile_Full_Access (MAXLEN);
      --  Unspecified
      TXD                      : aliased NFCT_TXD_Cluster;
      --  Unspecified
      RXD                      : aliased NFCT_RXD_Cluster;
      --  Last NFCID1 part (4, 7 or 10 bytes ID)
      NFCID1_LAST              : aliased NFCID1_LAST_Register;
      pragma Volatile_Full_Access (NFCID1_LAST);
      --  Second last NFCID1 part (7 or 10 bytes ID)
      NFCID1_2ND_LAST          : aliased NFCID1_2ND_LAST_Register;
      pragma Volatile_Full_Access (NFCID1_2ND_LAST);
      --  Third last NFCID1 part (10 bytes ID)
      NFCID1_3RD_LAST          : aliased NFCID1_3RD_LAST_Register;
      pragma Volatile_Full_Access (NFCID1_3RD_LAST);
      --  Controls the auto collision resolution function. This setting must be
      --  done before the NFCT peripheral is enabled.
      AUTOCOLRESCONFIG         : aliased AUTOCOLRESCONFIG_Register;
      pragma Volatile_Full_Access (AUTOCOLRESCONFIG);
      --  NFC-A SENS_RES auto-response settings
      SENSRES                  : aliased SENSRES_Register;
      pragma Volatile_Full_Access (SENSRES);
      --  NFC-A SEL_RES auto-response settings
      SELRES                   : aliased SELRES_Register;
      pragma Volatile_Full_Access (SELRES);
   end record
     with Volatile;

   for NFCT_Peripheral use record
      TASKS_ACTIVATE           at 16#0# range 0 .. 31;
      TASKS_DISABLE            at 16#4# range 0 .. 31;
      TASKS_SENSE              at 16#8# range 0 .. 31;
      TASKS_STARTTX            at 16#C# range 0 .. 31;
      TASKS_ENABLERXDATA       at 16#1C# range 0 .. 31;
      TASKS_GOIDLE             at 16#24# range 0 .. 31;
      TASKS_GOSLEEP            at 16#28# range 0 .. 31;
      EVENTS_READY             at 16#100# range 0 .. 31;
      EVENTS_FIELDDETECTED     at 16#104# range 0 .. 31;
      EVENTS_FIELDLOST         at 16#108# range 0 .. 31;
      EVENTS_TXFRAMESTART      at 16#10C# range 0 .. 31;
      EVENTS_TXFRAMEEND        at 16#110# range 0 .. 31;
      EVENTS_RXFRAMESTART      at 16#114# range 0 .. 31;
      EVENTS_RXFRAMEEND        at 16#118# range 0 .. 31;
      EVENTS_ERROR             at 16#11C# range 0 .. 31;
      EVENTS_RXERROR           at 16#128# range 0 .. 31;
      EVENTS_ENDRX             at 16#12C# range 0 .. 31;
      EVENTS_ENDTX             at 16#130# range 0 .. 31;
      EVENTS_AUTOCOLRESSTARTED at 16#138# range 0 .. 31;
      EVENTS_COLLISION         at 16#148# range 0 .. 31;
      EVENTS_SELECTED          at 16#14C# range 0 .. 31;
      EVENTS_STARTED           at 16#150# range 0 .. 31;
      SHORTS                   at 16#200# range 0 .. 31;
      INTEN                    at 16#300# range 0 .. 31;
      INTENSET                 at 16#304# range 0 .. 31;
      INTENCLR                 at 16#308# range 0 .. 31;
      ERRORSTATUS              at 16#404# range 0 .. 31;
      FRAMESTATUS              at 16#40C# range 0 .. 31;
      NFCTAGSTATE              at 16#410# range 0 .. 31;
      SLEEPSTATE               at 16#420# range 0 .. 31;
      FIELDPRESENT             at 16#43C# range 0 .. 31;
      FRAMEDELAYMIN            at 16#504# range 0 .. 31;
      FRAMEDELAYMAX            at 16#508# range 0 .. 31;
      FRAMEDELAYMODE           at 16#50C# range 0 .. 31;
      PACKETPTR                at 16#510# range 0 .. 31;
      MAXLEN                   at 16#514# range 0 .. 31;
      TXD                      at 16#518# range 0 .. 63;
      RXD                      at 16#520# range 0 .. 63;
      NFCID1_LAST              at 16#590# range 0 .. 31;
      NFCID1_2ND_LAST          at 16#594# range 0 .. 31;
      NFCID1_3RD_LAST          at 16#598# range 0 .. 31;
      AUTOCOLRESCONFIG         at 16#59C# range 0 .. 31;
      SENSRES                  at 16#5A0# range 0 .. 31;
      SELRES                   at 16#5A4# range 0 .. 31;
   end record;

   --  NFC-A compatible radio
   NFCT_Periph : aliased NFCT_Peripheral
     with Import, Address => NFCT_Base;

end NRF52840.NFCT;
