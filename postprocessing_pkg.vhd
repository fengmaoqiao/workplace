
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: postprocessing_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.9  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for postprocessing.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/postprocessing/vhdl/rtl/postprocessing_pkg.vhd,v  
--  Log: postprocessing_pkg.vhd,v  
-- Revision 1.9  2004/12/14 17:40:50  Dr.C
-- #BugId:810#
-- Added peak_position debug output.
--
-- Revision 1.8  2003/12/23 10:18:00  Dr.B
-- peak_search : 1 generic added.
--
-- Revision 1.7  2003/10/15 09:24:27  Dr.C
-- Updated top.
--
-- Revision 1.6  2003/08/01 14:54:18  Dr.B
-- changes for new metrics calc,
-- ,
--
-- Revision 1.5  2003/06/27 16:42:28  Dr.B
-- change su size.
--
-- Revision 1.4  2003/06/25 17:12:48  Dr.B
-- no output to preprocessing anymore.
--
-- Revision 1.3  2003/04/11 08:55:52  Dr.B
-- read_enable gen by phase comp.
--
-- Revision 1.2  2003/04/04 16:26:09  Dr.B
-- cordic_vect changes (scaling_g).
--
-- Revision 1.1  2003/03/27 16:59:05  Dr.B
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
package postprocessing_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/cordic_vect/vhdl/rtl/cordic_vect.vhd
----------------------
  component cordic_vect
  generic (
    datasize_g    : integer := 10; -- Data size. Max value is 30.
    errorsize_g   : integer := 10; -- Data size. Max value is 30.
    scaling_g     : integer := 0   -- 1:Use all the amplitude of angle_out
                                        --  pi/2 =^=  2^errosize_g =~ 01111... 
  );                                    -- -pi/2 =^= -2^errosize_g =  100000.. 
  port (
    -- clock and reset.
    clk          : in  std_logic;                   
    reset_n      : in  std_logic;    
    --
    load         : in  std_logic; -- Load input values.
    x_in         : in  std_logic_vector(datasize_g-1 downto 0); -- Real part in.
    y_in         : in  std_logic_vector(datasize_g-1 downto 0); -- Imaginary part.
    --
    angle_out    : out std_logic_vector(errorsize_g-1 downto 0); -- Angle out.
    cordic_ready : out std_logic                             -- Angle ready.
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/preprocessing/vhdl/rtl/magnitude_gen.vhd
----------------------
  component magnitude_gen
  generic (
    size_in_g : integer := 16);
  port (
    --------------------------------------
    -- Signals
    --------------------------------------
    data_in_i : in  std_logic_vector(size_in_g -1 downto 0);
    data_in_q : in  std_logic_vector(size_in_g -1 downto 0);
    --
    mag_out  : out std_logic_vector(size_in_g -1 downto 0)
    
  );

  end component;


----------------------
-- File: peak_search.vhd
----------------------
  component peak_search
  generic (
    yb_size_g : integer := 9;
    yb_max_g  : integer := 4);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic;
    reset_n              : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i               : in  std_logic;  -- initialize registers
    enable_peak_search_i : in  std_logic;  -- enable block (no search when dis)
    yb_data_valid_i      : in  std_logic;  -- yb available
    yb_i                 : in  std_logic_vector (yb_size_g-1 downto 0);  -- magnitude xb
    yb_counter_i         : in  std_logic_vector(6 downto 0);-- 16 counter 
    --
    peak_position_o      : out std_logic_vector (3 downto 0);  -- position of peak mod 16
    f_position_o         : out std_logic;   -- high when counter = F (reg)
    expected_peak_o      : out std_logic;   -- high when a next peak should occur (according to memorize peak)
    current_peak_o       : out std_logic    -- high when a peak occurs (according to present peak)
  );

  end component;


