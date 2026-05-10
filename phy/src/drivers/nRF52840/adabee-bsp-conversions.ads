--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with System;
private with System.Storage_Elements;

with NRF52840;

package AdaBee.BSP.Conversions with Preelaborate, SPARK_Mode is

   function To_UInt32 (Addr : System.Address) return NRF52840.UInt32;

private

   function To_UInt32 (Addr : System.Address) return NRF52840.UInt32 is
     (NRF52840.UInt32 (System.Storage_Elements.To_Integer (Addr)));

end AdaBee.BSP.Conversions;