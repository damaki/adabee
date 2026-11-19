--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.MLME.PIB;
with AdaBee.MAC.MLME.Metrics;

pragma Unreferenced (AdaBee.MAC.MLME.PIB);
pragma Unreferenced (AdaBee.MAC.MLME.Metrics);

package body AdaBee.MAC.MLME
  with
    SPARK_Mode,
    Refined_State =>
      (PIB_Attributes_Data => AdaBee.MAC.MLME.PIB.DB,
       MAC_Metrics         =>
         (AdaBee.MAC.MLME.Metrics.MAC_Retry_Count,
          AdaBee.MAC.MLME.Metrics.MAC_Multiple_Retry_Count,
          AdaBee.MAC.MLME.Metrics.MAC_Tx_Fail_Count,
          AdaBee.MAC.MLME.Metrics.MAC_Security_Failure,
          AdaBee.MAC.MLME.Metrics.MAC_Duplicate_Frame_Count,
          AdaBee.MAC.MLME.Metrics.MAC_Rx_Success_Count,
          AdaBee.MAC.MLME.Metrics.MAC_Nack_Count))
is

   procedure Dummy is null;

end AdaBee.MAC.MLME;
