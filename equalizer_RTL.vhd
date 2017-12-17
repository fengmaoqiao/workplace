
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: equalizer.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.16   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Feedforward Equalizer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/equalizer/vhdl/rtl/equalizer.vhd,v  
--  Log: equalizer.vhd,v  
-- Revision 1.16  2005/01/24 14:14:25  arisse
-- #BugId:624#
-- Added status signals for registers.
--
-- Revision 1.15  2004/08/24 13:44:33  arisse
-- Added globals for testbench.
--
-- Revision 1.14  2004/03/15 13:07:49  Dr.B
-- Added saturation on error_i/q calculus.
--
-- Revision 1.13  2003/10/16 16:18:58  arisse
-- Changed diag_error_i/q to 8 bits instead of 9 bits.
--
-- Revision 1.12  2003/10/16 14:21:15  arisse
-- Added diag ports.
--
-- Revision 1.11  2003/09/18 08:37:42  Dr.A
-- Removed unused generics.
--
-- Revision 1.10  2003/09/09 12:58:51  Dr.C
-- Removed power_estim links.
--
-- Revision 1.9  2002/12/03 15:06:32  Dr.B
-- change condition on multiplier sharing.
--
-- Revision 1.8  2002/11/06 17:16:50  Dr.A
-- Changed abs_2 signals size.
--
-- Revision 1.7  2002/10/18 15:34:22  Dr.J
-- Removed the DC Offset
--
-- Revision 1.6  2002/09/19 17:00:37  Dr.A
-- Added ports to use a multiplier from outside.
-- data size debug.
--
-- Revision 1.5  2002/07/31 13:06:51  Dr.B
-- new size.
--
-- Revision 1.4  2002/07/11 12:36:39  Dr.B
-- delay_g in half-chip.
--
-- Revision 1.3  2002/06/27 16:15:27  Dr.B
-- synchro with matlab changes.
--
-- Revision 1.2  2002/05/07 16:52:09  Dr.A
-- Corrected structure and blocks.
--
-- Revision 1.1  2002/03/28 13:48:54  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all; 

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
entity equalizer is
  generic (
    dsize_g : integer := 8;  -- Input data size
    csize_g : integer := 8;  -- Coefficient size 
    coeff_g : integer := 36; -- Number of filter coefficients 
    delay_g : integer := 44; -- Delay for remodulation (in half-chip)
    
    -- for ffwd_estimation:
    -- generics for coefficients calculation
    shifta_g : integer := 14;  -- data size after shifting by alpha.
    cacsize_g: integer := 19;  -- accumulated coeff size  

    -- generics for DC_output calculation
    dccoeff_g : integer := 19; -- numbers of bits kept from coeff to calc sum.
    sum_g     : integer := 8; -- data size of the sum
    multerr_g : integer := 12; -- data size after the mult by error
    shiftb_g  : integer := 14; -- data size after shifting by beta
    dcacsize_g: integer := 17; -- accumulated dc_offset size  
    dcsize_g  : integer := 6;   -- DC_offset size (output)
    outsize_g : integer := 9;
    p_size_g  : integer := 4 -- nb of input bits from correlator for peak_detect
    
  );
  port (
    -------------------------------
    -- reset and clock
    -------------------------------
    reset_n         : in  std_logic; 
    clk             : in  std_logic;
    -------------------------------
    -- Control signals
    -------------------------------
    equ_activate    : in std_logic;  -- activate the block
    equalizer_init_n: in  std_logic; -- filter coeffs= 0  when low.
    equalizer_disb  : in  std_logic; -- Disable the filter when high.
                                     -- data_in are shifted to data_out 
    data_sync       : in  std_logic; -- Pulse at first data.
    alpha_accu_disb : in  std_logic; -- stop coeff accu when high
    beta_accu_disb  : in  std_logic; -- stop dc accu when high
    -------------------------------
    -- Equalizer inputs
    -------------------------------
    -- Incoming data stream at 22 MHz (I and Q).
    data_fil_i      : in  std_logic_vector(dsize_g-1 downto 0);
    data_fil_q      : in  std_logic_vector(dsize_g-1 downto 0);
    -- Remodulated data at 11 MHz (I and Q).
    remod_data_i    : in  std_logic_vector(outsize_g-1 downto 0);
    remod_data_q    : in  std_logic_vector(outsize_g-1 downto 0);
    -- Equalizer parameters.
    alpha           : in  std_logic_vector(2 downto 0);
    beta            : in  std_logic_vector(2 downto 0);
    -- Data to multiply  when equ is disable for peak detector
    d_signed_peak_i   : in  std_logic_vector(p_size_g-1 downto 0);
    d_signed_peak_q   : in  std_logic_vector(p_size_g-1 downto 0);
    -------------------------------
    -- Equalizer outputs
    -------------------------------
    equalized_data_i      : out std_logic_vector(outsize_g-1 downto 0);
    equalized_data_q      : out std_logic_vector(outsize_g-1 downto 0);    
    -- Output for peak_detect
    abs_2_corr            : out std_logic_vector (2*p_size_g-1 downto 0);

    -- Register stat
    coeff_sum_i_stat : out std_logic_vector(sum_g-1 downto 0);
    coeff_sum_q_stat : out std_logic_vector(sum_g-1 downto 0);
    
    -- DC Offset outputs.
    dc_offset_i      : out std_logic_vector(dcsize_g-1 downto 0);
    dc_offset_q      : out std_logic_vector(dcsize_g-1 downto 0);
    
    -------------------------------
    -- Diag ports
    -------------------------------
    diag_error_i     : out std_logic_vector(outsize_g-2 downto 0); 
    diag_error_q     : out std_logic_vector(outsize_g-2 downto 0)
  );

