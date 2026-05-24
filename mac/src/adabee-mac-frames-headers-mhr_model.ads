--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Formal model of the MAC header fields
--
--  @description
--  This package formally defines each field in the MAC header. For each field
--  it defines:
--    * the conditions when the field is present in the frame;
--    * the offset (position) of the field in the frame, if it is present;
--    * the length of the field in the frame; and
--    * the value of the field, if it is present.
--
--  The model is defined in a functional style using expression functions and
--  is not expected to be efficient at run-time. It is therefore defined as
--  ghost code as it is intended for specification only.

with AdaBee.MAC.Frames.Info_Elements.Headers;

package AdaBee.MAC.Frames.Headers.MHR_Model
  with Ghost, Pure, SPARK_Mode, Always_Terminates
is
   use type Interfaces.Unsigned_8;
   use type AdaBee.MAC.Frames.Info_Elements.Headers.Element_ID_Field;

   package Header_IE_Model renames
     AdaBee.MAC.Frames.Info_Elements.Headers.Lists.IE_Model;

   -------------------------------
   -- Frame Control Field Views --
   -------------------------------

   --  These functions provide a view into the various Frame Control types
   --  at the start of the frame.

   function Get_MP_S_FC
     (Frame : Byte_Array) return MP_Short_Frame_Control_Field
   is (MP_Short_Frame_Control_Field'(From_Bytes (Frame (Frame'First))))
   with Pre => Frame'Length >= 1;
   --  Read the short (8-bit) multipurpose frame control field from the frame

   function Get_Frame_Type (Frame : Byte_Array) return Frame_Type_Field
   is (Get_MP_S_FC (Frame).Frame_Type)
   with Pre => Frame'Length > 0;
   --  Get the frame type field from the frame

   function Get_MP_L_FC (Frame : Byte_Array) return MP_Long_Frame_Control_Field
   is (MP_Long_Frame_Control_Field'
         (From_Bytes (Frame (Frame'First .. Frame'First + 1))))
   with Pre => Frame'Length >= 2;
   --  Read the long (16-bit) multipurpose frame control field from the frame

   function Get_FC (Frame : Byte_Array) return Frame_Control_Field
   is (Frame_Control_Field'
         (From_Bytes (Frame (Frame'First .. Frame'First + 1))))
   with Pre => Frame'Length >= 2;
   --  Read the general frame control field from the frame

   ----------------------
   -- Field Type Views --
   ----------------------

   --  These functions provide views to different kinds of MHR fields at
   --  arbitrary locations in a frame.

   function Get_Sequence_Number_At
     (Frame       : Byte_Array;
      Offset      : Natural;
      Suppression : Seq_Number_Suppression_Field)
      return Variant_Sequence_Number
   is (case Suppression is
         when Suppressed     =>
           Variant_Sequence_Number'(Suppression => Suppressed),
         when Not_Suppressed =>
           Variant_Sequence_Number'
             (Suppression => Not_Suppressed,
              Number      => Frame (Frame'First + Offset)))
   with Pre => (if Suppression = Not_Suppressed then Offset < Frame'Length);

   function Sequence_Number_Equal_At
     (Frame : Byte_Array; Offset : Natural; SN : Variant_Sequence_Number)
      return Boolean
   is (if SN.Suppression = Not_Suppressed
       then SN.Number = Frame (Frame'First + Offset))
   with Pre => (if SN.Suppression = Not_Suppressed then Offset < Frame'Length);

   function Get_PAN_ID_At
     (Frame : Byte_Array; Offset : Natural) return PAN_ID_Field
   is (From_Bytes (Frame (Frame'First + Offset .. Frame'First + Offset + 1)))
   with Pre => Offset <= Frame'Length - 2;
   --  Reads a PAN ID field from the frame at the specified offset

   function Get_PAN_ID_At
     (Frame : Byte_Array; Offset : Natural; Present : Boolean)
      return Variant_PAN_ID
   is (if Present
       then
         Variant_PAN_ID'
           (Present => True,
            PAN_ID  =>
              From_Bytes
                (Frame (Frame'First + Offset .. Frame'First + Offset + 1)))
       else Variant_PAN_ID'(Present => False))
   with
     Pre  => (if Present then Offset <= Frame'Length - 2),
     Post => Get_PAN_ID_At'Result.Present = Present;

   function PAN_ID_Equal_At
     (Frame : Byte_Array; Offset : Natural; PAN_ID : Variant_PAN_ID)
      return Boolean
   is (if PAN_ID.Present
       then
         PAN_ID.PAN_ID
         = From_Bytes
             (Frame (Frame'First + Offset .. Frame'First + Offset + 1)))
   with Pre => (if PAN_ID.Present then Offset <= Frame'Length - 2);

   function Get_Address_At
     (Frame : Byte_Array; Offset : Natural; Mode : Valid_Address_Mode_Field)
      return Variant_Address
   is (case Mode is
         when Not_Present => Variant_Address'(Mode => Not_Present),
         when Short       =>
           Variant_Address'
             (Mode          => Short,
              Short_Address =>
                From_Bytes
                  (Frame (Frame'First + Offset .. Frame'First + Offset + 1))),
         when Extended    =>
           Variant_Address'
             (Mode             => Extended,
              Extended_Address =>
                From_Bytes
                  (Frame (Frame'First + Offset .. Frame'First + Offset + 7))))
   with
     Pre  =>
       (if Mode /= Not_Present
        then Offset <= Frame'Length - Address_Length (Mode)),
     Post => Get_Address_At'Result.Mode = Mode;
   --  Reads an address field from the frame at the specified offset

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

   function Get_Security_Control_At
     (Frame : Byte_Array; Offset : Natural) return Security_Control_Field
   is (From_Bytes (Frame (Frame'First + Offset)))
   with Pre => Offset < Frame'Length;

   function Security_Control_Equal_At
     (Frame : Byte_Array; Offset : Natural; SC : Security_Control_Field)
      return Boolean
   is (SC = Get_Security_Control_At (Frame, Offset))
   with Pre => Offset < Frame'Length;

   function Get_Frame_Counter_At
     (Frame       : Byte_Array;
      Offset      : Natural;
      Suppression : Frame_Counter_Suppression_Field)
      return Variant_Frame_Counter
   is (case Suppression is
         when Suppressed     =>
           Variant_Frame_Counter'(Suppression => Suppressed),
         when Not_Suppressed =>
           Variant_Frame_Counter'
             (Suppression   => Not_Suppressed,
              Frame_Counter =>
                From_Bytes
                  (Frame (Frame'First + Offset .. Frame'First + Offset + 3))))
   with
     Pre  => (if Suppression = Not_Suppressed then Offset <= Frame'Length - 4),
     Post => Get_Frame_Counter_At'Result.Suppression = Suppression;

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

   function Get_Key_ID_At
     (Frame : Byte_Array; Offset : Natural; Mode : Key_ID_Mode_Field)
      return Variant_Key_ID
   is (case Mode is
         when 0 => Variant_Key_ID'(Mode => 0),
         when 1 =>
           Variant_Key_ID'
             (Mode      => 1,
              Key_Index => Key_Index_Field (Frame (Frame'First + Offset))),
         when 2 =>
           Variant_Key_ID'
             (Mode         => 2,
              Key_Index    => Key_Index_Field (Frame (Frame'First + Offset)),
              Key_Source_4 =>
                Key_Source_Field
                  (Frame
                     (Frame'First + Offset + 1 .. Frame'First + Offset + 4))),
         when 3 =>
           Variant_Key_ID'
             (Mode         => 3,
              Key_Index    => Key_Index_Field (Frame (Frame'First + Offset)),
              Key_Source_8 =>
                Key_Source_Field
                  (Frame
                     (Frame'First + Offset + 1 .. Frame'First + Offset + 8))))
   with
     Pre  => Offset <= Frame'Length - Key_ID_Length (Mode),
     Post => Get_Key_ID_At'Result.Mode = Mode;

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

   ----------------------
   -- MAC_Header Model --
   ----------------------

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

   -----------------------------
   -- Frame Control Accessors --
   -----------------------------

   function Frame_Control_Valid (Frame : Byte_Array) return Boolean
   is (Frame'Length > 0
       and then
         (case Get_Frame_Type (Frame) is
            when Unsupported_Frame_Types           => False,

            when Multipurpose                      =>
              Get_MP_S_FC (Frame).Dest_Address_Mode /= Reserved
              and then Get_MP_S_FC (Frame).Src_Address_Mode /= Reserved
              and then
                (if Get_MP_S_FC (Frame).Long_Frame_Control = Long
                 then
                   Frame'Length >= 2
                   and then
                     Get_MP_L_FC (Frame).Frame_Version = IEEE_802_15_4_2003),

            when Beacon | Data | Ack | MAC_Command =>
              Frame'Length >= 2
              and then Get_FC (Frame).Dest_Address_Mode /= Reserved
              and then Get_FC (Frame).Src_Address_Mode /= Reserved
              and then Get_FC (Frame).Frame_Version /= Reserved));
   --  Check if the frame contains a valid frame control field

   function Get_Dest_Address_Mode
     (Frame : Byte_Array) return Valid_Address_Mode_Field
   is (case Supported_Frame_Types (Get_Frame_Type (Frame)) is
         when Beacon | Data | Ack | MAC_Command =>
           Get_FC (Frame).Dest_Address_Mode,

         when Multipurpose                      =>
           Get_MP_S_FC (Frame).Dest_Address_Mode)
   with Pre => Frame_Control_Valid (Frame);
   --  Read the destination addressing mode from the frame control field

   function Get_Src_Address_Mode
     (Frame : Byte_Array) return Valid_Address_Mode_Field
   is (case Supported_Frame_Types (Get_Frame_Type (Frame)) is
         when Beacon | Data | Ack | MAC_Command =>
           Get_FC (Frame).Src_Address_Mode,

         when Multipurpose                      =>
           Get_MP_S_FC (Frame).Src_Address_Mode)
   with Pre => Frame_Control_Valid (Frame);
   --  Read the source addressing mode from the frame control field

   function Get_Frame_Control_Length (Frame : Byte_Array) return Natural
   is (case Supported_Frame_Types (Get_Frame_Type (Frame)) is
         when Beacon | Data | Ack | MAC_Command => 2,
         when Multipurpose                      =>
           (if Get_MP_S_FC (Frame).Long_Frame_Control = Long then 2 else 1))
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Frame_Control_Length'Result in 1 .. 2;
   --  Get the length of the frame control field in bytes
   --
   --  The frame control is 2 bytes long, except for multipurpose frames
   --  which have long frame control set to "short", in which case the frame
   --  control field is 1 byte. See IEEE 802.15.4-2024 Section 7.3.5.3

   function Get_Frame_Version
     (Frame : Byte_Array) return Valid_Frame_Version_Field
   is (if Get_Frame_Type (Frame) /= Multipurpose
       then Get_FC (Frame).Frame_Version
       elsif Get_MP_S_FC (Frame).Long_Frame_Control = Short
       then IEEE_802_15_4_2003
       else Get_MP_L_FC (Frame).Frame_Version)
   with Pre => Frame_Control_Valid (Frame);
   --  Read the frame version from the frame control field

   function Get_IE_Present (Frame : Byte_Array) return IE_Present_Field
   is (if Get_Frame_Type (Frame) /= Multipurpose
       then Get_FC (Frame).IE_Present
       elsif Get_MP_S_FC (Frame).Long_Frame_Control = Short
       then Not_Present
       else Get_MP_L_FC (Frame).IE_Present)
   with Pre => Frame_Control_Valid (Frame);
   --  Read the IE present bit from the frame control field

   function Get_Ack_Required (Frame : Byte_Array) return Ack_Required_Field
   is (if Get_Frame_Type (Frame) /= Multipurpose
       then Get_FC (Frame).AR
       elsif Get_MP_S_FC (Frame).Long_Frame_Control = Short
       then Not_Required
       else Get_MP_L_FC (Frame).Ack_Required)
   with Pre => Frame_Control_Valid (Frame);
   --  Read the frame ack required (AR) bit from the frame control field

   function Get_Frame_Pending (Frame : Byte_Array) return Frame_Pending_Field
   is (if Get_Frame_Type (Frame) /= Multipurpose
       then Get_FC (Frame).Frame_Pending
       elsif Get_MP_S_FC (Frame).Long_Frame_Control = Short
       then Not_Pending
       else Get_MP_L_FC (Frame).Frame_Pending)
   with Pre => Frame_Control_Valid (Frame);
   --  Read the frame pending bit from the frame control field

   function Get_Security_Enabled
     (Frame : Byte_Array) return Security_Enabled_Field
   is (if Get_Frame_Type (Frame) /= Multipurpose
       then Get_FC (Frame).Security_Enabled
       elsif Get_MP_S_FC (Frame).Long_Frame_Control = Short
       then Disabled
       else Get_MP_L_FC (Frame).Security_Enabled)
   with Pre => Frame_Control_Valid (Frame);
   --  Read the frame pending bit from the frame control field

   function Get_Seq_Number_Suppression
     (Frame : Byte_Array) return Seq_Number_Suppression_Field
   is (if Get_Frame_Type (Frame) /= Multipurpose
       then Get_FC (Frame).SN_Suppression
       elsif Get_MP_S_FC (Frame).Long_Frame_Control = Short
       then Suppressed
       else Get_MP_L_FC (Frame).SN_Suppression)
   with Pre => Frame_Control_Valid (Frame);
   --  Read the sequence number suppression bit from the frame control field

   function Frame_Control_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (Frame_Control_Valid (Frame)

       --  Compare Frame Control fields that are in all frame types
       and then MHR.Frame_Type = Get_Frame_Type (Frame)
       and then MHR.Frame_Pending = Get_Frame_Pending (Frame)
       and then MHR.AR = Get_Ack_Required (Frame)
       and then MHR.IE_Present = Get_IE_Present (Frame)
       and then MHR.Frame_Version = Get_Frame_Version (Frame)
       and then MHR.Destination_Address.Mode = Get_Dest_Address_Mode (Frame)
       and then MHR.Source_Address.Mode = Get_Src_Address_Mode (Frame)
       and then
         MHR.Aux_Security_Header.Security_Enabled
         = Get_Security_Enabled (Frame)
       and then
         MHR.Sequence_Number.Suppression = Get_Seq_Number_Suppression (Frame)

       --  Compare "PAN ID present" field for Multipurpose frame type
       and then
         (if MHR.Frame_Type = Multipurpose
          then
            MHR.Long_Frame_Control = Get_MP_S_FC (Frame).Long_Frame_Control
            and then
              (if MHR.Long_Frame_Control = Short
               then not MHR.Destination_PAN_ID.Present
               else
                 MHR.Destination_PAN_ID.Present
                 = (Get_MP_L_FC (Frame).PAN_ID_Present = Present)))

       --  Compare "PAN ID compression" field for general frame types
       and then
         (if MHR.Frame_Type in Beacon | Data | Ack | MAC_Command
          then
            Get_FC (Frame).PAN_ID_Compression
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

   ---------------------------
   -- Sequence Number Field --
   ---------------------------

   function Is_Sequence_Number_Present (Frame : Byte_Array) return Boolean
   is (case Supported_Frame_Types (Get_Frame_Type (Frame)) is
         when Beacon | Data | Ack | MAC_Command =>
           Get_FC (Frame).SN_Suppression = Not_Suppressed,

         when Multipurpose                      =>
           Get_MP_S_FC (Frame).Long_Frame_Control = Long
           and then Get_MP_L_FC (Frame).SN_Suppression = Not_Suppressed)
   with
     Pre  => Frame_Control_Valid (Frame),
     Post =>
       (if Is_Sequence_Number_Present'Result
        then Get_Frame_Control_Length (Frame) = 2);
   --  Returns True iff the frame contains the sequence number field

   function Get_Sequence_Number_Offset (Frame : Byte_Array) return Natural
   is (Get_Frame_Control_Length (Frame))
   with Pre => Frame_Control_Valid (Frame);
   --  Get the offset of the sequence number field relative to the start of
   --  the frame.
   --
   --  The sequence number is located immediately after the frame control field
   --
   --  Ref. IEEE 802.15.4-2024 Figure 7-1 and Figure 7-18

   function Get_Sequence_Number_Length (Frame : Byte_Array) return Natural
   is (if Is_Sequence_Number_Present (Frame) then 1 else 0)
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Sequence_Number_Length'Result in 0 .. 1;
   --  Get the length of the sequence number field.
   --
   --  If the sequence number is present, then it is 1 byte long.

   function Get_Sequence_Number
     (Frame : Byte_Array) return Variant_Sequence_Number
   is (if not Is_Sequence_Number_Present (Frame)
       then Variant_Sequence_Number'(Suppression => Suppressed)
       else
         Variant_Sequence_Number'
           (Suppression => Not_Suppressed,
            Number      =>
              Frame (Frame'First + Get_Sequence_Number_Offset (Frame))))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         (if Is_Sequence_Number_Present (Frame)
          then
            Frame'Length
            >= Get_Sequence_Number_Offset (Frame)
               + Get_Sequence_Number_Length (Frame));
   --  Read the sequence number field from the frame

   function Sequence_Number_Equal
     (Frame : Byte_Array; SN : Variant_Sequence_Number) return Boolean
   is ((SN.Suppression = Not_Suppressed) = Is_Sequence_Number_Present (Frame)
       and then
         Sequence_Number_Equal_At
           (Frame, Get_Sequence_Number_Offset (Frame), SN))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         (if Is_Sequence_Number_Present (Frame)
          then
            Frame'Length
            >= Get_Sequence_Number_Offset (Frame)
               + Get_Sequence_Number_Length (Frame));
   --  Returns True if the sequence number in SN is equal to the value in the
   --  frame.

   function Sequence_Number_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (Sequence_Number_Equal_At
         (Frame, Get_Sequence_Number_Offset (MHR), MHR.Sequence_Number))
   with
     Pre =>
       Frame'Length
       >= Get_Sequence_Number_Offset (MHR) + Get_Sequence_Number_Length (MHR);

   ------------------------------
   -- Destination PAN ID Field --
   ------------------------------

   function Is_Destination_PAN_ID_Present (Frame : Byte_Array) return Boolean
   is (case Supported_Frame_Types (Get_Frame_Type (Frame)) is
         when Beacon | Data | Ack | MAC_Command =>
           PAN_ID_Model.Is_Destination_PAN_ID_Present
             (Frame_Version            => Get_FC (Frame).Frame_Version,
              Destination_Address_Mode => Get_FC (Frame).Dest_Address_Mode,
              Source_Address_Mode      => Get_FC (Frame).Src_Address_Mode,
              PAN_ID_Compression       => Get_FC (Frame).PAN_ID_Compression),

         when Multipurpose                      =>
           (if Get_MP_S_FC (Frame).Long_Frame_Control = Long
            then Get_MP_L_FC (Frame).PAN_ID_Present = Present
            else False))
   with Pre => Frame_Control_Valid (Frame);
   --  Returns True if the destination PAN ID field is present in the frame

   function Get_Destination_PAN_ID_Offset (Frame : Byte_Array) return Natural
   is (Get_Sequence_Number_Offset (Frame) + Get_Sequence_Number_Length (Frame))
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Destination_PAN_ID_Offset'Result in 1 .. 3;
   --  Get the offset of the destination PAN ID field relative to the start
   --  of the frame.

   function Get_Destination_PAN_ID_Length (Frame : Byte_Array) return Natural
   is (if Is_Destination_PAN_ID_Present (Frame) then 2 else 0)
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Destination_PAN_ID_Length'Result in 0 | 2;
   --  Get the length of the destination PAN ID field

   function Get_Destination_PAN_ID (Frame : Byte_Array) return Variant_PAN_ID
   is (if Is_Destination_PAN_ID_Present (Frame)
       then
         Variant_PAN_ID'
           (Present => True,
            PAN_ID  =>
              Get_PAN_ID_At (Frame, Get_Destination_PAN_ID_Offset (Frame)))
       else Variant_PAN_ID'(Present => False))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         (if Is_Destination_PAN_ID_Present (Frame)
          then
            Frame'Length
            >= Get_Destination_PAN_ID_Offset (Frame)
               + Get_Destination_PAN_ID_Length (Frame));
   --  Read the destination PAN ID field from the frame

   function Destination_PAN_ID_Equal
     (Frame : Byte_Array; PAN_ID : Variant_PAN_ID) return Boolean
   is (PAN_ID.Present = Is_Destination_PAN_ID_Present (Frame)
       and then
         PAN_ID_Equal_At
           (Frame, Get_Destination_PAN_ID_Offset (Frame), PAN_ID))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         (if Is_Destination_PAN_ID_Present (Frame)
          then
            Frame'Length
            >= Get_Destination_PAN_ID_Offset (Frame)
               + Get_Destination_PAN_ID_Length (Frame));

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

   -------------------------------
   -- Destination Address Field --
   -------------------------------

   function Get_Destination_Address_Offset (Frame : Byte_Array) return Natural
   is (Get_Destination_PAN_ID_Offset (Frame)
       + Get_Destination_PAN_ID_Length (Frame))
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Destination_Address_Offset'Result in 1 .. 5;

   function Get_Destination_Address_Length (Frame : Byte_Array) return Natural
   is (Address_Length (Get_Dest_Address_Mode (Frame)))
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Destination_Address_Length'Result in 0 | 2 | 8;

   function Get_Destination_Address (Frame : Byte_Array) return Variant_Address
   is (if Get_Dest_Address_Mode (Frame) = Not_Present
       then Variant_Address'(Mode => Not_Present)
       else
         Get_Address_At
           (Frame,
            Get_Destination_Address_Offset (Frame),
            Get_Dest_Address_Mode (Frame)))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         Frame'Length
         >= Get_Destination_Address_Offset (Frame)
            + Get_Destination_Address_Length (Frame);

   function Destination_Address_Equal
     (Frame : Byte_Array; Address : Variant_Address) return Boolean
   is (Address.Mode = Get_Dest_Address_Mode (Frame)
       and then
         Address_Equal_At
           (Frame, Get_Destination_Address_Offset (Frame), Address))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         Frame'Length
         >= Get_Destination_Address_Offset (Frame)
            + Get_Destination_Address_Length (Frame);

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

   -------------------------
   -- Source PAN ID Field --
   -------------------------

   function Is_Source_PAN_ID_Present (Frame : Byte_Array) return Boolean
   is (case Supported_Frame_Types (Get_Frame_Type (Frame)) is
         when Beacon | Data | Ack | MAC_Command =>
           PAN_ID_Model.Is_Source_PAN_ID_Present
             (Frame_Version            => Get_FC (Frame).Frame_Version,
              Destination_Address_Mode => Get_FC (Frame).Dest_Address_Mode,
              Source_Address_Mode      => Get_FC (Frame).Src_Address_Mode,
              PAN_ID_Compression       => Get_FC (Frame).PAN_ID_Compression),

         when Multipurpose                      => False)
   with Pre => Frame_Control_Valid (Frame);

   function Get_Source_PAN_ID_Offset (Frame : Byte_Array) return Natural
   is (Get_Destination_Address_Offset (Frame)
       + Get_Destination_Address_Length (Frame))
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Source_PAN_ID_Offset'Result in 1 .. 13;

   function Get_Source_PAN_ID_Length (Frame : Byte_Array) return Natural
   is (if Is_Source_PAN_ID_Present (Frame) then 2 else 0)
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Source_PAN_ID_Length'Result in 0 | 2;

   function Get_Source_PAN_ID (Frame : Byte_Array) return Variant_PAN_ID
   is (if Is_Source_PAN_ID_Present (Frame)
       then
         Variant_PAN_ID'
           (Present => True,
            PAN_ID  => Get_PAN_ID_At (Frame, Get_Source_PAN_ID_Offset (Frame)))
       else Variant_PAN_ID'(Present => False))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         (if Is_Source_PAN_ID_Present (Frame)
          then
            Frame'Length
            >= Get_Source_PAN_ID_Offset (Frame)
               + Get_Source_PAN_ID_Length (Frame));
   --  Read the destination PAN ID field from the frame

   function Get_Decompressed_Source_PAN_ID
     (Frame : Byte_Array) return Variant_PAN_ID
   is (if Is_Source_PAN_ID_Present (Frame)
       then Get_Source_PAN_ID (Frame)
       elsif Get_Frame_Type (Frame) in Beacon | Data | Ack | MAC_Command
         and then
           PAN_ID_Model.Is_Source_PAN_ID_Compressed
             (Frame_Version            => Get_Frame_Version (Frame),
              Destination_Address_Mode => Get_Dest_Address_Mode (Frame),
              Source_Address_Mode      => Get_Src_Address_Mode (Frame),
              PAN_ID_Compression       => Get_FC (Frame).PAN_ID_Compression)
       then Get_Destination_PAN_ID (Frame)
       else Variant_PAN_ID'(Present => False))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         (if Is_Source_PAN_ID_Present (Frame)
          then
            Frame'Length
            >= Get_Source_PAN_ID_Offset (Frame)
               + Get_Source_PAN_ID_Length (Frame))
       and then
         (if Is_Destination_PAN_ID_Present (Frame)
          then
            Frame'Length
            >= Get_Destination_PAN_ID_Offset (Frame)
               + Get_Destination_PAN_ID_Length (Frame));

   function Source_PAN_ID_Equal
     (Frame : Byte_Array; PAN_ID : Variant_PAN_ID) return Boolean
   is (PAN_ID.Present = Is_Source_PAN_ID_Present (Frame)
       and then
         PAN_ID_Equal_At (Frame, Get_Source_PAN_ID_Offset (Frame), PAN_ID))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         (if Is_Source_PAN_ID_Present (Frame)
          then
            Frame'Length
            >= Get_Source_PAN_ID_Offset (Frame)
               + Get_Source_PAN_ID_Length (Frame));

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

   --------------------------
   -- Source Address Field --
   --------------------------

   function Get_Source_Address_Offset (Frame : Byte_Array) return Natural
   is (Get_Source_PAN_ID_Offset (Frame) + Get_Source_PAN_ID_Length (Frame))
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Source_Address_Offset'Result in 1 .. 15;

   function Get_Source_Address_Length (Frame : Byte_Array) return Natural
   is (Address_Length (Get_Src_Address_Mode (Frame)))
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Source_Address_Length'Result in 0 | 2 | 8;

   function Get_Source_Address (Frame : Byte_Array) return Variant_Address
   is (if Get_Src_Address_Mode (Frame) = Not_Present
       then Variant_Address'(Mode => Not_Present)
       else
         Get_Address_At
           (Frame,
            Get_Source_Address_Offset (Frame),
            Get_Src_Address_Mode (Frame)))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         Frame'Length
         >= Get_Source_Address_Offset (Frame)
            + Get_Source_Address_Length (Frame);

   function Source_Address_Equal
     (Frame : Byte_Array; Address : Variant_Address) return Boolean
   is (Address.Mode = Get_Src_Address_Mode (Frame)
       and then
         Address_Equal_At (Frame, Get_Source_Address_Offset (Frame), Address))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then
         Frame'Length
         >= Get_Source_Address_Offset (Frame)
            + Get_Source_Address_Length (Frame);

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

   -------------------------------------
   -- Auxiliary Security Header Field --
   -------------------------------------

   function Is_Aux_Security_Header_Present (Frame : Byte_Array) return Boolean
   is (case Supported_Frame_Types (Get_Frame_Type (Frame)) is
         when Beacon | Data | Ack | MAC_Command =>
           Get_FC (Frame).Security_Enabled = Enabled,

         when Multipurpose                      =>
           (if Get_MP_S_FC (Frame).Long_Frame_Control = Long
            then Get_MP_L_FC (Frame).Security_Enabled = Enabled
            else False))
   with Pre => Frame_Control_Valid (Frame);

   function Get_Aux_Security_Header_Offset (Frame : Byte_Array) return Natural
   is (Get_Source_Address_Offset (Frame) + Get_Source_Address_Length (Frame))
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Aux_Security_Header_Offset'Result in 1 .. 23;

   function Get_Aux_Security_Header_Length (Frame : Byte_Array) return Natural
   with
     Pre  => Security_Control_Valid (Frame),
     Post => Get_Aux_Security_Header_Length'Result in 0 .. 14;

   function Get_Aux_Security_Header_Length
     (ASH : Variant_Aux_Security_Header) return Natural
   is (if ASH.Security_Enabled = Disabled
       then 0
       else
         1
         + (if ASH.Frame_Counter.Suppression = Suppressed then 0 else 4)
         + (case ASH.Key_ID.Mode is
              when 0 => 0,
              when 1 => 1,
              when 2 => 5,
              when 3 => 9));

   function Get_Aux_Security_Header
     (Frame : Byte_Array) return Variant_Aux_Security_Header
   with
     Pre =>
       Security_Control_Valid (Frame)
       and then
         (if Is_Aux_Security_Header_Present (Frame)
          then
            Frame'Length
            >= Get_Aux_Security_Header_Offset (Frame)
               + Get_Aux_Security_Header_Length (Frame));

   ----------------------------
   -- Security Control Field --
   ----------------------------

   function Is_Security_Control_Present (Frame : Byte_Array) return Boolean
   renames Is_Aux_Security_Header_Present;

   function Get_Security_Control_Offset (Frame : Byte_Array) return Natural
   renames Get_Aux_Security_Header_Offset;

   function Get_Security_Control_Length (Frame : Byte_Array) return Natural
   is (if Is_Security_Control_Present (Frame) then 1 else 0)
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Security_Control_Length'Result in 0 .. 1;

   function Security_Control_Valid (Frame : Byte_Array) return Boolean
   is (Frame_Control_Valid (Frame)
       and then
         (if Is_Security_Control_Present (Frame)
          then Frame'Length > Get_Security_Control_Offset (Frame)));

   function Get_Security_Control
     (Frame : Byte_Array) return Security_Control_Field
   is (Security_Control_Field'
         (From_Bytes
            (Frame (Frame'First + Get_Security_Control_Offset (Frame)))))
   with
     Pre =>
       Security_Control_Valid (Frame)
       and then Is_Security_Control_Present (Frame);

   function Security_Control_Equal
     (Frame : Byte_Array; SC : Security_Control_Field) return Boolean
   is (Security_Control_Equal_At
         (Frame, Get_Security_Control_Offset (Frame), SC))
   with
     Pre =>
       Security_Control_Valid (Frame)
       and then Is_Security_Control_Present (Frame);

   function Security_Control_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (if MHR.Aux_Security_Header.Security_Enabled = Enabled
       then
         (declare
            SC : constant Security_Control_Field :=
              Get_Security_Control_At
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

   function Get_Key_ID_Mode (Frame : Byte_Array) return Key_ID_Mode_Field
   is (Get_Security_Control (Frame).Key_ID_Mode)
   with
     Pre =>
       Security_Control_Valid (Frame)
       and then Is_Security_Control_Present (Frame);

   -------------------------
   -- Frame Counter Field --
   -------------------------

   function Is_Frame_Counter_Present (Frame : Byte_Array) return Boolean
   is (Is_Security_Control_Present (Frame)
       and then Get_Security_Control (Frame).FC_Suppression = Not_Suppressed)
   with Pre => Security_Control_Valid (Frame);

   function Get_Frame_Counter_Offset (Frame : Byte_Array) return Natural
   is (Get_Security_Control_Offset (Frame)
       + Get_Security_Control_Length (Frame))
   with
     Pre  => Frame_Control_Valid (Frame),
     Post => Get_Frame_Counter_Offset'Result in 1 .. 24;

   function Get_Frame_Counter_Length (Frame : Byte_Array) return Natural
   is (if Is_Frame_Counter_Present (Frame) then 4 else 0)
   with
     Pre  => Security_Control_Valid (Frame),
     Post => Get_Frame_Counter_Length'Result in 0 | 4;

   function Get_Frame_Counter (Frame : Byte_Array) return Variant_Frame_Counter
   is (if Is_Frame_Counter_Present (Frame)
       then
         Get_Frame_Counter_At
           (Frame,
            Get_Frame_Counter_Offset (Frame),
            Get_Security_Control (Frame).FC_Suppression)
       else Variant_Frame_Counter'(Suppression => Suppressed))
   with
     Pre  =>
       Security_Control_Valid (Frame)
       and then
         (if Is_Frame_Counter_Present (Frame)
          then Frame'Length >= Get_Frame_Counter_Offset (Frame) + 4),
     Post =>
       (if not Is_Aux_Security_Header_Present (Frame)
        then Get_Frame_Counter'Result.Suppression = Suppressed
        else
          Get_Frame_Counter'Result.Suppression
          = Get_Security_Control (Frame).FC_Suppression);

   function Frame_Counter_Equal
     (Frame : Byte_Array; Frame_Counter : Variant_Frame_Counter) return Boolean
   is ((Frame_Counter.Suppression = Not_Suppressed)
       = Is_Frame_Counter_Present (Frame)
       and then
         Frame_Counter_Equal_At
           (Frame, Get_Frame_Counter_Offset (Frame), Frame_Counter))
   with
     Pre =>
       Security_Control_Valid (Frame)
       and then
         (if Is_Frame_Counter_Present (Frame)
          then Frame'Length >= Get_Frame_Counter_Offset (Frame) + 4);

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

   --------------------------
   -- Key Identifier Field --
   --------------------------

   function Is_Key_ID_Present (Frame : Byte_Array) return Boolean
   is (Is_Security_Control_Present (Frame)
       and then Get_Key_ID_Mode (Frame) /= 0)
   with Pre => Security_Control_Valid (Frame);

   function Get_Key_ID_Offset (Frame : Byte_Array) return Natural
   is (Get_Frame_Counter_Offset (Frame) + Get_Frame_Counter_Length (Frame))
   with
     Pre  => Security_Control_Valid (Frame),
     Post => Get_Key_ID_Offset'Result in 1 .. 28;

   function Get_Key_ID_Length (Frame : Byte_Array) return Natural
   is (if not Is_Aux_Security_Header_Present (Frame)
       then 0
       else Key_ID_Length (Get_Key_ID_Mode (Frame)))
   with
     Pre  => Security_Control_Valid (Frame),
     Post => Get_Key_ID_Length'Result in 0 | 1 | 5 | 9;

   function Get_Key_ID (Frame : Byte_Array) return Variant_Key_ID
   is (if Is_Key_ID_Present (Frame)
       then
         Get_Key_ID_At
           (Frame,
            Get_Key_ID_Offset (Frame),
            Get_Security_Control (Frame).Key_ID_Mode)
       else Variant_Key_ID'(Mode => 0))
   with
     Pre  =>
       Security_Control_Valid (Frame)
       and then
         Frame'Length >= Get_Key_ID_Offset (Frame) + Get_Key_ID_Length (Frame),
     Post =>
       (if not Is_Aux_Security_Header_Present (Frame)
        then Get_Key_ID'Result.Mode = 0
        else
          Get_Key_ID'Result.Mode = Get_Security_Control (Frame).Key_ID_Mode);

   function Key_ID_Equal
     (Frame : Byte_Array; Key_ID : Variant_Key_ID) return Boolean
   is (if Get_Security_Enabled (Frame) = Enabled
       then
         Key_ID.Mode = Get_Key_ID_Mode (Frame)
         and then Key_ID_Equal_At (Frame, Get_Key_ID_Offset (Frame), Key_ID))
   with
     Pre =>
       Security_Control_Valid (Frame)
       and then
         Frame'Length >= Get_Key_ID_Offset (Frame) + Get_Key_ID_Length (Frame);

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

   ----------------
   -- Header IEs --
   ----------------

   function Is_Header_IEs_Present (Frame : Byte_Array) return Boolean
   is (Get_IE_Present (Frame) = Present)
   with Pre => Frame_Control_Valid (Frame);

   function Get_Header_IEs_Offset (Frame : Byte_Array) return Natural
   is (Get_Frame_Control_Length (Frame)
       + Get_Sequence_Number_Length (Frame)
       + Get_Destination_PAN_ID_Length (Frame)
       + Get_Destination_Address_Length (Frame)
       + Get_Source_PAN_ID_Length (Frame)
       + Get_Source_Address_Length (Frame)
       + Get_Aux_Security_Header_Length (Frame))
   with Pre => Security_Control_Valid (Frame);

   function Is_Header_IEs_Valid (Frame : Byte_Array) return Boolean
   is (if Is_Header_IEs_Present (Frame)
       then
         Frame'Length > Get_Header_IEs_Offset (Frame)
         and then
           Info_Elements.Headers.Lists.IE_Model.Valid_IE_List
             (Frame
                (Frame'First + Get_Header_IEs_Offset (Frame) .. Frame'Last)))
   with Pre => Security_Control_Valid (Frame);

   function Get_Header_IEs_Length (Frame : Byte_Array) return Natural
   is (if Is_Header_IEs_Present (Frame)
       then
         Info_Elements.Headers.Lists.IE_Model.IE_List_Length
           (Frame (Frame'First + Get_Header_IEs_Offset (Frame) .. Frame'Last))
       else 0)
   with
     Pre =>
       Security_Control_Valid (Frame) and then Is_Header_IEs_Valid (Frame);

   -----------------
   -- MAC Payload --
   -----------------

   function Is_MAC_Payload_Present (Frame : Byte_Array) return Boolean
   is (Get_Frame_Control_Length (Frame)
       + Get_Sequence_Number_Length (Frame)
       + Get_Destination_PAN_ID_Length (Frame)
       + Get_Destination_Address_Length (Frame)
       + Get_Source_PAN_ID_Length (Frame)
       + Get_Source_Address_Length (Frame)
       + Get_Aux_Security_Header_Length (Frame)
       + Get_Header_IEs_Length (Frame)
       < Frame'Length)
   with
     Pre =>
       Security_Control_Valid (Frame) and then Is_Header_IEs_Valid (Frame);

   function Get_MAC_Payload_Offset (Frame : Byte_Array) return Natural
   is (Get_Frame_Control_Length (Frame)
       + Get_Sequence_Number_Length (Frame)
       + Get_Destination_PAN_ID_Length (Frame)
       + Get_Destination_Address_Length (Frame)
       + Get_Source_PAN_ID_Length (Frame)
       + Get_Source_Address_Length (Frame)
       + Get_Aux_Security_Header_Length (Frame)
       + Get_Header_IEs_Length (Frame))
   with
     Pre =>
       Security_Control_Valid (Frame) and then Is_Header_IEs_Valid (Frame);

   function Get_MAC_Payload_Length (Frame : Byte_Array) return Natural
   is (if Is_MAC_Payload_Present (Frame)
       then Frame'Length - Get_MAC_Payload_Offset (Frame)
       else 0)
   with
     Pre =>
       Security_Control_Valid (Frame) and then Is_Header_IEs_Valid (Frame);

   -----------------
   -- Payload IEs --
   -----------------

   function Is_Payload_IE_Present (Frame : Byte_Array) return Boolean
   is (Is_MAC_Payload_Present (Frame)
       and then Is_Header_IEs_Present (Frame)
       and then
         Info_Elements.Headers.Lists.IE_Model.Last_IE_Header_Field
           (Frame (Frame'First + Get_Header_IEs_Offset (Frame) .. Frame'Last))
           .Element_ID
         = Info_Elements.Headers.Header_Termination_1_IE)
   with
     Pre =>
       Security_Control_Valid (Frame) and then Is_Header_IEs_Valid (Frame);

   -----------------------
   -- MAC Header Length --
   -----------------------

   function MHR_Length_Excluding_IEs (Frame : Byte_Array) return Natural
   is (Get_Frame_Control_Length (Frame)
       + Get_Sequence_Number_Length (Frame)
       + Get_Destination_PAN_ID_Length (Frame)
       + Get_Destination_Address_Length (Frame)
       + Get_Source_PAN_ID_Length (Frame)
       + Get_Source_Address_Length (Frame)
       + Get_Aux_Security_Header_Length (Frame))
   with
     Pre =>
       Frame_Control_Valid (Frame) and then Security_Control_Valid (Frame);
   --  Returns the length of the MAC header, in bytes, excluding header IEs.

   function MHR_Length (Frame : Byte_Array) return Natural
   is (Get_Frame_Control_Length (Frame)
       + Get_Sequence_Number_Length (Frame)
       + Get_Destination_PAN_ID_Length (Frame)
       + Get_Destination_Address_Length (Frame)
       + Get_Source_PAN_ID_Length (Frame)
       + Get_Source_Address_Length (Frame)
       + Get_Aux_Security_Header_Length (Frame)
       + Get_Header_IEs_Length (Frame))
   with
     Pre =>
       Frame_Control_Valid (Frame)
       and then Security_Control_Valid (Frame)
       and then Is_Header_IEs_Valid (Frame);
   --  Returns the length of the MAC header, in bytes.
   --
   --  This includes all fields of the MAC header, including the header IEs.

   -------------------------
   -- MAC Header Validity --
   -------------------------

   function Is_MHR_Valid_Excluding_IEs (Frame : Byte_Array) return Boolean
   is (Frame_Control_Valid (Frame)
       and then Security_Control_Valid (Frame)
       and then Frame'Length >= MHR_Length_Excluding_IEs (Frame));
   --  Returns True if all fields in the MAC header (excluding header IEs)
   --  are valid.

   function Is_MHR_Valid (Frame : Byte_Array) return Boolean
   is (Frame_Control_Valid (Frame)
       and then Security_Control_Valid (Frame)
       and then Is_Header_IEs_Valid (Frame)
       and then Frame'Length >= MHR_Length (Frame));
   --  Returns True if all fields in the MAC header (including header IEs)
   --  are valid.

   function Is_Valid_Decoding
     (MHR : Valid_MAC_Header; Frame : Byte_Array) return Boolean
   is (MHR.Frame_Type = Get_Frame_Type (Frame)
       and then MHR.Frame_Pending = Get_Frame_Pending (Frame)
       and then MHR.AR = Get_Ack_Required (Frame)
       and then MHR.IE_Present = Get_IE_Present (Frame)
       and then MHR.Frame_Version = Get_Frame_Version (Frame)
       and then MHR.Sequence_Number = Get_Sequence_Number (Frame)
       and then MHR.Destination_PAN_ID = Get_Destination_PAN_ID (Frame)
       and then MHR.Destination_Address = Get_Destination_Address (Frame)
       and then MHR.Source_PAN_ID = Get_Decompressed_Source_PAN_ID (Frame)
       and then MHR.Source_Address = Get_Source_Address (Frame)
       and then MHR.Aux_Security_Header = Get_Aux_Security_Header (Frame))
   with Pre => Is_MHR_Valid_Excluding_IEs (Frame);
   --  Returns True if all fields in MHR are equivalent to the model's
   --  view of the frame buffer.

   function MHR_Equal
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

   ------------
   -- Lemmas --
   ------------

   procedure Lemma_Frame_Control_Length_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  => Frame_Control_Equal (MHR, Frame),
     Post => Get_Frame_Control_Length (MHR) = Get_Frame_Control_Length (Frame);

   procedure Lemma_PAN_ID_Presence_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  => Frame_Control_Equal (MHR, Frame),
     Post =>
       (if MHR.Frame_Type = Multipurpose
        then
          MHR.Destination_PAN_ID.Present
          = (Get_MP_S_FC (Frame).Long_Frame_Control = Long
             and then Get_MP_L_FC (Frame).PAN_ID_Present = Present)
        else
          MHR.Destination_PAN_ID.Present
          = PAN_ID_Model.Is_Destination_PAN_ID_Present
              (Frame_Version            => Get_FC (Frame).Frame_Version,
               Destination_Address_Mode => Get_FC (Frame).Dest_Address_Mode,
               Source_Address_Mode      => Get_FC (Frame).Src_Address_Mode,
               PAN_ID_Compression       => Get_FC (Frame).PAN_ID_Compression)
          and then
            Compressed_Source_PAN_ID
              (Destination_PAN_ID => MHR.Destination_PAN_ID,
               Source_PAN_ID      => MHR.Source_PAN_ID)
              .Present
            = PAN_ID_Model.Is_Source_PAN_ID_Present
                (Frame_Version            => Get_FC (Frame).Frame_Version,
                 Destination_Address_Mode => Get_FC (Frame).Dest_Address_Mode,
                 Source_Address_Mode      => Get_FC (Frame).Src_Address_Mode,
                 PAN_ID_Compression       =>
                   Get_FC (Frame).PAN_ID_Compression));

   procedure Lemma_Field_Positions_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  => Frame_Control_Equal (MHR, Frame),
     Post =>
       Get_Frame_Control_Length (MHR) = Get_Frame_Control_Length (Frame)
       and then
         Get_Sequence_Number_Offset (MHR) = Get_Sequence_Number_Offset (Frame)
       and then
         Get_Sequence_Number_Length (MHR) = Get_Sequence_Number_Length (Frame)
       and then
         Get_Destination_PAN_ID_Offset (MHR)
         = Get_Destination_PAN_ID_Offset (Frame)
       and then
         Get_Destination_PAN_ID_Length (MHR)
         = Get_Destination_PAN_ID_Length (Frame)
       and then
         Get_Destination_Address_Offset (MHR)
         = Get_Destination_Address_Offset (Frame)
       and then
         Get_Destination_Address_Length (MHR)
         = Get_Destination_Address_Length (Frame)
       and then
         Get_Source_PAN_ID_Offset (MHR) = Get_Source_PAN_ID_Offset (Frame)
       and then
         Get_Source_PAN_ID_Length (MHR) = Get_Source_PAN_ID_Length (Frame)
       and then
         Get_Source_Address_Offset (MHR) = Get_Source_Address_Offset (Frame)
       and then
         Get_Source_Address_Length (MHR) = Get_Source_Address_Length (Frame);

private

   ------------------------------------
   -- Get_Aux_Security_Header_Length --
   ------------------------------------

   function Get_Aux_Security_Header_Length (Frame : Byte_Array) return Natural
   is (Get_Security_Control_Length (Frame)
       + Get_Frame_Counter_Length (Frame)
       + Get_Key_ID_Length (Frame));

   function Get_Aux_Security_Header_Length
     (MHR : Valid_MAC_Header) return Natural
   is (Get_Security_Control_Length (MHR)
       + Get_Frame_Counter_Length (MHR)
       + Get_Key_ID_Length (MHR));

   -----------------------------
   -- Get_Aux_Security_Header --
   -----------------------------

   function Get_Aux_Security_Header
     (Frame : Byte_Array) return Variant_Aux_Security_Header
   is (if Is_Aux_Security_Header_Present (Frame)
       then
         Variant_Aux_Security_Header'
           (Security_Enabled => Enabled,
            Security_Level   => Get_Security_Control (Frame).Security_Level,
            ASN_In_Nonce     => Get_Security_Control (Frame).Nonce_Source,
            Frame_Counter    => Get_Frame_Counter (Frame),
            Key_ID           => Get_Key_ID (Frame))
       else Variant_Aux_Security_Header'(Security_Enabled => Disabled));

end AdaBee.MAC.Frames.Headers.MHR_Model;
