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
 
 library work：
--library modem802_11g_maxim_rtl;
--library stream_processor_rtl;
--library radioctrl_maxair_rtl;
--library bup2_kernel_rtl;

--library clockreset_maxim_rtl;

--library commonlib;
library work
use commonlib.mdm_math_func_pkg.all;

--library rw_wlanbb_11g_maxim_rtl;
library work
use rw_wlanbb_11g_maxim_rtl.rw_wlanbb_11g_maxim_pkg.all;

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
   pll_clk                : in std_logic;           --   240MHz HiSS clock, from RW_WLAN RF
   -- for Analog IF from Ext. PL
   osc_clk                : in std_logic;           --   32kHz clock from from oscillator
   pci_clk                : in std_logic;           --   33MHz MiniPCI/CardBus clock
   clk_240_96             : in std_logic;           -- muxed 240/96 clock
  -- -------------------------------------------------------------------------
  -- Clocks & Reset               
  -- -------------------------------------------------------------------------
    bus_clk_resetn_o    : out std_logic;  --  => bus_clk_resetn_i,
    bus_clk_reset_o     : out std_logic;  --  => bus_clk_reset_i,
    cclk_resetn_o       : out std_logic;  -- -- Reset for External System Bridge
    --                  out std_logic;  --  
    bus_clk_o           : out std_logic;  --  => bus_clk_i,    
    bus_gclk_o          : out std_logic;  --  => bus_gclk_i,   
    bus_gclk_n_o        : out std_logic;  --  => bus_gclk_n_i, 
    cclk_o              : out std_logic;  --  => cclk_i,
    cclk_n_o            : out std_logic;  --  => cclk_n_i, 
    
    dac_gclk            : out std_logic;  -- 60 MHz clk to DAC
    adc_gclk            : out std_logic;  -- 60 MHz clk to ADC  
    enable_7mhz         : out std_logic;  -- enable signal at 7 MHz for UART
    a7s_gclk              : out std_logic;
    mem_rst_n_o             : out std_logic; 
    --------------------------------------
    -- Clock Reset block interface
    -------------------------------------- 
    -- Signals for clock gating enable.
    bus_gating           : in std_logic;  --  => bus_gating,          
    a7s_gating           : in std_logic;  --  => a7s_gating,          
    strp_gating          : in std_logic;  --  => strp_gating,         
    modema_clkforce      : in std_logic;  --  => modema_clkforce,     
    modema_gating        : in std_logic;  --  => modema_gating,       
    modemb_clkforce      : in std_logic;  --  => modemb_clkforce,     
    modemb_gating        : in std_logic;  --  => modemb_gating,         
    set_osc32ken_i       : in std_logic;  --  => set_osc32ken_i, 
    
    -- Clock controls
    clkcntl_out_o        : out std_logic_vector(1 downto 0);  ---  => clkcntl_out_i,
    clkcntl_update_o     : out std_logic;  ---  => clkcntl_update_i,
    osc32ken_o           : out std_logic;  ---  => osc32ken_i,
    --
    reg_en_hisslp        : in std_logic;  --  => reg_en_hisslp_i,
    -- clock selection
    reg_44_80_cntl       : in std_logic;  --  => reg_44_80_cntl,      
    reg_manwkup          : in std_logic;  --  => reg_manwkup_i,
    -- Startup frequency of the radio
    reg_rffreq_whole     : in std_logic;  --  => open, 
    reg_rffreq_frac      : in std_logic;  --  => open,
    -- max value of the rf_reset_n counter
    reg_rfcount_max      : in std_logic_vector(8 downto 0);  --  => reg_rfcount_max,
    reg_clkcntl_update   : in std_logic;  --  => reg_clkcntl_update,
    reg_clkcntl          : in std_logic_vector(1 downto 0);  --  => reg_clkcntl,
    radio_if_wakeup      : in std_logic;  --  => radio_if_wakeup,
                          
    -- Reset controls.    
    swreset              : in std_logic; --  => swreset,             
    pmreset              : in std_logic; --  => pmreset,
    -- Signals for reset status.
    wdreset_stat         : out std_logic; --  => wdreset_stat,        
    swreset_stat         : out std_logic; --  => swreset_stat,        
    pmreset_stat         : out std_logic; --  => pmreset_stat,
    extreset_stat        : out std_logic; --  => extreset_stat,       
    -- Watchdog Timer
    wd_enable            : in  std_logic; --  => wd_enable,           -- Enables WDT           
    wd_div               : in  std_logic_vector(6 downto 0); --  => wd_div,              -- Selects WDT period    
    wd_stroke            : in  std_logic; --  => wd_stroke,           -- Strokes WDT
    -- -------------------------------------------------------------------------  
    -- Misc                                                                       
    -- -------------------------------------------------------------------------                                             
    refclk_req            : out std_logic; -- Reference clock request.
    clk32_select_out      : out std_logic;   
    -- ------------------------------------------------------------------------
    -- Test Signals
    -- -----------------------------------------------------------
    -- For at speed scan, a scan clock must be provided for each clock domain
    scan_hissclk          : in  std_logic;
    scan_oscclk           : in  std_logic;
    scan_pciclk           : in  std_logic;
    scan_80clk            : in  std_logic;
    scan_44clk            : in  std_logic;
    scan_60clk            : in  std_logic;
    --
    scan_hissclk_sel      : in  std_logic;
    scan_oscclk_sel       : in  std_logic;
    scan_pciclk_sel       : in  std_logic;
    scan_80clk_sel        : in  std_logic;
    scan_44clk_sel        : in  std_logic;
    scan_60clk_sel        : in  std_logic;
    --
    reset_direct          : in  std_logic;
    reset_under_test      : in  std_logic;
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
    
    -- -------------------------------------------------------------------------  
    -- Diagnostic port:
    -- -------------------------------------------------------------------------  
    modem_diag0            : out std_logic_vector(15 downto 0);
    modem_diag1            : out std_logic_vector(15 downto 0);
    modem_diag2            : out std_logic_vector(15 downto 0);
    modem_diag3            : out std_logic_vector(15 downto 0);
    modem_diag4            : out std_logic_vector(15 downto 0);
    modem_diag5            : out std_logic_vector(15 downto 0);
    modem_diag6            : out std_logic_vector(15 downto 0);
    modem_diag7            : out std_logic_vector(15 downto 0);
    modem_diag8            : out std_logic_vector(15 downto 0);
    modem_diag9            : out std_logic_vector(15 downto 0);
    modem_diag10           : out std_logic_vector(15 downto 0);
    modem_diag11           : out std_logic_vector(15 downto 0);
    modem_diag12           : out std_logic_vector(15 downto 0);
    modem_diag13           : out std_logic_vector(15 downto 0);
    stream_proc_diag       : out std_logic_vector(31 downto 0);
    radio_ctrl_diag0       : out std_logic_vector(15 downto 0);
    radio_ctrl_diag1       : out std_logic_vector(15 downto 0);
    bup_diag0              : out std_logic_vector(15 downto 0);
    bup_diag1              : out std_logic_vector(15 downto 0);
    bup_diag2              : out std_logic_vector(15 downto 0);
    bup_diag3              : out std_logic_vector(15 downto 0);
    agc_cca_diag0          : out std_logic_vector(15 downto 0);
    
    clockreset_diag0       : out std_logic_vector(15 downto 0);
    clockreset_diag1       : out std_logic_vector(15 downto 0);
    clockreset_diag2       : out std_logic_vector(15 downto 0);
    clockreset_diag3       : out std_logic_vector(15 downto 0);

    --------------------------------------
    -- WLAN Indication
    --------------------------------------
    wlanrxind              : out std_logic;
	
	-- ----------------------------------------------
	-- -----------------debug------------------------  
	-- ----------------------------------------------
	
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
    txv_immstop          : in std_logic;
    
    clk_80m              : out std_logic;
     
    plf_clk              : in std_logic
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
  bus_clk_resetn_o <= bus_clk_resetn;
  bus_clk_o            <= bus_clk;    -- Bus clock not gated 
  bus_gclk_o          <= bus_gclk;  -- Bus system gated clock    
  
  -- ---------------------------------------------------------------------
  -- -----------------------------debug-----------------------------------
  -- ---------------------------------------------------------------------
  -- tx
  phy_data_conf_debug <= phy_data_conf;
  bup_txdata_debug    <= bup_txdata;
  -- rx
  phy_data_ind_debug  <= phy_data_ind;
  bup_rxdata_debug    <= bup_rxdata;
  
  clk_80m             <= tx_path_a_gclk;
  
  rxv_length_debug       <= rxv_length;
  rxv_service_debug      <=  rxv_service;
  rxv_service_ind_debug  <=  rxv_service_ind;
  rxv_datarate_debug     <=  rxv_datarate;
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
    modem_diag0             => modem_diag0,
    modem_diag1             => modem_diag1,
    modem_diag2             => modem_diag2,
    modem_diag3             => modem_diag3,
    modem_diag4             => modem_diag4,
    modem_diag5             => modem_diag5,
    modem_diag6             => modem_diag6,
    modem_diag7             => modem_diag7,
    modem_diag8             => modem_diag8,
    modem_diag9             => modem_diag9,
    modem_diag10            => modem_diag10,
    modem_diag11            => modem_diag11,
    modem_diag12            => modem_diag12,
    modem_diag13            => modem_diag13,
    agc_cca_diag0	        => agc_cca_diag0,
	
	-- ------------------------- debug -------------------------------------
	modem_rx_a_toggle_80m_debug=> modem_rx_a_toggle_80m_debug,
	modem_rx_a_i_80m_debug     => modem_rx_a_i_80m_debug     ,
	modem_rx_a_q_80m_debug     => modem_rx_a_q_80m_debug     ,
	
	modem_tx_a_toggle_80m_debug=> modem_tx_a_toggle_80m_debug,
    modem_tx_a_i_80m_debug     => modem_tx_a_i_80m_debug     ,
    modem_tx_a_q_80m_debug     => modem_tx_a_q_80m_debug     ,
	
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
  -- Stream processing
  -- ---------------------------------------------------------------------------
