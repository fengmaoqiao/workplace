
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: ffwd_estimation.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.14   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Feedforward estimation for equalizer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/equalizer/vhdl/rtl/ffwd_estimation.vhd,v  
--  Log: ffwd_estimation.vhd,v  
-- Revision 1.14  2005/01/24 14:14:43  arisse
-- #BugId:624#
-- Added status signals for registers.
--
-- Revision 1.13  2004/04/29 15:57:41  arisse
--  coeff_err_i/q was not reseted between two packets : corrected.
--
-- Revision 1.12  2004/03/15 13:25:54  Dr.B
-- Debug res_mult_comp.
--
-- Revision 1.11  2003/12/12 15:19:15  Dr.B
-- change beta shift.
--
-- Revision 1.10  2003/11/28 08:43:08  arisse
-- Changed generation of array_alpha_shift_trunc_i/q.
--
-- Revision 1.9  2003/09/19 15:14:45  Dr.B
-- debug alpha and beta shift + dc_offset saturation.
--
-- Revision 1.8  2002/11/14 09:12:23  Dr.B
-- dc_offset truncation changes.
--
-- Revision 1.7  2002/08/19 09:18:27  Dr.B
-- variables for max val of array_add_i/q changed to signals.
--
-- Revision 1.6  2002/08/07 12:55:39  Dr.B
-- dc_offset saturation added.
--
-- Revision 1.5  2002/07/31 13:07:45  Dr.B
-- new size.
--
-- Revision 1.4  2002/07/11 12:38:50  Dr.B
-- added saturation on coeff accumulation.
--
-- Revision 1.3  2002/06/27 16:17:57  Dr.B
-- synchro with matlab simu + area optimization.
--
-- Revision 1.2  2002/05/07 16:53:56  Dr.A
-- Cleaned code.
-- Added equalizer_init_n input.
--
-- Revision 1.1  2002/03/28 13:49:04  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

--library equalizer_rtl;
library work;
--use equalizer_rtl.equalizer_pkg.all;
use work.equalizer_pkg.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

