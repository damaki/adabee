--
--  Copyright 2026 (C) Daniel King
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
with Ada.Interrupts;
with Ada.Interrupts.Names;

with NRF52840.EGU;
with NRF52840.RTC;
with NRF52840.TIMER;

package AdaBee.BSP.Config with SPARK_Mode is

   -----------------------------
   -- PPI_Scheduler Resources --
   -----------------------------

   --  The following peripherals are used by the radio's PPI scheduler:
   --   * one RTC peripheral
   --   * one TIMER peripheral
   --   * one PPI channel

   PPI_Scheduler_RTC_Periph : NRF52840.RTC.RTC_Peripheral
                              renames NRF52840.RTC.RTC1_Periph;

   PPI_Scheduler_RTC_Interrupt : constant Ada.Interrupts.Interrupt_ID :=
                                 Ada.Interrupts.Names.RTC1_Interrupt;

   PPI_Scheduler_TIMER_Periph : NRF52840.TIMER.TIMER_Peripheral
                                renames NRF52840.TIMER.TIMER3_Periph;

   PPI_Scheduler_TIMER_Interrupt : constant Ada.Interrupts.Interrupt_ID :=
                                   Ada.Interrupts.Names.TIMER3_Interrupt;

   PPI_Scheduler_PPI_CH_Idx : constant := 15;

   ---------------------
   -- Radio Resources --
   ---------------------

   --  The following peripherals are used by the radio driver:
   --   * one EGU peripheral
   --   * 6 PPI channels

   Radio_EGU_Periph : NRF52840.EGU.EGU_Peripheral
                      renames NRF52840.EGU.EGU5_Periph;
   --  The EGU peripheral used by the radio

   Radio_EGU_Interrupt : constant Ada.Interrupts.Interrupt_ID :=
                         Ada.Interrupts.Names.SWI5_EGU5_Interrupt;

   Radio_PPI_CH0_Idx : constant := 14;
   Radio_PPI_CH1_Idx : constant := 15;
   Radio_PPI_CH2_Idx : constant := 16;
   Radio_PPI_CH3_Idx : constant := 17;
   Radio_PPI_CH4_Idx : constant := 18;
   Radio_PPI_CH5_Idx : constant := 19;

end AdaBee.BSP.Config;
