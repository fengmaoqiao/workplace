
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : ALL
--    ,' GoodLuck ,'      RCSfile: target_config_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.10   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Constants for the synthesis target. 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/PROJECTS/WILD_IP_LIB/packages/target_config/vhdl/pkg/target_config_pkg.vhd,v  
--  Log: target_config_pkg.vhd,v  
-- Revision 1.10  2004/06/28 08:53:08  Dr.A
-- Added Target_supplier constant for simulation.
--
-- Revision 1.9  2003/07/15 15:06:48  Dr.J
-- Renamed FF by FLIPFLOP
--
-- Revision 1.8  2003/07/15 15:00:51  Dr.J
-- Commented the line constant CELL : integer := 0
--
-- Revision 1.7  2003/07/15 14:53:20  Dr.J
-- Updated to be synthesized by Synopsys
--
-- Revision 1.6  2003/07/15 13:52:59  Dr.J
-- Changed constant
--
-- Revision 1.5  2002/10/01 15:41:04  Dr.A
-- Added constants for clock gating.
--
-- Revision 1.4  2002/09/25 17:51:54  Dr.A
-- Added constants for synchronizer cell.
--
-- Revision 1.3  2002/04/23 12:06:57  Dr.J
-- Added IFX in TARGET_SUPPLIER_
--
-- Revision 1.2  2002/04/18 12:03:56  Dr.J
-- Added comment used by fb
--
-- Revision 1.1  2001/10/24 11:42:26  omilou
-- Initial revision
--
--
--
--
--------------------------------------------------------------------------------

library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package target_config_pkg is


  ------------------------------------------------------------------------------
  -- Constants for TARGET configuration
  ------------------------------------------------------------------------------
--  type TARGET_t is (FPGA, ASIC);
  subtype TARGET_t is integer; 
  constant FPGA : integer := 0;
  constant ASIC : integer := 1;
  constant TARGET_CT : TARGET_t := ASIC;

  ------------------------------------------------------------------------------
  -- Constants for TARGET_SUPPLIER configuration
  ------------------------------------------------------------------------------
--  type TARGET_SUPPLIER_t is (XILINX, ALTERA, TSMC, UMC, IFX);
  subtype TARGET_SUPPLIER_t is integer; 
  constant XILINX     : integer := 0;
  constant ALTERA     : integer := 1;
  constant TSMC       : integer := 2;
  constant UMC        : integer := 3;
  constant IFX        : integer := 4;
  constant SIMULATION : integer := 5;
  constant TARGET_SUPPLIER_CT  : TARGET_SUPPLIER_t := TSMC;

  ------------------------------------------------------------------------------
  -- Constants for synchronizer cells configuration
  ------------------------------------------------------------------------------
  -- type SYNC_t is (CELL, FF);
  subtype SYNC_t is integer; 
  constant CELL     : integer := 0;
  constant FLIPFLOP : integer := 1;
  constant SYNC_IMPLEMENTATION_CT  : SYNC_t := FLIPFLOP;

  ------------------------------------------------------------------------------
  -- Constants for clock gating configuration
  ------------------------------------------------------------------------------
--  type CLK_t is (CELL, VHDL);
  subtype CLK_t is integer; 
  -- constant CELL : integer := 0; -- already defined before.
  constant VHDL : integer := 1;
  constant CLK_IMPLEMENTATION_CT  : CLK_t := VHDL;

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------

 
end target_config_pkg;
