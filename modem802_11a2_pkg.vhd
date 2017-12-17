
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: modem802_11a2_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.49   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for modem802_11a2.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/modem802_11a2/vhdl/rtl/modem802_11a2_pkg.vhd,v  
--  Log: modem802_11a2_pkg.vhd,v  
-- Revision 1.49  2005/01/19 17:24:54  Dr.C
-- #BugId:737#
-- Added residual_dc_offset.
--
-- Revision 1.48  2004/12/20 08:59:30  Dr.C
-- #BugId:810,910#
-- Updated registers, tx_top and rx_top port map.
--
-- Revision 1.47  2004/12/14 17:25:54  Dr.C
-- #BugId:595,855,810,794#
-- Updated port map of rx_top, tx_top and registers.
--
-- Revision 1.46  2004/06/18 12:49:25  Dr.C
-- Updated rx_top and iq_estimation.
--
-- Revision 1.45  2004/01/07 09:58:20  Dr.C
-- Removed unused component.
--
-- Revision 1.44  2003/12/12 10:05:54  Dr.C
-- Updated rx_top.
--
-- Revision 1.43  2003/12/03 14:43:51  Dr.C
-- Updated registers.
--
-- Revision 1.42  2003/12/02 13:44:56  Dr.C
-- Updated.
--
-- Revision 1.41  2003/11/25 18:32:04  Dr.C
-- Updated.
--
-- Revision 1.40  2003/11/14 15:50:00  Dr.C
-- Updated.
--
-- Revision 1.39  2003/11/03 15:55:35  Dr.C
-- Updated tx_top_a2.
--
-- Revision 1.38  2003/11/03 13:38:07  rrich
-- Added new IQMMEST input to iq_estimation block.
--
-- Revision 1.37  2003/11/03 09:18:53  Dr.C
-- Updated registers.
--
-- Revision 1.36  2003/10/23 17:16:25  Dr.C
-- Updated.
--
-- Revision 1.35  2003/10/23 12:52:51  Dr.C
-- Updated iq_estimation.
--
-- Revision 1.34  2003/10/15 17:32:33  Dr.C
-- Updated tops.
--
-- Revision 1.33  2003/10/13 14:57:26  Dr.C
-- Updated tx_top_a2.
--
-- Revision 1.32  2003/10/10 16:37:48  Dr.C
-- Added tx & rx gating.
--
-- Revision 1.31  2003/10/10 15:46:00  Dr.C
-- Updated gated clock.
--
-- Revision 1.30  2003/09/25 13:30:55  Dr.C
-- Updated generic of calibration_rnd.
--
-- Revision 1.29  2003/09/22 10:08:06  Dr.C
-- Updated registers and rx_top port map.
--
-- Revision 1.28  2003/09/17 06:59:28  Dr.F
-- port map changed.
--
-- Revision 1.27  2003/09/10 07:22:07  Dr.F
-- removed phy_reset_n in rx_top.
--
-- Revision 1.26  2003/08/29 16:32:54  Dr.B
-- iq_comp has changed its generics.
--
-- Revision 1.25  2003/07/29 10:37:53  Dr.C
-- Added cp2_detected output to modem802_11a2_core
--
-- Revision 1.24  2003/07/27 07:43:31  Dr.F
-- port map changed.
--
-- Revision 1.23  2003/07/22 15:51:44  Dr.C
-- Updated.
--
-- Revision 1.22  2003/07/21 13:46:01  Dr.C
-- Removed wild_rf components.
--
-- Revision 1.21  2003/07/02 13:44:13  Dr.C
-- Updated tx_rx_filter.
--
-- Revision 1.20  2003/07/01 16:13:25  Dr.C
-- Updated core, wild_rf and wild_rf_fpga.
--
-- Revision 1.19  2003/06/30 10:30:15  arisse
-- Updated register signals according to spec 0.15 of modema2.
--
-- Revision 1.18  2003/06/11 09:34:23  Dr.C
-- Removed last version.
--
-- Revision 1.17  2003/06/05 07:07:05  Dr.C
-- Updated tx_rx_filter.
--
-- Revision 1.16  2003/06/04 16:21:26  rrich
-- Integrated iq_estimation block
--
-- Revision 1.15  2003/05/26 09:38:23  Dr.F
-- added rx_packet_end.
--
-- Revision 1.14  2003/05/23 15:34:04  Dr.J
-- Updated
--
-- Revision 1.13  2003/05/15 08:08:31  Dr.C
-- Added modem802_11a2_wild_rf_fpga.
--
-- Revision 1.12  2003/04/30 09:26:02  Dr.A
-- IQ compensation added.
--
-- Revision 1.11  2003/04/28 10:10:39  arisse
-- Changed port map of modema2 registers.
--
-- Revision 1.10  2003/04/24 12:04:34  Dr.A
-- New iq_compensation block.
--
-- Revision 1.9  2003/04/23 08:48:22  Dr.C
-- Added modem core and wild_rf.
--
-- Revision 1.8  2003/04/14 08:35:06  Dr.A
-- New blocks moved from tx_top.
--
-- Revision 1.7  2003/04/08 12:31:19  Dr.A
-- Removed scrambler_init.
--
-- Revision 1.6  2003/04/07 16:04:08  Dr.F
-- port map changed.
--
-- Revision 1.5  2003/04/04 10:26:57  arisse
-- updated register ports.
--
-- Revision 1.4  2003/04/03 10:02:43  Dr.A
-- Added calib_test.
--
-- Revision 1.3  2003/04/02 08:10:31  Dr.A
-- Updated tx_top and fft_shell port maps.
--
-- Revision 1.2  2003/03/31 08:23:19  Dr.F
-- port map change.
--
-- Revision 1.1  2003/03/28 16:35:34  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package modem802_11a2_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/iq_estimation/vhdl/rtl/iq_estimation.vhd
----------------------
  component iq_estimation

  generic (
    iq_i_width_g   : integer := 11;   -- Width of the input IQ signals
    gain_width_g   : integer := 9;    -- Gain  mismatch estimate width
    phase_width_g  : integer := 6;    -- Phase mismatch estimate width
    preset_width_g : integer := 16    -- Estimate presets width 
  );
  
  port (
    clk             : in  std_logic; -- Module clock
    reset_n         : in  std_logic; -- Asynchronous reset

    --------------------------------------
    -- Controls
    --------------------------------------
    rx_iqmm_est     : in  std_logic; -- Enable from register
    rx_iqmm_est_en  : in  std_logic; -- Estimation enable (high during data)
    rx_iqmm_out_dis : in  std_logic; -- Outputs disable (high after signal field error)
    rx_iqmm_reset   : in  std_logic; -- Restart estimation
    rx_packet_end   : in  std_logic; -- Packet end
    rx_iqmm_g_pset  : in  std_logic_vector(preset_width_g-1 downto 0);
    rx_iqmm_ph_pset : in  std_logic_vector(preset_width_g-1 downto 0);
    rx_iqmm_g_step  : in  std_logic_vector(7 downto 0);
    rx_iqmm_ph_step : in  std_logic_vector(7 downto 0);
    --
    iqmm_reset_done : out std_logic; -- Restart estimation done

    --------------------------------------
    -- Data in
    --------------------------------------
    data_valid_in   : in  std_logic; -- High when a new data is available
    i_in            : in  std_logic_vector(iq_i_width_g-1 downto 0);
    q_in            : in  std_logic_vector(iq_i_width_g-1 downto 0);

    --------------------------------------
    -- Estimates out
    --------------------------------------
    rx_iqmm_g_est         : out std_logic_vector(gain_width_g-1 downto 0);
    rx_iqmm_ph_est        : out std_logic_vector(phase_width_g-1 downto 0);
    gain_accum            : out std_logic_vector(preset_width_g-1 downto 0);
    phase_accum           : out std_logic_vector(preset_width_g-1 downto 0)
  );

  end component;


