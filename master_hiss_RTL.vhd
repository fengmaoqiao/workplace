
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: master_hiss.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.18   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Master HiSS top level - Instantiate subblocks
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/master_hiss/vhdl/rtl/master_hiss.vhd,v  
--  Log: master_hiss.vhd,v  
-- Revision 1.18  2005/03/16 13:09:20  sbizet
-- #BugId:1135#
-- added txv_immstop port to master_seria
--
-- Revision 1.17  2005/01/06 15:08:44  sbizet
-- #BugId:713#
-- Added txv_immstop enhancement
--
-- Revision 1.16  2004/07/16 07:36:02  Dr.B
-- add cca_add_info feature
--
-- Revision 1.15  2004/03/29 13:01:31  Dr.B
-- add clk44possible_g generic.
--
-- Revision 1.14  2004/02/19 17:26:59  Dr.B
-- add hiss_reset_n reset.
--
-- Revision 1.13  2003/12/01 09:57:23  Dr.B
-- add rd_access_stop.
--
-- Revision 1.12  2003/11/28 10:39:23  Dr.B
-- change update of apb_accesses.
--
-- Revision 1.11  2003/11/26 13:58:53  Dr.B
-- decode_add is now running at 240 MHz.
--
-- Revision 1.10  2003/11/21 17:52:43  Dr.B
-- add stream_enable_i.
--
-- Revision 1.9  2003/11/20 11:18:08  Dr.B
-- add cs protection + sync 240to80.
--
-- Revision 1.8  2003/11/17 14:33:37  Dr.B
-- add clk_switch_80 output.
--
-- Revision 1.7  2003/10/30 14:37:24  Dr.B
-- remove sampling_clk + add CCA info.
--
-- Revision 1.6  2003/10/09 08:23:58  Dr.B
-- add carrier sense info.
--
-- Revision 1.5  2003/09/25 12:32:08  Dr.B
-- start_seria replace one_data_in_buf, ant_selection, cca_search ...
--
-- Revision 1.4  2003/09/23 13:03:35  Dr.B
-- mux rx a b
--
-- Revision 1.3  2003/09/22 09:31:42  Dr.B
-- new subblocks.
--
-- Revision 1.2  2003/07/21 12:24:35  Dr.B
-- remove clk_gen_rtl.
--
-- Revision 1.1  2003/07/21 11:52:29  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

--library master_hiss_rtl;
library work;
--use master_hiss_rtl.master_hiss_pkg.all;
use work.master_hiss_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity master_hiss is
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

