--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Headers.Decoders.Views
  with SPARK_Mode
is

   procedure Validate_General_MAC_Header
     (Ctx : out View_Context; Frame : Byte_Array; Result : out Status_Code)
   with
     Global                 => null,
     Relaxed_Initialization => Ctx,
     Pre                    =>
       Frame'Length > 0
       and then Frame'Last < Integer'Last
       and then
         Decoder_Model.Get_Frame_Type (Frame)
         in Beacon | Data | Ack | MAC_Command,
     Post                   =>
       (Result = Success) = Decoder_Model.Is_MHR_Valid_Excluding_IEs (Frame)
       and then
         (if Result = Success
          then Ctx'Initialized and then Is_Valid (Ctx, Frame));

   procedure Validate_Multipurpose_MAC_Header
     (Ctx : out View_Context; Frame : Byte_Array; Result : out Status_Code)
   with
     Global                 => null,
     Relaxed_Initialization => Ctx,
     Pre                    =>
       Frame'Length > 0
       and then Frame'Last < Integer'Last
       and then Decoder_Model.Get_Frame_Type (Frame) = Multipurpose,
     Post                   =>
       (Result = Success) = Decoder_Model.Is_MHR_Valid_Excluding_IEs (Frame)
       and then
         (if Result = Success
          then Ctx'Initialized and then Is_Valid (Ctx, Frame));

   --------------
   -- Validate --
   --------------

   procedure Validate
     (Ctx : out View_Context; Frame : Byte_Array; Result : out Status_Code) is
   begin
      if Frame'Length = 0 then
         Result := Malformed_Frame;
         return;
      end if;

      case Get_Frame_Type (Frame) is
         when Beacon | Data | Ack | MAC_Command =>
            Validate_General_MAC_Header (Ctx, Frame, Result);

         when Multipurpose                      =>
            Validate_Multipurpose_MAC_Header (Ctx, Frame, Result);

         when Unsupported_Frame_Types           =>
            Result := Unsupported_Field;
      end case;
   end Validate;

   ----------------------------
   -- Validate_Frame_Control --
   ----------------------------

   procedure Validate_Frame_Control
     (Frame : Byte_Array; Result : out Status_Code)
   is
      G_FC : Frame_Control_Field;
      S_FC : MP_Short_Frame_Control_Field;
      L_FC : MP_Long_Frame_Control_Field;
   begin
      if Frame'Length = 0 then
         Result := Malformed_Frame;
         return;
      end if;

      --  Check for any reserved or unsupported values in the Frame Control

      case Get_Frame_Type (Frame) is
         when Beacon | Data | Ack | MAC_Command =>
            if Frame'Length < 2 then
               Result := Malformed_Frame;
            else
               G_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
               if G_FC.Dest_Address_Mode = Reserved
                 or G_FC.Src_Address_Mode = Reserved
                 or G_FC.Frame_Version = Reserved
               then
                  Result := Unsupported_Field;
               else
                  Result := Success;
               end if;
            end if;

         when Multipurpose                      =>
            S_FC := From_Bytes (Frame (Frame'First));

            if S_FC.Long_Frame_Control = Short then
               if S_FC.Dest_Address_Mode = Reserved
                 or S_FC.Src_Address_Mode = Reserved
               then
                  Result := Unsupported_Field;
               else
                  Result := Success;
               end if;

            elsif Frame'Length < 2 then
               Result := Malformed_Frame;

            else
               L_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));

               if L_FC.Dest_Address_Mode = Reserved
                 or L_FC.Src_Address_Mode = Reserved
                 or L_FC.Frame_Version /= Frame_Version_Field'First
               then
                  Result := Unsupported_Field;
               else
                  Result := Success;
               end if;
            end if;

         when Unsupported_Frame_Types           =>
            Result := Unsupported_Field;
      end case;
   end Validate_Frame_Control;

   ---------------------------------
   -- Validate_General_MAC_Header --
   ---------------------------------

   procedure Validate_General_MAC_Header
     (Ctx : out View_Context; Frame : Byte_Array; Result : out Status_Code)
   is
      FC : Frame_Control_Field;
      SC : Security_Control_Field;

      Dest_PAN_ID_Present : Boolean;
      Src_PAN_ID_Present  : Boolean;

      Pos : Positive;

   begin
      if Frame'Length < 2 then
         Result := Malformed_Frame;
         return;
      end if;

      FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));

      --  Check for reserved values

      if FC.Dest_Address_Mode = Reserved
        or FC.Src_Address_Mode = Reserved
        or FC.Frame_Version = Reserved
      then
         Result := Unsupported_Field;
         return;
      end if;

      pragma Assert (Decoder_Model.Frame_Control_Valid (Frame));
      pragma Assert (FC = Decoder_Model.Get_FC (Frame));

      --  Length check the frame, up to the end of the addressing fields

      Dest_PAN_ID_Present :=
        Is_Destination_PAN_ID_Present
          (Frame_Version            => FC.Frame_Version,
           Destination_Address_Mode => FC.Dest_Address_Mode,
           Source_Address_Mode      => FC.Src_Address_Mode,
           PAN_ID_Compression       => FC.PAN_ID_Compression);

      Src_PAN_ID_Present :=
        Is_Source_PAN_ID_Present
          (Frame_Version            => FC.Frame_Version,
           Destination_Address_Mode => FC.Dest_Address_Mode,
           Source_Address_Mode      => FC.Src_Address_Mode,
           PAN_ID_Compression       => FC.PAN_ID_Compression);

      if Frame'Length
        < 2
          + (if FC.SN_Suppression = Suppressed then 0 else 1)
          + (if Dest_PAN_ID_Present then 2 else 0)
          + (if Src_PAN_ID_Present then 2 else 0)
          + Address_Length (FC.Dest_Address_Mode)
          + Address_Length (FC.Src_Address_Mode)
      then
         Result := Malformed_Frame;
         return;
      end if;

      Pos := Frame'First + 2;

      --  Calculate the position of all the addressing fields

      --  Sequence Number field

      if FC.SN_Suppression = Not_Suppressed then
         Ctx.Seq_Num_Pos := Pos;
         Pos := Pos + 1;
      else
         Ctx.Seq_Num_Pos := 0;
      end if;

      --  Destination PAN ID field

      pragma
        Assert
          (Pos
           = Frame'First
             + Decoder_Model.Get_Destination_PAN_ID_Offset (Frame));

      if Dest_PAN_ID_Present then
         Ctx.Dest_PAN_ID_Pos := Pos;
         Pos := Pos + 2;
      else
         Ctx.Dest_PAN_ID_Pos := 0;
      end if;

      --  Destination Address field

      pragma
        Assert
          (Pos
           = Frame'First
             + Decoder_Model.Get_Destination_Address_Offset (Frame));

      case Valid_Address_Mode_Field (FC.Dest_Address_Mode) is
         when Not_Present =>
            Ctx.Dest_Address_Pos := 0;

         when Short       =>
            Ctx.Dest_Address_Pos := Pos;
            Pos := Pos + 2;

         when Extended    =>
            Ctx.Dest_Address_Pos := Pos;
            Pos := Pos + 8;
      end case;

      --  Source PAN ID field

      pragma
        Assert
          (Pos = Frame'First + Decoder_Model.Get_Source_PAN_ID_Offset (Frame));

      if Src_PAN_ID_Present then
         Ctx.Src_PAN_ID_Pos := Pos;
         Pos := Pos + 2;
      else
         Ctx.Src_PAN_ID_Pos := 0;
      end if;

      --  Source Address field

      pragma
        Assert
          (Pos
           = Frame'First + Decoder_Model.Get_Source_Address_Offset (Frame));

      case Valid_Address_Mode_Field (FC.Src_Address_Mode) is
         when Not_Present =>
            Ctx.Src_Address_Pos := 0;

         when Short       =>
            Ctx.Src_Address_Pos := Pos;
            Pos := Pos + 2;

         when Extended    =>
            Ctx.Src_Address_Pos := Pos;
            Pos := Pos + 8;
      end case;

      --  Validate the auxiliary security header

      pragma
        Assert
          (Pos
           = Frame'First
             + Decoder_Model.Get_Aux_Security_Header_Offset (Frame));

      if FC.Security_Enabled = Disabled then
         Ctx.Sec_Ctrl_Pos := 0;
         Ctx.Frame_Cnt_Pos := 0;
         Ctx.Key_ID_Pos := 0;

      elsif Pos > Frame'Last then
         Result := Malformed_Frame;
         return;

      else
         --  Security Control field

         SC := From_Bytes (Frame (Pos));

         if (Frame'Last - Pos) + 1
           < 1
             + (if SC.FC_Suppression = Suppressed then 0 else 4)
             + Key_ID_Length (SC.Key_ID_Mode)
         then
            Result := Malformed_Frame;
            return;
         end if;

         pragma Assert (Decoder_Model.Security_Control_Valid (Frame));

         Ctx.Sec_Ctrl_Pos := Pos;
         Pos := Pos + 1;

         --  Frame Counter field

         pragma
           Assert
             (Pos
              = Frame'First + Decoder_Model.Get_Frame_Counter_Offset (Frame));

         if SC.FC_Suppression = Not_Suppressed then
            Ctx.Frame_Cnt_Pos := Pos;
            Pos := Pos + 4;
         else
            Ctx.Frame_Cnt_Pos := 0;
         end if;

         --  Key ID field

         pragma
           Assert
             (Pos = Frame'First + Decoder_Model.Get_Key_ID_Offset (Frame));

         if SC.Key_ID_Mode /= 0 then
            Ctx.Key_ID_Pos := Pos;
         else
            Ctx.Key_ID_Pos := 0;
         end if;
      end if;

      Result := Success;
   end Validate_General_MAC_Header;

   --------------------------------------
   -- Validate_Multipurpose_MAC_Header --
   --------------------------------------

   procedure Validate_Multipurpose_MAC_Header
     (Ctx : out View_Context; Frame : Byte_Array; Result : out Status_Code)
   is
      FC       : MP_Long_Frame_Control_Field;
      Short_FC : MP_Short_Frame_Control_Field;
      SC       : Security_Control_Field;

      Pos : Positive;

   begin
      if Frame'Length = 0 then
         Result := Malformed_Frame;
         return;
      end if;

      Short_FC := From_Bytes (Frame (Frame'First));

      if Short_FC.Long_Frame_Control = Long then
         if Frame'Length < 2 then
            Result := Malformed_Frame;
            return;
         else
            FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
            Pos := Frame'First + 2;
         end if;
      else
         FC := To_Long_Frame_Control (Short_FC);
         Pos := Frame'First + 1;
      end if;

      --  Check for reserved values

      if FC.Dest_Address_Mode = Reserved
        or FC.Src_Address_Mode = Reserved
        or FC.Frame_Version /= Frame_Version_Field'First
      then
         Result := Unsupported_Field;
         return;
      end if;

      pragma
        Assert_And_Cut
          (Decoder_Model.Frame_Control_Valid (Frame)
           and then
             Pos
             = Frame'First + Decoder_Model.Get_Sequence_Number_Offset (Frame)
           and then FC = Get_Multipurpose_Frame_Control (Frame));

      --  Length check the frame, up to the end of the addressing fields

      if Frame'Length
        < (Pos - Frame'First) --  Frame control length
          + (if FC.SN_Suppression = Suppressed then 0 else 1)
          + (if FC.PAN_ID_Present = Present then 2 else 0)
          + Address_Length (FC.Dest_Address_Mode)
          + Address_Length (FC.Src_Address_Mode)
      then
         Result := Malformed_Frame;
         return;
      end if;

      --  Calculate the position of all the addressing fields

      --  Sequence Number field

      if FC.SN_Suppression = Not_Suppressed then
         Ctx.Seq_Num_Pos := Pos;
         Pos := Pos + 1;
      else
         Ctx.Seq_Num_Pos := 0;
      end if;

      --  Destination PAN ID field

      pragma
        Assert
          (Pos
           = Frame'First
             + Decoder_Model.Get_Destination_PAN_ID_Offset (Frame));

      if FC.PAN_ID_Present = Present then
         Ctx.Dest_PAN_ID_Pos := Pos;
         Pos := Pos + 2;
      else
         Ctx.Dest_PAN_ID_Pos := 0;
      end if;

      --  Destination Address field

      pragma
        Assert
          (Pos
           = Frame'First
             + Decoder_Model.Get_Destination_Address_Offset (Frame));

      case Valid_Address_Mode_Field (FC.Dest_Address_Mode) is
         when Not_Present =>
            Ctx.Dest_Address_Pos := 0;

         when Short       =>
            Ctx.Dest_Address_Pos := Pos;
            Pos := Pos + 2;

         when Extended    =>
            Ctx.Dest_Address_Pos := Pos;
            Pos := Pos + 8;
      end case;

      --  The Source PAN ID field is never present in multipurpose frames.
      --  Ref. IEEE 802.15.4-2024 Section 7.3.5.1

      pragma Assert (not Decoder_Model.Is_Source_PAN_ID_Present (Frame));
      Ctx.Src_PAN_ID_Pos := 0;

      --  Source Address field

      pragma
        Assert
          (Pos
           = Frame'First + Decoder_Model.Get_Source_Address_Offset (Frame));

      case Valid_Address_Mode_Field (FC.Src_Address_Mode) is
         when Not_Present =>
            Ctx.Src_Address_Pos := 0;

         when Short       =>
            Ctx.Src_Address_Pos := Pos;
            Pos := Pos + 2;

         when Extended    =>
            Ctx.Src_Address_Pos := Pos;
            Pos := Pos + 8;
      end case;

      --  Validate the auxiliary security header

      pragma
        Assert
          (Pos
           = Frame'First
             + Decoder_Model.Get_Aux_Security_Header_Offset (Frame));

      if FC.Security_Enabled = Disabled then
         Ctx.Sec_Ctrl_Pos := 0;
         Ctx.Frame_Cnt_Pos := 0;
         Ctx.Key_ID_Pos := 0;

      elsif Pos > Frame'Last then
         Result := Malformed_Frame;
         return;

      else
         --  Security Control field

         SC := From_Bytes (Frame (Pos));

         if (Frame'Last - Pos) + 1
           < 1
             + (if SC.FC_Suppression = Suppressed then 0 else 4)
             + Key_ID_Length (SC.Key_ID_Mode)
         then
            Result := Malformed_Frame;
            return;
         end if;

         pragma Assert (Decoder_Model.Security_Control_Valid (Frame));

         Ctx.Sec_Ctrl_Pos := Pos;
         Pos := Pos + 1;

         --  Frame Counter field

         pragma
           Assert
             (Pos
              = Frame'First + Decoder_Model.Get_Frame_Counter_Offset (Frame));

         if SC.FC_Suppression = Not_Suppressed then
            Ctx.Frame_Cnt_Pos := Pos;
            Pos := Pos + 4;
         else
            Ctx.Frame_Cnt_Pos := 0;
         end if;

         --  Key ID field

         pragma
           Assert
             (Pos = Frame'First + Decoder_Model.Get_Key_ID_Offset (Frame));

         if SC.Key_ID_Mode /= 0 then
            Ctx.Key_ID_Pos := Pos;
         else
            Ctx.Key_ID_Pos := 0;
         end if;
      end if;

      Result := Success;
   end Validate_Multipurpose_MAC_Header;

   --------------------
   -- Get_Frame_Type --
   --------------------

   function Get_Frame_Type (Frame : Byte_Array) return Frame_Type_Field
   is (MP_Short_Frame_Control_Field'(From_Bytes (Frame (Frame'First)))
         .Frame_Type);

   -------------------------------
   -- Get_General_Frame_Control --
   -------------------------------

   function Get_General_Frame_Control
     (Frame : Byte_Array) return Valid_Frame_Control_Field
   is (From_Bytes (Frame (Frame'First .. Frame'First + 1)));

   ------------------------------------
   -- Get_Multipurpose_Frame_Control --
   ------------------------------------

   function Get_Multipurpose_Frame_Control
     (Frame : Byte_Array) return Valid_MP_Long_Frame_Control_Field
   is (if MP_Short_Frame_Control_Field'(From_Bytes (Frame (Frame'First)))
            .Long_Frame_Control
         = Short
       then To_Long_Frame_Control (From_Bytes (Frame (Frame'First)))
       else From_Bytes (Frame (Frame'First .. Frame'First + 1)));

   ----------------------------
   -- Get_Long_Frame_Control --
   ----------------------------

   function Get_Long_Frame_Control
     (Frame : Byte_Array) return Long_Frame_Control_Field
   is
      FC : constant MP_Short_Frame_Control_Field :=
        From_Bytes (Frame (Frame'First));
   begin
      if FC.Frame_Type = Multipurpose then
         return FC.Long_Frame_Control;
      else
         return Long;
      end if;
   end Get_Long_Frame_Control;

   --------------------------
   -- Get_Security_Enabled --
   --------------------------

   function Get_Security_Enabled
     (Frame : Byte_Array) return Security_Enabled_Field
   is
      L_FC : MP_Long_Frame_Control_Field;
      G_FC : Frame_Control_Field;
   begin
      if Get_Frame_Type (Frame) = Multipurpose then
         if From_Bytes (Frame (Frame'First)).Long_Frame_Control = Short then
            return Disabled;
         else
            L_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
            return L_FC.Security_Enabled;
         end if;
      else
         G_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
         return G_FC.Security_Enabled;
      end if;
   end Get_Security_Enabled;

   -----------------------
   -- Get_Frame_Pending --
   -----------------------

   function Get_Frame_Pending (Frame : Byte_Array) return Frame_Pending_Field
   is
      L_FC : MP_Long_Frame_Control_Field;
      G_FC : Frame_Control_Field;
   begin
      if Get_Frame_Type (Frame) = Multipurpose then
         if From_Bytes (Frame (Frame'First)).Long_Frame_Control = Short then
            return Not_Pending;
         else
            L_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
            return L_FC.Frame_Pending;
         end if;
      else
         G_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
         return G_FC.Frame_Pending;
      end if;
   end Get_Frame_Pending;

   -----------------------
   -- Get_Ack_Required --
   -----------------------

   function Get_Ack_Required (Frame : Byte_Array) return Ack_Required_Field is
      L_FC : MP_Long_Frame_Control_Field;
      G_FC : Frame_Control_Field;
   begin
      if Get_Frame_Type (Frame) = Multipurpose then
         if From_Bytes (Frame (Frame'First)).Long_Frame_Control = Short then
            return Not_Required;
         else
            L_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
            return L_FC.Ack_Required;
         end if;
      else
         G_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
         return G_FC.AR;
      end if;
   end Get_Ack_Required;

   --------------------------------
   -- Get_Seq_Number_Suppression --
   --------------------------------

   function Get_Seq_Number_Suppression
     (Frame : Byte_Array) return Seq_Number_Suppression_Field
   is
      L_FC : MP_Long_Frame_Control_Field;
      G_FC : Frame_Control_Field;
   begin
      if Get_Frame_Type (Frame) = Multipurpose then
         if From_Bytes (Frame (Frame'First)).Long_Frame_Control = Short then
            return Suppressed;
         else
            L_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
            return L_FC.SN_Suppression;
         end if;
      else
         G_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
         return G_FC.SN_Suppression;
      end if;
   end Get_Seq_Number_Suppression;

   --------------------
   -- Get_IE_Present --
   --------------------

   function Get_IE_Present (Frame : Byte_Array) return IE_Present_Field is
      L_FC : MP_Long_Frame_Control_Field;
      G_FC : Frame_Control_Field;
   begin
      if Get_Frame_Type (Frame) = Multipurpose then
         if From_Bytes (Frame (Frame'First)).Long_Frame_Control = Short then
            return Not_Present;
         else
            L_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
            return L_FC.IE_Present;
         end if;
      else
         G_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
         return G_FC.IE_Present;
      end if;
   end Get_IE_Present;

   ---------------------------
   -- Get_Dest_Address_Mode --
   ---------------------------

   function Get_Dest_Address_Mode
     (Frame : Byte_Array) return Valid_Address_Mode_Field
   is
      S_FC : MP_Short_Frame_Control_Field;
      G_FC : Frame_Control_Field;
   begin
      if Get_Frame_Type (Frame) = Multipurpose then
         S_FC := From_Bytes (Frame (Frame'First));
         return S_FC.Dest_Address_Mode;
      else
         G_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
         return G_FC.Dest_Address_Mode;
      end if;
   end Get_Dest_Address_Mode;

   --------------------------
   -- Get_Src_Address_Mode --
   --------------------------

   function Get_Src_Address_Mode
     (Frame : Byte_Array) return Valid_Address_Mode_Field
   is
      S_FC : MP_Short_Frame_Control_Field;
      G_FC : Frame_Control_Field;
   begin
      if Get_Frame_Type (Frame) = Multipurpose then
         S_FC := From_Bytes (Frame (Frame'First));
         return S_FC.Src_Address_Mode;
      else
         G_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
         return G_FC.Src_Address_Mode;
      end if;
   end Get_Src_Address_Mode;

   -----------------------
   -- Get_Frame_Version --
   -----------------------

   function Get_Frame_Version
     (Frame : Byte_Array) return Valid_Frame_Version_Field
   is
      L_FC : MP_Long_Frame_Control_Field;
      G_FC : Frame_Control_Field;
   begin
      if Get_Frame_Type (Frame) = Multipurpose then
         if From_Bytes (Frame (Frame'First)).Long_Frame_Control = Short then
            return Frame_Version_Field'First;
         else
            L_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
            return L_FC.Frame_Version;
         end if;
      else
         G_FC := From_Bytes (Frame (Frame'First .. Frame'First + 1));
         return G_FC.Frame_Version;
      end if;
   end Get_Frame_Version;

   -------------------------
   -- Get_Sequence_Number --
   -------------------------

   function Get_Sequence_Number
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Sequence_Number
   is (if Ctx.Seq_Num_Pos = 0
       then Variant_Sequence_Number'(Suppression => Suppressed)
       else
         Variant_Sequence_Number'
           (Suppression => Not_Suppressed, Number => Frame (Ctx.Seq_Num_Pos)));

   ----------------------------
   -- Get_Destination_PAN_ID --
   ----------------------------

   function Get_Destination_PAN_ID
     (Frame : Byte_Array; Ctx : View_Context) return Variant_PAN_ID
   is (if Ctx.Dest_PAN_ID_Pos = 0
       then Variant_PAN_ID'(Present => False)
       else
         Variant_PAN_ID'
           (Present => True,
            PAN_ID  =>
              From_Bytes
                (Frame (Ctx.Dest_PAN_ID_Pos .. Ctx.Dest_PAN_ID_Pos + 1))));

   -----------------------------
   -- Get_Destination_Address --
   -----------------------------

   function Get_Destination_Address
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Address
   is (if Ctx.Dest_Address_Pos = 0
       then Variant_Address'(Mode => Not_Present)
       elsif Get_Dest_Address_Mode (Frame) = Short
       then
         Variant_Address'
           (Mode          => Short,
            Short_Address =>
              From_Bytes
                (Frame (Ctx.Dest_Address_Pos .. Ctx.Dest_Address_Pos + 1)))
       else
         Variant_Address'
           (Mode             => Extended,
            Extended_Address =>
              From_Bytes
                (Frame (Ctx.Dest_Address_Pos .. Ctx.Dest_Address_Pos + 7))));

   -----------------------
   -- Get_Source_PAN_ID --
   -----------------------

   function Get_Source_PAN_ID
     (Frame : Byte_Array; Ctx : View_Context) return Variant_PAN_ID
   is (if Ctx.Src_PAN_ID_Pos = 0
       then Variant_PAN_ID'(Present => False)
       else
         Variant_PAN_ID'
           (Present => True,
            PAN_ID  =>
              From_Bytes
                (Frame (Ctx.Src_PAN_ID_Pos .. Ctx.Src_PAN_ID_Pos + 1))));

   ------------------------------------
   -- Get_Decompressed_Source_PAN_ID --
   ------------------------------------

   function Get_Decompressed_Source_PAN_ID
     (Frame : Byte_Array; Ctx : View_Context) return Variant_PAN_ID
   is
      FC : Frame_Control_Field;
   begin
      if Get_Frame_Type (Frame) = Multipurpose then
         --  Source PAN ID field is not present in this frame type
         return Variant_PAN_ID'(Present => False);

      elsif Ctx.Src_PAN_ID_Pos /= 0 then
         --  The Source PAN ID is present in the frame
         return
           Variant_PAN_ID'
             (Present => True,
              PAN_ID  =>
                From_Bytes
                  (Frame (Ctx.Src_PAN_ID_Pos .. Ctx.Src_PAN_ID_Pos + 1)));

      else
         --  The Source PAN ID is not present in the frame, but it might have
         --  been omitted due to PAN ID compression. If this is the case, then
         --  it is the same as the Destination PAN ID so return that.

         FC := Get_General_Frame_Control (Frame);

         if Is_Source_PAN_ID_Compressed
              (Frame_Version            => FC.Frame_Version,
               Destination_Address_Mode => FC.Dest_Address_Mode,
               Source_Address_Mode      => FC.Src_Address_Mode,
               PAN_ID_Compression       => FC.PAN_ID_Compression)
         then
            pragma Assert (Ctx.Dest_PAN_ID_Pos /= 0);

            return
              Variant_PAN_ID'
                (Present => True,
                 PAN_ID  =>
                   From_Bytes
                     (Frame (Ctx.Dest_PAN_ID_Pos .. Ctx.Dest_PAN_ID_Pos + 1)));

         else
            return Variant_PAN_ID'(Present => False);
         end if;
      end if;
   end Get_Decompressed_Source_PAN_ID;

   ------------------------
   -- Get_Source_Address --
   ------------------------

   function Get_Source_Address
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Address
   is (if Ctx.Src_Address_Pos = 0
       then Variant_Address'(Mode => Not_Present)
       elsif Get_Src_Address_Mode (Frame) = Short
       then
         Variant_Address'
           (Mode          => Short,
            Short_Address =>
              From_Bytes
                (Frame (Ctx.Src_Address_Pos .. Ctx.Src_Address_Pos + 1)))
       else
         Variant_Address'
           (Mode             => Extended,
            Extended_Address =>
              From_Bytes
                (Frame (Ctx.Src_Address_Pos .. Ctx.Src_Address_Pos + 7))));

   --------------------------
   -- Get_Security_Control --
   --------------------------

   function Get_Security_Control
     (Frame : Byte_Array; Ctx : View_Context) return Security_Control_Field
   is (From_Bytes (Frame (Ctx.Sec_Ctrl_Pos)));

   -----------------------
   -- Get_Frame_Counter --
   -----------------------

   function Get_Frame_Counter
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Frame_Counter
   is (if Ctx.Frame_Cnt_Pos = 0
       then Variant_Frame_Counter'(Suppression => Suppressed)
       else
         Variant_Frame_Counter'
           (Suppression   => Not_Suppressed,
            Frame_Counter =>
              From_Bytes
                (Frame (Ctx.Frame_Cnt_Pos .. Ctx.Frame_Cnt_Pos + 3))));

   ----------------
   -- Get_Key_ID --
   ----------------

   function Get_Key_ID
     (Frame : Byte_Array; Ctx : View_Context) return Variant_Key_ID
   is (if Ctx.Key_ID_Pos = 0
       then Variant_Key_ID'(Mode => 0)
       else
         (case Get_Security_Control (Frame, Ctx).Key_ID_Mode is
            when 0 => Variant_Key_ID'(Mode => 0),

            when 1 =>
              Variant_Key_ID'
                (Mode      => 1,
                 Key_Index => Key_Index_Field (Frame (Ctx.Key_ID_Pos))),

            when 2 =>
              Variant_Key_ID'
                (Mode         => 2,
                 Key_Index    => Key_Index_Field (Frame (Ctx.Key_ID_Pos)),
                 Key_Source_4 =>
                   Key_Source_Field
                     (Frame (Ctx.Key_ID_Pos + 1 .. Ctx.Key_ID_Pos + 4))),

            when 3 =>
              Variant_Key_ID'
                (Mode         => 3,
                 Key_Index    => Key_Index_Field (Frame (Ctx.Key_ID_Pos)),
                 Key_Source_8 =>
                   Key_Source_Field
                     (Frame (Ctx.Key_ID_Pos + 1 .. Ctx.Key_ID_Pos + 8)))));

   -----------------------------
   -- Get_Aux_Security_Header --
   -----------------------------

   function Get_Aux_Security_Header
     (Frame : Byte_Array; Ctx : View_Context)
      return Variant_Aux_Security_Header
   is (if Ctx.Sec_Ctrl_Pos = 0
       then Variant_Aux_Security_Header'(Security_Enabled => Disabled)
       else
         Variant_Aux_Security_Header'
           (Security_Enabled => Enabled,
            Frame_Counter    => Get_Frame_Counter (Frame, Ctx),
            Key_ID           => Get_Key_ID (Frame, Ctx),
            Security_Level   =>
              Get_Security_Control (Frame, Ctx).Security_Level,
            ASN_In_Nonce     =>
              Get_Security_Control (Frame, Ctx).Nonce_Source));

end AdaBee.MAC.Frames.Headers.Decoders.Views;
