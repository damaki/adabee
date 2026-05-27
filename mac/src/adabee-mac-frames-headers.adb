--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Headers
  with SPARK_Mode
is

   package body PAN_ID_Model
     with SPARK_Mode
   is

      ----------------------------------------------
      -- Lemma_PAN_ID_Present_Valid_Configuration --
      ----------------------------------------------

      procedure Lemma_PAN_ID_Present_Valid_Configuration
        (Frame_Version            : Valid_Frame_Version_Field;
         Destination_Address_Mode : Valid_Address_Mode_Field;
         Source_Address_Mode      : Valid_Address_Mode_Field;
         PAN_ID_Compression       : PAN_ID_Compression_Field) is
      begin
         null;
      end Lemma_PAN_ID_Present_Valid_Configuration;

      ---------------------------------------
      -- Lemma_PAN_ID_Compression_Identity --
      ---------------------------------------

      procedure Lemma_PAN_ID_Compression_Identity
        (Frame_Version              : Valid_Frame_Version_Field;
         Destination_Address_Mode   : Valid_Address_Mode_Field;
         Source_Address_Mode        : Valid_Address_Mode_Field;
         PAN_ID_Compression         : PAN_ID_Compression_Field;
         Destination_PAN_ID_Present : Boolean;
         Source_PAN_ID_Present      : Boolean) is
      begin
         null;
      end Lemma_PAN_ID_Compression_Identity;

   end PAN_ID_Model;

end AdaBee.MAC.Frames.Headers;
