--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body AdaBee.MAC.Frames.Info_Elements.Generic_Lists.Lemmas is

   --------------------------------
   -- Lemma_IE_Content_Preserved --
   --------------------------------

   procedure Lemma_IE_Content_Preserved
     (B1, B2 : Byte_Array; X1, X2 : Positive) is
   begin
      Lemma_IE_Header_Preserved (B1, B2, X1, X2);
   end Lemma_IE_Content_Preserved;

   ---------------------------
   -- Lemma_IE_Count_Append --
   ---------------------------

   procedure Lemma_IE_Count_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive) is
   begin
      Lemma_Valid_IE_List_Append (Buffer, X, Length);
      Lemma_IE_Count_Concat (Buffer, X, Length);
   end Lemma_IE_Count_Append;

   ---------------------------
   -- Lemma_IE_Count_Concat --
   ---------------------------

   procedure Lemma_IE_Count_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   is
      B1 : Byte_Array renames Buffer (X .. X + (Length - 1));
   begin
      Lemma_Valid_IE_List_Concat (Buffer, X, Length);

      if Is_Last_IE (B1, X) then
         pragma Assert (IE_Count (B1, X) = 1);
      else
         Lemma_IE_Count_Concat
           (Buffer,
            Next_IE_Position (Buffer, X),
            Length - IE_Length (Buffer, X));

         pragma
           Assert_And_Cut
             (IE_Count (Buffer, X)
              = IE_Count (Buffer (Buffer'First .. X + (Length - 1)), X)
                + IE_Count (Buffer, X + Length));
      end if;
   end Lemma_IE_Count_Concat;

   ------------------------------
   -- Lemma_IE_Count_Preserved --
   ------------------------------

   procedure Lemma_IE_Count_Preserved (B1, B2 : Byte_Array; X1, X2 : Positive)
   is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X1, X2);
      Lemma_IE_Header_Preserved (B1, B2, X1, X2);

      if not Is_Last_IE (B1, X1) then
         Lemma_Slice_Equal_Next (B1, B2, X1, X2);

         Lemma_IE_Count_Preserved
           (B1 => B1,
            B2 => B2,
            X1 => X1 + IE_Length (B1, X1),
            X2 => X2 + IE_Length (B1, X1));
      end if;
   end Lemma_IE_Count_Preserved;

   -------------------------------
   -- Lemma_IE_Header_Preserved --
   -------------------------------

   procedure Lemma_IE_Header_Preserved (B1, B2 : Byte_Array; X1, X2 : Positive)
   is
   begin
      null;
   end Lemma_IE_Header_Preserved;

   -------------------------------
   -- Lemma_IE_Length_Preserved --
   -------------------------------

   procedure Lemma_IE_Length_Preserved (B1, B2 : Byte_Array; X1, X2 : Positive)
   is
   begin
      Lemma_IE_Header_Preserved (B1, B2, X1, X2);
   end Lemma_IE_Length_Preserved;

   --------------------------
   -- Lemma_IE_List_Append --
   --------------------------

   procedure Lemma_IE_List_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive) is
   begin
      Lemma_Valid_IE_List_Append (Buffer, X, Length);
      Lemma_IE_List_Length_Append (Buffer, X, Length);
      Lemma_IE_Count_Append (Buffer, X, Length);
      Lemma_Reachable_Set_Append (Buffer, X, Length);
      Lemma_Model_Append (Buffer, X, Length);
   end Lemma_IE_List_Append;

   ---------------------------------
   -- Lemma_IE_List_Length_Append --
   ---------------------------------

   procedure Lemma_IE_List_Length_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive) is
   begin
      Lemma_Valid_IE_List_Append (Buffer, X, Length);
      Lemma_IE_List_Length_Concat (Buffer, X, Length);
   end Lemma_IE_List_Length_Append;

   ---------------------------------
   -- Lemma_IE_List_Length_Concat --
   ---------------------------------

   procedure Lemma_IE_List_Length_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   is
      B1 : Byte_Array renames Buffer (X .. X + (Length - 1));
   begin
      Lemma_Valid_IE_List_Concat (Buffer, X, Length);

      if Is_Last_IE (B1, X) then
         pragma Assert (IE_List_Length (B1, X) = IE_Length (B1, X));

         pragma
           Assert_And_Cut
             (IE_List_Length (Buffer, X)
              = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
                + IE_List_Length (Buffer, X + Length));
      else
         Lemma_IE_List_Length_Concat
           (Buffer, Next_IE_Position (B1, X), Length - IE_Length (B1, X));

         pragma
           Assert_And_Cut
             (IE_List_Length (Buffer, X)
              = IE_List_Length (Buffer (Buffer'First .. X + (Length - 1)), X)
                + IE_List_Length (Buffer, X + Length));
      end if;
   end Lemma_IE_List_Length_Concat;

   ---------------------------------------------
   -- Lemma_IE_List_Length_Implies_Terminated --
   ---------------------------------------------

   procedure Lemma_IE_List_Length_Implies_Terminated
     (Buffer : Byte_Array; X : Positive) is
   begin
      if Is_Last_IE (Buffer, X) then
         pragma
           Assert
             (if IE_Length (Buffer, X) - 1 < Buffer'Last - X
              then Is_Termination_IE (IE_Header (Buffer, X)));
      else
         Lemma_IE_List_Length_Implies_Terminated
           (Buffer, Next_IE_Position (Buffer, X));
      end if;
   end Lemma_IE_List_Length_Implies_Terminated;

   -------------------------------
   -- Lemma_IE_List_Length_Next --
   -------------------------------

   procedure Lemma_IE_List_Length_Next (Buffer : Byte_Array; X : Positive) is
   begin
      null;
   end Lemma_IE_List_Length_Next;

   ------------------------------------
   -- Lemma_IE_List_Length_Preserved --
   ------------------------------------

   procedure Lemma_IE_List_Length_Preserved
     (B1, B2 : Byte_Array; X1, X2 : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X1, X2);
      Lemma_IE_Header_Preserved (B1, B2, X1, X2);

      if not Is_Last_IE (B1, X1) then
         Lemma_Slice_Equal_Next (B1, B2, X1, X2);

         Lemma_IE_List_Length_Preserved
           (B1 => B1,
            B2 => B2,
            X1 => X1 + IE_Length (B1, X1),
            X2 => X2 + IE_Length (B1, X1));
      end if;
   end Lemma_IE_List_Length_Preserved;

   -----------------------------
   -- Lemma_IE_List_Preserved --
   -----------------------------

   procedure Lemma_IE_List_Preserved (B1, B2 : Byte_Array; X : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X, X);
      Lemma_IE_Count_Preserved (B1, B2, X, X);
      Lemma_IE_List_Length_Preserved (B1, B2, X, X);
      Lemma_Reachable_Set_Preserved (B1, B2, X);
      Lemma_Model_Preserved (B1, B2, X);
      Lemma_Reachable_IE_Headers_Preserved (B1, B2, X);
      Lemma_Reachable_IE_Content_Preserved (B1, B2, X);
   end Lemma_IE_List_Preserved;

   ------------------------------------
   -- Lemma_Last_IE_Header_Preserved --
   ------------------------------------

   procedure Lemma_Last_IE_Header_Preserved
     (B1, B2 : Byte_Array; X1, X2 : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X1, X2);
      Lemma_Model_Shifted (B1, B2, X1, X2);
      Lemma_IE_List_Length_Anti_Isometric (B1, X1);
      Lemma_IE_Header_Preserved
        (B1, B2, Last_IE_Position (B1, X1), Last_IE_Position (B2, X2));
   end Lemma_Last_IE_Header_Preserved;

   -----------------------------------
   -- Lemma_Last_IE_Position_Append --
   -----------------------------------

   procedure Lemma_Last_IE_Position_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive) is
   begin
      Lemma_Valid_IE_List_Append (Buffer, X, Length);
      Lemma_Model_Append (Buffer, X, Length);
   end Lemma_Last_IE_Position_Append;

   ---------------------------------
   -- Lemma_Last_IE_Position_Next --
   ---------------------------------

   procedure Lemma_Last_IE_Position_Next (Buffer : Byte_Array; X : Positive) is
   begin
      Lemma_Model_Next (Buffer, X);
   end Lemma_Last_IE_Position_Next;

   ------------------------
   -- Lemma_Model_Append --
   ------------------------

   procedure Lemma_Model_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive) is
   begin
      Lemma_Valid_IE_List_Append (Buffer, X, Length);
      Lemma_Model_Concat (Buffer, X, Length);
      Lemma_IE_Count_Append (Buffer, X, Length);
   end Lemma_Model_Append;

   ------------------------
   -- Lemma_Model_Concat --
   ------------------------

   procedure Lemma_Model_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   is
      B1 : Byte_Array renames Buffer (Buffer'First .. X + (Length - 1));
   begin
      Lemma_Valid_IE_List_Concat (Buffer, X, Length);
      Lemma_Reachable_Set_Concat (Buffer, X, Length);
      Lemma_IE_Count_Concat (Buffer, X, Length);
      Lemma_IE_List_Length_Anti_Isometric (Buffer, X + Length);
      Lemma_Model_Monotonic (Buffer, X);

      if Is_Last_IE (B1, X) then
         pragma Assert (Model (B1, X) = [X]);

         pragma
           Assert_And_Cut
             (declare
                M1 : constant V.Sequence :=
                  Model (Buffer (Buffer'First .. X + (Length - 1)), X);
                M2 : constant V.Sequence := Model (Buffer, X + Length);
                M3 : constant V.Sequence := Model (Buffer, X);
              begin
                V.Length (M3) = V.Length (M1) + V.Length (M2)
                and then M2 < M3
                and then
                  (for all I in M1 =>
                     V.Get (M1, I) = V.Get (M3, I + V.Last (M2))));
      else
         pragma Assert (IE_Length (Buffer, X) = IE_Length (B1, X));

         pragma
           Assert
             (IE_List_Length (B1, X + IE_Length (Buffer, X))
              = IE_List_Length (B1, X) - IE_Length (Buffer, X));

         Lemma_Model_Next (Buffer, X);

         Lemma_Model_Concat
           (Buffer,
            Next_IE_Position (Buffer, X),
            Length - IE_Length (Buffer, X));

         Lemma_Model_Next (B1, X);

         pragma
           Assert_And_Cut
             (declare
                M1 : constant V.Sequence :=
                  Model (Buffer (Buffer'First .. X + (Length - 1)), X);
                M2 : constant V.Sequence := Model (Buffer, X + Length);
                M3 : constant V.Sequence := Model (Buffer, X);
              begin
                V.Length (M3) = V.Length (M1) + V.Length (M2)
                and then M2 < M3
                and then
                  (for all I in M1 =>
                     V.Get (M1, I) = V.Get (M3, I + V.Last (M2))));
      end if;

   end Lemma_Model_Concat;

   ---------------------------
   -- Lemma_Model_Monotonic --
   ---------------------------

   procedure Lemma_Model_Monotonic (Buffer : Byte_Array; X : Positive) is
   begin
      if not Is_Last_IE (Buffer, X) then
         Lemma_Model_Monotonic (Buffer, Next_IE_Position (Buffer, X));
      end if;
   end Lemma_Model_Monotonic;

   ----------------------
   -- Lemma_Model_Next --
   ----------------------

   procedure Lemma_Model_Next (Buffer : Byte_Array; X : Positive) is
   begin
      null;
   end Lemma_Model_Next;

   ---------------------------
   -- Lemma_Model_Preserved --
   ---------------------------

   procedure Lemma_Model_Preserved (B1, B2 : Byte_Array; X : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X, X);
      Lemma_IE_Header_Preserved (B1, B2, X, X);

      if not Is_Last_IE (B1, X) then
         Lemma_Model_Preserved (B1, B2, Next_IE_Position (B1, X));
         Lemma_Model_Next (B1, X);
         Lemma_Model_Next (B2, X);
      end if;
   end Lemma_Model_Preserved;

   -------------------------
   -- Lemma_Model_Shifted --
   -------------------------

   procedure Lemma_Model_Shifted (B1, B2 : Byte_Array; X1, X2 : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X1, X2);
      Lemma_IE_List_Length_Preserved (B1, B2, X1, X2);
      Lemma_IE_Header_Preserved (B1, B2, X1, X2);

      pragma Assert (IE_Length (B2, X2) = IE_Length (B1, X1));

      if not Is_Last_IE (B1, X1) then
         Lemma_Slice_Equal_Next (B1, B2, X1, X2);

         Lemma_Model_Shifted
           (B1 => B1,
            B2 => B2,
            X1 => Next_IE_Position (B1, X1),
            X2 => Next_IE_Position (B2, X2));

         Lemma_Model_Next (B1, X1);
         Lemma_Model_Next (B2, X2);
      end if;
   end Lemma_Model_Shifted;

   -----------------------------------------
   -- Lemma_IE_List_Length_Anti_Isometric --
   -----------------------------------------

   procedure Lemma_IE_List_Length_Anti_Isometric
     (Buffer : Byte_Array; X : Positive) is
   begin
      if not Is_Last_IE (Buffer, X) then
         Lemma_IE_List_Length_Anti_Isometric
           (Buffer, Next_IE_Position (Buffer, X));
      end if;
   end Lemma_IE_List_Length_Anti_Isometric;

   ------------------------------------------
   -- Lemma_Reachable_IE_Content_Preserved --
   ------------------------------------------

   procedure Lemma_Reachable_IE_Content_Preserved
     (B1, B2 : Byte_Array; X : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X, X);
      Lemma_Reachable_Set_Preserved (B1, B2, X);
      Lemma_IE_Content_Preserved (B1, B2, X, X);

      if Is_Last_IE (B1, X) then
         pragma
           Assert_And_Cut
             (for all P of Reachable_Set (B1, X) =>
                IE_Content (B1, P) = IE_Content (B2, P));

      else
         Lemma_Reachable_IE_Content_Preserved
           (B1, B2, Next_IE_Position (B1, X));

         pragma
           Assert_And_Cut
             (IE_Content (B1, X) = IE_Content (B2, X)
              and then
                Reachable_Set (B1, Next_IE_Position (B1, X))
                <= Reachable_Set (B1, X)
              and then
                S.Included_Except
                  (Reachable_Set (B1, X),
                   Reachable_Set (B1, Next_IE_Position (B1, X)),
                   X)
              and then
                (for all P of Reachable_Set (B1, Next_IE_Position (B1, X)) =>
                   IE_Content (B1, P) = IE_Content (B2, P)));

         pragma
           Assert_And_Cut
             (for all P of Reachable_Set (B1, X) =>
                IE_Content (B1, P) = IE_Content (B2, P));
      end if;
   end Lemma_Reachable_IE_Content_Preserved;

   -------------------------------------------------
   -- Lemma_Reachable_IE_Content_Preserved_Prefix --
   -------------------------------------------------

   procedure Lemma_Reachable_IE_Content_Preserved_Prefix
     (B1, B2 : Byte_Array; X : Positive) is
   begin
      Lemma_IE_Header_Preserved (B1, B2, X, X);
      Lemma_IE_Content_Preserved (B1, B2, X, X);
      Lemma_IE_Length_Preserved (B1, B2, X, X);

      if Is_Last_IE (B1, X) then
         pragma
           Assert_And_Cut
             (for all P of Reachable_Set (B1, X) =>
                IE_Content (B1, P) = IE_Content (B2, P));

      else
         Lemma_Reachable_IE_Content_Preserved_Prefix
           (B1, B2, Next_IE_Position (B1, X));

         Lemma_Reachable_Next (B1, X);

         pragma
           Assert_And_Cut
             (for all P of Reachable_Set (B1, X) =>
                IE_Content (B1, P) = IE_Content (B2, P));
      end if;
   end Lemma_Reachable_IE_Content_Preserved_Prefix;

   ----------------------------------------
   -- Lemma_Reachable_IE_Content_Shifted --
   ----------------------------------------

   procedure Lemma_Reachable_IE_Content_Shifted
     (B1, B2 : Byte_Array; X1, X2 : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X1, X2);
      Lemma_IE_List_Length_Preserved (B1, B2, X1, X2);
      Lemma_Reachable_Set_Shifted (B1, B2, X1, X2);

      if not Is_Last_IE (B1, X1) then
         Lemma_Slice_Equal_Next (B1, B2, X1, X2);

         Lemma_Reachable_IE_Content_Shifted
           (B1 => B1,
            B2 => B2,
            X1 => X1 + IE_Length (B1, X1),
            X2 => X2 + IE_Length (B1, X1));

         Lemma_Reachable_Next (B1, X1);
         Lemma_Reachable_Next (B2, X2);
      end if;

      Lemma_Reachable_Range (B1, X1);
      Lemma_Reachable_Range (B2, X2);
      Lemma_IE_Content_Preserved (B1, B2, X1, X2);
   end Lemma_Reachable_IE_Content_Shifted;

   ------------------------------------------
   -- Lemma_Reachable_IE_Headers_Preserved --
   ------------------------------------------

   procedure Lemma_Reachable_IE_Headers_Preserved
     (B1, B2 : Byte_Array; X : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X, X);
      Lemma_Reachable_Set_Preserved (B1, B2, X);
      Lemma_IE_Header_Preserved (B1, B2, X, X);

      if not Is_Last_IE (B1, X) then
         Lemma_Reachable_IE_Headers_Preserved
           (B1, B2, Next_IE_Position (B1, X));
      end if;
   end Lemma_Reachable_IE_Headers_Preserved;

   -------------------------------------------------
   -- Lemma_Reachable_IE_Headers_Preserved_Prefix --
   -------------------------------------------------

   procedure Lemma_Reachable_IE_Headers_Preserved_Prefix
     (B1, B2 : Byte_Array; X : Positive) is
   begin
      Lemma_IE_Header_Preserved (B1, B2, X, X);
      Lemma_IE_Length_Preserved (B1, B2, X, X);

      if Is_Last_IE (B1, X) then
         pragma
           Assert_And_Cut
             (for all P of Reachable_Set (B1, X) =>
                IE_Header (B1, P) = IE_Header (B2, P));

      else
         Lemma_Reachable_IE_Headers_Preserved_Prefix
           (B1, B2, Next_IE_Position (B1, X));

         Lemma_Reachable_Next (B1, X);

         pragma
           Assert_And_Cut
             (for all P of Reachable_Set (B1, X) =>
                IE_Header (B1, P) = IE_Header (B2, P));
      end if;
   end Lemma_Reachable_IE_Headers_Preserved_Prefix;

   ----------------------------------------
   -- Lemma_Reachable_IE_Headers_Shifted --
   ----------------------------------------

   procedure Lemma_Reachable_IE_Headers_Shifted
     (B1, B2 : Byte_Array; X1, X2 : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X1, X2);
      Lemma_IE_List_Length_Preserved (B1, B2, X1, X2);
      Lemma_IE_Header_Preserved (B1, B2, X1, X2);

      if not Is_Last_IE (B1, X1) then
         Lemma_Reachable_Set_Shifted (B1, B2, X1, X2);
         Lemma_Slice_Equal_Next (B1, B2, X1, X2);

         Lemma_Reachable_IE_Headers_Shifted
           (B1 => B1,
            B2 => B2,
            X1 => X1 + IE_Length (B1, X1),
            X2 => X2 + IE_Length (B1, X1));

         Lemma_Reachable_Next (B1, X1);
         Lemma_Reachable_Next (B2, X2);
      end if;

      Lemma_Reachable_Range (B1, X1);
      Lemma_Reachable_Range (B2, X2);
   end Lemma_Reachable_IE_Headers_Shifted;

   --------------------------
   -- Lemma_Reachable_Next --
   --------------------------

   procedure Lemma_Reachable_Next (Buffer : Byte_Array; X : Positive) is
   begin
      null;
   end Lemma_Reachable_Next;

   -----------------------------
   -- Lemma_Reachable_Ordered --
   -----------------------------

   procedure Lemma_Reachable_Ordered (Buffer : Byte_Array; X : Positive) is
   begin
      if not Is_Last_IE (Buffer, X) then
         Lemma_Reachable_Ordered (Buffer, Next_IE_Position (Buffer, X));
      end if;
   end Lemma_Reachable_Ordered;

   --------------------------------
   -- Lemma_Reachable_Set_Append --
   --------------------------------

   procedure Lemma_Reachable_Set_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive) is
   begin
      pragma
        Assert
          (S.Is_Singleton (Reachable_Set (Buffer, X + Length), X + Length));

      Lemma_Valid_IE_List_Append (Buffer, X, Length);
      Lemma_Reachable_Set_Concat (Buffer, X, Length);
      Lemma_IE_Count_Append (Buffer, X, Length);
   end Lemma_Reachable_Set_Append;

   --------------------------------
   -- Lemma_Reachable_Set_Concat --
   --------------------------------

   procedure Lemma_Reachable_Set_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   is
      B1 : Byte_Array renames Buffer (Buffer'First .. X + (Length - 1));
   begin
      Lemma_Valid_IE_List_Concat (Buffer, X, Length);
      Lemma_IE_List_Length_Anti_Isometric (B1, X);
      Lemma_IE_List_Length_Anti_Isometric (Buffer, X + Length);

      if Is_Last_IE (B1, X) then
         pragma
           Assert_And_Cut
             (Reachable_Set (B1, X) <= Reachable_Set (Buffer, X)
              and then
                Reachable_Set (Buffer, X + Length) <= Reachable_Set (Buffer, X)
              and then
                S.Included_In_Union
                  (Reachable_Set (Buffer, X),
                   Reachable_Set (B1, X),
                   Reachable_Set (Buffer, X + Length)));
      else
         Lemma_Reachable_Set_Concat
           (Buffer, Next_IE_Position (B1, X), Length - IE_Length (B1, X));

         Lemma_Reachable_Next (B1, X);

         pragma
           Assert_And_Cut
             (Reachable_Set (B1, X) <= Reachable_Set (Buffer, X)
              and then
                Reachable_Set (Buffer, X + Length) <= Reachable_Set (Buffer, X)
              and then
                S.Included_In_Union
                  (Reachable_Set (Buffer, X),
                   Reachable_Set (B1, X),
                   Reachable_Set (Buffer, X + Length)));
      end if;

   end Lemma_Reachable_Set_Concat;

   -----------------------------------
   -- Lemma_Reachable_Set_Preserved --
   -----------------------------------

   procedure Lemma_Reachable_Set_Preserved (B1, B2 : Byte_Array; X : Positive)
   is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X, X);
      Lemma_IE_Header_Preserved (B1, B2, X, X);

      if not Is_Last_IE (B1, X) then
         Lemma_Reachable_Set_Preserved (B1, B2, Next_IE_Position (B1, X));
         Lemma_Reachable_Next (B1, X);
      end if;
   end Lemma_Reachable_Set_Preserved;

   ---------------------------------
   -- Lemma_Reachable_Set_Shifted --
   ---------------------------------

   procedure Lemma_Reachable_Set_Shifted
     (B1, B2 : Byte_Array; X1, X2 : Positive) is
   begin
      Lemma_Valid_IE_List_Preserved (B1, B2, X1, X2);
      Lemma_IE_Header_Preserved (B1, B2, X1, X2);

      pragma Assert (Is_Last_IE (B1, X1) = Is_Last_IE (B2, X2));

      if not Is_Last_IE (B1, X1) then
         Lemma_Last_IE_Position_Next (B1, X1);
         Lemma_Slice_Equal_Next (B1, B2, X1, X2);

         Lemma_Reachable_Set_Shifted
           (B1 => B1,
            B2 => B2,
            X1 => X1 + IE_Length (B1, X1),
            X2 => X2 + IE_Length (B1, X1));

         pragma
           Assert
             (Next_IE_Position (B1, X1) - Next_IE_Position (B2, X2) = X1 - X2);

         Lemma_Reachable_Range (B1, X1);
         Lemma_Reachable_Range (B2, X2);
         Lemma_Reachable_Next (B1, X1);
         Lemma_Reachable_Next (B2, X2);
         Lemma_IE_List_Length_Preserved (B1, B2, X1, X2);
      end if;
   end Lemma_Reachable_Set_Shifted;

   ---------------------------
   -- Lemma_Reachable_Range --
   ---------------------------

   procedure Lemma_Reachable_Range (Buffer : Byte_Array; X : Positive) is
   begin
      if not Is_Last_IE (Buffer, X) then
         Lemma_Reachable_Range (Buffer, Next_IE_Position (Buffer, X));
      end if;
   end Lemma_Reachable_Range;

   --------------------------------
   -- Lemma_Reachable_Transitive --
   --------------------------------

   procedure Lemma_Reachable_Transitive
     (Buffer : Byte_Array; X, Y, Z : Positive) is
   begin
      if X /= Y and then Reachable (X, Buffer, Y) then
         Lemma_Reachable_Transitive
           (Buffer, Next_IE_Position (Buffer, X), Y, Z);
      end if;
   end Lemma_Reachable_Transitive;

   ----------------------------
   -- Lemma_Slice_Equal_Next --
   ----------------------------

   procedure Lemma_Slice_Equal_Next (B1, B2 : Byte_Array; X1, X2 : Positive) is
      pragma Unreferenced (B2, X2);
   begin
      if not Is_Last_IE (B1, X1) then
         pragma
           Assert
             (IE_List_Length (B1, Next_IE_Position (B1, X1))
              = IE_List_Length (B1, X1) - IE_Length (B1, X1));

         pragma Assert (IE_Length (B1, X1) < IE_List_Length (B1, X1));
      end if;
   end Lemma_Slice_Equal_Next;

   ---------------------------------
   -- Lemma_Termination_IE_Unique --
   ---------------------------------

   procedure Lemma_Termination_IE_Unique (Buffer : Byte_Array; X : Positive) is
   begin
      if not Is_Last_IE (Buffer, X) then
         Lemma_Reachable_Next (Buffer, X);
         Lemma_Termination_IE_Unique (Buffer, Next_IE_Position (Buffer, X));
      end if;
   end Lemma_Termination_IE_Unique;

   --------------------------------
   -- Lemma_Valid_IE_List_Append --
   --------------------------------

   procedure Lemma_Valid_IE_List_Append
     (Buffer : Byte_Array; X : Positive; Length : Positive) is
   begin
      Lemma_Valid_IE_List_Concat (Buffer, X, Length);
   end Lemma_Valid_IE_List_Append;

   --------------------------------
   -- Lemma_Valid_IE_List_Concat --
   --------------------------------

   procedure Lemma_Valid_IE_List_Concat
     (Buffer : Byte_Array; X : Positive; Length : Positive)
   is
      B1 : Byte_Array renames Buffer (X .. X + (Length - 1));
   begin
      if Is_Last_IE (B1, X) then
         pragma Assert (Valid_IE (B1, X));
         pragma Assert (Valid_IE_List (B1, X));

         pragma
           Assert_And_Cut
             (Valid_IE_List (Buffer, X) = Valid_IE_List (Buffer, X + Length));
      else
         Lemma_Valid_IE_List_Concat
           (Buffer, Next_IE_Position (B1, X), Length - IE_Length (B1, X));

         pragma
           Assert_And_Cut
             (Valid_IE_List (Buffer, X) = Valid_IE_List (Buffer, X + Length));
      end if;
   end Lemma_Valid_IE_List_Concat;

   ------------------------------
   -- Lemma_Valid_IE_List_Last --
   ------------------------------

   procedure Lemma_Valid_IE_List_Last (Buffer : Byte_Array; X : Positive) is
   begin
      null;
   end Lemma_Valid_IE_List_Last;

   -----------------------------------
   -- Lemma_Valid_IE_List_Preserved --
   -----------------------------------

   procedure Lemma_Valid_IE_List_Preserved
     (B1, B2 : Byte_Array; X1, X2 : Positive) is
   begin
      Lemma_IE_Header_Preserved (B1, B2, X1, X2);
      pragma Assert (Valid_IE (B2, X2));

      if not Is_Last_IE (B1, X1) then
         pragma
           Assert
             (IE_List_Length (B1, Next_IE_Position (B1, X1))
              = IE_List_Length (B1, X1) - IE_Length (B1, X1));

         pragma Assert (Valid_IE_List (B1, Next_IE_Position (B1, X1)));

         Lemma_Valid_IE_List_Preserved
           (B1 => B1,
            B2 => B2,
            X1 => Next_IE_Position (B1, X1),
            X2 => X2 + IE_Length (B1, X1));
      end if;
   end Lemma_Valid_IE_List_Preserved;

end AdaBee.MAC.Frames.Info_Elements.Generic_Lists.Lemmas;
