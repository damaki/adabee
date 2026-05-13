--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Decoders for IEEE 802.15.4 MAC headers

package AdaBee.MAC.Frames.Headers.Decoders
  with Pure, SPARK_Mode, Always_Terminates
is

   procedure Decode_MAC_Header
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   with
     Global => null,
     Pre    => Buffer'Length > 0,
     Post   => Length <= Buffer'Length and then Length <= Max_MHR_Length;
   --  Decode a MAC header from a byte array buffer (excluding the header IE
   --  list).
   --
   --  @param Buffer The buffer containing the MAC header to decode.
   --  @param MHR The decoded header fields are stored here.
   --  @param Length The length of the MHR, excluding the header IE list.
   --    This length includes the frame control, sequence number, addressing
   --    fields, and auxiliary security header parts of the MAC header.
   --  @param Result Success if the MAC header was successfully decoded, or
   --    any other value to indicate an error.

end AdaBee.MAC.Frames.Headers.Decoders;
