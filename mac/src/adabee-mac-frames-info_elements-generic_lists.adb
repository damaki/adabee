--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Info_Elements.Generic_Lists is

   package body IE_Positions_Model is separate;
   package body IE_Model is separate;

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
   end Validate_IE_List;

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
