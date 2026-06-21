--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
package body AdaBee.MAC.MCPS.SAP
  with SPARK_Mode, Refined_State => (Confirm_Monitors => Monitors)
is

   ----------------------------
   -- Notify_Confirm_Pending --
   ----------------------------

   procedure Notify_Confirm_Pending (TID : Transaction_ID_Range) is
   begin
      Monitors (TID).Notify;
   end Notify_Confirm_Pending;

   -------------
   -- Monitor --
   -------------

   protected body Monitor is

      ----------
      -- Wait --
      ----------

      entry Wait when Signalled is
      begin
         Signalled := False;
      end Wait;

      ------------
      -- Notify --
      ------------

      procedure Notify is
      begin
         Signalled := True;
      end Notify;

      -----------
      -- Clear --
      -----------

      procedure Clear is
      begin
         Signalled := False;
      end Clear;

   end Monitor;

end AdaBee.MAC.MCPS.SAP;
