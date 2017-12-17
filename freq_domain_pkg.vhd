
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: freq_domain_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.11  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for freq_domain.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/freq_domain/vhdl/rtl/freq_domain_pkg.vhd,v  
--  Log: freq_domain_pkg.vhd,v  
-- Revision 1.11  2004/12/14 16:59:41  Dr.C
-- #BugId:772#
-- Updated channel decoder port map.
--
-- Revision 1.10  2004/07/20 16:13:28  Dr.C
-- Updated path.
--
-- Revision 1.9  2003/11/24 11:31:03  Dr.C
-- Updated pilot_tracking.
--
-- Revision 1.8  2003/10/15 16:40:08  Dr.C
-- Updated freq domain top.
--
-- Revision 1.7  2003/06/25 16:05:43  Dr.J
-- Changed the size of the sto & cpe in the ramp_phase_rot
--
-- Revision 1.6  2003/05/12 15:04:05  Dr.F
-- port map changed.
--
-- Revision 1.5  2003/04/24 06:22:35  Dr.F
-- port map changed.
--
-- Revision 1.4  2003/04/04 08:00:06  Dr.F
-- removed the inverter.
--
-- Revision 1.3  2003/03/31 08:40:35  Dr.F
-- added inverter.
--
-- Revision 1.2  2003/03/28 16:05:04  Dr.F
-- changed some port names.
--
-- Revision 1.1  2003/03/27 09:43:01  Dr.F
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

