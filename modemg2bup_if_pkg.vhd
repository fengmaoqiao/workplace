
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: modemg2bup_if_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for modemg2bup_if.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11g/modemg2bup_if/vhdl/rtl/modemg2bup_if_pkg.vhd,v  
--  Log: modemg2bup_if_pkg.vhd,v  
-- Revision 1.3  2005/01/11 10:33:47  Dr.A
-- #BugId:952#
-- New A/B select in RX mode
--
-- Revision 1.2  2004/12/14 09:30:22  Dr.A
-- #BugId:822,606#
-- Added rxv_macaddr_match and txv_immstop to the BuP/Modem resync interface.
--
-- Revision 1.1  2004/05/18 13:07:02  Dr.A
-- initial release
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
package modemg2bup_if_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDBuP2/modem2bup_sync/vhdl/rtl/modem2bup_sync.vhd
----------------------
  component modem2bup_sync
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n                        : in std_logic; -- Global reset.
    bup_clk                        : in std_logic; -- BuP clock.

    --------------------------------------
    -- Signals from Modem clock domain
    --------------------------------------
    phy_txstartend_conf            : in  std_logic;
    phy_rxstartend_ind             : in  std_logic;
    phy_data_conf                  : in  std_logic;
    phy_data_ind                   : in  std_logic;
    phy_cca_ind                    : in  std_logic;
    rxv_service_ind                : in  std_logic;
    phy_ccarst_conf                : in  std_logic;

    --------------------------------------
    -- Signals synchronized with bup_clk
    --------------------------------------
    phy_txstartend_conf_ff2_resync : out std_logic;
    phy_rxstartend_ind_ff2_resync  : out std_logic;
    phy_data_conf_ff2_resync       : out std_logic;
    phy_data_ind_ff2_resync        : out std_logic;
    phy_cca_ind_ff2_resync         : out std_logic;
    rxv_service_ind_ff2_resync     : out std_logic;
    phy_ccarst_conf_ff2_resync     : out std_logic
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDBuP2/bup2modem_sync/vhdl/rtl/bup2modem_sync.vhd
----------------------
  component bup2modem_sync
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n                         : in std_logic; -- Global reset.
    modem_clk                       : in std_logic; -- Modem clock.

    --------------------------------------
    -- Signals from BuP clock domain
    --------------------------------------
    phy_txstartend_req              : in  std_logic;
    phy_data_req                    : in  std_logic;
    phy_ccarst_req                  : in  std_logic; 
    rxv_macaddr_match               : in  std_logic; 
    txv_immstop                     : in  std_logic; 

    --------------------------------------
    -- Signals synchronized with modem_clk
    --------------------------------------
    phy_txstartend_req_ff2_resync   : out std_logic;
    phy_data_req_ff2_resync         : out std_logic;
    phy_ccarst_req_ff2_resync       : out std_logic;
    rxv_macaddr_match_ff2_resync    : out std_logic;
    txv_immstop_ff2_resync          : out std_logic 

  );

  end component;


----------------------
-- File: modemg2bup_if.vhd
----------------------
  component modemg2bup_if
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n                  : in  std_logic; -- Global reset.
    bup_clk                  : in  std_logic; -- BuP clock.
    modemb_clk               : in  std_logic; -- Modem B clock.
    modema_clk               : in  std_logic; -- Modem A clock.

    --------------------------------------
    -- Modem selection
    --------------------------------------
    -- BuP -> Modem selection: high when Modem A is transmitting.
    bup_txv_datarate3        : in  std_logic; -- From BuP clock domain
    -- Modem -> BuP selection: low when Modem A is receiving.
    select_rx_ab              : in  std_logic; -- From AGC clock domain.
    
    --====================================
    -- Modems to BuP interface
    --====================================
    --------------------------------------
    -- Signals from Modem A
    --------------------------------------
    a_phy_txstartend_conf    : in  std_logic;
    a_phy_rxstartend_ind     : in  std_logic;
    a_phy_data_conf          : in  std_logic;
    a_phy_data_ind           : in  std_logic;
    a_phy_cca_ind            : in  std_logic;
    a_rxv_service_ind        : in  std_logic;
    a_phy_ccarst_conf        : in  std_logic;
    -- Busses
    a_rxv_datarate           : in  std_logic_vector( 3 downto 0);
    a_rxv_length             : in  std_logic_vector(11 downto 0);
    a_rxv_rssi               : in  std_logic_vector( 7 downto 0);
    a_rxv_service            : in  std_logic_vector(15 downto 0);
    a_rxe_errorstat          : in  std_logic_vector( 1 downto 0);
    a_rxdata                 : in  std_logic_vector( 7 downto 0);

    --------------------------------------
    -- Signals from Modem B
    --------------------------------------
    b_phy_txstartend_conf    : in  std_logic;
    b_phy_rxstartend_ind     : in  std_logic;
    b_phy_data_conf          : in  std_logic;
    b_phy_data_ind           : in  std_logic;
    b_phy_cca_ind            : in  std_logic;
    -- Busses
    b_rxv_datarate           : in  std_logic_vector( 3 downto 0);
    b_rxv_length             : in  std_logic_vector(11 downto 0);
    b_rxv_rssi               : in  std_logic_vector( 7 downto 0);
    b_rxv_service            : in  std_logic_vector( 7 downto 0);
    b_rxe_errorstat          : in  std_logic_vector( 1 downto 0);
    b_rxdata                 : in  std_logic_vector( 7 downto 0);

    --------------------------------------
    -- Signals to BuP
    --------------------------------------
    bup_phy_txstartend_conf  : out std_logic;
    bup_phy_rxstartend_ind   : out std_logic;
    bup_phy_data_conf        : out std_logic;
    bup_phy_data_ind         : out std_logic;
    bup_phy_cca_ind          : out std_logic;
    bup_rxv_service_ind      : out std_logic;
    bup_a_phy_ccarst_conf    : out std_logic;
    -- Busses
    bup_rxv_datarate         : out std_logic_vector( 3 downto 0);
    bup_rxv_length           : out std_logic_vector(11 downto 0);
    bup_rxv_rssi             : out std_logic_vector( 7 downto 0);
    bup_rxv_service          : out std_logic_vector(15 downto 0);
    bup_rxe_errorstat        : out std_logic_vector( 1 downto 0);
    bup_rxdata               : out std_logic_vector( 7 downto 0);
    
    --====================================
    -- BuP to Modems interface
    --====================================
    --------------------------------------
    -- Signals from BuP
    --------------------------------------
    bup_phy_txstartend_req   : in  std_logic;
    bup_phy_data_req         : in  std_logic;
    bup_phy_ccarst_req       : in  std_logic;
    bup_rxv_macaddr_match    : in  std_logic; 
    bup_txv_immstop          : in  std_logic; 

    --------------------------------------
    -- Signals to Modem A
    --------------------------------------
    a_phy_txstartend_req     : out std_logic;
    a_phy_data_req           : out std_logic;
    a_phy_ccarst_req         : out std_logic;
    a_rxv_macaddr_match      : out std_logic; 
    a_txv_immstop            : out std_logic; 

    --------------------------------------
    -- Signals to Modem B
    --------------------------------------
    b_phy_txstartend_req     : out std_logic;
    b_phy_data_req           : out std_logic;
    b_phy_ccarst_req         : out std_logic;
    b_rxv_macaddr_match      : out std_logic; 
    b_txv_immstop            : out std_logic 
    
  );

  end component;



 
end modemg2bup_if_pkg;
