
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: peak_detect_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.8   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for peak_detect.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/peak_detect/vhdl/rtl/peak_detect_pkg.vhd,v  
--  Log: peak_detect_pkg.vhd,v  
-- Revision 1.8  2005/01/24 14:36:17  arisse
-- #BugId:983#
-- Cleaned of unused signals.
--
-- Revision 1.7  2003/09/18 08:36:41  Dr.A
-- Added synchronization output.
--
-- Revision 1.6  2002/11/28 09:36:24  Dr.A
-- Data in update.
--
-- Revision 1.5  2002/10/24 17:03:04  Dr.A
-- Added accumulator reset.
--
-- Revision 1.4  2002/10/17 08:21:30  Dr.A
-- Input data from an equalizer multiplier.
--
-- Revision 1.3  2002/07/31 06:49:28  Dr.A
-- Added signal quality, synchro_en and mod_type ports
--
-- Revision 1.2  2002/07/11 12:13:15  Dr.A
-- Removed packet_sync.
--
-- Revision 1.1  2002/03/05 15:10:04  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package peak_detect_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: peak_detect.vhd
----------------------
  component peak_detect
  generic (
    accu_size_g : integer := 20
  );
  port (
    -- clock and reset.
    reset_n        : in  std_logic; -- Global reset.
    clk            : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).
    --
    accu_resetn    : in  std_logic; -- Reset the accumulator.
    synchro_en     : in  std_logic; -- '1' to enable timing synchronization.
    mod_type       : in  std_logic; -- Modulation type (0 for DSSS , 1 for CCK).
    -- Square module of the correlator output data.
    abs_2_corr     : in  std_logic_vector(15 downto 0);
    --
    barker_sync    : out std_logic; -- Synchronization signal to Correlator.
    symbol_sync    : out std_logic -- Indicates the correlator peak value.
  );

  end component;



 
end peak_detect_pkg;
