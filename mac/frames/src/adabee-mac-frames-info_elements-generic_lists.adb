--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Info_Elements.Generic_Lists is

   package body IE_Positions_Model is separate;
   package body IE_Model is separate;

   generic
      with procedure Transform (IE : in out Byte_Array);
   procedure Shift_And_Transform_IE
     (Buffer        : in out AdaBee.Byte_Array;
      Source_IE_Pos : in out Positive;
      Target_Pos    : in out Positive;
      Is_Last       : Boolean)
   with
     Inline,
     Pre  =>
       Buffer'Last < Positive'Last
       and then Target_Pos in Buffer'Range
       and then Source_IE_Pos in Buffer'Range
       and then Target_Pos <= Source_IE_Pos

       and then
         IE_Model.Valid_IE_List
           (Buffer (Source_IE_Pos .. Buffer'Last), Source_IE_Pos)

       and then
         Is_Last
         = Is_Last_IE (Buffer (Source_IE_Pos .. Buffer'Last), Source_IE_Pos)

       and then
         (if Target_Pos > Buffer'First
          then
            IE_Model.Valid_IE_List
              (Buffer (Buffer'First .. Target_Pos - 1), Buffer'First)

            and then
              IE_Model.IE_List_Length (Buffer (Buffer'First .. Target_Pos - 1))
              = Target_Pos - Buffer'First

            and then
              not Is_Termination_IE
                    (IE_Model.Last_IE_Header_Field
                       (Buffer (Buffer'First .. Target_Pos - 1)))),
     Post =>
       Target_Pos > Target_Pos'Old
       and then
         Target_Pos
         <= Target_Pos'Old + IE_Length (Buffer'Old, Source_IE_Pos'Old)

       and then
         Buffer (Buffer'First .. Target_Pos'Old - 1)
         = Buffer'Old (Buffer'Old'First .. Target_Pos'Old - 1)

       and then
         IE_Model.Valid_IE_List
           (Buffer (Buffer'First .. Target_Pos - 1), Buffer'First)

       and then
         Valid_IE (Buffer (Buffer'First .. Target_Pos - 1), Target_Pos'Old)

       and then
         IE_Model.IE_List_Length (Buffer (Buffer'First .. Target_Pos - 1))
         = Target_Pos - Buffer'First

       and then
         (if not Is_Last
          then
            Source_IE_Pos in Buffer'Range
            and then Target_Pos <= Source_IE_Pos
            and then
              Source_IE_Pos
              = Source_IE_Pos'Old + IE_Length (Buffer'Old, Source_IE_Pos'Old)
            and then
              IE_Model.Valid_IE_List
                (Buffer (Source_IE_Pos .. Buffer'Last), Source_IE_Pos))

       and then
         (if Is_Termination_IE
               (IE_Model.Last_IE_Header_Field
                  (Buffer (Buffer'First .. Target_Pos - 1)))
          then Is_Last);

   ----------------------------
   -- Shift_And_Transform_IE --
   ----------------------------

   procedure Shift_And_Transform_IE
     (Buffer        : in out Byte_Array;
      Source_IE_Pos : in out Positive;
      Target_Pos    : in out Positive;
      Is_Last       : Boolean)
   is
      use type IE_Positions_Model.Positions_Array;

      Empty_Positions : constant IE_Positions_Model.Positions_Array (1 .. 0) :=
        [others => 1]
      with Ghost;

      Buffer_Old : constant Byte_Array := Buffer
      with Ghost;

      Target_Pos_Old : constant Positive := Target_Pos
      with Ghost;

      Source_IE_Pos_Old : constant Positive := Source_IE_Pos
      with Ghost;

      Target_Positions : constant IE_Positions_Model.Positions_Array :=
        (if Target_Pos = Buffer'First
         then Empty_Positions
         else
           IE_Positions_Model.IE_Positions
             (Buffer (Buffer'First .. Target_Pos - 1)))
      with Ghost;

      Source_Positions : constant IE_Positions_Model.Positions_Array :=
        IE_Positions_Model.IE_Positions (Buffer (Source_IE_Pos .. Buffer'Last))
      with Ghost;

      Source_IE_Length : constant Positive :=
        IE_Length (Buffer, Source_IE_Pos);
      Target_IE_Length : Positive;

   begin
      if Target_Pos /= Source_IE_Pos then
         Buffer (Target_Pos .. Target_Pos + (Source_IE_Length - 1)) :=
           Buffer (Source_IE_Pos .. Source_IE_Pos + (Source_IE_Length - 1));
      end if;

      Transform (Buffer (Target_Pos .. Target_Pos + (Source_IE_Length - 1)));

      if not Is_Last then
         Source_IE_Pos := Source_IE_Pos + Source_IE_Length;
      end if;

      Target_IE_Length := IE_Length (Buffer, Target_Pos);
      Target_Pos := Target_Pos + Target_IE_Length;

      --  Transform can shorten the IE, but it cannot lengthen it

      pragma
        Assert
          (IE_Length (Buffer, Target_Pos_Old)
           <= IE_Length (Buffer_Old, Source_IE_Pos_Old));

      --  Prove that the Target IE list is still a valid IE list

      if Target_Pos - Target_IE_Length /= Buffer'First then

         --  First, establish that all existing IEs in the target IE list are
         --  unchanged.

         IE_Positions_Model.Lemma_IEs_Preserved
           (Buffer_Old (Buffer_Old'First .. Target_Pos_Old - 1),
            Buffer (Buffer'First .. Target_Pos - 1),
            Target_Positions);

         declare
            New_Target_Positions :
              constant IE_Positions_Model.Positions_Array :=
                Target_Positions & [Target_Pos_Old]
            with Ghost;
         begin

            --  Prove that Target_Pos_Old denotes the next byte after the last
            --  IE.

            IE_Positions_Model.Lemma_Positions_IE_List_Length
              (Buffer_Old (Buffer_Old'First .. Target_Pos_Old - 1),
               Target_Positions);

            IE_Positions_Model.Lemma_IE_List_Length
              (Buffer_Old (Buffer_Old'First .. Target_Pos_Old - 1),
               Target_Positions,
               Target_Pos_Old - Buffer'First);

            --  Help prove that the last IE was not a termination IE.

            IE_Positions_Model.Lemma_Last_IE_Header
              (Buffer_Old (Buffer_Old'First .. Target_Pos_Old - 1),
               Target_Positions);

            pragma
              Assert
                (not Is_Termination_IE
                       (IE_Header
                          (Buffer, Target_Positions (Target_Positions'Last))));

            --  Prove that the new IE is placed immediately after the previous
            --  last IE.

            pragma
              Assert
                (New_Target_Positions (New_Target_Positions'Last)
                 = Next_IE_Position
                     (Buffer (Buffer'First .. Target_Pos - 1),
                      New_Target_Positions (New_Target_Positions'Last - 1)));

            --  Help prove that the new IE is valid

            pragma
              Assert
                (Valid_IE
                   (Buffer (Buffer'First .. Target_Pos - 1), Target_Pos_Old));

            --  Now we can establish that we have a valid set of positions

            pragma
              Assert
                (IE_Positions_Model.Valid_Positions
                   (Buffer (Buffer'First .. Target_Pos - 1),
                    New_Target_Positions));

            --  Finally, we can prove that the IE list is valid

            IE_Positions_Model.Lemma_Valid_IE_List
              (Buffer (Buffer'First .. Target_Pos - 1), New_Target_Positions);

            --  Next, prove that the Target_Pos - Buffer'First denotes the
            --  length of the IE list.

            IE_Positions_Model.Lemma_IE_List_Length
              (Buffer (Buffer'First .. Target_Pos - 1),
               New_Target_Positions,
               Target_Pos - Buffer'First);

            --  Next, prove that the termination IE status is preserved during
            --  the move.

            IE_Positions_Model.Lemma_Last_IE_Header
              (Buffer (Buffer'First .. Target_Pos - 1), New_Target_Positions);

            pragma
              Assert
                (Is_Termination_IE
                   (IE_Model.Last_IE_Header_Field
                      (Buffer (Buffer'First .. Target_Pos - 1)))
                 = Is_Termination_IE
                     (IE_Header (Buffer_Old, Source_IE_Pos_Old)));

            --  Cut the proof context size

            pragma
              Assert_And_Cut
                (IE_Model.Valid_IE_List
                   (Buffer (Buffer'First .. Target_Pos - 1))

                 and then
                   Target_Pos - Buffer'First
                   = IE_Model.IE_List_Length
                       (Buffer (Buffer'First .. Target_Pos - 1))

                 and then
                   Valid_IE
                     (Buffer (Buffer'First .. Target_Pos - 1), Target_Pos_Old)

                 and then
                   (if Is_Termination_IE
                         (IE_Model.Last_IE_Header_Field
                            (Buffer (Buffer'First .. Target_Pos - 1)))
                    then Is_Last));
         end;
      end if;

      --  Prove that the source IE list is still valid, starting from the
      --  IE after the one that was moved.

      if not Is_Last then
         declare
            New_Source_Positions :
              constant IE_Positions_Model.Positions_Array :=
                Source_Positions
                  (Source_Positions'First + 1 .. Source_Positions'Last)
            with Ghost;
         begin
            IE_Positions_Model.Lemma_IEs_Preserved
              (A         => Buffer_Old (Source_IE_Pos_Old .. Buffer_Old'Last),
               B         => Buffer (Source_IE_Pos .. Buffer'Last),
               Positions => New_Source_Positions);

            IE_Positions_Model.Lemma_Valid_IE_List
              (Buffer (Source_IE_Pos .. Buffer'Last), New_Source_Positions);
         end;
      end if;
   end Shift_And_Transform_IE;

   ---------------
   -- Append_IE --
   ---------------

   procedure Append_IE
     (Buffer : in out Byte_Array; Length : in out Natural; IE : Byte_Array)
   is
      use type IE_Positions_Model.Positions_Array;

      IE_List_Old : constant Byte_Array :=
        Buffer (Buffer'First .. Buffer'First + (Length - 1))
      with Ghost;

      Length_Old : constant Natural := Length;

   begin
      Buffer
        (Buffer'First + Length .. Buffer'First + Length + (IE'Length - 1)) :=
        IE;

      Length := Length + IE'Length;

      declare
         IE_List : constant Byte_Array :=
           Buffer (Buffer'First .. Buffer'First + (Length - 1))
         with Ghost;
      begin

         pragma Assert (Valid_IE (IE_List, Buffer'First + Length_Old));

         pragma
           Assert
             (IE_Header (IE_List, Buffer'First + Length_Old)
              = IE_Header (IE, IE'First));

         if Length > IE'Length then
            IE_Model.Lemma_Valid_IE_List_Preserved
              (IE_List_Old,
               IE_List (Buffer'First .. Buffer'First + (Length_Old - 1)));

            IE_Model.Lemma_IE_List_Length_Preserved
              (IE_List_Old,
               IE_List (Buffer'First .. Buffer'First + (Length_Old - 1)));

            IE_Model.Lemma_Last_IE_Header_Field_Preserved
              (IE_List_Old,
               IE_List (Buffer'First .. Buffer'First + (Length_Old - 1)));
         end if;

         IE_Model.Lemma_IE_List_Extend
           (Buffer => IE_List, L1 => Length_Old, L2 => Length);
      end;

   end Append_IE;

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

      Positions : IE_Positions_Model.Positions_Array (1 .. Buffer'Length) :=
        [others => 1]
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
            IE_Positions_Model.Lemma_Invalid_IE_List
              (Buffer, Positions (1 .. IE_Count));

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

      IE_Positions_Model.Lemma_Valid_IE_List
        (Buffer, Positions (1 .. IE_Count));

      IE_Positions_Model.Lemma_IE_List_Length
        (Buffer, Positions (1 .. IE_Count), Length);

      IE_Positions_Model.Lemma_Position_Reachable
        (Buffer, Positions (1 .. IE_Count), Last_IE);

      IE_Positions_Model.Lemma_Last_IE_Header
        (Buffer, Positions (1 .. IE_Count));
   end Validate_IE_List;

   ----------------------------------
   -- Filter_And_Transform_IE_List --
   ----------------------------------

   procedure Filter_And_Transform_IE_List
     (Buffer : in out Byte_Array; Length : out Natural)
   is

      procedure Move_IE is new Shift_And_Transform_IE (Transform);

      R : Positive := Buffer'First; --  read pointer
      W : Positive := Buffer'First; --  write pointer

      Is_Last : Boolean;
   begin

      loop
         pragma Loop_Variant (Increases => R);

         pragma Loop_Invariant (W in Buffer'Range);
         pragma Loop_Invariant (R in Buffer'Range);
         pragma Loop_Invariant (W <= R);

         pragma
           Loop_Invariant
             (if W > Buffer'First
              then
                IE_Model.Valid_IE_List
                  (Buffer (Buffer'First .. W - 1), Buffer'First)
                and then
                  W - Buffer'First
                  = IE_Model.IE_List_Length (Buffer (Buffer'First .. W - 1))
                and then
                  not Is_Termination_IE
                        (IE_Model.Last_IE_Header_Field
                           (Buffer (Buffer'First .. W - 1))));

         pragma
           Loop_Invariant
             (IE_Model.Valid_IE_List (Buffer (R .. Buffer'Last), R));

         Is_Last := Is_Last_IE (Buffer (R .. Buffer'Last), R);

         if Filter (Buffer (R .. Buffer'Last)) then

            Move_IE
              (Buffer        => Buffer,
               Source_IE_Pos => R,
               Target_Pos    => W,
               Is_Last       => Is_Last);

         elsif not Is_Last then
            R := Next_IE_Position (Buffer (R .. Buffer'Last), R);

            pragma
              Assert
                (if not Is_Last
                 then IE_Model.Valid_IE_List (Buffer (R .. Buffer'Last), R));
         end if;

         exit when Is_Last;
      end loop;

      Length := W - Buffer'First;
   end Filter_And_Transform_IE_List;

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
