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
--/ Description      : Package for cca_maxim.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/cca_maxim/vhdl/rtl/cca_maxim_pkg.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package cca_maxim_pkg is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Constants for CCA state
  constant RFOFF_ST_CT                  : std_logic_vector(4 downto 0) := "00000";
  constant RF_BIAS_SETTING_ST_CT        : std_logic_vector(4 downto 0) := "00001";
  constant IDLE_ST_CT                   : std_logic_vector(4 downto 0) := "00010";
  constant WAIT_GAIN1_ST_CT             : std_logic_vector(4 downto 0) := "00011";
  constant OFDM_SEARCH1_ST_CT           : std_logic_vector(4 downto 0) := "00100";
  constant OFDM_SEARCH2_ST_CT           : std_logic_vector(4 downto 0) := "00101";
  constant WAIT_OFDM_HEADER_ST_CT       : std_logic_vector(4 downto 0) := "00110";
  constant WAIT_GAIN3_ST_CT             : std_logic_vector(4 downto 0) := "00111";
  constant DSSS_SEARCH_ST_CT            : std_logic_vector(4 downto 0) := "01000";
  constant WAIT_PLCP_HEADER_ST_CT       : std_logic_vector(4 downto 0) := "01001";
  constant START_RECEPTION_ST_CT        : std_logic_vector(4 downto 0) := "01010";
  constant RX_MODEM_AGC_ST_CT           : std_logic_vector(4 downto 0) := "01011";
  constant WAIT_RAMP_DOWN1_ST_CT        : std_logic_vector(4 downto 0) := "01100";
  constant RX_MODEM_ONLY_ST_CT          : std_logic_vector(4 downto 0) := "01101";
  constant WAIT_PACKET_END_ST_CT        : std_logic_vector(4 downto 0) := "01110";
  constant WAIT_RAMP_DOWN2_ST_CT        : std_logic_vector(4 downto 0) := "01111";
  constant WAIT_RAMP_DOWN_RF_BIAS_ST_CT : std_logic_vector(4 downto 0) := "10000";
  constant WAIT_RX_CHAIN_DELAY_ST_CT    : std_logic_vector(4 downto 0) := "10001";
  constant ERROR_ST_CT                  : std_logic_vector(4 downto 0) := "10010";
  constant AGC_RESET_ST_CT              : std_logic_vector(4 downto 0) := "10011";
  
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: en_20m_gen.vhd
----------------------
  component en_20m_gen
  port (
    reset_n : in std_logic; -- Reset synchronously removed with clk.
    clk     : in std_logic; -- Clock to divide.

    en_20m  : out std_logic -- enable 20MHz
  );
  end component;


----------------------
-- File: cca_resync_maxim.vhd
----------------------
  component cca_resync_maxim
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

  end component;


----------------------
-- File: cca_fsm_maxim.vhd
----------------------
  component cca_fsm_maxim
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                : in std_logic;
    reset_n            : in std_logic;
    
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
    reg_ccastatbdgen   : in  std_logic_vector(4 downto 0); -- '1' to enable CCA during some states

    -- Threshold
    -- AGC OFF
    reg_thragcoff      : in  std_logic_vector(8 downto 0);

    --------------------------------------
    -- AGC interface
    --------------------------------------
    agc_lock           : in  std_logic; -- CCA demodulation phase
    agc_rise           : in  std_logic; -- AGC detection
    agc_fall           : in  std_logic; -- AGC signal disappearance
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
    in_packet_mode_en  : out std_logic; -- Packet state
    agc_firstpkt_recep : out std_logic; -- first pkt after AGC enable for SW antenna selection
    
    --------------------------------------
    -- Modem interface
    --------------------------------------
    -- Information from Modems
    phy_rxstartend_ind : in  std_logic; -- HIGH during modem RX processing
    sfd_found          : in  std_logic; -- HIGH when SFD is found
    cp2_detected       : in  std_logic; -- HIGH when synch is found
    -- Modems enable
    ofdm_rx_en         : out std_logic;
    dcck_rx_en         : out std_logic;
    -- Specific controls
    ofdm_sm_rst_n      : out std_logic; -- Pulse active low to reset OFDM SM
    agcproc_end        : out std_logic;
    correl_rst_n       : out std_logic;
    
    --------------------------------------
    -- Radio Controller
    --------------------------------------
    -- Request to switch on (rising edge) or off (falling edge) the RF RX mode
    phy_rxonoff_req    : out std_logic;
    phy_rxbusy         : out std_logic; -- Indication of air activity
    --
    phy_txonoff_req    : in  std_logic; -- Request radio TX mode
    phy_txonoff_conf   : in  std_logic; -- Status of the radio TX mode
    phy_rxonoff_stat   : in  std_logic; -- Status of the radio RX mode

    --------------------------------------
    -- BuP
    --------------------------------------
    phy_ccarst_req     : in  std_logic; -- Pulse HIGH to reset CCA
    -- Flag LOW till phy_cca_ind is reset if MAC address does not match
    rxv_macaddr_match  : in  std_logic;
    phy_txstartend_req : in  std_logic; -- HIGH when a TX is going to start
    --
    phy_ccarst_conf    : out std_logic; -- reset CCA confirmation
    cca_rxsifs_en      : out std_logic; -- sifs indication

    --------------------------------------
    -- CCA based on Carrier sense
    --------------------------------------
    phy_cca_on_cs       : out std_logic; -- HIGH to indicate a busy medium
    wlanrxind           : out std_logic; -- HIGH to indicate a WLAN reception

    --------------------------------------
    -- Controls to/from CCA timers
    --------------------------------------
    timeout_it          : in  std_logic; -- HIGH when CCA timer reaches zero
    --
    load_timer          : out std_logic; -- Pulse HIGH to reload the CCA timer
    enable_timer        : out std_logic; -- HIGH to enable timer downcount
    cca_dec_state       : out std_logic_vector(4 downto 0); -- CCA state

    --------------------------------------
    -- Diagnostic
    --------------------------------------
    cca_fsm_diag        : out std_logic_vector(3 downto 0)
    );

  end component;


