
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: dsss_demod_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for dsss_demod.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/dsss_demod/vhdl/rtl/dsss_demod_pkg.vhd,v  
--  Log: dsss_demod_pkg.vhd,v  
-- Revision 1.1  2002/03/11 12:54:07  Dr.A
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
package dsss_demod_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: dsss_demod.vhd
----------------------
  component dsss_demod
  generic (
    dsize_g : integer := 6
  );
  port (
    -- clock and reset.
    reset_n      : in  std_logic; -- Global reset.
    clk          : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).
    --
    symbol_sync  : in  std_logic; -- Symbol synchronization at 1 Mhz.
    x_i          : in  std_logic_vector(dsize_g-1 downto 0); -- dsss input.
    x_q          : in  std_logic_vector(dsize_g-1 downto 0); -- dsss input.
    -- 
    demod_i      : out std_logic_vector(dsize_g+3 downto 0); -- dsss output.
    demod_q      : out std_logic_vector(dsize_g+3 downto 0)  -- dsss output.
    
  );

  end component;



 
end dsss_demod_pkg;
