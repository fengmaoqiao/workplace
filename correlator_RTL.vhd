
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: correlator.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Correlator for preprocessing (Init Sync)
--
-- RE_Result = Sum (coeff_re_i * Reg_re_i + coeff_im_i * Reg_im_i)
-- IM_Result = Sum (coeff_re_i * Reg_im_i - coeff_im_i * Reg_re_i)
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/preprocessing/vhdl/rtl/correlator.vhd,v  
--  Log: correlator.vhd,v  
-- Revision 1.2  2003/11/18 08:02:20  Dr.B
-- debug i addition.
--
-- Revision 1.1  2003/03/27 16:36:45  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.STD_LOGIC_ARITH.all;

--library preprocessing_rtl;
library work;
--use preprocessing_rtl.preprocessing_pkg.all;
use work.preprocessing_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity correlator is
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

end correlator;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of correlator is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type ArrayOfDataReg is array (0 to 15) of std_logic_vector(size_in_g-1 downto 0);
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- *** Registered Data Array ***
  signal data_reg_ar_i  : ArrayOfDataReg;
  signal data_reg_ar_q  : ArrayOfDataReg;

  -- *** Intermediate signals ***
  -- First Real Part 
  signal operand_a0_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a1_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a2_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a3_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a4_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a5_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a6_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a7_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a8_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a9_i  : std_logic_vector(size_in_g downto 0);
  signal operand_a10_i : std_logic_vector(size_in_g downto 0);
  signal operand_a11_i : std_logic_vector(size_in_g downto 0);
  signal operand_a12_i : std_logic_vector(size_in_g downto 0);
  signal operand_a13_i : std_logic_vector(size_in_g downto 0);
  signal operand_a14_i : std_logic_vector(size_in_g downto 0);
  signal operand_a15_i : std_logic_vector(size_in_g downto 0);
  -- Second Real Part                              
  signal operand_b0_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b1_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b2_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b3_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b4_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b5_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b6_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b7_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b8_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b9_i  : std_logic_vector(size_in_g downto 0);
  signal operand_b10_i : std_logic_vector(size_in_g downto 0);
  signal operand_b11_i : std_logic_vector(size_in_g downto 0);
  signal operand_b12_i : std_logic_vector(size_in_g downto 0);
  signal operand_b13_i : std_logic_vector(size_in_g downto 0);
  signal operand_b14_i : std_logic_vector(size_in_g downto 0);
  signal operand_b15_i : std_logic_vector(size_in_g downto 0);
                                                   
  -- First Imaginary Part                          
  signal operand_a0_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a1_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a2_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a3_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a4_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a5_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a6_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a7_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a8_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a9_q  : std_logic_vector(size_in_g downto 0);
  signal operand_a10_q : std_logic_vector(size_in_g downto 0);
  signal operand_a11_q : std_logic_vector(size_in_g downto 0);
  signal operand_a12_q : std_logic_vector(size_in_g downto 0);
  signal operand_a13_q : std_logic_vector(size_in_g downto 0);
  signal operand_a14_q : std_logic_vector(size_in_g downto 0);
  signal operand_a15_q : std_logic_vector(size_in_g downto 0);
  -- Second Imaginary Part                         
  signal operand_b0_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b1_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b2_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b3_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b4_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b5_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b6_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b7_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b8_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b9_q  : std_logic_vector(size_in_g downto 0);
  signal operand_b10_q : std_logic_vector(size_in_g downto 0);
  signal operand_b11_q : std_logic_vector(size_in_g downto 0);
  signal operand_b12_q : std_logic_vector(size_in_g downto 0);
  signal operand_b13_q : std_logic_vector(size_in_g downto 0);
  signal operand_b14_q : std_logic_vector(size_in_g downto 0);
  signal operand_b15_q : std_logic_vector(size_in_g downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- Operand Calculation
  -----------------------------------------------------------------------------
  -- For optimization, the calculation is split.
  -- operandaj_ai = coeff_ji * data_reg_j
  -- operandaj_ai = coeff_ji * data_reg_j
  -- data_out_i = 
  -- data_out_q =  ....

  -- stage 0
  complex_mult_corr_0: complex_mult_corr
    generic map (
      size_in_g => size_in_g)
    port map (
        data_in_i   => data_reg0_i,
        data_in_q   => data_reg0_q,
        coeff_i     => coeff0_i,
        coeff_q     => coeff0_q,
        operand_a_i => operand_a0_i,
        operand_a_q => operand_a0_q,
        operand_b_i => operand_b0_i,
        operand_b_q => operand_b0_q
        );
  
  -- stage 1
   complex_mult_corr_1: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg1_i,
        data_in_q   => data_reg1_q,
        coeff_i     => coeff1_i,
        coeff_q     => coeff1_q,
        operand_a_i => operand_a1_i,
        operand_a_q => operand_a1_q,
        operand_b_i => operand_b1_i,
        operand_b_q => operand_b1_q
        );

  -- stage 2
   complex_mult_corr_2: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg2_i,
        data_in_q   => data_reg2_q,
        coeff_i     => coeff2_i,
        coeff_q     => coeff2_q,
        operand_a_i => operand_a2_i,
        operand_a_q => operand_a2_q,
        operand_b_i => operand_b2_i,
        operand_b_q => operand_b2_q
        );
  
  -- stage 3
   complex_mult_corr_3: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg3_i,
        data_in_q   => data_reg3_q,
        coeff_i     => coeff3_i,
        coeff_q     => coeff3_q,
        operand_a_i => operand_a3_i,
        operand_a_q => operand_a3_q,
        operand_b_i => operand_b3_i,
        operand_b_q => operand_b3_q
        );

  -- stage 4
   complex_mult_corr_4: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg4_i,
        data_in_q   => data_reg4_q,
        coeff_i     => coeff4_i,
        coeff_q     => coeff4_q,
        operand_a_i => operand_a4_i,
        operand_a_q => operand_a4_q,
        operand_b_i => operand_b4_i,
        operand_b_q => operand_b4_q
        );
  
  -- stage 5
   complex_mult_corr_5: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg5_i,
        data_in_q   => data_reg5_q,
        coeff_i     => coeff5_i,
        coeff_q     => coeff5_q,
        operand_a_i => operand_a5_i,
        operand_a_q => operand_a5_q,
        operand_b_i => operand_b5_i,
        operand_b_q => operand_b5_q
        );
  
  -- stage 6
   complex_mult_corr_6: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg6_i,
        data_in_q   => data_reg6_q,
        coeff_i     => coeff6_i,
        coeff_q     => coeff6_q,
        operand_a_i => operand_a6_i,
        operand_a_q => operand_a6_q,
        operand_b_i => operand_b6_i,
        operand_b_q => operand_b6_q
        );
  
  -- stage 7
   complex_mult_corr_7: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg7_i,
        data_in_q   => data_reg7_q,
        coeff_i     => coeff7_i,
        coeff_q     => coeff7_q,
        operand_a_i => operand_a7_i,
        operand_a_q => operand_a7_q,
        operand_b_i => operand_b7_i,
        operand_b_q => operand_b7_q
        );
  
  -- stage 8
   complex_mult_corr_8: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg8_i,
        data_in_q   => data_reg8_q,
        coeff_i     => coeff8_i,
        coeff_q     => coeff8_q,
        operand_a_i => operand_a8_i,
        operand_a_q => operand_a8_q,
        operand_b_i => operand_b8_i,
        operand_b_q => operand_b8_q
        );
  
  -- stage 9
   complex_mult_corr_9: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg9_i,
        data_in_q   => data_reg9_q,
        coeff_i     => coeff9_i,
        coeff_q     => coeff9_q,
        operand_a_i => operand_a9_i,
        operand_a_q => operand_a9_q,
        operand_b_i => operand_b9_i,
        operand_b_q => operand_b9_q
        );
  
  -- stage 10
   complex_mult_corr_10: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg10_i,
        data_in_q   => data_reg10_q,
        coeff_i     => coeff10_i,
        coeff_q     => coeff10_q,
        operand_a_i => operand_a10_i,
        operand_a_q => operand_a10_q,
        operand_b_i => operand_b10_i,
        operand_b_q => operand_b10_q
        );
  
  -- stage 11
   complex_mult_corr_11: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg11_i,
        data_in_q   => data_reg11_q,
        coeff_i     => coeff11_i,
        coeff_q     => coeff11_q,
        operand_a_i => operand_a11_i,
        operand_a_q => operand_a11_q,
        operand_b_i => operand_b11_i,
        operand_b_q => operand_b11_q
        );
  
  -- stage 12
   complex_mult_corr_12: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg12_i,
        data_in_q   => data_reg12_q,
        coeff_i     => coeff12_i,
        coeff_q     => coeff12_q,
        operand_a_i => operand_a12_i,
        operand_a_q => operand_a12_q,
        operand_b_i => operand_b12_i,
        operand_b_q => operand_b12_q
        );
  
  -- stage 13
   complex_mult_corr_13: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg13_i,
        data_in_q   => data_reg13_q,
        coeff_i     => coeff13_i,
        coeff_q     => coeff13_q,
        operand_a_i => operand_a13_i,
        operand_a_q => operand_a13_q,
        operand_b_i => operand_b13_i,
        operand_b_q => operand_b13_q
        );
  
  -- stage 14
   complex_mult_corr_14: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg14_i,
        data_in_q   => data_reg14_q,
        coeff_i     => coeff14_i,
        coeff_q     => coeff14_q,
        operand_a_i => operand_a14_i,
        operand_a_q => operand_a14_q,
        operand_b_i => operand_b14_i,
        operand_b_q => operand_b14_q
        );
  
  -- stage 15
   complex_mult_corr_15: complex_mult_corr
      generic map (
        size_in_g => size_in_g)
      port map (
        data_in_i   => data_reg15_i,
        data_in_q   => data_reg15_q,
        coeff_i     => coeff15_i,
        coeff_q     => coeff15_q,
        operand_a_i => operand_a15_i,
        operand_a_q => operand_a15_q,
        operand_b_i => operand_b15_i,
        operand_b_q => operand_b15_q
        );

  -----------------------------------------------------------------------------
  -- Operation tree easy to optimized by any synthetizor
  -----------------------------------------------------------------------------
  -- Real Part
  data_out_i <=(sxt(sxt(sxt(sxt(operand_a0_i,  size_in_g+2)
                  +sxt(operand_b0_i,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a1_i,  size_in_g+2)
                  +sxt(operand_b1_i,  size_in_g+2), size_in_g+3),size_in_g+4)

          +sxt(sxt(sxt(operand_a2_i,  size_in_g+2)
                  +sxt(operand_b2_i,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a3_i,  size_in_g+2)
                  +sxt(operand_b3_i,  size_in_g+2), size_in_g+3),size_in_g+4),size_in_g+5)

      +sxt(sxt(sxt(sxt(operand_a4_i,  size_in_g+2)
                  +sxt(operand_b4_i,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a5_i,  size_in_g+2)
                  +sxt(operand_b5_i,  size_in_g+2), size_in_g+3),size_in_g+4)

          +sxt(sxt(sxt(operand_a6_i,  size_in_g+2)
                  +sxt(operand_b6_i,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a7_i,  size_in_g+2)
                  +sxt(operand_b7_i,  size_in_g+2), size_in_g+3),size_in_g+4),size_in_g+5))

  +   (sxt(sxt(sxt(sxt(operand_a8_i,  size_in_g+2)
                  +sxt(operand_b8_i,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a9_i,  size_in_g+2)
                  +sxt(operand_b9_i,  size_in_g+2), size_in_g+3),size_in_g+4)

          +sxt(sxt(sxt(operand_a10_i, size_in_g+2)
                  +sxt(operand_b10_i, size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a11_i, size_in_g+2)
                  +sxt(operand_b11_i, size_in_g+2), size_in_g+3),size_in_g+4),size_in_g+5)

      +sxt(sxt(sxt(sxt(operand_a12_i, size_in_g+2)
                  +sxt(operand_b12_i, size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a13_i, size_in_g+2)
                  +sxt(operand_b13_i, size_in_g+2), size_in_g+3),size_in_g+4)

          +sxt(sxt(sxt(operand_a14_i, size_in_g+2)
                  +sxt(operand_b14_i, size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a15_i, size_in_g+2)
                  +sxt(operand_b15_i, size_in_g+2), size_in_g+3),size_in_g+4),size_in_g+5));

  -- Imaginary Part
  data_out_q <=(sxt(sxt(sxt(sxt(operand_a0_q,  size_in_g+2)
                  +sxt(operand_b0_q,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a1_q,  size_in_g+2)
                  +sxt(operand_b1_q,  size_in_g+2), size_in_g+3),size_in_g+4)

          +sxt(sxt(sxt(operand_a2_q,  size_in_g+2)
                  +sxt(operand_b2_q,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a3_q,  size_in_g+2)
                  +sxt(operand_b3_q,  size_in_g+2), size_in_g+3),size_in_g+4),size_in_g+5)

      +sxt(sxt(sxt(sxt(operand_a4_q,  size_in_g+2)
                  +sxt(operand_b4_q,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a5_q,  size_in_g+2)
                  +sxt(operand_b5_q,  size_in_g+2), size_in_g+3),size_in_g+4)

          +sxt(sxt(sxt(operand_a6_q,  size_in_g+2)
                  +sxt(operand_b6_q,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a7_q,  size_in_g+2)
                  +sxt(operand_b7_q,  size_in_g+2), size_in_g+3),size_in_g+4),size_in_g+5))

  +   (sxt(sxt(sxt(sxt(operand_a8_q,  size_in_g+2)
                  +sxt(operand_b8_q,  size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a9_q,  size_in_g+2)
                  +sxt(operand_b9_q,  size_in_g+2), size_in_g+3),size_in_g+4)

          +sxt(sxt(sxt(operand_a10_q, size_in_g+2)
                  +sxt(operand_b10_q, size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a11_q, size_in_g+2)
                  +sxt(operand_b11_q, size_in_g+2), size_in_g+3),size_in_g+4),size_in_g+5)

      +sxt(sxt(sxt(sxt(operand_a12_q, size_in_g+2)
                  +sxt(operand_b12_q, size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a13_q, size_in_g+2)
                  +sxt(operand_b13_q, size_in_g+2), size_in_g+3),size_in_g+4)

          +sxt(sxt(sxt(operand_a14_q, size_in_g+2)
                  +sxt(operand_b14_q, size_in_g+2), size_in_g+3)
              +sxt(sxt(operand_a15_q, size_in_g+2)
                  +sxt(operand_b15_q, size_in_g+2), size_in_g+3),size_in_g+4),size_in_g+5));

   
end RTL;
