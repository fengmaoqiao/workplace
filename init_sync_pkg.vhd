
  -------------------------------------------------------------------
  -- End of file
  -------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: init_sync_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.16  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for init_sync.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/init_sync/vhdl/rtl/init_sync_pkg.vhd,v  
--  Log: init_sync_pkg.vhd,v  
-- Revision 1.16  2004/12/20 08:57:14  Dr.C
-- #BugId:810#
-- Added ybnb port.
--
-- Revision 1.15  2004/12/14 17:19:00  Dr.C
-- #BugId:810#
-- Updated postprocessing port map.
--
-- Revision 1.14  2004/04/07 12:47:44  Dr.B
-- Changed generics type from boolean to integer.
--
-- Revision 1.13  2004/03/10 16:54:11  Dr.B
-- Updated GENERIC PORT of preprocessing:
--  - removed use_full_preprocessing_g.
--  - replaced by use_3correlators_g & use_autocorrelators_g..
--
-- Revision 1.12  2004/02/20 17:41:32  Dr.B
-- Updated preprocessing GENEIRC PORT with use_full_preprocessing_g.
--
-- Revision 1.11  2003/11/18 13:23:18  Dr.B
-- Updated port on carrier_detect: detthr_reg_i is 6 bits (was 4), new INPUT cs_accu_en.
--
-- Revision 1.10  2003/11/18 10:35:02  Dr.B
-- Added INPUT cs_accu_en, updated INPUT detthr_reg_i to 6 bits (was 4).
--
-- Revision 1.9  2003/11/07 08:56:26  Dr.B
-- Updated at0_o, at1_o & a16m_o port which were NOT updated automatically by vfe because of their generic definition.
--
-- Revision 1.8  2003/11/06 16:33:13  Dr.B
-- Updated port on preprocessing.
--
-- Revision 1.7  2003/11/03 08:32:12  Dr.B
-- Added OUTPUT fast_99carrier_s_o to carrier_detect.vhd, used in 11g AGC procedure.
--
-- Revision 1.6  2003/10/15 09:52:06  Dr.C
-- Updated tops.
--
-- Revision 1.5  2003/07/29 09:38:51  Dr.C
-- Added cp2_detected output
--
-- Revision 1.4  2003/06/25 17:15:09  Dr.B
-- new link between pre and post processing.
--
-- Revision 1.3  2003/04/04 16:30:05  Dr.B
-- shift_param_gen added.
--
-- Revision 1.2  2003/03/31 08:36:34  Dr.B
-- read_enable = '1' removed.
--
-- Revision 1.1  2003/03/27 17:06:20  Dr.B
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
package init_sync_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- Source: Good
----------------------
  component preprocessing
  generic (
    size_n_g                  : integer := 11;
    size_rem_corr_g           : integer := 4;    -- nb of bits removed for correlation calc
--    use_3correlators_g        : integer range 0 to 1:= 1; -- When 1 the "3" correlators are generated.
    use_3correlators_g        : integer range 0 to 1:= 1; -- When 1 the "3" correlators are generated.
--    use_autocorrelators_g     : integer range 0 to 1:= 1  -- When 1 the auto-correlators are generated.
    use_autocorrelators_g     : integer range 0 to 1:= 1  -- When 1 the auto-correlators are generated.
    );                                          
    
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                    : in std_logic;
    reset_n                : in std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i                 : in std_logic;
    -- Data Input
    i_i                    : in std_logic_vector (10 downto 0);
    q_i                    : in std_logic_vector (10 downto 0);
    data_valid_i           : in std_logic;
    dc_offset_4_corr_i_i   : in std_logic_vector (11 downto 0);-- NEW (rev 1.4)
    dc_offset_4_corr_q_i   : in std_logic_vector (11 downto 0);-- NEW (rev 1.4)
    autocorr_enable_i      : in std_logic; -- from AGC, enable autocorr calc when high
    -- *** CALCULATION PARAMETERS *** 
    -- autocorrelation threshold (from register)
    autothr0_i             : in std_logic_vector (5 downto 0);
    autothr1_i             : in std_logic_vector (5 downto 0);
    -- *** Interface with Mem (write port + control) ***
    mem_o                  : out std_logic_vector (2*(size_n_g-size_rem_corr_g+5-2)-1 downto 0);
    wr_ptr_o               : out std_logic_vector(6 downto 0);
    write_enable_o         : out std_logic;
    -- XB (from B-correlator)
    xb_re_o                : out std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
    xb_im_o                : out std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
    xb_data_valid_o        : out std_logic;
    -- XC1 (from CP1-correlator)
    xc1_re_o               : out std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
    xc1_im_o               : out std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
    -- AT threshold 
    at0_o                  : out std_logic_vector (13 downto 0);-- NEW (rev 1.4): was (12 downto 0)! 
    at1_o                  : out std_logic_vector (13 downto 0);-- NEW (rev 1.4): was (12 downto 0)!
    -- Y data (from CP1/CP2-correlator)
    yc1_o                  : out std_logic_vector (size_n_g-size_rem_corr_g+5-2-1 downto 0);
    yc2_o                  : out std_logic_vector (size_n_g-size_rem_corr_g+5-2-1 downto 0);
    -- Auto-correlation outputs
    a16_m_o                : out std_logic_vector (13 downto 0);-- NEW (rev 1.4): was (12 downto 0)!
    a16_data_valid_o       : out std_logic;
    -- Stat register
    ybnb_o                 : out std_logic_vector(6 downto 0)
    );
    
    
  end component;


