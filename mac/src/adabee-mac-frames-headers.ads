--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Unchecked_Conversion;
with System;

private with Interfaces;

--  @summary
--  IEEE 802.15.4 MAC frame header (MHR) definitions.

package AdaBee.MAC.Frames.Headers
  with Pure, SPARK_Mode, Always_Terminates
is

   ----------------------
   -- Frame Type Field --
   ----------------------
   --  Ref. 7.2.2.2 of IEEE 802.15.4-2024

   type Frame_Type_Field is
     (Beacon, Data, Ack, MAC_Command, Reserved, Multipurpose, Frak, Extended)
   with Size => 3;

   for Frame_Type_Field use
     (Beacon       => 2#000#,
      Data         => 2#001#,
      Ack          => 2#010#,
      MAC_Command  => 2#011#,
      Reserved     => 2#100#,
      Multipurpose => 2#101#,
      Frak         => 2#110#,
      Extended     => 2#111#);

   subtype Unsupported_Frame_Types is Frame_Type_Field
   with
     Static_Predicate => Unsupported_Frame_Types in Reserved | Frak | Extended;
   --  The set of frame types that are not supported in this implementation

   subtype Supported_Frame_Types is Frame_Type_Field
   with
     Static_Predicate =>
       Supported_Frame_Types
       in Beacon | Data | Ack | MAC_Command | Multipurpose;

   ----------------------------
   -- Security Enabled Field --
   ----------------------------
   --  Ref. 7.2.2.3 of IEEE 802.15.4-2024

   type Security_Enabled_Field is (Disabled, Enabled) with Size => 1;

   for Security_Enabled_Field use (Disabled => 0, Enabled => 1);

   -------------------------
   -- Frame Pending Field --
   -------------------------
   --  Ref. 7.2.2.4 of IEEE 802.15.4-2024

   type Frame_Pending_Field is (Not_Pending, Pending) with Size => 1;

   for Frame_Pending_Field use (Not_Pending => 0, Pending => 1);

   ------------------------
   -- Ack Required Field --
   ------------------------
   --  Ref. 7.2.2.5 of IEEE 802.15.4-2024

   type Ack_Required_Field is (Not_Required, Required) with Size => 1;

   for Ack_Required_Field use (Not_Required => 0, Required => 1);

   ------------------------
   -- PAN ID Compression --
   ------------------------
   --  Ref. 7.2.2.6 of IEEE 802.15.4-2024

   type PAN_ID_Compression_Field is (Not_Compressed, Compressed)
   with Size => 1;

   for PAN_ID_Compression_Field use (Not_Compressed => 0, Compressed => 1);

   ---------------------------------
   -- Sequence Number Suppression --
   ---------------------------------
   --  Ref. 7.2.2.7 of IEEE 802.15.4-2024

   type Seq_Number_Suppression_Field is (Not_Suppressed, Suppressed)
   with Size => 1;

   for Seq_Number_Suppression_Field use (Not_Suppressed => 0, Suppressed => 1);

   ----------------------------------------
   -- Information Elements Present Field --
   ----------------------------------------
   --  Ref. 7.2.2.8 of IEEE 802.15.4-2024

   type IE_Present_Field is (Not_Present, Present) with Size => 1;

   for IE_Present_Field use (Not_Present => 0, Present => 1);

   ------------------------------------------------
   -- Destination/Source Addressing Mode Field --
   ------------------------------------------------
   --  Ref. 7.2.2.9 of IEEE 802.15.4-2024

   type Address_Mode_Field is (Not_Present, Reserved, Short, Extended)
   with Size => 2;

   for Address_Mode_Field use
     (Not_Present => 2#00#,
      Reserved    => 2#01#,
      Short       => 2#10#,
      Extended    => 2#11#);

   subtype Valid_Address_Mode_Field is Address_Mode_Field
   with
     Static_Predicate =>
       Valid_Address_Mode_Field in Not_Present | Short | Extended;

   --------------------------------------
   -- Destination/Source Address Field --
   --------------------------------------
   --  Ref. Table 7-3 of IEEE 802.15.4-2024

   type Extended_Address_Field is new Bits_64;

   Broadcast_Extended_Address : constant Extended_Address_Field :=
     16#FFFF_FFFF_FFFF_FFFF#;

   type Short_Address_Field is new Bits_16;

   Broadcast_Short_Address : constant Short_Address_Field := 16#FFFF#;
   Invalid_Short_Address   : constant Short_Address_Field := 16#FFFE#;

   subtype Device_Short_Address_Range is
     Short_Address_Field range 0 .. 16#FFFD#;

   type Variant_Address (Mode : Valid_Address_Mode_Field := Not_Present) is
   record
      case Mode is
         when Not_Present =>
            null;

         when Short =>
            Short_Address : Short_Address_Field;

         when Extended =>
            Extended_Address : Extended_Address_Field;
      end case;
   end record;

   -------------------------
   -- Frame Version Field --
   -------------------------
   --  Ref. 7.2.2.10 of IEEE 802.15.4-2024

   type Frame_Version_Field is
     (IEEE_802_15_4_2003, IEEE_802_15_4_2006, IEEE_802_15_4, Reserved)
   with Size => 2;

   for Frame_Version_Field use
     (IEEE_802_15_4_2003 => 2#00#,
      IEEE_802_15_4_2006 => 2#01#,
      IEEE_802_15_4      => 2#10#,
      Reserved           => 2#11#);

   subtype Valid_Frame_Version_Field is Frame_Version_Field
   with
     Static_Predicate =>
       Valid_Frame_Version_Field
       in IEEE_802_15_4_2003 | IEEE_802_15_4_2006 | IEEE_802_15_4;

   ---------------------------
   -- Sequence Number Field --
   ---------------------------
   --  Ref. 7.2.3 of IEEE 802.15.4-2024

   type Variant_Sequence_Number
     (Suppression : Seq_Number_Suppression_Field := Suppressed)
   is record
      case Suppression is
         when Suppressed =>
            null;

         when Not_Suppressed =>
            Number : Bits_8;
      end case;
   end record;

   ------------------
   -- PAN ID Field --
   ------------------
   --  Ref. 7.2.4 of IEEE 802.15.4-2024

   type PAN_ID_Field is new Bits_16;

   Broadcast_PAN_ID : constant PAN_ID_Field := 16#FFFF#;

   type Variant_PAN_ID (Present : Boolean := False) is record
      case Present is
         when False =>
            null;

         when True =>
            PAN_ID : PAN_ID_Field;
      end case;
   end record;

   -------------------------
   -- Frame Control Field --
   -------------------------
   --  Ref. 7.2.2 of IEEE 802.15.4-2024

   type Frame_Control_Field is record
      Frame_Type         : Frame_Type_Field;
      Security_Enabled   : Security_Enabled_Field;
      Frame_Pending      : Frame_Pending_Field;
      AR                 : Ack_Required_Field;
      PAN_ID_Compression : PAN_ID_Compression_Field;
      Reserved           : Bit;
      SN_Suppression     : Seq_Number_Suppression_Field;
      IE_Present         : IE_Present_Field;
      Dest_Address_Mode  : Address_Mode_Field;
      Frame_Version      : Frame_Version_Field;
      Src_Address_Mode   : Address_Mode_Field;
   end record
   with
     Size                 => 16,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Frame_Control_Field use
     record
       Frame_Type         at 0 range 0 .. 2;
       Security_Enabled   at 0 range 3 .. 3;
       Frame_Pending      at 0 range 4 .. 4;
       AR                 at 0 range 5 .. 5;
       PAN_ID_Compression at 0 range 6 .. 6;
       Reserved           at 0 range 7 .. 7;
       SN_Suppression     at 0 range 8 .. 8;
       IE_Present         at 0 range 9 .. 9;
       Dest_Address_Mode  at 0 range 10 .. 11;
       Frame_Version      at 0 range 12 .. 13;
       Src_Address_Mode   at 0 range 14 .. 15;
     end record;

   ------------------------------
   -- Long Frame_Control Field --
   ------------------------------
   --  Ref. 7.3.5.3 of IEEE 802.15.4-2024

   type Long_Frame_Control_Field is (Short, Long) with Size => 1;
   for Long_Frame_Control_Field use (Short => 0, Long => 1);

   --------------------------
   -- PAN ID Present Field --
   --------------------------
   --  Ref. 7.3.5.6 of IEEE 802.15.4-2024

   type PAN_ID_Present_Field is (Not_Present, Present) with Size => 1;
   for PAN_ID_Present_Field use (Not_Present => 0, Present => 1);

   ----------------------------
   -- MP Frame Control Field --
   ----------------------------
   --  Ref. 7.3.5.1 of IEEE 802.15.4-2024

   --  The Frame Control field for Multipurpose frames is either 1 or 2
   --  octets depending on the value of the Long Frame Control field.

   type MP_Short_Frame_Control_Field is record
      Frame_Type         : Frame_Type_Field;
      Long_Frame_Control : Long_Frame_Control_Field;
      Dest_Address_Mode  : Address_Mode_Field;
      Src_Address_Mode   : Address_Mode_Field;
   end record
   with
     Size                 => 8,
     Alignment            => 1,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for MP_Short_Frame_Control_Field use
     record
       Frame_Type         at 0 range 0 .. 2;
       Long_Frame_Control at 0 range 3 .. 3;
       Dest_Address_Mode  at 0 range 4 .. 5;
       Src_Address_Mode   at 0 range 6 .. 7;
     end record;

   type MP_Long_Frame_Control_Field is record
      Frame_Type         : Frame_Type_Field;
      Long_Frame_Control : Long_Frame_Control_Field;
      Dest_Address_Mode  : Address_Mode_Field;
      Src_Address_Mode   : Address_Mode_Field;
      PAN_ID_Present     : PAN_ID_Present_Field;
      Security_Enabled   : Security_Enabled_Field;
      SN_Suppression     : Seq_Number_Suppression_Field;
      Frame_Pending      : Frame_Pending_Field;
      Frame_Version      : Frame_Version_Field;
      Ack_Required       : Ack_Required_Field;
      IE_Present         : IE_Present_Field;
   end record
   with
     Size                 => 16,
     Alignment            => 1,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for MP_Long_Frame_Control_Field use
     record
       Frame_Type         at 0 range 0 .. 2;
       Long_Frame_Control at 0 range 3 .. 3;
       Dest_Address_Mode  at 0 range 4 .. 5;
       Src_Address_Mode   at 0 range 6 .. 7;
       PAN_ID_Present     at 0 range 8 .. 8;
       Security_Enabled   at 0 range 9 .. 9;
       SN_Suppression     at 0 range 10 .. 10;
       Frame_Pending      at 0 range 11 .. 11;
       Frame_Version      at 0 range 12 .. 13;
       Ack_Required       at 0 range 14 .. 14;
       IE_Present         at 0 range 15 .. 15;
     end record;

   function To_Long_Frame_Control
     (FC : MP_Short_Frame_Control_Field) return MP_Long_Frame_Control_Field
   is (MP_Long_Frame_Control_Field'
         (Frame_Type         => FC.Frame_Type,
          Long_Frame_Control => FC.Long_Frame_Control,
          Dest_Address_Mode  => FC.Dest_Address_Mode,
          Src_Address_Mode   => FC.Src_Address_Mode,
          PAN_ID_Present     => Not_Present,
          Security_Enabled   => Disabled,
          SN_Suppression     => Suppressed,
          Frame_Pending      => Not_Pending,
          Frame_Version      => IEEE_802_15_4_2003,
          Ack_Required       => Not_Required,
          IE_Present         => Not_Present));

   --------------------------
   -- Security Level Field --
   --------------------------
   --  Ref. 9.4.2.2 of IEEE 802.15.4-2024

   type Security_Level_Field is range 0 .. 7 with Size => 3;

   -------------------------------
   -- Key Identifier Mode Field --
   -------------------------------
   --  Ref. 9.4.2.3 of IEEE 802.15.4-2024

   type Key_ID_Mode_Field is range 0 .. 3 with Size => 2;

   -------------------------------------
   -- Frame Counter Suppression Field --
   -------------------------------------
   --  Ref. 9.4.2.4 of IEEE 802.15.4-2024

   type Frame_Counter_Suppression_Field is (Not_Suppressed, Suppressed)
   with Size => 1;

   for Frame_Counter_Suppression_Field use
     (Not_Suppressed => 0, Suppressed => 1);

   ------------------------
   -- ASN In Nonce Field --
   ------------------------
   --  Ref. 9.4.2.5 of IEEE 802.15.4-2024

   type Nonce_Source_Field is (From_Frame_Counter, From_ASN) with Size => 1;

   for Nonce_Source_Field use (From_Frame_Counter => 0, From_ASN => 1);

   ----------------------------
   -- Security Control Field --
   ----------------------------
   --  Ref. 9.4.2 of IEEE 802.15.4-2024

   type Security_Control_Field is record
      Security_Level : Security_Level_Field;
      Key_ID_Mode    : Key_ID_Mode_Field;
      FC_Suppression : Frame_Counter_Suppression_Field;
      Nonce_Source   : Nonce_Source_Field;
      Reserved       : Bit;
   end record
   with
     Size                 => 8,
     Alignment            => 1,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Security_Control_Field use
     record
       Security_Level at 0 range 0 .. 2;
       Key_ID_Mode    at 0 range 3 .. 4;
       FC_Suppression at 0 range 5 .. 5;
       Nonce_Source   at 0 range 6 .. 6;
       Reserved       at 0 range 7 .. 7;
     end record;

   -------------------------
   -- Frame Counter Field --
   -------------------------
   --  Ref. 9.4.3 of IEEE 802.15.4-2024

   type Frame_Counter_Field is range 0 .. 2 ** 32 - 1 with Size => 32;

   type Variant_Frame_Counter
     (Suppression : Frame_Counter_Suppression_Field := Suppressed)
   is record
      case Suppression is
         when Suppressed =>
            null;

         when Not_Suppressed =>
            Frame_Counter : Frame_Counter_Field;
      end case;
   end record;

   --------------------------
   -- Key Identifier Field --
   --------------------------
   --  Ref. 9.4.4 of IEEE 802.15.4-2024

   type Key_Source_Field is new Byte_Array
   with Dynamic_Predicate => Key_Source_Field'Length in 0 | 4 | 8;

   type Key_Index_Field is range 0 .. 255 with Size => 8;

   --  Presence of Key Index and Key Source fields depends on the Key ID Mode.
   --  Refer to Table 9-7 of IEEE 802.15.4-20120

   type Variant_Key_ID (Mode : Key_ID_Mode_Field := 0) is record
      case Mode is
         when 0 =>
            null;

         when 1 .. 3 =>
            Key_Index : Key_Index_Field;

            case Mode is
               when 0 | 1 =>
                  null;

               when 2 =>
                  Key_Source_4 : Key_Source_Field (1 .. 4);

               when 3 =>
                  Key_Source_8 : Key_Source_Field (1 .. 8);
            end case;
      end case;
   end record;

   -------------------------------
   -- Auxiliary Security Header --
   -------------------------------
   --  Ref 9.4 of IEEE 802.15.4-2024

   type Variant_Aux_Security_Header
     (Security_Enabled : Security_Enabled_Field := Disabled)
   is record
      case Security_Enabled is
         when Disabled =>
            null;

         when Enabled =>
            Security_Level : Security_Level_Field;
            ASN_In_Nonce   : Nonce_Source_Field;
            Frame_Counter  : Variant_Frame_Counter;
            Key_ID         : Variant_Key_ID;
      end case;
   end record;

   ----------------
   -- MAC Header --
   ----------------
   --  Ref. 7.2 of IEEE 802.15.4-2024

   type MAC_Header is record
      --  Frame Control Fields.
      --  Note that some fields are in the discriminant part of other fields.
      Frame_Type    : Supported_Frame_Types;
      Frame_Pending : Frame_Pending_Field;
      AR            : Ack_Required_Field;
      IE_Present    : IE_Present_Field;
      Frame_Version : Valid_Frame_Version_Field;

      --  Other fields
      Sequence_Number     : Variant_Sequence_Number;
      Destination_PAN_ID  : Variant_PAN_ID;
      Destination_Address : Variant_Address;
      Source_PAN_ID       : Variant_PAN_ID;
      Source_Address      : Variant_Address;
      Aux_Security_Header : Variant_Aux_Security_Header;
   end record;

   ------------------
   -- Formal Rules --
   ------------------

   --  This package formalizes several rules from IEEE 802.15.4-2024
   --  regarding MAC headers and PAN ID compression.

   package PAN_ID_Model
     with Ghost
   is

      function Is_Valid_Configuration
        (Frame_Version              : Frame_Version_Field;
         Destination_Address_Mode   : Address_Mode_Field;
         Source_Address_Mode        : Address_Mode_Field;
         Destination_PAN_ID_Present : Boolean;
         Source_PAN_ID_Present      : Boolean) return Boolean
      is (Frame_Version /= Reserved
          and then Destination_Address_Mode /= Reserved
          and then Source_Address_Mode /= Reserved
          and then
            (if Frame_Version in IEEE_802_15_4_2003 | IEEE_802_15_4_2006
             then
               --  Destination PAN ID is present when the destination address
               --  is present.
               (Destination_PAN_ID_Present
                = (Destination_Address_Mode /= Not_Present))

               --  The source address must be present when the source PAN ID
               --  is present.
               and then
                 (if Source_PAN_ID_Present
                  then Source_Address_Mode /= Not_Present)

               --  Ref. IEEE 802.15.4-2024 Section 7.2.2.9:
               --  If this field is equal to zero and the Frame Type field
               --  specifies a Data frame or MAC command and the Frame Version
               --  field is set to 0b00 or 0b01, the Source Addressing Mode
               --  field shall be nonzero, implying that the frame is directed
               --  to the PAN coordinator with the PAN ID as specified in the
               --  Source PAN ID field.
               and then
                 (if Destination_Address_Mode = Not_Present
                  then
                    Source_Address_Mode /= Not_Present
                    and then Source_PAN_ID_Present)
             else
               --  Ref. Table 7-2 of IEEE 802.15.4-2024

               --  The source address must be present if the source PAN ID is
               --  present.
               (if Source_PAN_ID_Present
                then Source_Address_Mode /= Not_Present)

               --  The source PAN ID is never present when both addresses are
               --  extended addresses
               and then
                 (if Destination_Address_Mode = Extended
                    and then Source_Address_Mode = Extended
                  then not Source_PAN_ID_Present)

               --  The destination PAN ID is always present when both addresses
               --  are present.
               and then
                 (if Destination_Address_Mode /= Not_Present
                    and then Source_Address_Mode /= Not_Present
                  then Destination_PAN_ID_Present)

               --  The destination address must be present if the destination
               --  PAN ID is present, except when both the source address &
               --  PAN ID are also not present.
               and then
                 (if Destination_PAN_ID_Present
                  then
                    Destination_Address_Mode /= Not_Present
                    or else
                      (Source_Address_Mode = Not_Present
                       and then not Source_PAN_ID_Present))));
      --  Checks if the given source/destination address and PAN IDs are a
      --  valid configuration according to Table 7-2 of IEEE 802.15.4-2024

      function Get_PAN_ID_Compression
        (Frame_Version              : Frame_Version_Field;
         Destination_Address_Mode   : Address_Mode_Field;
         Source_Address_Mode        : Address_Mode_Field;
         Destination_PAN_ID_Present : Boolean;
         Source_PAN_ID_Present      : Boolean) return PAN_ID_Compression_Field
      is (case Frame_Version is
            when Reserved                                => Not_Compressed,
            when IEEE_802_15_4_2003 | IEEE_802_15_4_2006 =>
              (if Destination_Address_Mode /= Not_Present
                 and then Source_Address_Mode /= Not_Present
                 and then Destination_PAN_ID_Present
                 and then not Source_PAN_ID_Present
               then Compressed
               else Not_Compressed),

            when IEEE_802_15_4                           =>
              --  PAN ID compression is always zero when the Source PAN ID is
              --  present, unless the destination PAN ID is also present and
              --  one (or both) of the address is a short address and the
              --  PAN IDs are equal.
              (if Source_PAN_ID_Present
               then Not_Compressed

               --  Case when destination PAN ID is present, but the source
               --  PAN ID is not present.
               elsif Destination_PAN_ID_Present
               then
                 (if Destination_Address_Mode = Not_Present
                  then Compressed
                  elsif Source_Address_Mode = Not_Present
                  then Not_Compressed
                  elsif Destination_Address_Mode = Extended
                    and then Source_Address_Mode = Extended
                  then Not_Compressed
                  else Compressed)

               --  Case when neither PAN ID is present
               elsif Destination_Address_Mode = Not_Present
                 and then Source_Address_Mode = Not_Present
               then Not_Compressed
               else Compressed))
      with
        Global => null,
        Pre    =>
          Is_Valid_Configuration
            (Frame_Version,
             Destination_Address_Mode,
             Source_Address_Mode,
             Destination_PAN_ID_Present,
             Source_PAN_ID_Present),
        Post   =>
          Source_PAN_ID_Present
          = PAN_ID_Model.Is_Source_PAN_ID_Present
              (Frame_Version,
               Destination_Address_Mode,
               Source_Address_Mode,
               Get_PAN_ID_Compression'Result)

          and then
            Destination_PAN_ID_Present
            = PAN_ID_Model.Is_Destination_PAN_ID_Present
                (Frame_Version,
                 Destination_Address_Mode,
                 Source_Address_Mode,
                 Get_PAN_ID_Compression'Result);
      --  Get the value of the PAN ID Compression field for the specified
      --  source/destination address and PAN ID presence configuration,
      --  as per Section 7.2.2.6 of IEEE 802.15.4-2024.

      function Is_Source_PAN_ID_Present
        (Frame_Version            : Frame_Version_Field;
         Destination_Address_Mode : Address_Mode_Field;
         Source_Address_Mode      : Address_Mode_Field;
         PAN_ID_Compression       : PAN_ID_Compression_Field) return Boolean
      is (PAN_ID_Compression = Not_Compressed
          and then Source_Address_Mode /= Not_Present
          and then
            (if Frame_Version = IEEE_802_15_4
             then
               Destination_Address_Mode /= Extended
               or else Source_Address_Mode /= Extended))
      with
        Global => null,
        Pre    =>
          Frame_Version /= Reserved
          and then Destination_Address_Mode /= Reserved
          and then Source_Address_Mode /= Reserved;
      --  Checks whether the source PAN ID field is present in a MAC header,
      --  based on the source/destination addresses and the PAN ID compression
      --  field.

      function Is_Destination_PAN_ID_Present
        (Frame_Version            : Frame_Version_Field;
         Destination_Address_Mode : Address_Mode_Field;
         Source_Address_Mode      : Address_Mode_Field;
         PAN_ID_Compression       : PAN_ID_Compression_Field) return Boolean
      is (if Frame_Version in IEEE_802_15_4_2003 | IEEE_802_15_4_2006
          then Destination_Address_Mode /= Not_Present

          elsif PAN_ID_Compression = Compressed
          then
            ((Destination_Address_Mode = Not_Present)
             and then (Source_Address_Mode = Not_Present))
            or else
              (Destination_Address_Mode /= Not_Present
               and then Source_Address_Mode /= Not_Present
               and then
                 ((Destination_Address_Mode /= Extended)
                  or else (Source_Address_Mode /= Extended)))

          else Destination_Address_Mode /= Not_Present)
      with
        Global => null,
        Pre    =>
          Frame_Version /= Reserved
          and then Destination_Address_Mode /= Reserved
          and then Source_Address_Mode /= Reserved;
      --  Checks whether the destination PAN ID field is present in a MAC
      --  header, based on the source/destination addresses and the PAN ID
      --  compression field.

   end PAN_ID_Model;

   -------------------------
   -- PAN ID Field Checks --
   -------------------------

   function Same_PAN_ID (A, B : Variant_PAN_ID) return Boolean
   is (A.Present and then B.Present and then A.PAN_ID = B.PAN_ID);
   --  Check whether two Variant_PAN_IDs denote the same PAN ID.

   function Get_PAN_ID_Compression
     (Frame_Version              : Frame_Version_Field;
      Destination_Address_Mode   : Address_Mode_Field;
      Source_Address_Mode        : Address_Mode_Field;
      Destination_PAN_ID_Present : Boolean;
      Source_PAN_ID_Present      : Boolean) return PAN_ID_Compression_Field
   with
     Global => null,
     Pre    =>
       PAN_ID_Model.Is_Valid_Configuration
         (Frame_Version,
          Destination_Address_Mode,
          Source_Address_Mode,
          Destination_PAN_ID_Present,
          Source_PAN_ID_Present),
     Post   =>
       Get_PAN_ID_Compression'Result
       = PAN_ID_Model.Get_PAN_ID_Compression
           (Frame_Version,
            Destination_Address_Mode,
            Source_Address_Mode,
            Destination_PAN_ID_Present,
            Source_PAN_ID_Present);
   --  Get the value of the PAN ID Compression field for the specified
   --  source/destination addresses and PAN IDs.

   function Is_Source_PAN_ID_Present
     (Frame_Version            : Frame_Version_Field;
      Destination_Address_Mode : Address_Mode_Field;
      Source_Address_Mode      : Address_Mode_Field;
      PAN_ID_Compression       : PAN_ID_Compression_Field) return Boolean
   with
     Global => null,
     Pre    =>
       Frame_Version /= Reserved
       and then Destination_Address_Mode /= Reserved
       and then Source_Address_Mode /= Reserved,
     Post   =>
       Is_Source_PAN_ID_Present'Result
       = PAN_ID_Model.Is_Source_PAN_ID_Present
           (Frame_Version,
            Destination_Address_Mode,
            Source_Address_Mode,
            PAN_ID_Compression);
   --  Checks whether the source PAN ID field is present in a MAC header,
   --  based on the source/destination addresses and the PAN ID compression
   --  field.

   function Is_Destination_PAN_ID_Present
     (Frame_Version            : Frame_Version_Field;
      Destination_Address_Mode : Address_Mode_Field;
      Source_Address_Mode      : Address_Mode_Field;
      PAN_ID_Compression       : PAN_ID_Compression_Field) return Boolean
   with
     Global => null,
     Pre    =>
       Frame_Version /= Reserved
       and then Destination_Address_Mode /= Reserved
       and then Source_Address_Mode /= Reserved,
     Post   =>
       Is_Destination_PAN_ID_Present'Result
       = PAN_ID_Model.Is_Destination_PAN_ID_Present
           (Frame_Version,
            Destination_Address_Mode,
            Source_Address_Mode,
            PAN_ID_Compression);
   --  Checks whether the destination PAN ID field is present in a MAC
   --  header, based on the source/destination addresses and the PAN ID
   --  compression field.

   -----------------
   -- Conversions --
   -----------------

   --  These subprograms convert certain field types to and from their
   --  byte array representation.
   --
   --  These are used for encoding and decoding operations.

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Frame_Control_Field,
        Target => Byte_Array_2);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Byte_Array_2_Aligned_2,
        Target => Frame_Control_Field);

   function From_Bytes (Bytes : Byte_Array_2) return Frame_Control_Field
   is (From_Bytes (Byte_Array_2_Aligned_2 (Bytes)));

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => MP_Short_Frame_Control_Field,
        Target => Bits_8);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Bits_8,
        Target => MP_Short_Frame_Control_Field);

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => MP_Long_Frame_Control_Field,
        Target => Byte_Array_2);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Byte_Array_2_Aligned_2,
        Target => MP_Long_Frame_Control_Field);

   function From_Bytes
     (Bytes : Byte_Array_2) return MP_Long_Frame_Control_Field
   is (From_Bytes (Byte_Array_2_Aligned_2 (Bytes)));

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Security_Control_Field,
        Target => Bits_8);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Bits_8,
        Target => Security_Control_Field);

   function To_Bytes (PAN_ID : PAN_ID_Field) return Byte_Array_2
   with Inline, Global => null;

   function From_Bytes (Bytes : Byte_Array_2) return PAN_ID_Field
   with Inline, Global => null;

   function To_Bytes (Address : Short_Address_Field) return Byte_Array_2
   with Inline, Global => null;

   function From_Bytes (Bytes : Byte_Array_2) return Short_Address_Field
   with Inline, Global => null;

   function To_Bytes (FC : Frame_Counter_Field) return Byte_Array_4
   with Inline, Global => null;

   function From_Bytes (Bytes : Byte_Array_4) return Frame_Counter_Field
   with Inline, Global => null;

   function To_Bytes (Address : Extended_Address_Field) return Byte_Array_8
   with Inline, Global => null;

   function From_Bytes (Bytes : Byte_Array_8) return Extended_Address_Field
   with Inline, Global => null;

