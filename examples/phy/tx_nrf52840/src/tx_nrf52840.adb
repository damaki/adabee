--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Text_IO;
with Ada.Real_Time;

with AdaBee;
with AdaBee.PHY; use AdaBee.PHY;

procedure TX_NRF52840
with SPARK_Mode, No_Return, Pre => AdaBee.PHY.Current_State = Off
is

   function First_Supported_Channel return AdaBee.PHY.RF_Channel_Number
   with
     Global => null,
     Post   => AdaBee.PHY.Channel_Supported (First_Supported_Channel'Result);
   --  Get the first channel that is supported by the PHY

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

   Packet : constant AdaBee.Byte_Array (1 .. 10) :=
     (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
   --  Buffer containing the packet to transmit

   CCA_Result : AdaBee.PHY.CCA_Result_Kind;

begin
   Ada.Text_IO.Put_Line ("Packet transmit demo");

   --  Power up the PHY and wait for the PHY to finish exiting sleep
   --  (Operation_Complete event).

   AdaBee.PHY.Turn_On;
   AdaBee.PHY.Exit_Sleep;
   AdaBee.PHY.Wait_For_Event (AdaBee.PHY.Operation_Complete);

   --  Configure the PHY

   AdaBee.PHY.Set_Channel (First_Supported_Channel);
   AdaBee.PHY.Set_Tx_Power (-40);
   AdaBee.PHY.Set_CCA_Mode (AdaBee.PHY.Energy_Above_Threshold);

   --  Transmit the packet (including a CCA check)

   AdaBee.PHY.Transmit_Now (Packet => Packet, Ignore_CCA => False);
   AdaBee.PHY.Wait_For_Event (AdaBee.PHY.Operation_Complete);

   --  Check if the transmit was successful

   AdaBee.PHY.Get_CCA_Result (CCA_Result);

   if CCA_Result = AdaBee.PHY.Clear then
      Ada.Text_IO.Put_Line ("Channel clear - packet transmitted");
   else
      Ada.Text_IO.Put_Line ("Channel busy - packet not transmitted");
   end if;

   --  Return the PHY to the Idle state to complete the transmit process

   AdaBee.PHY.Go_Idle;

   --  Turn the PHY off

   AdaBee.PHY.Enter_Sleep;
   AdaBee.PHY.Turn_Off;

   --  Go to sleep

   loop
      delay until Ada.Real_Time.Time_Last;
   end loop;

end TX_NRF52840;
