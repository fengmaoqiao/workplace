
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: rx_mac_if_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rx_mac_if.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/rx_mac_if/vhdl/rtl/rx_mac_if_pkg.vhd,v  
--  Log: rx_mac_if_pkg.vhd,v  
-- Revision 1.2  2005/03/09 12:03:53  Dr.C
-- #BugId:1123#
-- Added packet_end_i input to avoid data taken into account 2 times by the bup at the end of the reception.
--
-- Revision 1.1  2003/03/14 14:17:19  Dr.C
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
package rx_mac_if_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: rx_mac_if.vhd
----------------------
  component rx_mac_if
  port(
    -- asynchronous reset
    reset_n               : in  std_logic; 
    -- synchronous reset
    sync_reset_n          : in  std_logic; 
    -- clock
    clk                   : in  std_logic; 

    -- data coming from the rx path
    data_i                : in  std_logic;
    -- data valid indication. When 1, data_i is valid.
    data_valid_i          : in  std_logic;
    -- start of burst (packet) when 1.
    start_of_burst_i      : in  std_logic;
    
    data_ready_o          : out std_logic;
    -- end of packet
    packet_end_i          : in  std_logic;
    -- BuP interface
    rx_data_o             : out std_logic_vector(7 downto 0);
    rx_data_ind_o         : out std_logic
  );
  end component;



 
end rx_mac_if_pkg;
