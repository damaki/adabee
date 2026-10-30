--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  This package provides some useful lemmas for reasoning about properties
--  over IE lists.

generic
package AdaBee.MAC.Frames.Info_Elements.Generic_Lists.Lemmas with
    Elaborate_Body,
    SPARK_Mode,
    Ghost,
    Always_Terminates
is

   use Formal_Model;
   use type V.Sequence;

   --------------------------
   -- Miscellaneous Lemmas --
   --------------------------

   procedure Lemma_Valid_IE_List_Last (Buffer : Byte_Array; X : Positive)
   with
     Pre  =>
       X in Buffer'Range
       and then Valid_IE (Buffer, X)
       and then Is_Last_IE (Buffer, X),
     Post => Valid_IE_List (Buffer, X);
   --  An IE which is the last IE is a valid IE list on its own

   procedure Lemma_Reachable_Next (Buffer : Byte_Array; X : Positive)
   with
     Pre  => Valid_IE_List (Buffer, X) and then not Is_Last_IE (Buffer, X),
     Post =>
       S.Length (Reachable_Set (Buffer, Next_IE_Position (Buffer, X)))
       = S.Length (Reachable_Set (Buffer, X)) - 1
       and then
         Reachable_Set (Buffer, Next_IE_Position (Buffer, X))
         <= Reachable_Set (Buffer, X)
       and then
         S.Included_Except
           (Reachable_Set (Buffer, X),
            Reachable_Set (Buffer, Next_IE_Position (Buffer, X)),
            X);
   --  The set of reachable IEs after X is a subset of the reachable set
   --  starting from X.

   procedure Lemma_Last_IE_Position_Next (Buffer : Byte_Array; X : Positive)
   with
     Pre  => Valid_IE_List (Buffer, X) and then not Is_Last_IE (Buffer, X),
     Post =>
       Last_IE_Position (Buffer, Next_IE_Position (Buffer, X))
       = Last_IE_Position (Buffer, X);
   --  Definition of Last_IE_Position for the next IE

   procedure Lemma_IE_List_Length_Next (Buffer : Byte_Array; X : Positive)
   with
     Pre  => Valid_IE_List (Buffer, X) and then not Is_Last_IE (Buffer, X),
     Post =>
       IE_List_Length (Buffer, Next_IE_Position (Buffer, X))
       = IE_List_Length (Buffer, X) - IE_Length (Buffer, X);
   --  Definition of IE_List_Length for the next IE

   procedure Lemma_Model_Next (Buffer : Byte_Array; X : Positive)
   with
     Pre  => Valid_IE_List (Buffer, X) and then not Is_Last_IE (Buffer, X),
     Post =>
       Model (Buffer, Next_IE_Position (Buffer, X)) < Model (Buffer, X)
       and then
         V.Length (Model (Buffer, Next_IE_Position (Buffer, X)))
         = V.Length (Model (Buffer, X)) - 1;
   --  The model of the next IE after X is a strict prefix of the model
   --  starting from X.

   procedure Lemma_Model_Monotonic (Buffer : Byte_Array; X : Positive)
   with
     Pre                => Valid_IE_List (Buffer, X),
     Post               =>
       (for all I of Reachable_Set (Buffer, X) =>
          (for all J of Reachable_Set (Buffer, X) =>
             (I < J) = (Model (Buffer, J) < Model (Buffer, I)))),
     Subprogram_Variant => (Increases => X);
   --  Models of IEs occuring later in the list are strict prefixes of
   --  the models of IEs occuring earlier in the list.

   procedure Lemma_Termination_IE_Unique (Buffer : Byte_Array; X : Positive)
   with
     Pre                => Valid_IE_List (Buffer, X),
     Post               =>
       (for all I of Reachable_Set (Buffer, X) =>
          (for all J of Reachable_Set (Buffer, X) =>
             (if Is_Termination_IE (IE_Header (Buffer, I))
                and then Is_Termination_IE (IE_Header (Buffer, J))
              then I = J))),
     Subprogram_Variant => (Increases => X);
   --  There is no more than one termination IE in the set of reachable IEs.

   procedure Lemma_Slice_Equal_Next (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre  =>
       Valid_IE_List (B1, X1)
       and then X2 in B2'Range
       and then (B2'Last - X2) >= IE_List_Length (B1, X1) - 1
       and then
         B1 (X1 .. X1 + (IE_List_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_List_Length (B1, X1) - 1)),
     Post =>
       (if not Is_Last_IE (B1, X1)
        then
          B1 (Next_IE_Position (B1, X1) .. X1 + (IE_List_Length (B1, X1) - 1))
          = B2
              (X2 + IE_Length (B1, X1) .. X2 + (IE_List_Length (B1, X1) - 1)));
   --  If B1 contains a valid IE list starting at position X1, and the slice
   --  of B1 that contains the IE list is equal in B2 starting at X2, then
   --  if the IE at position X1 in B1 is not the last IE then the slice of
   --  B1 that contains the subsequent IEs is equal at the corresponding
   --  position in B2.

   procedure Lemma_IE_List_Length_Implies_Terminated
     (Buffer : Byte_Array; X : Positive)
   with
     Pre                => Valid_IE_List (Buffer, X),
     Post               =>
       (if IE_List_Length (Buffer, X) - 1 < Buffer'Last - X
        then Is_Terminated (Buffer, X)),
     Subprogram_Variant => (Increases => X);
   --  Lemma to prove the property that if the length of an IE list is shorter
   --  than the buffer space available to it, then it must end in a termination
   --  IE.

   -----------------------------
   -- Lemmas for Reachability --
   -----------------------------

   procedure Lemma_IE_List_Length_Anti_Isometric
     (Buffer : Byte_Array; X : Positive)
   with
     Pre                => Valid_IE_List (Buffer, X),
     Post               =>
       (for all Y of Reachable_Set (Buffer, X) =>
          IE_List_Length (Buffer, X) - IE_List_Length (Buffer, Y) = Y - X),
     Subprogram_Variant => (Increases => X);
   --  The difference between the IE list lengths of reachable IEs is
   --  equal to the difference of their positions

   procedure Lemma_Reachable_Transitive
     (Buffer : Byte_Array; X, Y, Z : Positive)
   with
     Pre                => Valid_IE_List (Buffer, X),
     Post               =>
       (if Reachable (X, Buffer, Y) and then Reachable (Y, Buffer, Z)
        then Reachable (X, Buffer, Z)),
     Subprogram_Variant => (Decreases => S.Length (Reachable_Set (Buffer, X)));
   --  If X is a valid IE list, Y is reachable from X, and Z is reachable
   --  from Y, then Z is reachable from X.

   procedure Lemma_Reachable_Ordered (Buffer : Byte_Array; X : Positive)
   with
     Pre                => Valid_IE_List (Buffer, X),
     Post               =>
       (for all I of Reachable_Set (Buffer, X) =>
          (for all J of Reachable_Set (Buffer, X) =>
             (I <= J) = Reachable (I, Buffer, J))),
     Subprogram_Variant => (Increases => X);
   --  IEs located further in the IE list are reachable from IEs located
   --  earlier in the IE list.

   procedure Lemma_Reachable_Range (Buffer : Byte_Array; X : Positive)
   with
     Pre                => Valid_IE_List (Buffer, X),
     Post               =>
       (for all P of Reachable_Set (Buffer, X) =>
          P >= X and then P < X + (IE_List_Length (Buffer, X) - 1)),
     Subprogram_Variant => (Increases => X);
   --  The positions of all reachable IEs in the list starting at position
   --  X are bounded to within range of the IE list's length in Buffer.

   --------------------------------------
   -- Lemmas for Property Preservation --
   --------------------------------------

   --  These lemmas are used to prove that properties on IE lists are
   --  preserved between two buffers when the memory containing an IE list is
   --  equal in both buffers.

   procedure Lemma_Valid_IE_List_Preserved
     (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X1)
       and then X2 in B2'Range
       and then
         (if Is_Terminated (B1, X1)
          then B2'Last - X2 >= IE_List_Length (B1, X1) - 1
          else B2'Last - X2 = IE_List_Length (B1, X1) - 1)
       and then
         B1 (X1 .. X1 + (IE_List_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_List_Length (B1, X1) - 1)),
     Post               => Valid_IE_List (B2, X2),
     Subprogram_Variant => (Increases => X1);
   --  Prove the preservation of the Valid_IE_List property between buffers
   --  B1 and B2 at different positions.

   procedure Lemma_IE_Length_Preserved (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre  =>
       B1'Length >= IE_Header_Length
       and then X2 in B2'Range
       and then X1 in B1'First .. B1'Last - (IE_Header_Length - 1)
       and then X2 in B2'First .. B2'Last - (IE_Header_Length - 1)
       and then
         B1 (X1 .. X1 + (IE_Header_Length - 1))
         = B2 (X2 .. X2 + (IE_Header_Length - 1)),
     Post => IE_Length (B2, X2) = IE_Length (B1, X1);
   --  If the IE header bytes are equal in B1 and B2 at positions X1 and X2
   --  respectively, then the IE lengths are identical.

   procedure Lemma_IE_List_Length_Preserved
     (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X1)
       and then X2 in B2'Range
       and then
         (if Is_Terminated (B1, X1)
          then B2'Last - X2 >= IE_List_Length (B1, X1) - 1
          else B2'Last - X2 = IE_List_Length (B1, X1) - 1)
       and then
         B1 (X1 .. X1 + (IE_List_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_List_Length (B1, X1) - 1)),
     Post               => IE_List_Length (B2, X2) = IE_List_Length (B1, X1),
     Subprogram_Variant => (Increases => X1);
   --  If the IE list memory is equal in B1 and B2 at positions X1 and X2
   --  respectively, then the IE list lengths are identical.

   procedure Lemma_IE_Count_Preserved (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X1)
       and then X2 in B2'Range
       and then
         (if Is_Terminated (B1, X1)
          then B2'Last - X2 >= IE_List_Length (B1, X1) - 1
          else B2'Last - X2 = IE_List_Length (B1, X1) - 1)
       and then
         B1 (X1 .. X1 + (IE_List_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_List_Length (B1, X1) - 1)),
     Post               => IE_Count (B2, X2) = IE_Count (B1, X1),
     Subprogram_Variant => (Increases => X1);
   --  If the IE list memory is equal in B1 and B2 at positions X1 and X2
   --  respectively, then the number of IEs in the list is preserved.

   procedure Lemma_Reachable_Set_Shifted
     (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X1)
       and then X2 in B2'Range
       and then
         (if Is_Terminated (B1, X1)
          then B2'Last - X2 >= IE_List_Length (B1, X1) - 1
          else B2'Last - X2 = IE_List_Length (B1, X1) - 1)
       and then
         B1 (X1 .. X1 + (IE_List_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_List_Length (B1, X1) - 1)),
     Post               =>
       S.Length (Reachable_Set (B2, X2)) = S.Length (Reachable_Set (B1, X1))
       and then
         (for all P of Reachable_Set (B1, X1) =>
            Positive'Last - P >= X2 - X1
            and then P + (X2 - X1) in B2'Range
            and then S.Contains (Reachable_Set (B2, X2), P + (X2 - X1)))
       and then
         (for all P of Reachable_Set (B2, X2) =>
            P - Positive'First >= X2 - X1
            and then P - (X2 - X1) in B1'Range
            and then S.Contains (Reachable_Set (B1, X1), P - (X2 - X1))),
     Subprogram_Variant => (Increases => X1);
   --  If the IE list memory is equal in B1 and B2 at positions X1 and X2
   --  respectively, then the positions of all reachable IEs are shifted by
   --  the difference of X2 and X1.

   procedure Lemma_Reachable_Set_Preserved (B1, B2 : Byte_Array; X : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X)
       and then B2'First <= B1'First
       and then
         (if Is_Terminated (B1, X)
          then B2'Last >= X + (IE_List_Length (B1, X) - 1)
          else B2'Last = X + (IE_List_Length (B1, X) - 1))
       and then
         B1 (X .. X + (IE_List_Length (B1, X) - 1))
         = B2 (X .. X + (IE_List_Length (B1, X) - 1)),
     Post               =>
       Reachable_Set (B2, X) = Reachable_Set (B1, X)
       and then
         S.Length (Reachable_Set (B2, X)) = S.Length (Reachable_Set (B1, X)),
     Subprogram_Variant => (Increases => X);
   --  If the IE list memory is equal in B1 and B2 at position X in both,
   --  then the set of reachable IE positions is preserved.

   procedure Lemma_Model_Shifted (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X1)
       and then X2 in B2'Range
       and then
         (if Is_Terminated (B1, X1)
          then B2'Last - X2 >= IE_List_Length (B1, X1) - 1
          else B2'Last - X2 = IE_List_Length (B1, X1) - 1)
       and then
         B1 (X1 .. X1 + (IE_List_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_List_Length (B1, X1) - 1)),
     Post               =>
       (declare
          M1 : constant V.Sequence := Model (B1, X1);
          M2 : constant V.Sequence := Model (B2, X2);
        begin
          V.Length (M1) = V.Length (M2)
          and then
            (for all I in M1 => V.Get (M2, I) = V.Get (M1, I) + (X2 - X1))),
     Subprogram_Variant => (Increases => X1);
   --  If the IE list memory is equal in B1 and B2 at positions X1 and X2
   --  respectively, then the positions in the model in B2 are shifted by
   --  the difference of X2 and X1.

   procedure Lemma_Model_Preserved (B1, B2 : Byte_Array; X : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X)
       and then B2'First <= B1'First
       and then
         (if Is_Terminated (B1, X)
          then B2'Last >= X + (IE_List_Length (B1, X) - 1)
          else B2'Last = X + (IE_List_Length (B1, X) - 1))
       and then
         B1 (X .. X + (IE_List_Length (B1, X) - 1))
         = B2 (X .. X + (IE_List_Length (B1, X) - 1)),
     Post               => Model (B2, X) = Model (B1, X),
     Subprogram_Variant => (Increases => X);
   --  If the IE list memory is equal in B1 and B2 at position X in both,
   --  then the model of IE positions is preserved.

   procedure Lemma_IE_Header_Preserved (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre  =>
       B1'Length >= IE_Header_Length
       and then X2 in B2'Range
       and then X1 in B1'First .. B1'Last - (IE_Header_Length - 1)
       and then X2 in B2'First .. B2'Last - (IE_Header_Length - 1)
       and then
         B1 (X1 .. X1 + (IE_Header_Length - 1))
         = B2 (X2 .. X2 + (IE_Header_Length - 1)),
     Post => IE_Header (B2, X2) = IE_Header (B1, X1);
   --  If the IE header memory is equal in B1 and B2 at positions X1 and X2
   --  respectively, then the contents of the IE header is preserved.

   procedure Lemma_Reachable_IE_Headers_Preserved
     (B1, B2 : Byte_Array; X : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X)
       and then B2'First <= B1'First
       and then
         (if Is_Terminated (B1, X)
          then B2'Last >= X + (IE_List_Length (B1, X) - 1)
          else B2'Last = X + (IE_List_Length (B1, X) - 1))
       and then
         B1 (X .. X + (IE_List_Length (B1, X) - 1))
         = B2 (X .. X + (IE_List_Length (B1, X) - 1)),
     Post               =>
       (for all P of Reachable_Set (B1, X) =>
          IE_Header (B1, P) = IE_Header (B2, P)),
     Subprogram_Variant => (Increases => X);
   --  If the IE list memory is equal in B1 and B2 at position X in both,
   --  then the IE headers of all reachable IEs are preserved in B2.

   procedure Lemma_Reachable_IE_Headers_Preserved_Prefix
     (B1, B2 : Byte_Array; X : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X)
       and then Valid_IE_List (B2, X)
       and then IE_List_Length (B1, X) <= IE_List_Length (B2, X)
       and then Reachable_Set (B1, X) <= Reachable_Set (B2, X)
       and then
         B1 (X .. X + (IE_List_Length (B1, X) - 1))
         = B2 (X .. X + (IE_List_Length (B1, X) - 1)),
     Post               =>
       (for all P of Reachable_Set (B1, X) =>
          IE_Header (B2, P) = IE_Header (B1, P)),
     Subprogram_Variant => (Increases => X);
   --  If B1 and B2 both contain a valid IE list at position X, the list in
   --  B2 is longer than the one in B1, and the memory for the list in B1 is
   --  equal in B2, then all reachable IE headers in B1 are equal in B2 at the
   --  same position.

   procedure Lemma_Reachable_IE_Headers_Shifted
     (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X1)
       and then X2 in B2'Range
       and then
         (if Is_Terminated (B1, X1)
          then B2'Last - X2 >= IE_List_Length (B1, X1) - 1
          else B2'Last - X2 = IE_List_Length (B1, X1) - 1)
       and then
         B1 (X1 .. X1 + (IE_List_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_List_Length (B1, X1) - 1)),
     Post               =>
       (for all P of Reachable_Set (B1, X1) =>
          IE_Header (B2, P + (X2 - X1)) = IE_Header (B1, P)),
     Subprogram_Variant => (Increases => X1);
   --  If the IE header memory is equal in B1 and B2 at positions X1 and X2
   --  respectively, then the IE headers of all reachable IEs are preserved
   --  in B2, but their position is shifted by the difference of X2 and X1.

   procedure Lemma_IE_Content_Preserved
     (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre  =>
       X1 in B1'Range
       and then Valid_IE (B1, X1)
       and then X2 in B2'Range
       and then (B2'Last - X2) >= IE_Length (B1, X1) - 1
       and then
         B1 (X1 .. X1 + (IE_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_Length (B1, X1) - 1)),
     Post => IE_Content (B2, X2) = IE_Content (B1, X1);
   --  If the IE header memory is equal in B1 and B2 at positions X1 and X2
   --  respectively, then the IE content field is preserved.

   procedure Lemma_Reachable_IE_Content_Preserved
     (B1, B2 : Byte_Array; X : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X)
       and then B2'First <= B1'First
       and then
         (if Is_Terminated (B1, X)
          then B2'Last >= X + (IE_List_Length (B1, X) - 1)
          else B2'Last = X + (IE_List_Length (B1, X) - 1))
       and then
         B1 (X .. X + (IE_List_Length (B1, X) - 1))
         = B2 (X .. X + (IE_List_Length (B1, X) - 1)),
     Post               =>
       (for all P of Reachable_Set (B1, X) =>
          IE_Content (B1, P) = IE_Content (B2, P)),
     Subprogram_Variant => (Increases => X);
   --  If the IE list memory is equal in B1 and B2 at position X in both,
   --  then the IE content fields of all reachable IEs are preserved in B2.

   procedure Lemma_Reachable_IE_Content_Preserved_Prefix
     (B1, B2 : Byte_Array; X : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X)
       and then Valid_IE_List (B2, X)
       and then IE_List_Length (B1, X) <= IE_List_Length (B2, X)
       and then Reachable_Set (B1, X) <= Reachable_Set (B2, X)
       and then
         B1 (X .. X + (IE_List_Length (B1, X) - 1))
         = B2 (X .. X + (IE_List_Length (B1, X) - 1)),
     Post               =>
       (for all P of Reachable_Set (B1, X) =>
          IE_Content (B2, P) = IE_Content (B1, P)),
     Subprogram_Variant => (Increases => X);
   --  If B1 and B2 both contain a valid IE list at position X, the list in
   --  B2 is longer than the one in B1, and the memory for the list in B1 is
   --  equal in B2, then all reachable IEs' content fields in B1 are equal in
   --  B2 at the same position.

   procedure Lemma_Reachable_IE_Content_Shifted
     (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre                =>
       Valid_IE_List (B1, X1)
       and then X2 in B2'Range
       and then
         (if Is_Terminated (B1, X1)
          then B2'Last - X2 >= IE_List_Length (B1, X1) - 1
          else B2'Last - X2 = IE_List_Length (B1, X1) - 1)
       and then
         B1 (X1 .. X1 + (IE_List_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_List_Length (B1, X1) - 1)),
     Post               =>
       (for all P of Reachable_Set (B1, X1) =>
          IE_Content (B2, P + (X2 - X1)) = IE_Content (B1, P)),
     Subprogram_Variant => (Increases => X1);

   procedure Lemma_Last_IE_Header_Preserved
     (B1, B2 : Byte_Array; X1, X2 : Positive)
   with
     Pre  =>
       Valid_IE_List (B1, X1)
       and then X2 in B2'Range
       and then
         (if Is_Terminated (B1, X1)
          then B2'Last - X2 >= IE_List_Length (B1, X1) - 1
          else B2'Last - X2 = IE_List_Length (B1, X1) - 1)
       and then
         B1 (X1 .. X1 + (IE_List_Length (B1, X1) - 1))
         = B2 (X2 .. X2 + (IE_List_Length (B1, X1) - 1)),
     Post => Last_IE_Header (B2, X2) = Last_IE_Header (B1, X1);

   procedure Lemma_IE_List_Preserved (B1, B2 : Byte_Array; X : Positive)
   with
     Pre  =>
       Valid_IE_List (B1, X)
       and then B2'First <= B1'First
       and then
         (if Is_Terminated (B1, X)
          then B2'Last >= X + (IE_List_Length (B1, X) - 1)
          else B2'Last = X + (IE_List_Length (B1, X) - 1))
       and then
         B1 (X .. X + (IE_List_Length (B1, X) - 1))
         = B2 (X .. X + (IE_List_Length (B1, X) - 1)),
     Post =>
       Valid_IE_List (B2, X)
       and then IE_Count (B2, X) = IE_Count (B1, X)
       and then IE_List_Length (B2, X) = IE_List_Length (B1, X)
       and then Reachable_Set (B2, X) = Reachable_Set (B1, X)
       and then Model (B2, X) = Model (B1, X)
       and then
         (for all P of Reachable_Set (B1, X) =>
            IE_Header (B2, P) = IE_Header (B1, P)
            and then IE_Content (B2, P) = IE_Content (B1, P));

   ----------------------------------------
   -- Lemmas for Appending to an IE List --
   ----------------------------------------

   --  These lemmas are useful when appending an IE to an IE list.
   --
   --  Generally, they describe how the properties over IE lists change when
   --  a valid IE list is combined with another IE immediately following that
   --  list. In this case, combining the two results in another, valid IE list
   --  whose length and count is increased with the appended IE.
   --
   --  Appending an IE requires that the IE list preceding does not end in a
   --  termination IE.

   procedure Lemma_Valid_IE_List_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre  =>
       X in Buffer'Range
       and then Length <= (Buffer'Last - X)
       and then Valid_IE (Buffer, X + Length)
       and then Is_Last_IE (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Terminated (Buffer (Buffer'First .. X + (Length - 1)), X),
     Post => Valid_IE_List (Buffer, X);
   --  If Buffer contains a valid IE list at position X whose length is Length,
   --  the IE list does not end in a termination IE, and there is another valid
   --  IE immediately after the IE list, then appending the IE results in
   --  a valid IE list.

   procedure Lemma_IE_Count_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre  =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE (Buffer, X + Length)
       and then Is_Last_IE (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Terminated (Buffer (Buffer'First .. X + (Length - 1)), X),
     Post =>
       IE_Count (Buffer, X)
       = IE_Count (Buffer (Buffer'First .. X + (Length - 1)), X) + 1;
   --  If Buffer contains a valid IE list at position X whose length is Length,
   --  the IE list does not end in a termination IE, and there is another valid
   --  IE immediately after the IE list, then appending the IE results
   --  increases the length of the list by one IE.

   procedure Lemma_IE_List_Length_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre  =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE (Buffer, X + Length)
       and then Is_Last_IE (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Terminated (Buffer (Buffer'First .. X + (Length - 1)), X),
     Post =>
       IE_List_Length (Buffer, X)
       = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
         + IE_Length (Buffer, X + Length);
   --  If Buffer contains a valid IE list at position X whose length is Length,
   --  the IE list does not end in a termination IE, and there is another valid
   --  IE immediately after the IE list, then appending the IE causes the
   --  length of the IE list to increase by the length of the new IE.

   procedure Lemma_Reachable_Set_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre  =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE (Buffer, X + Length)
       and then Is_Last_IE (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Terminated (Buffer (Buffer'First .. X + (Length - 1)), X),
     Post =>
       Reachable (X, Buffer, X + Length)
       and then
         Reachable_Set (Buffer (Buffer'First .. X + (Length - 1)), X)
         <= Reachable_Set (Buffer, X)
       and then
         S.Included_Except
           (Reachable_Set (Buffer, X),
            Reachable_Set (Buffer (Buffer'First .. X + (Length - 1)), X),
            X + Length)
       and then
         S.Length (Reachable_Set (Buffer, X))
         = S.Length
             (Reachable_Set (Buffer (Buffer'First .. X + (Length - 1)), X))
           + 1;
   --  If Buffer contains a valid IE list at position X whose length is Length,
   --  the IE list does not end in a termination IE, and there is another valid
   --  IE immediately after the IE list, then appending the IE results in a
   --  list whose reachable set has the new IE added.

   procedure Lemma_Model_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre  =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE (Buffer, X + Length)
       and then Is_Last_IE (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Terminated (Buffer (Buffer'First .. X + (Length - 1)), X),
     Post =>
       (for all I in Model (Buffer, X) =>
          (if I = V.First
           then V.Get (Model (Buffer, X), I) = X + Length
           else
             V.Get (Model (Buffer, X), I)
             = V.Get
                 (Model (Buffer (Buffer'First .. X + (Length - 1)), X),
                  I - 1)))
       and then
         V.Length (Model (Buffer, X))
         = V.Length (Model (Buffer (Buffer'First .. X + (Length - 1)), X)) + 1;
   --  If Buffer contains a valid IE list at position X whose length is Length,
   --  the IE list does not end in a termination IE, and there is another valid
   --  IE immediately after the IE list, then appending the IE results in a
   --  new IE that becomes the last IE in the Model sequence.

   procedure Lemma_Last_IE_Position_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre  =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE (Buffer, X + Length)
       and then Is_Last_IE (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Terminated (Buffer (Buffer'First .. X + (Length - 1)), X),
     Post => Last_IE_Position (Buffer, X) = X + Length;
   --  If Buffer contains a valid IE list at position X whose length is Length,
   --  the IE list does not end in a termination IE, and there is another valid
   --  IE immediately after the IE list, then appending the IE results in a
   --  list where the position of the last IE is the position of the new IE.

   procedure Lemma_IE_List_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre  =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE (Buffer, X + Length)
       and then Is_Last_IE (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Terminated (Buffer (Buffer'First .. X + (Length - 1)), X),
     Post =>
       (declare
          Prefix : constant Byte_Array :=
            Buffer (Buffer'First .. X + (Length - 1));
        begin
          Valid_IE_List (Buffer, X)
          and then
            IE_List_Length (Buffer, X)
            = IE_List_Length (Prefix, X) + IE_Length (Buffer, X + Length)
          and then IE_Count (Buffer, X) = IE_Count (Prefix, X) + 1
          and then Reachable_Set (Prefix, X) <= Reachable_Set (Buffer, X)
          and then
            S.Included_Except
              (Reachable_Set (Buffer, X),
               Reachable_Set (Prefix, X),
               X + Length)
          and then
            (for all I in Model (Buffer, X) =>
               (if I = V.First
                then V.Get (Model (Buffer, X), I) = X + Length
                else
                  V.Get (Model (Buffer, X), I)
                  = V.Get (Model (Prefix, X), I - 1))));
   --  Lemma to combine the effect of appending an IE to the IE list validity,
   --  length, IE count, reachable set, and model sequence.

   ---------------------------------------
   -- Lemmas for Concatenating IE Lists --
   ---------------------------------------

   --  These lemmas are useful for taking properties that are proven for an
   --  IE list in a slice of a buffer, and extending them over other IEs
   --  located consecutively after the first IE list in the same buffer.

   procedure Lemma_Valid_IE_List_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre                =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Termination_IE
               (Last_IE_Header (Buffer (Buffer'First .. X + (Length - 1)), X)),
     Post               =>
       Valid_IE_List (Buffer, X) = Valid_IE_List (Buffer, X + Length),
     Subprogram_Variant => (Increases => X);
   --  If two IE lists are located contiguously in Buffer and the first IE list
   --  at position X is a valid IE list, then the concatenation of both IE
   --  lists results in a valid IE list if and only if the second IE list is
   --  also valid.

   procedure Lemma_IE_Count_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre                =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE_List (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Termination_IE
               (Last_IE_Header (Buffer (Buffer'First .. X + (Length - 1)), X)),
     Post               =>
       IE_Count (Buffer, X)
       = IE_Count (Buffer (Buffer'First .. X + (Length - 1)), X)
         + IE_Count (Buffer, X + Length),
     Subprogram_Variant => (Increases => X);
   --  If two IE valid lists are located contiguously in Buffer, then the
   --  number if IEs in the concatenation of both IE lists is equal to the
   --  sum of the IE count of both lists.

   procedure Lemma_IE_List_Length_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre                =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE_List (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Termination_IE
               (Last_IE_Header (Buffer (Buffer'First .. X + (Length - 1)), X)),
     Post               =>
       IE_List_Length (Buffer, X)
       = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
         + IE_List_Length (Buffer, X + Length),
     Subprogram_Variant => (Increases => X);
   --  If two IE valid lists are located contiguously in Buffer, then the
   --  length of the concatenated IE list is equal to the sum of the lengths of
   --  both lists.

   procedure Lemma_Reachable_Set_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre                =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE_List (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Termination_IE
               (Last_IE_Header (Buffer (Buffer'First .. X + (Length - 1)), X)),
     Post               =>
       Reachable_Set (Buffer (Buffer'First .. X + (Length - 1)), X)
       <= Reachable_Set (Buffer, X)
       and then Reachable_Set (Buffer, X + Length) <= Reachable_Set (Buffer, X)
       and then
         S.Included_In_Union
           (Reachable_Set (Buffer, X),
            Reachable_Set (Buffer (Buffer'First .. X + (Length - 1)), X),
            Reachable_Set (Buffer, X + Length)),
     Subprogram_Variant => (Increases => X);
   --  If two IE valid lists are located contiguously in Buffer, then the
   --  reachable set of the concatenated IE lists is equal to the union of
   --  reachable sets of both lists.

   procedure Lemma_Model_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   with
     Pre                =>
       X in Buffer'Range
       and then Length < (Buffer'Last - X) + 1
       and then Valid_IE_List (Buffer, X + Length)
       and then Valid_IE_List (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         Length = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
       and then
         not Is_Termination_IE
               (Last_IE_Header (Buffer (Buffer'First .. X + (Length - 1)), X)),
     Post               =>
       (declare
          M1 : constant V.Sequence :=
            Model (Buffer (Buffer'First .. X + (Length - 1)), X);
          M2 : constant V.Sequence := Model (Buffer, X + Length);
          M3 : constant V.Sequence := Model (Buffer, X);
        begin
          V.Length (M3) = V.Length (M1) + V.Length (M2)
          and then M2 < M3
          and then
            (for all I in M1 => V.Get (M1, I) = V.Get (M3, I + V.Last (M2)))),
     Subprogram_Variant => (Increases => X);
   --  If two IE valid lists are located contiguously in Buffer, then the
   --  model sequence of the concatenated IE list is equal to the concatenation
   --  of the two lists' model sequences.

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists.Lemmas;
