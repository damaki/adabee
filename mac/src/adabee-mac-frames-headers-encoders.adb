--
--  Copyright 2024 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Headers.Encoders
  with SPARK_Mode
is

   -------------
   -- Helpers --
   -------------

   function Prefix_Initialized
     (Buffer : Byte_Array; Length : Natural) return Boolean
   is (Buffer (Buffer'First .. Buffer'First + (Length - 1))'Initialized)
   with
     Ghost,
     Relaxed_Initialization => Buffer,
     Pre                    => Length <= Buffer'Length;
   --  Returns True if the first Length bytes of Buffer are initialized

   function Slice (Buffer : Byte_Array; Length : Natural) return Byte_Array
   is (Buffer (Buffer'First .. Buffer'First + (Length - 1)))
   with
     Ghost,
     Relaxed_Initialization => Buffer,
     Pre                    =>
       Length <= Buffer'Length and then Prefix_Initialized (Buffer, Length),
     Annotate               => (GNATprove, Inline_For_Proof);
   --  Helper function to get a slice of the first Length bytes of Buffer.
   --
   --  This helps to make the buffer slicing more readable in contracts.

   procedure Assign_Slice
     (Target : out Byte_Array; Source : Byte_Array; Length : Natural)
   with
     Ghost,
     Relaxed_Initialization => (Target, Source),
     Pre                    =>
       Length <= Target'Length
       and then Length <= Source'Length
       and then Prefix_Initialized (Source, Length),
     Post                   =>
       Prefix_Initialized (Target, Length)
       and then Slice (Target, Length) = Slice (Source, Length);

   ------------
   -- Lemmas --
   ------------

   procedure Lemma_Frame_Control_Preserved
     (A        : Byte_Array;
      A_Length : Natural;
      B        : Byte_Array;
      B_Length : Natural;
      MHR      : Valid_MAC_Header)
   with
     Ghost,
     Relaxed_Initialization => (A, B),
     Pre                    =>
       A_Length >= MHR_Model.Get_Frame_Control_Length (MHR)
       and then A_Length <= B_Length
       and then A_Length <= A'Length
       and then B_Length <= B'Length
       and then Prefix_Initialized (A, A_Length)
       and then Prefix_Initialized (B, B_Length)
       and then Slice (A, A_Length) = Slice (B, A_Length)
       and then MHR_Model.Frame_Control_Equal (MHR, Slice (A, A_Length)),
     Post                   =>
       MHR_Model.Frame_Control_Equal (MHR, Slice (B, B_Length))
       and then MHR_Model.Frame_Control_Valid (Slice (B, B_Length));

   procedure Lemma_Sequence_Number_Preserved
     (A        : Byte_Array;
      A_Length : Natural;
      B        : Byte_Array;
      B_Length : Natural;
      MHR      : Valid_MAC_Header)
   with
     Ghost,
     Relaxed_Initialization => (A, B),
     Pre                    =>
       A_Length >= MHR_Model.Get_Destination_PAN_ID_Offset (MHR)
       and then A_Length <= B_Length
       and then A_Length <= A'Length
       and then B_Length <= B'Length
       and then Prefix_Initialized (A, A_Length)
       and then Prefix_Initialized (B, B_Length)
       and then Slice (A, A_Length) = Slice (B, A_Length)
       and then MHR_Model.Sequence_Number_Equal (MHR, Slice (A, A_Length)),
     Post                   =>
       MHR_Model.Sequence_Number_Equal (MHR, Slice (B, B_Length));

   procedure Lemma_Addressing_Fields_Preserved
     (A        : Byte_Array;
      A_Length : Natural;
      B        : Byte_Array;
      B_Length : Natural;
      MHR      : Valid_MAC_Header)
   with
     Ghost,
     Relaxed_Initialization => (A, B),
     Pre                    =>
       A_Length >= MHR_Model.Get_Aux_Security_Header_Offset (MHR)
       and then A_Length <= B_Length
       and then A_Length <= A'Length
       and then B_Length <= B'Length
       and then Prefix_Initialized (A, A_Length)
       and then Prefix_Initialized (B, B_Length)
       and then Slice (A, A_Length) = Slice (B, A_Length)
       and then MHR_Model.Destination_PAN_ID_Equal (MHR, Slice (A, A_Length))
       and then MHR_Model.Destination_Address_Equal (MHR, Slice (A, A_Length))
       and then MHR_Model.Source_PAN_ID_Equal (MHR, Slice (A, A_Length))
       and then MHR_Model.Source_Address_Equal (MHR, Slice (A, A_Length)),
     Post                   =>
       MHR_Model.Destination_PAN_ID_Equal (MHR, Slice (B, B_Length))
       and MHR_Model.Destination_Address_Equal (MHR, Slice (B, B_Length))
       and MHR_Model.Source_PAN_ID_Equal (MHR, Slice (B, B_Length))
       and MHR_Model.Source_Address_Equal (MHR, Slice (B, B_Length));

   procedure Lemma_Frame_Counter_Preserved
     (A        : Byte_Array;
      A_Length : Natural;
      B        : Byte_Array;
      B_Length : Natural;
      MHR      : Valid_MAC_Header)
   with
     Ghost,
     Relaxed_Initialization => (A, B),
     Pre                    =>
       A_Length >= MHR_Model.Get_Key_ID_Offset (MHR)
       and then A_Length <= B_Length
       and then A_Length <= A'Length
       and then B_Length <= B'Length
       and then Prefix_Initialized (A, A_Length)
       and then Prefix_Initialized (B, B_Length)
       and then Slice (A, A_Length) = Slice (B, A_Length)
       and then MHR_Model.Frame_Counter_Equal (MHR, Slice (A, A_Length)),
     Post                   =>
       MHR_Model.Frame_Counter_Equal (MHR, Slice (B, B_Length));

   --------------------
   -- Field Encoders --
   --------------------

   --  These procedures encode each individual field in the MAC header

   procedure Encode_General_Frame_Control
     (MHR : Valid_MAC_Header; Buffer : out Byte_Array; Length : out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Buffer'Length >= 2
       and then MHR.Frame_Type in Beacon | Data | Ack | MAC_Command,
     Post                   =>
       Length = MHR_Model.Get_Frame_Control_Length (MHR)
       and then Prefix_Initialized (Buffer, Length)
       and then MHR_Model.Frame_Control_Equal (MHR, Slice (Buffer, Length));

   procedure Encode_Multipurpose_Frame_Control
     (MHR : Valid_MAC_Header; Buffer : out Byte_Array; Length : out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Buffer'Length >= 2 and then MHR.Frame_Type = Multipurpose,
     Post                   =>
       Length = MHR_Model.Get_Frame_Control_Length (MHR)
       and then Prefix_Initialized (Buffer, Length)
       and then MHR_Model.Frame_Control_Equal (MHR, Slice (Buffer, Length));

   procedure Encode_Frame_Control
     (MHR : Valid_MAC_Header; Buffer : out Byte_Array; Length : out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    => Buffer'Length >= 2,
     Post                   =>
       Length = MHR_Model.Get_Frame_Control_Length (MHR)
       and then Prefix_Initialized (Buffer, Length)
       and then MHR_Model.Frame_Control_Equal (MHR, Slice (Buffer, Length));

   procedure Encode_Sequence_Number
     (SN     : Variant_Sequence_Number;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Buffer'Length > 0
       and then Offset < Buffer'Length
       and then Prefix_Initialized (Buffer, Offset),
     Post                   =>
       --  Buffer is initialized up to the new offset
       Prefix_Initialized (Buffer, Offset)

       --  Elements in Buffer before Offset are unchanged
       and then Slice (Buffer'Old, Offset'Old) = Slice (Buffer, Offset'Old)

       and then
         MHR_Model.Sequence_Number_Equal_At
           (Slice (Buffer, Offset), Offset'Old, SN),

     Contract_Cases         =>
       (SN.Suppression = Suppressed     => Offset = Offset'Old,
        SN.Suppression = Not_Suppressed => Offset = Offset'Old + 1);

   procedure Encode_PAN_ID
     (PAN_ID : Variant_PAN_ID;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Offset <= Buffer'Length - 2
       and then Prefix_Initialized (Buffer, Offset),
     Post                   =>
       --  Buffer is initialized up to the new offset
       Prefix_Initialized (Buffer, Offset)

       and then
         Offset
         >= Offset'Old

            --  Elements in Buffer before Offset are unchanged
       and then Slice (Buffer'Old, Offset'Old) = Slice (Buffer, Offset'Old)

       and then
         MHR_Model.PAN_ID_Equal_At
           (Slice (Buffer, Offset), Offset'Old, PAN_ID),

     Contract_Cases         =>
       (PAN_ID.Present     => Offset = Offset'Old + 2,
        not PAN_ID.Present => Offset = Offset'Old);

   procedure Encode_Address
     (Address : Variant_Address;
      Buffer  : in out Byte_Array;
      Offset  : in out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Offset <= Buffer'Length - 8
       and then Prefix_Initialized (Buffer, Offset),
     Post                   =>
       --  Buffer is initialized up to the new offset
       Prefix_Initialized (Buffer, Offset)

       and then
         Offset
         >= Offset'Old

            --  Elements in Buffer before Offset are unchanged
       and then Slice (Buffer'Old, Offset'Old) = Slice (Buffer, Offset'Old)

       --  Offset has been advanced by the number of bytes written
       and then Offset = Offset'Old + Address_Length (Address.Mode)

       and then
         MHR_Model.Address_Equal_At
           (Slice (Buffer, Offset), Offset'Old, Address);

   procedure Encode_Addressing_Fields
     (MHR    : Valid_MAC_Header;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Buffer'Length >= Max_MHR_Length
       and then Offset = MHR_Model.Get_Destination_PAN_ID_Offset (MHR)
       and then Prefix_Initialized (Buffer, Offset),
     Post                   =>
       Offset = MHR_Model.Get_Aux_Security_Header_Offset (MHR)
       and then Prefix_Initialized (Buffer, Offset)
       and then Slice (Buffer'Old, Offset'Old) = Slice (Buffer, Offset'Old)
       and then
         MHR_Model.Destination_PAN_ID_Equal (MHR, Slice (Buffer, Offset))
       and then
         MHR_Model.Destination_Address_Equal (MHR, Slice (Buffer, Offset))
       and then MHR_Model.Source_PAN_ID_Equal (MHR, Slice (Buffer, Offset))
       and then MHR_Model.Source_Address_Equal (MHR, Slice (Buffer, Offset));

   procedure Encode_Security_Control
     (SC     : Security_Control_Field;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Offset < Buffer'Length and then Prefix_Initialized (Buffer, Offset),
     Post                   =>
       --  Buffer is initialized up to the new offset
       Prefix_Initialized (Buffer, Offset)

       --  Offset is monotonic
       and then Offset >= Offset'Old

       and then Slice (Buffer, Offset'Old) = Slice (Buffer'Old, Offset'Old)

       --  Offset has been advanced by the number of bytes written
       and then Offset = Offset'Old + 1

       --  The Security Control was written to Buffer
       and then SC = From_Bytes (Buffer (Buffer'First + Offset'Old));

   procedure Encode_Frame_Counter
     (Frame_Counter : Variant_Frame_Counter;
      Buffer        : in out Byte_Array;
      Offset        : in out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Offset <= Buffer'Length - 4
       and then Prefix_Initialized (Buffer, Offset),
     Post                   =>
       --  Buffer is initialized up to the new offset
       Prefix_Initialized (Buffer, Offset)

       --  Offset is monotonic
       and then Offset >= Offset'Old

       and then Slice (Buffer, Offset'Old) = Slice (Buffer'Old, Offset'Old)

       --  The frame counter was written to Buffer
       and then
         MHR_Model.Frame_Counter_Equal_At
           (Slice (Buffer, Offset), Offset'Old, Frame_Counter),

     Contract_Cases         =>
       (Frame_Counter.Suppression = Suppressed     => Offset = Offset'Old,
        Frame_Counter.Suppression = Not_Suppressed => Offset = Offset'Old + 4);

   procedure Encode_Key_ID
     (Key_ID : Variant_Key_ID;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Offset <= Buffer'Length - 9
       and then Prefix_Initialized (Buffer, Offset),
     Post                   =>
       --  Buffer is initialized up to the new offset
       Prefix_Initialized (Buffer, Offset)

       and then
         --  Offset is monotonic
         Offset >= Offset'Old

       and then Slice (Buffer'Old, Offset'Old) = Slice (Buffer, Offset'Old)

       and then
         --  Offset has been advanced by the number of bytes written
         Offset = Offset'Old + Key_ID_Length (Key_ID.Mode)

       and then
         MHR_Model.Key_ID_Equal_At
           (Slice (Buffer, Offset), Offset'Old, Key_ID);

   procedure Encode_Aux_Security_Header
     (MHR    : Valid_MAC_Header;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Pre                    =>
       Offset = MHR_Model.Get_Aux_Security_Header_Offset (MHR)
       and then Buffer'Length >= Max_MHR_Length
       and then Offset <= Buffer'Length
       and then Prefix_Initialized (Buffer, Offset),
     Post                   =>
       Prefix_Initialized (Buffer, Offset)

       and then Offset >= Offset'Old

       and then Slice (Buffer'Old, Offset'Old) = Slice (Buffer, Offset'Old)

       and then
         Offset
         = Offset'Old
           + MHR_Model.Get_Security_Control_Length (MHR)
           + MHR_Model.Get_Frame_Counter_Length (MHR)
           + MHR_Model.Get_Key_ID_Length (MHR)

       and then Slice (Buffer, Offset'Old) = Slice (Buffer'Old, Offset'Old)

       and then MHR_Model.Security_Control_Equal (MHR, Slice (Buffer, Offset))
       and then MHR_Model.Frame_Counter_Equal (MHR, Slice (Buffer, Offset))
       and then MHR_Model.Key_ID_Equal (MHR, Slice (Buffer, Offset));

   -----------------------
   -- Encode_MAC_Header --
   -----------------------

   procedure Encode_MAC_Header
     (MHR : Valid_MAC_Header; Buffer : out Byte_Array; Length : out Natural)
   is
      --  The body of Frame_Control_Equal is hidden during the proofs of this
      --  subprogram to help reduce the size of the proof context.
      --
      --  Lemma_Frame_Control_Preserved is used to help prove that this
      --  property is preserved as other fields are written to Buffer.

      pragma
        Annotate
          (GNATprove,
           Hide_Info,
           "Expression_Function_Body",
           MHR_Model.Frame_Control_Equal);

      --  Keep a snapshot of the buffer state after each field is written
      --  to help prove that the contents of previously written fields are
      --  preserved.

      Buffer_FC : Byte_Array (1 .. Buffer'Length)
      with Ghost, Relaxed_Initialization;

      Length_FC : Natural
      with Ghost;

      Buffer_SN : Byte_Array (1 .. Buffer'Length)
      with Ghost, Relaxed_Initialization;

      Length_SN : Natural
      with Ghost;

      Buffer_Addr : Byte_Array (1 .. Buffer'Length)
      with Ghost, Relaxed_Initialization;

      Length_Addr : Natural
      with Ghost;
   begin

      --  Write the Frame Control field

      Encode_Frame_Control (MHR, Buffer, Length);

      Length_FC := Length;
      Assign_Slice (Target => Buffer_FC, Source => Buffer, Length => Length);

      Lemma_Frame_Control_Preserved
        (Buffer, Length, Buffer_FC, Length_FC, MHR);

      --  Write the Sequence number

      Encode_Sequence_Number (MHR.Sequence_Number, Buffer, Length);

      Lemma_Frame_Control_Preserved
        (Buffer_FC, Length_FC, Buffer, Length, MHR);

      Length_SN := Length;
      Assign_Slice (Target => Buffer_SN, Source => Buffer, Length => Length);

      Lemma_Frame_Control_Preserved
        (Buffer, Length, Buffer_SN, Length_SN, MHR);

      Lemma_Sequence_Number_Preserved
        (Buffer, Length, Buffer_SN, Length_SN, MHR);

      --  Write the addressing fields (source/destination address/PAN IDs)

      Encode_Addressing_Fields (MHR, Buffer, Length);

      Lemma_Frame_Control_Preserved
        (Buffer_SN, Length_SN, Buffer, Length, MHR);

      Lemma_Sequence_Number_Preserved
        (Buffer_SN, Length_SN, Buffer, Length, MHR);

      Length_Addr := Length;
      Assign_Slice (Target => Buffer_Addr, Source => Buffer, Length => Length);

      Lemma_Frame_Control_Preserved
        (Buffer, Length, Buffer_Addr, Length_Addr, MHR);

      Lemma_Sequence_Number_Preserved
        (Buffer, Length, Buffer_Addr, Length_Addr, MHR);

      Lemma_Addressing_Fields_Preserved
        (Buffer, Length, Buffer_Addr, Length_Addr, MHR);

      --  Write the auxiliary security header

      Encode_Aux_Security_Header (MHR, Buffer, Length);

      Lemma_Frame_Control_Preserved
        (Buffer_Addr, Length_Addr, Buffer, Length, MHR);

      Lemma_Sequence_Number_Preserved
        (Buffer_Addr, Length_Addr, Buffer, Length, MHR);

      Lemma_Addressing_Fields_Preserved
        (Buffer_Addr, Length_Addr, Buffer, Length, MHR);

      pragma Assert (Length = MHR_Model.MHR_Length_Excluding_IEs (MHR));

   end Encode_MAC_Header;

   ------------------
   -- Assign_Slice --
   ------------------

   procedure Assign_Slice
     (Target : out Byte_Array; Source : Byte_Array; Length : Natural) is
   begin
      Target (Target'First .. Target'First + (Length - 1)) :=
        Slice (Source, Length);
   end Assign_Slice;

   -----------------------------------
   -- Lemma_Frame_Control_Preserved --
   -----------------------------------

   procedure Lemma_Frame_Control_Preserved
     (A        : Byte_Array;
      A_Length : Natural;
      B        : Byte_Array;
      B_Length : Natural;
      MHR      : Valid_MAC_Header) is
   begin
      null;
   end Lemma_Frame_Control_Preserved;

   -------------------------------------
   -- Lemma_Sequence_Number_Preserved --
   -------------------------------------

   procedure Lemma_Sequence_Number_Preserved
     (A        : Byte_Array;
      A_Length : Natural;
      B        : Byte_Array;
      B_Length : Natural;
      MHR      : Valid_MAC_Header) is
   begin
      null;
   end Lemma_Sequence_Number_Preserved;

   ---------------------------------------
   -- Lemma_Addressing_Fields_Preserved --
   ---------------------------------------

   procedure Lemma_Addressing_Fields_Preserved
     (A        : Byte_Array;
      A_Length : Natural;
      B        : Byte_Array;
      B_Length : Natural;
      MHR      : Valid_MAC_Header) is
   begin
      null;
   end Lemma_Addressing_Fields_Preserved;

   -----------------------------------
   -- Lemma_Frame_Counter_Preserved --
   -----------------------------------

   procedure Lemma_Frame_Counter_Preserved
     (A        : Byte_Array;
      A_Length : Natural;
      B        : Byte_Array;
      B_Length : Natural;
      MHR      : Valid_MAC_Header)
   is
      AS : constant Byte_Array := Slice (A, A_Length);
      BS : constant Byte_Array := Slice (B, B_Length);
      N  : Natural;
   begin
      --  The provers have a hard time seeing that the part of A and B that
      --  contain the frame counter are the same when dealing with slices of
      --  the two buffers. So we use some intermediatae assertions to help
      --  guide them.

      if MHR.Aux_Security_Header.Security_Enabled = Enabled
        and then
          MHR.Aux_Security_Header.Frame_Counter.Suppression = Not_Suppressed
      then
         N := MHR_Model.Get_Frame_Counter_Offset (MHR);

         pragma
           Assert
             (AS (AS'First + N .. AS'First + N + 3)
              = BS (BS'First + N .. BS'First + N + 3));

         pragma
           Assert
             (MHR_Model.Frame_Counter_Equal_At
                (BS, N, MHR.Aux_Security_Header.Frame_Counter));

         pragma
           Assert (MHR_Model.Frame_Counter_Equal (MHR, Slice (B, B_Length)));
      end if;
   end Lemma_Frame_Counter_Preserved;

   ----------------------------------
   -- Encode_General_Frame_Control --
   ----------------------------------

   procedure Encode_General_Frame_Control
     (MHR : Valid_MAC_Header; Buffer : out Byte_Array; Length : out Natural)
   is
      FC : Frame_Control_Field;
   begin
      Length := 2;

      FC :=
        Frame_Control_Field'
          (Frame_Type         => MHR.Frame_Type,
           Security_Enabled   => MHR.Aux_Security_Header.Security_Enabled,
           Frame_Pending      => MHR.Frame_Pending,
           AR                 => MHR.AR,
           PAN_ID_Compression =>
             Get_PAN_ID_Compression
               (Frame_Version              => MHR.Frame_Version,
                Destination_Address_Mode   => MHR.Destination_Address.Mode,
                Source_Address_Mode        => MHR.Source_Address.Mode,
                Destination_PAN_ID_Present => MHR.Destination_PAN_ID.Present,
                Source_PAN_ID_Present      =>
                  not Same_PAN_ID (MHR.Destination_PAN_ID, MHR.Source_PAN_ID)
                  and then MHR.Source_PAN_ID.Present),
           Reserved           => 0,
           SN_Suppression     => MHR.Sequence_Number.Suppression,
           IE_Present         => MHR.IE_Present,
           Dest_Address_Mode  => MHR.Destination_Address.Mode,
           Frame_Version      => MHR.Frame_Version,
           Src_Address_Mode   => MHR.Source_Address.Mode);

      Buffer (Buffer'First .. Buffer'First + 1) := To_Bytes (FC);

      pragma Assert (FC = From_Bytes (Slice (Buffer, Length)));
   end Encode_General_Frame_Control;

   ---------------------------------------
   -- Encode_Multipurpose_Frame_Control --
   ---------------------------------------

   procedure Encode_Multipurpose_Frame_Control
     (MHR : Valid_MAC_Header; Buffer : out Byte_Array; Length : out Natural)
   is
      FC_L : Valid_MP_Long_Frame_Control_Field;
      FC_S : MP_Short_Frame_Control_Field;
   begin
      if MHR.Long_Frame_Control = Long then
         FC_L :=
           Valid_MP_Long_Frame_Control_Field'
             (Frame_Type         => Multipurpose,
              Long_Frame_Control => Long,
              Dest_Address_Mode  => MHR.Destination_Address.Mode,
              Src_Address_Mode   => MHR.Source_Address.Mode,
              PAN_ID_Present     =>
                (if MHR.Destination_PAN_ID.Present
                 then Present
                 else Not_Present),
              Security_Enabled   => MHR.Aux_Security_Header.Security_Enabled,
              SN_Suppression     => MHR.Sequence_Number.Suppression,
              Frame_Pending      => MHR.Frame_Pending,
              Frame_Version      => MHR.Frame_Version,
              Ack_Required       => MHR.AR,
              IE_Present         => MHR.IE_Present);

         Buffer (Buffer'First .. Buffer'First + 1) := To_Bytes (FC_L);
         Length := 2;

         pragma
           Assert
             (FC_L = From_Bytes (Buffer (Buffer'First .. Buffer'First + 1)));
      else
         FC_S :=
           MP_Short_Frame_Control_Field'
             (Frame_Type         => Multipurpose,
              Long_Frame_Control => Short,
              Dest_Address_Mode  => MHR.Destination_Address.Mode,
              Src_Address_Mode   => MHR.Source_Address.Mode);

         Buffer (Buffer'First) := To_Bytes (FC_S);
         Length := 1;

         pragma Assert (FC_S = From_Bytes (Buffer (Buffer'First)));
      end if;
   end Encode_Multipurpose_Frame_Control;

   --------------------------
   -- Encode_Frame_Control --
   --------------------------

   procedure Encode_Frame_Control
     (MHR : Valid_MAC_Header; Buffer : out Byte_Array; Length : out Natural) is
   begin
      case MHR.Frame_Type is
         when Beacon | Data | Ack | MAC_Command =>
            Encode_General_Frame_Control (MHR, Buffer, Length);

         when Multipurpose                      =>
            Encode_Multipurpose_Frame_Control (MHR, Buffer, Length);
      end case;
   end Encode_Frame_Control;

   ----------------------------
   -- Encode_Sequence_Number --
   ----------------------------

   procedure Encode_Sequence_Number
     (SN     : Variant_Sequence_Number;
      Buffer : in out Byte_Array;
      Offset : in out Natural) is
   begin
      if SN.Suppression = Not_Suppressed then
         Buffer (Buffer'First + Offset) := SN.Number;
         Offset := Offset + 1;
      end if;
   end Encode_Sequence_Number;

   -------------------
   -- Encode_PAN_ID --
   -------------------

   procedure Encode_PAN_ID
     (PAN_ID : Variant_PAN_ID;
      Buffer : in out Byte_Array;
      Offset : in out Natural) is
   begin
      if PAN_ID.Present then
         Buffer (Buffer'First + Offset .. Buffer'First + Offset + 1) :=
           To_Bytes (PAN_ID.PAN_ID);

         pragma
           Assert
             (Bits_16 (PAN_ID.PAN_ID)
              = From_Bytes
                  (Buffer
                     (Buffer'First + Offset .. Buffer'First + Offset + 1)));

         Offset := Offset + 2;
      end if;
   end Encode_PAN_ID;

   --------------------
   -- Encode_Address --
   --------------------

   procedure Encode_Address
     (Address : Variant_Address;
      Buffer  : in out Byte_Array;
      Offset  : in out Natural) is
   begin
      case Address.Mode is
         when Extended    =>
            Buffer (Buffer'First + Offset .. Buffer'First + Offset + 7) :=
              To_Bytes (Address.Extended_Address);

            Offset := Offset + 8;

         when Short       =>
            Buffer (Buffer'First + Offset .. Buffer'First + Offset + 1) :=
              To_Bytes (Address.Short_Address);

            Offset := Offset + 2;

         when Not_Present =>
            null;
      end case;
   end Encode_Address;

   ------------------------------
   -- Encode_Addressing_Fields --
   ------------------------------

   procedure Encode_Addressing_Fields
     (MHR    : Valid_MAC_Header;
      Buffer : in out Byte_Array;
      Offset : in out Natural) is
   begin
      Encode_PAN_ID (MHR.Destination_PAN_ID, Buffer, Offset);

      Encode_Address (MHR.Destination_Address, Buffer, Offset);

      Encode_PAN_ID
        (Compressed_Source_PAN_ID
           (Destination_PAN_ID => MHR.Destination_PAN_ID,
            Source_PAN_ID      => MHR.Source_PAN_ID),
         Buffer,
         Offset);

      Encode_Address (MHR.Source_Address, Buffer, Offset);
   end Encode_Addressing_Fields;

   -----------------------------
   -- Encode_Security_Control --
   -----------------------------

   procedure Encode_Security_Control
     (SC     : Security_Control_Field;
      Buffer : in out Byte_Array;
      Offset : in out Natural) is
   begin
      Buffer (Buffer'First + Offset) := To_Bytes (SC);
      Offset := Offset + 1;
   end Encode_Security_Control;

   --------------------------
   -- Encode_Frame_Counter --
   --------------------------

   procedure Encode_Frame_Counter
     (Frame_Counter : Variant_Frame_Counter;
      Buffer        : in out Byte_Array;
      Offset        : in out Natural) is
   begin
      if Frame_Counter.Suppression = Not_Suppressed then
         Buffer (Buffer'First + Offset .. Buffer'First + Offset + 3) :=
           To_Bytes (Frame_Counter.Frame_Counter);

         pragma
           Assert
             (Bits_32 (Frame_Counter.Frame_Counter)
              = From_Bytes
                  (Buffer
                     (Buffer'First + Offset .. Buffer'First + Offset + 3)));

         Offset := Offset + 4;
      end if;
   end Encode_Frame_Counter;

   -------------------
   -- Encode_Key_ID --
   -------------------

   procedure Encode_Key_ID
     (Key_ID : Variant_Key_ID;
      Buffer : in out Byte_Array;
      Offset : in out Natural) is
   begin
      case Key_ID.Mode is
         when 0 =>
            null;

         when 1 =>
            Buffer (Buffer'First + Offset) := Bits_8 (Key_ID.Key_Index);
            Offset := Offset + 1;

         when 2 =>
            Buffer (Buffer'First + Offset) := Bits_8 (Key_ID.Key_Index);
            Buffer (Buffer'First + Offset + 1 .. Buffer'First + Offset + 4) :=
              Byte_Array (Key_ID.Key_Source_4);

            Offset := Offset + 5;

         when 3 =>
            Buffer (Buffer'First + Offset) := Bits_8 (Key_ID.Key_Index);
            Buffer (Buffer'First + Offset + 1 .. Buffer'First + Offset + 8) :=
              Byte_Array (Key_ID.Key_Source_8);

            Offset := Offset + 9;
      end case;
   end Encode_Key_ID;

   --------------------------------
   -- Encode_Aux_Security_Header --
   --------------------------------

   procedure Encode_Aux_Security_Header
     (MHR    : Valid_MAC_Header;
      Buffer : in out Byte_Array;
      Offset : in out Natural)
   is
      Buffer_Old : constant Byte_Array := Slice (Buffer, Offset)
      with Ghost;

      Buffer_FC : Byte_Array (Buffer'Range)
      with Ghost, Relaxed_Initialization;

      Offset_FC : Natural
      with Ghost;

   begin
      if MHR.Aux_Security_Header.Security_Enabled = Enabled then

         --  Write the Security Control field

         Encode_Security_Control
           (Security_Control_Field'
              (Security_Level => MHR.Aux_Security_Header.Security_Level,
               Key_ID_Mode    => MHR.Aux_Security_Header.Key_ID.Mode,
               FC_Suppression =>
                 MHR.Aux_Security_Header.Frame_Counter.Suppression,
               Nonce_Source   => MHR.Aux_Security_Header.ASN_In_Nonce,
               Reserved       => 0),
            Buffer => Buffer,
            Offset => Offset);

         pragma Assert (Buffer_Old = Slice (Buffer, Buffer_Old'Length));
         pragma Assert (Offset = MHR_Model.Get_Frame_Counter_Offset (MHR));

         --  Write the Frame Counter

         Encode_Frame_Counter
           (MHR.Aux_Security_Header.Frame_Counter, Buffer, Offset);

         pragma Assert (Buffer_Old = Slice (Buffer, Buffer_Old'Length));
         pragma Assert (Offset = MHR_Model.Get_Key_ID_Offset (MHR));

         Offset_FC := Offset;
         Assign_Slice
           (Target => Buffer_FC, Source => Buffer, Length => Offset);

         Lemma_Frame_Counter_Preserved
           (Buffer, Offset, Buffer_FC, Offset_FC, MHR);

         --  Write the Key ID

         Encode_Key_ID (MHR.Aux_Security_Header.Key_ID, Buffer, Offset);

         --  Help prove postcondition

         Lemma_Frame_Counter_Preserved
           (Buffer_FC, Offset_FC, Buffer, Offset, MHR);

         pragma
           Assert
             (MHR_Model.Frame_Counter_Equal_At
                (Slice (Buffer, Offset),
                 MHR_Model.Get_Frame_Counter_Offset (MHR),
                 MHR.Aux_Security_Header.Frame_Counter));
      end if;
   end Encode_Aux_Security_Header;

end AdaBee.MAC.Frames.Headers.Encoders;