-- pragma translate_off
--use equalizer_rtl.equalizer_global_pkg.all;
-- pragma translate_on 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity ffwd_estimation is
  generic (
    -- generics for coefficients calculation
    dsize_g   : integer := 8;           -- Data Input size
    shifta_g  : integer := 12;          -- data size after shifting by alpha.
    cacsize_g : integer := 20;          -- accumulated coeff size  
    csize_g   : integer := 9;           -- Coeff size (output)
    coeff_g   : integer := 36;  -- Number of filter coefficients (31 to 50)

    -- generics for DC_output calculation
    dccoeff_g  : integer := 20;  -- numbers of bits kept from coeff to calc sum.
    sum_g      : integer := 10;         -- data size of the sum
    multerr_g  : integer := 18;         -- data size after the mult by error
    shiftb_g   : integer := 21;         -- data size after shifting by beta
    dcacsize_g : integer := 21;         -- accumulated dc_offset size  
    dcsize_g   : integer := 6;           -- DC_offset size (output)
    outsize_g : integer := 9  
    );
  port (
    -- Clock and reset
    reset_n : in std_logic;
    clk     : in std_logic;

    -- Chip synchronization.
    div_counter      : in std_logic_vector(1 downto 0);
    equalizer_init_n : in std_logic;    -- Use init coefficients values when 0.
    -- Demodulation error
    error_i          : in std_logic_vector(outsize_g-1 downto 0);  -- I error.
    error_q          : in std_logic_vector(outsize_g-1 downto 0);  -- Q error.
    -- Estimation parameters.
    alpha            : in std_logic_vector(2 downto 0);  -- Shift values from
    beta             : in std_logic_vector(2 downto 0);  -- modem registers.
    -- Control of accumulation
    alpha_accu_disb  : in std_logic;    -- stop coeff accu when high
    beta_accu_disb   : in std_logic;    -- stop dc accu when high

    -- Data from I delay line
    data_i_ff0  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff1  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff2  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff3  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff4  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff5  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff6  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff7  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff8  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff9  : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff10 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff11 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff12 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff13 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff14 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff15 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff16 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff17 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff18 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff19 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff20 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff21 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff22 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff23 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff24 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff25 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff26 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff27 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff28 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff29 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff30 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff31 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff32 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff33 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff34 : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff35 : in  std_logic_vector(dsize_g-1 downto 0);
    -- Data from Q delay line
    data_q_ff0  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff1  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff2  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff3  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff4  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff5  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff6  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff7  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff8  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff9  : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff10 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff11 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff12 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff13 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff14 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff15 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff16 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff17 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff18 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff19 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff20 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff21 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff22 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff23 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff24 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff25 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff26 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff27 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff28 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff29 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff30 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff31 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff32 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff33 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff34 : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff35 : in  std_logic_vector(dsize_g-1 downto 0);
    -- Filter coefficients (real part)
    coeff_i0    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i1    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i2    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i3    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i4    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i5    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i6    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i7    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i8    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i9    : out std_logic_vector(csize_g-1 downto 0);
    coeff_i10   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i11   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i12   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i13   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i14   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i15   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i16   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i17   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i18   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i19   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i20   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i21   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i22   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i23   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i24   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i25   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i26   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i27   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i28   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i29   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i30   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i31   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i32   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i33   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i34   : out std_logic_vector(csize_g-1 downto 0);
    coeff_i35   : out std_logic_vector(csize_g-1 downto 0);

    -- Filter coefficients (imaginary part)
    coeff_q0  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q1  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q2  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q3  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q4  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q5  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q6  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q7  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q8  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q9  : out std_logic_vector(csize_g-1 downto 0);
    coeff_q10 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q11 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q12 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q13 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q14 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q15 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q16 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q17 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q18 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q19 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q20 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q21 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q22 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q23 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q24 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q25 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q26 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q27 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q28 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q29 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q30 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q31 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q32 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q33 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q34 : out std_logic_vector(csize_g-1 downto 0);
    coeff_q35 : out std_logic_vector(csize_g-1 downto 0);
    
    -- Register stat
    coeff_sum_i_stat : out std_logic_vector(sum_g-1 downto 0);
    coeff_sum_q_stat : out std_logic_vector(sum_g-1 downto 0);
    
    -- DC offset.
    dc_offset_i : out std_logic_vector(dcsize_g-1 downto 0);
    dc_offset_q : out std_logic_vector(dcsize_g-1 downto 0)
    );

