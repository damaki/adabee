--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

separate (AdaBee.MAC.Frames.Info_Elements.Generic_Lists)
package body IE_Model is

   -------------------------------
   -- Lemma_Valid_IE_List_Slice --
   -------------------------------

   procedure Lemma_Valid_IE_List_Preserved
     (Buffer : Byte_Array; Slice : Byte_Array)
   is
      Positions : constant IE_Positions_Model.Positions_Array :=
        IE_Positions_Model.IE_Positions (Buffer);

   begin
      --  Prove that the positions of each each IE is the same in
      --  Buffer and Slice.

      IE_Positions_Model.Lemma_Positions_Valid_For_Slice
        (Buffer, Slice, Positions);

      IE_Positions_Model.Lemma_Valid_IE_List_All_Positions (Slice, Positions);

      pragma Assert (Positions (Positions'First) = Slice'First);

   end Lemma_Valid_IE_List_Preserved;

   -------------------------------
   -- Lemma_Reachable_Preserved --
   -------------------------------

   procedure Lemma_Reachable_Preserved
     (Buffer : Byte_Array; Slice : Byte_Array; Target : Positive)
   is
      Positions : constant IE_Positions_Model.Positions_Array :=
        IE_Positions_Model.IE_Positions (Buffer);

   begin
      --  Prove that the positions of each each IE is the same in
      --  Buffer and Slice.

      IE_Positions_Model.Lemma_Positions_Valid_For_Slice
        (Buffer, Slice, Positions);

      --  Prove that each position in Positions is a valid IE list

      IE_Positions_Model.Lemma_Valid_IE_List_All_Positions (Buffer, Positions);
      IE_Positions_Model.Lemma_Valid_IE_List_All_Positions (Slice, Positions);

      --  Prove that the reachability of Target in Buffer and Slice depends
      --  on whether Target is equal to some position in Positions.

      for I in reverse Positions'Range loop
         pragma
           Loop_Invariant
             (Reachable (Buffer, Target, Positions (I))
              = (for some J in I .. Positions'Last => Positions (J) = Target));

         pragma
           Loop_Invariant
             (Reachable (Slice, Target, Positions (I))
              = (for some J in I .. Positions'Last => Positions (J) = Target));
      end loop;

      --  Given that Positions is the same for Buffer and Slice, since
      --  Target is reachable in Buffer, then it must also be reachable
      --  in Slice.

      pragma Assert (Reachable (Slice, Target) = Reachable (Buffer, Target));

   end Lemma_Reachable_Preserved;

   ------------------------------
   -- Lemma_Contains_Preserved --
   ------------------------------

   procedure Lemma_Contains_Preserved
     (Buffer : Byte_Array; Slice : Byte_Array; Header : Header_Field)
   is
      Positions : constant IE_Positions_Model.Positions_Array :=
        IE_Positions_Model.IE_Positions (Buffer);

   begin
      --  Prove that the positions of each each IE is the same in
      --  Buffer and Slice.

      IE_Positions_Model.Lemma_Positions_Valid_For_Slice
        (Buffer, Slice, Positions);

      --  Prove that each position in Positions is a valid IE list

      IE_Positions_Model.Lemma_Valid_IE_List_All_Positions (Buffer, Positions);
      IE_Positions_Model.Lemma_Valid_IE_List_All_Positions (Slice, Positions);

      --  This helps prove the equality for IE_Header in the subsequent loop

      pragma Assert (for all I in Slice'Range => Slice (I) = Buffer (I));

      pragma
        Assert
          (for all P of Positions =>
             P in Buffer'First .. Buffer'Last - 1
             and then P in Slice'First .. Slice'Last - 1
             and then Buffer (P .. P + 1) = Slice (P .. P + 1));

      --  Prove that the Contains in Buffer and Slice depends
      --  on whether Target is equal to some position in Positions.

      for I in reverse Positions'Range loop
         pragma
           Loop_Invariant
             (IE_Header (Buffer, Positions (I))
              = IE_Header (Slice, Positions (I)));

         pragma
           Loop_Invariant
             (Contains (Buffer, Header, Positions (I))
              = Contains (Slice, Header, Positions (I)));
      end loop;

      --  Given that Positions is the same for Buffer and Slice, if Buffer
      --  contains Header, then Slice must also contain Header.

      pragma Assert (Contains (Slice, Header) = Contains (Buffer, Header));

   end Lemma_Contains_Preserved;

   ------------------------------------
   -- Lemma_IE_List_Length_Preserved --
   ------------------------------------

   procedure Lemma_IE_List_Length_Preserved
     (Buffer : Byte_Array; Slice : Byte_Array)
   is
      Positions : constant IE_Positions_Model.Positions_Array :=
        IE_Positions_Model.IE_Positions (Buffer);

   begin

      --  First, prove that Positions is also valid for Slice

      IE_Positions_Model.Lemma_Positions_Valid_For_Slice
        (Buffer, Slice, Positions);

      --  Valid_IE_List (Slice) is required by the precondition of
      --  IE_List_Length (Slice).

      IE_Positions_Model.Lemma_Valid_IE_List (Slice, Positions);

      --  Help guide the provers that the length of the last IE is the same
      --  for both Buffer and Slice

      pragma Assert (Slice'First = Buffer'First);
      pragma
        Assert
          (IE_Length (Slice, Positions (Positions'Last))
           = IE_Length (Buffer, Positions (Positions'Last)));

      --  Prove the relation of IE_List_Length against the last IE position
      --  for both Buffer and Slice.
      --
      --  Since the last IE position is the same in both Buffer and Slice, and
      --  the length of that IE is the same in both of them, then then length
      --  of both lists are the same.

      IE_Positions_Model.Lemma_IE_List_Length
        (Buffer    => Slice,
         Positions => Positions,
         Length    =>
           Positions (Positions'Last)
           - Slice'First
           + IE_Length (Slice, Positions (Positions'Last)));

      IE_Positions_Model.Lemma_IE_List_Length
        (Buffer    => Buffer,
         Positions => Positions,
         Length    =>
           Positions (Positions'Last)
           - Buffer'First
           + IE_Length (Buffer, Positions (Positions'Last)));
   end Lemma_IE_List_Length_Preserved;

   ------------------------------------------
   -- Lemma_Last_IE_Header_Field_Preserved --
   ------------------------------------------

   procedure Lemma_Last_IE_Header_Field_Preserved
     (Buffer : Byte_Array; Slice : Byte_Array)
   is
      Positions : constant IE_Positions_Model.Positions_Array :=
        IE_Positions_Model.IE_Positions (Buffer);
   begin
      Lemma_Valid_IE_List_Preserved (Buffer, Slice);

      IE_Positions_Model.Lemma_Last_IE_Header (Buffer, Positions);
      IE_Positions_Model.Lemma_Positions_IE_List_Length (Buffer, Positions);
      IE_Positions_Model.Lemma_IEs_Preserved (Buffer, Slice, Positions);
      IE_Positions_Model.Lemma_Last_IE_Header (Slice, Positions);

      pragma
        Assert
          (IE_Header (Slice, Positions (Positions'Last))
           = IE_Header (Slice, Positions (Positions'Last)));
   end Lemma_Last_IE_Header_Field_Preserved;

   ----------------------
   -- Lemma_Next_Valid --
   ----------------------

   procedure Lemma_Valid_List_Slice (Buffer : Byte_Array; From, Pos : Positive)
   is
   begin
      pragma Assert (Valid_IE (Buffer (From .. Buffer'Last), Pos));

      if not Is_Last_IE (Buffer, Pos) then
         Lemma_Valid_List_Slice (Buffer, From, Next_IE_Position (Buffer, Pos));
      end if;
   end Lemma_Valid_List_Slice;

   --------------------------
   -- Lemma_IE_List_Extend --
   --------------------------

   procedure Lemma_IE_List_Extend (Buffer : Byte_Array; L1, L2 : Natural) is
      use type IE_Positions_Model.Positions_Array;

      BF  : constant Positive := Buffer'First;
      BL1 : constant Natural := Buffer'First + (L1 - 1);
      BL2 : constant Natural := Buffer'First + (L2 - 1);
   begin
      if L1 > 0 then
         declare
            Positions_Old : constant IE_Positions_Model.Positions_Array :=
              IE_Positions_Model.IE_Positions (Buffer (BF .. BL1))
            with Ghost;

            Positions : constant IE_Positions_Model.Positions_Array :=
              Positions_Old & [BF + L1]
            with Ghost;

         begin
            IE_Positions_Model.Lemma_Positions_IE_List_Length
              (Buffer (BF .. BL1), Positions_Old);

            IE_Positions_Model.Lemma_IEs_Preserved
              (A         => Buffer (BF .. BL1),
               B         => Buffer (BF .. BL2),
               Positions => Positions_Old);

            IE_Positions_Model.Lemma_Last_IE_Header
              (Buffer (BF .. BL1), Positions_Old);

            pragma Assert (Valid_IE (Buffer (BF .. BL2), BF + L1));
            pragma Assert (IE_Length (Buffer (BF .. BL2), BF + L1) = L2 - L1);
            pragma Assert (Is_Last_IE (Buffer (BF .. BL2), BF + L1));

            pragma
              Assert
                (IE_Positions_Model.Valid_Positions
                   (Buffer (BF .. BL2), Positions));

            IE_Positions_Model.Lemma_Valid_IE_List
              (Buffer (BF .. BL2), Positions);

            IE_Positions_Model.Lemma_IE_List_Length
              (Buffer    => Buffer (BF .. BL2),
               Positions => Positions,
               Length    => L2);

            IE_Positions_Model.Lemma_Last_IE_Header
              (Buffer (BF .. BL2), Positions);
         end;
      else
         pragma Assert (Valid_IE (Buffer (BF .. BL2), BF));
         pragma Assert (Is_Last_IE (Buffer (BF .. BL2), BF));

         IE_Positions_Model.Lemma_Valid_IE_List
           (Buffer => Buffer (BF .. BL2), Positions => [BF]);

         IE_Positions_Model.Lemma_IE_List_Length
           (Buffer => Buffer (BF .. BL2), Positions => [BF], Length => L2);

         IE_Positions_Model.Lemma_Last_IE_Header
           (Buffer => Buffer (BF .. BL2), Positions => [BF]);
      end if;
   end Lemma_IE_List_Extend;

end IE_Model;
