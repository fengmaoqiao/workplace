
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: master_hiss_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.16   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for master_hiss.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/master_hiss/vhdl/rtl/master_hiss_pkg.vhd,v  
--  Log: master_hiss_pkg.vhd,v  
-- Revision 1.16  2005/03/16 13:09:49  sbizet
-- #BugId:1135#
-- Added txv_immstop port to master_seria
--
-- Revision 1.15  2005/01/06 15:09:21  sbizet
-- #BugId:713#
-- Added txv_immstop enhancement
--
-- Revision 1.14  2004/07/16 07:36:16  Dr.B
-- add cca_add_info feature
--
-- Revision 1.13  2004/03/29 13:01:46  Dr.B
-- add clk44_possible_g generic.
--
-- Revision 1.12  2004/02/19 17:25:47  Dr.B
-- add hiss_reset_n reset.
--
-- Revision 1.11  2003/12/01 09:57:45  Dr.B
-- add rd_access_stop.
--
-- Revision 1.10  2003/11/26 13:59:32  Dr.B
-- decode_add is now running at 240 MHz.
--
-- Revision 1.9  2003/11/21 17:54:58  Dr.B
-- add stream_enable_i.
--
-- Revision 1.8  2003/11/20 11:18:34  Dr.B
-- add cs protection and sync240to80.
--
-- Revision 1.7  2003/11/17 14:34:02  Dr.B
-- add clk_switch output.
--
-- Revision 1.6  2003/10/30 14:37:39  Dr.B
-- remove sampling_clk + add CCA info.
--
-- Revision 1.5  2003/10/09 08:25:29  Dr.B
-- add carrier sense info.
--
-- Revision 1.4  2003/09/25 12:32:33  Dr.B
-- start_seria, cca_abmode, ant_selection ...
--
-- Revision 1.3  2003/09/23 13:04:06  Dr.B
-- mux rx a b.
--
-- Revision 1.2  2003/09/22 09:33:08  Dr.B
-- new master_dec_data +numerous changes.
--
-- Revision 1.1  2003/07/21 11:52:55  Dr.B
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
package master_hiss_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/serial_parity/vhdl/rtl/serial_parity_gen.vhd
----------------------
  component serial_parity_gen
  generic (
    reset_val_g : integer := 1);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk             : in  std_logic;
    reset_n         : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    data_i          : in  std_logic;    -- data input
    init_i          : in  std_logic;    -- reinit register
    data_valid_i    : in  std_logic;    -- high when 1 data is available
    --
    parity_bit_o    : out std_logic;  -- parity bit available when  the last data is entered
    parity_bit_ff_o : out std_logic  -- parity bit available after the last data entered
    
  );

  end component;


----------------------
-- File: buffer_for_seria.vhd
----------------------
  component buffer_for_seria
  generic (
    buf_size_g      : integer := 2;    -- size of the buffer
    fifo_content_g  : integer := 2;    -- start seria only when fifo_content_g data in fifo
    empty_at_end_g  : integer := 0;    -- when 1, empty the fifo before ending
    in_size_g       : integer := 11);  -- size of data input of tx_filter B  
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    sampling_clk        : in  std_logic;
    reset_n             : in  std_logic;
    --------------------------------------
    -- Interface with muxed 60 MHz path
    --------------------------------------
    -- Data from Tx/Rx Filter
    data_i_i             : in  std_logic_vector(in_size_g-1 downto 0);
    data_q_i             : in  std_logic_vector(in_size_g-1 downto 0);
    data_val_tog_i       : in  std_logic;   -- high = data is valid
    --------------------------------------
    -- Control Signal
    --------------------------------------
    immstop_i           : in  std_logic;  -- Immediate stop request from BuP
    hiss_enable_n_i     : in  std_logic;  -- enable block
    path_enable_i       : in  std_logic;  --  when high data can be taken into account
    stream_enable_i     : in  std_logic;  --  when high, data stream is transfered.
    --------------------------------------
    -- Interface master_seria
    --------------------------------------
    next_d_req_tog_i    : in  std_logic; -- ask for a new data (last one is registered)
    --
    start_seria_o       : out std_logic;   -- high = data is valid
    buf_tog_o           : out std_logic;   -- toggle when buf change
    bufi_o              : out std_logic_vector(in_size_g-1 downto 0);
    bufq_o              : out std_logic_vector(in_size_g-1 downto 0)
  );

  end component;