----------------------
-- Source: Good
----------------------
  component postprocessing
  generic (
    xb_size_g : integer := 10);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in  std_logic;
    reset_n             : in  std_logic;
    init_i              : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    -- XB from B Correlator
    xb_data_valid_i     : in  std_logic;                      -- xb available
    xb_re_i             : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb real part
    xb_im_i             : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb im part
    -- XC1 from CP1 Correlator
    xc1_re_i            : in  std_logic_vector (xb_size_g-1 downto 0);
    xc1_im_i            : in  std_logic_vector (xb_size_g-1 downto 0);
    -- YC1 - YC2 - Mag from Correlator (yc_data_valid = xc_data_valid)
    yc1_i               : in  std_logic_vector (xb_size_g-1 downto 0);
    yc2_i               : in  std_logic_vector (xb_size_g-1 downto 0);
    -- Memory Interface
    xb_from_mem_re_i    : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb stored in mem
    xb_from_mem_im_i    : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb stored in mem
    wr_ptr_i            : in  std_logic_vector(6 downto 0);
    mem_wr_enable_i     : in  std_logic;
    --
    rd_ptr1_o           : out std_logic_vector (6 downto 0);
    read_enable_o       : out std_logic;
    --
    cf_inc_o            : out std_logic_vector (23 downto 0);
    cf_inc_data_valid_o : out std_logic;
    --
    cp2_detected_o      : out std_logic;
    preamb_detect_o     : out std_logic;
    -- Internal signal for debug
    yb_o                : out std_logic_vector(3 downto 0);
    peak_position_o     : out std_logic_vector(3 downto 0)
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/packages/commonlib/vhdl/rtl/mdm_math_func_pkg.vhd
----------------------
-- No entity declaration


----------------------
-- File: shift_param_gen.vhd
----------------------
  component shift_param_gen
  generic (
    data_size_g : integer := 11);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in std_logic;
    reset_n             : in std_logic;

    --------------------------------------
    -- Signals
    --------------------------------------
    init_i              : in std_logic;
    cp2_detected_i      : in std_logic;
    -- Data Input
    i_i                 : in std_logic_vector (10 downto 0);
    q_i                 : in std_logic_vector (10 downto 0);
    data_valid_i        : in std_logic;
    -- Shift Parameter : nb of LSB to remove
    shift_param_o       : out std_logic_vector(2 downto 0)
    
    
  );

  end component;


----------------------
-- File: carrier_detect.vhd
----------------------
  component carrier_detect
  generic (
    data_size_g : integer := 13 );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in  std_logic;
    reset_n             : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    -- Control Signals
    init_i               : in  std_logic;
    autocorr_enable_i    : in  std_logic;
    a16m_data_valid_i    : in  std_logic; -- a16m valid
    cs_accu_en           : in  std_logic;--NEW rev. 1.4
    -- Level estimation signals
    at0_i                : in  std_logic_vector (data_size_g-1 downto 0);
    at1_i                : in  std_logic_vector (data_size_g-1 downto 0);
    -- Autocorrelation signal
    a16m_i               : in  std_logic_vector (data_size_g-1 downto 0);
    -- treshold of accu (from registers)
    detthr_reg_i         : in  std_logic_vector (5 downto 0);--NEW rev. 1.4 - was (3 downto 0)
    --
    -- Fast Carrier Sense
    fast_carrier_s_o     : out std_logic; -- pulse
    fast_99carrier_s_o   : out std_logic; -- pulse    
    -- Carrier Sense
    carrier_s_o          : out std_logic -- remain high until init_i    
  );

  end component;


----------------------
-- File: init_sync.vhd
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



 
end init_sync_pkg;
