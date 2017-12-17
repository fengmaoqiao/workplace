
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: bup2modem_sync.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Synchronization block between the BuP and the 802.11 A or B
--               modem clock domains.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2modem_sync/vhdl/rtl/bup2modem_sync.vhd,v  
--  Log: bup2modem_sync.vhd,v  
-- Revision 1.2  2004/12/14 09:27:45  Dr.A
-- #BugId:821,606#
-- Added rxv_macaddr_match and txv_immstop to the BuP/Modem resync interface.
--
-- Revision 1.1  2004/05/18 12:57:50  Dr.A
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
entity bup2modem_sync is
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

end bup2modem_sync;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of bup2modem_sync is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal phy_txstartend_req_ff1_resync   : std_logic;
  signal phy_data_req_ff1_resync         : std_logic;
  signal phy_ccarst_req_ff1_resync       : std_logic;
  signal rxv_macaddr_match_ff1_resync    : std_logic;
  signal txv_immstop_ff1_resync          : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- Each input signal is synchronized twice with modem_clk.
  sync_p: process (reset_n, modem_clk)
  begin
    if reset_n = '0' then
      phy_txstartend_req_ff1_resync <= '0';
      phy_data_req_ff1_resync       <= '0';
      phy_ccarst_req_ff1_resync     <= '0';
      rxv_macaddr_match_ff1_resync  <= '1';
      txv_immstop_ff1_resync        <= '0';
      
      phy_txstartend_req_ff2_resync <= '0';
      phy_data_req_ff2_resync       <= '0';
      phy_ccarst_req_ff2_resync     <= '0';
      rxv_macaddr_match_ff2_resync  <= '1';
      txv_immstop_ff2_resync        <= '0';
      
    elsif modem_clk'event and modem_clk = '1' then
      phy_txstartend_req_ff1_resync <= phy_txstartend_req;
      phy_data_req_ff1_resync       <= phy_data_req;
      phy_ccarst_req_ff1_resync     <= phy_ccarst_req;
      rxv_macaddr_match_ff1_resync  <= rxv_macaddr_match;
      txv_immstop_ff1_resync        <= txv_immstop;

      phy_txstartend_req_ff2_resync <= phy_txstartend_req_ff1_resync;
      phy_data_req_ff2_resync       <= phy_data_req_ff1_resync;
      phy_ccarst_req_ff2_resync     <= phy_ccarst_req_ff1_resync;
      rxv_macaddr_match_ff2_resync  <= rxv_macaddr_match_ff1_resync;
      txv_immstop_ff2_resync        <= txv_immstop_ff1_resync;
      
    end if;
  end process sync_p;

end RTL;
