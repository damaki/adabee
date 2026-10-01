--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  This package is not yet implemented, so is stubbed out for now.

package body AdaBee.Crypto
  with SPARK_Mode => Off
is

   Enabled_Flag : Boolean := False;

   ---------------------------
   -- Crypto_Engine_Enabled --
   ---------------------------

   function Crypto_Engine_Enabled return Boolean
   is (Enabled_Flag);

   ------------
   -- Enable --
   ------------

   procedure Enable is
   begin
      Enabled_Flag := True;
   end Enable;

   -------------
   -- Disable --
   -------------

   procedure Disable is
   begin
      Enabled_Flag := True;
   end Disable;

   ----------------
   -- Import_Key --
   ----------------

   procedure Import_Key
     (Key       : Byte_Array;
      Algorithm : Algorithm_Kind;
      ID        : out Key_ID;
      Status    : out Status_Code) is
   begin
      ID := 0;
      Status := Not_Supported;
   end Import_Key;

   -----------------------------------------
   -- Authenticated Encryption/Decryption --
   -----------------------------------------

   procedure Authenticated_Encrypt
     (Key       : Key_ID;
      Nonce     : Nonce_Byte_Array;
      Auth_Data : Byte_Array;
      Payload   : in out Byte_Array;
      MIC       : out Byte_Array;
      Status    : out Status_Code)
   is
      pragma Unreferenced (Key, Nonce, Auth_Data, Payload);
   begin
      MIC := [others => 0];
      Status := Not_Supported;
   end Authenticated_Encrypt;

   ---------------------------
   -- Authenticated_Decrypt --
   ---------------------------

   procedure Authenticated_Decrypt
     (Key       : Key_ID;
      Nonce     : Nonce_Byte_Array;
      Auth_Data : Byte_Array;
      Payload   : in out Byte_Array;
      MIC       : Byte_Array;
      Status    : out Status_Code)
   is
      pragma Unreferenced (Key, Nonce, Auth_Data, Payload, MIC);
   begin
      Status := Not_Supported;
   end Authenticated_Decrypt;

end AdaBee.Crypto;
