--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

separate (AdaBee.MAC.Frames.Info_Elements.Generic_Lists)
package body IE_Positions_Model is

   ------------------
   -- IE_Positions --
   ------------------

   function IE_Positions (Buffer : Byte_Array) return Positions_Array is
      Positions : Positions_Array (1 .. Buffer'Length) := [others => 1];
      Count     : Natural := 0;
      Pos       : Positive := Buffer'First;
   begin
      loop
         pragma Loop_Variant (Increases => Pos);
         pragma Loop_Variant (Increases => Count);

         pragma Loop_Invariant (Pos in Buffer'Range);
         pragma Loop_Invariant (Count <= ((Pos - Buffer'First) + 1) / 2);

         --  Pos always points to the next IE, except for the first
         --  iteration when it points to the first IE in the buffer.

         pragma
           Loop_Invariant
             (if Count = 0
              then Pos = Buffer'First
              else Pos = Next_IE_Position (Buffer, Positions (Count)));

         --  Every IE recorded so far in Positions is a valid IE and is not
         --  the last IE.

         pragma
           Loop_Invariant
             (for all I in 1 .. Count =>
                Positions (I) in Buffer'Range
                and then Valid_IE (Buffer, Positions (I))
                and then not Is_Last_IE (Buffer, Positions (I)));

         --  Each position references the next IE of the one at the position
         --  before.

         pragma
           Loop_Invariant
             (for all I in 1 .. Count =>
                (if I = 1
                 then Positions (I) = Buffer'First
                 else
                   Positions (I)
                   = Next_IE_Position (Buffer, Positions (I - 1))));

         pragma Loop_Invariant (IE_Model.Valid_IE_List (Buffer, Pos));

         pragma
           Loop_Invariant
             (Count
              = IE_Model.IE_Count (Buffer, Buffer'First)
                - IE_Model.IE_Count (Buffer, Pos));

         Count := Count + 1;
         Positions (Count) := Pos;

         exit when Is_Last_IE (Buffer, Pos);

         --  Move to the next IE

         Pos := Next_IE_Position (Buffer, Pos);
      end loop;

      return Positions (1 .. Count);
   end IE_Positions;

   -------------------------
   -- Lemma_Valid_IE_List --
   -------------------------

   procedure Lemma_Valid_IE_List
     (Buffer : Byte_Array; Positions : Positions_Array) is
   begin
      for I in reverse Positions'Range loop
         pragma
           Loop_Invariant (IE_Model.Valid_IE_List (Buffer, Positions (I)));
      end loop;
   end Lemma_Valid_IE_List;

   ---------------------------------------
   -- Lemma_Valid_IE_List_All_Positions --
   ---------------------------------------

   procedure Lemma_Valid_IE_List_All_Positions
     (Buffer : Byte_Array; Positions : Positions_Array) is
   begin
      for I in reverse Positions'Range loop
         pragma
           Loop_Invariant
             (for all J in I .. Positions'Last =>
                IE_Model.Valid_IE_List (Buffer, Positions (J)));
      end loop;
   end Lemma_Valid_IE_List_All_Positions;

   ---------------------------
   -- Lemma_Invalid_IE_List --
   ---------------------------

   procedure Lemma_Invalid_IE_List
     (Buffer : Byte_Array; Positions : Positions_Array) is
   begin
      for I in reverse Positions'Range loop
         pragma
           Loop_Invariant (not IE_Model.Valid_IE_List (Buffer, Positions (I)));
      end loop;
   end Lemma_Invalid_IE_List;

   --------------------------
   -- Lemma_IE_List_Length --
   --------------------------

   procedure Lemma_IE_List_Length
     (Buffer : Byte_Array; Positions : Positions_Array; Length : Natural)
   is
      Visited_Length : Natural := 0;
   begin
      for I in reverse Positions'Range loop
         Visited_Length := Visited_Length + IE_Length (Buffer, Positions (I));

         pragma
           Loop_Invariant (IE_Model.Valid_IE_List (Buffer, Positions (I)));

         pragma
           Loop_Invariant
             (Visited_Length
              = IE_Model.IE_List_Length (Buffer, Positions (I)));

         pragma
           Loop_Invariant
             (Length = Visited_Length + (Positions (I) - Buffer'First));
      end loop;
   end Lemma_IE_List_Length;

   ------------------------------
   -- Lemma_Position_Reachable --
   ------------------------------

   procedure Lemma_Position_Reachable
     (Buffer : Byte_Array; Positions : Positions_Array; Pos : Positive) is
   begin
      for I in reverse Positions'Range loop
         pragma Loop_Invariant (Valid_IE (Buffer, Positions (I)));

         pragma
           Loop_Invariant (IE_Model.Valid_IE_List (Buffer, Positions (I)));

         pragma
           Loop_Invariant
             (IE_Model.Reachable (Buffer, Pos, Positions (I))
              = (for some J in I .. Positions'Last => Positions (J) = Pos));
      end loop;
   end Lemma_Position_Reachable;

   ------------------------------------
   -- Lemma_Positions_IE_List_Length --
   ------------------------------------

   procedure Lemma_Positions_IE_List_Length
     (Buffer : Byte_Array; Positions : Positions_Array)
   is
      Length : constant Natural :=
        (Positions (Positions'Last) - Buffer'First)
        + IE_Length (Buffer, Positions (Positions'Last));

   begin
      Lemma_Valid_IE_List (Buffer, Positions);
      Lemma_IE_List_Length (Buffer, Positions, Length);

      for I in reverse Positions'Range loop
         pragma Loop_Invariant (Valid_IE (Buffer, Positions (I)));

         pragma
           Loop_Invariant (IE_Model.Valid_IE_List (Buffer, Positions (I)));

         pragma
           Loop_Invariant
             (for all J in I .. Positions'Last =>
                Valid_IE (Buffer, Positions (J))
                and then IE_Model.Valid_IE_List (Buffer, Positions (J))
                and then
                  Length
                  = (Positions (J) - Buffer'First)
                    + IE_Model.IE_List_Length (Buffer, Positions (J)));
      end loop;
   end Lemma_Positions_IE_List_Length;

   -------------------------------------
   -- Lemma_Positions_Valid_For_Slice --
   -------------------------------------

   procedure Lemma_Positions_Valid_For_Slice
     (Buffer : Byte_Array; Slice : Byte_Array; Positions : Positions_Array) is
   begin
      Lemma_Positions_IE_List_Length (Buffer, Positions);
      Lemma_Valid_IE_List_All_Positions (Buffer, Positions);

      for I in reverse Positions'Range loop
         pragma
           Loop_Invariant
             (for all J in I .. Positions'Last =>
                Positions (J) in Slice'Range
                and then Valid_IE (Slice, Positions (J))
                and then
                  Is_Last_IE (Slice, Positions (J)) = (J = Positions'Last));
      end loop;

      for I in Positions'Range loop
         pragma
           Loop_Invariant
             (for all J in I .. Positions'Last =>
                (if J = Positions'First
                 then Positions (J) = Slice'First
                 else
                   Positions (J)
                   = Next_IE_Position (Slice, Positions (J - 1))));
      end loop;
   end Lemma_Positions_Valid_For_Slice;

   --------------------------
   -- Lemma_Last_IE_Header --
   --------------------------

   procedure Lemma_Last_IE_Header
     (Buffer : Byte_Array; Positions : Positions_Array) is
   begin
      Lemma_Valid_IE_List_All_Positions (Buffer, Positions);

      for I in reverse Positions'Range loop
         pragma
           Loop_Invariant
             (IE_Header (Buffer, Positions (Positions'Last))
              = IE_Model.Last_IE_Header_Field (Buffer, Positions (I)));
      end loop;

      pragma Assert (Positions (Positions'First) = Buffer'First);
   end Lemma_Last_IE_Header;

   -------------------------------
   -- Lemma_Positions_Monotonic --
   -------------------------------

   procedure Lemma_Positions_Monotonic
     (Buffer : Byte_Array; Positions : Positions_Array) is
   begin
      if Positions'Length > 1 then
         Lemma_Positions_Monotonic
           (Buffer, Positions (Positions'First + 1 .. Positions'Last));

         pragma
           Assert
             (Positions (Positions'First) < Positions (Positions'First + 1));
      end if;
   end Lemma_Positions_Monotonic;

   -------------------------
   -- Lemma_IEs_Preserved --
   -------------------------

   procedure Lemma_IEs_Preserved
     (A, B : Byte_Array; Positions : Positions_Array)
   is
      First_Pos : constant Positive := Positions (Positions'First);

      IE_List_Last : constant Positive :=
        Positions (Positions'Last)
        + (IE_Length (A, Positions (Positions'Last)) - 1);
   begin
      Lemma_Positions_Monotonic (A, Positions);

      pragma Assert (if Is_Last_IE (A, First_Pos) then B'Last >= IE_List_Last);
      pragma Assert (IE_Header (A, First_Pos) = IE_Header (B, First_Pos));
      pragma Assert (Valid_IE (B, First_Pos));

      if Positions'Length > 1 then
         Lemma_IEs_Preserved
           (A, B, Positions (Positions'First + 1 .. Positions'Last));

         pragma
           Assert
             (if not Is_Last_IE (A, First_Pos)
              then not Is_Last_IE (B, First_Pos));
      end if;
   end Lemma_IEs_Preserved;

end IE_Positions_Model;
