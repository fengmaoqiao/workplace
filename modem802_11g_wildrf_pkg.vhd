
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: modem802_11g_wildrf_pkg.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.67   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for modem802_11g_wildrf.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/modem802_11g_wildrf/vhdl/rtl/modem802_11g_wildrf_pkg.vhd,v  
--  Log: modem802_11g_wildrf_pkg.vhd,v  
-- Revision 1.67  2005/03/23 08:28:05  Dr.J
-- #BugId:720#
-- Added Energy Detect control signals
--
-- Revision 1.66  2005/03/11 08:52:24  arisse
-- #BugId:1124#
-- Add one clock cycle to start correlation.
--
-- Revision 1.65  2005/01/24 16:21:55  arisse
-- #BugId:684,795,983#
-- Added interp_max_stage.
-- Added generic for front-end registers.
-- Added resynchronization on init_rx_b and connected
-- it to agc_procend and correl_rst.
--
-- Revision 1.64  2005/01/19 12:57:08  Dr.J
-- #BugId:727#
-- Added ofdm_preamble_detection block
--
-- Revision 1.63  2005/01/14 15:21:47  Dr.C
-- #BugId:916#
-- Updated .11g FE.
--
-- Revision 1.62  2005/01/11 10:08:17  Dr.J
-- #BugId:952#
-- Added selection of the modem in rx done by the agc
--
-- Revision 1.61  2005/01/06 14:01:00  Dr.C
-- #BugId:916,942#
-- Updated .11g FE instance.
--
-- Revision 1.60  2005/01/04 13:46:42  sbizet
-- #BugId:907#
-- Added agc_busy outport
--
-- Revision 1.59  2004/12/21 13:36:10  Dr.J
-- #BugId:921#
-- Connected the wlanrxind signal from the AGC/CCA BB.
-- Added input of the AGC/CCA BB the rxe_errstat from the modems.
--
-- Revision 1.58  2004/12/15 11:46:58  Dr.C
-- #BugId:902#
-- Updated 11g frontend port map.
--
-- Revision 1.57  2004/12/15 10:03:48  arisse
-- #BugId:883,819#
-- Updated Modem B Front-End entities.
--
-- Revision 1.56  2004/12/14 16:47:51  Dr.J
-- #BugId:727,907,606#
-- Updated ports map
--
-- Revision 1.55  2004/11/08 17:13:55  arisse
-- #BugId:828#
-- Updated modem802_11g_front_end.
--
-- Revision 1.54  2004/09/24 13:06:11  arisse
-- Modified Interference Filter.
--
-- Revision 1.53  2004/08/24 13:41:57  arisse
-- Added globals for testbench.
--
-- Revision 1.52  2004/07/16 08:28:33  arisse
-- Added globals.
--
-- Revision 1.51  2004/07/02 12:00:54  arisse
-- Added globals.
--
-- Revision 1.50  2004/07/02 06:52:27  Dr.C
-- Updated rx_b_front_end_wildrf port map.
--
-- Revision 1.49  2004/07/01 11:44:24  Dr.C
-- Changed tx_rx_filter_reset_n to tx_reset_n.
--
-- Revision 1.48  2004/06/16 15:16:19  Dr.C
-- Updated 11g frontend.
--
-- Revision 1.47  2004/06/16 14:06:52  Dr.C
-- Updated rx_b_front_end_wildrf port map.
--
-- Revision 1.46  2004/06/15 15:28:16  Dr.C
-- Updated modemg frontend.
--
-- Revision 1.45  2004/06/04 13:59:08  Dr.C
-- Updated 11g frontend and modemg core.
--
-- Revision 1.44  2004/05/18 12:36:14  Dr.A
-- Modem G port map update: added bup_clk for synchronization blocks, and use only one cca_ind input for A and B.
--
-- Revision 1.43  2004/04/19 15:24:27  Dr.C
-- Updated modem802_11g_frontend.
--
-- Revision 1.42  2004/03/24 16:36:34  Dr.C
-- Added input select_clk80 for BB AGC block
--
-- Revision 1.41  2004/02/10 14:53:21  Dr.C
-- Updated modemg core.
--
-- Revision 1.40  2003/12/12 11:50:36  sbizet
-- agc_fake port map updated
--
-- Revision 1.39  2003/12/12 11:02:15  Dr.C
-- Updated AGC and core.
--
-- Revision 1.38  2003/12/12 09:13:07  sbizet
-- agc_fake port map updated
--
-- Revision 1.37  2003/12/08 08:57:05  sbizet
-- New agc_fake port map
--
-- Revision 1.36  2003/12/03 15:28:09  Dr.F
-- port map changed.
--
-- Revision 1.35  2003/12/02 11:42:38  arisse
-- Added txiconst, txc2disb and rxc2disb.
--
-- Revision 1.34  2003/12/02 10:15:54  Dr.J
-- Added agc_cca_analog_fake
--
-- Revision 1.33  2003/11/21 18:34:22  Dr.F
-- ?
--
-- Revision 1.32  2003/11/21 16:12:49  Dr.J
-- Added agc_rx_onoff_req
--
-- Revision 1.31  2003/11/21 14:18:06  Dr.C
-- Updated AGC port map
--
-- Revision 1.30  2003/11/20 16:31:48  Dr.J
-- Added agc_hissbb
--
-- Revision 1.29  2003/11/20 07:28:29  Dr.J
-- Removed resync_init
--
-- Revision 1.28  2003/11/14 16:00:00  Dr.C
-- Updated core and front_end.
--
-- Revision 1.27  2003/11/06 09:08:58  Dr.C
-- Updated generic.
--
-- Revision 1.26  2003/11/03 16:08:05  Dr.C
-- Updated core.
--
-- Revision 1.25  2003/11/03 15:59:49  Dr.B
-- pa_on, radio_interface_g, c2disb changes.
--
-- Revision 1.24  2003/10/31 15:54:42  arisse
-- Added hiss controller signals.
--
-- Revision 1.23  2003/10/29 14:47:19  Dr.C
-- Added ports on rx 11b front end for AGC
--
-- Revision 1.22  2003/10/24 09:29:49  Dr.C
-- Adde generic radio_interface_g.
--
-- Revision 1.21  2003/10/23 17:39:48  Dr.C
-- Updated core & frontend.
--
-- Revision 1.20  2003/10/21 15:09:01  arisse
-- Added filters_reset_n.
--
-- Revision 1.19  2003/10/16 15:10:14  Dr.C
-- Updated.
--
-- Revision 1.18  2003/10/15 18:18:22  Dr.C
-- Updated diag port.
--
-- Revision 1.17  2003/10/13 10:11:51  Dr.C
-- Updated.
--
-- Revision 1.16  2003/10/09 09:51:47  Dr.B
-- *** empty log message ***
--
-- Revision 1.15  2003/09/30 15:40:52  arisse
-- Added clk_2skip_i.
--
-- Revision 1.14  2003/09/24 13:26:59  Dr.J
-- Added sync_found
--
-- Revision 1.13  2003/09/23 07:54:41  Dr.C
-- Updated core.
--
-- Revision 1.12  2003/09/18 14:10:53  Dr.J
-- Added filter clk
-- .,
--
-- Revision 1.11  2003/09/09 14:01:47  Dr.C
-- Updated modem802_11g_core.
--
-- Revision 1.10  2003/08/29 16:41:40  Dr.B
-- rx_iq_comp goes to 60 MHz area.
--
-- Revision 1.9  2003/08/07 17:26:58  Dr.C
-- Updated modemg_core.
--
-- Revision 1.8  2003/08/07 09:11:29  Dr.C
-- Updated.
--
-- Revision 1.7  2003/07/30 16:45:29  Dr.C
-- Added AGC correl_reset_n output
--
-- Revision 1.6  2003/07/30 06:09:17  Dr.F
-- agc port map changed.
--
-- Revision 1.5  2003/07/28 15:38:23  Dr.C
-- Updated modem802_11g_core.
--
-- Revision 1.4  2003/07/28 07:42:22  Dr.B
-- remove modemb_clk in modemb_core.
--
-- Revision 1.3  2003/07/27 17:27:36  Dr.F
-- port map changed.
--
-- Revision 1.2  2003/07/22 16:26:44  Dr.C
-- Updated.
--
-- Revision 1.1  2003/07/22 13:55:11  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package modem802_11g_wildrf_pkg is