----------------------
-- File: master_seria.vhd
----------------------
  component master_seria
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hiss_clk            : in  std_logic;
    reset_n             : in  std_logic;
    --------------------------------------
    -- Interface with Buffer_for_deseria synchronized at 240 MHz
    --------------------------------------
    -- Data from buffer for seria (extended to 12 to fit with shift_counter)
    bufi_i              : in std_logic_vector(11 downto 0);
    bufq_i              : in std_logic_vector(11 downto 0);
    tx_abmode_i         : in std_logic;  -- 0 = A - 1 = B
    trans_enable_i      : in std_logic;
    txv_immstop_i       : in std_logic;
    --
    next_data_req_tog_o : out  std_logic;
    --------------------------------------
    -- Interface with APB_interface 80 MHz
    --------------------------------------
    wrdata_i            : in  std_logic_vector(15 downto 0);
    add_i               : in  std_logic_vector( 5 downto 0);
    --------------------------------------
    -- Interface with SM 240 MHz
    --------------------------------------
    transmit_possible_i : in  std_logic;  -- high only when marker is sent
    rd_reg_pulse_i      : in  std_logic;  -- read register
    wr_reg_pulse_i      : in  std_logic;  -- write register
    seria_valid_o       : out std_logic;  -- data from seria is available
    reg_or_i_o          : out std_logic;  -- serialized a0-a2/d0-d7  val
    reg_or_q_o          : out std_logic   -- serialized a3-a5/d8-d15 val
    
  );

  end component;


----------------------
-- File: master_deseria.vhd
----------------------
  component master_deseria
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hiss_clk             : in  std_logic;
    reset_n              : in  std_logic;
    --------------------------------------
    -- Interface with BB (synchronized inside SM)
    --------------------------------------
    rf_rxi_i             : in  std_logic;  -- Received Real Part 
    rf_rxq_i             : in  std_logic;  -- Received Imaginary Part 
    --------------------------------------
    -- Interface with SM
    --------------------------------------
    start_rx_data_i      : in  std_logic;  -- high when there are rx data to deserialize
    get_reg_pulse_i      : in  std_logic;  -- get data (return from WildRF)
    cca_info_pulse_i     : in  std_logic;  -- get data (cca from WildRF)
    abmode_i             : in  std_logic;  -- 0 = A - 1 = B
    --
    get_reg_cca_conf_o   : out std_logic;  -- high (pulse) = data is ready
    --------------------------------------
    -- Interface with Rx Filters 60 MHz speed
    --------------------------------------
    -- Data for Rx Filter A or B -12 bits are output as it can contain info on unused bit.
    memo_i_reg_o         : out std_logic_vector(11 downto 0); --  CCA / RDATA or RX data
    memo_q_reg_o         : out std_logic_vector(11 downto 0); --  CCA / RDATA or RX data
    rx_val_tog_o         : out std_logic;  -- high = data is valid
    --------------------------------------
    --  Interface with Radio Controller sm 
    --------------------------------------
    hiss_enable_n_i      : in  std_logic;  -- enable block 
    -- Data (from read-access)
    parity_err_tog_o     : out std_logic;  -- toggle when parity error on reg deseria
    parity_err_cca_tog_o : out std_logic;  -- toggle when parity error on CCA deseria
    cca_tog_o            : out std_logic
  );

  end component;


