--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  @summary
--  Root package for the Medium Access Control (MAC) layer
package AdaBee.MAC
  with Pure, SPARK_Mode
is

   type Status_Code is
     (Success,
      Bad_Channel,
      Channel_Access_Failure,
      Counter_Error,
      Frame_Too_Long,
      Improper_Key_Type,
      Improper_Security_Level,
      Invalid_Index,
      Invalid_Parameter,
      Limit_Reached,
      Malformed_Frame,
      No_Ack,
      No_Beacon,
      Not_Supported,
      Read_Only,
      Scan_In_Progress,
      Security_Error,
      Transaction_Expired,
      Transaction_Overflow,
      Unavailable_Key,
      Unsupported_Attribute,
      Unsupported_Field,
      Unsupported_Legacy,
      Unsupported_Security);

end AdaBee.MAC;
