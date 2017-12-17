
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : MODEM A2
--    ,' GoodLuck ,'      RCSfile: time_domain_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.13  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for time_domain.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/time_domain/vhdl/rtl/time_domain_pkg.vhd,v  
--  Log: time_domain_pkg.vhd,v  
-- Revision 1.13  2004/12/20 09:06:53  Dr.C
-- #BugId:810#
-- Updated instance port map.
--
-- Revision 1.12  2004/12/14 17:44:11  Dr.C
-- #BugId:810#
-- Updated debug port.
--
-- Revision 1.11  2003/10/15 16:11:41  Dr.C
-- Updated tops.
--
-- Revision 1.10  2003/07/29 10:27:50  Dr.C
-- Added cp2_detected output
--
-- Revision 1.9  2003/07/22 15:42:48  Dr.C
-- Updated.
--
-- Revision 1.8  2003/06/30 10:11:42  arisse
-- Added detect_thr_carrier_i input.
--
-- Revision 1.7  2003/06/27 13:53:46  Dr.B
-- update shared_fifo_mem port map.
--
-- Revision 1.6  2003/06/25 17:17:20  Dr.B
-- change init_sync port map.
--
-- Revision 1.5  2003/04/30 09:14:31  Dr.A
-- Removed IQ compensation and RX filter interface.
--
-- Revision 1.4  2003/04/04 16:43:02  Dr.B
-- fine_freq_data_ready removed.
--
-- Revision 1.3  2003/04/04 16:40:01  Dr.B
-- shift_param added + freq_corr_data_ready removed.
--
-- Revision 1.2  2003/04/01 11:53:54  Dr.B
-- remove unused signals.
--
-- Revision 1.1  2003/03/27 18:28:23  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package time_domain_pkg is

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- OR_T1T2DEMUX_DATA_WIDTH_CT is used for the I and Q data output from the
-- t1t2demux module.
-------------------------------------------------------------------------------
  constant OR_T1T2DEMUX_DATA_WIDTH_CT : integer := 11;

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/sample_fifo/vhdl/rtl/sample_fifo.vhd
----------------------
  component sample_fifo
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in std_logic;  -- Clock input
    reset_n             : in std_logic;  -- Asynchronous negative reset
    --------------------------------------
    -- Signals
    --------------------------------------
    sync_res_n          : in std_logic;  -- 0: The control state of the module will be reset
    i_i                 : in std_logic_vector(10 downto 0);  -- I input data
    q_i                 : in std_logic_vector(10 downto 0);  -- Q input data
    data_valid_i        : in std_logic;  -- 1: Input data is valid
    timoffst_i          : in std_logic_vector(2 downto 0);
    frame_start_valid_i : in std_logic;  -- 1: The frame_start signal is valid.
    data_ready_i        : in std_logic;  -- 0: Do not output more data
    --
    i_o                 : out std_logic_vector(10 downto 0);  -- I output data
    q_o                 : out std_logic_vector(10 downto 0);  -- Q output data
    data_valid_o        : out std_logic;  -- 1: Output data is valid
    start_of_burst_o    : out std_logic;  -- 1: The next valid data output belongs to the next burst
    start_of_symbol_o   : out std_logic  -- 1: The next valid data output belongs to the next symbol
    );

  end component;


