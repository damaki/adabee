--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with SPARK.Big_Integers;
with SPARK.Containers.Functional.Sets;
with SPARK.Containers.Functional.Vectors;

--  This package provides a formal model of IE lists, and operations for
--  validating and manipulating information element (IE) lists.

generic
   type Header_Field (<>) is private;
   type Length_Type is range <>;

   with function From_Bytes (Bytes : Byte_Array_2) return Header_Field;
   --  Converts a 2-byte array to an IE field header

   with function Content_Length (Header : Header_Field) return Length_Type;
   --  Gets the length field from the IE header

   with function Is_Termination_IE (Header : Header_Field) return Boolean;
   --  Returns True if the IE is a termination IE, or False otherwise.

package AdaBee.MAC.Frames.Info_Elements.Generic_Lists
is

   use type SPARK.Big_Integers.Big_Integer;

   -------------------
   -- IE attributes --
   -------------------

   --  These subprograms are helpers to read various attributes of an IE

   function IE_Header (Buffer : Byte_Array; Pos : Positive) return Header_Field
   is (From_Bytes (Buffer (Pos .. Pos + 1)))
   with Pre => Pos in Buffer'Range and then Pos < Buffer'Last;
   --  Convert from Bytes to a Header_Field type

   function Content_Length
     (Buffer : Byte_Array; Pos : Positive) return Length_Type
   is (Content_Length (IE_Header (Buffer, Pos)))
   with Pre => Pos in Buffer'Range and then Pos < Buffer'Last;
   --  Get the length of the content field of an information element in bytes.

   function IE_Length (Buffer : Byte_Array; Pos : Positive) return Positive
   is (IE_Header_Length + Natural (Content_Length (Buffer, Pos)))
   with Pre => Pos in Buffer'Range and then Pos < Buffer'Last;
   --  Get the total length (in bytes) of an information element, including
   --  both the header and content fields.

   function Valid_IE (Buffer : Byte_Array; Pos : Positive) return Boolean
   is (Pos < Buffer'Last
       and then IE_Length (Buffer, Pos) <= (Buffer'Last - Pos) + 1)
   with Pre => Pos in Buffer'Range;
   --  Check whether an information element at position Pos fits within the
   --  bounds of the Buffer. This returns False when the IE's reported length
   --  exceeds the bounds of the Buffer.

   function Content_First (Buffer : Byte_Array; Pos : Positive) return Positive
   is (Pos + IE_Header_Length)
   with
     Pre =>
       Pos in Buffer'Range
       and then Valid_IE (Buffer, Pos)
       and then Content_Length (Buffer, Pos) > 0;
   --  Get the index in Buffer of the first byte of the IE content

   function Content_Last (Buffer : Byte_Array; Pos : Positive) return Positive
   is (Pos + IE_Header_Length + (Natural (Content_Length (Buffer, Pos)) - 1))
   with
     Pre =>
       Pos in Buffer'Range
       and then Valid_IE (Buffer, Pos)
       and then Content_Length (Buffer, Pos) > 0;
   --  Get the index in Buffer of the last byte of the IE content

   ------------------
   -- IE Iteration --
   ------------------

   function Is_Last_IE (Buffer : Byte_Array; Pos : Positive) return Boolean
   is (Is_Termination_IE (From_Bytes (Buffer (Pos .. Pos + 1)))
       or else IE_Length (Buffer, Pos) = (Buffer'Last - Pos) + 1)
   with Pre => Pos in Buffer'Range and then Valid_IE (Buffer, Pos);
   --  Returns True if the IE at position Pos in Buffer is the last IE in the
   --  IE list.
   --
   --  The last IE is one that is either a termination IE, or is an IE that
   --  ends at the end of the buffer.
   --
   --  @param Buffer The Buffer containing an IE list.
   --  @param Pos The position in Buffer of the IE to check.
   --
   --  @return True if the IE referenced by Pos is the last IE in the list,
   --    or False otherwise.

   function Next_IE_Position
     (Buffer : Byte_Array; Pos : Positive) return Positive
   is (Pos + IE_Length (Buffer, Pos))
   with
     Pre      =>
       Pos in Buffer'Range
       and then Valid_IE (Buffer, Pos)
       and then not Is_Last_IE (Buffer, Pos),
     Annotate => (GNATprove, Inline_For_Proof);
   --  Given the position Pos of an information element in Buffer, get the
   --  position of the next IE in Buffer.
   --
   --  @param Buffer The Buffer containing an IE list.
   --  @param Pos The position in Buffer of the current IE in the list.
   --    This must reference a valid IE and must not be the last IE.
   --
   --  @return The position in Buffer of the next IE.

   ------------------
   -- Formal Model --
   ------------------

   --  This formal model provides definitions and models for reasoning about
   --  IE lists.
   --
   --  It provides the following recursive definitions:
   --   * Valid_IE_List:  True if the IE list either ends in a termination IE,
   --                     or ends exactly at the end of the buffer.
   --   * IE_List_Length: The length (in bytes) of an IE list.
   --   * IE_Count:       The number of IEs in an IE list.
   --
   --  It also provides the following formal models over IE lists:
   --   * Reachable_Set: Models the set of IE positions that are reachable from
   --                    the start of an IE list.
   --   * Model:         Models the sequence of IE positions in the reverse
   --                    order they are visited from the start of the IE list
   --                    (note that the reverse order means that the last IE
   --                    appears first in the sequence).
   --
   --  It also provides many useful lemmas for proving that the above
   --  properties and models are preserved after an IE list is moved or
   --  modified.

   package Formal_Model
     with Ghost
   is

      function Big (Value : Integer) return SPARK.Big_Integers.Big_Integer
      renames SPARK.Big_Integers.To_Big_Integer;

      package S is new SPARK.Containers.Functional.Sets (Positive);
      use type S.Set;

      package V is new
        SPARK.Containers.Functional.Vectors
          (Index_Type   => Positive,
           Element_Type => Positive);
      use type V.Sequence;

      function IE_Content
        (Buffer : Byte_Array; Pos : Positive) return Byte_Array
      is (if Content_Length (Buffer, Pos) = 0
          then Empty_Byte_Array
          else
            Buffer (Content_First (Buffer, Pos) .. Content_Last (Buffer, Pos)))
      with Pre => Pos in Buffer'Range and then Valid_IE (Buffer, Pos);
      --  Get the content field of the IE at postion Pos in Buffer

      ----------------------
      -- IE List Validity --
      ----------------------

      function Valid_IE_List
        (Buffer : Byte_Array; Pos : Positive) return Boolean
      is (Pos in Buffer'Range
          and then Valid_IE (Buffer, Pos)
          and then
            (if not Is_Last_IE (Buffer, Pos)
             then Valid_IE_List (Buffer, Next_IE_Position (Buffer, Pos))))
      with Subprogram_Variant => (Increases => Pos);
      --  Returns True if the IE list in Buffer is a valid IE list, starting at
      --  the IE at position Pos in the Buffer.
      --
      --  A valid IE list is one where:
      --   * all IEs in the list are within the bounds of the Buffer.
      --     In other words, there are no IEs whose length field would exceed
      --     the bounds of Buffer.
      --   * the list ends with a termination IE, or the last IE ends at
      --     exactly the end of the buffer.

      function Valid_IE_List (Buffer : Byte_Array) return Boolean
      is (Buffer'Length > 0 and then Valid_IE_List (Buffer, Buffer'First));
      --  Returns True if the IE list in Buffer is a valid IE list, starting at
      --  the IE at the beginning of the Buffer.

      --------------------
      -- IE List Length --
      --------------------

      function IE_List_Length
        (Buffer : Byte_Array; Pos : Positive) return Positive
      is (if Is_Last_IE (Buffer, Pos)
          then IE_Length (Buffer, Pos)
          else
            IE_Length (Buffer, Pos)
            + IE_List_Length (Buffer, Next_IE_Position (Buffer, Pos)))
      with
        Pre                =>
          Pos in Buffer'Range and then Valid_IE_List (Buffer, Pos),
        Post               =>
          IE_List_Length'Result in 2 .. (Buffer'Last - Pos) + 1,
        Subprogram_Variant => (Increases => Pos);
      --  Calculates the length of a valid IE list, in bytes, starting
      --  with the IE at position Pos in the Buffer.

      function IE_List_Length (Buffer : Byte_Array) return Positive
      is (IE_List_Length (Buffer, Buffer'First))
      with
        Pre  => Valid_IE_List (Buffer),
        Post => IE_List_Length'Result in 2 .. Buffer'Length;
      --  Calculates the length of a valid IE list, in bytes, starting
      --  with the IE at the beginning of Buffer.

      -------------------
      -- IE List Count --
      -------------------

      function IE_Count (Buffer : Byte_Array; Pos : Positive) return Positive
      is (if Is_Last_IE (Buffer, Pos)
          then 1
          else 1 + IE_Count (Buffer, Next_IE_Position (Buffer, Pos)))
      with
        Pre                =>
          Pos in Buffer'Range and then Valid_IE_List (Buffer, Pos),
        Post               =>
          IE_Count'Result <= IE_List_Length (Buffer, Pos) / 2,
        Subprogram_Variant => (Increases => Pos);
      --  Count the number of IEs in the list starting at the IE at index Pos
      --  in Buffer.

      -------------------------
      -- Models over IE List --
      -------------------------

      function Reachable_Set
        (Buffer : Byte_Array; From : Positive) return S.Set
      is (if Is_Last_IE (Buffer, From)
          then S.Add (S.Empty_Set, From)
          else
            S.Add
              (Reachable_Set (Buffer, Next_IE_Position (Buffer, From)), From))
      with
        Pre                => Valid_IE_List (Buffer, From),
        Post               =>
          S.Length (Reachable_Set'Result) = Big (IE_Count (Buffer, From))
          and then S.Contains (Reachable_Set'Result, From)
          and then
            (for all X of Reachable_Set'Result =>
               X in Buffer'Range
               and then X >= From
               and then Valid_IE (Buffer, X)
               and then Valid_IE_List (Buffer, X)),
        Subprogram_Variant => (Increases => From);
      --  The set of positions of all IEs reachable in the IE list starting at
      --  position From in Buffer.

      function Model (Buffer : Byte_Array; From : Positive) return V.Sequence
      is (if Is_Last_IE (Buffer, From)
          then V.Add (V.Empty_Sequence, From)
          else V.Add (Model (Buffer, Next_IE_Position (Buffer, From)), From))
      with
        Pre                => Valid_IE_List (Buffer, From),
        Post               =>
          V.Length (Model'Result) = Big (IE_Count (Buffer, From))

          --  Every position in the Model is reachable from position From
          and then
            (for all X of Model'Result =>
               S.Contains (Reachable_Set (Buffer, From), X))

          --  Every reachable position is in the Model
          and then
            (for all X of Reachable_Set (Buffer, From) =>
               V.Contains (Model'Result, V.First, V.Last (Model'Result), X))

          --  Positions are unique
          and then
            (for all I in Model'Result =>
               (for all J in Model'Result =>
                  (I = J)
                  = (V.Get (Model'Result, I) = V.Get (Model'Result, J))))

          --  The sequence is in reverse order, so From is at the end of the
          --  and the last IE is always the first position in the sequence.
          and then V.Get (Model'Result, V.Last (Model'Result)) = From
          and then
            (for all I in Model'Result =>
               (I = V.First) = Is_Last_IE (Buffer, V.Get (Model'Result, I)))

          --  Each item is the next position of the one before
          and then
            (for all I in 1 .. V.Last (Model'Result) - 1 =>
               V.Get (Model'Result, I)
               = Next_IE_Position (Buffer, V.Get (Model'Result, I + 1))),
        Subprogram_Variant => (Increases => From);
      --  The sequence of IE positions that are reachable from the IE list
      --  starting at position From in Buffer.
      --
      --  Note that the sequence is in reverse order, with the first IE
      --  position at the last index of the sequence. This reverse order is
      --  what makes the model of an IE position reachable from From a prefix
      --  of the model of From, so that segments of the structure can be
      --  expressed using "<=" and Range_Shifted on sequences.

      ------------------
      -- Reachability --
      ------------------

      function Reachable
        (X : Positive; Buffer : Byte_Array; Y : Positive) return Boolean
      is (S.Contains (Reachable_Set (Buffer, X), Y))
      with
        Pre      => Valid_IE_List (Buffer, X),
        Annotate => (GNATprove, Inline_For_Proof);
      --  True if the IE at position Y is reachable from the IE at position X

      ---------------------
      -- Last IE headers --
      ---------------------

      function Last_IE_Position
        (Buffer : Byte_Array; X : Positive) return Positive
      is (V.Get (Model (Buffer, X), V.First))
      with
        Pre      => Valid_IE_List (Buffer, X),
        Annotate => (GNATprove, Inline_For_Proof);
      --  Get the position of the last IE in the list starting at position X

      function Last_IE_Header
        (Buffer : Byte_Array; X : Positive) return Header_Field
      is (IE_Header (Buffer, Last_IE_Position (Buffer, X)))
      with
        Pre      => Valid_IE_List (Buffer, X),
        Annotate => (GNATprove, Inline_For_Proof);
      --  Get the header field of the last IE in the list starting from the
      --  list at position X.

      -----------------
      -- Termination --
      -----------------

      function Is_Terminated (Buffer : Byte_Array; X : Positive) return Boolean
      is (Is_Termination_IE (Last_IE_Header (Buffer, X)))
      with
        Pre      => Valid_IE_List (Buffer, X),
        Annotate => (GNATprove, Inline_For_Proof);
      --  Returns True if the IE list starting at position X in Buffer ends
      --  with a termination IE.

      function Is_Terminated (Buffer : Byte_Array) return Boolean
      is (Is_Terminated (Buffer, Buffer'First))
      with
        Pre      => Valid_IE_List (Buffer),
        Annotate => (GNATprove, Inline_For_Proof);
      --  Returns True if the IE list in Buffer ends with a termination IE

   end Formal_Model;
   use Formal_Model;
   use type S.Set;

   ------------------------
   -- IE List Operations --
   ------------------------

   procedure Validate_IE_List
     (Buffer  : Byte_Array;
      Length  : out Natural;
      Result  : out Status_Code;
      Last_IE : out Positive)
   with
     Global => null,
     Post   =>
       Result in Success | Malformed_Frame
       and then (Result = Success) = Valid_IE_List (Buffer)
       and then
         (if Result = Success
          then
            Length in 2 .. Buffer'Length
            and then Length = IE_List_Length (Buffer, Buffer'First)
            and then Last_IE = Last_IE_Position (Buffer, Buffer'First)
            and then (if Length < Buffer'Length then Is_Terminated (Buffer)));
   --  Walks through an IE list to calculate its length and to verify that the
   --  IE list is well formed.
   --
   --  @param Buffer The Buffer containing the IE list. The first IE is at the
   --    start of the buffer.
   --  @param Length The length of the IE list in bytes.
   --  @param Result Success if the IE list is well formed, or Malformed_Frame
   --    if the IE list is not well formed.
   --  @param Last_IE The index of the last IE in the IE list. This is valid
   --    only when Result = Success.

   procedure Append_IE
     (Buffer : in out Byte_Array; Length : in out Natural; IE : Byte_Array)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Pre                    =>
       --  IE must contain a valid IE that is sized to fit the IE exactly
       IE'Length > 0
       and then Valid_IE (IE, IE'First)
       and then IE'Length = IE_Length (IE, IE'First)

       --  If Length is zero, then the first Length bytes in Buffer must be
       --  a valid IE list that does not end in a termination IE, and Length
       --  must be the length of that list.
       and then Length <= Buffer'Length
       and then Buffer'Length - Length >= IE'Length
       and then
         Buffer (Buffer'First .. Buffer'First + (Length - 1))'Initialized
       and then
         (if Length > 0
          then
            (declare
               IE_List : Byte_Array renames
                 Buffer (Buffer'First .. Buffer'First + (Length - 1));
             begin
               Valid_IE_List (IE_List)
               and then Length = IE_List_Length (IE_List)
               and then not Is_Terminated (IE_List))),
     Post                   =>
       (declare
          IE_List_Old : Byte_Array renames
            Buffer'Old (Buffer'First .. Buffer'First + (Length'Old - 1));
          --  The slice of Buffer that contains the previous IE list, before
          --  appending.

          IE_List : Byte_Array renames
            Buffer (Buffer'First .. Buffer'First + (Length - 1));
          --  The slice of Buffer that contains the updated IE list

          New_IE_Pos : constant Positive := Buffer'First + Length'Old;
          --  The position of the new IE that was appended
        begin
        --  The length has increased by the IE's length
          Length <= Buffer'Length
          and then Length = Length'Old + IE_Length (IE, IE'First)
          and then
            IE_List'Initialized

            --  The resulting IE list is a valid IE list
          and then Valid_IE_List (IE_List)

          and then
            --  If the previous IE list was empty, then it consists of the new
            --  IE as the sole IE in the list. Otherwise, the new IE is
            --  appended to the existing list and all existing IEs are
            --  unchanged.
            (if Length'Old = 0
             then
               --  IE is the the sole IE in the list
               IE_Count (IE_List, IE_List'First) = 1
               and then IE_List_Length (IE_List, IE_List'First) = IE'Length
               and then
                 IE_Header (IE_List, IE_List'First) = IE_Header (IE, IE'First)
               and then
                 IE_Content (IE_List, IE_List'First)
                 = IE_Content (IE, IE'First)

             else
               --  Any previous data in Buffer is unchanged
               IE_List (IE_List_Old'Range) = IE_List_Old

               --  The set of reachable IEs has been extended with New_IE_Pos
               and then
                 Reachable_Set (IE_List_Old, IE_List_Old'First)
                 <= Reachable_Set (IE_List, IE_List'First)
               and then
                 S.Included_Except
                   (Reachable_Set (IE_List, IE_List'First),
                    Reachable_Set (IE_List_Old, IE_List_Old'First),
                    New_IE_Pos)

               --  A new IE position has been added to the model as the last IE
               --  (note that the model sequence is in reverse order, so the
               --  last IE is first in the sequence).
               and then
                 (declare
                    M     : constant V.Sequence :=
                      Model (IE_List, IE_List'First);
                    M_Old : constant V.Sequence :=
                      Model (IE_List_Old, IE_List_Old'First);
                  begin
                    V.Length (M) = V.Length (M_Old) + 1
                    and then
                      (for all I in M =>
                         (if I = V.First
                          then V.Get (M, I) = New_IE_Pos
                          else V.Get (M, I) = V.Get (M_Old, I - 1))))

               --  The IE headers and content of existing IEs are preserved
               and then
                 (for all P of
                    Reachable_Set (IE_List_Old, IE_List_Old'First) =>
                    IE_Header (IE_List, P) = IE_Header (IE_List_Old, P)
                    and then
                      IE_Content (IE_List, P) = IE_Content (IE_List_Old, P))));

   generic

      type Writer_Context (<>) is limited private;

      with
        function Precondition (Ctx : Writer_Context) return Boolean
        with Ghost;

      with
        function Required_Content_Length (Ctx : Writer_Context) return Natural
        with Pre => Precondition (Ctx);
      --  The maximum length of the IE's content field that can be written
      --  by Write_IE.

      with
        function IE_Property
          (Header : Header_Field; Content : Byte_Array) return Boolean;
      --  Function to express a custom property over an IE.
      --
      --  This is useful to prove that a specific IE type has been added.
      --  For example, to prove that the new IE is a termination IE (or not).

      with
        procedure Write_IE
          (IE : out Byte_Array; Length : out Positive; Ctx : Writer_Context);
   procedure Append_IE_Inplace_With_Context
     (Buffer : in out Byte_Array;
      Length : in out Natural;
      Ctx    : Writer_Context)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Pre                    =>
       Length <= Buffer'Length
       and then
         Buffer'Length - Length
         >= IE_Header_Length + Required_Content_Length (Ctx)
       and then
         Buffer (Buffer'First .. Buffer'First + (Length - 1))'Initialized
       and then
         (if Length > 0
          then
            (declare
               IE_List : Byte_Array renames
                 Buffer (Buffer'First .. Buffer'First + (Length - 1));
             begin
               Valid_IE_List (IE_List)
               and then Length = IE_List_Length (IE_List)
               and then not Is_Terminated (IE_List)))
       and then Precondition (Ctx),
     Post                   =>
       (declare
          IE_List_Old : Byte_Array renames
            Buffer'Old (Buffer'First .. Buffer'First + (Length'Old - 1));

          IE_List : Byte_Array renames
            Buffer (Buffer'First .. Buffer'First + (Length - 1));
        begin
        --  Length has increased by the length of the new IE
          Length <= Buffer'Length
          and then
            Length
            = Length'Old + IE_Header_Length + Required_Content_Length (Ctx)

          --  Buffer is now initialized up to the new Length
          and then
            IE_List'Initialized

            --  The new IE list is valid
          and then Valid_IE_List (IE_List)

          --  The IE_Property holds for the appended IE
          and then
            IE_Property
              (Header  =>
                 IE_Header
                   (IE_List, Last_IE_Position (IE_List, IE_List'First)),
               Content =>
                 IE_Content
                   (IE_List, Last_IE_Position (IE_List, IE_List'First)))

          --  If the IE list was previously empty, then the new IE becomes the
          --  sole IE in the list. Otherwise, the IE list is increased by an
          --  extra IE and all other IEs are preserved.
          and then
            (if Length'Old = 0
             then
               IE_Count (IE_List, IE_List'First) = 1
               and then
                 IE_List_Length (IE_List)
                 = IE_Header_Length + Required_Content_Length (Ctx)

             else
               (declare
                  New_IE_Pos : constant Positive := Buffer'First + Length'Old;

                  M_Old : constant V.Sequence :=
                    Model (IE_List_Old, IE_List_Old'First);

                  M : constant V.Sequence := Model (IE_List, IE_List'First);
                begin
                  IE_Count (IE_List, IE_List'First)
                  = IE_Count (IE_List_Old, IE_List_Old'First) + 1
                  and then
                    IE_List_Length (IE_List)
                    = IE_List_Length (IE_List_Old)
                      + IE_Header_Length
                      + Required_Content_Length (Ctx)

                  --  The positions of previously reachable IEs iare preserved
                  and then
                    Reachable_Set (IE_List_Old, IE_List_Old'First)
                    <= Reachable_Set (IE_List, IE_List'First)

                  --  The new positions are the same as before, except for the
                  --  addition of New_IE_Pos.
                  and then
                    S.Included_Except
                      (Reachable_Set (IE_List, IE_List'First),
                       Reachable_Set (IE_List_Old, IE_List_Old'First),
                       New_IE_Pos)

                  --  The ordering of previous IE positions is preserved,
                  --  and New_IE_Pos is the last IE in the sequence.
                  --  (note that the sequence is in reverse order, so the last
                  --  IE position is first in the sequence).
                  and then
                    (for all I in M_Old => V.Get (M_Old, I) = V.Get (M, I + 1))
                  and then V.Get (M, V.First) = New_IE_Pos

                  --  The headers and content of any existing IEs are preserved
                  and then
                    (for all P of
                       Reachable_Set (IE_List_Old, IE_List_Old'First) =>
                       IE_Header (IE_List, P) = IE_Header (IE_List_Old, P)
                       and then
                         IE_Content (IE_List, P)
                         = IE_Content (IE_List_Old, P)))));

   procedure Null_Transform (IE : in out Byte_Array)
   with Inline, Post => IE = IE'Old;

   generic
      with
        function Filter (IE : Byte_Array) return Boolean
        with Pre => IE'Length > 0 and then Valid_IE (IE, IE'First);

      with
        procedure Transform (IE : in out Byte_Array) is Null_Transform
        with
          Pre  => IE'Length > 0 and then Valid_IE (IE, IE'First),
          Post =>
            Valid_IE (IE, IE'First)
            and then
              Is_Termination_IE (IE_Header (IE, IE'First))
              = Is_Termination_IE (IE_Header (IE'Old, IE'First));
      --  Optional procedure to modify an IE. This may shorten the IE length,
      --  but it cannot lengthen it.
   procedure Filter_And_Transform_IE_List
     (Buffer : in out Byte_Array; Length : out Natural)
   with
     Pre  =>
       Buffer'Last < Natural'Last
       and then Valid_IE_List (Buffer)
       and then Buffer'Length = IE_List_Length (Buffer),
     Post =>
       (if Length > 0
        then
          Length <= Buffer'Length
          and then
            Valid_IE_List
              (Buffer (Buffer'First .. Buffer'First + (Length - 1)))
          and then
            Length
            = IE_List_Length
                (Buffer (Buffer'First .. Buffer'First + (Length - 1))));

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
