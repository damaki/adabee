--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package AdaBee.PHY.Constants with
  SPARK_Mode => On
is

   Max_PHY_Packet_Size : constant := 127;
   --  aMaxPhyPacketSize

   Turnaround_Time : constant Symbol_Count := 12;
   --  aTurnaroundTime

   CCA_Time : constant Symbol_Count := 8;
   --  aCcaTime
   --
   --  This value is valid for all PHYs except the SUN O-QPSK PHY

end AdaBee.PHY.Constants;