----------------------
-- File: master_hiss_sm.vhd
----------------------
  component master_hiss_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hiss_clk                : in  std_logic;
    rfh_fastclk             : in  std_logic; -- 240 MHz clock inverted without clktree
    reset_n                 : in  std_logic;
    --------------------------------------
    -- Interface with Wild_RF
    --------------------------------------
    rf_rxi_i                : in  std_logic;  -- Real Part received
    rf_rxq_i                : in  std_logic;  -- Imaginary Part received 
    -- 
    rf_txi_o                : out std_logic;  -- Real Part to send 
    rf_txq_o                : out std_logic;  -- Imaginary Part to send
    rf_tx_enable_o          : out std_logic;  -- Enable the rf_txi/rf_txq output when high
    rf_rx_rec_o             : out std_logic;  -- Enable the rf_rx input when high
    rf_en_o                 : out std_logic;  -- Control Signal - enable transfers
    --------------------------------------
    -- Interface with serializer-deserializer
    --------------------------------------
    seria_valid_i           : in  std_logic;  -- high = there is a data to transfert
    start_seria_i           : in  std_logic;  -- 1st data to transfer
    get_reg_cca_conf_i      : in  std_logic;  -- high = accept received data
    parity_err_tog_i        : in  std_logic;  -- toggle = a prity error occured
    parity_err_cca_tog_i    : in  std_logic;  -- toggle = a prity error occured
    i_i                     : in  std_logic;  -- serialized d0-d7 val
    q_i                     : in  std_logic;  -- serialized d8-d15 val
    --
    start_rx_data_o         : out std_logic;  -- high when there are rx data to deserialize
    get_reg_pulse_o         : out std_logic;  -- pulse when data reg to get(right after the pulse)
    cca_info_pulse_o        : out std_logic;  -- pulse when cca info to get(right after the pulse)
    wr_reg_pulse_o          : out std_logic;  -- pulse when add/data to send
    rd_reg_pulse_o          : out std_logic;  -- pulse when data to send(right after the pulse)
    transmit_possible_o     : out std_logic;  -- enable the transmission (after the marker is set)
    rf_rxi_reg_o            : out std_logic;  -- registered input rf_rxi
    rf_rxq_reg_o            : out std_logic;  -- registered input rf_rxq    
    --------------------------------------------
    -- Interface for BuP
    --------------------------------------------
    txv_immstop_i           : in  std_logic;  -- BuP asks for immediate transmission stop
    --------------------------------------
    -- Interface with Radio Controller sm 
    --------------------------------------
    rf_en_force_i           : in  std_logic;  -- clock reset force rf_en in order to wake up hiss clock.
    hiss_enable_n_i         : in  std_logic;  -- enable block 
    force_hiss_pad_i        : in  std_logic;  -- when high the receivers/drivers are always activated
    clk_switch_req_i        : in  std_logic;  -- ask of clock switching (decoded from write_reg)
    back_from_deep_sleep_i  : in  std_logic;  -- pulse when wake up.
    preamble_detect_req_i   : in  std_logic;  -- ask of pre detection (from AGC)
    apb_access_i            : in  std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_i                : in  std_logic;  -- wr_nrd = '1' => write access
    rd_time_out_i           : in  std_logic;  -- time out : no reg val from RF
    clkswitch_time_out_i    : in  std_logic;  -- time out : no clock switch happens
    reception_enable_i      : in  std_logic;  -- high = BB accepts incoming data (after CCA detect)
    transmission_enable_i   : in  std_logic;  -- high = there are data to transmit
    sync_found_i            : in  std_logic;  -- high and remain high when sync is found
    --
    rd_access_stop_o        : out std_logic;  -- indicate the sync to cancel 
    switch_ant_tog_o        : out std_logic;  -- toggle = antenna switch
    acc_end_tog_o           : out std_logic;  -- toggle when acc finished
    glitch_found_o          : out std_logic;  -- pulse = glitch found or rf_rxi/rf_rxq  
    prot_err_o              : out std_logic;  -- error on the protocol (high during G pers)
    clk_switched_o          : out std_logic;  -- pulse when the clock will switch
    clk_switched_tog_o      : out std_logic   -- toggle when the clock will switch
    
    
  );

  end component;


----------------------
-- File: decode_add.vhd
----------------------
  component decode_add
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                   : in  std_logic; 
    reset_n               : in  std_logic;  
    --------------------------------------
    -- Signals
    --------------------------------------
    hiss_enable_n_i       : in  std_logic;  -- enable hiss block
    apb_access_i          : in  std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_i              : in  std_logic;  -- wr_nrd = '1' => write access
    add_i                 : in  std_logic_vector( 5 downto 0);
    wrdata_i              : in  std_logic_vector(15 downto 0);
    clk_switched_i        : in  std_logic;  -- clk switched.
    
    clk_switch_req_tog_o  : out std_logic;  -- toggle:ask of clock switching (decoded from write_reg)
    clk_switch_req_o      : out std_logic;  -- ask of clock switching (decoded from write_reg)
    clk_div_o             : out std_logic_vector(2 downto 0);
    back_from_deep_sleep_o : out std_logic  -- pulse when back to deep sleep
    
  );

  end component;


