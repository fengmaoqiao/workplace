
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: symbol_sync_pkg.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for symbol_sync.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/symbol_sync/vhdl/rtl/symbol_sync_pkg.vhd,v  
--  Log: symbol_sync_pkg.vhd,v  
-- Revision 1.2  2002/07/01 15:50:48  Dr.J
-- changed chip_sync by symbol_sync
--
-- Revision 1.1  2002/03/05 15:20:10  Dr.A
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
package symbol_sync_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: chip_sync.vhd
----------------------
  component symbol_sync
  generic (
    dsize_g : integer := 10
  );
  port (
    -- clock and reset.
    reset_n      : in  std_logic; -- Global reset.
    clk          : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).
    --
    corr_i       : in  std_logic_vector(dsize_g-1 downto 0); -- correlated 
    corr_q       : in  std_logic_vector(dsize_g-1 downto 0); -- inputs.
    symbol_sync  : in  std_logic; -- Symbol synchronization signal.
    --
    data_i       : out std_logic_vector(dsize_g-1 downto 0); -- Sampled
    data_q       : out std_logic_vector(dsize_g-1 downto 0)  -- outputs.
  
  );

  end component;



 
end symbol_sync_pkg;
