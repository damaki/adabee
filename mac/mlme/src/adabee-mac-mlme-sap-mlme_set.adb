--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.MLME.SAP.Requests;
with AdaBee.MAC.MLME.SAP.Wait_For_Confirm;

procedure AdaBee.MAC.MLME.SAP.MLME_SET
  (Request : MLME_SET_Req_Type; Status : out Status_Code)
with SPARK_Mode
is
   Req_Handle  : Requests.Request_Handle;
   Cfm_Promise : Requests.Confirm_Promise;
   Cfm_Handle  : Requests.Confirm_Handle;
begin

   Requests.Try_Allocate_Request (Req_Handle);

   if Requests.Is_Null (Req_Handle) then
      Status := Transaction_Overflow;

   else
      declare
         function Is_SET_Req (MLME_Request : MLME_Request_Type) return Boolean
         is (MLME_Request.Kind = MLME_SET_Req
             and then MLME_Request.SET = Request);

         procedure Build_SET_Req (MLME_Request : out MLME_Request_Type)
         with
           Pre  => not MLME_Request'Constrained,
           Post => Is_SET_Req (MLME_Request)
         is
         begin
            MLME_Request := (Kind => MLME_SET_Req, SET => Request);
         end Build_SET_Req;

         procedure Build_SET_Req is new
           Requests.Initialize_Request
             (Initialize    => Build_SET_Req,
              Postcondition => Is_SET_Req);

      begin
         Build_SET_Req (Req_Handle);
         Requests.Send_Request (Req_Handle, Cfm_Promise);
         AdaBee.MAC.MLME.SAP.Wait_For_Confirm (Cfm_Handle, Cfm_Promise);
         Status := Requests.Confirm_Reference (Cfm_Handle).all.SET.Status;
         Requests.Release (Cfm_Handle);
      end;
   end if;

   pragma Unreferenced (Req_Handle);
   pragma Unreferenced (Cfm_Promise);
   pragma Unreferenced (Cfm_Handle);
end AdaBee.MAC.MLME.SAP.MLME_SET;