----------------------
-- File: master_dec_data.vhd
----------------------
  component master_dec_data
  generic (
    rx_a_size_g : integer := 10         -- size of data input of tx_filter A
    );  
  port (
    sampling_clk    : in  std_logic;
    reset_n         : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    -- Data from deserializer
    rx_i_i          : in  std_logic_vector(11 downto 0);
    rx_q_i          : in  std_logic_vector(11 downto 0);
    rx_val_tog_i    : in  std_logic;    -- high = data is valid
    --
    recep_enable_i  : in  std_logic;    -- when low reinit 
    rx_abmode_i     : in  std_logic;
    -- Data for Tx Filter A and B
    rx_i_o          : out std_logic_vector(rx_a_size_g-1 downto 0);  -- B data are on LSB
    rx_q_o          : out std_logic_vector(rx_a_size_g-1 downto 0);  -- B data are on LSB
    rx_val_tog_o    : out std_logic;    -- high = data is valid
    --
    clk_2skip_tog_o : out std_logic;    -- inform that 2 clk_skip are neededwhen toggle
    cs_error_o      : out std_logic;  -- when toggle : error on CS
    cs_o            : out std_logic_vector(1 downto 0);  -- CS info for AGC/CCA
    cs_valid_o      : out std_logic     -- high when the CS is valid
    );

  end component;


----------------------
-- File: sync_80to240.vhd
----------------------
  component sync_80to240
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hiss_clk              : in  std_logic; -- 240 MHz clock
    reset_n               : in  std_logic; 
    --------------------------------------
    --  ***  Signals ****
    --------------------------------------
    -- Control Signals (240 MHz)
    rd_reg_pulse_on240_i        : in  std_logic;  -- used to reset apb_access_on240_o
    wr_reg_pulse_on240_i        : in  std_logic;  -- used to reset apb_access_on240_o
    -- 80 MHz signals Inputs (from Radio Controller)
    txv_immstop_i               : in  std_logic;  -- BuP asks for transmission immediate stop
    hiss_enable_n_on80_i        : in  std_logic;  -- enable block 
    force_hiss_pad_on80_i       : in  std_logic;  -- when high the receivers/drivers are always activated
    tx_abmode_on80_i            : in  std_logic;  --  tx mode A=0 - B=1
    rx_abmode_on80_i            : in  std_logic;  --  rx mode A=0 - B=1
    rd_time_out_on80_i          : in  std_logic;  -- time out : no reg val from RF
    clkswitch_time_out_on80_i   : in  std_logic;  -- time out : no clkswitch happens
    apb_access_on80_i           : in  std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_on80_i               : in  std_logic;  -- wr_nrd = '1' => write access
    wrdata_on80_i               : in  std_logic_vector(15 downto 0);
    add_on80_i                  : in  std_logic_vector( 5 downto 0);
    preamble_detect_req_on80_i  : in  std_logic; 
    recep_enable_on80_i         : in  std_logic;  -- high = BB accepts incoming data (after CCA detect)
    trans_enable_on80_i         : in  std_logic;  -- high = there are data to transmit
    start_seria_on80_i          : in  std_logic;  -- high when trans is ready
    sync_found_on80_i           : in  std_logic;  -- sync A is found
    buf_tog_on80_i              : in  std_logic;
    bufi_on80_i                 : in  std_logic_vector(11 downto 0);
    bufq_on80_i                 : in  std_logic_vector(11 downto 0);
    -- 240 MHz Synchronized Outputs (to HiSS interface)
    txv_immstop_on240_o         : out std_logic;  -- BuP asks for transmission immediate stop
    hiss_enable_n_on240_o       : out std_logic;  -- enable block 
    force_hiss_pad_on240_o      : out std_logic;  -- when high the receivers/drivers are always activated
    tx_abmode_on240_o           : out std_logic;  -- tx mode A=0 - B=1
    rx_abmode_on240_o           : out std_logic;  -- rx mode A=0 - B=1
    rd_time_out_on240_o         : out std_logic;  -- timer out pulse
    clkswitch_time_out_on240_o  : out  std_logic;  -- time out : no clkswitch happens
    apb_access_on240_o          : out std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_on240_o              : out std_logic;  -- wr_nrd = '1' => write access
    wrdata_on240_o              : out std_logic_vector(15 downto 0);
    add_on240_o                 : out std_logic_vector( 5 downto 0);
    preamble_detect_req_on240_o : out std_logic;  -- (from decode_add)
    recep_enable_on240_o        : out std_logic;  -- high = BB accepts incoming data (after CCA detect)
    trans_enable_on240_o        : out std_logic;  -- high = there are data to transmit
    start_seria_on240_o         : out std_logic;  -- serialization can start
    sync_found_on240_o          : out  std_logic;  -- sync A is found
    bufi_on240_o                : out std_logic_vector(11 downto 0);
    bufq_on240_o                : out std_logic_vector(11 downto 0)
    
  );

  end component;


