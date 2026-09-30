--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.MAC.Frames.Headers;

with AdaBee.MAC.MLME.SAP.Requests;
private with AdaBee.PHY;

--  This package stores the MAC PIB attributes and handles MLME-SET and
--  MLME-GET requests.

private package AdaBee.MAC.MLME.PIB
  with Elaborate_Body, SPARK_Mode
is

   use all type AdaBee.MAC.MLME.SAP.MLME_Request_Kind;

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
   end record;

   Default_PIB : constant PIB_Attributes := (others => <>);

   DB : PIB_Attributes := (others => <>);

   function MAC_Extended_Address return Frames.Headers.Extended_Address_Field;

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

   function MAC_Extended_Address return Frames.Headers.Extended_Address_Field
   is (Frames.Headers.Extended_Address_Field (AdaBee.PHY.Get_Device_ID));

end AdaBee.MAC.MLME.PIB;
