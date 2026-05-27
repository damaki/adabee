--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Formal model of the MAC header encoder
--
--  @description
--  This package provides a formal specification for the encoding of a
--  MAC_Header data structure into the frame buffer in the format described
--  by IEEE 802.15.4-2024
--
--  The formal model consists of three parts:
--    * MAC Header Layout Model - Defines the position and length of each
--      field in the MAC header, based on the content of the MAC_Header record.
--    * Equality Helpers - Provides some helper functions for checking
--      equality of values at arbitrary positions in the frame buffer.
--    * MAC Header Equality - Defines equality between the MAC_Header
--      record and the contents of the encoded frame buffer.
--
--  The model is defined in a functional style using expression functions and
--  is not expected to be efficient at run-time. It is therefore defined as
--  ghost code as it is intended for specification only.

with AdaBee.MAC.Frames.Headers.Decoder_Model;

package AdaBee.MAC.Frames.Headers.Encoder_Model
  with Ghost, Pure, SPARK_Mode, Always_Terminates
is
   use type Interfaces.Unsigned_8;

   -----------------------------
   -- MAC Header Layout Model --
   -----------------------------

   --  These functions provide information about the frame layout based on
   --  the information in a MAC_Header record.

   function Get_Frame_Control_Length (MHR : Valid_MAC_Header) return Natural
   is (if MHR.Long_Frame_Control = Short then 1 else 2)
   with Post => Get_Frame_Control_Length'Result in 1 .. 2;

   function Get_Sequence_Number_Offset (MHR : Valid_MAC_Header) return Natural
   is (Get_Frame_Control_Length (MHR))
   with Post => Get_Sequence_Number_Offset'Result in 1 .. 2;

   function Get_Sequence_Number_Length (MHR : Valid_MAC_Header) return Natural
   is (if MHR.Sequence_Number.Suppression = Suppressed then 0 else 1)
   with Post => Get_Sequence_Number_Length'Result in 0 .. 1;

   function Get_Destination_PAN_ID_Offset
     (MHR : Valid_MAC_Header) return Natural
   is (Get_Sequence_Number_Offset (MHR) + Get_Sequence_Number_Length (MHR))
   with Post => Get_Destination_PAN_ID_Offset'Result in 1 .. 3;

   function Get_Destination_PAN_ID_Length
     (MHR : Valid_MAC_Header) return Natural
   is (if MHR.Destination_PAN_ID.Present then 2 else 0)
   with Post => Get_Destination_PAN_ID_Length'Result in 0 | 2;

   function Get_Destination_Address_Offset
     (MHR : Valid_MAC_Header) return Natural
   is (Get_Destination_PAN_ID_Offset (MHR)
       + Get_Destination_PAN_ID_Length (MHR))
   with Post => Get_Destination_Address_Offset'Result in 1 .. 5;

   function Get_Destination_Address_Length
     (MHR : Valid_MAC_Header) return Natural
   is (Address_Length (MHR.Destination_Address.Mode))
   with Post => Get_Destination_Address_Length'Result in 0 | 2 | 8;

   function Get_Source_PAN_ID_Offset (MHR : Valid_MAC_Header) return Natural
   is (Get_Destination_Address_Offset (MHR)
       + Get_Destination_Address_Length (MHR))
   with Post => Get_Source_PAN_ID_Offset'Result in 1 .. 13;

   function Get_Source_PAN_ID_Length (MHR : Valid_MAC_Header) return Natural
   is (if not Same_PAN_ID (MHR.Destination_PAN_ID, MHR.Source_PAN_ID)
         and then MHR.Source_PAN_ID.Present
       then 2
       else 0)
   with Post => Get_Source_PAN_ID_Length'Result in 0 | 2;

   function Get_Source_Address_Offset (MHR : Valid_MAC_Header) return Natural
   is (Get_Source_PAN_ID_Offset (MHR) + Get_Source_PAN_ID_Length (MHR))
   with Post => Get_Source_Address_Offset'Result in 1 .. 15;

   function Get_Source_Address_Length (MHR : Valid_MAC_Header) return Natural
   is (Address_Length (MHR.Source_Address.Mode))
   with Post => Get_Source_Address_Length'Result in 0 | 2 | 8;

   function Get_Aux_Security_Header_Offset
     (MHR : Valid_MAC_Header) return Natural
   is (Get_Source_Address_Offset (MHR) + Get_Source_Address_Length (MHR))
   with Post => Get_Aux_Security_Header_Offset'Result in 1 .. 23;

   function Get_Aux_Security_Header_Length
     (MHR : Valid_MAC_Header) return Natural
   with Post => Get_Aux_Security_Header_Length'Result in 0 .. 14;

   function Get_Security_Control_Offset (MHR : Valid_MAC_Header) return Natural
   renames Get_Aux_Security_Header_Offset;

   function Get_Security_Control_Length (MHR : Valid_MAC_Header) return Natural
   is (if MHR.Aux_Security_Header.Security_Enabled = Enabled then 1 else 0)
   with Post => Get_Security_Control_Length'Result in 0 .. 1;

   function Get_Frame_Counter_Offset (MHR : Valid_MAC_Header) return Natural
   is (Get_Security_Control_Offset (MHR) + Get_Security_Control_Length (MHR))
   with Post => Get_Frame_Counter_Offset'Result in 1 .. 24;

   function Get_Frame_Counter_Length (MHR : Valid_MAC_Header) return Natural
   is (if MHR.Aux_Security_Header.Security_Enabled = Enabled
         and then
           MHR.Aux_Security_Header.Frame_Counter.Suppression = Not_Suppressed
       then 4
       else 0)
   with Post => Get_Frame_Counter_Length'Result in 0 | 4;

   function Get_Key_ID_Offset (MHR : Valid_MAC_Header) return Natural
   is (Get_Frame_Counter_Offset (MHR) + Get_Frame_Counter_Length (MHR))
   with Post => Get_Key_ID_Offset'Result in 1 .. 28;

   function Get_Key_ID_Length (MHR : Valid_MAC_Header) return Natural
   is (if MHR.Aux_Security_Header.Security_Enabled = Disabled
       then 0
       else Key_ID_Length (MHR.Aux_Security_Header.Key_ID.Mode))
   with Post => Get_Key_ID_Length'Result in 0 | 1 | 5 | 9;

   function MHR_Length_Excluding_IEs (MHR : Valid_MAC_Header) return Natural
   is (Get_Frame_Control_Length (MHR)
       + Get_Sequence_Number_Length (MHR)
       + Get_Destination_PAN_ID_Length (MHR)
       + Get_Destination_Address_Length (MHR)
       + Get_Source_PAN_ID_Length (MHR)
       + Get_Source_Address_Length (MHR)
       + Get_Aux_Security_Header_Length (MHR))
   with Post => MHR_Length_Excluding_IEs'Result in 1 .. Max_MHR_Length;

   -------------------------
   -- Equality Helpers --
   -------------------------

   --  These sections decode individual fields from arbitrary positions in the
   --  frame buffer and check them for equivalence against provided values.

   function Sequence_Number_Equal_At
     (Frame : Byte_Array; Offset : Natural; SN : Variant_Sequence_Number)
      return Boolean
   is (if SN.Suppression = Not_Suppressed
       then SN.Number = Frame (Frame'First + Offset))
   with Pre => (if SN.Suppression = Not_Suppressed then Offset < Frame'Length);

   function PAN_ID_Equal_At
     (Frame : Byte_Array; Offset : Natural; PAN_ID : Variant_PAN_ID)
      return Boolean
   is (if PAN_ID.Present
       then
         PAN_ID.PAN_ID
         = From_Bytes
             (Frame (Frame'First + Offset .. Frame'First + Offset + 1)))
   with Pre => (if PAN_ID.Present then Offset <= Frame'Length - 2);

   function Address_Equal_At
     (Frame : Byte_Array; Offset : Natural; Address : Variant_Address)
      return Boolean
   is (case Address.Mode is
         when Not_Present => True,

         when Short       =>
           Address.Short_Address
           = From_Bytes
               (Frame (Frame'First + Offset .. Frame'First + Offset + 1)),

         when Extended    =>
           Address.Extended_Address
           = From_Bytes
               (Frame (Frame'First + Offset .. Frame'First + Offset + 7)))
   with Pre => Offset <= Frame'Length - Address_Length (Address.Mode);

   function Security_Control_Equal_At
     (Frame : Byte_Array; Offset : Natural; SC : Security_Control_Field)
      return Boolean
   is (SC = Decoder_Model.Get_Security_Control_At (Frame, Offset))
   with Pre => Offset < Frame'Length;

   function Frame_Counter_Equal_At
     (Frame : Byte_Array; Offset : Natural; FC : Variant_Frame_Counter)
      return Boolean
   is (if FC.Suppression = Not_Suppressed
       then
         FC.Frame_Counter
         = From_Bytes
             (Frame (Frame'First + Offset .. Frame'First + Offset + 3)))
   with
     Pre =>
       (if FC.Suppression = Not_Suppressed then Offset <= Frame'Length - 4);

   function Key_ID_Equal_At
     (Frame : Byte_Array; Offset : Natural; Key_ID : Variant_Key_ID)
      return Boolean
   is (case Key_ID.Mode is
         when 0 => True,

         when 1 =>
           Key_ID.Key_Index = Key_Index_Field (Frame (Frame'First + Offset)),

         when 2 =>
           Key_ID.Key_Index = Key_Index_Field (Frame (Frame'First + Offset))
           and then
             Key_ID.Key_Source_4
             = Key_Source_Field
                 (Frame
                    (Frame'First + Offset + 1 .. Frame'First + Offset + 4)),

         when 3 =>
           Key_ID.Key_Index = Key_Index_Field (Frame (Frame'First + Offset))
           and then
             Key_ID.Key_Source_8
             = Key_Source_Field
                 (Frame
                    (Frame'First + Offset + 1 .. Frame'First + Offset + 8)))
   with Pre => Offset <= Frame'Length - Key_ID_Length (Key_ID.Mode);

   -------------------------
   -- MAC Header Equality --
   -------------------------

   --  These functions define equality between the MAC_Header and encoded
   --  frame for each field in the MHR.

   function Frame_Control_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (Decoder_Model.Frame_Control_Valid (Frame)

       --  Compare Frame Control fields that are in all frame types
       and then MHR.Frame_Type = Decoder_Model.Get_Frame_Type (Frame)
       and then MHR.Frame_Pending = Decoder_Model.Get_Frame_Pending (Frame)
       and then MHR.AR = Decoder_Model.Get_Ack_Required (Frame)
       and then MHR.IE_Present = Decoder_Model.Get_IE_Present (Frame)
       and then MHR.Frame_Version = Decoder_Model.Get_Frame_Version (Frame)
       and then
         MHR.Destination_Address.Mode
         = Decoder_Model.Get_Dest_Address_Mode (Frame)
       and then
         MHR.Source_Address.Mode = Decoder_Model.Get_Src_Address_Mode (Frame)
       and then
         MHR.Aux_Security_Header.Security_Enabled
         = Decoder_Model.Get_Security_Enabled (Frame)
       and then
         MHR.Sequence_Number.Suppression
         = Decoder_Model.Get_Seq_Number_Suppression (Frame)

       --  Compare "PAN ID present" field for Multipurpose frame type
       and then
         (if MHR.Frame_Type = Multipurpose
          then
            MHR.Long_Frame_Control
            = Decoder_Model.Get_MP_S_FC (Frame).Long_Frame_Control
            and then
              (if MHR.Long_Frame_Control = Short
               then not MHR.Destination_PAN_ID.Present
               else
                 MHR.Destination_PAN_ID.Present
                 = (Decoder_Model.Get_MP_L_FC (Frame).PAN_ID_Present
                    = Present)))

       --  Compare the "PAN ID compression" field for general frame types
       and then
         (if MHR.Frame_Type in Beacon | Data | Ack | MAC_Command
          then
            Decoder_Model.Get_FC (Frame).PAN_ID_Compression
            = PAN_ID_Model.Get_PAN_ID_Compression
                (Frame_Version              => MHR.Frame_Version,
                 Destination_Address_Mode   => MHR.Destination_Address.Mode,
                 Source_Address_Mode        => MHR.Source_Address.Mode,
                 Destination_PAN_ID_Present => MHR.Destination_PAN_ID.Present,
                 Source_PAN_ID_Present      =>
                   Compressed_Source_PAN_ID
                     (Destination_PAN_ID => MHR.Destination_PAN_ID,
                      Source_PAN_ID      => MHR.Source_PAN_ID)
                     .Present)));
   --  Returns True if the Frame Control field in a frame buffer is equivalent
   --  to the information in a MAC_Header record.

   function Sequence_Number_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (Sequence_Number_Equal_At
         (Frame, Get_Sequence_Number_Offset (MHR), MHR.Sequence_Number))
   with
     Pre =>
       Frame'Length
       >= Get_Sequence_Number_Offset (MHR) + Get_Sequence_Number_Length (MHR);

   function Destination_PAN_ID_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (if MHR.Destination_PAN_ID.Present
       then
         PAN_ID_Equal_At
           (Frame,
            Get_Destination_PAN_ID_Offset (MHR),
            MHR.Destination_PAN_ID))
   with
     Pre =>
       Frame'Length
       >= Get_Destination_PAN_ID_Offset (MHR)
          + Get_Destination_PAN_ID_Length (MHR);

   function Destination_Address_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (if MHR.Destination_Address.Mode /= Not_Present
       then
         Address_Equal_At
           (Frame,
            Get_Destination_Address_Offset (MHR),
            MHR.Destination_Address))
   with
     Pre =>
       Frame'Length
       >= Get_Destination_Address_Offset (MHR)
          + Get_Destination_Address_Length (MHR);

   function Source_PAN_ID_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (declare
         Source_PAN_ID : constant Variant_PAN_ID :=
           Compressed_Source_PAN_ID
             (Destination_PAN_ID => MHR.Destination_PAN_ID,
              Source_PAN_ID      => MHR.Source_PAN_ID);
       begin
         (if Source_PAN_ID.Present
          then
            PAN_ID_Equal_At
              (Frame, Get_Source_PAN_ID_Offset (MHR), Source_PAN_ID)))
   with
     Pre =>
       Frame'Length
       >= Get_Source_PAN_ID_Offset (MHR) + Get_Source_PAN_ID_Length (MHR);

   function Source_Address_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (if MHR.Source_Address.Mode /= Not_Present
       then
         Address_Equal_At
           (Frame, Get_Source_Address_Offset (MHR), MHR.Source_Address))
   with
     Pre =>
       Frame'Length
       >= Get_Source_Address_Offset (MHR) + Get_Source_Address_Length (MHR);

   function Security_Control_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (if MHR.Aux_Security_Header.Security_Enabled = Enabled
       then
         (declare
            SC : constant Security_Control_Field :=
              Decoder_Model.Get_Security_Control_At
                (Frame, Get_Security_Control_Offset (MHR));
          begin
            SC.Security_Level = MHR.Aux_Security_Header.Security_Level
            and then SC.Key_ID_Mode = MHR.Aux_Security_Header.Key_ID.Mode
            and then
              SC.FC_Suppression
              = MHR.Aux_Security_Header.Frame_Counter.Suppression
            and then SC.Nonce_Source = MHR.Aux_Security_Header.ASN_In_Nonce))
   with
     Pre =>
       (if MHR.Aux_Security_Header.Security_Enabled = Enabled
        then
          Frame'Length
          >= Get_Security_Control_Offset (MHR)
             + Get_Security_Control_Length (MHR));

   function Frame_Counter_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (if MHR.Aux_Security_Header.Security_Enabled = Enabled
       then
         Frame_Counter_Equal_At
           (Frame,
            Get_Frame_Counter_Offset (MHR),
            MHR.Aux_Security_Header.Frame_Counter))
   with
     Pre =>
       (if MHR.Aux_Security_Header.Security_Enabled = Enabled
        then
          Frame'Length
          >= Get_Frame_Counter_Offset (MHR) + Get_Frame_Counter_Length (MHR));

   function Key_ID_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (if MHR.Aux_Security_Header.Security_Enabled = Enabled
       then
         Key_ID_Equal_At
           (Frame, Get_Key_ID_Offset (MHR), MHR.Aux_Security_Header.Key_ID))
   with
     Pre =>
       (if MHR.Aux_Security_Header.Security_Enabled = Enabled
        then
          Frame'Length >= Get_Key_ID_Offset (MHR) + Get_Key_ID_Length (MHR));

   function Aux_Security_Header_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (Security_Control_Equal (MHR, Frame)
       and then Frame_Counter_Equal (MHR, Frame)
       and then Key_ID_Equal (MHR, Frame))
   with
     Pre =>
       (if MHR.Aux_Security_Header.Security_Enabled = Enabled
        then
          Frame'Length >= Get_Key_ID_Offset (MHR) + Get_Key_ID_Length (MHR));

   function MHR_Equal_Excluding_IEs
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (Frame_Control_Equal (MHR, Frame)
       and then Sequence_Number_Equal (MHR, Frame)
       and then Destination_PAN_ID_Equal (MHR, Frame)
       and then Destination_Address_Equal (MHR, Frame)
       and then Source_PAN_ID_Equal (MHR, Frame)
       and then Source_Address_Equal (MHR, Frame)
       and then Security_Control_Equal (MHR, Frame)
       and then Frame_Counter_Equal (MHR, Frame)
       and then Key_ID_Equal (MHR, Frame))
   with Pre => Frame'Length >= MHR_Length_Excluding_IEs (MHR);

private

   ------------------------------------
   -- Get_Aux_Security_Header_Length --
   ------------------------------------

   function Get_Aux_Security_Header_Length
     (MHR : Valid_MAC_Header) return Natural
   is (Get_Security_Control_Length (MHR)
       + Get_Frame_Counter_Length (MHR)
       + Get_Key_ID_Length (MHR));

end AdaBee.MAC.Frames.Headers.Encoder_Model;
