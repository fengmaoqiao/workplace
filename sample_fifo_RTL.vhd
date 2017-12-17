
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: sample_fifo.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Sample Fifo Top Level - Instantiate sm, ring_buffer and 
-- output modes sm.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/sample_fifo/vhdl/rtl/sample_fifo.vhd,v  
--  Log: sample_fifo.vhd,v  
-- Revision 1.2  2003/05/15 13:09:17  Dr.B
-- adapt FIFO_DEPTH.
--
-- Revision 1.1  2003/03/27 17:14:49  Dr.B
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

--library sample_fifo_rtl;
library work;
--use sample_fifo_rtl.sample_fifo_pkg.all;
use work.sample_fifo_pkg.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity sample_fifo is
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

end sample_fifo;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of sample_fifo is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant FIFO_WIDTH_CT               : integer := 22; 
  constant FIFO_DEPTH_CT               : integer := 26; 
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal ctrl_data_valid   : std_logic;
  signal start_rd          : std_logic;
  signal rbuf_data_i       : std_logic_vector(i_i'length + q_i'length - 1 downto 0);
  signal rbuf_data_o       : std_logic_vector(i_o'length + q_o'length - 1 downto 0);
  signal out_data_ready_o  : std_logic;
  signal rbuf_data_valid_o : std_logic;
  signal rbuf_i_o          : std_logic_vector(10 downto 0);
  signal rbuf_q_o          : std_logic_vector(10 downto 0);
  signal init              : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  init <= not sync_res_n;
  -----------------------------------------------------------------------------
  -- Sample Fifo States Machines Instantiation
  -----------------------------------------------------------------------------
  sample_fifo_sm_1 : sample_fifo_sm
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      init_i              => init,
      data_valid_i        => data_valid_i,
      timoffst_i          => timoffst_i,
      frame_start_valid_i => frame_start_valid_i,
      --
      start_rd_o          => start_rd,
      data_valid_o        => ctrl_data_valid
      );

  -----------------------------------------------------------------------------
  -- Ring Buffer Instantiation
  -----------------------------------------------------------------------------
  ring_buffer_1 : ring_buffer
    generic map (
      fifo_width_g => FIFO_WIDTH_CT,
      fifo_depth_g => FIFO_DEPTH_CT
      )
    port map (
      clk          => clk,
      reset_n      => reset_n,
      init_i       => init,
      --
      data_valid_i => ctrl_data_valid,
      data_ready_i => out_data_ready_o,
      --
      start_rd_i     => start_rd,
      rd_wr_diff   => timoffst_i,
      data_valid_o => rbuf_data_valid_o,
      data_i       => rbuf_data_i,
      data_o       => rbuf_data_o
      );

  -- I and Q are concatenated inside rbuf_data_o => split it
  rbuf_i_o    <= rbuf_data_o(rbuf_data_o'high downto rbuf_data_o'low + i_o'length);
  rbuf_q_o    <= rbuf_data_o(q_o'high downto 0);
  rbuf_data_i <= i_i & q_i;

  -----------------------------------------------------------------------------
  -- Output Modes Instantiation
  -----------------------------------------------------------------------------
  output_modes_1 : output_modes
    port map(
      clk               => clk,
      reset_n           => reset_n,
      init_i            => init,
      i_i               => rbuf_i_o,
      q_i               => rbuf_q_o,
      data_valid_i      => rbuf_data_valid_o,
      data_ready_i      => data_ready_i,
      --
      i_o               => i_o,
      q_o               => q_o,
      data_ready_o      => out_data_ready_o,
      data_valid_o      => data_valid_o,
      start_of_burst_o  => start_of_burst_o,
      start_of_symbol_o => start_of_symbol_o
      );

end RTL;
