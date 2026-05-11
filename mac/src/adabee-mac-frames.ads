--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.PHY_Constants;

--  @summary
--  Root package for IEEE 802.15.4 MAC frame definitions and encoders/decoders.
package AdaBee.MAC.Frames
  with Pure, SPARK_Mode
is

   ---------------
   -- Constants --
   ---------------

   --  Min/Max length of the MAC header (excluding Header IEs).
   Min_MHR_Length : constant := 1;
   Max_MHR_Length : constant := 37;

   --  Min/Max length of the Auxiliary Security Header
   Min_Aux_Security_Header_Length : constant := 0;
   Max_Aux_Security_Header_Length : constant := 14;

   --  Length of the Frame Check Sequence (FCS)
   FCS_Length : constant := 2;

   Max_Payload_Length : constant :=
     AdaBee.PHY_Constants.Max_PHY_Packet_Size - Min_MHR_Length - FCS_Length;

   ----------------------------
   -- Fixed-Size Byte Arrays --
   ----------------------------

   --  These subtypes are used for converting various fields to byte arrays

   subtype Byte_Array_2 is Byte_Array (1 .. 2);
   subtype Byte_Array_3 is Byte_Array (1 .. 3);
   subtype Byte_Array_4 is Byte_Array (1 .. 4);
   subtype Byte_Array_6 is Byte_Array (1 .. 6);
   subtype Byte_Array_8 is Byte_Array (1 .. 8);

   type Byte_Array_2_Aligned_2 is new Byte_Array (1 .. 2) with Alignment => 2;

   ------------------
   -- Common Types --
   ------------------

   --  These types are used in several places and don't fit under any
   --  particular subcategory.

   type Beacon_Order_Number is range 0 .. 15 with Size => 4;
   type Superframe_Order_Number is range 0 .. 15 with Size => 4;
   type Slot_Number is range 0 .. 15 with Size => 4;

   type Frame_Indices is record
      Header_IE_First : Natural := 0;
      --  Index of the first byte of the header IE list in the frame buffer

      Header_IE_Length : Natural := 0;
      --  Length of the header IE list in bytes, excluding any termination IE

      Payload_IE_First : Natural := 0;
      --  Index of the first byte of the payload IE list in the frame buffer

      Payload_IE_Length : Natural := 0;
      --  Length of the payload IE list in bytes, excluding any termination IE

      Payload_First : Natural := 0;
      --  Index of the first byte of the payload in the frame buffer

      Payload_Length : Natural := 0;
      --  Length of the payload in bytes.
   end record;

end AdaBee.MAC.Frames;
