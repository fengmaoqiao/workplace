--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 19178 $
--/ $Date: 2011-12-07 16:18:02 +0100 (Wed, 07 Dec 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : RW_WLANcore top for Modem a/b/g mode. Adapted to MAX2829 RF.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/rw_wlanbb_11g_maxim/vhdl/rtl/rw_wlanbb_11g_maxim.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
library modem802_11g_maxim_rtl;
--library stream_processor_rtl;
library radioctrl_maxair_rtl;
library bup2_kernel_rtl;

--library clockreset_maxim_rtl;

library commonlib;
use work.mdm_math_func_pkg.all;

library rw_wlanbb_11g_maxim_rtl;
use work.rw_wlanbb_11g_maxim_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity rw_wlanbb_11g_maxim is
  generic (
    num_queues_g           : integer := 4;
    num_abstimer_g         : integer := 8;
    radar_g                : integer := 1;
    fpga_g                 : integer := 1; --fpga_g,
    wdt_div_g              : integer := 11;
    gate_arm_in_fpga       : integer := 0;
    gate_ofdm_in_fpga      : integer := 1;
    use_clkskip_in_fpga    : integer := 0;
    rf_cnt_size_g          : integer := 8   
    );
  port (
   -- ------------------------------------------------------------------------
   -- incoming reset
   -- ------------------------------------------------------------------------
   external_resetn        : in std_logic;           -- 1.8V external reset pin
   crstn                  : in std_logic;           -- reset from CardBus for PCI bridge
   -- -------------------------------------------------------------------------
   -- incoming clock
   -- ------------------------------------------------------------------------
   plf_clk               : in std_logic;
   clk_60m               : in std_logic;
   clk_80m               : in std_logic;
   en_20m_i              : in std_logic;
   rst_n                 : in std_logic;

    --------------------------------------
    -- Interrupt lines
    --------------------------------------    
    bup_irq                : out std_logic;
    bup_fiq                : out std_logic;
    stream_proc_irq        : out std_logic;
    cca_irq                : out std_logic; 
    radar_irq              : out std_logic;
    --------------------------------------
    -- AHB bus
    --------------------------------------
    -- from BuP
    hgrant_bup             : in  std_logic;
    hbusreq_bup            : out std_logic; 
    hlock_bup              : out std_logic;
    haddr_bup              : out std_logic_vector(31 downto 0);
    htrans_bup             : out std_logic_vector( 1 downto 0);
    hwrite_bup             : out std_logic; 
    hprot_bup              : out std_logic_vector( 3 downto 0);
    hsize_bup              : out std_logic_vector( 2 downto 0);
    hburst_bup             : out std_logic_vector( 2 downto 0);
    hwdata_bup             : out std_logic_vector(31 downto 0);
    -- from 802.11 stream processing
    hgrant_streamproc      : in  std_logic;
    hbusreq_streamproc     : out std_logic;
    hlock_streamproc       : out std_logic;
    haddr_streamproc       : out std_logic_vector(31 downto 0);
    htrans_streamproc      : out std_logic_vector( 1 downto 0);
    hwrite_streamproc      : out std_logic;
    hprot_streamproc       : out std_logic_vector( 3 downto 0);
    hsize_streamproc       : out std_logic_vector( 2 downto 0);
    hburst_streamproc      : out std_logic_vector( 2 downto 0);
    hwdata_streamproc      : out std_logic_vector(31 downto 0);
    -- from platform
    hready                 : in  std_logic;
    hresp                  : in  std_logic_vector( 1 downto 0);
    hrdata                 : in  std_logic_vector(31 downto 0);
 
    -- -------------------------------------------------------------------------  
    -- APB bus
    -- -------------------------------------------------------------------------  
    psel_radar            : in  std_logic; -- Select. radar registers
    prdata_radar          : out std_logic_vector(31 downto 0); -- Read radar register data.
    -------------------------------------

    psel_modema            : in  std_logic;
    psel_modemb            : in  std_logic;
    psel_modemg            : in  std_logic;
    psel_radio             : in  std_logic;
    psel_streamproc        : in  std_logic;
    psel_frontend          : in  std_logic;
    paddr                  : in  std_logic_vector(11 downto 0);
    pwrite                 : in  std_logic;
    penable                : in  std_logic;
    pwdata                 : in  std_logic_vector(31 downto 0);
    --
    prdata_modema          : out std_logic_vector(31 downto 0);
    prdata_modemb          : out std_logic_vector(31 downto 0);
    prdata_modemg          : out std_logic_vector(31 downto 0);
    prdata_bup             : out std_logic_vector(31 downto 0);
    prdata_radio           : out std_logic_vector(31 downto 0);
    prdata_streamproc      : out std_logic_vector(31 downto 0);
    prdata_frontend        : out std_logic_vector(31 downto 0);

    -- -------------------------------------------------------------------------  
    -- AES SRAM:
    -- -------------------------------------------------------------------------  
    aesram_do_i            : in  std_logic_vector(127 downto 0);
    aesram_di_o            : out std_logic_vector(127 downto 0);
    aesram_a_o             : out std_logic_vector(  3 downto 0);
    aesram_rw_no           : out std_logic;
    aesram_cs_no           : out std_logic;

    -- -------------------------------------------------------------------------  
    -- RC4 SRAM:
    -- -------------------------------------------------------------------------  
    rc4ram_do_i            : in  std_logic_vector(7 downto 0);
    rc4ram_di_o            : out std_logic_vector(7 downto 0);
    rc4ram_a_o             : out std_logic_vector(8 downto 0);
    rc4ram_rw_no           : out std_logic; 
    rc4ram_cs_no           : out std_logic; 

    -- -------------------------------------------------------------------------  
    -- Analog interface                                                           
    -- -------------------------------------------------------------------------  
    -- RX                                                                         
    anaif_rxi              :  in std_logic_vector(9 downto 0);                         
    anaif_rxq              :  in std_logic_vector(9 downto 0);                         
    -- TX                                                                         
    anaif_txi              : out std_logic_vector(9 downto 0);                         
    anaif_txq              : out std_logic_vector(9 downto 0);                         
    -- RF control                                                                    
    anaif_lock_det         : in  std_logic;
    --
    anaif_tx_plc           : out std_logic_vector( 6 downto 0);                         
    anaif_bb_rx_en         : out std_logic;                                             
    anaif_bb_tx_en         : out std_logic;                                             
    anaif_bb_jmp_ant_selb  : out std_logic;                                             
    anaif_bb_rxhp          : out std_logic;                                             
    anaif_bb_5gpa_on       : out std_logic;                                             
    anaif_bb_24gpa_on      : out std_logic;                                             
    anaif_bb_shutdown      : out std_logic;                                             
    anaif_bb_spi_clk       : out std_logic;                                             
    anaif_bb_spi_en        : out std_logic;                                             
    anaif_bb_spi_wdata     : out std_logic;                                              
    -- ADC control
    anaif_bb_adc_pwron     : out std_logic;
    anaif_bb_adc_rxen      : out std_logic;
    -- DAC control
    anaif_bb_dac_pwron     : out std_logic;
    anaif_bb_dac_txen      : out std_logic;
    -- RSSI ADC control
    anaif_rssi             : in  std_logic_vector(7 downto 0);
    --
    anaif_bb_rssiadc_pwron : out std_logic;
    anaif_bb_rssiadc_rxen  : out std_logic;
    rssi_gclk              : out std_logic;
    
    --------------------------------------
    -- WLAN Indication
    --------------------------------------
    wlanrxind              : out std_logic;
	
	-- ----------------------------------------------
	-- -----------------debug------------------------  
	-- ----------------------------------------------
	
	modem_rx_a_tog               : in std_logic;
	modem_rx_a_i_phy             : in std_logic_vector(10 downto 0);
	modem_rx_a_q_phy             : in std_logic_vector(10 downto 0);
	
	modem_tx_a_tog  : out std_logic;
    modem_tx_a_i_phy       : out std_logic_vector(9 downto 0);
    modem_tx_a_q_phy       : out std_logic_vector(9 downto 0);
	
	agc_lock_i_debug             : in std_logic;
    agc_rise_i_debug             : in std_logic;
    agc_fall_i_debug             : in std_logic;
    
    cs_a_high_i_debug            : in std_logic;
    cs_a_low_i_debug             : in std_logic;
    cs_b_high_i_debug            : in std_logic;
    cs_b_low_i_debug             : in std_logic;
    cs_flag_nb_i_debug           : in std_logic_vector(1 downto 0);
    cs_flag_valid_i_debug        : in std_logic;
    
    phy_cca_ind_medium           : out std_logic;
        
    phy_data_conf_debug          : out std_logic;
    bup_txdata_debug             : out std_logic_vector(7 downto 0);
    
    phy_data_ind_debug           : out std_logic;
    bup_rxdata_debug             : out std_logic_vector(7 downto 0);
    -- ------------------------------------------------------------------
    rxv_length_debug             : out std_logic_vector(11 downto 0);
    rxv_service_debug            : out std_logic_vector(15 downto 0);
    rxv_service_ind_debug        : out std_logic;
    rxv_datarate_debug           : out std_logic_vector(3 downto 0);
    -- ------------------------------------------------------------------
        tx_start             : in std_logic;
    phy_txstartend_conf  : out std_logic;
 --   phy_data_conf        : out std_logic;

    phy_data_req         : in std_logic;
    fifo_dout_d1         : in std_logic_vector(7 downto 0);  
    phy_txstartend_req   : in std_logic;
    phy_ccarst_req       : in std_logic;
    rxv_macaddr_match    : in std_logic;  
    txv_datarate         : in std_logic_vector(3 downto 0);  
    txv_length           : in std_logic_vector(11 downto 0);
    txpwr_level          : in std_logic_vector(6 downto 0);
    txv_service          : in std_logic_vector(15 downto 0);
    txv_immstop          : in std_logic
     
    );

end entity rw_wlanbb_11g_maxim;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of rw_wlanbb_11g_maxim is
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Constant signals for unused port mapping.
  signal constant_zero        : std_logic_vector(31 downto 0);
  signal constant_one         : std_logic_vector(31 downto 0);
  
--  signal phy_ccarst_req       : std_logic;
  signal phy_ccarst_conf      : std_logic;
--  signal phy_txstartend_req   : std_logic;
--  signal phy_txstartend_conf  : std_logic;
  signal phy_rxstartend_ind   : std_logic;
--  signal phy_data_req         : std_logic;
  signal phy_data_conf        : std_logic;
  signal phy_data_ind         : std_logic;
  signal phy_cca_ind          : std_logic;
  signal rxv_datarate         : std_logic_vector( 3 downto 0);
  signal rxv_length           : std_logic_vector(11 downto 0);
  signal rxe_errorstat        : std_logic_vector( 1 downto 0);
  signal rxv_rssi             : std_logic_vector( 6 downto 0);
  signal rxv_service          : std_logic_vector(15 downto 0);
  signal rxv_service_ind      : std_logic;
--  signal rxv_macaddr_match    : std_logic;-- Indication that MAC Address 1 of received packet matches
  signal rxv_ccaaddinfo       : std_logic_vector( 7 downto 0);
  signal cca_rxsifs_en        : std_logic;
  signal rxv_rxant            : std_logic; -- Antenna used during reception.
  signal txv_txant            : std_logic; -- Antenna used during transmission.
--  signal txv_datarate         : std_logic_vector( 3 downto 0);
--  signal txv_length           : std_logic_vector(11 downto 0);
--  signal txpwr_level          : std_logic_vector( 6 downto 0);
--  signal txv_service          : std_logic_vector(15 downto 0);
--  signal txv_immstop          : std_logic;
  signal bup_txdata           : std_logic_vector( 7 downto 0);
  signal bup_rxdata           : std_logic_vector(7 downto 0);
  --
  signal agc_bb_on            : std_logic; 
  signal agc_rise             : std_logic; 
  signal agc_busy             : std_logic; 
  signal agc_lock             : std_logic; 
  --
  signal a_txonoff_req        : std_logic;                             
  signal a_txend_preamble     : std_logic;                             
  signal a_txonoff_conf       : std_logic;                             
  signal b_txonoff_req        : std_logic;                             
  signal b_txend_preamble     : std_logic;                             
  signal b_txonoff_conf       : std_logic;                             
  signal agc_rxonoff_req      : std_logic;                             
  signal agc_rxonoff_conf     : std_logic;                             
  --
  signal rxagc                : std_logic_vector(4 downto 0);
  signal attenoff             : std_logic_vector(1 downto 0);
  --
  signal dac_gating_i         : std_logic;
  signal adc_gating_i         : std_logic;
  signal dac_gating_mdm       : std_logic;
  signal adc_gating_mdm       : std_logic;
  --
  signal adc_rxen             : std_logic;
  signal force_adc_clk        : std_logic;
  signal dac_txen             : std_logic;
  signal force_dac_clk        : std_logic;
  --
  signal anaif_bb_spi_clk_i   : std_logic;
  signal anaif_bb_spi_en_i    : std_logic;
  signal anaif_bb_spi_wdata_i : std_logic;
  signal anaif_bb_rx_en_i     : std_logic;
  signal anaif_bb_tx_en_i     : std_logic;
  signal anaif_bb_24gpa_on_i  : std_logic;
  signal anaif_bb_5gpa_on_i   : std_logic;
  signal anaif_tx_plc_i       : std_logic_vector(6 downto 0);
  signal anaif_bb_shutdown_i  : std_logic;
  --
  signal fcs_ok_pulse_i       : std_logic;
  signal in_sifs_pulse_i      : std_logic;
  signal switch_antenna_i     : std_logic;
  signal rxhp_radio_i         : std_logic;
  signal rx_ic_gain_i         : std_logic_vector(5 downto 0);
  signal rx_gain_control      : std_logic_vector(6 downto 0);
  
  -- -------------------------------------------------------------------------
  -- Clocks and Reset
  -- -------------------------------------------------------------------------
  signal modema_clk_resetn     : std_logic; --  => modema_clk_resetn,
  signal modemb_clk_resetn     : std_logic; --  => modemb_clk_resetn,
  signal bus_clk_resetn        : std_logic; --  => bus_clk_resetn_i,
  signal sampling_clk_resetn   : std_logic; --  => sampling_clk_resetn_i,
  signal frontend_clk44m_resetn: std_logic; --  => frontend_clk44m_resetn,
  signal frontend_clk60m_resetn: std_logic; --  => frontend_clk60m_resetn,
 
  signal modema_gclk           : std_logic; --  => modema_gclk_i,     
  signal rx_path_a_gclk        : std_logic; --  => rx_path_a_gclk_i,   
  signal tx_path_a_gclk        : std_logic; --  => tx_path_a_gclk_i,     
  signal fft_gclk              : std_logic; --  => fft_gclk_i,      
  signal modemb_gclk           : std_logic; --  => modemb_gclk_i,     
  signal rx_path_b_gclk        : std_logic; --  => rx_path_b_gclk_i,   
  signal tx_path_b_gclk        : std_logic; --  => tx_path_b_gclk_i,   
  signal bus_gclk              : std_logic; --  => bus_gclk_i,       
  signal bus_clk               : std_logic; --  => bus_clk_i,
  signal sampling_gclk         : std_logic; --  => sampling_gclk_i,
  signal filta_gclk            : std_logic; --  => filta_gclk_i,
  signal filtb_gclk            : std_logic; --  => filtb_gclk_i,
  signal correla_gclk          : std_logic; --  => correla_gclk_i,
  signal correlb_gclk          : std_logic; --  => correlb_gclk_i,
  signal strp_gclk             : std_logic; --  => strp_gclk_i,
  
  signal enable_1mhz           : std_logic; --  => enable_1mhz,    
  signal mode32k         : std_logic; --  => ,  ready_for_sleep
 
  signal select_clk80          : std_logic; --  => select_clk80, 
 
  signal modema_rx_gating      : std_logic; --  => modema_rx_gating,
  signal modema_tx_gating      : std_logic; --  => modema_tx_gating,
  signal modemb_rx_gating      : std_logic; --  => modemb_rx_gating,
  signal modemb_tx_gating      : std_logic; --  => modemb_tx_gating,
  signal filta_gating          : std_logic; --  => filta_gating,      
  signal filtb_gating          : std_logic; --  => filtb_gating,    
  signal correla_gating        : std_logic; --  => correla_gating,     
  signal correlb_gating        : std_logic; --  => correlb_gating,     
  signal adc_gating            : std_logic; --  => adc_gating,
  signal dac_gating            : std_logic; --  => dac_gating,
  signal clkskip               : std_logic; --  => clkskip,        
 
  signal frontend_reset_en     : std_logic; --  => frontend_reset_en,    
 
  signal rf_en_force           : std_logic; --  => rf_en_force,
  signal clock_switched        : std_logic; --  => clock_switched,
  signal clk_div               : std_logic_vector(2 downto 0); --  => clk_div,
  -- -------------------------------------------------------------------------
  -- -------------------- just for debug -------------------------------------
  -- -------------------------------------------------------------------------
  
  signal modem_rx_a_active_60m : std_logic;
  signal modem_rx_a_i_60m      : std_logic_vector( 10 downto 0);
  signal modem_rx_a_q_60m      : std_logic_vector( 10 downto 0);
  signal modem_rx_a_toggle_60m : std_logic;

  
  
  
  
  
  signal i_inbd_i          : std_logic_vector( 9 downto 0);
  signal q_inbd_i          : std_logic_vector( 9 downto 0);
  signal i_inbd_ff1_i      : std_logic_vector( 9 downto 0);
  signal q_inbd_ff1_i      : std_logic_vector( 9 downto 0);
  signal i_inbd_ff2_i      : std_logic_vector( 9 downto 0);
  signal q_inbd_ff2_i      : std_logic_vector( 9 downto 0);
  signal i_inbd_ff3_i      : std_logic_vector( 9 downto 0);
  signal q_inbd_ff3_i      : std_logic_vector( 9 downto 0);
  signal i_inbd_ff4_i      : std_logic_vector( 9 downto 0);
  signal q_inbd_ff4_i      : std_logic_vector( 9 downto 0);
  signal i_inbd_ff5_i      : std_logic_vector( 9 downto 0);
  signal q_inbd_ff5_i      : std_logic_vector( 9 downto 0);
  signal i_inbd_ff6_i      : std_logic_vector( 9 downto 0);
  signal q_inbd_ff6_i      : std_logic_vector( 9 downto 0);
  signal i_inbd_ff7_i      : std_logic_vector( 9 downto 0);
  signal q_inbd_ff7_i      : std_logic_vector( 9 downto 0);
  signal i_inbd_ff8_i      : std_logic_vector( 9 downto 0);
  signal q_inbd_ff8_i      : std_logic_vector( 9 downto 0);
  signal i_inbd_ff9_i      : std_logic_vector( 9 downto 0);
  signal q_inbd_ff9_i      : std_logic_vector( 9 downto 0);
  signal i_inbd_ff10_i     : std_logic_vector( 9 downto 0);
  signal q_inbd_ff10_i     : std_logic_vector( 9 downto 0);
  signal i_inbd_ff11_i     : std_logic_vector( 9 downto 0);
  signal q_inbd_ff11_i     : std_logic_vector( 9 downto 0);
  signal i_inbd_ff12_i     : std_logic_vector( 9 downto 0);
  signal q_inbd_ff12_i     : std_logic_vector( 9 downto 0);
  signal i_inbd_ff13_i     : std_logic_vector( 9 downto 0);
  signal q_inbd_ff13_i     : std_logic_vector( 9 downto 0);
  signal i_inbd_ff14_i     : std_logic_vector( 9 downto 0);
  signal q_inbd_ff14_i     : std_logic_vector( 9 downto 0);
  signal i_inbd_ff15_i     : std_logic_vector( 9 downto 0);
  signal q_inbd_ff15_i     : std_logic_vector( 9 downto 0);
  signal i_inbd_ff16_i     : std_logic_vector( 9 downto 0);
  signal q_inbd_ff16_i     : std_logic_vector( 9 downto 0);
  signal i_inbd_ff32_i     : std_logic_vector( 9 downto 0);
  signal q_inbd_ff32_i     : std_logic_vector( 9 downto 0);
  signal i_inbd_ff64_i     : std_logic_vector( 9 downto 0);
  signal q_inbd_ff64_i     : std_logic_vector( 9 downto 0);
  
  signal dp_inbd_lin_i     : std_logic_vector(20 downto 0);
  
  signal ca_ac_agc         : std_logic_vector( 13 downto 0);
  signal ca_cc_agc         : std_logic_vector( 13 downto 0);
  signal ca_rl_agc         : std_logic_vector( 13 downto 0); 
  
   -- OFDM Detector
   signal ca_det_i            : std_logic;
   signal ca_rlw_i            : std_logic_vector(14+1 downto 0);
   signal ca_ac_out_i         : std_logic_vector(14-1 downto 0);
   
   signal reg_thr_ac_plat     : std_logic_vector(5 downto 0);
   signal reg_thr_cc_plat     : std_logic_vector(5 downto 0);
   signal reg_mix_acc_plat    : std_logic;
   signal reg_thr_ac_cs2      : std_logic_vector(5 downto 0);
   signal reg_thr_cc_cs2      : std_logic_vector(5 downto 0);
   signal reg_cc_peak_cs2     : std_logic_vector(1 downto 0);
   signal reg_mix_acc_cs2     : std_logic;
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- ---------------------------------------------------------------------------
  -- assignments
  -- ---------------------------------------------------------------------------
  phy_cca_ind_medium <= phy_cca_ind;
  
  constant_zero <= (others=>'0');
  constant_one  <= (others=>'1');
--  bus_clk_resetn_o <= bus_clk_resetn;
--  bus_clk_o            <= bus_clk;    -- Bus clock not gated 
--  bus_gclk_o           <= bus_gclk;  -- Bus system gated clock    
  
  -- ---------------------------------------------------------------------
  -- -----------------------------debug-----------------------------------
  -- ---------------------------------------------------------------------
  -- tx
  phy_data_conf_debug <= phy_data_conf;
  bup_txdata_debug    <= bup_txdata;
  -- rx
  phy_data_ind_debug  <= phy_data_ind;
  bup_rxdata_debug    <= bup_rxdata;
  
  
  rxv_length_debug       <= rxv_length;
  rxv_service_debug      <=  rxv_service;
  rxv_service_ind_debug  <=  rxv_service_ind;
  rxv_datarate_debug     <=  rxv_datarate;
  
  -- -- clock ------------------
  tx_path_a_gclk      <= clk_80m;
  rx_path_a_gclk      <= clk_80m;
  modema_gclk         <= clk_80m;
  fft_gclk            <= clk_80m;
  sampling_gclk       <= clk_60m;
  
  -- -- reset -------------------
  bus_clk_resetn      <= rst_n;
  modema_clk_resetn   <= rst_n;
  modemb_clk_resetn   <= rst_n;
  sampling_clk_resetn <= rst_n;
   
  -- ---------------------------------------------------------------------
  -- -----------------------------debug-----------------------------------
  -- ---------------------------------------------------------------------
  
  -- ---------------------------------------------------------------------------
  -- 802.11 g Modem 
  -- ---------------------------------------------------------------------------
  modem802_11g_maxim_1:modem802_11g_maxim
  generic map 
  (
    radar_g => radar_g
  )
  port map 
  (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    modema_gclk             => modema_gclk,           --(in) :Modem 802.11a main clock
    rx_path_a_gclk          => rx_path_a_gclk,        --(in) :Modem 802.11a gated clock for RX path
    tx_path_a_gclk          => tx_path_a_gclk,        --(in) :Modem 802.11a gated clock for TX path
    fft_gclk                => fft_gclk,              --(in) :Modem 802.11a FFT gated clock
    modemb_gclk             => modemb_gclk,           --(in) :Modem 802.11b main clock
    rx_path_b_gclk          => rx_path_b_gclk,        --(in) :Modem 802.11b gated clock for RX path
    tx_path_b_gclk          => tx_path_b_gclk,        --(in) :Modem 802.11b gated clock for TX path
--    bus_gclk                => bus_gclk,              --(in) :APB clock
--    bup_gclk                => bus_gclk,              --(in) :BuP clock
    bus_gclk                => plf_clk,              --(in) :APB clock
    bup_gclk                => plf_clk,              --(in) :BuP clock

    sampling_gclk           => sampling_gclk,         --(in) :Sampling clock
    filta_gclk              => filta_gclk,            --(in) :Sampling clock 11a filters
    filtb_gclk              => filtb_gclk,            --(in) :Sampling clock 11b filters
    correla_gclk            => correla_gclk,          --(in) 
    correlb_gclk            => correlb_gclk,          --(in) 
    --                                                --(in) 
    frontend_clk44m_resetn  => frontend_clk44m_resetn,--(in) :frontend clk60m related reset
    frontend_clk60m_resetn  => frontend_clk60m_resetn,--(in) :frontend clk44m related reset
    modema_clk_resetn       => modema_clk_resetn,     --(in) :global reset for 11a clock domain
    modemb_clk_resetn       => modemb_clk_resetn,     --(in) :global reset for 11b clock domain
    sampling_clk_resetn     => sampling_clk_resetn,   --(in) :global reset for frontend/agc clock domain
    bus_clk_resetn          => bus_clk_resetn,        --(in) :global reset for bup clock domain
    --
    modema_rx_gating        => modema_rx_gating,   --(out) to  clockreset_maxim
    modema_tx_gating        => modema_tx_gating,   --(out) to  clockreset_maxim
    modemb_rx_gating        => modemb_rx_gating,   --(out) to  clockreset_maxim
    modemb_tx_gating        => modemb_tx_gating,   --(out) to  clockreset_maxim
    filta_gating            => filta_gating,
    filtb_gating            => filtb_gating,
    correla_gating          => correla_gating,
    correlb_gating          => correlb_gating,
    dac_gating              => dac_gating_mdm,
    adc_gating              => adc_gating_mdm,
    clkskip                 => clkskip,
    --
    frontend_reset_en       => frontend_reset_en,
    --
    select_clk80            => select_clk80,

    --------------------------------------
    -- APB slave
    --------------------------------------
    psel_radar              => psel_radar,
    prdata_radar            => prdata_radar,
    -------------------------------------

    psel_modema             => psel_modema,
    psel_modemb             => psel_modemb,
    psel_modemg             => psel_modemg,
    psel_misc               => psel_frontend,
    penable                 => penable,
    paddr                   => paddr(9 downto 0),
    pwrite                  => pwrite,
    pwdata                  => pwdata,
    --
    prdata_modema           => prdata_modema,
    prdata_modemb           => prdata_modemb,
    prdata_modemg           => prdata_modemg,
    prdata_misc             => prdata_frontend,

    --------------------------------------------
    -- Interface with RW_WLAN Bup
    --------------------------------------------
    --bup_txdata              => bup_txdata,             --(in) from bup2_kernel
    bup_txdata              => fifo_dout_d1,             --(in) from bup2_kernel
    phy_txstartend_req      => phy_txstartend_req,     --(in) from bup2_kernel
    phy_data_req            => phy_data_req,           --(in) from bup2_kernel
    phy_ccarst_req          => phy_ccarst_req,         --(in) from bup2_kernel
    txv_length              => txv_length,             --(in) from bup2_kernel
    txv_service             => txv_service,            --(in) from bup2_kernel
    txv_datarate            => txv_datarate,           --(in) from bup2_kernel
    txpwr_level             => txpwr_level(2 downto 0),--(in) from bup2_kernel
    rxv_macaddr_match       => rxv_macaddr_match,      --(in) from bup2_kernel
    txv_immstop             => txv_immstop,            --(in) from bup2_kernel
    fcs_ok_pulse            => fcs_ok_pulse_i,         --(in) from bup2_kernel
    in_sifs_pulse           => in_sifs_pulse_i,        --(in) from bup2_kernel
    --
    phy_txstartend_conf     => phy_txstartend_conf,    --(out) to  bup2_kernel
    phy_rxstartend_ind      => phy_rxstartend_ind,     --(out) to  bup2_kernel
    phy_ccarst_conf         => phy_ccarst_conf,        --(out) to  bup2_kernel
    phy_data_conf           => phy_data_conf,          --(out) to  bup2_kernel
    phy_data_ind            => phy_data_ind,           --(out) to  bup2_kernel
    rxv_length              => rxv_length,             --(out) to  bup2_kernel
    rxv_service             => rxv_service,            --(out) to  bup2_kernel
    rxv_service_ind         => rxv_service_ind,        --(out) to  bup2_kernel
    rxv_datarate            => rxv_datarate,           --(out) to  bup2_kernel
    rxe_errorstat           => rxe_errorstat,          --(out) to  bup2_kernel
    phy_cca_ind             => phy_cca_ind,            --(out) to  bup2_kernel
    bup_rxdata              => bup_rxdata,             --(out) to  bup2_kernel
    rxv_rssi                => rxv_rssi,               --(out) to  bup2_kernel
    rxv_rxant               => rxv_rxant,              --(out) to  bup2_kernel
    rxv_ccaaddinfo          => rxv_ccaaddinfo,         --(out) to  bup2_kernel
    cca_rxsifs_en           => cca_rxsifs_en,          --(out) to  bup2_kernel
    --------------------------------------
    -- Radio controller interface
    --------------------------------------
    -- 802.11a side
    a_txonoff_conf          => a_txonoff_conf,    --(in) from radioctrl_maxair
    a_txonoff_req           => a_txonoff_req,     --(out) to  radioctrl_maxair
    a_txend_preamble        => a_txend_preamble,  --(out) to  radioctrl_maxair
    -- 802.11b side
    b_txonoff_conf          => b_txonoff_conf,    --(in) from radioctrl_maxair
    b_txonoff_req           => b_txonoff_req,     --(out) to  radioctrl_maxair
    b_txend_preamble        => b_txend_preamble,  --(out) to  radioctrl_maxair
    -- 
    agc_rxonoff_req         => agc_rxonoff_req,   --(out) to  radioctrl_maxair
    agc_rxonoff_conf        => agc_rxonoff_conf,  --(out) to  radioctrl_maxair
    agc_busy                => agc_busy,          --(out) to  radioctrl_maxair
    agc_rise                => agc_rise,          --(out) to  radioctrl_maxair
    agc_lock                => agc_lock,          --(out) to  radioctrl_maxair
    agc_bb_on               => agc_bb_on,         --(in) from radioctrl_maxair
    --
    rx_ic_gain              => rx_ic_gain_i, 
    rx_gain_control         => rx_gain_control, 

    --------------------------------------
    -- MAXIM MAX2829 interface
    --------------------------------------
    anaif_rxi               => anaif_rxi,         --(in) from outside
    anaif_rxq               => anaif_rxq,         --(in) from outside
    anaif_txi               => anaif_txi,         --(out) to  outside
    anaif_txq               => anaif_txq,         --(out) to  outside
    anaif_bb_jmp_ant_selb   => switch_antenna_i,  --(out) to  radioctrl_maxair                                         
    anaif_bb_rxhp           => rxhp_radio_i,
    
    --------------------------------------
    -- WLAN Indication
    --------------------------------------
    wlanrxind               => wlanrxind, 
  
    -------------------------------------
    cca_irq                 => cca_irq,  
    radar_irq               => radar_irq,
    --------------------------------------
    -- Diag
    --------------------------------------
--    modem_diag0             => modem_diag0,
--    modem_diag1             => modem_diag1,
--    modem_diag2             => modem_diag2,
--    modem_diag3             => modem_diag3,
--    modem_diag4             => modem_diag4,
--    modem_diag5             => modem_diag5,
--    modem_diag6             => modem_diag6,
--    modem_diag7             => modem_diag7,
--    modem_diag8             => modem_diag8,
--    modem_diag9             => modem_diag9,
--    modem_diag10            => modem_diag10,
--    modem_diag11            => modem_diag11,
--    modem_diag12            => modem_diag12,
--    modem_diag13            => modem_diag13,
--    agc_cca_diag0	        => agc_cca_diag0,
	
	-- ------------------------- debug -------------------------------------
	modem_rx_a_tog       => modem_rx_a_tog     ,
	modem_rx_a_i_phy     => modem_rx_a_i_phy     ,
	modem_rx_a_q_phy     => modem_rx_a_q_phy     ,
	
	modem_tx_a_tog=> modem_tx_a_tog,
    modem_tx_a_i_phy     => modem_tx_a_i_phy     ,
    modem_tx_a_q_phy     => modem_tx_a_q_phy     ,
	
	agc_lock_i_debug           => agc_lock_i_debug ,
    agc_rise_i_debug           => agc_rise_i_debug,
    agc_fall_i_debug           => agc_fall_i_debug ,
    
    cs_a_high_i_debug          => cs_a_high_i_debug ,
    cs_a_low_i_debug           => cs_a_low_i_debug ,
    cs_b_high_i_debug          => cs_b_high_i_debug ,
    cs_b_low_i_debug           => cs_b_low_i_debug ,
    cs_flag_nb_i_debug         => cs_flag_nb_i_debug ,
    cs_flag_valid_i_debug      => cs_flag_valid_i_debug
    -- -----------------------end ---------------------------------------
  );

  -- ---------------------------------------------------------------------------
  -- Radio controller for MAX2830
  -- ---------------------------------------------------------------------------
  radioctrl_maxair_1 : radioctrl_maxair
  port map
  (
    -- -------------------------------------------------------------------------
    -- system
    -- -------------------------------------------------------------------------
    reset_n             => bus_clk_resetn,
    clk                 => plf_clk,
    
    -- -------------------------------------------------------------------------
    -- APB
    -- -------------------------------------------------------------------------
    psel                => psel_radio,
    penable             => penable,
    pwrite              => pwrite,
    paddr               => paddr(6 downto 0),
    pwdata              => pwdata,
    prdata              => prdata_radio,
 
    -- -------------------------------------------------------------------------
    -- Radio 3 wires interface
    -- -------------------------------------------------------------------------
    ana_3wclk           => anaif_bb_spi_clk_i,
    ana_3wdataout       => anaif_bb_spi_wdata_i,
    ana_3wdataen        => anaif_bb_spi_en_i,

    -------------------------------------------
    -- Analog interface
    -------------------------------------------
    -- ADC control
    adc_pwron           => anaif_bb_adc_pwron,
    adc_rxen            => adc_rxen,
    force_adc_clk       => force_adc_clk,
    -- DAC control
    dac_pwron           => anaif_bb_dac_pwron,
    dac_txen            => dac_txen,
    force_dac_clk       => force_dac_clk,
    -- RSSI ADC control
    rf_rssi             => anaif_rssi,
    --
    rssiadc_pwron       => anaif_bb_rssiadc_pwron,
    rssiadc_rxen        => anaif_bb_rssiadc_rxen,
    rssi_gclk           => rssi_gclk,

    -- -------------------------------------------------------------------------
    -- Radio interface
    -- -------------------------------------------------------------------------
    lock_detect         => anaif_lock_det,
    --
    rxen                => anaif_bb_rx_en_i,        
    txen                => anaif_bb_tx_en_i,              
    paon2g              => anaif_bb_24gpa_on_i,           
    paon5g              => anaif_bb_5gpa_on_i,           
    gaincontrol         => anaif_tx_plc_i,       
    shutdown            => anaif_bb_shutdown_i,          
    antsel              => anaif_bb_jmp_ant_selb,
    rxhp                => anaif_bb_rxhp,

    -- -------------------------------------------------------------------------
    -- AGC/CCA
    -- -------------------------------------------------------------------------
    agc_rxonoff_req     => agc_rxonoff_req, --(in) from modem802_11g_maxim
    agc_rxonoff_conf    => agc_rxonoff_conf,--(in) from modem802_11g_maxim
    agc_bb_on           => agc_bb_on,       --(out) to  modem802_11g_maxim
    agc_busy            => agc_busy,        --(in) from modem802_11g_maxim
    agc_lock            => agc_lock,        --(in) from modem802_11g_maxim
    agc_rise            => agc_rise,        --(in) from modem802_11g_maxim
    rxv_rxant           => rxv_rxant,
    rx_gain_control     => rx_gain_control,
    rx_ic_gain          => rx_ic_gain_i,
    switch_antenna      => switch_antenna_i,--(in) from modem802_11g_maxim
    rxhp_radio          => rxhp_radio_i,

    -- -------------------------------------------------------------------------
    -- RW_WLAN MODEM
    -- -------------------------------------------------------------------------
    -- Common to both modems
    phy_rxstartend_ind  => phy_rxstartend_ind,--(in) from modem802_11g_maxim
    -- OFDM modem
    a_txend_preamble    => a_txend_preamble,  --(in) from modem802_11g_maxim
    a_txonoff_req       => a_txonoff_req,     --(in) from modem802_11g_maxim
    a_txonoff_conf      => a_txonoff_conf,    --(out) to  modem802_11g_maxim
    -- DSSS/CCK modem
    b_txend_preamble    => b_txend_preamble,  --(in) from modem802_11g_maxim 
    b_txonoff_req       => b_txonoff_req,     --(in) from modem802_11g_maxim
    b_txonoff_conf      => b_txonoff_conf,    --(out) to  modem802_11g_maxim

    -- -------------------------------------------------------------------------
    -- BuP
    -- -------------------------------------------------------------------------
    txpwr_level         => txpwr_level,       --(in) from bup2_kernel
    txv_immstop         => txv_immstop,  
    txv_txant           => txv_txant,         --(in) from bup2_kernel

    -- ------------------------------------------------------------------------
    -- Deep sleep
    -- ------------------------------------------------------------------------
    clock_switched      => clock_switched,
    clk_div             => clk_div,
    --
    rf_en_force         => '0'
   );
  
  anaif_bb_spi_clk              <= anaif_bb_spi_clk_i;
  anaif_bb_spi_en               <= anaif_bb_spi_en_i;
  anaif_bb_spi_wdata            <= anaif_bb_spi_wdata_i;
  anaif_bb_rx_en                <= anaif_bb_rx_en_i;
  anaif_bb_tx_en                <= anaif_bb_tx_en_i;
  anaif_bb_24gpa_on             <= anaif_bb_24gpa_on_i;
  anaif_bb_5gpa_on              <= anaif_bb_5gpa_on_i;
  anaif_tx_plc                  <= anaif_tx_plc_i;
  anaif_bb_shutdown             <= anaif_bb_shutdown_i;
  
  -- ADC / DAC clock gating and standby control
  dac_gating_i                  <= dac_gating_mdm and not force_dac_clk;
  adc_gating_i                  <= adc_gating_mdm and not force_adc_clk;
  dac_gating                    <= dac_gating_i;
  adc_gating                    <= adc_gating_i;
  anaif_bb_dac_txen             <= (not dac_gating_mdm) or dac_txen;
  anaif_bb_adc_rxen             <= (not adc_gating_mdm) or adc_rxen;


  -- -------------------------------------------------------------------------
  -- ----------------------- just for debug ----------------------------------
  -- -------------------------------------------------------------------------

    resync_80to60_1:resync_80to60
    port map
    (
      -- -------------------------------------------------------------------------
      -- 80 MHz write domain
      -- -------------------------------------------------------------------------
      resetn80m    => external_resetn,
      clk80m       => clk_80m,
      enable80m    => '1',--(in) from modem802_11g_core
      i80m         => modem_rx_a_i_phy,     --(in) from modem802_11g_core
      q80m         => modem_rx_a_q_phy,     --(in) from modem802_11g_core
      toggle80m    => modem_rx_a_tog,--(in) from modem802_11g_core
    
      -- -------------------------------------------------------------------------
      -- 60 MHz write domain
      -- -------------------------------------------------------------------------
      resetn60m    => external_resetn,
      clk60m       => clk_60m,
      enable60m    => modem_rx_a_active_60m, --(out) to frontend_maxim 
      i60m         => modem_rx_a_i_60m,      --(out) to frontend_maxim 
      q60m         => modem_rx_a_q_60m,      --(out) to frontend_maxim 
      toggle60m    => modem_rx_a_toggle_60m  --(out) to frontend_maxim 
    );
  
    -- In-Band Delay Line
  inbd_delay_line_1 : inbd_delay_line
  generic map (
    data_in_g       => 14,
    data_est_size_g => 11,
    data_out_g      => 10
  )
  port map (
    ---------------------------------
    -- Inputs Declaration
    ---------------------------------
    clk             => clk_60m,
    reset_n         => external_resetn,
    agc_inbd_pow_en => '1',   --(in) from outside <= agc :Enable from AGC FSM
    modem_rx_a_i_60m  => modem_rx_a_i_60m,--(in) from dc_off_dloop
    modem_rx_a_q_60m  => modem_rx_a_q_60m,--(in) from dc_off_dloop
    en_20m_i        => en_20m_i,      --(in) from dc_off_dloop   :20 MHz data enable input

    ---------------------------------
    -- Outputs Declaration
    ---------------------------------
    i_inbd          =>  i_inbd_i,     --(out) to  ofdm_corr and inbd_power_est
    q_inbd          =>  q_inbd_i,     --(out) to  ofdm_corr and inbd_power_est
    i_inbd_ff1      =>  i_inbd_ff1_i, --(out) to  ofdm_corr 
    q_inbd_ff1      =>  q_inbd_ff1_i, --(out) to  ofdm_corr 
    i_inbd_ff2      =>  i_inbd_ff2_i, --(out) to  ofdm_corr 
    q_inbd_ff2      =>  q_inbd_ff2_i, --(out) to  ofdm_corr 
    i_inbd_ff3      =>  i_inbd_ff3_i, --(out) to  ofdm_corr 
    q_inbd_ff3      =>  q_inbd_ff3_i, --(out) to  ofdm_corr 
    i_inbd_ff4      =>  i_inbd_ff4_i, --(out) to  ofdm_corr 
    q_inbd_ff4      =>  q_inbd_ff4_i, --(out) to  ofdm_corr 
    i_inbd_ff5      =>  i_inbd_ff5_i, --(out) to  ofdm_corr 
    q_inbd_ff5      =>  q_inbd_ff5_i, --(out) to  ofdm_corr 
    i_inbd_ff6      =>  i_inbd_ff6_i, --(out) to  ofdm_corr 
    q_inbd_ff6      =>  q_inbd_ff6_i, --(out) to  ofdm_corr 
    i_inbd_ff7      =>  i_inbd_ff7_i, --(out) to  ofdm_corr 
    q_inbd_ff7      =>  q_inbd_ff7_i, --(out) to  ofdm_corr 
    i_inbd_ff8      =>  i_inbd_ff8_i, --(out) to  ofdm_corr 
    q_inbd_ff8      =>  q_inbd_ff8_i, --(out) to  ofdm_corr 
    i_inbd_ff9      =>  i_inbd_ff9_i, --(out) to  ofdm_corr 
    q_inbd_ff9      =>  q_inbd_ff9_i, --(out) to  ofdm_corr 
    i_inbd_ff10     =>  i_inbd_ff10_i,--(out) to  ofdm_corr 
    q_inbd_ff10     =>  q_inbd_ff10_i,--(out) to  ofdm_corr 
    i_inbd_ff11     =>  i_inbd_ff11_i,--(out) to  ofdm_corr 
    q_inbd_ff11     =>  q_inbd_ff11_i,--(out) to  ofdm_corr 
    i_inbd_ff12     =>  i_inbd_ff12_i,--(out) to  ofdm_corr 
    q_inbd_ff12     =>  q_inbd_ff12_i,--(out) to  ofdm_corr 
    i_inbd_ff13     =>  i_inbd_ff13_i,--(out) to  ofdm_corr 
    q_inbd_ff13     =>  q_inbd_ff13_i,--(out) to  ofdm_corr 
    i_inbd_ff14     =>  i_inbd_ff14_i,--(out) to  ofdm_corr 
    q_inbd_ff14     =>  q_inbd_ff14_i,--(out) to  ofdm_corr 
    i_inbd_ff15     =>  i_inbd_ff15_i,--(out) to  ofdm_corr 
    q_inbd_ff15     =>  q_inbd_ff15_i,--(out) to  ofdm_corr 
    i_inbd_ff16     =>  i_inbd_ff16_i,--(out) to  ofdm_corr 
    q_inbd_ff16     =>  q_inbd_ff16_i,--(out) to  ofdm_corr 
    i_inbd_ff32     =>  i_inbd_ff32_i,--(out) to  ofdm_corr 
    q_inbd_ff32     =>  q_inbd_ff32_i,--(out) to  ofdm_corr 
    i_inbd_ff64     =>  i_inbd_ff64_i,--(out) to  ofdm_corr 
    q_inbd_ff64     =>  q_inbd_ff64_i --(out) to  ofdm_corr 
  );
  

  -- In-Band Power Estimator
  inbd_power_est_1 : inbd_power_est
  generic map (
    data_in_g  => 10,
    data_out_g => 21
  )
  port map (
    ---------------------------------
    -- Inputs Declaration
    ---------------------------------
    clk             => clk_60m,
    reset_n         => external_resetn,
    en_20m_i        => en_20m_i,   --(in) from dc_off_dloop   :20 MHz data enable input
    agc_inbd_pow_en => '1',--(in) from outside <= agc :Enable from AGC FSM
    i_inbd          => i_inbd_i,       --(in) from inbd_delay_line
    q_inbd          => q_inbd_i,       --(in) from inbd_delay_line
    i_inbd_ff64     => i_inbd_ff64_i,  --(in) from inbd_delay_line
    q_inbd_ff64     => q_inbd_ff64_i,  --(in) from inbd_delay_line

    ---------------------------------
    -- Outputs Declaration
    ---------------------------------
    dp_inbd_lin     => dp_inbd_lin_i   --(out) to  dbvrms_conv
  );
  
--    -- OFDM Correlator
  ofdm_corr_1 : ofdm_corr
  generic map (
    data_in_g  => 10,
    data_out_g => 14
  )
  port map (
    ----------------------------------
    -- Inputs Declaration
    ----------------------------------
    clk            => clk_60m,
    reset_n        => external_resetn,
    agc_ca_en      => "01",
    en_20m_i       => en_20m_i,     --(in) from dc_off_dloop    :20 MHz data enable input
    i_inbd         => i_inbd_i,     --(in) from inbd_delay_line
    q_inbd         => q_inbd_i,     --(in) from inbd_delay_line
    i_inbd_ff1     => i_inbd_ff1_i, --(in) from inbd_delay_line
    q_inbd_ff1     => q_inbd_ff1_i, --(in) from inbd_delay_line
    i_inbd_ff2     => i_inbd_ff2_i, --(in) from inbd_delay_line
    q_inbd_ff2     => q_inbd_ff2_i, --(in) from inbd_delay_line
    i_inbd_ff3     => i_inbd_ff3_i, --(in) from inbd_delay_line
    q_inbd_ff3     => q_inbd_ff3_i, --(in) from inbd_delay_line
    i_inbd_ff4     => i_inbd_ff4_i, --(in) from inbd_delay_line
    q_inbd_ff4     => q_inbd_ff4_i, --(in) from inbd_delay_line
    i_inbd_ff5     => i_inbd_ff5_i, --(in) from inbd_delay_line
    q_inbd_ff5     => q_inbd_ff5_i, --(in) from inbd_delay_line
    i_inbd_ff6     => i_inbd_ff6_i, --(in) from inbd_delay_line
    q_inbd_ff6     => q_inbd_ff6_i, --(in) from inbd_delay_line
    i_inbd_ff7     => i_inbd_ff7_i, --(in) from inbd_delay_line
    q_inbd_ff7     => q_inbd_ff7_i, --(in) from inbd_delay_line
    i_inbd_ff8     => i_inbd_ff8_i, --(in) from inbd_delay_line
    q_inbd_ff8     => q_inbd_ff8_i, --(in) from inbd_delay_line
    i_inbd_ff9     => i_inbd_ff9_i, --(in) from inbd_delay_line
    q_inbd_ff9     => q_inbd_ff9_i, --(in) from inbd_delay_line
    i_inbd_ff10    => i_inbd_ff10_i,--(in) from inbd_delay_line
    q_inbd_ff10    => q_inbd_ff10_i,--(in) from inbd_delay_line
    i_inbd_ff11    => i_inbd_ff11_i,--(in) from inbd_delay_line
    q_inbd_ff11    => q_inbd_ff11_i,--(in) from inbd_delay_line
    i_inbd_ff12    => i_inbd_ff12_i,--(in) from inbd_delay_line
    q_inbd_ff12    => q_inbd_ff12_i,--(in) from inbd_delay_line
    i_inbd_ff13    => i_inbd_ff13_i,--(in) from inbd_delay_line
    q_inbd_ff13    => q_inbd_ff13_i,--(in) from inbd_delay_line
    i_inbd_ff14    => i_inbd_ff14_i,--(in) from inbd_delay_line
    q_inbd_ff14    => q_inbd_ff14_i,--(in) from inbd_delay_line
    i_inbd_ff15    => i_inbd_ff15_i,--(in) from inbd_delay_line
    q_inbd_ff15    => q_inbd_ff15_i,--(in) from inbd_delay_line
    i_inbd_ff16    => i_inbd_ff16_i,--(in) from inbd_delay_line
    q_inbd_ff16    => q_inbd_ff16_i,--(in) from inbd_delay_line
    i_inbd_ff32    => i_inbd_ff32_i,--(in) from inbd_delay_line
    q_inbd_ff32    => q_inbd_ff32_i,--(in) from inbd_delay_line
    i_inbd_ff64    => i_inbd_ff64_i,--(in) from inbd_delay_line
    q_inbd_ff64    => q_inbd_ff64_i,--(in) from inbd_delay_line

    ----------------------------------
    -- Outputs Declaration
    ----------------------------------
    ca_rl          => ca_rl_agc,    --(out) to  outside => agc_1
    ca_ac          => ca_ac_agc,    --(out) to  outside => agc_1
    ca_cc          => ca_cc_agc     --(out) to  outside => agc_1

  );  
  ------------------------
  -- OFDM Detector
  ------------------------
  ofdm_det_1 : ofdm_det
  generic map (
    ca_ac_w_g => 14, -- (natural)
    ca_cc_w_g => 14, -- (natural)
    ca_rl_w_g => 14  -- (natural)
  )
  port map ( 
    reset_n          => external_resetn,          -- (in)
    clk              => clk_60m,              -- (in)
    en_20m           => en_20m_i,           -- (in) from outside <= cca
    ca_en            => "01",          -- (in) from agc_fsm
    ca_ac            => ca_ac_agc,            -- (in) from outside <= agc_sp
    ca_cc            => ca_cc_agc,            -- (in) from outside <= agc_sp
    ca_rl            => ca_rl_agc,            -- (in) from outside <= agc_sp
    reg_thr_ac_plat  => reg_thr_ac_plat,  -- (in) from outside <= regbank
    reg_thr_cc_plat  => reg_thr_cc_plat,  -- (in) from outside <= regbank
    reg_mix_acc_plat => reg_mix_acc_plat, -- (in) from outside <= regbank
    reg_thr_ac_cs2   => reg_thr_ac_cs2,   -- (in) from outside <= regbank
    reg_thr_cc_cs2   => reg_thr_cc_cs2,   -- (in) from outside <= regbank
    reg_cc_peak_cs2  => reg_cc_peak_cs2,  -- (in) from outside <= regbank
    reg_mix_acc_cs2  => reg_mix_acc_cs2,  -- (in) from outside <= regbank
                                                                                              
    ca_det           => ca_det_i,         -- (out) to  plat_search and cs_flags_gen
    ca_rlw           => ca_rlw_i,         -- (out) to  cs_flags_gen
    ca_ac_out        => ca_ac_out_i       -- (out) to  cs_flags_gen
  );  
  
  cs_flags_gen_1 : cs_flags_gen
  generic map (
    ca_ac_w_g => 14, -- (natural)
    cb_bc_w_g => 22  -- (natural)
  )
  port map ( 
    reset_n              => external_resetn,              -- (in)
    clk                  => clk,                  -- (in)
    cs_flag_en           => '1',         -- (in)
    flag_state           => flag_state_i,         -- (in)
    ca_det               => ca_det_i,             -- (in)
    ca_rlw               => ca_rlw_i,             -- (in)
    ca_ac                => ca_ac_out_i,          -- (in)
    cb_det               => open,             -- (in)
    cb_rlw               => open,             -- (in)
    cb_bc                => open,          -- (in)
    reg_thr_ca_ratio_cs1 => reg_thr_ca_ratio_cs1, -- (in)
    reg_thr_ca_ratio_cs2 => reg_thr_ca_ratio_cs2, -- (in)
    reg_thr_ca_ratio_cs3 => reg_thr_ca_ratio_cs3, -- (in)
    reg_thr_cb_ratio_cs3 => open, -- (in)
    reg_cs1_a_high_force => reg_cs1_a_high_force, -- (in)
    reg_cs1_a_high_val   => reg_cs1_a_high_val,   -- (in)
    reg_cs1_a_low_force  => reg_cs1_a_low_force,  -- (in)
    reg_cs1_a_low_val    => reg_cs1_a_low_val,    -- (in)
    reg_cs2_a_high_force => reg_cs2_a_high_force, -- (in)
    reg_cs2_a_high_val   => reg_cs2_a_high_val,   -- (in)
    reg_cs2_a_low_force  => reg_cs2_a_low_force,  -- (in)
    reg_cs2_a_low_val    => reg_cs2_a_low_val,    -- (in)
    reg_cs3_a_high_force => reg_cs3_a_high_force, -- (in)
    reg_cs3_a_high_val   => reg_cs3_a_high_val,   -- (in)
    reg_cs3_a_low_force  => reg_cs3_a_low_force,  -- (in)
    reg_cs3_a_low_val    => reg_cs3_a_low_val,    -- (in)
    reg_cs3_b_high_force => reg_cs3_b_high_force, -- (in)
    reg_cs3_b_high_val   => reg_cs3_b_high_val,   -- (in)
    reg_cs3_b_low_force  => reg_cs3_b_low_force,  -- (in)
    reg_cs3_b_low_val    => reg_cs3_b_low_val,    -- (in)
    reg_cs3_g_force      => reg_cs3_g_force,      -- (in)
                               
    cs_flag_valid        => cs_flag_valid_i,      -- (out)
    cs_flag_nb           => cs_flag_nb,           -- (out)
    cs_a_high            => cs_a_high_d,            -- (out)
    cs_a_low             => cs_a_low_d,             -- (out)
    cs_b_high            => open,            -- (out)
    cs_b_low             => open,             -- (out)
    cs_b_gt_a            => open             -- (out)
    );
  
  
  

end architecture rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
