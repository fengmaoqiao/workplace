
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_top.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.19   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : RX top.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/rx_top/vhdl/rtl/rx_top.vhd,v  
--  Log: rx_top.vhd,v  
-- Revision 1.19  2005/03/09 12:06:35  Dr.C
-- #BugId:1123#
-- Updated mdma2_rx_sm and rx_mac_if.
--
-- Revision 1.18  2004/12/20 09:04:57  Dr.C
-- #BugId:810#
-- Updated port dedicated to validation registers.
--
-- Revision 1.17  2004/12/14 17:42:52  Dr.C
-- #BugId:772,810#
-- Updated debug port and length limit port for channel decoder.
--
-- Revision 1.16  2004/06/18 09:47:17  Dr.C
-- Updated mdma2_rx_sm port map and removed some unused port.
--
-- Revision 1.15  2003/12/12 10:02:41  Dr.C
-- Added mdma_sm_rst_n for state machine.
--
-- Revision 1.14  2003/10/16 07:21:32  Dr.C
-- Debugged diag port connection.
--
-- Revision 1.13  2003/10/15 16:57:31  Dr.C
-- Added diag port.
--
-- Revision 1.12  2003/10/10 15:24:51  Dr.C
-- Added gclk gated clock input.
--
-- Revision 1.11  2003/09/22 09:44:45  Dr.C
-- Removed calgain_i and cal_valid_i unused.
--
-- Revision 1.10  2003/09/17 06:55:00  Dr.F
-- added enable_iq_estim.
--
-- Revision 1.9  2003/09/10 07:22:19  Dr.F
-- phy_reset_n port removed.
-- removed phy_reset_n port.
--
-- Revision 1.8  2003/07/29 10:32:38  Dr.C
-- Added cp2_detected output
--
-- Revision 1.7  2003/07/27 07:39:15  Dr.F
-- added cca_busy_i and listen_start_o.
--
-- Revision 1.6  2003/07/22 15:52:59  Dr.C
-- Removed sampling_clk.
--
-- Revision 1.5  2003/06/30 09:46:07  arisse
-- Added input register detect_thr_carrier.
-- Removed inputs registers : calmstart, calmstop, calfrq1,
-- callen1,acllen2, calmav_re, calmav_im, calpow_re, calpow_im.
--
-- Revision 1.4  2003/05/26 09:26:39  Dr.F
-- added rx_packet_end_o.
--
-- Revision 1.3  2003/04/30 09:17:45  Dr.A
-- IQ comp moved to top of modem.
--
-- Revision 1.2  2003/04/07 15:59:27  Dr.F
-- removed calgener_i.
--
-- Revision 1.1  2003/03/28 16:22:47  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;



--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--library time_domain_rtl;
library work;
--library freq_domain_rtl;
library work;
--library mdma2_rx_sm_rtl;
library work;
--library rx_mac_if_rtl;
library work;

--library rx_top_rtl;
library work;
--use rx_top_rtl.rx_top_pkg.all;
use work.rx_top_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity rx_top is

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

end rx_top;


--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_top is


  -- freq_domain
  signal data_valid_freq_domain        : std_logic;
  signal data_freq_domain              : std_logic;
  signal start_of_burst_freq_domain    : std_logic;

  -- rx_mac_if
  signal data_ready_mac                : std_logic;

  -- glb_cntl
  signal signal_field_unsupported_rate   : std_logic;
  signal signal_field_unsupported_length : std_logic;
  signal signal_field                    : std_logic_vector(17 downto 0);
  signal signal_field_valid              : std_logic;
  signal channel_decoder_end             : std_logic;
  signal signal_field_parity_error       : std_logic;
  -- glb enable and reset sync
  signal data_path_sync_res              : std_logic;
  signal low                             : std_logic;
  signal high                            : std_logic;

  -- Modem state machine
  signal preamb_detect                   : std_logic;

  -- Diag. port
  signal time_domain_diag0             : std_logic_vector(15 downto 0);
  signal time_domain_diag1             : std_logic_vector(11 downto 0);
  signal time_domain_diag2             : std_logic_vector(5 downto 0);
  signal freq_domain_diag              : std_logic_vector(6 downto 0);
  signal rx_gsm_state_o                : std_logic_vector(3 downto 0);
  signal rx_packet_end                 : std_logic;

