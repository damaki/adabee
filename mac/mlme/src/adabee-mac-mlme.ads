--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
pragma Profile (Jorvik);
pragma Partition_Elaboration_Policy (Sequential);

--  This is the root package for the MAC Layer Management Entity (MLME).
--
--  The MLME provides the service interfaces to the next higher layer, and
--  interfaces with the PHY to realize those services. The MLME services can be
--  invoked via the MLME-SAP. The MLME-SAP interface is based on Service
--  Primitives (request, confirm, indication, and response primitives) as
--  defined in IEEE 802.15.4-2024. Services can be invoked by sending a
--  request to the MLME-SAP, defined in package `AdaBee.MAC.MLME.SAP.Requests`.

package AdaBee.MAC.MLME
  with Pure, SPARK_Mode, Always_Terminates
is

end AdaBee.MAC.MLME;
