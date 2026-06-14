--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.MLME.MLME_FSM
  with SPARK_Mode
is

   ---------------------
   -- Notify_SCAN_Req --
   ---------------------

   procedure Notify_SCAN_Req
     (FSM    : in out Machine;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   is
   begin
      Scan_FSM.Notify_SCAN_Req (FSM.Scan_Machine, Handle);

      if Scan_FSM.Current_State (FSM.Scan_Machine) = Scan_Pending then
         Scan_FSM.Begin_Scan (FSM.Scan_Machine);
      end if;
   end Notify_SCAN_Req;

   -----------------------------------
   -- Notify_PHY_Operation_Complete --
   -----------------------------------

   procedure Notify_PHY_Operation_Complete (FSM : in out Machine) is
   begin
      Scan_FSM.Notify_PHY_Operation_Complete (FSM.Scan_Machine);

      --  Power down the PHY when the scan has completed.

      if Scan_FSM.Current_State (FSM.Scan_Machine) = Idle then
         AdaBee.PHY.Enter_Sleep;
         AdaBee.PHY.Turn_Off;
      end if;
   end Notify_PHY_Operation_Complete;

end AdaBee.MAC.MLME.MLME_FSM;
