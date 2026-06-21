--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

procedure AdaBee.MAC.MCPS.SAP.MCPS_PURGE
  (Request : MCPS_PURGE_Request_Type; Status : out Status_Code)
with SPARK_Mode, Always_Terminates => False;
--  Write a MAC PIB attribute.
--
--  This uses the MCPS-PURGE service to send an MCPS-PURGE.request, then waits
--  for the response (MCPS-PURGE.confirm).
--
--  If there is no capacity to send the request to the MCPS-SAP, then Status is
--  set to Transaction_Overflow.