----------------------
-- File: phase_computation.vhd
----------------------
  component phase_computation
  generic (
    xb_size_g      : integer := 10);-- size of xb
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk              : in  std_logic;
    reset_n          : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i           : in  std_logic;   -- initialize registers
    -- Peak Position
    peak_position_i  : in  std_logic_vector (3 downto 0);  -- position of peak mod 16
    f_position_i     : in  std_logic;   -- start to get the prev peaks
    -- Memory Interface
    mem_wr_ptr_i     : in  std_logic_vector (6 downto 0);  -- wr_ptr of shared fifo
    mem_wr_enable_i  : in  std_logic;
    xb_from_mem_re_i : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb stored in mem
    xb_from_mem_im_i : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb stored in mem
    -- CP2 info
    cp2_detected_i   : in  std_logic; -- high (and remain high when cp2 is detected
    -- xc1 calculated
    xc1_data_valid_i : in  std_logic;
    xc1_re_i         : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb dir calculated
    xc1_im_i         : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb dir calculated
    --
    -- XP Buffer
    xp_valid_o       : out std_logic;
    xp_buf0_o        : out std_logic_vector (xb_size_g+2 downto 0);  
    xp_buf1_o        : out std_logic_vector (xb_size_g+2 downto 0);  
    xp_buf2_o        : out std_logic_vector (xb_size_g+2 downto 0);   
    xp_buf3_o        : out std_logic_vector (xb_size_g+2 downto 0);
    nb_xp_to_take_o  : out std_logic; -- '0' for 3 and '1' for 4
    -- Memory Rd Pointer
    read_enable_o    : out std_logic;
    mem_rd_ptr_o      : out std_logic_vector (6 downto 0)  -- rd_ptr of shared fifo
    
  );

  end component;


----------------------
-- File: coarse_freq_sync.vhd
----------------------
  component coarse_freq_sync
  generic (
    xp_size_g : integer := 13);         -- xp size
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk     : in std_logic;
    reset_n : in std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i              : in std_logic;  -- when high reset registers
    -- XP Buffer
    xp_valid_i       : in  std_logic;
    xp_buf0_i        : in  std_logic_vector (xp_size_g-1 downto 0);  
    xp_buf1_i        : in  std_logic_vector (xp_size_g-1 downto 0);  
    xp_buf2_i        : in  std_logic_vector (xp_size_g-1 downto 0);   
    xp_buf3_i        : in  std_logic_vector (xp_size_g-1 downto 0);
    nb_xp_to_take_i  : in  std_logic; -- nb xp to take into account '0' for 3 and '1' for 4
    
    -- Coarse Frequency Correction Increment
    su_o             : out std_logic_vector (xp_size_g+3 downto 0);
    su_data_valid_o  : out std_logic
    );

  end component;


----------------------
-- File: max_decision.vhd
----------------------
  component max_decision
  generic (
    yb_size_g : integer := 10);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic;  -- ofdm clock (80 MHz)   
    reset_n              : in  std_logic;  -- asynchronous negative reset
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i               : in  std_logic;  -- synchronous negative reset
    f_position_i         : in  std_logic;  -- when high yb_memo => yb_old
    current_peak_i       : in  std_logic;  -- used for y_old calculation
    expected_peak_i      : in  std_logic;  -- begin decision metrics and maximum search
    -- current (n) yb, yci, yt
    yb_data_valid_i      : in  std_logic;  -- xb available   
    yb_i                 : in  std_logic_vector (yb_size_g-1 downto 0);
    yc1_i                : in  std_logic_vector (yb_size_g-1 downto 0);
    yc2_i                : in  std_logic_vector (yb_size_g-1 downto 0);
    -- Timing decision metrics and maximum search outputs (flags + their valid)
    cp2_detected_o       : out std_logic;
    cp2_detected_pulse_o : out std_logic);

  end component;


----------------------
-- File: phase_slope_comput.vhd
----------------------
  component phase_slope_comput
  generic (
    xd_size_g : integer := 13);         -- xp size  
  port (
    --------------------------------------
    -- Clocks & Reset; 
    --------------------------------------
    clk                 : in  std_logic;
    reset_n             : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    m_factor_i          : in  std_logic; -- (3 or 4)
    enable_slope_comp_i : in  std_logic;
    xd_buffer0_i        : in  std_logic_vector(xd_size_g-1 downto 0);
    xd_buffer1_i        : in  std_logic_vector(xd_size_g-1 downto 0);
    --
    su_o                : out std_logic_vector(xd_size_g-2 downto 0)
  );

  end component;


----------------------
-- File: postprocessing.vhd
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



 
end postprocessing_pkg;