----------------------
-- Source: Good
----------------------
  component residual_dc_offset
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic; -- Module clock. 80 MHz
    reset_n      : in  std_logic; -- Asynchronous reset
    sync_reset_n : in  std_logic; -- Synchronous reset.

    --------------------------------------
    -- I & Q
    --------------------------------------
    i_i          : in  std_logic_vector(10 downto 0);
    q_i          : in  std_logic_vector(10 downto 0);
    data_valid_i : in  std_logic; -- toggle when a new data is available
    --
    i_o          : out std_logic_vector(10 downto 0);
    q_o          : out std_logic_vector(10 downto 0);
    data_valid_o : out std_logic; -- toggle when a new data is available

    --------------------------------------
    -- Registers
    --------------------------------------
    dcoffset_disb : in  std_logic; -- Disable the dc offset correction
    
    --------------------------------------
    -- Synchronization
    --------------------------------------
    cp2_detected  : in  std_logic   -- Synchronisation found
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/iq_compensation/vhdl/rtl/iq_compensation.vhd
----------------------
  component iq_compensation
  generic ( 
    iq_i_width_g     : integer := 9; -- IQ inputs width.
    iq_o_width_g     : integer := 9; -- IQ outputs width.
    phase_width_g    : integer := 6; -- Phase parameter width.
    ampl_width_g     : integer := 9; -- Amplitude parameter width.
    toggle_in_g      : integer := 0; -- when 1 the data_valid_i toggles
    toggle_out_g     : integer := 0; -- when 1 the data_valid_o toggles
    --
--    use_sync_reset_g : integer := 1  -- when 1 sync_reset_n input is used
    use_sync_reset_g : integer := 1  -- when 1 sync_reset_n input is used
  );                                 -- else the reset_n input must be separately
  port (                             -- controlled by the reset controller
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic; -- Module clock. 60 MHz
    reset_n      : in  std_logic; -- Asynchronous reset.
    sync_reset_n : in  std_logic; -- Block enable.
    --------------------------------------
    -- Controls
    --------------------------------------
    -- Phase compensation control.
    phase_i      : in  std_logic_vector(phase_width_g-1 downto 0);
    -- Amplitude compensation control.
    ampl_i       : in  std_logic_vector(ampl_width_g-1 downto 0);
    data_valid_i : in  std_logic; -- high when a new data is available
    --
    data_valid_o : out std_logic; -- high/toggle when a new data is available
    --------------------------------------
    -- Data
    --------------------------------------
    i_in         : in  std_logic_vector(iq_i_width_g-1 downto 0);
    q_in         : in  std_logic_vector(iq_i_width_g-1 downto 0);
    --
    i_out        : out std_logic_vector(iq_o_width_g-1 downto 0);
    q_out        : out std_logic_vector(iq_o_width_g-1 downto 0)
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/tx_top_a2/vhdl/rtl/tx_top_a2.vhd
----------------------
  component tx_top_a2
  generic (
    fsize_in_g        : integer := 10 -- I & Q size for filter input.
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                      : in  std_logic; -- Clock at 80 MHz for state machine.
    gclk                     : in  std_logic; -- Gated clock at 80 MHz.
    reset_n                  : in  std_logic; -- asynchronous reset
    --------------------------------------
    -- BuP interface
    --------------------------------------
    phy_txstartend_req_i     : in  std_logic;
    phy_txstartend_conf_o    : out std_logic;
    txv_immstop_i            : in  std_logic;
    phy_data_req_i           : in  std_logic;
    phy_data_conf_o          : out std_logic;
    bup_txdata_i             : in  std_logic_vector( 7 downto 0);
    -- Frame parameters: rate, length, service field, TX power level.
    txv_rate_i               : in  std_logic_vector( 3 downto 0);
    txv_length_i             : in  std_logic_vector(11 downto 0);
    txv_service_i            : in  std_logic_vector(15 downto 0);
    txv_txpwr_level_i        : in  std_logic_vector( 2 downto 0);
    --------------------------------------
    -- RF control FSM interface
    --------------------------------------
    dac_powerdown_dyn_i      : in  std_logic;
    a_txonoff_req_o          : out std_logic;
    a_txbbonoff_req_o        : out std_logic;
    a_txonoff_conf_i         : in  std_logic;
    a_txpga_o                : out std_logic_vector( 2 downto 0);
    dac_on_o                 : out std_logic;
    -- to rx
    tx_active_o              : out std_logic;
    sync_reset_n_o           : out std_logic; -- FFT synchronous reset.
    --------------------------------------
    -- IFFT interface
    --------------------------------------
    -- Controls to FFT
    tx_start_signal_o        : out std_logic; -- 'start of signal' marker.
    tx_end_burst_o           : out std_logic; -- 'end of burst' marker.
    mapper_data_valid_o      : out std_logic; -- High when mapper data is valid.
    fft_serial_data_ready_o  : out std_logic;
    -- Data to FFT
    mapper_data_i_o          : out std_logic_vector(7 downto 0);
    mapper_data_q_o          : out std_logic_vector(7 downto 0);
    -- Controls from FFT
    ifft_tx_start_of_signal_i: in  std_logic;   -- 'start of signal' marker.
    ifft_tx_end_burst_i      : in  std_logic;   -- 'end of burst' marker.
    ifft_data_ready_i        : in  std_logic;
    -- Data from FFT
    ifft_data_i_i            : in  FFT_ARRAY_T; -- Data from FFT.
    ifft_data_q_i            : in  FFT_ARRAY_T; -- Data from FFT.
    --------------------------------------
    -- TX filter interface
    --------------------------------------
    data2filter_i_o          : out std_logic_vector(fsize_in_g-1 downto 0);
    data2filter_q_o          : out std_logic_vector(fsize_in_g-1 downto 0);
    filter_start_of_burst_o  : out std_logic;
    filter_sampleready_o     : out std_logic;
    --------------------------------------
    -- Parameters from registers
    --------------------------------------
    add_short_pre_i          : in  std_logic_vector( 1 downto 0); -- prepreamble value.
    tx_enddel_i              : in  std_logic_vector( 7 downto 0); -- front delay.
    -- Test signals
    prbs_sel_i               : in  std_logic_vector( 1 downto 0);
    prbs_inv_i               : in  std_logic;
    prbs_init_i              : in  std_logic_vector(22 downto 0);
    -- Scrambler
    scrmode_i                : in  std_logic;  -- '1' to reinit the scrambler btw two bursts.
    scrinitval_i             : in  std_logic_vector(6 downto 0); -- Seed init value.
    tx_scrambler_o           : out std_logic_vector(6 downto 0); -- scrambler init value
    --------------------------------------
    -- Diag port
    --------------------------------------
    tx_top_diag              : out std_logic_vector(8 downto 0)
  );

  end component;


----------------------
-- Source: Good
----------------------
  component modema2_registers
  generic (
    -- Use of Front-end register : 1 or 3 for use, 2 for don't use
    -- If the HiSS interface is used, the front-end is a part of the radio and
    -- so during the synthesis these registers could be removed.
    radio_interface_g   : integer := 1 -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    reset_n             : in  std_logic;  -- asynchronous negative reset
    -- APB interface
    apb_clk             : in  std_logic;  -- APB clock (sync with clk in)
    apb_sel_i           : in  std_logic;  -- APB select
    apb_enable_i        : in  std_logic;  -- APB enable
    apb_write_i         : in  std_logic;  -- APB write
    apb_addr_i          : in  std_logic_vector(5 downto 0);   -- APB address
    apb_wdata_i         : in  std_logic_vector(31 downto 0);  -- APB write data
    apb_rdata_o         : out std_logic_vector(31 downto 0);  -- APB read data
    -- Clock controls
    calib_test_o        : out std_logic;  -- Do not gate clocks when high
    -- MDMaTXCNTL
    add_short_pre_o     : out std_logic_vector(1 downto 0);
    scrmode_o           : out std_logic;  -- '1' to tx scrambler.
    tx_filter_bypass_o  : out std_logic;  -- to tx_rx_filter
    dac_powerdown_dyn_o : out std_logic;
    tx_enddel_o         : out std_logic_vector(7 downto 0);  -- to Tx mux
    scrinitval_o        : out std_logic_vector(6 downto 0);  -- Seed init value
    tx_scrambler_i      : in  std_logic_vector(6 downto 0);  -- from scrambler
    c2disb_tx_o         : out std_logic;
    tx_norm_factor_o    : out std_logic_vector(7 downto 0);  -- to tx_rx_filter
    -- MDMaTXIQCOMP
    tx_iq_phase_o       : out std_logic_vector(5 downto 0);  -- to tx iq_comp
    tx_iq_ampl_o        : out std_logic_vector(8 downto 0);  -- to tx iq_comp
    -- MDMaTXCONST
    tx_const_o          : out std_logic_vector(7 downto 0);  -- to DAC (I only)
    -- MDMaRXCNTL0
    rx_iq_step_ph_o     : out std_logic_vector(7 downto 0);
    rx_iq_step_g_o      : out std_logic_vector(7 downto 0);
    adc_powerdown_dyn_o : out std_logic;
    c2disb_rx_o         : out std_logic;
    wf_window_o         : out std_logic_vector(1 downto 0);  -- to wiener
    reduceerasures_o    : out std_logic_vector(1 downto 0);  -- to rx_equ
    res_dco_disb_o      : out std_logic;                     -- to residual_dc_offset
    iq_mm_estrst_o      : out std_logic;                     -- to iq_estimation
    iq_mm_estrst_done_i : in  std_logic;
    iq_mm_est_o         : out std_logic;                     -- to iq_estimation
    dc_off_disb_o       : out std_logic;                     -- to dc_offset
    -- MDMaRXCNTL1
    rx_del_dc_cor_o     : out std_logic_vector(7 downto 0);  -- to dc_offset
    rx_length_limit_o   : out std_logic_vector(11 downto 0); -- to rx_sm
    rx_length_chk_en_o  : out std_logic;
    -- MDMaRXIQPRESET
    rx_iq_ph_preset_o   : out std_logic_vector(15 downto 0);
    rx_iq_g_preset_o    : out std_logic_vector(15 downto 0);
    -- MDMaRXIQEST
    rx_iq_ph_est_i      : in  std_logic_vector(15 downto 0);
    rx_iq_g_est_i       : in  std_logic_vector(15 downto 0);
    -- MDMaTIMEDOMSTAT
    rx_ybnb_i           : in  std_logic_vector(6 downto 0);
    rx_freq_off_est_i   : in  std_logic_vector(19 downto 0);
    -- MDMaEQCNTL1
    histoffset18_o      : out std_logic_vector(1 downto 0);
    histoffset12_o      : out std_logic_vector(1 downto 0);
    histoffset9_o       : out std_logic_vector(1 downto 0);
    histoffset6_o       : out std_logic_vector(1 downto 0);
    satmaxncar18_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar12_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar9_o       : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar6_o       : out std_logic_vector(5 downto 0);  -- to rx_equ
    -- MDMaEQCNTL2
    histoffset54_o      : out std_logic_vector(1 downto 0);
    histoffset48_o      : out std_logic_vector(1 downto 0);
    histoffset36_o      : out std_logic_vector(1 downto 0);
    histoffset24_o      : out std_logic_vector(1 downto 0);
    satmaxncar54_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar48_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar36_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar24_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    -- MDMaINITSYNCCNTL
    detect_thr_carrier_o : out std_logic_vector(3 downto 0);
    initsync_timoffst_o : out std_logic_vector(2 downto 0);
    -- Combiner accumulator for slow preamble detection
    initsync_autothr1_o : out std_logic_vector(5 downto 0);
    -- Combiner accumulator for fast preamble detection
    initsync_autothr0_o : out std_logic_vector(5 downto 0);
    -- MDMaPRBSCNTL
    prbs_inv_o          : out std_logic;
    prbs_sel_o          : out std_logic_vector(1 downto 0);
    prbs_init_o         : out std_logic_vector(22 downto 0);
    -- MDMaIQCALIBCNTL
    calmode_o           : out std_logic;
    calgain_o           : out std_logic_vector(2 downto 0);
    calfrq0_o           : out std_logic_vector(22 downto 0)
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/fft_shell/vhdl/rtl/fft_shell.vhd
----------------------
  component fft_shell
  generic(
    data_size_g   : integer := 11;
    cordic_bits_g : integer := 10;
    ifft_norm_g   : integer := 0
    );
  port(
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    masterclk            : in  std_logic;
    reset_n              : in  std_logic;
    sync_reset_n         : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    -- signal to control the fft_mode
    tx_rxn_i             : in  std_logic; -- High for TX mode.
    --------------------------------------
    -- Controls for TX mode
    --------------------------------------
    -- signals from/to mapper.
    tx_start_of_signal_i : in  std_logic; -- 'start of signal' marker.
    tx_end_of_burst_i    : in  std_logic; -- 'end of burst' marker.
    tx_data_valid_i      : in  std_logic; -- High when input data is valid.
    tx_data_ready_i      : in  std_logic; -- Next block ready for data.
    --
    tx_data_ready_o      : out std_logic; -- FFT ready for data.
    tx_start_of_signal_o : out std_logic; -- 'start of signal' marker.
    tx_end_of_burst_o    : out std_logic; -- 'end of burst' marker.
    --------------------------------------
    -- Controls for RX mode
    --------------------------------------
    -- signals from/to preceeding module
    rx_start_of_burst_i  : in  std_logic;
    rx_start_of_symbol_i : in  std_logic;
    rx_data_valid_i      : in  std_logic;
    rx_data_ready_o      : out std_logic;
    -- signals from/to subsequent module
    rx_data_ready_i      : in  std_logic;
    rx_data_valid_o      : out std_logic;
    rx_start_of_burst_o  : out std_logic;
    rx_start_of_symbol_o : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    -- TX data in.
    tx_x_i               : in  std_logic_vector(data_size_g-1 downto 0);
    tx_y_i               : in  std_logic_vector(data_size_g-1 downto 0);
    -- RX data in.
    rx_x_i               : in  std_logic_vector(data_size_g-1 downto 0);
    rx_y_i               : in  std_logic_vector(data_size_g-1 downto 0);
    -- Data out.
    x_0_o                : out std_logic_vector(data_size_g downto 0);
    y_0_o                : out std_logic_vector(data_size_g downto 0);
    x_1_o                : out std_logic_vector(data_size_g downto 0);
    y_1_o                : out std_logic_vector(data_size_g downto 0);
    x_2_o                : out std_logic_vector(data_size_g downto 0);
    y_2_o                : out std_logic_vector(data_size_g downto 0);
    x_3_o                : out std_logic_vector(data_size_g downto 0);
    y_3_o                : out std_logic_vector(data_size_g downto 0);
    x_4_o                : out std_logic_vector(data_size_g downto 0);
    y_4_o                : out std_logic_vector(data_size_g downto 0);
    x_5_o                : out std_logic_vector(data_size_g downto 0);
    y_5_o                : out std_logic_vector(data_size_g downto 0);
    x_6_o                : out std_logic_vector(data_size_g downto 0);
    y_6_o                : out std_logic_vector(data_size_g downto 0);
    x_7_o                : out std_logic_vector(data_size_g downto 0);
    y_7_o                : out std_logic_vector(data_size_g downto 0);
    x_8_o                : out std_logic_vector(data_size_g downto 0);
    y_8_o                : out std_logic_vector(data_size_g downto 0);
    x_9_o                : out std_logic_vector(data_size_g downto 0);
    y_9_o                : out std_logic_vector(data_size_g downto 0);
    x_10_o               : out std_logic_vector(data_size_g downto 0);
    y_10_o               : out std_logic_vector(data_size_g downto 0);
    x_11_o               : out std_logic_vector(data_size_g downto 0);
    y_11_o               : out std_logic_vector(data_size_g downto 0);
    x_12_o               : out std_logic_vector(data_size_g downto 0);
    y_12_o               : out std_logic_vector(data_size_g downto 0);
    x_13_o               : out std_logic_vector(data_size_g downto 0);
    y_13_o               : out std_logic_vector(data_size_g downto 0);
    x_14_o               : out std_logic_vector(data_size_g downto 0);
    y_14_o               : out std_logic_vector(data_size_g downto 0);
    x_15_o               : out std_logic_vector(data_size_g downto 0);
    y_15_o               : out std_logic_vector(data_size_g downto 0);
    x_16_o               : out std_logic_vector(data_size_g downto 0);
    y_16_o               : out std_logic_vector(data_size_g downto 0);
    x_17_o               : out std_logic_vector(data_size_g downto 0);
    y_17_o               : out std_logic_vector(data_size_g downto 0);
    x_18_o               : out std_logic_vector(data_size_g downto 0);
    y_18_o               : out std_logic_vector(data_size_g downto 0);
    x_19_o               : out std_logic_vector(data_size_g downto 0);
    y_19_o               : out std_logic_vector(data_size_g downto 0);
    x_20_o               : out std_logic_vector(data_size_g downto 0);
    y_20_o               : out std_logic_vector(data_size_g downto 0);
    x_21_o               : out std_logic_vector(data_size_g downto 0);
    y_21_o               : out std_logic_vector(data_size_g downto 0);
    x_22_o               : out std_logic_vector(data_size_g downto 0);
    y_22_o               : out std_logic_vector(data_size_g downto 0);
    x_23_o               : out std_logic_vector(data_size_g downto 0);
    y_23_o               : out std_logic_vector(data_size_g downto 0);
    x_24_o               : out std_logic_vector(data_size_g downto 0);
    y_24_o               : out std_logic_vector(data_size_g downto 0);
    x_25_o               : out std_logic_vector(data_size_g downto 0);
    y_25_o               : out std_logic_vector(data_size_g downto 0);
    x_26_o               : out std_logic_vector(data_size_g downto 0);
    y_26_o               : out std_logic_vector(data_size_g downto 0);
    x_27_o               : out std_logic_vector(data_size_g downto 0);
    y_27_o               : out std_logic_vector(data_size_g downto 0);
    x_28_o               : out std_logic_vector(data_size_g downto 0);
    y_28_o               : out std_logic_vector(data_size_g downto 0);
    x_29_o               : out std_logic_vector(data_size_g downto 0);
    y_29_o               : out std_logic_vector(data_size_g downto 0);
    x_30_o               : out std_logic_vector(data_size_g downto 0);
    y_30_o               : out std_logic_vector(data_size_g downto 0);
    x_31_o               : out std_logic_vector(data_size_g downto 0);
    y_31_o               : out std_logic_vector(data_size_g downto 0);
    x_32_o               : out std_logic_vector(data_size_g downto 0);
    y_32_o               : out std_logic_vector(data_size_g downto 0);
    x_33_o               : out std_logic_vector(data_size_g downto 0);
    y_33_o               : out std_logic_vector(data_size_g downto 0);
    x_34_o               : out std_logic_vector(data_size_g downto 0);
    y_34_o               : out std_logic_vector(data_size_g downto 0);
    x_35_o               : out std_logic_vector(data_size_g downto 0);
    y_35_o               : out std_logic_vector(data_size_g downto 0);
    x_36_o               : out std_logic_vector(data_size_g downto 0);
    y_36_o               : out std_logic_vector(data_size_g downto 0);
    x_37_o               : out std_logic_vector(data_size_g downto 0);
    y_37_o               : out std_logic_vector(data_size_g downto 0);
    x_38_o               : out std_logic_vector(data_size_g downto 0);
    y_38_o               : out std_logic_vector(data_size_g downto 0);
    x_39_o               : out std_logic_vector(data_size_g downto 0);
    y_39_o               : out std_logic_vector(data_size_g downto 0);
    x_40_o               : out std_logic_vector(data_size_g downto 0);
    y_40_o               : out std_logic_vector(data_size_g downto 0);
    x_41_o               : out std_logic_vector(data_size_g downto 0);
    y_41_o               : out std_logic_vector(data_size_g downto 0);
    x_42_o               : out std_logic_vector(data_size_g downto 0);
    y_42_o               : out std_logic_vector(data_size_g downto 0);
    x_43_o               : out std_logic_vector(data_size_g downto 0);
    y_43_o               : out std_logic_vector(data_size_g downto 0);
    x_44_o               : out std_logic_vector(data_size_g downto 0);
    y_44_o               : out std_logic_vector(data_size_g downto 0);
    x_45_o               : out std_logic_vector(data_size_g downto 0);
    y_45_o               : out std_logic_vector(data_size_g downto 0);
    x_46_o               : out std_logic_vector(data_size_g downto 0);
    y_46_o               : out std_logic_vector(data_size_g downto 0);
    x_47_o               : out std_logic_vector(data_size_g downto 0);
    y_47_o               : out std_logic_vector(data_size_g downto 0);
    x_48_o               : out std_logic_vector(data_size_g downto 0);
    y_48_o               : out std_logic_vector(data_size_g downto 0);
    x_49_o               : out std_logic_vector(data_size_g downto 0);
    y_49_o               : out std_logic_vector(data_size_g downto 0);
    x_50_o               : out std_logic_vector(data_size_g downto 0);
    y_50_o               : out std_logic_vector(data_size_g downto 0);
    x_51_o               : out std_logic_vector(data_size_g downto 0);
    y_51_o               : out std_logic_vector(data_size_g downto 0);
    x_52_o               : out std_logic_vector(data_size_g downto 0);
    y_52_o               : out std_logic_vector(data_size_g downto 0);
    x_53_o               : out std_logic_vector(data_size_g downto 0);
    y_53_o               : out std_logic_vector(data_size_g downto 0);
    x_54_o               : out std_logic_vector(data_size_g downto 0);
    y_54_o               : out std_logic_vector(data_size_g downto 0);
    x_55_o               : out std_logic_vector(data_size_g downto 0);
    y_55_o               : out std_logic_vector(data_size_g downto 0);
    x_56_o               : out std_logic_vector(data_size_g downto 0);
    y_56_o               : out std_logic_vector(data_size_g downto 0);
    x_57_o               : out std_logic_vector(data_size_g downto 0);
    y_57_o               : out std_logic_vector(data_size_g downto 0);
    x_58_o               : out std_logic_vector(data_size_g downto 0);
    y_58_o               : out std_logic_vector(data_size_g downto 0);
    x_59_o               : out std_logic_vector(data_size_g downto 0);
    y_59_o               : out std_logic_vector(data_size_g downto 0);
    x_60_o               : out std_logic_vector(data_size_g downto 0);
    y_60_o               : out std_logic_vector(data_size_g downto 0);
    x_61_o               : out std_logic_vector(data_size_g downto 0);
    y_61_o               : out std_logic_vector(data_size_g downto 0);
    x_62_o               : out std_logic_vector(data_size_g downto 0);
    y_62_o               : out std_logic_vector(data_size_g downto 0);
    x_63_o               : out std_logic_vector(data_size_g downto 0);
    y_63_o               : out std_logic_vector(data_size_g downto 0)
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/rx_top/vhdl/rtl/rx_top.vhd
----------------------
  component rx_top

  port (
    ---------------------------------------
    -- Clock & reset
    ---------------------------------------
    clk                : in  std_logic;     -- Clock for state machine
    gclk               : in  std_logic;     -- Gated clock
    reset_n            : in  std_logic;
    mdma_sm_rst_n      : in  std_logic;     -- synchronous reset for state machine

    ---------------------------------------
    -- FFT
    ---------------------------------------
    fft_data_ready_i      : in  std_logic;  -- FFT control signals
    fft_start_of_burst_i  : in  std_logic;
    fft_start_of_symbol_i : in  std_logic;
    fft_data_valid_i      : in  std_logic;
    fft_i_i               : in  FFT_ARRAY_T;
    fft_q_i               : in  FFT_ARRAY_T;
    td_start_of_symbol_o  : out std_logic;  -- Time domain control signals
    td_start_of_burst_o   : out std_logic;
    td_data_valid_o       : out std_logic;
    fd_data_ready_o       : out std_logic;
    td_i_o                : out std_logic_vector(10 downto 0);
    td_q_o                : out std_logic_vector(10 downto 0); 

    ---------------------------------------
    -- Bup interface
    ---------------------------------------
    phy_ccarst_req_i     : in  std_logic;
    tx_dac_on_i          : in  std_logic;  -- TX DAC ON (1). Signal the status
                                           -- of TX to RX state machine.
    rxe_errorstat_o      : out std_logic_vector(1 downto 0);   --RXERROR vector
                                        -- is valid at the falling edge
                                        -- of rx_start_end_ind_o
                                        -- The coding is as follows:
                                        -- 0b00: No Error
                                        -- 0b01: Format Violation
                                        -- 0b10: Carrier lost
                                        -- 0b11: Unsupported rate
    rxv_length_o         : out std_logic_vector(11 downto 0);  -- RXVECTOR length
                                           -- parameter is valid rx_start_end_ind_o
                                           -- goes from 0 to 1.
    rxv_datarate_o       : out std_logic_vector(3 downto 0);
                                        -- RXVECTOR rate parameter
    phy_cca_ind_o        : out std_logic;  -- 0: IDLE
                                           -- 1: BUSY 
    phy_ccarst_conf_o    : out std_logic;
    rxv_service_o        : out std_logic_vector(15 downto 0);
    rxv_service_ind_o    : out std_logic;
    bup_rxdata_o         : out std_logic_vector(7 downto 0);
    phy_data_ind_o       : out std_logic;
    phy_rxstartend_ind_o : out std_logic;  -- rising edge: PHY_RXSTART.ind 
                                           -- falling edge: PHY_RXEND.ind
    ---------------------------------------
    -- Radio controller
    ---------------------------------------
    rxactive_conf_i     : in  std_logic;
    rssi_on_o           : out std_logic;
    rxactive_req_o      : out std_logic;
    adc_powerctrl_o     : out std_logic_vector(1 downto 0);
                                           -- falling edge: PHY_RXEND.ind
    --------------------------------------------
    -- CCA
    --------------------------------------------
    cca_busy_i          : in  std_logic;
    listen_start_o      : out std_logic; -- high when start to listen
    cp2_detected_o      : out std_logic; -- Detected preamble

    ---------------------------------------
    -- IQ compensation
    ---------------------------------------
    i_iqcomp_i          : in std_logic_vector(10 downto 0);
    q_iqcomp_i          : in std_logic_vector(10 downto 0);
    iqcomp_data_valid_i : in std_logic;
    --
    rx_dpath_reset_n_o  : out std_logic;
    rx_packet_end_o     : out std_logic;  -- pulse on end of RX packet

    enable_iq_estim_o   : out std_logic;  -- `1': enable iq estimation block.
    disable_output_iq_estim_o : out std_logic;  -- `1': disable iq estimation outputs.
    
    ---------------------------------------
    -- Registers
    ---------------------------------------
    -- INIT sync
    detect_thr_carrier_i: in std_logic_vector(3 downto 0);-- Thres carrier sense
    initsync_autothr0_i : in  std_logic_vector(5 downto 0);-- Thresholds for
    initsync_autothr1_i : in  std_logic_vector(5 downto 0);-- preamble detection
    -- Samplefifo                                           
    sampfifo_timoffst_i : in  std_logic_vector(2 downto 0);  -- Timing acquisition
                                                             -- headroom
    -- For IQ calibration module -- TBD
    calmode_i           : in  std_logic;  -- Calibration mode
    -- ADC mode
    adcpdmod_i          : in  std_logic;  -- Power down mode enable
    -- Wiener filter
    wf_window_i         : in  std_logic_vector(1 downto 0);  -- Window length
    reducerasures_i     : in  std_logic_vector(1 downto 0);  -- Reduce erasures
    -- Channel decoder
    length_limit_i      : in  std_logic_vector(11 downto 0); -- Max. Rx length
    rx_length_chk_en_i  : in  std_logic;                     -- Rx length check enable
    -- Equalizer
    histoffset_54_i  : in std_logic_vector(1 downto 0);  -- Histogram offset
    histoffset_48_i  : in std_logic_vector(1 downto 0);
    histoffset_36_i  : in std_logic_vector(1 downto 0);
    histoffset_24_i  : in std_logic_vector(1 downto 0);
    histoffset_18_i  : in std_logic_vector(1 downto 0);
    histoffset_12_i  : in std_logic_vector(1 downto 0);
    histoffset_09_i  : in std_logic_vector(1 downto 0);
    histoffset_06_i  : in std_logic_vector(1 downto 0);
    satmaxncarr_54_i : in std_logic_vector(5 downto 0); -- Saturate max N carrier
    satmaxncarr_48_i : in std_logic_vector(5 downto 0);
    satmaxncarr_36_i : in std_logic_vector(5 downto 0);
    satmaxncarr_24_i : in std_logic_vector(5 downto 0);
    satmaxncarr_18_i : in std_logic_vector(5 downto 0);
    satmaxncarr_12_i : in std_logic_vector(5 downto 0);
    satmaxncarr_09_i : in std_logic_vector(5 downto 0);
    satmaxncarr_06_i : in std_logic_vector(5 downto 0);
    -- Frequency correction
    freq_off_est_o   : out std_logic_vector(19 downto 0);
    -- Preprocessing sample number before sync
    ybnb_o           : out std_logic_vector(6 downto 0);
   
    ---------------------------------
    -- Diag. port
    ---------------------------------
    rx_top_diag0     : out std_logic_vector(15 downto 0);
    rx_top_diag1     : out std_logic_vector(15 downto 0);
    rx_top_diag2     : out std_logic_vector(15 downto 0)
    );

  end component;


----------------------
-- File: modem802_11a2_core.vhd
----------------------
  component modem802_11a2_core
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
    clk            : in  std_logic; -- State machine clock
    rx_path_a_gclk : in  std_logic; -- Rx path gated clock
    tx_path_a_gclk : in  std_logic; -- Tx path gated clock
    fft_gclk       : in  std_logic; -- FFT gated clock
    pclk           : in  std_logic; -- APB clock
    reset_n        : in  std_logic; -- Reset
    mdma_sm_rst_n  : in  std_logic; -- synchronous reset for state machine
    --
    rx_gating      : out std_logic; -- Gating condition for Rx path
    tx_gating      : out std_logic; -- Gating condition for Tx path
    --
    calib_test     : out std_logic; -- Do not gate clocks when high.

    --------------------------------------
    -- WILD bup interface
    --------------------------------------
    phy_txstartend_req_i  : in  std_logic;
    txv_immstop_i         : in  std_logic;
    txv_length_i          : in  std_logic_vector(11 downto 0);
    txv_datarate_i        : in  std_logic_vector(3 downto 0);
    txv_service_i         : in  std_logic_vector(15 downto 0);
    txpwr_level_i         : in  std_logic_vector(2 downto 0);
    phy_data_req_i        : in  std_logic;
    bup_txdata_i          : in  std_logic_vector(7 downto 0);
    phy_txstartend_conf_o : out std_logic;
    phy_data_conf_o       : out std_logic;

    --                                                      
    phy_ccarst_req_i     : in  std_logic;
    phy_rxstartend_ind_o : out std_logic;
    rxv_length_o         : out std_logic_vector(11 downto 0);
    rxv_datarate_o       : out std_logic_vector(3 downto 0);
    rxv_rssi_o           : out std_logic_vector(7 downto 0);
    rxv_service_o        : out std_logic_vector(15 downto 0);
    rxv_service_ind_o    : out std_logic;
    rxe_errorstat_o      : out std_logic_vector(1 downto 0);
    phy_ccarst_conf_o    : out std_logic; 
    phy_cca_ind_o        : out std_logic;
    phy_data_ind_o       : out std_logic;
    bup_rxdata_o         : out std_logic_vector(7 downto 0);
    --                                            
    --------------------------------------
    -- APB interface
    --------------------------------------
    penable_i         : in  std_logic;
    paddr_i           : in  std_logic_vector(5 downto 0);
    pwrite_i          : in  std_logic;
    psel_i            : in  std_logic;
    pwdata_i          : in  std_logic_vector(31 downto 0);
    prdata_o          : out std_logic_vector(31 downto 0);

    --------------------------------------
    -- Radio controller interface
    --------------------------------------
    a_txonoff_conf_i    : in  std_logic;
    a_rxactive_conf_i   : in  std_logic;
    a_txonoff_req_o     : out std_logic;
    a_txbbonoff_req_o   : out std_logic;
    a_txpga_o           : out std_logic_vector(2 downto 0);
    a_rxactive_req_o    : out std_logic;
    dac_on_o            : out std_logic;
    --
    adc_powerctrl_o     : out std_logic_vector(1 downto 0);
    --
    rssi_on_o           : out std_logic;

    --------------------------------------------
    -- CCA
    --------------------------------------------
    cca_busy_i          : in  std_logic;
    listen_start_o      : out std_logic; -- high when start to listen

    --------------------------------------------
    -- DC offset
    --------------------------------------------    
    cp2_detected_o      : out std_logic; -- Detected preamble

    --------------------------------------
    -- Tx & Rx filter
    --------------------------------------
    -- Rx
    filter_valid_rx_i   : in  std_logic;
    rx_filtered_data_i  : in  std_logic_vector(10 downto 0);
    rx_filtered_data_q  : in  std_logic_vector(10 downto 0);
    -- Tx
    tx_active_o             : out std_logic;
    filter_start_of_burst_o : out std_logic;
    filter_valid_tx_o       : out std_logic;
    tx_data2filter_i        : out std_logic_vector( 9 downto 0);
    tx_data2filter_q        : out std_logic_vector( 9 downto 0);
    -- Register
    tx_filter_bypass_o      : out std_logic;
    tx_norm_o               : out std_logic_vector( 7 downto 0);
    
    --------------------------------------
    -- Registers
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
    c2disb_tx_o             : out std_logic;
    c2disb_rx_o             : out std_logic;
    -- Constant generator
    tx_const_o              : out std_logic_vector(7 downto 0);
    
    ---------------------------------
    -- Diag. port
    ---------------------------------
    modem_diag0     : out std_logic_vector(15 downto 0); -- Rx
    modem_diag1     : out std_logic_vector(15 downto 0);
    modem_diag2     : out std_logic_vector(15 downto 0);
    modem_diag3     : out std_logic_vector(8 downto 0)   -- Tx
    );

  end component;



 
end modem802_11a2_pkg;
