--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
procedure AdaBee.MAC.MLME.SAP_Events.Wait_For_Confirm
  (Handle  : in out Req_SAP.Confirm_Handle;
   Promise : in out Req_SAP.Confirm_Promise)
is
begin
   loop
      pragma Loop_Invariant (Req_SAP.Is_Null (Handle));
      pragma Loop_Invariant (not Req_SAP.Is_Null (Promise));

      Req_SAP.Try_Get_Confirm (Handle, Promise);

      exit when not Req_SAP.Is_Null (Handle);

      Monitors (Transaction_ID_Range (Req_SAP.Get_TID (Promise))).Wait;
   end loop;
end AdaBee.MAC.MLME.SAP_Events.Wait_For_Confirm;
