
separate (AdaBee.MAC.Frames.Info_Elements.Generic_Lists)
package body IE_Positions_Model is

   ---------------------
   -- Build_Positions --
   ---------------------

   procedure Build_Positions
     (Buffer    : Byte_Array;
      Length    : out Natural;
      IE_Count  : out Natural;
      Positions : in out Positions_Array)
   is
      Pos : Positive := Buffer'First;
   begin
      IE_Count := 0;

      loop
         pragma Loop_Variant (Increases => Pos);
         pragma Loop_Variant (Increases => IE_Count);

         pragma Loop_Invariant (Pos in Buffer'Range);
         pragma Loop_Invariant (IE_Count <= ((Pos - Buffer'First) + 1) / 2);

         --  Pos always points to the next IE, except for the first
         --  iteration when it points to the first IE in the buffer.

         pragma
           Loop_Invariant
             (if IE_Count = 0
              then Pos = Buffer'First
              else Pos = Next_IE_Position (Buffer, Positions (IE_Count)));

         --  Every IE recorded so far in Positions is a valid IE and is not
         --  the last IE.

         pragma
           Loop_Invariant
             (for all I in 1 .. IE_Count =>
                Positions (I) in Buffer'Range
                and then Valid_IE (Buffer, Positions (I))
                and then not Is_Last_IE (Buffer, Positions (I)));

         --  Each position references the next IE of the one at the position
         --  before.

         pragma
           Loop_Invariant
             (for all I in 1 .. IE_Count =>
                (if I = 1
                 then Positions (I) = Buffer'First
                 else
                   Positions (I)
                   = Next_IE_Position (Buffer, Positions (I - 1))));

         pragma Loop_Invariant (IE_Model.Valid_IE_List (Buffer, Pos));

         IE_Count := IE_Count + 1;
         Positions (IE_Count) := Pos;

         if Is_Last_IE (Buffer, Pos) then
            Length := (Pos - Buffer'First) + IE_Length (Buffer, Pos);
            exit;
         end if;

         --  Move to the next IE

         Pos := Next_IE_Position (Buffer, Pos);
      end loop;

      Lemma_IE_List_Length (Buffer, Positions (1 .. IE_Count), Length);
   end Build_Positions;

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
      Lemma_Last_IE_Preserved_Slice (Buffer, Slice, Positions);

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

   -----------------------------------
   -- Lemma_Last_IE_Preserved_Slice --
   -----------------------------------

   procedure Lemma_Last_IE_Preserved_Slice
     (Buffer : Byte_Array; Slice : Byte_Array; Positions : Positions_Array) is
   begin
      null;
   end Lemma_Last_IE_Preserved_Slice;

end IE_Positions_Model;
