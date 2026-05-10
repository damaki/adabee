--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Text_IO;
with Interfaces; use Interfaces;

with AdaBee;
with AdaBee.PHY; use AdaBee.PHY;

procedure RX_NRF52840
with SPARK_Mode, No_Return, Pre => AdaBee.PHY.Current_State = Off
is

   function First_Supported_Channel return AdaBee.PHY.RF_Channel_Number
   with
     Global => null,
     Post   => AdaBee.PHY.Channel_Supported (First_Supported_Channel'Result);
   --  Get the first supported channel

   procedure Print_Hex_Bytes (Bytes : AdaBee.Byte_Array)
   with Global => (In_Out => Ada.Text_IO.File_System);

   -----------------------------
   -- First_Supported_Channel --
   -----------------------------

   function First_Supported_Channel return AdaBee.PHY.RF_Channel_Number is
   begin
      for Ch in AdaBee.PHY.RF_Channel_Number loop
         if AdaBee.PHY.Channel_Supported (Ch) then
            return Ch;
         end if;

         pragma
           Loop_Invariant
             (for all Ch2 in AdaBee.PHY.RF_Channel_Number =>
                (if Ch2 <= Ch then not AdaBee.PHY.Supported_Channels (Ch2)));
      end loop;

      --  This should be unreachable since the PHY supports at least one
      --  channel number.

      pragma Assert (False);
      raise Program_Error;
   end First_Supported_Channel;

   ---------------------
   -- Print_Hex_Bytes --
   ---------------------

   procedure Print_Hex_Bytes (Bytes : AdaBee.Byte_Array) is
      Hex_Chars : constant array (Unsigned_8 range 0 .. 15) of Character :=
      --!format off
        ('0', '1', '2', '3', '4', '5', '6', '7',
         '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
      --!format off

   begin
      for B of Bytes loop
         Ada.Text_IO.Put (Hex_Chars (Shift_Right (B, 4) and 16#0F#));
         Ada.Text_IO.Put (Hex_Chars (B and 16#0F#));
      end loop;
   end Print_Hex_Bytes;

   Rx_Packet : AdaBee.Byte_Array (1 .. AdaBee.PHY.Maximum_Packet_Length)
   with Relaxed_Initialization;

   Rx_Length : AdaBee.PHY.Packet_Length_Number;
   Rx_Info   : AdaBee.PHY.Receive_Metadata;

begin
   Ada.Text_IO.Put_Line ("Packet receive demo");

   --  Power up the PHY and wait for the PHY to finish exiting sleep
   --  (Operation_Complete event).

   AdaBee.PHY.Turn_On;
   AdaBee.PHY.Exit_Sleep;
   AdaBee.PHY.Wait_For_Event (AdaBee.PHY.Operation_Complete);

   --  Configure the PHY

   AdaBee.PHY.Set_Channel (First_Supported_Channel);
   AdaBee.PHY.Set_Tx_Power (-40);
   AdaBee.PHY.Set_CCA_Mode (AdaBee.PHY.Energy_Above_Threshold);

   --  Keep receiving packets

   loop
      pragma Loop_Invariant (AdaBee.PHY.Current_State = Idle);

      --  Enable the receiver and

      AdaBee.PHY.Receive_Now;
      AdaBee.PHY.Wait_For_Event (AdaBee.PHY.Operation_Complete);

      pragma Assert (AdaBee.PHY.Current_State = Rx_Complete);

      if AdaBee.PHY.Packet_Received then
         AdaBee.PHY.Get_Received_Packet (Rx_Packet, Rx_Length, Rx_Info);

         Ada.Text_IO.Put_Line ("Packet received:");

         Ada.Text_IO.Put ("  Packet: ");
         Print_Hex_Bytes (Rx_Packet (1 .. Rx_Length));
         Ada.Text_IO.New_Line;

         Ada.Text_IO.Put ("  Length:");
         Ada.Text_IO.Put_Line (Rx_Length'Image);

         Ada.Text_IO.Put ("  RSSI: ");
         Ada.Text_IO.Put_Line (Rx_Info.RSSI'Image);

         Ada.Text_IO.Put ("  LQI:");
         Ada.Text_IO.Put_Line (Rx_Info.LQI'Image);

         Ada.Text_IO.Put ("  CRC valid: ");
         Ada.Text_IO.Put_Line (Rx_Info.CRC_Valid'Image);

         Ada.Text_IO.Put ("  tPreamble:");
         Ada.Text_IO.Put_Line (Rx_Info.Timestamps.Preamble_Start'Image);

         Ada.Text_IO.Put ("  tSFD:     ");
         Ada.Text_IO.Put_Line (Rx_Info.Timestamps.Preamble_Start'Image);

         Ada.Text_IO.Put ("  tEnd:     ");
         Ada.Text_IO.Put_Line (Rx_Info.Timestamps.Preamble_Start'Image);
      end if;

      AdaBee.PHY.Go_Idle;
   end loop;
end RX_NRF52840;