-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  signal phy_txstartend_conf_gbl : std_logic;  -- transmission started, ready for data    
--  signal phy_data_req_gbl        : std_logic;  -- request to send a byte 
--  signal phy_data_conf_gbl       : std_logic;  -- last byte was read, ready for new one                                                       
--  signal bup_txdata_gbl          : std_logic_vector(7 downto 0);  -- data to send     
--  signal txv_datarate_gbl        : std_logic_vector( 3 downto 0);  -- PSDU transm. rate              
--  signal txv_length_gbl          : std_logic_vector(11 downto 0);  -- RX PSDU length  
--  signal txpwr_level_gbl         : std_logic_vector( 2 downto 0);  -- TX power level.      
--  signal txv_service_gbl         : std_logic_vector(15 downto 0);  -- tx service field   
--
--  signal phy_rxstartend_ind_gbl  : std_logic;  -- indication of RX packet  
--  signal phy_data_ind_gbl        : std_logic;  -- received byte ready
--  signal bup_rxdata_gbl          : std_logic_vector(7 downto 0);  -- data received 
--  signal rxv_datarate_gbl        : std_logic_vector( 3 downto 0);  -- PSDU rec. rate       
--  signal rxv_length_gbl          : std_logic_vector(11 downto 0);  -- RX PSDU length 
--  signal rxe_errorstat_gbl       : std_logic_vector( 1 downto 0);  -- packet recep. stat
--  signal phy_cca_ind_gbl         : std_logic;  -- CCA status from Modems 
--  signal rxv_rssi_gbl            : std_logic_vector( 6 downto 0);  -- rx rssi 
--  signal rxv_service_gbl         : std_logic_vector(15 downto 0);  -- rx service field 
--  signal rxv_service_ind_gbl     : std_logic;
--  signal phy_ccarst_req_gbl      : std_logic;  -- request to reset CCA state machine                      
--  signal phy_ccarst_conf_gbl     : std_logic;
--  signal bup_txdata              : std_logic_vector(7 downto 0); -- data to send         
--  signal phy_data_req            : std_logic; -- request to send a byte
--
  -- Modem B globals.
