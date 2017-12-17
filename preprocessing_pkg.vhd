
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: preprocessing_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for preprocessing.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/preprocessing/vhdl/rtl/preprocessing_pkg.vhd,v  
--  Log: preprocessing_pkg.vhd,v  
-- Revision 1.7  2004/12/20 09:03:01  Dr.C
-- #BugId:810#
-- Added ybnb port.
--
-- Revision 1.6  2004/04/07 12:42:38  Dr.B
-- Changed type of generics from boolean to integer.
--
-- Revision 1.5  2004/03/10 16:38:30  Dr.B
-- Removed use_full_preprocessing_g generic.
-- Replaced by: use_3correlators_g & use_autocorrelators_g for
-- conditional generation of these 2 sub-parts.
--
-- Revision 1.4  2004/02/23 13:50:54  Dr.B
-- Updated preprocessing GENERIC PORT.
--
-- Revision 1.3  2003/11/06 16:38:08  Dr.B
-- Added dc_offset_4_corr i&q INPUT, updated at0_o,at1_o & a16_m_o OUTPUTS to 14 bits.
--
-- Revision 1.2  2003/06/25 17:06:02  Dr.B
-- remove dc_offset inputs.
--
-- Revision 1.1  2003/03/27 16:36:23  Dr.B
-- Initial revision
--
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
package preprocessing_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: complex_mult_corr.vhd
----------------------
  component complex_mult_corr
  generic (
    size_in_g     : integer := 11      -- size of the data inputs
          );    
  port (

    --------------------------------------
    -- Signals
    --------------------------------------
    -- Data in
    data_in_i : in std_logic_vector(size_in_g - 1 downto 0);
    data_in_q : in std_logic_vector(size_in_g - 1 downto 0);
    -- Coeff
    coeff_i   : in std_logic_vector(1 downto 0);
    coeff_q   : in std_logic_vector(1 downto 0);
    -- Results (1 bit more because of the max negative value
    -- that can not be "-" with the same nb of bits
    operand_a_i : out std_logic_vector(size_in_g downto 0);
    operand_a_q : out std_logic_vector(size_in_g downto 0);
    operand_b_i : out std_logic_vector(size_in_g downto 0);
    operand_b_q : out std_logic_vector(size_in_g downto 0)   
  );

  end component;


----------------------
-- File: complex_mult_autocorr.vhd
----------------------
  component complex_mult_autocorr
  generic (
    size_in_g     : integer := 11      -- size of the data inputs
          );    
  port (

    --------------------------------------
    -- Signals
    --------------------------------------
    -- Data in
    data_in_i : in std_logic_vector(size_in_g - 1 downto 0);
    data_in_q : in std_logic_vector(size_in_g - 1 downto 0);
    -- Coeff
    sign_i   : in std_logic;
    sign_q   : in std_logic;
    -- Results (1 bit more because of the max negative value
    -- that can not be "-" with the same nb of bits
    operand_a_i : out std_logic_vector(size_in_g downto 0);
    operand_a_q : out std_logic_vector(size_in_g downto 0);
    operand_b_i : out std_logic_vector(size_in_g downto 0);
    operand_b_q : out std_logic_vector(size_in_g downto 0)
   

    
  );

  end component;


----------------------
-- File: correlator.vhd
----------------------
  component correlator
  generic (
    size_in_g     : integer := 11);      -- size of the data inputs
  port (
    -- Input Data
    -- Real Part
    data_reg0_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg1_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg2_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg3_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg4_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg5_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg6_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg7_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg8_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg9_i  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg10_i : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg11_i : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg12_i : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg13_i : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg14_i : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg15_i : in std_logic_vector(size_in_g - 1 downto 0);
    -- Imaginary Part
    data_reg0_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg1_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg2_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg3_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg4_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg5_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg6_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg7_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg8_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg9_q  : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg10_q : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg11_q : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg12_q : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg13_q : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg14_q : in std_logic_vector(size_in_g - 1 downto 0);
    data_reg15_q : in std_logic_vector(size_in_g - 1 downto 0);
    -- Real Coefficients
    coeff0_i   : in std_logic_vector(1 downto 0);
    coeff1_i   : in std_logic_vector(1 downto 0);
    coeff2_i   : in std_logic_vector(1 downto 0);
    coeff3_i   : in std_logic_vector(1 downto 0);
    coeff4_i   : in std_logic_vector(1 downto 0);
    coeff5_i   : in std_logic_vector(1 downto 0);
    coeff6_i   : in std_logic_vector(1 downto 0);
    coeff7_i   : in std_logic_vector(1 downto 0);
    coeff8_i   : in std_logic_vector(1 downto 0);
    coeff9_i   : in std_logic_vector(1 downto 0);
    coeff10_i  : in std_logic_vector(1 downto 0);
    coeff11_i  : in std_logic_vector(1 downto 0);
    coeff12_i  : in std_logic_vector(1 downto 0);
    coeff13_i  : in std_logic_vector(1 downto 0);
    coeff14_i  : in std_logic_vector(1 downto 0);
    coeff15_i  : in std_logic_vector(1 downto 0);
    -- Imaginary Part                 
    coeff0_q   : in std_logic_vector(1 downto 0);
    coeff1_q   : in std_logic_vector(1 downto 0);
    coeff2_q   : in std_logic_vector(1 downto 0);
    coeff3_q   : in std_logic_vector(1 downto 0);
    coeff4_q   : in std_logic_vector(1 downto 0);
    coeff5_q   : in std_logic_vector(1 downto 0);
    coeff6_q   : in std_logic_vector(1 downto 0);
    coeff7_q   : in std_logic_vector(1 downto 0);
    coeff8_q   : in std_logic_vector(1 downto 0);
    coeff9_q   : in std_logic_vector(1 downto 0);
    coeff10_q  : in std_logic_vector(1 downto 0);
    coeff11_q  : in std_logic_vector(1 downto 0);
    coeff12_q  : in std_logic_vector(1 downto 0);
    coeff13_q  : in std_logic_vector(1 downto 0);
    coeff14_q  : in std_logic_vector(1 downto 0);
    coeff15_q  : in std_logic_vector(1 downto 0);

    -- Result of correlation
    data_out_i : out std_logic_vector(size_in_g + 5 - 1 downto 0);
    data_out_q : out std_logic_vector(size_in_g + 5 - 1 downto 0)    
    );

  end component;


----------------------
-- File: three_correlators.vhd
----------------------
  component three_correlators
  generic (
    size_in_g         : integer := 11;  -- size of the data inputs
    size_rem_corr_g   : integer := 4);  -- nb of bits removed for corr calc
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n : in std_logic;
    clk     : in std_logic;

    --------------------------------------
    -- Signals
    --------------------------------------
    shift_i       : in  std_logic;      -- shift the registers
    init_i        : in  std_logic;      -- init registers
    -- Input Data
    data_in_i_i   : in  std_logic_vector(size_in_g - 1 downto 0);
    data_in_q_i   : in  std_logic_vector(size_in_g - 1 downto 0);
    -- Registered input data
    data_i_ff15_o : out std_logic_vector(size_in_g - 1 downto 0);
    data_q_ff15_o : out std_logic_vector(size_in_g - 1 downto 0);
    data_i_ff0_o  : out std_logic_vector(size_in_g - 1 downto 0);
    data_q_ff0_o  : out std_logic_vector(size_in_g - 1 downto 0);  -- B-Correlator Output
    bb_out_i_o    : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    bb_out_q_o    : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    -- CP1-Correlator Output
    cp1_out_i_o   : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    cp1_out_q_o   : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    -- CP2-Correlator Output
    cp2_out_i_o   : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    cp2_out_q_o   : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0)
  );

  end component;


----------------------
-- File: magnitude_gen.vhd
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
-- File: preprocessing.vhd
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



 
end preprocessing_pkg;
