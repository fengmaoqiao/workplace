
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_equ_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.4  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rx_equ.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_equ/vhdl/rtl/rx_equ_pkg.vhd,v  
--  Log: rx_equ_pkg.vhd,v  
-- Revision 1.4  2003/05/19 07:16:24  Dr.F
-- port map changed.
--
-- Revision 1.3  2003/03/28 15:53:39  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.2  2003/03/17 17:07:26  Dr.F
-- removed debug signals.
--
-- Revision 1.1  2003/03/17 10:01:38  Dr.F
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
package rx_equ_pkg is

  constant EQU_SYMB_LENGTH_CT : integer := 48; -- symbol lenght


  -- internal
  constant LENGTH_MANTISSE_CT    : integer := 9;  -- Despite of its name this parameter is no more 
						 -- equal to the length mantissa without sign. 
						 -- Anyway,  LENGTH_MANTISSE_CT is still an useful parameter 
						 -- for internal computation (sofbit) 

						 -- The real internal length mantissa of CorManI and CorManR is
					   -- now equal to LENGTH_MANTISSE_CT + 1 (see below MANTLEN_CT)
							

  constant MANTLEN_CT            : integer := LENGTH_MANTISSE_CT + 1;  -- Lenght mantissa without sign

  constant MAX_SOFTBIT_CT       : integer := 15 ;    -- max value of soft_bit
  constant MIN_SOFTBIT_CT       : integer := -15 ;   -- min value of soft_bit

  constant CORMAN_PROD_WIDTH_CT : integer := (FFT_WIDTH_CT + CHMEM_WIDTH_CT -4); 
  constant HPOWMAN_PROD_WIDTH_CT: integer := (FFT_WIDTH_CT + CHMEM_WIDTH_CT -4)-1;
           --hpowman_prod is unsigned, then it is a bit shorter than corman_prod

  constant MAX_HPOWEXP_CT  : integer := HPOWMAN_PROD_WIDTH_CT - LENGTH_MANTISSE_CT; -- 10

  constant HPOWEXP_WIDTH_CT: integer := 4;
           -- BE CAREFUL! It has to be: 2**HPOWEXP_WIDTH_CT -1 >= MAX_HPOWEXP_CT

  constant MAX_HISTEXPZ_CT : integer := (HPOWMAN_PROD_WIDTH_CT -1);
  constant HISTEXPZ_WIDTH_CT : integer := 5;
           -- BE CAREFUL! It has to be: 2**HISTEXPZ_WIDTH_CT -1 >= MAX_HISTEXPZ_CT

  constant MAX_SHIFT_SOFT_CT    : integer :=  4 + LENGTH_MANTISSE_CT - 5; -- 8

  constant SHIFT_SOFT_WIDTH_CT  : integer :=  4;
           -- BE CAREFUL! It has to be: 2**shift_soft_width_c -1 >= max_shift_soft_c

  constant S1_QAM16_CT          :integer := 162;
  constant S1_QAM64_CT          :integer := 158;

  type SUM_T         is array (HPOWMAN_PROD_WIDTH_CT-1 downto 1) of integer range 0 to EQU_SYMB_LENGTH_CT;

                                                             -- array 18 downto 1 of integer 0 to 48
  --for ctr_input_t
  constant DEFAULT_INPUT_CT	:std_logic_vector (1 downto 0) := "00";
  constant SAVED_CHMEM_CT	:std_logic_vector (1 downto 0) := "01";
  constant SAVED_DATA_CT		:std_logic_vector (1 downto 0) := "10";

  -- MinMantisse = -(2<<lengthmantisse)
  constant MAX_MANTISSE_CT: integer := 1023;
  constant MIN_MANTISSE_CT: integer := -1024;

  constant RATE_6_CT   :    std_logic_vector (3 downto 0) := "1011";
  constant RATE_9_CT   :    std_logic_vector (3 downto 0) := "1111";
  constant RATE_12_CT  :    std_logic_vector (3 downto 0) := "1010";
  constant RATE_18_CT  :    std_logic_vector (3 downto 0) := "1110";
  constant RATE_24_CT  :    std_logic_vector (3 downto 0) := "1001";
  constant RATE_36_CT  :    std_logic_vector (3 downto 0) := "1101";
  constant RATE_48_CT  :    std_logic_vector (3 downto 0) := "1000";
  constant RATE_54_CT  :    std_logic_vector (3 downto 0) := "1100";

  constant BURST_RATE_WIDTH_CT  :    integer := 4;
  constant QAM_LEFT_BOUND_CT  :    integer := 1;
  constant QAM_RIGHT_BOUND_CT :    integer := 0;

  --constant histoffset_width_c :    integer := 2;
  constant MAX_HISTOFFSET_CT   :  std_logic_vector(HISTOFFSET_WIDTH_CT -1 downto 0) := "10";
 
  constant PREAMBLE_CT      : std_logic_vector (1 downto 0) := "00";
  constant SIGNAL_FIELD_CT  : std_logic_vector (1 downto 0) := "01";
  constant DATA_FIELD_CT    : std_logic_vector (1 downto 0) := "10";

  constant CNT_RST_CT       : std_logic_vector (5 downto 0) := "000001";

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: rx_equ_instage0_corman.vhd
----------------------
  component rx_equ_instage0_corman
  generic (
    complex_part_g  : integer := 0 -- 0: real; 1: imaginary
  );
  port (
    clk             : in  std_logic; -- Clock input
    reset_n         : in  std_logic; -- Asynchronous negative reset
    module_enable_i : in  std_logic; -- '1': Internal enable for clock gating
    pipeline_en_i   : in  std_logic;

    z_re_i          : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    z_im_i          : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    h_re_i          : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    h_im_i          : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);

   -- burst_rate_i    : in  std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);

    corman_o       : out std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0)
  );

  end component;


