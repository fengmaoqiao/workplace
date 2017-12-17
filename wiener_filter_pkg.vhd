
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: wiener_filter_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for wiener_filter.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/wiener_filter/vhdl/rtl/wiener_filter_pkg.vhd,v  
--  Log: wiener_filter_pkg.vhd,v  
-- Revision 1.3  2003/12/10 17:26:01  arisse
-- Changed coeffs and cyclical incrementation of chanwien_a.
--
-- Revision 1.2  2003/03/28 15:48:42  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.1  2003/03/14 07:42:52  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package wiener_filter_pkg is

  -----------------------------------------------------------------------------
  -- WIENER_COEFF_WIDTH_CT is used for the width of the wiener coefficients.
  -----------------------------------------------------------------------------
  constant WIENER_COEFF_WIDTH_CT : integer := 10;
  -----------------------------------------------------------------------------
  -- WIENER_ADDR_WIDTH_CT is used for the width of the address for the
  -- wiener coefficients.
  -----------------------------------------------------------------------------
  constant WIENER_ADDR_WIDTH_CT : integer := 9;
  -----------------------------------------------------------------------------
  -- WIENER_FIRSTROUND_WIDTH_CT is used for the the number of lsb's to 
  -- remove after the first multiply-add stage.
  -----------------------------------------------------------------------------
  constant WIENER_FIRSTROUND_WIDTH_CT : integer := 5;
  -----------------------------------------------------------------------------
  -- WIENER_FIRSTADD_WIDTH_CT is used for the size of the first addition 
  -- stage.
  -----------------------------------------------------------------------------
  constant WIENER_FIRSTADD_WIDTH_CT : integer := 
           WIENER_COEFF_WIDTH_CT+FFT_WIDTH_CT-WIENER_FIRSTROUND_WIDTH_CT;
  -----------------------------------------------------------------------------
  -- WIENER_MAX_NEG_CT and WIENER_MAX_POS_CT are min and max values for 
  -- the wiener filter output.
  -----------------------------------------------------------------------------
  constant WIENER_MAX_NEG_CT : integer := -2**(FFT_WIDTH_CT-1);
  constant WIENER_MAX_POS_CT : integer := (2**(FFT_WIDTH_CT-1))-1;

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: wiener_coeff.vhd
----------------------
  component wiener_coeff

  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    chanwien_cs_ni    : in  std_logic;
    module_enable_i   : in  std_logic;
    chanwien_a_i      : in  std_logic_vector(WIENER_ADDR_WIDTH_CT-1 downto 0);
    chanwien_do_o     : out std_logic_vector((4*WIENER_COEFF_WIDTH_CT)-1 downto 0)
  );

  end component;


----------------------
-- File: wiener_ctrl.vhd
----------------------
  component wiener_ctrl

  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    wf_window_i       : in  std_logic_vector(1 downto 0);
    i_i               : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_i               : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data_valid_i      : in  std_logic;
    start_of_burst_i  : in  std_logic;
    start_of_symbol_i : in  std_logic;
    data_ready_i      : in  std_logic;
    data_ready_o      : out std_logic;
    i_o               : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_o               : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data_valid_o      : out std_logic;
    start_of_symbol_o : out std_logic;
    start_of_burst_o  : out std_logic;
    -- ROM access
    chanwien_do_i     : in  std_logic_vector((4*WIENER_COEFF_WIDTH_CT)-1 downto 0);
    chanwien_a_o      : out std_logic_vector(WIENER_ADDR_WIDTH_CT-1 downto 0);
    chanwien_cs_no    : out std_logic;
    module_enable_o   : out std_logic;
    -- to multadd module
    i_add1_i          : in  std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0);
    q_add1_i          : in  std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0);
    i_add2_i          : in  std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0);
    q_add2_i          : in  std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0);
    i_data1_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_data1_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    i_data2_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_data2_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    i_data3_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_data3_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    i_data4_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_data4_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    chanwien_c0_o     : out std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    chanwien_c1_o     : out std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    chanwien_c2_o     : out std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    chanwien_c3_o     : out std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    en_add_reg_o      : out std_logic
  );

  end component;


----------------------
-- File: wiener_multadd2.vhd
----------------------
  component wiener_multadd2
  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    module_enable_i   : in  std_logic;
    data1_i           : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data2_i           : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    chanwien_c0_i     : in  std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    chanwien_c1_i     : in  std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    en_add_reg_i      : in  std_logic;
    add_o             : out std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0)  
  );

  end component;


----------------------
-- File: wiener_filter.vhd
----------------------
  component wiener_filter

  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    wf_window_i       : in  std_logic_vector(1 downto 0);
    i_i               : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_i               : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data_valid_i      : in  std_logic;
    start_of_burst_i  : in  std_logic;
    start_of_symbol_i : in  std_logic;
    data_ready_i      : in  std_logic;
    data_ready_o      : out std_logic;
    i_o               : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_o               : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data_valid_o      : out std_logic;
    start_of_symbol_o : out std_logic;
    module_enable_o   : out std_logic;
    start_of_burst_o  : out std_logic
  );

  end component;



 
end wiener_filter_pkg;
