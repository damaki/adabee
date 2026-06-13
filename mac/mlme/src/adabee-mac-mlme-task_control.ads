--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
pragma Profile (Jorvik);
pragma Partition_Elaboration_Policy (Sequential);

with System;
with AdaBee.PHY;

--  This package implements the main MLME task

package AdaBee.MAC.MLME.Task_Control
  with SPARK_Mode, Always_Terminates
is

   procedure Poke_MLME_Task
   with Global => (In_Out => AdaBee.PHY.Radio_Events);
   --  Notify the MLME task that a new request primitive is pending

private

   task MLME_Task
     with Priority => System.Priority'Last;

end AdaBee.MAC.MLME.Task_Control;
