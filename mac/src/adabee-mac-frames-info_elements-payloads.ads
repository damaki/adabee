--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Unchecked_Conversion;
with System;

--  @summary
--  Definitions for Payload IEs as defined in IEEE 802.15.4-2024 Section 7.4.3
package AdaBee.MAC.Frames.Info_Elements.Payloads
  with Pure, SPARK_Mode, Always_Terminates
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

end AdaBee.MAC.Frames.Info_Elements.Payloads;
