
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: tx_mux_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for tx_mux.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/tx_mux/vhdl/rtl/tx_mux_pkg.vhd,v  
--  Log: tx_mux_pkg.vhd,v  
-- Revision 1.4  2003/11/14 15:41:06  Dr.C
-- Updated.
--
-- Revision 1.3  2003/03/28 13:43:29  Dr.A
-- Renamed bit_rev_in ports.
--
-- Revision 1.2  2003/03/27 17:10:37  Dr.A
-- Adapted to new tx filter.
--
-- Revision 1.1  2003/03/13 15:09:50  Dr.A
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
package tx_mux_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: tx_mux.vhd
----------------------
  component tx_mux
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in  std_logic; -- Module clock
    reset_n             : in  std_logic; -- Asynchronous reset
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i            : in  std_logic; -- TX path enable.
    start_burst_i       : in  std_logic; -- Start of burst.
    end_preamble_i      : in  std_logic; -- End of preamble.
    marker_i            : in  std_logic; -- End of burst.
    tx_enddel_i         : in  std_logic_vector(7 downto 0); -- End of tx delay.
    --
    tx_start_end_conf_o : out std_logic;
    res_intfil_o        : out std_logic; -- Reset tx filter.
    data_valid_o        : out std_logic; -- Output data is valid.
    pream_ready_o       : out std_logic; -- tx_mux ready for preamble data.
    data_ready_o        : out std_logic; -- tx_mux ready for tx data.
    filter_sampleready_o: out std_logic; -- sample signal for tx filter.
    --------------------------------------
    -- Data
    --------------------------------------
    preamble_in_i       : in  std_logic_vector(9 downto 0); -- I preamble data.
    preamble_in_q       : in  std_logic_vector(9 downto 0); -- Q preamble data.
    data_in_i           : in  std_logic_vector(9 downto 0); -- I TX data.
    data_in_q           : in  std_logic_vector(9 downto 0); -- Q TX data.
    --
    out_i               : out std_logic_vector(9 downto 0); -- I data out.
    out_q               : out std_logic_vector(9 downto 0)  -- Q data out.

  );

  end component;



 
end tx_mux_pkg;
