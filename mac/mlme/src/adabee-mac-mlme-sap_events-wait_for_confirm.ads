--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.MAC.MLME.Req_SAP; use AdaBee.MAC.MLME.Req_SAP;

procedure AdaBee.MAC.MLME.SAP_Events.Wait_For_Confirm
  (Handle  : in out Req_SAP.Confirm_Handle;
   Promise : in out Req_SAP.Confirm_Promise)
with
  Always_Terminates => False,
  Global            => (In_Out => Confirm_Monitors),
  Pre               =>
    not Req_SAP.Is_Null (Promise) and then Req_SAP.Is_Null (Handle),
  Post              =>
    not Req_SAP.Is_Null (Handle)
    and Req_SAP.Is_Null (Promise)
    and (Req_SAP.Get_TID (Handle) = Req_SAP.Get_TID (Promise)'Old)
    and (Req_SAP.Request_Kind (Handle) = Req_SAP.Request_Kind (Promise)'Old)
    and
      Valid_Confirm
        (Req_SAP.Request_Reference (Handle).all,
         Req_SAP.Confirm_Reference (Handle).all);
--  Block until the confirm for the given `Promise` has been posted.
--
--  This can be used to put the calling task to sleep until a specific Confirm
--  primitive has been posted by the MLME-SAP.
