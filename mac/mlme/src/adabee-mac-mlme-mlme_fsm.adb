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
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle) is
   begin
      Scan_FSM.Notify_SCAN_Req (FSM.Scan_Machine, Handle);

      if FSM.State = Idle
        and then Scan_FSM.Current_State (FSM.Scan_Machine) = Scan_Pending
      then
         FSM.State := Exiting_Sleep;
         AdaBee.PHY.Turn_On;
         AdaBee.PHY.Exit_Sleep;
      end if;
   end Notify_SCAN_Req;

   ----------------------
   -- Notify_RESET_Req --
   ----------------------

   procedure Notify_RESET_Req
     (FSM    : in out Machine;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   is
      function Is_RESET_Req (Request : MLME_Request_Type) return Boolean
      is (Request.Kind = MLME_RESET_Req)
      with Ghost;

      procedure Write_RESET_Cfm
        (Request : MLME_Request_Type; Confirm : out MLME_Confirm_Type)
      with
        Pre  => Is_RESET_Req (Request) and then not Confirm'Constrained,
        Post => Valid_Confirm (Request, Confirm)
      is
         pragma Unreferenced (Request);
      begin
         Confirm := (Kind => MLME_RESET_Cfm, RESET => (Status => Success));
      end Write_RESET_Cfm;

      procedure Write_RESET_Cfm is new
        Req_SAP.Initialize_Confirm
          (Initialize    => Write_RESET_Cfm,
           Precondition  => Is_RESET_Req,
           Postcondition => Valid_Confirm);

   begin
      case FSM.State is
         when Idle          =>
            null;

         when Exiting_Sleep =>
            Scan_FSM.Cancel_Scan (FSM.Scan_Machine);

            AdaBee.PHY.Wait_For_Event (AdaBee.PHY.Operation_Complete);
            AdaBee.PHY.Enter_Sleep;
            AdaBee.PHY.Turn_Off;

         when Scan_Active   =>
            Scan_FSM.Cancel_Scan (FSM.Scan_Machine);

            AdaBee.PHY.Enter_Sleep;
            AdaBee.PHY.Turn_Off;

      end case;

      FSM.State := Idle;

      if Req_SAP.Request_Reference (Handle).all.RESET.Set_Default_PIB then
         AdaBee.MAC.MLME.PIB.Reset;
      end if;

      Write_RESET_Cfm (Handle);
      Req_SAP.Send_Confirm (Handle);
   end Notify_RESET_Req;

   -----------------------------------
   -- Notify_PHY_Operation_Complete --
   -----------------------------------

   procedure Notify_PHY_Operation_Complete (FSM : in out Machine) is
   begin
      case FSM.State is
         when Idle          =>
            pragma Assert (False); --  Unreachable

         when Exiting_Sleep =>
            FSM.State := Scan_Active;
            Scan_FSM.Begin_Scan (FSM.Scan_Machine);

            --  Power down the PHY when the scan has completed.

            if Scan_FSM.Current_State (FSM.Scan_Machine) = Idle then
               FSM.State := Idle;
               AdaBee.PHY.Enter_Sleep;
               AdaBee.PHY.Turn_Off;
            end if;

         when Scan_Active   =>
            Scan_FSM.Notify_PHY_Operation_Complete (FSM.Scan_Machine);

            --  Power down the PHY when the scan has completed.

            if Scan_FSM.Current_State (FSM.Scan_Machine) = Idle then
               FSM.State := Idle;
               AdaBee.PHY.Enter_Sleep;
               AdaBee.PHY.Turn_Off;
            end if;
      end case;

   end Notify_PHY_Operation_Complete;

end AdaBee.MAC.MLME.MLME_FSM;
