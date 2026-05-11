--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package AdaBee.MAC.Frames.MAC_Commands
  with SPARK_Mode
is
   --  Ref. Table 7-11 of IEEE 802.15.4-2024

   Association_Request                 : constant Bits_8 := 16#01#;
   Association_Response                : constant Bits_8 := 16#02#;
   Disassociation_Notification         : constant Bits_8 := 16#03#;
   Data_Request                        : constant Bits_8 := 16#04#;
   PAN_ID_Conflict_Notification        : constant Bits_8 := 16#05#;
   Orphan_Notification                 : constant Bits_8 := 16#06#;
   Beacon_Request                      : constant Bits_8 := 16#07#;
   Coordinator_Realignment             : constant Bits_8 := 16#08#;
   GTS_Request                         : constant Bits_8 := 16#09#;
   TRLE_Management_Request             : constant Bits_8 := 16#0A#;
   TRLE_Management_Response            : constant Bits_8 := 16#0B#;
   --  16#0C# .. 16#12# reserved
   DSME_Association_Request            : constant Bits_8 := 16#13#;
   DSME_Association_Response           : constant Bits_8 := 16#14#;
   DSME_GTS_Request                    : constant Bits_8 := 16#15#;
   DSME_GTS_Response                   : constant Bits_8 := 16#16#;
   DSME_GTS_Notify                     : constant Bits_8 := 16#17#;
   DSME_Information_Request            : constant Bits_8 := 16#18#;
   DSME_Information_Response           : constant Bits_8 := 16#19#;
   DSME_Beacon_Allocation_Notification : constant Bits_8 := 16#1A#;
   DSME_Beacon_Collision_Notification  : constant Bits_8 := 16#1B#;
   DSME_Link_Report                    : constant Bits_8 := 16#1C#;
   --  16#1D# .. 16#1F# reserved
   RIT_Data_Request                    : constant Bits_8 := 16#20#;
   DBS_Request                         : constant Bits_8 := 16#21#;
   DBS_Response                        : constant Bits_8 := 16#22#;
   RIT_Data_Response                   : constant Bits_8 := 16#23#;
   Vendor_Specific                     : constant Bits_8 := 16#24#;
   SRM_Request                         : constant Bits_8 := 16#25#;
   SRM_Response                        : constant Bits_8 := 16#26#;
   SRM_Report                          : constant Bits_8 := 16#27#;
   SRM_Information                     : constant Bits_8 := 16#28#;
   Ranging_Verifier                    : constant Bits_8 := 16#29#;
   Ranging_Prover                      : constant Bits_8 := 16#2A#;
   --  16#2B# .. 16#FF# reserved

end AdaBee.MAC.Frames.MAC_Commands;
