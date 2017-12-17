
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: modema_tx_sm_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for modema_tx_sm.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/modema_tx_sm/vhdl/rtl/modema_tx_sm_pkg.vhd,v  
--  Log: modema_tx_sm_pkg.vhd,v  
-- Revision 1.5  2004/12/14 10:53:13  Dr.C
-- #BugId:595#
-- Added txv_immstop port and updated state control for BT coexistence.
--
-- Revision 1.4  2004/05/18 12:29:32  Dr.A
-- Removed some registers. no more used because of the BuP-Modem synchro block.
--
-- Revision 1.3  2003/04/01 16:04:33  Dr.F
-- added sync_reset_n_o port.
--
-- Revision 1.2  2003/03/28 14:14:03  Dr.A
-- Updated ports names.
--
-- Revision 1.1  2003/03/13 15:10:24  Dr.A
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
package modema_tx_sm_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: modema_tx_sm.vhd
----------------------
  component modema_tx_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic; -- Module clock
    reset_n              : in  std_logic; -- asynchronous reset

    --------------------------------------
    -- Global controls
    --------------------------------------
    enable_o             : out std_logic; -- Enable for TX blocks.
    tx_active_o          : out std_logic; -- High during transmission.
    sync_reset_n_o       : out std_logic; -- synchronous reset

    --------------------------------------
    -- BuP interface.
    --------------------------------------
    txv_txpwr_level_i    : in  std_logic_vector( 2 downto 0); -- TX Power Level.
    txv_rate_i           : in  std_logic_vector( 3 downto 0); -- Rate.
    txv_length_i         : in  std_logic_vector(11 downto 0); -- Length.
    txv_service_i        : in  std_logic_vector(15 downto 0); -- Service field.
    phy_txstartend_req_i : in  std_logic;
    txv_immstop_i        : in  std_logic;                     -- Stop Tx
    --
    phy_txstartend_conf_o: out std_logic;

    --------------------------------------
    -- Interface with mac_interface block
    --------------------------------------
    int_start_end_conf_i : in  std_logic;
    --
    int_start_end_req_o  : out std_logic;
    int_rate_o           : out std_logic_vector( 3 downto 0); -- Rate.
    int_length_o         : out std_logic_vector(11 downto 0); -- Length.
    int_service_o        : out std_logic_vector(15 downto 0); -- Service field.
    
    --------------------------------------
    -- Interface with RF control FSM
    --------------------------------------
    dac_powerdown_dyn_i  : in  std_logic;
    a_txonoff_conf_i     : in  std_logic;
    --
    dac_on_o             : out std_logic;
    a_txpga_o            : out std_logic_vector(2 downto 0);
    a_txonoff_req_o      : out std_logic
  );

  end component;



 
end modema_tx_sm_pkg;
