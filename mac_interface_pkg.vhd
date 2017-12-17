
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: mac_interface_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for mac_interface.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/mac_interface/vhdl/rtl/mac_interface_pkg.vhd,v  
--  Log: mac_interface_pkg.vhd,v  
-- Revision 1.1  2003/03/13 14:54:10  Dr.A
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
package mac_interface_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: mac_interface.vhd
----------------------
  component mac_interface
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n             : in  std_logic;
    clk                 : in  std_logic;

    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i            : in  std_logic;
    tx_start_end_req_i  : in  std_logic;
    tx_start_end_conf_i : in  std_logic;
    data_ready_i        : in  std_logic;
    data_valid_o        : out std_logic;
    tx_data_req_i       : in  std_logic;
    tx_data_conf_o      : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    tx_data_i           : in  std_logic_vector(7 downto 0);
    data_o              : out std_logic_vector(7 downto 0)

    
  );

  end component;



 
end mac_interface_pkg;
