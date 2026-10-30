--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  This package provides facilities for writing header IEs.

package AdaBee.MAC.Frames.Info_Elements.Headers.Encoders
  with Elaborate_Body, SPARK_Mode, Always_Terminates
is

   use Lists;

   -----------------------------------------
   -- Simplified Superframe Specification --
   -----------------------------------------

   procedure Encode_Simplified_Superframe_Spec_IE
     (Buffer : out Byte_Array;
      Length : out Natural;
      Spec   : Simplified_Superframe_Spec_Field)
   with
     Inline,
     Relaxed_Initialization => Buffer,
     Pre                    =>
       Buffer'Length >= IE_Header_Length + Simplified_Superframe_Spec_Length,
     Post                   =>
       Length = IE_Header_Length + Simplified_Superframe_Spec_Length
       and then
         (declare
            IE : Byte_Array renames
              Buffer (Buffer'First .. Buffer'First + (Length - 1));
          begin
            IE'Initialized
            and then Lists.Valid_IE (IE, IE'First)
            and then
              Is_Simplified_Superframe_Spec_IE
                (Lists.IE_Header (IE, IE'First)));
   --  Encode a simplified superframe specification IE into a byte array.
   --
   --  @param Buffer The target byte array to encode the IE.
   --    The length of this buffer must be at least as big as the required IE
   --    size.
   --
   --  @param Length On output, this is the number of bytes that were written
   --    to the Buffer.
   --
   --  @param Spec The simplified superframe specification data to write to the
   --    content field of the IE.

   procedure Append_Simplified_Superframe_Spec_IE is new
     Lists.Append_IE_Inplace_With_Context
       (Writer_Context          => Simplified_Superframe_Spec_Field,
        Precondition            => Always_True,
        Required_Content_Length =>
          Simplified_Superframe_Spec_IE_Content_Length,
        IE_Property             => Is_Simplified_Superframe_Spec_IE,
        Write_IE                => Encode_Simplified_Superframe_Spec_IE);
   --  Append a simplified superframe specification IE to an IE list.

end AdaBee.MAC.Frames.Info_Elements.Headers.Encoders;
