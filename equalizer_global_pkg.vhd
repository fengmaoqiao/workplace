
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: equalizer_global_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Global package for test.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/equalizer/vhdl/rtl/equalizer_global_pkg.vhd,v  
--  Log: equalizer_global_pkg.vhd,v  
-- Revision 1.5  2004/08/24 13:44:39  arisse
-- Added globals for testbench.
--
-- Revision 1.4  2002/07/31 13:07:04  Dr.B
-- new size.
--
-- Revision 1.3  2002/06/27 16:15:49  Dr.B
-- generics added - other global added.
--
-- Revision 1.2  2002/05/07 16:52:47  Dr.A
-- Added error signals.
--
-- Revision 1.1  2002/03/28 13:48:56  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--library equalizer_rtl;
library work;
--use equalizer_rtl.equalizer_pkg.all;
use work.equalizer_pkg.all;


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package equalizer_global_pkg is
    constant dsize_ct   : integer := 8;           -- Data Input size
    constant shifta_ct  : integer := 14;          -- data size after shifting by alpha.
    constant cacsize_ct : integer := 19;          -- accumulated coeff size  
    constant csize_ct   : integer := 8;           -- Coeff size (output)
    constant coeff_ct   : integer := 36;  -- Number of filter coefficients (31 to 50)

    constant csize_g    : integer := 8;  -- Coefficient size

    -- generics for DC_output calculation
    constant dccoeff_ct  : integer := 19;  -- numbers of bits kept from coeff to calc sum.
    constant sum_ct      : integer := 8;         -- data size of the sum
    constant multerr_ct  : integer := 12;         -- data size after the mult by error
    constant shiftb_ct   : integer := 12;         -- data size after shifting by beta
    constant dcacsize_ct : integer := 17;         -- accumulated dc_offset size  
    constant dcsize_ct   : integer := 6;           -- DC_offset size (output)
    constant outsize_ct  : integer := 9;

   type ArrayOfSLVcsize is array        ( 0 to coeff_ct-1) of
                                     std_logic_vector(csize_ct-1 downto 0); 
  type ArrayOfSLVshiftasize is array    (0 to coeff_ct-1) of 
                                     std_logic_vector(shifta_ct-1 downto 0); 
  type ArrayOfSLVdsize1 is array        (0 to coeff_ct-1) of 
                                     std_logic_vector(dsize_ct downto 0); 
  type ArrayOfSLVcacsize is array       (0 to coeff_ct-1) of 
                                     std_logic_vector(cacsize_ct-1 downto 0); 
--------------------------------------------------------------------------------
-- Global signals
--------------------------------------------------------------------------------
  signal array_coeffi_tglobal     : ArrayOfSLVcsize;
  signal array_coeffq_tglobal     : ArrayOfSLVcsize;
  signal array_add_i_ff1_tglobal  : ArrayOfSLVcacsize;
  signal array_add_q_ff1_tglobal  : ArrayOfSLVcacsize;
  signal prod_i_tglobal           : ArrayOfSLVdsize1;
  signal prod_q_tglobal           : ArrayOfSLVdsize1;
  signal shift_i_tglobal          : ArrayOfSLVshiftasize;
  signal shift_q_tglobal          : ArrayOfSLVshiftasize;
  signal tk_i_out_tglobal : std_logic_vector(outsize_ct-1 downto 0);
  signal tk_q_out_tglobal : std_logic_vector(outsize_ct-1 downto 0);

  signal dc_offset_i_tglobal      : std_logic_vector(dcsize_ct-1 downto 0);
  signal dc_offset_q_tglobal      : std_logic_vector(dcsize_ct-1 downto 0);
  signal data_i_tglobal           : std_logic_vector(outsize_ct-1 downto 0);
  signal data_q_tglobal           : std_logic_vector(outsize_ct-1 downto 0);
  signal error_i_tglobal          : std_logic_vector(dsize_ct-1 downto 0); 
  signal error_q_tglobal          : std_logic_vector(dsize_ct-1 downto 0);

  -- For save_modem.vhd
  signal coeff_i0_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i1_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i2_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i3_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i4_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i5_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i6_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i7_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i8_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i9_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i10_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i11_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i12_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i13_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i14_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i15_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i16_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i17_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i18_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i19_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i20_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i21_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i22_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i23_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i24_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i25_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i26_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i27_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i28_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i29_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i30_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i31_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i32_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i33_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i34_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i35_est_gbl    : std_logic_vector(csize_g-1 downto 0);                   
  signal coeff_q0_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q1_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q2_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q3_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q4_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q5_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q6_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q7_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q8_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q9_est_gbl     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q10_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q11_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q12_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q13_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q14_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q15_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q16_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q17_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q18_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q19_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q20_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q21_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q22_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q23_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q24_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q25_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q26_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q27_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q28_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q29_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q30_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q31_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q32_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q33_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q34_est_gbl    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q35_est_gbl    : std_logic_vector(csize_g-1 downto 0);
    
  signal error_i_gbl          : std_logic_vector(outsize_ct-1 downto 0); 
  signal error_q_gbl          : std_logic_vector(outsize_ct-1 downto 0);
  signal delta1_i_gbl         : std_logic_vector(outsize_ct-1 downto 0);
  signal delta1_q_gbl         : std_logic_vector(outsize_ct-1 downto 0); 
     
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
 
end equalizer_global_pkg;
