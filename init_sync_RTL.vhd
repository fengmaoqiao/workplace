
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: init_sync.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.15  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Init Sync Top Level Block - Include Preprocessing
-- and Postprocessing
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/init_sync/vhdl/rtl/init_sync.vhd,v  
--  Log: init_sync.vhd,v  
-- Revision 1.15  2004/12/20 08:57:10  Dr.C
-- #BugId:810#
-- Added ybnb port.
--
-- Revision 1.14  2004/12/14 17:18:55  Dr.C
-- #BugId:810#
-- Updated postprocessing port map.
--
-- Revision 1.13  2004/04/07 12:47:58  Dr.B
-- Changed generics type from boolean to integer.
--
-- Revision 1.12  2004/03/10 16:54:42  Dr.B
-- Updated GENERIC PORT of preprocessing:
--  - removed use_full_preprocessing_g.
--  - replaced by use_3correlators_g & use_autocorrelators_g..
--
-- Revision 1.11  2004/02/20 17:43:17  Dr.B
-- Updated preprocessing GENEIRC PORT with use_full_preprocessing_g.
--
-- Revision 1.10  2003/11/18 13:23:49  Dr.B
-- Updated port on carrier_detect: detthr_reg_i is 6 bits (was 4), new INPUT cs_accu_en.
--
-- Revision 1.9  2003/11/06 16:30:53  Dr.B
-- Updated ports on preprocessing and data_size_g (now 14) on carrier_detect.
--
-- Revision 1.8  2003/11/03 08:33:56  Dr.B
-- Added OUTPUT fast_99carrier_s_o to carrier_detect.vhd, used in 11g AGC procedure.
--
-- Revision 1.7  2003/10/15 09:51:46  Dr.C
-- Added yb_o.
--
-- Revision 1.6  2003/08/01 15:06:18  Dr.B
-- comments added.
--
-- Revision 1.5  2003/07/29 09:38:35  Dr.C
-- Added cp2_detected output
--
-- Revision 1.4  2003/06/25 17:14:18  Dr.B
-- new links between pre and post processing.
-- ..
--
-- Revision 1.3  2003/04/04 16:29:53  Dr.B
-- shift_param_gen added.
--
-- Revision 1.2  2003/03/31 08:36:20  Dr.B
-- read_enable = '1' removed.
--
-- Revision 1.1  2003/03/27 17:06:11  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--library preprocessing_rtl;
library work;
 
--library postprocessing_rtl;
library work;

--library init_sync_rtl;
library work;
--use init_sync_rtl.init_sync_pkg.all;
use work.init_sync_pkg.all;
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity init_sync is
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

