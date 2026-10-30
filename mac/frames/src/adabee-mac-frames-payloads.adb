--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Payloads
  with SPARK_Mode
is

   -------------------------------
   -- Decode_MAC_Payload_Layout --
   -------------------------------

   procedure Decode_MAC_Payload_Layout
     (Buffer              : Byte_Array;
      Layout              : in out Frame_Layout;
      Payload_IEs_Present : Boolean;
      Status              : out Status_Code)
   is
      Unused : Positive;
      Length : Natural;
   begin
      if Payload_IEs_Present then
         AdaBee.MAC.Frames.Info_Elements.Payloads.Lists.Validate_IE_List
           (Buffer  =>
              Buffer (Layout.MAC_Payload_First .. Layout.MAC_Payload_Last),
            Length  => Length,
            Result  => Status,
            Last_IE => Unused);

         if Status = Success then
            Layout.Payload_IEs_Last := Layout.MAC_Payload_First + (Length - 1);

            Info_Elements.Payloads.Lemmas.Lemma_Valid_IE_List_Preserved
              (B1 =>
                 Buffer (Layout.MAC_Payload_First .. Layout.MAC_Payload_Last),
               B2 =>
                 Buffer (Layout.MAC_Payload_First .. Layout.Payload_IEs_Last),
               X1 => Layout.MAC_Payload_First,
               X2 => Layout.MAC_Payload_First);
         end if;
      else
         Layout.Payload_IEs_Last := 0;
         Status := Success;
      end if;
   end Decode_MAC_Payload_Layout;

end AdaBee.MAC.Frames.Payloads;
