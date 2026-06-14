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

   function Is_SCAN_Req
     (Handle : AdaBee.MAC.MLME.Req_SAP.Service_Handle) return Boolean
   with Global => null;
   --  Returns True if `Handle` is a non-null handle that contains an
   --  MLME-SCAN.request primitive.

   -----------
   -- Types --
   -----------

   type State_Kind is (Idle, Scan_Pending, Scan_Active);
   --  The set of types for the state machine

   subtype Supported_Scan_Types is Scan_Type_Kind
   with Static_Predicate => Supported_Scan_Types in ED;
   --  The set of scan types that are supported in this implementation

   ------------------------
   -- Scan State Machine --
   ------------------------

   type Machine is limited private
   with Default_Initial_Condition => Current_State (Machine) = Idle;

   function Current_State (FSM : Machine) return State_Kind
   with Global => null;
   --  Gets the current state of the state machine

   function Current_Scan_Type (FSM : Machine) return Supported_Scan_Types
   with Global => null, Pre => Current_State (FSM) /= Idle;
   --  Gets the scan type that is currently being processed by the state
   --  machine.

   function Valid_PHY_Active_State (FSM : Machine) return Boolean
   with Ghost, Global => (Input => AdaBee.PHY.Radio_State);
   --  Returns True if the PHY is in the correct state for the current scan
   --  state machine state.

   procedure Notify_SCAN_Req
     (FSM    : in out Machine;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   with
     Pre  =>
       Is_SCAN_Req (Handle)
       and then not Req_SAP.Confirm_Written (Handle)
       and then Valid_PHY_Active_State (FSM),
     Post =>
       (declare
          Old_State : constant State_Kind := Current_State (FSM)'Old;
        begin
          Req_SAP.Is_Null (Handle)
          and then Valid_PHY_Active_State (FSM)
          and then
            (if Old_State = Idle
             then Current_State (FSM) in Idle | Scan_Pending
             else Current_State (FSM) = Old_State));
   --  Notify the state machine that a new MLME-SCAN.request primitive has
   --  been received.
   --
   --  If the state machine is idle, then this will begin a new scan.
   --  Note that the scan might complete immediately in some cases, e.g. if
   --  an invalid request is received.
   --
   --  If a scan is already in progress, then the new MLME-SCAN.request is
   --  rejected.

   procedure Begin_Scan (FSM : in out Machine)
   with
     Pre  =>
       Current_State (FSM) = Scan_Pending
       and then
         AdaBee.PHY.Current_State in Off | Sleeping | Exiting_Sleep | Idle,
     Post =>
       (declare
          Old_PHY_State : constant AdaBee.PHY.State_Kind :=
            AdaBee.PHY.Current_State'Old;
        begin
          Current_State (FSM) in Idle | Scan_Active
          and then
            (if Current_State (FSM) = Idle
             then AdaBee.PHY.Current_State = Old_PHY_State
             elsif Old_PHY_State in Off | Sleeping | Exiting_Sleep
             then AdaBee.PHY.Current_State = Exiting_Sleep
             else AdaBee.PHY.Current_State = ED_Scan_Active));

   procedure Notify_PHY_Operation_Complete (FSM : in out Machine)
   with
     Always_Terminates => False,
     Pre               =>
       Current_State (FSM) = Scan_Active
       and then
         (case Current_Scan_Type (FSM) is
            when ED => AdaBee.PHY.Current_State in Idle | ED_Scan_Complete),

     Post              =>
       (case Current_State (FSM) is
          when Idle         => AdaBee.PHY.Current_State = Idle,
          when Scan_Pending => False,
          when Scan_Active  => AdaBee.PHY.Current_State = ED_Scan_Active);
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
      Pending : Boolean := False;
   end record
   with
     Type_Invariant =>
       (if not Req_SAP.Is_Null (Handle)
        then
          --  The Handle is always an MLME-SCAN.request with one of the
          --  supported scan types.
          Req_SAP.Request_Reference (Handle).all.Kind = MLME_SCAN_Req
          and then
            Req_SAP.Request_Reference (Handle).all.SCAN.Scan_Type
            in Supported_Scan_Types

          --  The confirm primitive has not been written yet while the scan
          --  is pending.
          and then
            (if Pending
             then not Req_SAP.Confirm_Written (Handle)
             else AdaBee.MAC.MLME.ED_Scan.Is_Valid (ED_Scan, Handle)));

   -------------------
   -- Current_State --
   -------------------

   function Current_State (FSM : Machine) return State_Kind
   is (if Req_SAP.Is_Null (FSM.Handle)
       then Idle

       elsif FSM.Pending
       then Scan_Pending

       else Scan_Active);

   -----------------------
   -- Current_Scan_Type --
   -----------------------

   function Current_Scan_Type (FSM : Machine) return Supported_Scan_Types
   is (Req_SAP.Request_Reference (FSM.Handle).all.SCAN.Scan_Type);

   ----------------------------
   -- Valid_PHY_Active_State --
   ----------------------------

   function Valid_PHY_Active_State (FSM : Machine) return Boolean
   is (case Current_State (FSM) is
         when Idle | Scan_Pending => True,
         when Scan_Active         =>
           (case Current_Scan_Type (FSM) is
              when ED =>
                AdaBee.PHY.Current_State in Exiting_Sleep | ED_Scan_Active));

end AdaBee.MAC.MLME.Scan_FSM;
