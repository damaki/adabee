--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Headers;
with AdaBee.MAC.Frames.Headers.Decoder_Model;
with AdaBee.MAC.Frames.Headers.Encoder_Model;
with AdaBee.MAC.Frames.Info_Elements.Headers;
with AdaBee.MAC.Frames.Info_Elements.Payloads;
with AdaBee.MAC.Frames.Layouts;

private with AdaBee.MAC.MLME.PIB;
private with AdaBee.MAC.MLME.SAP;
private with AdaBee.MAC.MLME.Security_Types;

--  This package implements the incoming and outgoing frame security procedures
--  as defined in Section 9.2 of IEEE 802.15.4-2024.

private package AdaBee.MAC.MLME.Security_Procedures
  with SPARK_Mode, Always_Terminates
is

   use all type AdaBee.MAC.Frames.Headers.Security_Enabled_Field;
   use all type AdaBee.MAC.Frames.Headers.IE_Present_Field;

   ---------------
   -- IE Status --
   ---------------

   type IE_Status_Kind is (Failed, Passed) with Size => 1;
   --  Result of the incoming IE security checking procedure

   type IE_Status_Array is array (Positive range <>) of IE_Status_Kind
   with Pack;
   --  Represents the IeStatusList output by the security procedures defined
   --  in Section 9.2 of IEEE 802.15.4-2024.
   --
   --  The array index corresponds to the position of the IE in the frame
   --  buffer. For example, the status at index 5 corresponds to the IE at
   --  index 5 in the frame buffer.

   ----------------------------------------
   -- Incoming Frame Security Procedures --
   ----------------------------------------

   function Incoming_Frame_Security_Preconditions
     (Frame               : Byte_Array;
      MHR                 : AdaBee.MAC.Frames.Headers.Valid_MAC_Header;
      Layout              : AdaBee.MAC.Frames.Layouts.Frame_Layout;
      Payload_IEs_Present : Boolean) return Boolean
   is (
       --  The Frame buffer must hold a frame with a valid MAC header (MHR)
       Frames.Headers.Decoder_Model.Is_MHR_Valid (Frame)

       --  The MAC header and FCS fields must fit within the Frame buffer
       and then
         Frame'Length - Frames.FCS_Length
         >= Frames.Headers.Decoder_Model.MHR_Length (Frame)

       --  The decoded MHR data matches the content of the Frame buffer
       and then
         Frame'Length
         >= Frames.Headers.Encoder_Model.MHR_Length_Excluding_IEs (MHR)
       and then
         Frames.Headers.Encoder_Model.MHR_Equal_Excluding_IEs (MHR, Frame)

       --  The layout (size & position) of the MAC header and MAC payload
       --  fields must be set correctly in the Layout record.
       and then
         Frames.Layouts.Formal_Model.MAC_Header_Layout_Matches_Model
           (Frame, Layout)
       and then
         Frames.Layouts.Formal_Model.MAC_Payload_Layout_Matches_Model
           (Frame, Layout)

       --  If header IEs are present, then the IE list must have been validated
       and then
         (if MHR.IE_Present = Present
          then
            Frames.Info_Elements.Headers.Lists.Formal_Model.Valid_IE_List
              (Frame (Layout.Header_IEs_First .. Layout.Header_IEs_Last)))

       --  Payload_IEs_Present indicates whether payload IEs are present in
       --  the frame.
       and then
         Payload_IEs_Present
         = Frames.Headers.Decoder_Model.Is_Payload_IE_Present (Frame))
   with Ghost;
   --  Defines the preconditions required for the incoming frame security
   --  procedures.
   --
   --  The incoming frame security procedures require that:
   --    * the MAC header in the frame has been validated, and MHR contains the
   --      decoded data from that MAC header;
   --    * the Layout record denotes the correct positions of the header IEs
   --      and MAC payload fields;
   --    * if header IEs are present, then the IE list has been validated; and
   --    * Payload_IEs_Present correctly denotes whether a payload IE list is
   --      expected to be in the MAC payload field.

   procedure Unsecure_Incoming_Frame_Security_Disabled
     (Frame               : Byte_Array;
      MHR                 : AdaBee.MAC.Frames.Headers.Valid_MAC_Header;
      Layout              : in out AdaBee.MAC.Frames.Layouts.Frame_Layout;
      Payload_IEs_Present : Boolean;
      IE_Status_List      : out IE_Status_Array;
      Status              : out Status_Code)
   with
     Relaxed_Initialization => IE_Status_List,
     Pre                    =>
       --  This security procedure is used when the Security Enabled field is
       --  set to zero (disabled).
       MHR.Aux_Security_Header.Security_Enabled = Disabled

       and then
         Incoming_Frame_Security_Preconditions
           (Frame, MHR, Layout, Payload_IEs_Present)

       --  If IE lists are present, then the IE_Status_List must span at least
       --  the range of the Frame where IEs can be located.
       and then
         (if MHR.IE_Present = Present
          then
            IE_Status_List'First <= Layout.Header_IEs_First
            and then IE_Status_List'Last >= Layout.Header_IEs_Last
            and then IE_Status_List'Last >= Layout.MAC_Payload_Last),

     Post                   =>
       --  Header IE and MAC payload indices in the Layout are unchanged
       Layout.Header_IEs_First = Layout'Old.Header_IEs_First
       and then Layout.Header_IEs_Last = Layout'Old.Header_IEs_Last
       and then Layout.MAC_Payload_First = Layout'Old.MAC_Payload_First
       and then Layout.MAC_Payload_Last = Layout'Old.MAC_Payload_Last

       and then
         (if Status = Success
          then
            IE_Status_List'Initialized

            --  The Layout field correctly denotes the positions of the MAC
            --  frame fields according to the formal model.
            and then
              Frames.Layouts.Formal_Model.Layout_Matches_Model (Frame, Layout)

            and then
              (if Payload_IEs_Present
               then
                 --  The payload IE list (and any nested IEs) have been
                 --  successfully validated.
                 Frames.Info_Elements.Payloads.Lists.Formal_Model.Valid_IE_List
                   (Frame
                      (Layout.MAC_Payload_First .. Layout.Payload_IEs_Last))
                 and then
                   Frames.Info_Elements.Payloads.Nested_IE_Lists_Valid
                     (Frame
                        (Layout.MAC_Payload_First
                         .. Layout.Payload_IEs_Last))));
   --  Perform the incoming frame security procedure when the Security Enabled
   --  field is set to zero, as per Section 9.2.5 of IEEE 802.15.4-2024.
   --
   --  This also validates the payload IE list (and any nested IEs) of the
   --  unsecured frame, if payload IEs are present.

private
   use type AdaBee.MAC.MLME.SAP.Sec_Device_List_Index;
   use type AdaBee.MAC.MLME.SAP.Sec_Security_Level_List_Index;
   use type AdaBee.MAC.MLME.Security_Types.IE_Security_Level_Descriptor_Count;
   use type AdaBee.MAC.Frames.Headers.Short_Address_Field;
   use type AdaBee.MAC.Frames.Headers.Extended_Address_Field;
   use all type AdaBee.MAC.Frames.Headers.Address_Mode_Field;

   ------------------------------
   -- Device Descriptor Lookup --
   ------------------------------

   subtype Sec_Device_List_Extended_Index is
     AdaBee.MAC.MLME.SAP.Sec_Device_List_Index'Base
       range AdaBee.MAC.MLME.SAP.Sec_Device_List_Index'First
             - 1
             .. AdaBee.MAC.MLME.SAP.Sec_Device_List_Index'Last;

   No_Device : constant Sec_Device_List_Extended_Index :=
     Sec_Device_List_Extended_Index'First;

   function Address_Equal
     (Address    : AdaBee.MAC.Frames.Headers.Variant_Address;
      Descriptor : AdaBee.MAC.MLME.Security_Types.Device_Descriptor)
      return Boolean
   is (if Address.Mode = Extended
       then Address.Extended_Address = Descriptor.Ext_Address
       else Address.Short_Address = Descriptor.Short_Address)
   with Pre => Address.Mode in Short | Extended;
   --  Compares an address with the address in a device descriptor and returns
   --  True if and only if the addresses are equal.

   function Lookup_Device_Descriptor
     (Device_PAN_ID  : AdaBee.MAC.Frames.Headers.PAN_ID_Field;
      Device_Address : AdaBee.MAC.Frames.Headers.Variant_Address)
      return Sec_Device_List_Extended_Index
   with Global => (Input => PIB.DB);
   --  Perform the DeviceDescriptor lookup procedure as specified in
   --  IEEE 802.15.4-2024 Section 9.2.6.
   --
   --  No_Device is returned when the device descriptor was not found,
   --  otherwise the index of the descriptor in secDeviceList is returned.

   --------------------------------------
   -- Security Level Descriptor Lookup --
   --------------------------------------

   subtype Sec_Security_Level_List_Extended_Index is
     AdaBee.MAC.MLME.SAP.Sec_Security_Level_List_Index'Base
       range AdaBee.MAC.MLME.SAP.Sec_Security_Level_List_Index'First
             - 1
             .. AdaBee.MAC.MLME.SAP.Sec_Security_Level_List_Index'Last;

   No_Security_Level : constant Sec_Security_Level_List_Extended_Index :=
     Sec_Security_Level_List_Extended_Index'First;

   function Lookup_Security_Level
     (Frame_Type     : AdaBee.MAC.Frames.Headers.Frame_Type_Field;
      MAC_Command_ID : Bits_8) return Sec_Security_Level_List_Extended_Index
   with Global => (Input => PIB.DB);
   --  Perform the SecurityLevelDescriptor lookup procedure as specified in
   --  IEEE 802.15.4-2024 Section 9.2.7.
   --
   --  No_Security_Level is returned when the descriptor was not found,
   --  otherwise the index of the descriptor in secSecurityLevelList is
   --  returned.

   -----------------------------
   -- Security Level Checking --
   -----------------------------

   type Security_Level_Status is (Failed, Conditionally_Passed, Passed);

end AdaBee.MAC.MLME.Security_Procedures;
