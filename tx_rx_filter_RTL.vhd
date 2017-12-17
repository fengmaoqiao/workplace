
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: tx_rx_filter.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.27   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Tx & RX Filter for WILD Modem A2
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/tx_rx_filter/vhdl/rtl/tx_rx_filter.vhd,v  
--  Log: tx_rx_filter.vhd,v  
-- Revision 1.27  2005/01/18 13:13:24  Dr.C
-- #BugId:960#
-- Added dc_pre_estim_4_agc outputs and reduce dc_pre_estim to 11-bit.
--
-- Revision 1.26  2004/10/27 14:15:40  Dr.C
-- #BugId:799#
-- Added dc pre-estimation calculation.
--
-- Revision 1.25  2004/05/13 14:48:08  Dr.C
-- Added use_sync_reset_g generic.
--
-- Revision 1.24  2004/04/07 13:44:25  Dr.C
-- Change architecture for redure gate count.
--
-- Revision 1.23  2003/12/03 12:08:41  Dr.C
-- Added sample_toggle_tx_o.
--
-- Revision 1.22  2003/11/29 11:29:12  Dr.C
-- Changed architecture.
--
-- Revision 1.21  2003/11/18 15:10:41  Dr.C
-- Added resynchronization for start_of_burst.
--
-- Revision 1.20  2003/11/18 13:08:01  Dr.C
-- Resynchronized tx_rx_select.
--
-- Revision 1.19  2003/10/27 11:28:23  Dr.C
-- Added sync_reset_n.
--
-- Revision 1.18  2003/09/22 13:00:13  Dr.C
-- Added clear_buffer for tx_60mhz I/Q assignment.
--
-- Revision 1.17  2003/09/15 16:41:21  Dr.C
-- Added a toggle for Rx output.
--
-- Revision 1.16  2003/08/29 16:13:16  Dr.C
-- Updated core_filter with clear_buffer input.
--
-- Revision 1.15  2003/07/02 13:31:52  Dr.C
-- Changed structure.
--
-- Revision 1.14  2003/06/11 09:26:53  Dr.C
-- Removed last version.
--
-- Revision 1.13  2003/06/04 15:04:34  Dr.C
-- Updated core_filter & added rounding.
--
-- Revision 1.12  2003/04/11 15:16:19  Dr.C
-- Debugged Rx norm.
--
-- Revision 1.11  2003/04/04 12:48:09  Dr.C
-- Debugged Tx output value.
--
-- Revision 1.10  2003/04/02 08:18:37  Dr.C
-- Debugged saturation constants.
--
-- Revision 1.9  2003/04/01 14:41:00  Dr.C
-- Added saturation for Tx outputs.
--
-- Revision 1.8  2003/03/31 07:42:59  Dr.C
-- Added filtbyp_tx_i and filtbyp_rx_i inputs.
--
-- Revision 1.7  2003/03/28 18:47:08  Dr.C
-- Removed natural range convertion for Tx outputs.
--
-- Revision 1.6  2003/03/27 14:43:43  Dr.C
-- Removed 2's complement notation in Rx.
--
-- Revision 1.5  2003/03/26 14:52:13  Dr.C
-- Added register after normalizations.
--
-- Revision 1.4  2003/03/24 09:53:02  Dr.C
-- Added normalization for Rx path output.
--
-- Revision 1.3  2003/03/18 15:38:52  Dr.C
-- Added zero_rx signal.
--
-- Revision 1.2  2003/03/18 15:19:31  Dr.C
-- Changed comment.
--
-- Revision 1.1  2003/03/17 15:33:32  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library tx_rx_filter_rtl;
library work;
--use tx_rx_filter_rtl.tx_rx_filter_pkg.ALL; 
use work.tx_rx_filter_pkg.ALL; 

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity tx_rx_filter is
   generic (
    size_in_tx_g     : integer := 10; -- I & Q size for Tx input
    size_out_tx_g    : integer := 8;  -- I & Q size for Tx output
    size_in_rx_g     : integer := 10; -- I & Q size for Tx input
    size_out_rx_g    : integer := 11; -- I & Q size for Rx output
    size_core_in_g   : integer := 10; -- size for Core front-end input
    size_core_out_g  : integer := 15; -- size for Core front-end output
    --
--    use_sync_reset_g : integer := 1   -- when 1 sync_reset_n input is used
    use_sync_reset_g : integer := 1   -- when 1 sync_reset_n input is used
    );                                -- else the reset_n input must be separately
  port (                              -- controlled by the reset controller
    ----------------------------
    -- Clock and reset
    ----------------------------
    clk                : in  std_logic;       -- 60 MHz
    reset_n            : in  std_logic;
    sync_reset_n       : in  std_logic;       -- synchronous reset from AGC/CCA
    ----------------------------
    -- Tx/Rx selection
    ----------------------------
    tx_rx_select       : in  std_logic;       -- 1 -> Tx 
    ----------------------------                 0 -> Rx
    -- Filter bypass
    ----------------------------
    filtbyp_tx_i       : in  std_logic;       -- 1 -> bypass the filter for Tx
    ----------------------------
    -- I & Q for Rx
    ----------------------------    
    -- From dc_offset (60 MS/s)
    rx_filter_in_i     : in  std_logic_vector(size_in_rx_g-1 downto 0);
    rx_filter_in_q     : in  std_logic_vector(size_in_rx_g-1 downto 0);
    -- To Rx path (20 MS/s)
    rx_filter_out_i    : out std_logic_vector(size_out_rx_g-1 downto 0);
    rx_filter_out_q    : out std_logic_vector(size_out_rx_g-1 downto 0);
    ----------------------------
    -- I & Q for Tx
    ----------------------------
    -- From Tx path (20 MS/s)
    tx_filter_in_i     : in  std_logic_vector(size_in_tx_g-1 downto 0);
    tx_filter_in_q     : in  std_logic_vector(size_in_tx_g-1 downto 0);
    -- To iq_compensation (60 MS/s)
    tx_filter_out_i    : out std_logic_vector(size_out_tx_g-1 downto 0);
    tx_filter_out_q    : out std_logic_vector(size_out_tx_g-1 downto 0);
    ----------------------------
    -- Sampling ready command
    ----------------------------
    start_of_burst_i   : in  std_logic;  -- start of burst
    sample_ready_tx_i  : in  std_logic;  -- toggle from Tx path
    --
    sample_ready_rx_o  : out std_logic;  -- pulse for rx
    sample_toggle_rx_o : out std_logic;  -- toggle for rx
    ----------------------------
    -- Normalization factor
    ----------------------------
    txnorm_i           : in  std_logic_vector(7 downto 0);
    ------------------------------------------------
    -- DC offset pre-estimation
    ------------------------------------------------
    sel_dc_mode        : in std_logic;
    --
    dc_pre_estim_i     : out std_logic_vector(10 downto 0);
    dc_pre_estim_q     : out std_logic_vector(10 downto 0);
    dc_pre_estim_valid : out std_logic;
    --
    dc_pre_estim_4_agc_i : out std_logic_vector(10 downto 0);
    dc_pre_estim_4_agc_q : out std_logic_vector(10 downto 0)
    );

