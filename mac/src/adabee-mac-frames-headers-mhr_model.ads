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
   use type AdaBee.MAC.Frames.Info_Elements.Headers.Element_ID_Field;

   -------------------------------
   -- Frame Control Field Views --
   -------------------------------

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
   --  Read the short (8-bit) multipurpose frame control field from the frame

   function Get_FC (Frame : Byte_Array) return Frame_Control_Field
   is (Frame_Control_Field'
         (From_Bytes (Frame (Frame'First .. Frame'First + 1))))
   with Pre => Frame'Length >= 2;
   --  Read the general frame control field from the frame

   -------------------------
   -- Address Field Views --
   -------------------------

   function Address_Length (Mode : Valid_Address_Mode_Field) return Natural
   is (case Mode is
         when Not_Present => 0,
         when Short       => 2,
         when Extended    => 8);
   --  Returns the length of an address field based on its mode

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

   ------------------
   -- PAN ID Views --
   ------------------

   function Get_PAN_ID_At
     (Frame : Byte_Array; Offset : Natural) return PAN_ID_Field
   is (From_Bytes (Frame (Frame'First + Offset .. Frame'First + Offset + 1)))
   with Pre => Offset <= Frame'Length - 2;
   --  Reads a PAN ID field from the frame at the specified offset

   -------------------
   -- Frame Control --
   -------------------

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
   with
     Pre =>
       Frame_Control_Valid (Frame) and then Is_Sequence_Number_Present (Frame);
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
   is (Get_Frame_Control_Length (Frame) + Get_Sequence_Number_Length (Frame))
   with
     Pre  =>
       Frame_Control_Valid (Frame)
       and then Is_Destination_PAN_ID_Present (Frame),
     Post => Get_Destination_PAN_ID_Offset'Result in 2 .. 3;
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
   is (Get_Frame_Control_Length (Frame)
       + Get_Sequence_Number_Length (Frame)
       + Get_Destination_PAN_ID_Length (Frame))
   with
     Pre  =>
       Frame_Control_Valid (Frame)
       and then Get_Dest_Address_Mode (Frame) /= Not_Present,
     Post => Get_Destination_Address_Offset'Result in 1 .. 5;

   function Get_Destination_Address_Length (Frame : Byte_Array) return Natural
   is (case Get_Dest_Address_Mode (Frame) is
         when Not_Present => 0,
         when Short       => 2,
         when Extended    => 8)
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
         (if Get_Dest_Address_Mode (Frame) /= Not_Present
          then
            Frame'Length
            >= Get_Destination_Address_Offset (Frame)
               + Get_Destination_Address_Length (Frame));

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
   is (Get_Frame_Control_Length (Frame)
       + Get_Sequence_Number_Length (Frame)
       + Get_Destination_PAN_ID_Length (Frame)
       + Get_Destination_Address_Length (Frame))
   with
     Pre  =>
       Frame_Control_Valid (Frame) and then Is_Source_PAN_ID_Present (Frame),
     Post => Get_Source_PAN_ID_Offset'Result in 2 .. 13;

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
   is (Get_Frame_Control_Length (Frame)
       + Get_Sequence_Number_Length (Frame)
       + Get_Destination_PAN_ID_Length (Frame)
       + Get_Destination_Address_Length (Frame)
       + Get_Source_PAN_ID_Length (Frame))
   with
     Pre  =>
       Frame_Control_Valid (Frame)
       and then Get_Src_Address_Mode (Frame) /= Not_Present,
     Post => Get_Source_Address_Offset'Result in 1 .. 15;

   function Get_Source_Address_Length (Frame : Byte_Array) return Natural
   is (case Get_Src_Address_Mode (Frame) is
         when Not_Present => 0,
         when Short       => 2,
         when Extended    => 8)
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
         (if Get_Src_Address_Mode (Frame) /= Not_Present
          then
            Frame'Length
            >= Get_Source_Address_Offset (Frame)
               + Get_Source_Address_Length (Frame));

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
   is (Get_Frame_Control_Length (Frame)
       + Get_Sequence_Number_Length (Frame)
       + Get_Destination_PAN_ID_Length (Frame)
       + Get_Destination_Address_Length (Frame)
       + Get_Source_PAN_ID_Length (Frame)
       + Get_Source_Address_Length (Frame))
   with
     Pre  =>
       Frame_Control_Valid (Frame)
       and then Is_Aux_Security_Header_Present (Frame),
     Post => Get_Aux_Security_Header_Offset'Result in 2 .. 23;

   function Get_Aux_Security_Header_Length (Frame : Byte_Array) return Natural
   with
     Pre  => Security_Control_Valid (Frame),
     Post => Get_Aux_Security_Header_Length'Result in 0 .. 14;

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
     Post => Get_Security_Control_Length'Result in 0 | 1;

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
   is (Get_Aux_Security_Header_Offset (Frame) + 1)
   with
     Pre  =>
       Security_Control_Valid (Frame)
       and then Is_Frame_Counter_Present (Frame),
     Post => Get_Frame_Counter_Offset'Result in 3 .. 24;

   function Get_Frame_Counter_Length (Frame : Byte_Array) return Natural
   is (if Is_Frame_Counter_Present (Frame) then 4 else 0)
   with
     Pre  => Security_Control_Valid (Frame),
     Post => Get_Frame_Counter_Length'Result in 0 | 4;

   function Get_Frame_Counter (Frame : Byte_Array) return Variant_Frame_Counter
   is (if Is_Frame_Counter_Present (Frame)
       then
         Variant_Frame_Counter'
           (Suppression   => Not_Suppressed,
            Frame_Counter =>
              From_Bytes
                (Frame
                   (Frame'First + Get_Frame_Counter_Offset (Frame)
                    .. Frame'First + Get_Frame_Counter_Offset (Frame) + 3)))
       else Variant_Frame_Counter'(Suppression => Suppressed))
   with
     Pre  =>
       Security_Control_Valid (Frame)
       and then
         (if Is_Frame_Counter_Present (Frame)
          then
            Frame'Length
            >= Get_Frame_Counter_Offset (Frame)
               + Get_Frame_Counter_Length (Frame)),
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
   is (Get_Aux_Security_Header_Offset (Frame)
       + Get_Security_Control_Length (Frame)
       + Get_Frame_Counter_Length (Frame))
   with
     Pre  => Security_Control_Valid (Frame) and then Is_Key_ID_Present (Frame),
     Post => Get_Key_ID_Offset'Result in 3 .. 28;

   function Get_Key_ID_Length (Frame : Byte_Array) return Natural
   is (if not Is_Aux_Security_Header_Present (Frame)
       then 0
       else
         (case Get_Key_ID_Mode (Frame) is
            when 0 => 0,
            when 1 => 1,
            when 2 => 5,
            when 3 => 9))
   with
     Pre  => Security_Control_Valid (Frame),
     Post => Get_Key_ID_Length'Result in 0 | 1 | 5 | 9;

   function Get_Key_ID (Frame : Byte_Array) return Variant_Key_ID
   is (if Is_Key_ID_Present (Frame)
       then
         (case Get_Key_ID_Mode (Frame) is
            when 0 => raise Program_Error,

            when 1 =>
              Variant_Key_ID'
                (Mode      => 1,
                 Key_Index =>
                   Key_Index_Field
                     (Frame (Frame'First + Get_Key_ID_Offset (Frame)))),

            when 2 =>
              Variant_Key_ID'
                (Mode         => 2,
                 Key_Index    =>
                   Key_Index_Field
                     (Frame (Frame'First + Get_Key_ID_Offset (Frame))),
                 Key_Source_4 =>
                   Key_Source_Field
                     (Frame
                        (Frame'First + Get_Key_ID_Offset (Frame) + 1
                         .. Frame'First + Get_Key_ID_Offset (Frame) + 4))),

            when 3 =>
              Variant_Key_ID'
                (Mode         => 3,
                 Key_Index    =>
                   Key_Index_Field
                     (Frame (Frame'First + Get_Key_ID_Offset (Frame))),
                 Key_Source_8 =>
                   Key_Source_Field
                     (Frame
                        (Frame'First + Get_Key_ID_Offset (Frame) + 1
                         .. Frame'First + Get_Key_ID_Offset (Frame) + 8))))

       else Variant_Key_ID'(Mode => 0))
   with
     Pre  =>
       Security_Control_Valid (Frame)
       and then
         (if Is_Key_ID_Present (Frame)
          then
            Frame'Length
            >= Get_Key_ID_Offset (Frame) + Get_Key_ID_Length (Frame)),
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
   with
     Pre =>
       Security_Control_Valid (Frame) and then Is_Header_IEs_Present (Frame);

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
   is (Is_Header_IEs_Present (Frame)
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
     (MHR : MAC_Header; Frame : Byte_Array) return Boolean
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

end AdaBee.MAC.Frames.Headers.MHR_Model;
