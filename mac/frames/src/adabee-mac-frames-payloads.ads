--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Headers.Decoder_Model;
with AdaBee.MAC.Frames.Layouts;
with AdaBee.MAC.Frames.Info_Elements.Payloads;

--  This package provides utilties for decoding the MAC payload field of
--  a MAC frame.

package AdaBee.MAC.Frames.Payloads
  with Elaborate_Body, SPARK_Mode, Always_Terminates
is

   procedure Decode_MAC_Payload_Layout
     (Frame               : Byte_Array;
      Layout              : in out Layouts.Frame_Layout;
      Payload_IEs_Present : Boolean;
      Status              : out Status_Code)
   with
     Global => null,
     Pre    =>
       Headers.Decoder_Model.Is_MHR_Valid (Frame)
       and then Headers.Decoder_Model.Is_MAC_Payload_Present (Frame)
       and then
         Payload_IEs_Present
         = Headers.Decoder_Model.Is_Payload_IE_Present (Frame)
       and then
         Layouts.Formal_Model.MAC_Header_Layout_Matches_Model (Frame, Layout)
       and then
         Layout.MAC_Payload_First
         = Frame'First + Headers.Decoder_Model.Get_MAC_Payload_Offset (Frame)
       and then
         Layout.MAC_Payload_Last
         = Layout.MAC_Payload_First
           + (Headers.Decoder_Model.Get_MAC_Payload_Length (Frame) - 1),
     Post   =>
       --  Unchanged layout fields
       Layout.Header_IEs_First = Layout'Old.Header_IEs_First
       and then Layout.Header_IEs_Last = Layout'Old.Header_IEs_Last
       and then Layout.MAC_Payload_First = Layout'Old.MAC_Payload_First
       and then Layout.MAC_Payload_Last = Layout'Old.MAC_Payload_Last

       --  Status is set to Success if and only if the payload and nested IE
       --  lists were successfully validated.
       and then
         (Status = Success)
         = (not Payload_IEs_Present
            or else
              (Info_Elements.Payloads.Lists.Formal_Model.Valid_IE_List
                 (Frame (Layout.MAC_Payload_First .. Layout.MAC_Payload_Last))
               and then
                 Info_Elements.Payloads.Nested_IE_Lists_Valid
                   (Frame
                      (Layout.MAC_Payload_First .. Layout.MAC_Payload_Last),
                    Layout.MAC_Payload_First)))

       and then
         (if Status = Success
          then Layouts.Formal_Model.Layout_Matches_Model (Frame, Layout));
   --  Determines the positions and size of the payload IEs and the Frame
   --  Payload fields within the MAC payload field.
   --
   --  If Payload_IEs_Present is True, then the payload IE list and any nested
   --  IE lists are validated. Status is set to Success if and only if this
   --  validation is successful.
   --
   --  If Payload_IEs_Present is False, then the frame payload is the only
   --  field in the MAC payload.

end AdaBee.MAC.Frames.Payloads;