private

   use Interfaces;

   ----------------------------
   -- Get_PAN_ID_Compression --
   ----------------------------

   --  Lookup table for PAN ID compression for frame version 0b00 and 0b01

   PAN_ID_Compression_LUT_0b00_0b01 :
     constant array (Address_Mode_Field, --  Destination address
                     Address_Mode_Field, --  Source address
                     Boolean,            --  Destination PAN ID present
                     Boolean)            --  Source PAN ID present
     of PAN_ID_Compression_Field :=
   --!format off
   --              |               |Destination|  Source  |
   --  Destination |    Source     |  PAN ID   |  PAN ID  | PAN ID
   --    Address   |    Address    | Present?  | Present? | Compression
     [Not_Present => [Not_Present => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Short       => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Extended    => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Reserved    => [others  => [others => Not_Compressed]]],
      Short       => [Not_Present => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Short       => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Compressed,
                                                  True   => Not_Compressed]],
                      Extended    => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Compressed,
                                                  True   => Not_Compressed]],
                      Reserved    => [others  => [others => Not_Compressed]]],
      Extended    => [Not_Present => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Short       => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Compressed,
                                                  True   => Not_Compressed]],
                      Extended    => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Compressed,
                                                  True   => Not_Compressed]],
                      Reserved    => [others  => [others => Not_Compressed]]],
      Reserved    => [others      => [others  => [others => Not_Compressed]]]];
   --!format on

   --  Lookup table for PAN ID compression for frame version 0b10
   --  Ref. Table 7-2 of IEEE 802.15.4-2024

   PAN_ID_Compression_LUT_0b10 :
     constant array (Address_Mode_Field, --  Destination address
                     Address_Mode_Field, --  Source address
                     Boolean,            --  Destination PAN ID present
                     Boolean)            --  Source PAN ID present
     of PAN_ID_Compression_Field :=
   --!format off
   --              |               |Destination|  Source  |
   --  Destination |    Source     |  PAN ID   |  PAN ID  | PAN ID
   --    Address   |    Address    | Present?  | Present? | Compression
     [Not_Present => [Not_Present => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Compressed,
                                                  True   => Not_Compressed]],
                      Short       => [False   => [False  => Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Extended    => [False   => [False  => Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Reserved    => [others  => [others => Not_Compressed]]],
      Short       => [Not_Present => [False   => [False  => Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Short       => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Compressed,
                                                  True   => Not_Compressed]],
                      Extended    => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Compressed,
                                                  True   => Not_Compressed]],
                      Reserved    => [others  => [others => Not_Compressed]]],
      Extended    => [Not_Present => [False   => [False  => Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Short       => [False   => [False  => Not_Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Compressed,
                                                  True   => Not_Compressed]],
                      Extended    => [False   => [False  => Compressed,
                                                  True   => Not_Compressed],
                                      True    => [False  => Not_Compressed,
                                                  True   => Not_Compressed]],
                      Reserved    => [others  => [others => Not_Compressed]]],
      Reserved    => [others      => [others  => [others => Not_Compressed]]]];
   --!format on

   function Get_PAN_ID_Compression
     (Frame_Version              : Frame_Version_Field;
      Destination_Address_Mode   : Address_Mode_Field;
      Source_Address_Mode        : Address_Mode_Field;
      Destination_PAN_ID_Present : Boolean;
      Source_PAN_ID_Present      : Boolean) return PAN_ID_Compression_Field
   is (case Frame_Version is
         when Reserved                                => Not_Compressed,
         when IEEE_802_15_4_2003 | IEEE_802_15_4_2006 =>
           PAN_ID_Compression_LUT_0b00_0b01
             (Destination_Address_Mode,
              Source_Address_Mode,
              Destination_PAN_ID_Present,
              Source_PAN_ID_Present),

         when IEEE_802_15_4                           =>
           PAN_ID_Compression_LUT_0b10
             (Destination_Address_Mode,
              Source_Address_Mode,
              Destination_PAN_ID_Present,
              Source_PAN_ID_Present));

   ------------------------------
   -- Is_Source_PAN_ID_Present --
   ------------------------------

   --  Lookup table for Source PAN ID presence for frame version 0b10.
   --  Ref. Table 7-2 of IEEE 802.15.4-2024

   Source_PAN_ID_Present_LUT_0b10 :
     constant array (Address_Mode_Field,       --  Destination address
                     Address_Mode_Field,       --  Source address
                     PAN_ID_Compression_Field) --  PAN ID Compression
     of Boolean :=
   --!format off
   --              |               |              |  Source
   --  Destination |    Source     |  PAN ID      |  PAN ID
   --    Address   |    Address    | Compression  | Present?
     [Not_Present => [Not_Present => [Not_Compressed => False,
                                      Compressed     => False],
                      Short       => [Not_Compressed => True,
                                      Compressed     => False],
                      Extended    => [Not_Compressed => True,
                                      Compressed     => False],
                      Reserved    => [others         => False]],
      Short       => [Not_Present => [Not_Compressed => False,
                                      Compressed     => False],
                      Short       => [Not_Compressed => True,
                                      Compressed     => False],
                      Extended    => [Not_Compressed => True,
                                      Compressed     => False],
                      Reserved    => [others         => False]],
      Extended    => [Not_Present => [Not_Compressed => False,
                                      Compressed     => False],
                      Short       => [Not_Compressed => True,
                                      Compressed     => False],
                      Extended    => [Not_Compressed => False,
                                      Compressed     => False],
                      Reserved    => [others         => False]],
      Reserved    => [others      => [others         => False]]];
   --!format on

   function Is_Source_PAN_ID_Present
     (Frame_Version            : Frame_Version_Field;
      Destination_Address_Mode : Address_Mode_Field;
      Source_Address_Mode      : Address_Mode_Field;
      PAN_ID_Compression       : PAN_ID_Compression_Field) return Boolean
   is (if Frame_Version = IEEE_802_15_4
       then
         Source_PAN_ID_Present_LUT_0b10
           (Destination_Address_Mode, Source_Address_Mode, PAN_ID_Compression)
       else
         PAN_ID_Compression = Not_Compressed
         and then Source_Address_Mode /= Not_Present);

   -----------------------------------
   -- Is_Destination_PAN_ID_Present --
   -----------------------------------

   --  Lookup table for Destination PAN ID presence for frame version 0b10.
   --  Ref. Table 7-2 of IEEE 802.15.4-2024

   Destination_PAN_ID_Present_LUT_0b10 :
     constant array (Address_Mode_Field,       --  Destination address
                     Address_Mode_Field,       --  Source address
                     PAN_ID_Compression_Field) --  PAN ID Compression
     of Boolean :=
   --!format off
   --              |               |              |  Source
   --  Destination |    Source     |  PAN ID      |  PAN ID
   --    Address   |    Address    | Compression  | Present?
     [Not_Present => [Not_Present => [Not_Compressed => False,
                                      Compressed     => True],
                      Short       => [Not_Compressed => False,
                                      Compressed     => False],
                      Extended    => [Not_Compressed => False,
                                      Compressed     => False],
                      Reserved    => [others         => False]],
      Short       => [Not_Present => [Not_Compressed => True,
                                      Compressed     => False],
                      Short       => [Not_Compressed => True,
                                      Compressed     => True],
                      Extended    => [Not_Compressed => True,
                                      Compressed     => True],
                      Reserved    => [others         => False]],
      Extended    => [Not_Present => [Not_Compressed => True,
                                      Compressed     => False],
                      Short       => [Not_Compressed => True,
                                      Compressed     => True],
                      Extended    => [Not_Compressed => True,
                                      Compressed     => False],
                      Reserved    => [others         => False]],
      Reserved    => [others      => [others         => False]]];

   function Is_Destination_PAN_ID_Present
     (Frame_Version            : Frame_Version_Field;
      Destination_Address_Mode : Address_Mode_Field;
      Source_Address_Mode      : Address_Mode_Field;
      PAN_ID_Compression       : PAN_ID_Compression_Field) return Boolean
   is (if Frame_Version = IEEE_802_15_4
       then Destination_PAN_ID_Present_LUT_0b10
         (Destination_Address_Mode, Source_Address_Mode, PAN_ID_Compression)
       else Destination_Address_Mode /= Not_Present);

   -----------------
   -- Conversions --
   -----------------

   function To_Bytes (PAN_ID : PAN_ID_Field) return Byte_Array_2
   is (Byte_Array_2'
         (Bits_8 (Bits_16 (PAN_ID) and 16#FF#),
          Bits_8 (Shift_Right (Bits_16 (PAN_ID), 8) and 16#FF#)));

   function From_Bytes (Bytes : Byte_Array_2) return PAN_ID_Field
   is (PAN_ID_Field (Bytes (1))
       or PAN_ID_Field (Shift_Left (Bits_16 (Bytes (2)), 8)));

   function To_Bytes (Address : Short_Address_Field) return Byte_Array_2
   is (Byte_Array_2'
         (Bits_8 (Bits_16 (Address) and 16#FF#),
          Bits_8 (Shift_Right (Bits_16 (Address), 8) and 16#FF#)));

   function From_Bytes (Bytes : Byte_Array_2) return Short_Address_Field
   is (Short_Address_Field (Bytes (1))
       or Short_Address_Field (Shift_Left (Bits_16 (Bytes (2)), 8)));

   function To_Bytes (FC : Frame_Counter_Field) return Byte_Array_4
   is (Byte_Array_4'
         (Bits_8 (Bits_32 (FC) and 16#FF#),
          Bits_8 (Shift_Right (Bits_32 (FC), 8) and 16#FF#),
          Bits_8 (Shift_Right (Bits_32 (FC), 16) and 16#FF#),
          Bits_8 (Shift_Right (Bits_32 (FC), 24) and 16#FF#)));

   function From_Bytes (Bytes : Byte_Array_4) return Frame_Counter_Field
   is (Frame_Counter_Field
         (Bits_32 (Bytes (1))
          or Bits_32 (Shift_Left (Bits_32 (Bytes (2)), 8))
          or Bits_32 (Shift_Left (Bits_32 (Bytes (3)), 16))
          or Bits_32 (Shift_Left (Bits_32 (Bytes (4)), 24))));

   function To_Bytes (Address : Extended_Address_Field) return Byte_Array_8
   is (Byte_Array_8'
         (Bits_8 (Bits_64 (Address) and 16#FF#),
          Bits_8 (Shift_Right (Bits_64 (Address), 8) and 16#FF#),
          Bits_8 (Shift_Right (Bits_64 (Address), 16) and 16#FF#),
          Bits_8 (Shift_Right (Bits_64 (Address), 24) and 16#FF#),
          Bits_8 (Shift_Right (Bits_64 (Address), 32) and 16#FF#),
          Bits_8 (Shift_Right (Bits_64 (Address), 40) and 16#FF#),
          Bits_8 (Shift_Right (Bits_64 (Address), 48) and 16#FF#),
          Bits_8 (Shift_Right (Bits_64 (Address), 56) and 16#FF#)));

   function From_Bytes (Bytes : Byte_Array_8) return Extended_Address_Field
   is (Extended_Address_Field (Bytes (1))
       or Extended_Address_Field (Shift_Left (Bits_64 (Bytes (2)), 8))
       or Extended_Address_Field (Shift_Left (Bits_64 (Bytes (3)), 16))
       or Extended_Address_Field (Shift_Left (Bits_64 (Bytes (4)), 24))
       or Extended_Address_Field (Shift_Left (Bits_64 (Bytes (5)), 32))
       or Extended_Address_Field (Shift_Left (Bits_64 (Bytes (6)), 40))
       or Extended_Address_Field (Shift_Left (Bits_64 (Bytes (7)), 48))
       or Extended_Address_Field (Shift_Left (Bits_64 (Bytes (8)), 56)));

end AdaBee.MAC.Frames.Headers;
