--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.MLME.SAP.Requests;
with AdaBee.MAC.MLME.SAP.Wait_For_Confirm;

procedure AdaBee.MAC.MLME.SAP.MLME_GET
  (Request : MLME_GET_Req_Type; Confirm : out MLME_GET_Cfm_Type)
with SPARK_Mode
is
   Req_Handle  : Requests.Request_Handle;
   Cfm_Promise : Requests.Confirm_Promise;
   Cfm_Handle  : Requests.Confirm_Handle;
begin

   Requests.Try_Allocate_Request (Req_Handle);

   if Requests.Is_Null (Req_Handle) then
      Confirm :=
        (PIB_Attribute => Confirm.PIB_Attribute,
         Status        => Transaction_Overflow);

   else
      declare
         function Is_GET_Req (MLME_Request : MLME_Request_Type) return Boolean
         is (MLME_Request.Kind = MLME_GET_Req
             and then MLME_Request.GET = Request);

         procedure Build_GET_Req (MLME_Request : out MLME_Request_Type)
         with
           Pre  => not MLME_Request'Constrained,
           Post => Is_GET_Req (MLME_Request)
         is
         begin
            MLME_Request := (Kind => MLME_GET_Req, GET => Request);
         end Build_GET_Req;

         procedure Build_GET_Req is new
           Requests.Initialize_Request
             (Initialize    => Build_GET_Req,
              Postcondition => Is_GET_Req);

      begin
         Build_GET_Req (Req_Handle);
         Requests.Send_Request (Req_Handle, Cfm_Promise);
         AdaBee.MAC.MLME.SAP.Wait_For_Confirm (Cfm_Handle, Cfm_Promise);
         Confirm := Requests.Confirm_Reference (Cfm_Handle).all.GET;
         Requests.Release (Cfm_Handle);
      end;
   end if;

   pragma Unreferenced (Req_Handle);
   pragma Unreferenced (Cfm_Promise);
   pragma Unreferenced (Cfm_Handle);
end AdaBee.MAC.MLME.SAP.MLME_GET;
