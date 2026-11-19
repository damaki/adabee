--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with AdaBee.MAC.Frames.Info_Elements.Headers;
with AdaBee.MAC.Frames.Info_Elements.Generic_Lists;
with AdaBee.MAC.Frames.Info_Elements.Generic_Lists.Lemmas;
with AdaBee.MAC.Frames.Info_Elements.Payloads;
with AdaBee.MAC.Frames.Info_Elements.Nested;

--  This package implements the incoming IE security procedures defined in
--  sections 9.2.8 and 9.2.9 of IEEE 802.15.4-2024.

private package AdaBee.MAC.MLME.Security_Procedures.IE_Procedures
  with Elaborate_Body, SPARK_Mode, Always_Terminates
is

   use type AdaBee.MAC.Frames.Info_Elements.Payloads.Group_ID_Field;
   use type AdaBee.MAC.Frames.Info_Elements.Payloads.Length_Field;

   package Payload_IE_Lists renames
     AdaBee.MAC.Frames.Info_Elements.Payloads.Lists;

   package Nested_IE_Lists renames
     AdaBee.MAC.Frames.Info_Elements.Nested.Lists;

   package Header_IEs_Model renames
     AdaBee.MAC.Frames.Info_Elements.Headers.Lists.Formal_Model;

   package Payload_IEs_Model renames
     AdaBee.MAC.Frames.Info_Elements.Payloads.Lists.Formal_Model;

   package Nested_IEs_Model renames
     AdaBee.MAC.Frames.Info_Elements.Nested.Lists.Formal_Model;

   ----------------------------------------
   -- Security Checks for Individual IEs --
   ----------------------------------------

   --  These procedures perform the incoming IE security checking procedures
   --  for individual IEs.

   function Check_Header_IE_Security_Level
     (Header               : Frames.Info_Elements.Headers.Header_Field;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field)
      return IE_Status_Kind;
   --  Perform the incoming IE security level checking procedure for an
   --  individual header IE.
   --
   --  If the incoming frame has security disabled, then Key_Desc should be
   --  null. Otherwise, if the incoming frame has security enabled, then the
   --  Key_Desc should point to the matching key descriptor and
   --  Frame_Security_Level should be set to the security level field from
   --  the frame's auxiliary security header.
   --
   --  Ref. IEEE 802.15.4-2024 Section 9.2.8

   function Check_Payload_IE_Security_Level
     (Header               : Frames.Info_Elements.Payloads.Header_Field;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field)
      return IE_Status_Kind;
   --  Perform the incoming IE security level checking procedure for an
   --  individual payload IE.
   --
   --  If the incoming frame has security disabled, then Key_Desc should be
   --  null. Otherwise, if the incoming frame has security enabled, then the
   --  Key_Desc should point to the matching key descriptor and
   --  Frame_Security_Level should be set to the security level field from
   --  the frame's auxiliary security header.
   --
   --  Ref. IEEE 802.15.4-2024 Section 9.2.8

   function Check_Nested_IE_Security_Level
     (Header               : Frames.Info_Elements.Nested.Header_Field;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field)
      return IE_Status_Kind;
   --  Perform the incoming IE security level checking procedure for an
   --  individual nested IE.
   --
   --  If the incoming frame has security disabled, then Key_Desc should be
   --  null. Otherwise, if the incoming frame has security enabled, then the
   --  Key_Desc should point to the matching key descriptor and
   --  Frame_Security_Level should be set to the security level field from
   --  the frame's auxiliary security header.
   --
   --  Ref. IEEE 802.15.4-2024 Section 9.2.8

   function Check_Header_IE_Key_Usage_Policy
     (Header         : Frames.Info_Elements.Headers.Header_Field;
      Key_Desc       : Security_Types.Key_Descriptor;
      Frame_Type     : Frames.Headers.Frame_Type_Field;
      MAC_Command_ID : Bits_8) return IE_Status_Kind;
   --  Perform the incoming IE key usage policy checking procedure for an
   --  individual header IE.
   --
   --  Ref. IEEE 802.15.4-2024 Section 9.2.9

   function Check_Payload_IE_Key_Usage_Policy
     (Header         : Frames.Info_Elements.Payloads.Header_Field;
      Key_Desc       : Security_Types.Key_Descriptor;
      Frame_Type     : Frames.Headers.Frame_Type_Field;
      MAC_Command_ID : Bits_8) return IE_Status_Kind;
   --  Perform the incoming IE key usage policy checking procedure for an
   --  individual payload IE.
   --
   --  Ref. IEEE 802.15.4-2024 Section 9.2.9

   function Check_Nested_IE_Key_Usage_Policy
     (Header         : Frames.Info_Elements.Nested.Header_Field;
      Key_Desc       : Security_Types.Key_Descriptor;
      Frame_Type     : Frames.Headers.Frame_Type_Field;
      MAC_Command_ID : Bits_8) return IE_Status_Kind;
   --  Perform the incoming IE key usage policy checking procedure for an
   --  individual nested IE.
   --
   --  Ref. IEEE 802.15.4-2024 Section 9.2.9

   ----------------------------------
   -- Security Checks for IE Lists --
   ----------------------------------

   --  These procedures perform incoming IE security checking procedures for
   --  IE lists.

   generic
      type Header_Field (<>) is private;

      with
        function Check_IE_Security
          (Header               : Header_Field;
           Device_Desc          : Security_Types.Device_Descriptor;
           SL_Desc              : Security_Types.Security_Level_Descriptor;
           Key_Desc             :
             access constant Security_Types.Key_Descriptor;
           Frame_Security_Level : Frames.Headers.Security_Level_Field)
           return IE_Status_Kind;
      --  Checks the security of an individual IE

      with package Lists is new
        AdaBee.MAC.Frames.Info_Elements.Generic_Lists
          (Header_Field => Header_Field,
           others       => <>);

      with package Lists_Lemmas is new Lists.Lemmas with Ghost;
   procedure Generic_Check_IEs_Security_Disabled
     (IE_List              : Byte_Array;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field;
      IE_Status_List       : in out IE_Status_Array)
   with
     Pre  =>
       --  This procedure is only used when the IE security level descriptor
       --  list is not empty.
       SL_Desc.IE_Security_Level_Descriptor_List_Length > 0

       and then Lists.Formal_Model.Valid_IE_List (IE_List)
       and then IE_Status_List'First = IE_List'First
       and then IE_Status_List'Last = IE_List'Last
       and then (for all X of IE_Status_List => X = Failed),
     Post =>
       --  Positions in IE_Status_List that do not denote a valid IE position
       --  are set to Failed.
       (for all I in IE_Status_List'Range =>
          (if not Lists.Formal_Model.Reachable (IE_List'First, IE_List, I)
           then IE_Status_List (I) = Failed))

       --  Positions of valid IEs in IE_Status_List have their status set to
       --  the result of calling Check_IE_Security on the IE.
       and then
         (for all I of Lists.Formal_Model.Reachable_Set (IE_List) =>
            IE_Status_List (I)
            = Check_IE_Security
                (Lists.IE_Header (IE_List, I),
                 Device_Desc,
                 SL_Desc,
                 Key_Desc,
                 Frame_Security_Level));
   --  Perform the incoming IE security level checking procedure for the
   --  case when SecurityLevel is equal to 0x00 (security disabled).
   --
   --  Ref. IEEE 802.15.4-2024 Section 9.2.8.

   procedure Check_Payload_And_Nested_IEs_Security_Disabled
     (IE_List              : Byte_Array;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field;
      IE_Status_List       : in out IE_Status_Array)
   with
     Global => null,
     Pre    =>
       --  This procedure is only used when the IE security level descriptor
       --  list is not empty.
       SL_Desc.IE_Security_Level_Descriptor_List_Length > 0

       --  IE_List must denote a valid payload IE list
       and then Payload_IEs_Model.Valid_IE_List (IE_List)

       --  Any nested IE lists must also have been validated
       and then Frames.Info_Elements.Payloads.Nested_IE_Lists_Valid (IE_List)

       --  IE_Status_List must have the same range as IE_List, and must be
       --  initialized to Failed.
       and then IE_Status_List'First = IE_List'First
       and then IE_Status_List'Last = IE_List'Last
       and then (for all X of IE_Status_List => X = Failed),
     Post   =>
       --  Positions of valid payload IEs in IE_Status_List have their
       --  status set to the result of
       --  Check_Payload_IE_Security_Level.
       (for all I of Payload_IEs_Model.Reachable_Set (IE_List) =>
          IE_Status_List (I)
          = Check_Payload_IE_Security_Level
              (Payload_IE_Lists.IE_Header (IE_List, I),
               Device_Desc,
               SL_Desc,
               Key_Desc,
               Frame_Security_Level))

       --  Positions of valid nested IEs in IE_Status_List have their status
       --  set to the result of Check_Nested_IE_Security_Level, if and only if
       --  the parent MLME IE passes its security check.
       --
       --  Note that nested IE lists are contained within the content
       --  field of MLME IEs in the payload IE list.
       and then
         (for all I of Payload_IEs_Model.Reachable_Set (IE_List) =>
            (if IE_Status_List (I) = Passed
               and then
                 Payload_IE_Lists.IE_Header (IE_List, I).Group_ID
                 = Frames.Info_Elements.Payloads.MLME_IE
               and then Payload_IE_Lists.IE_Header (IE_List, I).Length > 0
             then
               (declare
                  Nested_IE_List : constant Byte_Array :=
                    Payload_IEs_Model.IE_Content (IE_List, I);
                begin
                  (for all J of
                     Nested_IEs_Model.Reachable_Set (Nested_IE_List) =>
                     IE_Status_List (J)
                     = Check_Nested_IE_Security_Level
                         (Header               =>
                            Nested_IE_Lists.IE_Header (Nested_IE_List, J),
                          Device_Desc          => Device_Desc,
                          SL_Desc              => SL_Desc,
                          Key_Desc             => Key_Desc,
                          Frame_Security_Level => Frame_Security_Level)))))

       --  If an IE status is marked as Passed, then its position denotes
       --  either a payload IE or a nested IE.
       and then
         (for all I in IE_Status_List'Range =>
            (if IE_Status_List (I) = Passed
             then
               --  Position I denotes either a payload IE...
               Payload_IEs_Model.Reachable (IE_List'First, IE_List, I)

               --  ...or a nested IE within a payload IE that has passed
               --  its security check.
               or else
                 (for some J of Payload_IEs_Model.Reachable_Set (IE_List) =>
                    (declare
                       Payload_Header :
                         constant Frames.Info_Elements.Payloads.Header_Field :=
                           Payload_IE_Lists.IE_Header (IE_List, J);
                     begin
                       IE_Status_List (J) = Passed
                       and then
                         Payload_Header.Group_ID
                         = Frames.Info_Elements.Payloads.MLME_IE
                       and then Payload_Header.Length > 0
                       and then
                         Nested_IEs_Model.Reachable
                           (Payload_IEs_Model.IE_Content (IE_List, J), I)))));

end AdaBee.MAC.MLME.Security_Procedures.IE_Procedures;
