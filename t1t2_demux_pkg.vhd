
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: t1t2_demux_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for t1t2_demux.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/t1t2_demux/vhdl/rtl/t1t2_demux_pkg.vhd,v  
--  Log: t1t2_demux_pkg.vhd,v  
-- Revision 1.2  2003/03/28 13:11:22  Dr.B
-- removed call to modem802_11a1_pkg
--
-- Revision 1.1  2003/03/27 17:18:16  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package t1t2_demux_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: t1t2_demux.vhd
----------------------
  component t1t2_demux
  generic (
    data_size_g : integer := 11);       -- size of data (i_i/q_i/i_o/q_i)
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                        : in  std_logic;  -- clock (80 MHz)
    reset_n                    : in  std_logic;  -- asynchronous negative reset
    sync_reset_n               : in  std_logic;  -- synchronous negative reset
    --------------------------------------
    -- Controls
    --------------------------------------
    i_i                        : in  std_logic_vector(data_size_g-1 downto 0);
    q_i                        : in  std_logic_vector(data_size_g-1 downto 0);
    data_valid_i               : in  std_logic;  -- input data valid
    start_of_burst_i           : in  std_logic;  -- next valid data input belongs to the next burst
    start_of_symbol_i          : in  std_logic;  -- next valid data input belongs to the next symbol
    ffe_data_ready_i           : in  std_logic;  -- 0 do not output more data (from ffe)  
    tcombmux_data_ready_i      : in  std_logic;  -- 0 do not output more data (from tcombmux)
    --
    data_ready_o               : out std_logic;  -- do not input more data    
    ffe_start_of_burst_o       : out std_logic;  -- next valid data output belongs to the next burst (for ffe)   
    ffe_start_of_symbol_o      : out std_logic;  -- next valid data output belongs to the next symbol (for ffe)   
    ffe_data_valid_o           : out std_logic;  -- output data valid for the ffe   
    tcombmux_data_valid_o      : out std_logic;  -- output data valid for the tcombmux   
    tcombmux_start_of_symbol_o : out std_logic;  -- next valid data output belongs to the next symbol (for tcomb mux)
    i_o                        : out std_logic_vector(10 downto 0);
    q_o                        : out std_logic_vector(10 downto 0)


  );

  end component;



 
end t1t2_demux_pkg;
