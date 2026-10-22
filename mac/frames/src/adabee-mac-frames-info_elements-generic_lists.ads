--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Utilties and formal models for Information Element (IE) lists
--
--  @description
--  To iterate through an IE list, it is first necessary to parse the list
--  by calling Validate_IE_List to check that the IE list is well-formed and to
--  determine its length.
--
--  If the IE list is well-formed then it is possible to iterate over each IE
--  in the list. The current position in the IE list is determined by an index
--  in the buffer which references the first byte of the current IE. The
--  function Next_IE_Position is used to get the index of the next IE in the
--  list, and the function Is_Last_IE is used to determine when the end of the
--  list has been reached.
--
--  An example loop to iterate through an IE list in SPARK would look like:
--
--     procedure Example (Buffer : Byte_Array)
--     with Pre => IE_Model.Valid_IE_List (Buffer)
--     is
--        Pos : Positive := Buffer'First;
--     begin
--        loop
--           pragma Loop_Variant (Increases => Pos);
--           pragma Loop_Invariant (Pos in Buffer'Range);
--           pragma Loop_Invariant (IE_Model.Valid_IE_List (Buffer, Pos));
--
--           --  Do something with the IE here.
--
--           exit when Is_Last_IE (Buffer, Pos);
--
--           Pos := Next_IE_Position (Buffer, Pos);
--        end loop;
--     end Example;

generic
   type Header_Field (<>) is private;
   type Length_Type is range <>;

   with function From_Bytes (Bytes : Byte_Array_2) return Header_Field;
   --  Converts a 2-byte array to an IE field header

   with function Content_Length (Header : Header_Field) return Length_Type;
   --  Gets the length field from the IE header

   with function Is_Termination_IE (Header : Header_Field) return Boolean;
   --  Returns True if the IE is a termination IE, or False otherwise.

package AdaBee.MAC.Frames.Info_Elements.Generic_Lists with Pure
is

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

   function IE_Length (Buffer : Byte_Array; Pos : Positive) return Natural
   is (Natural (Content_Length (Buffer, Pos)) + 2)
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
     Pre =>
       Pos in Buffer'Range
       and then Valid_IE (Buffer, Pos)
       and then not Is_Last_IE (Buffer, Pos);
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

   --  This formal model provides a functional definition for a valid IE list
   --  for use in proof.

   package IE_Model
     with Ghost
   is

      ----------------------
      -- IE List Validity --
      ----------------------

      function Valid_IE_List
        (Buffer : Byte_Array; Pos : Positive) return Boolean
      is (Valid_IE (Buffer, Pos)
          and then
            (if not Is_Last_IE (Buffer, Pos)
             then Valid_IE_List (Buffer, Next_IE_Position (Buffer, Pos))))
      with
        Pre                => Pos in Buffer'Range,
        Subprogram_Variant => (Increases => Pos);
      --  Returns True if the IE list in Buffer is a valid IE list, starting at
      --  the IE at position Pos in the Buffer.
      --
      --  A valid IE list is one where:
      --   * all IEs in the list are within the bounds of the Buffer.
      --     In other words, there are no IEs whose length field would exceed
      --     the bounds of Buffer.
      --   * the last IE is either a termination IE or reaches exactly the end
      --     of the Buffer.

      function Valid_IE_List (Buffer : Byte_Array) return Boolean
      is (Buffer'Length > 0 and then Valid_IE_List (Buffer, Buffer'First));
      --  Returns True if the IE list in Buffer is a valid IE list, starting at
      --  the IE at the beginning of the Buffer.

      --------------------
      -- IE List Length --
      --------------------

      function IE_List_Length
        (Buffer : Byte_Array; Pos : Positive) return Natural
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

      function IE_List_Length (Buffer : Byte_Array) return Natural
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

      ------------------
      -- Reachability --
      ------------------

      function Reachable
        (Buffer : Byte_Array; Target_Pos : Positive; Pos : Positive)
         return Boolean
      is (if Target_Pos = Pos
          then True
          elsif Is_Last_IE (Buffer, Pos)
          then False
          else Reachable (Buffer, Target_Pos, Next_IE_Position (Buffer, Pos)))
      with
        Pre                =>
          Pos in Buffer'Range and then Valid_IE_List (Buffer, Pos),
        Subprogram_Variant => (Increases => Pos);
      --  Returns True if the IE at position Target_Pos is reachable in the
      --  IE list, starting with the IE at position Pos in the Buffer.

      function Reachable
        (Buffer : Byte_Array; Target_Pos : Positive) return Boolean
      is (Reachable (Buffer, Target_Pos, Buffer'First))
      with Pre => Valid_IE_List (Buffer);
      --  Returns True if the IE at position Target_Pos is reachable in the
      --  IE list, starting at the beginning of Buffer.

      function Contains
        (Buffer : Byte_Array; Header : Header_Field; Pos : Positive)
         return Boolean
      is (if From_Bytes (Buffer (Pos .. Pos + 1)) = Header
          then True
          elsif Is_Last_IE (Buffer, Pos)
          then False
          else Contains (Buffer, Header, Next_IE_Position (Buffer, Pos)))
      with
        Pre                =>
          Pos in Buffer'Range and then Valid_IE_List (Buffer, Pos),
        Subprogram_Variant => (Increases => Pos);
      --  Returns True if the IE list contains an IE with the given header
      --  field.

      function Contains
        (Buffer : Byte_Array; Header : Header_Field) return Boolean
      is (Contains (Buffer, Header, Buffer'First))
      with Pre => Valid_IE_List (Buffer);
      --  Returns True if the IE list contains an IE with the given header
      --  field.

      -----------------------
      -- IE List Accessors --
      -----------------------

      function Last_IE_Header_Field
        (Buffer : Byte_Array; Pos : Positive) return Header_Field
      is (if Is_Last_IE (Buffer, Pos)
          then From_Bytes (Buffer (Pos .. Pos + 1))
          else Last_IE_Header_Field (Buffer, Next_IE_Position (Buffer, Pos)))
      with
        Pre                =>
          Pos in Buffer'Range and then Valid_IE_List (Buffer, Pos),
        Post               =>
          Contains (Buffer, Last_IE_Header_Field'Result, Pos),
        Subprogram_Variant => (Increases => Pos);
      --  Gets the header field of the last IE in an IE list starting at
      --  position Pos in the Buffer.

      function Last_IE_Header_Field (Buffer : Byte_Array) return Header_Field
      is (Last_IE_Header_Field (Buffer, Buffer'First))
      with
        Pre  => Valid_IE_List (Buffer),
        Post => Contains (Buffer, Last_IE_Header_Field'Result);
      --  Gets the header field of the last IE in an IE list

      ------------------------
      -- IE List Properties --
      ------------------------

      function Is_Terminated
        (Buffer : Byte_Array; Pos : Positive) return Boolean
      is (Is_Termination_IE (Last_IE_Header_Field (Buffer, Pos)))
      with Pre => Pos in Buffer'Range and then Valid_IE_List (Buffer, Pos);
      --  Returns True if the IE list starting at position Pos in Buffer ends
      --  with a termination IE.

      function Is_Terminated (Buffer : Byte_Array) return Boolean
      is (Is_Terminated (Buffer, Buffer'First))
      with
        Pre => Buffer'Length > 0 and then Valid_IE_List (Buffer, Buffer'First);
      --  Returns True if the IE list in Buffer ends with a termination IE.

      function Is_Appendable_IE_List (Buffer : Byte_Array) return Boolean
      is (Buffer'Length = 0
          or else
            (Valid_IE_List (Buffer)
             and then Buffer'Length = IE_List_Length (Buffer)
             and then not Is_Terminated (Buffer)));
      --  Returns True if Buffer contains a valid (possibly empty) IE list
      --  that does not end in a termination IE.
      --
      --  The range of the Buffer should exactly fit the length of the IE list.
      --  If the IE list is part of a larger buffer, then Buffer should be a
      --  slice of that buffer.

      function Is_Appendable_IE_List_Relaxed
        (Buffer : Byte_Array; Length : Natural) return Boolean
      is (Buffer (Buffer'First .. Buffer'First + (Length - 1))'Initialized
          and then
            Is_Appendable_IE_List
              (Buffer (Buffer'First .. Buffer'First + (Length - 1))))
      with Relaxed_Initialization => Buffer, Pre => Length <= Buffer'Length;
      --  Returns True if the first Length bytes in Buffer contains a valid
      --  (possibly empty) IE list that does not end in a termination IE.
      --
      --  Length is the length of the IE list in Buffer. Only the first Length
      --  bytes in Buffer need to be initialized.

      ------------
      -- Lemmas --
      ------------

      --  These lemmas are useful for proving that properties are preserved
      --  for slices of buffers that fully contain the IE list.

      procedure Lemma_Valid_IE_List_Preserved
        (Buffer : Byte_Array; Slice : Byte_Array)
      with
        Pre  =>
          Valid_IE_List (Buffer)
          and then Slice'First = Buffer'First
          and then Slice'Length in IE_List_Length (Buffer) .. Buffer'Length
          and then Slice = Buffer (Slice'Range),
        Post => Valid_IE_List (Slice);
      --  Prove that Valid_IE_List is preserved for a slice of a Buffer that
      --  contains the entire IE list.

      procedure Lemma_Reachable_Preserved
        (Buffer : Byte_Array; Slice : Byte_Array; Target : Positive)
      with
        Pre  =>
          Valid_IE_List (Buffer)
          and then Slice'First = Buffer'First
          and then Slice'Length in IE_List_Length (Buffer) .. Buffer'Length
          and then Slice = Buffer (Slice'Range),
        Post => Reachable (Buffer, Target) = Reachable (Slice, Target);
      --  Prove that Reachable is preserved for a slice of a Buffer that
      --  contains the entire IE list.

      procedure Lemma_Contains_Preserved
        (Buffer : Byte_Array; Slice : Byte_Array; Header : Header_Field)
      with
        Pre  =>
          Valid_IE_List (Buffer)
          and then Slice'First = Buffer'First
          and then Slice'Length in IE_List_Length (Buffer) .. Buffer'Length
          and then Slice = Buffer (Slice'Range),
        Post => Contains (Buffer, Header) = Contains (Slice, Header);
      --  Prove that Contains is preserved for a slice of a Buffer that
      --  contains the entire IE list.

      procedure Lemma_IE_List_Length_Preserved
        (Buffer : Byte_Array; Slice : Byte_Array)
      with
        Pre  =>
          Valid_IE_List (Buffer)
          and then Slice'First = Buffer'First
          and then Slice'Length in IE_List_Length (Buffer) .. Buffer'Length
          and then Slice = Buffer (Slice'Range),
        Post => IE_List_Length (Slice) = IE_List_Length (Buffer);

      procedure Lemma_Last_IE_Header_Field_Preserved
        (Buffer : Byte_Array; Slice : Byte_Array)
      with
        Pre  =>
          Valid_IE_List (Buffer)
          and then Slice'First = Buffer'First
          and then Slice'Length in IE_List_Length (Buffer) .. Buffer'Length
          and then Slice = Buffer (Slice'Range),
        Post => Last_IE_Header_Field (Slice) = Last_IE_Header_Field (Buffer);

      procedure Lemma_Valid_List_Slice
        (Buffer : Byte_Array; From, Pos : Positive)
      with
        Pre                =>
          From in Buffer'Range
          and then Pos in Buffer'Range
          and then From <= Pos
          and then Valid_IE_List (Buffer, Pos),
        Post               =>
          Valid_IE_List (Buffer (From .. Buffer'Last), Pos),
        Subprogram_Variant => (Increases => Pos);
      --  Given a valid IE list, prove that Valid_IE_List holds for a slice
      --  of Buffer that starts at the next IE.

      procedure Lemma_IE_List_Extend (Buffer : Byte_Array; L1, L2 : Natural)
      with
        Pre  =>
          L2 <= Buffer'Length
          and then L1 < L2
          and then Valid_IE (Buffer, Buffer'First + L1)
          and then L2 - L1 = IE_Length (Buffer, Buffer'First + L1)
          and then
            (if L1 > 0
             then
               (declare
                  BF  : constant Positive := Buffer'First;
                  BL1 : constant Natural := Buffer'First + (L1 - 1);
                begin
                  Valid_IE_List (Buffer (BF .. BL1))
                  and then L1 = IE_List_Length (Buffer (BF .. BL1))
                  and then
                    not Is_Termination_IE
                          (Last_IE_Header_Field (Buffer (BF .. BL1))))),
        Post =>
          (declare
             BF  : constant Positive := Buffer'First;
             BL1 : constant Natural := Buffer'First + (L1 - 1);
             BL2 : constant Natural := Buffer'First + (L2 - 1);
           begin
             Valid_IE_List (Buffer (BF .. BL2))
             and then L2 = IE_List_Length (Buffer (BF .. BL2))
             and then
               Last_IE_Header_Field (Buffer (BF .. BL2))
               = IE_Header (Buffer, BF + L1));
      --  Prove that an existing valid, non-terminated IE list (up to L1)
      --  can be extended into another contiguous IE (up to L2).

   end IE_Model;

   ---------------------
   -- IE List Parsing --
   ---------------------

   procedure Validate_IE_List
     (Buffer  : Byte_Array;
      Length  : out Natural;
      Result  : out Status_Code;
      Last_IE : out Positive)
   with
     Global => null,
     Post   =>
       Result in Success | Malformed_Frame
       and then (Result = Success) = IE_Model.Valid_IE_List (Buffer)
       and then
         (if Result = Success
          then
            Length in 2 .. Buffer'Length
            and then Length = IE_Model.IE_List_Length (Buffer)
            and then Last_IE in Buffer'Range
            and then Valid_IE (Buffer, Last_IE)
            and then Is_Last_IE (Buffer, Last_IE)
            and then IE_Model.Reachable (Buffer, Last_IE)
            and then
              IE_Header (Buffer, Last_IE)
              = IE_Model.Last_IE_Header_Field (Buffer));
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

   ------------------------
   -- IE List Generation --
   ------------------------

   procedure Append_IE
     (Buffer : in out Byte_Array; Length : in out Natural; IE : Byte_Array)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Pre                    =>
       Length <= Buffer'Length
       and then IE_Model.Is_Appendable_IE_List_Relaxed (Buffer, Length)

       --  The IE buffer must contain a valid IE and is sized exactly for that
       --  IE.
       and then IE'Length > 0
       and then Valid_IE (IE, IE'First)
       and then IE'Length = IE_Length (IE, IE'First)

       --  There must be enough free space in Buffer to store the IE
       and then Buffer'Length - Length >= IE_Length (IE, IE'First),

     Post                   =>
       (declare
          IE_List_Old : Byte_Array renames
            Buffer'Old (Buffer'First .. Buffer'First + (Length'Old - 1));

          IE_List : Byte_Array renames
            Buffer (Buffer'First .. Buffer'First + (Length - 1));
        begin
          Length = Length'Old + IE_Length (IE, IE'First)
          and then IE_List'Initialized
          and then IE_List (IE_List_Old'Range) = IE_List_Old
          and then IE_Model.Valid_IE_List (IE_List)
          and then Length = IE_Model.IE_List_Length (IE_List)
          and then
            IE_Model.Last_IE_Header_Field (IE_List)
            = IE_Header (IE, IE'First));
   --  Append an IE to a valid (or empty) IE list.
   --
   --  @param Buffer The byte array containing the IE list to modify.
   --
   --  @param Length The length (in bytes) of the IE list in `Buffer`.
   --    This is updated with the new length after the IE is appended.
   --
   --  @param IE Buffer containing the IE to append. This must be a valid IE.

   generic
      Maximum_Content_Length : Natural;
      --  The maximum length of the IE's content field that can be written
      --  by Write_IE.

      with
        function IE_Header_Property (Header : Header_Field) return Boolean
        with Ghost;
      --  Function to express a custom property over an IE header.
      --
      --  This is useful to prove that a specific IE type has been added.
      --  For example, to prove that the new IE is a termination IE (or not).

      with procedure Write_IE (IE : out Byte_Array; Length : out Positive);
   procedure Append_IE_Inplace
     (Buffer : in out Byte_Array; Length : in out Natural)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Pre                    =>
       Length <= Buffer'Length
       and then Buffer'Length - Length >= 2 + Maximum_Content_Length
       and then IE_Model.Is_Appendable_IE_List_Relaxed (Buffer, Length),
     Post                   =>
       (declare
          IE_List_Old : Byte_Array renames
            Buffer'Old (Buffer'First .. Buffer'First + (Length'Old - 1));

          IE_List : Byte_Array renames
            Buffer (Buffer'First .. Buffer'First + (Length - 1));
        begin
          Length in Length'Old + 2 .. Length'Old + 2 + Maximum_Content_Length
          and then IE_List'Initialized
          and then IE_List (IE_List_Old'Range) = IE_List_Old
          and then IE_Model.Valid_IE_List (IE_List)
          and then Length = IE_Model.IE_List_Length (IE_List)
          and then
            Length - Length'Old
            = IE_Header_Length
              + Natural
                  (Content_Length (IE_Model.Last_IE_Header_Field (IE_List)))
          and then
            IE_Header_Property (IE_Model.Last_IE_Header_Field (IE_List)));
   --  Append an IE to a valid (or empty) IE list.
   --
   --  The new IE is constructed in-place in `Buffer` by calling `Write_IE`.
   --
   --  @param Buffer The byte array containing the IE list to modify.
   --
   --  @param Length The length (in bytes) of the IE list in `Buffer`.
   --    This is updated with the new length after the IE is appended.

   generic
      Maximum_Content_Length : Natural;
      --  The maximum length of the IE's content field that can be written
      --  by Write_IE.

      type Writer_Context (<>) is limited private;

      with
        function Precondition (Ctx : Writer_Context) return Boolean
        with Ghost;

      with
        function IE_Header_Property (Header : Header_Field) return Boolean
        with Ghost;
      --  Function to express a custom property over an IE header.
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
       and then Buffer'Length - Length >= 2 + Maximum_Content_Length
       and then IE_Model.Is_Appendable_IE_List_Relaxed (Buffer, Length)
       and then Precondition (Ctx),
     Post                   =>
       (declare
          IE_List_Old : Byte_Array renames
            Buffer'Old (Buffer'First .. Buffer'First + (Length'Old - 1));

          IE_List : Byte_Array renames
            Buffer (Buffer'First .. Buffer'First + (Length - 1));
        begin
          Length in Length'Old + 2 .. Length'Old + 2 + Maximum_Content_Length
          and then IE_List'Initialized
          and then IE_List (IE_List_Old'Range) = IE_List_Old
          and then IE_Model.Valid_IE_List (IE_List)
          and then Length = IE_Model.IE_List_Length (IE_List)
          and then
            Length - Length'Old
            = IE_Header_Length
              + Natural
                  (Content_Length (IE_Model.Last_IE_Header_Field (IE_List)))
          and then
            IE_Header_Property (IE_Model.Last_IE_Header_Field (IE_List)));
   --  Append an IE to a valid (or empty) IE list.
   --
   --  The new IE is constructed in-place in `Buffer` by calling `Write_IE`.
   --
   --  This is the same as `Append_IE_Inplace`, but passes an extra parameter
   --  to `Write_IE` to allow passing extra context information.
   --
   --  @param Buffer The byte array containing the IE list to modify.
   --
   --  @param Length The length (in bytes) of the IE list in `Buffer`.
   --    This is updated with the new length after the IE is appended.

   -----------------------
   -- IE List Filtering --
   -----------------------

   generic
      with
        function Filter (IE : Byte_Array) return Boolean
        with Pre => Valid_IE (IE, IE'First);

      with
        procedure Transform (IE : in out Byte_Array) is null
        with
          Pre  => Valid_IE (IE, IE'First),
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
       and then IE_Model.Valid_IE_List (Buffer)
       and then Buffer'Length = IE_Model.IE_List_Length (Buffer),
     Post =>
       (if Length > 0
        then
          IE_Model.Valid_IE_List
            (Buffer (Buffer'First .. Buffer'First + (Length - 1)))
          and then
            Length
            = IE_Model.IE_List_Length
                (Buffer (Buffer'First .. Buffer'First + (Length - 1))));
   --  Filter elements from an IE list, and apply a transformation to each IE.
   --
   --  This modifies the IE list to remove IEs that don't pass the Filter,
   --  and applies an optional transformation to each IE.
   --
   --  The transformation may shorten the IE content, but cannot lengthen it.
   --  The transformation also cannot change a non-termination IE into a
   --  termination IE or vice versa.

   ------------------------
   -- IE Positions Model --
   ------------------------

   --  This package models the positions of each IE within a buffer.
   --
   --  It is useful for certain inductive proofs, particularly when proving
   --  inductively starting from the end of the IE list.

   package IE_Positions_Model
     with Ghost
   is

      -----------
      -- Types --
      -----------

      type Positions_Array is array (Positive range <>) of Positive;

      -----------------------------
      -- Properties on Positions --
      -----------------------------

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
                  Positions (I)
                  = Next_IE_Position (Buffer, Positions (I - 1)))));

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
          --  except the first position which is the first IE in Buffer.
          and then
            (for all I in Positions'Range =>
               (if I = Positions'First
                then Positions (I) = Buffer'First
                else
                  Positions (I)
                  = Next_IE_Position (Buffer, Positions (I - 1)))));

      function IE_Positions (Buffer : Byte_Array) return Positions_Array
      with
        Pre  => IE_Model.Valid_IE_List (Buffer),
        Post =>
          IE_Positions'Result'First = 1
          and then Valid_Positions (Buffer, IE_Positions'Result)
          and then
            IE_Positions'Result'Length
            = IE_Model.IE_Count (Buffer, Buffer'First);
      --  Return the positions of all IEs in an IE list.

      ------------
      -- Lemmas --
      ------------

      procedure Lemma_Valid_IE_List
        (Buffer : Byte_Array; Positions : Positions_Array)
      with
        Pre  => Valid_Positions (Buffer, Positions),
        Post => IE_Model.Valid_IE_List (Buffer);
      --  Given an array containing the positions of each IE in a Buffer, prove
      --  that the IE list is valid.

      procedure Lemma_Valid_IE_List_All_Positions
        (Buffer : Byte_Array; Positions : Positions_Array)
      with
        Pre  => Valid_Positions (Buffer, Positions),
        Post => (for all P of Positions => IE_Model.Valid_IE_List (Buffer, P));
      --  Prove that each IE position is a valid IE list when starting at that
      --  position.

      procedure Lemma_Invalid_IE_List
        (Buffer : Byte_Array; Positions : Positions_Array)
      with
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
      --  Prove that an IE list is not valid when an invalid IE is encountered.
      --
      --  In this case, Positions contains the list of all valid IEs, and
      --  the invalid IE is the one after the last IE in Positions.

      procedure Lemma_IE_List_Length
        (Buffer : Byte_Array; Positions : Positions_Array; Length : Natural)
      with
        Pre  =>
          Valid_Positions (Buffer, Positions)
          and then IE_Model.Valid_IE_List (Buffer)
          and then
            Length
            = (Positions (Positions'Last) - Buffer'First)
              + IE_Length (Buffer, Positions (Positions'Last)),
        Post => Length = IE_Model.IE_List_Length (Buffer);
      --  Relate the IE list length to the position of the last IE.

      procedure Lemma_Position_Reachable
        (Buffer : Byte_Array; Positions : Positions_Array; Pos : Positive)
      with
        Pre  =>
          Valid_Positions (Buffer, Positions)
          and then (for some P of Positions => P = Pos),
        Post => IE_Model.Reachable (Buffer, Pos);
      --  Prove that a position Pos is reachable in an IE list if it is equal
      --  to one of the positions in the Positions array.

      procedure Lemma_Positions_IE_List_Length
        (Buffer : Byte_Array; Positions : Positions_Array)
      with
        Pre  => Valid_Positions (Buffer, Positions),
        Post =>
          (for all P of Positions =>
             IE_Model.IE_List_Length (Buffer)
             = (P - Buffer'First) + IE_Model.IE_List_Length (Buffer, P));
      --  Relate the IE list length to the positions of all IEs in the Buffer.

      procedure Lemma_Positions_Valid_For_Slice
        (Buffer : Byte_Array; Slice : Byte_Array; Positions : Positions_Array)
      with
        Pre  =>
          IE_Model.Valid_IE_List (Buffer)
          and then Valid_Positions (Buffer, Positions)
          and then Slice'First = Buffer'First
          and then
            Slice'Length in IE_Model.IE_List_Length (Buffer) .. Buffer'Length
          and then Slice = Buffer (Slice'Range),
        Post => Valid_Positions (Slice, Positions);
      --  Prove that Positions_Valid also holds for Slice, provided that
      --  Slice contains the entire IE list.

      procedure Lemma_Last_IE_Header
        (Buffer : Byte_Array; Positions : Positions_Array)
      with
        Pre  => Valid_Positions (Buffer, Positions),
        Post =>
          IE_Header (Buffer, Positions (Positions'Last))
          = IE_Model.Last_IE_Header_Field (Buffer);

      procedure Lemma_Positions_Monotonic
        (Buffer : Byte_Array; Positions : Positions_Array)
      with
        Pre                =>
          --  Each index in Positions must denote a valid IE in Buffer
          (for all P of Positions =>
             P in Buffer'Range and then Valid_IE (Buffer, P))

          --  Only the last position can denote the last IE in the list
          and then
            (for all I in Positions'Range =>
               (if Is_Last_IE (Buffer, Positions (I)) then I = Positions'Last))

          --  Each position references the next IE of the one before
          and then
            (for all I in Positions'Range =>
               (if I > Positions'First
                then
                  Positions (I)
                  = Next_IE_Position (Buffer, Positions (I - 1)))),
        Post               =>
          (for all I in Positions'Range =>
             (for all J in Positions'Range =>
                (I < J) = (Positions (I) < Positions (J)))),
        Subprogram_Variant => (Decreases => Positions'Length);

      procedure Lemma_IEs_Preserved
        (A, B : Byte_Array; Positions : Positions_Array)
      with
        Pre                =>
          Positions'Length > 0

          --  Each index in Positions must denote a valid IE in A
          and then
            (for all P of Positions => P in A'Range and then Valid_IE (A, P))

          --  B'First must be at or before the start of the first IE
          and then B'First <= Positions (Positions'First)

          --  B'Last must be at or after the last byte of the last IE
          and then
            B'Last
            >= Positions (Positions'Last)
               + (IE_Length (A, Positions (Positions'Last)) - 1)

          --  The last IE must be at the last position
          and then
            (for all I in Positions'Range =>
               (if Is_Last_IE (A, Positions (I)) then I = Positions'Last))

          --  Each position references the next IE of the one before
          and then
            (for all I in Positions'Range =>
               (if I > Positions'First
                then Positions (I) = Next_IE_Position (A, Positions (I - 1))))

          --  The slice of B is equal to A for the range in A that contains the
          --  IE list.
          and then
            (declare
               F : constant Positive := Positions (Positions'First);
               L : constant Positive :=
                 Positions (Positions'Last)
                 + (IE_Length (A, Positions (Positions'Last)) - 1);
             begin
               A (F .. L) = B (F .. L)),
        Post               =>
          --  IEs are still valid in B, and have the same IE header
          (for all P of Positions =>
             P in B'Range
             and then Valid_IE (B, P)
             and then IE_Header (B, P) = IE_Header (A, P))

          --  Each position references the next IE of the one before
          and then
            (for all I in Positions'Range =>
               (if I > Positions'First
                then Positions (I) = Next_IE_Position (B, Positions (I - 1)))),
        Subprogram_Variant => (Decreases => Positions'Length);
      --  Given a buffer A for which Positions denotes a valid sequence of IEs,
      --  and a buffer B that is equal to A for the slice that encapsulates the
      --  IEs, prove that the IE sequence is preserved.

   end IE_Positions_Model;

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
