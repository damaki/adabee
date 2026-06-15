--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with AdaBee.PHY;
with AdaBee.PHY_Constants;

with AdaBee.MAC.Frames.Headers;
with AdaBee.MAC.Frames.Beacons;

with AdaBee.Time_Units;
with Adabee_Mlme_Config;

private with System;

--  This package is the root package for the Service Access Point (SAP) for the
--  MLME (MLME-SAP)
--
--  The various MLME service primitive types are defined in this package.
--
--  Request primitives can be sent to the MLME-SAP using the services provided
--  by package `AdaBee.MAC.MLME.SAP.Requests`.

package AdaBee.MAC.MLME.SAP
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

   --------------------
   -- PAN Descriptor --
   --------------------

   --  Ref. IEEE 802.15.4-2024 Table 8-3

   type PAN_Descriptor_Type is record
      Coord_PAN_ID    : MAC.Frames.Headers.PAN_ID_Field := 0;
      Coord_Address   : MAC.Frames.Headers.Variant_Address := (others => <>);
      Channel_Number  : PHY.RF_Channel_Number := 0;
      Link_Quality    : PHY.LQI_Number := 0;
      Superframe_Spec : MAC.Frames.Beacons.Superframe_Specification_Field :=
        (Beacon_Order       => 0,
         Superframe_Order   => 0,
         Final_CAP_Slot     => 0,
         BLE                => False,
         Reserved           => 0,
         PAN_Coordinator    => False,
         Association_Permit => False);
      Timestamp       : PHY_Constants.Symbol_Count := 0;
      GTS_Permit      : Boolean := False;

      --  Extra info, not defined in IEEE 802.15.4-2024
      RSSI          : PHY.RF_Power_dBm := 0;
      Abs_Timestamp : Time_Units.Time := 0.0;
   end record;

   -----------------------
   -- MLME-SCAN.request --
   -----------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.2.8.2

   type Scan_Type_Kind is (ED, Active, Passive, Orphan, Enhanced_Active);
   --  MLME-SCAN.request ScanType field
   --
   --  RIT_PASSIVE scan is not supported.

   type MLME_SCAN_Req_Type is record
      Scan_Type          : Scan_Type_Kind := ED;
      Scan_Channels      : PHY.Channel_Boolean_Array := [others => False];
      Scan_Duration      : PHY_Constants.Symbol_Count := 0;
      Link_Quality_Scan  : Boolean := False;
      PAN_ID_Suppressed  : Boolean := False;
      Seq_Num_Suppressed : Boolean := False;
   end record;

   -----------------------
   -- MLME-SCAN.confirm --
   -----------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.2.8.3

   type Channel_ED_Range_Array is array (PHY.RF_Channel_Number) of PHY.ED_Range
   with Pack;

   subtype MLME_SCAN_Cfm_PAN_Descriptors_Length is
     Natural range 0 .. Adabee_Mlme_Config.MLME_SCAN_Cfm_Max_PAN_Descriptors;

   type MLME_SCAN_Cfm_PAN_Descriptors is
     array (Positive range 1 .. MLME_SCAN_Cfm_PAN_Descriptors_Length'Last)
     of PAN_Descriptor_Type;

   type MLME_SCAN_Cfm_Type (Scan_Type : Scan_Type_Kind := ED) is record
      Status : Status_Code := Transaction_Expired;

      case Scan_Type is
         when ED =>
            Energy_Detect_List : Channel_ED_Range_Array := [others => 0];

         when others =>
            Unscanned_Channels : PHY.Channel_Boolean_Array :=
              [others => False];

            case Scan_Type is

               when Active | Passive | Enhanced_Active =>
                  PAN_Descriptor_List : MLME_SCAN_Cfm_PAN_Descriptors :=
                    [others => <>];

                  Nb_PAN_Descriptors : MLME_SCAN_Cfm_PAN_Descriptors_Length :=
                    0;

               when others =>
                  null;
            end case;
      end case;
   end record;

   function Is_Valid_SCAN_Cfm
     (Request : MLME_SCAN_Req_Type; Confirm : MLME_SCAN_Cfm_Type)
      return Boolean
   is (Confirm.Scan_Type = Request.Scan_Type

       --  IEEE 802.15.4-2024 Table 8-19 describes UnscannedChannels as:
       --  "A list of the channels given in the request that were not scanned."
       --
       --  So we only allow elements in Unscanned_Channels to be True if they
       --  are one of the channels given in the request.
       and then
         (if Confirm.Scan_Type /= ED
          then
            (for all Ch in PHY.RF_Channel_Number =>
               (if Confirm.Unscanned_Channels (Ch)
                then Request.Scan_Channels (Ch)))));

   ----------------------
   -- MLME-SET.request --
   ----------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.2.5.4

   type PIB_Attribute_Kind is
     (MAC_Auto_Request,
      MAC_DSN,
      MAC_Extended_Address,
      MAC_Max_BE,
      MAC_Max_CSMA_Backoffs,
      MAC_Max_Frame_Retries,
      MAC_Min_BE,
      MAC_PAN_ID,
      MAC_Rx_On_When_Idle,
      MAC_Security_Enabled,
      MAC_Short_Address,

      --  PHY PIB attributes
      PHY_CCA_Mode);
   --  Set of supported MAC PIB attributes

   subtype Read_Only_PIB_Attributes is PIB_Attribute_Kind
   with Static_Predicate => Read_Only_PIB_Attributes in MAC_Extended_Address;
   --  Set of MAC PIB attributes that are read-only

   subtype Writable_PIB_Attributes is PIB_Attribute_Kind
   with
     Static_Predicate =>
       Writable_PIB_Attributes not in Read_Only_PIB_Attributes;

   subtype MAC_Min_BE_Range is Natural range 0 .. 8;
   subtype MAC_Max_BE_Range is Natural range 3 .. 8;
   subtype MAC_Max_CSMA_Backoffs_Range is Natural range 0 .. 5;
   subtype MAC_Max_Frame_Retries_Range is Natural range 0 .. 7;

   type MLME_SET_Req_Type
     (PIB_Attribute : Writable_PIB_Attributes := MAC_Auto_Request)
   is record
      case PIB_Attribute is
         when MAC_Auto_Request =>
            Auto_Request : Boolean := False;

         when MAC_DSN =>
            DSN : Bits_8 := 0;

         when MAC_Min_BE =>
            Min_BE : MAC_Min_BE_Range := MAC_Min_BE_Range'First;

         when MAC_Max_BE =>
            Max_BE : MAC_Max_BE_Range := MAC_Max_BE_Range'First;

         when MAC_Max_CSMA_Backoffs =>
            Max_CSMA_Backoffs : MAC_Max_CSMA_Backoffs_Range := 0;

         when MAC_Short_Address =>
            Short_Address : Frames.Headers.Short_Address_Field := 0;

         when MAC_Max_Frame_Retries =>
            Max_Frame_Retries : MAC_Max_Frame_Retries_Range := 0;

         when MAC_PAN_ID =>
            PAN_ID : Frames.Headers.PAN_ID_Field := 0;

         when MAC_Rx_On_When_Idle =>
            Rx_On_When_Idle : Boolean := False;

         when MAC_Security_Enabled =>
            Security_Enabled : Boolean := False;

         when PHY_CCA_Mode =>
            CCA_Mode : AdaBee.PHY.CCA_Mode_Kind := AdaBee.PHY.ALOHA;

      end case;
   end record;

   ----------------------
   -- MLME-SET.confirm --
   ----------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.2.5.5

   type MLME_SET_Cfm_Type is record
      PIB_Attribute : PIB_Attribute_Kind := PIB_Attribute_Kind'First;
      Status        : Status_Code := Transaction_Expired;
   end record;

   function Is_Valid_SET_Cfm
     (Request : MLME_SET_Req_Type; Confirm : MLME_SET_Cfm_Type) return Boolean
   is (Confirm.PIB_Attribute = Request.PIB_Attribute);

   ----------------------
   -- MLME-GET.request --
   ----------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.2.5.2

   type MLME_GET_Req_Type is record
      PIB_Attribute : PIB_Attribute_Kind := PIB_Attribute_Kind'First;
   end record;

   ----------------------
   -- MLME-GET.confirm --
   ----------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.2.5.2

   type MLME_GET_Cfm_Type
     (PIB_Attribute : PIB_Attribute_Kind := PIB_Attribute_Kind'First;
      Status        : Status_Code := Status_Code'First)
   is record
      --  The attribute value is only present when Status = Success

      case Status is
         when Success =>
            case PIB_Attribute is
               when MAC_Auto_Request =>
                  Auto_Request : Boolean := False;

               when MAC_DSN =>
                  DSN : Bits_8 := 0;

               when MAC_Min_BE =>
                  Min_BE : MAC_Min_BE_Range := MAC_Min_BE_Range'First;

               when MAC_Max_BE =>
                  Max_BE : MAC_Max_BE_Range := MAC_Max_BE_Range'First;

               when MAC_Max_CSMA_Backoffs =>
                  Max_CSMA_Backoffs : MAC_Max_CSMA_Backoffs_Range := 0;

               when MAC_Short_Address =>
                  Short_Address : Frames.Headers.Short_Address_Field := 0;

               when MAC_Extended_Address =>
                  Extended_Address : Frames.Headers.Extended_Address_Field :=
                    0;

               when MAC_Max_Frame_Retries =>
                  Max_Frame_Retries : MAC_Max_Frame_Retries_Range := 0;

               when MAC_PAN_ID =>
                  PAN_ID : Frames.Headers.PAN_ID_Field := 0;

               when MAC_Rx_On_When_Idle =>
                  Rx_On_When_Idle : Boolean := False;

               when MAC_Security_Enabled =>
                  Security_Enabled : Boolean := False;

               when PHY_CCA_Mode =>
                  CCA_Mode : AdaBee.PHY.CCA_Mode_Kind := AdaBee.PHY.ALOHA;

            end case;

         when others =>
            null;
      end case;
   end record;

   function Is_Valid_GET_Cfm
     (Request : MLME_GET_Req_Type; Confirm : MLME_GET_Cfm_Type) return Boolean
   is (Confirm.PIB_Attribute = Request.PIB_Attribute);

   ------------------------
   -- MLME-RESET.request --
   ------------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.2.6.2

   type MLME_RESET_Req_Type is record
      Set_Default_PIB : Boolean := True;
   end record;

   ------------------------
   -- MLME-RESET.confirm --
   ------------------------

   --  Ref. IEEE 802.15.4-2024 Section 8.2.6.3

   --  Success is the only alowed result, as specified in Table 8-13 of
   --  IEEE 802.15.4-2024.

   type MLME_RESET_Cfm_Type is record
      Status : Status_Code := Success;
   end record
   with Predicate => Status = Success;

   -------------------
   -- MLME Requests --
   -------------------

   type MLME_Request_Kind is
     (MLME_SCAN_Req, MLME_SET_Req, MLME_GET_Req, MLME_RESET_Req);

   type MLME_Request_Type
     (Kind : MLME_Request_Kind := MLME_Request_Kind'First)
   is record
      case Kind is
         when MLME_SCAN_Req =>
            SCAN : MLME_SCAN_Req_Type := (others => <>);

         when MLME_SET_Req =>
            SET : MLME_SET_Req_Type := (others => <>);

         when MLME_GET_Req =>
            GET : MLME_GET_Req_Type := (others => <>);

         when MLME_RESET_Req =>
            RESET : MLME_RESET_Req_Type := (others => <>);
      end case;
   end record;

   function Requires_Confirm (Request : MLME_Request_Type) return Boolean
   is (case Request.Kind is
         when MLME_SCAN_Req  => True,
         when MLME_SET_Req   => True,
         when MLME_GET_Req   => True,
         when MLME_RESET_Req => True);

   function Request_Requires_Cleanup
     (Request : MLME_Request_Type with Unreferenced) return Boolean
   is (False);

   function Valid_Request
     (Request : MLME_Request_Type with Unreferenced) return Boolean
   is (True);

   ------------------------
   -- MLME Confirmations --
   ------------------------

   type MLME_Confirm_Kind is
     (MLME_SCAN_Cfm, MLME_SET_Cfm, MLME_GET_Cfm, MLME_RESET_Cfm);

   type MLME_Confirm_Type
     (Kind : MLME_Confirm_Kind := MLME_Confirm_Kind'First)
   is record
      case Kind is
         when MLME_SCAN_Cfm =>
            SCAN : MLME_SCAN_Cfm_Type := (others => <>);

         when MLME_SET_Cfm =>
            SET : MLME_SET_Cfm_Type := (others => <>);

         when MLME_GET_Cfm =>
            GET : MLME_GET_Cfm_Type := (others => <>);

         when MLME_RESET_Cfm =>
            RESET : MLME_RESET_Cfm_Type := (others => <>);
      end case;
   end record;

   function Confirm_Requires_Cleanup
     (Confirm : MLME_Confirm_Type with Unreferenced) return Boolean
   is (False);

   function Valid_Confirm
     (Request : MLME_Request_Type; Confirm : MLME_Confirm_Type) return Boolean
   is (case Request.Kind is
         when MLME_SCAN_Req  =>
           Confirm.Kind = MLME_SCAN_Cfm
           and then Is_Valid_SCAN_Cfm (Request.SCAN, Confirm.SCAN),

         when MLME_SET_Req   =>
           Confirm.Kind = MLME_SET_Cfm
           and then Is_Valid_SET_Cfm (Request.SET, Confirm.SET),

         when MLME_GET_Req   =>
           Confirm.Kind = MLME_GET_Cfm
           and then Is_Valid_GET_Cfm (Request.GET, Confirm.GET),

         when MLME_RESET_Req => Confirm.Kind = MLME_RESET_Cfm);

   -------------------------
   --  MLME Request Kinds --
   -------------------------

   --  LibSAP allows proving that the kind of request is preserved throughout
   --  the transaction lifecycle.
   --
   --  This is useful for the user to be able to prove that the key aspects of
   --  the original request have not been changed when they get the confirm
   --  primitive back. For example, if they sent a MLME-SCAN.request, then they
   --  will get a MLME-SCAN.request back (and not, say, a MLME-SET.request).
   --
   --  For some kinds of requests it is also desirable to prove that some key
   --  fields of the request are also preserved. For example, in the case of
   --  the MLME-SCAN.request it is useful to prove that the Scan_Type field
   --  is also preserved.
   --
   --  MLME_Compound_Request_Kind is defined for this purpose. This type
   --  should be as small as reasonably practicable since it is copied in a
   --  few places within LibSAP. This may change in the future when ghost
   --  fields are supported in GNATprove.

   type MLME_Compound_Request_Kind
     (Kind : MLME_Request_Kind := MLME_Request_Kind'First)
   is record
      case Kind is
         when MLME_SCAN_Req =>
            Scan_Type : Scan_Type_Kind := Scan_Type_Kind'First;

         when MLME_GET_Req | MLME_SET_Req =>
            PIB_Attribute : PIB_Attribute_Kind := PIB_Attribute_Kind'First;

         when others =>
            null;
      end case;
   end record
   with Size => 16;

   function Request_Kind
     (Request : MLME_Request_Type) return MLME_Compound_Request_Kind
   is (case Request.Kind is
         when MLME_SCAN_Req  =>
           (Kind => MLME_SCAN_Req, Scan_Type => Request.SCAN.Scan_Type),

         when MLME_SET_Req   =>
           (Kind => MLME_SET_Req, PIB_Attribute => Request.SET.PIB_Attribute),

         when MLME_GET_Req   =>
           (Kind => MLME_GET_Req, PIB_Attribute => Request.GET.PIB_Attribute),

         when MLME_RESET_Req => (Kind => MLME_RESET_Req))
   with Post => Request_Kind'Result.Kind = Request.Kind;

   function Request_Kind_Requires_Cleanup
     (Kind : MLME_Compound_Request_Kind with Unreferenced) return Boolean
   is (False);

   ----------------------------
   -- Transaction Management --
   ----------------------------

   subtype Transaction_ID_Range is
     Positive range 1 .. Adabee_Mlme_Config.MLME_Request_Queue_Capacity;

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

end AdaBee.MAC.MLME.SAP;
