--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

procedure AdaBee.MAC.MLME.MLME_SET
  (Request : MLME_SET_Req_Type; Status : out Status_Code)
with SPARK_Mode, Always_Terminates => False;
--  Write a MAC PIB attribute.
--
--  This uses the MLME-SET service to send an MLME-SET.request, then waits
--  for the response (MLME-SET.confirm).
--
--  If there is no capacity to send the request to the MLME-SAP, then Status is
--  set to Transaction_Overflow.
