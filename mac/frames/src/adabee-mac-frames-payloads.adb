--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Payloads
  with SPARK_Mode
is

   use all type Headers.Security_Enabled_Field;
   use all type Headers.Security_Level_Field;

   subtype MIC_Length_Number is Bits_8 range 0 .. 16;

   MIC_Length_LUT :
     constant array (Headers.Security_Level_Field) of MIC_Length_Number :=
       [None        => 0,
        Reserved    => 0,
        MIC_32      => 4,
        MIC_64      => 8,
        MIC_128     => 16,
        ENC_MIC_32  => 4,
        ENC_MIC_64  => 8,
        ENC_MIC_128 => 16];
   --  Lookup table for the MIC length in bytes

   -------------------------------
   -- Decode_MAC_Payload_Layout --
   -------------------------------

   procedure Decode_MAC_Payload_Layout
     (Frame               : Byte_Array;
      MHR                 : Headers.Valid_MAC_Header;
      Layout              : in out Layouts.Frame_Layout;
      Payload_IEs_Present : Boolean;
      Status              : out Status_Code)
   is
      MIC_Length                  : Natural;
      MAC_Payload_Last_Before_MIC : Integer;
      IE_List_Length              : Natural;
      Unused                      : Positive;
   begin
      --  If the frame is secured then the payload IE list before at the MIC,
      --  even if it does not contain a termination IE. Otherwise, if the MIC
      --  is not present, then the payload IE list may go up to the end of the
      --  MAC Payload field.

      if MHR.Aux_Security_Header.Security_Enabled = Enabled then
         MIC_Length :=
           Natural (MIC_Length_LUT (MHR.Aux_Security_Header.Security_Level));
      else
         MIC_Length := 0;
      end if;

      MAC_Payload_Last_Before_MIC := Layout.MAC_Payload_Last - MIC_Length;

      pragma
        Assert (MIC_Length = Headers.Decoder_Model.Get_MIC_Length (Frame));

      if Layouts.MAC_Payload_Length (Layout) < MIC_Length then
         Status := Malformed_Frame;

      elsif Payload_IEs_Present then

         Info_Elements.Payloads.Validate_Payload_And_Nested_IE_Lists
           (Buffer  =>
              Frame (Layout.MAC_Payload_First .. MAC_Payload_Last_Before_MIC),
            Length  => IE_List_Length,
            Result  => Status,
            Last_IE => Unused);

         pragma
           Assert
             (Layout.MAC_Payload_First
              = Frame'First
                + Headers.Decoder_Model.Get_Payload_IE_Offset (Frame));

         pragma
           Assert
             ((MAC_Payload_Last_Before_MIC - Layout.MAC_Payload_First) + 1
              = Headers.Decoder_Model.Get_MAC_Payload_Length (Frame)
                - Headers.Decoder_Model.Get_MIC_Length (Frame));

         if Status = Success then

            --  Calculate the position of the last byte of the payload IE list

            Layout.Payload_IEs_Last :=
              Layout.MAC_Payload_First + (IE_List_Length - 1);

            --  Determine first/last positions of the Frame Payload field

            if Layout.Payload_IEs_Last < MAC_Payload_Last_Before_MIC then
               Layout.Frame_Payload_First := Layout.Payload_IEs_Last + 1;
               Layout.Frame_Payload_Last := MAC_Payload_Last_Before_MIC;
            else
               Layout.Frame_Payload_First := 1;
               Layout.Frame_Payload_Last := 0;
            end if;

            --  Prove that IE list properties are preserved for the slice of
            --  the Frame buffer that is narrowed to exactly the IE list
            --  length.

            Info_Elements.Payloads.Lemmas.Lemma_Valid_IE_List_Preserved
              (B1 =>
                 Frame
                   (Layout.MAC_Payload_First .. MAC_Payload_Last_Before_MIC),
               B2 =>
                 Frame (Layout.MAC_Payload_First .. Layout.Payload_IEs_Last),
               X1 => Layout.MAC_Payload_First,
               X2 => Layout.MAC_Payload_First);

            Info_Elements.Payloads.Lemmas.Lemma_Reachable_Set_Preserved
              (B1 =>
                 Frame
                   (Layout.MAC_Payload_First .. MAC_Payload_Last_Before_MIC),
               B2 =>
                 Frame (Layout.MAC_Payload_First .. Layout.Payload_IEs_Last),
               X  => Layout.MAC_Payload_First);
         end if;

      else
         Layout.Payload_IEs_Last := 0;
         Status := Success;

         --  Determine first/last positions of the Frame Payload field

         Layout.Frame_Payload_First := Layout.MAC_Payload_First;
         Layout.Frame_Payload_Last := MAC_Payload_Last_Before_MIC;
      end if;
   end Decode_MAC_Payload_Layout;

end AdaBee.MAC.Frames.Payloads;
