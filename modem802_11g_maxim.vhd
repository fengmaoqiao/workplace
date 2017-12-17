--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 19177 $
--/ $Date: 2011-12-07 16:16:37 +0100 (Wed, 07 Dec 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/modem802_11g_maxim/vhdl/rtl/modem802_11g_maxim.vhd $
--/
--////////////////////////////////////////////////////////////////////////////



--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all; 

--library modem802_11g_maxim_rtl;
use work.modem802_11g_maxim_pkg.all;

--library modem802_11g_rtl;

--library frontend_maxim_rtl;
use work.frontend_maxim_pkg.all;

--library agc_rtl;
use work.agc_pkg.all;

--library agc_sp_rtl;
use work.agc_sp_pkg.all;

--library cca_maxim_rtl;
use work.cca_maxim_pkg.all;

--library radar_detection_rtl;
use work.radar_detection_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity modem802_11g_maxim is
  generic 
  (
    radar_g : integer := 1    -- 1 to use RADAR.
  );
  port 
  (                            
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    modema_gclk           :  in std_logic; -- Modem 802.11a main clock
    rx_path_a_gclk        :  in std_logic; -- Modem 802.11a gated clock for RX path
    tx_path_a_gclk        :  in std_logic; -- Modem 802.11a gated clock for TX path
    fft_gclk              :  in std_logic; -- Modem 802.11a FFT gated clock
    modemb_gclk           :  in std_logic; -- Modem 802.11b main clock
    --
    rx_path_b_gclk        :  in std_logic; -- Modem 802.11b gated clock for RX path
    tx_path_b_gclk        :  in std_logic; -- Modem 802.11b gated clock for TX path
    --
    bus_gclk              :  in std_logic; -- APB clock
    bup_gclk              :  in std_logic; -- BuP clock
    sampling_gclk         :  in std_logic; -- Sampling clock
    filta_gclk            :  in std_logic; -- Sampling clock 11a filters
    filtb_gclk            :  in std_logic; -- Sampling clock 11b filters
    correla_gclk          :  in std_logic;
    correlb_gclk          :  in std_logic;
    --
    frontend_clk60m_resetn:  in std_logic; -- frontend clk60m related reset
    frontend_clk44m_resetn:  in std_logic; -- frontend clk44m related reset
    modema_clk_resetn     :  in std_logic; -- global reset for 11a clock domain
    modemb_clk_resetn     :  in std_logic; -- global reset for 11b clock domain
    sampling_clk_resetn   :  in std_logic; -- global reset for frontend/agc clock domain
    bus_clk_resetn        :  in std_logic; -- global reset for bup clock domain
    --
    modema_rx_gating      : out std_logic; -- Gating condition for Rx path .11a
    modema_tx_gating      : out std_logic; -- Gating condition for Tx path .11a
    modemb_rx_gating      : out std_logic; -- Gating condition for Rx path .11b
    modemb_tx_gating      : out std_logic; -- Gating condition for Tx path .11b
    filta_gating          : out std_logic;
    filtb_gating          : out std_logic;
    correla_gating        : out std_logic;
    correlb_gating        : out std_logic;
    dac_gating            : out std_logic;
    adc_gating            : out std_logic;
    clkskip               : out std_logic; -- skip one clock cycle in Rx path
    --
    frontend_reset_en     : out std_logic; -- generate an asynchronous reset for correlator
    -- 
    select_clk80          :  in std_logic;
  
    --------------------------------------
    -- APB slave
    --------------------------------------
    psel_radar            : in  std_logic; -- Select. radar registers
    prdata_radar          : out std_logic_vector(31 downto 0); -- Read radar register data.
    psel_modema           : in  std_logic; -- Select. modem a registers
    psel_modemb           : in  std_logic; -- Select. modem b registers
    psel_modemg           : in  std_logic; -- Select. modem g registers
    psel_misc             : in  std_logic;
    penable               : in  std_logic; -- Defines the enable cycle.
    paddr                 : in  std_logic_vector( 9 downto 0); -- Address.
    pwrite                : in  std_logic; -- Write signal.
    pwdata                : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata_modema         : out std_logic_vector(31 downto 0); -- Read modem a data.
    prdata_modemb         : out std_logic_vector(31 downto 0); -- Read modem b data.
    prdata_modemg         : out std_logic_vector(31 downto 0); -- Read modem g data.
    prdata_misc           : out std_logic_vector(31 downto 0);
    
    --------------------------------------------
    -- Interface with RW_WLAN Bup
    --------------------------------------------
    -- inputs signals                                                           
    bup_txdata            : in  std_logic_vector(7 downto 0); -- data to send         
    phy_txstartend_req    : in  std_logic; -- request to start a packet transmission    
    phy_data_req          : in  std_logic; -- request to send a byte                  
    phy_ccarst_req        : in  std_logic; -- request to reset CCA state machine                 
    txv_length            : in  std_logic_vector(11 downto 0);  -- RX PSDU length     
    txv_service           : in  std_logic_vector(15 downto 0);  -- tx service field   
    txv_datarate          : in  std_logic_vector( 3 downto 0); -- PSDU transm. rate
    txpwr_level           : in  std_logic_vector( 2 downto 0); -- TX power level.
    rxv_macaddr_match     : in  std_logic;                     -- Stop the reception because the mac 
                                                               -- addresss does not match  
    txv_immstop           : in  std_logic; -- request to stop the transmission               
    fcs_ok_pulse          : in std_logic;  -- FCS ok status
    in_sifs_pulse         : in std_logic;  -- SIFS status
    -- outputs signals                                                            
    phy_txstartend_conf   : out std_logic; -- transmission started, ready for data  
    phy_rxstartend_ind    : out std_logic; -- indication of RX packet                     
    phy_ccarst_conf       : out std_logic; 
    phy_data_conf         : out std_logic; -- last byte was read, ready for new one 
    phy_data_ind          : out std_logic; -- received byte ready                  
    rxv_length            : out std_logic_vector(11 downto 0); -- RX PSDU length  
    rxv_service           : out std_logic_vector(15 downto 0); -- rx service field
    rxv_service_ind       : out std_logic;
    rxv_datarate          : out std_logic_vector( 3 downto 0); -- PSDU rec. rate
    rxe_errorstat         : out std_logic_vector( 1 downto 0); -- packet recep. stat
    phy_cca_ind           : out std_logic; -- CCA status from Modems
    bup_rxdata            : out std_logic_vector(7 downto 0); -- data received      
    rxv_rssi              : out std_logic_vector (6 downto 0);  -- Value of measured RSSI
    rxv_rxant             : out std_logic;                      -- Antenna used
    rxv_ccaaddinfo        : out std_logic_vector (15 downto 8); -- Additionnal data
    cca_rxsifs_en         : out std_logic; -- respond to cca busy indication 
                                           -- even during RXSIFS state
    --------------------------------------
    -- Radio controller interface
    --------------------------------------
    -- 802.11a side
    a_txonoff_conf        :  in std_logic;
    a_txonoff_req         : out std_logic;
    a_txend_preamble      : out std_logic;  -- End of OFDM preamble
    -- 802.11b side
    b_txonoff_conf        :  in std_logic;
    b_txonoff_req         : out std_logic;
    b_txend_preamble      : out std_logic;  -- End of DSSS-CCK preamble
    --
    agc_rxonoff_req       : out std_logic; 
    agc_rxonoff_conf      :  in std_logic; 
    agc_busy              : out std_logic; 
    agc_rise              : out std_logic; 
    agc_lock              : out std_logic; 
    agc_bb_on             :  in std_logic; 
    --
    rx_ic_gain            : out std_logic_vector(5 downto 0);
    rx_gain_control       : out std_logic_vector(6 downto 0);  
    anaif_bb_rxhp         : out std_logic;                                              
    --------------------------------------
    -- MAXIM MAX2830 interface
    --------------------------------------
    -- RX                                                                         
    anaif_rxi             :  in std_logic_vector(9 downto 0);                          
    anaif_rxq             :  in std_logic_vector(9 downto 0);                          
    -- TX                                                                         
    anaif_txi             : out std_logic_vector(9 downto 0);                          
    anaif_txq             : out std_logic_vector(9 downto 0);                          
    -- control                                                                    
    anaif_bb_jmp_ant_selb : out std_logic;                                              
    
    --------------------------------------
    -- WLAN Indication
    --------------------------------------
    wlanrxind             : out std_logic; -- Indicates a wlan reception 
    
    --------------------------------------
    -- Interrupt controller
    --------------------------------------
    cca_irq               : out std_logic;
    radar_irq             : out std_logic;    
    --------------------------------------
    -- Diag. port
    --------------------------------------
    modem_diag0           : out std_logic_vector(15 downto 0); -- DSSS/CCK modem
    modem_diag1           : out std_logic_vector(15 downto 0); -- DSSS/CCK modem
    modem_diag2           : out std_logic_vector(15 downto 0); -- DSSS/CCK modem
    modem_diag3           : out std_logic_vector(15 downto 0); -- DSSS/CCK modem
    modem_diag4           : out std_logic_vector(15 downto 0); -- frontend_maxim tx I/Q
    modem_diag5           : out std_logic_vector(15 downto 0); -- frontend_maxim rx I/Q
    modem_diag6           : out std_logic_vector(15 downto 0); -- OFDM modem
    modem_diag7           : out std_logic_vector(15 downto 0); -- OFDM modem
    modem_diag8           : out std_logic_vector(15 downto 0); -- OFDM modem
    modem_diag9           : out std_logic_vector(15 downto 0); -- OFDM modem
    modem_diag10          : out std_logic_vector(15 downto 0); -- agc_maxim 
    modem_diag11          : out std_logic_vector(15 downto 0); -- agc_maxim 
    modem_diag12          : out std_logic_vector(15 downto 0); -- frontend_maxim top
    modem_diag13          : out std_logic_vector(15 downto 0); 
    agc_cca_diag0         : out std_logic_vector(15 downto 0); -- agc_cca
	
	-- ------------------------------- debug -----------------------------------------------
	modem_rx_a_toggle_80m_debug  : in std_logic;
	modem_rx_a_i_80m_debug       : in std_logic_vector(10 downto 0);
	modem_rx_a_q_80m_debug       : in std_logic_vector(10 downto 0);
	
	modem_tx_a_toggle_80m_debug  : out std_logic;
    modem_tx_a_i_80m_debug       : out std_logic_vector(9 downto 0);
    modem_tx_a_q_80m_debug       : out std_logic_vector(9 downto 0);
	
	agc_lock_i_debug             : in std_logic;
    agc_rise_i_debug             : in std_logic;
    agc_fall_i_debug             : in std_logic;
	
	cs_a_high_i_debug            : in std_logic;
    cs_a_low_i_debug             : in std_logic;
    cs_b_high_i_debug            : in std_logic;
    cs_b_low_i_debug             : in std_logic;
    cs_flag_nb_i_debug           : in std_logic_vector(1 downto 0);
    cs_flag_valid_i_debug        : in std_logic
	
	-- -------------------------------- end ------------------------------------------------
	);
end entity modem802_11g_maxim;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of modem802_11g_maxim is

  -- ---------------------------------------------------------------------------
  -- BUP
  -- ---------------------------------------------------------------------------
  signal phy_rxstartend_ind_int      : std_logic;                    
  signal phy_txstartend_conf_int     : std_logic;
  signal phy_data_conf_int           : std_logic;  -- last byte was read, ready for new one 
  signal phy_data_ind_int            : std_logic;  -- received byte ready   
  signal bup_rxdata_int              : std_logic_vector(7 downto 0);  -- data received 
  signal rxv_datarate_int            : std_logic_vector( 3 downto 0);  -- PSDU rec. rate
  signal rxv_length_int              : std_logic_vector(11 downto 0);  -- RX PSDU length      
  signal rxe_errorstat_int           : std_logic_vector( 1 downto 0);  -- packet recep. stat
  signal rxv_service_int             : std_logic_vector(15 downto 0);  -- rx service field
  signal rxv_service_ind_int         : std_logic;
  signal phy_ccarst_conf_int         : std_logic;
  
  -- ---------------------------------------------------------------------------
  -- MODEM
  -- ---------------------------------------------------------------------------
  signal modem_tx_b_toggle           : std_logic;
  signal modem_tx_b                  : std_logic_vector( 1 downto 0);
  signal modem_tx_b_active           : std_logic;

  signal modem_rx_b_i                : std_logic_vector(7 downto 0);
  signal modem_rx_b_q                : std_logic_vector(7 downto 0); 
  signal modem_rx_b_toggle           : std_logic; 
  
  signal modem_tx_a_toggle_60m       : std_logic;
  signal modem_tx_a_i_60m            : std_logic_vector( 9 downto 0);
  signal modem_tx_a_q_60m            : std_logic_vector( 9 downto 0);
  signal modem_tx_a_active_60m       : std_logic;
  signal modem_tx_a_toggle_80m       : std_logic;
  signal modem_tx_a_i_80m            : std_logic_vector( 9 downto 0);
  signal modem_tx_a_q_80m            : std_logic_vector( 9 downto 0);
  signal modem_tx_a_active_80m       : std_logic;

  signal modem_rx_a_toggle_60m       : std_logic;
  signal modem_rx_a_i_60m            : std_logic_vector(10 downto 0);
  signal modem_rx_a_q_60m            : std_logic_vector(10 downto 0);
  signal modem_rx_a_toggle_80m       : std_logic;
  signal modem_rx_a_i_80m            : std_logic_vector(10 downto 0);
  signal modem_rx_a_q_80m            : std_logic_vector(10 downto 0);
  
  signal modem_sfd_found             : std_logic;
  
  signal modem_agc_disb              : std_logic;
  signal modem_agc_disb_1t           : std_logic;
  signal modem_agc_disb_2t           : std_logic;
  
  signal modem_psdu_duration         : std_logic_vector(15 downto 0);
  signal tx_ab_mode                  : std_logic;
  signal modem_cp2_detected          : std_logic;
  
  --
  signal a_rxonoff_req_int           : std_logic;
  signal b_rxonoff_req_int           : std_logic;
  signal a_txonoff_req_int           : std_logic;
  signal a_txonoff_req_1t            : std_logic;
  signal a_txonoff_req_2t            : std_logic;

  signal b_txonoff_req_int           : std_logic;
  signal b_txonoff_req_1t            : std_logic;
  signal b_txonoff_req_2t            : std_logic;

  signal a_txonoff_conf_1t           : std_logic;
  signal a_txonoff_conf_2t           : std_logic;
  signal b_txonoff_conf_1t           : std_logic;
  signal b_txonoff_conf_2t           : std_logic;
  signal phy_txonoff_conf            : std_logic;
  signal b_txonoff_req_80m_1t        : std_logic;
  signal b_txonoff_req_80m_2t        : std_logic;
  --
  --
  signal phy_txstartend_req_1t       : std_logic;
  signal phy_txstartend_req_2t       : std_logic;

  --
  signal agc_rxonoff_req_int         : std_logic;
  signal agc_rxonoff_req_1t          : std_logic; 
  signal agc_rxonoff_req_2t          : std_logic; 

  signal agc_bb_on_1t                : std_logic;
  signal agc_bb_on_2t                : std_logic;
  signal agc_enable                  : std_logic;

  signal agc_busy_int                : std_logic;  
  signal agc_busy_1t                 : std_logic; 
  signal agc_busy_2t                 : std_logic; 
  
  signal agc_rise_1t                 : std_logic; 
  signal agc_rise_2t                 : std_logic; 
  
  signal agc_lock_1t                 : std_logic; 
  signal agc_lock_2t                 : std_logic;
  
  signal b_txend_preamble_int        : std_logic; 
  signal b_txend_preamble_2t         : std_logic;
  signal b_txend_preamble_1t         : std_logic; 
  
  ------------------------------------------------------------------------------
  -- Resync FFs
  ------------------------------------------------------------------------------
  signal phy_cca_ind_ff1_resync      : std_logic;
  signal phy_cca_ind_ff2_resync      : std_logic;
  signal phy_ccarst_conf_ff1_resync  : std_logic;
  signal phy_ccarst_conf_ff2_resync  : std_logic;
  signal rxv_rxant_ff1_resync        : std_logic;
  signal rxv_rxant_ff2_resync        : std_logic;

  -- ---------------------------------------------------------------------------
  -- Clock gating
  -- ---------------------------------------------------------------------------
  signal modemb_tx_gating_int        : std_logic;
  signal modemb_rx_gating_int        : std_logic;
  signal modema_tx_gating_int        : std_logic;
  signal modema_rx_gating_int        : std_logic;
  signal dac_gating_int              : std_logic;
   
  -- ---------------------------------------------------------------------------
  -- DAC
  -- ---------------------------------------------------------------------------
  signal txi_int                     : std_logic_vector(9 downto 0);
  signal txq_int                     : std_logic_vector(9 downto 0);

  -- ---------------------------------------------------------------------------
  -- AGC 
  -- ---------------------------------------------------------------------------
  signal rx_ic_gain_i           : std_logic_vector(5 downto 0);
  signal ic_gain_updt_i         : std_logic;
  -- AGC SP - Outputs 
  signal dc_dloop_i_est60_i     : std_logic_vector(12 downto 0);
  signal dc_dloop_q_est60_i     : std_logic_vector(12 downto 0);
  signal dc_dloop_i_est20_i     : std_logic_vector(12 downto 0);
  signal dc_dloop_q_est20_i     : std_logic_vector(12 downto 0);
  signal dp_adc_qdbvrms_agc_i   : std_logic_vector( 8 downto 0);
  signal dp_sat_qdbvrms_agc_i   : std_logic_vector( 8 downto 0);
  signal dp_inbd_qdbvrms_agc_i  : std_logic_vector( 8 downto 0);
  signal dp_radar_qdbvrms_agc_i : std_logic_vector( 8 downto 0);
  signal ca_ac_agc_i            : std_logic_vector(13 downto 0);  
  signal ca_cc_agc_i            : std_logic_vector(13 downto 0); 
  signal ca_rl_agc_i            : std_logic_vector(13 downto 0); 
  signal cb_rl_agc_i            : std_logic_vector(21 downto 0);
  signal cb_bc_agc_i            : std_logic_vector(21 downto 0);

  -- To Radar detect block
  signal radar_valid_i          : std_logic; 
  signal rx_i_radar_i           : std_logic_vector( 9 downto 0);
  signal rx_q_radar_i           : std_logic_vector( 9 downto 0);

  -- AGC/FSM Outputs
  signal dc_en_i                : std_logic;

  signal en_20m_i               : std_logic;
  signal adc_pow_en_i           : std_logic;
  signal inbd_pow_en_i          : std_logic;
  signal ca_en_i                : std_logic_vector(1 downto 0);
  signal cb_en_i                : std_logic_vector(1 downto 0);
  signal agc_fea_en_i           : std_logic;
  signal agc_feb_en_i           : std_logic;
  signal fea_en_i               : std_logic;
  signal feb_en_i               : std_logic;
  signal y_valid_i              : std_logic;

  signal agc_sat_event_i        : std_logic;
  signal agc_lock_i             : std_logic;
  signal agc_rise_i             : std_logic;
  signal agc_fall_i             : std_logic;

  signal cs_flag_nb_i           : std_logic_vector(1 downto 0);
  signal cs_a_high_i            : std_logic;
  signal cs_a_low_i             : std_logic;
  signal cs_b_high_i            : std_logic;
  signal cs_b_low_i             : std_logic;
  signal cs_flag_valid_i        : std_logic;
  signal cs_flag_radar_i        : std_logic;
  signal energy_thr_i           : std_logic;
  signal energy_ud_i            : std_logic;
  signal dsss_cor_thr_i         : std_logic;
  signal pantpack_dbm_i         : std_logic_vector(8 downto 0);
  signal pradar_dbm_i           : std_logic_vector(7 downto 0);
  signal diggain6db_i           : std_logic_vector(2 downto 0);
  signal diggainlin_i           : std_logic_vector(7 downto 0);
  signal scale_factor_i         : std_logic_vector(7 downto 0);
  signal rxv_rxant_i            : std_logic;
  signal rxhp_radio_i           : std_logic;
  signal rxhp_radio_1t          : std_logic;
  signal rxhp_radio_2t          : std_logic;
  -- cca Outputs
   signal cca_busy_a_i           : std_logic;
  signal cca_busy_a_1t          : std_logic;
  signal cca_busy_a_2t          : std_logic;
  signal cca_busy_b_i           : std_logic;
  signal cca_busy_b_1t          : std_logic;
  signal cca_busy_b_2t          : std_logic;
  signal cca_busy_b_del_i       : std_logic_vector(2 downto 0);
  signal agc_sync_reset_i       : std_logic;
  signal in_packet_mode_en_i    : std_logic;
  signal agc_firstpkt_recep_i   : std_logic;
  signal mdma_sm_rst_n_i        : std_logic;
  signal mdma_sm_rst_n_1t       : std_logic;
  signal mdma_sm_rst_n_2t       : std_logic;
  
  signal agcproc_end_i          : std_logic;
  signal agcproc_end_1t         : std_logic;
  signal agcproc_end_2t         : std_logic;

  signal correl_rst_n_i         : std_logic;
  signal correl_rst_n_1t        : std_logic;
  signal correl_rst_n_2t        : std_logic;
  signal correl_rst_n_3t        : std_logic;
  
  signal phy_txonoff_req_i      : std_logic; 
  signal phy_cca_ind_i          : std_logic;
  signal fcs_ok_2agc_i          : std_logic;
  signal in_sifs_2agc_i         : std_logic;
  
  -- Front-end Outputs
  signal i_digfilt60_20_i       : std_logic_vector(13 downto 0); 
  signal q_digfilt60_20_i       : std_logic_vector(13 downto 0); 
  signal i_digfilt44_22_i       : std_logic_vector( 9 downto 0); 
  signal q_digfilt44_22_i       : std_logic_vector( 9 downto 0); 
  signal en_22m_i               : std_logic;

  ----------------------------------
  -- AGC Registers
  ----------------------------------
  signal sw_edcca_ack_i              : std_logic;
  signal reg_rfmode_i                : std_logic;
  signal reg_antenna_loss_db_i       : std_logic_vector(1 downto 0);
  signal reg_thr_sensi_i             : std_logic_vector(9 downto 0);
  signal reg_ndl_det_i               : std_logic_vector(3 downto 0);
  signal reg_rampup_gap_i            : std_logic_vector(4 downto 0);
  signal reg_thr_dsss_det_i          : std_logic_vector(6 downto 0);
  signal reg_thr_dsss_in_i           : std_logic_vector(6 downto 0);
  signal reg_sat_thr_i               : std_logic_vector(6 downto 0);
  signal reg_sat_delta_i             : std_logic_vector(2 downto 0);
  signal reg_sat_up_i                : std_logic_vector(2 downto 0);
  signal reg_dis_inbd_thr_i          : std_logic_vector(6 downto 0);
  signal reg_dis_adc_thr_i           : std_logic_vector(6 downto 0);
  signal reg_ndl_dis_adc_i           : std_logic_vector(4 downto 0);
  signal reg_ndl_dis_inbd_i          : std_logic_vector(4 downto 0);
  signal reg_del_plat_i              : std_logic_vector(6 downto 0);
  signal reg_del_plat_sat_i          : std_logic_vector(6 downto 0);
  signal reg_dp_plat_i               : std_logic_vector(3 downto 0);
  signal reg_thr_plat_cor_i          : std_logic_vector(7 downto 0);
  signal reg_thr_ac_plat_i           : std_logic_vector(5 downto 0);
  signal reg_thr_cc_plat_i           : std_logic_vector(5 downto 0);
  signal reg_mix_acc_plat_i          : std_logic;
  signal reg_thr_ac_cs2_i            : std_logic_vector(5 downto 0);
  signal reg_thr_cc_cs2_i            : std_logic_vector(5 downto 0);
  signal reg_cc_peak_cs2_i           : std_logic_vector(1 downto 0);
  signal reg_mix_acc_cs2_i           : std_logic;
  signal reg_thr_ca_ratio_cs1_i      : std_logic_vector(6 downto 0);
  signal reg_thr_ca_ratio_cs2_i      : std_logic_vector(6 downto 0);
  signal reg_thr_ca_ratio_cs3_i      : std_logic_vector(6 downto 0);
  signal reg_thr_cb_ratio_cs3_i      : std_logic_vector(6 downto 0);
  signal reg_cs1_a_high_force_i      : std_logic;
  signal reg_cs1_a_high_val_i        : std_logic;
  signal reg_cs1_a_low_force_i       : std_logic;
  signal reg_cs1_a_low_val_i         : std_logic;
  signal reg_cs2_a_high_force_i      : std_logic;
  signal reg_cs2_a_high_val_i        : std_logic;
  signal reg_cs2_a_low_force_i       : std_logic;
  signal reg_cs2_a_low_val_i         : std_logic;
  signal reg_cs3_a_high_force_i      : std_logic;
  signal reg_cs3_a_high_val_i        : std_logic;
  signal reg_cs3_a_low_force_i       : std_logic;
  signal reg_cs3_a_low_val_i         : std_logic;
  signal reg_cs3_b_high_force_i      : std_logic;
  signal reg_cs3_b_high_val_i        : std_logic;
  signal reg_cs3_b_low_force_i       : std_logic;
  signal reg_cs3_b_low_val_i         : std_logic;
  signal reg_cs3_g_force_i           : std_logic;
  signal reg_cca_energy_thr_i        : std_logic_vector(7 downto 0);
  signal reg_cca_energy_hys_i        : std_logic_vector(2 downto 0);
  signal reg_cca_energy_up_i         : std_logic_vector(4 downto 0);
  signal reg_cca_energy_down_i       : std_logic_vector(4 downto 0);
  signal reg_delta_preamble_i        : std_logic_vector(6 downto 0);
  signal reg_delta_data_i            : std_logic_vector(6 downto 0);
  signal reg_del_crossing_in_pre_i   : std_logic_vector(6 downto 0);
  signal reg_adctgt11bsc_i           : std_logic_vector(6 downto 0);
  signal reg_adc_tgt_ant_i           : std_logic_vector(6 downto 0);
  signal reg_adc_tgt_fine_i          : std_logic_vector(6 downto 0);
  signal reg_adc_tgt_dis_i           : std_logic_vector(6 downto 0);
  signal reg_adctgt_dglin_fine_i     : std_logic_vector(7 downto 0);
  signal reg_adctgt_dglin_coarse_i   : std_logic_vector(7 downto 0);
  signal reg_adctgt_dg6db_fine_i     : std_logic_vector(7 downto 0);
  signal reg_adctgt_dg6db_coarse_i   : std_logic_vector(7 downto 0);
  signal reg_gain_min_det_i          : std_logic_vector(5 downto 0);
  signal reg_gain_max_det_i          : std_logic_vector(5 downto 0);
  signal reg_gain_min_demod_i        : std_logic_vector(5 downto 0);
  signal reg_gain_max_demod_i        : std_logic_vector(5 downto 0);
  signal reg_gain_hi_i               : std_logic_vector(5 downto 0);
  signal reg_gstep1_i                : std_logic_vector(5 downto 0);
  signal reg_gstep2_i                : std_logic_vector(5 downto 0);
  signal reg_gstep3_i                : std_logic_vector(5 downto 0);
  signal reg_modeabg_i               : std_logic_vector(1 downto 0);
  signal reg_rxant_start_i           : std_logic;
  signal reg_ant_sel_allow_i         : std_logic;
  signal reg_q_dc_comp_i             : std_logic_vector(6 downto 0);
  signal reg_i_dc_comp_i             : std_logic_vector(6 downto 0);
  signal reg_dc_comp_force_i         : std_logic;
  signal reg_del_cs2_i               : std_logic_vector(6 downto 0);
  signal reg_del_cs3_i               : std_logic_vector(8 downto 0);
  signal reg_del_2ant_i              : std_logic_vector(8 downto 0);
  signal reg_del_2ant_sat_i          : std_logic_vector(8 downto 0);
  signal reg_del_gain_set1_i         : std_logic_vector(3 downto 0);
  signal reg_del_gain_set2_i         : std_logic_vector(3 downto 0);
  signal reg_del_gain_set3_i         : std_logic_vector(3 downto 0);
  signal reg_del_gain_set4_i         : std_logic_vector(3 downto 0);
  signal reg_del_radar_i             : std_logic_vector(4 downto 0);
  signal reg_del_pradarinbd_i        : std_logic_vector(7 downto 0);
  signal reg_del_recent_sat_i        : std_logic_vector(8 downto 0);
  signal reg_del_dc_conv_i           : std_logic_vector(3 downto 0);
  signal reg_del_fea_on_i            : std_logic_vector(4 downto 0);
  signal reg_del_fea_conv_i          : std_logic_vector(5 downto 0);
  signal reg_del_feb_on_i            : std_logic_vector(5 downto 0);
  signal reg_del_feb_conv_i          : std_logic_vector(6 downto 0);
  signal reg_del_pinbd_conv_i        : std_logic_vector(6 downto 0);
  signal reg_del_padc_conv_i         : std_logic_vector(5 downto 0);
  signal reg_del_pow_4stat_i         : std_logic_vector(7 downto 0);
  signal reg_cca_thr_cs3_i           : std_logic_vector(6 downto 0);
  signal reg_cca_thr_dsss_i          : std_logic_vector(6 downto 0);
  signal update_stat_i               : std_logic;
  signal reg_pant_qdbm_stat_i        : std_logic_vector(9 downto 0);
  signal reg_padc_dbvrms_stat_i      : std_logic_vector(7 downto 0);
  signal reg_gain_stat_i             : std_logic_vector(5 downto 0);
  signal reg_pant_qdbm_2d_stat_i     : std_logic_vector(9 downto 0);
  signal reg_padc_dbvrms_2d_stat_i   : std_logic_vector(7 downto 0);
  signal reg_gain_2d_stat_i          : std_logic_vector(5 downto 0);
  signal reg_pant_qdbm_sifs_stat_i   : std_logic_vector(9 downto 0);
  signal reg_padc_dbvrms_sifs_stat_i : std_logic_vector(7 downto 0);
  signal reg_gain_sifs_stat_i        : std_logic_vector(5 downto 0);
  signal reg_pant_qdbm_ok_stat_i     : std_logic_vector(9 downto 0);
  signal reg_padc_dbvrms_ok_stat_i   : std_logic_vector(7 downto 0);
  signal reg_gain_ok_stat_i          : std_logic_vector(5 downto 0);
  ---------------------------------------
  -- CCA Registers
  ---------------------------------------
  signal reg_agccca_disb_i          : std_logic; -- '1' to enable the CCA procedure
  signal reg_ccarfoffen_i           : std_logic; -- '1' to enable RFOFF on CCA request
  signal reg_forceagcrst_i          : std_logic; -- '1' to enable AGC reset after packet reception
  signal reg_act_i                  : std_logic;
  signal reg_ccarampen_i            : std_logic; -- '1' to enable CCA busy indication on ramp UP/DOWN
  signal reg_agcwaitdc_i            : std_logic; -- '1' to keep AGC disable in RF bias setting state
  signal reg_ccacoren_i             : std_logic; -- '1' to enable CCA busy indication on correlation
  signal reg_ccastatbdgen_i         : std_logic_vector(4 downto 0); -- '1' to enable CCA during some states
  signal reg_sensingmode_i          : std_logic_vector(2 downto 0); -- CCA mode control
  signal reg_rampdown_i             : std_logic_vector(2 downto 0); -- us
  signal reg_biasdel_i              : std_logic_vector(2 downto 0); -- us
  signal reg_ofdmrxdel_i            : std_logic_vector(3 downto 0); -- us
  signal reg_dcckrxdel_i            : std_logic_vector(3 downto 0); -- us
  signal reg_ccamaxlength_i         : std_logic_vector(7 downto 0); -- us
  signal reg_thragcoff_i            : std_logic_vector(8 downto 0);
  ---------------------------------------
  -- AGC SP Registers
  ---------------------------------------
  signal reg_del_radar_dc_force_i   : std_logic_vector( 5 downto 0);
  signal reg_radar_dc_force_dis_i   : std_logic;
  signal reg_gadc_offset_qdb        : std_logic_vector(4 downto 0);
  ---------------------------------------
  -- Front-End Registers
  ---------------------------------------
  -- ADC/DAC scaling
  signal reg_adcscale               : std_logic_vector( 2 downto 0);
  signal reg_dacscale               : std_logic_vector( 1 downto 0);
  -- ADC 2's complement
  signal anaif_rxi_compl            : std_logic_vector(9 downto 0);
  signal anaif_rxq_compl            : std_logic_vector(9 downto 0);
  -- Txa filter
  signal reg_filtbyp_tx_i           : std_logic;
  signal reg_txnorm_i               : std_logic_vector(7 downto 0);
  -- Modules control signals for transmitter
  signal reg_tx_iq_phase_i          : std_logic_vector(5 downto 0);
  signal reg_tx_iq_ampl_i           : std_logic_vector(8 downto 0);
  -- calibration_mux
  signal reg_calmode_i              : std_logic;
  -- IQ calibration signal generator
  signal reg_calfrq0_i              : std_logic_vector(22 downto 0);
  signal reg_calgain_i              : std_logic_vector(2 downto 0);
  signal reg_txiqcalen_i            : std_logic;
  -- Control for interference filter
  signal reg_interf_filt_disb_i     : std_logic;  -- =1 : interference filter disabled.
  signal reg_interp_disb_i          : std_logic; -- disable interpolation when high
  signal reg_interp_max_stage_i     : std_logic_vector(5 downto 0); -- Max value of stage
  -- Control for gain compensation.
  signal reg_gaindisb_i             : std_logic;  -- disable gain compensation when high
  -- Control for filter-Downsampling_44to22- disabled when high.
  signal reg_b_fir_disb_i           : std_logic;
  -- Control for Attenuator - Coefficient of the attenuator from a register.
  signal reg_attenuator_scale_i     : std_logic_vector(5 downto 0);
  -- Control for TX shift in DSSS-CCK.
  signal reg_txshiftb_i             : std_logic_vector(1 downto 0);
  -- Control of sign wave sent to muxes.
  signal reg_rfspeval_i             : std_logic_vector(3 downto 0);
  -- DC Offset force delay
  signal reg_del_fea_dc_force_i     : std_logic_vector(5 downto 0);
  signal reg_del_feb_dc_force_i     : std_logic_vector(5 downto 0);
  -- FETESTCNTL register.
  signal reg_txiqswap               : std_logic;
  signal reg_txc2disb               : std_logic;
  signal reg_dacdatasel             : std_logic_vector(1 downto 0);
  signal reg_dacconstsel            : std_logic_vector(1 downto 0);
  signal reg_rxiqswap               : std_logic;
  signal reg_rxc2disb               : std_logic;
  -- FETXCONST register.
  signal reg_idacconst              : std_logic_vector(7 downto 0);
  signal reg_qdacconst              : std_logic_vector(7 downto 0);
  signal reg_txconsta               : std_logic_vector(7 downto 0);
  signal reg_txconstb               : std_logic_vector(7 downto 0);
  -- FETESTCNTL register.
  signal reg_dcck_sf_force_en        : std_logic;
  signal reg_dcck_scale_factor_force : std_logic_vector(7 downto 0);
  signal reg_ofdm_diggainlin_force   : std_logic_vector(7 downto 0);
  signal reg_ofdmgain_force_en       : std_logic;
  signal reg_ofdm_diggain6db_force   : std_logic_vector(2 downto 0);
  -- AGCCNTL10 register.
  signal reg_gstep2ant_i             : std_logic_vector(5 downto 0);
  signal reg_del2antswitch_i         : std_logic_vector(8 downto 0);
  signal reg_del_dc_hpf_i            : std_logic_vector(3 downto 0);
  
  -- frontend reset enable generation
  signal frontend_en          : std_logic;
  signal frontend_en_ff1      : std_logic;

  -- ---------------------------------------------------------------------------
  -- Debug port
  -- ---------------------------------------------------------------------------
  signal radar_diag           :  std_logic_vector(15 downto 0);

  -- ---------------------------------------------------------------------------
  -- constants
  -- ---------------------------------------------------------------------------
  signal constant_zero        : std_logic_vector(31 downto 0);
  signal constant_one         : std_logic_vector(31 downto 0);
  
-- --------------- ChipScope ----------------
  attribute mark_debug:string;
  attribute mark_debug of psel_modema:signal is "true";  
  attribute mark_debug of psel_modemg:signal is "true";
  attribute mark_debug of penable:signal is "true";   
  attribute mark_debug of paddr:signal is "true";
  attribute mark_debug of pwrite:signal is "true";   
  attribute mark_debug of pwdata:signal is "true";
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin


  -- --------------------------------------------------------------------------
  -- global assignments required by testbench (tracer)
  -- -------------------------------------------------------------------------- 
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--
  a_txonoff_conf_tglobal <= a_txonoff_conf;
  rx_gain_global         <= '0' & rx_ic_gain_i;
  rx_gain_update_global  <= ic_gain_updt_i;


--
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on


  -- --------------------------------------------------------------------------
  -- assignments
  -- -------------------------------------------------------------------------- 
  constant_zero          <= (others=>'0');
  constant_one           <= (others=>'1');

  a_txonoff_req          <= a_txonoff_req_int;
  b_txonoff_req          <= b_txonoff_req_80m_2t;
 
  phy_txonoff_req_i      <= a_txonoff_req_int or b_txonoff_req_int; 
  agc_rxonoff_req        <= agc_rxonoff_req_2t; -- sync to 80 Mhz clock domain 
  agc_busy               <= agc_busy_2t;
  agc_rise               <= agc_rise_2t;
  agc_lock               <= agc_lock_2t;
  b_txend_preamble       <= b_txend_preamble_2t;
  anaif_bb_rxhp          <= rxhp_radio_2t;
 
  phy_txstartend_conf    <= phy_txstartend_conf_int;
  phy_rxstartend_ind     <= phy_rxstartend_ind_int;
  
  -- Gating condition
  modema_rx_gating       <= modema_rx_gating_int and not cca_busy_a_2t;
  modema_tx_gating       <= modema_tx_gating_int;
  modemb_rx_gating       <= not (modemb_rx_gating_int or cca_busy_b_2t);
  modemb_tx_gating       <= modemb_tx_gating_int and not cca_busy_b_2t;
  
  dac_gating             <= dac_gating_int;
  
  filta_gating           <= '0';
  filtb_gating           <= '0';
  correla_gating         <= '0';
  correlb_gating         <= '0';
  
  rxv_rxant              <= rxv_rxant_ff2_resync;
  rxv_ccaaddinfo         <= (others=>'0');  
  anaif_txi              <= txi_int;
  anaif_txq              <= txq_int;
 
  anaif_bb_jmp_ant_selb  <= rxv_rxant_i;
 
  
  -- tx_ab_mode is a false-path
  -- no need to resynchronize a_txonoff_conf for 60 MHz clock domain 
  tx_ab_mode             <= '0' when a_txonoff_conf='1' else '1';
 
  agc_enable             <= agc_bb_on_2t and not modem_agc_disb_2t;
  
  phy_txonoff_conf       <= a_txonoff_conf_2t or b_txonoff_conf_2t;
 
  -----------------------------------------------------------------------------
  -- Resynchronization of control signals between modem b, CCA, AGC and 
  -- Radio controller (60/44 MHz to 80 MHz) 
  -----------------------------------------------------------------------------
  resync_bus_clk_p:process(bus_gclk,bus_clk_resetn)
  begin

    if bus_clk_resetn='0' then

      b_txonoff_req_80m_1t <= '0';
      b_txonoff_req_80m_2t <= '0';
      agc_rxonoff_req_1t   <= '0';
      agc_rxonoff_req_2t   <= '0';
      agc_busy_1t          <= '0';
      agc_busy_2t          <= '0';
      agc_rise_1t          <= '0';
      agc_rise_2t          <= '0';
      agc_lock_1t          <= '0';
      agc_lock_2t          <= '0';
      b_txend_preamble_2t  <= '0';
      b_txend_preamble_1t  <= '0';
      rxhp_radio_1t        <= '0';
      rxhp_radio_2t        <= '0';

    elsif bus_gclk'event and bus_gclk='1' then

      b_txonoff_req_80m_1t <= b_txonoff_req_int;
      b_txonoff_req_80m_2t <= b_txonoff_req_80m_1t;
      agc_rxonoff_req_1t   <= agc_rxonoff_req_int;
      agc_rxonoff_req_2t   <= agc_rxonoff_req_1t;
      agc_busy_1t          <= agc_busy_int;
      agc_busy_2t          <= agc_busy_1t;
      agc_rise_1t          <= agc_rise_i;
      agc_rise_2t          <= agc_rise_1t;
      agc_lock_1t          <= agc_lock_i;
      agc_lock_2t          <= agc_lock_1t;
      b_txend_preamble_1t  <= b_txend_preamble_int;
      b_txend_preamble_2t  <= b_txend_preamble_1t;
      rxhp_radio_1t        <= rxhp_radio_i;
      rxhp_radio_2t        <= rxhp_radio_1t;

    end if;

  end process resync_bus_clk_p;

  -- Resync FFs (60 MHz to 80/44 MHz) for signal going as
  -- inputs to bup2_kernel module.
  -- Resync required since agc/cca is running at 60 MHz clock
  resync_ffs_p: process (bus_clk_resetn, bus_gclk)
  begin
    if bus_clk_resetn = '0' then
      phy_cca_ind_ff1_resync     <= '0';
      phy_cca_ind_ff2_resync     <= '0';
      phy_ccarst_conf_ff1_resync <= '0';
      phy_ccarst_conf_ff2_resync <= '0';
      rxv_rxant_ff1_resync       <= '0';
      rxv_rxant_ff2_resync       <= '0';
    elsif bus_gclk'event and bus_gclk = '1' then
      phy_cca_ind_ff1_resync     <= phy_cca_ind_i;
      phy_cca_ind_ff2_resync     <= phy_cca_ind_ff1_resync;
      phy_ccarst_conf_ff1_resync <= phy_ccarst_conf_int;
      phy_ccarst_conf_ff2_resync <= phy_ccarst_conf_ff1_resync;
      rxv_rxant_ff1_resync       <= rxv_rxant_i;
      rxv_rxant_ff2_resync       <= rxv_rxant_ff1_resync;
    end if;
  end process resync_ffs_p;

  -----------------------------------------------------------------------------
  -- Resynchronization of control signals from 44/80MHz to 60 MHz 
  -----------------------------------------------------------------------------
  resync_sampling_clk_p:process(sampling_gclk,sampling_clk_resetn)
  begin
  
    if sampling_clk_resetn='0' then

      a_txonoff_req_1t          <= '0';
      a_txonoff_req_2t          <= '0';
      b_txonoff_req_1t          <= '0';
      b_txonoff_req_2t          <= '0';
      --
      a_txonoff_conf_1t         <= '0';
      a_txonoff_conf_2t         <= '0';
      -- 
      b_txonoff_conf_1t         <= '0';
      b_txonoff_conf_2t         <= '0';
 
      agc_bb_on_1t              <= '0';
      agc_bb_on_2t              <= '0';
      --
      modem_agc_disb_1t         <= '0';
      modem_agc_disb_2t         <= '0';
      --
      phy_txstartend_req_1t     <= '0';
      phy_txstartend_req_2t     <= '0';
      -- 
             
    elsif sampling_gclk'event and sampling_gclk='1' then
      
        
      agc_bb_on_1t              <= agc_bb_on;
      agc_bb_on_2t              <= agc_bb_on_1t;
      --
      modem_agc_disb_1t         <= modem_agc_disb;
      modem_agc_disb_2t         <= modem_agc_disb_1t;
      --
      phy_txstartend_req_1t     <= phy_txstartend_req;
      phy_txstartend_req_2t     <= phy_txstartend_req_1t;
      a_txonoff_req_1t          <= a_txonoff_req_int;
      a_txonoff_req_2t          <= a_txonoff_req_1t;

      b_txonoff_req_1t          <= b_txonoff_req_int;
      b_txonoff_req_2t          <= b_txonoff_req_1t;

      a_txonoff_conf_1t         <= a_txonoff_conf;
      a_txonoff_conf_2t         <= a_txonoff_conf_1t;
      --
      b_txonoff_conf_1t         <= b_txonoff_conf;
      b_txonoff_conf_2t         <= b_txonoff_conf_1t;
 
    end if;
  
  end process resync_sampling_clk_p;

  ------------------------------------------------------------------------
  -- Resync control signals from (cca) 60 MHz to 80 MHz modema clock
  ------------------------------------------------------------------------
  mdma_resync_p : process (modema_gclk, modema_clk_resetn)
  begin  -- process mdm_resync_p
   if modema_clk_resetn = '0' then
     
     mdma_sm_rst_n_1t <= '1' ;
     mdma_sm_rst_n_2t <= '1' ;
     cca_busy_a_1t    <= '0';
     cca_busy_a_2t    <= '0';
 

    elsif modema_gclk'event and modema_gclk = '1' then
     
     mdma_sm_rst_n_1t <= mdma_sm_rst_n_i;
     mdma_sm_rst_n_2t <= mdma_sm_rst_n_1t;
     cca_busy_a_1t    <= cca_busy_a_i;
     cca_busy_a_2t    <= cca_busy_a_1t;

    end if;
  end process mdma_resync_p;

  ------------------------------------------------------------------------
  -- Resync control signals from (cca) 60 MHz to 44 MHz modemb clock
  ------------------------------------------------------------------------
  mdmb_resync_p : process (modemb_gclk, modemb_clk_resetn)
  begin  -- process mdm_resync_p
   if modemb_clk_resetn = '0' then

     agcproc_end_1t  <= '0';
     agcproc_end_2t  <= '0' ;
     correl_rst_n_1t <= '1' ;
     correl_rst_n_2t <= '1' ;
     correl_rst_n_3t <= '1' ;
     cca_busy_b_1t   <= '0';
     cca_busy_b_2t   <= '0';  

    elsif modemb_gclk'event and modemb_gclk = '1' then

     agcproc_end_1t  <= agcproc_end_i;
     agcproc_end_2t  <= agcproc_end_1t; 
     correl_rst_n_1t <= correl_rst_n_i;    
     correl_rst_n_2t <= correl_rst_n_1t;    
     correl_rst_n_3t <= correl_rst_n_2t;    
     cca_busy_b_1t   <= cca_busy_b_i;
     cca_busy_b_2t   <= cca_busy_b_1t;

    end if;
  end process mdmb_resync_p;

 


 
-- Output assignement for intermediate signals used as globals.
  phy_data_conf   <= phy_data_conf_int;
  phy_data_ind    <= phy_data_ind_int;
  bup_rxdata      <= bup_rxdata_int;
  rxv_datarate    <= rxv_datarate_int;
  rxv_length      <= rxv_length_int;
  rxe_errorstat   <= rxe_errorstat_int;
  phy_cca_ind     <= phy_cca_ind_ff2_resync;
  rxv_service     <= rxv_service_int;
  rxv_service_ind <= rxv_service_ind_int;
  phy_ccarst_conf <= phy_ccarst_conf_ff2_resync;
  rxv_rssi        <= pantpack_dbm_i(6 downto 0);


-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off

  phy_data_ind_gbl        <= phy_data_ind_int;
  bup_rxdata_gbl          <= bup_rxdata_int;

  modem_rx_a_i_gbl        <= modem_rx_a_i_60m;     
  modem_rx_a_q_gbl        <= modem_rx_a_q_60m;     
  modem_rx_a_toggle_gbl   <= modem_rx_a_toggle_60m;

-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on 

  ------------------------------------------------------------------------------
  -- 802.11g Core instance
  ------------------------------------------------------------------------------
  modem802_11g_core_1 : modem802_11g_core
  generic map
  (
    radio_interface_g => 2,
    agc_gain_nb_g     => 6 
  )
  port map
  (
  
    modema_clk               =>  modema_gclk,              --(in) from outside
    rx_path_a_gclk           =>  rx_path_a_gclk,           --(in) from outside
    tx_path_a_gclk           =>  tx_path_a_gclk,           --(in) from outside
    fft_gclk                 =>  fft_gclk,                 --(in) from outside
    mdma_reset_n             =>  bus_clk_resetn,           --(in) from outside
    --                      
    modemb_clk               =>  modemb_gclk,              --(in) from outside
    rx_path_b_gclk           =>  rx_path_b_gclk,           --(in) from outside
    tx_path_b_gclk           =>  tx_path_b_gclk,           --(in) from outside
    mdmb_reset_n             =>  bus_clk_resetn,           --(in) from outside
    --                      
    bup_clk                  =>  bup_gclk,                 --(in) from outside 
    bup_reset_n              =>  bus_clk_resetn,           --(in) from outside
    --                      
    pclk                     =>  bus_gclk,                 --(in) from outside
    preset_n                 =>  bus_clk_resetn,           --(in) from outside
    --                      
    mdma_sm_rst_n            =>  mdma_sm_rst_n_2t,         --(in) from process mdma_resync_p <= cca_1
    --                      
    modema_rx_gating         =>  modema_rx_gating_int,     --(out) to  assign => outside => clockreset_maxim
    modema_tx_gating         =>  modema_tx_gating_int,     --(out) to  assign => outside => clockreset_maxim
    modemb_rx_gating         =>  modemb_rx_gating_int,     --(out) to  assign => outside => clockreset_maxim
    modemb_tx_gating         =>  modemb_tx_gating_int,     --(out) to  assign => outside => clockreset_maxim
    calib_test               =>  open,                     --(out) 

    -- APB slave            
    psel_a                   => psel_modema,               --(in) from outside
    psel_b                   => psel_modemb,               --(in) from outside
    psel_g                   => psel_modemg,               --(in) from outside
    penable                  => penable,                   --(in) from outside
    paddr                    => paddr(5 downto 0),         --(in) from outside
    pwrite                   => pwrite,                    --(in) from outside
    pwdata                   => pwdata,                    --(in) from outside 
    --                              
    prdata_modemg            => prdata_modemg,             --(out) to  outside
    prdata_modemb            => prdata_modemb,             --(out) to  outside
    prdata_modema            => prdata_modema,             --(out) to  outside

    -- RW_WLAN bup interface
    bup_txdata               => bup_txdata,                --(in) from outside
    phy_txstartend_req       => phy_txstartend_req,        --(in) from outside    :request to start a packet transmission 
    phy_data_req             => phy_data_req,              --(in) from outside
    phy_ccarst_req           => phy_ccarst_req,            --(in) from outside    :request to reset CCA state machine
    txv_length               => txv_length,                --(in) from outside
    txv_service              => txv_service,               --(in) from outside
    txv_datarate             => txv_datarate,              --(in) from outside
    txpwr_level              => txpwr_level,               --(in) from outside
    bup_rxv_macaddr_match    => rxv_macaddr_match,         --(in) from outside  :Stop the reception because the mac addresss does not match 
    bup_txv_immstop          => txv_immstop,               --(in) from outside
    select_rx_ab             => cca_busy_b_2t,             --(in) from process mdmb_resync_p <= cca_1
    -- 
    phy_txstartend_conf      => phy_txstartend_conf_int,   --(out) to  assign => outside
    phy_rxstartend_ind       => phy_rxstartend_ind_int,    --(out) to  assign => outside and cca_1
    a_phy_ccarst_conf        => open,                      --(out)     
    phy_data_conf            => phy_data_conf_int,         --(out) to  assign => outside
    phy_data_ind             => phy_data_ind_int,          --(out) to  assign => outside 
    rxv_length               => rxv_length_int,            --(out) to  assign => outside and cca_1 
    rxv_rssi                 => open,                      --(out)     
    rxv_service              => rxv_service_int,           --(out) to  assign => outside
    rxv_service_ind          => rxv_service_ind_int,       --(out) to  assign => outside
    rxv_datarate             => rxv_datarate_int,          --(out) to  assign => outside and cca_1 
    rxe_errorstat            => rxe_errorstat_int,         --(out) to  assign => outside 
    phy_cca_ind              => open,                      --(out)     
    bup_rxdata               => bup_rxdata_int,            --(out) to  assign => outside 

    -- Radio controller interface                           
    a_txonoff_conf           => a_txonoff_conf,            --(in) from outside
    a_rxonoff_conf           => a_rxonoff_req_int,         --(in) from modem802_11g_core_1
    a_rssi                   => constant_zero(6 downto 0), --(in) from assign <= '0'
    --
    a_txonoff_req            => a_txonoff_req_int,         --(out) to  assign and process resync_sampling_clk_p
    a_txbbonoff_req_o        => open,                      --(out)
    a_rxonoff_req            => a_rxonoff_req_int,         --(out) to  modem802_11g_core_1
    a_txpwr                  => open,                      --(out)
    a_dac_enable             => open,                      --(out)
    a_txend_preamble         => a_txend_preamble,          --(out) to  outside => radioctrl_maxair
    -- 802.11b side
    b_txonoff_conf           => b_txonoff_conf,            --(in) from outside
    b_rxonoff_conf           => b_rxonoff_req_int,         --(in) from modem802_11g_core_1
    b_rxi                    => modem_rx_b_i,              --(in) from frontend_maxim_1
    b_rxq                    => modem_rx_b_q,              --(in) from frontend_maxim_1
    --
    b_txon                   => b_txonoff_req_int,         --(out) to  assign => cca_1 and process resync_bus_clk_p and process resync_sampling_clk_p
    b_rxon                   => b_rxonoff_req_int,         --(out) to  modem802_11g_core_1
    b_dac_enable             => open,                      --(out)
    b_txend_preamble         => b_txend_preamble_int,      --(out) to  process resync_bus_clk_p => outside => radioctrl_maxair
    -- AGC/CCA                          
    cca_busy_a               => cca_busy_a_2t,             --(in) from process mdma_resync_p <= cca_1
    cca_busy_b               => cca_busy_b_2t,             --(in) from process mdmb_resync_p <= cca_1
    agc_gain                 => rx_ic_gain_i,              --(in) from agc_1 (001001)
    agc_gain_updt            => ic_gain_updt_i,            --(in) from agc_1 (1)
    --
    listen_start_o           => open,                      --(out)
    cp2_detected             => modem_cp2_detected,        --(out) to  cca_1
    a_phy_cca_ind            => open,                      --(out)
    b_phy_cca_ind            => open,                      --(out)
    -- 802.11b TX front end
    fir_disb                 => open,                      --(out)
    init_fir                 => open,                      --(out)
    fir_activate             => modem_tx_b_active,         --(out) to  frontend_maxim_1
    fir_phi_out_tog_o        => modem_tx_b_toggle,         --(out) to  frontend_maxim_1
    fir_phi_out              => modem_tx_b,                --(out) to  frontend_maxim_1
    tx_const                 => open,                      --(out)
    txc2disb                 => open,                      --(out)
    -- Interface with 11b RX Frontend                      
    interp_disb              => open,                      --(out)
    clock_lock               => open,                      --(out)
    tlockdisb                => open,                      --(out)
    gain_enable              => open,                      --(out)
    tau_est                  => open,                      --(out) 
    enable_error             => open,                      --(out)
    rxc2disb                 => open,                      --(out)
    interpmaxstage           => open,                      --(out)
    -- 802.11b AGC
    agcproc_end              => agcproc_end_2t,            --(in) from process mdmb_resync_p <= cca_1
    correl_rst_n             => correl_rst_n_3t,           --(in) from process mdmb_resync_p <= cca_1
    agc_diag                 => constant_zero(15 downto 0),--(in) from assign <= '0'
    -- 
    psdu_duration            => modem_psdu_duration,       --(out) to  cca_1
    correct_header           => open,                      --(out)
    plcp_state               => open,                      --(out)
    plcp_error               => open,                      --(out)
    agc_modeabg              => open,                      --(out)
    agc_longslot             => open,                      --(out)
    agc_wait_cs_max          => open,                      --(out)
    agc_wait_sig_max         => open,                      --(out)
    agc_disb                 => modem_agc_disb,            --(out) to  process resync_sampling_clk_p => cca_1
    agc_modeant              => open,                      --(out)
    interfildisb             => open,                      --(out)
    ccamode                  => open,                      --(out)
    sfd_found                => modem_sfd_found,           --(out) to  cca_1
    symbol_sync2             => open,                      --(out)
    -- 802.11a Filters                                     
    filter_valid_rx_i        => modem_rx_a_toggle_80m_debug,     --(in) from rx_resync_60to80_1
    rx_filtered_data_i       => modem_rx_a_i_80m_debug,          --(in) from rx_resync_60to80_1
    rx_filtered_data_q       => modem_rx_a_q_80m_debug,          --(in) from rx_resync_60to80_1
    -- 
    tx_active_o              => modem_tx_a_active_80m,     --(out) to  tx_resync_80to60
    tx_filter_bypass_o       => open,                      --(out)
    filter_start_of_burst_o  => open,                      --(out)
    filter_valid_tx_o        => modem_tx_a_toggle_80m_debug,     --(out) to  tx_resync_80to60
    tx_norm_o                => open,                      --(out)
    tx_data2filter_i         => modem_tx_a_i_80m_debug,          --(out) to  tx_resync_80to60
    tx_data2filter_q         => modem_tx_a_q_80m_debug,          --(out) to  tx_resync_80to60
    -- Registers for rw_wlan rf front end
    calmode_o                => open,                      --(out)  
    calfrq0_o                => open,                      --(out)
    calgain_o                => open,                      --(out)
    tx_iq_phase_o            => open,                      --(out)
    tx_iq_ampl_o             => open,                      --(out)
    rx_del_dc_cor_o          => open,                      --(out)
    dc_off_disb_o            => open,                      --(out)
    a_c2disb_tx_o            => open,                      --(out)
    a_c2disb_rx_o            => open,                      --(out)
    deldc2_o                 => open,                      --(out)
    tx_const_o               => open,                      --(out)
    tx_iqswap                => open,                      --(out)
    rx_iqswap                => open,                      --(out)
    ofdmcoex                 => constant_zero(7 downto 0), --(in) from assign <= '0'
    reg_addestimdura         => open,                      --(out)
    reg_addestimdurb         => open,                      --(out)
    reg_rampdown             => open,                      --(out)
    reg_rstoecnt             => open,                      --(out) 
    edtransmode_reset        => constant_zero(0),          --(in) from assign <= '0'
    reg_edtransmode          => open,                      --(out)
    reg_edmode               => open,                      --(out)
    -- Diag. port
    modem_diag0              => modem_diag0, -- modemb     --(out)  
    modem_diag1              => modem_diag1,               --(out)
    modem_diag2              => modem_diag2,               --(out)
    modem_diag3              => modem_diag6, -- modema Rx  --(out) 
    modem_diag4              => modem_diag7,               --(out) 
    modem_diag5              => modem_diag8,               --(out)
    modem_diag6              => modem_diag9                --(out)  
    );



  rx_resync_60to80_1:rx_resync_60to80
  port map
  (
    -- -------------------------------------------------------------------------
    -- 60 MHz write domain
    -- -------------------------------------------------------------------------
    resetn60m    => frontend_clk60m_resetn,--(in) from 
    clk60m       => filta_gclk,            --(in) from 
    i60m         => modem_rx_a_i_60m,      --(in) from frontend_maxim
    q60m         => modem_rx_a_q_60m,      --(in) from frontend_maxim
    toggle60m    => modem_rx_a_toggle_60m, --(in) from frontend_maxim
  
    -- -------------------------------------------------------------------------
    -- 80 MHz write domain
    -- -------------------------------------------------------------------------
    resetn80m    => modema_clk_resetn,     --(in) from outside
    clk80m       => rx_path_a_gclk,        --(in) from outside
    i80m         => modem_rx_a_i_80m,      --(out) to  modem802_11g_core
    q80m         => modem_rx_a_q_80m,      --(out) to  modem802_11g_core
    toggle80m    => modem_rx_a_toggle_80m  --(out) to  modem802_11g_core
  );

  tx_resync_80to60_1:tx_resync_80to60
  port map
  (
    -- -------------------------------------------------------------------------
    -- 80 MHz write domain
    -- -------------------------------------------------------------------------
    resetn80m    => modema_clk_resetn,
    clk80m       => tx_path_a_gclk,
    enable80m    => modem_tx_a_active_80m,--(in) from modem802_11g_core
    i80m         => modem_tx_a_i_80m,     --(in) from modem802_11g_core
    q80m         => modem_tx_a_q_80m,     --(in) from modem802_11g_core
    toggle80m    => modem_tx_a_toggle_80m,--(in) from modem802_11g_core
  
    -- -------------------------------------------------------------------------
    -- 60 MHz write domain
    -- -------------------------------------------------------------------------
    resetn60m    => frontend_clk60m_resetn,
    clk60m       => filta_gclk,
    enable60m    => modem_tx_a_active_60m, --(out) to frontend_maxim 
    i60m         => modem_tx_a_i_60m,      --(out) to frontend_maxim 
    q60m         => modem_tx_a_q_60m,      --(out) to frontend_maxim 
    toggle60m    => modem_tx_a_toggle_60m  --(out) to frontend_maxim 
  );
    
  
  ------------------------------------------------------------------------------
  -- 802.11g frontend instance 
  ------------------------------------------------------------------------------

-- frontend_maxim_1 : frontend_maxim
  -- port  map(
    ------------------------------------
    ----Clocks & Reset
    ------------------------------------
    -- filta_gclk               => filta_gclk,  
    -- filtb_gclk               => filtb_gclk,
    -- sampling_gclk            => sampling_gclk,
    -- rx_path_b_gclk           => rx_path_b_gclk, 
    -- modemb_clk               => modemb_gclk,
    
    -- clk60m_resetn            => frontend_clk60m_resetn,  
    -- clk44m_resetn            => frontend_clk44m_resetn,
 
    ------------------------------------
    ----OFDM interface
    ------------------------------------
    ----Tx & Rx filter
    -- txa_active_i             => modem_tx_a_active_60m, --(in) from tx_resync_80to60
    -- txi_data2filter_i        => modem_tx_a_i_60m,      --(in) from tx_resync_80to60
    -- txq_data2filter_i        => modem_tx_a_q_60m,      --(in) from tx_resync_80to60
    -- filter_toggle_tx_i       => modem_tx_a_toggle_60m, --(in) from tx_resync_80to60
    ----Rx A outputs
    -- rxa_out_i_o              => modem_rx_a_i_60m,      --(out) to  rx_resync_60to80 and assign => open 
    -- rxa_out_q_o              => modem_rx_a_q_60m,      --(out) to  rx_resync_60to80 and assign => open 
    -- rxa_toggle_o             => modem_rx_a_toggle_60m, --(out) to  rx_resync_60to80 and assign => open 

    ------------------------------------
    ----DSSS-CCK interface
    ------------------------------------
    ----Tx filter
    -- txb_phi_angle_i          => modem_tx_b,        --(in) from modem802_11g_core_1
    ----Control for tx resync. only for BB
    -- fir_activate_i           => modem_tx_b_active, --(in) from modem802_11g_core_1
    -- phi_angle_tog_i          => modem_tx_b_toggle, --(in) from modem802_11g_core_1

    ----Control for interpolator
    -- clk_skip_o              => clkskip,            --(out) to  outside  :when '1': gate clk during 1 period
    ----Rx B outputs
    -- rxb_out_i_o             => modem_rx_b_i,       --(out) to  modem802_11g_core
    -- rxb_out_q_o             => modem_rx_b_q,       --(out) to  modem802_11g_core
    ----For ADC test mode only
    -- rxb_i_60m               => open,
    -- rxb_q_60m               => open,
    -- rxb_toggle              => modem_rx_b_toggle,  --open
    
    --------------------------
    ----AGC interface
    --------------------------
    -- fea_en                   => fea_en_i,           --(in) from assign <= agc and <= cca          
    -- feb_en                   => feb_en_i,           --(in) from assign <= agc and <= cca        
    -- en_20m                   => en_20m_i,           --(in) from cca    
    -- in_packet_mode_en        => in_packet_mode_en_i,    
    -- diggain_6db              => diggain6db_i,           
    -- diggain_lin              => diggainlin_i,           
    -- interf_filt_scaling      => scale_factor_i,         
    -- dco_estim_60_i           => dc_dloop_i_est60_i, --(in) from agc_sp_1    
    -- dco_estim_60_q           => dc_dloop_q_est60_i, --(in) from agc_sp_1    
    -- dco_estim_20_i           => dc_dloop_i_est20_i, --(in) from agc_sp_1    
    -- dco_estim_20_q           => dc_dloop_q_est20_i, --(in) from agc_sp_1    
    -- rx_filter_out_i          => i_digfilt60_20_i,   --(out) to  agc_sp_1    
    -- rx_filter_out_q          => q_digfilt60_20_i,   --(out) to  agc_sp_1    
    -- rxb_filt_4_corr_i_o      => i_digfilt44_22_i,   --(out) to  agc_sp_1    
    -- rxb_filt_4_corr_q_o      => q_digfilt44_22_i,   --(out) to  agc_sp_1    
    -- rxb_filter_down_toggle_o => en_22m_i,           --(out) to  agc_sp_1            
    
    ------------------------------------
    ----BuP
    ------------------------------------
    ----Mode selection
    -- tx_abmode                => tx_ab_mode, -- 0 -> Tx B protocol 1 -> Tx A protocol
    ----Tx power for 0.5dB reduction
    -- txpwr_level              => txpwr_level(0),

    ---------------------