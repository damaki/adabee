--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.MLME.SAP.Requests;
with AdaBee.PHY_Constants;
with AdaBee.PHY;

--  This package implements the logic for performing Energy Detection scans
--  based on an MLME-SCAN.request primitive.
--
--  An ED scan is started by calling `Begin_ED_Scan` and passing the
--  MLME-SCAN.request primitive. The PHY is then configured to begin scanning
--  the first supported channel in the PHY.
--
--  Once the PHY emits the Operation_Complete event at the end of the ED scan,
--  the `Notify_Operation_Complete` procedure must be called. This reads the
--  ED value from the PHY, saves it in the MLME-SCAN.confirm primitive, then
--  configures the PHY to start scanning the next channel.
--
--  The MLME-SCAN.confirm primitive is sent once all channels have been
--  scanned.

private package AdaBee.MAC.MLME.ED_Scan
  with Elaborate_Body, SPARK_Mode
is
   use all type AdaBee.PHY.State_Kind;
   use type AdaBee.PHY.RF_Channel_Number;

   function Is_Valid_ED_SCAN_Req
     (Request : SAP.MLME_Request_Type) return Boolean
   with Global => null;

   function Is_Valid_ED_SCAN_Req
     (Handle : AdaBee.MAC.MLME.SAP.Requests.Service_Handle) return Boolean
   with Global => null;
   --  Returns True if the `Handle` contains an MLME-SCAN.request
   --  primitive with the ScanType set to ED (Energy Detection).

   function Is_Valid_ED_SCAN_Req_And_Cfm
     (Request : SAP.MLME_Request_Type; Confirm : SAP.MLME_Confirm_Type)
      return Boolean
   with Global => null;
   --  Returns True if the `Request` is an MLME-SCAN.request
   --  primitive with the ScanType set to ED (Energy Detection).

   function Is_Valid_ED_SCAN_Req_And_Cfm
     (Handle : AdaBee.MAC.MLME.SAP.Requests.Service_Handle) return Boolean
   with Global => null;

   type Scan_State is private;

   function Is_Valid
     (Scan    : Scan_State;
      Request : SAP.MLME_Request_Type;
      Confirm : SAP.MLME_Confirm_Type) return Boolean
   with Ghost, Global => null;

   function Is_Valid
     (Scan : Scan_State; Handle : AdaBee.MAC.MLME.SAP.Requests.Service_Handle)
      return Boolean
   with Ghost, Global => null;

   procedure Begin_ED_Scan
     (Scan   : out Scan_State;
      Handle : in out AdaBee.MAC.MLME.SAP.Requests.Service_Handle)
   with
     Pre  =>
       Is_Valid_ED_SCAN_Req (Handle)
       and then not SAP.Requests.Confirm_Written (Handle)
       and then PHY.Current_State = Idle,
     Post =>
       (declare
          Old_PHY_State : constant AdaBee.PHY.State_Kind :=
            AdaBee.PHY.Current_State'Old;
        begin
          (if not SAP.Requests.Is_Null (Handle)
           then
             Is_Valid (Scan, Handle)
             and then AdaBee.PHY.Current_State = ED_Scan_Active
           else PHY.Current_State = Old_PHY_State));
   --  Begins a new ED scan for the MLME-SCAN.request given in `Handle`.
   --
   --  The PHY may be in any low-power state. If the PHY is sleeping, then this
   --  procedure powers up the PHY before initiating the scan.

   procedure Cancel_ED_Scan
     (Handle : in out AdaBee.MAC.MLME.SAP.Requests.Service_Handle)
   with
     Always_Terminates => False,
     Pre               =>
       Is_Valid_ED_SCAN_Req_And_Cfm (Handle)
       and then AdaBee.PHY.Current_State = ED_Scan_Active,
     Post              =>
       SAP.Requests.Is_Null (Handle) and then AdaBee.PHY.Current_State = Idle;

   procedure Notify_PHY_Operation_Complete
     (Scan   : in out Scan_State;
      Handle : in out AdaBee.MAC.MLME.SAP.Requests.Service_Handle)
   with
     Always_Terminates => False,
     Pre               =>
       Is_Valid (Scan, Handle)
       and then AdaBee.PHY.Current_State = ED_Scan_Complete,
     Post              =>
       (if not SAP.Requests.Is_Null (Handle)
        then
          AdaBee.PHY.Current_State = ED_Scan_Active
          and then Is_Valid (Scan, Handle)
        else AdaBee.PHY.Current_State = Idle);
   --  Notify the ED scanner that the PHY has emitted the
   --  `Operation_Complete` event.
   --
   --  This saves the ED result for the current channel, then configures the
   --  PHY to start scanning the next channel.
   --
   --  If all channels have been scanned, then the MLME-SCAN.confirm primitive
   --  is set which invalidates `Handle`.