----------------------
-- File: sync_240to80.vhd
----------------------
  component sync_240to80
  generic (
    clk44_possible_g : integer := 0); -- when 1 - the radioctrl can work with a
                                      -- 44 MHz clock instead of the normal 80 MHz.
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    pclk                      : in  std_logic;  -- 240 MHz clock
    reset_n                   : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    -- Registers from deserializer : CCA / RDATA or RX data
    memo_i_reg_on240_i         : in  std_logic_vector(11 downto 0);
    memo_q_reg_on240_i         : in  std_logic_vector(11 downto 0);
    cca_tog_on240_i            : in  std_logic;
    acc_end_tog_on240_i        : in  std_logic;
    rx_val_tog_on240_i         : in  std_logic;
    -- Controls Signals
    next_data_req_tog_on240_i  : in  std_logic;
    switch_ant_tog_on240_i     : in  std_logic;
    clk_switch_req_tog_on240_i : in  std_logic;
    clk_switched_tog_on240_i   : in  std_logic;
    parity_err_tog_on240_i     : in  std_logic;
    parity_err_cca_tog_on240_i : in  std_logic;
    prot_err_on240_i           : in  std_logic; -- long pulse (gamma cycles)
    -- *** Outputs ****
    -- Data out
    rx_i_on80_o                : out std_logic_vector(11 downto 0);
    rx_q_on80_o                : out std_logic_vector(11 downto 0);
    rx_val_tog_on80_o          : out std_logic;
    -- CCA info
    cca_info_on80_o            : out std_logic_vector( 5 downto 0);
    cca_add_info_on80_o        : out std_logic_vector(15 downto 0);
    cca_on80_o                 : out std_logic;
    -- RDDATA
    prdata_on80_o              : out std_logic_vector(15 downto 0);
    acc_end_on80_o             : out std_logic;
    -- Controls Signals
    next_data_req_tog_on80_o   : out std_logic;
    switch_ant_tog_on80_o      : out std_logic;
    clk_switch_req_on80_o      : out std_logic;
    clk_switched_on80_o        : out std_logic;  -- pulse when clk switched
    parity_err_tog_on80_o      : out std_logic;
    parity_err_cca_tog_on80_o  : out std_logic;
    prot_err_on80_o            : out std_logic  -- pulse
      
  );

  end component;


