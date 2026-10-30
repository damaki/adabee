--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Info_Elements.Payloads;

--  This package provides utilties for decoding the MAC payload field of
--  a MAC frame.

package AdaBee.MAC.Frames.Payloads
  with Elaborate_Body, SPARK_Mode, Always_Terminates
is

   procedure Decode_MAC_Payload_Layout
     (Buffer              : Byte_Array;
      Layout              : in out Frame_Layout;
      Payload_IEs_Present : Boolean;
      Status              : out Status_Code)
   with
     Global => null,
     Pre    =>
       Layout.MAC_Payload_First <= Layout.MAC_Payload_Last
       and then Layout.MAC_Payload_First >= Buffer'First
       and then Layout.MAC_Payload_Last <= Buffer'Last,
     Post   =>
       --  Unchanged layout fields
       Layout.Header_IEs_First = Layout'Old.Header_IEs_First
       and then Layout.Header_IEs_Last = Layout'Old.Header_IEs_Last
       and then Layout.MAC_Payload_First = Layout'Old.MAC_Payload_First
       and then Layout.MAC_Payload_Last = Layout'Old.MAC_Payload_Last

       --  Status is set to Success if and only if the payload IE list was
       --  correctly parsed.
       and then
         (Status = Success)
         = (not Payload_IEs_Present
            or else
              Info_Elements.Payloads.Lists.Formal_Model.Valid_IE_List
                (Buffer (Layout.MAC_Payload_First .. Layout.MAC_Payload_Last)))

       and then
         (if Status = Success
          then
            --  Payload_IEs_Last is after the MAC payload start if payload IEs
            --  are present.
            (Layout.Payload_IEs_Last > Layout.MAC_Payload_First)
            = Payload_IEs_Present

            --  Payload_IEs_Last does not exceed the end of the MAC payload
            and then Layout.Payload_IEs_Last <= Layout.MAC_Payload_Last

            and then
              (if Payload_IEs_Present
               then
                 --  The slice of Buffer containing the payload IEs is a valid
                 --  IE list.
                 Info_Elements.Payloads.Lists.Formal_Model.Valid_IE_List
                   (Buffer
                      (Layout.MAC_Payload_First .. Layout.Payload_IEs_Last))

                 --  The calculated length of the payload IE list correctly
                 --  matches the actual length of the IE list in the buffer.
                 and then
                   Payload_IEs_Length (Layout)
                   = Info_Elements.Payloads.Lists.Formal_Model.IE_List_Length
                       (Buffer
                          (Layout.MAC_Payload_First
                           .. Layout.MAC_Payload_Last)))

            --  If payload IEs are not present, then the frame payload makes
            --  up the entirety of the MAC payload.
            and then
              (if not Payload_IEs_Present
               then
                 Frame_Payload_Length (Layout) = MAC_Payload_Length (Layout)));
   --  Determines the positions and size of the payload IEs and the frame
   --  payload fields of the MAC payload field.
   --
   --  If Payload_IEs_Present is True, then the payload IE list is validated;
   --  Status is set to Success if and only if this validation is successful.
   --  If Payload_IEs_Present is False, then the frame payload is the only
   --  field in the MAC payload.

end AdaBee.MAC.Frames.Payloads;
