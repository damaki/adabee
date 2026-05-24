--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Info_Elements.Headers;

--  @summary
--  Formal model of the MAC header decoder
--
--  @description
--  This package provides a formal specification for frame structure of MAC
--  headers according to IEEE 802.15.4-2024.
--
--  Whereas the Encoder_Model defines the frame layout in terms of the content
--  of a MAC_Header record, this model defines the frame layout based solely
--  on the content of the frame buffer itself.
--
--  This formal model consists of several parts:
--   * Frame Control Field Views: Provides views of the various frame control
--     field types in the frame buffer, based on Unchecked_Conversions
--     (From_Bytes).
--   * Frame Control Accessors - Provides helper functions for reading the
--     various elements of the frame control field.
--   * Definitions for individual fields - Provides definitions for checking
--     when the field is present in the frame (based on the content of the
--     frame control field), the length of the field, and functions for reading
--     the value of the field.
--   * MAC Header Validity - Provides a definition of validity for the overall
--     MAC header.
--
--  The model is defined in a functional style using expression functions and
--  is not expected to be efficient at run-time. It is therefore defined as
--  ghost code as it is intended for specification only.

package AdaBee.MAC.Frames.Headers.Decoder_Model
  with Ghost, Pure, SPARK_mode, Always_Terminates
is
   use type Interfaces.Unsigned_8;
   use type AdaBee.MAC.Frames.Info_Elements.Headers.Element_ID_Field;

   package Header_IE_Model renames
     AdaBee.MAC.Frames.Info_Elements.Headers.Lists.IE_Model;

   -------------------------------
   -- Frame Control Field Views --
   -------------------------------

   --  These functions provide a view into the various Frame Control types
   --  at the start of the frame by converting from a byte array to the
   --  appropriate data type.

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

   ---------------------
   -- Field Accessors --
   ---------------------

   --  These functions read individual fields from arbitary positions in the
   --  frame buffer into the appropriate data structure.

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

   function Get_Security_Control_At
     (Frame : Byte_Array; Offset : Natural) return Security_Control_Field
   is (From_Bytes (Frame (Frame'First + Offset)))
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

private

   ------------------------------------
   -- Get_Aux_Security_Header_Length --
   ------------------------------------

   function Get_Aux_Security_Header_Length (Frame : Byte_Array) return Natural
   is (Get_Security_Control_Length (Frame)
       + Get_Frame_Counter_Length (Frame)
       + Get_Key_ID_Length (Frame));

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

end AdaBee.MAC.Frames.Headers.Decoder_Model;
