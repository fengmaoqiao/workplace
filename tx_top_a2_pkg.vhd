
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: tx_top_a2_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.16   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for tx_top_a2.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/tx_top_a2/vhdl/rtl/tx_top_a2_pkg.vhd,v  
--  Log: tx_top_a2_pkg.vhd,v  
-- Revision 1.16  2004/12/20 09:08:16  Dr.C
-- #BugId:630#
-- Updated port names of scrambler according to spec 1.02.
--
-- Revision 1.15  2004/12/14 13:51:18  Dr.C
-- #BugId:630,595#
-- Added txv_immstop input port. Updated fft_serial and scrambler port map.
--
-- Revision 1.14  2004/05/18 12:33:37  Dr.A
-- modema_tx_sm port map update.
--
-- Revision 1.13  2003/11/14 15:42:54  Dr.C
-- Updated.
--
-- Revision 1.12  2003/11/03 15:52:19  Dr.C
-- Added a_txbbonoff_req_o.
--
-- Revision 1.11  2003/10/15 09:03:22  Dr.C
-- Updated top.
--
-- Revision 1.10  2003/10/13 14:55:46  Dr.C
-- Updated.
--
-- Revision 1.9  2003/04/14 07:59:27  Dr.A
-- Removed some blocks.
--
-- Revision 1.8  2003/04/07 13:47:48  Dr.A
-- Removed calgener.
--
-- Revision 1.7  2003/04/07 13:25:54  Dr.A
-- New calibration blocks.
--
-- Revision 1.6  2003/04/02 08:03:25  Dr.A
-- Added generics and sync_reset_n to FFT shell.
--
-- Revision 1.5  2003/03/28 16:06:48  Dr.A
-- Changed output size.
--
-- Revision 1.4  2003/03/28 14:17:00  Dr.A
-- Added fft_serial.
--
-- Revision 1.3  2003/03/28 07:48:49  Dr.A
-- Added clk_60mhz.
--
-- Revision 1.2  2003/03/27 17:35:25  Dr.A
-- Modified tx_filter interface.
--
-- Revision 1.1  2003/03/26 14:49:19  Dr.A
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
package tx_top_a2_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/sine_table_rom/vhdl/rtl/sine_table_rom.vhd
----------------------
  component sine_table_rom
  port (
     addr_i   : in  std_logic_vector(9 downto 0); -- input angle
     sin_o    : out std_logic_vector(9 downto 0)  -- output sine
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/mac_interface/vhdl/rtl/mac_interface.vhd
----------------------
  component mac_interface
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n             : in  std_logic;
    clk                 : in  std_logic;

    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i            : in  std_logic;
    tx_start_end_req_i  : in  std_logic;
    tx_start_end_conf_i : in  std_logic;
    data_ready_i        : in  std_logic;
    data_valid_o        : out std_logic;
    tx_data_req_i       : in  std_logic;
    tx_data_conf_o      : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    tx_data_i           : in  std_logic_vector(7 downto 0);
    data_o              : out std_logic_vector(7 downto 0)

    
  );

  end component;


----------------------
-- Source: Good
----------------------
  component scrambler_a2
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic; -- asynchronous reset
    clk            : in  std_logic; -- Module clock
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i       : in  std_logic; -- Enable the module when high.
    marker_i       : in  std_logic; -- Control signal for the input data stream.
    data_valid_i   : in  std_logic; -- '1' when data_i is valid.
    data_ready_i   : in  std_logic; -- '1' when next module is ready for data.
    --
    marker_o       : out std_logic; -- Control signal for output data stream.
    data_valid_o   : out std_logic; -- '1' when data_o is valid.
    data_ready_o   : out std_logic; -- '1' to indicates that data is processed.
    --
    scrmode_i      : in  std_logic; -- '1' to reinit the scrambler btw 2 bursts
    -- Forced init value for the pseudo-noise generator.
    scrinitval_i   : in  std_logic_vector(6 downto 0);
    tx_scrambler_o : out std_logic_vector(6 downto 0); -- scrambler init value
    --------------------------------------
    -- Data
    --------------------------------------
    data_i       : in  std_logic;
    --
    data_o       : out std_logic
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/padding/vhdl/rtl/padding.vhd
----------------------
  component padding
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                : in std_logic;
    reset_n            : in std_logic;

    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i           : in  std_logic;
    data_ready_o       : out std_logic;
    data_ready_i       : in  std_logic;
    data_valid_i       : in  std_ulogic;
    tx_start_end_req_i : in  std_logic;
    prbs_sel_i         : in  std_logic_vector(1 downto 0);
    prbs_inv_i         : in  std_logic;
    prbs_init_i        : in  std_logic_vector(22 downto 0);
    --
    data_valid_o       : out std_logic;
    marker_o           : out std_logic;
    coding_rate_o          : out std_logic_vector(1 downto 0);  -- data coding rate
    qam_mode_o         : out std_logic_vector(1 downto 0);  -- qam mode
    start_burst_o      : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    txv_length_i       : in  std_logic_vector(11 downto 0);  -- Length of frame 1
    txv_rate_i         : in  std_logic_vector(3 downto 0);  -- Rate for frame 1
    txv_service_i      : in  std_logic_vector(15 downto 0);  -- Service field
    data_i             : in  std_logic_vector(7 downto 0);  -- Input data octet
    --
    data_o             : out std_logic


    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/encoder/vhdl/rtl/encoder.vhd
