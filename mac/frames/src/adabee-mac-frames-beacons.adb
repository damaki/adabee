--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
--

package body AdaBee.MAC.Frames.Beacons
  with SPARK_Mode
is

   ---------------------------
   -- Encode_GTS_Info_Field --
   ---------------------------

   procedure Encode_GTS_Info_Field
     (GTS_Info : GTS_Info_Field; Buffer : out Byte_Array)
   is
      Offset : Natural;
   begin
      --  Encode the GTS specification field

      Buffer (Buffer'First) := To_Bytes (GTS_Info.GTS_Spec);

      --  The GTS directions and GTS list fields are only present when there
      --  is at least one descriptor.

      if GTS_Info.GTS_Spec.GTS_Descriptor_Count > 0 then

         --  Encode the GTS directions field

         Buffer (Buffer'First + 1) :=
           To_Bytes
             (GTS_Directions_Field'
                (GTS_Directions => GTS_Info.GTS_Directions, Reserved => 0));

         --  Encode each GTS descriptor

         Offset := 2;

         for I in 0 .. GTS_Info.GTS_Spec.GTS_Descriptor_Count - 1 loop
            Buffer (Buffer'First + Offset .. Buffer'First + Offset + 2) :=
              To_Bytes (GTS_Info.GTS_List (I));

            Offset := Offset + 3;

            pragma Loop_Invariant (Offset = 2 + (Natural (I + 1) * 3));

            pragma
              Loop_Invariant
                (Buffer
                   (Buffer'First .. Buffer'First + (Offset - 1))'Initialized);
         end loop;
      end if;
   end Encode_GTS_Info_Field;

   ---------------------------
   -- Decode_GTS_Info_Field --
   ---------------------------

   procedure Decode_GTS_Info_Field
     (Buffer   : Byte_Array;
      GTS_Info : out GTS_Info_Field;
      Length   : out Natural;
      Result   : out Status_Code)
   is
      Offset : Natural;
   begin
      --  Buffer length check

      if Buffer'Length = 0 then
         Length := 0;
         Result := Limit_Reached;

      else
         --  Decode the GTS specification field

         GTS_Info.GTS_Spec := From_Bytes (Buffer (Buffer'First));
         Length :=
           GTS_Info_Encoded_Length (GTS_Info.GTS_Spec.GTS_Descriptor_Count);

         --  The GTS directions and GTS list are only present when there is
         --  at least one GTS descriptor.

         if GTS_Info.GTS_Spec.GTS_Descriptor_Count = 0 then
            GTS_Info.GTS_Directions := [others => Transmit];
            GTS_Info.GTS_List :=
              [others =>
                 (Device_Short_Addr => 0,
                  GTS_Starting_Slot => 0,
                  GTS_Length        => 0)];

            Result := Success;

         elsif Buffer'Length < Length then
            --  The buffer is too small for the specified GTS descriptor count

            Result := Limit_Reached;

         else
            Result := Success;

            --  Decode the GTS directions field

            GTS_Info.GTS_Directions :=
              From_Bytes (Buffer (Buffer'First + 1)).GTS_Directions;

            --  Decode each GTS descriptor

            Offset := 2;

            for I in 0 .. GTS_Info.GTS_Spec.GTS_Descriptor_Count - 1 loop
               GTS_Info.GTS_List (I) :=
                 From_Bytes
                   (Buffer
                      (Buffer'First + Offset .. Buffer'First + Offset + 2));

               Offset := Offset + 3;

               pragma
                 Loop_Invariant
                   (for all J in 0 .. I => GTS_Info.GTS_List (J)'Initialized);

               pragma Loop_Invariant (Offset = 2 + (Natural (I + 1) * 3));
            end loop;
         end if;
      end if;
   end Decode_GTS_Info_Field;

   ----------------------------------
   -- Encode_Pending_Address_Field --
   ----------------------------------

   procedure Encode_Pending_Address_Field
     (Buffer             : out Byte_Array;
      Short_Addresses    : Pending_Short_Address_List;
      Extended_Addresses : Pending_Extended_Address_List)
   is
      Offset : Natural;
   begin
      --  Encode the Pending Address Specification field

      Buffer (Buffer'First) :=
        To_Bytes
          (Pending_Address_Spec_Field'
             (Nb_Pending_Short_Addrs    =>
                Pending_Address_Count (Short_Addresses'Length),
              Nb_Pending_Extended_Addrs =>
                Pending_Address_Count (Extended_Addresses'Length),
              Reserved_1                => 0,
              Reserved_2                => 0));

      Offset := 1;

      --  IEEE 802.15.4-2024 Section 7.3.1.6 states:
      --  "All pending short addresses shall appear first in the list followed
      --  by any extended addresses."

      --  Encode short addresses

      for I in Short_Addresses'Range loop
         Buffer (Buffer'First + Offset .. Buffer'First + Offset + 1) :=
           Headers.To_Bytes (Short_Addresses (I));

         Offset := Offset + 2;

         pragma Loop_Invariant (Offset = 1 + Natural (I + 1) * 2);

         pragma
           Loop_Invariant
             (Buffer
                (Buffer'First .. Buffer'First + (Offset - 1))'Initialized);
      end loop;

      --  Encode extended addresses

      for I in Extended_Addresses'Range loop
         Buffer (Buffer'First + Offset .. Buffer'First + Offset + 7) :=
           Headers.To_Bytes (Extended_Addresses (I));

         Offset := Offset + 8;

         pragma
           Loop_Invariant
             (Offset = 1 + (Short_Addresses'Length * 2) + Natural (I + 1) * 8);

         pragma
           Loop_Invariant
             (Buffer
                (Buffer'First .. Buffer'First + (Offset - 1))'Initialized);
      end loop;

   end Encode_Pending_Address_Field;

end AdaBee.MAC.Frames.Beacons;
