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
--/ Description      :  Top of the MAXIM CCA generation block. 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/cca_maxim/vhdl/rtl/cca_maxim.vhd $
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

-- prefix *reg_* is used for inputs from SW controlled registers

entity cca_maxim is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                : in std_logic; -- 60 MHz clock
    reset_n            : in std_logic;
    --
    en_20m             : out std_logic;
    
    --------------------------------------
    -- Registers
    --------------------------------------
    -- Enable signals
    reg_agccca_disb    : in  std_logic; -- '1' to disable the CCA procedure
    reg_ccarfoffen     : in  std_logic; -- '1' to enable RFOFF on CCA request
    reg_forceagcrst    : in  std_logic; -- '1' to enable AGC reset after packet reception
    reg_act            : in  std_logic; -- '1' to inform ACT procedure
    reg_modeabg        : in  std_logic_vector(1 downto 0); -- select .11a/b/g mode
    reg_agcwaitdc      : in  std_logic; -- '1' to keep AGC disable in RF bias setting state
    reg_ccarampen      : in  std_logic; -- '1' to enable CCA busy indication on ramp UP/DOWN
    reg_ccacoren       : in  std_logic; -- '1' to enable CCA busy indication on correlation
    reg_ccastatbdgen   : in  std_logic_vector(4 downto 0); -- '1' to enable CCA during some states
    reg_sensingmode    : in  std_logic_vector(2 downto 0); -- CCA mode control

    -- Delay values
    -- Delay between end of air activity and AGC reset
    reg_rampdown       : in  std_logic_vector(2 downto 0); -- us
    -- RF bias setting time
    reg_biasdel        : in  std_logic_vector(2 downto 0); -- us
    -- OFDM end of packet
    reg_ofdmrxdel      : in  std_logic_vector(3 downto 0); -- us
    -- DSSS-CCK end of packet
    reg_dcckrxdel      : in  std_logic_vector(3 downto 0); -- us
    -- Max length on energy detect
    reg_ccamaxlength   : in  std_logic_vector(7 downto 0); -- us

    -- Threshold
    -- AGC OFF
    reg_thragcoff      : in  std_logic_vector(8 downto 0);
    
    -- SW ack for energy detect channel busy indication
    sw_edcca_ack       : in  std_logic;
    
    --------------------------------------
    -- AGC Interface
    --------------------------------------
    agc_lock           : in  std_logic; -- CCA demodulation phase
    agc_rise           : in  std_logic; -- AGC detection
    agc_fall           : in  std_logic; -- AGC signal disappearance
    energy_thr         : in  std_logic; -- energy above threshold
    energy_ud          : in  std_logic; -- energy ramp UP/DOWN
    dsss_cor_thr       : in  std_logic; -- DSSS correlation significant
    --
    pantpack_dbm       : in  std_logic_vector(8 downto 0); -- Power measure
    -- CS flags
    cs_a_high          : in  std_logic; -- OFDM high confidence
    cs_a_low           : in  std_logic; -- OFDM low confidence
    cs_b_high          : in  std_logic; -- DSSS high confidence
    cs_b_low           : in  std_logic; -- DSSS low confidence
    cs_flag_nb         : in  std_logic_vector(1 downto 0); -- Flags number
    cs_flag_valid      : in  std_logic; -- Flags valid
    --
    agc_sync_reset     : out std_logic; -- Synchronous reset to the AGC block
    --
    in_packet_mode_en  : out std_logic; -- Packet state
    agc_firstpkt_recep : out std_logic; -- first pkt after AGC enable for SW antenna selection
    --
    fcs_ok_2agc        : out std_logic; -- FCS ok status
    in_sifs_2agc       : out std_logic; -- SIFS status
    
    --------------------------------------
    -- Modem interface
    --------------------------------------
    -- Specific controls
    ofdm_sm_rst_n      : out std_logic; -- Pulse active low to reset OFDM SM
    -- Information from modems
    phy_rxstartend_ind : in  std_logic; -- HIGH during modem RX processing
    sfd_found          : in  std_logic; -- HIGH when SFD is found
    cp2_detected       : in  std_logic; -- HIGH when synch is found
    phy_txonoff_req    : in  std_logic; -- Request radio TX mode
    -- PSDU length in us from Modem DSSS-CCK
    b_psdu_duration    : in  std_logic_vector(15 downto 0); -- us
    -- Rx length & datarate from Modem OFDM
    rxv_length         : in  std_logic_vector(11 downto 0); -- rx psdu length  
    rxv_datarate       : in  std_logic_vector( 3 downto 0); -- PSDU rec. rate
    -- Modems enable
    ofdm_rx_en         : out std_logic;
    dcck_rx_en         : out std_logic;
    -- Modem DSSS-CCK control
    agcproc_end        : out std_logic;
    correl_rst_n       : out std_logic;
    
    --------------------------------------
    -- Radio Controller
    --------------------------------------
    -- Request to switch on (rising edge) or off (falling edge) the RF RX mode
    phy_rxonoff_req    : out std_logic;
    phy_rxbusy         : out std_logic; -- Indication of air activity
    -- Request to switch on (rising edge) or off (falling edge) the RF TX mode
    phy_txonoff_req_rc : out std_logic;
    --
    phy_txonoff_conf   : in  std_logic; -- Status of the radio TX mode
    phy_rxonoff_stat   : in  std_logic; -- Status of the radio RX mode

    --------------------------------------
    -- BuP
    --------------------------------------
    phy_ccarst_req     : in  std_logic; -- Pulse HIGH to reset CCA
    -- Flag LOW till CCA is reset if MAC address does not match
    rxv_macaddr_match  : in  std_logic;
    phy_txstartend_req : in  std_logic; -- HIGH when a TX is going to start
    fcs_ok_pulse       : in  std_logic; -- Pulse HIGH when correct packet
    in_sifs_pulse      : in  std_logic; -- Pulse HIGH when in SIFS
    --
    phy_ccarst_conf    : out std_logic; -- reset CCA confirmation
    cca_rxsifs_en      : out std_logic; -- SIFS indication

    --------------------------------------
    -- CCA
    --------------------------------------
    wlanrxind          : out std_logic;
    phy_cca_ind        : out std_logic;
    cca_diag           : out std_logic_vector(15 downto 0);
    
    --------------------------------------
    -- Interrupt
    --------------------------------------
    cca_irq            : out std_logic
    );

