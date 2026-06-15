--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.MLME.PIB
  with SPARK_Mode
is

   use all type AdaBee.MAC.MLME.SAP.MLME_Confirm_Kind;
   use all type AdaBee.MAC.MLME.SAP.PIB_Attribute_Kind;

   -----------
   -- Reset --
   -----------

   procedure Reset is
   begin
      DB := (others => <>);

      PHY.Set_CCA_Mode (PHY.ALOHA);
   end Reset;

   -----------------
   -- SET_Request --
   -----------------

   procedure SET_Request (Handle : in out SAP.Requests.Service_Handle) is

      function Is_SET_Request (Request : SAP.MLME_Request_Type) return Boolean
      is (Request.Kind = MLME_SET_Req);

      procedure Process_Request
        (Request : SAP.MLME_Request_Type; Confirm : out SAP.MLME_Confirm_Type)
      with
        Pre  => Request.Kind = MLME_SET_Req and then not Confirm'Constrained,
        Post => SAP.Valid_Confirm (Request, Confirm);

      procedure Process_Request
        (Request : SAP.MLME_Request_Type; Confirm : out SAP.MLME_Confirm_Type)
      is
      begin
         case Request.SET.PIB_Attribute is
            when MAC_Auto_Request         =>
               DB.MAC_Auto_Request := Request.SET.Auto_Request;

            when MAC_DSN                  =>
               DB.MAC_DSN := Request.SET.DSN;

            when MAC_Min_BE               =>
               DB.MAC_Min_BE := Request.SET.Min_BE;

            when MAC_Max_BE               =>
               DB.MAC_Max_BE := Request.SET.Max_BE;

            when MAC_Max_CSMA_Backoffs    =>
               DB.MAC_Max_CSMA_Backoffs := Request.SET.Max_CSMA_Backoffs;

            when MAC_Short_Address        =>
               DB.MAC_Short_Address := Request.SET.Short_Address;

            when MAC_Max_Frame_Retries    =>
               DB.MAC_Max_Frame_Retries := Request.SET.Max_Frame_Retries;

            when MAC_PAN_ID               =>
               DB.MAC_PAN_ID := Request.SET.PAN_ID;

            when MAC_Rx_On_When_Idle      =>
               DB.MAC_Rx_On_When_Idle := Request.SET.Rx_On_When_Idle;

            when MAC_Security_Enabled     =>
               DB.MAC_Security_Enabled := Request.SET.Security_Enabled;

            when PHY_CCA_Mode             =>
               AdaBee.PHY.Set_CCA_Mode (Request.SET.CCA_Mode);

            when SAP.Read_Only_PIB_Attributes =>
               Confirm :=
                 (Kind => MLME_SET_Cfm,
                  SET  =>
                    (PIB_Attribute => Request.SET.PIB_Attribute,
                     Status        => Read_Only));
               return;
         end case;

         Confirm :=
           (Kind => MLME_SET_Cfm,
            SET  =>
              (PIB_Attribute => Request.SET.PIB_Attribute, Status => Success));
      end Process_Request;

      procedure Process_Request is new
        SAP.Requests.Initialize_Confirm
          (Initialize    => Process_Request,
           Precondition  => Is_SET_Request,
           Postcondition => SAP.Valid_Confirm);

   begin
      Process_Request (Handle);
      SAP.Requests.Send_Confirm (Handle);
   end SET_Request;

   -----------------
   -- GET_Request --
   -----------------

   procedure GET_Request (Handle : in out SAP.Requests.Service_Handle) is

      function Is_GET_Request (Request : SAP.MLME_Request_Type) return Boolean
      is (Request.Kind = MLME_GET_Req);

      procedure Process_Request
        (Request : SAP.MLME_Request_Type; Confirm : out SAP.MLME_Confirm_Type)
      with
        Pre  => Request.Kind = MLME_GET_Req and then not Confirm'Constrained,
        Post => SAP.Valid_Confirm (Request, Confirm);

      procedure Process_Request
        (Request : SAP.MLME_Request_Type; Confirm : out SAP.MLME_Confirm_Type)
      is
         CCA_Mode : AdaBee.PHY.CCA_Mode_Kind;
      begin
         case Request.GET.PIB_Attribute is
            when MAC_Auto_Request      =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_Auto_Request,
                     Status        => Success,
                     Auto_Request  => DB.MAC_Auto_Request));

            when MAC_DSN               =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_DSN,
                     Status        => Success,
                     DSN           => DB.MAC_DSN));

            when MAC_Min_BE            =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_Min_BE,
                     Status        => Success,
                     Min_BE        => DB.MAC_Min_BE));

            when MAC_Max_BE            =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_Max_BE,
                     Status        => Success,
                     Max_BE        => DB.MAC_Max_BE));

            when MAC_Max_CSMA_Backoffs =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute     => MAC_Max_CSMA_Backoffs,
                     Status            => Success,
                     Max_CSMA_Backoffs => DB.MAC_Max_CSMA_Backoffs));

            when MAC_Short_Address     =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_Short_Address,
                     Status        => Success,
                     Short_Address => DB.MAC_Short_Address));

            when MAC_Extended_Address  =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute    => MAC_Extended_Address,
                     Status           => Success,
                     Extended_Address => MAC_Extended_Address));

            when MAC_Max_Frame_Retries =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute     => MAC_Max_Frame_Retries,
                     Status            => Success,
                     Max_Frame_Retries => DB.MAC_Max_Frame_Retries));

            when MAC_PAN_ID            =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_PAN_ID,
                     Status        => Success,
                     PAN_ID        => DB.MAC_PAN_ID));

            when MAC_Rx_On_When_Idle   =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute   => MAC_Rx_On_When_Idle,
                     Status          => Success,
                     Rx_On_When_Idle => DB.MAC_Rx_On_When_Idle));

            when MAC_Security_Enabled  =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute    => MAC_Security_Enabled,
                     Status           => Success,
                     Security_Enabled => DB.MAC_Security_Enabled));

            when PHY_CCA_Mode          =>
               CCA_Mode := AdaBee.PHY.Get_CCA_Mode;

               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => PHY_CCA_Mode,
                     Status        => Success,
                     CCA_Mode      => CCA_Mode));
         end case;
      end Process_Request;

      procedure Process_Request is new
        SAP.Requests.Initialize_Confirm
          (Initialize    => Process_Request,
           Precondition  => Is_GET_Request,
           Postcondition => SAP.Valid_Confirm);

   begin
      Process_Request (Handle);
      SAP.Requests.Send_Confirm (Handle);
   end GET_Request;

end AdaBee.MAC.MLME.PIB;