end tx_rx_filter;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of tx_rx_filter is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
 
  -- I & Q before Core front-end filter
  signal core_input_i : std_logic_vector(size_core_in_g-1 downto 0);
  signal core_input_q : std_logic_vector(size_core_in_g-1 downto 0);
  
  -- I & Q after Core front-end filter
  signal core_output_i : std_logic_vector(size_core_out_g-1 downto 0);
  signal core_output_q : std_logic_vector(size_core_out_g-1 downto 0);
  
  -- Clear core during transition Tx -> Rx or Rx -> Tx or sync_reset_n active
  signal clear_core    : std_logic;
  
  -- Dc Offset pre-estimation valid (seq)
  signal dc_pre_estim_valid_int : std_logic;
  signal tx_active              : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- Control filter instanciation
  -----------------------------------------------------------------------------
  control_filter_1 : control_filter
  generic map ( 
    size_in_tx_g     => size_in_tx_g,      -- I & Q size for Tx input
    size_out_tx_g    => size_out_tx_g,     -- I & Q size for Tx output
    size_in_rx_g     => size_in_rx_g,      -- I & Q size for Tx input
    size_out_rx_g    => size_out_rx_g,     -- I & Q size for Rx output
    size_core_in_g   => size_core_in_g,    -- size for Core front-end input
    size_core_out_g  => size_core_out_g,   -- size for Core front-end output
--    use_sync_reset_g => use_sync_reset_g   -- use of synchronous reset
    use_sync_reset_g => use_sync_reset_g   -- use of synchronous reset
    )
  port map(
    -- Clock and reset
    clk                => clk,
    reset_n            => reset_n,
    sync_reset_n       => sync_reset_n,
    -- Tx/Rx selection
    tx_rx_select       => tx_rx_select,
    -- Filter bypass
    filtbyp_tx_i       => filtbyp_tx_i,
    -- Rx
    -- From dc_offset : 60 MS/s
    rx_filter_in_i     => rx_filter_in_i,
    rx_filter_in_q     => rx_filter_in_q,
    -- To Rx path : 20 MS/s
    rx_filter_out_i    => rx_filter_out_i,
    rx_filter_out_q    => rx_filter_out_q,
    -- Tx
    -- From Tx path : 20 MS/s
    tx_filter_in_i     => tx_filter_in_i,
    tx_filter_in_q     => tx_filter_in_q,
    -- To iq_compensation : 60 MS/s
    tx_filter_out_i    => tx_filter_out_i,
    tx_filter_out_q    => tx_filter_out_q,
    -- Sampling ready command
    start_of_burst_i   => start_of_burst_i,
    sample_ready_tx_i  => sample_ready_tx_i,
    --
    sample_ready_rx_o  => sample_ready_rx_o,
    sample_toggle_rx_o => sample_toggle_rx_o,
    -- Normalization factor
    txnorm_i           => txnorm_i,
    -- Core interface
    data_filtered_i    => core_output_i,
    data_filtered_q    => core_output_q,
    --
    data2core_i        => core_input_i,
    data2core_q        => core_input_q,
    --
    clear_core         => clear_core,
    tx_active          => tx_active,
    -- DC Offset pre-estimation
    dc_pre_estim_valid => dc_pre_estim_valid_int
    );

  -- DC Offset pre-estimation ouput valid
  dc_pre_estim_valid <= dc_pre_estim_valid_int;

  -----------------------------------------------------------------------------
  -- Core filter instanciations I & Q
  -----------------------------------------------------------------------------
  -----------
  -- I
  -----------
  core_filter_i_1 : core_filter
  generic map ( 
    size_in_g        => size_core_in_g,   -- size for Core front-end input
    size_out_g       => size_core_out_g,  -- size for Core front-end output
--    use_sync_reset_g => use_sync_reset_g  -- use of synchronous reset
    use_sync_reset_g => use_sync_reset_g  -- use of synchronous reset
    )
  port map(
    clk                => clk,
    reset_n            => reset_n,
    -- Filter
    clear_buffer       => clear_core,
    fil_buf_i          => core_input_i,
    add_stage_o        => core_output_i,
    -- DC Offset pre-estimation
    tx_active          => tx_active,
    sel_dc_mode        => sel_dc_mode,
    dc_pre_estim_valid => dc_pre_estim_valid_int,
    dc_pre_estim       => dc_pre_estim_i,
    dc_pre_estim_4_agc => dc_pre_estim_4_agc_i
    );
  
  -----------
  -- Q
  -----------
  core_filter_q_1 : core_filter
  generic map ( 
    size_in_g        => size_core_in_g,   -- size for Core front-end input
    size_out_g       => size_core_out_g,  -- size for Core front-end output
--    use_sync_reset_g => use_sync_reset_g  -- use of synchronous reset
    use_sync_reset_g => use_sync_reset_g  -- use of synchronous reset
    )
  port map(
    clk                => clk,
    reset_n            => reset_n,
    -- Filter
    clear_buffer       => clear_core,
    fil_buf_i          => core_input_q,
    add_stage_o        => core_output_q,
    -- DC Offset pre-estimation
    tx_active          => tx_active,
    sel_dc_mode        => sel_dc_mode,
    dc_pre_estim_valid => dc_pre_estim_valid_int,
    dc_pre_estim       => dc_pre_estim_q,
    dc_pre_estim_4_agc => dc_pre_estim_4_agc_q
    );
  

end RTL;
