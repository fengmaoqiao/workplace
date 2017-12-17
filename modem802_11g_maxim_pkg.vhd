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
--/ Description      : Package for modem802_11g_maxim.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/modem802_11g_maxim/vhdl/rtl/modem802_11g_maxim_pkg.vhd $
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
package modem802_11g_maxim_pkg is

-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off

  signal a_txonoff_conf_tglobal : std_logic;
  signal phy_data_ind_gbl       : std_logic;
  signal bup_rxdata_gbl         : std_logic_vector( 7 downto 0);
  signal modem_rx_a_i_gbl       : std_logic_vector(10 downto 0);
  signal modem_rx_a_q_gbl       : std_logic_vector(10 downto 0);
  signal modem_rx_a_toggle_gbl  : std_logic;
  signal rx_gain_global         : std_logic_vector(6 downto 0);
  signal rx_gain_update_global  : std_logic;

-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on

----------------------
-- File: modem802_11g_core.vhd
----------------------
  component modem802_11g_core
  generic (
    -- Use of Front-end register : 1 or 3 for use, 2 for don't use
    -- If the HiSS interface is used, the front-end is a part of the radio and
    -- so during the synthesis these registers could be removed.
    radio_interface_g   : integer := 1; -- 0 -> reserved
                                        -- 1 -> only Analog interface
                                        -- 2 -> only HISS interface                                                     -- 3 -> both interfaces (HISS and Analog)
    agc_gain_nb_g       : integer := 6  -- 5 -> M90SOC
                                        -- 6 -> Maxim 
    );
  port (                               
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    modema_clk        : in  std_logic; -- Modem 802.11a main clock
    rx_path_a_gclk    : in  std_logic; -- Rx path .11a gated clock
    tx_path_a_gclk    : in  std_logic; -- Tx path .11a gated clock
    fft_gclk          : in  std_logic; -- FFT gated clock
    mdma_reset_n      : in  std_logic; -- Global .11a reset async
    --
    modemb_clk        : in  std_logic; -- Modem 802.11b main clock
    rx_path_b_gclk    : in  std_logic; -- Rx path .11b gated clock
    tx_path_b_gclk    : in  std_logic; -- Tx path .11b gated clock
    mdmb_reset_n      : in  std_logic; -- Global .11b reset async
    --
    bup_clk           : in  std_logic; -- BuP clock
    bup_reset_n       : in  std_logic; -- BuP reset async
    --
    pclk              : in  std_logic; -- APB clock
    preset_n          : in  std_logic; -- APB reset async
    --
    mdma_sm_rst_n     : in  std_logic; -- synchronous reset for state machine A
    --
    modema_rx_gating  : out std_logic; -- Gating condition for Rx path .11a
    modema_tx_gating  : out std_logic; -- Gating condition for Tx path .11a
    modemb_rx_gating  : out std_logic; -- Gating condition for Rx path .11b
    modemb_tx_gating  : out std_logic; -- Gating condition for Tx path .11b
    --
    calib_test        : out std_logic;
    
    --------------------------------------
    -- APB slave
    --------------------------------------
    psel_a          : in  std_logic; -- Select. modem a registers
    psel_b          : in  std_logic; -- Select. modem b registers
    psel_g          : in  std_logic; -- Select. modem g registers
    penable         : in  std_logic; -- Defines the enable cycle.
    paddr           : in  std_logic_vector( 5 downto 0); -- Address.
    pwrite          : in  std_logic; -- Write signal.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata_modemg   : out std_logic_vector(31 downto 0); -- Read data.
    prdata_modemb   : out std_logic_vector(31 downto 0); -- Read data.
    prdata_modema   : out std_logic_vector(31 downto 0); -- Read data.
    
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
    bup_rxv_macaddr_match : in  std_logic; -- request to stop the reception
    bup_txv_immstop       : in  std_logic; -- request to stop the transmission               
    select_rx_ab          : in  std_logic; -- Selection Rx A or B for BuP2Modem IF
    -- outputs signals                                                          
    phy_txstartend_conf : out std_logic; -- transmission started, ready for data  
    phy_rxstartend_ind  : out std_logic; -- indication of RX packet                     
    a_phy_ccarst_conf   : out std_logic; 
    phy_data_conf       : out std_logic; -- last byte was read, ready for new one 
    phy_data_ind        : out std_logic; -- received byte ready                  
    rxv_length          : out std_logic_vector(11 downto 0); -- RX PSDU length  
    rxv_rssi            : out std_logic_vector( 7 downto 0); -- rx rssi
    rxv_service         : out std_logic_vector(15 downto 0); -- rx service field
    rxv_service_ind     : out std_logic;
    rxv_datarate        : out std_logic_vector( 3 downto 0); -- PSDU rec. rate
    rxe_errorstat       : out std_logic_vector( 1 downto 0); -- packet recep. stat
    phy_cca_ind         : out std_logic; -- CCA status from Modems
    bup_rxdata          : out std_logic_vector(7 downto 0); -- data received      
    
    --------------------------------------
    -- Radio controller interface
    --------------------------------------
    -- 802.11a side
    a_txonoff_conf      : in std_logic;
    a_rxonoff_conf      : in std_logic;
    a_rssi              : in  std_logic_vector(6 downto 0);
    --
    a_txonoff_req       : out std_logic;
    a_txbbonoff_req_o   : out std_logic;
    a_rxonoff_req       : out std_logic;
    a_txpwr             : out std_logic_vector(2 downto 0);
    a_dac_enable        : out std_logic;
    a_txend_preamble    : out std_logic;  -- End of OFDM preamble
    -- 802.11b side
    b_txonoff_conf      : in  std_logic;
    b_rxonoff_conf      : in  std_logic;
    b_rxi               : in  std_logic_vector(7 downto 0);
    b_rxq               : in  std_logic_vector(7 downto 0);
    --    
    b_txon              : out std_logic;
    b_rxon              : out std_logic;
    b_dac_enable        : out std_logic;
    b_txend_preamble    : out std_logic;  -- End of DSSS-CCK preamble
    
    --------------------------------------------
    -- AGC/CCA
    --------------------------------------------
    cca_busy_a          : in  std_logic;
    cca_busy_b          : in  std_logic;
    agc_gain            : in  std_logic_vector(agc_gain_nb_g-1 downto 0);
    agc_gain_updt       : in  std_logic;
    --
    listen_start_o      : out std_logic;
    cp2_detected        : out std_logic;
    a_phy_cca_ind       : out std_logic; -- CCA status from ModemA
    b_phy_cca_ind       : out std_logic; -- CCA status from ModemB
    
    --------------------------------------------
    -- 802.11b TX front end
    --------------------------------------------
    -- Disable Tx & Rx filter
    fir_disb            : out std_logic;
    -- Tx FIR controls
    init_fir            : out std_logic;
    fir_activate        : out std_logic;
    fir_phi_out_tog_o   : out std_logic;
    fir_phi_out         : out std_logic_vector (1 downto 0);
    tx_const            : out std_logic_vector(7 downto 0);
    txc2disb            : out std_logic; -- Complement's 2 disable (from reg)
    --------------------------------------------
    -- Interface with 11b RX Frontend
    --------------------------------------------
    -- Control from Registers
    interp_disb         : out std_logic; -- Interpolator disable
    clock_lock          : out std_logic;
    tlockdisb           : out std_logic;  -- use timing lock from service field.
    gain_enable         : out std_logic;  -- gain compensation control.
    tau_est             : out std_logic_vector(17 downto 0);
    enable_error        : out std_logic;
    rxc2disb            : out std_logic; -- Complement's 2 disable (from reg)
    interpmaxstage      : out std_logic_vector(5 downto 0);

    --------------------------------------------
    -- 802.11b AGC
    --------------------------------------------
    agcproc_end         : in std_logic;
    correl_rst_n        : in std_logic;
    agc_diag            : in std_logic_vector(15 downto 0);
    --
    psdu_duration       : out std_logic_vector(15 downto 0);
    correct_header      : out std_logic;
    plcp_state          : out std_logic;
    plcp_error          : out std_logic;
    -- registers
    agc_modeabg         : out std_logic_vector(1 downto 0);
    agc_longslot        : out std_logic;
    agc_wait_cs_max     : out std_logic_vector(3 downto 0);
    agc_wait_sig_max    : out std_logic_vector(3 downto 0);
    agc_disb            : out std_logic;
    agc_modeant         : out std_logic;
    interfildisb        : out std_logic;
    ccamode             : out std_logic_vector( 2 downto 0);
    --
    sfd_found           : out std_logic;
    symbol_sync2        : out std_logic;

    --------------------------------------
    -- 802.11a Filters
    --------------------------------------
    -- Rx filter
    filter_valid_rx_i       : in  std_logic;
    rx_filtered_data_i      : in  std_logic_vector(10 downto 0);
    rx_filtered_data_q      : in  std_logic_vector(10 downto 0);
    -- tx part
    tx_active_o             : out std_logic;
    tx_filter_bypass_o      : out std_logic;
    filter_start_of_burst_o : out std_logic;
    filter_valid_tx_o       : out std_logic;
    tx_norm_o               : out std_logic_vector( 7 downto 0);
    tx_data2filter_i        : out std_logic_vector( 9 downto 0);
    tx_data2filter_q        : out std_logic_vector( 9 downto 0);

    --------------------------------------
    -- Registers for rw_wlan rf front end
    --------------------------------------
    -- calibration_mux
    calmode_o               : out std_logic;
    -- IQ calibration signal generator
    calfrq0_o               : out std_logic_vector(22 downto 0);
    calgain_o               : out std_logic_vector( 2 downto 0);
    -- Modules control signals for transmitter
    tx_iq_phase_o           : out std_logic_vector( 5 downto 0);
    tx_iq_ampl_o            : out std_logic_vector( 8 downto 0);
    -- dc offset
    rx_del_dc_cor_o         : out std_logic_vector(7 downto 0);
    dc_off_disb_o           : out std_logic;    
    -- 2's complement
    a_c2disb_tx_o           : out std_logic;
    a_c2disb_rx_o           : out std_logic;
    -- DC waiting period.
    deldc2_o                : out std_logic_vector(4 downto 0);
    -- Constant generator
    tx_const_o              : out std_logic_vector(7 downto 0);
    -- IQ swap
    tx_iqswap               : out std_logic;           -- Swap I/Q in Tx.
    rx_iqswap               : out std_logic;           -- Swap I/Q in Rx.

    -- MDMg11hCNTL register.
    ofdmcoex                : in  std_logic_vector(7 downto 0);  -- Current value of the 
    -- MDMgADDESTMDUR register.
    reg_addestimdura        : out std_logic_vector(3 downto 0); -- additional time duration 11a
    reg_addestimdurb        : out std_logic_vector(3 downto 0); -- additional time duration 11b
    reg_rampdown            : out std_logic_vector(2 downto 0); -- ramp-down time duration
    -- MDMg11hCNTL register.
    reg_rstoecnt            : out std_logic;                    -- Reset OFDM Preamble Existence cnounter
    -- MDMgAGCCCA register.
    edtransmode_reset       : in  std_logic; -- Reset the edtransmode register     
    reg_edtransmode         : out std_logic; -- Energy Detect Transitional Mode
    reg_edmode              : out std_logic; -- Energy Detect Mode
    --------------------------------------
    -- Diag. port
    --------------------------------------
    modem_diag0              : out std_logic_vector(15 downto 0);
    modem_diag1              : out std_logic_vector(15 downto 0);
    modem_diag2              : out std_logic_vector(15 downto 0);
    modem_diag3              : out std_logic_vector(15 downto 0);
    modem_diag4              : out std_logic_vector(15 downto 0);
    modem_diag5              : out std_logic_vector(15 downto 0);
    modem_diag6              : out std_logic_vector(15 downto 0)
    );

  end component;


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: tx_resync_80to60.vhd
----------------------
  component tx_resync_80to60
  port
  (
    -- -------------------------------------------------------------------------
    -- 80 MHz write domain
    -- -------------------------------------------------------------------------
    resetn80m    :  in std_logic;
    clk80m       :  in std_logic;
    enable80m    :  in std_logic;
    i80m         :  in std_logic_vector( 9 downto 0);
    q80m         :  in std_logic_vector( 9 downto 0);
    toggle80m    :  in std_logic;
  
    -- -------------------------------------------------------------------------
    -- 60 MHz write domain
    -- -------------------------------------------------------------------------
    resetn60m    :  in std_logic;
    clk60m       :  in std_logic;
    enable60m    : out std_logic;
    i60m         : out std_logic_vector( 9 downto 0);
    q60m         : out std_logic_vector( 9 downto 0);
    toggle60m    : out std_logic
  );
  end component;


