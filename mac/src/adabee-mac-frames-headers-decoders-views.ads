--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Headers.Decoder_Model;

--  @summary
--  Decoder for IEEE 802.15.4-2024 MAC headers that reads fields directly from
--  the frame buffer.
--
--  @description
--  This package provides a means of decoding packets by reading fields
--  directly from the frame buffer instead of decoding each field into a
--  separate MAC_Header record. In other words, it provides a "view" into the
--  frame buffer for each field.
--
--  The frame buffer must be validated before fields can be read to ensure that
--  the frame is well-formed and does not contain any invalid or unsuppoprted
--  values. Once the frame has been successfully validated, then the various
--  getter functions can be used to read each of the field values.

package AdaBee.MAC.Frames.Headers.Decoders.Views
  with Pure, SPARK_Mode, Always_Terminates
is

   ------------------
   -- View Context --
   ------------------

   type View_Context is private;
   --  Holds information about the position of each field in the frame.

   function Is_Valid (Ctx : View_Context; Frame : Byte_Array) return Boolean
   with Ghost, Global => null;
   --  Returns True if and only if Ctx is a correct view into the MAC header
   --  stored in Frame.
   --
   --  This is used for specification only, so it is marked as Ghost.

   ----------------------
   -- Frame Validation --
   ----------------------

   procedure Validate
     (Ctx : out View_Context; Frame : Byte_Array; Result : out Status_Code)
   with
     Global                 => null,
     Relaxed_Initialization => Ctx,
     Pre                    => Frame'Last < Integer'Last,
     Post                   =>
       (Result = Success) = Decoder_Model.Is_MHR_Valid_Excluding_IEs (Frame)
       and then
         (if Result = Success
          then Ctx'Initialized and then Is_Valid (Ctx, Frame));
   --  Validate the contents of a MAC header up (and including) the Auxiliary
   --  Security Header field.
   --
   --  @param Ctx If the frame was successfully validated, then this is
   --    initialized and can be used to access individual fields within the
   --    frame.
   --  @param Frame The buffer containing the MAC header to validate
   --  @param Result Written to indicate whether the frame was successfully
   --    validated or not.

   procedure Validate_Frame_Control
     (Frame : Byte_Array; Result : out Status_Code)
   with
     Global => null,
     Post   => (Result = Success) = Decoder_Model.Frame_Control_Valid (Frame);
   --  Validate the Frame Control field only.
   --
   --  This can be used to perform a quick validation of the frame control
   --  field. Upon successful validation the contents of the frame control
   --  field can be read without needing to validate the rest of the frame.
   --
   --  @param Frame The buffer containing the Frame Control field to validate.
   --  @param Result Written to indicate whether the frame control field was
   --    successfully validated or not.

   -----------------------------------
   -- Frame Control Field Accessors --
   -----------------------------------

   --  These functions provide accessors to read the various parts of the
   --  Frame Control field.

   function Get_Frame_Type (Frame : Byte_Array) return Frame_Type_Field
   with
     Inline,
     Global => null,
     Pre    => Frame'Length > 0,
     Post   => Get_Frame_Type'Result = Decoder_Model.Get_Frame_Type (Frame);
   --  Read the Frame Type field from the Frame.

   function Get_General_Frame_Control
     (Frame : Byte_Array) return Valid_Frame_Control_Field
   with
     Inline,
     Global => null,
     Pre    =>
       Decoder_Model.Frame_Control_Valid (Frame)
       and then
         Decoder_Model.Get_Frame_Type (Frame)
         in Beacon | Data | Ack | MAC_Command,
     Post   => Get_General_Frame_Control'Result = Decoder_Model.Get_FC (Frame);
   --  Get the Frame Control field for general frame types.

   function Get_Multipurpose_Frame_Control
     (Frame : Byte_Array) return Valid_MP_Long_Frame_Control_Field
   with
     Inline,
     Global => null,
     Pre    =>
       Decoder_Model.Frame_Control_Valid (Frame)
       and then Decoder_Model.Get_Frame_Type (Frame) = Multipurpose,
     Post   =>
       (if Decoder_Model.Get_MP_S_FC (Frame).Long_Frame_Control = Long
        then
          Get_Multipurpose_Frame_Control'Result
          = Decoder_Model.Get_MP_L_FC (Frame)
        else
          Get_Multipurpose_Frame_Control'Result
          = To_Long_Frame_Control (Decoder_Model.Get_MP_S_FC (Frame)));
   --  Get the Frame Control field for multipurpose frames.

   function Get_Long_Frame_Control
     (Frame : Byte_Array) return Long_Frame_Control_Field
   with
     Inline,
     Global => null,
     Pre    => Decoder_Model.Frame_Control_Valid (Frame),
     Post   =>
       (Get_Long_Frame_Control'Result = Short)
       = (Decoder_Model.Get_Frame_Type (Frame) = Multipurpose
          and then
            Decoder_Model.Get_MP_S_FC (Frame).Long_Frame_Control = Short);
   --  Read the Long Frame Control bit from the Frame Control
   --
   --  The Long Frame Control field is only present for multipurpose frames.
   --  For other frame types, it always returns Long indicating a 2-byte frame
   --  control field.

   function Get_PAN_ID_Compression
     (Frame : Byte_Array) return PAN_ID_Compression_Field
   is (Get_General_Frame_Control (Frame).PAN_ID_Compression)
   with
     Global => null,
     Pre    =>
       Decoder_Model.Frame_Control_Valid (Frame)
       and then
         Decoder_Model.Get_Frame_Type (Frame)
         in Beacon | Data | Ack | MAC_Command,
     Post   =>
       Get_PAN_ID_Compression'Result
       = Decoder_Model.Get_FC (Frame).PAN_ID_Compression;
   --  Read the PAN ID compression bit from the Frame Control field.
   --
   --  This may only be called for frame types for which this field is present
   --  (Beacon, Data, Ack, and MAC_Command frames).

   --  The following functions are agnostic to the frame type (they work for
   --  all supported frame types), but if you know the frame type, then it will
   --  be slightly more efficient to call Get_General_Frame_Control or
   --  Get_Multipurpose_Frame_Control and access the desired field through
   --  their return value.
   --
   --  The following functions are less efficient because they need an
   --  additional run-time check on the frame type to determine which part of
   --  the frame to read, which is not needed by Get_General_Frame_Control and
   --  Get_Multipurpose_Frame_Control

   function Get_Security_Enabled
     (Frame : Byte_Array) return Security_Enabled_Field
   with
     Inline,
     Global => null,
     Pre    => Decoder_Model.Frame_Control_Valid (Frame),
     Post   =>
       Get_Security_Enabled'Result
       = Decoder_Model.Get_Security_Enabled (Frame);
   --  Read the Security Enabled bit from the Frame Control field

   function Get_Frame_Pending (Frame : Byte_Array) return Frame_Pending_Field
   with
     Inline,
     Global => null,
     Pre    => Decoder_Model.Frame_Control_Valid (Frame),
     Post   =>
       Get_Frame_Pending'Result = Decoder_Model.Get_Frame_Pending (Frame);
   --  Read the Frame Pending bit from the Frame Control field

   function Get_Ack_Required (Frame : Byte_Array) return Ack_Required_Field
   with
     Inline,
     Global => null,
     Pre    => Decoder_Model.Frame_Control_Valid (Frame),
     Post   =>
       Get_Ack_Required'Result = Decoder_Model.Get_Ack_Required (Frame);
   --  Read the Acknowledgement Required bit from the Frame Control field

   function Get_Seq_Number_Suppression
     (Frame : Byte_Array) return Seq_Number_Suppression_Field
   with
     Inline,
     Global => null,
     Pre    => Decoder_Model.Frame_Control_Valid (Frame),
     Post   =>
       Get_Seq_Number_Suppression'Result
       = Decoder_Model.Get_Seq_Number_Suppression (Frame);
   --  Read the Sequence Number Suppression bit from the Frame Control field

   function Get_IE_Present (Frame : Byte_Array) return IE_Present_Field
   with
     Inline,
     Global => null,
     Pre    => Decoder_Model.Frame_Control_Valid (Frame),
     Post   => Get_IE_Present'Result = Decoder_Model.Get_IE_Present (Frame);
   --  Read the IE present bit from the Frame Control field

   function Get_Dest_Address_Mode
     (Frame : Byte_Array) return Valid_Address_Mode_Field
   with
     Inline,
     Global => null,
     Pre    => Decoder_Model.Frame_Control_Valid (Frame),
     Post   =>
       Get_Dest_Address_Mode'Result
       = Decoder_Model.Get_Dest_Address_Mode (Frame);
   --  Read the Destination Address Mode from the Frame Control field

   function Get_Src_Address_Mode
     (Frame : Byte_Array) return Valid_Address_Mode_Field
   with
     Inline,
     Global => null,
     Pre    => Decoder_Model.Frame_Control_Valid (Frame),
     Post   =>
       Get_Src_Address_Mode'Result
       = Decoder_Model.Get_Src_Address_Mode (Frame);
   --  Read the Source Address Mode from the Frame Control field

   function Get_Frame_Version
     (Frame : Byte_Array) return Valid_Frame_Version_Field
   with
     Inline,
     Global => null,
     Pre    => Decoder_Model.Frame_Control_Valid (Frame),
     Post   =>
       Get_Frame_Version'Result = Decoder_Model.Get_Frame_Version (Frame);
   --  Read the Frame Version from the Frame Control field

   ---------------------------
   -- Sequence Number Field --
   ---------------------------

   function Get_Sequence_Number
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Sequence_Number
   with
     Inline,
     Global => null,
     Pre    => Is_Valid (Ctx, Frame),
     Post   =>
       Get_Sequence_Number'Result = Decoder_Model.Get_Sequence_Number (Frame);
   --  Read the Sequence Number field from the MAC header

   ------------------------------
   -- Destination PAN ID Field --
   ------------------------------

   function Get_Destination_PAN_ID
     (Frame : Byte_Array; Ctx : View_Context) return Variant_PAN_ID
   with
     Inline,
     Global => null,
     Pre    => Is_Valid (Ctx, Frame),
     Post   =>
       Get_Destination_PAN_ID'Result
       = Decoder_Model.Get_Destination_PAN_ID (Frame);
   --  Read the Destination PAN ID field from the MAC header

   ------------------------------
   -- Destination Address Field --
   ------------------------------

   function Get_Destination_Address
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Address
   with
     Inline,
     Global => null,
     Pre    => Is_Valid (Ctx, Frame),
     Post   =>
       Get_Destination_Address'Result
       = Decoder_Model.Get_Destination_Address (Frame);
   --  Read the Destination Address field from the MAC header

   -------------------------
   -- Source PAN ID Field --
   -------------------------

   function Get_Source_PAN_ID
     (Frame : Byte_Array; Ctx : View_Context) return Variant_PAN_ID
   with
     Inline,
     Global => null,
     Pre    => Is_Valid (Ctx, Frame),
     Post   =>
       Get_Source_PAN_ID'Result = Decoder_Model.Get_Source_PAN_ID (Frame);
   --  Read the Source PAN ID field from the MAC header, as it appears in the
   --  frame buffer.

   function Get_Decompressed_Source_PAN_ID
     (Frame : Byte_Array; Ctx : View_Context) return Variant_PAN_ID
   with
     Inline,
     Global => null,
     Pre    => Is_Valid (Ctx, Frame),
     Post   =>
       Get_Decompressed_Source_PAN_ID'Result
       = Decoder_Model.Get_Decompressed_Source_PAN_ID (Frame);
   --  Read the Source PAN ID field from the MAC header, reversing the effects
   --  of PAN ID compression (if it was compressed).
   --
   --  If PAN ID compression was used, then the source PAN ID is omitted from
   --  the frame because it is identical to the Destination PAN ID. In this
   --  case, this function returns the Destination PAN ID.

   --------------------------
   -- Source Address Field --
   --------------------------

   function Get_Source_Address
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Address
   with
     Inline,
     Global => null,
     Pre    => Is_Valid (Ctx, Frame),
     Post   =>
       Get_Source_Address'Result = Decoder_Model.Get_Source_Address (Frame);
   --  Read the Source Address field from the MAC header

   ----------------------------
   -- Security Control Field --
   ----------------------------

   function Get_Security_Control
     (Frame : Byte_Array; Ctx : View_Context) return Security_Control_Field
   with
     Inline,
     Global => null,
     Pre    =>
       Is_Valid (Ctx, Frame)
       and then Decoder_Model.Get_Security_Enabled (Frame) = Enabled,
     Post   =>
       Get_Security_Control'Result
       = Decoder_Model.Get_Security_Control (Frame);
   --  Read the Security Control from the MAC header
   --
   --  This function may only be called if security is enabled in the Frame
   --  Control field.

   -----------------------
   -- Get_Frame_Counter --
   -----------------------

   function Get_Frame_Counter
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Frame_Counter
   with
     Inline,
     Global => null,
     Pre    => Is_Valid (Ctx, Frame),
     Post   =>
       Get_Frame_Counter'Result = Decoder_Model.Get_Frame_Counter (Frame);
   --  Read the Frame Counter field from the MAC header

   ----------------
   -- Get_Key_ID --
   ----------------

   function Get_Key_ID
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Key_ID
   with
     Inline,
     Global => null,
     Pre    => Is_Valid (Ctx, Frame),
     Post   => Get_Key_ID'Result = Decoder_Model.Get_Key_ID (Frame);
   --  Read the Key ID field from the MAC header

   -------------------------------
   -- Auxiliary Security Header --
   -------------------------------

   function Get_Aux_Security_Header
     (Frame : Byte_Array; Ctx : View_Context)
      return Variant_Aux_Security_Header
   with
     Inline,
     Global => null,
     Pre    => Is_Valid (Ctx, Frame),
     Post   =>
       Get_Aux_Security_Header'Result
       = Decoder_Model.Get_Aux_Security_Header (Frame);

private

   --  The View_Context stores the position of each field in the validated
   --  frame buffer for fast access.

   type View_Context is record
      Seq_Num_Pos      : Natural;
      Dest_PAN_ID_Pos  : Natural;
      Dest_Address_Pos : Natural;
      Src_PAN_ID_Pos   : Natural;
      Src_Address_Pos  : Natural;
      Sec_Ctrl_Pos     : Natural;
      Frame_Cnt_Pos    : Natural;
      Key_ID_Pos       : Natural;
   end record;

   --------------
   -- Is_Valid --
   --------------

   function Is_Valid (Ctx : View_Context; Frame : Byte_Array) return Boolean
   is (Decoder_Model.Frame_Control_Valid (Frame)
       and then Decoder_Model.Security_Control_Valid (Frame)
       and then Frame'Length >= Decoder_Model.MHR_Length_Excluding_IEs (Frame)

       --  Seq_Num_Pos is set to the position of the sequence number in Frame,
       --  if it is present.
       and then
         (Ctx.Seq_Num_Pos /= 0)
         = Decoder_Model.Is_Sequence_Number_Present (Frame)
       and then
         (if Decoder_Model.Is_Sequence_Number_Present (Frame)
          then
            Ctx.Seq_Num_Pos
            = Frame'First + Decoder_Model.Get_Sequence_Number_Offset (Frame))

       --  Dest_PAN_ID_Pos is set to the position of the destination PAN ID
       --  in Frame, if it is present.
       and then
         (Ctx.Dest_PAN_ID_Pos /= 0)
         = Decoder_Model.Is_Destination_PAN_ID_Present (Frame)
       and then
         (if Decoder_Model.Is_Destination_PAN_ID_Present (Frame)
          then
            Ctx.Dest_PAN_ID_Pos
            = Frame'First
              + Decoder_Model.Get_Destination_PAN_ID_Offset (Frame))

       --  Dest_Address_Pos is set to the position of the destination address
       --  in Frame, if it is present.
       and then
         (Ctx.Dest_Address_Pos /= 0)
         = (Decoder_Model.Get_Dest_Address_Mode (Frame) /= Not_Present)
       and then
         (if Decoder_Model.Get_Dest_Address_Mode (Frame) /= Not_Present
          then
            Ctx.Dest_Address_Pos
            = Frame'First
              + Decoder_Model.Get_Destination_Address_Offset (Frame))

       --  Src_PAN_ID_Pos is set to the position of the source PAN ID
       --  in Frame, if it is present.
       and then
         (Ctx.Src_PAN_ID_Pos /= 0)
         = Decoder_Model.Is_Source_PAN_ID_Present (Frame)
       and then
         (if Decoder_Model.Is_Source_PAN_ID_Present (Frame)
          then
            Ctx.Src_PAN_ID_Pos
            = Frame'First + Decoder_Model.Get_Source_PAN_ID_Offset (Frame))

       --  Src_Address_Pos is set to the position of the source address
       --  in Frame, if it is present.
       and then
         (Ctx.Src_Address_Pos /= 0)
         = (Decoder_Model.Get_Src_Address_Mode (Frame) /= Not_Present)
       and then
         (if Decoder_Model.Get_Src_Address_Mode (Frame) /= Not_Present
          then
            Ctx.Src_Address_Pos
            = Frame'First + Decoder_Model.Get_Source_Address_Offset (Frame))

       --  Check auxiliary security header fields
       and then
         (if Decoder_Model.Get_Security_Enabled (Frame) = Disabled
          then
            Ctx.Sec_Ctrl_Pos = 0
            and then Ctx.Frame_Cnt_Pos = 0
            and then Ctx.Key_ID_Pos = 0
          else

            --  Src_Address_Pos is set to the position of the security control
            --  byte in Frame.
            Ctx.Sec_Ctrl_Pos
            = Frame'First + Decoder_Model.Get_Security_Control_Offset (Frame)

            --  Frame_Cnt_Pos is set to the position of the frame counter
            --  in Frame, if it is present.
            and then
              (Ctx.Frame_Cnt_Pos /= 0)
              = Decoder_Model.Is_Frame_Counter_Present (Frame)
            and then
              (if Decoder_Model.Is_Frame_Counter_Present (Frame)
               then
                 Ctx.Frame_Cnt_Pos
                 = Frame'First
                   + Decoder_Model.Get_Frame_Counter_Offset (Frame))

            --  Key_ID_Pos is set to the position of the key ID field in Frame,
            --  if it is present.
            and then
              (Ctx.Key_ID_Pos /= 0) = Decoder_Model.Is_Key_ID_Present (Frame)
            and then
              (if Decoder_Model.Is_Key_ID_Present (Frame)
               then
                 Ctx.Key_ID_Pos
                 = Frame'First + Decoder_Model.Get_Key_ID_Offset (Frame))));

end AdaBee.MAC.Frames.Headers.Decoders.Views;
