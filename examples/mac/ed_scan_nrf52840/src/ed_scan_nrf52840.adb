--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
pragma SPARK_Mode (On);

with Ada.Text_IO;
with System;

with AdaBee.PHY;
with AdaBee.MAC.MLME;
with AdaBee.MAC.MLME.SAP.Requests;
with AdaBee.MAC.MLME.SAP.Wait_For_Confirm;

--  This example demonstrates an Energy Detection (ED) scan on the nRF52840
--  using the MLME-SCAN service.
--
--  The program performs the following sequence in a loop:
--   1. Allocate a new transaction from the MLME-SAP.
--   2. Write an MLME-SCAN.request primitive and send it to the MLME-SAP.
--   3. Wait for the response from the MLME
--   4. Print the contents of the MLME-SCAN.confirm primitive via Ada.Text_IO

procedure ED_Scan_nRF52840 with Priority => System.Priority'First is
   use all type AdaBee.MAC.MLME.SAP.MLME_Request_Kind;
   use all type AdaBee.MAC.MLME.SAP.Scan_Type_Kind;

   package MLME_SAP renames AdaBee.MAC.MLME.SAP.Requests;

   function Is_ED_Scan_Req
     (Request : AdaBee.MAC.MLME.SAP.MLME_Request_Type) return Boolean
   is (Request.Kind = MLME_SCAN_Req and then Request.SCAN.Scan_Type = ED);

   Req_Handle  : MLME_SAP.Request_Handle;
   Cfm_Promise : MLME_SAP.Confirm_Promise;
   Cfm_Handle  : MLME_SAP.Confirm_Handle;

begin

   loop
      pragma Loop_Invariant (MLME_SAP.Is_Null (Req_Handle));
      pragma Loop_Invariant (MLME_SAP.Is_Null (Cfm_Promise));
      pragma Loop_Invariant (MLME_SAP.Is_Null (Cfm_Handle));

      --  Allocate a new request

      Ada.Text_IO.Put_Line ("Allocating an MLME-SAP transaction");

      MLME_SAP.Try_Allocate_Request (Req_Handle);

      if MLME_SAP.Is_Null (Req_Handle) then
         Ada.Text_IO.Put_Line ("Failed to allocate transaction");

      else
         --  Build and send an MLME-SCAN.request primitive

         declare
            procedure Build_MLME_SCAN_Req
              (Request : out AdaBee.MAC.MLME.SAP.MLME_Request_Type)
            with
              Pre  => not Request'Constrained,
              Post => Is_ED_Scan_Req (Request)
            is
            begin
               Request :=
                 (Kind => MLME_SCAN_Req,
                  SCAN =>
                    (Scan_Type          => ED,
                     Scan_Channels      => [11 .. 26 => True, others => False],
                     Scan_Duration      => 31_250,
                     --  31.25 ksym = 0.5 seconds per channel
                     Link_Quality_Scan  => True,
                     PAN_ID_Suppressed  => True,
                     Seq_Num_Suppressed => True));
            end Build_MLME_SCAN_Req;

            procedure Build_Request is new
              MLME_SAP.Initialize_Request
                (Initialize    => Build_MLME_SCAN_Req,
                 Postcondition => Is_ED_Scan_Req);
         begin
            Build_Request (Req_Handle);
            MLME_SAP.Send_Request (Req_Handle, Cfm_Promise);
         end;

         Ada.Text_IO.Put_Line ("Sent MLME-SAP.request");
         Ada.Text_IO.Put_Line ("Waiting for MLME-SAP.confirm...");

         AdaBee.MAC.MLME.SAP.Wait_For_Confirm (Cfm_Handle, Cfm_Promise);

         --  Read and print the MLME-SCAN.confirm results

         declare
            SCAN_Req :
              constant not null access constant
                AdaBee.MAC.MLME.SAP.MLME_Request_Type :=
                MLME_SAP.Request_Reference (Cfm_Handle);

            SCAN_Cfm :
              constant not null access constant
                AdaBee.MAC.MLME.SAP.MLME_Confirm_Type :=
                MLME_SAP.Confirm_Reference (Cfm_Handle);
         begin
            Ada.Text_IO.Put_Line ("Received MLME-SCAN.confirm:");

            Ada.Text_IO.Put ("    Scan_Type: ");
            Ada.Text_IO.Put_Line (SCAN_Cfm.all.SCAN.Scan_Type'Image);

            Ada.Text_IO.Put ("    Status:    ");
            Ada.Text_IO.Put_Line (SCAN_Cfm.all.SCAN.Status'Image);

            Ada.Text_IO.Put_Line ("    Energy_Detect_List: ");

            for Ch in AdaBee.PHY.RF_Channel_Number loop
               if SCAN_Req.all.SCAN.Scan_Channels (Ch) then
                  Ada.Text_IO.Put ("       ");
                  Ada.Text_IO.Put (Ch'Image);
                  Ada.Text_IO.Put (" =>");
                  Ada.Text_IO.Put_Line
                    (SCAN_Cfm.all.SCAN.Energy_Detect_List (Ch)'Image);
               end if;
            end loop;
         end;

         --  Complete the MLME-SAP transaction

         MLME_SAP.Release (Cfm_Handle);
      end if;
   end loop;

end ED_Scan_nRF52840;