----------------------
-- File: rx_equ_instage0_ctr.vhd
----------------------
  component rx_equ_instage0_ctr
  port (
    clk                : in  std_logic; --Clock input
    reset_n            : in  std_logic; -- Asynchronous negative reset
    module_enable_i    : in  std_logic; -- '1': Internal enable
    sync_reset_n       : in  std_logic; -- Synchronous negative reset
    pipeline_en_i      : in  std_logic;
    cumhist_en_i       : in  std_logic;
    current_symb_i     : in  std_logic_vector(1 downto 0);
    i_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    i_saved_i          : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    q_saved_i          : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    ich_i              : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    qch_i              : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    ich_saved_i        : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    qch_saved_i        : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    ctr_input_i        : in  std_logic_vector(1 downto 0);
    burst_rate_i       : in  std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);

    z_re_o             : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    z_im_o             : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    h_re_o             : out std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    h_im_o             : out std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);

    burst_rate_o       : out std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);
    cumhist_valid_o    : out std_logic;
    current_symb_o     : out std_logic_vector(1 downto 0);
    data_valid_o       : out std_logic
  );

  end component;


----------------------
-- File: rx_equ_instage0_hpowman.vhd
----------------------
  component rx_equ_instage0_hpowman
  port (
    clk             : in  std_logic; -- Clock input
    reset_n         : in  std_logic; -- Asynchronous negative reset
    module_enable_i : in  std_logic; -- '1': Internal enable
    pipeline_en_i   : in  std_logic;
    cumhist_en_i    : in  std_logic;

    h_re_i          : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    h_im_i          : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);

    hpowman_o       : out std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0)
  );

  end component;


----------------------
-- File: rx_equ_instage0.vhd
----------------------
  component rx_equ_instage0
  port (
    clk                : in  std_logic; -- Clock input
    reset_n            : in  std_logic; -- Asynchronous negative reset
    module_enable_i    : in  std_logic; -- '1': Internal enable 
    sync_reset_n       : in  std_logic; -- Synchronous negative reset
    pipeline_en_i      : in  std_logic;
    cumhist_en_i       : in  std_logic;

    current_symb_i     : in  std_logic_vector (1 downto 0);

    i_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    i_saved_i          : in  std_logic_vector (FFT_WIDTH_CT-1 downto 0); 
    q_saved_i          : in  std_logic_vector (FFT_WIDTH_CT-1 downto 0); 
    ich_i              : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    qch_i              : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    ich_saved_i        : in  std_logic_vector (CHMEM_WIDTH_CT-1 downto 0); 
    qch_saved_i        : in  std_logic_vector (CHMEM_WIDTH_CT-1 downto 0); 
    ctr_input_i        : in  std_logic_vector (1 downto 0);

    burst_rate_i       : in  std_logic_vector (BURST_RATE_WIDTH_CT-1 downto 0);

    hpowman_o          : out std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0);
    cormanr_o          : out std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    cormani_o          : out std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
   
    burst_rate_o       : out std_logic_vector (BURST_RATE_WIDTH_CT-1 downto 0);
    cumhist_valid_o    : out std_logic;
    current_symb_o     : out std_logic_vector (1 downto 0);
    data_valid_o       : out std_logic
  );

  end component;


