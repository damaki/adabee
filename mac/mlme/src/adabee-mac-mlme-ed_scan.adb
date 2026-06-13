--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.MLME.ED_Scan
  with SPARK_Mode
is

   procedure Initialize_ED_SCAN_Cfm
     (Request : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   with
     Inline,
     Pre  =>
       Is_Valid_ED_SCAN_Req (Request)
       and then not Req_SAP.Confirm_Written (Request),
     Post =>
       not Req_SAP.Is_Null (Request)
       and then Is_Valid_ED_SCAN_Req_And_Cfm (Request)
       and then Req_SAP.Confirm_Reference (Request).all.SCAN.Status = Success;
   --  Writes an initial MLME-SCAN.confirm primitive to the `Request` handle

   procedure Save_ED_Scan_Result
     (Scan   : Scan_State;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   with
     Inline,
     Pre  =>
       Is_Valid (Scan, Handle)
       and then AdaBee.PHY.Current_State = ED_Scan_Complete,
     Post =>
       Is_Valid (Scan, Handle)
       and then AdaBee.PHY.Current_State = ED_Scan_Complete;
   --  Reads the ED value from the PHY and stores it in the MLME-SCAN.confirm
   --  for the current channel.

   procedure Start_ED_Scan_On_Current_Channel
     (Scan : Scan_State; Handle : AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   with
     Inline,
     Pre  =>
       Is_Valid_ED_SCAN_Req (Handle)
       and then Req_SAP.Request_Reference (Handle).all.SCAN.Scan_Duration > 0
       and then AdaBee.PHY.Channel_Supported (Scan.Current_Channel)
       and then AdaBee.PHY.Current_State = Idle,
     Post => AdaBee.PHY.Current_State = ED_Scan_Active;
   --  Starts an ED scan on the PHY for the current channel

   procedure Start_ED_Scan_On_Next_Channel
     (Scan   : in out Scan_State;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   with
     Inline,
     Pre  =>
       Is_Valid_ED_SCAN_Req_And_Cfm (Handle)
       and then
         AdaBee.PHY.Current_State in Off | Sleeping | Exiting_Sleep | Idle,
     Post =>
       (if not Req_SAP.Is_Null (Handle) then Is_Valid (Scan, Handle))

       and then
         (declare
            Old_PHY_State : constant AdaBee.PHY.State_Kind :=
              AdaBee.PHY.Current_State'Old;
          begin
            (if Req_SAP.Is_Null (Handle)
             then AdaBee.PHY.Current_State = Old_PHY_State
             elsif Old_PHY_State /= Idle
             then AdaBee.PHY.Current_State = Exiting_Sleep
             else AdaBee.PHY.Current_State = ED_Scan_Active));
   --  Searches for the next channel to scan, and initiates the scan on the PHY
   --  if one is found.
   --
   --  This iterates through each RF channel, starting at `Search_From`, and
   --  searches for the next channel that is both requested in the
   --  MLME-SCAN.request primitive and is supported by the PHY. If one is
   --  found, then it starts an ED scan of that channel on the PHY.
   --
   --  If a channel is found that is requested in the MLME-SCAN.request but is
   --  not supported by the PHY, then it is marked as an unscanned channel in
   --  the MLME-SCAN.confirm and the search is continued.
   --
   --  If no channel is found, then the MLME-SCAN.confirm primitive is sent
   --  with its current contents.

   -------------------
   -- Begin_ED_Scan --
   -------------------

   procedure Begin_ED_Scan
     (Scan   : out Scan_State;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle) is
   begin
      Initialize_ED_SCAN_Cfm (Handle);

      Scan := (Current_Channel => AdaBee.PHY.RF_Channel_Number'First);

      Start_ED_Scan_On_Next_Channel (Scan, Handle);
   end Begin_ED_Scan;

   -----------------------------------
   -- Notify_PHY_Operation_Complete --
   -----------------------------------

   procedure Notify_PHY_Operation_Complete
     (Scan   : in out Scan_State;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle) is
   begin
      case AdaBee.PHY.Current_State is
         when Idle             =>
            --  The PHY has exited sleep mode, so start the first scan.
            Start_ED_Scan_On_Current_Channel (Scan, Handle);

         when ED_Scan_Complete =>
            Save_ED_Scan_Result (Scan, Handle);

            AdaBee.PHY.Go_Idle;

            if Scan.Current_Channel < AdaBee.PHY.RF_Channel_Number'Last then
               Scan.Current_Channel := Scan.Current_Channel + 1;
               Start_ED_Scan_On_Next_Channel (Scan, Handle);
            else
               Req_SAP.Send_Confirm (Handle);
            end if;

         when others           =>
            pragma Assert (False); --  Unreachable
      end case;
   end Notify_PHY_Operation_Complete;

   ----------------------------
   -- Initialize_ED_SCAN_Cfm --
   ----------------------------

   procedure Initialize_ED_SCAN_Cfm
     (Request : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   is
      function Postcondition
        (Request : MLME_Request_Type; Confirm : MLME_Confirm_Type)
         return Boolean
      is (Is_Valid_ED_SCAN_Req (Request)
          and then Valid_Confirm (Request, Confirm)
          and then Confirm.SCAN.Status = Success);

      procedure Write_ED_SCAN_Cfm
        (Request : MLME_Request_Type; Confirm : out MLME_Confirm_Type)
      with
        Pre  =>
          Is_Valid_ED_SCAN_Req (Request) and then not Confirm'Constrained,
        Post => Postcondition (Request, Confirm);

      -----------------------
      -- Write_ED_SCAN_Cfm --
      -----------------------

      procedure Write_ED_SCAN_Cfm
        (Request : MLME_Request_Type; Confirm : out MLME_Confirm_Type)
      is
         pragma Unreferenced (Request);
      begin
         Confirm :=
           (Kind => MLME_SCAN_Cfm,
            SCAN =>
              (Scan_Type          => ED,
               Status             => Success,
               Energy_Detect_List => [others => 0]));
      end Write_ED_SCAN_Cfm;

      procedure Write_Confirm is new
        Req_SAP.Initialize_Confirm
          (Initialize    => Write_ED_SCAN_Cfm,
           Precondition  => Is_Valid_ED_SCAN_Req,
           Postcondition => Postcondition);

   begin
      Write_Confirm (Request);
   end Initialize_ED_SCAN_Cfm;

   -------------------------
   -- Save_ED_Scan_Result --
   -------------------------

   procedure Save_ED_Scan_Result
     (Scan   : Scan_State;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   is

      function Invariant
        (Request : MLME_Request_Type; Confirm : MLME_Confirm_Type)
         return Boolean
      is (Is_Valid_ED_SCAN_Req_And_Cfm (Request, Confirm)
          and then AdaBee.PHY.Current_State = ED_Scan_Complete
          and then Request.SCAN.Scan_Channels (Scan.Current_Channel)
          and then Request.SCAN.Scan_Duration > 0);

      procedure Update_ED_SCAN_Cfm
        (Request : MLME_Request_Type; Confirm : in out MLME_Confirm_Type)
      with
        Pre  => Invariant (Request, Confirm),
        Post => Invariant (Request, Confirm);

      ------------------------
      -- Update_ED_SCAN_Cfm --
      ------------------------

      procedure Update_ED_SCAN_Cfm
        (Request : MLME_Request_Type; Confirm : in out MLME_Confirm_Type)
      is
         pragma Unreferenced (Request);

         Max_ED : AdaBee.PHY.ED_Range;
      begin
         AdaBee.PHY.Get_ED_Scan_Result (Max_ED);
         Confirm.SCAN.Energy_Detect_List (Scan.Current_Channel) := Max_ED;
      end Update_ED_SCAN_Cfm;

      procedure Update_Confirm is new
        Req_SAP.Update_Confirm
          (Update        => Update_ED_SCAN_Cfm,
           Precondition  => Invariant,
           Postcondition => Invariant);

   begin
      Update_Confirm (Handle);
   end Save_ED_Scan_Result;

   --------------------------------------
   -- Start_ED_Scan_On_Current_Channel --
   --------------------------------------

   procedure Start_ED_Scan_On_Current_Channel
     (Scan : Scan_State; Handle : AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   is
      Duration : constant AdaBee.Time_Units.Time_Span :=
        AdaBee.PHY.Symbols_Duration
          (Req_SAP.Request_Reference (Handle).all.SCAN.Scan_Duration);
   begin
      AdaBee.PHY.Set_Channel (Scan.Current_Channel);
      AdaBee.PHY.Start_ED_Scan (Duration);
   end Start_ED_Scan_On_Current_Channel;

   -----------------------------------
   -- Start_ED_Scan_On_Next_Channel --
   -----------------------------------

   procedure Start_ED_Scan_On_Next_Channel
     (Scan   : in out Scan_State;
      Handle : in out AdaBee.MAC.MLME.Req_SAP.Service_Handle)
   is
      Next_Channel  : AdaBee.PHY.RF_Channel_Number := 0;
      Channel_Found : Boolean := False;

   begin
      --  PHY.Start_ED_Scan requires a non-zero scan duration, but the
      --  MLME-SCAN.request's ScanDuration parameter might be zero.
      --
      --  In this case, simply finish the scan now since a zero-duration scan
      --  is the same as not scanning at all.

      if Req_SAP.Request_Reference (Handle).all.SCAN.Scan_Duration = 0 then
         Req_SAP.Send_Confirm (Handle);

      else

         --  Find the next channel

         for Ch in Scan.Current_Channel .. AdaBee.PHY.RF_Channel_Number'Last
         loop
            pragma Loop_Invariant (not Channel_Found);

            if Req_SAP.Request_Reference (Handle).all.SCAN.Scan_Channels (Ch)
            then
               if AdaBee.PHY.Channel_Supported (Ch) then
                  Next_Channel := Ch;
                  Channel_Found := True;
                  exit;
               end if;
            end if;
         end loop;

         if not Channel_Found then
            Req_SAP.Send_Confirm (Handle);

         else
            Scan.Current_Channel := Next_Channel;

            case AdaBee.PHY.Current_State is
               when Off           =>
                  AdaBee.PHY.Turn_On;
                  AdaBee.PHY.Exit_Sleep;

               when Sleeping      =>
                  AdaBee.PHY.Exit_Sleep;

               when Exiting_Sleep =>
                  null;

               when Idle          =>
                  Start_ED_Scan_On_Current_Channel (Scan, Handle);

               when others        =>
                  pragma Assert (False); --  Unreachable
            end case;
         end if;
      end if;
   end Start_ED_Scan_On_Next_Channel;

end AdaBee.MAC.MLME.ED_Scan;