--  stream_processor_1: stream_processor
--  generic map 
--  (
--    aes_enable_g => 1 -- Enables AES. (0=RC4 only,1=AES+RC4,2=AES only)
--  )
--  port map 
--  (
--    --------------------------------------------                               
--    -- Clocks and resets                                                       
--    --------------------------------------------                               
--    clk       => strp_gclk,          -- AHB and APB clock.                     
--    reset_n   => bus_clk_resetn,     -- AHB and APB reset.                     
--    --------------------------------------------                               
--    -- AHB Master                                                              
--    --------------------------------------------                               
--    hgrant    => hgrant_streamproc,  --(in) from outside :Bus grant.                             
--    hready    => hready,             --(in) from outside :AHB Slave ready.                       
--    hresp     => hresp,              --(in) from outside :AHB Transfer response.                 
--    hrdata    => hrdata,             --(in) from outside :AHB Read data bus.                     
--    --                                                                         
--    hbusreq   => hbusreq_streamproc, --(out) to  outside :Bus request.                           
--    hlock     => hlock_streamproc,   --(out) to  outside :Locked transfer.                       
--    htrans    => htrans_streamproc,  --(out) to  outside :AHB Transfer type.                     
--    haddr     => haddr_streamproc,   --(out) to  outside :AHB Address.                           
--    hwrite    => hwrite_streamproc,  --(out) to  outside :Transfer direction. 1=>Write;0=>Read.  
--    hsize     => hsize_streamproc,   --(out) to  outside :AHB Transfer size.                     
--    hburst    => hburst_streamproc,  --(out) to  outside :AHB Burst information.                 
--    hprot     => hprot_streamproc,   --(out) to  outside :Protection information.                
--    hwdata    => hwdata_streamproc,  --(out) to  outside :AHB Write data bus.                    
--    --------------------------------------------                               
--    -- APB Slave                                                               
--    --------------------------------------------                               
--    paddr     => paddr(4 downto 0),  --(in) from outside :APB Address.               
--    psel      => psel_streamproc,    --(in) from outside :Selection line.                        
--    pwrite    => pwrite,             --(in) from outside :0 => Read; 1 => Write.                 
--    penable   => penable,            --(in) from outside :APB enable line.                       
--    pwdata    => pwdata,             --(in) from outside :APB Write data bus.                    
--    --                                                                         
--    prdata    => prdata_streamproc,  --(out) to  outside :APB Read data bus.                     
--    --------------------------------------------                               
--    -- Interrupt line                                                          
--    --------------------------------------------                               
--    interrupt => stream_proc_irq,    -- Interrupt line.                        
--    --------------------------------------------                               
--    -- AES SRAM:                                                               
--    --------------------------------------------                               
--    aesram_di_o  => aesram_di_o,     -- Data to be written.                    
--    aesram_a_o   => aesram_a_o,      -- Address.                               
--    aesram_rw_no => aesram_rw_no,    -- Write Enable. Inverted logic.          
--    aesram_cs_no => aesram_cs_no,    -- Chip Enable. Inverted logic.           
--    aesram_do_i  => aesram_do_i,     -- Data read.                             
--    --------------------------------------------                               
--    -- RC4 SRAM:                                                               
--    --------------------------------------------                               
--    rc4ram_di_o  => rc4ram_di_o,     -- Data to be written.                    
--    rc4ram_a_o   => rc4ram_a_o,      -- Address.                               
--    rc4ram_rw_no => rc4ram_rw_no,    -- Write Enable. Inverted logic.          
--    rc4ram_cs_no => rc4ram_cs_no,    -- Chip Enable. Inverted logic.           
--    rc4ram_do_i  => rc4ram_do_i,     -- Data read.                             
--    --------------------------------------------                               
--    -- Test Vector:                                                            
--    --------------------------------------------                               
--    test_vector  => stream_proc_diag -- test vectors.                          
--    );


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
    clk                 => bus_gclk,
    
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
    rf_en_force         => rf_en_force
   );
  
  radio_ctrl_diag0(15)          <= anaif_bb_spi_clk_i;
  radio_ctrl_diag0(14)          <= anaif_bb_spi_en_i;
  radio_ctrl_diag0(13)          <= anaif_bb_spi_wdata_i;
  radio_ctrl_diag0(12)          <= anaif_bb_rx_en_i;
  radio_ctrl_diag0(11)          <= anaif_bb_tx_en_i;
  radio_ctrl_diag0(10)          <= anaif_bb_24gpa_on_i;
  radio_ctrl_diag0(9)           <= anaif_bb_5gpa_on_i;
  radio_ctrl_diag0(8 downto 2)  <= anaif_tx_plc_i;
  radio_ctrl_diag0(1)           <= anaif_bb_shutdown_i;
  radio_ctrl_diag0(0)           <= anaif_lock_det;
  
  radio_ctrl_diag1(15)          <= agc_rxonoff_req;
  radio_ctrl_diag1(14)          <= agc_rxonoff_conf;
  radio_ctrl_diag1(13)          <= a_txonoff_req;
  radio_ctrl_diag1(12)          <= a_txonoff_conf;
  radio_ctrl_diag1(11)          <= b_txonoff_req;
  radio_ctrl_diag1(10)          <= b_txonoff_conf;
  radio_ctrl_diag1(9 downto 3)  <= txpwr_level;
  radio_ctrl_diag1(2)           <= dac_gating_i;
  radio_ctrl_diag1(1)           <= adc_gating_i;
  radio_ctrl_diag1(0)           <= agc_bb_on;
  
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


  -- ---------------------------------------------------------------------------
  -- Clock and reset
  -- ---------------------------------------------------------------------------
  clockreset_maxim_1:clockreset_maxim
  generic map
  (
    fpga_g              => fpga_g, --fpga_g,
    wdt_div_g           => wdt_div_g,
    gate_arm_in_fpga    => gate_arm_in_fpga,
    gate_ofdm_in_fpga   => gate_ofdm_in_fpga,
    use_clkskip_in_fpga => use_clkskip_in_fpga,
    rf_cnt_size_g       => rf_cnt_size_g
  )
  port map
  (
    -- -------------------------------------------------------------------------
    -- incoming reset
    -- -------------------------------------------------------------------------
    extreset18_n          => external_resetn,  --(in) from outside :1.8V external reset pin
    crstn                 => crstn,            --(in) from outside :reset from CardBus for PCI bridge
    -- -------------------------------------------------------------------------
    -- incoming clocks
    -- -------------------------------------------------------------------------
    hissclk               => pll_clk,    --(in) from outside  :240MHz HiSS clock, from RW_WLAN RF
                                         --(in) from outside  :for Analog IF from Ext. PLL
    oscclk                => osc_clk,    --(in) from outside  :32kHz clock from from oscillator
    pciclk                => pci_clk,    --(in) from outside  :33MHz MiniPCI/CardBus clock
    clk_240_96            => clk_240_96, --(in) from outside  :muxed 240/96 clock
    -- -------------------------------------------------------------------------
    -- outgoing resets
    -- -------------------------------------------------------------------------
    reset_n               => bus_clk_resetn,   --_i, --Reset for chip and processor
                                               --(synch to bus_clk, bus_gclk)   
    reset                 => bus_clk_reset_o,  -- Active HIGH reset for blocks
    mem_rst_n             => mem_rst_n_o,      -- Reset for (flash) memory
    pcibridge_resetn      => cclk_resetn_o,    -- Reset for External System Bridge
    hiss_reset_n          => open,             -- Reset for Radio Controller (HiSS case)
    rf_reset_n            => open,
    modema_clk_resetn     => modema_clk_resetn,-- Reset for 11a Modem 
    modemb_clk_resetn     => modemb_clk_resetn,-- Reset for 11b Modem 
    sampling_clk_resetn   => sampling_clk_resetn,--_i, -- Reset for AGC/Correlator Control
    frontend_clk44_resetn => frontend_clk44m_resetn, -- Reset for 44 MHz block (11b) 
    frontend_clk60_resetn => frontend_clk60m_resetn, -- Reset for 60 MHz block (Front End) 
    -- -------------------------------------------------------------------------
    -- outgoing clocks
    -- -------------------------------------------------------------------------
    bus_clk               => bus_clk, -- Bus clock not gated 
    bus_gclk              => bus_gclk, -- Bus system gated clock    
    bus_gclk_n            => bus_gclk_n_o, -- Inverted bus system clock     
    arm7_gclk             => a7s_gclk, -- ARM7 processor gated clock
                                       -- For FPGA 40 MHz, for ASIC 80 MHz
    streamproc_gclk       => strp_gclk, -- Stream processor gated clock
    hiss_sclk             => open,
    pci_sclk              => cclk_o, -- MiniPCI/CardBus clock out
    pci_sclk_n            => cclk_n_o,-- Inverted MiniPCI/CardBus clock
    --
    modema_clk            => modema_gclk,       --_i, -- Modem 802.11a clock  
    rxpatha_gclk          => rx_path_a_gclk,    --_i, -- Modem 802.11a RX path gated clock
    txpatha_gclk          => tx_path_a_gclk,    --_i, -- Modem 802.11a TX path gated clock
    ffta_gclk             => fft_gclk,          --_i, -- Modem 802.11a FFT gated clock    
    modemb_clk            => modemb_gclk,       --_i,  -- Modem 802.11b clock 
    rxpathb_gclk          => rx_path_b_gclk,    --_i, -- Modem 802.11b RX path gated clock
    txpathb_gclk          => tx_path_b_gclk,    --_i, -- Modem 802.11b TX path gated clock
    sampling_gclk         => sampling_gclk,     --_i, -- 60 MHz Clk for frontend and AGC
    filta_gclk            => filta_gclk,        --_i,  -- 60 MHz Clk for 11a front end filter 
    filtb_gclk            => filtb_gclk,        --_i,  -- 60 MHz clk 
    correla_gclk          => correla_gclk,      --_i, -- 60 MHz clk
    correlb_gclk          => correlb_gclk,      --_i, -- 60 MHz clk
    
    dac_gclk              => dac_gclk,          --_i, -- 60 MHz clk to DAC
    adc_gclk              => adc_gclk,          --_i, -- 60 MHz clk to ADC
    
    -- -------------------------------------------------------------------------
    -- reset enables
    -- -------------------------------------------------------------------------
    frontend_reset_en     => frontend_reset_en,     
    
    ---------------------------------------------------------------------------
    -- Test signals
    ---------------------------------------------------------------------------
    scan_hissclk          => scan_hissclk,
    scan_oscclk           => scan_oscclk,
    scan_pciclk           => scan_pciclk,
    scan_80clk            => scan_80clk,
    scan_44clk            => scan_44clk,
    scan_60clk            => scan_60clk,
    ---
    scan_hissclk_sel      => scan_hissclk_sel,
    scan_oscclk_sel       => scan_oscclk_sel,
    scan_pciclk_sel       => scan_pciclk_sel,
    scan_80clk_sel        => scan_80clk_sel,
    scan_44clk_sel        => scan_44clk_sel,
    scan_60clk_sel        => scan_60clk_sel,
    --
    reset_direct          => reset_direct,
    reset_under_test      => reset_under_test,
    -- -------------------------------------------------------------------------
    -- clocks enables
    -- -------------------------------------------------------------------------
    bus_clock_en          => bus_gating, --used to gate bus clock      
    arm7_clock_en         => a7s_gating, --used to gate ARM7 processor clock 
    streamproc_clock_en   => strp_gating, --used to gate stream processor clock 
    --
    modema_fgate          => modema_clkforce, --Force Modem 802.11a clock gate open   
    modemb_fgate          => modemb_clkforce, --Force Modem 802.11b clock gate open
    modema_clock_en       => modema_gating,    --(in) from outside            : used to gate Modem 802.11a clock
    rxpatha_en            => modema_rx_gating, --(in) from modem802_11g_maxim : Gate Modem 802.11a RX path 
    txpatha_en            => modema_tx_gating, --(in) from modem802_11g_maxim : Gate Modem 802.11a TX path
    modemb_clock_en       => modemb_gating,    --(in) from outside            : used to gate Modem 802.11b clock
    rxpathb_en            => modemb_rx_gating, --(in) from modem802_11g_maxim : Gate Modem 802.11b RX path
    txpathb_en            => modemb_tx_gating, --(in) from modem802_11g_maxim : Gate Modem 802.11b TX path
    calib_test            => constant_zero(1), -- Force open Modem 802.11a clock gate
    filta_en              => filta_gating, -- Gate 11a frontend filter    
    filtb_en              => filtb_gating, -- Gate 11b frontend filter    
    correla_en            => correla_gating,  -- Gate 11a frontend correlator 
    correlb_en            => correlb_gating,  -- Gate 11b frontend correlator 
    clkskip               => clkskip,  -- skip a Modem 802.11b clock cycle
    dac_clock_en          => dac_gating, -- Gate DAC clock
    adc_clock_en          => adc_gating, -- Gate ADC clock       
    -----------------------------------------------------------
    -- 32 KHz oscillator
    -----------------------------------------------------------
    set_osc32ken          => set_osc32ken_i,  -- High to set 32kHz oscillator enable
    osc32ken              => osc32ken_o,      -- Oscillator enable read value 
    -- -------------------------------------------------------------------------
    -- reference periods (BUP,UART)
    -- -------------------------------------------------------------------------
    enable_1mhz           => enable_1mhz,
    enable_7mhz           => enable_7mhz,
    --------------------------------------
    -- Clock controls
    --------------------------------------
    reg_44_80_cntl        => reg_44_80_cntl,       -- 0 to select 80 MHz, 1 for 44 MHz.
    reg_clkcntl           => reg_clkcntl,          -- CLKCNTL registe (s/w write val)
    reg_clkcntl_update    => reg_clkcntl_update,   -- Indicates a sw update of reg_clkcntl
    clock_switched        => clock_switched,       -- main clock freq switched indication for deep sleep or active
    clk_div               => clk_div,                      -- Active/Deep Sleep
    radio_if_wakeup       => radio_if_wakeup,      -- HW wake-up of the radio interface
    reg_manwkup           => reg_manwkup,   --_i,        -- SW wake-up of the radio interface
    --
    ready_for_sleep       => mode32k,      -- Low-power clock enabled
    rf_en_force           => rf_en_force,          -- Pulse to wake up HiSS interface
    clkcntl_out           => clkcntl_out_o,        -- CLKCNTL register update from clkreset_controller
    clkcntl_update        => clkcntl_update_o,     -- CLKCNTL register updation indication pulse

    clk32_select_out      => clk32_select_out,     -- control for mux in top lvl
    --------------------------------------
    -- Reset controls
    -------------------------------------- 
    swreset               => swreset,              -- Software reset active HIGH
    pmreset               => pmreset,
    -- Max value of the rf_reset_n counter
    reg_rfcount_max       => reg_rfcount_max,

    -- Signals for reset status
    wdreset_stat          => wdreset_stat,         -- Watchdog system reset status
    swreset_stat          => swreset_stat,         -- Software reset status
    pmreset_stat          => pmreset_stat,
    extreset_stat         => extreset_stat,        -- External system reset status
    --------------------------------------
    -- Watchdog Timer (WDT)
    --------------------------------------
    watchdog_test        => constant_zero(0),     -- Shorten WDT period for test
    wd_enable            => wd_enable,            -- Enables WDT
    wd_div               => wd_div,               -- WDT period
    wd_stroke            => wd_stroke,            -- Strokes WDT
    --
    wd_reset             => open,
    --------------------------------------
    -- HiSS pads
    --------------------------------------
    reg_en_hisslp        => reg_en_hisslp,  --_i,
    --
    hiss_biasen          => open,
    hiss_replien         => open,
    hiss_clken           => open,
    refclk_req           => refclk_req,            -- Reference clock request
    --------------------------------------   
    -- Diagnostic ports
    --------------------------------------   
    clockreset_diag0     => clockreset_diag0,     
    clockreset_diag1     => clockreset_diag1,     
    clockreset_diag2     => clockreset_diag2,     
    clockreset_diag3     => clockreset_diag3     
  );

end architecture rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
