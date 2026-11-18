--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Types and functions for keeping track of the size & positions of the the
--  main fields in a MAC frame.

with AdaBee.MAC.Frames.Headers.Decoder_Model;
with AdaBee.MAC.Frames.Info_Elements.Payloads;

package AdaBee.MAC.Frames.Layouts
  with SPARK_Mode, Always_Terminates
is

   ------------------
   -- Frame_Layout --
   ------------------

   type Frame_Layout is record
      Header_IEs_First : Positive;
      --  Index of the first byte of the header IEs in the frame buffer.

      Header_IEs_Last : Natural;
      --  Index of the last byte of the header IEs in the frame buffer.
      --  This is < Header_IEs_First when header IEs are not present.

      MAC_Payload_First : Positive;
      --  Index of the first byte of the MAC payload field in the frame buffer.
      --  This is also the first byte of the payload IEs, if they are present.

      MAC_Payload_Last : Natural;
      --  Index of the last byte of the MAC payload field in the frame buffer.
      --  This is < MAC_Payload_First when the MAC payload is not present.

      Payload_IEs_Last : Natural;
      --  Index of the last byte of the payload IEs in the frame buffer.
      --  This is < MAC_Payload_First when the payload IEs are not present.
   end record
   with Predicate => Payload_IEs_Last <= MAC_Payload_Last;
   --  Stores the first/last indices that mark the positions of the following
   --  fields in the frame (See Figure 7-1 of IEEE 802.15.4-2024):
   --   * header IEs
   --   * payload IEs
   --   * frame payload

   ----------------
   -- Attributes --
   ----------------

   function Has_Header_IEs (Layout : Frame_Layout) return Boolean
   is (Layout.Header_IEs_Last >= Layout.Header_IEs_First);
   --  Returns True if the header IE list is not empty in the frame layout

   function Has_MAC_Payload (Layout : Frame_Layout) return Boolean
   is (Layout.MAC_Payload_Last >= Layout.MAC_Payload_First);
   --  Returns True if the MAC payload is not empty in the frame layout

   function Has_Payload_IEs (Layout : Frame_Layout) return Boolean
   is (Layout.Payload_IEs_Last >= Layout.MAC_Payload_First);
   --  Returns True if the payload IE list is not empty in the frame layout

   function Has_Frame_Payload (Layout : Frame_Layout) return Boolean
   is (Layout.MAC_Payload_First <= Layout.MAC_Payload_Last
       and then Layout.Payload_IEs_Last < Layout.MAC_Payload_Last);
   --  Returns True if the frame payload is not empty in the frame layout

   function Frame_Payload_First (Layout : Frame_Layout) return Positive
   is (if Layout.Payload_IEs_Last < Layout.MAC_Payload_First
       then Layout.MAC_Payload_First
       else Layout.Payload_IEs_Last + 1)
   with Pre => Has_Frame_Payload (Layout);
   --  Get the index of the first byte of the frame payload field

   function Header_IEs_Length (Layout : Frame_Layout) return Natural
   is (if Has_Header_IEs (Layout)
       then (Layout.Header_IEs_Last - Layout.Header_IEs_First) + 1
       else 0);
   --  Returns the length (in bytes) of the header IEs part of the frame

   function MAC_Payload_Length (Layout : Frame_Layout) return Natural
   is (if Has_MAC_Payload (Layout)
       then (Layout.MAC_Payload_Last - Layout.MAC_Payload_First) + 1
       else 0);
   --  Returns the length (in bytes) of the MAC payload part of the frame

   function Payload_IEs_Length (Layout : Frame_Layout) return Natural
   is (if Has_Payload_IEs (Layout)
       then (Layout.Payload_IEs_Last - Layout.MAC_Payload_First) + 1
       else 0);
   --  Returns the length (in bytes) of the payload IEs part of the frame

   function Frame_Payload_Length (Layout : Frame_Layout) return Natural
   is (if Has_Frame_Payload (Layout)
       then (Layout.MAC_Payload_Last - Frame_Payload_First (Layout)) + 1
       else 0);
   --  Returns the length (in bytes) of the frame payload part of the frame

   function Header_IEs_In_Range
     (Layout : Frame_Layout; Buffer : Byte_Array) return Boolean
   is (if Has_Header_IEs (Layout)
       then
         Layout.Header_IEs_First >= Buffer'First
         and then Layout.Header_IEs_Last <= Buffer'Last);
   --  Returns True if the header IEs range in the Layout is within range of
   --  Buffer.

   function MAC_Payload_In_Range
     (Layout : Frame_Layout; Buffer : Byte_Array) return Boolean
   is (if Has_MAC_Payload (Layout)
       then
         Layout.MAC_Payload_First >= Buffer'First
         and then Layout.MAC_Payload_Last <= Buffer'Last);
   --  Returns True if the MAC payload range in the Layout is within range of
   --  Buffer.

   ------------------
   -- Formal Model --
   ------------------

   --  The formal model defines the mapping between a Frame_Layout and the
   --  Decoder_Model.

   package Formal_Model
     with Ghost
   is

      function MAC_Header_Layout_Matches_Model
        (Frame : Byte_Array; Layout : Layouts.Frame_Layout) return Boolean
      is (
          --  Header IEs presence
          Has_Header_IEs (Layout)
          = Headers.Decoder_Model.Is_Header_IEs_Present (Frame)

          and then
            (if Has_Header_IEs (Layout)
             then
               --  Header_IEs_First denotes the first byte of the header IE
               --  list.
               Layout.Header_IEs_First
               = Frame'First
                 + Headers.Decoder_Model.Get_Header_IEs_Offset (Frame)

               --  Header_IEs_First denotes the last byte of the header IE
               --  list.
               and then
                 Layout.Header_IEs_Last
                 = Layout.Header_IEs_First
                   + (Headers.Decoder_Model.Get_Header_IEs_Length (Frame)
                      - 1)))
      with Pre => Headers.Decoder_Model.Is_MHR_Valid (Frame);

      function MAC_Payload_Layout_Matches_Model
        (Frame : Byte_Array; Layout : Layouts.Frame_Layout) return Boolean
      is (
          --  MAC payload presence
          Has_MAC_Payload (Layout)
          = Headers.Decoder_Model.Is_MAC_Payload_Present (Frame)

          --  Payload IEs presence
          and then
            (Has_Payload_IEs (Layout)
             = Headers.Decoder_Model.Is_Payload_IE_Present (Frame))

          and then
            (if Has_MAC_Payload (Layout)
             then
               --  MAC_Payload_First denotes the first byte of the MAC payload
               --  field.
               Layout.MAC_Payload_First
               = Frame'First
                 + Headers.Decoder_Model.Get_MAC_Payload_Offset (Frame)

               --  MAC_Payload_Last denotes the last byte of the MAC payload
               --  field.
               and then
                 (Layout.MAC_Payload_Last - Layout.MAC_Payload_First) + 1
                 = Headers.Decoder_Model.Get_MAC_Payload_Length (Frame)

               --  Payload_IEs_Last does not exceed the MAC payload field
               and then Layout.Payload_IEs_Last <= Layout.MAC_Payload_Last

               --  Payload_IEs_Last denotes the last byte of the payload IE
               --  list.
               and then
                 (if Has_Payload_IEs (Layout)
                  then
                    Layout.Payload_IEs_Last
                    = Layout.MAC_Payload_First
                      + (Info_Elements
                           .Payloads
                           .Lists
                           .Formal_Model
                           .IE_List_Length
                              (Headers.Decoder_Model.Get_MAC_Payload_Content
                                 (Frame))
                         - 1))))
      with
        Pre =>
          Headers.Decoder_Model.Is_MHR_Valid (Frame)
          and then
            (if Headers.Decoder_Model.Is_Payload_IE_Present (Frame)
             then
               Info_Elements.Payloads.Lists.Formal_Model.Valid_IE_List
                 (Headers.Decoder_Model.Get_MAC_Payload_Content (Frame)));

      function Layout_Matches_Model
        (Frame : Byte_Array; Layout : Layouts.Frame_Layout) return Boolean
      is (MAC_Header_Layout_Matches_Model (Frame, Layout)
          and then MAC_Payload_Layout_Matches_Model (Frame, Layout))
      with
        Pre =>
          Headers.Decoder_Model.Is_MHR_Valid (Frame)
          and then
            (if Headers.Decoder_Model.Is_Payload_IE_Present (Frame)
             then
               Info_Elements.Payloads.Lists.Formal_Model.Valid_IE_List
                 (Headers.Decoder_Model.Get_MAC_Payload_Content (Frame)));

   end Formal_Model;

end AdaBee.MAC.Frames.Layouts;
