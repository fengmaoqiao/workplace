
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: tcombine_preamble_mux_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for tcombine_preamble_mux.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/tcombine_preamble_mux/vhdl/rtl/tcombine_preamble_mux_pkg.vhd,v  
--  Log: tcombine_preamble_mux_pkg.vhd,v  
-- Revision 1.1  2003/03/27 09:04:47  Dr.C
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
package tcombine_preamble_mux_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: tcombine_preamble_mux.vhd
----------------------
  component tcombine_preamble_mux
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    start_of_burst_i  : in  std_logic;
    start_of_symbol_i : in  std_logic;
    data_ready_i      : in  std_logic;
    i_i               : in  std_logic_vector(10 downto 0);
    q_i               : in  std_logic_vector(10 downto 0);
    data_valid_i      : in  std_logic;
    i_tcomb_i         : in  std_logic_vector(10 downto 0);
    q_tcomb_i         : in  std_logic_vector(10 downto 0);
    tcomb_valid_i     : in  std_logic;
    --
    start_of_burst_o  : out std_logic;
    start_of_symbol_o : out std_logic;
    data_ready_o      : out std_logic;
    tcomb_ready_o     : out std_logic;
    i_o               : out std_logic_vector(10 downto 0);
    q_o               : out std_logic_vector(10 downto 0);
    data_valid_o      : out std_logic
  );

  end component;



 
end tcombine_preamble_mux_pkg;
