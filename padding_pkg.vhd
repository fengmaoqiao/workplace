
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: padding_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for padding.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/padding/vhdl/rtl/padding_pkg.vhd,v  
--  Log: padding_pkg.vhd,v  
-- Revision 1.2  2004/12/14 10:54:57  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.1  2003/03/13 15:00:21  Dr.A
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
package padding_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: padding.vhd
----------------------
  component padding
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                : in std_logic;
    reset_n            : in std_logic;

    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i           : in  std_logic;
    data_ready_o       : out std_logic;
    data_ready_i       : in  std_logic;
    data_valid_i       : in  std_ulogic;
    tx_start_end_req_i : in  std_logic;
    prbs_sel_i         : in  std_logic_vector(1 downto 0);
    prbs_inv_i         : in  std_logic;
    prbs_init_i        : in  std_logic_vector(22 downto 0);
    --
    data_valid_o       : out std_logic;
    marker_o           : out std_logic;
    coding_rate_o          : out std_logic_vector(1 downto 0);  -- data coding rate
    qam_mode_o         : out std_logic_vector(1 downto 0);  -- qam mode
    start_burst_o      : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    txv_length_i       : in  std_logic_vector(11 downto 0);  -- Length of frame 1
    txv_rate_i         : in  std_logic_vector(3 downto 0);  -- Rate for frame 1
    txv_service_i      : in  std_logic_vector(15 downto 0);  -- Service field
    data_i             : in  std_logic_vector(7 downto 0);  -- Input data octet
    --
    data_o             : out std_logic


    );

  end component;



 
end padding_pkg;