----------------------
  component encoder
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i     : in  std_logic;
    data_valid_i : in  std_logic;
    data_ready_i : in  std_logic;
    marker_i     : in  std_logic;
    --
    data_valid_o : out std_logic;
    data_ready_o : out std_logic;
    marker_o     : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    data_i       : in  std_logic; -- Data to encode.
    --
    x_o          : out std_logic; -- x encoded data at coding rate 1/2.
    y_o          : out std_logic  -- y encoded data at coding rate 1/2.
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/puncturer/vhdl/rtl/puncturer.vhd
----------------------
  component puncturer
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk           : in  std_logic;
    reset_n       : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i      : in  std_logic; -- TX global enable.
    data_valid_i  : in  std_logic; -- from previous module
    data_ready_i  : in  std_logic; -- from following module
    marker_i      : in  std_logic; -- marks start of burst & signal field
    coding_rate_i : in  std_logic_vector(1 downto 0);
    --
    data_valid_o  : out std_logic; -- to following module
    data_ready_o  : out std_logic; -- to previous module
    marker_o      : out std_logic; -- marks start of burst
    --------------------------------------
    -- Data
    --------------------------------------
    x_i           : in  std_logic;  -- x data from encoder. 
    y_i           : in  std_logic;  -- y data from encoder.
    --
    x_o           : out std_logic;  -- x punctured data.
    y_o           : out std_logic   -- y punctured data.

  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/pilot_scr/vhdl/rtl/pilot_scr.vhd
----------------------
  component pilot_scr
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n           : in std_logic; -- asynchronous reset.
    clk               : in std_logic; -- Module clock.
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i          : in  std_logic; -- TX path enable.
    pilot_ready_i     : in  std_logic;
    init_pilot_scr_i  : in  std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    pilot_scr_o       : out std_logic  -- Data for the 4 pilot carriers.
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/interleaver/vhdl/rtl/interleaver.vhd
----------------------
  component interleaver
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk             : in  std_logic; -- Module clock.
    reset_n         : in  std_logic; -- Asynchronous reset.
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i        : in  std_logic; -- TX path enable.
    data_valid_i    : in  std_logic; -- High when input data is valid.
    data_ready_i    : in  std_logic; -- Following block is ready to accept data.
    qam_mode_i      : in  std_logic_vector(1 downto 0);
    marker_i        : in  std_logic; -- 'start of signal' or 'end of burst'.
    --
    pilot_ready_o   : out std_logic; -- Ready to accept data from pilot scr.
    start_signal_o  : out std_logic; -- 'start of signal' marker.
    end_burst_o     : out std_logic; -- 'end of burst' marker.
    data_valid_o    : out std_logic; -- High when output data is valid.
    data_ready_o    : out std_logic; -- Ready to accept data from puncturer.
    null_carrier_o  : out std_logic; -- '1' when data for null carrier.
    -- coding rate: 0: QAM64, 1: QPSK, 2: QAM16,  3:BPSK.
    qam_mode_o      : out std_logic_vector(1 downto 0);
    --------------------------------------
    -- Data
    --------------------------------------
    x_i             : in  std_logic; -- x data from puncturer.
    y_i             : in  std_logic; -- y data from puncturer.
    pilot_scr_i     : in  std_logic; -- Data for the 4 pilot carriers.
    --
    data_o          : out std_logic_vector(5 downto 0) -- Interleaved data.
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/mapper/vhdl/rtl/mapper.vhd
----------------------
  component mapper
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk            : in  std_logic; -- Module clock
    reset_n        : in  std_logic; -- asynchronous reset
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i       : in  std_logic; -- TX path enable.
    data_valid_i   : in  std_logic; -- High when input data is valid.
    data_ready_i   : in  std_logic; -- Next block ready to accept data.
    start_signal_i : in  std_logic; -- 'start of signal' marker.
    end_burst_i    : in  std_logic; -- 'end of burst' marker.
    qam_mode_i     : in  std_logic_vector(1 downto 0);
    null_carrier_i : in  std_logic; -- '1' when data for null carrier
    --
    data_valid_o   : out std_logic; -- High when output data is valid.
    data_ready_o   : out std_logic; -- Block ready to accept data.
    start_signal_o : out std_logic; -- 'start of signal' marker.
    end_burst_o    : out std_logic; -- 'end of burst' marker.
    --------------------------------------
    -- Data
    --------------------------------------
    data_i         : in  std_logic_vector(5 downto 0);
    -- Mapped data.
    data_i_o       : out std_logic_vector(7 downto 0);
    data_q_o       : out std_logic_vector(7 downto 0)

    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/preamble_gen/vhdl/rtl/preamble_gen.vhd
