--
--  Copyright 2024 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Headers.Encoders
  with SPARK_Mode
is

   procedure Encode_PAN_ID
     (PAN_ID : Variant_PAN_ID;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   with
     Inline,
     Global         => null,
     Depends        =>
       (Buffer => (Buffer, Offset, PAN_ID), Offset => (Offset, PAN_ID)),
     Pre            =>
       (Buffer'Length >= 2 and then Offset <= Buffer'Length - 2),
     Contract_Cases =>
       (PAN_ID.Present => Offset = Offset'Old + 2,
        others         => (Offset = Offset'Old and then Buffer = Buffer'Old));

   procedure Encode_Address
     (Address : Variant_Address;
      Buffer  : in out Byte_Array;
      Offset  : in out Natural)
   with
     Inline,
     Global         => null,
     Depends        =>
       (Buffer => (Buffer, Offset, Address), Offset => (Offset, Address)),
     Pre            =>
       (Buffer'Length >= 8
        and then Offset <= Buffer'Length - 8
        and then Address.Mode /= Reserved),
     Contract_Cases =>
       (Address.Mode = Extended => Offset = Offset'Old + 8,
        Address.Mode = Short    => Offset = Offset'Old + 2,
        others                  =>
          (Offset = Offset'Old and then Buffer = Buffer'Old));

   procedure Encode_Aux_Security_Header
     (ASH    : Variant_Aux_Security_Header;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   with
     Inline,
     Global  => null,
     Depends => (Buffer => (Buffer, Offset, ASH), Offset => (Offset, ASH)),
     Pre     =>
       (Buffer'Length >= Max_Aux_Security_Header_Length
        and then Offset <= Buffer'Length - Max_Aux_Security_Header_Length),
     Post    =>
       (Offset in Offset'Old .. Offset'Old + Max_Aux_Security_Header_Length);

   procedure Encode_Normal_MAC_Header
     (MHR : MAC_Header; Buffer : in out Byte_Array; Length : out Natural)
   with
     Global  => null,
     Depends => (Buffer => (Buffer, MHR), Length => MHR),
     Pre     =>
       Buffer'Length >= Max_MHR_Length
       and then
         Formal_Rules.Is_Valid_Configuration
           (Frame_Version              => MHR.Frame_Version,
            Destination_Address_Mode   => MHR.Destination_Address.Mode,
            Source_Address_Mode        => MHR.Source_Address.Mode,
            Destination_PAN_ID_Present => MHR.Destination_PAN_ID.Present,
            Source_PAN_ID_Present      => MHR.Source_PAN_ID.Present)
       and then MHR.Frame_Type not in Multipurpose | Unsupported_Frame_Types,
     Post    =>
       (Length <= Buffer'Length
        and then (Length in Min_MHR_Length .. Max_MHR_Length));

   procedure Encode_Multipurpose_MAC_Header
     (MHR : MAC_Header; Buffer : in out Byte_Array; Length : out Natural)
   with
     Global  => null,
     Depends => (Buffer => (Buffer, MHR), Length => MHR),
     Pre     =>
       Buffer'Length >= Max_MHR_Length
       and then
         Formal_Rules.Is_Valid_Configuration
           (Frame_Version              => MHR.Frame_Version,
            Destination_Address_Mode   => MHR.Destination_Address.Mode,
            Source_Address_Mode        => MHR.Source_Address.Mode,
            Destination_PAN_ID_Present => MHR.Destination_PAN_ID.Present,
            Source_PAN_ID_Present      => MHR.Source_PAN_ID.Present)
       and then MHR.Frame_Type = Multipurpose
       and then not MHR.Source_PAN_ID.Present,
     Post    =>
       (Length <= Buffer'Length
        and then (Length in Min_MHR_Length .. Max_MHR_Length));

   -----------------------
   -- Encode_MAC_Header --
   -----------------------

   procedure Encode_MAC_Header
     (MHR : MAC_Header; Buffer : in out Byte_Array; Length : out Natural) is
   begin
      case MHR.Frame_Type is
         when Beacon | Data | Ack | MAC_Command =>
            Encode_Normal_MAC_Header (MHR, Buffer, Length);

         when Multipurpose                      =>
            Encode_Multipurpose_MAC_Header (MHR, Buffer, Length);

         when Unsupported_Frame_Types           =>
            pragma Assert (False);
      end case;
   end Encode_MAC_Header;

   ------------------------------
   -- Encode_Normal_MAC_Header --
   ------------------------------

   procedure Encode_Normal_MAC_Header
     (MHR : MAC_Header; Buffer : in out Byte_Array; Length : out Natural)
   is
      --  Omit the Source PAN ID (and rely on PAN ID compression) if
      --  the source and destination PANs are both present and denote the
      --  same PAN ID, as required by the rules in IEEE 802.15.4-2024 Section
      --  7.2.2.6.

      Source_PAN_ID : constant Variant_PAN_ID :=
        (if Same_PAN_ID (MHR.Destination_PAN_ID, MHR.Source_PAN_ID)
         then Variant_PAN_ID'(Present => False)
         else MHR.Source_PAN_ID);

      PAN_ID_Compression : constant PAN_ID_Compression_Field :=
        Get_PAN_ID_Compression
          (Frame_Version              => MHR.Frame_Version,
           Destination_Address_Mode   => MHR.Destination_Address.Mode,
           Source_Address_Mode        => MHR.Source_Address.Mode,
           Destination_PAN_ID_Present => MHR.Destination_PAN_ID.Present,
           Source_PAN_ID_Present      => Source_PAN_ID.Present);

   begin

      --  Encode the Frame Control field

      Buffer (Buffer'First .. Buffer'First + 1) :=
        To_Bytes
          (Frame_Control_Field'
             (Frame_Type         => MHR.Frame_Type,
              Security_Enabled   => MHR.Aux_Security_Header.Security_Enabled,
              Frame_Pending      => MHR.Frame_Pending,
              AR                 => MHR.AR,
              PAN_ID_Compression => PAN_ID_Compression,
              Reserved           => 0,
              SN_Suppression     => MHR.Sequence_Number.Suppression,
              IE_Present         => MHR.IE_Present,
              Dest_Address_Mode  => MHR.Destination_Address.Mode,
              Frame_Version      => MHR.Frame_Version,
              Src_Address_Mode   => MHR.Source_Address.Mode));

      Length := 2;

      pragma Assert (Length = 2);

      --  Encode the sequence number
      if MHR.Sequence_Number.Suppression = Not_Suppressed then
         Buffer (Buffer'First + Length) := MHR.Sequence_Number.Number;

         Length := Length + 1;
      end if;

      pragma Assert (Length in 2 .. 3);

      --  Encode the destination PAN ID
      Encode_PAN_ID
        (PAN_ID => MHR.Destination_PAN_ID, Buffer => Buffer, Offset => Length);

      pragma Assert (Length in 2 .. 5);

      --  Encode the destination address
      Encode_Address
        (Address => MHR.Destination_Address,
         Buffer  => Buffer,
         Offset  => Length);

      pragma Assert (Length in 2 .. 13);

      --  Encode the source PAN ID
      Encode_PAN_ID
        (PAN_ID => Source_PAN_ID, Buffer => Buffer, Offset => Length);

      pragma Assert (Length in 2 .. 15);

      --  Encode the source address
      Encode_Address
        (Address => MHR.Source_Address, Buffer => Buffer, Offset => Length);

      pragma Assert (Length in 2 .. 23);

      Encode_Aux_Security_Header
        (ASH => MHR.Aux_Security_Header, Buffer => Buffer, Offset => Length);

   end Encode_Normal_MAC_Header;

   ------------------------------------
   -- Encode_Multipurpose_MAC_Header --
   ------------------------------------

   procedure Encode_Multipurpose_MAC_Header
     (MHR : MAC_Header; Buffer : in out Byte_Array; Length : out Natural) is
   begin

      if not MHR.Destination_PAN_ID.Present
        and then MHR.Aux_Security_Header.Security_Enabled = Disabled
        and then MHR.Sequence_Number.Suppression = Suppressed
        and then MHR.Frame_Pending = Not_Pending
        and then MHR.Frame_Version = IEEE_802_15_4_2003
        and then MHR.AR = Not_Required
        and then MHR.IE_Present = Not_Present
      then
         --  Use short Frame Control

         Buffer (Buffer'First) :=
           To_Bytes
             (MP_Short_Frame_Control_Field'
                (Frame_Type         => Multipurpose,
                 Long_Frame_Control => Short,
                 Dest_Address_Mode  => MHR.Destination_Address.Mode,
                 Src_Address_Mode   => MHR.Source_Address.Mode));

         Length := 1;

      else
         --  Use long frame control

         Buffer (Buffer'First .. Buffer'First + 1) :=
           To_Bytes
             (MP_Long_Frame_Control_Field'
                (Frame_Type         => Multipurpose,
                 Long_Frame_Control => Long,
                 Dest_Address_Mode  => MHR.Destination_Address.Mode,
                 Src_Address_Mode   => MHR.Source_Address.Mode,
                 PAN_ID_Present     =>
                   (if MHR.Destination_PAN_ID.Present
                    then Present
                    else Not_Present),
                 Security_Enabled   =>
                   MHR.Aux_Security_Header.Security_Enabled,
                 SN_Suppression     => MHR.Sequence_Number.Suppression,
                 Frame_Pending      => MHR.Frame_Pending,
                 Frame_Version      => IEEE_802_15_4_2003,
                 Ack_Required       => MHR.AR,
                 IE_Present         => MHR.IE_Present));

         Length := 2;

      end if;

      pragma Assert (Length in 1 .. 2);

      --  Encode the sequence number
      if MHR.Sequence_Number.Suppression = Not_Suppressed then
         Buffer (Buffer'First + Length) := MHR.Sequence_Number.Number;

         Length := Length + 1;
      end if;

      pragma Assert (Length in 1 .. 3);

      --  Encode the destination PAN ID
      Encode_PAN_ID
        (PAN_ID => MHR.Destination_PAN_ID, Buffer => Buffer, Offset => Length);

      pragma Assert (Length in 1 .. 5);

      --  Encode the destination address
      Encode_Address
        (Address => MHR.Destination_Address,
         Buffer  => Buffer,
         Offset  => Length);

      pragma Assert (Length in 1 .. 13);

      --  Encode the source address
      Encode_Address
        (Address => MHR.Source_Address, Buffer => Buffer, Offset => Length);

      pragma Assert (Length in 1 .. 21);

      Encode_Aux_Security_Header
        (ASH => MHR.Aux_Security_Header, Buffer => Buffer, Offset => Length);

   end Encode_Multipurpose_MAC_Header;

   --------------------
   --  Encode_PAN_ID --
   --------------------

   procedure Encode_PAN_ID
     (PAN_ID : Variant_PAN_ID;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   is
      Pos : constant Positive := Buffer'First + Offset;

   begin
      if PAN_ID.Present then
         Buffer (Pos .. Pos + 1) := To_Bytes (PAN_ID.PAN_ID);
         Offset := Offset + 2;
      end if;
   end Encode_PAN_ID;

   ---------------------
   --  Encode_Address --
   ---------------------

   procedure Encode_Address
     (Address : Variant_Address;
      Buffer  : in out Byte_Array;
      Offset  : in out Natural)
   is
      Pos : constant Positive := Buffer'First + Offset;

   begin
      case Address.Mode is
         when Extended    =>
            Buffer (Pos .. Pos + 7) := To_Bytes (Address.Extended_Address);
            Offset := Offset + 8;

         when Short       =>
            Buffer (Pos .. Pos + 1) := To_Bytes (Address.Short_Address);
            Offset := Offset + 2;

         when Reserved    =>
            --  Unreachable (unless precondition is violated)
            raise Program_Error;

         when Not_Present =>
            null;
      end case;
   end Encode_Address;

   ---------------------------------
   --  Encode_Aux_Security_Header --
   ---------------------------------

   procedure Encode_Aux_Security_Header
     (ASH    : Variant_Aux_Security_Header;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   is
      Pos : Positive := Buffer'First + Offset;

   begin
      if ASH.Security_Enabled = Enabled then
         --  Encode the Security Control field
         Buffer (Pos) :=
           To_Bytes
             (Security_Control_Field'
                (Security_Level => ASH.Security_Level,
                 Key_ID_Mode    => ASH.Key_ID.Mode,
                 FC_Suppression => ASH.Frame_Counter.Suppression,
                 Nonce_Source   => ASH.ASN_In_Nonce,
                 Reserved       => 0));

         Pos := Pos + 1;
         Offset := Offset + 1;

         --  Encode the Frame Counter (if not suppressed)
         if ASH.Frame_Counter.Suppression = Not_Suppressed then
            Buffer (Pos .. Pos + 3) :=
              To_Bytes (ASH.Frame_Counter.Frame_Counter);

            Pos := Pos + 4;
            Offset := Offset + 4;
         end if;

         --  Encode the Key ID field (variable length)
         case ASH.Key_ID.Mode is
            when 0 =>
               null;

            when 1 =>
               Buffer (Pos) := Bits_8 (ASH.Key_ID.Key_Index);

               Offset := Offset + 1;

            when 2 =>
               Buffer (Pos) := Bits_8 (ASH.Key_ID.Key_Index);
               Buffer (Pos .. Pos + 3) := Byte_Array (ASH.Key_ID.Key_Source_4);

               Offset := Offset + 5;

            when 3 =>
               Buffer (Pos) := Bits_8 (ASH.Key_ID.Key_Index);
               Buffer (Pos .. Pos + 7) := Byte_Array (ASH.Key_ID.Key_Source_8);

               Offset := Offset + 9;
         end case;
      end if;
   end Encode_Aux_Security_Header;

end AdaBee.MAC.Frames.Headers.Encoders;
