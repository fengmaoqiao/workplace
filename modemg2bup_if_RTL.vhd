
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: modemg2bup_if.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Interface between the 802.11g modem and the BuP. It contains
--               synchronization blocks between the BuP and the Modems, along
--               with logic redirecting the BuP signals towards the selected
--               modem (A or B), and selecting which modem (A or B) outputs
--               are sent to the BuP.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11g/modemg2bup_if/vhdl/rtl/modemg2bup_if.vhd,v  
--  Log: modemg2bup_if.vhd,v  
-- Revision 1.7  2005/01/11 15:56:49  Dr.A
-- #BugId:952#
-- A modem selected when select_rx_ab = 0
--
-- Revision 1.6  2005/01/11 10:33:41  Dr.A
-- #BugId:952#
-- New A/B select in RX mode
--
-- Revision 1.5  2005/01/05 10:10:32  Dr.A
-- #BugId:798#
-- BuP signals towards A and B modems are gated with txv_datarate(3) before resynchronization.
--
-- Revision 1.4  2004/12/14 09:30:17  Dr.A
-- #BugId:822,606#
-- Added rxv_macaddr_match and txv_immstop to the BuP/Modem resync interface.
--
-- Revision 1.3  2004/08/03 09:01:19  sbizet
-- phy_cca_ind FF and process name changed
--
-- Revision 1.2  2004/07/12 13:20:14  sbizet
-- Delayed a_phy_cca_ind to avoid bup2_timers SM stucking when BuP gating not activated (CLKCNTL(5)=0)
--
-- Revision 1.1  2004/05/18 13:06:57  Dr.A
-- initial release
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
--library modem2bup_sync_rtl;
library work;
--library bup2modem_sync_rtl;
library work;

--library modemg2bup_if_rtl;
library work;
--use modemg2bup_if_rtl.modemg2bup_if_pkg.all;
use work.modemg2bup_if_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity modemg2bup_if is
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