----------------------
  component preamble_gen
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk             : in  std_logic; -- Module clock
    reset_n         : in  std_logic; -- Asynchronous reset
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i        : in  std_logic; -- TX path enable.
    data_ready_i    : in  std_logic; -- '1' when next block ready to accept data
    add_short_pre_i : in  std_logic_vector(1 downto 0); -- pre-preamble value.
    --
    end_preamble_o  : out std_logic; -- High at the end of the preamble.
    --------------------------------------
    -- Data
    --------------------------------------
    i_out           : out std_logic_vector(9 downto 0); -- I preamble data.
    q_out           : out std_logic_vector(9 downto 0)  -- Q preamble data.
  );

  end component;


----------------------
-- Source: Good
----------------------
  component fft_serial
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic;
    reset_n              : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------  
    sync_reset_n         : in  std_logic; -- Synchronous reset
    start_serial_i       : in  std_logic; -- 'start of signal' marker.
    last_serial_i        : in  std_logic; -- Indicates the last symbol.
    data_ready_i         : in  std_logic; -- Next block is ready to accept data.
    --
    data_ready_o         : out std_logic; -- High when waiting for new data.
    marker_o             : out std_logic; -- 'end of burst' marker.
    --------------------------------------
    -- Data
    --------------------------------------  
    x_fft_data_i         : in  FFT_ARRAY_T; -- Parallel I data from FFT.
    y_fft_data_i         : in  FFT_ARRAY_T; -- Parallel Q data from FFT.
    -- Serialized I and Q data.
    x_fft_data_o         : out std_logic_vector(9 downto 0);
    y_fft_data_o         : out std_logic_vector(9 downto 0)
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/TX_TOP/tx_mux/vhdl/rtl/tx_mux.vhd
----------------------
  component tx_mux
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in  std_logic; -- Module clock
    reset_n             : in  std_logic; -- Asynchronous reset
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i            : in  std_logic; -- TX path enable.
    start_burst_i       : in  std_logic; -- Start of burst.
    end_preamble_i      : in  std_logic; -- End of preamble.
    marker_i            : in  std_logic; -- End of burst.
    tx_enddel_i         : in  std_logic_vector(7 downto 0); -- End of tx delay.
    --
    tx_start_end_conf_o : out std_logic;
    res_intfil_o        : out std_logic; -- Reset tx filter.
    data_valid_o        : out std_logic; -- Output data is valid.
    pream_ready_o       : out std_logic; -- tx_mux ready for preamble data.
    data_ready_o        : out std_logic; -- tx_mux ready for tx data.
    filter_sampleready_o: out std_logic; -- sample signal for tx filter.
    --------------------------------------
    -- Data
    --------------------------------------
    preamble_in_i       : in  std_logic_vector(9 downto 0); -- I preamble data.
    preamble_in_q       : in  std_logic_vector(9 downto 0); -- Q preamble data.
    data_in_i           : in  std_logic_vector(9 downto 0); -- I TX data.
    data_in_q           : in  std_logic_vector(9 downto 0); -- Q TX data.
    --
    out_i               : out std_logic_vector(9 downto 0); -- I data out.
    out_q               : out std_logic_vector(9 downto 0)  -- Q data out.

  );

  end component;


----------------------
-- Source: Good
----------------------
  component modema_tx_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic; -- Module clock
    reset_n              : in  std_logic; -- asynchronous reset

    --------------------------------------
    -- Global controls
    --------------------------------------
    enable_o             : out std_logic; -- Enable for TX blocks.
    tx_active_o          : out std_logic; -- High during transmission.
    sync_reset_n_o       : out std_logic; -- synchronous reset

    --------------------------------------
    -- BuP interface.
    --------------------------------------
    txv_txpwr_level_i    : in  std_logic_vector( 2 downto 0); -- TX Power Level.
    txv_rate_i           : in  std_logic_vector( 3 downto 0); -- Rate.
    txv_length_i         : in  std_logic_vector(11 downto 0); -- Length.
    txv_service_i        : in  std_logic_vector(15 downto 0); -- Service field.
    phy_txstartend_req_i : in  std_logic;
    txv_immstop_i        : in  std_logic;                     -- Stop Tx
    --
    phy_txstartend_conf_o: out std_logic;

    --------------------------------------
    -- Interface with mac_interface block
    --------------------------------------
    int_start_end_conf_i : in  std_logic;
    --
    int_start_end_req_o  : out std_logic;
    int_rate_o           : out std_logic_vector( 3 downto 0); -- Rate.
    int_length_o         : out std_logic_vector(11 downto 0); -- Length.
    int_service_o        : out std_logic_vector(15 downto 0); -- Service field.
    
    --------------------------------------
    -- Interface with RF control FSM
    --------------------------------------
    dac_powerdown_dyn_i  : in  std_logic;
    a_txonoff_conf_i     : in  std_logic;
    --
    dac_on_o             : out std_logic;
    a_txpga_o            : out std_logic_vector(2 downto 0);
    a_txonoff_req_o      : out std_logic
  );

  end component;


----------------------
-- File: tx_top_a2.vhd
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



 
end tx_top_a2_pkg;
