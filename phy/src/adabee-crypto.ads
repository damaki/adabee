--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Interfaces;

--  This package provides an interface to the MAC layer to access cryptographic
--  services needed to encrypt and decrypt frames.

package AdaBee.Crypto
  with
    SPARK_Mode,
    Abstract_State    =>
      ((Crypto_Engine with
        External => (Async_Readers, Async_Writers, Effective_Writes)),
      --  Models the internal state of the crypto engine.

      Crypto_Engine_Power_State
      --  Models whether the crypto engine has been enabled
      ),
    Initializes       => (Crypto_Engine, Crypto_Engine_Power_State),
    Initial_Condition => not Crypto_Engine_Enabled
is

   type Status_Code is
     (Success,
      --  The operation was completed successfully

      Not_Supported,
      --  The requested operation is not supported by the implementation

      Hardware_Error,
      --  A hardware error occurred

      Invalid_Key,
      --  The specified key ID does not identify a valid key

      Invalid_ASN,
      --  The ASN is not valid/available, or an error occurred while accessing
      --  it.

      Invalid_Frame_Counter,
      --  The frame counter associated with the key has reached its maximum
      --  value.

      Authentication_Failure
      --  The decryption operation failed due to an incorrect MIC

     );

   type Algorithm_Kind is (AES_128_CCM_Star, AES_128_CCM, AES_256_CCM);

   type Key_ID is range 0 .. 2 ** 32 - 1 with Size => 32;
   --  Value used to identify distinct keys in the crypto engine.

   No_Key : constant Key_ID := 0;
   --  Represents an invalid key ID

   type Frame_Counter_Number is new Interfaces.Unsigned_32;

   type Absolute_Slot_Number is range 0 .. 2 ** 40 - 1 with Size => 40;

   subtype MIC_Length_Number is Natural
   with Static_Predicate => MIC_Length_Number in 4 | 8 | 16;
   --  The range of valid lengths (in bytes) for the Message Integrity Code
   --  (MIC).
   --
   --  IEEE 802.15.4-2024 specifies 32, 64, and 128-bit MICs.

   subtype Nonce_Byte_Array is Byte_Array (1 .. 13);
   --  Byte array to hold the AEAD nonce.
   --
   --  Ref. IEEE 802.15.4-2024 Section 9.3.2

   --------------------------
   -- API State Management --
   --------------------------

   function Crypto_Engine_Enabled return Boolean
   with Global => (Input => Crypto_Engine_Power_State);
   --  Returns True if the crypto engine is currently enabled, or False
   --  otherwise.

   procedure Enable
   with
     Global => (In_Out => Crypto_Engine, Output => Crypto_Engine_Power_State),
     Pre    => not Crypto_Engine_Enabled,
     Post   => Crypto_Engine_Enabled;
   --  Enable (power up) the crypto engine

   procedure Disable
   with
     Global => (In_Out => Crypto_Engine, Output => Crypto_Engine_Power_State),
     Pre    => Crypto_Engine_Enabled,
     Post   => not Crypto_Engine_Enabled;
   --  Disable (power down) the crypto engine

   --------------------
   -- Key Management --
   --------------------

   procedure Import_Key
     (Key       : Byte_Array;
      Algorithm : Algorithm_Kind;
      ID        : out Key_ID;
      Status    : out Status_Code)
   with
     Global  => (In_Out => Crypto_Engine),
     --!format off
     Depends =>
       (Crypto_Engine => (Crypto_Engine, Key, Algorithm),
        ID            => (Crypto_Engine, Key, Algorithm),
        Status        => (Crypto_Engine, Key, Algorithm)),
     --!format off
     Pre     =>
       (case Algorithm is
          when AES_128_CCM_Star => Key'Length = 16,
          when AES_128_CCM      => Key'Length = 16,
          when AES_256_CCM      => Key'Length = 32);
   --  Import a key into the crypto engine.
   --
   --  This stores the key internally in the crypto engine, where it can then
   --  be used for AEAD encryption and decryption operations.
   --
   --  The implementation must store the key in volatile memory.
   --
   --  The crypto engine does not need to be enabled before calling this
   --  procedure. Imported keys must persist while the crypto engine is
   --  disabled.
   --
   --  @param Key Buffer containing the key material.
   --
   --  @param Algorithm The AEAD algorithm used with the key.
   --
   --  @param ID A unique ID allocated to the imported key by the crypto
   --       engine. This ID will be used to refer to the key for
   --       encryption/decryption.
   --
   --  @param Status Set to `Success` if the key was successfully imported, or
   --       any other value to indicate an error.

   -----------------------------------------
   -- Authenticated Encryption/Decryption --
   -----------------------------------------

   --  These subprograms provide services for encrypting and decrypting data
   --  frames.

   procedure Authenticated_Encrypt
     (Key       : Key_ID;
      Nonce     : Nonce_Byte_Array;
      Auth_Data : Byte_Array;
      Payload   : in out Byte_Array;
      MIC       : out Byte_Array;
      Status    : out Status_Code)
   with
     Global  => (In_Out => Crypto_Engine, Proof_In => Crypto_Engine_Power_State),
     --!format off
     Depends =>
       (Payload       => (Crypto_Engine, Key, Nonce, Auth_Data, Payload),
        MIC           => (Crypto_Engine, Key, Nonce, Auth_Data, Payload),
        Status        => (Crypto_Engine, Key),
        Crypto_Engine => (Crypto_Engine, Key, Nonce, Auth_Data, Payload)),
     --!format on
     Pre     =>
       Crypto_Engine_Enabled

       and then MIC'Length in MIC_Length_Number

       --  A non-empty Auth_Data or Payload buffer (or both) must be given.
       and then (Auth_Data'Length > 0 or else Payload'Length > 0);
   --  Perform authenticated encryption on the given Payload.
   --
   --  @param Key Identifies the key to use for the authenticated encryption.
   --
   --  @param Nonce The 13-byte AEAD nonce to use.
   --
   --  @param Auth_Data An optional array of bytes for data that is
   --     authenticated, but not encrypted. If there is no authenticated-only
   --     data, then this buffer may be empty.
   --
   --  @param Payload On input, this contains the plaintext to be encrypted.
   --     On output, this contains the encrypted ciphertext.
   --     This array can be empty when there is no data to be encrypted
   --     (i.e., when operating in an authenticated-only mode).
   --
   --  @param MIC Buffer to where the Message Integrity Code (MIC) is written.
   --     This must be a 4, 8, or 16-byte buffer.
   --
   --  @param Status Set to `Success` if the AEAD operation was successfully
   --     completed, or any other value to indicate an error.

   procedure Authenticated_Decrypt
     (Key       : Key_ID;
      Nonce     : Nonce_Byte_Array;
      Auth_Data : Byte_Array;
      Payload   : in out Byte_Array;
      MIC       : Byte_Array;
      Status    : out Status_Code)
   with
     Global  =>
       (In_Out => Crypto_Engine, Proof_In => Crypto_Engine_Power_State),
     --!format off
     Depends =>
       (Payload       => (Crypto_Engine, Key, Nonce, Auth_Data, Payload, MIC),
        Status        => (Crypto_Engine, Key, Nonce, Auth_Data, Payload, MIC),
        Crypto_Engine => (Crypto_Engine, Key, Nonce, Auth_Data, Payload, MIC)),
     --!format on
     Pre     =>
       Crypto_Engine_Enabled

       and then MIC'Length in MIC_Length_Number

       --  A non-empty Auth_Data or Payload buffer (or both) must be given.
       and then (Auth_Data'Length > 0 or else Payload'Length > 0);
   --  Perform authenticated decryption on the given Payload.
   --
   --  @param Key Identifies the key to use for the authenticated encryption.
   --
   --  @param Nonce The 13-byte AEAD nonce to use.
   --
   --  @param Auth_Data An optional array of bytes for data that is
   --     authenticated, but not encrypted. If there is no authenticated-only
   --     data, then this buffer may be empty.
   --
   --  @param Payload On input, this contains the ciphertext to be decrypted.
   --     On output, this contains the decrypted plaintext if the operation
   --     was successful.
   --     This array can be empty when there is no data to be decrypted
   --     (i.e., when operating in an authenticated-only mode).
   --
   --  @param MIC Buffer containing the Message Integrity Code (MIC) is written.
   --     This must be a 4, 8, or 16-byte buffer.
   --
   --  @param Status Set to `Success` if the AEAD operation was successfully
   --     completed, or any other value to indicate an error.

end AdaBee.Crypto;
