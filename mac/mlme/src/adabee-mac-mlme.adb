--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.MLME.PIB;

pragma Unreferenced (AdaBee.MAC.MLME.PIB);

package body AdaBee.MAC.MLME
  with
    SPARK_Mode,
    Refined_State => (PIB_Attributes_Data => AdaBee.MAC.MLME.PIB.DB)
is

   procedure Dummy is null;

end AdaBee.MAC.MLME;