end equalizer;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of equalizer is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type ArrayOfSLVdsize is array (natural range <>) of 
                                     std_logic_vector(dsize_g-1 downto 0); 
  type ArrayOfSLVoutsize is array (natural range <>) of 
                                     std_logic_vector(outsize_g-1 downto 0); 
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- zero for saturation
  constant zero_for_delta0  : std_logic_vector(dsize_g-3 downto 0):=(others => '0');  
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Data with DC offset compensation
  signal data_dc_i        : std_logic_vector(dsize_g-1 downto 0);
  signal data_dc_q        : std_logic_vector(dsize_g-1 downto 0);  
  -- Counter for chip synchronization
  signal chip_counter     : std_logic_vector(1 downto 0);
  signal div_counter      : std_logic_vector(1 downto 0);
  -- Delta1 delay line (for error calculation).
  signal array_delta1_i   : ArrayOfSLVoutsize((delay_g/2-1) downto 0);
  signal array_delta1_q   : ArrayOfSLVoutsize((delay_g/2-1) downto 0);
  signal delta1_odd_i     : std_logic_vector(outsize_g-1 downto 0);
  signal delta1_odd_q     : std_logic_vector(outsize_g-1 downto 0);
  signal delta1_i         : std_logic_vector(outsize_g-1 downto 0);
  signal delta1_q         : std_logic_vector(outsize_g-1 downto 0);
  
  -- Estimation input signals
  -- Output of filter:
  -- Even if the filter is disabled, tk_out will contain result of filter 
  signal tk_i_out         : std_logic_vector(outsize_g-1 downto 0);
  signal tk_q_out         : std_logic_vector(outsize_g-1 downto 0);
  -- Error :
  signal error_i_tmp      : std_logic_vector(outsize_g   downto 0); 
  signal error_q_tmp      : std_logic_vector(outsize_g   downto 0);  
  signal error_i          : std_logic_vector(outsize_g-1 downto 0); 
  signal error_q          : std_logic_vector(outsize_g-1 downto 0); 
  
  -- Delta0 delay line input signals
  signal delta0_in        : std_logic_vector(dsize_g-1 downto 0);
  --                        mix of i/q ff34 and ff35 
  signal delta0_in_sat    : std_logic_vector(dsize_g-1 downto 0);
  --                        saturated delta0_in
  -- Delta0 delay line (for comparing remod data with correspondant input).  
  signal array_delta0     : ArrayOfSLVdsize(2*(delay_g-15-18) downto 0);
  -- Delta0 outputs
  signal delta0_i_out      : std_logic_vector(dsize_g-1 downto 0);
  signal delta0_q_out      : std_logic_vector(dsize_g-1 downto 0);
    
  -- Filter input signals
  signal filter_shift     : std_logic; -- Shift filter delay line.
  -- Signals to sample input data at 22 MHz for filter delay lines.
  signal even_data_i      : std_logic_vector(dsize_g-1 downto 0);
  signal odd_data_i       : std_logic_vector(dsize_g-1 downto 0);
  signal even_data_q      : std_logic_vector(dsize_g-1 downto 0);
  signal odd_data_q       : std_logic_vector(dsize_g-1 downto 0); 
  -- I signals from filter delay line at 22 MHz
  signal data_i_ff0       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff1       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff2       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff3       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff4       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff5       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff6       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff7       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff8       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff9       : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff10      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff11      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff12      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff13      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff14      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff15      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff16      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff17      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff18      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff19      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff20      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff21      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff22      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff23      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff24      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff25      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff26      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff27      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff28      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff29      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff30      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff31      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff32      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff33      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff34      : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff35      : std_logic_vector(dsize_g-1 downto 0);
  -- Q signals from filter delay line at 22 MHz
  signal data_q_ff0       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff1       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff2       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff3       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff4       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff5       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff6       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff7       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff8       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff9       : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff10      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff11      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff12      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff13      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff14      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff15      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff16      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff17      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff18      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff19      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff20      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff21      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff22      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff23      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff24      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff25      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff26      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff27      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff28      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff29      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff30      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff31      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff32      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff33      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff34      : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff35      : std_logic_vector(dsize_g-1 downto 0);
  -- Estimated I filters coefficients
  signal coeff_i0_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i1_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i2_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i3_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i4_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i5_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i6_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i7_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i8_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i9_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i10_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i11_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i12_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i13_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i14_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i15_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i16_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i17_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i18_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i19_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i20_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i21_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i22_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i23_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i24_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i25_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i26_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i27_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i28_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i29_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i30_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i31_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i32_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i33_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i34_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_i35_est    : std_logic_vector(csize_g-1 downto 0);                   
  -- Estimated Q filters coefficients
  signal coeff_q0_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q1_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q2_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q3_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q4_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q5_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q6_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q7_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q8_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q9_est     : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q10_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q11_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q12_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q13_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q14_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q15_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q16_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q17_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q18_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q19_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q20_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q21_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q22_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q23_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q24_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q25_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q26_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q27_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q28_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q29_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q30_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q31_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q32_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q33_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q34_est    : std_logic_vector(csize_g-1 downto 0);
  signal coeff_q35_est    : std_logic_vector(csize_g-1 downto 0);
   
  -- I data delayed for estimation (from delta0 line)
  signal data_i_ff0_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff1_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff2_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff3_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff4_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff5_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff6_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff7_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff8_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff9_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff10_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff11_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff12_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff13_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff14_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff15_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff16_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff17_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff18_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff19_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff20_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff21_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff22_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff23_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff24_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff25_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff26_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff27_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff28_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff29_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff30_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff31_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff32_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff33_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff34_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_i_ff35_dly0 : std_logic_vector(dsize_g-1 downto 0);

  -- Q data delayed for estimation (from delta0 line)
  signal data_q_ff0_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff1_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff2_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff3_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff4_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff5_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff6_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff7_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff8_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff9_dly0  : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff10_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff11_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff12_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff13_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff14_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff15_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff16_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff17_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff18_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff19_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff20_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff21_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff22_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff23_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff24_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff25_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff26_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff27_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff28_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff29_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff30_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff31_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff32_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff33_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff34_dly0 : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff35_dly0 : std_logic_vector(dsize_g-1 downto 0);

  -- Estimation outputs.

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- ********************************* EQUALIZER ******************************
  -----------------------------------------------------------------------------
  -------------------------------------
  -- dc_offset compensation
  -------------------------------------
  