end modemg2bup_if;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of modemg2bup_if is

  -- Naming convention for ports:
  --  * names of ports from/to Modem A begin with a_
  --  * names of ports from/to Modem B begin with b_
  --  * names of ports from/to BuP begin with bup_
  -- Naming convention for signals from *_sync blocks:
  --  * names of signals synchronized with bup_clk end with _bup_resync
  --  * names of signals synchronized with modema_clk end with _mdma_resync
  --  * names of signals synchronized with modemb_clk end with _mdmb_resync
  -- Naming convention for signals synchronized in this block:
  --  * Flip-flops used to avoid metastability are names *_ff[x]_resync,
  -- with x = 1, 2...

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  
  ------------------------------------------------------------------------------
  -- Signals from Modem A synchronized with bup_clk.
  ------------------------------------------------------------------------------
  signal a_txstartend_conf_bup_resync    : std_logic;
  signal a_rxstartend_ind_bup_resync     : std_logic;
  signal a_data_conf_bup_resync          : std_logic;
  signal a_data_ind_bup_resync           : std_logic;
  signal a_cca_ind_bup_resync            : std_logic;
  signal a_cca_ind_bup_resync_ff1        : std_logic;
  signal a_cca_ind_bup_resync_ff2        : std_logic;

  ------------------------------------------------------------------------------
  -- Signals from Modem B synchronized with bup_clk.
  ------------------------------------------------------------------------------
  signal b_txstartend_conf_bup_resync    : std_logic;
  signal b_rxstartend_ind_bup_resync     : std_logic;
  signal b_data_conf_bup_resync          : std_logic;
  signal b_data_ind_bup_resync           : std_logic;
  signal b_cca_ind_bup_resync            : std_logic;
  
  --------------------------------------
  -- Signals from BuP to be synchronized with modema_clk.
  --------------------------------------
  signal bup_a_txstartend_req            : std_logic;
  signal bup_a_data_req                  : std_logic;
  signal bup_a_ccarst_req                : std_logic;

  --------------------------------------
  -- Signals from BuP to be synchronized with modemb_clk.
  --------------------------------------
  signal bup_b_txstartend_req            : std_logic;
  signal bup_b_data_req                  : std_logic;
  signal bup_b_ccarst_req                : std_logic;

  --------------------------------------
  -- Misc. signals
  --------------------------------------
  signal logic0                              : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  logic0 <= '0';
  
  --============================================================================
  -- Modems to BuP interface
  --============================================================================
  
  -----------------------------------------
  -- Modem A to BuP synchronization
  -----------------------------------------
  -- The outputs of this block are the inputs, synchronized twice with the input
  -- clock.
  modem2bup_sync_a : modem2bup_sync
    port map (
      -- Clock and reset.
      reset_n                        => reset_n,
      bup_clk                        => bup_clk,
      -- Signals from Modem A clock domain
      phy_txstartend_conf            => a_phy_txstartend_conf,
      phy_rxstartend_ind             => a_phy_rxstartend_ind,
      phy_data_conf                  => a_phy_data_conf,
      phy_data_ind                   => a_phy_data_ind,
      phy_cca_ind                    => a_phy_cca_ind,
      rxv_service_ind                => a_rxv_service_ind,
      phy_ccarst_conf                => a_phy_ccarst_conf,
      -- Modem A signals synchronized with bup_clk
      phy_txstartend_conf_ff2_resync => a_txstartend_conf_bup_resync,
      phy_rxstartend_ind_ff2_resync  => a_rxstartend_ind_bup_resync,
      phy_data_conf_ff2_resync       => a_data_conf_bup_resync,
      phy_data_ind_ff2_resync        => a_data_ind_bup_resync,
      phy_cca_ind_ff2_resync         => a_cca_ind_bup_resync,
      -- These two signals are sent directly to an output port.
      rxv_service_ind_ff2_resync     => bup_rxv_service_ind, 
      phy_ccarst_conf_ff2_resync     => bup_a_phy_ccarst_conf
      );
  

  -----------------------------------------
  -- Modem B to BuP synchronization
  -----------------------------------------
  -- The outputs of this block are the inputs, synchronized twice with the input
  -- clock.
  modem2bup_sync_b : modem2bup_sync
    port map (
      -- Clock and reset.
      reset_n                        => reset_n,
      bup_clk                        => bup_clk,
      -- Signals from Modem B clock domain
      phy_txstartend_conf            => b_phy_txstartend_conf,
      phy_rxstartend_ind             => b_phy_rxstartend_ind,
      phy_data_conf                  => b_phy_data_conf,
      phy_data_ind                   => b_phy_data_ind,
      phy_cca_ind                    => b_phy_cca_ind,
      rxv_service_ind                => logic0, -- Not used in 802.11b
      phy_ccarst_conf                => logic0, -- Not used in 802.11b
      -- Modem B signals synchronized with bup_clk
      phy_txstartend_conf_ff2_resync => b_txstartend_conf_bup_resync,
      phy_rxstartend_ind_ff2_resync  => b_rxstartend_ind_bup_resync,
      phy_data_conf_ff2_resync       => b_data_conf_bup_resync,
      phy_data_ind_ff2_resync        => b_data_ind_bup_resync,
      phy_cca_ind_ff2_resync         => b_cca_ind_bup_resync,
      rxv_service_ind_ff2_resync     => open,   -- Not used in 802.11b
      phy_ccarst_conf_ff2_resync     => open    -- Not used in 802.11b
      );  
  

  -----------------------------------------
  -- Modems to BuP TX mux
  -----------------------------------------
  -- This process sends to the BuP TX signals from the A or B modem, depending
  -- on bup_txv_datarate3.
  connect_tx_p: process(a_data_conf_bup_resync, a_txstartend_conf_bup_resync,
                        b_data_conf_bup_resync, b_txstartend_conf_bup_resync,
                        bup_txv_datarate3)
  begin
    case bup_txv_datarate3 is
      when '1'     => -- Modem A is transmiting.
        bup_phy_txstartend_conf  <= a_txstartend_conf_bup_resync;
        bup_phy_data_conf        <= a_data_conf_bup_resync;
      when others  => -- Modem B is transmiting.
        bup_phy_txstartend_conf  <= b_txstartend_conf_bup_resync;
        bup_phy_data_conf        <= b_data_conf_bup_resync;
    end case;
  end process connect_tx_p;


  -----------------------------------------
  -- Modems to BuP RX mux
  -----------------------------------------

  -- This process sends to the BuP RX signals from the A or B modem, depending
  -- on select_rx_ab.
  connect_rxbus_p: process(a_data_ind_bup_resync, a_rxstartend_ind_bup_resync,
                           b_data_ind_bup_resync, b_rxstartend_ind_bup_resync,
                           select_rx_ab)
  begin
    case select_rx_ab is
      when '0'     => -- Modem A is receiving.
        bup_phy_rxstartend_ind   <= a_rxstartend_ind_bup_resync;
        bup_phy_data_ind         <= a_data_ind_bup_resync;
      when others  => -- Modem B is receiving.
        bup_phy_rxstartend_ind   <= b_rxstartend_ind_bup_resync;
        bup_phy_data_ind         <= b_data_ind_bup_resync;
    end case;
  end process connect_rxbus_p;
  
  
  -- Delay inserted to avoid glitch on phy_cca_ind when modem clocks non-gated(CLKCNTL(5) bit) 
  delay_cca_ind_p : process(bup_clk, reset_n)
  begin
    if (reset_n = '0') then
      a_cca_ind_bup_resync_ff1 <= '0';
      a_cca_ind_bup_resync_ff2 <= '0';
    elsif (bup_clk'event and bup_clk='1') then
      a_cca_ind_bup_resync_ff1 <= a_cca_ind_bup_resync;
      a_cca_ind_bup_resync_ff2 <= a_cca_ind_bup_resync_ff1;
    end if;
  end process delay_cca_ind_p;
  
  bup_phy_cca_ind <= a_cca_ind_bup_resync or a_cca_ind_bup_resync_ff2 or b_cca_ind_bup_resync;
  
  -- Busses are not synchronized before being sent to the BuP. The BuP is
  -- designed to sample the values from these busses only when they are
  -- validated by a synchronized signal.
  connect_rx_p: process(a_rxdata, a_rxe_errorstat, a_rxv_datarate,
                        a_rxv_length, a_rxv_rssi, a_rxv_service, b_rxdata,
                        b_rxe_errorstat, b_rxv_datarate, b_rxv_length,
                        b_rxv_rssi, b_rxv_service, select_rx_ab)
  begin
    case select_rx_ab is
      when '0'     => -- Modem A is receiving.
        bup_rxv_datarate     <= a_rxv_datarate;
        bup_rxv_length       <= a_rxv_length;
        bup_rxv_rssi         <= a_rxv_rssi;
        bup_rxv_service      <= a_rxv_service;
        bup_rxe_errorstat    <= a_rxe_errorstat;
        bup_rxdata           <= a_rxdata;
      when others  => -- Modem B is receiving.
        bup_rxv_datarate     <= b_rxv_datarate;
        bup_rxv_length       <= b_rxv_length;
        bup_rxv_rssi         <= b_rxv_rssi;
        bup_rxv_service      <= "00000000" & b_rxv_service;
        bup_rxe_errorstat    <= b_rxe_errorstat;
        bup_rxdata           <= b_rxdata;
    end case;
  end process connect_rx_p;


  --============================================================================
  -- BuP to Modems interface
  --============================================================================

  -- Gate signals from BuP with control from BuP before resynchronization.
  -- bup_txv_datarate3 from the BuP tx state machines is valid at tx_start_req
  -- and stays valid till the next packet.  
  modem_select_p: process (bup_clk, reset_n)
  begin
    if reset_n = '0' then
      bup_a_txstartend_req <= '0';
      bup_a_data_req       <= '0';
      bup_a_ccarst_req     <= '0';
      
      bup_b_txstartend_req <= '0';
      bup_b_data_req       <= '0';
      bup_b_ccarst_req     <= '0';
      
    elsif bup_clk'event and bup_clk = '1' then
      bup_a_txstartend_req <= bup_phy_txstartend_req and bup_txv_datarate3;
      bup_a_data_req       <= bup_phy_data_req and bup_txv_datarate3;
      bup_a_ccarst_req     <= bup_phy_ccarst_req and bup_txv_datarate3;
      
      bup_b_txstartend_req <= bup_phy_txstartend_req and not(bup_txv_datarate3);
      bup_b_data_req       <= bup_phy_data_req and not(bup_txv_datarate3);
      bup_b_ccarst_req     <= bup_phy_ccarst_req and not(bup_txv_datarate3);
      
    end if;
  end process modem_select_p;
  
  

  -----------------------------------------
  -- BuP to Modem A synchronization
  -----------------------------------------
  -- The outputs of this block are the inputs, synchronized twice with the input
  -- clock.
  bup2modem_sync_A : bup2modem_sync
    port map (
      -- Clock and reset.
      reset_n                        => reset_n,
      modem_clk                      => modema_clk,
      -- Signals from BuP clock domain
      phy_txstartend_req             => bup_a_txstartend_req,
      phy_data_req                   => bup_a_data_req,
      phy_ccarst_req                 => bup_a_ccarst_req,
      rxv_macaddr_match              => bup_rxv_macaddr_match,
      txv_immstop                    => bup_txv_immstop,
      -- BuP signals synchronized with modema_clk
      phy_txstartend_req_ff2_resync  => a_phy_txstartend_req,
      phy_data_req_ff2_resync        => a_phy_data_req,
      phy_ccarst_req_ff2_resync      => a_phy_ccarst_req,
      rxv_macaddr_match_ff2_resync   => a_rxv_macaddr_match,
      txv_immstop_ff2_resync         => a_txv_immstop
      );
        

  -----------------------------------------
  -- BuP to Modem B synchronization
  -----------------------------------------
  -- The outputs of this block are the inputs, synchronized twice with the input
  -- clock.
  bup2modem_sync_b : bup2modem_sync
    port map (
      -- Clock and reset.
      reset_n                        => reset_n,
      modem_clk                      => modemb_clk,
      -- Signals from BuP clock domain
      phy_txstartend_req             => bup_b_txstartend_req,
      phy_data_req                   => bup_b_data_req,
      phy_ccarst_req                 => bup_b_ccarst_req,
      rxv_macaddr_match              => bup_rxv_macaddr_match,
      txv_immstop                    => bup_txv_immstop,
      -- Signals synchronized with modemb_clk
      phy_txstartend_req_ff2_resync  => b_phy_txstartend_req,
      phy_data_req_ff2_resync        => b_phy_data_req,
      phy_ccarst_req_ff2_resync      => b_phy_ccarst_req,
      rxv_macaddr_match_ff2_resync   => b_rxv_macaddr_match,
      txv_immstop_ff2_resync         => b_txv_immstop
      );
  
end RTL;
