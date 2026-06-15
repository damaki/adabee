--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
pragma SPARK_Mode (On);

with System;

with LibSAP.Synchronous_Provider_Service_Access_Point;

with AdaBee.MAC.MLME.Task_Control;
with Adabee_Mlme_Config;

package AdaBee.MAC.MLME.SAP.Requests is new
  LibSAP.Synchronous_Provider_Service_Access_Point
    (Request_Kind_Type        => MLME_Compound_Request_Kind,
     Request_Type             => MLME_Request_Type,
     Confirm_Type             => MLME_Confirm_Type,
     Queue_Capacity           =>
       Adabee_Mlme_Config.MLME_Request_Queue_Capacity,
     Request_Kind             => Request_Kind,
     Requires_Confirm         => Requires_Confirm,
     Request_Requires_Cleanup => Request_Requires_Cleanup,
     Confirm_Requires_Cleanup => Confirm_Requires_Cleanup,
     Might_Require_Cleanup    => Request_Kind_Requires_Cleanup,
     Valid_Request            => Valid_Request,
     Valid_Confirm            => Valid_Confirm,
     Notify_Request_Pending   => AdaBee.MAC.MLME.Task_Control.Poke_MLME_Task,
     Notify_Confirm_Pending   => Notify_Confirm_Pending,
     Priority                 => System.Priority'Last);