----------------------
-- File: cca_timers_maxim.vhd
----------------------
  component cca_timers_maxim
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk              : in  std_logic;
    reset_n          : in  std_logic;

    --------------------------------------
    -- Controls from registers
    --------------------------------------
    -- Delay between end of air activity and AGC reset
    reg_rampdown     : in  std_logic_vector(2 downto 0); -- us
    -- RF bias setting time
    reg_biasdel      : in  std_logic_vector(2 downto 0); -- us
    -- OFDM end of packet
    reg_ofdmrxdel    : in  std_logic_vector(3 downto 0); -- us
    -- DSSS-CCK end of packet
    reg_dcckrxdel    : in  std_logic_vector(3 downto 0); -- us
    
    --------------------------------------
    -- Controls from modem
    --------------------------------------
    phy_rxstartend_ind : in  std_logic; -- HIGH during modem RX processing
    -- DSSS-CCK
    b_psdu_duration    : in  std_logic_vector(15 downto 0); -- us
    -- OFDM
    rxv_length         : in  std_logic_vector(11 downto 0); -- rx psdu length  
    rxv_datarate       : in  std_logic_vector( 3 downto 0); -- rx data rate

    --------------------------------------
    -- Controls from CCA state machines
    --------------------------------------
    -- Modems enable
    ofdm_rx_en       : in  std_logic;
    dcck_rx_en       : in  std_logic;
    -- Timer control
    load_timer       : in  std_logic;
    enable_timer     : in  std_logic;
    cca_dec_state    : in  std_logic_vector(4 downto 0);
    --
    timeout_it       : out std_logic -- Pulse when CCA timer reaches zero
    );

  end component;


----------------------
-- File: cca_gen_maxim.vhd
----------------------
  component cca_gen_maxim
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk              : in std_logic;
    reset_n          : in std_logic;

    --------------------------------------
    -- Controls from registers
    --------------------------------------
    reg_agccca_disb  : in  std_logic; -- '1' to disable the CCA procedure
    reg_sensingmode  : in  std_logic_vector(2 downto 0); -- CCA mode control
    reg_ccarampen    : in  std_logic; -- '1' to enable CCA busy indication on ramp UP/DOWN
    reg_ccacoren     : in  std_logic; -- '1' to enable CCA busy indication on correlation
    reg_ccamaxlength : in  std_logic_vector(7 downto 0); -- Max length on energy detect
    --
    sw_edcca_ack     : in  std_logic; -- SW ack for energy detect channel busy indication
    
    --------------------------------------
    -- Energy detect from AGC
    --------------------------------------
    energy_thr       : in  std_logic; -- Threshold
    energy_ud        : in  std_logic; -- Ramp UP/DOWN
    
    --------------------------------------
    -- DSSS correlation significant
    --------------------------------------
    dsss_cor_thr     : in  std_logic; 

    --------------------------------------
    -- CCA
    --------------------------------------
    phy_cca_on_cs    : in  std_logic;
    --
    phy_cca_ind      : out std_logic;
    
    --------------------------------------
    -- Interrupt
    --------------------------------------
    cca_irq          : out std_logic
    );

  end component;


----------------------
-- File: cca_maxim.vhd
----------------------
  component cca_maxim
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

  end component;



 
end cca_maxim_pkg;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
