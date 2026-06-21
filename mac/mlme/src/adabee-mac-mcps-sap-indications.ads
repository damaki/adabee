--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
pragma SPARK_Mode (On);

with System;

with LibSAP.Synchronous_User_Service_Access_Point;

with Adabee_Mlme_Config;

package AdaBee.MAC.MCPS.SAP.Indications is new
  LibSAP.Synchronous_User_Service_Access_Point
    (Indication_Kind_Type        => MCPS_Indication_Kind,
     Indication_Type             => MCPS_Indication_Type,
     Response_Type               => MCPS_Response_Type,
     Queue_Capacity              =>
       Adabee_Mlme_Config.MCPS_Indication_Queue_Capacity,
     Indication_Kind             => Indication_Kind,
     Requires_Response           => Requires_Response,
     Indication_Requires_Cleanup => Indication_Requires_Cleanup,
     Response_Requires_Cleanup   => Response_Requires_Cleanup,
     Might_Require_Cleanup       => Indication_Kind_Requires_Cleanup,
     Valid_Indication            => Valid_Indication,
     Valid_Response              => Valid_Response,
     Priority                    => System.Priority'Last);
