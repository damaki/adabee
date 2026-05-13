--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Info_Elements.Generic_Lists is

   type Positions_Array is array (Positive range <>) of Positive;

   function Valid_Positions
     (Buffer : Byte_Array; Positions : Positions_Array) return Boolean
   is (
       --  There must be at least one IE in the list
       Positions'Length > 0

       --  All positions reference a valid index in Buffer and reference
       --  a valid IE at that index.
       and then
         (for all P of Positions =>
            P in Buffer'Range and then Valid_IE (Buffer, P))

       --  Exactly one IE is the last IE, and it is the IE referenced by the
       --  last position.
       and then
         (for all I in Positions'Range =>
            Is_Last_IE (Buffer, Positions (I)) = (I = Positions'Last))

       and then
         (for all I in Positions'Range =>
            (if I = Positions'First
             then Positions (I) = Buffer'First
             else
               Positions (I) = Next_IE_Position (Buffer, Positions (I - 1)))))
   with Ghost;

   procedure Lemma_Valid_IE_List
     (Buffer : Byte_Array; Positions : Positions_Array)
   with
     Ghost,
     Pre  => Valid_Positions (Buffer, Positions),
     Post => Formal_Model.Valid_IE_List (Buffer);
   --  Given a set of valid positions of IEs in a buffer, prove that the IE
   --  list is valid.

   procedure Lemma_Valid_IE_List_Truncated
     (Buffer : Byte_Array; Length : Positive; Positions : Positions_Array)
   with
     Ghost,
     Pre  =>
       Valid_Positions (Buffer, Positions)
       and then
         Length
         = (Positions (Positions'Last) - Buffer'First)
           + IE_Length (Buffer, Positions (Positions'Last)),
     Post =>
       Formal_Model.Valid_IE_List
         (Buffer (Buffer'First .. Buffer'First + (Length - 1)));

   -------------------
   -- Parse_IE_List --
   -------------------

   procedure Parse_IE_List
     (Buffer : Byte_Array; Length : out Natural; Result : out Status_Code)
   is
      IE_Count : Natural := 0
      with Ghost;
      --  Counts the number of IEs visited

      Positions : Positions_Array (1 .. Buffer'Length) := [others => 1]
      with Ghost;
      --  Keeps track of the position in the Buffer of each IE

      Pos : Positive;
   begin
      --  Abort early if the buffer is empty.

      if Buffer'Length = 0 then
         Result := Malformed_Frame;
         Length := 0;
         return;
      end if;

      Result := Success;
      Pos := Buffer'First;

      loop
         pragma Loop_Variant (Increases => Pos);
         pragma Loop_Variant (Increases => IE_Count);

         pragma Loop_Invariant (Result = Success);
         pragma Loop_Invariant (Pos in Buffer'Range);
         pragma Loop_Invariant (IE_Count <= ((Pos - Buffer'First) + 1) / 2);

         --  Pos always points to the next IE, except for the first iteration
         --  when it points to the first IE in the buffer.

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

         --  Validity check on the IE to verify that its length field would not
         --  exceed the bounds of Buffer. If it does, then it is a malformed
         --  packet.

         if not Valid_IE (Buffer, Pos) then
            Result := Malformed_Frame;
            Length := 0;
            return;
         end if;

         IE_Count := IE_Count + 1;
         Positions (IE_Count) := Pos;

         --  Stop when the last IE is reached (either a termination IE or the
         --  current IE is the last IE in the buffer).

         if Is_Last_IE (Buffer, Pos) then
            Length := (Pos - Buffer'First) + IE_Length (Buffer, Pos);
            exit;
         end if;

         --  Move to the next IE

         Pos := Next_IE_Position (Buffer, Pos);
      end loop;

      pragma Assert (Result = Success);

      Lemma_Valid_IE_List_Truncated
        (Buffer, Length, Positions (1 .. IE_Count));
   end Parse_IE_List;

   -------------------------
   -- Lemma_Valid_IE_List --
   -------------------------

   procedure Lemma_Valid_IE_List
     (Buffer : Byte_Array; Positions : Positions_Array) is
   begin
      --  The definition of Valid_IE_List recurses down the right side of the
      --  Buffer, so prove it inductively starting at the IE on the right and
      --  working backwards to the left.

      for I in reverse Positions'Range loop
         pragma
           Loop_Invariant (Formal_Model.Valid_IE_List (Buffer, Positions (I)));
      end loop;
   end Lemma_Valid_IE_List;

   -----------------------------------
   -- Lemma_Valid_IE_List_Truncated --
   -----------------------------------

   procedure Lemma_Valid_IE_List_Truncated
     (Buffer : Byte_Array; Length : Positive; Positions : Positions_Array)
   is
      F : constant Positive := Buffer'First;
      L : constant Positive := Buffer'First + (Length - 1);

      Buffer_Slice : constant Byte_Array := Buffer (F .. L);

   begin
      Lemma_Valid_IE_List (Buffer, Positions);

      for I in Positions'Range loop
         pragma
           Loop_Invariant
             (for all J in Positions'First .. I =>
                (I < J) = (Positions (I) < Positions (J)));
      end loop;

      for I in reverse Positions'Range loop
         pragma Loop_Invariant (Valid_IE (Buffer_Slice, Positions (I)));

         pragma
           Loop_Invariant
             (Formal_Model.Valid_IE_List (Buffer_Slice, Positions (I)));
      end loop;
   end Lemma_Valid_IE_List_Truncated;

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