--  signal rx_path_b_gclk_gbl      : std_logic;
--  signal modemb_clk_gbl          : std_logic;
--  signal rxi_fe_gbl              : std_logic_vector(7 downto 0);
--  signal rxq_fe_gbl              : std_logic_vector(7 downto 0); 
--  
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDRF_FRONTEND/tx_b_frontend_wildrf/vhdl/rtl/tx_b_frontend_wildrf.vhd
----------------------
  component tx_b_frontend_wildrf
  generic(
    out_length_g : integer := 7; -- number of significant output bits
    phi_degree_g : integer := 5; -- deg of filter (3 -> 4 phis on equation)
    radio_interface_g : integer := 3   -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk_44       : in  std_logic;
    clk_60       : in  std_logic;
    reset_n      : in  std_logic; 
    --------------------------------------
    -- Signals
    --------------------------------------
    hiss_enable_n: in  std_logic; -- when high, the analog interface is selected
    fir_activate : in  std_logic; -- activate the block (when disact, it finishes the transfer)
    c2disb       : in  std_logic; -- disable C2's when high.
    fir_disb     : in  std_logic; -- when disb, i and q are transfered without modif
    phi_angle_tog: in  std_logic; -- toggle when new data
    phi_angle    : in  std_logic_vector(1 downto 0); -- phi input
    pa_on        : in  std_logic; -- pa_on from radioctrl
    b_txiconst   : in  std_logic_vector(out_length_g downto 0); -- signed value from reg of the constant to be sent
    -- Outputs Signals : Data to radio_controller
    tx_val_tog   : out std_logic; -- toggle when new value
    tx_i_o       : out std_logic_vector(out_length_g downto 0); 
    tx_q_o       : out std_logic_vector(out_length_g downto 0)   
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDRF_FRONTEND/rx_b_front_end_wildrf/vhdl/rtl/rx_b_front_end_wildrf.vhd
----------------------
  component rx_b_front_end_wildrf
  generic (
    rx_length_g       : integer := 7;
    m_size_g          : integer := 7;  -- nb of input bits from radio
    radio_interface_g : integer := 3   -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n           : in  std_logic;
    filtb_clk         : in  std_logic;  -- 60 MHz clock.
    rx_path_b_gclk    : in  std_logic;  -- 44 MHz clock gated.
    modemb_clk        : in  std_logic;  -- 44 MHz clock non gated.
    interf_filter_reset_n : in std_logic;  -- Reset for rx_11b_interf_filter.
    interf_filter_clk     : in std_logic;  -- Clock for rx_11b_interf_filter.
    --------------------------------------
    -- Controls
    --------------------------------------
    rx_i_i            : in  std_logic_vector(rx_length_g downto 0);
    rx_q_i            : in  std_logic_vector(rx_length_g downto 0);
    hiss_mode_n       : in  std_logic;  -- =1 when data go through filter pass
                                        -- =0 when data go directly to tx_resync.
    rx_val_tog        : in  std_logic;

    --------------------------------------
    -- AGC
    --------------------------------------
    agc_sync_rst_n    : in  std_logic;  -- Synchronous reset from AGC to reset
                                        -- filters and resynch block.
    --
    filt_out_4_corr_i : out std_logic_vector(rx_length_g+2 downto 0);  -- These
    filt_out_4_corr_q : out std_logic_vector(rx_length_g+2 downto 0); -- outputs 
                                    -- are only used by the correlator in
                                    -- the AGC block
    
    -------------------------------
    -- Control for 2's complement.
    -------------------------------
    c2disb            : in  std_logic;
    -----------------------------------
    -- Control for interference filter
    -----------------------------------
    dcoffdisb             : in std_logic;
    h_b_select            : in  std_logic;  -- =1: modem_11h, =0 : modem_11b
    interf_filter_disable : in std_logic;  -- =1 : interference filter disabled.
    scaling               : in std_logic_vector(3 downto 0); -- scaling from AGC
    -- Outputs of Interference filter : for modem_h purpose.
    rx_i_interf_filter_o  : out std_logic_vector(rx_length_g downto 0);
    rx_q_interf_filter_o  : out std_logic_vector(rx_length_g downto 0);
    -------------------------------
    -- Control for interpolator
    -------------------------------
    interp_disb       : in  std_logic;  -- disable the interpolation when high 
    interp_max_stage_i : in  std_logic_vector(5 downto 0); -- Max value of stage
    clock_lock        : in  std_logic;  -- High when the clocks are locked.
    tlockdisb         : in  std_logic;  -- Use clock_lock input when low.
    tau_est           : in  std_logic_vector(17 downto 0);  -- from rx_11b_demod.
    clk_skip          : out std_logic;  -- when '0': gate clk during 1 period
    -------------------------------
    -- Control for timingoff_estim.
    -------------------------------
    timingoff_en      : in  std_logic;
    -------------------------------
    -- Control for power_estimation
    -------------------------------    
    pw_estim_activate : in  std_logic;
    --                  activate the blockagc_sync_rst_n
    integration_end   : in  std_logic;
    --                  Indicates end of integration
    power_estimation  : out std_logic_vector(20 downto 0);
    -------------------------------
    -- Control for filter-Downsampling_44to22
    -------------------------------
    fir_disb          : in  std_logic;
    -------------------------------
    -- Control for gain compensation.
    -------------------------------
    gain_enable       : in  std_logic;  -- enable gain compensation when high
    -------------------------------
    -- Control for resync.
    -------------------------------
    clk_2skip         : in  std_logic;
--    resync_init       : in  std_logic;  -- From AGC in the BB in analog mode
    --
    rx_i_o            : out std_logic_vector(rx_length_g downto 0);
    rx_q_o            : out std_logic_vector(rx_length_g downto 0);
    -------------------------------
    -- Control for hiss_buff
    -------------------------------
    hiss_buf_init     : in std_logic;   -- Initialization of hiss_buffer
    toggle_hiss_buffer: in std_logic;   -- toggle on input data.
    rx_i_hiss_i       : in std_logic_vector(rx_length_g downto 0);
    rx_q_hiss_i       : in std_logic_vector(rx_length_g downto 0);
    clk_2skip_hiss_i  : in std_logic;   -- toggle for clk_2skip.
    -------------------------------
    -- Diag ports.
    -------------------------------
    modem_diag        : out std_logic_vector(15 downto 0)
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDRF_FRONTEND/modem802_11a2_frontend/vhdl/rtl/modem802_11a2_frontend.vhd
----------------------
  component modem802_11a2_frontend
  generic (
    radio_interface_g : integer := 3   -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    sampling_clk            : in  std_logic;
    reset_n                 : in  std_logic;

    --------------------------------------
    -- HISS mode
    --------------------------------------
    hiss_mode_n             : in  std_logic; -- 0 -> HISS active
                                             -- 1 -> HISS inactive
    --------------------------------------
    -- Tx & Rx filter
    --------------------------------------
    tx_active_i             : in  std_logic;
    tx_filter_bypass_i      : in  std_logic;
    filter_start_of_burst_i : in  std_logic;
    filter_valid_tx_i       : in  std_logic;
    tx_norm_i               : in  std_logic_vector( 7 downto 0);
    tx_data2filter_i        : in  std_logic_vector( 9 downto 0);
    tx_data2filter_q        : in  std_logic_vector( 9 downto 0);
    --
    rx_filtered_data_i      : out std_logic_vector(10 downto 0);
    rx_filtered_data_q      : out std_logic_vector(10 downto 0);
    filter_valid_rx_o       : out std_logic; -- data_valid pulse

    --------------------------------------
    -- Radio controller
    --------------------------------------
    a_rxi                   : in  std_logic_vector(10 downto 0);
    a_rxq                   : in  std_logic_vector(10 downto 0);
    a_rxdatavalid           : in  std_logic;
    --
    a_txi                   : out std_logic_vector( 9 downto 0);
    a_txq                   : out std_logic_vector( 9 downto 0);
    a_txdatavalid           : out std_logic;
    --
    pa_on                   : in  std_logic;  -- beginning constant generator
    txonoff_conf            : in  std_logic;  -- end of constant generator
    
    --------------------------------------
    -- Init sync
    --------------------------------------
    cp2_detected            : in  std_logic;  -- Synchronization found
    
    --------------------------------------
    -- AGC
    --------------------------------------
    cca_busy                : in  std_logic;    -- Detected new packet
    power_estim             : out std_logic_vector(18 downto 0); -- Power estimation
    
    --------------------------------------
    -- Registers
    --------------------------------------
    -- calibration_mux
    calmode_i               : in  std_logic;
    -- IQ calibration signal generator
    calfrq0_i               : in  std_logic_vector(22 downto 0);
    calgain_i               : in  std_logic_vector( 2 downto 0);
    -- Modules control signals for transmitter
    tx_iq_phase_i           : in  std_logic_vector( 5 downto 0);
    tx_iq_ampl_i            : in  std_logic_vector( 8 downto 0);
    --  Max value to determine when correct the data with dc_accu
    maxcount_4corr          : in  std_logic_vector(7 downto 0);
    dc_off_disb             : in  std_logic;
    -- Control for 2's complement.
    c2disb_tx_i             : in  std_logic;
    c2disb_rx_i             : in  std_logic;
    -- Signed value from reg of the constant to be sent
    a_txiconst              : in  std_logic_vector(7 downto 0)
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDRF_FRONTEND/hiss_buffer/vhdl/rtl/hiss_buffer.vhd
----------------------
  component hiss_buffer
  generic (
    buf_size_g  : integer := 4;
    rx_length_g : integer := 8);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n       : in  std_logic;
    clk_44        : in  std_logic;      -- rx chain clock.
    clk_44g       : in  std_logic;      -- gated clock.
    --------------------------------------
    -- Controls
    --------------------------------------
    hiss_buf_init : in  std_logic;      -- init when pulse
    toggle_i      : in  std_logic;      -- toggle when new data.
    -- Input data.
    rx_i_i        : in  std_logic_vector(rx_length_g-1 downto 0);
    rx_q_i        : in  std_logic_vector(rx_length_g-1 downto 0);
    clk_2skip_i   : in  std_logic;      -- Toggle for clock skip : 2 periods.
    rx_i_o        : out std_logic_vector(rx_length_g-1 downto 0);
    rx_q_o        : out std_logic_vector(rx_length_g-1 downto 0);
    clkskip_o     : out std_logic
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDRF_FRONTEND/modem802_11g_frontend/vhdl/rtl/modem802_11g_frontend.vhd
----------------------
  component modem802_11g_frontend
  generic (
    radio_interface_g : integer := 1;
    -- 0 -> reserved
    -- 1 -> BB interface
    -- 2 -> RF interface
--    use_sync_reset_g  : integer := 1
    use_sync_reset_g  : integer := 1
    -- when 1 sync_reset_n input is used else the reset_n input must be
    -- separately controlled by the reset controller
    );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    rx_11a_clk               : in  std_logic; -- 60 MHz Rxa clock.
    rx_11b_clk               : in  std_logic; -- 60 MHz Rxb clock.
    tx_11a_clk               : in  std_logic; -- 60 MHz Txa clock.
    tx_11b_clk               : in  std_logic; -- 60 MHz Txb clock.
    tx_rx_filter_clk         : in  std_logic; -- 60 MHz Txa/Rxa filter clock.
    interf_filter_clk        : in  std_logic; -- 60 MHz Rxb interf_filter clock.
    adc_pw_clk               : in  std_logic;        -- Clock for power estimation logic
    --
    rx_path_b_gclk           : in  std_logic; -- 44 MHz clock gated.
    modemb_clk               : in  std_logic; -- 44 MHz clock non gated.
    --
    reset_n                  : in  std_logic; -- global asynchronous reset
    tx_reset_n               : in  std_logic; -- tx asynchronous reset
    sync_reset_n             : in  std_logic; -- global synchronous reset
    interf_filter_reset_n    : in  std_logic; -- Reset for rx_11b_interf_filter.
    tx_rx_filter_reset_n     : in  std_logic;
    
    --------------------------------------
    -- Modem A interface
    --------------------------------------
    -- Tx & Rx filter
    txa_active_i             : in  std_logic;
    txi_data2filter_i        : in  std_logic_vector(9 downto 0);
    txq_data2filter_i        : in  std_logic_vector(9 downto 0);
    filter_toggle_tx_i       : in  std_logic;
    filter_start_of_burst_i  : in  std_logic; -- for RF, not used -> 0
    --
    rxa_filtered_data_i      : out std_logic_vector(10 downto 0);
    rxa_filtered_data_q      : out std_logic_vector(10 downto 0);
    rxa_filter_toggle_o      : out std_logic; -- rx toggle
    rxa_filter_pulse_o       : out std_logic; -- rx pulse
    -- Rxa DC offset pre-estimation - AGC interface
    sel_dc_mode              : in  std_logic;
    dc_pre_estim_i           : out std_logic_vector(10 downto 0);
    dc_pre_estim_q           : out std_logic_vector(10 downto 0);
    dc_pre_estim_valid       : out std_logic;
    -- DC offset estimation
    dc_off_4_11h_i           : out std_logic_vector(7 downto 0);
    dc_off_4_11h_q           : out std_logic_vector(7 downto 0);
    -- Rxa DC offset estimation/compensation - AGC interface
    rxa_synch_detect_i       : in  std_logic;        -- Synchronisation found
    dcadisbmode              : in std_logic_vector(1 downto 0);
    rxa_power_estim_o        : out std_logic_vector(18 downto 0);
    -- Select gain digital - AGC interface
    select_gain_digital_i    : in  std_logic_vector(1 downto 0);
    -- Gain digital outputs
    rxa_out_i_o              : out std_logic_vector(10 downto 0);
    rxa_out_q_o              : out std_logic_vector(10 downto 0);
    rxa_out_toggle_o         : out std_logic; -- rx toggle

    --------------------------------------
    -- Modem B interface
    --------------------------------------
    -- Tx filter
    txb_phi_angle_i          : in  std_logic_vector(1 downto 0); -- phi input
    txb_active_i             : in  std_logic;
    txb_init_i               : in  std_logic; -- init the registers
    -- Control for tx resync. only for BB
    fir_activate_i           : in  std_logic; -- activate the block (when disact, it finishes the transfer)
    phi_angle_tog_i          : in  std_logic; -- toggle when new data
    -- Rxb enable from AGC
    rxb_enable_i             : in  std_logic;
    -- Interference filter
    h_b_select               : in  std_logic; 
    rx_i_interf_filter_o     : out std_logic_vector(7 downto 0);
    rx_q_interf_filter_o     : out std_logic_vector(7 downto 0);
    -- These outputs are only used by the correlator in the AGC block
    rxb_filt_4_corr_i_o      : out std_logic_vector(9 downto 0);
    rxb_filt_4_corr_q_o      : out std_logic_vector(9 downto 0);
    rxb_filter_down_toggle_o : out std_logic;  -- Toggle signal from the rx_filter_wildrf.
    -- Control for interpolator
    clock_lock_i             : in  std_logic;  -- High when the clocks are locked,only for BB.
    tlockdisb_i              : in  std_logic;  -- Use clock_lock input when low,only for BB.
    tau_est_i                : in  std_logic_vector(17 downto 0);  -- from rx_11b_demod.
    clk_skip_o               : out std_logic;  -- when '0': gate clk during 1 period
    -- Control for timingoff_estim.
    timingoff_en_i           : in  std_logic;  -- activate the timingoff_estim,only for BB.
    -- Control for power_estimation
    rxb_pw_estim_active_i    : in  std_logic; -- activate the blockagc_sync_rst_n
    integration_end_i        : in  std_logic; -- indicates end of integration
    rxb_power_estimation_o   : out std_logic_vector(20 downto 0);
    -- Control for gain compensation.
    rxb_gaindisb_i           : in  std_logic;  -- enable gain compensation when high
    rxb_out_i_o              : out std_logic_vector(7 downto 0);
    rxb_out_q_o              : out std_logic_vector(7 downto 0);
    rxb_valid_o              : out std_logic;
    -- Control for rx resync. only for BB
    clk_2skip_i              : in  std_logic;

    --------------------------------------
    -- Registers
    --------------------------------------
    -- Txa filter
    txa_filter_bypass_i      : in  std_logic;
    txa_norm_i               : in  std_logic_vector(7 downto 0);
    -- Mode selection
    abmode_i                 : in  std_logic; -- 1 -> B protocol 0 -> A protocol
    -- Modules control signals for transmitter
    tx_iq_phase_i            : in  std_logic_vector(5 downto 0);
    tx_iq_ampl_i             : in  std_logic_vector(8 downto 0);
    -- calibration_mux
    calmode_i                : in  std_logic;
    -- IQ calibration signal generator
    calfrq0_i                : in  std_logic_vector(22 downto 0);
    calgain_i                : in  std_logic_vector(2 downto 0);
    -- Signed value from reg of the constant to be sent
    a_txiconst_i             : in  std_logic_vector(7 downto 0);
    b_txiconst_i             : in  std_logic_vector(7 downto 0);
    --  Max value to determine when correct the data with dc_accu
    rxa_maxcount_4corr_i     : in  std_logic_vector(7 downto 0);
    -- DC disable
    rxa_dcoff_disb_i         : in  std_logic;
    rxb_dcoff_disb_i         : in  std_logic;
    -- Coarse DC disable
    rxa_coarsedc_comp_disb_i : in  std_logic;
    -- Dig gain disable
    rxa_diggain_disb_i       : in  std_logic;
    -- Control for interference filter
    interf_filt_disb_i       : in  std_logic;  -- =1 : interference filter disabled.
    interf_filt_scaling_i    : in  std_logic_vector(6 downto 0);
    -- Control for interpolator
    interp_disb_i            : in  std_logic; -- disable interpolation when high
    interp_max_stage_i       : in  std_logic_vector(5 downto 0); -- Max value of stage
    -- Control for filter-Downsampling_44to22- disabled when high.
    b_fir_disb_i             : in  std_logic;
    -- Control for Attenuator - Coefficient of the attenuator from a register.
    attenuator_scale         : in std_logic_vector(5 downto 0);  -- = txb_norm
    -- Control for 2's complement.- disabled when high.
    c2disb_tx_i              : in  std_logic;
    c2disb_rx_i              : in  std_logic;
    -- Control for swap.
    txiqswap_i               : in  std_logic;
    rxiqswap_i               : in  std_logic;
    -- Control of sign wave sent to muxes.
    rfspeval_reg             : in std_logic_vector(3 downto 0);

    --------------------------------------
    -- Constant generator control
    --------------------------------------
    -- BB specific interface
    pa_on_i                  : in  std_logic;  -- beginning constant generator
    txonoff_conf_i           : in  std_logic;  -- end of constant generator
    -- RF specific interface
    rampup                   : in  std_logic;   -- 1 -> Constant gen 'ON'  0 -> otherwise    

    --------------------------------------
    -- ADC/DAC
    --------------------------------------
    adc_in_i                 : in  std_logic_vector(7 downto 0);
    adc_in_q                 : in  std_logic_vector(7 downto 0);
    --
    dac_out_i                : out std_logic_vector(7 downto 0);
    dac_out_q                : out std_logic_vector(7 downto 0);

    -------------------------------
    -- Diag ports.
    -------------------------------
    modem_diag               : out std_logic_vector(15 downto 0)
    );

  end component;


----------------------
-- Source: Good
----------------------
  component agc_cca_hissbb
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk     : in STD_LOGIC;             -- 80 MHz
    reset_n : in STD_LOGIC;

    --------------------------------------
    -- Registers
    --------------------------------------

    -- cca_mode used only for 11b
    -- 000: Reserved, 001: Carrier Sense only, 010: Carrier Sense Only
    -- 011: Carrier sense with energy above threshold
    -- 100: Carrier sense with timer
    -- 101: A combination of carrier sense and energy above threshold
    cca_mode     : in STD_LOGIC_VECTOR(2 downto 0);
    modeabg      : in STD_LOGIC_VECTOR(1 downto 0);  -- Reception Mode 11a(01) 11b(10) 11g(00)
    deldc2       : in STD_LOGIC_VECTOR(4 downto 0);  -- Delay for DC loop convergence
    longslot     : in STD_LOGIC;        -- Long slot mode : 1
                                        -- short slot mode: 0
    wait_cs_max  : in STD_LOGIC_VECTOR(3 downto 0);  -- Max time to wait for cca_cs
    wait_sig_max : in STD_LOGIC_VECTOR(3 downto 0);  -- Max time to wait for
                                                     -- signal valid on
    select_clk80 : in STD_LOGIC;    -- Indicates clock frequency: '1' = 80 MHz
                                    --                            '0' = 44 MHz
    -- MDMgADDESTMDUR register.
    reg_addestimdura : in STD_LOGIC_VECTOR(3 downto 0); -- additional time duration 11a
    reg_addestimdurb : in STD_LOGIC_VECTOR(3 downto 0); -- additional time duration 11b
    reg_rampdown     : in STD_LOGIC_VECTOR(2 downto 0); -- ramp-down time duration
    -- MDMgAGCCCA register.
    reg_edtransmode  : in STD_LOGIC; -- Energy Detect Transitional Mode
    reg_edmode       : in STD_LOGIC; -- Energy Detect Mode

    edtransmode_reset : out STD_LOGIC; -- Reset the edtransmode register     

    ---------------------------------------------------------------------------
    -- Modem 11a
    ---------------------------------------------------------------------------
    cp2_detected      : in  STD_LOGIC;  -- Indicates synchronization has been found
    rxv_length        : in  STD_LOGIC_VECTOR(11 downto 0); -- RX PSDU length  
    rxv_datarate      : in  STD_LOGIC_VECTOR( 3 downto 0); -- PSDU rec. rate
    rxe_errorstat     : in  STD_LOGIC_VECTOR( 1 downto 0); -- RX Error status
    rx_11a_enable     : out STD_LOGIC;  -- Enables .11a RX path block
    modem_a_fsm_rst_n : out STD_LOGIC;  -- reset modem a

    ---------------------------------------------------------------------------
    -- Modem 11b
    ---------------------------------------------------------------------------
    sfd_found        : in  STD_LOGIC;   -- SFD has been detected when hi
    packet_length    : in  STD_LOGIC_VECTOR (15 downto 0);  -- Packet length in us 
    
    energy_detect    : out STD_LOGIC;   -- Energy above threshold
    cca_busy         : out STD_LOGIC;   -- Indicates correlation result:
                                        -- a signal is present when high
    init_rx          : out STD_LOGIC;   -- Initializes the modem 11b 
    rx_11b_enable    : out STD_LOGIC;   -- Enables .11a RX path bloc

    ---------------------------------------------------------------------------
    -- BUP
    ---------------------------------------------------------------------------
    phy_rxstartend_ind : in  STD_LOGIC;                      -- Indicates start/end of Rx packet
    phy_txstartend_req : in  STD_LOGIC;                      -- Indicates start/end of transmissi
    phy_ccarst_req     : in  STD_LOGIC;                      -- Reset AGC procedu
    rxv_macaddr_match  : in  STD_LOGIC;                      -- Stop the reception because the mac 
                                                             -- addresss does not match  

    phy_ccarst_conf    : out STD_LOGIC;                      -- Acknowledges reset request
    phy_cca_ind        : out STD_LOGIC;                      -- Indicates to occupation of the medium 
    rxv_rssi           : out STD_LOGIC_VECTOR (6 downto 0);  -- Value of measured RSSI
    rxv_rxant          : out STD_LOGIC;                      -- Antenna used
    rxv_ccaaddinfo     : out STD_LOGIC_VECTOR (15 downto 8); -- Additionnal data
    
    select_rx_ab       : out STD_LOGIC;                      -- Selection Rx A or B for BuP2Modem IF
    ---------------------------------------------------------------------------
    -- Radio Controller
    ---------------------------------------------------------------------------
    cca_flags          : in  STD_LOGIC_VECTOR (5 downto 0);
                                         -- CCA marcker flag
    cca_add_flags      : in  STD_LOGIC_VECTOR (15 downto 0);
                                         -- CCA additionnal info
    cca_flags_marker   : in  STD_LOGIC;  -- Pulse to indicate cca_flags are val
    cca_cs             : in  STD_LOGIC_VECTOR (1 downto 0);
                                         -- Carrier sense informati
    cca_cs_valid       : in  STD_LOGIC;  -- Pulse to indicate cca_cs are valid
    agc_disb           : in  STD_LOGIC;  -- Disable AGC procedure
    agc_rxonoff_conf   : in  STD_LOGIC;  -- Acknowledges start/end of Rx packet
    sw_rfoff_req       : in  STD_LOGIC;  -- Request by the SW to switch to IDLE the WiLDRF  

    a_b_mode           : out STD_LOGIC;  -- Indicates the reception mode
    hiss_stream_enable : out STD_LOGIC;  -- Enable Hiss master to receive data
    agc_rxonoff_req    : out STD_LOGIC;  -- Indicates start/end of Rx packet
    agc_rfint          : out STD_LOGIC;  -- Interrupt from WiLDRF  
    agc_rfoff          : out STD_LOGIC;  -- Request to switch to IDLE the WiLDRF  
    agc_busy           : out STD_LOGIC;  -- Indicates start/end of Rx packet

    ---------------------------------------------------------------------------
    -- WLAN Indication
    ---------------------------------------------------------------------------
    wlanrxind            : out std_logic; -- Indicates a wlan reception
    ---------------------------------------------------------------------------
    -- Diag port
    ---------------------------------------------------------------------------
    agc_cca_hissbb_diag_port : out STD_LOGIC_VECTOR (15 downto 0)
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDRF_FRONTEND/agc_cca_analog_fake/vhdl/rtl/agc_cca_analog_fake.vhd
----------------------
  component agc_cca_analog_fake
  port (
    clk                 : in  std_logic;
    reset_n             : in  std_logic;

    modeabg             : in  std_logic_vector(1 downto 0);
    rf_cca              : in  std_logic;
    phy_rxstartend_ind  : in  std_logic;
    phy_txstartend_req  : in  std_logic;
    
    agc_rxonoff_req     : out std_logic;
    
    rx_init             : out std_logic;
    rx_11a_enable       : out std_logic;
    rx_11b_enable       : out std_logic;
    cca_busy            : out std_logic;
    energy_detect       : out std_logic;
    power_estim_en      : out std_logic;
    integration_end     : out std_logic
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDRF_FRONTEND/ofdm_preamble_detector/vhdl/rtl/ofdm_preamble_detector.vhd
----------------------
  component ofdm_preamble_detector
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n      : in  std_logic;
    clk          : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    reg_rstoecnt   : in  std_logic;
    a_b_mode       : in  std_logic;
    cp2_detected   : in  std_logic;
    rxe_errorstat  : in  std_logic_vector(1 downto 0);
    phy_cca_ind    : in  std_logic;
    ofdmcoex       : out std_logic_vector(7 downto 0)
  );

  end component;


----------------------
-- Source: Good
----------------------
  component modem802_11g_core
  generic (
    -- Use of Front-end register : 1 or 3 for use, 2 for don't use
    -- If the HiSS interface is used, the front-end is a part of the radio and
    -- so during the synthesis these registers could be removed.
    radio_interface_g   : integer := 1 -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    modema_clk      : in  std_logic; -- Modem 802.11a main clock
    rx_path_a_gclk  : in  std_logic; -- Rx path .11a gated clock
    tx_path_a_gclk  : in  std_logic; -- Tx path .11a gated clock
    modemb_clk      : in  std_logic; -- Modem 802.11b main clock
    rx_path_b_gclk  : in  std_logic; -- Rx path .11b gated clock
    tx_path_b_gclk  : in  std_logic; -- Tx path .11b gated clock
    fft_gclk        : in  std_logic; -- FFT gated clock
    bus_clk         : in  std_logic; -- apb clock
    bup_clk         : in  std_logic; -- BuP clock
    reset_n         : in  std_logic; -- global reset
    mdma_sm_rst_n   : in  std_logic; -- synchronous reset for state machine A
    --
    rstn_non_srpg_wild_sync  : in  std_logic;  -- Added for PSO - Santhosh
    --
    modema_rx_gating  : out std_logic; -- Gating condition for Rx path .11a
    modema_tx_gating  : out std_logic; -- Gating condition for Tx path .11a
    modemb_rx_gating  : out std_logic; -- Gating condition for Rx path .11b
    modemb_tx_gating  : out std_logic; -- Gating condition for Tx path .11b
    --
    calib_test      : out std_logic;
    
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
    -- Interface with Wild Bup
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
    -- 802.11b side
    b_txonoff_conf      : in  std_logic;
    b_rxonoff_conf      : in  std_logic;
    b_rxi               : in  std_logic_vector(7 downto 0);
    b_rxq               : in  std_logic_vector(7 downto 0);
    --    
    b_txon              : out std_logic;
    b_rxon              : out std_logic;
    b_dac_enable        : out std_logic;
    
    --------------------------------------------
    -- 11a CCA
    --------------------------------------------
    cca_busy_a          : in  std_logic;

    --------------------------------------------
    -- AGC
    --------------------------------------------
    listen_start_o   : out std_logic;
    cp2_detected     : out std_logic;
    a_phy_cca_ind    : out std_logic; -- CCA status from ModemA
    b_phy_cca_ind    : out std_logic; -- CCA status from ModemB
    
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
    power_estim_en      : in std_logic;
    integration_end     : in std_logic;
    agcproc_end         : in std_logic;
    cca_busy_b          : in std_logic;
    correl_rst_n        : in std_logic;
    agc_diag            : in std_logic_vector(15 downto 0);
    --
    power_estim         : out std_logic_vector(20 downto 0);
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
    -- Registers for wild rf front end
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
    modem_diag6              : out std_logic_vector(8  downto 0)
    );

  end component;


----------------------
-- File: modem802_11g_wildrf.vhd
----------------------
  component modem802_11g_wildrf
  generic (
    radio_interface_g : integer := 1   -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    modema_clk      : in  std_logic; -- Modem 802.11a main clock
    rx_path_a_gclk  : in  std_logic; -- Modem 802.11a gated clock for RX path
    tx_path_a_gclk  : in  std_logic; -- Modem 802.11a gated clock for TX path
    fft_gclk        : in  std_logic; -- Modem 802.11a FFT gated clock
    modemb_clk      : in  std_logic; -- Modem 802.11b main clock
    rx_path_b_gclk  : in  std_logic; -- Modem 802.11b gated clock for RX path
    tx_path_b_gclk  : in  std_logic; -- Modem 802.11b gated clock for TX path
    bus_clk         : in  std_logic; -- APB clock
    bup_clk         : in  std_logic; -- BuP clock
    sampling_clk    : in  std_logic; -- sampling clock
    filta_clk       : in  std_logic; -- sampling clock 11a filters
    filtb_clk       : in  std_logic; -- sampling clock 11b filters
    rcagc_main_clk  : in  std_logic; -- AGC clock at 80 MHz.
    reset_n         : in  std_logic; -- global reset
    select_clk80    : in  std_logic; -- Indicates clock frequency: '1' = 80 MHz
                                     --                            '0' = 44 MHz
    --
    rstn_non_srpg_wild_sync  : in  std_logic;  -- added for PSO
    --
    modema_rx_gating : out std_logic; -- Gating condition for Rx path .11a
    modema_tx_gating : out std_logic; -- Gating condition for Tx path .11a
    modemb_rx_gating : out std_logic; -- Gating condition for Rx path .11b
    modemb_tx_gating : out std_logic; -- Gating condition for Tx path .11b
    --
    clkskip         : out std_logic; -- skip one clock cycle in Rx path
    --
    calib_test      : out std_logic;
  
    --------------------------------------
    -- APB slave
    --------------------------------------
    psel_modema     : in  std_logic; -- Select. modem a registers
    psel_modemb     : in  std_logic; -- Select. modem b registers
    psel_modemg     : in  std_logic; -- Select. modem g registers
    penable         : in  std_logic; -- Defines the enable cycle.
    paddr           : in  std_logic_vector( 5 downto 0); -- Address.
    pwrite          : in  std_logic; -- Write signal.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata_modema   : out std_logic_vector(31 downto 0); -- Read modem a data.
    prdata_modemb   : out std_logic_vector(31 downto 0); -- Read modem b data.
    prdata_modemg   : out std_logic_vector(31 downto 0); -- Read modem g data.
    
    --------------------------------------------
    -- Interface with Wild Bup
    --------------------------------------------
    -- inputs signals                                                           
    bup_txdata          : in  std_logic_vector(7 downto 0); -- data to send         
    phy_txstartend_req  : in  std_logic; -- request to start a packet transmission    
    phy_data_req        : in  std_logic; -- request to send a byte                  
    phy_ccarst_req      : in  std_logic; -- request to reset CCA state machine                 
    txv_length          : in  std_logic_vector(11 downto 0);  -- RX PSDU length     
    txv_service         : in  std_logic_vector(15 downto 0);  -- tx service field   
    txv_datarate        : in  std_logic_vector( 3 downto 0); -- PSDU transm. rate
    txpwr_level         : in  std_logic_vector( 2 downto 0); -- TX power level.
    rxv_macaddr_match   : in  std_logic;                     -- Stop the reception because the mac 
                                                             -- addresss does not match  
    txv_immstop         : in  std_logic; -- request to stop the transmission               
    
    -- outputs signals                                                          
    phy_txstartend_conf : out std_logic; -- transmission started, ready for data  
    phy_rxstartend_ind  : out std_logic; -- indication of RX packet                     
    phy_ccarst_conf     : out std_logic; 
    phy_data_conf       : out std_logic; -- last byte was read, ready for new one 
    phy_data_ind        : out std_logic; -- received byte ready                  
    rxv_length          : out std_logic_vector(11 downto 0); -- RX PSDU length  
    rxv_service         : out std_logic_vector(15 downto 0); -- rx service field
    rxv_service_ind     : out std_logic;
    rxv_datarate        : out std_logic_vector( 3 downto 0); -- PSDU rec. rate
    rxe_errorstat       : out std_logic_vector( 1 downto 0); -- packet recep. stat
    phy_cca_ind         : out std_logic; -- CCA status from Modems
    bup_rxdata          : out std_logic_vector(7 downto 0); -- data received      
    rxv_rssi            : out std_logic_vector (6 downto 0);  -- Value of measured RSSI
    rxv_rxant           : out std_logic;                      -- Antenna used
    rxv_ccaaddinfo      : out std_logic_vector (15 downto 8); -- Additionnal data

    --------------------------------------
    -- HISS mode
    --------------------------------------
    hiss_mode_n         : in  std_logic;
    
    --------------------------------------
    -- Radio controller interface
    --------------------------------------
    -- 802.11a side
    a_txonoff_conf      : in  std_logic;
    a_txonoff_req       : out std_logic;
    a_txbbonoff_req_o   : out std_logic;
    a_txdatavalid       : out std_logic; -- toggle when new data (only on HiSS)
    a_dac_enable        : out std_logic;
    --
    a_rxonoff_conf      : in  std_logic;
    a_rxonoff_req       : out std_logic;
    a_rxdatavalid       : in  std_logic; -- toggle when new data (only on HiSS)
    -- 802.11b side
    b_txonoff_conf      : in  std_logic;
    b_txonoff_req       : out std_logic;
    b_txbbonoff_req     : out std_logic;
    b_txdatavalid       : out std_logic; -- toggle when new data (only on HiSS)
    b_dac_enable        : out std_logic;
    --
    b_rxonoff_conf      : in  std_logic;
    b_rxonoff_req       : out std_logic;
    b_rxdatavalid       : in  std_logic;  -- toggle when new data (only on HiSS)
    --
    clk_2skip_i         : in  std_logic;
    b_antswitch         : out std_logic;
    -- ADC/DAC
    rxi                 : in  std_logic_vector(10 downto 0);
    rxq                 : in  std_logic_vector(10 downto 0);
    txi                 : out std_logic_vector(9 downto 0);
    txq                 : out std_logic_vector(9 downto 0);
    -- misc
    pa_on               : in  std_logic; -- high when PA is on.
    gain_o              : out std_logic_vector(7 downto 0);
    sync_found          : out std_logic; -- Synchronization found active high

    --
    agc_cca_flags        : in std_logic_vector (5 downto 0);
                                       -- indicates cca procedure stat
    agc_cca_add_flags    : in std_logic_vector (15 downto 0);
                                       -- CCA additional data
    agc_cca_flags_marker : in  std_logic;  -- pulse to indicate cca_flags are val
    agc_cca_cs           : in  std_logic_vector (1 downto 0);
                                       -- carrier sense informati
    agc_cca_cs_valid     : in  std_logic;  -- pulse to indicate cca_cs are valid
    sw_rfoff_req         : in  std_logic; -- pulse resquest by SW to switch idle the WiLDRF  
    
    agc_rx_onoff_conf    : in std_logic; -- Acknowledges start/end of Rx  
    agc_ana_enable       : in std_logic; -- Enable the fake analog AGC
    rf_cca               : in std_logic; 

    agc_stream_enable    : out std_logic;  -- Enable hiss 'pipe' on reception
    agc_ab_mode          : out std_logic;  -- Mode of received packet
    agc_rx_onoff_req     : out std_logic; -- Indicates start/end of Rx  

    agc_rfoff            : out std_logic; -- Indicates that the WiLD RF can be switch off
    agc_rfint            : out std_logic; -- Interrupt from WiLDRF

    agc_busy             : out std_logic;   -- Indicates when receiving a packet(Including RF config)
    --------------------------------------
    -- WLAN Indication
    --------------------------------------
    wlanrxind            : out std_logic; -- Indicates a wlan reception
    
    --------------------------------------
    -- Diag. port
    --------------------------------------
    modem_diag0         : out std_logic_vector(15 downto 0); -- Modem b diag.
    modem_diag1         : out std_logic_vector(15 downto 0);
    modem_diag2         : out std_logic_vector(15 downto 0);
    modem_diag3         : out std_logic_vector(15 downto 0);
    --
    modem_diag4         : out std_logic_vector(15 downto 0); -- Common diag
    modem_diag5         : out std_logic_vector(15 downto 0);
    --
    modem_diag6         : out std_logic_vector(15 downto 0); -- Modem a diag.
    modem_diag7         : out std_logic_vector(15 downto 0);
    modem_diag8         : out std_logic_vector(15 downto 0);
    modem_diag9         : out std_logic_vector(15 downto 0);
    agc_cca_diag0       : out std_logic_vector(15 downto 0)
    );

  end component;



 
end modem802_11g_wildrf_pkg;