----------------------
-- File: rx_equ_instage1.vhd
----------------------
  component rx_equ_instage1
  port (
    clk                 : in  std_logic; -- Clock input
    reset_n             : in  std_logic; -- Asynchronous negative reset
    module_enable_i     : in  std_logic; -- '1': Internal enable for clock gating
    sync_reset_n        : in  std_logic; -- synchronous negative reset

    current_symb_i      : in  std_logic_vector(1 downto 0);
    data_valid_i        : in  std_logic;
    cumhist_valid_i     : in  std_logic;
    clean_hist_i        : in  std_logic;

    hpowman_i           : in  std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0);
    cormanr_i           : in  std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    cormani_i           : in  std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);

    satmaxncarr_54_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_48_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_36_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_24_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_18_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_12_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_09_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_06_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
   
    burst_rate_i        : in  std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);
    burst_rate_4_hist_i : in  std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);

    hpowman_o           : out std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0);
    cormanr_o           : out std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    cormani_o           : out std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    
    hpowexp_o           : out std_logic_vector(HPOWEXP_WIDTH_CT-1 downto 0);
    histexpz_signal_o   : out std_logic_vector(HISTEXPZ_WIDTH_CT-1 downto 0);
    histexpz_data_o     : out std_logic_vector(HISTEXPZ_WIDTH_CT-1 downto 0);


    burst_rate_o        : out std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);
    current_symb_o      : out std_logic_vector(1 downto 0);
    data_valid_o        : out std_logic
  );

  end component;


----------------------
-- File: rx_equ_instage2.vhd
----------------------
  component rx_equ_instage2
  port (
    clk                : in  std_logic; -- Clock input
    reset_n            : in  std_logic; -- Asynchronous negative reset
    module_enable_i    : in  std_logic; --'1': Internal enable
    sync_reset_n       : in  std_logic; -- Synchronous negative reset

    current_symb_i     : in  std_logic_vector (1 downto 0);
    data_valid_i       : in  std_logic;

    hpowman_i          : in  std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0);
    cormanr_i          : in  std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    cormani_i          : in  std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);

    hpowexp_i          : in  std_logic_vector(HPOWEXP_WIDTH_CT-1 downto 0);
    histexpz_signal_i  : in  std_logic_vector(HISTEXPZ_WIDTH_CT-1 downto 0);
    histexpz_data_i    : in  std_logic_vector(HISTEXPZ_WIDTH_CT-1 downto 0);

    histoffset_54_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_48_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0);
    histoffset_36_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_24_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_18_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_12_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_09_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_06_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 

    burst_rate_i       : in  std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);
    start_of_symbol_i  : in  std_logic;
    start_of_burst_i   : in  std_logic;

    hpowman_o          : out std_logic_vector(MANTLEN_CT-1 downto 0);
    cormanr_o          : out std_logic_vector(MANTLEN_CT  downto 0);
    cormani_o          : out std_logic_vector(MANTLEN_CT  downto 0);
    secondexp_o        : out std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);
    

    qam_mode_o         : out std_logic_vector(QAM_MODE_WIDTH_CT-1 downto 0);
    data_valid_o       : out std_logic;
    start_of_symbol_o  : out std_logic;
    start_of_burst_o   : out std_logic
  );

  end component;


----------------------
-- File: rx_equ_outstage0.vhd
----------------------
  component rx_equ_outstage0
  port (
    clk               : in  std_logic; --Clock input
    reset_n           : in  std_logic; --Asynchronous negative reset
    module_enable_i   : in  std_logic; --'1': Internal enable for clock gating
    sync_reset_n      : in  std_logic; --'0': The control state of the module will be reset

    data_valid_i      : in  std_logic;

    hpowman_i         : in  std_logic_vector(MANTLEN_CT-1 downto 0);
    cormanr_i         : in  std_logic_vector(MANTLEN_CT downto 0);
    cormani_i         : in  std_logic_vector(MANTLEN_CT downto 0);
    secondexp_i       : in  std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);
   
    qam_mode_i        : in  std_logic_vector(QAM_MODE_WIDTH_CT-1 downto 0);
    start_of_symbol_i : in  std_logic;
    start_of_burst_i  : in  std_logic;

    hpowman_o         : out std_logic_vector(MANTLEN_CT-1 downto 0);
    cormanr_o         : out std_logic_vector(MANTLEN_CT  downto 0);
    cormani_o         : out std_logic_vector(MANTLEN_CT  downto 0);
    secondexp_o       : out std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);
    
    soft_x0_o         : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y0_o         : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    qam_mode_o        : out std_logic_vector(QAM_MODE_WIDTH_CT-1 downto 0);
    data_valid_o      : out std_logic;
    start_of_symbol_o : out std_logic;
    start_of_burst_o  : out std_logic;
    reducerasures_i   : in  std_logic_vector(1 downto 0)
  );

  end component;


