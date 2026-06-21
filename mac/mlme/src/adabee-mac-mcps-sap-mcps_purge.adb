--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.MCPS.SAP.Requests;
with AdaBee.MAC.MCPS.SAP.Wait_For_Confirm;

procedure AdaBee.MAC.MCPS.SAP.MCPS_PURGE
  (Request : MCPS_PURGE_Request_Type; Status : out Status_Code)
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
         function Is_PURGE_Req
           (MCPS_Request : MCPS_Request_Type) return Boolean
         is (MCPS_Request.Kind = MCPS_PURGE_Req
             and then MCPS_Request.PURGE = Request);

         procedure Build_PURGE_Req (MCPS_Request : out MCPS_Request_Type)
         with
           Pre  => not MCPS_Request'Constrained,
           Post => Is_PURGE_Req (MCPS_Request)
         is
         begin
            MCPS_Request := (Kind => MCPS_PURGE_Req, PURGE => Request);
         end Build_PURGE_Req;

         procedure Build_PURGE_Req is new
           Requests.Initialize_Request
             (Initialize    => Build_PURGE_Req,
              Postcondition => Is_PURGE_Req);

      begin
         Build_PURGE_Req (Req_Handle);
         Requests.Send_Request (Req_Handle, Cfm_Promise);
         AdaBee.MAC.MCPS.SAP.Wait_For_Confirm (Cfm_Handle, Cfm_Promise);
         Status := Requests.Confirm_Reference (Cfm_Handle).all.PURGE.Status;
         Requests.Release (Cfm_Handle);
      end;
   end if;

   pragma Unreferenced (Req_Handle);
   pragma Unreferenced (Cfm_Promise);
   pragma Unreferenced (Cfm_Handle);
end AdaBee.MAC.MCPS.SAP.MCPS_PURGE;
