--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.Crypto;

package body AdaBee.MAC.MLME.PIB
  with SPARK_Mode
is

   use all type AdaBee.MAC.MLME.SAP.MLME_Confirm_Kind;
   use all type AdaBee.MAC.MLME.SAP.PIB_Attribute_Kind;
   use all type AdaBee.MAC.MLME.Security_Types.Key_ID_Lookup_Descriptor;

   Sec_Key_ID_Lookup_List_Enabled : constant Boolean :=
     Adabee_Mlme_Config.Sec_Key_ID_Lookup_List_Max_Length > 0;

   Sec_Device_List_Enabled : constant Boolean :=
     Adabee_Mlme_Config.Sec_Device_List_Max_Length > 0;

   procedure Install_Key_And_Set_Descriptor
     (Source : Security_Types.Key_ID_Lookup_Descriptor;
      Target : in out Security_Types.Key_ID_Lookup_Descriptor;
      Status : in out Status_Code)
   with
     Global => (In_Out => AdaBee.Crypto.Crypto_Engine),
     Pre    => Status = Success and then not Target'Constrained,
     Post   =>
       --  Descriptors that do not contain key material are copied directly.
       (if not Source.Key_Item.Key.Contains_Key_Data
        then Target = Source and then Status = Success)

       --  If Target was written, then it never contains key material
       --  (it contains a key ID only).
       and then
         (if Status = Success
          then not Target.Key_Item.Key.Contains_Key_Data
          else Target = Target'Old);

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
         Confirm :=
           (Kind => MLME_SET_Cfm,
            SET  =>
              (PIB_Attribute => Request.SET.PIB_Attribute, Status => Success));

         case Request.SET.PIB_Attribute is
            when MAC_Auto_Request       =>
               DB.MAC_Auto_Request := Request.SET.Auto_Request;

            when MAC_DSN                =>
               DB.MAC_DSN := Request.SET.DSN;

            when MAC_Min_BE             =>
               DB.MAC_Min_BE := Request.SET.Min_BE;

            when MAC_Max_BE             =>
               DB.MAC_Max_BE := Request.SET.Max_BE;

            when MAC_Max_CSMA_Backoffs  =>
               DB.MAC_Max_CSMA_Backoffs := Request.SET.Max_CSMA_Backoffs;

            when MAC_Short_Address      =>
               DB.MAC_Short_Address := Request.SET.Short_Address;

            when MAC_Max_Frame_Retries  =>
               DB.MAC_Max_Frame_Retries := Request.SET.Max_Frame_Retries;

            when MAC_PAN_ID             =>
               DB.MAC_PAN_ID := Request.SET.PAN_ID;

            when MAC_Rx_On_When_Idle    =>
               DB.MAC_Rx_On_When_Idle := Request.SET.Rx_On_When_Idle;

            when MAC_Security_Enabled   =>
               DB.MAC_Security_Enabled := Request.SET.Security_Enabled;

            when PHY_CCA_Mode           =>
               AdaBee.PHY.Set_CCA_Mode (Request.SET.CCA_Mode);

            when Sec_Key_ID_Lookup_List =>

               pragma
                 Warnings
                   (GNATprove,
                    Off,
                    "statement has no effect",
                    Reason => "Conditionally compiled code");

               pragma
                 Warnings
                   (GNATprove,
                    Off,
                    "this statement is never reached",
                    Reason => "Conditionally compiled code");

               if Sec_Key_ID_Lookup_List_Enabled then
                  Install_Key_And_Set_Descriptor
                    (Source => Request.SET.Key_Descriptor,
                     Target =>
                       DB.Sec_Key_ID_Lookup_List (Request.SET.Key_Index),
                     Status => Confirm.SET.Status);
               else
                  Confirm.SET.Status := Not_Supported;
               end if;

               pragma Warnings (GNATprove, On);

            when Sec_Device_List        =>

               pragma
                 Warnings
                   (GNATprove,
                    Off,
                    "statement has no effect",
                    Reason => "Conditionally compiled code");

               pragma
                 Warnings
                   (GNATprove,
                    Off,
                    "this statement is never reached",
                    Reason => "Conditionally compiled code");

               if Sec_Device_List_Enabled then
                  DB.Sec_Device_List (Request.SET.Device_Index) :=
                    Request.SET.Device_Descriptor;
               else
                  Confirm.SET.Status := Not_Supported;
               end if;

               pragma Warnings (GNATprove, On);

            when Sec_Frame_Counter      =>
               DB.Sec_Frame_Counter := Request.SET.Frame_Counter;

         end case;
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
            when MAC_Auto_Request       =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_Auto_Request,
                     Status        => Success,
                     Auto_Request  => DB.MAC_Auto_Request));

            when MAC_DSN                =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_DSN,
                     Status        => Success,
                     DSN           => DB.MAC_DSN));

            when MAC_Min_BE             =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_Min_BE,
                     Status        => Success,
                     Min_BE        => DB.MAC_Min_BE));

            when MAC_Max_BE             =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_Max_BE,
                     Status        => Success,
                     Max_BE        => DB.MAC_Max_BE));

            when MAC_Max_CSMA_Backoffs  =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute     => MAC_Max_CSMA_Backoffs,
                     Status            => Success,
                     Max_CSMA_Backoffs => DB.MAC_Max_CSMA_Backoffs));

            when MAC_Short_Address      =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_Short_Address,
                     Status        => Success,
                     Short_Address => DB.MAC_Short_Address));

            when MAC_Extended_Address   =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute    => MAC_Extended_Address,
                     Status           => Success,
                     Extended_Address => MAC_Extended_Address));

            when MAC_Max_Frame_Retries  =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute     => MAC_Max_Frame_Retries,
                     Status            => Success,
                     Max_Frame_Retries => DB.MAC_Max_Frame_Retries));

            when MAC_PAN_ID             =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => MAC_PAN_ID,
                     Status        => Success,
                     PAN_ID        => DB.MAC_PAN_ID));

            when MAC_Rx_On_When_Idle    =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute   => MAC_Rx_On_When_Idle,
                     Status          => Success,
                     Rx_On_When_Idle => DB.MAC_Rx_On_When_Idle));

            when MAC_Security_Enabled   =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute    => MAC_Security_Enabled,
                     Status           => Success,
                     Security_Enabled => DB.MAC_Security_Enabled));

            when PHY_CCA_Mode           =>
               CCA_Mode := AdaBee.PHY.Get_CCA_Mode;

               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => PHY_CCA_Mode,
                     Status        => Success,
                     CCA_Mode      => CCA_Mode));

            when Sec_Key_ID_Lookup_List =>
               if Sec_Key_ID_Lookup_List_Enabled then
                  Confirm :=
                    (Kind => MLME_GET_Cfm,
                     GET  =>
                       (PIB_Attribute  => Sec_Key_ID_Lookup_List,
                        Status         => Success,
                        Key_Descriptor =>
                          PIB.DB.Sec_Key_ID_Lookup_List
                            (Request.GET.Key_Index)));
               else
                  Confirm :=
                    (Kind => MLME_GET_Cfm,
                     GET  =>
                       (PIB_Attribute => Sec_Key_ID_Lookup_List,
                        Status        => Not_Supported));
               end if;

            when Sec_Device_List        =>
               if Sec_Device_List_Enabled then
                  Confirm :=
                    (Kind => MLME_GET_Cfm,
                     GET  =>
                       (PIB_Attribute     => Sec_Device_List,
                        Status            => Success,
                        Device_Descriptor =>
                          PIB.DB.Sec_Device_List (Request.GET.Device_Index)));
               else
                  Confirm :=
                    (Kind => MLME_GET_Cfm,
                     GET  =>
                       (PIB_Attribute => Sec_Device_List,
                        Status        => Not_Supported));
               end if;

            when Sec_Frame_Counter      =>
               Confirm :=
                 (Kind => MLME_GET_Cfm,
                  GET  =>
                    (PIB_Attribute => Sec_Frame_Counter,
                     Status        => Success,
                     Frame_Counter => DB.Sec_Frame_Counter));

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

   ------------------------------------
   -- Install_Key_And_Set_Descriptor --
   ------------------------------------

   procedure Install_Key_And_Set_Descriptor
     (Source : Security_Types.Key_ID_Lookup_Descriptor;
      Target : in out Security_Types.Key_ID_Lookup_Descriptor;
      Status : in out Status_Code)
   is
      use all type AdaBee.Crypto.Status_Code;
      use all type AdaBee.Crypto.Algorithm_Kind;

      New_Key : Security_Types.Key_Holder;

      Crypto_Status : AdaBee.Crypto.Status_Code;
      Allocated_ID  : AdaBee.Crypto.Key_ID;
   begin
      if Source.Key_Item.Key.Contains_Key_Data then
         case Source.Key_Item.Key.AEAD_Algorithm is
            when AES_128_CCM_Star =>
               AdaBee.Crypto.Import_Key
                 (Key       => Source.Key_Item.Key.Key_128,
                  Algorithm => AES_128_CCM_Star,
                  ID        => Allocated_ID,
                  Status    => Crypto_Status);

               New_Key :=
                 (AEAD_Algorithm    => AES_128_CCM_Star,
                  Contains_Key_Data => False,
                  Key_ID            => Allocated_ID);

            when AES_128_CCM      =>
               AdaBee.Crypto.Import_Key
                 (Key       => Source.Key_Item.Key.Key_128,
                  Algorithm => AES_128_CCM,
                  ID        => Allocated_ID,
                  Status    => Crypto_Status);

               New_Key :=
                 (AEAD_Algorithm    => AES_128_CCM,
                  Contains_Key_Data => False,
                  Key_ID            => Allocated_ID);

            when AES_256_CCM      =>
               AdaBee.Crypto.Import_Key
                 (Key       => Source.Key_Item.Key.Key_256,
                  Algorithm => AES_256_CCM,
                  ID        => Allocated_ID,
                  Status    => Crypto_Status);

               New_Key :=
                 (AEAD_Algorithm    => AES_256_CCM,
                  Contains_Key_Data => False,
                  Key_ID            => Allocated_ID);
         end case;

         if Crypto_Status /= Success then
            Status := Security_Error;
         else
            Target :=
              (Source
               with delta
                 Key_Item => (Source.Key_Item with delta Key => New_Key));
         end if;
      else
         Target := Source;
      end if;
   end Install_Key_And_Set_Descriptor;

end AdaBee.MAC.MLME.PIB;