----------------------
-- Source: Good
----------------------
  component init_sync
  generic (
    size_n_g        : integer := 11;
    size_rem_corr_g : integer := 4);  -- nb of bits removed for correlation calc
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in  std_logic;
    reset_n             : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    sync_res_n          : in  std_logic;
    -- interface with dezfilter
    i_i                 : in  std_logic_vector (10 downto 0);
    q_i                 : in  std_logic_vector (10 downto 0);
    data_valid_i        : in  std_logic;
    autocorr_enable_i   : in  std_logic;  -- from AGC, enable autocorr calc when high
    -- Calculation parameters
    -- timing acquisition correction threshold parameters
    autothr0_i          : in  std_logic_vector (5 downto 0);
    autothr1_i          : in  std_logic_vector (5 downto 0);
    -- Treshold Accumulation for carrier sense  Register
    detthr_reg_i        : in  std_logic_vector (3 downto 0);
    -- interface with Mem (write port Read port + control)
    mem_o               : out std_logic_vector (2*(size_n_g-size_rem_corr_g+5-2)-1 downto 0);
    mem1_i              : in  std_logic_vector (2*(size_n_g-size_rem_corr_g+5-2)-1 downto 0);
    wr_ptr_o            : out std_logic_vector(6 downto 0);
    rd_ptr1_o           : out std_logic_vector(6 downto 0);
    write_enable_o      : out std_logic;
    read_enable_o       : out std_logic;
    -- coarse frequency correction increment
    cf_inc_o            : out std_logic_vector (23 downto 0);
    cf_inc_data_valid_o : out std_logic;
    -- Preamble Detected
    preamb_detect_o     : out std_logic; -- pulse
    cp2_detected_o      : out std_logic; -- remains high until next init
    -- Shift Paramater (for ffe scaling)
    shift_param_o       : out std_logic_vector(2 downto 0);
    -- Carrier Sense Detection
    fast_carrier_s_o    : out std_logic;
    carrier_s_o         : out std_logic;
    -- Internal signal for debug from postprocessing
    yb_o                : out std_logic_vector(3 downto 0);
    ybnb_o              : out std_logic_vector(6 downto 0)
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/fine_freq_estim/vhdl/rtl/fine_freq_estim.vhd
----------------------
  component fine_freq_estim
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                           : in  std_logic;
    reset_n                       : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    sync_res_n                    : in  std_logic;
    -- Markers/data associated with ffe-inputs (i/q)
    start_of_burst_i              : in  std_logic;
    start_of_symbol_i             : in  std_logic;
    data_valid_i                  : in  std_logic;
    i_i                           : in  std_logic_vector(10 downto 0);
    q_i                           : in  std_logic_vector(10 downto 0);
    data_ready_o                  : out std_logic;
    -- control Mem Write/Read 
    read_enable_o                 : out std_logic;
    wr_ptr_o                      : out std_logic_vector(6 downto 0);
    write_enable_o                : out std_logic;
    rd_ptr_o                      : out std_logic_vector(6 downto 0);
    rd_ptr2_o                     : out std_logic_vector(6 downto 0);
    -- data interface with Mem
    mem1_i                        : in  std_logic_vector (21 downto 0);
    mem2_i                        : in  std_logic_vector (21 downto 0);
    mem_o                         : out std_logic_vector (21 downto 0);
    -- interface with t1t2premux
    data_ready_t1t2premux_i       : in  std_logic;
    i_t1t2_o                      : out std_logic_vector(10 downto 0);
    q_t1t2_o                      : out std_logic_vector(10 downto 0);
    data_valid_t1t2premux_o       : out std_logic;
    start_of_symbol_t1t2premux_o  : out std_logic;
    -- Shift Parameter from Init_Sync
    shift_param_i                 : in  std_logic_vector(2 downto 0);
    -- interface with tcombpremux
    data_ready_tcombpremux_i      : in  std_logic;
    i_tcomb_o                     : out std_logic_vector(10 downto 0);
    q_tcomb_o                     : out std_logic_vector(10 downto 0);
    data_valid_tcombpremux_o      : out std_logic;
    start_of_burst_tcombpremux_o  : out std_logic;
    start_of_symbol_tcombpremux_o : out std_logic;
    cf_freqcorr_o                 : out std_logic_vector(23 downto 0);
    data_valid_freqcorr_o         : out std_logic;
    -- Internal state for debug
    ffest_state_o                 : out std_logic_vector(2 downto 0)

    );

  end component;


