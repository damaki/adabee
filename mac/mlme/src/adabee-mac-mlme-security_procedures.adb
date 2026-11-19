--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Payloads;
with AdaBee.MAC.MLME.Security_Procedures.IE_Procedures;

package body AdaBee.MAC.MLME.Security_Procedures
  with SPARK_Mode
is
   use type AdaBee.MAC.Frames.Headers.Frame_Type_Field;
   use type AdaBee.MAC.Frames.Headers.PAN_ID_Field;

   use all type AdaBee.MAC.Frames.Headers.Security_Level_Field;

   procedure Lookup_MAC_Command
     (Frame               : Byte_Array;
      Layout              : AdaBee.MAC.Frames.Layouts.Frame_Layout;
      Payload_IEs_Present : Boolean;
      Status              : out Status_Code;
      MAC_Command         : out Bits_8)
   with
     Global => null,
     Pre    =>
       Frames.Headers.Decoder_Model.Is_MHR_Valid (Frame)
       and then
         (if Frames.Headers.Decoder_Model.Is_Payload_IE_Present (Frame)
          then
            Frames.Info_Elements.Payloads.Lists.Formal_Model.Valid_IE_List
              (Frames.Headers.Decoder_Model.Get_MAC_Payload_Content (Frame)))
       and then
         Frames.Headers.Decoder_Model.Get_Frame_Type (Frame)
         = Frames.Headers.MAC_Command
       and then
         Payload_IEs_Present
         = Frames.Headers.Decoder_Model.Is_Payload_IE_Present (Frame)
       and then
         Frames.Layouts.Formal_Model.Layout_Matches_Model (Frame, Layout),
     Post   =>
       (Status = Success)
       = (AdaBee.MAC.Frames.Layouts.Frame_Payload_Length (Layout) > 0);
   --  Extract the MAC command field from the frame.
   --
   --  This function succeeds if and only if the Frame contains a non-empty
   --  Frame Payload field.

   procedure Check_Header_IEs_Security_Disabled is new
     IE_Procedures.Generic_Check_IEs_Security_Disabled
       (Header_Field      =>
          AdaBee.MAC.Frames.Info_Elements.Headers.Header_Field,
        Check_IE_Security => IE_Procedures.Check_Header_IE_Security_Level,
        Lists             => AdaBee.MAC.Frames.Info_Elements.Headers.Lists,
        Lists_Lemmas      => AdaBee.MAC.Frames.Info_Elements.Headers.Lemmas);

   ------------------------------
   -- Lookup_Device_Descriptor --
   ------------------------------

   function Lookup_Device_Descriptor
     (Device_PAN_ID  : AdaBee.MAC.Frames.Headers.PAN_ID_Field;
      Device_Address : AdaBee.MAC.Frames.Headers.Variant_Address)
      return Sec_Device_List_Extended_Index
   is
      PAN_ID  : AdaBee.MAC.Frames.Headers.PAN_ID_Field;
      Address : AdaBee.MAC.Frames.Headers.Variant_Address;
   begin
      if Device_Address.Mode = Not_Present then
         PAN_ID := PIB.DB.MAC_PAN_ID;
      else
         PAN_ID := Device_PAN_ID;
      end if;

      if Device_Address.Mode = Not_Present then
         case PIB.DB.MAC_Coord_Short_Address is
            when 16#0000# .. 16#FFFD# =>
               Address :=
                 (Mode          => Short,
                  Short_Address => PIB.DB.MAC_Coord_Short_Address);

            when 16#FFFE#             =>
               Address :=
                 (Mode             => Extended,
                  Extended_Address => PIB.DB.MAC_Coord_Extended_Address);

            when 16#FFFF#             =>
               return No_Device;
         end case;
      else
         Address := Device_Address;
      end if;

      pragma Assert (Address.Mode in Short | Extended);

      for I in PIB.DB.Sec_Device_List'Range loop
         if PIB.DB.Sec_Device_List (I).PAN_ID = PAN_ID
           and then Address_Equal (Address, PIB.DB.Sec_Device_List (I))
         then
            return I;
         end if;
      end loop;

      return No_Device;
   end Lookup_Device_Descriptor;

   ------------------------
   -- Lookup_MAC_Command --
   ------------------------

   procedure Lookup_MAC_Command
     (Frame               : Byte_Array;
      Layout              : AdaBee.MAC.Frames.Layouts.Frame_Layout;
      Payload_IEs_Present : Boolean;
      Status              : out Status_Code;
      MAC_Command         : out Bits_8) is
   begin
      if Payload_IEs_Present then
         if Layout.Payload_IEs_Last >= Layout.MAC_Payload_Last then
            --  There is no frame payload after the payload IEs

            MAC_Command := 0;
            Status := Malformed_Frame;
         else
            --  The MAC command is the first byte after the payload IEs
            --  (i.e. the first byte of the frame payload field).

            MAC_Command := Frame (Layout.Payload_IEs_Last + 1);
            Status := Success;
         end if;
      elsif Layout.MAC_Payload_First <= Layout.MAC_Payload_Last then
         --  There are no payload IEs, so the MAC command is the first byte
         --  of the MAC payload.

         MAC_Command := Frame (Layout.MAC_Payload_First);
         Status := Success;
      else
         --  The MAC payload is empty

         MAC_Command := 0;
         Status := Malformed_Frame;
      end if;
   end Lookup_MAC_Command;

   ---------------------------
   -- Lookup_Security_Level --
   ---------------------------

   function Lookup_Security_Level
     (Frame_Type     : AdaBee.MAC.Frames.Headers.Frame_Type_Field;
      MAC_Command_ID : Bits_8) return Sec_Security_Level_List_Extended_Index
   is
      use all type AdaBee.MAC.Frames.Headers.Frame_Type_Field;
   begin
      for I in PIB.DB.Sec_Security_Level_List'Range loop
         if PIB.DB.Sec_Security_Level_List (I).Frame_Types (Frame_Type) then
            if Frame_Type /= MAC_Command then
               return I;

            elsif MAC_Command_ID
                  in PIB.DB.Sec_Security_Level_List (I).Command_IDs'Range
              and then
                PIB.DB.Sec_Security_Level_List (I).Command_IDs (MAC_Command_ID)
            then
               return I;
            end if;
         end if;
      end loop;

      return No_Security_Level;
   end Lookup_Security_Level;

   -----------------------------------------------
   -- Unsecure_Incoming_Frame_Security_Disabled --
   -----------------------------------------------

   procedure Unsecure_Incoming_Frame_Security_Disabled
     (Frame               : Byte_Array;
      MHR                 : AdaBee.MAC.Frames.Headers.Valid_MAC_Header;
      Layout              : in out AdaBee.MAC.Frames.Layouts.Frame_Layout;
      Payload_IEs_Present : Boolean;
      IE_Status_List      : out IE_Status_Array;
      Status              : out Status_Code)
   is
      PAN_ID      : AdaBee.MAC.Frames.Headers.PAN_ID_Field;
      Device      : Sec_Device_List_Extended_Index;
      SL_Index    : Sec_Security_Level_List_Extended_Index;
      SL_Result   : Security_Level_Status;
      MAC_Command : Bits_8;
   begin

      --  The steps here are defined in Section 9.2.5 of IEEE 802.15.4-2024

      --  a) Check for macSecurityEnabled

      if not PIB.DB.MAC_Security_Enabled then
         IE_Status_List := [others => Passed];

         if AdaBee.MAC.Frames.Layouts.Has_MAC_Payload (Layout) then
            AdaBee.MAC.Frames.Payloads.Decode_MAC_Payload_Layout
              (Frame               => Frame,
               Layout              => Layout,
               Payload_IEs_Present => Payload_IEs_Present,
               Status              => Status);
         else
            Status := Success;
         end if;

         return;
      end if;

      --  b) Obtain source address

      if MHR.Source_PAN_ID.Present then
         PAN_ID := MHR.Source_PAN_ID.PAN_ID;
      elsif MHR.Destination_PAN_ID.Present then
         PAN_ID := MHR.Destination_PAN_ID.PAN_ID;
      else
         PAN_ID := PIB.DB.MAC_PAN_ID;
      end if;

      --  c) Obtain DeviceDescriptor

      Device := Lookup_Device_Descriptor (PAN_ID, MHR.Source_Address);

      if Device = No_Device then
         Status := Unavailable_Device;
         return;
      end if;

      --  d) Obtain SecurityLevelDescriptor

      --  First, we need to decode the layout of the MAC payload field to
      --  extract the MAC command (if present) to feed into the security level
      --  lookup procedure.

      if AdaBee.MAC.Frames.Layouts.Has_MAC_Payload (Layout) then
         AdaBee.MAC.Frames.Payloads.Decode_MAC_Payload_Layout
           (Frame               => Frame,
            Layout              => Layout,
            Payload_IEs_Present => Payload_IEs_Present,
            Status              => Status);

         if Status /= Success then
            return;
         end if;
      end if;

      if MHR.Frame_Type = AdaBee.MAC.Frames.Headers.MAC_Command then
         Lookup_MAC_Command
           (Frame               => Frame,
            Layout              => Layout,
            Payload_IEs_Present => Payload_IEs_Present,
            Status              => Status,
            MAC_Command         => MAC_Command);

         --  Lookup_MAC_Command fails if the frame payload field is empty

         if Status /= Success then
            return;
         end if;
      else
         MAC_Command := 0;
      end if;

      SL_Index := Lookup_Security_Level (MHR.Frame_Type, MAC_Command);

      if SL_Index = No_Security_Level then
         Status := Unavailable_Security_Level;
         return;
      end if;

      --  e) Check IE security

      if MHR.IE_Present = Present then
         if PIB.DB.Sec_Security_Level_List (SL_Index)
              .IE_Security_Level_Descriptor_List_Length
           = 0
         then
            --  Case a) in Section 9.2.8 of IEEE 802.15.4-2024
            IE_Status_List := [others => Passed];

         else
            IE_Status_List := [others => Failed];

            Check_Header_IEs_Security_Disabled
              (IE_List              =>
                 Frame (Layout.Header_IEs_First .. Layout.Header_IEs_Last),
               Device_Desc          => PIB.DB.Sec_Device_List (Device),
               SL_Desc              =>
                 PIB.DB.Sec_Security_Level_List (SL_Index),
               Key_Desc             => null,
               Frame_Security_Level => None,
               IE_Status_List       =>
                 IE_Status_List
                   (Layout.Header_IEs_First .. Layout.Header_IEs_Last));

            if Payload_IEs_Present then
               IE_Procedures.Check_Payload_And_Nested_IEs_Security_Disabled
                 (IE_List              =>
                    Frame
                      (Layout.MAC_Payload_First .. Layout.Payload_IEs_Last),
                  Device_Desc          => PIB.DB.Sec_Device_List (Device),
                  SL_Desc              =>
                    PIB.DB.Sec_Security_Level_List (SL_Index),
                  Key_Desc             => null,
                  Frame_Security_Level => None,
                  IE_Status_List       =>
                    IE_Status_List
                      (Layout.MAC_Payload_First .. Layout.Payload_IEs_Last));
            end if;
         end if;

      else
         --  No IEs are present
         IE_Status_List := [others => Failed];
      end if;

      --  f) Check security level

      --  First, perform the incoming security level checking procedure as per
      --  Section 9.2.10 of IEEE 802.15.4-2024.
      --
      --  Note that step a) of Section 9.2.10 does not apply here because the
      --  incoming frame does not have a key descriptor.

      if PIB.DB.Sec_Security_Level_List (SL_Index)
           .Device_Override_Security_Levels
      then
         SL_Result := Conditionally_Passed;
      else
         SL_Result := Failed;
      end if;

      --  Second, perform the check as per step f) of Section 9.2.5

      if SL_Result = Failed or else not PIB.DB.Sec_Device_List (Device).Exempt
      then
         Status := Improper_Security_Level;
         return;
      end if;

      --  g) Return frame

      Status := Success;

   end Unsecure_Incoming_Frame_Security_Disabled;

end AdaBee.MAC.MLME.Security_Procedures;