----------------------
-- File: master_hiss.vhd
----------------------
  component master_hiss
  generic (
    rx_a_size_g      : integer := 11;   -- size of data of rx_filter A
    rx_b_size_g      : integer := 8;    -- size of data of rx_filter B
    tx_a_size_g      : integer := 10;   -- size of data input of tx_filter A
    tx_b_size_g      : integer := 1;    -- size of data input of tx_filter B
    clk44_possible_g : integer := 0);  -- when 1 - the radioctrl can work with a
  -- 44 MHz clock instead of the normal 80 MHz.
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hiss_clk              : in  std_logic; -- 240 MHz clock
    rfh_fastclk           : in  std_logic; -- 240 MHz clock without clktree directly from pad)
    pclk                  : in  std_logic; -- 80  MHz clock
    reset_n               : in  std_logic;
    hiss_reset_n          : in  std_logic;
    --------------------------------------
    -- Interface with Wild_RF
    --------------------------------------
    rf_rxi_i              : in  std_logic;  -- Real Part received
    rf_rxq_i              : in  std_logic;  -- Imaginary Part received 
    -- 
    rf_txi_o              : out std_logic;  -- Real Part to send 
    rf_txq_o              : out std_logic;  -- Imaginary Part to send
    rf_txen_o             : out std_logic;  -- Enable the rf_txi/rf_txq output when high
    rf_rxen_o             : out std_logic;  -- Enable the inputs rf_rx when high
    rf_en_o               : out std_logic;  -- Control Signal - enable transfers
    --------------------------------------
    -- Interface with muxed tx path
    --------------------------------------
    -- Data from Tx Filter A and B
    tx_ai_i               : in  std_logic_vector(tx_a_size_g-1 downto 0);
    tx_aq_i               : in  std_logic_vector(tx_a_size_g-1 downto 0);
    tx_val_tog_a_i        : in  std_logic;   -- toggle = data is valid
    --
    tx_b_i                : in  std_logic_vector(2*tx_b_size_g-1 downto 0);
    tx_val_tog_b_i        : in  std_logic;   -- toggle = data is valid
    --------------------------------------
    -- Interface with Rx Paths 
    --------------------------------------
    hiss_enable_n_i      : in  std_logic;  -- enable block 60 MHz
    -- Data from Rx Filter A or B
    rx_i_o               : out std_logic_vector(rx_a_size_g-1 downto 0); -- B data are on LSB
    rx_q_o               : out std_logic_vector(rx_a_size_g-1 downto 0); -- B data are on LSB
    rx_val_tog_o         : out std_logic;  -- toggle = data is valid
    clk_2skip_tog_o      : out std_logic;  -- tog when 2 clock-skip is needed | gated 44 MHz clk
    --------------------------------------
    -- Interface with Radio Controller sm 
    --------------------------------------
    -- 80 MHz signals Inputs (from Radio Controller)
    rf_en_force_i         : in  std_logic;  -- clock reset force rf_en in order to wake up hiss clock.
    tx_abmode_i           : in  std_logic;  -- transmission mode : 0 = A , 1 = B
    rx_abmode_i           : in  std_logic;  -- reception mode : 0 = A , 1 = B
    force_hiss_pad_i      : in  std_logic;  -- when high the receivers/drivers are always activated
    apb_access_i          : in  std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_i              : in  std_logic;  -- wr_nrd = '1' => write access
    rd_time_out_i         : in  std_logic;  -- time out : no reg val from RF
    clkswitch_time_out_i  : in  std_logic;  -- time out : no clock switch happens
    wrdata_i              : in  std_logic_vector(15 downto 0); -- data to write in reg
    add_i                 : in  std_logic_vector( 5 downto 0); -- add of the reg access
    sync_found_i          : in  std_logic;  -- high and remain high when sync is found
    -- BuP control
    txv_immstop_i         : in std_logic;   -- BuP asks for immediate transmission stop
    -- Control signals Inputs (from Radio Controller)   
    recep_enable_i        : in  std_logic;  -- high = BB accepts incoming data (after CCA detect)
    trans_enable_i        : in  std_logic;  -- high = there are data to transmit
    --
    -- Data (from read-access)
    parity_err_tog_o      : out std_logic;  -- toggle when parity check error (no data will be sent)
    rddata_o              : out std_logic_vector(15 downto 0);
    -- Control Signals    
    cca_search_i          : in  std_logic;  -- wait for CCA (wait for pr_detected_o)
    --
    cca_info_o            : out std_logic_vector(5 downto 0);  -- CCA information
    cca_add_info_o        : out std_logic_vector(15 downto 0); -- CCA additional information
    cca_o                 : out std_logic;  -- high during a 80 MHz period
    parity_err_cca_tog_o  : out std_logic;  -- toggle when parity err during CCA info
    cs_error_o            : out std_logic;  -- when high : error on CS
    switch_ant_tog_o      : out std_logic;  -- toggle = antenna switch
    cs_o                  : out std_logic_vector(1 downto 0);  -- CS info for AGC/CCA
    cs_valid_o            : out std_logic;  -- high when the CS is valid
    acc_end_o             : out std_logic;  -- toggle => acc finished
    prot_err_o            : out std_logic;  -- "long signal" : error on the protocol
    clk_switch_req_o      : out std_logic;  -- pulse: clk swich req for time out
    clk_div_o             : out std_logic_vector(2 downto 0); -- val of rf_fastclk speed
    clk_switched_tog_o    : out std_logic;   -- toggle, the clock will switch
    clk_switched_80_o     : out std_logic;   -- pulse, the clock will switch (80 MHz)
    --
    hiss_diagport_o       : out std_logic_vector(15 downto 0)
  );

  end component;



 
end master_hiss_pkg;