end init_sync;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of init_sync is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- XC1
  signal xc1_re         : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
  signal xc1_im         : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
  --XB
  signal xb_re          : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
  signal xb_im          : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
  signal xb_data_valid  : std_logic;
  -- write access
  signal wr_ptr         : std_logic_vector(6 downto 0);
  signal write_enable   : std_logic;
  -- YR
  signal yr             : std_logic_vector (9 downto 0);
  signal yr_data_valid  : std_logic;
  -- AT
  signal at1            : std_logic_vector (13 downto 0); --NEW (ver 1.9). Was (12 downto 0)
  signal at0            : std_logic_vector (13 downto 0); --NEW (ver 1.9). Was (12 downto 0)
  --A16M
  signal a16_m          : std_logic_vector (13 downto 0); --NEW (ver 1.9). Was (12 downto 0)
  signal a16_data_valid : std_logic;
  -- YC1 - YC2
  signal yc1            : std_logic_vector (size_n_g-size_rem_corr_g+5-2-1 downto 0);
  signal yc2            : std_logic_vector (size_n_g-size_rem_corr_g+5-2-1 downto 0);
  -- Control Signals
  signal init           : std_logic;
  signal init_preproc   : std_logic;

  signal calc_cp       : std_logic;
  signal cp2_detected  : std_logic;
  signal preamb_detect : std_logic;

  signal dc_offset_4_corr_i   : std_logic_vector (11 downto 0); --NEW (ver 1.9)
  signal dc_offset_4_corr_q   : std_logic_vector (11 downto 0); --NEW (ver 1.9)
  
  signal detthr_reg_int       : std_logic_vector(5 downto 0);  --NEW (ver 1.10)
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  init         <= not sync_res_n;
  init_preproc <= not sync_res_n or cp2_detected; -- no need to continue when
                                                   -- cp2 detected

  -----------------------------------------------------------------------------
  -- Preprocessing Instantiation
  -----------------------------------------------------------------------------
  preprocessing_1 : preprocessing
  generic map(
    size_n_g                  => size_n_g,
    size_rem_corr_g           => size_rem_corr_g,-- nb of bits removed for correlation calc
--    use_3correlators_g        => 1,
    use_3correlators_g        => 1,
--    use_autocorrelators_g     => 0)
    use_autocorrelators_g     => 0)
    
    port map(
      clk                  => clk,
      reset_n              => reset_n,
      init_i               => init_preproc,
      -- interface with dezfilter
      i_i                  => i_i,
      q_i                  => q_i,
      data_valid_i         => data_valid_i,
      dc_offset_4_corr_i_i => dc_offset_4_corr_i, -- NEW (rev 1.9)
      dc_offset_4_corr_q_i => dc_offset_4_corr_q, -- NEW (rev 1.9)     
      autocorr_enable_i    => autocorr_enable_i,
      -- autocorrelation threshold 
      autothr0_i           => autothr0_i,
      autothr1_i           => autothr1_i,
      -- interface with Mem (write port + control)
      mem_o                => mem_o,
      wr_ptr_o             => wr_ptr,
      write_enable_o       => write_enable,
      -- XB (from CP1-correlator)
      xb_re_o              => xb_re,
      xb_im_o              => xb_im,
      xb_data_valid_o      => xb_data_valid,
      -- XC1 (from CP1-correlator)
      xc1_re_o             => xc1_re,
      xc1_im_o             => xc1_im,
      -- Y threshold 
      at0_o                => at0,
      at1_o                => at1,
      -- Y data (from CP1/CP2-correlator)
      yc1_o                => yc1,
      yc2_o                => yc2,
      -- Auto-correlation outputs
      a16_m_o              => a16_m,
      a16_data_valid_o     => a16_data_valid,
      -- Stat register
      ybnb_o               => ybnb_o
      );

  dc_offset_4_corr_i   <=(others=>'0');-- NEW (rev 1.9)
  dc_offset_4_corr_q   <=(others=>'0');-- NEW (rev 1.9)

  -----------------------------------------------------------------------------
  -- Postprocessing Instantiation
  -----------------------------------------------------------------------------

  postprocessing_1 : postprocessing
  generic map (
    xb_size_g => (size_n_g-size_rem_corr_g + 3))
  port map(
    -- ofdm clock (80 MHz)
    clk                 => clk,
    -- asynchronous negative reset
    reset_n             => reset_n,
    -- synchronous negative reset
    init_i              => init,
    xb_data_valid_i     => xb_data_valid,
    xb_re_i             => xb_re,
    xb_im_i             => xb_im,
    xc1_re_i            => xc1_re,
    xc1_im_i            => xc1_im,
    yc1_i               => yc1,
    yc2_i               => yc2,
    -- Memory Interface
    xb_from_mem_re_i    => mem1_i (2*(size_n_g-size_rem_corr_g + 3)-1 downto size_n_g-size_rem_corr_g + 3),
    xb_from_mem_im_i    => mem1_i (size_n_g-size_rem_corr_g + 3-1 downto 0),
    wr_ptr_i            => wr_ptr,
    mem_wr_enable_i     => write_enable,
    rd_ptr1_o           => rd_ptr1_o,
    read_enable_o       => read_enable_o,
    -- coarse frequency correction increment
    cf_inc_o            => cf_inc_o,
    cf_inc_data_valid_o => cf_inc_data_valid_o,
    -- Preamble Detected
    cp2_detected_o      => cp2_detected,
    preamb_detect_o     => preamb_detect,
    -- Internal signal for debug
    yb_o                => yb_o,
    peak_position_o     => open
    );

  -----------------------------------------------------------------------------
  -- Shift Parameter Instantiation
  -----------------------------------------------------------------------------
  shift_param_gen_1: shift_param_gen
    generic map (
      data_size_g => 11)
    port map (
      clk            => clk,
      reset_n        => reset_n,
      --
      init_i         => init_preproc,
      cp2_detected_i => preamb_detect,
      i_i            => i_i,
      q_i            => q_i,
      data_valid_i   => data_valid_i,
      --
      shift_param_o  => shift_param_o);

  -----------------------------------------------------------------------------
  -- Carrier Sense Detection Instantiation
  -----------------------------------------------------------------------------
  -- * detthr_reg_i INPUT of carrier_detect  is now 6 bits (requirement of
  --   modem g AGC procedure).
  --   !! TBC confirm for modem a2 !!
  --
  -- * cs_accu_en INPUT is a requirement of modem g AGC procedure.
  
  detthr_reg_int <= "00"&detthr_reg_i;
  
  carrier_detect_1: carrier_detect
    generic map (
      data_size_g => 14)-- NEW (ver 1.9). Was 13
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      init_i              => init_preproc,
      autocorr_enable_i   => autocorr_enable_i,
      a16m_data_valid_i   => a16_data_valid,
      cs_accu_en          => autocorr_enable_i,
      at0_i               => at0,
      at1_i               => at1,
      a16m_i              => a16_m,
      detthr_reg_i        => detthr_reg_int,
      fast_carrier_s_o    => fast_carrier_s_o,
      fast_99carrier_s_o  => open,-- Signal used for 11g AGC procedure      
      carrier_s_o         => carrier_s_o);
    

  -----------------------------------------------------------------------------
  -- Output Linking
  -----------------------------------------------------------------------------
  wr_ptr_o            <= wr_ptr;
  write_enable_o      <= write_enable;
  preamb_detect_o     <= preamb_detect;
  cp2_detected_o      <= cp2_detected;

end RTL;