----------------------
-- File: rx_equ_outstage1.vhd
----------------------
  component rx_equ_outstage1
  port (
    clk                : in  std_logic; --Clock input
    reset_n            : in  std_logic; --Asynchronous negative reset
    module_enable_i    : in  std_logic; --'1': Internal enable for clock gating
    sync_reset_n       : in  std_logic; --'0': The control state of the module will be reset

    data_valid_i       : in  std_logic; 

    hpowman_i          : in  std_logic_vector(MANTLEN_CT -1 downto 0);
    cormanr_i          : in  std_logic_vector(MANTLEN_CT downto 0);
    cormani_i          : in  std_logic_vector(MANTLEN_CT downto 0);
    secondexp_i        : in  std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);
   
    soft_x0_i          : in  std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); 
    soft_y0_i          : in  std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    qam_mode_i         : in  std_logic_vector(QAM_MODE_WIDTH_CT-1 downto 0);
    start_of_symbol_i  : in  std_logic;
    start_of_burst_i   : in  std_logic;

    hpowman_o          : out std_logic_vector(MANTLEN_CT-1 downto 0);
    cormanr_o          : out std_logic_vector(MANTLEN_CT  downto 0);
    cormani_o          : out std_logic_vector(MANTLEN_CT  downto 0);
    secondexp_o        : out std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);
    
    soft_x0_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y0_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    soft_x1_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y1_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    qam_mode_o         : out std_logic_vector(QAM_MODE_WIDTH_CT-1 downto 0);
    data_valid_o       : out std_logic; 
    start_of_symbol_o  : out std_logic;
    start_of_burst_o   : out std_logic;
    reducerasures_i    : in  std_logic_vector(1 downto 0)
  );

  end component;


----------------------
-- File: rx_equ_outstage2.vhd
----------------------
  component rx_equ_outstage2
  port (
    clk                : in  std_logic; --Clock input
    reset_n            : in  std_logic; --Asynchronous negative reset
    module_enable_i    : in  std_logic; --'1': Internal enable for clock gating
    sync_reset_n       : in  std_logic; --'0': The control state of the module will be reset

    data_valid_i       : in  std_logic; 

    hpowman_i          : in  std_logic_vector(MANTLEN_CT-1 downto 0);
    cormanr_i          : in  std_logic_vector(MANTLEN_CT downto 0);
    cormani_i          : in  std_logic_vector(MANTLEN_CT downto 0);
    secondexp_i        : in  std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);
   
    soft_x0_i          : in  std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); 
    soft_y0_i          : in  std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    soft_x1_i          : in  std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); 
    soft_y1_i          : in  std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    qam_mode_i         : in  std_logic_vector(QAM_MODE_WIDTH_CT-1 downto 0);
    start_of_symbol_i  : in  std_logic;
    start_of_burst_i   : in  std_logic;

    soft_x0_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y0_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    soft_x1_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y1_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    soft_x2_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y2_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    data_valid_o       : out std_logic;
    start_of_symbol_o  : out std_logic;
    start_of_burst_o   : out std_logic;
    reducerasures_i    : in  std_logic_vector(1 downto 0)
  );

  end component;


