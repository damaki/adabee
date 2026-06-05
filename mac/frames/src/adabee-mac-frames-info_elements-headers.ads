--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Unchecked_Conversion;
with System;

with AdaBee.MAC.Frames.Beacons;
with AdaBee.MAC.Frames.Info_Elements.Generic_Lists;

--  @summary
--  Definitions for Header IEs as defined in IEEE 802.15.4-2024 Section 7.4.2

package AdaBee.MAC.Frames.Info_Elements.Headers
  with Pure, SPARK_Mode, Always_Terminates
is

   ----------------------
   -- Header IE Format --
   ----------------------

   --  Ref. IEEE 802.15.4-2024 Section 7.4.2.1

   type Element_ID_Field is range 0 .. 255 with Size => 8;
   type Length_Field is range 0 .. 127 with Size => 7;

   type Header_Field is record
      Length     : Length_Field;
      Element_ID : Element_ID_Field;
      IE_Type    : IE_Type_Field;
   end record
   with
     Size                 => 16,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Header_Field use
     record
       Length     at 0 range 0 .. 6;
       Element_ID at 0 range 7 .. 14;
       IE_Type    at 0 range 15 .. 15;
     end record;

   function Is_Valid_IE_Header (Header : Header_Field) return Boolean
   is (Header.IE_Type = Short);
   --  Checks if a Header IE header field (first 16 bits) is valid.
   --
   --  For Header IEs, the Type is always 0 (short format).

   function To_Bytes is new
     Ada.Unchecked_Conversion (Source => Header_Field, Target => Byte_Array_2);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Byte_Array_2_Aligned_2,
        Target => Header_Field);

   function From_Bytes (Bytes : Byte_Array_2) return Header_Field
   is (From_Bytes (Byte_Array_2_Aligned_2 (Bytes)));

   ---------------------------
   -- Header IE Element IDs --
   ---------------------------

   --  Ref. Table 7-7 of IEEE 802.15.4-2024

   Vendor_Specific_IE              : constant Element_ID_Field := 16#00#;
   CSL_IE                          : constant Element_ID_Field := 16#1A#;
   RIT_IE                          : constant Element_ID_Field := 16#1B#;
   DSME_PAN_Descriptor_IE          : constant Element_ID_Field := 16#1C#;
   Rendezvous_Time_IE              : constant Element_ID_Field := 16#1D#;
   Time_Correction_IE              : constant Element_ID_Field := 16#1E#;
   Extended_DSME_PAN_Descriptor_IE : constant Element_ID_Field := 16#21#;
   FSCD_IE                         : constant Element_ID_Field := 16#22#;
   Simplified_Superframe_Spec_IE   : constant Element_ID_Field := 16#23#;
   Simplified_GTS_Spec_IE          : constant Element_ID_Field := 16#24#;
   LECIM_Capabilities_IE           : constant Element_ID_Field := 16#25#;
   TRLE_Descriptor_IE              : constant Element_ID_Field := 16#26#;
   RCC_Capabilities_IE             : constant Element_ID_Field := 16#27#;
   RCCN_Descriptor_IE              : constant Element_ID_Field := 16#28#;
   Global_Time_IE                  : constant Element_ID_Field := 16#29#;
   DA_IE                           : constant Element_ID_Field := 16#2B#;
   Header_Termination_1_IE         : constant Element_ID_Field := 16#7E#;
   Header_Termination_2_IE         : constant Element_ID_Field := 16#7F#;

   --------------
   -- IE Lists --
   --------------

   function Content_Length (Header : Header_Field) return Length_Field
   is (Header.Length);

   function Is_Termination_IE (Header : Header_Field) return Boolean
   is (Header.Element_ID in Header_Termination_1_IE | Header_Termination_2_IE);

   package Lists is new
     AdaBee.MAC.Frames.Info_Elements.Generic_Lists
       (Header_Field      => Header_Field,
        Length_Type       => Length_Field,
        From_Bytes        => From_Bytes,
        Content_Length    => Content_Length,
        Is_Termination_IE => Is_Termination_IE);

   --------------------------------------------
   -- Simplified Superframe Specification IE --
   --------------------------------------------

   --  Ref. Section 10.2.8.1 of IEEE 802.15.4-2024

   type CFP_Specification_Field is record
      Nb_GTS         : Slot_Number;
      First_CFP_Slot : Slot_Number;
      Last_CFP_Slot  : Slot_Number;
      GTS_Permit     : Boolean;
      Reserved       : Bits_3;
   end record
   with
     Size                 => 16,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for CFP_Specification_Field use
     record
       Nb_GTS         at 0 range 0 .. 3;
       First_CFP_Slot at 0 range 4 .. 7;
       Last_CFP_Slot  at 0 range 8 .. 11;
       GTS_Permit     at 0 range 12 .. 12;
       Reserved       at 0 range 13 .. 15;
     end record;

   type Simplified_Superframe_Specification_Field is record
      Timestamp       : Bits_16;
      Superframe_Spec : Beacons.Superframe_Specification_Field;
      CFP_Spec        : CFP_Specification_Field;
   end record
   with
     Size                 => 48,
     Alignment            => 2,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Simplified_Superframe_Specification_Field use
     record
       Timestamp       at 0 range 0 .. 15;
       Superframe_Spec at 2 range 0 .. 15;
       CFP_Spec        at 4 range 0 .. 15;
     end record;

   Simplified_Superframe_Spec_Length : constant Natural :=
     Simplified_Superframe_Specification_Field'Size / 8;

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Simplified_Superframe_Specification_Field,
        Target => Byte_Array_6);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Byte_Array_6_Aligned_2,
        Target => Simplified_Superframe_Specification_Field);

end AdaBee.MAC.Frames.Info_Elements.Headers;
