--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.MAC.MLME.Req_SAP;

private with AdaBee.MAC.MLME.Scan_FSM;

--  This package implements the main state machine for the MLME that is
--  responsible for managing the PHY activities.
--
--  This state machine is driven by two sources of events:
--   * Requests received via the MLME-SAP (e.g. a MLME-SCAN.request).
--   * Events from the PHY, such as the `Operation_Complete` event.

private package AdaBee.MAC.MLME.MLME_FSM
  with Elaborate_Body, SPARK_Mode
is

   type State_Kind is (Idle, Scan_Active);

   type Machine is limited private;

   function Current_State (FSM : Machine) return State_Kind
   with Global => null;

   function Valid_PHY_Active_State (FSM : Machine) return Boolean
   with Global => (Input => AdaBee.PHY.Radio_State);

   function Valid_PHY_Operation_Complete_State (FSM : Machine) return Boolean
   with Global => (Input => AdaBee.PHY.Radio_State);

   procedure Notify_SCAN_Req
     (FSM    : in out Machine;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   with
     Pre  =>
       Valid_PHY_Active_State (FSM)
       and then not Req_SAP.Is_Null (Handle)
       and then Req_SAP.Request_Reference (Handle).all.Kind = MLME_SCAN_Req
       and then not Req_SAP.Confirm_Written (Handle),
     Post => Valid_PHY_Active_State (FSM) and then Req_SAP.Is_Null (Handle);
   --  Processes an MLME-SCAN.request primitive.

   procedure Notify_PHY_Operation_Complete (FSM : in out Machine)
   with
     Always_Terminates => False,
     Pre               => Valid_PHY_Operation_Complete_State (FSM),
     Post              => Valid_PHY_Active_State (FSM);
   --  Notify the state machine that the PHY has emitted the
   --  `Operation_Complete` event.

private

   use all type AdaBee.MAC.MLME.Scan_FSM.State_Kind;
   use all type AdaBee.PHY.State_Kind;

   type Machine is limited record
      Scan_Machine : Scan_FSM.Machine;
   end record;

   -------------------
   -- Current_State --
   -------------------

   function Current_State (FSM : Machine) return State_Kind
   is (if Scan_FSM.Current_State (FSM.Scan_Machine) = Scan_Active
       then Scan_Active
       else Idle);

   function Valid_PHY_Active_State (FSM : Machine) return Boolean
   is (case Current_State (FSM) is
         when Idle        => AdaBee.PHY.Current_State = Off,
         when Scan_Active =>
           AdaBee.PHY.Current_State in Exiting_Sleep | ED_Scan_Active);

   function Valid_PHY_Operation_Complete_State (FSM : Machine) return Boolean
   is (case Current_State (FSM) is
         when Idle        => False,
         when Scan_Active =>
           (case Scan_FSM.Current_State (FSM.Scan_Machine) is
              when Idle | Scan_Pending => raise Program_Error, --  Unreachable
              when Scan_Active         =>
                (case Scan_FSM.Current_Scan_Type (FSM.Scan_Machine) is
                   when ED                                          =>
                     AdaBee.PHY.Current_State in Idle | ED_Scan_Complete)));

end AdaBee.MAC.MLME.MLME_FSM;
