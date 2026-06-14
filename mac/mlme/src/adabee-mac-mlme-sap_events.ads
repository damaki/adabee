--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Adabee_Mlme_Config;

private with System;

package AdaBee.MAC.MLME.SAP_Events
  with
    Elaborate_Body,
    SPARK_Mode,
    Abstract_State =>
      (Confirm_Monitors with
        Synchronous,
        External =>
          (Async_Writers, Effective_Reads, Async_Readers, Effective_Writes)),
    Initializes    => Confirm_Monitors
is

   subtype Transaction_ID_Range is
     Positive range 1 .. Adabee_Mlme_Config.MLME_Request_Queue_Capacity;

   procedure Notify_Confirm_Pending (TID : Transaction_ID_Range)
   with Global => (In_Out => Confirm_Monitors);

private

   protected type Monitor with Priority => System.Priority'Last is
      entry Wait;
      procedure Notify;
      procedure Clear;
   private
      Signalled : Boolean := False;
   end Monitor;

   type Monitor_Array is array (Transaction_ID_Range) of Monitor;

   Monitors : Monitor_Array
   with Part_Of => Confirm_Monitors;

end AdaBee.MAC.MLME.SAP_Events;
