
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: symbol_sync.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Sampling of Barker correlator peak for chip synchronization.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/symbol_sync/vhdl/rtl/symbol_sync.vhd,v  
--  Log: symbol_sync.vhd,v  
-- Revision 1.2  2002/07/01 15:50:33  Dr.J
-- changed chip_sync by symbol_sync
--
-- Revision 1.1  2002/03/05 15:20:08  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_unsigned.all; 
 
--library symbol_sync_rtl;
library work;
--use symbol_sync_rtl.symbol_sync_pkg.all;
use work.symbol_sync_pkg.all;



--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity symbol_sync is
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

end symbol_sync;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of symbol_sync is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  --------------------------------------------
  -- Sample process.
  --------------------------------------------
  -- This process samples the Barker correlator peak output when the symbol_sync
  -- signal is received.
  sampl_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      data_i <= (others => '0');
      data_q <= (others => '0');
    elsif clk'event and clk = '1' then
      if symbol_sync = '1' then
        data_i <= corr_i;
        data_q <= corr_q;
      end if;
    end if;
  end process sampl_pr;

end RTL;