begin

  low                  <= '0';
  high                 <= '1';
  rx_dpath_reset_n_o   <= data_path_sync_res;
  rx_packet_end_o      <= rx_packet_end;

  ---------------------------------
  -- Diag. port
  ---------------------------------
  rx_top_diag0 <= time_domain_diag0;
  rx_top_diag1 <= time_domain_diag1 & 
                  freq_domain_diag(6 downto 3);
  rx_top_diag2 <= data_path_sync_res &
                  channel_decoder_end &
                  time_domain_diag2 &
                  rx_gsm_state_o &
                  freq_domain_diag(2 downto 0) &
                  rx_packet_end;


  --------------------------------------------
  -- Time domain
  --------------------------------------------
  time_domain_1: time_domain
  port map (
    -- Clocks & Reset
    clk                         => gclk,   
    reset_n                     => reset_n,         
    -- Synchronous reset
    sync_reset_n                => data_path_sync_res,
    -- INIT sync
    detect_thr_carrier_i        => detect_thr_carrier_i,
    initsync_autothr0_i         => initsync_autothr0_i,
    initsync_autothr1_i         => initsync_autothr1_i,
    -- Samplefifo
    sampfifo_timoffst_i         => sampfifo_timoffst_i,
    -- Frequency correction
    freq_off_est_o              => freq_off_est_o,
    -- Preprocessing sample number before sync
    ybnb_o                      => ybnb_o,
    -- To FFT
    data_ready_i                => fft_data_ready_i,
    start_of_symbol_o           => td_start_of_symbol_o,
    data_valid_o                => td_data_valid_o, 
    start_of_burst_o            => td_start_of_burst_o,
    -- to global state machine
    preamb_detect_o             => preamb_detect,
    cp2_detected_o              => cp2_detected_o,
    -- I&Q
    i_iqcomp_i                  => i_iqcomp_i,
    q_iqcomp_i                  => q_iqcomp_i,
    iqcomp_data_valid_i         => iqcomp_data_valid_i,
    --
    i_o                         => td_i_o,
    q_o                         => td_q_o,
    --  Diag. port
    time_domain_diag0           => time_domain_diag0,
    time_domain_diag1           => time_domain_diag1,
    time_domain_diag2           => time_domain_diag2
  );
  
  
  --------------------------------------------
  -- Frequency domain
  --------------------------------------------
  freq_domain_1 : freq_domain
    port map (
      clk                        => gclk,
      reset_n                    => reset_n,
      sync_reset_n               => data_path_sync_res,
      -- from or_mac
      data_ready_i               => data_ready_mac,
      --from fft
      i_i                        => fft_i_i,
      q_i                        => fft_q_i,
      data_valid_i               => fft_data_valid_i,
      start_of_burst_i           => fft_start_of_burst_i,
      start_of_symbol_i          => fft_start_of_symbol_i,
      data_ready_o               => fd_data_ready_o,
      -- from rx_descr
      data_o                     => data_freq_domain,
      data_valid_o               => data_valid_freq_domain,
      rxv_service_o              => rxv_service_o,
      rxv_service_ind_o          => rxv_service_ind_o,
      start_of_burst_o           => start_of_burst_freq_domain,
      -----------------------------------------------------------------------
      -- Parameters
      -----------------------------------------------------------------------
      -- to wiener
      wf_window_i                => wf_window_i,
      -- to channel decoder
      length_limit_i             => length_limit_i,
      rx_length_chk_en_i         => rx_length_chk_en_i,
      -- to equalizer
      histoffset_54_i            => histoffset_54_i,
      histoffset_48_i            => histoffset_48_i,
      histoffset_36_i            => histoffset_36_i,
      histoffset_24_i            => histoffset_24_i,
      histoffset_18_i            => histoffset_18_i,
      histoffset_12_i            => histoffset_12_i,
      histoffset_09_i            => histoffset_09_i,
      histoffset_06_i            => histoffset_06_i,

      satmaxncarr_54_i           => satmaxncarr_54_i,
      satmaxncarr_48_i           => satmaxncarr_48_i,
      satmaxncarr_36_i           => satmaxncarr_36_i,
      satmaxncarr_24_i           => satmaxncarr_24_i,
      satmaxncarr_18_i           => satmaxncarr_18_i,
      satmaxncarr_12_i           => satmaxncarr_12_i,
      satmaxncarr_09_i           => satmaxncarr_09_i,
      satmaxncarr_06_i           => satmaxncarr_06_i,

      reducerasures_i                   => reducerasures_i, 
      -----------------------------------------------------------------------
      -- Control info interface
      -----------------------------------------------------------------------
      signal_field_o                    => signal_field,
      signal_field_parity_error_o       => signal_field_parity_error,
      signal_field_unsupported_rate_o   => signal_field_unsupported_rate,
      signal_field_unsupported_length_o => signal_field_unsupported_length,
      signal_field_valid_o              => signal_field_valid,
      end_of_data_o                     => channel_decoder_end,
      -----------------------------------------------------------------------
      -- Diag. port
      -----------------------------------------------------------------------
      freq_domain_diag                  => freq_domain_diag
      );


  --------------------------------------------
  -- RX MAC interface
  --------------------------------------------
  rx_mac_if_1 : rx_mac_if
    port map (
      clk                => gclk,
      reset_n            => reset_n,
      sync_reset_n       => data_path_sync_res,
      data_i             => data_freq_domain,
      data_valid_i       => data_valid_freq_domain,
      start_of_burst_i   => start_of_burst_freq_domain,
      packet_end_i       => rx_packet_end,
      data_ready_o       => data_ready_mac,
      rx_data_o          => bup_rxdata_o,
      rx_data_ind_o      => phy_data_ind_o
    );


  --------------------------------------------
  -- RX global state machine
  --------------------------------------------
  mdma2_rx_sm_1 : mdma2_rx_sm
    generic map (
      delay_chdec_sig_g  => 102,
      delay_datapath_g   => 413,
      worst_case_chdec_g => 150)
    port map (
      clk                         => clk,
      reset_n                     => reset_n,
      mdma_sm_rst_n               => mdma_sm_rst_n,
      reset_dp_modules_n_o        => data_path_sync_res,
      --
      calmode_i                   => calmode_i,
      rx_start_end_ind_o          => phy_rxstartend_ind_o,
      tx_dac_on_i                 => tx_dac_on_i,
      rxactive_req_o              => rxactive_req_o,
      rxactive_conf_i             => rxactive_conf_i,
      rx_packet_end_o             => rx_packet_end,
      enable_iq_estim_o           => enable_iq_estim_o,
      disable_output_iq_estim_o   => disable_output_iq_estim_o,
      rx_error_o                  => rxe_errorstat_o,
      rxv_length_o                => rxv_length_o,
      rxv_rate_o                  => rxv_datarate_o,
      rx_cca_ind_o                => phy_cca_ind_o,
      rx_ccareset_req_i           => phy_ccarst_req_i,
      rx_ccareset_confirm_o       => phy_ccarst_conf_o,
      signal_field_unsup_rate_i   => signal_field_unsupported_rate,
      signal_field_unsup_length_i => signal_field_unsupported_length,
      signal_field_i              => signal_field,
      signal_field_parity_error_i => signal_field_parity_error,
      signal_field_valid_i        => signal_field_valid,
      channel_decoder_end_i       => channel_decoder_end,
      listen_start_o              => listen_start_o,
      rssi_abovethr_i             => cca_busy_i,
      rssi_enable_o               => rssi_on_o,
      tdone_i                     => preamb_detect,
      adc_powerdown_dyn_i         => adcpdmod_i,
      adc_powctrl_o               => adc_powerctrl_o,
      rx_gsm_state_o              => rx_gsm_state_o
    );

  
end rtl;