private

   use all type AdaBee.MAC.MLME.SAP.MLME_Request_Kind;
   use all type AdaBee.MAC.MLME.SAP.Scan_Type_Kind;

   use type AdaBee.PHY_Constants.Symbol_Count;

   --------------------------
   -- Is_Valid_ED_SCAN_Req --
   --------------------------

   function Is_Valid_ED_SCAN_Req
     (Request : SAP.MLME_Request_Type) return Boolean
   is (SAP.Valid_Request (Request)
       and then Request.Kind = MLME_SCAN_Req
       and then Request.SCAN.Scan_Type = ED);

   function Is_Valid_ED_SCAN_Req
     (Handle : AdaBee.MAC.MLME.SAP.Requests.Service_Handle) return Boolean
   is (not SAP.Requests.Is_Null (Handle)
       and then
         Is_Valid_ED_SCAN_Req (SAP.Requests.Request_Reference (Handle).all));

   ----------------------------------
   -- Is_Valid_ED_SCAN_Req_And_Cfm --
   ----------------------------------

   function Is_Valid_ED_SCAN_Req_And_Cfm
     (Request : SAP.MLME_Request_Type; Confirm : SAP.MLME_Confirm_Type)
      return Boolean
   is (Is_Valid_ED_SCAN_Req (Request)
       and then SAP.Valid_Confirm (Request, Confirm));

   function Is_Valid_ED_SCAN_Req_And_Cfm
     (Handle : AdaBee.MAC.MLME.SAP.Requests.Service_Handle) return Boolean
   is (not SAP.Requests.Is_Null (Handle)
       and then SAP.Requests.Confirm_Written (Handle)
       and then
         Is_Valid_ED_SCAN_Req_And_Cfm
           (SAP.Requests.Request_Reference (Handle).all,
            SAP.Requests.Confirm_Reference (Handle).all));

   ----------------
   -- Scan_State --
   ----------------

   type Scan_State is record
      Current_Channel : AdaBee.PHY.RF_Channel_Number := 0;
   end record;

   --------------
   -- Is_Valid --
   --------------

   function Is_Valid
     (Scan    : Scan_State;
      Request : SAP.MLME_Request_Type;
      Confirm : SAP.MLME_Confirm_Type) return Boolean
   is (Is_Valid_ED_SCAN_Req_And_Cfm (Request, Confirm)
       and then Request.SCAN.Scan_Duration > 0
       and then Request.SCAN.Scan_Channels (Scan.Current_Channel) = True
       and then AdaBee.PHY.Channel_Supported (Scan.Current_Channel));

   function Is_Valid
     (Scan : Scan_State; Handle : AdaBee.MAC.MLME.SAP.Requests.Service_Handle)
      return Boolean
   is (Is_Valid_ED_SCAN_Req_And_Cfm (Handle)
       and then
         Is_Valid
           (Scan,
            SAP.Requests.Request_Reference (Handle).all,
            SAP.Requests.Confirm_Reference (Handle).all));

end AdaBee.MAC.MLME.ED_Scan;
