--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package AdaBee.Time_Units
  with Pure, SPARK_Mode, Always_Terminates
is

   Time_Unit : constant := 0.000_001; --  1 microsecond resolution
   Time_Size : constant := 64;        --  64-bit time

   type Time_Span is
     delta Time_Unit
     range -Time_Unit * (2.0 ** (Time_Size - 1) - 1.0)
           .. Time_Unit * (2.0 ** (Time_Size - 1) - 1.0)
   with Small => Time_Unit;
   --  Represents a length of real time duration in seconds.

   subtype Time is Time_Span range 0.0 .. Time_Span'Last;
   --  Represents a point in time in seconds.

end AdaBee.Time_Units;
