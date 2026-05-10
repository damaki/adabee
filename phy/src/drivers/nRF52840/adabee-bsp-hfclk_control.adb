--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with NRF52840.CLOCK; use NRF52840.CLOCK;

with AdaBee.BSP.Conversions; use AdaBee.BSP.Conversions;

package body AdaBee.BSP.HFCLK_Control is

   protected body HFCLK is

      -----------
      -- Start --
      -----------

      procedure Start is
      begin
         if Reference_Count = 0 then
            CLOCK_Periph.EVENTS_HFCLKSTARTED :=
              (EVENTS_HFCLKSTARTED => 0,
               others              => <>);

            CLOCK_Periph.TASKS_HFCLKSTART :=
              (TASKS_HFCLKSTART => 1,
               others           => <>);
         end if;

         Reference_Count := Reference_Count + 1;
      end Start;

      procedure Start
        (EEP             : out UInt32;
         Already_Started : out Boolean)
      is
      begin
         if Reference_Count = 0 then
            Already_Started := False;

            CLOCK_Periph.EVENTS_HFCLKSTARTED :=
              (EVENTS_HFCLKSTARTED => 0,
               others              => <>);

            EEP := To_UInt32 (CLOCK_Periph.EVENTS_HFCLKSTARTED'Address);

            CLOCK_Periph.TASKS_HFCLKSTART :=
              (TASKS_HFCLKSTART => 1,
               others           => <>);

         elsif CLOCK_Periph.EVENTS_HFCLKSTARTED.EVENTS_HFCLKSTARTED /= 0 then
            Already_Started := True;

         else
            --  HFCLK is still starting

            Already_Started := False;

            EEP := To_UInt32 (CLOCK_Periph.EVENTS_HFCLKSTARTED'Address);
         end if;

         Reference_Count := Reference_Count + 1;
      end Start;

      ----------
      -- Stop --
      ----------

      procedure Stop is
      begin
         if Reference_Count > 0 then
            Reference_Count := Reference_Count - 1;

            if Reference_Count = 0 then
               CLOCK_Periph.TASKS_HFCLKSTOP :=
                 (TASKS_HFCLKSTOP => 1,
                  others          => <>);
            end if;
         end if;
      end Stop;

   end HFCLK;

end AdaBee.BSP.HFCLK_Control;