package body AdaBee.MAC.Frames.Headers.MHR_Model
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

   ---------------------------------
   -- Lemma_Field_Positions_Equal --
   ---------------------------------

   procedure Lemma_Field_Positions_Equal
     (MHR : Valid_MAC_Header; Frame : Byte_Array) is
   begin
      Lemma_Frame_Control_Length_Equal (MHR, Frame);
      Lemma_PAN_ID_Presence_Equal (MHR, Frame);
   end Lemma_Field_Positions_Equal;

end AdaBee.MAC.Frames.Headers.MHR_Model;
