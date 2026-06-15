--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.MAC.MLME.SAP.Requests;
with AdaBee.MAC.MLME.PIB;
with AdaBee.PHY;

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

   use all type AdaBee.MAC.MLME.SAP.MLME_Request_Kind;
   use type AdaBee.MAC.MLME.PIB.PIB_Attributes;

   type State_Kind is (Idle, Exiting_Sleep, Scan_Active);

   type Machine is limited private;

   function Current_State (FSM : Machine) return State_Kind
   with Global => null;

   function Valid_PHY_Active_State (FSM : Machine) return Boolean
   with Ghost, Global => (Input => AdaBee.PHY.Radio_State);

   function Valid_PHY_Operation_Complete_State (FSM : Machine) return Boolean
   with Ghost, Global => (Input => AdaBee.PHY.Radio_State);

   procedure Notify_SCAN_Req
     (FSM    : in out Machine;
      Handle : in out AdaBee.MAC.MLME.SAP.Requests.Service_Handle)
   with
     Pre  =>
       Valid_PHY_Active_State (FSM)
       and then not SAP.Requests.Is_Null (Handle)
       and then
         SAP.Requests.Request_Reference (Handle).all.Kind = MLME_SCAN_Req
       and then not SAP.Requests.Confirm_Written (Handle),
     Post =>
       Valid_PHY_Active_State (FSM) and then SAP.Requests.Is_Null (Handle);
   --  Processes an MLME-SCAN.request primitive.

   procedure Notify_RESET_Req
     (FSM    : in out Machine;
      Handle : in out AdaBee.MAC.MLME.SAP.Requests.Service_Handle)
   with
     Always_Terminates => False,
     Pre               =>
       Valid_PHY_Active_State (FSM)
       and then not SAP.Requests.Is_Null (Handle)
       and then
         SAP.Requests.Request_Reference (Handle).all.Kind = MLME_RESET_Req
       and then not SAP.Requests.Confirm_Written (Handle),
     Post              =>
       Valid_PHY_Active_State (FSM)
       and then Current_State (FSM) = Idle
       and then SAP.Requests.Is_Null (Handle),
     Contract_Cases    =>
       (SAP.Requests.Request_Reference (Handle).all.RESET.Set_Default_PIB
        = True  => AdaBee.MAC.MLME.PIB.DB = AdaBee.MAC.MLME.PIB.Default_PIB,

        SAP.Requests.Request_Reference (Handle).all.RESET.Set_Default_PIB
        = False => AdaBee.MAC.MLME.PIB.DB = AdaBee.MAC.MLME.PIB.DB'Old);
   --  Processes an MLME-RESET.request primitive.

   procedure Notify_PHY_Operation_Complete (FSM : in out Machine)
   with
     Always_Terminates => False,
     Pre               => Valid_PHY_Operation_Complete_State (FSM),
     Post              => Valid_PHY_Active_State (FSM);
   --  Notify the state machine that the PHY has emitted the
   --  `Operation_Complete` event.

private

   use all type AdaBee.MAC.MLME.SAP.Scan_Type_Kind;
   use all type AdaBee.MAC.MLME.Scan_FSM.State_Kind;
   use all type AdaBee.PHY.State_Kind;

   type Machine is limited record
      State        : State_Kind := Idle;
      Scan_Machine : Scan_FSM.Machine;
   end record
   with
     Type_Invariant =>
       (case State is
          when Idle          => Scan_FSM.Current_State (Scan_Machine) = Idle,

          when Exiting_Sleep =>
            Scan_FSM.Current_State (Scan_Machine) = Scan_Pending,

          when Scan_Active   =>
            Scan_FSM.Current_State (Scan_Machine) = Scan_Active);

   -------------------
   -- Current_State --
   -------------------

   function Current_State (FSM : Machine) return State_Kind
   is (FSM.State);

   function Valid_PHY_Active_State (FSM : Machine) return Boolean
   is (case Current_State (FSM) is
         when Idle          => AdaBee.PHY.Current_State = Off,
         when Exiting_Sleep => AdaBee.PHY.Current_State = Exiting_Sleep,
         when Scan_Active   => AdaBee.PHY.Current_State in ED_Scan_Active);

   function Valid_PHY_Operation_Complete_State (FSM : Machine) return Boolean
   is (case Current_State (FSM) is
         when Idle          => False,
         when Exiting_Sleep => AdaBee.PHY.Current_State = Idle,
         when Scan_Active   =>
           (case Scan_FSM.Current_Scan_Type (FSM.Scan_Machine) is
              when ED => AdaBee.PHY.Current_State = ED_Scan_Complete));

end AdaBee.MAC.MLME.MLME_FSM;
