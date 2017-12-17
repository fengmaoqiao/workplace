--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 19173 $
--/ $Date: 2011-12-07 16:05:55 +0100 (Wed, 07 Dec 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : Resync block for CCA FSM & timer.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/cca_maxim/vhdl/rtl/cca_resync_maxim.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
 
library cca_maxim_rtl;
use cca_maxim_rtl.cca_maxim_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity cca_resync_maxim is
  port (
    ------------------------------------------------
    -- Clocks & Reset
    ------------------------------------------------
    clk                           : in std_logic; -- 60 MHz clock
    reset_n                       : in std_logic;
    
    ------------------------------------------------
    -- Register - 80-44 clk domain
    ------------------------------------------------
    sw_edcca_ack                  : in  std_logic;
    reg_agccca_disb               : in  std_logic; -- '1' to disable the CCA procedure
    reg_agcwaitdc                 : in  std_logic; -- '1' to keep AGC disable in RF bias setting state

    ------------------------------------------------
    -- Modem interface - 80 MHz & 44 MHz clk domain
    ------------------------------------------------
    -- Information from modems
    phy_rxstartend_ind            : in  std_logic; -- HIGH during modem RX processing
    sfd_found                     : in  std_logic; -- HIGH when SFD is found
    cp2_detected                  : in  std_logic; -- HIGH when synch is found
    phy_txonoff_req               : in  std_logic; -- Request radio TX mode
    
    ------------------------------------------------
    -- BuP - 80-44 clk domain
    ------------------------------------------------
    phy_ccarst_req                : in  std_logic; -- Pulse HIGH to reset the AGC/CCA
    -- Flag LOW till CCA is reset if MAC address does not match
    rxv_macaddr_match             : in  std_logic;
    phy_txstartend_req            : in  std_logic; -- HIGH when a TX is going to start
    fcs_ok_pulse                  : in  std_logic; -- Pulse HIGH when correct packet
    in_sifs_pulse                 : in  std_logic; -- Pulse HIGH when in SIFS period
    
    ------------------------------------------------
    -- Resync signals - 60 clk domain
    ------------------------------------------------
    sw_edcca_ack_ff2_resync       : out std_logic;
    reg_agccca_disb_ff2_resync    : out std_logic;
    reg_agcwaitdc_ff2_resync      : out std_logic;
    phy_rxstartend_ind_ff2_resync : out std_logic;
    sfd_found_ff2_resync          : out std_logic;
    cp2_detected_ff2_resync       : out std_logic;
    phy_txonoff_req_ff2_resync    : out std_logic;
    phy_ccarst_req_ff2_resync     : out std_logic;
    rxv_macaddr_match_ff2_resync  : out std_logic;
    phy_txstartend_req_ff2_resync : out std_logic;
    fcs_ok_pulse_ff2_resync       : out std_logic;
    in_sifs_pulse_ff2_resync      : out std_logic
    );

end cca_resync_maxim;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of cca_resync_maxim is

  ------------------------------------------------------------------------------
  -- Resync signals
  ------------------------------------------------------------------------------
  signal sw_edcca_ack_ff1_resync       : std_logic;
  signal reg_agccca_disb_ff1_resync    : std_logic;
  signal reg_agcwaitdc_ff1_resync      : std_logic;
  signal phy_rxstartend_ind_ff1_resync : std_logic;
  signal sfd_found_ff1_resync          : std_logic;
  signal cp2_detected_ff1_resync       : std_logic;
  signal phy_txonoff_req_ff1_resync    : std_logic;
  signal phy_ccarst_req_ff1_resync     : std_logic;
  signal rxv_macaddr_match_ff1_resync  : std_logic;
  signal phy_txstartend_req_ff1_resync : std_logic;
  signal fcs_ok_pulse_ff1_resync       : std_logic;
  signal in_sifs_pulse_ff1_resync      : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin


  ------------------------------------------
  -- Resync FFs
  ------------------------------------------

  -- CCA FSM Seq process
  cca_resync_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      sw_edcca_ack_ff1_resync       <= '0';
      sw_edcca_ack_ff2_resync       <= '0';
      reg_agccca_disb_ff1_resync    <= '1';
      reg_agccca_disb_ff2_resync    <= '1';
      reg_agcwaitdc_ff1_resync      <= '1';
      reg_agcwaitdc_ff2_resync      <= '1';
      phy_rxstartend_ind_ff1_resync <= '0';
      phy_rxstartend_ind_ff2_resync <= '0';
      sfd_found_ff1_resync          <= '0';
      sfd_found_ff2_resync          <= '0';
      cp2_detected_ff1_resync       <= '0';
      cp2_detected_ff2_resync       <= '0';
      phy_txonoff_req_ff1_resync    <= '0';
      phy_txonoff_req_ff2_resync    <= '0';
      phy_ccarst_req_ff1_resync     <= '0';
      phy_ccarst_req_ff2_resync     <= '0';
      rxv_macaddr_match_ff1_resync  <= '0';
      rxv_macaddr_match_ff2_resync  <= '0';
      phy_txstartend_req_ff1_resync <= '0';
      phy_txstartend_req_ff2_resync <= '0';
      fcs_ok_pulse_ff1_resync       <= '0';
      fcs_ok_pulse_ff2_resync       <= '0';
      in_sifs_pulse_ff1_resync      <= '0';
      in_sifs_pulse_ff2_resync      <= '0';
    elsif clk'event and clk = '1' then
      sw_edcca_ack_ff1_resync       <= sw_edcca_ack;
      sw_edcca_ack_ff2_resync       <= sw_edcca_ack_ff1_resync;
      reg_agccca_disb_ff1_resync    <= reg_agccca_disb;
      reg_agccca_disb_ff2_resync    <= reg_agccca_disb_ff1_resync;
      reg_agcwaitdc_ff1_resync      <= reg_agcwaitdc;
      reg_agcwaitdc_ff2_resync      <= reg_agcwaitdc_ff1_resync;
      phy_rxstartend_ind_ff1_resync <= phy_rxstartend_ind;
      phy_rxstartend_ind_ff2_resync <= phy_rxstartend_ind_ff1_resync;
      sfd_found_ff1_resync          <= sfd_found;
      sfd_found_ff2_resync          <= sfd_found_ff1_resync;
      cp2_detected_ff1_resync       <= cp2_detected;
      cp2_detected_ff2_resync       <= cp2_detected_ff1_resync;
      phy_txonoff_req_ff1_resync    <= phy_txonoff_req;
      phy_txonoff_req_ff2_resync    <= phy_txonoff_req_ff1_resync;
      phy_ccarst_req_ff1_resync     <= phy_ccarst_req;
      phy_ccarst_req_ff2_resync     <= phy_ccarst_req_ff1_resync;
      rxv_macaddr_match_ff1_resync  <= rxv_macaddr_match;
      rxv_macaddr_match_ff2_resync  <= rxv_macaddr_match_ff1_resync;
      phy_txstartend_req_ff1_resync <= phy_txstartend_req;
      phy_txstartend_req_ff2_resync <= phy_txstartend_req_ff1_resync;
      fcs_ok_pulse_ff1_resync       <= fcs_ok_pulse;
      fcs_ok_pulse_ff2_resync       <= fcs_ok_pulse_ff1_resync;
      in_sifs_pulse_ff1_resync      <= in_sifs_pulse;
      in_sifs_pulse_ff2_resync      <= in_sifs_pulse_ff1_resync;
    end if;
  end process cca_resync_p;
  

end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

