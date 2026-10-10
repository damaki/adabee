--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee
  with SPARK_Mode
is

   -------------------
   -- Is_All_Zeroes --
   -------------------

   function Is_All_Zeroes (Buffer : Byte_Array) return Boolean is
      Accumulator : Interfaces.Unsigned_8 := 0;
   begin
      for I in Buffer'Range loop
         pragma
           Loop_Invariant
             ((Accumulator = 0)
              = (for all J in Buffer'First .. I - 1 => Buffer (J) = 0));

         Accumulator := Accumulator or Buffer (I);
      end loop;

      return Accumulator = 0;
   end Is_All_Zeroes;

   --------------
   -- Sanitize --
   --------------

   procedure Sanitize (Buffer : out Byte_Array) is
   begin
      Buffer := (others => 0);

      --  Force the value of Buffer to be visible via Inspection_Point to avoid
      --  dead store elimination.

      pragma Inspection_Point (Buffer);
   end Sanitize;

end AdaBee;
