--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Unchecked_Conversion;
with System;

with AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
with AdaBee.MAC.Frames.Info_Elements.Generic_Lists.Lemmas;
with AdaBee.MAC.Frames.Info_Elements.Nested;

--  @summary
--  Definitions for Payload IEs as defined in IEEE 802.15.4-2024 Section 7.4.3

package AdaBee.MAC.Frames.Info_Elements.Payloads
  with SPARK_Mode, Always_Terminates
is

   -----------------------
   -- Payload IE Format --
   -----------------------

   --  Ref. IEEE 802.15.4-2024 Section 7.4.3.1

   type Group_ID_Field is range 0 .. 15 with Size => 4;
   type Length_Field is range 0 .. 2047 with Size => 11;

   type Header_Field is record
      Length   : Length_Field;
      Group_ID : Group_ID_Field;
      IE_Type  : IE_Type_Field;
   end record
   with
     Size                 => 16,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Header_Field use
     record
       Length   at 0 range 0 .. 10;
       Group_ID at 0 range 11 .. 14;
       IE_Type  at 0 range 15 .. 15;
     end record;

   function Is_Valid_IE_Header (Header : Header_Field) return Boolean
   is (Header.IE_Type = Long);
   --  Checks if a Payload IE header field (first 16 bits) is valid.
   --
   --  For Payload IEs, the Type is always 1 (long format).

   function To_Bytes is new
     Ada.Unchecked_Conversion (Source => Header_Field, Target => Byte_Array_2);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Byte_Array_2_Aligned_2,
        Target => Header_Field);

   function From_Bytes (Bytes : Byte_Array_2) return Header_Field
   is (From_Bytes (Byte_Array_2_Aligned_2 (Bytes)));

   --------------------------
   -- Payload IE Group IDs --
   --------------------------

   --  Ref. Table 7-8 of IEEE 802.15.4-2024

   ESDU_IE                   : constant Group_ID_Field := 16#0#;
   MLME_IE                   : constant Group_ID_Field := 16#1#;
   Vendor_Specific_Nested_IE : constant Group_ID_Field := 16#2#;
   Payload_Termination_IE    : constant Group_ID_Field := 16#F#;

   --------------
   -- IE Lists --
   --------------

   function Content_Length (Header : Header_Field) return Length_Field
   is (Header.Length);

   function Is_Termination_IE (Header : Header_Field) return Boolean
   is (Header.Group_ID = Payload_Termination_IE);

   package Lists is new
     AdaBee.MAC.Frames.Info_Elements.Generic_Lists
       (Header_Field      => Header_Field,
        Length_Type       => Length_Field,
        From_Bytes        => From_Bytes,
        Content_Length    => Content_Length,
        Is_Termination_IE => Is_Termination_IE);

   package Lemmas is new Lists.Lemmas;

   ---------------------
   -- Nested IE Lists --
   ---------------------

   function Nested_IE_Lists_Valid
     (Buffer : Byte_Array; X : Positive) return Boolean
   is (for all I of Lists.Formal_Model.Reachable_Set (Buffer, X) =>
         (declare
            Header : constant Header_Field := Lists.IE_Header (Buffer, I);
          begin
            (if Header.Group_ID = MLME_IE and then Header.Length > 0
             then
               Nested.Lists.Formal_Model.Valid_IE_List
                 (Payloads.Lists.Formal_Model.IE_Content (Buffer, I)))))
   with Ghost, Pre => Payloads.Lists.Formal_Model.Valid_IE_List (Buffer, X);
   --  Returns True if and only if all MLME IEs in the payload IE list that
   --  have a non-empty content field contain a valid nested IE list.

   procedure Validate_Payload_And_Nested_IE_Lists
     (Buffer  : Byte_Array;
      Length  : out Natural;
      Result  : out Status_Code;
      Last_IE : out Positive)
   with
     Global => null,
     Post   =>
       Result in Success | Malformed_Frame

       --  Result is set to Success if and only if the IE list in Buffer is a
       --  valid payload IE list, and any MLME IEs with a non-empty content
       --  field contain a valid nested IE list.
       and then
         (Result = Success)
         = (Lists.Formal_Model.Valid_IE_List (Buffer)
            and then Nested_IE_Lists_Valid (Buffer, Buffer'First))

       and then
         (if Result = Success
          then
            --  Length is set to the length of the IE list according to the
            --  formal spec.
            Length in IE_Header_Length .. Buffer'Length
            and then
              Length = Lists.Formal_Model.IE_List_Length (Buffer, Buffer'First)

            --  Last_IE denotes the position of the last IE in the list
            and then
              Last_IE
              = Lists.Formal_Model.Last_IE_Position (Buffer, Buffer'First)

            --  If the IE list does not end at the end of the buffer, then it
            --  is guaranteed to be terminated by a termination IE.
            and then
              (if Length < Buffer'Length
               then Lists.Formal_Model.Is_Terminated (Buffer)));
   --  Validate the payload IE list stored in Buffer. If the IE list contains
   --  any nested IE lists (MLME IE elements), then also validate those nested
   --  IE lists.

end AdaBee.MAC.Frames.Info_Elements.Payloads;
