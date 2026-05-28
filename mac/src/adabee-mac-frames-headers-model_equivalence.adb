--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Headers.Model_Equivalence
  with SPARK_Mode
is

   --------------------------------------
   -- Lemma_Frame_Control_Length_Equal --
   --------------------------------------

   procedure Lemma_Frame_Control_Length_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      null;
   end Lemma_Frame_Control_Length_Equal;

   ---------------------------------
   -- Lemma_PAN_ID_Presence_Equal --
   ---------------------------------

   procedure Lemma_PAN_ID_Presence_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      null;
   end Lemma_PAN_ID_Presence_Equal;

   --------------------------------------------
   -- Lemma_Addressing_Field_Positions_Equal --
   --------------------------------------------

   procedure Lemma_Addressing_Field_Positions_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      Lemma_Frame_Control_Length_Equal (MHR, Frame);
      Lemma_PAN_ID_Presence_Equal (MHR, Frame);
   end Lemma_Addressing_Field_Positions_Equal;

   -----------------------------------------------------
   -- Lemma_Aux_Security_Header_Field_Positions_Equal --
   -----------------------------------------------------

   procedure Lemma_Aux_Security_Header_Field_Positions_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      Lemma_Addressing_Field_Positions_Equal (MHR, Frame);
   end Lemma_Aux_Security_Header_Field_Positions_Equal;

   ------------------------------------------
   -- Lemma_MHR_Length_Excluding_IEs_Equal --
   ------------------------------------------

   procedure Lemma_MHR_Length_Excluding_IEs_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      Lemma_Addressing_Field_Positions_Equal (MHR, Frame);
      Lemma_Aux_Security_Header_Field_Positions_Equal (MHR, Frame);
   end Lemma_MHR_Length_Excluding_IEs_Equal;

   -------------------------------------------
   -- Lemma_Get_Sequence_Number_Equivalence --
   -------------------------------------------

   procedure Lemma_Get_Sequence_Number_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      Lemma_Addressing_Field_Positions_Equal (MHR, Frame);
   end Lemma_Get_Sequence_Number_Equivalence;

   ----------------------------------------------
   -- Lemma_Get_Destination_PAN_ID_Equivalence --
   ----------------------------------------------

   procedure Lemma_Get_Destination_PAN_ID_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      null;
   end Lemma_Get_Destination_PAN_ID_Equivalence;

   -----------------------------------------------
   -- Lemma_Get_Destination_Address_Equivalence --
   -----------------------------------------------

   procedure Lemma_Get_Destination_Address_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      Lemma_Addressing_Field_Positions_Equal (MHR, Frame);
   end Lemma_Get_Destination_Address_Equivalence;

   -----------------------------------------
   -- Lemma_Get_Source_PAN_ID_Equivalence --
   -----------------------------------------

   procedure Lemma_Get_Source_PAN_ID_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      Lemma_Addressing_Field_Positions_Equal (MHR, Frame);
      Lemma_PAN_ID_Presence_Equal (MHR, Frame);
   end Lemma_Get_Source_PAN_ID_Equivalence;

   ------------------------------------------
   -- Lemma_Get_Source_Address_Equivalence --
   ------------------------------------------

   procedure Lemma_Get_Source_Address_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      Lemma_Addressing_Field_Positions_Equal (MHR, Frame);
   end Lemma_Get_Source_Address_Equivalence;

   -----------------------------------------------
   -- Lemma_Get_Aux_Security_Header_Equivalence --
   -----------------------------------------------

   procedure Lemma_Get_Aux_Security_Header_Equivalence
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      Lemma_Aux_Security_Header_Field_Positions_Equal (MHR, Frame);
   end Lemma_Get_Aux_Security_Header_Equivalence;

end AdaBee.MAC.Frames.Headers.Model_Equivalence;
