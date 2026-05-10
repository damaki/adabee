--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with System;

with NRF52840; use NRF52840;

--  This package provides a driver for managing starting/stopping the
--  HFCLK/HFXO using reference counting.
--
--  Multiple tasks may require the HFXO to be on or off at different times.
--  This driver manages a reference count to count the number of HFCLK requests
--  so that the HFCLK is only started on the first request, and is only turned
--  off when the the last reference is dropped.
--
--  The HFCLK can take a long time to start up, so this driver can also
--  provide an event endpoint (EEP) which will be triggered when the HFCLK has
--  finished starting. The caller may use this EEP with a PPI channel to
--  trigger some action (e.g. an EGU interrupt) when the HFCLK has started.

package AdaBee.BSP.HFCLK_Control is

   protected HFCLK with
     Interrupt_Priority => System.Interrupt_Priority'Last
   is

      procedure Start;
      --  Request to start the HFCLK.

      procedure Start
        (EEP             : out UInt32;
         Already_Started : out Boolean);
      --  Request to start the HFCLK.
      --
      --  This configures a PPI event endpoint (EEP) register with the event
      --  that will fire when the HFCLK has started.
      --
      --  @param EEP The PPI event endpoint (EEP) to write with the event
      --         that will fire when the HFCLK has started.
      --  @param Already_Started True if the HFCLK is already running, or
      --         False if the HFCLK is not yet fully up and running.
      --         Note that even if this is True, then the event may have
      --         been triggered.

      procedure Stop;
      --  Request to stop the HFCLK

   private

      Reference_Count : Natural := 0;

   end HFCLK;

end AdaBee.BSP.HFCLK_Control;