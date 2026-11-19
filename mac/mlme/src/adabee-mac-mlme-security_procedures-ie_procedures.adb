--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.MLME.Security_Procedures.IE_Procedures
  with SPARK_Mode
is
   use type AdaBee.MAC.Frames.Info_Elements.Headers.Element_ID_Field;
   use type AdaBee.MAC.Frames.Info_Elements.Nested.Short_Sub_ID_Field;
   use type AdaBee.MAC.Frames.Info_Elements.Nested.Long_Sub_ID_Field;

   use all type AdaBee.MAC.Frames.Headers.Frame_Type_Field;
   use all type AdaBee.MAC.Frames.Info_Elements.IE_Type_Field;
   use all type AdaBee.MAC.MLME.Security_Types.IE_Kind;

   function Check_IE_Allowed_Security_Levels
     (SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             :
        not null access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field)
      return IE_Status_Kind
   is (if (for some D of
             SL_Desc.IE_Security_Level_Descriptor_List
               (1 .. SL_Desc.IE_Security_Level_Descriptor_List_Length) =>
             D.IE_Allowed_Security_Levels
               (Key_Desc.all.Key.AEAD_Algorithm, Frame_Security_Level))
       then Passed
       else Failed);
   --  Check whether the tuple formed by AEAD_Algorithm from the key descriptor
   --  and the SecurityLevel from the incoming frame is equal to any of the
   --  elements of the IE allowed security levels list of the security level
   --  descriptor.

   ------------------------------------
   -- Check_Header_IE_Security_Level --
   ------------------------------------

   --  Ref. IEEE 802.15.4-2024 Section 9.2.8

   function Check_Header_IE_Security_Level
     (Header               : Frames.Info_Elements.Headers.Header_Field;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field)
      return IE_Status_Kind
   is (
       --  case a)
       if SL_Desc.IE_Security_Level_Descriptor_List_Length = 0
       then Passed

       --  case c) 1)
       elsif Key_Desc /= null
       then
         Check_IE_Allowed_Security_Levels
           (SL_Desc, Key_Desc, Frame_Security_Level)

       --  case c) 2)
       elsif Device_Desc.Exempt
         and then
           (for some D of
              SL_Desc.IE_Security_Level_Descriptor_List
                (1 .. SL_Desc.IE_Security_Level_Descriptor_List_Length) =>
              D.IE_Type = Header_IE
              and then D.Header_IE_ID = Header.Element_ID
              and then D.IE_Device_Override_Security_Levels)
       then Passed

       --  case b)
       else Failed);

   -------------------------------------
   -- Check_Payload_IE_Security_Level --
   -------------------------------------

   --  Ref. IEEE 802.15.4-2024 Section 9.2.8

   function Check_Payload_IE_Security_Level
     (Header               : Frames.Info_Elements.Payloads.Header_Field;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field)
      return IE_Status_Kind
   is (
       --  case a)
       if SL_Desc.IE_Security_Level_Descriptor_List_Length = 0
       then Passed

       --  case c) 1)
       elsif Key_Desc /= null
       then
         Check_IE_Allowed_Security_Levels
           (SL_Desc, Key_Desc, Frame_Security_Level)

       --  case c) 2)
       elsif Device_Desc.Exempt
         and then
           (for some D of
              SL_Desc.IE_Security_Level_Descriptor_List
                (1 .. SL_Desc.IE_Security_Level_Descriptor_List_Length) =>
              D.IE_Type = Payload_IE
              and then D.Payload_IE_ID = Header.Group_ID
              and then D.IE_Device_Override_Security_Levels)
       then Passed

       --  case b)
       else Failed);

   -------------------------------------
   -- Check_Nested_IE_Security_Level --
   -------------------------------------

   --  Ref. IEEE 802.15.4-2024 Section 9.2.8

   function Check_Nested_IE_Security_Level
     (Header               : Frames.Info_Elements.Nested.Header_Field;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field)
      return IE_Status_Kind
   is (
       --  case a)
       if SL_Desc.IE_Security_Level_Descriptor_List_Length = 0
       then Passed

       --  case c) 1)
       elsif Key_Desc /= null
       then
         Check_IE_Allowed_Security_Levels
           (SL_Desc, Key_Desc, Frame_Security_Level)

       --  case c) 2)
       elsif Device_Desc.Exempt
         and then
           (for some D of
              SL_Desc.IE_Security_Level_Descriptor_List
                (1 .. SL_Desc.IE_Security_Level_Descriptor_List_Length) =>
              (case Header.IE_Type is
                 when Short =>
                   D.IE_Type = Nested_Short_IE
                   and then D.Nested_Short_IE_ID = Header.Short_Sub_ID,

                 when Long  =>
                   D.IE_Type = Nested_Long_IE
                   and then D.Nested_Long_IE_ID = Header.Long_Sub_ID)
              and then D.IE_Device_Override_Security_Levels)
       then Passed

       --  case b)
       else Failed);

   --------------------------------------
   -- Check_Header_IE_Key_Usage_Policy --
   --------------------------------------

   function Check_Header_IE_Key_Usage_Policy
     (Header         : Frames.Info_Elements.Headers.Header_Field;
      Key_Desc       : Security_Types.Key_Descriptor;
      Frame_Type     : Frames.Headers.Frame_Type_Field;
      MAC_Command_ID : Bits_8) return IE_Status_Kind
   is (if (for some Usage_Policy of
             Key_Desc.Key_Usage_Descriptor_List
               (1 .. Key_Desc.Key_Usage_Descriptor_List_Length) =>
             Usage_Policy.Key_Usage_Frame_Types (Frame_Type)

             and then
               (if Frame_Type = MAC_Command
                then
                  MAC_Command_ID in Usage_Policy.Key_Usage_Command_IDs'Range
                  and then Usage_Policy.Key_Usage_Command_IDs (MAC_Command_ID))

             and then
               (for some IE_Policy of
                  Usage_Policy.Key_IE_Usage_Descriptor_List
                    (1 .. Usage_Policy.Key_IE_Usage_Descriptor_List_Length) =>
                  IE_Policy.Key_IE_Type = Header_IE
                  and then IE_Policy.Header_Key_IE_ID = Header.Element_ID))
       then Passed
       else Failed);

   --------------------------------------
   -- Check_Payload_IE_Key_Usage_Policy --
   --------------------------------------

   function Check_Payload_IE_Key_Usage_Policy
     (Header         : Frames.Info_Elements.Payloads.Header_Field;
      Key_Desc       : Security_Types.Key_Descriptor;
      Frame_Type     : Frames.Headers.Frame_Type_Field;
      MAC_Command_ID : Bits_8) return IE_Status_Kind
   is (if (for some Usage_Policy of
             Key_Desc.Key_Usage_Descriptor_List
               (1 .. Key_Desc.Key_Usage_Descriptor_List_Length) =>
             Usage_Policy.Key_Usage_Frame_Types (Frame_Type)

             and then
               (if Frame_Type = MAC_Command
                then
                  MAC_Command_ID in Usage_Policy.Key_Usage_Command_IDs'Range
                  and then Usage_Policy.Key_Usage_Command_IDs (MAC_Command_ID))

             and then
               (for some IE_Policy of
                  Usage_Policy.Key_IE_Usage_Descriptor_List
                    (1 .. Usage_Policy.Key_IE_Usage_Descriptor_List_Length) =>
                  IE_Policy.Key_IE_Type = Payload_IE
                  and then IE_Policy.Payload_Key_IE_ID = Header.Group_ID))
       then Passed
       else Failed);

   --------------------------------------
   -- Check_Nested_IE_Key_Usage_Policy --
   --------------------------------------

   function Check_Nested_IE_Key_Usage_Policy
     (Header         : Frames.Info_Elements.Nested.Header_Field;
      Key_Desc       : Security_Types.Key_Descriptor;
      Frame_Type     : Frames.Headers.Frame_Type_Field;
      MAC_Command_ID : Bits_8) return IE_Status_Kind
   is (if (for some Usage_Policy of
             Key_Desc.Key_Usage_Descriptor_List
               (1 .. Key_Desc.Key_Usage_Descriptor_List_Length) =>
             Usage_Policy.Key_Usage_Frame_Types (Frame_Type)

             and then
               (if Frame_Type = MAC_Command
                then
                  MAC_Command_ID in Usage_Policy.Key_Usage_Command_IDs'Range
                  and then Usage_Policy.Key_Usage_Command_IDs (MAC_Command_ID))

             and then
               (if Header.IE_Type = Short
                then
                  (for some IE_Policy of
                     Usage_Policy.Key_IE_Usage_Descriptor_List
                       (1
                        .. Usage_Policy.Key_IE_Usage_Descriptor_List_Length) =>
                     (IE_Policy.Key_IE_Type = Nested_Short_IE
                      and then
                        IE_Policy.Nested_Short_Key_IE_ID
                        = Header.Short_Sub_ID))
                else
                  (for some IE_Policy of
                     Usage_Policy.Key_IE_Usage_Descriptor_List
                       (1
                        .. Usage_Policy.Key_IE_Usage_Descriptor_List_Length) =>
                     (IE_Policy.Key_IE_Type = Nested_Long_IE
                      and then
                        IE_Policy.Nested_Long_Key_IE_ID
                        = Header.Long_Sub_ID))))
       then Passed
       else Failed);

   -----------------------------------------
   -- Generic_Check_IEs_Security_Disabled --
   -----------------------------------------

   procedure Generic_Check_IEs_Security_Disabled
     (IE_List              : Byte_Array;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field;
      IE_Status_List       : in out IE_Status_Array)
   is
      use Lists;
      use Lists.Formal_Model;

      use type Lists.Formal_Model.S.Set;

      Visited : S.Set := S.Empty_Set
      with Ghost;
      --  Keeps track of the positions of IEs processed so far

      Pos : Positive := IE_List'First;
   begin

      --  Iterate through the list and for each IE, check it using
      --  Check_IE_Security, then record the result at the corresponding
      --  position in IE_Status_List.

      loop
         IE_Status_List (Pos) :=
           Check_IE_Security
             (IE_Header (IE_List, Pos),
              Device_Desc,
              SL_Desc,
              Key_Desc,
              Frame_Security_Level);

         exit when Is_Last_IE (IE_List, Pos);

         Lists_Lemmas.Lemma_Reachable_Next (IE_List, Pos);
         Visited := S.Add (Visited, Pos);

         Pos := Next_IE_Position (IE_List, Pos);

         pragma Loop_Variant (Increases => Pos);

         --  Pos always denotes the position of a valid IE that is reachable
         --  from the start of the list.
         pragma Loop_Invariant (Reachable (IE_List'First, IE_List, Pos));

         --  Pos is always past the IEs visited so far
         pragma Loop_Invariant (for all P of Visited => Pos > P);

         pragma
           Loop_Invariant
             (
             --  Visited contains a subset of all reachable IEs
             Visited <= Reachable_Set (IE_List, IE_List'First)

              --  The set of IEs reachable from Pos is a subset of the IE list
              and then
                Reachable_Set (IE_List, Pos)
                <= Reachable_Set (IE_List, IE_List'First)

              --  All reachable IEs in the IE list are either in the Visited
              --  set, or are waiting to be processed.
              and then S.No_Overlap (Visited, Reachable_Set (IE_List, Pos))

              --  There are no IEs in Visited or reachable from Pos that are
              --  not in the IE list
              and then
                S.Included_In_Union
                  (Reachable_Set (IE_List, IE_List'First),
                   Reachable_Set (IE_List, Pos),
                   Visited));

         --  All IEs processed so far have their IE status set to the result
         --  of calling Check_Header_IE_Security_Level
         pragma
           Loop_Invariant
             (for all P of Visited =>
                IE_Status_List (P)
                = Check_IE_Security
                    (IE_Header (IE_List, P),
                     Device_Desc,
                     SL_Desc,
                     Key_Desc,
                     Frame_Security_Level));

         --  All positions in IE_Status_List that do not denote the position of
         --  a valid IE have their status set to Failed.
         pragma
           Loop_Invariant
             (for all I in IE_Status_List'Range =>
                (if not Reachable (IE_List'First, IE_List, I)
                 then IE_Status_List (I) = Failed));
      end loop;

      pragma Assert (S.Is_Singleton (Reachable_Set (IE_List, Pos), Pos));
   end Generic_Check_IEs_Security_Disabled;

   ----------------------------------------
   -- Check_Nested_IEs_Security_Disabled --
   ----------------------------------------

   procedure Check_Nested_IEs_Security_Disabled is new
     IE_Procedures.Generic_Check_IEs_Security_Disabled
       (Header_Field      => Frames.Info_Elements.Nested.Header_Field,
        Check_IE_Security => IE_Procedures.Check_Nested_IE_Security_Level,
        Lists             => Frames.Info_Elements.Nested.Lists,
        Lists_Lemmas      => Frames.Info_Elements.Nested.Lemmas);

   ----------------------------------------------------
   -- Check_Payload_And_Nested_IEs_Security_Disabled --
   ----------------------------------------------------

   procedure Check_Payload_And_Nested_IEs_Security_Disabled
     (IE_List              : Byte_Array;
      Device_Desc          : Security_Types.Device_Descriptor;
      SL_Desc              : Security_Types.Security_Level_Descriptor;
      Key_Desc             : access constant Security_Types.Key_Descriptor;
      Frame_Security_Level : Frames.Headers.Security_Level_Field;
      IE_Status_List       : in out IE_Status_Array)
   is
      use AdaBee.MAC.Frames.Info_Elements;
      use AdaBee.MAC.Frames.Info_Elements.Payloads;
      use AdaBee.MAC.Frames.Info_Elements.Payloads.Lists;
      use AdaBee.MAC.Frames.Info_Elements.Payloads.Lists.Formal_Model;
      use AdaBee.MAC.Frames.Info_Elements.Payloads.Lemmas;

      use type Payload_IEs_Model.S.Set;

      Visited : S.Set := S.Empty_Set
      with Ghost;
      --  Keeps track of the positions of payload IEs processed so far

      Pos    : Positive := IE_List'First;
      Header : AdaBee.MAC.Frames.Info_Elements.Payloads.Header_Field;

      Content_First : Positive;
      Content_Last  : Positive;
   begin

      --  Iterate through the payload IE list and for each IE, check it using
      --  Check_IE_Security, then record the result at the corresponding
      --  position in IE_Status_List.
      --
      --  When MLME IEs are encountered, then the security of nested IEs are
      --  also checked.

      loop

         --  Check the security of the payload IE

         Header := IE_Header (IE_List, Pos);

         IE_Status_List (Pos) :=
           Check_Payload_IE_Security_Level
             (Header, Device_Desc, SL_Desc, Key_Desc, Frame_Security_Level);

         --  If the IE is an MLME IE, also check the security of nested IEs.
         --
         --  Nested IEs are not checked (and all marked as Failed) if the
         --  MLME IE failed its security check.

         if IE_Status_List (Pos) = Passed
           and then Header.Group_ID = MLME_IE
           and then Header.Length > 0
         then
            Content_First := Pos + IE_Header_Length;
            Content_Last :=
              Pos + IE_Header_Length + (Natural (Header.Length) - 1);

            pragma
              Assert
                (Content_First
                 = Payload_IE_Lists.Content_First (IE_List, Pos));

            pragma
              Assert
                (Content_Last = Payload_IE_Lists.Content_Last (IE_List, Pos));

            Check_Nested_IEs_Security_Disabled
              (IE_List              => IE_List (Content_First .. Content_Last),
               Device_Desc          => Device_Desc,
               SL_Desc              => SL_Desc,
               Key_Desc             => Key_Desc,
               Frame_Security_Level => Frame_Security_Level,
               IE_Status_List       =>
                 IE_Status_List (Content_First .. Content_Last));
         end if;

         --  Move to the next IE, stopping at the last one

         exit when Is_Last_IE (IE_List, Pos);

         Lemma_Reachable_Next (IE_List, Pos);
         Visited := S.Add (Visited, Pos);

         Pos := Next_IE_Position (IE_List, Pos);

         --  The following loop invariants prove that

         pragma Loop_Variant (Increases => Pos);

         --  Pos always denotes the position of a valid IE that is reachable
         --  from the start of the list.
         pragma Loop_Invariant (Reachable (IE_List'First, IE_List, Pos));

         --  Pos is always past the IEs visited so far
         pragma Loop_Invariant (for all P of Visited => Pos > P);

         --  All unvisited positions are marked as Failed
         pragma
           Loop_Invariant
             (for all I in IE_Status_List'Range =>
                (if I >= Pos then IE_Status_List (I) = Failed));

         pragma
           Loop_Invariant
             (
             --  Visited contains a subset of all reachable IEs
             Visited <= Reachable_Set (IE_List, IE_List'First)

              --  The set of IEs reachable from Pos is a subset of the IE list
              and then
                Reachable_Set (IE_List, Pos)
                <= Reachable_Set (IE_List, IE_List'First)

              --  All reachable IEs in the IE list are either in the Visited
              --  set, or are waiting to be processed.
              and then S.No_Overlap (Visited, Reachable_Set (IE_List, Pos))

              --  There are no IEs in Visited or reachable from Pos that are
              --  not in the IE list
              and then
                S.Included_In_Union
                  (Reachable_Set (IE_List, IE_List'First),
                   Reachable_Set (IE_List, Pos),
                   Visited)

              --  All visited IEs are positioned before Pos
              and then (for all P of Visited => P < Pos));

         --  All visited positions are marked as Passed if and only if it
         --  denotes a valid IE position
         pragma
           Loop_Invariant
             (for all I in IE_Status_List'Range =>
                (if I < Pos and then IE_Status_List (I) = Passed
                 then
                   --  I denotes a visited payload IE...
                   S.Contains (Visited, I)

                   --  Or denotes a nested IE within a visited MLME IE
                   or else
                     (for some P of Visited =>
                        (declare
                           Header : constant Header_Field :=
                             IE_Header (IE_List, P);
                         begin
                           IE_Status_List (P) = Passed
                           and then Header.Group_ID = MLME_IE
                           and then Header.Length > 0
                           and then
                             Nested_IEs_Model.Reachable
                               (Payload_IEs_Model.IE_Content (IE_List, P),
                                I)))));

         --  Every visited nested IE has its status in IE_Status_List set to
         --  the result of calling Check_Nested_IE_Security_Level, but only
         --  when the parent MLME IE has passed its security check.
         pragma
           Loop_Invariant
             (for all P of Visited =>
                (declare
                   Header : constant Header_Field := IE_Header (IE_List, P);
                 begin
                   (if IE_Status_List (P) = Passed
                      and then Header.Group_ID = MLME_IE
                      and then Header.Length > 0
                    then
                      (declare
                         Nested_IE_List : constant Byte_Array :=
                           Payload_IEs_Model.IE_Content (IE_List, P);
                       begin
                         (for all N of
                            Nested_IEs_Model.Reachable_Set (Nested_IE_List) =>
                            N < Pos
                            and then
                              IE_Status_List (N)
                              = Check_Nested_IE_Security_Level
                                  (Nested_IE_Lists.IE_Header
                                     (Nested_IE_List, N),
                                   Device_Desc,
                                   SL_Desc,
                                   Key_Desc,
                                   Frame_Security_Level))))));

         --  All payload IEs processed so far have their IE status set to the
         --  result of calling Check_Header_IE_Security_Level
         pragma
           Loop_Invariant
             (for all P of Visited =>
                IE_Status_List (P)
                = Check_Payload_IE_Security_Level
                    (IE_Header (IE_List, P),
                     Device_Desc,
                     SL_Desc,
                     Key_Desc,
                     Frame_Security_Level));
      end loop;

      pragma Assert (S.Is_Singleton (Reachable_Set (IE_List, Pos), Pos));
   end Check_Payload_And_Nested_IEs_Security_Disabled;

end AdaBee.MAC.MLME.Security_Procedures.IE_Procedures;