----------------------
-- File: rx_equ_fsm.vhd
----------------------
  component rx_equ_fsm
  port (
    clk                 : in    std_logic; --Clock input
    reset_n             : in    std_logic; --Asynchronous negative reset
    sync_reset_n        : in    std_logic; --'0': The control state of the module will be reset
    i_i                 : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    q_i                 : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    data_valid_i        : in    std_logic; 
    data_ready_o        : out   std_logic; 
    ich_i               : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    qch_i               : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    data_valid_ch_i     : in    std_logic; 
    data_ready_ch_o     : out   std_logic; 
    burst_rate_i        : in    std_logic_vector(BURST_RATE_WIDTH_CT - 1 downto 0); 
    signal_field_valid_i: in    std_logic; 
    data_ready_i        : in    std_logic; 
    start_of_burst_i    : in    std_logic; 
    start_of_symbol_i   : in    std_logic; 
    start_of_burst_o    : out   std_logic;
    start_of_symbol_o   : out   std_logic; 

    i_saved_o           : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    q_saved_o           : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    ich_saved_o         : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    qch_saved_o         : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    module_enable_o     : out   std_logic;

    burst_rate_o        : out   std_logic_vector(BURST_RATE_WIDTH_CT - 1 downto 0);
    burst_rate_4_hist_o : out   std_logic_vector(BURST_RATE_WIDTH_CT - 1 downto 0);
    pipeline_en_o       : out   std_logic;
    cumhist_en_o        : out   std_logic;
    ctr_input_o         : out   std_logic_vector(1 downto 0);

    current_symb_o      : out   std_logic_vector(1 downto 0);

    data_valid_last_stage_i      : in    std_logic; 
    start_of_symbol_last_stage_i : in    std_logic
  );

  end component;


----------------------
-- File: rx_equ.vhd
----------------------
  component rx_equ
  port (
    clk               : in    std_logic; -- Clock input
    reset_n           : in    std_logic; -- Asynchronous negative reset
    sync_reset_n      : in    std_logic; -- Synchronous negative rese
    i_i               : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- I input data
    q_i               : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- Q input data
    data_valid_i      : in    std_logic; --'1': Input data is valid
    data_ready_o      : out   std_logic; --'0': Do not input more data
    ich_i             : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- I channel estimate from or_chmem
    qch_i             : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- Q channel estimate from or_chmem
    data_valid_ch_i   : in    std_logic; --'1': Input data is valid
    data_ready_ch_o   : out   std_logic; --'0': Do not input more data
    soft_x0_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit x0 output
    soft_x1_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit x1 output
    soft_x2_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit x2 output
    soft_y0_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit y0 output
    soft_y1_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit y1 output
    soft_y2_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit y2 output

    burst_rate_i      : in    std_logic_vector(BURST_RATE_WIDTH_CT - 1 downto 0);-- It includes the QAM mode 
                                                                             -- QAM mode: "00" => 64 QAM
                                                                             --           "01" => QPSK
                                                                             --           "10" => 16 QAM
                                                                             --           "11" => BPSK
    signal_field_valid_i: in    std_logic; --'1': The data rate mode is valid
    data_valid_o        : out   std_logic; --'1': Output data is valid
    data_ready_i        : in    std_logic; --'0': Do not output more data
    start_of_burst_i    : in    std_logic; --'1': The next valid data input belongs to the next burst
    start_of_symbol_i   : in    std_logic; --'1': The next valid data input belongs to the next symbol
    start_of_burst_o    : out   std_logic; --'1': The next valid data output belongs to the next burst
    start_of_symbol_o   : out   std_logic; --'1': The next valid data output belongs to the next symbol

    histoffset_54_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 54
    histoffset_48_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 48
    histoffset_36_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 36
    histoffset_24_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 24
    histoffset_18_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 18
    histoffset_12_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 12
    histoffset_09_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 09
    histoffset_06_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 06

    satmaxncarr_54_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 54
    satmaxncarr_48_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 48
    satmaxncarr_36_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 36
    satmaxncarr_24_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 24
    satmaxncarr_18_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 18
    satmaxncarr_12_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 12
    satmaxncarr_09_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 09
    satmaxncarr_06_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 06

    reducerasures_i     : in    std_logic_vector(1 downto 0); -- Reduce Erasures
    -- for debug purposes
    dbg_i_o              : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- I input data (to debug block)
    dbg_q_o              : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- Q input data (to debug block)
    dbg_ich_o            : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- I channel estimate from or_chmem (to debug block)
    dbg_qch_o            : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- Q channel estimate from or_chmem (to debug block)
    dbg_equ_chan_valid_o : out   std_logic; --'1': The current value of dbg_i, dbg_q, dbg_ich and dbg_qch are valid
    dbg_equ_carrier_o    : out   std_logic_vector(5 downto 0); -- Current incoming carrier
    dbg_soft_carrier_o   : out   std_logic_vector(5 downto 0) -- Current outgoing carrier
         );

  end component;



 
end rx_equ_pkg;