----------------------
-- File: rx_resync_60to80.vhd
----------------------
  component rx_resync_60to80
  port
  (
    -- -------------------------------------------------------------------------
    -- 60 MHz write domain
    -- -------------------------------------------------------------------------
    resetn60m    :  in std_logic;
    clk60m       :  in std_logic;
    i60m         :  in std_logic_vector(10 downto 0);
    q60m         :  in std_logic_vector(10 downto 0);
    toggle60m    :  in std_logic;
  
    -- -------------------------------------------------------------------------
    -- 80 MHz write domain
    -- -------------------------------------------------------------------------
    resetn80m    :  in std_logic;
    clk80m       :  in std_logic;
    i80m         : out std_logic_vector(10 downto 0);
    q80m         : out std_logic_vector(10 downto 0);
    toggle80m    : out std_logic
  );
  end component;


----------------------
-- File: gating_control.vhd
----------------------
  component gating_control
  port
  (
    clk                    :  in std_logic;
    resetn                 :  in std_logic;
    --
    agcenabled             :  in std_logic;
    -- bup
    phy_txstartend_req     :  in std_logic;
    -- modem
    a_txonoff_conf         :  in std_logic;
    b_txonoff_conf         :  in std_logic;
    
    dac_gating             : out std_logic;
    adc_gating             : out std_logic
    
  );
  end component;


