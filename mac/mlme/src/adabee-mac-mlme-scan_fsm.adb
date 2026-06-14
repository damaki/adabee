--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.MLME.Scan_FSM
  with SPARK_Mode
is

   procedure Reject_SCAN_Req
     (Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle;
      Reason : Status_Code)
   with
     Pre  =>
       Is_SCAN_Req (Handle)
       and then not Req_SAP.Confirm_Written (Handle)
       and then Reason /= Success,
     Post => Req_SAP.Is_Null (Handle);

   ---------------------
   -- Notify_SCAN_Req --
   ---------------------

   procedure Notify_SCAN_Req
     (FSM    : in out Machine;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   is

      function Is_Supported_SCAN_Req
        (Request : MLME_Request_Type) return Boolean
      is (Request.Kind = MLME_SCAN_Req
          and then Request.SCAN.Scan_Type in Supported_Scan_Types);

      procedure Move_Handle is new
        Req_SAP.Move_Service_Handle_With_Property
          (Request_Property => Is_Supported_SCAN_Req);

   begin

      --  This implementation cannot handle more than one MLME-SCAN.request
      --  at a time.

      if Current_State (FSM) /= Idle then
         Reject_SCAN_Req (Handle, Transaction_Overflow);

      elsif Req_SAP.Request_Reference (Handle).all.SCAN.Scan_Type
            not in Supported_Scan_Types
      then
         Reject_SCAN_Req (Handle, Unsupported_Feature);

      else
         FSM.Pending := True;
         Move_Handle (Target => FSM.Handle, Source => Handle);
      end if;
   end Notify_SCAN_Req;

   ----------------
   -- Begin_Scan --
   ----------------

   procedure Begin_Scan (FSM : in out Machine) is
   begin
      FSM.Pending := False;
      ED_Scan.Begin_ED_Scan (FSM.ED_Scan, FSM.Handle);
   end Begin_Scan;

   -----------------------------------
   -- Notify_PHY_Operation_Complete --
   -----------------------------------

   procedure Notify_PHY_Operation_Complete (FSM : in out Machine) is
   begin
      AdaBee.MAC.MLME.ED_Scan.Notify_PHY_Operation_Complete
        (FSM.ED_Scan, FSM.Handle);
   end Notify_PHY_Operation_Complete;

   ---------------------
   -- Reject_SCAN_Req --
   ---------------------

   procedure Reject_SCAN_Req
     (Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle;
      Reason : Status_Code)
   is
      procedure Write_SCAN_Cfm
        (Request : MLME_Request_Type; Confirm : out MLME_Confirm_Type)
      with
        Pre  => Is_SCAN_Req (Request) and then not Confirm'Constrained,
        Post => Valid_Confirm (Request, Confirm);

      --------------------
      -- Write_SCAN_Cfm --
      --------------------

      procedure Write_SCAN_Cfm
        (Request : MLME_Request_Type; Confirm : out MLME_Confirm_Type) is
      begin
         case Request.SCAN.Scan_Type is
            when ED              =>
               Confirm :=
                 (Kind => MLME_SCAN_Cfm,
                  SCAN =>
                    (Scan_Type          => ED,
                     Status             => Reason,
                     Energy_Detect_List => [others => 0]));

            when Active          =>
               Confirm :=
                 (Kind => MLME_SCAN_Cfm,
                  SCAN =>
                    (Scan_Type           => Active,
                     Status              => Reason,
                     Unscanned_Channels  => Request.SCAN.Scan_Channels,
                     PAN_Descriptor_List => [others => <>],
                     Nb_PAN_Descriptors  => 0));

            when Passive         =>
               Confirm :=
                 (Kind => MLME_SCAN_Cfm,
                  SCAN =>
                    (Scan_Type           => Passive,
                     Status              => Reason,
                     Unscanned_Channels  => Request.SCAN.Scan_Channels,
                     PAN_Descriptor_List => [others => <>],
                     Nb_PAN_Descriptors  => 0));

            when Enhanced_Active =>
               Confirm :=
                 (Kind => MLME_SCAN_Cfm,
                  SCAN =>
                    (Scan_Type           => Enhanced_Active,
                     Status              => Reason,
                     Unscanned_Channels  => Request.SCAN.Scan_Channels,
                     PAN_Descriptor_List => [others => <>],
                     Nb_PAN_Descriptors  => 0));

            when Orphan          =>
               Confirm :=
                 (Kind => MLME_SCAN_Cfm,
                  SCAN =>
                    (Scan_Type          => Orphan,
                     Status             => Reason,
                     Unscanned_Channels => Request.SCAN.Scan_Channels));
         end case;
      end Write_SCAN_Cfm;

      procedure Write_SCAN_Cfm is new
        Req_SAP.Initialize_Confirm
          (Initialize    => Write_SCAN_Cfm,
           Precondition  => Is_SCAN_Req,
           Postcondition => Valid_Confirm);

   begin
      Write_SCAN_Cfm (Handle);
      Req_SAP.Send_Confirm (Handle);
   end Reject_SCAN_Req;

end AdaBee.MAC.MLME.Scan_FSM;
