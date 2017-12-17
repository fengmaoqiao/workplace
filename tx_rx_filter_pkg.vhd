
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: tx_rx_filter_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.15   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rx_filter.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/tx_rx_filter/vhdl/rtl/tx_rx_filter_pkg.vhd,v  
--  Log: tx_rx_filter_pkg.vhd,v  
-- Revision 1.15  2005/01/18 13:13:27  Dr.C
-- #BugId:960#
-- Added dc_pre_estim_4_agc outputs and reduce dc_pre_estim to 11-bit.
--
-- Revision 1.14  2004/10/27 14:15:43  Dr.C
-- #BugId:799#
-- Added dc pre-estimation calculation.
--
-- Revision 1.13  2004/05/13 14:48:09  Dr.C
-- Added use_sync_reset_g generic.
--
-- Revision 1.12  2004/04/07 13:44:44  Dr.C
-- Updated.
--
-- Revision 1.11  2003/12/03 12:09:09  Dr.C
-- Updated.
--
-- Revision 1.10  2003/10/27 11:28:35  Dr.C
-- Added sync_reset_n.
--
-- Revision 1.9  2003/09/15 16:40:55  Dr.C
-- Added a toggle for Rx output.
--
-- Revision 1.8  2003/08/29 16:12:39  Dr.C
-- Added clear_buffer input.
--
-- Revision 1.7  2003/07/02 13:28:48  Dr.C
-- Updated core_filter and filter.
--
-- Revision 1.6  2003/06/11 09:27:05  Dr.C
-- Removed last version.
--
-- Revision 1.5  2003/06/04 15:06:25  Dr.C
-- Updated with modifications of generics.
--
-- Revision 1.4  2003/03/31 07:44:16  Dr.C
-- Updated with by pass inputs.
--
-- Revision 1.3  2003/03/26 14:53:08  Dr.C
-- Updated.
--
-- Revision 1.2  2003/03/24 09:52:45  Dr.C
-- Updated txnorm.
--
-- Revision 1.1  2003/03/17 15:33:35  Dr.C
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
package tx_rx_filter_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: core_filter.vhd
----------------------
  component core_filter
  generic (
    size_in_g        : integer := 10; -- Size of Core filter input
    size_out_g       : integer := 15; -- Size of Core filter output
    --
--    use_sync_reset_g : integer := 1   -- when 1 clear_buffer input is used
    use_sync_reset_g : integer := 1   -- when 1 clear_buffer input is used
    );                                -- else the reset_n input must be separately
  port (                              -- controlled by the reset controller
    ------------------------------------------------
    -- Clock and reset
    ------------------------------------------------
    clk          : in std_logic;       -- 60 Mhz
    reset_n      : in std_logic;
        
    ------------------------------------------------
    -- Clear buffer during transition Tx/Rx or Rx/Tx
    ------------------------------------------------
    clear_buffer : in std_logic;
    
    ------------------------------------------------
    -- Filter buffer input
    ------------------------------------------------
    fil_buf_i    : in std_logic_vector(size_in_g-1 downto 0);

    ------------------------------------------------
    -- Addition stage output with saturation
    ------------------------------------------------
    add_stage_o  : out std_logic_vector(size_out_g-1 downto 0);
    
    ------------------------------------------------
    -- DC offset pre-estimation
    ------------------------------------------------
    sel_dc_mode        : in std_logic;
    dc_pre_estim_valid : in std_logic;
    tx_active          : in std_logic; -- stop dc pre-estimation when tx active
    --
    dc_pre_estim       : out std_logic_vector(10 downto 0);
    dc_pre_estim_4_agc : out std_logic_vector(10 downto 0)
    );

  end component;


----------------------
-- File: control_filter.vhd
----------------------
  component control_filter
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
    -- I & Q for Rx (decimation)
    ----------------------------    
    -- From dc_offset (60 MS/s)
    rx_filter_in_i     : in  std_logic_vector(size_in_rx_g-1 downto 0);
    rx_filter_in_q     : in  std_logic_vector(size_in_rx_g-1 downto 0);
    -- To Rx path (20 MS/s)
    rx_filter_out_i    : out std_logic_vector(size_out_rx_g-1 downto 0);
    rx_filter_out_q    : out std_logic_vector(size_out_rx_g-1 downto 0);
    ----------------------------
    -- I & Q for Tx (interpolation)
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
    ----------------------------
    -- Core interface
    ----------------------------
    data_filtered_i    : in  std_logic_vector(size_core_out_g-1 downto 0);
    data_filtered_q    : in  std_logic_vector(size_core_out_g-1 downto 0);
    --
    data2core_i        : out std_logic_vector(size_core_in_g-1 downto 0);
    data2core_q        : out std_logic_vector(size_core_in_g-1 downto 0);
    --
    clear_core         : out std_logic;
    tx_active          : out std_logic;
    ----------------------------
    -- DC Offset pre-estimation control
    ----------------------------
    dc_pre_estim_valid : out std_logic
    );

  end component;


----------------------
-- File: tx_rx_filter.vhd
----------------------
  component tx_rx_filter
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

  end component;



 
end tx_rx_filter_pkg;
