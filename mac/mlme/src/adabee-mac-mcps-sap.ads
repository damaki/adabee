--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with System;

with AdaBee.MAC.Frames.Headers;
with AdaBee.PHY;
with AdaBee.PHY_Constants;
with AdaBee.Time_Units;
with Adabee_Mlme_Config;

package AdaBee.MAC.MCPS.SAP
  with
    Elaborate_Body,
    SPARK_Mode,
    Always_Terminates,
    Abstract_State =>
      (Confirm_Monitors with
        Synchronous,
        External =>
          (Async_Writers, Effective_Reads, Async_Readers, Effective_Writes)),
    Initializes    => Confirm_Monitors
is
   use all type AdaBee.MAC.Frames.Headers.Address_Mode_Field;
   use all type AdaBee.MAC.Frames.Headers.Seq_Number_Suppression_Field;
   use type AdaBee.PHY.RF_Power_dBm;

   ----------------
   -- Tx Options --
   ----------------

   --  Ref. IEEE 802.15.4-2024 Section 8.3.3

   type Tx_Options_Type is record
      Ack_Tx                 : Boolean := False;
      Gts_Tx                 : Boolean := False;
      Indirect_Tx            : Boolean := False;
      PAN_ID_Suppressed      : Boolean := False;
      Seq_Num_Suppressed     : Boolean := False;
      Send_Multipurpose      : Boolean := False;
      Critical_Event_Message : Boolean := False;
      Legacy_Tx              : Boolean := False;
      Empty_Payload          : Boolean := False;
   end record
   with Pack;

   -----------------------
   -- MCPS-DATA.request --
   -----------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.3.4

   type MSDU_Handle_Number is range 0 .. 255 with Size => 8;

   subtype MSDU_Length_Number is
     Natural range 0 .. Adabee_Mlme_Config.MCPS_Max_MSDU_Length;

   type MCPS_DATA_Request_Type is record
      Src_Addr : AdaBee.MAC.Frames.Headers.Variant_Address :=
        (Mode => Not_Present);

      Dst_Addr : AdaBee.MAC.Frames.Headers.Variant_Address :=
        (Mode => Not_Present);

      Dst_PAN_ID : AdaBee.MAC.Frames.Headers.PAN_ID_Field := 0;

      MSDU : Byte_Array (1 .. Adabee_Mlme_Config.MCPS_Max_MSDU_Length) :=
        [others => 0];

      MSDU_Length : MSDU_Length_Number := 0;

      MSDU_Handle : MSDU_Handle_Number := 0;

      Tx_Options : Tx_Options_Type := (others => <>);
   end record;

   -----------------------
   -- MCPS-DATA.confirm --
   -----------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.3.5

   type MCPS_DATA_Confirm_Type (Status : Status_Code := Success) is record
      MSDU_Handle : MSDU_Handle_Number := 0;

      case Status is
         when Success =>
            Timestamp     : AdaBee.PHY_Constants.Symbol_Count := 0;
            Abs_Timestamp : AdaBee.Time_Units.Time := 0.0;
            Num_Backoffs  : Natural := 0;
            Frame_Pending : Boolean := False;
            RSSI          : AdaBee.PHY.RF_Power_dBm := 0;

         when others =>
            null;
      end case;
   end record;

   function Valid_DATA_Confirm
     (Request : MCPS_DATA_Request_Type; Confirm : MCPS_DATA_Confirm_Type)
      return Boolean
   is (Confirm.MSDU_Handle = Request.MSDU_Handle
       and then
         (if Confirm.Status = Success and then not Request.Tx_Options.Ack_Tx
          then Confirm.RSSI = 0 and then not Confirm.Frame_Pending));

   --------------------------
   -- MCPS-DATA.indication --
   --------------------------

   --  Ref IEEE 802.15.4-2024 Secction 8.3.6

   type MCPS_DATA_Indication_Type is record
      Src_Addr : AdaBee.MAC.Frames.Headers.Variant_Address :=
        (Mode => Not_Present);

      Src_PAN_ID : AdaBee.MAC.Frames.Headers.Variant_PAN_ID :=
        (Present => False);

      Dst_Addr : AdaBee.MAC.Frames.Headers.Variant_Address :=
        (Mode => Not_Present);

      Dst_PAN_ID : AdaBee.MAC.Frames.Headers.PAN_ID_Field := 0;

      MSDU : Byte_Array (1 .. Adabee_Mlme_Config.MCPS_Max_MSDU_Length) :=
        [others => 0];

      MSDU_Length : MSDU_Length_Number := 0;

      MPDU_Link_Quality : AdaBee.PHY.LQI_Number := 0;

      RSSI : AdaBee.PHY.RF_Power_dBm := 0;

      DSN : AdaBee.MAC.Frames.Headers.Variant_Sequence_Number :=
        (Suppression => Suppressed);

      Timestamp     : AdaBee.PHY_Constants.Symbol_Count := 0;
      Abs_Timestamp : AdaBee.Time_Units.Time := 0.0;

      Frame_Pending : Boolean := False;

      Ack_Sent : Boolean := False;

      Data_Frame_Version : AdaBee.MAC.Frames.Headers.Frame_Version_Field :=
        AdaBee.MAC.Frames.Headers.Frame_Version_Field'First;
   end record;

   ------------------------
   -- MCPS-PURGE.request --
   ------------------------

   --  Ref IEEE 802.15.4-2024 Secction 8.3.7

   type MCPS_PURGE_Request_Type is record
      MSDU_Handle : MSDU_Handle_Number := 0;
   end record;

   ------------------------
   -- MCPS-PURGE.confirm --
   ------------------------

   --  Ref IEEE 802.15.4-2024 Secction 8.3.8

   type MCPS_PURGE_Confirm_Type is record
      MSDU_Handle : MSDU_Handle_Number := 0;
      Status      : Status_Code := Success;
   end record;

   function Valid_PURGE_Confirm
     (Request : MCPS_PURGE_Request_Type; Confirm : MCPS_PURGE_Confirm_Type)
      return Boolean
   is (Confirm.MSDU_Handle = Request.MSDU_Handle);

   -------------------
   -- MCPS Requests --
   -------------------

   type MCPS_Request_Kind is (MCPS_DATA_Req, MCPS_PURGE_Req)
   with Default_Value => MCPS_DATA_Req;

   type MCPS_Request_Type
     (Kind : MCPS_Request_Kind := MCPS_Request_Kind'First)
   is record
      case Kind is
         when MCPS_DATA_Req =>
            DATA : MCPS_DATA_Request_Type := (others => <>);

         when MCPS_PURGE_Req =>
            PURGE : MCPS_PURGE_Request_Type := (others => <>);
      end case;
   end record;

   function Requires_Confirm (Request : MCPS_Request_Type) return Boolean
   is (case Request.Kind is
         when MCPS_DATA_Req  => True,
         when MCPS_PURGE_Req => True);

   function Request_Requires_Cleanup
     (Request : MCPS_Request_Type with Unreferenced) return Boolean
   is (False);

   function Valid_Request
     (Request : MCPS_Request_Type with Unreferenced) return Boolean
   is (True);

   function Request_Kind_Requires_Cleanup
     (Kind : MCPS_Request_Kind with Unreferenced) return Boolean
   is (False);

   function Request_Kind (Request : MCPS_Request_Type) return MCPS_Request_Kind
   is (Request.Kind);

   ------------------------
   -- MCPS Confirmations --
   ------------------------

   type MCPS_Confirm_Kind is (MCPS_DATA_Cfm, MCPS_PURGE_Cfm);

   type MCPS_Confirm_Type
     (Kind : MCPS_Confirm_Kind := MCPS_Confirm_Kind'First)
   is record
      case Kind is
         when MCPS_DATA_Cfm =>
            DATA : MCPS_DATA_Confirm_Type := (others => <>);

         when MCPS_PURGE_Cfm =>
            PURGE : MCPS_PURGE_Confirm_Type := (others => <>);
      end case;
   end record;

   function Confirm_Requires_Cleanup
     (Confirm : MCPS_Confirm_Type with Unreferenced) return Boolean
   is (False);

   function Valid_Confirm
     (Request : MCPS_Request_Type; Confirm : MCPS_Confirm_Type) return Boolean
   is (case Request.Kind is
         when MCPS_DATA_Req  =>
           Confirm.Kind = MCPS_DATA_Cfm
           and then Valid_DATA_Confirm (Request.DATA, Confirm.DATA),

         when MCPS_PURGE_Req =>
           Confirm.Kind = MCPS_PURGE_Cfm
           and then Valid_PURGE_Confirm (Request.PURGE, Confirm.PURGE));

   ----------------------
   -- MCPS Indications --
   ----------------------

   type MCPS_Indication_Kind is (MCPS_DATA_Ind)
   with Default_Value => MCPS_DATA_Ind;

   type MCPS_Indication_Type is record
      DATA : MCPS_DATA_Indication_Type := (others => <>);
   end record;

   function Requires_Response
     (Indication : MCPS_Indication_Type with Unreferenced) return Boolean
   is (False);

   function Indication_Requires_Cleanup
     (Indication : MCPS_Indication_Type with Unreferenced) return Boolean
   is (False);

   function Valid_Indication
     (Indication : MCPS_Indication_Type with Unreferenced) return Boolean
   is (True);

   function Indication_Kind
     (Indication : MCPS_Indication_Type with Unreferenced)
      return MCPS_Indication_Kind
   is (MCPS_DATA_Ind);

   function Indication_Kind_Requires_Cleanup
     (Kind : MCPS_Indication_Kind with Unreferenced) return Boolean
   is (False);

   --------------------
   -- MCPS Responses --
   --------------------

   --  IEEE 802.15.4-2024 does not define any .response primitives for the
   --  MCPS-SAP.

   type MCPS_Response_Type is null record;

   function Response_Requires_Cleanup
     (Response : MCPS_Response_Type with Unreferenced) return Boolean
   is (False);

   function Valid_Response
     (Indication : MCPS_Indication_Type with Unreferenced;
      Response   : MCPS_Response_Type with Unreferenced) return Boolean
   is (False);

   ----------------------------
   -- Transaction Management --
   ----------------------------

   subtype Transaction_ID_Range is
     Positive range 1 .. Adabee_Mlme_Config.MCPS_Request_Queue_Capacity;

   procedure Notify_Confirm_Pending (TID : Transaction_ID_Range)
   with Global => (In_Out => Confirm_Monitors);

private

   protected type Monitor with Priority => System.Priority'Last is
      entry Wait;
      procedure Notify;
      procedure Clear;
   private
      Signalled : Boolean := False;
   end Monitor;

   type Monitor_Array is array (Transaction_ID_Range) of Monitor;

   Monitors : Monitor_Array
   with Part_Of => Confirm_Monitors;

end AdaBee.MAC.MCPS.SAP;
