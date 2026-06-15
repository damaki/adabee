--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.MAC.MLME.SAP.Requests; use AdaBee.MAC.MLME.SAP.Requests;

procedure AdaBee.MAC.MLME.SAP.Wait_For_Confirm
  (Handle  : in out Requests.Confirm_Handle;
   Promise : in out Requests.Confirm_Promise)
with
  Always_Terminates => False,
  Global            => (In_Out => Confirm_Monitors),
  Pre               =>
    not Requests.Is_Null (Promise) and then Requests.Is_Null (Handle),
  Post              =>
    not Requests.Is_Null (Handle)
    and Requests.Is_Null (Promise)
    and (Requests.Get_TID (Handle) = Requests.Get_TID (Promise)'Old)
    and (Requests.Request_Kind (Handle) = Requests.Request_Kind (Promise)'Old)
    and
      Valid_Confirm
        (Requests.Request_Reference (Handle).all,
         Requests.Confirm_Reference (Handle).all);
--  Block until the confirm for the given `Promise` has been posted.
--
--  This can be used to put the calling task to sleep until a specific confirm
--  primitive has been posted by the MLME-SAP.
