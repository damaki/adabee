--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Info_Elements.Headers
  with SPARK_Mode
is

   ---------------------------------------------------
   -- Encode_Simplified_Superframe_Specification_IE --
   ---------------------------------------------------

   procedure Encode_Simplified_Superframe_Specification_IE
     (Buffer : out Byte_Array;
      Length : out Natural;
      Spec   : Simplified_Superframe_Specification_Field)
   is
      F : constant Positive := Buffer'First;
   begin
      Length := IE_Header_Length + Simplified_Superframe_Spec_Length;

      --  Write the IE header
      Buffer (F .. F + (IE_Header_Length - 1)) :=
        To_Bytes (Simplified_Superframe_Spec_Header);

      --  Write the IE content
      Buffer (F + IE_Header_Length .. F + (Length - 1)) := To_Bytes (Spec);
   end Encode_Simplified_Superframe_Specification_IE;

end AdaBee.MAC.Frames.Info_Elements.Headers;
