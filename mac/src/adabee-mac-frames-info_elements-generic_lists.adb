--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Info_Elements.Generic_Lists is

   type Positions_Array is array (Positive range <>) of Positive;

   function Valid_Partial_Positions
     (Buffer : Byte_Array; Positions : Positions_Array) return Boolean
   is (
       --  All positions reference a valid index in Buffer and reference
       --  a valid IE at that index.

       (for all P of Positions =>
          P in Buffer'Range and then Valid_IE (Buffer, P))

       --  The IE list is not terminated yet
       and then (for all P of Positions => not Is_Last_IE (Buffer, P))

       --  Each position references the next IE of the one before,
       --  except the first which is the first IE in Buffer.
       and then
         (for all I in Positions'Range =>
            (if I = Positions'First
             then Positions (I) = Buffer'First
             else
               Positions (I) = Next_IE_Position (Buffer, Positions (I - 1)))))
   with Ghost;

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

       --  Each position references the next IE of the one before,
       --  except the first which is the first IE in Buffer.
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
     Post => IE_Model.Valid_IE_List (Buffer);
   --  Given an array containing the positions of each IE in a Buffer, prove
   --  that the IE list is valid.

   procedure Lemma_Invalid_IE_List
     (Buffer : Byte_Array; Positions : Positions_Array)
   with
     Ghost,
     Pre  =>
       Buffer'Length > 0
       and then Valid_Partial_Positions (Buffer, Positions)
       and then
         (if Positions'Length = 0
          then not Valid_IE (Buffer, Buffer'First)
          else
            not Valid_IE
                  (Buffer,
                   Next_IE_Position (Buffer, Positions (Positions'Last)))),
     Post => not IE_Model.Valid_IE_List (Buffer);
   --  Given an array containing the positions of valid IEs in a buffer,
   --  where the next IE after the last position is an invalid IE, prove that
   --  the IE list is not valid.

   procedure Lemma_IE_List_Length
     (Buffer : Byte_Array; Positions : Positions_Array; Length : Natural)
   with
     Ghost,
     Pre  =>
       Valid_Positions (Buffer, Positions)
       and then IE_Model.Valid_IE_List (Buffer)
       and then
         Length
         = (Positions (Positions'Last) - Buffer'First)
           + IE_Length (Buffer, Positions (Positions'Last)),
     Post => Length = IE_Model.IE_List_Length (Buffer);
   --  Given an array containing the positions of all IEs in an IE list,
   --  and the Length is equal to the position after the last IE, prove that
   --  the Length is equivalent to the length of the entire IE list.

   procedure Lemma_Position_Reachable
     (Buffer : Byte_Array; Positions : Positions_Array; Pos : Positive)
   with
     Ghost,
     Pre  =>
       Valid_Positions (Buffer, Positions)
       and then (for some P of Positions => P = Pos),
     Post => IE_Model.Reachable (Buffer, Pos);

   --------------
   -- IE_Model --
   --------------

   package body IE_Model is

      procedure Build_Positions
        (Buffer    : Byte_Array;
         Length    : out Natural;
         IE_Count  : out Natural;
         Positions : in out Positions_Array)
      with
        Global => null,
        Pre    =>
          Valid_IE_List (Buffer)
          and then Positions'Length >= Buffer'Length
          and then Positions'First = 1,
        Post   =>
          Length = IE_List_Length (Buffer)
          and then IE_Count <= Positions'Length
          and then Valid_Positions (Buffer, Positions (1 .. IE_Count))
          and then
            Length
            = (Positions (IE_Count) - Buffer'First)
              + IE_Length (Buffer, Positions (IE_Count));
      --  Iterate through the IE list and store the position of each IE in
      --  the Positions array.

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

            pragma Loop_Invariant (Valid_IE_List (Buffer, Pos));

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

      -------------------------------
      -- Lemma_Valid_IE_List_Slice --
      -------------------------------

      procedure Lemma_Valid_IE_List_Slice
        (Buffer : Byte_Array; Slice : Byte_Array)
      is
         Positions     : Positions_Array (1 .. Buffer'Length) := [others => 1];
         IE_Count      : Natural;
         Actual_Length : Natural;

      begin
         Build_Positions (Buffer, Actual_Length, IE_Count, Positions);

         for I in reverse 1 .. IE_Count loop
            pragma Loop_Invariant (Valid_IE (Slice, Positions (I)));

            pragma
              Loop_Invariant (IE_Model.Valid_IE_List (Slice, Positions (I)));
         end loop;
      end Lemma_Valid_IE_List_Slice;

      ---------------------------
      -- Lemma_Reachable_Slice --
      ---------------------------

      procedure Lemma_Reachable_Slice
        (Buffer : Byte_Array; Slice : Byte_Array; Pos : Positive)
      is
         Positions     : Positions_Array (1 .. Buffer'Length) := [others => 1];
         IE_Count      : Natural;
         Actual_Length : Natural;

      begin
         Build_Positions (Buffer, Actual_Length, IE_Count, Positions);

         for I in reverse 1 .. IE_Count loop
            pragma Loop_Invariant (Valid_IE (Buffer, Positions (I)));

            pragma
              Loop_Invariant (IE_Model.Valid_IE_List (Buffer, Positions (I)));

            pragma Loop_Invariant (Valid_IE (Slice, Positions (I)));

            pragma
              Loop_Invariant (IE_Model.Valid_IE_List (Slice, Positions (I)));

            pragma
              Loop_Invariant
                (Is_Last_IE (Buffer, Positions (I))
                 = Is_Last_IE (Slice, Positions (I)));

            pragma
              Loop_Invariant
                (Reachable (Buffer, Pos, Positions (I))
                 = Reachable (Slice, Pos, Positions (I)));
         end loop;
      end Lemma_Reachable_Slice;

   end IE_Model;

   ----------------------
   -- Validate_IE_List --
   ----------------------

   procedure Validate_IE_List
     (Buffer  : Byte_Array;
      Length  : out Natural;
      Result  : out Status_Code;
      Last_IE : out Positive)
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
         Last_IE := 1;
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
            Lemma_Invalid_IE_List (Buffer, Positions (1 .. IE_Count));

            Result := Malformed_Frame;
            Length := 0;
            Last_IE := 1;
            return;
         end if;

         IE_Count := IE_Count + 1;
         Positions (IE_Count) := Pos;

         --  Stop when the last IE is reached (either a termination IE or the
         --  current IE is the last IE in the buffer).

         if Is_Last_IE (Buffer, Pos) then
            Last_IE := Pos;
            Length := (Pos - Buffer'First) + IE_Length (Buffer, Pos);
            exit;
         end if;

         --  Move to the next IE

         Pos := Next_IE_Position (Buffer, Pos);
      end loop;

      pragma Assert (Result = Success);

      --  Help prove postcondition

      Lemma_Valid_IE_List (Buffer, Positions (1 .. IE_Count));
      Lemma_IE_List_Length (Buffer, Positions (1 .. IE_Count), Length);
      Lemma_Position_Reachable (Buffer, Positions (1 .. IE_Count), Last_IE);
   end Validate_IE_List;

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

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
