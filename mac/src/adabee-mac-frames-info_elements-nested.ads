--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Unchecked_Conversion;
with System;

--  @summary
--  Definitions for Nested IEs as defined in IEEE 802.15.4-2024 Section 7.4.4
package AdaBee.MAC.Frames.Info_Elements.Nested
  with Pure, SPARK_Mode, Always_Terminates
is

   -------------------------------------
   -- Nested IE Format (short format) --
   -------------------------------------

   --  Ref. IEEE 802.15.4-2024 Section 7.4.4.1

   type Short_Sub_ID_Field is range 0 .. 127 with Size => 7;
   type Short_Length_Field is range 0 .. 255 with Size => 8;

   type Short_Header_Field is record
      Length  : Short_Length_Field;
      Sub_ID  : Short_Sub_ID_Field;
      IE_Type : IE_Type_Field;
   end record
   with
     Size                 => 16,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Short_Header_Field use
     record
       Length  at 0 range 0 .. 7;
       Sub_ID  at 0 range 8 .. 14;
       IE_Type at 0 range 15 .. 15;
     end record;

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Short_Header_Field,
        Target => Byte_Array_2);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Byte_Array_2_Aligned_2,
        Target => Short_Header_Field);

   function From_Bytes (Bytes : Byte_Array_2) return Short_Header_Field
   is (From_Bytes (Byte_Array_2_Aligned_2 (Bytes)));

   -------------------------------------
   -- Nested IE Format (long format) --
   -------------------------------------

   --  Ref. IEEE 802.15.4-2024 Section 7.4.4.1

   type Long_Sub_ID_Field is range 0 .. 15 with Size => 4;
   type Long_Length_Field is range 0 .. 2047 with Size => 11;

   type Long_Header_Field is record
      Length  : Long_Length_Field;
      Sub_ID  : Long_Sub_ID_Field;
      IE_Type : IE_Type_Field;
   end record
   with
     Size                 => 16,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Long_Header_Field use
     record
       Length  at 0 range 0 .. 10;
       Sub_ID  at 0 range 11 .. 14;
       IE_Type at 0 range 15 .. 15;
     end record;

   function To_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Long_Header_Field,
        Target => Byte_Array_2);

   function From_Bytes is new
     Ada.Unchecked_Conversion
       (Source => Byte_Array_2_Aligned_2,
        Target => Long_Header_Field);

   function From_Bytes (Bytes : Byte_Array_2) return Long_Header_Field
   is (From_Bytes (Byte_Array_2_Aligned_2 (Bytes)));

   ----------------------
   -- Nested IE Header --
   ----------------------

   type Header_Field (IE_Type : IE_Type_Field) is record
      case IE_Type is
         when Short =>
            Short_Length : Short_Length_Field;
            Short_Sub_ID : Short_Sub_ID_Field;

         when Long =>
            Long_Length : Long_Length_Field;
            Long_Sub_ID : Long_Sub_ID_Field;
      end case;
   end record
   with
     Size                 => 16,
     Bit_Order            => System.Low_Order_First,
     Scalar_Storage_Order => System.Low_Order_First;

   for Header_Field use
     record
       Short_Length at 0 range 0 .. 7;
       Short_Sub_ID at 0 range 8 .. 14;

       Long_Length at 0 range 0 .. 10;
       Long_Sub_ID at 0 range 11 .. 14;

       IE_Type at 0 range 15 .. 15;
     end record;

   --  SPARK does not allow Unchecked_Conversion with type Header_Field because
   --  it has discriminants.

   function To_Bytes (HF : Header_Field) return Byte_Array_2
   is (case HF.IE_Type is
         when Short =>
           To_Bytes
             (Short_Header_Field'
                (IE_Type => HF.IE_Type,
                 Length  => HF.Short_Length,
                 Sub_ID  => HF.Short_Sub_ID)),
         when Long  =>
           To_Bytes
             (Long_Header_Field'
                (IE_Type => HF.IE_Type,
                 Length  => HF.Long_Length,
                 Sub_ID  => HF.Long_Sub_ID)));

   function From_Bytes (Bytes : Byte_Array_2) return Header_Field
   is (case Short_Header_Field'(From_Bytes (Bytes)).IE_Type is
         when Short =>
           Header_Field'
             (IE_Type      => Short,
              Short_Length => Short_Header_Field'(From_Bytes (Bytes)).Length,
              Short_Sub_ID => Short_Header_Field'(From_Bytes (Bytes)).Sub_ID),
         when Long  =>
           Header_Field'
             (IE_Type     => Long,
              Long_Length => Long_Header_Field'(From_Bytes (Bytes)).Length,
              Long_Sub_ID => Long_Header_Field'(From_Bytes (Bytes)).Sub_ID));

   --------------------------------------
   -- Nested IE Sub-IDs (short format) --
   --------------------------------------

   --  Ref. IEEE 802.15.4-2024 Table 7-9

   TSCH_Sync_IE                        : constant Short_Sub_ID_Field := 16#1A#;
   TSCH_Slotframe_And_Link_IE          : constant Short_Sub_ID_Field := 16#1B#;
   TSCH_Timeslot_IE                    : constant Short_Sub_ID_Field := 16#1C#;
   Hopping_Timing_IE                   : constant Short_Sub_ID_Field := 16#1D#;
   Enhanced_Beacon_Filter_IE           : constant Short_Sub_ID_Field := 16#1E#;
   MAC_Metrics_IE                      : constant Short_Sub_ID_Field := 16#1F#;
   All_MAC_Metrics_IE                  : constant Short_Sub_ID_Field := 16#20#;
   Coexistence_Spec_IE                 : constant Short_Sub_ID_Field := 16#21#;
   SUN_Device_Capabilities_IE          : constant Short_Sub_ID_Field := 16#22#;
   SUN_FSK_Generic_PHY_IE              : constant Short_Sub_ID_Field := 16#23#;
   Mode_Switch_Parameter_IE            : constant Short_Sub_ID_Field := 16#24#;
   PHY_Parameter_Change_IE             : constant Short_Sub_ID_Field := 16#25#;
   O_QPSK_PHY_Mode_IE                  : constant Short_Sub_ID_Field := 16#26#;
   PCA_Allocation_IE                   : constant Short_Sub_ID_Field := 16#27#;
   LECIM_DSSS_Operating_Mode_IE        : constant Short_Sub_ID_Field := 16#28#;
   LECIM_FSK_Operating_Mode_IE         : constant Short_Sub_ID_Field := 16#29#;
   TVWS_PHY_Operating_Mode_Desc_IE     : constant Short_Sub_ID_Field := 16#2B#;
   TVWS_Device_Capabilities_IE         : constant Short_Sub_ID_Field := 16#2C#;
   TVWS_Device_Category_IE             : constant Short_Sub_ID_Field := 16#2D#;
   TVWS_Device_ID_IE                   : constant Short_Sub_ID_Field := 16#2E#;
   TVWS_Device_Location_IE             : constant Short_Sub_ID_Field := 16#2F#;
   TVWS_Channel_Info_Query_IE          : constant Short_Sub_ID_Field := 16#30#;
   TVWS_Channel_Info_Source_IE         : constant Short_Sub_ID_Field := 16#31#;
   CTM_IE                              : constant Short_Sub_ID_Field := 16#32#;
   Timestamp_IE                        : constant Short_Sub_ID_Field := 16#33#;
   Timestamp_Diff_IE                   : constant Short_Sub_ID_Field := 16#34#;
   TMCTP_Spec_IE                       : constant Short_Sub_ID_Field := 16#35#;
   RCC_PHY_Operating_Mode_IE           : constant Short_Sub_ID_Field := 16#36#;
   Link_Margin_IE                      : constant Short_Sub_ID_Field := 16#37#;
   RS_GFSK_Device_Capabilities_IE      : constant Short_Sub_ID_Field := 16#38#;
   Multi_PHY_IE                        : constant Short_Sub_ID_Field := 16#39#;
   Vendor_Specific_IE                  : constant Short_Sub_ID_Field := 16#40#;
   SRM_IE                              : constant Short_Sub_ID_Field := 16#46#;
   LECIM_FSK_Split_Operating_Mode_IE   : constant Short_Sub_ID_Field := 16#47#;
   Ranging_Reply_Time_Instantaneous_IE : constant Short_Sub_ID_Field := 16#48#;
   Advanced_Ranging_Control_IE         : constant Short_Sub_ID_Field := 16#49#;
   Ranging_Interval_Update_IE          : constant Short_Sub_ID_Field := 16#4A#;
   Ranging_Round_IE                    : constant Short_Sub_ID_Field := 16#4B#;
   Ranging_Block_Update_IE             : constant Short_Sub_ID_Field := 16#4C#;
   Ranging_Contention_Phase_Struct_IE  : constant Short_Sub_ID_Field := 16#4D#;
   Ranging_Contention_Max_Attempts_IE  : constant Short_Sub_ID_Field := 16#4E#;
   Ranging_STS_Seed_And_Data_IE        : constant Short_Sub_ID_Field := 16#4F#;
   Ranging_Change_Request_IE           : constant Short_Sub_ID_Field := 16#50#;
   Ranging_Device_Management_IE        : constant Short_Sub_ID_Field := 16#51#;
   Ranging_Req_Meas_And_Control_IE     : constant Short_Sub_ID_Field := 16#52#;
   Ranging_Meas_Info_IE                : constant Short_Sub_ID_Field := 16#53#;
   SP3_Ranging_Request_Reports_IE      : constant Short_Sub_ID_Field := 16#54#;
   Ranging_Channel_And_Preamble_Sel_IE : constant Short_Sub_ID_Field := 16#55#;
   Ranging_Reply_Time_Negotiation_IE   : constant Short_Sub_ID_Field := 16#56#;
   Ranging_Msg_Non_Receipt_IE          : constant Short_Sub_ID_Field := 16#57#;
   Ranging_Ancillary_Info_Msg_Ctr_IE   : constant Short_Sub_ID_Field := 16#58#;
   Ranging_Multiple_Msg_Receipt_Cfm_IE : constant Short_Sub_ID_Field := 16#59#;
   Auth_Challenge_Res_Ranging_Ctrl_IE  : constant Short_Sub_ID_Field := 16#5A#;
   Ranging_Descriptor_IE               : constant Short_Sub_ID_Field := 16#5B#;
   Challenge_Response_Transfer_IE      : constant Short_Sub_ID_Field := 16#5C#;

   --  Shorter aliases for ranging-related IEs

   ARC_IE   : constant Short_Sub_ID_Field := Advanced_Ranging_Control_IE;
   RIU_IE   : constant Short_Sub_ID_Field := Ranging_Interval_Update_IE;
   RR_IE    : constant Short_Sub_ID_Field := Ranging_Round_IE;
   RBU_IE   : constant Short_Sub_ID_Field := Ranging_Block_Update_IE;
   RSSD_IE  : constant Short_Sub_ID_Field := Ranging_STS_Seed_And_Data_IE;
   RCR_IE   : constant Short_Sub_ID_Field := Ranging_Change_Request_IE;
   RDM_IE   : constant Short_Sub_ID_Field := Ranging_Device_Management_IE;
   RRMC_IE  : constant Short_Sub_ID_Field := Ranging_Req_Meas_And_Control_IE;
   RMI_IE   : constant Short_Sub_ID_Field := Ranging_Meas_Info_IE;
   SRRR_IE  : constant Short_Sub_ID_Field := SP3_Ranging_Request_Reports_IE;
   RRTN_IE  : constant Short_Sub_ID_Field := Ranging_Reply_Time_Negotiation_IE;
   RMNR_IE  : constant Short_Sub_ID_Field := Ranging_Msg_Non_Receipt_IE;
   RAICT_IE : constant Short_Sub_ID_Field := Ranging_Ancillary_Info_Msg_Ctr_IE;
   RD_IE    : constant Short_Sub_ID_Field := Ranging_Descriptor_IE;

   RCPS_IE : constant Short_Sub_ID_Field := Ranging_Contention_Phase_Struct_IE;
   RCMA_IE : constant Short_Sub_ID_Field := Ranging_Contention_Max_Attempts_IE;

   RRTI_IE : constant Short_Sub_ID_Field :=
     Ranging_Reply_Time_Instantaneous_IE;

   RCPCS_IE : constant Short_Sub_ID_Field :=
     Ranging_Channel_And_Preamble_Sel_IE;

   ACRRC_IE : constant Short_Sub_ID_Field :=
     Ranging_Multiple_Msg_Receipt_Cfm_IE;

   ACRRC_IE : constant Short_Sub_ID_Field :=
     Auth_Challenge_Res_Ranging_Ctrl_IE;

   -------------------------------------
   -- Nested IE Sub-IDs (long format) --
   -------------------------------------

   --  Ref. IEEE 802.15.4-2024 Table 7-10

   Vendor_Specific_Nested_IE : constant Long_Sub_ID_Field := 16#8#;
   Channel_Hopping_IE        : constant Long_Sub_ID_Field := 16#9#;

end AdaBee.MAC.Frames.Info_Elements.Nested;