----------------------
-- File: regbank_maxim.vhd
----------------------
  component regbank_maxim
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n         : in  std_logic; -- Reset.
    pclk            : in  std_logic; -- APB clock.

    --------------------------------------------
    -- Registers
    --------------------------------------------
    -- AGCSTAT0 register.
    pant2stat                    : in  std_logic_vector(9 downto 0);
    pant1stat                    : in  std_logic_vector(9 downto 0);
    -- AGCSTAT1 register.
    gain2stat                    : in  std_logic_vector(5 downto 0);
    gain1stat                    : in  std_logic_vector(5 downto 0);
    padc2stat                    : in  std_logic_vector(6 downto 0);
    padc1stat                    : in  std_logic_vector(6 downto 0);
    -- AGCSTAT2 register.
    gainsifsstat                 : in  std_logic_vector(5 downto 0);
    padcsifsstat                 : in  std_logic_vector(6 downto 0);
    pantsifsstat                 : in  std_logic_vector(9 downto 0);
    -- AGCSTAT3 register.
    gainokstat                   : in  std_logic_vector(5 downto 0);
    padcokstat                   : in  std_logic_vector(6 downto 0);
    pantokstat                   : in  std_logic_vector(9 downto 0);
    --
    -- begin_manually_added
    sw_edcca_ack                 : out std_logic;
    -- end_manually_added
    -- CCACTL register.
    reg_agcccadisb               : out std_logic;
    reg_ccarfoffen               : out std_logic;
    reg_forceagcrst              : out std_logic;
    reg_rxant_start              : out std_logic;
    reg_antselen                 : out std_logic;
    reg_act                      : out std_logic;
    reg_modeabg                  : out std_logic_vector(1 downto 0);
    reg_agcwaitdc                : out std_logic;
    reg_ccarampen                : out std_logic;
    reg_ccacoren                 : out std_logic;
    reg_ccastatbdgen             : out std_logic_vector(4 downto 0);
    reg_sensingmode              : out std_logic_vector(2 downto 0);
    -- CCADEL0 register.
    reg_ofdmrxdel                : out std_logic_vector(3 downto 0);
    reg_dcckrxdel                : out std_logic_vector(3 downto 0);
    reg_rampdown                 : out std_logic_vector(2 downto 0);
    reg_rfbiasdel                : out std_logic_vector(2 downto 0);
    -- CCAED register.
    reg_ccathragcoff             : out std_logic_vector(8 downto 0);
    reg_ccamaxlength             : out std_logic_vector(7 downto 0);
    -- AGCCNTL0 register.
    reg_rfmode                   : out std_logic;
    reg_thrsensi                 : out std_logic_vector(9 downto 0);
    reg_rugap                    : out std_logic_vector(4 downto 0);
    reg_antlossdb                : out std_logic_vector(1 downto 0);
    -- AGCCNTL1 register.
    reg_satup                    : out std_logic_vector(2 downto 0);
    reg_satdelta                 : out std_logic_vector(2 downto 0);
    reg_satthr                   : out std_logic_vector(6 downto 0);
    reg_thrdsssin                : out std_logic_vector(6 downto 0);
    reg_thrdsssdet               : out std_logic_vector(6 downto 0);
    -- AGCCNTL2 register.
    reg_thrccanrg                : out std_logic_vector(7 downto 0);
    reg_thradcdis                : out std_logic_vector(6 downto 0);
    reg_thrinbddis               : out std_logic_vector(6 downto 0);
    -- AGCCNTL3 register.
    reg_thrplatcor               : out std_logic_vector(7 downto 0);
    reg_deltapplat               : out std_logic_vector(3 downto 0);
    reg_delplatsat               : out std_logic_vector(6 downto 0);
    reg_delplat                  : out std_logic_vector(6 downto 0);
    -- AGCCNTL4 register.
    reg_mixacccs2                : out std_logic;
    reg_mixaccplat               : out std_logic;
    reg_thrcccs2                 : out std_logic_vector(5 downto 0);
    reg_thraccs2                 : out std_logic_vector(5 downto 0);
    reg_thrccplat                : out std_logic_vector(5 downto 0);
    reg_thracplat                : out std_logic_vector(5 downto 0);
    -- AGCCCAOVNRG register.
    reg_downccanrg               : out std_logic_vector(4 downto 0);
    reg_upccanrg                 : out std_logic_vector(4 downto 0);
    reg_hysccanrg                : out std_logic_vector(2 downto 0);
    -- AGCCNTL5 register.
    reg_delpowstatus             : out std_logic_vector(7 downto 0);
    reg_delcrosspreamb           : out std_logic_vector(6 downto 0);
    reg_deltadata                : out std_logic_vector(6 downto 0);
    reg_deltapreamb              : out std_logic_vector(6 downto 0);
    -- AGCGAIN register.
    reg_gstep1                   : out std_logic_vector(5 downto 0);
    reg_gstep2                   : out std_logic_vector(5 downto 0);
    reg_gstep3                   : out std_logic_vector(5 downto 0);    
    reg_gainhi                   : out std_logic_vector(5 downto 0);
    -- AGCADCTGT register.
    reg_adctgt11bsc              : out std_logic_vector(6 downto 0);
    reg_adctgtant                : out std_logic_vector(6 downto 0);
    reg_adctgtfine               : out std_logic_vector(6 downto 0);
    reg_adctgtdis                : out std_logic_vector(6 downto 0);
    -- AGCDELCS register.
    reg_delcs3                   : out std_logic_vector(8 downto 0);
    reg_delcs2                   : out std_logic_vector(6 downto 0);
    -- AGCDEL2ANT register.
    reg_del2antsat               : out std_logic_vector(8 downto 0);
    reg_del2ant                  : out std_logic_vector(8 downto 0);
    -- AGCGAINMAXMIN register.
    reg_gainmindemod             : out std_logic_vector(5 downto 0);
    reg_gainmaxdemod             : out std_logic_vector(5 downto 0);
    reg_gainmindet               : out std_logic_vector(5 downto 0);
    reg_gainmaxdet               : out std_logic_vector(5 downto 0);
    -- AGCCNTL6 register.
    reg_deldcconv                : out std_logic_vector(3 downto 0);
    reg_del_recent_sat           : out std_logic_vector(8 downto 0);
    
    -- AGCCNTL9 register.
    reg_delgainset1              : out std_logic_vector(3 downto 0);
    reg_delgainset2              : out std_logic_vector(3 downto 0); 
    reg_delgainset3              : out std_logic_vector(3 downto 0); 
    reg_delgainset4              : out std_logic_vector(3 downto 0); 

    -- AGCMODEDC register.
    reg_q_dc_comp                : out std_logic_vector(6 downto 0);
    reg_i_dc_comp                : out std_logic_vector(6 downto 0);
    reg_dc_comp_force            : out std_logic;
    -- AGCDELFE register.
    reg_delfebconv               : out std_logic_vector(6 downto 0);
    reg_delfeb                   : out std_logic_vector(5 downto 0);
    reg_delfeaconv               : out std_logic_vector(5 downto 0);
    reg_delfea                   : out std_logic_vector(4 downto 0);
    -- AGCCNTL7 register.
    reg_delradar                 : out std_logic_vector(4 downto 0);
    reg_delpradarinbd            : out std_logic_vector(7 downto 0);
    reg_delpadconv               : out std_logic_vector(5 downto 0);
    reg_delpinbdconv             : out std_logic_vector(6 downto 0);
    -- AGCTHRACRATIO register.
    reg_thrbcratiocs3            : out std_logic_vector(6 downto 0);
    reg_thracratiocs3            : out std_logic_vector(6 downto 0);
    reg_thracratiocs2            : out std_logic_vector(6 downto 0);
    reg_thracratiocs1            : out std_logic_vector(6 downto 0);
    -- AGCTGTDG register.
    reg_adctgtdglin6dbc          : out std_logic_vector(7 downto 0);
    reg_adctgtdglin6dbf          : out std_logic_vector(7 downto 0);
    reg_adctgtdglinc             : out std_logic_vector(7 downto 0);
    reg_adctgtdglinf             : out std_logic_vector(7 downto 0);
    -- AGCCNTL8 register.
    reg_ccpeakcs2                : out std_logic_vector(1 downto 0);
    reg_ndldisadc                : out std_logic_vector(4 downto 0);
    reg_ndldisinbd               : out std_logic_vector(4 downto 0);
    reg_ndldet                   : out std_logic_vector(3 downto 0);
    -- AGCCSFORCE register.
    reg_cs3blowval               : out std_logic;
    reg_cs3bhighval              : out std_logic;
    reg_cs3alowval               : out std_logic;
    reg_cs3ahighval              : out std_logic;
    reg_cs2alowval               : out std_logic;
    reg_cs2ahighval              : out std_logic;
    reg_cs1alowval               : out std_logic;
    reg_cs1ahighval              : out std_logic;
    reg_cs3gforce                : out std_logic;
    reg_cs3blowforce             : out std_logic;
    reg_cs3bhighforce            : out std_logic;
    reg_cs3alowforce             : out std_logic;
    reg_cs3ahighforce            : out std_logic;
    reg_cs2alowforce             : out std_logic;
    reg_cs2ahighforce            : out std_logic;
    reg_cs1alowforce             : out std_logic;
    reg_cs1ahighforce            : out std_logic;
    -- AGCDELDCFORCE register.
    reg_raddcforcedisb           : out std_logic;
    reg_raddeldcforce            : out std_logic_vector(5 downto 0);
    reg_febdeldcforce            : out std_logic_vector(5 downto 0);
    reg_feadeldcforce            : out std_logic_vector(5 downto 0);
    -- FEOFDMCNTL register.
    reg_txnorma                  : out std_logic_vector(7 downto 0);
    reg_txiqcalen                : out std_logic;
    reg_txfbyp                   : out std_logic;
    reg_txiqg                    : out std_logic_vector(8 downto 0);
    reg_txiqph                   : out std_logic_vector(5 downto 0);
    -- FEDCCKCNTL register.
    reg_txshiftb                 : out std_logic_vector(1 downto 0);
    reg_txnormb                  : out std_logic_vector(5 downto 0);
    reg_maxstage                 : out std_logic_vector(5 downto 0);
    reg_firdisb                  : out std_logic;
    reg_gaindisb                 : out std_logic;
    reg_interpdisb               : out std_logic;
    reg_interfildisb             : out std_logic;
    -- FESINECNTL register.
    reg_speval                   : out std_logic_vector(3 downto 0);
    reg_calgain                  : out std_logic_vector(2 downto 0);
    reg_calmode                  : out std_logic;
    reg_calfreq                  : out std_logic_vector(22 downto 0);
    -- FETESTCNTL register.
    reg_txiqswap                 : out std_logic;
    reg_txc2disb                 : out std_logic;
    reg_dacdatasel               : out std_logic_vector(1 downto 0);
    reg_dacconstsel              : out std_logic_vector(1 downto 0);
    reg_rxiqswap                 : out std_logic;
    reg_rxc2disb                 : out std_logic;
    reg_dcck_sf_force_en         : out std_logic;
    reg_dcck_scale_factor_force  : out std_logic_vector(7 downto 0);
    reg_ofdm_diggainlin_force    : out std_logic_vector(7 downto 0);
    reg_ofdmgain_force_en        : out std_logic;
    reg_ofdm_diggain6db_force    : out std_logic_vector(2 downto 0);
    -- AGCADCCNTL register.
    reg_gadc_offset_qdb          : out std_logic_vector(4 downto 0);
    -- AGCCCATHR register.
    reg_cca_thr_cs3              : out std_logic_vector(6 downto 0);
    reg_cca_thr_dsss             : out std_logic_vector(6 downto 0);
    -- FETXCONST register.
    reg_idacconst                : out std_logic_vector(7 downto 0);
    reg_qdacconst                : out std_logic_vector(7 downto 0);
    reg_txconsta                 : out std_logic_vector(7 downto 0);
    reg_txconstb                 : out std_logic_vector(7 downto 0);
    reg_adcscale                 : out std_logic_vector(2 downto 0);
    reg_dacscale                 : out std_logic_vector(1 downto 0);
    -- AGCCNTL10 register.
    reg_gstep2ant                : out std_logic_vector(5 downto 0);
    reg_del2antswitch            : out std_logic_vector(8 downto 0);
    reg_del_dc_hpf               : out std_logic_vector(3 downto 0);
    --------------------------------------------
    -- APB slave
    --------------------------------------------
    psel            : in  std_logic; -- Device select.
    penable         : in  std_logic; -- Defines the enable cycle.
    pwrite          : in  std_logic; -- Write signal.
    paddr           : in  std_logic_vector(7 downto 0); -- Address.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata          : out std_logic_vector(31 downto 0)  -- Read data.
    );

  end component;


----------------------
-- File: modem802_11g_maxim.vhd
----------------------
  component modem802_11g_maxim
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


  );
  end component;



end modem802_11g_maxim_pkg;


--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
