--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Encoders for IEEE 802.15.4 MAC headers
package AdaBee.MAC.Frames.Headers.Encoders
  with Pure, SPARK_Mode, Always_Terminates
is

   procedure Encode_MAC_Header
     (MHR : MAC_Header; Buffer : in out Byte_Array; Length : out Natural)
   with
     Global  => null,
     Depends => (Buffer => (Buffer, MHR), Length => MHR),
     Pre     =>
       --  The buffer must be large enough to hold the biggest possible
       --  MAC Header.
       Buffer'Length >= Max_MHR_Length

       --  The MHR fields must be a valid combination according to the rules
       --  in IEEE 802.15.4-2024 (particularly section 7.2.2.6).
       and then
         Formal_Rules.Is_Valid_Configuration
           (Frame_Version              => MHR.Frame_Version,
            Destination_Address_Mode   => MHR.Destination_Address.Mode,
            Source_Address_Mode        => MHR.Source_Address.Mode,
            Destination_PAN_ID_Present => MHR.Destination_PAN_ID.Present,
            Source_PAN_ID_Present      => MHR.Source_PAN_ID.Present)

       --  The frame type must be one that is supported by this implementation
       and then MHR.Frame_Type not in Unsupported_Frame_Types

       --  Multipurpose frames do not have a source PAN ID field
       and then
         (if MHR.Frame_Type = Multipurpose then not MHR.Source_PAN_ID.Present),
     Post    =>
       (Length <= Buffer'Length
        and then (Length in Min_MHR_Length .. Max_MHR_Length));
   --  Encode a MAC header into a byte array.
   --
   --  Note that this procedure will take care of handling PAN ID compression
   --  as required by the rules in IEEE 802.15.4-2024 Section 7.2.2.6.
   --  In particular, if both the source and destination PAN IDs are present
   --  in the MHR and they are the same PAN ID, then PAN ID compression will be
   --  used and the source PAN ID will be omitted from the frame.
   --
   --  @param MHR The MAC header data to encode into the frame Buffer.
   --  @param Buffer The buffer to write the encoded MAC header data.
   --  @param Length The number of bytes that were written to Buffer.

end AdaBee.MAC.Frames.Headers.Encoders;