----------------------
-- Source: Good
----------------------
  component freq_corr
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in std_logic;
    reset_n      : in std_logic;
    sync_reset_n : in std_logic;

    --------------------------------------
    -- I & Q
    --------------------------------------
    i_i : in  std_logic_vector(10 downto 0);
    q_i : in  std_logic_vector(10 downto 0);
    i_o : out std_logic_vector(10 downto 0);
    q_o : out std_logic_vector(10 downto 0);

    --------------------------------------
    -- Data control
    --------------------------------------
    data_valid_i            : in  std_logic;  -- Input data is valid
    data_ready_i            : in  std_logic;
    start_of_burst_i        : in  std_logic;  -- New burst starts 
    start_of_symbol_i       : in  std_logic;  -- Next data belongs to next symb.
    t1t2premux_data_ready_o : out std_logic;  -- Indicates to T1T2premux whether
                                         -- to fetch data from sample FIFO or not
    data_valid_o            : out std_logic;  -- Output data is valid
    start_of_burst_o        : out std_logic;  -- Start of burst for T1T2 demux
    start_of_symbol_o       : out std_logic;  -- Start of symbol for T1T2 demux

    --------------------------------------
    -- Frequency
    --------------------------------------
    coarsefreq_i        : in std_logic_vector(23 downto 0);  -- Coarse
                                                          -- frequency estimate
    coarsefreq_valid_i  : in std_logic;
    finefreq_i          : in std_logic_vector(23 downto 0);  -- Fine frequency
                                                             --  estimate
    finefreq_valid_i    : in std_logic;  -- Fine frequency input valid
 
    --------------------------------------
    -- Debug
    --------------------------------------
    freq_off_est        : out std_logic_vector(19 downto 0) -- coarse + fine
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/shared_fifo_mem/vhdl/rtl/shared_fifo_mem.vhd
----------------------
  component shared_fifo_mem
  generic (
    datawidth_g  : integer := 22;
    addrsize_g   : integer := 6;
    depth_g      : integer := 128
    );

  port (
    --------------------------------
    -- Clock & reset
    --------------------------------
    clk     : in std_logic;
    reset_n : in std_logic;

    --------------------------------
    -- Init sync 
    --------------------------------
    init_sync_read_i      : in std_logic;
    init_sync_read_ptr1_i : in std_logic_vector(addrsize_g downto 0);
    init_sync_write_i     : in std_logic;
    init_sync_write_ptr_i : in std_logic_vector(addrsize_g downto 0);
    init_sync_wdata_i     : in std_logic_vector(datawidth_g - 1 downto 0);
    --------------------------------
    -- Fine frequency estimation 
    --------------------------------
    ffe_wdata_i           : in std_logic_vector(datawidth_g - 1 downto 0);
    ffe1_read_ptr_i       : in std_logic_vector(addrsize_g downto 0);
    ffe2_read_ptr_i       : in std_logic_vector(addrsize_g downto 0);
    ffe_write_ptr_i       : in std_logic_vector(addrsize_g downto 0);
    ffe_write_i           : in std_logic;
    ffe_read_i            : in std_logic;

    --------------------------------
    -- Read data
    --------------------------------    
    fifo_mem_data1_o : out std_logic_vector(datawidth_g - 1 downto 0);
    fifo_mem_data2_o : out std_logic_vector(datawidth_g - 1 downto 0)
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/t1t2_demux/vhdl/rtl/t1t2_demux.vhd
----------------------
  component t1t2_demux
  generic (
    data_size_g : integer := 11);       -- size of data (i_i/q_i/i_o/q_i)
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                        : in  std_logic;  -- clock (80 MHz)
    reset_n                    : in  std_logic;  -- asynchronous negative reset
    sync_reset_n               : in  std_logic;  -- synchronous negative reset
    --------------------------------------
    -- Controls
    --------------------------------------
    i_i                        : in  std_logic_vector(data_size_g-1 downto 0);
    q_i                        : in  std_logic_vector(data_size_g-1 downto 0);
    data_valid_i               : in  std_logic;  -- input data valid
    start_of_burst_i           : in  std_logic;  -- next valid data input belongs to the next burst
    start_of_symbol_i          : in  std_logic;  -- next valid data input belongs to the next symbol
    ffe_data_ready_i           : in  std_logic;  -- 0 do not output more data (from ffe)  
    tcombmux_data_ready_i      : in  std_logic;  -- 0 do not output more data (from tcombmux)
    --
    data_ready_o               : out std_logic;  -- do not input more data    
    ffe_start_of_burst_o       : out std_logic;  -- next valid data output belongs to the next burst (for ffe)   
    ffe_start_of_symbol_o      : out std_logic;  -- next valid data output belongs to the next symbol (for ffe)   
    ffe_data_valid_o           : out std_logic;  -- output data valid for the ffe   
    tcombmux_data_valid_o      : out std_logic;  -- output data valid for the tcombmux   
    tcombmux_start_of_symbol_o : out std_logic;  -- next valid data output belongs to the next symbol (for tcomb mux)
    i_o                        : out std_logic_vector(data_size_g-1 downto 0);
    q_o                        : out std_logic_vector(data_size_g-1 downto 0)


  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/t1t2_preamble_mux/vhdl/rtl/t1t2_preamble_mux.vhd
----------------------
  component t1t2_preamble_mux
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                           : in  std_logic;
    reset_n                       : in  std_logic;
    sync_reset_n                  : in  std_logic;
    --------------------------------------
    -- Control signal
    --------------------------------------
    -- From sample fifo
    i_i                           : in  std_logic_vector(10 downto 0);
    q_i                           : in  std_logic_vector(10 downto 0);
    data_valid_i                  : in  std_logic;
    start_of_burst_i              : in  std_logic;  
    start_of_symbol_samplefifo_i  : in  std_logic;
    -- To sample fifo
    data_ready_o                  : out std_logic;
    -- From fine freq. estimator
    i_finefreqest_i               : in  std_logic_vector(10 downto 0);
    q_finefreqest_i               : in  std_logic_vector(10 downto 0);
    start_of_symbol_finefreqest_i : in  std_logic;  
    finefreqest_valid_i           : in  std_logic;
    -- To fine freq. estimator
    finefreqest_ready_o           : out std_logic;
    -- From or_freqcorr
    data_ready_i                  : in  std_logic;
    -- To or_freqcorr
    i_o                           : out std_logic_vector(10 downto 0);
    q_o                           : out std_logic_vector(10 downto 0);
    data_valid_o                  : out std_logic;
    start_of_burst_o              : out std_logic;
    start_of_symbol_o             : out std_logic
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/tcombine_preamble_mux/vhdl/rtl/tcombine_preamble_mux.vhd
----------------------
  component tcombine_preamble_mux
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    start_of_burst_i  : in  std_logic;
    start_of_symbol_i : in  std_logic;
    data_ready_i      : in  std_logic;
    -- Data from T1T2_Demux
    i_i               : in  std_logic_vector(10 downto 0);
    q_i               : in  std_logic_vector(10 downto 0);
    data_valid_i      : in  std_logic;
    -- Data from Fine Freq Estim
    i_tcomb_i         : in  std_logic_vector(10 downto 0);
    q_tcomb_i         : in  std_logic_vector(10 downto 0);
    tcomb_valid_i     : in  std_logic;
    --
    start_of_burst_o  : out std_logic;
    start_of_symbol_o : out std_logic;
    data_ready_o      : out std_logic;
    tcomb_ready_o     : out std_logic;
    i_o               : out std_logic_vector(10 downto 0);
    q_o               : out std_logic_vector(10 downto 0);
    data_valid_o      : out std_logic
  );

  end component;


----------------------
-- File: time_domain.vhd
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



 
end time_domain_pkg;
