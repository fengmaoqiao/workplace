
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: modem2bup_sync.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Synchronization block between the 802.11 A or B modem and the
--               BuP clock domains.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/modem2bup_sync/vhdl/rtl/modem2bup_sync.vhd,v  
--  Log: modem2bup_sync.vhd,v  
-- Revision 1.1  2004/05/18 13:27:18  Dr.A
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
-- Entity
--------------------------------------------------------------------------------
entity modem2bup_sync is
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

end modem2bup_sync;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of modem2bup_sync is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal phy_txstartend_conf_ff1_resync : std_logic;
  signal phy_rxstartend_ind_ff1_resync  : std_logic;
  signal phy_data_conf_ff1_resync       : std_logic;
  signal phy_data_ind_ff1_resync        : std_logic;
  signal phy_cca_ind_ff1_resync         : std_logic;
  signal rxv_service_ind_ff1_resync     : std_logic;
  signal phy_ccarst_conf_ff1_resync     : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- Each input signal is synchronized twice with bup_clk.
  sync_p: process (reset_n, bup_clk)
  begin
    if reset_n = '0' then

      phy_txstartend_conf_ff1_resync  <= '0';
      phy_rxstartend_ind_ff1_resync   <= '0';
      phy_data_conf_ff1_resync        <= '0';
      phy_data_ind_ff1_resync         <= '0';
      phy_cca_ind_ff1_resync          <= '0';
      rxv_service_ind_ff1_resync      <= '0';
      phy_ccarst_conf_ff1_resync      <= '0';

      phy_txstartend_conf_ff2_resync  <= '0';
      phy_rxstartend_ind_ff2_resync   <= '0';
      phy_data_conf_ff2_resync        <= '0';
      phy_data_ind_ff2_resync         <= '0';
      phy_cca_ind_ff2_resync          <= '0';
      rxv_service_ind_ff2_resync      <= '0';
      phy_ccarst_conf_ff2_resync      <= '0';

    elsif bup_clk'event and bup_clk = '1' then

      phy_txstartend_conf_ff1_resync  <= phy_txstartend_conf;
      phy_rxstartend_ind_ff1_resync   <= phy_rxstartend_ind;
      phy_data_conf_ff1_resync        <= phy_data_conf;
      phy_data_ind_ff1_resync         <= phy_data_ind;
      phy_cca_ind_ff1_resync          <= phy_cca_ind;
      rxv_service_ind_ff1_resync      <= rxv_service_ind;
      phy_ccarst_conf_ff1_resync      <= phy_ccarst_conf;

      phy_txstartend_conf_ff2_resync  <= phy_txstartend_conf_ff1_resync;
      phy_rxstartend_ind_ff2_resync   <= phy_rxstartend_ind_ff1_resync;
      phy_data_conf_ff2_resync        <= phy_data_conf_ff1_resync;
      phy_data_ind_ff2_resync         <= phy_data_ind_ff1_resync;
      phy_cca_ind_ff2_resync          <= phy_cca_ind_ff1_resync;
      rxv_service_ind_ff2_resync      <= rxv_service_ind_ff1_resync;
      phy_ccarst_conf_ff2_resync      <= phy_ccarst_conf_ff1_resync;
      
    end if;
  end process sync_p;
  
end RTL;