end cca_maxim;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of cca_maxim is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal load_timer                     : std_logic; -- Pulse HIGH to reload the CCA timer
  signal enable_timer                   : std_logic; -- HIGH to enable timer downcount
  signal cca_dec_state                  : std_logic_vector(4 downto 0); -- CCA state
  signal timeout_it                     : std_logic; -- Pulse when CCA timer reaches zero.
  signal phy_cca_on_cs                  : std_logic; -- CCA on carrier sense
  -- signals for diags
  signal cca_fsm_diag                   : std_logic_vector(3 downto 0);
  signal agc_sync_reset_i               : std_logic;
  signal ofdm_rx_en_i                   : std_logic;
  signal dcck_rx_en_i                   : std_logic;
  signal phy_cca_ind_i                  : std_logic;
  signal phy_rxbusy_i                   : std_logic;
  -- resync 
  signal phy_rxstartend_ind_ff2_resync  : std_logic;
  signal sfd_found_ff2_resync           : std_logic;
  signal cp2_detected_ff2_resync        : std_logic;
  signal phy_txonoff_req_ff2_resync     : std_logic;
  signal phy_ccarst_req_ff2_resync      : std_logic;
  signal rxv_macaddr_match_ff2_resync   : std_logic;
  signal phy_txstartend_req_ff2_resync  : std_logic;
  signal sw_edcca_ack_ff2_resync        : std_logic;
  signal reg_agccca_disb_ff2_resync     : std_logic;
  signal reg_agcwaitdc_ff2_resync       : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin


  ----------------------------------------------------------
  -- Diagnostic
  ----------------------------------------------------------
  cca_diag <= cca_dec_state      & -- 15:11
              phy_cca_ind_i      & -- 10
              agc_sync_reset_i   & -- 9
              load_timer         & -- 8
              timeout_it         & -- 7
              ofdm_rx_en_i       & -- 6
              dcck_rx_en_i       & -- 5
              phy_rxbusy_i       & -- 4
              cca_fsm_diag(3 downto 0);
  
  
  ----------------------------------------------------------
  -- Outputs
  ----------------------------------------------------------
  agc_sync_reset     <= agc_sync_reset_i;
  ofdm_rx_en         <= ofdm_rx_en_i;
  dcck_rx_en         <= dcck_rx_en_i;
  phy_cca_ind        <= phy_cca_ind_i;
  phy_rxbusy         <= phy_rxbusy_i;
  phy_txonoff_req_rc <= phy_txonoff_req_ff2_resync;
  
  ----------------------------------------------------------
  -- Resync
  ----------------------------------------------------------
  cca_resync_maxim_1 : cca_resync_maxim
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk                           => clk,                 --(in) from outside 
      reset_n                       => reset_n,             --(in) from outside 
      --------------------------------------                
      -- Registers                                          
      --------------------------------------                
      sw_edcca_ack                  => sw_edcca_ack,        --(in) from outside  :SW ack for energy detect channel busy indication
      reg_agccca_disb               => reg_agccca_disb,     --(in) from outside  :'1' to disable the CCA procedure
      reg_agcwaitdc                 => reg_agcwaitdc,       --(in) from outside  :'1' to keep AGC disable in RF bias setting state
      --------------------------------------
      -- Modem interface
      --------------------------------------
      phy_rxstartend_ind            => phy_rxstartend_ind,  --(in) from outside  :HIGH during modem RX processing
      sfd_found                     => sfd_found,           --(in) from outside  :HIGH when SFD is found
      cp2_detected                  => cp2_detected,        --(in) from outside  :HIGH when synch is found
      phy_txonoff_req               => phy_txonoff_req,     --(in) from outside  :Request radio TX mode
      --------------------------------------
      -- BuP
      --------------------------------------
      phy_ccarst_req                => phy_ccarst_req,      --(in) from outside  :Pulse HIGH to reset CCA Flag LOW till CCA is reset if MAC address does not match
      rxv_macaddr_match             => rxv_macaddr_match,   --(in) from outside
      phy_txstartend_req            => phy_txstartend_req,  --(in) from outside  :HIGH when a TX is going to start
      fcs_ok_pulse                  => fcs_ok_pulse,        --(in) from outside  :Pulse HIGH when correct packet
      in_sifs_pulse                 => in_sifs_pulse,       --(in) from outside  :Pulse HIGH when in SIFS
      --------------------------------------
      -- Resync signals - 60 MHz clk domain
      --------------------------------------
      sw_edcca_ack_ff2_resync       => sw_edcca_ack_ff2_resync,       --(out) to  cca_gen_maxim_1
      reg_agccca_disb_ff2_resync    => reg_agccca_disb_ff2_resync,    --(out) to  cca_fsm_maxim_1 and cca_gen_maxim_1
      reg_agcwaitdc_ff2_resync      => reg_agcwaitdc_ff2_resync,      --(out) to  cca_fsm_maxim_1
      phy_rxstartend_ind_ff2_resync => phy_rxstartend_ind_ff2_resync, --(out) to  cca_fsm_maxim_1 and cca_timers_maxim_1
      sfd_found_ff2_resync          => sfd_found_ff2_resync,          --(out) to  cca_fsm_maxim_1
      cp2_detected_ff2_resync       => cp2_detected_ff2_resync,       --(out) to  cca_fsm_maxim_1  
      phy_txonoff_req_ff2_resync    => phy_txonoff_req_ff2_resync,    --(out) to  cca_fsm_maxim_1 and assign => outside
      phy_ccarst_req_ff2_resync     => phy_ccarst_req_ff2_resync,     --(out) to  cca_fsm_maxim_1   
      rxv_macaddr_match_ff2_resync  => rxv_macaddr_match_ff2_resync,  --(out) to  cca_fsm_maxim_1    
      phy_txstartend_req_ff2_resync => phy_txstartend_req_ff2_resync, --(out) to  cca_fsm_maxim_1   
      fcs_ok_pulse_ff2_resync       => fcs_ok_2agc,                   --(out) to  outside  :FCS ok status
      in_sifs_pulse_ff2_resync      => in_sifs_2agc                   --(out) to  outside  :SIFS status
      );


  ----------------------------------------------------------
  -- CCA generator state machines
  ----------------------------------------------------------
  cca_fsm_maxim_1 : cca_fsm_maxim
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk                   => clk,             --(in) from outside 
      reset_n               => reset_n,         --(in) from outside 
      --------------------------------------
      -- Registers
      --------------------------------------
      reg_agccca_disb       => reg_agccca_disb_ff2_resync, --(in) from cca_resync_maxim_1 :'1' to disable the CCA procedure
      reg_ccarfoffen        => reg_ccarfoffen,             --(in) from outside            :'1' to enable RFOFF on CCA request
      reg_forceagcrst       => reg_forceagcrst,            --(in) from outside            :'1' to enable AGC reset after packet reception
      reg_act               => reg_act,                    --(in) from outside            :'1' to inform ACT procedure
      reg_modeabg           => reg_modeabg,                --(in) from outside            :select .11a/b/g mode
      reg_agcwaitdc         => reg_agcwaitdc_ff2_resync,   --(in) from cca_resync_maxim_1 :'1' to keep AGC disable in RF bias setting state
      reg_ccastatbdgen      => reg_ccastatbdgen,           --(in) from outside            :'1' to enable phy_cca_on_bd during
      reg_thragcoff         => reg_thragcoff,              --(in) from outside            :AGC OFF threshold
      --------------------------------------
      -- AGC interface
      --------------------------------------
      agc_lock              => agc_lock,                   --(in) from outside            :CCA demodulation phase
      agc_rise              => agc_rise,                   --(in) from outside            :AGC detection
      agc_fall              => agc_fall,                   --(in) from outside            :AGC signal disappearance
      --                                                  
      pantpack_dbm          => pantpack_dbm,               --(in) from outside            :Power measure
      -- CS flags                                          
      cs_a_high             => cs_a_high,                  --(in) from outside            :OFDM high confidence
      cs_a_low              => cs_a_low ,                  --(in) from outside            :OFDM low confidence
      cs_b_high             => cs_b_high,                  --(in) from outside            :DSSS high confidence
      cs_b_low              => cs_b_low,                   --(in) from outside            :DSSS low confidence
      cs_flag_nb            => cs_flag_nb,                 --(in) from outside            :Flags number
      cs_flag_valid         => cs_flag_valid,              --(in) from outside            :Flags valid
      --                                                  
      agc_sync_reset        => agc_sync_reset_i,           --(out) to  assign => outside  :Synchronous reset to the AGC block
      in_packet_mode_en     => in_packet_mode_en,          --(out) to  outside            :Packet state
      agc_firstpkt_recep    => agc_firstpkt_recep,         --(out) to  outside            :first pkt after AGC enable for SW antenna selection
      --------------------------------------
      -- Modem interface
      --------------------------------------
      phy_rxstartend_ind    => phy_rxstartend_ind_ff2_resync, --(in) from cca_resync_maxim_1  :HIGH during modem RX processing
      sfd_found             => sfd_found_ff2_resync,          --(in) from cca_resync_maxim_1  :HIGH when SFD is found
      cp2_detected          => cp2_detected_ff2_resync,       --(in) from cca_resync_maxim_1  :HIGH when synch is found
      phy_txonoff_req       => phy_txonoff_req_ff2_resync,    --(in) from cca_resync_maxim_1  :Request radio TX mode
      -- Modems enable
      ofdm_rx_en            => ofdm_rx_en_i,                  --(out) to  cca_timers_maxim_1 and assign => outside => ... => modem802_11g_core_1
      dcck_rx_en            => dcck_rx_en_i,                  --(out) to  cca_timers_maxim_1 and assign => outside => ... => modem802_11g_core_1  
      -- Specific controls                                    
      ofdm_sm_rst_n         => ofdm_sm_rst_n,                 --(out) to  outside => ... => modem802_11g_core_1
      agcproc_end           => agcproc_end,                   --(out) to  outside => ... => modem802_11g_core_1 
      correl_rst_n          => correl_rst_n,                  --(out) to  outside => ... => modem802_11g_core_1 
      --------------------------------------
      -- Radio Controller
      --------------------------------------
      phy_rxonoff_req       => phy_rxonoff_req,               --(out) to  outside  => ... => radioctrl_maxair
      phy_rxbusy            => phy_rxbusy_i,                  --(out) to  assign => outside  => ... => radioctrl_maxair
      --
      phy_txonoff_conf      => phy_txonoff_conf,              --(in) from outside             :Status of the radio TX mode
      phy_rxonoff_stat      => phy_rxonoff_stat,              --(in) from outside             :Status of the radio RX mode
      --------------------------------------
      -- BuP
      --------------------------------------
      phy_ccarst_req        => phy_ccarst_req_ff2_resync,     --(in) from cca_resync_maxim_1  :Pulse HIGH to reset CCA
      rxv_macaddr_match     => rxv_macaddr_match_ff2_resync,  --(in) from cca_resync_maxim_1  
      phy_txstartend_req    => phy_txstartend_req_ff2_resync, --(in) from cca_resync_maxim_1  :HIGH when a TX is going to start
      --
      phy_ccarst_conf       => phy_ccarst_conf,               --(out) to  outside             :reset CCA confirmation
      cca_rxsifs_en         => cca_rxsifs_en,                 --(out) to  outside             :SIFS indication
      --------------------------------------
      -- CCA based on carrier sense
      --------------------------------------
      phy_cca_on_cs         => phy_cca_on_cs,                 --(out) to  cca_gen_maxim_1
      wlanrxind             => wlanrxind,                     --(out) to  outside    
      --------------------------------------
      -- Controls to/from CCA timers
      --------------------------------------
      load_timer            => load_timer,                    --(out) to  cca_timers_maxim_1  :Pulse HIGH to reload the CCA timer
      enable_timer          => enable_timer,                  --(out) to  cca_timers_maxim_1  :HIGH to enable timer downcount
      cca_dec_state         => cca_dec_state,                 --(out) to  cca_timers_maxim_1  :CCA state
      --                                                       
      timeout_it            => timeout_it,                    --(in) from cca_timers_maxim_1  :HIGH when CCA timer reaches zero.
      --------------------------------------
      -- Diagnostic
      --------------------------------------
      cca_fsm_diag          => cca_fsm_diag                   --(out) debug
      );


  ----------------------------------------------------------
  -- CCA timers
  ----------------------------------------------------------
  cca_timers_maxim_1 : cca_timers_maxim
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk                => clk,             --(in) from outside 
      reset_n            => reset_n,         --(in) from outside 
      -------------------------------------- 
      -- Controls from registers             
      -------------------------------------- 
      reg_rampdown       => reg_rampdown,    --(in) from outside  :Delay between end of air activity and AGC reset
      reg_biasdel        => reg_biasdel,     --(in) from outside  :RF bias setting time
      reg_ofdmrxdel      => reg_ofdmrxdel,   --(in) from outside  :OFDM end of packet
      reg_dcckrxdel      => reg_dcckrxdel,   --(in) from outside  :DSSS-CCK end of packet
      --------------------------------------
      -- Controls from modems
      --------------------------------------
      phy_rxstartend_ind => phy_rxstartend_ind_ff2_resync, --(in) from cca_resync_maxim_1
      --
      b_psdu_duration    => b_psdu_duration, --(in) from outside  :PSDU length in us from Modem DSSS-CCK
      --
      rxv_length         => rxv_length,      --(in) from outside  :rx psdu length  
      rxv_datarate       => rxv_datarate,    --(in) from outside  :PSDU rec. rate
      --------------------------------------
      -- Controls from/to CCA state machines
      --------------------------------------
      ofdm_rx_en         => ofdm_rx_en_i,    --(in) from cca_fsm_maxim_1
      dcck_rx_en         => dcck_rx_en_i,    --(in) from cca_fsm_maxim_1
      --                                     
      load_timer         => load_timer,      --(in) from cca_fsm_maxim_1
      enable_timer       => enable_timer,    --(in) from cca_fsm_maxim_1
      cca_dec_state      => cca_dec_state,   --(in) from cca_fsm_maxim_1
      --                                     
      timeout_it         => timeout_it       --(out) to  cca_fsm_maxim_1
      );


  ----------------------------------------------------------
  -- CCA based on energy detect + CCA sensing mode
  ----------------------------------------------------------
  cca_gen_maxim_1 : cca_gen_maxim
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk              => clk,                    --(in) from outside 
      reset_n          => reset_n,                --(in) from outside 
      --------------------------------------
      -- Controls from registers
      --------------------------------------
      reg_agccca_disb  => reg_agccca_disb_ff2_resync, --(in) from cca_resync_maxim_1
      reg_sensingmode  => reg_sensingmode,            --(in) from outside             :CCA mode control
      reg_ccarampen    => reg_ccarampen,              --(in) from outside             :'1' to enable CCA busy indication on ramp UP/DOWN
      reg_ccacoren     => reg_ccacoren,               --(in) from outside             :'1' to enable CCA busy indication on correlation
      reg_ccamaxlength => reg_ccamaxlength,           --(in) from outside             :Max length on energy detect
      --
      sw_edcca_ack     => sw_edcca_ack_ff2_resync,    --(in) from cca_resync_maxim_1
      --------------------------------------
      -- Energy detect from AGC
      --------------------------------------
      energy_thr       => energy_thr,                 --(in) from outside             :energy above threshold
      energy_ud        => energy_ud,                  --(in) from outside             :energy ramp UP/DOWN
      --------------------------------------
       -- DSSS correlation significant
      --------------------------------------
      dsss_cor_thr     => dsss_cor_thr,               --(in) from outside             :DSSS correlation significant
      --------------------------------------
      -- CCA
      --------------------------------------
      phy_cca_on_cs    => phy_cca_on_cs,              --(in) from cca_fsm_maxim_1
      --                                             
      phy_cca_ind      => phy_cca_ind_i,              --(out) to  outside => ... => bup2_kernel
      --------------------------------------         
      -- Interrupt                                   
      --------------------------------------         
      cca_irq          => cca_irq                     --(out) to  outside
      );

  ----------------------------------------------------------
  -- Enable 20 Mhz to AGC / AGC SP / FE
  ----------------------------------------------------------
  en_20m_gen_1 : en_20m_gen
  port map (
    reset_n => reset_n,   --(in) from outside 
    clk     => clk,       --(in) from outside 
                   
    en_20m  => en_20m     --(out) to  outside
    );

  

end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