end ffwd_estimation;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of ffwd_estimation is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Sample : chip speed
  constant SAMPL_CT : std_logic_vector(1 downto 0)         := "11";
  
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type ArrayOfSLVdsize is array (0 to coeff_g-1) of
    std_logic_vector(dsize_g-1 downto 0);
  type ArrayOfSLVdsize1 is array (0 to coeff_g-1) of
    std_logic_vector(dsize_g downto 0);
  type ArrayOfSLVshiftasize is array (0 to coeff_g-1) of
    std_logic_vector(shifta_g-1 downto 0);
  type ArrayOfSLV12 is array (0 to coeff_g-1) of
    std_logic_vector(11 downto 0);
  type ArrayOfSLVcacsize is array (0 to coeff_g-1) of
    std_logic_vector(cacsize_g-1 downto 0);
  type ArrayOfSLVcacsize1 is array (0 to coeff_g-1) of
    std_logic_vector(cacsize_g  downto 0);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  --------------------------------
  --  for coefficients calculation
  --------------------------------
  signal error_quant : std_logic_vector(1 downto 0);  -- quantized error

  -- Arrays for input data conjugate.
  signal array_i             : ArrayOfSLVdsize;  -- I data
  signal array_q             : ArrayOfSLVdsize;  -- Q data
  -- Arrays for conjugate input data multuplied by quantized error.
  signal array_err_i         : ArrayOfSLVdsize1;
  signal array_err_q         : ArrayOfSLVdsize1;
  -- array_err shifted by alpha.
  signal array_alpha_shift_i : ArrayOfSLVshiftasize;
  signal array_alpha_shift_q : ArrayOfSLVshiftasize;
  -- truncated array_alpha_shift
  signal array_alpha_shift_trunc_i : ArrayOfSLV12;
  signal array_alpha_shift_trunc_q : ArrayOfSLV12;
  -- Adder for coefficients.
  signal array_add_i         : ArrayOfSLVcacsize;
  signal array_add_q         : ArrayOfSLVcacsize;
  signal array_add_bef_sat_i         : ArrayOfSLVcacsize1;
  signal array_add_bef_sat_q         : ArrayOfSLVcacsize1;
 -- Arrays for coefficients chip delay.
  signal array_add_i_ff1 : ArrayOfSLVcacsize;
  signal array_add_q_ff1 : ArrayOfSLVcacsize;
  signal array_add_i_ff2 : ArrayOfSLVcacsize;
  signal array_add_q_ff2 : ArrayOfSLVcacsize;

  --------------------------------
  --  for DC offset
  --------------------------------
  -- Signals for coefficients sum.
  signal coeff_sum_i      : std_logic_vector(sum_g-1 downto 0);
  signal coeff_sum_q      : std_logic_vector(sum_g-1 downto 0);
  signal coeff_sum_i_tot  : std_logic_vector(cacsize_g-1 downto 0);
  signal coeff_sum_q_tot  : std_logic_vector(cacsize_g-1 downto 0);
  -- Signals for coefficients sum multiplied by quantized error.
  signal coeff_err_i      : std_logic_vector(multerr_g-1 downto 0);
  signal coeff_err_q      : std_logic_vector(multerr_g-1 downto 0);
  signal coeff_err_oper1  : std_logic_vector(sum_g-1 downto 0);
  signal coeff_err_oper2  : std_logic_vector(outsize_g-1 downto 0);
  signal coeff_err_oper3  : std_logic_vector(outsize_g-1 downto 0); 
 
  signal coeff_err_oper4  : std_logic_vector(sum_g-1 downto 0);
  signal res_mult_comp    : std_logic_vector((outsize_g+sum_g) downto 0);
  signal res_mult_c_trunc : std_logic_vector((outsize_g+sum_g-2) downto 0);
  signal res_mult_sat     : std_logic_vector(multerr_g-1 downto 0);
  signal res_mult1        : std_logic_vector((outsize_g+sum_g)-1 downto 0);
   
  signal res_mult2        : std_logic_vector((outsize_g+sum_g) downto 0);
  signal res_mult2_int    : std_logic_vector((outsize_g+sum_g)-1 downto 0);
  
  -- coeff_err shifted by beta.
  signal beta_shift_i     : std_logic_vector(shiftb_g-1 downto 0);
  signal beta_shift_q     : std_logic_vector(shiftb_g-1 downto 0);
  -- DC offset adder.
  -- before saturation:
  signal beta_add_bef_sat_i : std_logic_vector(17 downto 0);
  signal beta_add_bef_sat_q : std_logic_vector(17 downto 0);
  -- after saturation
  signal beta_add_i       : std_logic_vector(16 downto 0);
  signal beta_add_q       : std_logic_vector(16 downto 0);
  -- Signals for DC offset chip delay.
  signal beta_add_i_ff1   : std_logic_vector(16 downto 0);
  signal beta_add_q_ff1   : std_logic_vector(16 downto 0);
  

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  ------------------------------------------------------------------------------
  -- Global Signals for test
  ------------------------------------------------------------------------------
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  test_gen : for i in coeff_g-1 downto 0 generate
--    array_coeffi_tglobal(i)   <= array_add_i_ff1(i)(cacsize_g-1 downto cacsize_g-csize_g);
--    array_coeffq_tglobal(i)   <= array_add_q_ff1(i)(cacsize_g-1 downto cacsize_g-csize_g);
--
--    dc_offset_i_tglobal       <= beta_add_i_ff1 (dcacsize_g-1 downto dcacsize_g-dcsize_g);
--    dc_offset_q_tglobal       <= beta_add_q_ff1 (dcacsize_g-1 downto dcacsize_g-dcsize_g);
--
--    array_add_i_ff1_tglobal(i) <= array_add_i_ff1(i);
--    array_add_q_ff1_tglobal(i) <= array_add_q_ff1(i);
--
--    prod_i_tglobal (i) <= array_err_i(i);
--    prod_q_tglobal (i) <= array_err_q(i);
--
--    shift_i_tglobal (i) <= array_alpha_shift_i(i);
--    shift_q_tglobal (i) <= array_alpha_shift_q(i);
--    
--  end generate test_gen;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
  --------------------------------------------------------------------------
  -- Fill data arrays with input conjugate 
  --------------------------------------------------------------------------

  -- 30 first coefficients always used.
  -- Fill array with I values.
  array_i(0)  <= data_i_ff0;
  array_i(1)  <= data_i_ff1;
  array_i(2)  <= data_i_ff2;
  array_i(3)  <= data_i_ff3;
  array_i(4)  <= data_i_ff4;
  array_i(5)  <= data_i_ff5;
  array_i(6)  <= data_i_ff6;
  array_i(7)  <= data_i_ff7;
  array_i(8)  <= data_i_ff8;
  array_i(9)  <= data_i_ff9;
  array_i(10) <= data_i_ff10;
  array_i(11) <= data_i_ff11;
  array_i(12) <= data_i_ff12;
  array_i(13) <= data_i_ff13;
  array_i(14) <= data_i_ff14;
  array_i(15) <= data_i_ff15;
  array_i(16) <= data_i_ff16;
  array_i(17) <= data_i_ff17;
  array_i(18) <= data_i_ff18;
  array_i(19) <= data_i_ff19;
  array_i(20) <= data_i_ff20;
  array_i(21) <= data_i_ff21;
  array_i(22) <= data_i_ff22;
  array_i(23) <= data_i_ff23;
  array_i(24) <= data_i_ff24;
  array_i(25) <= data_i_ff25;
  array_i(26) <= data_i_ff26;
  array_i(27) <= data_i_ff27;
  array_i(28) <= data_i_ff28;
  array_i(29) <= data_i_ff29;
  array_i(30) <= data_i_ff30;
  array_i(31) <= data_i_ff31;
  array_i(32) <= data_i_ff32;
  array_i(33) <= data_i_ff33;
  array_i(34) <= data_i_ff34;
  array_i(35) <= data_i_ff35;

  -- Fill array with Q values.
  array_q(0)  <= data_q_ff0;
  array_q(1)  <= data_q_ff1;
  array_q(2)  <= data_q_ff2;
  array_q(3)  <= data_q_ff3;
  array_q(4)  <= data_q_ff4;
  array_q(5)  <= data_q_ff5;
  array_q(6)  <= data_q_ff6;
  array_q(7)  <= data_q_ff7;
  array_q(8)  <= data_q_ff8;
  array_q(9)  <= data_q_ff9;
  array_q(10) <= data_q_ff10;
  array_q(11) <= data_q_ff11;
  array_q(12) <= data_q_ff12;
  array_q(13) <= data_q_ff13;
  array_q(14) <= data_q_ff14;
  array_q(15) <= data_q_ff15;
  array_q(16) <= data_q_ff16;
  array_q(17) <= data_q_ff17;
  array_q(18) <= data_q_ff18;
  array_q(19) <= data_q_ff19;
  array_q(20) <= data_q_ff20;
  array_q(21) <= data_q_ff21;
  array_q(22) <= data_q_ff22;
  array_q(23) <= data_q_ff23;
  array_q(24) <= data_q_ff24;
  array_q(25) <= data_q_ff25;
  array_q(26) <= data_q_ff26;
  array_q(27) <= data_q_ff27;
  array_q(28) <= data_q_ff28;
  array_q(29) <= data_q_ff29;
  array_q(30) <= data_q_ff30;
  array_q(31) <= data_q_ff31;
  array_q(32) <= data_q_ff32;
  array_q(33) <= data_q_ff33;
  array_q(34) <= data_q_ff34;
  array_q(35) <= data_q_ff35;

  -----------------------------------------------------------------------------
  -- ******************** COEFFS CALCULATION **********************************
  -----------------------------------------------------------------------------
  --------------------------------------------------------------------------
  -- Quantize error
  --------------------------------------------------------------------------
  -- 
  -- Notations for error_quant
  --
  --     Q          error_quant |  notation
  --     |        --------------|-----------
  --  10 | 00          1+j      |      00
  --  ___|____ I       1-j      |      01
  --     |            -1+j      |      10
  --  11 | 01         -1-j      |      11
  --
  error_quant <= error_i(error_i'high) & error_q(error_q'high);

  ---------------------------------------------------------------------------
  -- Multiply by data conjugate by error_quant
  ---------------------------------------------------------------------------
  -- Re[(I+jQ) * error_quant] = e(0)*I - e(1)*Q  
  -- Im[(I+jQ) * error_quant] = e(0)*Q + e(1)*I
  --                            with e(i) =  1 when error_quant(i) = 0 
  --                            and  e(i) = -1 when error_quant(i) = 1
  err_mult_gen : for i in 0 to (coeff_g-1) generate
    qerror_mult_i : qerr_mult
      generic map ( dsize_g => dsize_g )
      port map (
        data_in_re  => array_i(i),
        data_in_im  => array_q(i),
        error_quant => error_quant,
        data_out_re => array_err_i(i),
        data_out_im => array_err_q(i)
        );
  end generate err_mult_gen;

  --------------------------------------------------------------------------
  -- Shift by alpha
  --------------------------------------------------------------------------
  alpha_shift_gen : for i in 0 to (coeff_g-1) generate

    i_alpha_shift_i : alpha_shift
      generic map ( dsize_g => dsize_g+1 )
      port map (
        alpha        => alpha,
        data_in      => array_err_i(i),
        shifted_data => array_alpha_shift_i(i)
        );

    q_alpha_shift_i : alpha_shift 
      generic map ( dsize_g => dsize_g+1)
      port map (
        alpha        => alpha,
        data_in      => array_err_q(i),
        shifted_data => array_alpha_shift_q(i)
        );

    array_alpha_shift_trunc_i(i) <= sat_signed_slv(array_alpha_shift_i(i),2);
    array_alpha_shift_trunc_q(i) <= sat_signed_slv(array_alpha_shift_q(i),2);
    
  end generate alpha_shift_gen;

  --------------------------------------------------------------------------
  -- Adder and chip delay for coefficients computing
  --------------------------------------------------------------------------
  -- I values
  alpha_chip_delay_p : process (reset_n, clk)
  begin
    if reset_n = '0' then
      array_add_i_ff1 <= (others => (others => '0'));
      array_add_q_ff1 <= (others => (others => '0'));
      
    elsif clk'event and clk = '1' then
      if equalizer_init_n = '0' then
        array_add_i_ff1 <= (others => (others => '0'));
        array_add_q_ff1 <= (others => (others => '0'));   
      elsif div_counter = SAMPL_CT and alpha_accu_disb = '0' then
        array_add_i_ff1 <= array_add_i;
        array_add_q_ff1 <= array_add_q;
      end if;
    end if;
  end process alpha_chip_delay_p;
  

  coeff_adder_gen : for i in 0 to coeff_g-1 generate
    -- add with 1 MSB for avoiding saturation
    array_add_bef_sat_i(i) <= sxt(array_alpha_shift_trunc_i(i),cacsize_g+1)
                            + sxt(array_add_i_ff1(i),cacsize_g+1);
    array_add_bef_sat_q(i) <= sxt(array_alpha_shift_trunc_q(i),cacsize_g+1)
                            + sxt(array_add_q_ff1(i),cacsize_g+1);

    -- Saturate
    array_add_i(i) <= sat_signed_slv(array_add_bef_sat_i(i),1);
    array_add_q(i) <= sat_signed_slv(array_add_bef_sat_q(i),1);

  end generate coeff_adder_gen;


  -----------------------------------------------------------------------------
  -- ******************** DC_OFFSET CALCULATION *******************************
  -----------------------------------------------------------------------------
  --------------------------------------------------------------------------
  -- Sum up coefficients
  --------------------------------------------------------------------------
  -- optimized parenthesis for synthesis : reduced worst path.
  coeff_sum_q_tot <=
    ((((array_add_q_ff1( 0) 
        + array_add_q_ff1( 1))
       + (array_add_q_ff1( 2)
           + array_add_q_ff1( 3)))

      + ((array_add_q_ff1( 4)
          + array_add_q_ff1( 5))
         + (array_add_q_ff1( 6)
             + array_add_q_ff1( 7))))

     +((((array_add_q_ff1(24)
          + array_add_q_ff1(25))
         + (array_add_q_ff1(26)
             + array_add_q_ff1(27)))

        + ((array_add_q_ff1(28)
            + array_add_q_ff1(29))
           + (array_add_q_ff1(30)
               + array_add_q_ff1(31))))

       + ((array_add_q_ff1(32)
           + array_add_q_ff1(33))
          + (array_add_q_ff1(34)
              + array_add_q_ff1(35)))))

    +((((array_add_q_ff1( 8)
         + array_add_q_ff1( 9))
        + (array_add_q_ff1(10)
            + array_add_q_ff1(11)))

       + ((array_add_q_ff1(12)
           + array_add_q_ff1(13))
          + (array_add_q_ff1(14)
              + array_add_q_ff1(15))))

      + (((array_add_q_ff1(16)
           + array_add_q_ff1(17))
          + (array_add_q_ff1(18)
              + array_add_q_ff1(19)))

         + ((array_add_q_ff1(20)
             + array_add_q_ff1(21))
            + (array_add_q_ff1(22)
                + array_add_q_ff1(23)))));


  coeff_sum_i_tot <=
    ((((array_add_i_ff1( 0)
        + array_add_i_ff1( 1))
       + (array_add_i_ff1( 2)
           + array_add_i_ff1( 3)))

      + ((array_add_i_ff1( 4)
          + array_add_i_ff1( 5))
         + (array_add_i_ff1( 6)
             + array_add_i_ff1( 7))))

     +((((array_add_i_ff1(24)
          + array_add_i_ff1(25))
         + (array_add_i_ff1(26)
             + array_add_i_ff1(27)))

        + ((array_add_i_ff1(28)
            + array_add_i_ff1(29))
           + (array_add_i_ff1(30)
               + array_add_i_ff1(31))))

       + ((array_add_i_ff1(32)
           + array_add_i_ff1(33))
          + (array_add_i_ff1(34)
              + array_add_i_ff1(35)))))

    +((((array_add_i_ff1( 8)
         + array_add_i_ff1( 9))
        + (array_add_i_ff1(10)
            + array_add_i_ff1(11)))

       + ((array_add_i_ff1(12)
           + array_add_i_ff1(13))
          + (array_add_i_ff1(14)
              + array_add_i_ff1(15))))

      + (((array_add_i_ff1(16)
           + array_add_i_ff1(17))
          + (array_add_i_ff1(18)
              + array_add_i_ff1(19)))

         + ((array_add_i_ff1(20)
             + array_add_i_ff1(21))
            + (array_add_i_ff1(22)
                + array_add_i_ff1(23)))));

  coeff_sum_i <= coeff_sum_i_tot (coeff_sum_i_tot'high downto dccoeff_g-sum_g);
  coeff_sum_q <= coeff_sum_q_tot (coeff_sum_i_tot'high downto dccoeff_g-sum_g);

  coeff_sum_stat_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      coeff_sum_i_stat <= (others => '0');
      coeff_sum_q_stat <= (others => '0');
    elsif clk'event and clk = '1' then
      coeff_sum_i_stat <= coeff_sum_i;
      coeff_sum_q_stat <= coeff_sum_q;
    end if;
  end process coeff_sum_stat_p;

  --------------------------------------------------------------------------
  -- Multiply sum conjugate by error
  --------------------------------------------------------------------------
  --   perform the multiplication in 2 time :
  -- div_c : oper1       * oper2   + oper3    * oper4       = res_mult_comp
  -- -----------------------------------------------------------------------
  -- 00-01 : coeff_sum_i * error_i +  error_q * coeff_sum_q = coeff_err_i
  -- 10-11 : coeff_sum_i * error_q + -error_q * coeff_sum_q = coeff_err_q

  coeff_err_oper1 <= coeff_sum_i;

  with div_counter(1) select
    coeff_err_oper2 <=
    error_i when '0',
    error_q when others;

  with div_counter(1) select
    coeff_err_oper3 <=
    error_q             when '0',
    error_i             when others;

  coeff_err_oper4 <= coeff_sum_q;

  res_mult1         <= signed(coeff_err_oper1) * signed (coeff_err_oper2);
  res_mult2_int     <= signed(coeff_err_oper3) * signed (coeff_err_oper4);

  
  with div_counter(1) select
    res_mult2 <=
    sxt(res_mult2_int, outsize_g+sum_g+1)             when '0',
    (not sxt(res_mult2_int, outsize_g+sum_g+1) + '1') when others;  
  
  res_mult_comp     <= sxt(res_mult1, outsize_g+sum_g+1) + res_mult2;  
  
  
  ------------------------------------
  -- Saturation 
  ------------------------------------
  -- remove 2 LSB
  res_mult_c_trunc <= res_mult_comp(res_mult_comp'high downto 2);

  -- remove 4 MSB
  res_mult_sat <= sat_signed_slv(res_mult_c_trunc,4);

                      
  -- Register the results of the 2 multiplications
  -- Remark:
  -- coeff_err_q does not need to be registered. But because of the
  -- previous amount of combinational calculation, it is sampled. 
  one_mult_p : process (clk, reset_n)
  begin  -- process one_mult_p
    if reset_n = '0' then
      coeff_err_i <= (others => '0');
      coeff_err_q <= (others => '0');
    elsif clk'event and clk = '1' then
      if equalizer_init_n = '1' then
        case div_counter is
          when "00" =>
            -- store erri1
            coeff_err_i <= res_mult_sat;
          when "10" =>
            -- store erri2
            coeff_err_q <= res_mult_sat;
          when others =>
            null;
        end case;
      elsif equalizer_init_n = '0' then
        coeff_err_i <= (others => '0');
        coeff_err_q <= (others => '0');
      end if;
    end if;
  end process one_mult_p;

  --------------------------------------------------------------------------
  -- Shift result by beta
  --------------------------------------------------------------------------
  i_beta_shift : beta_shift
    generic map (
      dsize_g => multerr_g
      )
    port map (
      beta         => beta,
      data_in      => coeff_err_i,
      shifted_data => beta_shift_i
      );

  q_beta_shift : beta_shift
    generic map (
      dsize_g => multerr_g
      )
    port map (
      beta         => beta,
      data_in      => coeff_err_q,
      shifted_data => beta_shift_q
      );

  ------------------------------------------------------------------------------
  -- Adder and chip delay for DC offset
  ------------------------------------------------------------------------------

  -- subtraction (MSB is added in order to avoid overflow)
  beta_add_bef_sat_i <= sxt(beta_add_i_ff1, 18)
                      - sxt(beta_shift_i,   18);
  beta_add_bef_sat_q <= sxt(beta_add_q_ff1, 18)
                      - sxt(beta_shift_q,   18);

  -- saturation

  beta_add_i <= sat_signed_slv(beta_add_bef_sat_i,1);
  beta_add_q <= sat_signed_slv(beta_add_bef_sat_q,1);
  
  -- register result
  beta_chip_delay_p : process (reset_n, clk)
  begin
    if reset_n = '0' then
      beta_add_i_ff1 <= (others => '0');
      beta_add_q_ff1 <= (others => '0');

    elsif clk'event and clk = '1' then
      if equalizer_init_n = '0' then
        beta_add_i_ff1 <= (others => '0');
        beta_add_q_ff1 <= (others => '0');
        
      elsif div_counter = SAMPL_CT and beta_accu_disb = '0' then
        beta_add_i_ff1 <= beta_add_i;
        beta_add_q_ff1 <= beta_add_q;

      end if;
    end if;
  end process beta_chip_delay_p;


  ------------------------------------------------------------------------------
  -- Assign output ports
  ------------------------------------------------------------------------------
  
  -- Truncation to the closest number 

  dc_offset_i <= beta_add_i_ff1(16 downto 11);
  dc_offset_q <= beta_add_q_ff1(16 downto 11);
  
  
  coeff_i0  <= array_add_i_ff1(0) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i1  <= array_add_i_ff1(1) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i2  <= array_add_i_ff1(2) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i3  <= array_add_i_ff1(3) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i4  <= array_add_i_ff1(4) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i5  <= array_add_i_ff1(5) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i6  <= array_add_i_ff1(6) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i7  <= array_add_i_ff1(7) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i8  <= array_add_i_ff1(8) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i9  <= array_add_i_ff1(9) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i10 <= array_add_i_ff1(10)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i11 <= array_add_i_ff1(11)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i12 <= array_add_i_ff1(12)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i13 <= array_add_i_ff1(13)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i14 <= array_add_i_ff1(14)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i15 <= array_add_i_ff1(15)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i16 <= array_add_i_ff1(16)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i17 <= array_add_i_ff1(17)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i18 <= array_add_i_ff1(18)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i19 <= array_add_i_ff1(19)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i20 <= array_add_i_ff1(20)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i21 <= array_add_i_ff1(21)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i22 <= array_add_i_ff1(22)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i23 <= array_add_i_ff1(23)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i24 <= array_add_i_ff1(24)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i25 <= array_add_i_ff1(25)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i26 <= array_add_i_ff1(26)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i27 <= array_add_i_ff1(27)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i28 <= array_add_i_ff1(28)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i29 <= array_add_i_ff1(29)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i30 <= array_add_i_ff1(30)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i31 <= array_add_i_ff1(31)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i32 <= array_add_i_ff1(32)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i33 <= array_add_i_ff1(33)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i34 <= array_add_i_ff1(34)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_i35 <= array_add_i_ff1(35)(cacsize_g-1 downto cacsize_g-csize_g);

  coeff_q0  <= array_add_q_ff1(0) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q1  <= array_add_q_ff1(1) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q2  <= array_add_q_ff1(2) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q3  <= array_add_q_ff1(3) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q4  <= array_add_q_ff1(4) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q5  <= array_add_q_ff1(5) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q6  <= array_add_q_ff1(6) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q7  <= array_add_q_ff1(7) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q8  <= array_add_q_ff1(8) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q9  <= array_add_q_ff1(9) (cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q10 <= array_add_q_ff1(10)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q11 <= array_add_q_ff1(11)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q12 <= array_add_q_ff1(12)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q13 <= array_add_q_ff1(13)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q14 <= array_add_q_ff1(14)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q15 <= array_add_q_ff1(15)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q16 <= array_add_q_ff1(16)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q17 <= array_add_q_ff1(17)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q18 <= array_add_q_ff1(18)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q19 <= array_add_q_ff1(19)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q20 <= array_add_q_ff1(20)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q21 <= array_add_q_ff1(21)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q22 <= array_add_q_ff1(22)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q23 <= array_add_q_ff1(23)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q24 <= array_add_q_ff1(24)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q25 <= array_add_q_ff1(25)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q26 <= array_add_q_ff1(26)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q27 <= array_add_q_ff1(27)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q28 <= array_add_q_ff1(28)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q29 <= array_add_q_ff1(29)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q30 <= array_add_q_ff1(30)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q31 <= array_add_q_ff1(31)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q32 <= array_add_q_ff1(32)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q33 <= array_add_q_ff1(33)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q34 <= array_add_q_ff1(34)(cacsize_g-1 downto cacsize_g-csize_g);
  coeff_q35 <= array_add_q_ff1(35)(cacsize_g-1 downto cacsize_g-csize_g);

  
end RTL;
