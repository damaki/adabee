--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.MAC.Frames.Headers;

with AdaBee.MAC.MLME.SAP.Requests;
with AdaBee.MAC.MLME.Security_Types;

with Adabee_Mlme_Config;

private with AdaBee.PHY;

--  This package stores the MAC PIB attributes and handles MLME-SET and
--  MLME-GET requests.

private package AdaBee.MAC.MLME.PIB
  with Elaborate_Body, SPARK_Mode
is

   use all type AdaBee.MAC.MLME.SAP.MLME_Request_Kind;
   use all type AdaBee.MAC.Frames.Headers.Security_Level_Field;

   ---------------
   -- PIB Types --
   ---------------

   type Key_ID_Lookup_Descriptor_Array is
     array (SAP.Sec_Key_ID_Lookup_List_Index range <>)
     of AdaBee.MAC.MLME.Security_Types.Key_ID_Lookup_Descriptor;

   type Device_Descriptor_Array is
     array (SAP.Sec_Device_List_Index range <>)
     of AdaBee.MAC.MLME.Security_Types.Device_Descriptor;

   type PIB_Attributes is record
      MAC_PAN_ID            : Frames.Headers.PAN_ID_Field := 16#FFFF#;
      MAC_Short_Address     : Frames.Headers.Short_Address_Field := 16#FFFF#;
      MAC_DSN               : Bits_8 := 0;
      MAC_Max_BE            : SAP.MAC_Max_BE_Range := 5;
      MAC_Max_CSMA_Backoffs : SAP.MAC_Max_CSMA_Backoffs_Range := 4;
      MAC_Max_Frame_Retries : SAP.MAC_Max_Frame_Retries_Range := 3;
      MAC_Min_BE            : SAP.MAC_Min_BE_Range := 3;
      MAC_Rx_On_When_Idle   : Boolean := False;
      MAC_Auto_Request      : Boolean := True;
      MAC_Security_Enabled  : Boolean := False;

      --  Security-related MAC PIB attributes.
      --
      --  Ref. IEEE 802.15.4-2024 Table 9-8

      Sec_Key_ID_Lookup_List :
        Key_ID_Lookup_Descriptor_Array
          (1 .. Adabee_Mlme_Config.Sec_Key_ID_Lookup_List_Max_Length) :=
          [others => <>];

      Sec_Device_List :
        Device_Descriptor_Array
          (1 .. Adabee_Mlme_Config.Sec_Device_List_Max_Length) :=
          [others => <>];

      Sec_Frame_Counter :
        AdaBee.MAC.MLME.Security_Types.Frame_Counter_Number := 0;

      Sec_Auto_Request_Security_Params :
        AdaBee.MAC.MLME.Security_Types.Security_Parameter_Descriptor :=
          (Security_Level => None);

      Sec_Enhanced_Beacon_Security_Params :
        AdaBee.MAC.MLME.Security_Types.Security_Parameter_Descriptor :=
          (Security_Level => None);

      Sec_Beacon_Security_Params :
        AdaBee.MAC.MLME.Security_Types.Security_Parameter_Descriptor :=
          (Security_Level => None);
   end record
   with
     Ghost_Predicate =>
       --  Plain keys are never stored in the PIB; it only holds identifiers
       --  for keys which are stored in a platform-specific crypto engine
       --  (see package AdaBee.Crypto).
       (for all K of Sec_Key_ID_Lookup_List =>
          not K.Key_Item.Key.Contains_Key_Data);

   ------------------
   -- PIB Instance --
   ------------------

   Default_PIB : constant PIB_Attributes := (others => <>);

   DB : PIB_Attributes := (others => <>)
   with Part_Of => PIB_Attributes_Data;
   --  Stores the PIB attributes data

   function MAC_Extended_Address return Frames.Headers.Extended_Address_Field;
   --  Read the macExtendedAddress attribute

   --------------------
   -- PIB Operations --
   --------------------

   procedure Reset
   with Post => DB = Default_PIB;
   --  Reset the PIB to its default values.

   procedure SET_Request (Handle : in out SAP.Requests.Service_Handle)
   with
     Always_Terminates => False,
     Pre               =>
       not SAP.Requests.Is_Null (Handle)
       and then SAP.Requests.Request_Reference (Handle).all.Kind = MLME_SET_Req
       and then not SAP.Requests.Confirm_Written (Handle),
     Post              => SAP.Requests.Is_Null (Handle);
   --  Handle a MLME-SET.request and issue the MLME-SET.confirm

   procedure GET_Request (Handle : in out SAP.Requests.Service_Handle)
   with
     Always_Terminates => False,
     Pre               =>
       not SAP.Requests.Is_Null (Handle)
       and then SAP.Requests.Request_Reference (Handle).all.Kind = MLME_GET_Req
       and then not SAP.Requests.Confirm_Written (Handle),
     Post              => SAP.Requests.Is_Null (Handle);
   --  Handle a MLME-GET.request and issue the MLME-GET.confirm

private

   --------------------------
   -- MAC_Extended_Address --
   --------------------------

   function MAC_Extended_Address return Frames.Headers.Extended_Address_Field
   is (Frames.Headers.Extended_Address_Field (AdaBee.PHY.Get_Device_ID));

end AdaBee.MAC.MLME.PIB;