--   data_dc_i <= signed(data_fil_i)
--             - signed(dc_offset_i);
--   data_dc_q <= signed(data_fil_q)
--             - signed(dc_offset_q);

  -------------------------------------
  -- split data into odd/even registers.
  -------------------------------------
  even_data_i <= data_fil_i;
  even_data_q <= data_fil_q;
    sampl22_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      odd_data_i  <= (others => '0');
      odd_data_q  <= (others => '0');
    elsif clk'event and clk = '1' then
      if chip_counter(0) = '1' then
        odd_data_i  <= even_data_i;        
        odd_data_q  <= even_data_q;
      end if;
    end if;
  end process sampl22_pr;  

  -------------------------------------
  -- I filter delay line for even data
  -------------------------------------
  delay_line_even_i: delay_line18
  generic map (
    dsize_g             => dsize_g
  )
  port map (
      reset_n             => reset_n,
      clk                 => clk,
      data_in             => even_data_i,
      shift               => filter_shift,      
      data_ff0            => data_i_ff0,
      data_ff1            => data_i_ff2,
      data_ff2            => data_i_ff4,
      data_ff3            => data_i_ff6,
      data_ff4            => data_i_ff8,
      data_ff5            => data_i_ff10,
      data_ff6            => data_i_ff12,
      data_ff7            => data_i_ff14,
      data_ff8            => data_i_ff16,
      data_ff9            => data_i_ff18,
      data_ff10           => data_i_ff20,
      data_ff11           => data_i_ff22,
      data_ff12           => data_i_ff24,
      data_ff13           => data_i_ff26,
      data_ff14           => data_i_ff28,
      data_ff15           => data_i_ff30,
      data_ff16           => data_i_ff32,
      data_ff17           => data_i_ff34
      );
  -------------------------------------
  -- I filter delay line for odd data
  -------------------------------------
  delay_line_odd_i: delay_line18
  generic map (
    dsize_g             => dsize_g
  )
  port map (
      reset_n             => reset_n,
      clk                 => clk,
      data_in             => odd_data_i,
      shift               => filter_shift,      
      data_ff0            => data_i_ff1,
      data_ff1            => data_i_ff3,
      data_ff2            => data_i_ff5,
      data_ff3            => data_i_ff7,
      data_ff4            => data_i_ff9,
      data_ff5            => data_i_ff11,
      data_ff6            => data_i_ff13,
      data_ff7            => data_i_ff15,
      data_ff8            => data_i_ff17,
      data_ff9            => data_i_ff19,
      data_ff10           => data_i_ff21,
      data_ff11           => data_i_ff23,
      data_ff12           => data_i_ff25,
      data_ff13           => data_i_ff27,
      data_ff14           => data_i_ff29,
      data_ff15           => data_i_ff31,
      data_ff16           => data_i_ff33,
      data_ff17           => data_i_ff35
      );


  -------------------------------------
  -- Q filter delay line for even data
  -------------------------------------
  delay_line_even_q: delay_line18
  generic map (
    dsize_g             => dsize_g
  )
  port map (
      reset_n             => reset_n,
      clk                 => clk,
      data_in             => even_data_q,
      shift               => filter_shift,      
      data_ff0            => data_q_ff0,
      data_ff1            => data_q_ff2,
      data_ff2            => data_q_ff4,
      data_ff3            => data_q_ff6,
      data_ff4            => data_q_ff8,
      data_ff5            => data_q_ff10,
      data_ff6            => data_q_ff12,
      data_ff7            => data_q_ff14,
      data_ff8            => data_q_ff16,
      data_ff9            => data_q_ff18,
      data_ff10           => data_q_ff20,
      data_ff11           => data_q_ff22,
      data_ff12           => data_q_ff24,
      data_ff13           => data_q_ff26,
      data_ff14           => data_q_ff28,
      data_ff15           => data_q_ff30,
      data_ff16           => data_q_ff32,
      data_ff17           => data_q_ff34
      );
      
  -------------------------------------
  -- Q filter delay line for odd data
  -------------------------------------
  delay_line_odd_q: delay_line18
  generic map (
    dsize_g             => dsize_g
  )
  port map (
      reset_n             => reset_n,
      clk                 => clk,
      data_in             => odd_data_q,
      shift               => filter_shift,      
      data_ff0            => data_q_ff1,
      data_ff1            => data_q_ff3,
      data_ff2            => data_q_ff5,
      data_ff3            => data_q_ff7,
      data_ff4            => data_q_ff9,
      data_ff5            => data_q_ff11,
      data_ff6            => data_q_ff13,
      data_ff7            => data_q_ff15,
      data_ff8            => data_q_ff17,
      data_ff9            => data_q_ff19,
      data_ff10           => data_q_ff21,
      data_ff11           => data_q_ff23,
      data_ff12           => data_q_ff25,
      data_ff13           => data_q_ff27,
      data_ff14           => data_q_ff29,
      data_ff15           => data_q_ff31,
      data_ff16           => data_q_ff33,
      data_ff17           => data_q_ff35
      );


            
                               
  -------------------------------------
  -- Equalizer filter.
  -------------------------------------
  ffwd_filter_1: ffwd_filter
  generic map (
      dsize_g               => dsize_g,
      csize_g               => csize_g,
      outsize_g             => outsize_g
  )
  port map (
      -- Clock and reset
      reset_n               => reset_n,
      clk                   => clk,
      -- Counter for filter speed
      div_counter           => chip_counter,
      equalizer_disb        => equalizer_disb,
      equalizer_init_n      => equalizer_init_n,
      -- Data to multiply  when equ is disable for peak detector
      d_signed_peak_i       => d_signed_peak_i,
      d_signed_peak_q       => d_signed_peak_q,
      
      -- Filter inputs from I delay line
      data_i_ff0            => data_i_ff0,
      data_i_ff1            => data_i_ff1,
      data_i_ff2            => data_i_ff2,
      data_i_ff3            => data_i_ff3,
      data_i_ff4            => data_i_ff4,
      data_i_ff5            => data_i_ff5,
      data_i_ff6            => data_i_ff6,
      data_i_ff7            => data_i_ff7,
      data_i_ff8            => data_i_ff8,
      data_i_ff9            => data_i_ff9,
      data_i_ff10           => data_i_ff10,
      data_i_ff11           => data_i_ff11,
      data_i_ff12           => data_i_ff12,
      data_i_ff13           => data_i_ff13,
      data_i_ff14           => data_i_ff14,
      data_i_ff15           => data_i_ff15,
      data_i_ff16           => data_i_ff16,
      data_i_ff17           => data_i_ff17,
      data_i_ff18           => data_i_ff18,
      data_i_ff19           => data_i_ff19,
      data_i_ff20           => data_i_ff20,
      data_i_ff21           => data_i_ff21,
      data_i_ff22           => data_i_ff22,
      data_i_ff23           => data_i_ff23,
      data_i_ff24           => data_i_ff24,
      data_i_ff25           => data_i_ff25,
      data_i_ff26           => data_i_ff26,
      data_i_ff27           => data_i_ff27,
      data_i_ff28           => data_i_ff28,
      data_i_ff29           => data_i_ff29,
      data_i_ff30           => data_i_ff30,
      data_i_ff31           => data_i_ff31,
      data_i_ff32           => data_i_ff32,
      data_i_ff33           => data_i_ff33,
      data_i_ff34           => data_i_ff34,
      data_i_ff35           => data_i_ff35,
      
      -- Filter inputs from Q delay line
      data_q_ff0            => data_q_ff0,
      data_q_ff1            => data_q_ff1,
      data_q_ff2            => data_q_ff2,
      data_q_ff3            => data_q_ff3,
      data_q_ff4            => data_q_ff4,
      data_q_ff5            => data_q_ff5,
      data_q_ff6            => data_q_ff6,
      data_q_ff7            => data_q_ff7,
      data_q_ff8            => data_q_ff8,
      data_q_ff9            => data_q_ff9,
      data_q_ff10           => data_q_ff10,
      data_q_ff11           => data_q_ff11,
      data_q_ff12           => data_q_ff12,
      data_q_ff13           => data_q_ff13,
      data_q_ff14           => data_q_ff14,
      data_q_ff15           => data_q_ff15,
      data_q_ff16           => data_q_ff16,
      data_q_ff17           => data_q_ff17,
      data_q_ff18           => data_q_ff18,
      data_q_ff19           => data_q_ff19,
      data_q_ff20           => data_q_ff20,
      data_q_ff21           => data_q_ff21,
      data_q_ff22           => data_q_ff22,
      data_q_ff23           => data_q_ff23,
      data_q_ff24           => data_q_ff24,
      data_q_ff25           => data_q_ff25,
      data_q_ff26           => data_q_ff26,
      data_q_ff27           => data_q_ff27,
      data_q_ff28           => data_q_ff28,
      data_q_ff29           => data_q_ff29,
      data_q_ff30           => data_q_ff30,
      data_q_ff31           => data_q_ff31,
      data_q_ff32           => data_q_ff32,
      data_q_ff33           => data_q_ff33,
      data_q_ff34           => data_q_ff34,
      data_q_ff35           => data_q_ff35,
      
      -- Filter coefficients (real part)
      k_i0                  => coeff_i0_est, 
      k_i1                  => coeff_i1_est, 
      k_i2                  => coeff_i2_est, 
      k_i3                  => coeff_i3_est, 
      k_i4                  => coeff_i4_est, 
      k_i5                  => coeff_i5_est, 
      k_i6                  => coeff_i6_est, 
      k_i7                  => coeff_i7_est, 
      k_i8                  => coeff_i8_est, 
      k_i9                  => coeff_i9_est, 
      k_i10                 => coeff_i10_est,
      k_i11                 => coeff_i11_est,
      k_i12                 => coeff_i12_est,
      k_i13                 => coeff_i13_est,
      k_i14                 => coeff_i14_est,
      k_i15                 => coeff_i15_est,
      k_i16                 => coeff_i16_est,
      k_i17                 => coeff_i17_est,
      k_i18                 => coeff_i18_est,
      k_i19                 => coeff_i19_est,
      k_i20                 => coeff_i20_est,
      k_i21                 => coeff_i21_est,
      k_i22                 => coeff_i22_est,
      k_i23                 => coeff_i23_est,
      k_i24                 => coeff_i24_est,
      k_i25                 => coeff_i25_est,
      k_i26                 => coeff_i26_est,
      k_i27                 => coeff_i27_est,
      k_i28                 => coeff_i28_est,
      k_i29                 => coeff_i29_est,
      k_i30                 => coeff_i30_est,
      k_i31                 => coeff_i31_est,
      k_i32                 => coeff_i32_est,
      k_i33                 => coeff_i33_est,
      k_i34                 => coeff_i34_est,
      k_i35                 => coeff_i35_est,
                                        
      -- Filter coefficients (imaginary part)
      k_q0                  => coeff_q0_est, 
      k_q1                  => coeff_q1_est, 
      k_q2                  => coeff_q2_est, 
      k_q3                  => coeff_q3_est, 
      k_q4                  => coeff_q4_est, 
      k_q5                  => coeff_q5_est, 
      k_q6                  => coeff_q6_est, 
      k_q7                  => coeff_q7_est, 
      k_q8                  => coeff_q8_est, 
      k_q9                  => coeff_q9_est, 
      k_q10                 => coeff_q10_est,
      k_q11                 => coeff_q11_est,
      k_q12                 => coeff_q12_est,
      k_q13                 => coeff_q13_est,
      k_q14                 => coeff_q14_est,
      k_q15                 => coeff_q15_est,
      k_q16                 => coeff_q16_est,
      k_q17                 => coeff_q17_est,
      k_q18                 => coeff_q18_est,
      k_q19                 => coeff_q19_est,
      k_q20                 => coeff_q20_est,
      k_q21                 => coeff_q21_est,
      k_q22                 => coeff_q22_est,
      k_q23                 => coeff_q23_est,
      k_q24                 => coeff_q24_est,
      k_q25                 => coeff_q25_est,
      k_q26                 => coeff_q26_est,
      k_q27                 => coeff_q27_est,
      k_q28                 => coeff_q28_est,
      k_q29                 => coeff_q29_est,
      k_q30                 => coeff_q30_est,
      k_q31                 => coeff_q31_est,
      k_q32                 => coeff_q32_est,
      k_q33                 => coeff_q33_est,
      k_q34                 => coeff_q34_est,
      k_q35                 => coeff_q35_est,
                                        
      -- Filtered outputs               
  -- When the equalizer is disabled, forward input data on output port.
  -- When the equalizer is enabled, send filtered data on output port.
      filter_i_out          => equalized_data_i,
      filter_q_out          => equalized_data_q,
      tk_i_out              => tk_i_out,
      tk_q_out              => tk_q_out,
      abs_2_corr            => abs_2_corr
      );

  --------------------------------------------
  -- Counter process: for 1 or 1/2 chip
  --------------------------------------------
  chip_counter_pr: process (clk, reset_n)                              
  begin                                                              
    if reset_n = '0' then
      chip_counter <= (others => '0');
    elsif clk'event and clk = '1' then
      if data_sync = '1' or equ_activate = '0' then
        chip_counter <= "11";
      else  
        chip_counter <= chip_counter + '1';
      end if;
    end if;
  end process chip_counter_pr;

  -- Shift filter delay line at 11 MHz.
  filter_shift <= '1' when chip_counter = "11" else '0';

  -----------------------------------------------------------------------------
  -- *************************** ESTIMATION ***********************************
  -----------------------------------------------------------------------------
  div_counter <= (not chip_counter(1)) & chip_counter(0);
  ffwd_estimation_1 : ffwd_estimation
    generic map (
      -- generics for coefficients calculation
      dsize_g   => dsize_g,             -- Data Input size
      shifta_g  => shifta_g,            -- data size after shifting by alpha.
      cacsize_g => cacsize_g,           -- accumulated coeff size  
      csize_g   => csize_g,             -- Coeff size (output)
      coeff_g   => coeff_g,    -- Number of filter coefficients (31 to 50)

      -- generics for DC_output calculation
      dccoeff_g  => dccoeff_g,  -- numbers of bits kept from coeff to calc sum.
      sum_g      => sum_g,              -- data size of the sum
      multerr_g  => multerr_g,          -- data size after the mult by error
      shiftb_g   => shiftb_g,           -- data size after shifting by beta
      dcacsize_g => dcacsize_g,         -- accumulated dc_offset size  
      dcsize_g   => dcsize_g,            -- DC_offset size (output)
      outsize_g  => outsize_g
      )
    port map (
      -- Clock and reset
      reset_n => reset_n,
      clk     => clk,

      -- Chip synchronization.
      div_counter      => chip_counter,
      equalizer_init_n => equalizer_init_n,
      -- Demodulation error
      error_i          => error_i,
      error_q          => error_q,
      -- Estimation parameters.
      alpha            => alpha,
      beta             => beta,
      -- Control of accumulation
      alpha_accu_disb  => alpha_accu_disb,
      beta_accu_disb   => beta_accu_disb,

      -- Data from I delay line
      data_i_ff0  => data_i_ff0_dly0,
      data_i_ff1  => data_i_ff1_dly0,
      data_i_ff2  => data_i_ff2_dly0,
      data_i_ff3  => data_i_ff3_dly0,
      data_i_ff4  => data_i_ff4_dly0,
      data_i_ff5  => data_i_ff5_dly0,
      data_i_ff6  => data_i_ff6_dly0,
      data_i_ff7  => data_i_ff7_dly0,
      data_i_ff8  => data_i_ff8_dly0,
      data_i_ff9  => data_i_ff9_dly0,
      data_i_ff10 => data_i_ff10_dly0,
      data_i_ff11 => data_i_ff11_dly0,
      data_i_ff12 => data_i_ff12_dly0,
      data_i_ff13 => data_i_ff13_dly0,
      data_i_ff14 => data_i_ff14_dly0,
      data_i_ff15 => data_i_ff15_dly0,
      data_i_ff16 => data_i_ff16_dly0,
      data_i_ff17 => data_i_ff17_dly0,
      data_i_ff18 => data_i_ff18_dly0,
      data_i_ff19 => data_i_ff19_dly0,
      data_i_ff20 => data_i_ff20_dly0,
      data_i_ff21 => data_i_ff21_dly0,
      data_i_ff22 => data_i_ff22_dly0,
      data_i_ff23 => data_i_ff23_dly0,
      data_i_ff24 => data_i_ff24_dly0,
      data_i_ff25 => data_i_ff25_dly0,
      data_i_ff26 => data_i_ff26_dly0,
      data_i_ff27 => data_i_ff27_dly0,
      data_i_ff28 => data_i_ff28_dly0,
      data_i_ff29 => data_i_ff29_dly0,
      data_i_ff30 => data_i_ff30_dly0,
      data_i_ff31 => data_i_ff31_dly0,
      data_i_ff32 => data_i_ff32_dly0,
      data_i_ff33 => data_i_ff33_dly0,
      data_i_ff34 => data_i_ff34_dly0,
      data_i_ff35 => data_i_ff35_dly0,

      -- Data from Q delay line
      data_q_ff0  => data_q_ff0_dly0,
      data_q_ff1  => data_q_ff1_dly0,
      data_q_ff2  => data_q_ff2_dly0,
      data_q_ff3  => data_q_ff3_dly0,
      data_q_ff4  => data_q_ff4_dly0,
      data_q_ff5  => data_q_ff5_dly0,
      data_q_ff6  => data_q_ff6_dly0,
      data_q_ff7  => data_q_ff7_dly0,
      data_q_ff8  => data_q_ff8_dly0,
      data_q_ff9  => data_q_ff9_dly0,
      data_q_ff10 => data_q_ff10_dly0,
      data_q_ff11 => data_q_ff11_dly0,
      data_q_ff12 => data_q_ff12_dly0,
      data_q_ff13 => data_q_ff13_dly0,
      data_q_ff14 => data_q_ff14_dly0,
      data_q_ff15 => data_q_ff15_dly0,
      data_q_ff16 => data_q_ff16_dly0,
      data_q_ff17 => data_q_ff17_dly0,
      data_q_ff18 => data_q_ff18_dly0,
      data_q_ff19 => data_q_ff19_dly0,
      data_q_ff20 => data_q_ff20_dly0,
      data_q_ff21 => data_q_ff21_dly0,
      data_q_ff22 => data_q_ff22_dly0,
      data_q_ff23 => data_q_ff23_dly0,
      data_q_ff24 => data_q_ff24_dly0,
      data_q_ff25 => data_q_ff25_dly0,
      data_q_ff26 => data_q_ff26_dly0,
      data_q_ff27 => data_q_ff27_dly0,
      data_q_ff28 => data_q_ff28_dly0,
      data_q_ff29 => data_q_ff29_dly0,
      data_q_ff30 => data_q_ff30_dly0,
      data_q_ff31 => data_q_ff31_dly0,
      data_q_ff32 => data_q_ff32_dly0,
      data_q_ff33 => data_q_ff33_dly0,
      data_q_ff34 => data_q_ff34_dly0,
      data_q_ff35 => data_q_ff35_dly0,

      -- Filter coefficients (real part)
      coeff_i0  => coeff_i0_est,
      coeff_i1  => coeff_i1_est,
      coeff_i2  => coeff_i2_est,
      coeff_i3  => coeff_i3_est,
      coeff_i4  => coeff_i4_est,
      coeff_i5  => coeff_i5_est,
      coeff_i6  => coeff_i6_est,
      coeff_i7  => coeff_i7_est,
      coeff_i8  => coeff_i8_est,
      coeff_i9  => coeff_i9_est,
      coeff_i10 => coeff_i10_est,
      coeff_i11 => coeff_i11_est,
      coeff_i12 => coeff_i12_est,
      coeff_i13 => coeff_i13_est,
      coeff_i14 => coeff_i14_est,
      coeff_i15 => coeff_i15_est,
      coeff_i16 => coeff_i16_est,
      coeff_i17 => coeff_i17_est,
      coeff_i18 => coeff_i18_est,
      coeff_i19 => coeff_i19_est,
      coeff_i20 => coeff_i20_est,
      coeff_i21 => coeff_i21_est,
      coeff_i22 => coeff_i22_est,
      coeff_i23 => coeff_i23_est,
      coeff_i24 => coeff_i24_est,
      coeff_i25 => coeff_i25_est,
      coeff_i26 => coeff_i26_est,
      coeff_i27 => coeff_i27_est,
      coeff_i28 => coeff_i28_est,
      coeff_i29 => coeff_i29_est,
      coeff_i30 => coeff_i30_est,
      coeff_i31 => coeff_i31_est,
      coeff_i32 => coeff_i32_est,
      coeff_i33 => coeff_i33_est,
      coeff_i34 => coeff_i34_est,
      coeff_i35 => coeff_i35_est,

      -- Filter coefficients (imaginary part)
      coeff_q0  => coeff_q0_est,
      coeff_q1  => coeff_q1_est,
      coeff_q2  => coeff_q2_est,
      coeff_q3  => coeff_q3_est,
      coeff_q4  => coeff_q4_est,
      coeff_q5  => coeff_q5_est,
      coeff_q6  => coeff_q6_est,
      coeff_q7  => coeff_q7_est,
      coeff_q8  => coeff_q8_est,
      coeff_q9  => coeff_q9_est,
      coeff_q10 => coeff_q10_est,
      coeff_q11 => coeff_q11_est,
      coeff_q12 => coeff_q12_est,
      coeff_q13 => coeff_q13_est,
      coeff_q14 => coeff_q14_est,
      coeff_q15 => coeff_q15_est,
      coeff_q16 => coeff_q16_est,
      coeff_q17 => coeff_q17_est,
      coeff_q18 => coeff_q18_est,
      coeff_q19 => coeff_q19_est,
      coeff_q20 => coeff_q20_est,
      coeff_q21 => coeff_q21_est,
      coeff_q22 => coeff_q22_est,
      coeff_q23 => coeff_q23_est,
      coeff_q24 => coeff_q24_est,
      coeff_q25 => coeff_q25_est,
      coeff_q26 => coeff_q26_est,
      coeff_q27 => coeff_q27_est,
      coeff_q28 => coeff_q28_est,
      coeff_q29 => coeff_q29_est,
      coeff_q30 => coeff_q30_est,
      coeff_q31 => coeff_q31_est,
      coeff_q32 => coeff_q32_est,
      coeff_q33 => coeff_q33_est,
      coeff_q34 => coeff_q34_est,
      coeff_q35 => coeff_q35_est,
      
      -- Register stat
      coeff_sum_i_stat => coeff_sum_i_stat,
      coeff_sum_q_stat => coeff_sum_q_stat,

      -- DC offset.
      dc_offset_i => dc_offset_i,
      dc_offset_q => dc_offset_q
      );

  -----------------------------------------------------------------------------
  --     DELTA 0
  -----------------------------------------------------------------------------
  -- To avoid using muxes, send one data each clock cycle (first i, then q)
  -- and set delay line length to twice the required delay in half chips.
  -- Create delay_line input at 44 MHz from data at 11 MHz.
   with chip_counter select
     delta0_in <=
       data_i_ff34 when "10",
       data_q_ff34 when "11",
       data_i_ff35 when "00",
       data_q_ff35 when others;  

  -----------------------------
  -- Signal saturation
  -----------------------------
  -- the interval [-128;127] becomes [-127;127].
  -- delta0_in <= -127 if delta0_in = -128.
  delta0_in_sat   <= '1'&zero_for_delta0&'1' when delta0_in = '1'&zero_for_delta0&'0'
                     else delta0_in;
  
  -----------------------------
  -- Delta0 delay line to wait for remodulated data.
  -----------------------------
  delta0_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      init_lp: for i in 0 to array_delta0'high loop
        array_delta0(i) <= (others => '0');
      end loop;
    elsif clk'event and clk = '1' then
      if equ_activate = '1' then
        array_delta0(0) <= delta0_in_sat;
        -- Shift registers.
        delay_lp: for i in 1 to array_delta0'high loop
          array_delta0(i) <= array_delta0(i-1); 
        end loop;
      end if;
    end if;
  end process delta0_pr;
  
  -- From delta0 delay line outputs, create estimation delay line input (22 Mhz)
  delta0_i_out <= array_delta0(array_delta0'high-1) when chip_counter(0) = '0'
    else array_delta0(array_delta0'high);
  delta0_q_out <= array_delta0(array_delta0'high-2) when chip_counter(0) = '0'
    else array_delta0(array_delta0'high-1);

  estimation_dly_i: delay_line36
  generic map (
    dsize_g               => dsize_g
  )
  port map (
      reset_n             => reset_n,
      clk                 => clk,
      
      shift               => chip_counter(0),      
      data_in             => delta0_i_out,
      data_ff0_dly        => data_i_ff0_dly0,
      data_ff1_dly        => data_i_ff1_dly0,
      data_ff2_dly        => data_i_ff2_dly0,
      data_ff3_dly        => data_i_ff3_dly0,
      data_ff4_dly        => data_i_ff4_dly0,
      data_ff5_dly        => data_i_ff5_dly0,
      data_ff6_dly        => data_i_ff6_dly0,
      data_ff7_dly        => data_i_ff7_dly0,
      data_ff8_dly        => data_i_ff8_dly0,
      data_ff9_dly        => data_i_ff9_dly0,
      data_ff10_dly       => data_i_ff10_dly0,
      data_ff11_dly       => data_i_ff11_dly0,
      data_ff12_dly       => data_i_ff12_dly0,
      data_ff13_dly       => data_i_ff13_dly0,
      data_ff14_dly       => data_i_ff14_dly0,
      data_ff15_dly       => data_i_ff15_dly0,
      data_ff16_dly       => data_i_ff16_dly0,
      data_ff17_dly       => data_i_ff17_dly0,
      data_ff18_dly       => data_i_ff18_dly0,
      data_ff19_dly       => data_i_ff19_dly0,
      data_ff20_dly       => data_i_ff20_dly0,
      data_ff21_dly       => data_i_ff21_dly0,
      data_ff22_dly       => data_i_ff22_dly0,
      data_ff23_dly       => data_i_ff23_dly0,
      data_ff24_dly       => data_i_ff24_dly0,
      data_ff25_dly       => data_i_ff25_dly0,
      data_ff26_dly       => data_i_ff26_dly0,
      data_ff27_dly       => data_i_ff27_dly0,
      data_ff28_dly       => data_i_ff28_dly0,
      data_ff29_dly       => data_i_ff29_dly0,
      data_ff30_dly       => data_i_ff30_dly0,
      data_ff31_dly       => data_i_ff31_dly0,
      data_ff32_dly       => data_i_ff32_dly0,
      data_ff33_dly       => data_i_ff33_dly0,
      data_ff34_dly       => data_i_ff34_dly0,
      data_ff35_dly       => data_i_ff35_dly0
      );
      
  estimation_dly_q: delay_line36
  generic map (
    dsize_g               => dsize_g
  )
  port map (
      reset_n             => reset_n,
      clk                 => clk,
      
      shift               => chip_counter(0),      
      data_in             => delta0_q_out,
      data_ff0_dly        => data_q_ff0_dly0,
      data_ff1_dly        => data_q_ff1_dly0,
      data_ff2_dly        => data_q_ff2_dly0,
      data_ff3_dly        => data_q_ff3_dly0,
      data_ff4_dly        => data_q_ff4_dly0,
      data_ff5_dly        => data_q_ff5_dly0,
      data_ff6_dly        => data_q_ff6_dly0,
      data_ff7_dly        => data_q_ff7_dly0,
      data_ff8_dly        => data_q_ff8_dly0,
      data_ff9_dly        => data_q_ff9_dly0,
      data_ff10_dly       => data_q_ff10_dly0,
      data_ff11_dly       => data_q_ff11_dly0,
      data_ff12_dly       => data_q_ff12_dly0,
      data_ff13_dly       => data_q_ff13_dly0,
      data_ff14_dly       => data_q_ff14_dly0,
      data_ff15_dly       => data_q_ff15_dly0,
      data_ff16_dly       => data_q_ff16_dly0,
      data_ff17_dly       => data_q_ff17_dly0,
      data_ff18_dly       => data_q_ff18_dly0,
      data_ff19_dly       => data_q_ff19_dly0,
      data_ff20_dly       => data_q_ff20_dly0,
      data_ff21_dly       => data_q_ff21_dly0,
      data_ff22_dly       => data_q_ff22_dly0,
      data_ff23_dly       => data_q_ff23_dly0,
      data_ff24_dly       => data_q_ff24_dly0,
      data_ff25_dly       => data_q_ff25_dly0,
      data_ff26_dly       => data_q_ff26_dly0,
      data_ff27_dly       => data_q_ff27_dly0,
      data_ff28_dly       => data_q_ff28_dly0,
      data_ff29_dly       => data_q_ff29_dly0,
      data_ff30_dly       => data_q_ff30_dly0,
      data_ff31_dly       => data_q_ff31_dly0,
      data_ff32_dly       => data_q_ff32_dly0,
      data_ff33_dly       => data_q_ff33_dly0,
      data_ff34_dly       => data_q_ff34_dly0,
      data_ff35_dly       => data_q_ff35_dly0
      );
      
  -------------------------------------------------------------------------------
  --  DELTA 1
  -------------------------------------------------------------------------------
  shift_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      init_loop: for i in 0 to array_delta1_i'high loop
        array_delta1_i(i) <= (others => '0');
        array_delta1_q(i) <= (others => '0');
        delta1_odd_q <= (others => '0');
        delta1_odd_i <= (others => '0');
        
      end loop;
    elsif clk'event and clk = '1' then
      if (chip_counter ="01") then
        delta1_odd_i <= array_delta1_i(array_delta1_i'high);
        delta1_odd_q <= array_delta1_q(array_delta1_q'high);        
      end if;
     
      if (chip_counter = "11")then
        array_delta1_i(0) <= tk_i_out;
        array_delta1_q(0) <= tk_q_out; 
        -- Shift registers.
        delay_loop: for i in 1 to array_delta1_q'high loop
          array_delta1_i(i) <= array_delta1_i(i-1); 
          array_delta1_q(i) <= array_delta1_q(i-1); 
        end loop;
      end if;
    end if;
  end process shift_pr;

--  delta1_i <= array_delta1_i(array_delta1_i'high);
  delta1_i <= delta1_odd_i when (delay_g mod 2) = 1
              else array_delta1_i(array_delta1_i'high);
  
--  delta1_q <= array_delta1_q(array_delta1_q'high);
  delta1_q <= delta1_odd_q when (delay_g mod 2) = 1
              else array_delta1_q(array_delta1_q'high);
  -------------------------------------------------------------------------------
  -- ERROR CALCULUS with overflow detection.        
  -------------------------------------------------------------------------------   
  error_i_tmp <= (others => '0') when equalizer_init_n = '0' else
                 sxt(remod_data_i,outsize_g+1) - sxt(delta1_i,outsize_g+1);
  
  error_q_tmp <= (others => '0') when equalizer_init_n = '0' else
                 sxt(remod_data_q,outsize_g+1) - sxt(delta1_q,outsize_g+1);
                 
  error_i     <= sat_signed_slv(error_i_tmp,1);               
  error_q     <= sat_signed_slv(error_q_tmp,1);                 
    
    
    
  -- pragma translate_off
--  tk_i_out_tglobal <= delta1_i;
--  tk_q_out_tglobal <= delta1_q;
  -- pragma translate_on

  -- Diagnostic ports.
  diag_error_i <= error_i(outsize_g-1 downto 1);
  diag_error_q <= error_q(outsize_g-1 downto 1);
  
  
  
  --Global signals.
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  coeff_i0_est_gbl <=     coeff_i0_est  ;
--  coeff_i1_est_gbl <=     coeff_i1_est  ;
--  coeff_i2_est_gbl <=     coeff_i2_est  ;
--  coeff_i3_est_gbl <=     coeff_i3_est  ;
--  coeff_i4_est_gbl <=     coeff_i4_est  ;
--  coeff_i5_est_gbl <=     coeff_i5_est  ;
--  coeff_i6_est_gbl <=     coeff_i6_est  ;
--  coeff_i7_est_gbl <=     coeff_i7_est  ;
--  coeff_i8_est_gbl <=     coeff_i8_est  ;
--  coeff_i9_est_gbl <=     coeff_i9_est  ;
--  coeff_i10_est_gbl <=    coeff_i10_est ;
--  coeff_i11_est_gbl <=    coeff_i11_est ;
--  coeff_i12_est_gbl <=    coeff_i12_est ;
--  coeff_i13_est_gbl <=    coeff_i13_est ;
--  coeff_i14_est_gbl <=    coeff_i14_est ;
--  coeff_i15_est_gbl <=    coeff_i15_est ;
--  coeff_i16_est_gbl <=    coeff_i16_est ;
--  coeff_i17_est_gbl <=    coeff_i17_est ;
--  coeff_i18_est_gbl <=    coeff_i18_est ;
--  coeff_i19_est_gbl <=    coeff_i19_est ;
--  coeff_i20_est_gbl <=    coeff_i20_est ;
--  coeff_i21_est_gbl <=    coeff_i21_est ;
--  coeff_i22_est_gbl <=    coeff_i22_est ;
--  coeff_i23_est_gbl <=    coeff_i23_est ;
--  coeff_i24_est_gbl <=    coeff_i24_est ;
--  coeff_i25_est_gbl <=    coeff_i25_est ;
--  coeff_i26_est_gbl <=    coeff_i26_est ;
--  coeff_i27_est_gbl <=    coeff_i27_est ;
--  coeff_i28_est_gbl <=    coeff_i28_est ;
--  coeff_i29_est_gbl <=    coeff_i29_est ;
--  coeff_i30_est_gbl <=    coeff_i30_est ;
--  coeff_i31_est_gbl <=    coeff_i31_est ;
--  coeff_i32_est_gbl <=    coeff_i32_est ;
--  coeff_i33_est_gbl <=    coeff_i33_est ;
--  coeff_i34_est_gbl <=    coeff_i34_est ;
--  coeff_i35_est_gbl <=    coeff_i35_est ; 
--                     
--  coeff_q0_est_gbl <=     coeff_q0_est  ;
--  coeff_q1_est_gbl <=     coeff_q1_est  ;
--  coeff_q2_est_gbl <=     coeff_q2_est  ;
--  coeff_q3_est_gbl <=     coeff_q3_est  ;
--  coeff_q4_est_gbl <=     coeff_q4_est  ;
--  coeff_q5_est_gbl <=     coeff_q5_est  ;
--  coeff_q6_est_gbl <=     coeff_q6_est  ;
--  coeff_q7_est_gbl <=     coeff_q7_est  ;
--  coeff_q8_est_gbl <=     coeff_q8_est  ;
--  coeff_q9_est_gbl <=     coeff_q9_est  ;
--  coeff_q10_est_gbl <=    coeff_q10_est ;
--  coeff_q11_est_gbl <=    coeff_q11_est ;
--  coeff_q12_est_gbl <=    coeff_q12_est ;
--  coeff_q13_est_gbl <=    coeff_q13_est ;
--  coeff_q14_est_gbl <=    coeff_q14_est ;
--  coeff_q15_est_gbl <=    coeff_q15_est ;
--  coeff_q16_est_gbl <=    coeff_q16_est ;
--  coeff_q17_est_gbl <=    coeff_q17_est ;
--  coeff_q18_est_gbl <=    coeff_q18_est ;
--  coeff_q19_est_gbl <=    coeff_q19_est ;
--  coeff_q20_est_gbl <=    coeff_q20_est ;
--  coeff_q21_est_gbl <=    coeff_q21_est ;
--  coeff_q22_est_gbl <=    coeff_q22_est ;
--  coeff_q23_est_gbl <=    coeff_q23_est ;
--  coeff_q24_est_gbl <=    coeff_q24_est ;
--  coeff_q25_est_gbl <=    coeff_q25_est ;
--  coeff_q26_est_gbl <=    coeff_q26_est ;
--  coeff_q27_est_gbl <=    coeff_q27_est ;
--  coeff_q28_est_gbl <=    coeff_q28_est ;
--  coeff_q29_est_gbl <=    coeff_q29_est ;
--  coeff_q30_est_gbl <=    coeff_q30_est ;
--  coeff_q31_est_gbl <=    coeff_q31_est ;
--  coeff_q32_est_gbl <=    coeff_q32_est ;
--  coeff_q33_est_gbl <=    coeff_q33_est ;
--  coeff_q34_est_gbl <=    coeff_q34_est ;
--  coeff_q35_est_gbl <=    coeff_q35_est ;
--
--  error_i_gbl <= error_i;
--  error_q_gbl <= error_q;
--  delta1_i_gbl <= delta1_i;
--  delta1_q_gbl <= delta1_q;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on 
end RTL;
