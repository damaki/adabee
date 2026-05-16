--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Headers.MHR_Model;
with AdaBee.MAC.Frames.Info_Elements.Headers;

--  @summary
--  Utilities for decoding the MAC header (MHR) part of the frame.
--
--  @description
--  The MHR can be partially decoded to quickly decode the address fields and
--  auxiliary security headers, without spending time also decoding the header
--  information elements (IEs). This is useful in some cases, such as quickly
--  determining the source address to send an acknowledgement.

package AdaBee.MAC.Frames.Headers.Decoders
  with Pure, SPARK_Mode, Always_Terminates
is

   procedure Decode_MHR_Partial
     (Buffer : Byte_Array;
      MHR    : out MAC_Header;
      Length : out Natural;
      Result : out Status_Code)
   with
     Global => null,
     Pre    => Buffer'Length > 0,
     Post   =>
       Length <= Buffer'Length
       and then Length <= Max_MHR_Length
       and then
         (Result = Success) = MHR_Model.Is_MHR_Valid_Excluding_IEs (Buffer)
       and then
         (if Result = Success
          then
            Length = MHR_Model.MHR_Length_Excluding_IEs (Buffer)
            and then MHR_Model.Is_Valid_Decoding (MHR, Buffer));
   --  Decode the first part of the MAC Header, up to (and including) the
   --  auxiliary security header.
   --
   --  This partially decodes the MHR; it decodes all fields of the MHR except
   --  for the header IEs.
   --
   --  @param Buffer The MAC frame containing the MAC header to decode.
   --    The FCS part must be excluded from this buffer.
   --  @param MHR The decoded header fields are written here.
   --  @param Length The length of the MHR up to (and including) the auxiliary
   --    security header, but excluding the header IEs.
   --  @param Result Success if the MAC header was successfully decoded, or
   --    any other value to indicate an error.

   procedure Decode_MHR_Header_IEs
     (Buffer            : Byte_Array;
      Header_IE_Last    : out Natural;
      MAC_Payload_First : out Integer;
      MAC_Payload_Last  : out Integer;
      Has_Payload_IEs   : out Boolean;
      Result            : out Status_Code)
   with
     Global => null,
     Post   =>
       (if Result = Success
        then
          Header_IE_Last in Buffer'Range
          and then
            (if Header_IE_Last < Buffer'Last
             then
               MAC_Payload_First = Header_IE_Last + 1
               and then MAC_Payload_Last = Buffer'Last
             else MAC_Payload_First > MAC_Payload_Last)

          and then
            Info_Elements.Headers.Lists.IE_Model.Valid_IE_List
              (Buffer (Buffer'First .. Header_IE_Last)))

       and then
         (if MAC_Payload_First <= MAC_Payload_Last
          then
            MAC_Payload_First in Buffer'Range
            and then MAC_Payload_Last in Buffer'Range)

       and then
         (if Has_Payload_IEs then MAC_Payload_First <= MAC_Payload_Last);
   --  Decode the header IE part of the MAC header (MHR).
   --
   --  This procedure determines the length of the header IEs and performs a
   --  quick validity check to ensure that the header IEs fit in the bounds of
   --  the Buffer.
   --
   --  This function must be called only if the Frame Control field of the MHR
   --  indicates that an IE list is present.
   --
   --  This also determines the location of the MAC payload, which starts
   --  immediately after the header IEs.
   --
   --  @param Buffer Buffer that contains the header IEs and MAC payload.
   --    The header IEs are expected to begin at the start of this buffer.
   --  @param MHR The MAC header data that was previously decoded.
   --  @param Header_IE_Last The index in Buffer of the last byte of the header
   --    IE list. This is set to a value outside Buffer'Range if the header IE
   --    list is not present.
   --  @param MAC_Payload_First The index in Buffer of the first byte of the
   --    MAC payload.
   --  @param MAC_Payload_Last The index in Buffer of the last byte of the MAC
   --    payload.
   --  @param Has_Payload_IEs This is set to true if the header IE list
   --    indicates that the MAC payload contains payload IEs. Specifically,
   --    this is set to True when the header IEs is terminated by a
   --    Header Termination 1 IE (see IEEE 802.15.4-2024 Table 7-6).
   --  @param Result Indicates whether the header IEs were decoded
   --    successfully. This is set to Success upon success, or any other value
   --    if the frame is malformed.

   procedure Decode_MHR
     (Buffer            : Byte_Array;
      MHR               : out MAC_Header;
      Header_IE_First   : out Positive;
      Header_IE_Last    : out Natural;
      MAC_Payload_First : out Integer;
      MAC_Payload_Last  : out Integer;
      Has_Payload_IEs   : out Boolean;
      Result            : out Status_Code)
   with
     Global => null,
     Pre    => Buffer'Length > 0,
     Post   =>
       (if MHR.IE_Present = Not_Present
        then Header_IE_First > Header_IE_Last and then not Has_Payload_IEs)

       and then
         (if MHR.IE_Present = Present and then Result = Success
          then
            Header_IE_First in Buffer'Range
            and then Header_IE_Last in Buffer'Range
            and then
              (if Header_IE_Last < Buffer'Last
               then
                 MAC_Payload_First = Header_IE_Last + 1
                 and then MAC_Payload_Last = Buffer'Last
               else MAC_Payload_First > MAC_Payload_Last)

            and then
              Info_Elements.Headers.Lists.IE_Model.Valid_IE_List
                (Buffer (Header_IE_First .. Header_IE_Last)))

       and then
         (if MAC_Payload_First <= MAC_Payload_Last
          then
            MAC_Payload_First in Buffer'Range
            and then MAC_Payload_Last in Buffer'Range)

       and then
         (if Has_Payload_IEs then MAC_Payload_First <= MAC_Payload_Last);
   --  Decode the MAC header (MHR) part of a frame.
   --
   --  This decodes all fields of the MHR, from the Frame Control field up to
   --  and including the header IEs (if present).
   --
   --  This also determines the position of the MAC payload part of the frame.
   --
   --  @param Buffer Buffer containing the MAC frame to decode (excluding the
   --    FCS field).
   --  @param MHR The MAC header data are written here.
   --  @param Header_IE_First The index in Buffer of the first byte of the
   --    header IE list. This is valid only if MHR.IE_Present = Present
   --  @param Header_IE_Last The index in Buffer of the last byte of the header
   --    IE list. This is valid only if MHR.IE_Present = Present
   --  @param MAC_Payload_First The index in Buffer of the first byte of the
   --    MAC payload.
   --  @param MAC_Payload_Last The index in Buffer of the last byte of the MAC
   --    payload. If the frame does not contain a payload, then this is set to
   --    a value less than MAC_Payload_First.
   --  @param Has_Payload_IEs This is set to true if the header IE list
   --    indicates that the MAC payload contains payload IEs. Specifically,
   --    this is set to True when the header IEs is terminated by a
   --    Header Termination 1 IE (see IEEE 802.15.4-2024 Table 7-6).
   --  @param Result Indicates whether the header IEs were decoded
   --    successfully. This is set to Success upon success, or any other value
   --    if the frame is malformed.

end AdaBee.MAC.Frames.Headers.Decoders;
