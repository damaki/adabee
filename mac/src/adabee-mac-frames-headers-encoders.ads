--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Encoders for IEEE 802.15.4 MAC headers

with AdaBee.MAC.Frames.Headers.MHR_Model;

package AdaBee.MAC.Frames.Headers.Encoders
  with Pure, SPARK_Mode, Always_Terminates
is

   procedure Encode_MAC_Header
     (MHR : Valid_MAC_Header; Buffer : out Byte_Array; Length : out Natural)
   with
     Relaxed_Initialization => Buffer,
     Global                 => null,
     Depends                => ((Buffer, Length) => (Buffer, MHR)),
     Pre                    => Buffer'Length >= Max_MHR_Length,
     Post                   =>
       (Length <= Buffer'Length
        and then
          Buffer (Buffer'First .. Buffer'First + (Length - 1))'Initialized
        and then Length = MHR_Model.MHR_Length_Excluding_IEs (MHR)
        and then
          MHR_Model.MHR_Equal
            (MHR, Buffer (Buffer'First .. Buffer'First + (Length - 1))));
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
   --  @param Length The length (in bytes) of the MAC header that was written
   --    to Buffer.

end AdaBee.MAC.Frames.Headers.Encoders;
