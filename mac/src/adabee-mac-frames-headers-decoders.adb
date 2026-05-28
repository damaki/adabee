--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Headers.Model_Equivalence;

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
         Decoder_Model.Get_Frame_Type (Buffer)
         not in Multipurpose | Unsupported_Frame_Types,
     Post    =>
       (Result = Success) = Decoder_Model.Frame_Control_Valid (Buffer)
       and then
         (if Result = Success
          then Frame_Control = Decoder_Model.Get_FC (Buffer));

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
       (Result = Success) = Decoder_Model.Frame_Control_Valid (Buffer)
       and then Length <= 2
       and then Length <= Buffer'Length
       and then
         (if Result = Success
          then
            Length = Decoder_Model.Get_Frame_Control_Length (Buffer)
            and then
              (if Decoder_Model.Get_MP_S_FC (Buffer).Long_Frame_Control = Long
               then Frame_Control = Decoder_Model.Get_MP_L_FC (Buffer)
               else
                 Frame_Control.Frame_Type = Multipurpose
                 and then Frame_Control.Long_Frame_Control = Short
                 and then
                   Frame_Control.Dest_Address_Mode
                   = Decoder_Model.Get_Dest_Address_Mode (Buffer)
                 and then
                   Frame_Control.Src_Address_Mode
                   = Decoder_Model.Get_Src_Address_Mode (Buffer)
                 and then Frame_Control.PAN_ID_Present = Not_Present
                 and then Frame_Control.Security_Enabled = Disabled
                 and then Frame_Control.SN_Suppression = Suppressed
                 and then Frame_Control.Frame_Pending = Not_Pending
                 and then Frame_Control.Frame_Version = IEEE_802_15_4_2003
                 and then Frame_Control.Ack_Required = Not_Required
                 and then Frame_Control.IE_Present = Not_Present));

   procedure Decode_Sequence_Number_Field
     (Buffer          : Byte_Array;
      Offset          : in out Natural;
      Sequence_Number : out Variant_Sequence_Number)
   with
     Inline,
     Global  => null,
     Depends => (Sequence_Number => (Buffer, Offset), Offset => Offset),
     Pre     =>
       not Sequence_Number'Constrained
       and then Decoder_Model.Frame_Control_Valid (Buffer)
       and then Decoder_Model.Is_Sequence_Number_Present (Buffer)
       and then Offset = Decoder_Model.Get_Sequence_Number_Offset (Buffer)
       and then Offset < Buffer'Length,
     Post    =>
       Offset = Offset'Old + 1
       and then Sequence_Number = Decoder_Model.Get_Sequence_Number (Buffer);

   procedure Decode_PAN_ID_Field
     (Buffer : Byte_Array;
      Offset : in out Natural;
      PAN_ID : out Variant_PAN_ID)
   with
     Inline,
     Global  => null,
     Depends => (PAN_ID => (Buffer, Offset), Offset => Offset),
     Pre     => not PAN_ID'Constrained and then Offset <= Buffer'Length - 2,
     Post    =>
       Offset = Offset'Old + 2
       and then PAN_ID.Present
       and then
         PAN_ID.PAN_ID = Decoder_Model.Get_PAN_ID_At (Buffer, Offset'Old);

   procedure Decode_Extended_Address_Field
     (Buffer  : Byte_Array;
      Offset  : in out Natural;
      Address : out Variant_Address)
   with
     Inline,
     Global  => null,
     Depends => (Address => (Buffer, Offset), Offset => Offset),
     Pre     => not Address'Constrained and then Offset <= Buffer'Length - 8,
     Post    =>
       Offset = Offset'Old + 8
       and then Address.Mode = Extended
       and then
         Address = Decoder_Model.Get_Address_At (Buffer, Offset'Old, Extended);

   procedure Decode_Short_Address_Field
     (Buffer  : Byte_Array;
      Offset  : in out Natural;
      Address : out Variant_Address)
   with
     Inline,
     Global  => null,
     Depends => (Address => (Buffer, Offset), Offset => Offset),
     Pre     => not Address'Constrained and then Offset <= Buffer'Length - 2,
     Post    =>
       Offset = Offset'Old + 2
       and then Address.Mode = Short
       and then
         Address = Decoder_Model.Get_Address_At (Buffer, Offset'Old, Short);

   procedure Decode_Address_Field
     (Buffer  : Byte_Array;
      Offset  : in out Natural;
      Mode    : Valid_Address_Mode_Field;
      Address : in out Variant_Address)
   with
     Inline,
     Global => null,
     Pre    =>
       not Address'Constrained
       and then Offset <= Buffer'Length - Address_Length (Mode)
       and then Address.Mode = Not_Present,
     Post   =>
       Offset = Offset'Old + Address_Length (Mode)
       and then Address.Mode = Mode
       and then Encoder_Model.Address_Equal_At (Buffer, Offset'Old, Address);

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
     Pre     =>
       not ASH'Constrained
       and then Offset <= Buffer'Length
       and then Decoder_Model.Frame_Control_Valid (Buffer)
       and then Decoder_Model.Is_Aux_Security_Header_Present (Buffer)
       and then Offset = Decoder_Model.Get_Aux_Security_Header_Offset (Buffer),
     Post    =>
       (Result = Success)
       = (Decoder_Model.Security_Control_Valid (Buffer)
          and then
            Offset'Old
            <= Buffer'Length
               - Decoder_Model.Get_Aux_Security_Header_Length (Buffer))
       and then Offset - Offset'Old <= Max_Aux_Security_Header_Length
       and then
         (if Result = Success
          then
            (Offset
             = Offset'Old
               + Decoder_Model.Get_Aux_Security_Header_Length (Buffer)
             and then Offset <= Buffer'Length
             and then ASH.Security_Enabled = Enabled
             and then ASH = Decoder_Model.Get_Aux_Security_Header (Buffer))
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
     Pre     =>
       Decoder_Model.Frame_Control_Valid (Buffer)
       and then Decoder_Model.Is_Security_Control_Present (Buffer)
       and then Offset = Decoder_Model.Get_Security_Control_Offset (Buffer),
     Post    =>
       (Result = Success)
       = (Decoder_Model.Security_Control_Valid (Buffer)
          and then
            Buffer'Length
            >= Decoder_Model.Get_Security_Control_Offset (Buffer)
               + Decoder_Model.Get_Security_Control_Length (Buffer))
       and then
         (if Result = Success
          then
            Offset
            = Offset'Old + Decoder_Model.Get_Security_Control_Length (Buffer)
            and then Offset <= Buffer'Length
            and then SC = Decoder_Model.Get_Security_Control (Buffer)
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
     Pre     =>
       not FC'Constrained
       and then Decoder_Model.Security_Control_Valid (Buffer)
       and then Decoder_Model.Is_Frame_Counter_Present (Buffer)
       and then Offset = Decoder_Model.Get_Frame_Counter_Offset (Buffer),
     Post    =>
       (Result = Success)
       = (Buffer'Length
          >= Decoder_Model.Get_Frame_Counter_Offset (Buffer)
             + Decoder_Model.Get_Frame_Counter_Length (Buffer))
       and then
         (if Result = Success
          then
            (Offset
             = Offset'Old + Decoder_Model.Get_Frame_Counter_Length (Buffer)
             and then Offset <= Buffer'Length
             and then FC.Suppression = Not_Suppressed
             and then FC = Decoder_Model.Get_Frame_Counter (Buffer))
          else Offset = Offset'Old and then FC.Suppression = Suppressed);

   procedure Decode_Key_ID_Field
     (Buffer : Byte_Array;
      Mode   : Key_ID_Mode_Field;
      Offset : in out Natural;
      Key_ID : out Variant_Key_ID;
      Result : out Status_Code)
   with
     Inline,
     Global  => null,
     Depends =>
       (Key_ID => (Buffer, Mode, Offset),
        Result => (Buffer, Mode, Offset),
        Offset => (Buffer, Mode, Offset)),
     Pre     =>
       not Key_ID'Constrained
       and then Decoder_Model.Security_Control_Valid (Buffer)
       and then Decoder_Model.Is_Aux_Security_Header_Present (Buffer)
       and then Decoder_Model.Get_Key_ID_Mode (Buffer) = Mode
       and then Offset = Decoder_Model.Get_Key_ID_Offset (Buffer)
       and then Offset <= Buffer'Length,
     Post    =>
       (Result = Success)
       = (Mode = 0
          or else
            Buffer'Length
            >= Decoder_Model.Get_Key_ID_Offset (Buffer)
               + Decoder_Model.Get_Key_ID_Length (Buffer))
       and then
         (if Result = Success
          then
            Offset = Offset'Old + Decoder_Model.Get_Key_ID_Length (Buffer)
            and then Offset <= Buffer'Length
            and then Key_ID = Decoder_Model.Get_Key_ID (Buffer)
          else Offset = Offset'Old);

   procedure Decode_General_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   with
     Global                 => null,
     Relaxed_Initialization => MHR,
     Pre                    =>
       Buffer'Length > 0
       and then Decoder_Model.Get_Frame_Type (Buffer) in General_Frame_Types
       and then not MHR'Constrained,
     Post                   =>
       Length <= Buffer'Length
       and then Length <= Max_MHR_Length
       and then
         (Result = Success) = Decoder_Model.Is_MHR_Valid_Excluding_IEs (Buffer)
       and then
         (if Result = Success
          then
            (Length = Decoder_Model.MHR_Length_Excluding_IEs (Buffer)
             and then Length <= Buffer'Length
             and then MHR'Initialized
             and then Is_Valid (MHR)
             and then Encoder_Model.MHR_Equal_Excluding_IEs (MHR, Buffer)));

   procedure Decode_Multipurpose_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   with
     Global                 => null,
     Relaxed_Initialization => MHR,
     Pre                    =>
       Buffer'Length > 0
       and then Decoder_Model.Get_Frame_Type (Buffer) = Multipurpose
       and then not MHR'Constrained,
     Post                   =>
       (Length <= Buffer'Length
        and then Length <= Max_MHR_Length
        and then
          (Result = Success)
          = Decoder_Model.Is_MHR_Valid_Excluding_IEs (Buffer)
        and then
          (if Result = Success
           then
             (Length = Decoder_Model.MHR_Length_Excluding_IEs (Buffer)
              and then Length <= Buffer'Length
              and then MHR'Initialized
              and then Is_Valid (MHR)
              and then Encoder_Model.MHR_Equal_Excluding_IEs (MHR, Buffer))));

   ------------------------
   -- Decode_MHR_Partial --
   ------------------------

   procedure Decode_MHR_Partial
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code) is
   begin
      case To_Frame_Type (Buffer (Buffer'First)) is
         when General_Frame_Types     =>
            Decode_General_MAC_Header (Buffer, MHR, Length, Result);

         when Multipurpose            =>
            Decode_Multipurpose_MAC_Header (Buffer, MHR, Length, Result);

         when Unsupported_Frame_Types =>
            --  Frame type is not supported in this implementation

            MHR :=
              (Frame_Type          => Frame_Type_Field'First,
               Frame_Pending       => Not_Pending,
               AR                  => Not_Required,
               IE_Present          => Not_Present,
               Frame_Version       => Frame_Version_Field'First,
               Long_Frame_Control  => Long_Frame_Control_Field'First,
               PAN_ID_Compression  => PAN_ID_Compression_Field'First,
               Sequence_Number     => (Suppression => Suppressed),
               Destination_PAN_ID  => (Present => False),
               Destination_Address => (Mode => Not_Present),
               Source_PAN_ID       => (Present => False),
               Source_Address      => (Mode => Not_Present),
               Aux_Security_Header => (Security_Enabled => Disabled));

            Length := 0;
            Result := Unsupported_Field;
      end case;

      if Result = Success then
         Model_Equivalence.Lemma_MHR_Length_Excluding_IEs_Equal (MHR, Buffer);
      end if;
   end Decode_MHR_Partial;

   ---------------------------
   -- Decode_MHR_Header_IEs --
   ---------------------------

   procedure Decode_MHR_Header_IEs
     (Buffer            : Byte_Array;
      Header_IE_Last    : out Natural;
      MAC_Payload_First : out Integer;
      MAC_Payload_Last  : out Integer;
      Has_Payload_IEs   : out Boolean;
      Result            : out Status_Code)
   is
      Header_IE_List_Length   : Natural;
      Last_Header_IE_Position : Natural;

      Last_Header_IE : AdaBee.MAC.Frames.Info_Elements.Headers.Header_Field;

   begin
      AdaBee.MAC.Frames.Info_Elements.Headers.Lists.Validate_IE_List
        (Buffer  => Buffer,
         Length  => Header_IE_List_Length,
         Result  => Result,
         Last_IE => Last_Header_IE_Position);

      if Result /= Success then
         Header_IE_Last := 0;
         MAC_Payload_First := 1;
         MAC_Payload_Last := 0;
         Has_Payload_IEs := False;

      else

         Header_IE_Last := Buffer'First + (Header_IE_List_Length - 1);

         --  Determine whether the MAC payload is present

         if Header_IE_Last < Buffer'Last then
            MAC_Payload_First := Header_IE_Last + 1;
            MAC_Payload_Last := Buffer'Last;

            --  Check whether the MAC payload contains payload IEs

            Last_Header_IE :=
              AdaBee.MAC.Frames.Info_Elements.Headers.From_Bytes
                (Buffer
                   (Last_Header_IE_Position .. Last_Header_IE_Position + 1));

            Has_Payload_IEs :=
              Last_Header_IE.Element_ID
              = Info_Elements.Headers.Header_Termination_1_IE;
         else
            MAC_Payload_First := 1;
            MAC_Payload_Last := 0;
            Has_Payload_IEs := False;
         end if;

         --  Help prove the postcondition

         Info_Elements.Headers.Lists.IE_Model.Lemma_Valid_IE_List_Preserved
           (Buffer => Buffer,
            Slice  => Buffer (Buffer'First .. Header_IE_Last));
      end if;
   end Decode_MHR_Header_IEs;

   ----------------
   -- Decode_MHR --
   ----------------

   procedure Decode_MHR
     (Buffer            : Byte_Array;
      MHR               : out MAC_Header;
      Header_IE_First   : out Positive;
      Header_IE_Last    : out Natural;
      MAC_Payload_First : out Integer;
      MAC_Payload_Last  : out Integer;
      Has_Payload_IEs   : out Boolean;
      Result            : out Status_Code)
   is
      MHR_Length : Natural;
   begin
      Decode_MHR_Partial (Buffer, MHR, MHR_Length, Result);

      if Result = Success then

         --  Check whether an IE list is present and if so, try to decode the
         --  header IEs to determine its length and where the MAC payload
         --  starts.

         if MHR.IE_Present = Present then
            if MHR_Length = Buffer'Length then

               --  The MHR indicates an IE list is present, but there's no
               --  space for it in the frame.

               Header_IE_First := 1;
               Header_IE_Last := 0;
               MAC_Payload_First := 1;
               MAC_Payload_Last := 0;
               Has_Payload_IEs := False;
               Result := Malformed_Frame;

            else
               Header_IE_First := Buffer'First + MHR_Length;

               Decode_MHR_Header_IEs
                 (Buffer            => Buffer (Header_IE_First .. Buffer'Last),
                  Header_IE_Last    => Header_IE_Last,
                  MAC_Payload_First => MAC_Payload_First,
                  MAC_Payload_Last  => MAC_Payload_Last,
                  Has_Payload_IEs   => Has_Payload_IEs,
                  Result            => Result);

               if Result = Success then
                  Decoder_Model.Header_IE_Model.Lemma_Valid_IE_List_Preserved
                    (Buffer (Header_IE_First .. Buffer'Last),
                     Buffer (Header_IE_First .. Header_IE_Last));

                  Decoder_Model.Header_IE_Model.Lemma_IE_List_Length_Preserved
                    (Buffer (Header_IE_First .. Buffer'Last),
                     Buffer (Header_IE_First .. Header_IE_Last));
               end if;
            end if;

         else
            --  No IE list is present, but a MAC payload might be present

            Header_IE_First := 1;
            Header_IE_Last := 0;
            Has_Payload_IEs := False;

            if MHR_Length = Buffer'Length then
               MAC_Payload_First := 1;
               MAC_Payload_Last := 0;
            else
               MAC_Payload_First := Buffer'First + MHR_Length;
               MAC_Payload_Last := Buffer'Last;
            end if;
         end if;

      else
         --  MHR decode failed

         Header_IE_First := 1;
         Header_IE_Last := 0;
         MAC_Payload_First := 1;
         MAC_Payload_Last := 0;
         Has_Payload_IEs := False;
      end if;
   end Decode_MHR;

   ------------------------------
   -- Decode_General_MAC_Header --
   ------------------------------

   procedure Decode_General_MAC_Header
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
      Decode_Frame_Control_Field
        (Buffer => Buffer, Frame_Control => Frame_Control, Result => Result);

      if Result /= Success then
         Length := 0;
         return;
      end if;

      pragma Assert (Decoder_Model.Frame_Control_Valid (Buffer));
      pragma Assert (Frame_Control = Decoder_Model.Get_FC (Buffer));

      case General_Frame_Types (Frame_Control.Frame_Type) is
         when Beacon      =>
            MHR :=
              (Frame_Type          => Beacon,
               Frame_Pending       => Frame_Control.Frame_Pending,
               AR                  => Frame_Control.AR,
               IE_Present          => Frame_Control.IE_Present,
               Frame_Version       => Frame_Control.Frame_Version,
               Long_Frame_Control  => Long,
               PAN_ID_Compression  => Frame_Control.PAN_ID_Compression,
               Sequence_Number     => (Suppression => Suppressed),
               Destination_PAN_ID  => (Present => False),
               Destination_Address => (Mode => Not_Present),
               Source_PAN_ID       => (Present => False),
               Source_Address      => (Mode => Not_Present),
               Aux_Security_Header => (Security_Enabled => Disabled));

         when Data        =>
            MHR :=
              (Frame_Type          => Data,
               Frame_Pending       => Frame_Control.Frame_Pending,
               AR                  => Frame_Control.AR,
               IE_Present          => Frame_Control.IE_Present,
               Frame_Version       => Frame_Control.Frame_Version,
               Long_Frame_Control  => Long,
               PAN_ID_Compression  => Frame_Control.PAN_ID_Compression,
               Sequence_Number     => (Suppression => Suppressed),
               Destination_PAN_ID  => (Present => False),
               Destination_Address => (Mode => Not_Present),
               Source_PAN_ID       => (Present => False),
               Source_Address      => (Mode => Not_Present),
               Aux_Security_Header => (Security_Enabled => Disabled));

         when Ack         =>
            MHR :=
              (Frame_Type          => Ack,
               Frame_Pending       => Frame_Control.Frame_Pending,
               AR                  => Frame_Control.AR,
               IE_Present          => Frame_Control.IE_Present,
               Frame_Version       => Frame_Control.Frame_Version,
               Long_Frame_Control  => Long,
               PAN_ID_Compression  => Frame_Control.PAN_ID_Compression,
               Sequence_Number     => (Suppression => Suppressed),
               Destination_PAN_ID  => (Present => False),
               Destination_Address => (Mode => Not_Present),
               Source_PAN_ID       => (Present => False),
               Source_Address      => (Mode => Not_Present),
               Aux_Security_Header => (Security_Enabled => Disabled));

         when MAC_Command =>
            MHR :=
              (Frame_Type          => MAC_Command,
               Frame_Pending       => Frame_Control.Frame_Pending,
               AR                  => Frame_Control.AR,
               IE_Present          => Frame_Control.IE_Present,
               Frame_Version       => Frame_Control.Frame_Version,
               Long_Frame_Control  => Long,
               PAN_ID_Compression  => Frame_Control.PAN_ID_Compression,
               Sequence_Number     => (Suppression => Suppressed),
               Destination_PAN_ID  => (Present => False),
               Destination_Address => (Mode => Not_Present),
               Source_PAN_ID       => (Present => False),
               Source_Address      => (Mode => Not_Present),
               Aux_Security_Header => (Security_Enabled => Disabled));
      end case;

      Length := 2;

      pragma
        Assert
          (MHR.Frame_Type = Decoder_Model.Get_Frame_Type (Buffer)
           and then MHR.AR = Decoder_Model.Get_Ack_Required (Buffer)
           and then MHR.Long_Frame_Control = Long
           and then MHR.IE_Present = Decoder_Model.Get_IE_Present (Buffer)
           and then
             MHR.Frame_Pending = Decoder_Model.Get_Frame_Pending (Buffer)
           and then
             MHR.Frame_Version = Decoder_Model.Get_Frame_Version (Buffer)
           and then
             MHR.PAN_ID_Compression
             = Decoder_Model.Get_FC (Buffer).PAN_ID_Compression
           and then MHR.Sequence_Number.Suppression = Suppressed
           and then not MHR.Destination_PAN_ID.Present
           and then not MHR.Source_PAN_ID.Present
           and then MHR.Destination_Address.Mode = Not_Present
           and then MHR.Source_Address.Mode = Not_Present
           and then MHR.Aux_Security_Header.Security_Enabled = Disabled);

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

      pragma
        Assert
          (Buffer'Length
           >= Decoder_Model.Get_Aux_Security_Header_Offset (Buffer));

      --  Decode the Sequence Number (if present)

      if Frame_Control.SN_Suppression = Not_Suppressed then
         Decode_Sequence_Number_Field
           (Buffer          => Buffer,
            Offset          => Length,
            Sequence_Number => MHR.Sequence_Number);
      end if;

      pragma
        Assert (Length = Decoder_Model.Get_Destination_PAN_ID_Offset (Buffer));

      --  Decode the Destination PAN ID field (if present)
      if Dest_PAN_ID_Present then
         Decode_PAN_ID_Field
           (Buffer => Buffer,
            Offset => Length,
            PAN_ID => MHR.Destination_PAN_ID);
      end if;

      pragma
        Assert
          (Length = Decoder_Model.Get_Destination_Address_Offset (Buffer));

      --  Decode the Destination Address field (if present)
      Decode_Address_Field
        (Buffer,
         Length,
         Frame_Control.Dest_Address_Mode,
         MHR.Destination_Address);

      pragma
        Assert
          (MHR.Destination_Address.Mode
           = Decoder_Model.Get_Dest_Address_Mode (Buffer));

      pragma Assert (Length = Decoder_Model.Get_Source_PAN_ID_Offset (Buffer));

      --  Decode the Source PAN ID field (if present)
      if Src_PAN_ID_Present then
         Decode_PAN_ID_Field
           (Buffer => Buffer, Offset => Length, PAN_ID => MHR.Source_PAN_ID);

      elsif Is_Source_PAN_ID_Compressed
              (Frame_Version            => Frame_Control.Frame_Version,
               Destination_Address_Mode => Frame_Control.Dest_Address_Mode,
               Source_Address_Mode      => Frame_Control.Src_Address_Mode,
               PAN_ID_Compression       => Frame_Control.PAN_ID_Compression)
      then
         pragma Assert (MHR.Destination_PAN_ID.Present);

         MHR.Source_PAN_ID := MHR.Destination_PAN_ID;
      end if;

      pragma
        Assert (Length = Decoder_Model.Get_Source_Address_Offset (Buffer));

      --  Decode the Source Address field (if present)
      Decode_Address_Field
        (Buffer, Length, Frame_Control.Src_Address_Mode, MHR.Source_Address);

      pragma
        Assert
          (Length = Decoder_Model.Get_Aux_Security_Header_Offset (Buffer));

      pragma
        Assert
          (MHR.Source_Address.Mode
           = Decoder_Model.Get_Src_Address_Mode (Buffer));

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

      pragma Assert (Encoder_Model.Frame_Control_Equal (MHR, Buffer));
      pragma Assert (Encoder_Model.Security_Control_Equal (MHR, Buffer));

      Model_Equivalence.Lemma_Get_Aux_Security_Header_Equivalence
        (MHR, Buffer);

      pragma Assert (Is_Valid (MHR));

      Model_Equivalence.Lemma_Addressing_Field_Positions_Equal (MHR, Buffer);

      Model_Equivalence.Lemma_Aux_Security_Header_Field_Positions_Equal
        (MHR, Buffer);

      Model_Equivalence.Lemma_MHR_Length_Excluding_IEs_Equal (MHR, Buffer);
   end Decode_General_MAC_Header;

   ------------------------------------
   -- Decode_Multipurpose_MAC_Header --
   ------------------------------------

   procedure Decode_Multipurpose_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   is
      Frame_Control      : MP_Long_Frame_Control_Field;
      Addr_Fields_Length : Natural;

   begin
      Decode_MP_Control_Field
        (Buffer        => Buffer,
         Frame_Control => Frame_Control,
         Length        => Length,
         Result        => Result);

      if Result /= Success then
         return;
      end if;

      MHR :=
        (Frame_Type          => Multipurpose,
         Frame_Pending       => Frame_Control.Frame_Pending,
         AR                  => Frame_Control.Ack_Required,
         IE_Present          => Frame_Control.IE_Present,
         Frame_Version       => Frame_Control.Frame_Version,
         Long_Frame_Control  => Frame_Control.Long_Frame_Control,
         Sequence_Number     => (Suppression => Suppressed),
         Destination_PAN_ID  => (Present => False),
         Destination_Address => (Mode => Not_Present),
         Source_PAN_ID       => (Present => False),
         Source_Address      => (Mode => Not_Present),
         Aux_Security_Header => (Security_Enabled => Disabled));

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

      pragma
        Assert
          (Buffer'Length
           >= Decoder_Model.Get_Aux_Security_Header_Offset (Buffer));

      --  Decode the Sequence Number (if present)

      if Frame_Control.SN_Suppression = Not_Suppressed then
         Decode_Sequence_Number_Field
           (Buffer          => Buffer,
            Offset          => Length,
            Sequence_Number => MHR.Sequence_Number);
      end if;

      pragma
        Assert (Length = Decoder_Model.Get_Destination_PAN_ID_Offset (Buffer));

      --  Decode the Destination PAN ID field (if present)
      if Frame_Control.PAN_ID_Present = Present then
         Decode_PAN_ID_Field
           (Buffer => Buffer,
            Offset => Length,
            PAN_ID => MHR.Destination_PAN_ID);
      end if;

      pragma
        Assert
          (Length = Decoder_Model.Get_Destination_Address_Offset (Buffer));

      --  Decode the Destination Address field (if present)
      Decode_Address_Field
        (Buffer,
         Length,
         Frame_Control.Dest_Address_Mode,
         MHR.Destination_Address);

      pragma
        Assert (Length = Decoder_Model.Get_Source_Address_Offset (Buffer));

      --  Decode the Source Address field (if present)
      Decode_Address_Field
        (Buffer, Length, Frame_Control.Src_Address_Mode, MHR.Source_Address);

      pragma
        Assert
          (Length = Decoder_Model.Get_Aux_Security_Header_Offset (Buffer));

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

      pragma Assert (Encoder_Model.Frame_Control_Equal (MHR, Buffer));
      pragma Assert (Encoder_Model.Security_Control_Equal (MHR, Buffer));

      Model_Equivalence.Lemma_Get_Aux_Security_Header_Equivalence
        (MHR, Buffer);

      pragma Assert (Is_Valid (MHR));

      Model_Equivalence.Lemma_Addressing_Field_Positions_Equal (MHR, Buffer);

      Model_Equivalence.Lemma_Aux_Security_Header_Field_Positions_Equal
        (MHR, Buffer);

      Model_Equivalence.Lemma_MHR_Length_Excluding_IEs_Equal (MHR, Buffer);
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

         --  IE lists requires frame version 0b10.
         --  Ref. IEEE 802.15.4-2024 Section 7.2.2.8
         elsif Frame_Control.Frame_Version
               in IEEE_802_15_4_2003 | IEEE_802_15_4_2006
           and then Frame_Control.IE_Present /= Not_Present
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

   --------------------------
   -- Decode_Address_Field --
   --------------------------

   procedure Decode_Address_Field
     (Buffer  : Byte_Array;
      Offset  : in out Natural;
      Mode    : Valid_Address_Mode_Field;
      Address : in out Variant_Address) is
   begin
      case Mode is
         when Extended    =>
            Decode_Extended_Address_Field
              (Buffer => Buffer, Offset => Offset, Address => Address);

         when Short       =>
            Decode_Short_Address_Field
              (Buffer => Buffer, Offset => Offset, Address => Address);

         when Not_Present =>
            null;
      end case;
   end Decode_Address_Field;

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
      if Offset >= Buffer'Length then
         SC :=
           (Security_Level => 0,
            Key_ID_Mode    => 0,
            FC_Suppression => Not_Suppressed,
            Nonce_Source   => From_Frame_Counter,
            Reserved       => 0);
         Result := Malformed_Frame;

      else
         SC := From_Bytes (Buffer (Buffer'First + Offset));

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
      if Buffer'Length < Offset + 4 then
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
            Result := Success;

            pragma
              Assert
                ((Result = Success)
                 = (Mode = 0
                    or else
                      Buffer'Length
                      >= Decoder_Model.Get_Key_ID_Offset (Buffer)
                         + Decoder_Model.Get_Key_ID_Length (Buffer)));

         when 1 =>
            if Offset >= Buffer'Length then
               Key_ID := (Mode => 0);
               Result := Malformed_Frame;

            else
               Pos := Buffer'First + Offset;

               Key_ID :=
                 (Mode => 1, Key_Index => Key_Index_Field (Buffer (Pos)));

               Offset := Offset + 1;
               Result := Success;
            end if;

            pragma
              Assert
                ((Result = Success)
                 = (Mode = 0
                    or else
                      Buffer'Length
                      >= Decoder_Model.Get_Key_ID_Offset (Buffer)
                         + Decoder_Model.Get_Key_ID_Length (Buffer)));

         when 2 =>
            if Offset >= Buffer'Length - 4 then
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
            if Offset >= Buffer'Length - 8 then
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
