--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Unchecked_Conversion;
with System;

with AdaBee.MAC.Frames.Headers;

package AdaBee.MAC.Frames.Beacons
  with Pure, SPARK_Mode, Always_Terminates
is
   use type AdaBee.MAC.Frames.Headers.Short_Address_Field;

   ------------------------------
   -- Superframe Specification --
   ------------------------------

   --  Ref. 7.3.1.4 of IEEE 802.15.4-2024

   type Superframe_Specification_Field is record
      Beacon_Order       : Beacon_Order_Number;
      Superframe_Order   : Superframe_Order_Number;
      Final_CAP_Slot     : Slot_Number;
      BLE                : Boolean;
      Reserved           : Bit;
      PAN_Coordinator    : Boolean;
      Association_Permit : Boolean;
   end record
   with
     Size                 => 16,
     Alignment            => 1,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Superframe_Specification_Field use
     record
       Beacon_Order       at 0 range 0 .. 3;
       Superframe_Order   at 0 range 4 .. 7;
       Final_CAP_Slot     at 0 range 8 .. 11;
       BLE                at 0 range 12 .. 12;
       Reserved           at 0 range 13 .. 13;
       PAN_Coordinator    at 0 range 14 .. 14;
       Association_Permit at 0 range 15 .. 15;
     end record;

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Superframe_Specification_Field,
        Target => Byte_Array_2);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Byte_Array_2,
        Target => Superframe_Specification_Field);

   --------------
   -- GTS Info --
   --------------

   --  Ref. 7.3.1.5 of IEEE 802.15.4-2024

   --  GTS Specification Field

   type GTS_Descriptor_Count_Field is range 0 .. 7 with Size => 3;

   type GTS_Specification_Field is record
      GTS_Descriptor_Count : GTS_Descriptor_Count_Field;
      Reserved             : Bits_4;
      GTS_Permit           : Boolean;
   end record
   with
     Size                 => 8,
     Alignment            => 1,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for GTS_Specification_Field use
     record
       GTS_Descriptor_Count at 0 range 0 .. 2;
       Reserved             at 0 range 3 .. 6;
       GTS_Permit           at 0 range 7 .. 7;
     end record;

   --  GTS Directions Field

   type GTS_Direction_Kind is (Transmit, Receive) with Size => 1;
   for GTS_Direction_Kind use (Transmit => 0, Receive => 1);

   type GTS_Directions_Array is
     array (GTS_Descriptor_Count_Field range 1 .. 7) of GTS_Direction_Kind
   with Pack, Size => 7;

   type GTS_Directions_Field is record
      GTS_Directions : GTS_Directions_Array;
      Reserved       : Bit;
   end record
   with
     Size                 => 8,
     Alignment            => 1,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for GTS_Directions_Field use
     record
       GTS_Directions at 0 range 0 .. 6;
       Reserved       at 0 range 7 .. 7;
     end record;

   --  GTS List Field

   type GTS_Descriptor_Field is record
      Device_Short_Addr : Headers.Short_Address_Field;
      GTS_Starting_Slot : Slot_Number;
      GTS_Length        : Slot_Number;
   end record
   with
     Size                 => 24,
     Alignment            => 1,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for GTS_Descriptor_Field use
     record
       Device_Short_Addr at 0 range 0 .. 15;
       GTS_Starting_Slot at 0 range 16 .. 19;
       GTS_Length        at 0 range 20 .. 23;
     end record;

   type GTS_Descriptor_Array is
     array (GTS_Descriptor_Count_Field) of GTS_Descriptor_Field;

   --  Variant GTS descriptor

   type GTS_Info_Field is record
      GTS_Spec       : GTS_Specification_Field;
      GTS_Directions : GTS_Directions_Array;
      GTS_List       : GTS_Descriptor_Array;
   end record;

   function GTS_Info_Encoded_Length
     (GTS_Descriptor_Count : GTS_Descriptor_Count_Field) return Positive
   is (case GTS_Descriptor_Count is
         when 0      => 1,
         when others => 2 + (Positive (GTS_Descriptor_Count) * 3));
   --  Calculates the length of a GTS info field, in bytes.
   --
   --  This length includes the GTS specification, GTS directions, and
   --  GTS list fields. The length of the GTS list part is determined from
   --  the GTS descriptor count in the GTS specification part.

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => GTS_Specification_Field,
        Target => Bits_8);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Bits_8,
        Target => GTS_Specification_Field);

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => GTS_Directions_Field,
        Target => Bits_8);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Bits_8,
        Target => GTS_Directions_Field);

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => GTS_Descriptor_Field,
        Target => Byte_Array_3);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Byte_Array_3_Aligned_2,
        Target => GTS_Descriptor_Field);

   function From_Bytes (Bytes : Byte_Array_3) return GTS_Descriptor_Field
   is (From_Bytes (Byte_Array_3_Aligned_2 (Bytes)));

   procedure Encode_GTS_Info_Field
     (GTS_Info : GTS_Info_Field; Buffer : out Byte_Array)
   with
     Global                 => null,
     Relaxed_Initialization => Buffer,
     Pre                    =>
       Buffer'Length
       >= GTS_Info_Encoded_Length (GTS_Info.GTS_Spec.GTS_Descriptor_Count),
     Post                   =>
       Buffer
         (Buffer'First
          ..
            Buffer'First
            + (GTS_Info_Encoded_Length (GTS_Info.GTS_Spec.GTS_Descriptor_Count)
               - 1))'Initialized;
   --  Write a GTS info field to a buffer
   --
   --  @param GTS_Info The GTS info field to write.
   --  @param Buffer The buffer to write to.

   procedure Decode_GTS_Info_Field
     (Buffer   : Byte_Array;
      GTS_Info : out GTS_Info_Field;
      Length   : out Natural;
      Result   : out Status_Code)
   with
     Global                 => null,
     Relaxed_Initialization => GTS_Info,
     Post                   =>
       Result in Success | Limit_Reached
       and then
         (if Result = Success
          then
            Length <= Buffer'Length
            and then GTS_Info.GTS_Spec'Initialized
            and then GTS_Info.GTS_Directions'Initialized
            and then
              GTS_Info.GTS_List
                (0 .. GTS_Info.GTS_Spec.GTS_Descriptor_Count - 1)'Initialized
            and then
              Length
              = GTS_Info_Encoded_Length
                  (GTS_Info.GTS_Spec.GTS_Descriptor_Count));
   --  Read a GTS info field from a byte array.
   --
   --  @param Buffer The buffer containing the GTS info field to read.
   --  @param GTS_Info The decoded GTS info data is written here. This is only
   --    initialized if Result = Success.
   --  @param Length The number of bytes that were read from Buffer.
   --  @param Result Success if the GTS info field was successfully read,
   --    or Limit_Reached if the decoded GTS descriptor count indicates that
   --    the GTS list is larger than the Buffer.

   -----------------------------------
   -- Pending Address Specification --
   -----------------------------------

   --  Ref. IEEE 802.15.4-2024 Section 7.3.1.6

   type Pending_Address_Count is range 0 .. 7 with Size => 3;

   type Pending_Address_Spec_Field is record
      Nb_Pending_Short_Addrs    : Pending_Address_Count;
      Reserved_1                : Bit;
      Nb_Pending_Extended_Addrs : Pending_Address_Count;
      Reserved_2                : Bit;
   end record
   with
     Size                 => 8,
     Alignment            => 1,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Pending_Address_Spec_Field use
     record
       Nb_Pending_Short_Addrs    at 0 range 0 .. 2;
       Reserved_1                at 0 range 3 .. 3;
       Nb_Pending_Extended_Addrs at 0 range 4 .. 6;
       Reserved_2                at 0 range 7 .. 7;
     end record;

   subtype Pending_Address_Index is Pending_Address_Count range 0 .. 6;

   type Pending_Short_Address_List is
     array (Pending_Address_Index range <>) of Headers.Short_Address_Field;

   type Pending_Extended_Address_List is
     array (Pending_Address_Index range <>) of Headers.Extended_Address_Field;

   function Pending_Address_List_Length_In_Range
     (Short_Addresses    : Pending_Short_Address_List;
      Extended_Addresses : Pending_Extended_Address_List) return Boolean
   is (Short_Addresses'Length + Extended_Addresses'Length
       in Pending_Address_Count);
   --  Checks that the length of the short + extended address lists does
   --  not exceed 7.
   --
   --  Ref. IEEE 802.15.4-2024 Section 7.3.1.6 states:
   --  If the coordinator is able to store more than seven transactions, it
   --  shall indicate them in its beacon on a first-come-first-served basis,
   --  ensuring that the Beacon frame contains at most seven addresses.

   function Pending_Address_Encoded_Length
     (Short_Addresses    : Pending_Short_Address_List;
      Extended_Addresses : Pending_Extended_Address_List) return Positive
   is (1 + (Short_Addresses'Length * 2) + (Extended_Addresses'Length * 8));
   --  Calculate the length (in bytes) of a pending address field given an
   --  address list.

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Pending_Address_Spec_Field,
        Target => Bits_8);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Bits_8,
        Target => Pending_Address_Spec_Field);

   procedure Encode_Pending_Address_Field
     (Buffer             : out Byte_Array;
      Short_Addresses    : Pending_Short_Address_List;
      Extended_Addresses : Pending_Extended_Address_List)
   with
     Global                 => null,
     Relaxed_Initialization => Buffer,
     Pre                    =>
       Buffer'Length
       >= Pending_Address_Encoded_Length (Short_Addresses, Extended_Addresses)

       and then (if Short_Addresses'Length > 0 then Short_Addresses'First = 0)
       and then
         (if Extended_Addresses'Length > 0 then Extended_Addresses'First = 0)

       and then
         Pending_Address_List_Length_In_Range
           (Short_Addresses, Extended_Addresses)

       --  IEEE 802.15.4-2024 Section 7.3.1.6 states:
       --  "The address list shall not contain the broadcast short address."
       and then
         (for all Addr of Short_Addresses =>
            Addr /= AdaBee.MAC.Frames.Headers.Broadcast_Short_Address),
     Post                   =>
       Buffer
         (Buffer'First
          ..
            Buffer'First
            + (Pending_Address_Encoded_Length
                 (Short_Addresses, Extended_Addresses)
               - 1))'Initialized;

end AdaBee.MAC.Frames.Beacons;