--library rx_equ_rtl;
library work;
--use rx_equ_rtl.rx_equ_pkg.all;
use work.rx_equ_pkg.all;

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package freq_domain_pkg is

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- Source: Good
----------------------
  component channel_decoder
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic;
    clk            : in  std_logic;
    sync_reset_n   : in  std_logic;

    --------------------------------------
    -- Interface Synchronization
    --------------------------------------
    data_valid_i   : in  std_logic;  -- Data valid from equalizer_softbit
    data_ready_i   : in  std_logic;  -- Data ready from descrambler
    --
    data_ready_o   : out std_logic;  -- Data ready to equalizer_softbit
    data_valid_o   : out std_logic;  -- Data valid to descrambler

    --------------------------------------
    -- Datapath interface
    --------------------------------------
    -- Softbits from equalizer_softbit
    soft_x0_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_x1_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_x2_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y0_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y1_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y2_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    --
    data_o         : out std_logic;  -- Decoded data to descambler

    --------------------------------------
    -- Control info interface
    --------------------------------------
    start_of_burst_i   : in std_logic;
    length_limit_i     : in std_logic_vector(11 downto 0);
    rx_length_chk_en_i : in  std_logic;
    --
    signal_field_o : out std_logic_vector(SIGNAL_FIELD_LENGTH_CT-1 downto 0);
    signal_field_parity_error_o       : out std_logic;
    signal_field_unsupported_rate_o   : out std_logic;
    signal_field_unsupported_length_o : out std_logic;
    signal_field_puncturing_mode_o    : out std_logic_vector(1 downto 0);
    signal_field_valid_o              : out std_logic;
    start_of_burst_o                  : out std_logic;
    end_of_data_o                     : out std_logic;

    --------------------------------------
    -- Debugging Ports
    --------------------------------------
    soft_x_deintpun_o     : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y_deintpun_o     : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    data_valid_deintpun_o : out std_logic  
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_descr/vhdl/rtl/rx_descr.vhd
----------------------
  component rx_descr
  port (
    clk                   : in  std_logic;
    reset_n               : in  std_logic;
    sync_reset_n          : in  std_logic;
    data_i                : in  std_logic;
    data_valid_i          : in  std_logic;
    data_ready_i          : in  std_logic;
    start_of_burst_i      : in  std_logic;
    
    data_ready_o          : out std_logic;
    data_o                : out std_logic;
    data_valid_o          : out std_logic;
    rxv_service_o         : out std_logic_vector(15 downto 0);
    rxv_service_ind_o     : out std_logic;
    start_of_burst_o      : out std_logic
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_equ/vhdl/rtl/rx_equ.vhd
----------------------
  component rx_equ
  port (
    clk               : in    std_logic; -- Clock input
    reset_n           : in    std_logic; -- Asynchronous negative reset
    sync_reset_n      : in    std_logic; -- Synchronous negative rese
    i_i               : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- I input data
    q_i               : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- Q input data
    data_valid_i      : in    std_logic; --'1': Input data is valid
    data_ready_o      : out   std_logic; --'0': Do not input more data
    ich_i             : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- I channel estimate from or_chmem
    qch_i             : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- Q channel estimate from or_chmem
    data_valid_ch_i   : in    std_logic; --'1': Input data is valid
    data_ready_ch_o   : out   std_logic; --'0': Do not input more data
    soft_x0_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit x0 output
    soft_x1_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit x1 output
    soft_x2_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit x2 output
    soft_y0_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit y0 output
    soft_y1_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit y1 output
    soft_y2_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit y2 output

    burst_rate_i      : in    std_logic_vector(BURST_RATE_WIDTH_CT - 1 downto 0);-- It includes the QAM mode 
                                                                             -- QAM mode: "00" => 64 QAM
                                                                             --           "01" => QPSK
                                                                             --           "10" => 16 QAM
                                                                             --           "11" => BPSK
    signal_field_valid_i: in    std_logic; --'1': The data rate mode is valid
    data_valid_o        : out   std_logic; --'1': Output data is valid
    data_ready_i        : in    std_logic; --'0': Do not output more data
    start_of_burst_i    : in    std_logic; --'1': The next valid data input belongs to the next burst
    start_of_symbol_i   : in    std_logic; --'1': The next valid data input belongs to the next symbol
    start_of_burst_o    : out   std_logic; --'1': The next valid data output belongs to the next burst
    start_of_symbol_o   : out   std_logic; --'1': The next valid data output belongs to the next symbol

    histoffset_54_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 54
    histoffset_48_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 48
    histoffset_36_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 36
    histoffset_24_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 24
    histoffset_18_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 18
    histoffset_12_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 12
    histoffset_09_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 09
    histoffset_06_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 06

    satmaxncarr_54_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 54
    satmaxncarr_48_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 48
    satmaxncarr_36_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 36
    satmaxncarr_24_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 24
    satmaxncarr_18_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 18
    satmaxncarr_12_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 12
    satmaxncarr_09_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 09
    satmaxncarr_06_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 06

    reducerasures_i     : in    std_logic_vector(1 downto 0); -- Reduce Erasures
    -- for debug purposes
    dbg_i_o              : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- I input data (to debug block)
    dbg_q_o              : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- Q input data (to debug block)
    dbg_ich_o            : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- I channel estimate from or_chmem (to debug block)
    dbg_qch_o            : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- Q channel estimate from or_chmem (to debug block)
    dbg_equ_chan_valid_o : out   std_logic; --'1': The current value of dbg_i, dbg_q, dbg_ich and dbg_qch are valid
    dbg_equ_carrier_o    : out   std_logic_vector(5 downto 0); -- Current incoming carrier
    dbg_soft_carrier_o   : out   std_logic_vector(5 downto 0) -- Current outgoing carrier
         );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_predmx/vhdl/rtl/rx_predmx.vhd
----------------------
  component rx_predmx

  port (
    clk                      : in  std_logic;  -- ofdm clock (80 MHz)
    reset_n                  : in  std_logic;  -- asynchronous negative reset
    sync_reset_n             : in  std_logic;  -- synchronous negative reset
    i_i                      : in  FFT_ARRAY_T;  -- I input data
    q_i                      : in  FFT_ARRAY_T;  -- Q input data
    data_valid_i             : in  std_logic;  -- '1': input data valid
    wie_data_ready_i         : in  std_logic;  -- '0': do not output more data (from Wiener filter)
    equ_data_ready_i         : in  std_logic;  -- '0': do not output more data (from equalizer)
    start_of_burst_i         : in  std_logic;  -- '1': the next valid data input belongs to
                                               -- the next burst
    start_of_symbol_i        : in  std_logic;  -- '1': the next valid data input belongs to
                                               -- the next symbol
    data_ready_o             : out std_logic;  -- '0': do not input more data
    i_o                      : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- I output data
    q_o                      : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- Q output data
    wie_data_valid_o         : out std_logic;  -- '1': output data valid for the Wiener filter
    equ_data_valid_o         : out std_logic;  -- '1': output data valid for the equalizer
    pilot_valid_o            : out std_logic;  -- '1': output pilot valid
    inv_matrix_done_i        : in  std_logic;  -- '1': pilot tracking matrix inverted
    wie_start_of_burst_o     : out std_logic;  -- '1': the next valid data output belongs to the next
                                               -- burst (for Wiener filter)
    wie_start_of_symbol_o    : out std_logic;  -- '1': the next valid data output belongs to the next
                                               -- symbol (for Wiener filter) 
    equ_start_of_burst_o     : out std_logic;  -- '1': the next valid data output belongs to the next
                                               -- burst (for equalizer and chfifo, it's the same signal)
    equ_start_of_symbol_o    : out std_logic;  -- '1': the next valid data output belongs to the next
                                               -- symbol (for equalizer)
    plt_track_start_of_symbol_o : out std_logic   -- '1': the next valid data output belongs to the next
                                               -- symbol (for pilot tracking)
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/wiener_filter/vhdl/rtl/wiener_filter.vhd
----------------------
  component wiener_filter

  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    wf_window_i       : in  std_logic_vector(1 downto 0);
    i_i               : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_i               : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data_valid_i      : in  std_logic;
    start_of_burst_i  : in  std_logic;
    start_of_symbol_i : in  std_logic;
    data_ready_i      : in  std_logic;
    data_ready_o      : out std_logic;
    i_o               : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_o               : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data_valid_o      : out std_logic;
    start_of_symbol_o : out std_logic;
    start_of_burst_o  : out std_logic
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/wie_mem/vhdl/rtl/wie_mem.vhd
----------------------
  component wie_mem

  port (
    clk                : in  std_logic;  -- ofdm clock (80 MHz)
    reset_n            : in  std_logic;  -- asynchronous negative reset
    sync_reset_n       : in  std_logic;  -- synchronous negative reset
    i_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- I input data
    q_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- Q input data
    data_valid_i       : in  std_logic;  -- '1': input data valid
    data_ready_i       : in  std_logic;  -- '0': do not output more data
    start_of_burst_i   : in  std_logic;  -- '1': the next valid data input 
                                         -- belongs to the next burst
    start_of_symbol_i  : in  std_logic;  -- '1': the next valid data input 
                                         -- belongs to the next symbol
    --
    i_o                : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- I output data
    q_o                : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- Q output data
    data_ready_o       : out std_logic;  -- '0': do not input more data
    data_valid_o       : out std_logic;  -- '1': output data valid
    start_of_burst_o   : out std_logic;  -- '1': the next valid data output 
                                         -- belongs to the next burst 
    start_of_symbol_o  : out std_logic;  -- '1': the next valid data output 
                                         -- belongs to the next symbol
    -- pilots coeffs
    pilot_ready_o      : out std_logic;
    eq_p21_i_o         : out std_logic_vector(11 downto 0);
    eq_p21_q_o         : out std_logic_vector(11 downto 0);
    eq_p7_i_o          : out std_logic_vector(11 downto 0);
    eq_p7_q_o          : out std_logic_vector(11 downto 0);
    eq_m21_i_o         : out std_logic_vector(11 downto 0);
    eq_m21_q_o         : out std_logic_vector(11 downto 0);
    eq_m7_i_o          : out std_logic_vector(11 downto 0);
    eq_m7_q_o          : out std_logic_vector(11 downto 0)
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/pilot_tracking.vhd
----------------------
  component pilot_tracking

  port (clk                 : in  std_logic;
        reset_n             : in  std_logic;
        sync_reset_n        : in  std_logic;
        start_of_burst_i    : in  std_logic;
        start_of_symbol_i   : in  std_logic;
        ch_valid_i          : in  std_logic;
        -- pilots
        pilot_p21_i_i       : in  std_logic_vector(11 downto 0);
        pilot_p21_q_i       : in  std_logic_vector(11 downto 0);
        pilot_p7_i_i        : in  std_logic_vector(11 downto 0);
        pilot_p7_q_i        : in  std_logic_vector(11 downto 0);
        pilot_m21_i_i       : in  std_logic_vector(11 downto 0);
        pilot_m21_q_i       : in  std_logic_vector(11 downto 0);
        pilot_m7_i_i        : in  std_logic_vector(11 downto 0);
        pilot_m7_q_i        : in  std_logic_vector(11 downto 0);
        -- channel response for the pilot subcarriers
        ch_m21_coef_i_i     : in  std_logic_vector(11 downto 0);
        ch_m21_coef_q_i     : in  std_logic_vector(11 downto 0);
        ch_m7_coef_i_i      : in  std_logic_vector(11 downto 0);
        ch_m7_coef_q_i      : in  std_logic_vector(11 downto 0);
        ch_p7_coef_i_i      : in  std_logic_vector(11 downto 0);
        ch_p7_coef_q_i      : in  std_logic_vector(11 downto 0);
        ch_p21_coef_i_i     : in  std_logic_vector(11 downto 0);
        ch_p21_coef_q_i     : in  std_logic_vector(11 downto 0);
        -- equalizer coefficients 1/(channel response)
        eq_p21_i_i          : in  std_logic_vector(11 downto 0);
        eq_p21_q_i          : in  std_logic_vector(11 downto 0);
        eq_p7_i_i           : in  std_logic_vector(11 downto 0);
        eq_p7_q_i           : in  std_logic_vector(11 downto 0);
        eq_m21_i_i          : in  std_logic_vector(11 downto 0);
        eq_m21_q_i          : in  std_logic_vector(11 downto 0);
        eq_m7_i_i           : in  std_logic_vector(11 downto 0);
        eq_m7_q_i           : in  std_logic_vector(11 downto 0);
        skip_cpe_o          : out std_logic_vector(1 downto 0);
        estimate_done_o     : out std_logic;
        sto_o               : out std_logic_vector(16 downto 0);
        cpe_o               : out std_logic_vector(16 downto 0);
        -- debug signals
        -- equalized pilots
        pilot_p21_i_dbg     : out std_logic_vector(11 downto 0);
        pilot_p21_q_dbg     : out std_logic_vector(11 downto 0);
        pilot_p7_i_dbg      : out std_logic_vector(11 downto 0);
        pilot_p7_q_dbg      : out std_logic_vector(11 downto 0);
        pilot_m21_i_dbg     : out std_logic_vector(11 downto 0);
        pilot_m21_q_dbg     : out std_logic_vector(11 downto 0);
        pilot_m7_i_dbg      : out std_logic_vector(11 downto 0);
        pilot_m7_q_dbg      : out std_logic_vector(11 downto 0);
        equalize_done_dbg   : out std_logic;
        -- unwrapped cordic phases
        ph_m21_dbg          : out std_logic_vector(12 downto 0);
        ph_m7_dbg           : out std_logic_vector(12 downto 0);
        ph_p7_dbg           : out std_logic_vector(12 downto 0);
        ph_p21_dbg          : out std_logic_vector(12 downto 0);
        cordic_done_dbg     : out std_logic;
        -- ext_sto_cpe
        sto_meas_dbg        : out std_logic_vector(13 downto 0);
        cpe_meas_dbg        : out std_logic_vector(15 downto 0);
        ext_done_dbg        : out std_logic;        
        -- est_mag
        weight_ch_m21_dbg   : out std_logic_vector(5 downto 0);
        weight_ch_m7_dbg    : out std_logic_vector(5 downto 0);
        weight_ch_p7_dbg    : out std_logic_vector(5 downto 0);
        weight_ch_p21_dbg   : out std_logic_vector(5 downto 0);
        est_mag_done_dbg    : out std_logic;
        -- inv_matrix
        p11_dbg             : out std_logic_vector(11 downto 0);
        p12_dbg             : out std_logic_vector(11 downto 0);
        p13_dbg             : out std_logic_vector(11 downto 0);
        p14_dbg             : out std_logic_vector(11 downto 0);
        p21_dbg             : out std_logic_vector(11 downto 0);
        p22_dbg             : out std_logic_vector(11 downto 0);
        p23_dbg             : out std_logic_vector(11 downto 0);
        p24_dbg             : out std_logic_vector(11 downto 0);
        -- inv matrix debug signals
        p11_f_dbg           : out std_logic_vector(23 downto 0);
        p12_f_dbg           : out std_logic_vector(23 downto 0);
        p13_f_dbg           : out std_logic_vector(23 downto 0);
        p14_f_dbg           : out std_logic_vector(23 downto 0);
        p21_f_dbg           : out std_logic_vector(23 downto 0);
        p22_f_dbg           : out std_logic_vector(23 downto 0);
        p23_f_dbg           : out std_logic_vector(23 downto 0);
        p24_f_dbg           : out std_logic_vector(23 downto 0);
        inv_matrix_done_dbg : out std_logic
        );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/ramp_phase_rot/vhdl/rtl/ramp_phase_rot.vhd
----------------------
  component ramp_phase_rot
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    clk               : in  std_logic;
    --------------------------------------
    -- Phase calculation
    --------------------------------------
    cpe_i             : in  std_logic_vector(16 downto 0);
    sto_i             : in  std_logic_vector(16 downto 0);
    --------------------------------------
    -- Flow controls
    --------------------------------------
    -- from pilots tracking
    estimate_done_i   : in  std_logic;
    signal_valid_i    : in  std_logic;
    -- from serialyzer
    pilot_valid_i     : in  std_logic;
    data_valid_i      : in  std_logic;
    start_of_burst_i  : in  std_logic;
    start_of_symbol_i : in  std_logic;
    -- from equalyzer
    data_ready_i      : in  std_logic;
    --
    -- to serialyzer
    data_ready_o      : out std_logic;
    -- to equalizer
    data_valid_o      : out std_logic;
    start_of_burst_o  : out std_logic;
    start_of_symbol_o : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    data_i_i          : in  std_logic_vector(11 downto 0);
    data_q_i          : in  std_logic_vector(11 downto 0);
    --
    data_i_o          : out std_logic_vector(11 downto 0);
    data_q_o          : out std_logic_vector(11 downto 0)
    );

  end component;


----------------------
-- File: freq_domain.vhd
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



 
end freq_domain_pkg;
