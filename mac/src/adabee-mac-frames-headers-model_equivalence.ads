--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Headers.Decoder_Model;
with AdaBee.MAC.Frames.Headers.Encoder_Model;

--  @summary
--  Proves equivalence between the Encoder_Model and Decoder_Model

package AdaBee.MAC.Frames.Headers.Model_Equivalence
  with Ghost, Pure, SPARK_Mode, Always_Terminates
is

   procedure Lemma_Frame_Control_Length_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  => Encoder_Model.Frame_Control_Equal (MHR, Frame),
     Post =>
       Encoder_Model.Get_Frame_Control_Length (MHR)
       = Decoder_Model.Get_Frame_Control_Length (Frame);
   --  Assuming a Frame buffer's Frame Control field is equal to the contents
   --  of a MAC_Header record, prove that the length of the frame control field
   --  is the same for both models.

   procedure Lemma_PAN_ID_Presence_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  => Encoder_Model.Frame_Control_Equal (MHR, Frame),
     Post =>
       (case MHR.Frame_Type is
          when Multipurpose                      =>

            --  The destination PAN ID is present in MHR if and only if the
            --  "PAN ID present" field in the frame control field is set to
            --  one.
            MHR
              .Destination_PAN_ID
              .Present
            = (Decoder_Model.Get_MP_S_FC (Frame).Long_Frame_Control = Long
               and then
                 Decoder_Model.Get_MP_L_FC (Frame).PAN_ID_Present = Present)

            --  Multipurpose frames never have a source PAN ID field.
            and then not MHR.Source_PAN_ID.Present,

          when Beacon | Data | Ack | MAC_Command =>
            --  The destination PAN ID is present in MHR if and only if it is
            --  present in Frame according to the frame version
            MHR
              .Destination_PAN_ID
              .Present
            = PAN_ID_Model.Is_Destination_PAN_ID_Present
                (Frame_Version            =>
                   Decoder_Model.Get_FC (Frame).Frame_Version,
                 Destination_Address_Mode =>
                   Decoder_Model.Get_FC (Frame).Dest_Address_Mode,
                 Source_Address_Mode      =>
                   Decoder_Model.Get_FC (Frame).Src_Address_Mode,
                 PAN_ID_Compression       =>
                   Decoder_Model.Get_FC (Frame).PAN_ID_Compression)

            --  Then source PAN ID field is present in the Frame buffer if
            --  and only if it is both present in MHR and not equal to the
            --  destination PAN ID. If it is present in MHR but the same as
            --  destination PAN ID, then it is omitted in the frame due to
            --  PAN ID compression.
            --
            --  Ref. IEEE 802.15.4-2024 Section 7.2.2.6.
            and then
              Compressed_Source_PAN_ID
                (Destination_PAN_ID => MHR.Destination_PAN_ID,
                 Source_PAN_ID      => MHR.Source_PAN_ID)
                .Present
              = PAN_ID_Model.Is_Source_PAN_ID_Present
                  (Frame_Version            =>
                     Decoder_Model.Get_FC (Frame).Frame_Version,
                   Destination_Address_Mode =>
                     Decoder_Model.Get_FC (Frame).Dest_Address_Mode,
                   Source_Address_Mode      =>
                     Decoder_Model.Get_FC (Frame).Src_Address_Mode,
                   PAN_ID_Compression       =>
                     Decoder_Model.Get_FC (Frame).PAN_ID_Compression));
   --  Assuming a Frame buffer's Frame Control field is equal to the contents
   --  of a MAC_Header record, prove that the presence of the source and
   --  destination PAN ID fields is the same between the two models.

   procedure Lemma_Addressing_Field_Positions_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  => Encoder_Model.Frame_Control_Equal (MHR, Frame),
     Post =>
       Encoder_Model.Get_Frame_Control_Length (MHR)
       = Decoder_Model.Get_Frame_Control_Length (Frame)
       and then
         Encoder_Model.Get_Sequence_Number_Offset (MHR)
         = Decoder_Model.Get_Sequence_Number_Offset (Frame)
       and then
         Encoder_Model.Get_Sequence_Number_Length (MHR)
         = Decoder_Model.Get_Sequence_Number_Length (Frame)
       and then
         Encoder_Model.Get_Destination_PAN_ID_Offset (MHR)
         = Decoder_Model.Get_Destination_PAN_ID_Offset (Frame)
       and then
         Encoder_Model.Get_Destination_PAN_ID_Length (MHR)
         = Decoder_Model.Get_Destination_PAN_ID_Length (Frame)
       and then
         Encoder_Model.Get_Destination_Address_Offset (MHR)
         = Decoder_Model.Get_Destination_Address_Offset (Frame)
       and then
         Encoder_Model.Get_Destination_Address_Length (MHR)
         = Decoder_Model.Get_Destination_Address_Length (Frame)
       and then
         Encoder_Model.Get_Source_PAN_ID_Offset (MHR)
         = Decoder_Model.Get_Source_PAN_ID_Offset (Frame)
       and then
         Encoder_Model.Get_Source_PAN_ID_Length (MHR)
         = Decoder_Model.Get_Source_PAN_ID_Length (Frame)
       and then
         Encoder_Model.Get_Source_Address_Offset (MHR)
         = Decoder_Model.Get_Source_Address_Offset (Frame)
       and then
         Encoder_Model.Get_Source_Address_Length (MHR)
         = Decoder_Model.Get_Source_Address_Length (Frame);
   --  Assuming the Frame Control field is equal in MHR and Frame, prove that
   --  the position and length of each field (up to the end of the end of the
   --  addressing fields) is the same between the two models.

   procedure Lemma_Aux_Security_Header_Field_Positions_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  =>
       Encoder_Model.Frame_Control_Equal (MHR, Frame)
       and then Frame'Length > Encoder_Model.Get_Security_Control_Offset (MHR)
       and then Encoder_Model.Security_Control_Equal (MHR, Frame),
     Post =>
       Encoder_Model.Get_Security_Control_Offset (MHR)
       = Decoder_Model.Get_Security_Control_Offset (Frame)
       and then
         Encoder_Model.Get_Security_Control_Length (MHR)
         = Decoder_Model.Get_Security_Control_Length (Frame)
       and then
         Encoder_Model.Get_Frame_Counter_Offset (MHR)
         = Decoder_Model.Get_Frame_Counter_Offset (Frame)
       and then
         Encoder_Model.Get_Frame_Counter_Length (MHR)
         = Decoder_Model.Get_Frame_Counter_Length (Frame)
       and then
         Encoder_Model.Get_Key_ID_Offset (MHR)
         = Decoder_Model.Get_Key_ID_Offset (Frame)
       and then
         Encoder_Model.Get_Key_ID_Length (MHR)
         = Decoder_Model.Get_Key_ID_Length (Frame);

   procedure Lemma_Get_Sequence_Number_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  =>
       Encoder_Model.Frame_Control_Equal (MHR, Frame)
       and then
         Frame'Length
         >= Encoder_Model.Get_Sequence_Number_Offset (MHR)
            + Encoder_Model.Get_Sequence_Number_Length (MHR),
     Post =>
       Encoder_Model.Sequence_Number_Equal (MHR, Frame)
       = (MHR.Sequence_Number = Decoder_Model.Get_Sequence_Number (Frame));
   --  Assuming the Frame Control field is equal in MHR and Frame, prove
   --  that Encoder_Model.Sequence_Number_Equal is equivalent to comparing the
   --  MHR's Sequence_Number against the value returned by
   --  Decoder_Model.Get_Sequence_Number.

   procedure Lemma_Get_Destination_PAN_ID_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  =>
       Encoder_Model.Frame_Control_Equal (MHR, Frame)
       and then
         Frame'Length
         >= Encoder_Model.Get_Destination_PAN_ID_Offset (MHR)
            + Encoder_Model.Get_Destination_PAN_ID_Length (MHR),
     Post =>
       Encoder_Model.Destination_PAN_ID_Equal (MHR, Frame)
       = (MHR.Destination_PAN_ID
          = Decoder_Model.Get_Destination_PAN_ID (Frame));
   --  Assuming the Frame Control field is equal in MHR and Frame, prove
   --  that Encoder_Model.Destination_PAN_ID_Equal is equivalent to comparing
   --  the MHR's Destination_PAN_ID against the value returned by
   --  Decoder_Model.Get_Destination_PAN_ID.

   procedure Lemma_Get_Destination_Address_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  =>
       Encoder_Model.Frame_Control_Equal (MHR, Frame)
       and then
         Frame'Length
         >= Encoder_Model.Get_Destination_Address_Offset (MHR)
            + Encoder_Model.Get_Destination_Address_Length (MHR),
     Post =>
       Encoder_Model.Destination_Address_Equal (MHR, Frame)
       = (MHR.Destination_Address
          = Decoder_Model.Get_Destination_Address (Frame));
   --  Assuming the Frame Control field is equal in MHR and Frame, prove
   --  that Encoder_Model.Destination_Address_Equal is equivalent to comparing
   --  the MHR's Destination_Address against the value returned by
   --  Decoder_Model.Get_Destination_Address.

   procedure Lemma_Get_Source_PAN_ID_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  =>
       Encoder_Model.Frame_Control_Equal (MHR, Frame)
       and then
         Frame'Length
         >= Encoder_Model.Get_Source_PAN_ID_Offset (MHR)
            + Encoder_Model.Get_Source_PAN_ID_Length (MHR),
     Post =>
       (declare
          CSPID : constant Variant_PAN_ID :=
            Compressed_Source_PAN_ID
              (Destination_PAN_ID => MHR.Destination_PAN_ID,
               Source_PAN_ID      => MHR.Source_PAN_ID);
        begin
          CSPID.Present = Decoder_Model.Is_Source_PAN_ID_Present (Frame)

          and then
            --  If the Frame contains a Source PAN ID field, then calling
            --  Encoder_Model.Source_PAN_ID_Equal is equivalent to checking
            --  the compressed source PAN ID from MHR against the value
            --  returned by Decoder_Model.Get_Source_PAN_ID.
            (if Decoder_Model.Is_Source_PAN_ID_Present (Frame)
             then
               Encoder_Model.Source_PAN_ID_Equal (MHR, Frame)
               = (CSPID = Decoder_Model.Get_Source_PAN_ID (Frame))));
   --  Assuming a Frame buffer's Frame Control field is equal to the contents
   --  of a MAC_Header record and that Source_PAN_ID_Equal is True, prove
   --  that Get_Decompressed_Source_PAN_ID returns a value equivalent to
   --  MHR.Source_PAN_ID.

   procedure Lemma_Get_Source_Address_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  =>
       Encoder_Model.Frame_Control_Equal (MHR, Frame)
       and then
         Frame'Length
         >= Encoder_Model.Get_Source_Address_Offset (MHR)
            + Encoder_Model.Get_Source_Address_Length (MHR),
     Post =>
       Encoder_Model.Source_Address_Equal (MHR, Frame)
       = (MHR.Source_Address = Decoder_Model.Get_Source_Address (Frame));
   --  Assuming the Frame Control field is equal in MHR and Frame, prove
   --  that Encoder_Model.Source_Address_Equal is equivalent to comparing the
   --  MHR's Source_Address against the value returned by
   --  Decoder_Model.Get_Source_Address.

   procedure Lemma_Get_Aux_Security_Header_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array)
   with
     Pre  =>
       Encoder_Model.Frame_Control_Equal (MHR, Frame)
       and then Frame'Length > Encoder_Model.Get_Security_Control_Offset (MHR)
       and then Encoder_Model.Security_Control_Equal (MHR, Frame)
       and then
         Frame'Length
         >= Encoder_Model.Get_Aux_Security_Header_Offset (MHR)
            + Encoder_Model.Get_Aux_Security_Header_Length (MHR),
     Post =>
       Encoder_Model.Aux_Security_Header_Equal (MHR, Frame)
       = (MHR.Aux_Security_Header
          = Decoder_Model.Get_Aux_Security_Header (Frame));
   --  Assuming the Frame Control and Security Control fields are equal in MHR
   --  and Frame, prove that Encoder_Model.Aux_Security_Header_Equal is
   --  equivalent to comparing the MHR's Aux_Security_Header against the value
   --  returned by Decoder_Model.Get_Aux_Security_Header.

end AdaBee.MAC.Frames.Headers.Model_Equivalence;
