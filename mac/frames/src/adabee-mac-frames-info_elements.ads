--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package AdaBee.MAC.Frames.Info_Elements
  with Pure, SPARK_Mode, Always_Terminates
is

   type IE_Type_Field is (Short, Long) with Size => 1;
   for IE_Type_Field use (Short => 0, Long => 1);

end AdaBee.MAC.Frames.Info_Elements;
