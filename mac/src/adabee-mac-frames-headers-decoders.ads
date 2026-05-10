--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Decoders for IEEE 802.15.4 MAC headers
package AdaBee.MAC.Frames.Headers.Decoders
  with Pure, SPARK_Mode
is

   procedure Decode_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   with
     Global => null,
     Pre    => Buffer'Length > 0,
     Post   =>
       (Length <= Buffer'Length
        and then Length <= Max_MHR_Length
        and then
          (if Result = Success
           then
             (MHR.Frame_Version /= Reserved
              and then MHR.Destination_Address.Mode /= Reserved
              and then MHR.Source_Address.Mode /= Reserved)));
   --  Decode a MAC header from a byte array buffer.
   --
   --  @param Buffer The buffer containing the MAC header to decode.
   --  @param MHR The decoded header fields are stored here.

end AdaBee.MAC.Frames.Headers.Decoders;
