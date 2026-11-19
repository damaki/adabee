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

       --  The positions & sizes of the header IEs and MAC header part of the
       --  frame must already be calculated in the Layout.
       and then
         Layouts.Formal_Model.MAC_Header_Layout_Matches_Model (Frame, Layout)
       and then
         Layouts.Formal_Model.MAC_Payload_Layout_Matches_Model (Frame, Layout),
     Post   =>
       --  Unchanged layout fields
       Layout.Header_IEs_First = Layout'Old.Header_IEs_First
       and then Layout.Header_IEs_Last = Layout'Old.Header_IEs_Last
       and then Layout.MAC_Payload_First = Layout'Old.MAC_Payload_First
       and then Layout.MAC_Payload_Last = Layout'Old.MAC_Payload_Last

       --  Status is set to Success if and only if either a) there are no
       --  payload IEs to decode, or b) there is a valid payload IE list in
       --  the MAC payload field of the frame.
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
          then
            Layouts.Formal_Model.Layout_Matches_Model (Frame, Layout)

            and then
              (if Payload_IEs_Present
               then
                 --  The payload IE list is valid for the slice of the
                 --  MAC payload up to Payload_IEs_Last
                 Info_Elements.Payloads.Lists.Formal_Model.Valid_IE_List
                   (Frame
                      (Layout.MAC_Payload_First .. Layout.Payload_IEs_Last))

                 --  The nested IE lists are valid for the payload IEs list in
                 --  the slice of the MAC payload up to Payload_IEs_Last
                 and then
                   Info_Elements.Payloads.Nested_IE_Lists_Valid
                     (Frame
                        (Layout.MAC_Payload_First
                         .. Layout.Payload_IEs_Last))));
   --  Determines the positions and sizes of the Payload IE and Frame Payload
   --  sub-fields within the MAC payload field.
   --
   --  Payload_IEs_Present determines whether the payload IEs are present in
   --  the frame. When this is false, then the Frame Payload sub-field fills
   --  the entire MAC payload field.
   --
   --  When payload IEs are present, then the list (and any nested IE lists)
   --  are validated, and Status is set to the result of this validation.

end AdaBee.MAC.Frames.Payloads;
