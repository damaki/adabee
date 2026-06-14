--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

procedure AdaBee.MAC.MLME.MLME_GET
  (Request : MLME_GET_Req_Type; Confirm : out MLME_GET_Cfm_Type)
with
  SPARK_Mode,
  Always_Terminates => False,
  Pre               =>
    not Confirm'Constrained
    and then Confirm.PIB_Attribute = Request.PIB_Attribute,
  Post              => Confirm.PIB_Attribute = Request.PIB_Attribute;
--  Read a MAC PIB attribute.
--
--  This uses the MLME-GET service to send an MLME-GET.request, then waits
--  for the response (MLME-GET.confirm).
--
--  If there is no capacity to send the request to the MLME-SAP, then
--  Confirm.Status is set to Transaction_Overflow.
