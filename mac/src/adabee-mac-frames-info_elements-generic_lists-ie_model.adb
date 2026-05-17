separate (AdaBee.MAC.Frames.Info_Elements.Generic_Lists)
package body IE_Model is

   -------------------------------
   -- Lemma_Valid_IE_List_Slice --
   -------------------------------

   procedure Lemma_Valid_IE_List_Slice
     (Buffer : Byte_Array; Slice : Byte_Array)
   is
      Positions     :
        IE_Positions_Model.Positions_Array (1 .. Buffer'Length) :=
          [others => 1];
      IE_Count      : Natural;
      Actual_Length : Natural;

   begin
      IE_Positions_Model.Build_Positions
        (Buffer, Actual_Length, IE_Count, Positions);

      --  Prove that the positions of each each IE is the same in
      --  Buffer and Slice.

      IE_Positions_Model.Lemma_Positions_Valid_For_Slice
        (Buffer, Slice, Positions (1 .. IE_Count));

      IE_Positions_Model.Lemma_Valid_IE_List_All_Positions
        (Slice, Positions (1 .. IE_Count));

      pragma Assert (Positions (1) = Slice'First);

   end Lemma_Valid_IE_List_Slice;

   ---------------------------
   -- Lemma_Reachable_Slice --
   ---------------------------

   procedure Lemma_Reachable_Slice
     (Buffer : Byte_Array; Slice : Byte_Array; Target : Positive)
   is
      Positions     :
        IE_Positions_Model.Positions_Array (1 .. Buffer'Length) :=
          [others => 1];
      IE_Count      : Natural;
      Actual_Length : Natural;

   begin
      IE_Positions_Model.Build_Positions
        (Buffer, Actual_Length, IE_Count, Positions);

      --  Prove that the positions of each each IE is the same in
      --  Buffer and Slice.

      IE_Positions_Model.Lemma_Positions_Valid_For_Slice
        (Buffer, Slice, Positions (1 .. IE_Count));

      --  Prove that each position in Positions is a valid IE list

      IE_Positions_Model.Lemma_Valid_IE_List_All_Positions
        (Buffer, Positions (1 .. IE_Count));
      IE_Positions_Model.Lemma_Valid_IE_List_All_Positions
        (Slice, Positions (1 .. IE_Count));

      --  Prove that the reachability of Target in Buffer and Slice depends
      --  on whether Target is equal to some position in Positions.

      for I in reverse 1 .. IE_Count loop
         pragma
           Loop_Invariant
             (Reachable (Buffer, Target, Positions (I))
              = (for some J in I .. IE_Count => Positions (J) = Target));

         pragma
           Loop_Invariant
             (Reachable (Slice, Target, Positions (I))
              = (for some J in I .. IE_Count => Positions (J) = Target));
      end loop;

      --  Given that Positions is the same for Buffer and Slice, since
      --  Target is reachable in Buffer, then it must also be reachable
      --  in Slice.

      pragma Assert (Reachable (Slice, Target) = Reachable (Buffer, Target));

   end Lemma_Reachable_Slice;

end IE_Model;
