--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.MAC.MLME.Req_SAP;
with AdaBee.PHY;

private with AdaBee.MAC.MLME.ED_Scan;

--  This package implements the logic for channel scanning as defined in
--  section 8.2.8 of IEEE 802.15.4-2024.
--
--  A scan is triggered by the reception of an MLME-SCAN.request primitive.
--  This state machine then performs the requested scan and sends the
--  MLME-SCAN.confirm primtive.
--
--  The state machine is driven by the following events:
--   * The reception of a MLME-SCAN.request primitive (`Notify_SCAN_Req`)
--   * The reception of an `Operation_Complete` event from the PHY
--     (`Notify_Operation_Complete`).
--
--  Only one scan can be active at a time. A MLME-SCAN.request is rejected
--  if a scan is already in progress.

private package AdaBee.MAC.MLME.Scan_FSM
  with Elaborate_Body, SPARK_Mode
is

   use all type AdaBee.PHY.State_Kind;

   type State_Kind is (Idle, ED_Scan_Active);

   function Is_SCAN_Req
     (Handle : AdaBee.MAC.MLME.Req_SAP.Service_Handle) return Boolean;

   type Machine is limited private
   with Default_Initial_Condition => Current_State (Machine) = Idle;

   function Current_State (FSM : Machine) return State_Kind
   with Global => null;

   procedure Notify_SCAN_Req
     (FSM    : in out Machine;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   with
     Pre  =>
       Is_SCAN_Req (Handle)
       and then not Req_SAP.Confirm_Written (Handle)
       and then
         (if Current_State (FSM) = Idle
          then
            AdaBee.PHY.Current_State in Off | Sleeping | Exiting_Sleep | Idle),
     Post =>
       Req_SAP.Is_Null (Handle)
       and then
         (declare
            Old_PHY_State : constant AdaBee.PHY.State_Kind :=
              AdaBee.PHY.Current_State'Old;
            Old_FSM_State : constant State_Kind := Current_State (FSM)'Old;
          begin
            (if Old_FSM_State /= Idle
             then
               Current_State (FSM) = Old_FSM_State
               and then AdaBee.PHY.Current_State = Old_PHY_State

             elsif Current_State (FSM) = Idle
             then AdaBee.PHY.Current_State = Old_PHY_State

             elsif Old_PHY_State in Off | Sleeping | Exiting_Sleep
             then AdaBee.PHY.Current_State = Exiting_Sleep

             else AdaBee.PHY.Current_State = ED_Scan_Active));
   --  Notify the state machine that a new MLME-SCAN.request primitive has
   --  been received.
   --
   --  If the state machine is idle, then this will begin a new scan.
   --  Note that the scan might complete immediately in some cases, e.g. if
   --  an invalid request is received.
   --
   --  If a scan is already in progress, then the new MLME-SCAN.request is
   --  rejected.

   procedure Notify_PHY_Operation_Complete (FSM : in out Machine)
   with
     Always_Terminates => False,
     Pre               =>
       Current_State (FSM) /= Idle
       and then AdaBee.PHY.Current_State in Idle | ED_Scan_Complete,
     Post              =>
       (case Current_State (FSM) is
          when Idle           => AdaBee.PHY.Current_State = Idle,
          when ED_Scan_Active => AdaBee.PHY.Current_State = ED_Scan_Active);
   --  Notify the state machine that the PHY has emitted the
   --  `Operation_Complete` event.

private

   -----------------
   -- Is_SCAN_Req --
   -----------------

   function Is_SCAN_Req (Request : MLME_Request_Type) return Boolean
   is (Request.Kind = MLME_SCAN_Req);

   function Is_SCAN_Req
     (Handle : AdaBee.MAC.MLME.Req_SAP.Service_Handle) return Boolean
   is (not Req_SAP.Is_Null (Handle)
       and then Is_SCAN_Req (Req_SAP.Request_Reference (Handle).all));

   -------------
   -- Machine --
   -------------

   type Machine is limited record
      Handle  : AdaBee.MAC.MLME.Req_SAP.Service_Handle;
      ED_Scan : AdaBee.MAC.MLME.ED_Scan.Scan_State;
   end record
   with
     Type_Invariant =>
       (if not Req_SAP.Is_Null (Handle)
        then
          Is_SCAN_Req (Handle)
          and then AdaBee.MAC.MLME.ED_Scan.Is_Valid (ED_Scan, Handle));

   -------------------
   -- Current_State --
   -------------------

   function Current_State (FSM : Machine) return State_Kind
   is (if Req_SAP.Is_Null (FSM.Handle) then Idle else ED_Scan_Active);

end AdaBee.MAC.MLME.Scan_FSM;
