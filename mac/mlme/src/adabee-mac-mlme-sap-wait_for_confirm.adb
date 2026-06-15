--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
procedure AdaBee.MAC.MLME.SAP.Wait_For_Confirm
  (Handle  : in out Requests.Confirm_Handle;
   Promise : in out Requests.Confirm_Promise)
is
begin
   loop
      pragma Loop_Invariant (Requests.Is_Null (Handle));
      pragma Loop_Invariant (not Requests.Is_Null (Promise));

      Requests.Try_Get_Confirm (Handle, Promise);

      exit when not Requests.Is_Null (Handle);

      Monitors (Transaction_ID_Range (Requests.Get_TID (Promise))).Wait;
   end loop;
end AdaBee.MAC.MLME.SAP.Wait_For_Confirm;
