
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: interleaver.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Interleaver and carrier reordering block.
--               This block performs the two premutation described by the
--               standard and sends out the carriers in the order expected
--               by the IFFT.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/interleaver/vhdl/rtl/interleaver.vhd,v  
--  Log: interleaver.vhd,v  
-- Revision 1.2  2003/03/26 10:57:11  Dr.A
-- Modified marker generation for FFT compliancy.
--
-- Revision 1.1  2003/03/13 14:50:56  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
--library interleaver_rtl;
library work;
--use interleaver_rtl.interleaver_pkg.all;
use work.interleaver_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity interleaver is
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

end interleaver;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of interleaver is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for memory interface.
  signal addr      : std_logic_vector(4 downto 0); -- address.
  signal mask_wr   : std_logic_vector(5 downto 0); -- write mask.
  signal rd_wrn    : std_logic; -- '1' means read, '0' means write.
  signal msb_lsbn  : std_logic; -- '1' to read the MSB, '0' to read the LSB.
  signal data_p1   : std_logic_vector(5 downto 0); -- First permutated data.


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  --------------------------------------
  -- Interleaver control block.
  --------------------------------------
  interl_ctrl_1 : interl_ctrl
    port map (
      -- Clocks & Reset
      clk               => clk,             -- Module clock.
      reset_n           => reset_n,         -- Asynchronous reset.
      -- Controls
      enable_i          => enable_i,        -- TX path enable.
      data_valid_i      => data_valid_i,
      data_ready_i      => data_ready_i,
      qam_mode_i        => qam_mode_i,
      marker_i          => marker_i,
      --
      pilot_ready_o     => pilot_ready_o,
      start_signal_o    => start_signal_o,  -- 'start of signal' marker.
      end_burst_o       => end_burst_o,      -- 'end of burst' marker.
      data_valid_o      => data_valid_o,
      data_ready_o      => data_ready_o,
      null_carrier_o    => null_carrier_o,  -- '1' data for null carriers.
      qam_mode_o        => qam_mode_o,      -- coding rate.
      -- Memory interface
      data_p1_i         => data_p1,         -- First permutated data.
      --
      addr_o            => addr,            -- Memory address.
      mask_wr_o         => mask_wr,         -- memory write mask.
      rd_wrn_o          => rd_wrn,          -- '1' to read, '0' to write.
      msb_lsbn_o        => msb_lsbn,        -- '1' to read MSB, '0' to read LSB.
      -- Data
      pilot_scr_i       => pilot_scr_i,     -- Data for the 4 pilot carriers.
      --
      data_o            => data_o           -- Interleaved data.
    
      );


  --------------------------------------
  -- Memory for permutation 1.
  --------------------------------------
  interl_mem_1 : interl_mem
    port map (
      -- Clocks & Reset
      clk               => clk,             -- Module clock.
      reset_n           => reset_n,         -- Asynchronous reset.
      -- Controls
      enable_i          => enable_i,        -- TX path enable.
      addr_i            => addr,            -- Memory address.
      mask_wr_i         => mask_wr,         -- Memory write mask.
      rd_wrn_i          => rd_wrn,          -- '1' to read, '0' to write.
      msb_lsbn_i        => msb_lsbn,
      -- Data
      x_i               => x_i,             -- x data from puncturer.
      y_i               => y_i,             -- y data from puncturer.
      --
      data_p1_o         => data_p1          -- First permutated data.
      );


end RTL;
