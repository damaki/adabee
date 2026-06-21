--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
pragma Profile (Jorvik);
pragma Partition_Elaboration_Policy (Sequential);

--  This package is the root package for the MAC Common Part Sublayer (MCPS).
--
--  The MCPS provides the service interfaces to the next higher layer, and
--  interfaces with the PHY to realize those services. The MCPS services can be
--  invoked via the MCPS-SAP. The MCPS-SAP interface is based on Service
--  Primitives (request, confirm, indication, and response primitives) as
--  defined in IEEE 802.15.4-2024. Services can be invoked by sending a
--  request to the MCPS-SAP, defined in package `AdaBee.MAC.MCPS.SAP.Requests`.
--
--  The MCPS-SAP also sends notifications of received packets via
--  MCPS-DATA.indication primitives, which can be read via the package
--  `AdaBee.MAC.MCPS.SAP.Indications`.

package AdaBee.MAC.MCPS
  with Pure, SPARK_Mode, Always_Terminates
is

end AdaBee.MAC.MCPS;
