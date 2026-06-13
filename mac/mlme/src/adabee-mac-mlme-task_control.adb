--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.MAC.MLME.MLME_FSM;
with AdaBee.MAC.MLME.Req_SAP;
with AdaBee.MAC.MLME.PIB;

package body AdaBee.MAC.MLME.Task_Control
  with SPARK_Mode
is

   --------------------
   -- Poke_MLME_Task --
   --------------------

   procedure Poke_MLME_Task is
   begin
      AdaBee.PHY.Send_User_Event;
   end Poke_MLME_Task;

   ---------------
   -- MLME_Task --
   ---------------

   --  The MLME task is responsible for driving the MLME state machines by
   --  waiting for and dispatching events to the appropriate entities.
   --
   --  Events are either:
   --    * A new request or response is received via the MLME-SAP; or
   --    * A PHY event was generated.
   --
   --  Note that the MLME-SAP event is signalled via the `User_Event` event
   --  flag in the PHY.

   task body MLME_Task is
      use all type AdaBee.PHY.State_Kind;
      use all type AdaBee.PHY.Event_Kind;

      MLME_Machine : MLME_FSM.Machine;
      PHY_Events   : AdaBee.PHY.Event_Flags_Array;
      Handle       : AdaBee.MAC.MLME.Req_SAP.Service_Handle;

      Is_Operation_Complete_Event_Set : Boolean;

   begin
      --  Ensure that the PHY is off.
      --
      --  The initial condition of AdaBee.PHY states that the PHY is off,
      --  but there's no way to prove that on entry to this task. We instead
      --  ensure that the PHY is turned off for whatever state it starts in.

      case AdaBee.PHY.Current_State is
         when Off               =>
            null;

         when Sleeping          =>
            AdaBee.PHY.Turn_Off;

         when Exiting_Sleep     =>
            AdaBee.PHY.Wait_For_Event (AdaBee.PHY.Operation_Complete);
            AdaBee.PHY.Enter_Sleep;
            AdaBee.PHY.Turn_Off;

         when Idle              =>
            AdaBee.PHY.Enter_Sleep;
            AdaBee.PHY.Turn_Off;

         when Transmitting
            | Tx_Complete
            | Receiving
            | Rx_Complete
            | ED_Scan_Active
            | ED_Scan_Complete
            | CCA_Scan_Active
            | CCA_Scan_Complete =>
            AdaBee.PHY.Go_Idle;
            AdaBee.PHY.Enter_Sleep;
            AdaBee.PHY.Turn_Off;
      end case;

      --  Process PHY events and SAP requests

      loop
         pragma
           Loop_Invariant (MLME_FSM.Valid_PHY_Active_State (MLME_Machine));

         pragma Loop_Invariant (Req_SAP.Is_Null (Handle));

         --  Block until an event is signalled

         AdaBee.PHY.Wait_For_Events (PHY_Events);

         --  Keep processing events until there is nothing left to do

         loop
            pragma
              Loop_Invariant
                (if PHY_Events (Operation_Complete)
                 then
                   MLME_FSM.Valid_PHY_Operation_Complete_State (MLME_Machine)
                 else MLME_FSM.Valid_PHY_Active_State (MLME_Machine));

            pragma Loop_Invariant (Req_SAP.Is_Null (Handle));

            --  The Operation_Complete event is the highest priority and takes
            --  precedence over anything else to ensure that critical on-air
            --  activities (e.g. ack transmission) are performed within their
            --  deadlines.

            if PHY_Events (Operation_Complete) then
               PHY_Events (Operation_Complete) := False;
               MLME_FSM.Notify_PHY_Operation_Complete (MLME_Machine);

            else

               --  Operation_Complete in PHY_Events is set only during the
               --  first loop iteration. For subsequent iterations, we poll
               --  the Operation_Complete flag manually to avoid blocking.

               Is_Operation_Complete_Event_Set :=
                 AdaBee.PHY.Is_Event_Set (Operation_Complete);

               if Is_Operation_Complete_Event_Set then
                  AdaBee.PHY.Wait_For_Event (Operation_Complete);
                  MLME_FSM.Notify_PHY_Operation_Complete (MLME_Machine);

               else

                  --  Process one MLME-SAP request

                  PHY_Events (User_Event) := False;

                  Req_SAP.Try_Get_Next_Request (Handle);

                  if not Req_SAP.Is_Null (Handle) then
                     case Req_SAP.Request_Reference (Handle).Kind is
                        when MLME_SCAN_Req =>
                           AdaBee.MAC.MLME.MLME_FSM.Notify_SCAN_Req
                             (MLME_Machine, Handle);

                        when MLME_SET_Req  =>
                           AdaBee.MAC.MLME.PIB.SET_Request (Handle);

                        when MLME_GET_Req  =>
                           AdaBee.MAC.MLME.PIB.GET_Request (Handle);
                     end case;
                  else
                     exit;
                  end if;
               end if;
            end if;
         end loop;
      end loop;
   end MLME_Task;

end AdaBee.MAC.MLME.Task_Control;
