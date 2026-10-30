--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Root package for IEEE 802.15.4 MAC frame definitions and encoders/decoders.

package AdaBee.MAC.Frames
  with Pure, SPARK_Mode, Always_Terminates
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
   type Byte_Array_3_Aligned_2 is new Byte_Array (1 .. 3) with Alignment => 2;
   type Byte_Array_6_Aligned_2 is new Byte_Array (1 .. 6) with Alignment => 2;

   ------------------
   -- Common Types --
   ------------------

   --  These types are used in several places and don't fit under any
   --  particular subcategory.

   type Beacon_Order_Number is range 0 .. 15 with Size => 4;
   type Superframe_Order_Number is range 0 .. 15 with Size => 4;
   type Slot_Number is range 0 .. 15 with Size => 4;

   ------------------
   -- Frame Layout --
   ------------------

   --  Types and functions for keeping track of the size & positions of
   --  IE lists & payloads in a MAC frame buffer.

   type Frame_Layout is record
      Header_IEs_First : Positive;
      --  Index of the first byte of the header IEs

      Header_IEs_Last : Natural;
      --  Index of the last byte of the header IEs
      --  This is < Header_IEs_First when header IEs are not present.

      MAC_Payload_First : Positive;
      --  Index of the first byte of the MAC payload field.
      --  This is also the first byte of the payload IEs, if they are present.

      MAC_Payload_Last : Natural;
      --  Index of the last byte of the MAC payload field.
      --  This is < MAC_Payload_First when the MAC payload is not present.

      Payload_IEs_Last : Natural;
      --  Length (in bytes) of the payload IE list.
      --  This is < MAC_Payload_First when the payload IEs are not present.
   end record
   with Predicate => Payload_IEs_Last <= MAC_Payload_Last;
   --  Stores the first/last indices that mark the positions of the following
   --  fields in the frame (See Figure 7-1 of IEEE 802.15.4-2024):
   --   * header IEs
   --   * payload IEs
   --   * frame payload

   function Has_Header_IEs (Layout : Frame_Layout) return Boolean
   is (Layout.Header_IEs_Last >= Layout.Header_IEs_First);
   --  Returns True if the header IE list is not empty in the frame layout

   function Has_MAC_Payload (Layout : Frame_Layout) return Boolean
   is (Layout.MAC_Payload_Last >= Layout.MAC_Payload_First);
   --  Returns True if the MAC payload is not empty in the frame layout

   function Has_Payload_IEs (Layout : Frame_Layout) return Boolean
   is (Layout.Payload_IEs_Last >= Layout.MAC_Payload_First);
   --  Returns True if the payload IE list is not empty in the frame layout

   function Has_Frame_Payload (Layout : Frame_Layout) return Boolean
   is (Layout.MAC_Payload_First <= Layout.MAC_Payload_Last
       and then Layout.Payload_IEs_Last < Layout.MAC_Payload_Last);
   --  Returns True if the frame payload is not empty in the frame layout

   function Frame_Payload_First (Layout : Frame_Layout) return Positive
   is (if Layout.Payload_IEs_Last < Layout.MAC_Payload_First
       then Layout.MAC_Payload_First
       else Layout.Payload_IEs_Last + 1)
   with Pre => Has_Frame_Payload (Layout);
   --  Get the index of the first byte of the frame payload field

   function Header_IEs_Length (Layout : Frame_Layout) return Natural
   is (if Has_Header_IEs (Layout)
       then (Layout.Header_IEs_Last - Layout.Header_IEs_First) + 1
       else 0);
   --  Returns the length (in bytes) of the header IEs part of the frame

   function MAC_Payload_Length (Layout : Frame_Layout) return Natural
   is (if Has_MAC_Payload (Layout)
       then (Layout.MAC_Payload_Last - Layout.MAC_Payload_First) + 1
       else 0);
   --  Returns the length (in bytes) of the MAC payload part of the frame

   function Payload_IEs_Length (Layout : Frame_Layout) return Natural
   is (if Has_Payload_IEs (Layout)
       then (Layout.Payload_IEs_Last - Layout.MAC_Payload_First) + 1
       else 0);
   --  Returns the length (in bytes) of the payload IEs part of the frame

   function Frame_Payload_Length (Layout : Frame_Layout) return Natural
   is (if Has_Frame_Payload (Layout)
       then (Layout.MAC_Payload_Last - Frame_Payload_First (Layout)) + 1
       else 0);
   --  Returns the length (in bytes) of the frame payload part of the frame

   function Header_IEs_In_Range
     (Layout : Frame_Layout; Buffer : Byte_Array) return Boolean
   is (if Has_Header_IEs (Layout)
       then
         Layout.Header_IEs_First >= Buffer'First
         and then Layout.Header_IEs_Last <= Buffer'Last);
   --  Returns True if the header IEs range in the Layout is within range of
   --  Buffer.

   function MAC_Payload_In_Range
     (Layout : Frame_Layout; Buffer : Byte_Array) return Boolean
   is (if Has_MAC_Payload (Layout)
       then
         Layout.MAC_Payload_First >= Buffer'First
         and then Layout.MAC_Payload_Last <= Buffer'Last);
   --  Returns True if the MAC payload range in the Layout is within range of
   --  Buffer.

end AdaBee.MAC.Frames;