end master_hiss;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of master_hiss is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Synchro 80 -> 240 MHz
  signal txv_immstop_on240         : std_logic;
  signal hiss_enable_n_on240       : std_logic;
  signal recep_enable_on240        : std_logic;
  signal trans_enable_on240        : std_logic;
  signal sync_found_on240          : std_logic;
  signal force_hiss_pad_on240      : std_logic;
  signal tx_abmode_on240           : std_logic;
  signal rd_time_out_on240         : std_logic;
  signal clkswitch_time_out_on240  : std_logic;
  signal apb_access_on240          : std_logic;
  signal wr_nrd_on240              : std_logic;
  signal wrdata_on240              : std_logic_vector(15 downto 0);
  signal add_on240                 : std_logic_vector( 5 downto 0);
  signal clk_switch_req_tog_on240  : std_logic;
  signal preamble_detect_req_on240 : std_logic;
  -- Synchro 240 -> 80 MHz
  signal memo_i_reg_on240         : std_logic_vector(11 downto 0);
  signal memo_q_reg_on240         : std_logic_vector(11 downto 0);
  signal cca_tog_on240            : std_logic;
  signal acc_end_tog_on240        : std_logic;
  signal rx_val_tog_on240         : std_logic;
  signal next_data_req_tog_on240  : std_logic;
  signal switch_ant_tog_on240     : std_logic;
  signal clk_switched_tog_on240   : std_logic;
  signal parity_err_tog_on240     : std_logic;
  signal parity_err_cca_tog_on240 : std_logic;
  signal prot_err_on240           : std_logic;  -- long pulse (gamma cycles)
  -- Interface SM <-> decode_add
  signal clk_switch_req_on240      : std_logic;
  signal clk_switched_on240        : std_logic;
  signal back_from_deep_sleep      : std_logic;  
  -- Interface SM <-> serializer/deserializer
  signal glitch_found              : std_logic;
  signal seria_valid               : std_logic;
  signal get_reg_cca_conf          : std_logic;
  signal i_or_reg                  : std_logic;
  signal q_or_reg                  : std_logic;
  signal start_rx_data             : std_logic;
  signal get_reg_pulse             : std_logic;
  signal cca_info_pulse            : std_logic;
  signal rd_reg_pulse              : std_logic;
  signal wr_reg_pulse              : std_logic;
  signal rf_rxi_reg                : std_logic;
  signal rf_rxq_reg                : std_logic;
  signal rx_abmode_on240           : std_logic;
  -- Muxed Input Data
  signal tx_i                      : std_logic_vector(11 downto 0);
  signal tx_q                      : std_logic_vector(11 downto 0);
  signal tx_val_tog                : std_logic;
  -- Interface seria <-> buffer_for_seria
  signal start_seria               : std_logic;
  signal bufi                      : std_logic_vector(11 downto 0);
  signal bufq                      : std_logic_vector(11 downto 0);
  signal buf_tog                   : std_logic;
  signal next_data_req_tog_on80    : std_logic;
  -- Data synchronized at 240 MHz
  signal start_seria_on240         : std_logic;
  signal bufi_on240                : std_logic_vector(11 downto 0);
  signal bufq_on240                : std_logic_vector(11 downto 0);
  -- Interface deseria <-> dec_data
  signal rx_i_on80                 : std_logic_vector(11 downto 0);  -- before skipping
  signal rx_q_on80                 : std_logic_vector(11 downto 0);
  signal rx_val_tog_on80           : std_logic;
  signal transmit_possible         : std_logic;
  signal rd_access_stop            : std_logic;

  
  

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- *** SYNCHRONIZATION ***
  ----------------------------------------------------------------------------
  -- Synchro 80 -> 240 MHz
  sync_80to240_1: sync_80to240
    port map (
      -- Clocks & Reset
      hiss_clk                    => hiss_clk,
      reset_n                     => hiss_reset_n,
      -- Control Signals
      rd_reg_pulse_on240_i        => rd_access_stop,
      wr_reg_pulse_on240_i        => wr_reg_pulse,
      -- 80 MHz signals Inputs (from Radio Controller or BuP)
      txv_immstop_i               => txv_immstop_i, -- from BuP
      hiss_enable_n_on80_i        => hiss_enable_n_i,
      force_hiss_pad_on80_i       => force_hiss_pad_i,
      tx_abmode_on80_i            => tx_abmode_i,
      rx_abmode_on80_i            => rx_abmode_i,
      rd_time_out_on80_i          => rd_time_out_i,
      clkswitch_time_out_on80_i   => clkswitch_time_out_i,
      apb_access_on80_i           => apb_access_i,
      wr_nrd_on80_i               => wr_nrd_i,
      wrdata_on80_i               => wrdata_i,
      add_on80_i                  => add_i,
      preamble_detect_req_on80_i  => cca_search_i,
      recep_enable_on80_i         => recep_enable_i,
      trans_enable_on80_i         => trans_enable_i,
      start_seria_on80_i          => start_seria,
      sync_found_on80_i           => sync_found_i,
      buf_tog_on80_i              => buf_tog,
      bufi_on80_i                 => bufi,
      bufq_on80_i                 => bufq,
      -- 240 MHz Synchronized Outputs (to HiSS interface)
      txv_immstop_on240_o         => txv_immstop_on240,
      hiss_enable_n_on240_o       => hiss_enable_n_on240,
      force_hiss_pad_on240_o      => force_hiss_pad_on240,
      tx_abmode_on240_o           => tx_abmode_on240,
      rx_abmode_on240_o           => rx_abmode_on240,
      rd_time_out_on240_o         => rd_time_out_on240,
      clkswitch_time_out_on240_o  => clkswitch_time_out_on240,
      apb_access_on240_o          => apb_access_on240,
      wr_nrd_on240_o              => wr_nrd_on240,
      wrdata_on240_o              => wrdata_on240,
      add_on240_o                 => add_on240,
      preamble_detect_req_on240_o => preamble_detect_req_on240,
      recep_enable_on240_o        => recep_enable_on240,
      trans_enable_on240_o        => trans_enable_on240,
      start_seria_on240_o         => start_seria_on240,
      sync_found_on240_o          => sync_found_on240,
      bufi_on240_o                => bufi_on240,
      bufq_on240_o                => bufq_on240);

  

  -----------------------------------------------------------------------------
  -- *** HiSS BLOCKS ***
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- Decode_add Instantiation - 240 MHz Block
  -----------------------------------------------------------------------------
  decode_add_1: decode_add
    port map (
      clk                    => hiss_clk,
      reset_n                => hiss_reset_n,
      hiss_enable_n_i        => hiss_enable_n_on240,  -- 240 MHz hiss_enable
      apb_access_i           => apb_access_on240,
      wr_nrd_i               => wr_nrd_on240,
      add_i                  => add_on240,
      wrdata_i               => wrdata_on240,
      clk_switched_i         => clk_switched_on240,
      --
      clk_switch_req_tog_o   => clk_switch_req_tog_on240,
      clk_switch_req_o       => clk_switch_req_on240,
      clk_div_o              => clk_div_o,
      back_from_deep_sleep_o => back_from_deep_sleep);

  -----------------------------------------------------------------------------
  -- State Machines Instantiation
  -----------------------------------------------------------------------------
  master_hiss_sm_1: master_hiss_sm
    port map (
      -- Clocks & Reset
      rfh_fastclk            => rfh_fastclk,
      hiss_clk               => hiss_clk,
      reset_n                => hiss_reset_n,
      -- Interface with Wild_RF
      rf_rxi_i               => rf_rxi_i,
      rf_rxq_i               => rf_rxq_i,
      --
      rf_txi_o               => rf_txi_o,
      rf_txq_o               => rf_txq_o,
      rf_tx_enable_o         => rf_txen_o,
      rf_rx_rec_o            => rf_rxen_o,
      rf_en_o                => rf_en_o,
      -- Interface with serializer-deserializer
      seria_valid_i          => seria_valid,
      start_seria_i          => start_seria_on240,
      get_reg_cca_conf_i     => get_reg_cca_conf,
      parity_err_tog_i       => parity_err_tog_on240,
      parity_err_cca_tog_i   => parity_err_cca_tog_on240,
      i_i                    => i_or_reg,
      q_i                    => q_or_reg,
      --
      start_rx_data_o        => start_rx_data,
      get_reg_pulse_o        => get_reg_pulse,
      cca_info_pulse_o       => cca_info_pulse,
      wr_reg_pulse_o         => wr_reg_pulse,
      rd_reg_pulse_o         => rd_reg_pulse,
      transmit_possible_o    => transmit_possible,
      rf_rxi_reg_o           => rf_rxi_reg,
      rf_rxq_reg_o           => rf_rxq_reg,
      -- Interface for BuP
      txv_immstop_i          => txv_immstop_on240,
      -- Interface with Radio Controller sm
      rf_en_force_i          => rf_en_force_i,
      hiss_enable_n_i        => hiss_enable_n_on240,
      force_hiss_pad_i       => force_hiss_pad_on240,
      clk_switch_req_i       => clk_switch_req_on240,
      back_from_deep_sleep_i => back_from_deep_sleep,
      preamble_detect_req_i  => preamble_detect_req_on240,
      apb_access_i           => apb_access_on240,
      wr_nrd_i               => wr_nrd_on240,
      rd_time_out_i          => rd_time_out_on240,
      clkswitch_time_out_i   => clkswitch_time_out_on240,
      reception_enable_i     => recep_enable_on240,
      transmission_enable_i  => trans_enable_on240,
      sync_found_i           => sync_found_on240,
      --
      rd_access_stop_o       => rd_access_stop,
      switch_ant_tog_o       => switch_ant_tog_on240,
      acc_end_tog_o          => acc_end_tog_on240,
      glitch_found_o         => glitch_found,
      prot_err_o             => prot_err_on240,
      clk_switched_o         => clk_switched_on240,
      clk_switched_tog_o     => clk_switched_tog_on240);


  -- To clock controller block:
  clk_switched_tog_o <= clk_switched_tog_on240;

   
  -----------------------------------------------------------------------------
  -- Buffer for Serialization Instantiation (60 MHz Block)
  -----------------------------------------------------------------------------
  -- mux input tx data  : A mode or B mode
  tx_val_tog <= tx_val_tog_a_i when tx_abmode_i = '0' else tx_val_tog_b_i;
  tx_i       <= sxt(tx_ai_i,12) when tx_abmode_i = '0'
                else sxt(tx_b_i(1) & tx_b_i(1) ,12); 
  tx_q       <= sxt(tx_aq_i,12) when tx_abmode_i = '0'
                else sxt(tx_b_i(0) & tx_b_i(0),12);
                        
  buffer_for_seria_1: buffer_for_seria
    generic map (
      buf_size_g  => 2,
      fifo_content_g => 1,
      empty_at_end_g => 1,
      in_size_g    => 12)
    port map (
      -- Clocks & Reset
      sampling_clk      => pclk,
      reset_n           => reset_n,
      -- Interface with muxed tx path
      data_i_i          => tx_i,
      data_q_i          => tx_q,
      data_val_tog_i    => tx_val_tog,
      -- Interface with Radio Controller  60 MHz
      immstop_i         => txv_immstop_i,
      hiss_enable_n_i   => hiss_enable_n_i,
      path_enable_i     => trans_enable_i,
      stream_enable_i   => trans_enable_i,
     -- Interface master_seria
      next_d_req_tog_i  => next_data_req_tog_on80,
      --
      start_seria_o     => start_seria,
      buf_tog_o         => buf_tog,
      bufi_o            => bufi,
      bufq_o            => bufq);
  
  -----------------------------------------------------------------------------
  -- Serializer Instantiation (240 MHz Block)
  -----------------------------------------------------------------------------
  master_seria_1: master_seria
    port map (
       -- Clocks & Reset
      hiss_clk            => hiss_clk,
      reset_n             => hiss_reset_n,
      -- Interface with Buffer_for_deseria
      bufi_i              => bufi_on240,
      bufq_i              => bufq_on240,
      tx_abmode_i         => tx_abmode_on240,
      trans_enable_i      => start_seria_on240,
      txv_immstop_i       => txv_immstop_on240,
      --
      next_data_req_tog_o => next_data_req_tog_on240,
      -- Interface with APB_interface 80 MHz
      wrdata_i            => wrdata_on240,
      add_i               => add_on240,
      -- Interface with SM 240 MHz
      transmit_possible_i => transmit_possible,
      rd_reg_pulse_i      => rd_reg_pulse,
      wr_reg_pulse_i      => wr_reg_pulse,
      --
      seria_valid_o       => seria_valid,
      reg_or_i_o          => i_or_reg,
      reg_or_q_o          => q_or_reg);

  -----------------------------------------------------------------------------
  -- Deserializer Instantiation
  -----------------------------------------------------------------------------
  master_deseria_1: master_deseria
    port map (
      -- Clocks & Reset
      hiss_clk             => hiss_clk,
      reset_n              => hiss_reset_n,
      -- Interface with BB (synchronized inside SM)
      rf_rxi_i             => rf_rxi_reg,
      rf_rxq_i             => rf_rxq_reg,
      -- Interface with SM
      start_rx_data_i      => start_rx_data,
      get_reg_pulse_i      => get_reg_pulse,
      cca_info_pulse_i     => cca_info_pulse,
      abmode_i             => rx_abmode_on240,
      get_reg_cca_conf_o   => get_reg_cca_conf,
      -- Controls
      memo_i_reg_o         => memo_i_reg_on240,
      memo_q_reg_o         => memo_q_reg_on240,
      rx_val_tog_o         => rx_val_tog_on240,
      --  Interface with Radio Controller sm
      hiss_enable_n_i      => hiss_enable_n_on240,
      --
      parity_err_tog_o     => parity_err_tog_on240,
      parity_err_cca_tog_o => parity_err_cca_tog_on240,
      cca_tog_o            => cca_tog_on240);


  -----------------------------------------------------------------------------
  -- Sync 240 to 80
  -----------------------------------------------------------------------------
  sync_240to80_1: sync_240to80
    generic map (
      clk44_possible_g => clk44_possible_g)  -- when 1 - the radioctrl can work with a
    port map (
      -- Clocks & Reset
      pclk                       => pclk,              -- [in]  240 MHz clock
      reset_n                    => reset_n,           -- [in]
      -- Signals
      -- Registers from deserializer : CCA / RDATA or RX data
      memo_i_reg_on240_i         => memo_i_reg_on240,   -- [in]
      memo_q_reg_on240_i         => memo_q_reg_on240,   -- [in]
      cca_tog_on240_i            => cca_tog_on240,      -- [in]
      acc_end_tog_on240_i        => acc_end_tog_on240,  -- [in]
      rx_val_tog_on240_i         => rx_val_tog_on240,   -- [in]
      -- Controls Signals
      next_data_req_tog_on240_i  => next_data_req_tog_on240,   -- [in]
      switch_ant_tog_on240_i     => switch_ant_tog_on240,      -- [in]
      clk_switch_req_tog_on240_i => clk_switch_req_tog_on240,  -- [in]
      clk_switched_tog_on240_i   => clk_switched_tog_on240,    -- [in]
      parity_err_tog_on240_i     => parity_err_tog_on240,      -- [in]
      parity_err_cca_tog_on240_i => parity_err_cca_tog_on240,  -- [in]
      prot_err_on240_i           => prot_err_on240,            -- [in]  long pulse (gamma cycles)
      -- *** Outputs ****
      -- Data out
      rx_i_on80_o                => rx_i_on80,          -- [out]
      rx_q_on80_o                => rx_q_on80,          -- [out]
      rx_val_tog_on80_o          => rx_val_tog_on80,    -- [out]
      -- CCA info
      cca_info_on80_o            => cca_info_o,       -- [out]
      cca_add_info_on80_o        => cca_add_info_o,   -- [out]
      cca_on80_o                 => cca_o,        -- [out]
      -- RDDATA
      prdata_on80_o              => rddata_o,     -- [out]
      acc_end_on80_o             => acc_end_o,    -- [out]
      -- Controls Signals
      next_data_req_tog_on80_o   => next_data_req_tog_on80,    -- [out]
      switch_ant_tog_on80_o      => switch_ant_tog_o,          -- [out]
      clk_switch_req_on80_o      => clk_switch_req_o,          -- [out] 
      clk_switched_on80_o        => clk_switched_80_o,         -- [out] pulse when clk switched
      parity_err_tog_on80_o      => parity_err_tog_o,          -- [out]
      parity_err_cca_tog_on80_o  => parity_err_cca_tog_o,      -- [out]
      prot_err_on80_o            => prot_err_o);  -- [out] pulse

  -----------------------------------------------------------------------------
  -- Decode Data ( get sample skip and cs inserted inside data)
  -----------------------------------------------------------------------------
  master_dec_data_1: master_dec_data
    generic map (
      rx_a_size_g => rx_a_size_g           -- size of data input of tx_filter A
      )                                    -- size of data input of tx_filter B
    port map (
      sampling_clk    => pclk,             -- [in]
      reset_n         => reset_n,          -- [in]
      --
      rx_i_i          => rx_i_on80,        -- [in]
      rx_q_i          => rx_q_on80,        -- [in]
      rx_val_tog_i    => rx_val_tog_on80,  -- [in]  high = data is valid
      recep_enable_i  => recep_enable_i,   -- [in]
      rx_abmode_i     => rx_abmode_i,      -- [in]
      --
      rx_i_o          => rx_i_o,           -- [out]
      rx_q_o          => rx_q_o,           -- [out]
      rx_val_tog_o    => rx_val_tog_o,     -- [out] high = data is valid
      clk_2skip_tog_o => clk_2skip_tog_o,  -- [out]
      cs_error_o      => cs_error_o,       -- [out]
      cs_o            => cs_o,             -- [out]
      cs_valid_o      => cs_valid_o);      -- [out]

  
  hiss_diagport_o <= (others => '0');
  
end RTL;
