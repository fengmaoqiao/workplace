
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: rx_descr_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rx_descr.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_descr/vhdl/rtl/rx_descr_pkg.vhd,v  
--  Log: rx_descr_pkg.vhd,v  
-- Revision 1.2  2003/03/28 16:02:16  Dr.F
-- changed some port names.
--
-- Revision 1.1  2003/03/17 15:30:59  Dr.C
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
package rx_descr_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: rx_descr.vhd
----------------------
  component rx_descr
  port (
    clk                   : in  std_logic;
    reset_n               : in  std_logic;
    sync_reset_n          : in  std_logic;
    data_i                : in  std_logic;
    data_valid_i          : in  std_logic;
    data_ready_i          : in  std_logic;
    start_of_burst_i      : in  std_logic;
    
    data_ready_o          : out std_logic;
    data_o                : out std_logic;
    data_valid_o          : out std_logic;
    rxv_service_o         : out std_logic_vector(15 downto 0);
    rxv_service_ind_o     : out std_logic;
    start_of_burst_o      : out std_logic
  );

  end component;



 
end rx_descr_pkg;
