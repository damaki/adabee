--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Info_Elements.Payloads
  with SPARK_Mode
is

   procedure Lemma_Nested_IE_Lists_Valid_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Ghost,
     Pre  =>
       --  X and Length must be within range of Buffer
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1

       --  The IE at position X must be the last IE
       and then Payloads.Lists.Valid_IE (Buffer, X + Length)
       and then Payloads.Lists.Is_Last_IE (Buffer, X + Length)

       --  The partial IE list at position X must be a valid IE list
       and then
         Payloads.Lists.Formal_Model.Valid_IE_List
           (Buffer (Buffer'First .. X + (Length - 1)), X)

       --  If the IE at position X is an MLME IE, then it must contain a valid
       --  nested IE list.
       and then
         (declare
            Header : constant Header_Field :=
              Lists.IE_Header (Buffer, X + Length);
          begin
            (if Header.Group_ID = MLME_IE and then Header.Length > 0
             then
               Nested.Lists.Formal_Model.Valid_IE_List
                 (Payloads.Lists.Formal_Model.IE_Content
                    (Buffer, X + Length))))

       --  Length is the length of the IE list subset up to (and excluding
       --  position X).
       and then
         Length
         = Payloads.Lists.Formal_Model.IE_List_Length
             (Buffer (Buffer'First .. X + (Length - 1)), X)

       --  All nested IE lists before X are valid IE lists
       and then
         Nested_IE_Lists_Valid (Buffer (Buffer'First .. X + (Length - 1)), X)

       and then
         not Lists.Formal_Model.Is_Terminated
               (Buffer (Buffer'First .. X + (Length - 1)), X),
     Post => Nested_IE_Lists_Valid (Buffer, X);

   procedure Lemma_Nested_IE_Lists_Invalid
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Ghost,
     Pre  =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then
         Payloads.Lists.Formal_Model.Valid_IE_List
           (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then Payloads.Lists.Valid_IE (Buffer, X + Length)
       and then
         (declare
            Header : constant Header_Field :=
              Lists.IE_Header (Buffer, X + Length);
          begin
            Header.Group_ID = MLME_IE
            and then Header.Length > 0
            and then
              not Nested.Lists.Formal_Model.Valid_IE_List
                    (Payloads.Lists.Formal_Model.IE_Content
                       (Buffer, X + Length)))
       and then
         Length
         = Payloads.Lists.Formal_Model.IE_List_Length
             (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Lists.Formal_Model.Is_Terminated
               (Buffer (Buffer'First .. X + (Length - 1)), X),
     Post =>
       (if Payloads.Lists.Formal_Model.Valid_IE_List (Buffer, X)
        then not Nested_IE_Lists_Valid (Buffer, X));

   ----------------------------------------
   -- Lemma_Nested_IE_Lists_Valid_Append --
   ----------------------------------------

   procedure Lemma_Nested_IE_Lists_Valid_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive) is
   begin
      Lemmas.Lemma_Valid_IE_List_Append (Buffer, X, Length);
      Lemmas.Lemma_IE_List_Length_Append (Buffer, X, Length);
      Lemmas.Lemma_Reachable_Set_Append (Buffer, X, Length);

      Lemmas.Lemma_Reachable_IE_Headers_Preserved_Prefix
        (Buffer (Buffer'First .. X + (Length - 1)), B2 => Buffer, X => X);

      Lemmas.Lemma_Reachable_IE_Content_Preserved_Prefix
        (Buffer (Buffer'First .. X + (Length - 1)), B2 => Buffer, X => X);
   end Lemma_Nested_IE_Lists_Valid_Append;

   -----------------------------------
   -- Lemma_Nested_IE_Lists_Invalid --
   -----------------------------------

   procedure Lemma_Nested_IE_Lists_Invalid
     (Buffer : Byte_Array; X : Positive; Length : Positive) is
   begin
      Payloads.Lemmas.Lemma_Valid_IE_List_Concat (Buffer, X, Length);

      if Payloads.Lists.Formal_Model.Valid_IE_List (Buffer, X + Length) then
         Payloads.Lemmas.Lemma_Reachable_Set_Concat (Buffer, X, Length);

         pragma Assert (not Nested_IE_Lists_Valid (Buffer, X));
      end if;
   end Lemma_Nested_IE_Lists_Invalid;

   ------------------------------------------
   -- Validate_Payload_And_Nested_IE_Lists --
   ------------------------------------------

   procedure Validate_Payload_And_Nested_IE_Lists
     (Buffer  : Byte_Array;
      Length  : out Natural;
      Result  : out Status_Code;
      Last_IE : out Positive)
   is
      use Lists;
      use Lemmas;

      Pos    : Positive;
      Header : Header_Field;

      Unused_Length  : Natural;
      Unused_Last_IE : Positive;

   begin
      --  Abort early if the buffer is empty.

      if Buffer'Length = 0 then
         Result := Malformed_Frame;
         Length := 0;
         Last_IE := 1;
         return;
      end if;

      --  Walk through the IE list and check that:
      --   1. the length of each IE (as reported by the length field in the
      --      IE header) does not exceed the bounds of the Buffer; and
      --   2. if the IE is an MLME IE, then if the content field is non-empty
      --      then it contains a valid nested IE list.

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

         pragma
           Loop_Invariant
             (if Pos > Buffer'First
              then
                Nested_IE_Lists_Valid
                  (Buffer (Buffer'First .. Pos - 1), Buffer'First));

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

         --  Check nested IE lists

         Header := IE_Header (Buffer, Pos);

         if Header.Group_ID = MLME_IE and then Header.Length > 0 then
            Nested.Lists.Validate_IE_List
              (Buffer  =>
                 Buffer
                   (Pos + IE_Header_Length
                    .. Pos + IE_Header_Length + (Natural (Header.Length) - 1)),
               Length  => Unused_Length,
               Result  => Result,
               Last_IE => Unused_Last_IE);

            if Result /= Success then
               if Pos > Buffer'First then
                  Lemma_Valid_IE_List_Concat
                    (Buffer => Buffer,
                     X      => Buffer'First,
                     Length => Pos - Buffer'First);

                  Lemma_Nested_IE_Lists_Invalid
                    (Buffer => Buffer,
                     X      => Buffer'First,
                     Length => Pos - Buffer'First);
               end if;

               Length := 0;
               Last_IE := 1;
               return;
            end if;
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

               Lemma_Nested_IE_Lists_Valid_Append
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

            Lemma_Nested_IE_Lists_Valid_Append
              (Buffer =>
                 Buffer (Buffer'First .. Pos + (IE_Length (Buffer, Pos) - 1)),
               X      => Buffer'First,
               Length => Pos - Buffer'First);
         end if;

         --  Go to the next IE

         Pos := Next_IE_Position (Buffer, Pos);
      end loop;
   end Validate_Payload_And_Nested_IE_Lists;

end AdaBee.MAC.Frames.Info_Elements.Payloads;
