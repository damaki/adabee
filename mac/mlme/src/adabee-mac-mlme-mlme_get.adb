--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.MLME.Req_SAP;
with AdaBee.MAC.MLME.SAP_Events.Wait_For_Confirm;

procedure AdaBee.MAC.MLME.MLME_GET
  (Request : MLME_GET_Req_Type; Confirm : out MLME_GET_Cfm_Type)
with SPARK_Mode
is
   Req_Handle  : Req_SAP.Request_Handle;
   Cfm_Promise : Req_SAP.Confirm_Promise;
   Cfm_Handle  : Req_SAP.Confirm_Handle;
begin

   Req_SAP.Try_Allocate_Request (Req_Handle);

   if Req_SAP.Is_Null (Req_Handle) then
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
           Req_SAP.Initialize_Request
             (Initialize    => Build_GET_Req,
              Postcondition => Is_GET_Req);

      begin
         Build_GET_Req (Req_Handle);
         Req_SAP.Send_Request (Req_Handle, Cfm_Promise);
         AdaBee.MAC.MLME.SAP_Events.Wait_For_Confirm (Cfm_Handle, Cfm_Promise);
         Confirm := Req_SAP.Confirm_Reference (Cfm_Handle).all.GET;
      end;
   end if;

   pragma Unreferenced (Req_Handle);
   pragma Unreferenced (Cfm_Promise);
   pragma Unreferenced (Cfm_Handle);
end AdaBee.MAC.MLME.MLME_GET;
