--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with Adabee_Mlme_Config;

--  This package instantiates the MAC metric counters as defined in
--  Table 10-128 of IEEE 802.15.4-2024.
--
--  Note that macFcsErrorCount is not managed here since FCS checking is
--  performed automatically by the PHY driver.

private package AdaBee.MAC.MLME.Metrics
  with SPARK_Mode, Always_Terminates
is

   --  Note that macFcsErrorCount is not implemented here, as the PHY performs
   --  FCS checking in hardware and maintains its own CRC error counter.

   Metric_Counter_Bits : constant := 8 * Adabee_Mlme_Config.MAC_Counter_Octets;

   type Metric_Counter is mod 2 ** Metric_Counter_Bits
   with Size => Metric_Counter_Bits;

   MAC_Retry_Count : Metric_Counter := 0
   with Part_Of => MAC_Metrics;
   --  macRetryCount

   MAC_Multiple_Retry_Count : Metric_Counter := 0
   with Part_Of => MAC_Metrics;
   --  macMultipleRetryCount

   MAC_Tx_Fail_Count : Metric_Counter := 0
   with Part_Of => MAC_Metrics;
   --  macTxFailCount

   MAC_Security_Failure : Metric_Counter := 0
   with Part_Of => MAC_Metrics;
   --  macSecurityFailure

   MAC_Duplicate_Frame_Count : Metric_Counter := 0
   with Part_Of => MAC_Metrics;
   --  macDuplicateFrameCount

   MAC_Rx_Success_Count : Metric_Counter := 0
   with Part_Of => MAC_Metrics;
   --  macRxSuccessCount

   MAC_Nack_Count : Metric_Counter := 0
   with Part_Of => MAC_Metrics;
   --  macNackCount

end AdaBee.MAC.MLME.Metrics;
