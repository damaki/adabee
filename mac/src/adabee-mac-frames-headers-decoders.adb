--
--  Copyright 2024 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Headers.Decoders
  with SPARK_Mode
is

   function To_Frame_Type is new
     Ada.Unchecked_Conversion (Source => Bits_3, Target => Frame_Type_Field);

   function To_Frame_Type
     (Byte : Interfaces.Unsigned_8) return Frame_Type_Field
   is (To_Frame_Type (Bits_3 (Byte and 2#111#)));

   function Address_Field_Length (Mode : Address_Mode_Field) return Natural
   is (case Mode is
         when Not_Present | Reserved => 0,
         when Short                  => 2,
         when Extended               => 8);

   procedure Decode_Frame_Control_Field
     (Buffer        : Byte_Array;
      Frame_Control : out Frame_Control_Field;
      Result        : out Status_Code)
   with
     Inline,
     Global  => null,
     Depends => (Frame_Control => Buffer, Result => Buffer),
     Pre     =>
       Buffer'Length > 0
       and then
         To_Frame_Type (Buffer (Buffer'First))
         not in Multipurpose | Unsupported_Frame_Types,
     Post    =>
       (if Result = Success
        then
          (Frame_Control.Frame_Type = To_Frame_Type (Buffer (Buffer'First))
           and then Frame_Control.Frame_Version /= Reserved
           and then Frame_Control.Dest_Address_Mode /= Reserved
           and then Frame_Control.Src_Address_Mode /= Reserved
           and then Buffer'Length >= 2));

   procedure Decode_MP_Control_Field
     (Buffer        : Byte_Array;
      Frame_Control : out MP_Long_Frame_Control_Field;
      Length        : out Natural;
      Result        : out Status_Code)
   with
     Inline,
     Global  => null,
     Depends => (Frame_Control => Buffer, Length => Buffer, Result => Buffer),
     Pre     =>
       Buffer'Length > 0
       and then To_Frame_Type (Buffer (Buffer'First)) = Multipurpose,
     Post    =>
       Length <= 2
       and then Length <= Buffer'Length
       and then
         (if Result = Success
          then
            (Frame_Control.Frame_Type = To_Frame_Type (Buffer (Buffer'First))
             and then Frame_Control.Frame_Version /= Reserved
             and then Frame_Control.Dest_Address_Mode /= Reserved
             and then Frame_Control.Src_Address_Mode /= Reserved
             and then
               (case Frame_Control.Long_Frame_Control is
                  when Short => Length = 1,
                  when Long  => Length = 2)));

   procedure Decode_Sequence_Number_Field
     (Buffer          : Byte_Array;
      Offset          : in out Natural;
      Sequence_Number : out Variant_Sequence_Number)
   with
     Inline,
     Global  => null,
     Depends => (Sequence_Number => (Buffer, Offset), Offset => Offset),
     Pre     =>
       not Sequence_Number'Constrained and then Offset < Buffer'Length,
     Post    => Offset = Offset'Old + 1;

   procedure Decode_PAN_ID_Field
     (Buffer : Byte_Array;
      Offset : in out Natural;
      PAN_ID : out Variant_PAN_ID)
   with
     Inline,
     Global  => null,
     Depends => (PAN_ID => (Buffer, Offset), Offset => Offset),
     Pre     => not PAN_ID'Constrained and then Offset <= Buffer'Length - 2,
     Post    => Offset = Offset'Old + 2 and then PAN_ID.Present;

   procedure Decode_Extended_Address_Field
     (Buffer  : Byte_Array;
      Offset  : in out Natural;
      Address : out Variant_Address)
   with
     Inline,
     Global  => null,
     Depends => (Address => (Buffer, Offset), Offset => Offset),
     Pre     => not Address'Constrained and then Offset <= Buffer'Length - 8,
     Post    => Offset = Offset'Old + 8 and then Address.Mode = Extended;

   procedure Decode_Short_Address_Field
     (Buffer  : Byte_Array;
      Offset  : in out Natural;
      Address : out Variant_Address)
   with
     Inline,
     Global  => null,
     Depends => (Address => (Buffer, Offset), Offset => Offset),
     Pre     => not Address'Constrained and then Offset <= Buffer'Length - 2,
     Post    => Offset = Offset'Old + 2 and then Address.Mode = Short;

   procedure Decode_Aux_Security_Header
     (Buffer : Byte_Array;
      Offset : in out Natural;
      ASH    : in out Variant_Aux_Security_Header;
      Result : out Status_Code)
   with
     Inline,
     Global  => null,
     Depends =>
       (ASH    => (Buffer, Offset),
        Result => (Buffer, Offset),
        Offset => (Buffer, Offset),
        null   => ASH),
     Pre     => not ASH'Constrained and then Offset <= Buffer'Length,
     Post    =>
       Offset - Offset'Old <= Max_Aux_Security_Header_Length
       and then
         (if Result = Success
          then
            (Offset > Offset'Old
             and then Offset <= Buffer'Length
             and then ASH.Security_Enabled = Enabled)
          else Offset in Offset'Old .. Buffer'Length);

   procedure Decode_Security_Control_Field
     (Buffer : Byte_Array;
      Offset : in out Natural;
      SC     : out Security_Control_Field;
      Result : out Status_Code)
   with
     Inline,
     Global  => null,
     Depends =>
       (SC     => (Buffer, Offset),
        Result => (Buffer, Offset),
        Offset => (Buffer, Offset)),
     Post    =>
       (if Result = Success
        then (Offset = Offset'Old + 1 and then Offset <= Buffer'Length)
        else Offset = Offset'Old);

   procedure Decode_Frame_Counter_Field
     (Buffer : Byte_Array;
      Offset : in out Natural;
      FC     : out Variant_Frame_Counter;
      Result : out Status_Code)
   with
     Inline,
     Global  => null,
     Depends =>
       (FC     => (Buffer, Offset),
        Result => (Buffer, Offset),
        Offset => (Buffer, Offset)),
     Pre     => not FC'Constrained,
     Post    =>
       (if Result = Success
        then
          (Offset = Offset'Old + 4
           and then Offset <= Buffer'Length
           and then FC.Suppression = Not_Suppressed)
        else Offset = Offset'Old and then FC.Suppression = Suppressed);

   procedure Decode_Key_ID_Field
     (Buffer : Byte_Array;
      Mode   : Key_ID_Mode_Field;
      Offset : in out Natural;
      Key_ID : out Variant_Key_ID;
      Result : out Status_Code)
   with
     Inline,
     Global         => null,
     Depends        =>
       (Key_ID => (Buffer, Mode, Offset),
        Result => (Buffer, Mode, Offset),
        Offset => (Buffer, Mode, Offset)),
     Pre            => not Key_ID'Constrained,
     Post           =>
       (if Result = Success
        then Key_ID.Mode = Mode and then Offset <= Buffer'Length
        else Offset = Offset'Old),
     Contract_Cases =>
       (Mode = 0 => Offset = Offset'Old,
        Mode = 1 => (if Result = Success then Offset = Offset'Old + 1),
        Mode = 2 => (if Result = Success then Offset = Offset'Old + 5),
        Mode = 3 => (if Result = Success then Offset = Offset'Old + 9));

   procedure Decode_Normal_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   with
     Global => null,
     Pre    =>
       Buffer'Length > 0
       and then
         To_Frame_Type (Buffer (Buffer'First))
         not in Multipurpose | Unsupported_Frame_Types,
     Post   =>
       (Length <= Buffer'Length
        and then Length <= Max_MHR_Length
        and then
          (if Result = Success
           then
             (MHR.Frame_Version /= Reserved
              and then MHR.Destination_Address.Mode /= Reserved
              and then MHR.Source_Address.Mode /= Reserved)));

   procedure Decode_Multipurpose_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   with
     Global => null,
     Pre    =>
       Buffer'Length > 0
       and then To_Frame_Type (Buffer (Buffer'First)) = Multipurpose,
     Post   =>
       (Length <= Buffer'Length
        and then Length <= Max_MHR_Length
        and then
          (if Result = Success
           then
             (MHR.Frame_Version /= Reserved
              and then MHR.Destination_Address.Mode /= Reserved
              and then MHR.Source_Address.Mode /= Reserved
              and then MHR.Frame_Type = Multipurpose
              and then not MHR.Source_PAN_ID.Present)));

   -------------------------
   --  Decode_MAC_Header  --
   -------------------------

   procedure Decode_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code) is
   begin
      case To_Frame_Type (Buffer (Buffer'First)) is
         when Beacon | Data | Ack | MAC_Command =>
            Decode_Normal_MAC_Header (Buffer, MHR, Length, Result);

         when Multipurpose                      =>
            Decode_Multipurpose_MAC_Header (Buffer, MHR, Length, Result);

         when Unsupported_Frame_Types           =>
            --  Frame type is not supported in this implementation

            MHR :=
              (Frame_Type          => Frame_Type_Field'First,
               Frame_Pending       => Not_Pending,
               AR                  => Not_Required,
               IE_Present          => Not_Present,
               Frame_Version       => Frame_Version_Field'First,
               Sequence_Number     => (Suppression => Suppressed),
               Destination_PAN_ID  => (Present => False),
               Destination_Address => (Mode => Not_Present),
               Source_PAN_ID       => (Present => False),
               Source_Address      => (Mode => Not_Present),
               Aux_Security_Header => (Security_Enabled => Disabled));

            Length := 0;
            Result := Unsupported_Field;
      end case;
   end Decode_MAC_Header;

   ------------------------------
   -- Decode_Normal_MAC_Header --
   ------------------------------

   procedure Decode_Normal_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   is
      Frame_Control       : Frame_Control_Field;
      Addr_Fields_Length  : Natural;
      Dest_PAN_ID_Present : Boolean;
      Src_PAN_ID_Present  : Boolean;

   begin
      MHR :=
        (Frame_Type          => Frame_Type_Field'First,
         Frame_Pending       => Not_Pending,
         AR                  => Not_Required,
         IE_Present          => Not_Present,
         Frame_Version       => Frame_Version_Field'First,
         Sequence_Number     => (Suppression => Suppressed),
         Destination_PAN_ID  => (Present => False),
         Destination_Address => (Mode => Not_Present),
         Source_PAN_ID       => (Present => False),
         Source_Address      => (Mode => Not_Present),
         Aux_Security_Header => (Security_Enabled => Disabled));

      Decode_Frame_Control_Field
        (Buffer => Buffer, Frame_Control => Frame_Control, Result => Result);

      if Result /= Success then
         Length := 0;
         return;
      end if;

      MHR.Frame_Type := Frame_Control.Frame_Type;
      MHR.Frame_Pending := Frame_Control.Frame_Pending;
      MHR.AR := Frame_Control.AR;
      MHR.IE_Present := Frame_Control.IE_Present;
      MHR.Frame_Version := Frame_Control.Frame_Version;

      Length := 2;

      pragma Assert (Length <= Buffer'Length);

      --  Calculate the length of the MHR addressing fields (including the
      --  sequence number), then do a length check on the buffer to verify
      --  that the buffer is big enough to hold all those fields.

      Dest_PAN_ID_Present :=
        Is_Destination_PAN_ID_Present
          (Frame_Version            => Frame_Control.Frame_Version,
           Destination_Address_Mode => Frame_Control.Dest_Address_Mode,
           Source_Address_Mode      => Frame_Control.Src_Address_Mode,
           PAN_ID_Compression       => Frame_Control.PAN_ID_Compression);

      Src_PAN_ID_Present :=
        Is_Source_PAN_ID_Present
          (Frame_Version            => Frame_Control.Frame_Version,
           Destination_Address_Mode => Frame_Control.Dest_Address_Mode,
           Source_Address_Mode      => Frame_Control.Src_Address_Mode,
           PAN_ID_Compression       => Frame_Control.PAN_ID_Compression);

      Addr_Fields_Length :=
        (if Frame_Control.SN_Suppression = Not_Suppressed then 1 else 0)
        + Address_Field_Length (Frame_Control.Dest_Address_Mode)
        + Address_Field_Length (Frame_Control.Src_Address_Mode)
        + (if Dest_PAN_ID_Present then 2 else 0)
        + (if Src_PAN_ID_Present then 2 else 0);

      if Buffer'Length < Length + Addr_Fields_Length then
         Result := Malformed_Frame;
         return;
      end if;

      --  Decode the Sequence Number (if present)

      if Frame_Control.SN_Suppression = Not_Suppressed then
         Decode_Sequence_Number_Field
           (Buffer          => Buffer,
            Offset          => Length,
            Sequence_Number => MHR.Sequence_Number);
      end if;

      pragma Assert (Length in 2 .. 3);
      pragma Assert (Length <= Buffer'Length);

      --  Decode the Destination PAN ID field (if present)
      if Dest_PAN_ID_Present then
         Decode_PAN_ID_Field
           (Buffer => Buffer,
            Offset => Length,
            PAN_ID => MHR.Destination_PAN_ID);
      end if;

      pragma Assert (Length in 2 .. 5);
      pragma Assert (Length <= Buffer'Length);

      --  Decode the Destination Address field (if present)
      case Frame_Control.Dest_Address_Mode is
         when Extended    =>
            Decode_Extended_Address_Field
              (Buffer  => Buffer,
               Offset  => Length,
               Address => MHR.Destination_Address);

         when Short       =>
            Decode_Short_Address_Field
              (Buffer  => Buffer,
               Offset  => Length,
               Address => MHR.Destination_Address);

         when Reserved    =>
            raise Program_Error; --  Unreachable

         when Not_Present =>
            null;
      end case;

      pragma
        Assert
          (MHR.Destination_Address.Mode = Frame_Control.Dest_Address_Mode);

      pragma Assert (Length in 2 .. 13);
      pragma Assert (Length <= Buffer'Length);

      --  Decode the Source PAN ID field (if present)
      if Src_PAN_ID_Present then
         Decode_PAN_ID_Field
           (Buffer => Buffer, Offset => Length, PAN_ID => MHR.Source_PAN_ID);
      end if;

      pragma Assert (Length in 2 .. 15);
      pragma Assert (Length <= Buffer'Length);

      --  Decode the Source Address field (if present)
      case Frame_Control.Src_Address_Mode is
         when Extended    =>
            Decode_Extended_Address_Field
              (Buffer  => Buffer,
               Offset  => Length,
               Address => MHR.Source_Address);

         when Short       =>
            Decode_Short_Address_Field
              (Buffer  => Buffer,
               Offset  => Length,
               Address => MHR.Source_Address);

         when Reserved    =>
            raise Program_Error; --  Unreachable

         when Not_Present =>
            null;
      end case;

      pragma Assert (MHR.Source_Address.Mode = Frame_Control.Src_Address_Mode);
      pragma Assert (Length in 2 .. 23);
      pragma Assert (Length <= Buffer'Length);

      if Frame_Control.Security_Enabled = Enabled then
         Decode_Aux_Security_Header
           (ASH    => MHR.Aux_Security_Header,
            Buffer => Buffer,
            Offset => Length,
            Result => Result);

         if Result /= Success then
            return;
         end if;
      end if;

      --  Reconstruct the Source PAN ID based on PAN ID compression

      if Frame_Control.Frame_Version in IEEE_802_15_4_2003 | IEEE_802_15_4_2006
      then

         --  IEEE 802.15.4-2024 Section 7.2.2.6:
         --
         --  If both destination and source addressing information is
         --  present, the MAC sublayer shall compare the destination and
         --  source PAN identifiers. If the PAN IDs are identical, the
         --  PAN ID Compression field shall be set to one, and the Source
         --  PAN ID field shall be omitted from the transmitted frame.

         if Frame_Control.Dest_Address_Mode /= Not_Present
           and then Frame_Control.Src_Address_Mode /= Not_Present
           and then Frame_Control.PAN_ID_Compression = Compressed
         then
            MHR.Source_PAN_ID := MHR.Destination_PAN_ID;
         end if;

      else
         --  If both the destination and source addressing information is
         --  present and either is a short address, the MAC sublayer shall
         --  compare the destination and source PAN IDs and the PAN ID
         --  Compression field shall be set to zero if and only if the PAN
         --  identifiers are identical.

         if Frame_Control.Src_Address_Mode /= Not_Present
           and then Frame_Control.Dest_Address_Mode /= Not_Present
           and then
             (Frame_Control.Src_Address_Mode = Short
              or else Frame_Control.Dest_Address_Mode = Short)
           and then Frame_Control.PAN_ID_Compression = Not_Compressed
         then
            MHR.Source_PAN_ID := MHR.Destination_PAN_ID;
         end if;
      end if;
   end Decode_Normal_MAC_Header;

   ------------------------------
   -- Decode_Normal_MAC_Header --
   ------------------------------

   procedure Decode_Multipurpose_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   is
      Frame_Control      : MP_Long_Frame_Control_Field;
      Addr_Fields_Length : Natural;

   begin
      MHR :=
        (Frame_Type          => Multipurpose,
         Frame_Pending       => Not_Pending,
         AR                  => Not_Required,
         IE_Present          => Not_Present,
         Frame_Version       => Frame_Version_Field'First,
         Sequence_Number     => (Suppression => Suppressed),
         Destination_PAN_ID  => (Present => False),
         Destination_Address => (Mode => Not_Present),
         Source_PAN_ID       => (Present => False),
         Source_Address      => (Mode => Not_Present),
         Aux_Security_Header => (Security_Enabled => Disabled));

      Decode_MP_Control_Field
        (Buffer        => Buffer,
         Frame_Control => Frame_Control,
         Length        => Length,
         Result        => Result);

      if Result /= Success then
         return;
      end if;

      MHR.Frame_Type := Frame_Control.Frame_Type;
      MHR.Frame_Pending := Frame_Control.Frame_Pending;
      MHR.AR := Frame_Control.Ack_Required;
      MHR.IE_Present := Frame_Control.IE_Present;
      MHR.Frame_Version := Frame_Control.Frame_Version;

      --  Calculate the length of the MHR addressing fields (including the
      --  sequence number), then do a length check on the buffer to verify
      --  that the buffer is big enough to hold all those fields.

      Addr_Fields_Length :=
        (if Frame_Control.SN_Suppression = Not_Suppressed then 1 else 0)
        + Address_Field_Length (Frame_Control.Dest_Address_Mode)
        + Address_Field_Length (Frame_Control.Src_Address_Mode)
        + (if Frame_Control.PAN_ID_Present = Present then 2 else 0);

      if Buffer'Length < Length + Addr_Fields_Length then
         Result := Malformed_Frame;
         return;
      end if;

      --  Decode the Sequence Number (if present)

      if Frame_Control.SN_Suppression = Not_Suppressed then
         Decode_Sequence_Number_Field
           (Buffer          => Buffer,
            Offset          => Length,
            Sequence_Number => MHR.Sequence_Number);
      end if;

      pragma Assert (Length in 1 .. 3);
      pragma Assert (Length <= Buffer'Length);

      --  Decode the Destination PAN ID field (if present)
      if Frame_Control.PAN_ID_Present = Present then
         Decode_PAN_ID_Field
           (Buffer => Buffer,
            Offset => Length,
            PAN_ID => MHR.Destination_PAN_ID);
      end if;

      pragma Assert (Length in 1 .. 5);
      pragma Assert (Length <= Buffer'Length);

      --  Decode the Destination Address field (if present)
      case Frame_Control.Dest_Address_Mode is
         when Extended    =>
            Decode_Extended_Address_Field
              (Buffer  => Buffer,
               Offset  => Length,
               Address => MHR.Destination_Address);

         when Short       =>
            Decode_Short_Address_Field
              (Buffer  => Buffer,
               Offset  => Length,
               Address => MHR.Destination_Address);

         when Reserved    =>
            raise Program_Error; --  Unreachable

         when Not_Present =>
            null;
      end case;

      pragma Assert (Length in 1 .. 13);
      pragma Assert (Length <= Buffer'Length);

      --  Decode the Source Address field (if present)
      case Frame_Control.Src_Address_Mode is
         when Extended    =>
            Decode_Extended_Address_Field
              (Buffer  => Buffer,
               Offset  => Length,
               Address => MHR.Source_Address);

         when Short       =>
            Decode_Short_Address_Field
              (Buffer  => Buffer,
               Offset  => Length,
               Address => MHR.Source_Address);

         when Reserved    =>
            raise Program_Error; --  Unreachable

         when Not_Present =>
            null;
      end case;

      pragma Assert (Length in 1 .. 21);
      pragma Assert (Length <= Buffer'Length);

      if Frame_Control.Security_Enabled = Enabled then
         Decode_Aux_Security_Header
           (ASH    => MHR.Aux_Security_Header,
            Buffer => Buffer,
            Offset => Length,
            Result => Result);
      end if;
   end Decode_Multipurpose_MAC_Header;

   ---------------------------------
   --  Decode_Frame_Control_Field --
   ---------------------------------

   Null_Frame_Control : constant Frame_Control_Field :=
     (Frame_Type         => Frame_Type_Field'First,
      Security_Enabled   => Disabled,
      Frame_Pending      => Not_Pending,
      AR                 => Not_Required,
      PAN_ID_Compression => Not_Compressed,
      Reserved           => 0,
      SN_Suppression     => Not_Suppressed,
      IE_Present         => Not_Present,
      Dest_Address_Mode  => Not_Present,
      Frame_Version      => Frame_Version_Field'First,
      Src_Address_Mode   => Not_Present);

   procedure Decode_Frame_Control_Field
     (Buffer        : Byte_Array;
      Frame_Control : out Frame_Control_Field;
      Result        : out Status_Code) is

   begin

      if Buffer'Length < 2 then
         Frame_Control := Null_Frame_Control;
         Result := Malformed_Frame;

      else
         Frame_Control :=
           From_Bytes (Buffer (Buffer'First .. Buffer'First + 1));

         if Frame_Control.Frame_Version = Reserved
           or else Frame_Control.Dest_Address_Mode = Reserved
           or else Frame_Control.Src_Address_Mode = Reserved
         then
            Result := Unsupported_Field;
         else
            Result := Success;
         end if;
      end if;
   end Decode_Frame_Control_Field;

   -----------------------------
   -- Decode_MP_Control_Field --
   -----------------------------

   procedure Decode_MP_Control_Field
     (Buffer        : Byte_Array;
      Frame_Control : out MP_Long_Frame_Control_Field;
      Length        : out Natural;
      Result        : out Status_Code)
   is
      Null_MP_Frame_Control_Field : constant MP_Long_Frame_Control_Field :=
        (Frame_Type         => Multipurpose,
         Long_Frame_Control => Short,
         Dest_Address_Mode  => Not_Present,
         Src_Address_Mode   => Not_Present,
         PAN_ID_Present     => Not_Present,
         Security_Enabled   => Disabled,
         SN_Suppression     => Suppressed,
         Frame_Pending      => Not_Pending,
         Frame_Version      => Frame_Version_Field'First,
         Ack_Required       => Not_Required,
         IE_Present         => Not_Present);

      Short_FC : MP_Short_Frame_Control_Field;
   begin
      if Buffer'Length = 0 then
         Frame_Control := Null_MP_Frame_Control_Field;
         Length := 0;
         Result := Malformed_Frame;

      else
         Short_FC := From_Bytes (Buffer (Buffer'First));

         if Short_FC.Dest_Address_Mode = Reserved
           or else Short_FC.Src_Address_Mode = Reserved
         then
            Frame_Control := Null_MP_Frame_Control_Field;
            Length := 1;
            Result := Unsupported_Field;

         elsif Short_FC.Long_Frame_Control = Short then
            Frame_Control :=
              (Frame_Type         => Short_FC.Frame_Type,
               Long_Frame_Control => Short_FC.Long_Frame_Control,
               Dest_Address_Mode  => Short_FC.Dest_Address_Mode,
               Src_Address_Mode   => Short_FC.Src_Address_Mode,
               PAN_ID_Present     => Not_Present,
               Security_Enabled   => Disabled,
               SN_Suppression     => Suppressed,
               Frame_Pending      => Not_Pending,
               Frame_Version      => Frame_Version_Field'First,
               Ack_Required       => Not_Required,
               IE_Present         => Not_Present);
            Length := 1;
            Result := Success;

         elsif Buffer'Length < 2 then
            Frame_Control := Null_MP_Frame_Control_Field;
            Length := 1;
            Result := Malformed_Frame;

         else
            Frame_Control :=
              From_Bytes (Buffer (Buffer'First .. Buffer'First + 1));

            Length := 2;

            --  IEEE 802.15.4-2024 Section 7.3.5.10 states:
            --  The Frame Version field is an unsigned integer that specifies
            --  the version number of the frame. This field shall be set to
            --  zero.

            if Frame_Control.Frame_Version = Frame_Version_Field'First then
               Result := Success;
            else
               Result := Unsupported_Field;
            end if;
         end if;
      end if;
   end Decode_MP_Control_Field;

   -----------------------------------
   --  Decode_Sequence_Number_Field --
   -----------------------------------

   procedure Decode_Sequence_Number_Field
     (Buffer          : Byte_Array;
      Offset          : in out Natural;
      Sequence_Number : out Variant_Sequence_Number) is
   begin
      Sequence_Number :=
        (Suppression => Not_Suppressed,
         Number      => Buffer (Buffer'First + Offset));

      Offset := Offset + 1;
   end Decode_Sequence_Number_Field;

   --------------------------
   --  Decode_PAN_ID_Field --
   --------------------------

   procedure Decode_PAN_ID_Field
     (Buffer : Byte_Array;
      Offset : in out Natural;
      PAN_ID : out Variant_PAN_ID)
   is
      Pos : constant Natural := Buffer'First + Offset;
   begin
      PAN_ID :=
        (Present => True, PAN_ID => From_Bytes (Buffer (Pos .. Pos + 1)));

      Offset := Offset + 2;
   end Decode_PAN_ID_Field;

   ------------------------------------
   --  Decode_Extended_Address_Field --
   ------------------------------------

   procedure Decode_Extended_Address_Field
     (Buffer  : Byte_Array;
      Offset  : in out Natural;
      Address : out Variant_Address)
   is
      Pos : constant Positive := Buffer'First + Offset;
   begin
      Address :=
        (Mode             => Extended,
         Extended_Address => From_Bytes (Buffer (Pos .. Pos + 7)));

      Offset := Offset + 8;
   end Decode_Extended_Address_Field;

   ---------------------------------
   --  Decode_Short_Address_Field --
   ---------------------------------

   procedure Decode_Short_Address_Field
     (Buffer  : Byte_Array;
      Offset  : in out Natural;
      Address : out Variant_Address)
   is
      Pos : constant Positive := Buffer'First + Offset;

   begin
      Address :=
        (Mode => Short, Short_Address => From_Bytes (Buffer (Pos .. Pos + 1)));

      Offset := Offset + 2;
   end Decode_Short_Address_Field;

   ---------------------------------
   --  Decode_Aux_Security_Header --
   ---------------------------------

   procedure Decode_Aux_Security_Header
     (Buffer : Byte_Array;
      Offset : in out Natural;
      ASH    : in out Variant_Aux_Security_Header;
      Result : out Status_Code)
   is
      Initial_Offset : constant Natural := Offset
      with Ghost;

      Security_Control : Security_Control_Field;

   begin
      Decode_Security_Control_Field
        (Buffer => Buffer,
         Offset => Offset,
         SC     => Security_Control,
         Result => Result);

      if Result = Success then
         pragma Assert (Offset = Initial_Offset + 1);

         ASH :=
           (Security_Enabled => Enabled,
            Security_Level   => Security_Control.Security_Level,
            ASN_In_Nonce     => Security_Control.Nonce_Source,
            Frame_Counter    => (Suppression => Suppressed),
            Key_ID           => (Mode => 0));

         if Security_Control.FC_Suppression = Not_Suppressed then
            Decode_Frame_Counter_Field
              (Buffer => Buffer,
               Offset => Offset,
               FC     => ASH.Frame_Counter,
               Result => Result);
         end if;
      else
         ASH := (Security_Enabled => Disabled);
      end if;

      pragma Assert (Offset in Initial_Offset .. Buffer'Length);
      pragma
        Assert (if Result = Success then Offset - Initial_Offset in 1 .. 5);
      pragma Assert (if Result = Success then Offset <= Buffer'Length);

      if Result = Success then
         Decode_Key_ID_Field
           (Buffer => Buffer,
            Mode   => Security_Control.Key_ID_Mode,
            Offset => Offset,
            Key_ID => ASH.Key_ID,
            Result => Result);
      end if;

      pragma Assert (Offset >= Initial_Offset);
      pragma
        Assert (if Result = Success then Offset - Initial_Offset in 1 .. 14);
      pragma Assert (if Result = Success then Offset <= Buffer'Length);

   end Decode_Aux_Security_Header;

   ------------------------------------
   --  Decode_Security_Control_Field --
   ------------------------------------

   procedure Decode_Security_Control_Field
     (Buffer : Byte_Array;
      Offset : in out Natural;
      SC     : out Security_Control_Field;
      Result : out Status_Code) is
   begin
      if Buffer'Length < 1 or else Offset > Buffer'Length - 1 then
         SC :=
           (Security_Level => 0,
            Key_ID_Mode    => 0,
            FC_Suppression => Not_Suppressed,
            Nonce_Source   => From_Frame_Counter,
            Reserved       => 0);
         Result := Malformed_Frame;

      else
         SC := From_Bytes (Buffer (Buffer'First));

         Offset := Offset + 1;
         Result := Success;
      end if;
   end Decode_Security_Control_Field;

   ---------------------------------
   --  Decode_Frame_Counter_Field --
   ---------------------------------

   procedure Decode_Frame_Counter_Field
     (Buffer : Byte_Array;
      Offset : in out Natural;
      FC     : out Variant_Frame_Counter;
      Result : out Status_Code)
   is
      Pos : Positive;

   begin
      if Buffer'Length < 4 or else Offset > Buffer'Length - 4 then
         FC := (Suppression => Suppressed);
         Result := Malformed_Frame;

      else
         Pos := Buffer'First + Offset;

         FC :=
           (Suppression   => Not_Suppressed,
            Frame_Counter => From_Bytes (Buffer (Pos .. Pos + 3)));

         Offset := Offset + 4;
         Result := Success;
      end if;
   end Decode_Frame_Counter_Field;

   --------------------------
   --  Decode_Key_ID_Field --
   --------------------------

   procedure Decode_Key_ID_Field
     (Buffer : Byte_Array;
      Mode   : Key_ID_Mode_Field;
      Offset : in out Natural;
      Key_ID : out Variant_Key_ID;
      Result : out Status_Code)
   is
      Pos : Positive;

   begin
      case Mode is
         when 0 =>
            Key_ID := (Mode => 0);
            if Offset > Buffer'Length then
               Result := Malformed_Frame;
            else
               Result := Success;
            end if;

         when 1 =>
            if Buffer'Length < 1 or else Offset > Buffer'Length - 1 then
               Key_ID := (Mode => 0);
               Result := Malformed_Frame;

            else
               Pos := Buffer'First + Offset;

               Key_ID :=
                 (Mode => 1, Key_Index => Key_Index_Field (Buffer (Pos)));

               Offset := Offset + 1;
               Result := Success;
            end if;

         when 2 =>
            if Buffer'Length < 5 or else Offset > Buffer'Length - 5 then
               Key_ID := (Mode => 0);
               Result := Malformed_Frame;

            else
               Pos := Buffer'First + Offset;

               Key_ID :=
                 (Mode         => 2,
                  Key_Index    => Key_Index_Field (Buffer (Pos)),
                  Key_Source_4 =>
                    Key_Source_Field (Buffer (Pos + 1 .. Pos + 4)));

               Offset := Offset + 5;
               Result := Success;
            end if;

         when 3 =>
            if Buffer'Length < 9 or else Offset > Buffer'Length - 9 then
               Key_ID := (Mode => 0);
               Result := Malformed_Frame;

            else
               Pos := Buffer'First + Offset;

               Key_ID :=
                 (Mode         => 3,
                  Key_Index    => Key_Index_Field (Buffer (Pos)),
                  Key_Source_8 =>
                    Key_Source_Field (Buffer (Pos + 1 .. Pos + 8)));

               Offset := Offset + 9;
               Result := Success;
            end if;
      end case;
   end Decode_Key_ID_Field;

end AdaBee.MAC.Frames.Headers.Decoders;
