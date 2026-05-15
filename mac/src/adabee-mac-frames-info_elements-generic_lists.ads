--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Utilties for parsing and iterating through Information Element (IE) lists
--
--  @description
--  To iterate through an IE list, it is first necessary to parse the list
--  by calling Parse_IE_List to check that the IE list is well-formed and to
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
   type Header_Field (<>) is limited private;
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

   function Content_Length
     (Buffer : Byte_Array; Pos : Positive) return Length_Type
   is (Content_Length (From_Bytes (Buffer (Pos .. Pos + 1))))
   with Pre => Pos in Buffer'Range and then Pos < Buffer'Last;
   --  Get the length of the content field of an information element in bytes.

   function IE_Length (Buffer : Byte_Array; Pos : Positive) return Natural
   is (Natural (Content_Length (Buffer, Pos)) + 2)
   with Pre => Pos in Buffer'Range and then Pos < Buffer'Last;
   --  Get the total length of an information element in bytes, including the
   --  header and content fields.

   function Valid_IE (Buffer : Byte_Array; Pos : Positive) return Boolean
   is (Pos < Buffer'Last
       and then IE_Length (Buffer, Pos) <= (Buffer'Last - Pos) + 1)
   with Pre => Pos in Buffer'Range;
   --  Check whether an information element at position Pos fits within the
   --  bounds of the Buffer. This returns False if the IE's reported length
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
   --  The last IE is one that is either a termination IE, or is the last
   --  IE in the buffer.
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

   end IE_Model;

   ---------------------
   -- IE List Parsing --
   ---------------------

   procedure Parse_IE_List
     (Buffer  : Byte_Array;
      Length  : out Natural;
      Result  : out Status_Code;
      Last_IE : out Positive)
   with
     Global => null,
     Post   =>
       Result in Success | Malformed_Frame
       and then
         (if Result = Success
          then
            Length > 0
            and then Length <= Buffer'Length
            and then
              IE_Model.Valid_IE_List
                (Buffer (Buffer'First .. Buffer'First + (Length - 1)))
            and then Last_IE in Buffer'Range
            and then Valid_IE (Buffer, Last_IE)
            and then Is_Last_IE (Buffer, Last_IE));
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

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
