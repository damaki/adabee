--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with SPARK.Cut_Operations; use SPARK.Cut_Operations;

with AdaBee.MAC.Frames.Info_Elements.Generic_Lists.Lemmas;

package body AdaBee.MAC.Frames.Info_Elements.Generic_Lists is

   package Lemmas_Instance is new Lemmas;
   use Lemmas_Instance;

   ---------------
   -- Append_IE --
   ---------------

   procedure Append_IE
     (Buffer : in out Byte_Array; Length : in out Natural; IE : Byte_Array)
   is
      Length_Old : constant Natural := Length
      with Ghost;

      IE_List_Old : constant Byte_Array :=
        Buffer (Buffer'First .. Buffer'First + (Length - 1))
      with Ghost;
   begin
      Buffer
        (Buffer'First + Length .. Buffer'First + Length + (IE'Length - 1)) :=
        IE;

      Length := Length + IE'Length;

      --  Prove the properties needed to prove the postcondition

      pragma
        Assert
          (Buffer (Buffer'First .. Buffer'First + (Length - 1))'Initialized);

      declare
         IE_List : constant Byte_Array :=
           Buffer (Buffer'First .. Buffer'First + (Length - 1))
         with Ghost;
      begin
         pragma Assert (IE_List (IE_List_Old'Range) = IE_List_Old);

         Lemma_IE_Header_Preserved
           (IE, IE_List, IE'First, IE_List'First + Length_Old);

         if Length > IE'Length then

            --  Prove that properties on the previous IE list are preserved
            --  after Buffer was modified.

            Lemma_IE_List_Preserved
              (B1 => IE_List_Old,
               B2 => IE_List (IE_List_Old'Range),
               X  => IE_List'First);

            --  Prove the preservation of Is_Terminated for IE_List

            pragma
              Assert
                (By
                   (Premise     =>
                      Last_IE_Header
                        (IE_List (IE_List_Old'Range), IE_List'First)
                      = Last_IE_Header (IE_List_Old, IE_List_Old'First),
                    Consequence =>
                      not Is_Terminated (IE_List (IE_List_Old'Range))));

            --  Prove that appending the new IE results in a new, valid IE list
            --  which preserves the positions and ordering of existing IEs.

            Lemma_IE_List_Append
              (Buffer => IE_List, X => IE_List'First, Length => Length_Old);

            --  Prove that the content of existing IEs are preserved

            Lemma_Reachable_IE_Headers_Preserved_Prefix
              (B1 => IE_List_Old, B2 => IE_List, X => IE_List'First);

            Lemma_Reachable_IE_Content_Preserved_Prefix
              (B1 => IE_List_Old, B2 => IE_List, X => IE_List'First);
         end if;
      end;
   end Append_IE;

   ------------------------------------
   -- Append_IE_Inplace_With_Context --
   ------------------------------------

   procedure Append_IE_Inplace_With_Context
     (Buffer : in out Byte_Array;
      Length : in out Natural;
      Ctx    : Writer_Context)
   is
      IE_List_Old : constant Byte_Array :=
        Buffer (Buffer'First .. Buffer'First + (Length - 1));

      Length_Old : constant Natural := Length
      with Ghost;

      New_IE_Length : Natural;
   begin
      --  Write the IE
      Write_IE
        (Buffer (Buffer'First + Length .. Buffer'Last), New_IE_Length, Ctx);

      Length := Length + New_IE_Length;

      --  Prove the properties needed to prove the postcondition

      pragma
        Assert
          (Buffer (Buffer'First .. Buffer'First + (Length - 1))'Initialized);

      declare
         IE_List : constant Byte_Array :=
           Buffer (Buffer'First .. Buffer'First + (Length - 1))
         with Ghost;

         New_IE_Pos : constant Positive := Buffer'First + Length_Old
         with Ghost;
      begin

         --  Check properties that should be provable from the postcondition
         --  of Write_IE

         pragma Assert (Valid_IE (IE_List, New_IE_Pos));
         pragma Assert (IE_Length (IE_List, New_IE_Pos) = New_IE_Length);
         pragma
           Assert
             (IE_Property
                (Header  => IE_Header (IE_List, New_IE_Pos),
                 Content => IE_Content (IE_List, New_IE_Pos)));

         if Length > New_IE_Length then

            --  Prove that properties on the previous IE list are preserved
            --  after Buffer was modified.

            Lemma_IE_List_Preserved
              (B1 => IE_List_Old,
               B2 => IE_List (IE_List_Old'Range),
               X  => IE_List'First);

            --  Prove the preservation of Is_Terminated in IE_List

            pragma
              Assert
                (By
                   (Premise     =>
                      Last_IE_Header
                        (IE_List (IE_List_Old'Range), IE_List'First)
                      = Last_IE_Header (IE_List_Old, IE_List_Old'First),
                    Consequence =>
                      not Is_Terminated (IE_List (IE_List_Old'Range))));

            --  Prove that appending the new IE results in a new, valid IE list
            --  which preserves the positions and ordering of existing IEs.

            Lemma_IE_List_Append
              (Buffer => IE_List, X => IE_List'First, Length => Length_Old);

            --  Prove that the content of existing IEs are preserved

            Lemma_Reachable_IE_Headers_Preserved_Prefix
              (B1 => IE_List_Old, B2 => IE_List, X => IE_List'First);

            Lemma_Reachable_IE_Content_Preserved_Prefix
              (B1 => IE_List_Old, B2 => IE_List, X => IE_List'First);
         end if;
      end;
   end Append_IE_Inplace_With_Context;

   ----------------------------------
   -- Filter_And_Transform_IE_List --
   ----------------------------------

   procedure Filter_And_Transform_IE_List
     (Buffer : in out Byte_Array; Length : out Natural)
   is
      Read_Idx : Positive := Buffer'First;
      --  Index in Buffer of the next IE to read and compare against the Filter

      Write_Idx : Positive := Buffer'First;
      --  Index of the next position to write to to append an IE the list of
      --  IEs that pass the filter.

      Is_Last : Boolean;

      IE_Length_Before : Positive;
      IE_Length_After  : Positive;
   begin
      loop
         pragma Loop_Variant (Increases => Read_Idx);

         pragma Loop_Invariant (Read_Idx in Buffer'Range);
         pragma Loop_Invariant (Write_Idx in Buffer'Range);
         pragma Loop_Invariant (Write_Idx <= Read_Idx);

         --  The IE list starting at Read_Idx is always a valid IE list
         pragma Loop_Invariant (Valid_IE_List (Buffer, Read_Idx));

         pragma
           Loop_Invariant
             (if Write_Idx > Buffer'First
              then
                --  IEs processed so far form a valid IE list
                Valid_IE_List (Buffer (Buffer'First .. Write_Idx - 1))

                --  Write_Idx denotes the next byte after the end of the list
                and then
                  Write_Idx - Buffer'First
                  = IE_List_Length (Buffer (Buffer'First .. Write_Idx - 1))

                --  The IE list processed so far does not contain any
                --  termination IEs.
                and then
                  not Is_Terminated (Buffer (Buffer'First .. Write_Idx - 1)));

         declare
            Buffer_At_Loop_Iteration_Start : constant Byte_Array := Buffer
            with Ghost;

            Next_Read_Idx : Positive
            with Relaxed_Initialization;
         begin

            Is_Last := Is_Last_IE (Buffer, Read_Idx);

            IE_Length_Before := IE_Length (Buffer, Read_Idx);

            if not Is_Last then
               Next_Read_Idx := Read_Idx + IE_Length_Before;
            end if;

            if Filter (Buffer (Read_Idx .. Buffer'Last)) then
               --  Avoid copying unless the IE would actually be moved

               if Write_Idx /= Read_Idx then
                  Buffer (Write_Idx .. Write_Idx + (IE_Length_Before - 1)) :=
                    Buffer (Read_Idx .. Read_Idx + (IE_Length_Before - 1));
               end if;

               pragma
                 Assert
                   (IE_Header (Buffer, Write_Idx)
                    = IE_Header (Buffer_At_Loop_Iteration_Start, Read_Idx));

               Transform
                 (Buffer (Write_Idx .. Write_Idx + (IE_Length_Before - 1)));

               --  Transform might shorten the IE, but it cannot lengthen it

               IE_Length_After := IE_Length (Buffer, Write_Idx);

               pragma Assert (IE_Length_After <= IE_Length_Before);

               declare
                  Updated_IE_List : constant Byte_Array :=
                    Buffer (Buffer'First .. Write_Idx + (IE_Length_After - 1));
               begin

                  if Write_Idx > Buffer'First then

                     --  Prove that the updated IE list is still valid
                     Lemma_Valid_IE_List_Append
                       (Buffer => Updated_IE_List,
                        X      => Buffer'First,
                        Length => Write_Idx - Buffer'First);

                     --  Prove that the length has increased by IE_Length_After
                     Lemma_IE_List_Length_Append
                       (Buffer => Updated_IE_List,
                        X      => Buffer'First,
                        Length => Write_Idx - Buffer'First);

                     --  Prove that Write_Idx currently denotes the position
                     --  of the last IE
                     Lemma_Last_IE_Position_Append
                       (Buffer => Updated_IE_List,
                        X      => Buffer'First,
                        Length => Write_Idx - Buffer'First);

                     --  Prove the relation between Write_Idx and the length of
                     --  the updated IE list.
                     Lemma_IE_List_Length_Anti_Isometric
                       (Updated_IE_List, Buffer'First);
                  end if;

                  Write_Idx := Write_Idx + IE_Length_After;

                  pragma
                    Assert
                      (By
                         (Premise     =>
                            Write_Idx - IE_Length_After
                            = Last_IE_Position (Updated_IE_List, Buffer'First),
                          Consequence =>
                            Write_Idx - Buffer'First
                            = IE_List_Length (Updated_IE_List)));

                  pragma
                    Assert
                      (By
                         (Premise     =>
                            Is_Termination_IE
                              (Last_IE_Header (Updated_IE_List, Buffer'First))
                            = Is_Termination_IE
                                (IE_Header
                                   (Buffer_At_Loop_Iteration_Start, Read_Idx)),
                          Consequence =>
                            (if Is_Terminated (Updated_IE_List)
                             then Is_Last)));
               end;
            end if;

            if not Is_Last then
               Lemma_Valid_IE_List_Preserved
                 (B1 => Buffer_At_Loop_Iteration_Start,
                  B2 => Buffer,
                  X1 => Next_Read_Idx,
                  X2 => Next_Read_Idx);
            end if;

            pragma
              Assert_And_Cut
                (Write_Idx in Buffer'First .. Buffer'Last + 1

                 --  If there are still more IEs to process, then Read_Idx
                 --  denotes the position of the valid IE list in Buffer that
                 --  contains those IEs.
                 and then
                   (if not Is_Last
                    then
                      Write_Idx in Buffer'Range
                      and then Next_Read_Idx'Initialized
                      and then Next_Read_Idx in Buffer'Range
                      and then Next_Read_Idx > Read_Idx
                      and then Write_Idx <= Next_Read_Idx
                      and then Valid_IE_List (Buffer, Next_Read_Idx))

                 --  IEs processed so far are stored at the start of Buffer,
                 --  and Write_Idx denotes the next byte after the end of this
                 --  list.
                 and then
                   (if Write_Idx > Buffer'First
                    then
                      Valid_IE_List (Buffer (Buffer'First .. Write_Idx - 1))
                      and then
                        Write_Idx - Buffer'First
                        = IE_List_Length
                            (Buffer (Buffer'First .. Write_Idx - 1))

                      --  If a termination IE was moved, then there are no more
                      --  IEs to process
                      and then
                        (if Is_Terminated
                              (Buffer (Buffer'First .. Write_Idx - 1))
                         then Is_Last)));

            exit when Is_Last;

            Read_Idx := Next_Read_Idx;
         end;
      end loop;

      Length := Write_Idx - Buffer'First;
   end Filter_And_Transform_IE_List;

   --------------------
   -- Null_Transform --
   --------------------

   procedure Null_Transform (IE : in out Byte_Array) is null;

   ----------------------
   -- Validate_IE_List --
   ----------------------

   procedure Validate_IE_List
     (Buffer  : Byte_Array;
      Length  : out Natural;
      Result  : out Status_Code;
      Last_IE : out Positive)
   is
      Pos : Positive;

   begin
      --  Abort early if the buffer is empty.

      if Buffer'Length = 0 then
         Result := Malformed_Frame;
         Length := 0;
         Last_IE := 1;
         return;
      end if;

      --  Walk through the IE list and check that the length of each IE
      --  (as reported by the length field in the IE header) does not exceed
      --  the bounds of the Buffer.

      Pos := Buffer'First;

      loop
         pragma Loop_Variant (Increases => Pos);

         pragma Loop_Invariant (Pos in Buffer'Range);

         --  At each loop iteration, maintain that the set of IEs visited so
         --  far (in the Buffer slice ranging from Buffer'First .. Pos - 1)
         --  is a valid IE list in itself.
         --
         --  Once we prove that the next IE at position Pos is a valid IE,
         --  then we use the concat lemmas to prove that the concatenation
         --  of the IEs visited so far and the next IE form a valid IE list.

         pragma
           Loop_Invariant
             (if Pos > Buffer'First
              then
                --  The slice of Buffer containing the IEs visited so far
                --  forms a valid IE list.
                Formal_Model.Valid_IE_List
                  (Buffer (Buffer'First .. Pos - 1), Buffer'First)

                --  Pos denotes the first byte of the next IE after the ones
                --  visited so far.
                and then
                  Pos - Buffer'First
                  = Formal_Model.IE_List_Length
                      (Buffer (Buffer'First .. Pos - 1), Buffer'First)

                --  No termination IEs have been found so far
                and then
                  (for all P of
                     Formal_Model.Reachable_Set
                       (Buffer (Buffer'First .. Pos - 1), Buffer'First) =>
                     not Is_Termination_IE (IE_Header (Buffer, P))));

         --  Stop when an invalid IE is found

         if not Valid_IE (Buffer, Pos) then

            pragma Assert (not Formal_Model.Valid_IE_List (Buffer, Pos));

            if Pos > Buffer'First then
               Lemma_Valid_IE_List_Concat
                 (Buffer => Buffer,
                  X      => Buffer'First,
                  Length => Pos - Buffer'First);
            end if;

            pragma Assert (not Formal_Model.Valid_IE_List (Buffer));

            Result := Malformed_Frame;
            Length := 0;
            Last_IE := 1;
            return;
         end if;

         --  The next IE is now proven to be valid. This IE forms a valid IE
         --  list by itself when Buffer is truncated to the end of the IE.

         pragma
           Assert
             (Formal_Model.Valid_IE_List
                (Buffer (Buffer'First .. Pos + (IE_Length (Buffer, Pos) - 1)),
                 Pos));

         pragma
           Assert
             (Is_Last_IE
                (Buffer (Buffer'First .. Pos + (IE_Length (Buffer, Pos) - 1)),
                 Pos));

         --  Stop when the last IE is found.
         --
         --  The last IE can either be a termination IE, or an IE that ends
         --  at the end of the Buffer.

         if Is_Last_IE (Buffer, Pos) then

            --  The IE list starting at position Pos consists only of the last
            --  IE, so it forms a valid IE list by itself (consisting of a
            --  single IE).

            pragma Assert (Formal_Model.Valid_IE_List (Buffer, Pos));

            --  If we have visited other IEs before this one, then prove that
            --  this new IE can be concatenated with those IEs to form a
            --  complete valid IE list.

            if Pos > Buffer'First then
               Lemma_Valid_IE_List_Append
                 (Buffer => Buffer,
                  X      => Buffer'First,
                  Length => Pos - Buffer'First);

               Lemma_Reachable_Set_Append
                 (Buffer => Buffer,
                  X      => Buffer'First,
                  Length => Pos - Buffer'First);
            end if;

            --  The length of an IE list is anti-isometric w.r.t. the positions
            --  of each IE in that list, and the length of the IE list from
            --  each position.
            --
            --  This allows us to prove that the length of the IE list as a
            --  whole can be derived from Pos (which denotes the position of
            --  the last IE) and the length of the last IE, which allows us to
            --  prove that Length is set to the length of the entire IE list.

            Lemma_IE_List_Length_Anti_Isometric (Buffer, Buffer'First);

            Result := Success;
            Last_IE := Pos;
            Length := (Pos - Buffer'First) + IE_Length (Buffer, Pos);
            exit;
         end if;

         --  If this IE is not the first one, then expand the slice of Buffer
         --  to include this IE and prove that the resulting IE list in that
         --  slice is still valid.

         if Pos > Buffer'First then
            Lemma_Valid_IE_List_Append
              (Buffer =>
                 Buffer (Buffer'First .. Pos + (IE_Length (Buffer, Pos) - 1)),
               X      => Buffer'First,
               Length => Pos - Buffer'First);

            Lemma_IE_List_Length_Append
              (Buffer =>
                 Buffer (Buffer'First .. Pos + (IE_Length (Buffer, Pos) - 1)),
               X      => Buffer'First,
               Length => Pos - Buffer'First);

            Lemma_Reachable_Set_Append
              (Buffer =>
                 Buffer (Buffer'First .. Pos + (IE_Length (Buffer, Pos) - 1)),
               X      => Buffer'First,
               Length => Pos - Buffer'First);
         end if;

         --  Go to the next IE

         Pos := Next_IE_Position (Buffer, Pos);
      end loop;

   end Validate_IE_List;

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
