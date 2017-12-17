
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_top_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.18   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rx_top.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/rx_top/vhdl/rtl/rx_top_pkg.vhd,v  
--  Log: rx_top_pkg.vhd,v  
-- Revision 1.18  2005/03/09 12:06:39  Dr.C
-- #BugId:1123#
-- Updated mdma2_rx_sm and rx_mac_if.
--
-- Revision 1.17  2004/12/20 09:05:02  Dr.C
-- #BugId:810#
-- Updated port dedicated to validation registers.
--
-- Revision 1.16  2004/12/14 17:42:58  Dr.C
-- #BugId:772,810#
-- Updated debug port and length limit port for channel decoder.
--
-- Revision 1.15  2004/06/18 09:47:23  Dr.C
-- Updated mdma2_rx_sm port map and removed some unused port.
--
-- Revision 1.14  2003/12/12 10:03:07  Dr.C
-- Updated state machine.
--
-- Revision 1.13  2003/10/15 16:57:40  Dr.C
-- Updated tops.
--
-- Revision 1.12  2003/10/10 15:25:22  Dr.C
-- Updated rx_top.
--
-- Revision 1.11  2003/09/22 09:45:28  Dr.C
-- Removed calgain_i and calvalid_i unused.
--
-- Revision 1.10  2003/09/17 06:55:09  Dr.F
-- added enable_iq_estim.
--
-- Revision 1.9  2003/09/10 07:25:13  Dr.F
-- removed phy_reset_n port.
--
-- Revision 1.8  2003/07/29 10:32:47  Dr.C
-- Added cp2_detected output
--
-- Revision 1.7  2003/07/27 07:39:29  Dr.F
-- added cca_busy_i and listen_start_o.
--
-- Revision 1.6  2003/07/22 15:44:00  Dr.C
-- Updated time_domain.
--
-- Revision 1.5  2003/06/30 10:13:36  arisse
-- Added detect_thr_carrier_i input.
--
-- Revision 1.4  2003/05/26 09:26:47  Dr.F
-- added rx_packet_end_o.
--
-- Revision 1.3  2003/04/30 09:18:13  Dr.A
-- IQ comp moved to top of Modem.
--
-- Revision 1.2  2003/04/07 15:59:36  Dr.F
-- removed calgener_i.
--
-- Revision 1.1  2003/03/28 16:22:49  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package rx_top_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/freq_domain/vhdl/rtl/freq_domain.vhd
----------------------
  component freq_domain

  port (
    clk                             : in  std_logic;
    reset_n                         : in  std_logic;
    sync_reset_n                    : in  std_logic;
    -- from mac interface
    data_ready_i                    : in  std_logic;
    
    -- FFT Shell interface
    i_i                             : in  FFT_ARRAY_T;
    q_i                             : in  FFT_ARRAY_T;
    data_valid_i                    : in  std_logic;
    start_of_burst_i                : in  std_logic;
    start_of_symbol_i               : in  std_logic;
    data_ready_o                    : out std_logic;

    -- from descrambling
    data_o                          : out std_logic;
    data_valid_o                    : out std_logic;
    rxv_service_o                   : out std_logic_vector(15 downto 0);
    rxv_service_ind_o               : out std_logic;
    start_of_burst_o                : out std_logic;
    -----------------------------------------------------------------------
    -- Parameters
    -----------------------------------------------------------------------
    -- to wiener filter
    wf_window_i       		          : in  std_logic_vector(1 downto 0);
    -- to channel decoder
    length_limit_i                  : in std_logic_vector(11 downto 0);
    rx_length_chk_en_i              : in std_logic;
    -- to equalizer
    histoffset_54_i                 : in  std_logic_vector(HISTOFFSET_WIDTH_CT -1 downto 0); 
    histoffset_48_i                 : in  std_logic_vector(HISTOFFSET_WIDTH_CT -1 downto 0); 
    histoffset_36_i                 : in  std_logic_vector(HISTOFFSET_WIDTH_CT -1 downto 0); 
    histoffset_24_i                 : in  std_logic_vector(HISTOFFSET_WIDTH_CT -1 downto 0); 
    histoffset_18_i                 : in  std_logic_vector(HISTOFFSET_WIDTH_CT -1 downto 0); 
    histoffset_12_i                 : in  std_logic_vector(HISTOFFSET_WIDTH_CT -1 downto 0); 
    histoffset_09_i                 : in  std_logic_vector(HISTOFFSET_WIDTH_CT -1 downto 0); 
    histoffset_06_i                 : in  std_logic_vector(HISTOFFSET_WIDTH_CT -1 downto 0); 

    satmaxncarr_54_i                : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_48_i                : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_36_i                : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_24_i                : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_18_i                : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_12_i                : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_09_i                : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_06_i                : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 

    reducerasures_i                 : in  std_logic_vector(1 downto 0);
    -----------------------------------------------------------------------
    -- Control info interface
    -----------------------------------------------------------------------
    signal_field_o                    : out std_logic_vector(SIGNAL_FIELD_LENGTH_CT-1 downto 0);
    signal_field_parity_error_o       : out std_logic;
    signal_field_unsupported_rate_o   : out std_logic;
    signal_field_unsupported_length_o : out std_logic;
    signal_field_valid_o              : out std_logic;
    end_of_data_o                     : out std_logic;
    -----------------------------------------------------------------------
    -- Diag. port
    -----------------------------------------------------------------------
    freq_domain_diag                  : out std_logic_vector(6 downto 0)
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/time_domain/vhdl/rtl/time_domain.vhd
----------------------
  component time_domain
  port (
    ---------------------------------------
    -- Clocks & Reset
    ---------------------------------------
    clk                         : in  std_logic; -- 80 MHz clk
    reset_n                     : in  std_logic;
    -- Enable and synchronous reset
    sync_reset_n                : in  std_logic;  -- Init 

    ---------------------------------------
    -- Parameters from registers
    ---------------------------------------
    -- InitSync Registers
    detect_thr_carrier_i        : in  std_logic_vector(3 downto 0);
    initsync_autothr0_i         : in  std_logic_vector (5 downto 0);
    initsync_autothr1_i         : in  std_logic_vector (5 downto 0);
    -- Samplefifo Registers
    sampfifo_timoffst_i         : in  std_logic_vector (2 downto 0);

    ---------------------------------------
    -- Parameters to registers
    ---------------------------------------
    -- Frequency correction
    freq_off_est_o              : out std_logic_vector(19 downto 0);
    -- Preprocessing sample number before sync
    ybnb_o                      : out std_logic_vector(6 downto 0);

    ---------------------------------------
    -- Controls
    ---------------------------------------
    -- To FFT
    data_ready_i                : in  std_logic;
    start_of_symbol_o           : out std_logic;
    data_valid_o                : out std_logic;
    start_of_burst_o            : out std_logic;
    -- to global state machine
    preamb_detect_o             : out std_logic;
    -- to DC offset
    cp2_detected_o              : out std_logic;   

    ---------------------------------------
    -- I&Q Data
    ---------------------------------------
    -- Input data after IQ compensation.
    iqcomp_data_valid_i         : in  std_logic; -- High when data is valid.
    i_iqcomp_i                  : in  std_logic_vector(10 downto 0);
    q_iqcomp_i                  : in  std_logic_vector(10 downto 0);
    --
    i_o                         : out std_logic_vector(10 downto 0);
    q_o                         : out std_logic_vector(10 downto 0);
    
    ---------------------------------------
    -- Diag. port
    ---------------------------------------
    time_domain_diag0           : out std_logic_vector(15 downto 0);
    time_domain_diag1           : out std_logic_vector(11 downto 0);
    time_domain_diag2           : out std_logic_vector(5 downto 0)
    );

  end component;


----------------------
-- Source: Good
----------------------
  component rx_mac_if
  port(
    -- asynchronous reset
    reset_n               : in  std_logic; 
    -- synchronous reset
    sync_reset_n          : in  std_logic; 
    -- clock
    clk                   : in  std_logic; 

    -- data coming from the rx path
    data_i                : in  std_logic;
    -- data valid indication. When 1, data_i is valid.
    data_valid_i          : in  std_logic;
    -- start of burst (packet) when 1.
    start_of_burst_i      : in  std_logic;
    
    data_ready_o          : out std_logic;
    -- end of packet
    packet_end_i          : in  std_logic;
    -- BuP interface
    rx_data_o             : out std_logic_vector(7 downto 0);
    rx_data_ind_o         : out std_logic
  );
  end component;


----------------------
-- Source: Good
----------------------
  component mdma2_rx_sm
  generic (
    -- time needed for the channel decoder to decode the 
    -- signal field from his input
    delay_chdec_sig_g   : integer := 102; 
    -- delay from CCA_flag_i(carry_lost) to intput of channel decoder 
    delay_datapath_g    : integer := 413; 
    -- worse case dalay for the channel decoder
    worst_case_chdec_g  : integer := 150;
    -- radio type : 1 for WILDRF, 0 for IFX
    radio_type_g        : integer := 1   
    );
  port (
    clk                       : in  std_logic;  -- Module clock
    reset_n                   : in  std_logic;  -- asynchronous reset
    mdma_sm_rst_n             : in  std_logic;  -- synchronous reset
    reset_dp_modules_n_o      : out std_logic;  -- `0': Reset data path modules.
    --
    calmode_i                 : in  std_logic;  -- IQ calibration mode.
    rx_start_end_ind_o        : out std_logic;  -- rising edge: PHY_RXSTART.ind
                                             -- falling edge: PHY_RXEND.ind
    tx_dac_on_i               : in  std_logic;  -- From TX
    rxactive_req_o            : out std_logic;  -- To RF Control
    rxactive_conf_i           : in  std_logic;  -- From RF Control
    rx_packet_end_o           : out std_logic;  -- pulse on end of RX packet
    enable_iq_estim_o         : out std_logic;  -- `1': enable iq estimation block.
    disable_output_iq_estim_o : out std_logic;  -- `1': disable iq estimation outputs.

    --------------------------------------------
    -- I/F to MAC
    --------------------------------------------
    rx_error_o             : out std_logic_vector(1 downto 0);  --RXERROR 
                                   -- vector is valid at     
                                   -- the falling edge of rx_start_end_ind_o.
                                   -- The coding is as follows:
                                   -- 0b00: No Error
                                   -- 0b01: Format Violation
                                   -- 0b10: Carrier lost
                                   -- 0b11: Unsupported rate
    rxv_length_o           : out std_logic_vector(11 downto 0);  -- RXVECTOR 
                                   -- length parameter is valid when
                                   -- rx_start_end_ind_o goes from 0 to 1.
    -- RXVECTOR rate parameter       
    rxv_rate_o             : out std_logic_vector(3 downto 0);
    rx_cca_ind_o           : out std_logic;  -- 0: IDLE 
                                             -- 1: BUSY 
    --
    rx_ccareset_req_i      : in  std_logic; -- CCA Reset
    rx_ccareset_confirm_o  : out std_logic;
    --------------------------------------------
    -- SIGNAL Field from channel decoder
    --------------------------------------------
    signal_field_unsup_rate_i   : in  std_logic;  -- 1: The rate computed in
                                        -- the signal field is not valid
    signal_field_unsup_length_i : in  std_logic;  -- 1: The length computed in
                                        -- the signal field is not valid
    -- This contains the RATE, LENGTH the reserved bit and the parity bit
    signal_field_i              : in  std_logic_vector(17 downto 0);
    signal_field_parity_error_i : in  std_logic;
    signal_field_valid_i        : in  std_logic;  -- 1: The signal field has 
                                        -- been decoded and the data is
                                        -- available. This signal is active
                                        -- for one cycle.
    --------------------------------------------
    -- End of channel decoder
    --------------------------------------------
    channel_decoder_end_i        : in std_logic;
    --------------------------------------------
    -- AGC/Power estimation blocks
    --------------------------------------------
    listen_start_o              : out std_logic; -- high when start to listen
    rssi_abovethr_i             : in  std_logic;  -- RSSI above threshold
    rssi_enable_o               : out std_logic;  -- RSSI ADC Enable
    --------------------------------------------
    -- Preamble detection from Init sync
    --------------------------------------------
    -- Confirm preamble detection
    tdone_i                     : in std_logic;  
    --------------------------------------------
    -- I and Q ADCs control
    --------------------------------------------
    adc_powerdown_dyn_i         : in  std_logic;  -- From control regs
    adc_powctrl_o               : out std_logic_vector(1 downto 0);
    --------------------------------------------
    -- Internal state for debug
    --------------------------------------------
    rx_gsm_state_o              : out std_logic_vector(3 downto 0)
    
  );

  end component;


----------------------
-- File: rx_top.vhd
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



 
end rx_top_pkg;
