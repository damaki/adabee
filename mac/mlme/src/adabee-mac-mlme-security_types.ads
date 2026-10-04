--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.MAC.Frames.Headers;
with AdaBee.MAC.Frames.Info_Elements.Headers;
with AdaBee.MAC.Frames.Info_Elements.Nested;
with AdaBee.MAC.Frames.Info_Elements.Payloads;
with AdaBee.Crypto;

with Adabee_Mlme_Config;

--  This package defines the data types for the security-related MAC PIB
--  attributes defined in Section 9.5 of IEEE 802.15.4-2024.
--
--  The memory usage of these PIB attributes, as described by the standard, can
--  be quite large. To reduce the memory usage of these types, the maximum
--  sizes of lists are limited using compile-time constants. These constants
--  are configurable via Alire crate configuration variables to allow them to
--  be tuned to application-specific requirements.
--
--  Packed records and arrays are also used to further reduce memory
--  consumption.

package AdaBee.MAC.MLME.Security_Types
  with SPARK_Mode
is

   use all type AdaBee.MAC.Frames.Headers.Address_Mode_Field;
   use all type AdaBee.MAC.Frames.Headers.Frame_Type_Field;
   use all type AdaBee.Crypto.Algorithm_Kind;

   type Frame_Counter_Number is range 0 .. 2 ** 32 - 1 with Size => 32;

   -----------------------------
   -- secKeyIeUsageDescriptor --
   -----------------------------

   --  Ref. IEEE 802.15.4-2024 Table 9-14

   type Key_IE_Type_Kind is (Header, Payload, Nested_Short, Nested_Long)
   with Size => 2;

   type Key_IE_Usage_Descriptor (Key_IE_Type : Key_IE_Type_Kind := Header) is
   record
      case Key_IE_Type is
         when Header =>
            Header_Key_IE_ID :
              AdaBee.MAC.Frames.Info_Elements.Headers.Element_ID_Field := 0;

         when Payload =>
            Payload_Key_IE_ID :
              AdaBee.MAC.Frames.Info_Elements.Payloads.Group_ID_Field := 0;

         when Nested_Short =>
            Nested_Short_Key_IE_ID :
              AdaBee.MAC.Frames.Info_Elements.Nested.Short_Sub_ID_Field := 0;

         when Nested_Long =>
            Nested_Long_Key_IE_ID :
              AdaBee.MAC.Frames.Info_Elements.Nested.Long_Sub_ID_Field := 0;
      end case;
   end record
   with Size => 16;
   --  secKeyIeUsageDescriptor

   ---------------------------
   -- secKeyUsageDescriptor --
   ---------------------------

   --  Ref. IEEE 802.15.4-2024 Table 9-13

   --  Arrays of secIeUsageDescriptor

   type Key_IE_Usage_Descriptor_Count is
     range 0 .. Adabee_Mlme_Config.Sec_Max_IE_Usage_Descriptors
   with Size => 6;

   type Key_IE_Usage_Descriptor_Array is
     array (Key_IE_Usage_Descriptor_Count range <>) of Key_IE_Usage_Descriptor
   with Pack;

   Key_IE_Usage_Descriptor_List_Max_Bit_Size : constant :=
     Adabee_Mlme_Config.Sec_Max_IE_Usage_Descriptors * 16;

   --  To reduce memory usage, multiple MAC commands (secKeyusageCommandId)
   --  are packed into the same secKeyUsageDescriptor. This allows a single
   --  secKeyUsageDescriptor to be used in cases where multiple MAC commands
   --  share the same secKeyIeUsageDescriptorList. Likewise for the frame type.
   --
   --  Supporting all 256 possible MAC command values as a packed Boolean array
   --  would require 32 bytes, but this is further reduced to 6 bytes by
   --  limiting the range of allowed values for the MAC command to the values
   --  defined in Table 7-11 of IEEE 802.15.4-2024, where commands above 0x2a
   --  are reserved.

   type MAC_Command_Boolean_Array is
     array (Interfaces.Unsigned_8 range 16#01# .. 16#2A#) of Boolean
   with Pack, Size => 42;

   type Frame_Type_Boolean_Array is
     array (AdaBee.MAC.Frames.Headers.Frame_Type_Field) of Boolean
   with Pack;

   type Key_Usage_Descriptor is record
      Key_IE_Usage_Descriptor_List :
        Key_IE_Usage_Descriptor_Array
          (1 .. Key_IE_Usage_Descriptor_Count'Last) := [others => <>];

      Key_IE_Usage_Descriptor_List_Length : Key_IE_Usage_Descriptor_Count := 0;

      Key_Usage_Frame_Types : Frame_Type_Boolean_Array := [others => False];
      Key_Usage_Command_IDs : MAC_Command_Boolean_Array := [others => False];
   end record
   with Size => 56 + (Adabee_Mlme_Config.Sec_Max_IE_Usage_Descriptors * 16);
   --  secKeyUsageDescriptor

   for Key_Usage_Descriptor use
     record
       Key_IE_Usage_Descriptor_List_Length at 0 range 0 .. 5;
       Key_Usage_Command_IDs               at 0 range 6 .. 47;

       Key_IE_Usage_Descriptor_List at 0
         range 48 .. 48 + Key_IE_Usage_Descriptor_List_Max_Bit_Size - 1;

       Key_Usage_Frame_Types at 0
         range 48 + Key_IE_Usage_Descriptor_List_Max_Bit_Size
               .. 48 + Key_IE_Usage_Descriptor_List_Max_Bit_Size + 7;
     end record;

   ----------------------------------------
   -- secKeyDeviceFrameCounterDescriptor --
   ----------------------------------------

   --  Ref. IEEE 802.15.4-2024 Table 9-12

   No_Address : constant AdaBee.MAC.Frames.Headers.Extended_Address_Field := 0;

   type Key_Device_Frame_Counter_Descriptor is record
      Device_Ext_Address : AdaBee.MAC.Frames.Headers.Extended_Address_Field :=
        No_Address;

      Device_Frame_Counter : Frame_Counter_Number := 0;
   end record
   with Size => 96;
   --  secKeyDeviceFrameCounterDescriptor

   type Key_Device_Frame_Counter_Descriptor_Count is
     range 0
           .. Adabee_Mlme_Config.Sec_Max_Key_Device_Frame_Counter_Descriptors;

   type Key_Device_Frame_Counter_Descriptor_Array is
     array (Key_Device_Frame_Counter_Descriptor_Count range <>)
     of Key_Device_Frame_Counter_Descriptor
   with Pack;

   ----------------------
   -- secKeyDescriptor --
   ----------------------

   --  Ref. IEEE 802.15.4-2024 Table 9-11

   type Key_Holder
     (AEAD_Algorithm    : AdaBee.Crypto.Algorithm_Kind := AES_128_CCM_Star;
      Contains_Key_Data : Boolean := False)
   is record
      case Contains_Key_Data is
         when True =>
            case AEAD_Algorithm is
               when AES_128_CCM_Star | AES_128_CCM =>
                  Key_128 : aliased Byte_Array (1 .. 16) := [others => 0];

               when AES_256_CCM =>
                  Key_256 : aliased Byte_Array (1 .. 32) := [others => 0];
            end case;

         when False =>
            Key_ID : AdaBee.Crypto.Key_ID := AdaBee.Crypto.No_Key;
      end case;
   end record;
   --  Encapsulates an encryption key.
   --
   --  This record holds either the raw key material, or an ID that refers to
   --  the key, depending on the setting of Contains_Key_Data. This allows for
   --  keys to be securely stored in a platform-specific crypto engine instead
   --  of storing them as plaintext in memory.

   type Key_Descriptor (Frame_Counter_Per_Key : Boolean := True) is record
      Key : Key_Holder := (others => <>);

      Key_Device_Frame_Counter_List :
        Key_Device_Frame_Counter_Descriptor_Array
          (1 .. Key_Device_Frame_Counter_Descriptor_Count'Last) :=
          [others => <>];

      case Frame_Counter_Per_Key is
         when True =>
            Key_Frame_Counter : Frame_Counter_Number := 0;

         when False =>
            null;
      end case;
   end record;
   --  secKeyDescriptor

   ------------------------------
   -- secKeyIdLookupDescriptor --
   ------------------------------

   --  Ref. IEEE 802.15.4-2024 Table 9.5.3

   type Key_ID_Lookup_Descriptor
     (Key_ID_Mode : AdaBee.MAC.Frames.Headers.Key_ID_Mode_Field := 0)
   is record
      Key_Item : Key_Descriptor := (others => <>);

      case Key_ID_Mode is
         when 0 =>
            Key_Device_PAN_ID : AdaBee.MAC.Frames.Headers.PAN_ID_Field := 0;

            Key_Device_Addr : AdaBee.MAC.Frames.Headers.Variant_Address :=
              (Mode => Not_Present);

         when 1 | 2 | 3 =>
            Key_Index : AdaBee.MAC.Frames.Headers.Key_Index_Field := 0;

            case Key_ID_Mode is
               when 0 | 1 =>
                  null;

               when 2 =>
                  Key_Source_4 : Byte_Array (1 .. 4) := [others => 0];

               when 3 =>
                  Key_Source_8 : Byte_Array (1 .. 8) := [others => 0];
            end case;
      end case;
   end record;
   --  secKeyIdLookupDescriptor

   -------------------------
   -- secDeviceDescriptor --
   -------------------------

   --  Ref. IEEE 802.15.4-2024 Table 9-15

   type Device_Descriptor is record
      PAN_ID        : AdaBee.MAC.Frames.Headers.PAN_ID_Field := 0;
      Short_Address : AdaBee.MAC.Frames.Headers.Short_Address_Field := 0;
      Ext_Address   : AdaBee.MAC.Frames.Headers.Extended_Address_Field := 0;
      Exempt        : Boolean := False;

      Device_Min_Frame_Counter : Frame_Counter_Number := 0;
   end record
   with Size => 17 * 8;
   --  secDeviceDescriptor

   for Device_Descriptor use
     record
       Ext_Address              at 0 range 0 .. 63;
       Device_Min_Frame_Counter at 0 range 64 .. 95;
       Short_Address            at 0 range 96 .. 111;
       PAN_ID                   at 0 range 112 .. 127;
       Exempt                   at 0 range 128 .. 135;
     end record;

   ----------------------------------
   -- secIeSecurityLevelDescriptor --
   ----------------------------------

   --  Ref. IEEE 802.15.4-2024 Table 9-17

   type Allowed_Security_Levels_Array is
     array (AdaBee.Crypto.Algorithm_Kind,
            AdaBee.MAC.Frames.Headers.Security_Level_Field)
     of Boolean
   with Component_Size => 1, Size => 32;

   type IE_Security_Level_Descriptor is record
      IE : Key_IE_Usage_Descriptor := (others => <>);
      --  Combines secIeType and secIeId

      IE_Allowed_Security_Levels : Allowed_Security_Levels_Array :=
        [others => [others => False]];

      IE_Device_Override_Security_Levels : Boolean := False;
   end record;
   --  secIeSecurityLevelDescriptor

   --------------------------------
   -- secSecurityLevelDescriptor --
   --------------------------------

   --  Ref. IEEE 802.15.4-2024 Table 9-16

   type IE_Security_Level_Descriptor_Count is
     range 0 .. Adabee_Mlme_Config.Sec_Max_IE_Security_Level_Descriptors;

   type IE_Security_Level_Descriptor_Array is
     array (IE_Security_Level_Descriptor_Count range <>)
     of IE_Security_Level_Descriptor;

   type Security_Level_Descriptor is record
      Frame_Types : Frame_Type_Boolean_Array := [others => False];

      Command_IDs : MAC_Command_Boolean_Array := [others => False];

      Device_Override_Security_Levels : Boolean := False;

      Allowed_Security_Levels : Allowed_Security_Levels_Array :=
        [others => [others => False]];

      IE_Security_Level_Descriptor_List_Length :
        IE_Security_Level_Descriptor_Count := 0;

      IE_Security_Level_Descriptor_List :
        IE_Security_Level_Descriptor_Array
          (1 .. IE_Security_Level_Descriptor_Count'Last) := [others => <>];
   end record;
   --  secSecurityLevelDescriptor

end AdaBee.MAC.MLME.Security_Types;
