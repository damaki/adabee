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
  with
    SPARK_Mode,
    Always_Terminates,
    Abstract_State => PIB_Attributes_Data,
    Initializes    => PIB_Attributes_Data
is

private

   procedure Dummy;
   --  A dummy procedure to allow this package to have a body so that the
   --  Refined_State can be specified for PIB_Attributes_Data.
   --
   --  Usually, using Elaborate_Body would allow this package to have a body,
   --  but that introduces an elaboration circularity between this package and
   --  AdaBee.MAC.MLME.PIB. So this dummy procedure is used as a workaround.

end AdaBee.MAC.MLME;
