
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: ffwd_filter.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.13   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Feedforward filter for equalization.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/equalizer/vhdl/rtl/ffwd_filter.vhd,v  
--  Log: ffwd_filter.vhd,v  
-- Revision 1.13  2004/04/05 15:27:35  Dr.B
-- Added condition on datapath to maintain registers reset until filter is activated (equalizer_init_n='1').
-- Changed data_i/q_ff18 for data_i/q_ff17 in filter_i/q_out OUTPUT when filter is not activated..
--
-- Revision 1.12  2003/09/30 08:36:18  Dr.B
-- debug output truncature.
--
-- Revision 1.11  2003/09/18 08:38:13  Dr.A
-- tk_out set to zero when equalizer_init_n is low.
--
-- Revision 1.10  2003/09/09 12:59:46  Dr.C
-- Removed power_estim links.
--
-- Revision 1.9  2002/12/03 15:05:42  Dr.B
-- change condition on multiplier sharing activate -> init_n.
--
-- Revision 1.8  2002/11/06 17:16:22  Dr.A
-- Optimized abs_2 signals.
--
-- Revision 1.7  2002/09/25 15:44:32  Dr.A
-- Use multiplier output to other blocks when equ_activate = 0.
--
-- Revision 1.6  2002/09/19 17:00:00  Dr.A
-- Share a multiplier external block + misc debug.
--
-- Revision 1.5  2002/07/31 13:07:30  Dr.B
-- new size.
--
-- Revision 1.4  2002/07/11 12:37:19  Dr.B
-- remove unused signals.
--
-- Revision 1.3  2002/06/27 16:18:27  Dr.B
-- filter removed. 9 complex_4mult instead.
--
-- Revision 1.2  2002/05/07 16:56:10  Dr.A
-- New filter.
--
-- Revision 1.1  2002/03/28 13:49:09  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 

--library equalizer_rtl;
library work;
--use equalizer_rtl.equalizer_pkg.all;
use work.equalizer_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity ffwd_filter is
  generic (
    dsize_g   : integer := 6;  -- Data size
    csize_g   : integer := 21; -- Coefficients size
    outsize_g : integer := 9   -- output data size
  );
  port (
    -- Clock and reset
    reset_n         : in  std_logic;
    clk             : in  std_logic;
    -- Counter for filter speed
    div_counter     : in  std_logic_vector(1 downto 0);
    -- Equalizer disable
    equalizer_disb  : in  std_logic;
    equalizer_init_n: in  std_logic; -- filter coeffs= 0  when low.
    -- Data to multiply  when equ is disable for peak detector
    d_signed_peak_i   : in  std_logic_vector(dsize_g-1 downto 0);
    d_signed_peak_q   : in  std_logic_vector(dsize_g-1 downto 0);
    -- Filter inputs from delay line
    data_i_ff0      : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff1      : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff2      : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff3      : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff4      : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff5      : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff6      : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff7      : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff8      : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff9      : in  std_logic_vector(dsize_g-1 downto 0);
    
    data_i_ff10     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff11     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff12     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff13     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff14     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff15     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff16     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff17     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff18     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff19     : in  std_logic_vector(dsize_g-1 downto 0);
    
    data_i_ff20     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff21     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff22     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff23     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff24     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff25     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff26     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff27     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff28     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff29     : in  std_logic_vector(dsize_g-1 downto 0);
    
    data_i_ff30     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff31     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff32     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff33     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff34     : in  std_logic_vector(dsize_g-1 downto 0);
    data_i_ff35     : in  std_logic_vector(dsize_g-1 downto 0);

    data_q_ff0      : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff1      : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff2      : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff3      : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff4      : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff5      : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff6      : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff7      : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff8      : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff9      : in  std_logic_vector(dsize_g-1 downto 0);
    
    data_q_ff10     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff11     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff12     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff13     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff14     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff15     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff16     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff17     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff18     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff19     : in  std_logic_vector(dsize_g-1 downto 0);
    
    data_q_ff20     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff21     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff22     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff23     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff24     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff25     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff26     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff27     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff28     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff29     : in  std_logic_vector(dsize_g-1 downto 0);
    
    data_q_ff30     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff31     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff32     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff33     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff34     : in  std_logic_vector(dsize_g-1 downto 0);
    data_q_ff35     : in  std_logic_vector(dsize_g-1 downto 0);

    
    -- Filter coefficients (real part)
    k_i0            : in  std_logic_vector(csize_g-1 downto 0);
    k_i1            : in  std_logic_vector(csize_g-1 downto 0);
    k_i2            : in  std_logic_vector(csize_g-1 downto 0);
    k_i3            : in  std_logic_vector(csize_g-1 downto 0);
    k_i4            : in  std_logic_vector(csize_g-1 downto 0);
    k_i5            : in  std_logic_vector(csize_g-1 downto 0);
    k_i6            : in  std_logic_vector(csize_g-1 downto 0);
    k_i7            : in  std_logic_vector(csize_g-1 downto 0);
    k_i8            : in  std_logic_vector(csize_g-1 downto 0);
    k_i9            : in  std_logic_vector(csize_g-1 downto 0);
    
    k_i10           : in  std_logic_vector(csize_g-1 downto 0);
    k_i11           : in  std_logic_vector(csize_g-1 downto 0);
    k_i12           : in  std_logic_vector(csize_g-1 downto 0);
    k_i13           : in  std_logic_vector(csize_g-1 downto 0);
    k_i14           : in  std_logic_vector(csize_g-1 downto 0);
    k_i15           : in  std_logic_vector(csize_g-1 downto 0);
    k_i16           : in  std_logic_vector(csize_g-1 downto 0);
    k_i17           : in  std_logic_vector(csize_g-1 downto 0);
    k_i18           : in  std_logic_vector(csize_g-1 downto 0);
    k_i19           : in  std_logic_vector(csize_g-1 downto 0);
    
    k_i20           : in  std_logic_vector(csize_g-1 downto 0);
    k_i21           : in  std_logic_vector(csize_g-1 downto 0);
    k_i22           : in  std_logic_vector(csize_g-1 downto 0);
    k_i23           : in  std_logic_vector(csize_g-1 downto 0);
    k_i24           : in  std_logic_vector(csize_g-1 downto 0);
    k_i25           : in  std_logic_vector(csize_g-1 downto 0);
    k_i26           : in  std_logic_vector(csize_g-1 downto 0);
    k_i27           : in  std_logic_vector(csize_g-1 downto 0);
    k_i28           : in  std_logic_vector(csize_g-1 downto 0);
    k_i29           : in  std_logic_vector(csize_g-1 downto 0);
    
    k_i30           : in  std_logic_vector(csize_g-1 downto 0);
    k_i31           : in  std_logic_vector(csize_g-1 downto 0);
    k_i32           : in  std_logic_vector(csize_g-1 downto 0);
    k_i33           : in  std_logic_vector(csize_g-1 downto 0);
    k_i34           : in  std_logic_vector(csize_g-1 downto 0);
    k_i35           : in  std_logic_vector(csize_g-1 downto 0);
    
    -- Filter coefficients (imaginary part)
    k_q0            : in  std_logic_vector(csize_g-1 downto 0);
    k_q1            : in  std_logic_vector(csize_g-1 downto 0);
    k_q2            : in  std_logic_vector(csize_g-1 downto 0);
    k_q3            : in  std_logic_vector(csize_g-1 downto 0);
    k_q4            : in  std_logic_vector(csize_g-1 downto 0);
    k_q5            : in  std_logic_vector(csize_g-1 downto 0);
    k_q6            : in  std_logic_vector(csize_g-1 downto 0);
    k_q7            : in  std_logic_vector(csize_g-1 downto 0);
    k_q8            : in  std_logic_vector(csize_g-1 downto 0);
    k_q9            : in  std_logic_vector(csize_g-1 downto 0);
    
    k_q10           : in  std_logic_vector(csize_g-1 downto 0);
    k_q11           : in  std_logic_vector(csize_g-1 downto 0);
    k_q12           : in  std_logic_vector(csize_g-1 downto 0);
    k_q13           : in  std_logic_vector(csize_g-1 downto 0);
    k_q14           : in  std_logic_vector(csize_g-1 downto 0);
    k_q15           : in  std_logic_vector(csize_g-1 downto 0);
    k_q16           : in  std_logic_vector(csize_g-1 downto 0);
    k_q17           : in  std_logic_vector(csize_g-1 downto 0);
    k_q18           : in  std_logic_vector(csize_g-1 downto 0);
    k_q19           : in  std_logic_vector(csize_g-1 downto 0);
    
    k_q20           : in  std_logic_vector(csize_g-1 downto 0);
    k_q21           : in  std_logic_vector(csize_g-1 downto 0);
    k_q22           : in  std_logic_vector(csize_g-1 downto 0);
    k_q23           : in  std_logic_vector(csize_g-1 downto 0);
    k_q24           : in  std_logic_vector(csize_g-1 downto 0);
    k_q25           : in  std_logic_vector(csize_g-1 downto 0);
    k_q26           : in  std_logic_vector(csize_g-1 downto 0);
    k_q27           : in  std_logic_vector(csize_g-1 downto 0);
    k_q28           : in  std_logic_vector(csize_g-1 downto 0);
    k_q29           : in  std_logic_vector(csize_g-1 downto 0);
    
    k_q30           : in  std_logic_vector(csize_g-1 downto 0);
    k_q31           : in  std_logic_vector(csize_g-1 downto 0);
    k_q32           : in  std_logic_vector(csize_g-1 downto 0);
    k_q33           : in  std_logic_vector(csize_g-1 downto 0);
    k_q34           : in  std_logic_vector(csize_g-1 downto 0);
    k_q35           : in  std_logic_vector(csize_g-1 downto 0);
    
    -- Filter output
    filter_i_out    : out std_logic_vector(outsize_g-1 downto 0);
    filter_q_out    : out std_logic_vector(outsize_g-1 downto 0);
    tk_i_out        : out std_logic_vector(outsize_g-1 downto 0);
    tk_q_out        : out std_logic_vector(outsize_g-1 downto 0);
    -- Output for peak_detect
    abs_2_corr      : out std_logic_vector (2*dsize_g-1 downto 0)
    
  );

end ffwd_filter;



--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of ffwd_filter is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- filter output
  signal filter_i_out_int   : std_logic_vector(outsize_g-1 downto 0);
  signal filter_q_out_int   : std_logic_vector(outsize_g-1 downto 0);

  signal filter_i_sum       : std_logic_vector(dsize_g+csize_g downto 0);
  signal filter_q_sum       : std_logic_vector(dsize_g+csize_g downto 0);
  
  signal data_i_ff18_int    : std_logic_vector(dsize_g-1 downto 0);
  signal data_q_ff18_int    : std_logic_vector(dsize_g-1 downto 0);

  -- div_counter fixed to "11" when equ is not activated
  signal div_counter_fixable : std_logic_vector(1 downto 0);
  
  -- Multipliers output signals: data real part.
  signal data_mult_i0         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i1         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i2         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i3         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i4         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i5         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i6         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i7         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i8         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i9         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i10        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i11        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i12        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i13        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i14        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i15        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i16        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_i17        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  -- Multipliers output signals: data imaginary part.
  signal data_mult_q0         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q1         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q2         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q3         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q4         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q5         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q6         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q7         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q8         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q9         : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q10        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q11        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q12        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q13        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q14        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q15        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q16        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  signal data_mult_q17        : std_logic_vector(dsize_g+csize_g-1 downto 0);
  -- addition of data_mult_i1 and data_mult_i0
  signal mult_i0_i1           : std_logic_vector(dsize_g+csize_g downto 0); 
  -- addition of data_mult_i2 and data_mult_i3
  signal mult_i2_i3           : std_logic_vector(dsize_g+csize_g downto 0); 

  -- For accumulation of the multiplications :
  signal mult_i_add         : std_logic_vector(dsize_g+csize_g downto 0);
  signal mult_q_add         : std_logic_vector(dsize_g+csize_g downto 0);
  signal mult_i_add_accu_ff : std_logic_vector(dsize_g+csize_g downto 0);
  signal mult_q_add_accu_ff : std_logic_vector(dsize_g+csize_g downto 0);

  -- Signals to share a multiplier with the power_est block.
  signal oper_coeff3_i : std_logic_vector(csize_g-1 downto 0);
  signal oper_data3_i  : std_logic_vector(dsize_g-1 downto 0);
  signal oper_coeff3_q : std_logic_vector(csize_g-1 downto 0);
  signal oper_data3_q  : std_logic_vector(dsize_g-1 downto 0);
  -- Signals to share a multiplier with the peak_detect block.
  signal oper_coeff7_i : std_logic_vector(csize_g-1 downto 0);
  signal oper_data7_i  : std_logic_vector(dsize_g-1 downto 0);
  signal oper_coeff7_q : std_logic_vector(csize_g-1 downto 0);
  signal oper_data7_q  : std_logic_vector(dsize_g-1 downto 0);
 
  -- Constant for 11MHz sample, based on div_counter
  constant FILTER_SAMP_CT : std_logic_vector(1 downto 0) := "11";
  -- Constant for half chip synchro, based on div_counter
  constant RESET_ACCU_CT : std_logic_vector(1 downto 0) := "11";

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- Multiplications
  -----------------------------------------------------------------------------
  -- div_counter is fixed to "11" when the equalizer is disabled
  div_counter_fixable  <= div_counter when equalizer_init_n = '1' else "11"; 
   
  
  complex_mult0 : complex_4mult
    generic map (
      dsize_g => dsize_g,
      csize_g => csize_g
      )
    port map (

      coeff0_i => k_i0,
      coeff1_i => k_i1,
      coeff2_i => k_i2,
      coeff3_i => k_i3,
      coeff0_q => k_q0,
      coeff1_q => k_q1,
      coeff2_q => k_q2,
      coeff3_q => k_q3,
      data0_i  => data_i_ff0,
      data1_i  => data_i_ff1,
      data2_i  => data_i_ff2,
      data3_i  => data_i_ff3,
      data0_q  => data_q_ff0,
      data1_q  => data_q_ff1,
      data2_q  => data_q_ff2,
      data3_q  => data_q_ff3,

      div_counter  => div_counter_fixable,
      data_i1_mult => data_mult_i0,
      data_i2_mult => data_mult_i1,
      data_q1_mult => data_mult_q0,
      data_q2_mult => data_mult_q1
      );

  -- The multiplier is shared with the peak_detect block.
  oper_data7_i  <= data_i_ff7 when equalizer_init_n = '1'
                   else d_signed_peak_i;
  oper_coeff7_i <= k_i7 when equalizer_init_n = '1'
                   else d_signed_peak_i;
  oper_data7_q  <= data_q_ff7 when equalizer_init_n = '1'
                   else (not(d_signed_peak_q)+'1');
  oper_coeff7_q <= k_q7 when equalizer_init_n = '1'
                   else d_signed_peak_q;
    
  complex_mult1 : complex_4mult
    generic map (
      dsize_g => dsize_g,
      csize_g => csize_g
      )
    port map (

      coeff0_i => k_i4,
      coeff1_i => k_i5,
      coeff2_i => k_i6,
      coeff3_i => oper_coeff7_i,
      coeff0_q => k_q4,
      coeff1_q => k_q5,
      coeff2_q => k_q6,
      coeff3_q => oper_coeff7_q,
      data0_i  => data_i_ff4,
      data1_i  => data_i_ff5,
      data2_i  => data_i_ff6,
      data3_i  => oper_data7_i,
      data0_q  => data_q_ff4,
      data1_q  => data_q_ff5,
      data2_q  => data_q_ff6,
      data3_q  => oper_data7_q,

      div_counter  => div_counter_fixable,
      data_i1_mult => data_mult_i2,
      data_i2_mult => data_mult_i3,
      data_q1_mult => data_mult_q2,
      data_q2_mult => data_mult_q3
      );

  complex_mult2 : complex_4mult
    generic map (
      dsize_g => dsize_g,
      csize_g => csize_g
      )
    port map (

      coeff0_i => k_i8,
      coeff1_i => k_i9,
      coeff2_i => k_i10,
      coeff3_i => k_i11,
      coeff0_q => k_q8,
      coeff1_q => k_q9,
      coeff2_q => k_q10,
      coeff3_q => k_q11,
      data0_i  => data_i_ff8,
      data1_i  => data_i_ff9,
      data2_i  => data_i_ff10,
      data3_i  => data_i_ff11,
      data0_q  => data_q_ff8,
      data1_q  => data_q_ff9,
      data2_q  => data_q_ff10,
      data3_q  => data_q_ff11,

      div_counter  => div_counter,
      data_i1_mult => data_mult_i4,
      data_i2_mult => data_mult_i5,
      data_q1_mult => data_mult_q4,
      data_q2_mult => data_mult_q5
      );

  complex_mult3 : complex_4mult
    generic map (
      dsize_g => dsize_g,
      csize_g => csize_g
      )
    port map (

      coeff0_i => k_i12,
      coeff1_i => k_i13,
      coeff2_i => k_i14,
      coeff3_i => k_i15,
      coeff0_q => k_q12,
      coeff1_q => k_q13,
      coeff2_q => k_q14,
      coeff3_q => k_q15,
      data0_i  => data_i_ff12,
      data1_i  => data_i_ff13,
      data2_i  => data_i_ff14,
      data3_i  => data_i_ff15,
      data0_q  => data_q_ff12,
      data1_q  => data_q_ff13,
      data2_q  => data_q_ff14,
      data3_q  => data_q_ff15,

      div_counter  => div_counter,
      data_i1_mult => data_mult_i6,
      data_i2_mult => data_mult_i7,
      data_q1_mult => data_mult_q6,
      data_q2_mult => data_mult_q7
      );

  complex_mult4 : complex_4mult
    generic map (
      dsize_g => dsize_g,
      csize_g => csize_g
      )
    port map (

      coeff0_i => k_i16,
      coeff1_i => k_i17,
      coeff2_i => k_i18,
      coeff3_i => k_i19,
      coeff0_q => k_q16,
      coeff1_q => k_q17,
      coeff2_q => k_q18,
      coeff3_q => k_q19,
      data0_i  => data_i_ff16,
      data1_i  => data_i_ff17,
      data2_i  => data_i_ff18,
      data3_i  => data_i_ff19,
      data0_q  => data_q_ff16,
      data1_q  => data_q_ff17,
      data2_q  => data_q_ff18,
      data3_q  => data_q_ff19,

      div_counter  => div_counter,
      data_i1_mult => data_mult_i8,
      data_i2_mult => data_mult_i9,
      data_q1_mult => data_mult_q8,
      data_q2_mult => data_mult_q9
      );

  complex_mult5 : complex_4mult
    generic map (
      dsize_g => dsize_g,
      csize_g => csize_g
      )
    port map (

      coeff0_i => k_i20,
      coeff1_i => k_i21,
      coeff2_i => k_i22,
      coeff3_i => k_i23,
      coeff0_q => k_q20,
      coeff1_q => k_q21,
      coeff2_q => k_q22,
      coeff3_q => k_q23,
      data0_i  => data_i_ff20,
      data1_i  => data_i_ff21,
      data2_i  => data_i_ff22,
      data3_i  => data_i_ff23,
      data0_q  => data_q_ff20,
      data1_q  => data_q_ff21,
      data2_q  => data_q_ff22,
      data3_q  => data_q_ff23,

      div_counter  => div_counter,
      data_i1_mult => data_mult_i10,
      data_i2_mult => data_mult_i11,
      data_q1_mult => data_mult_q10,
      data_q2_mult => data_mult_q11
      );
  complex_mult6 : complex_4mult
    generic map (
      dsize_g => dsize_g,
      csize_g => csize_g
      )
    port map (

      coeff0_i => k_i24,
      coeff1_i => k_i25,
      coeff2_i => k_i26,
      coeff3_i => k_i27,
      coeff0_q => k_q24,
      coeff1_q => k_q25,
      coeff2_q => k_q26,
      coeff3_q => k_q27,
      data0_i  => data_i_ff24,
      data1_i  => data_i_ff25,
      data2_i  => data_i_ff26,
      data3_i  => data_i_ff27,
      data0_q  => data_q_ff24,
      data1_q  => data_q_ff25,
      data2_q  => data_q_ff26,
      data3_q  => data_q_ff27,

      div_counter  => div_counter,
      data_i1_mult => data_mult_i12,
      data_i2_mult => data_mult_i13,
      data_q1_mult => data_mult_q12,
      data_q2_mult => data_mult_q13
      );

  complex_mult7 : complex_4mult
    generic map (
      dsize_g => dsize_g,
      csize_g => csize_g
      )
    port map (

      coeff0_i => k_i28,
      coeff1_i => k_i29,
      coeff2_i => k_i30,
      coeff3_i => k_i31,
      coeff0_q => k_q28,
      coeff1_q => k_q29,
      coeff2_q => k_q30,
      coeff3_q => k_q31,
      data0_i  => data_i_ff28,
      data1_i  => data_i_ff29,
      data2_i  => data_i_ff30,
      data3_i  => data_i_ff31,
      data0_q  => data_q_ff28,
      data1_q  => data_q_ff29,
      data2_q  => data_q_ff30,
      data3_q  => data_q_ff31,

      div_counter  => div_counter,
      data_i1_mult => data_mult_i14,
      data_i2_mult => data_mult_i15,
      data_q1_mult => data_mult_q14,
      data_q2_mult => data_mult_q15
      );

  complex_mult8 : complex_4mult
    generic map (
      dsize_g => dsize_g,
      csize_g => csize_g
      )
    port map (

      coeff0_i => k_i32,
      coeff1_i => k_i33,
      coeff2_i => k_i34,
      coeff3_i => k_i35,
      coeff0_q => k_q32,
      coeff1_q => k_q33,
      coeff2_q => k_q34,
      coeff3_q => k_q35,
      data0_i  => data_i_ff32,
      data1_i  => data_i_ff33,
      data2_i  => data_i_ff34,
      data3_i  => data_i_ff35,
      data0_q  => data_q_ff32,
      data1_q  => data_q_ff33,
      data2_q  => data_q_ff34,
      data3_q  => data_q_ff35,

      div_counter  => div_counter,
      data_i1_mult => data_mult_i16,
      data_i2_mult => data_mult_i17,
      data_q1_mult => data_mult_q16,
      data_q2_mult => data_mult_q17
      );

 
  -----------------------------------------------------------------------------
  -- Additions
  -----------------------------------------------------------------------------
  mult_i0_i1 <= sxt(data_mult_i1, dsize_g+csize_g+1)
                       + sxt(data_mult_i0, dsize_g+csize_g+1);

  mult_i2_i3 <= sxt(data_mult_i3, dsize_g+csize_g+1)
                       + sxt(data_mult_i2, dsize_g+csize_g+1);
  -- When the multiplier is used for the peak_detect block, the sum mult_i2_i3
  -- (a^2 + b^2) is positive. The sign bit is not sent on the abs_2_corr port.
  abs_2_corr <= mult_i2_i3(2*dsize_g-1 downto 0) when equalizer_init_n = '0'
    else (others => '0');

  
  -- optimized parenthesis for synthesis : reduced worst path.
  mult_i_add <= (((sxt(data_mult_i17, dsize_g+csize_g+1)
                   + sxt(data_mult_i16, dsize_g+csize_g+1))
                  + (sxt(data_mult_i15, dsize_g+csize_g+1)
                     + sxt(data_mult_i14, dsize_g+csize_g+1)))

                 +((sxt(data_mult_i13, dsize_g+csize_g+1)
                    + sxt(data_mult_i12, dsize_g+csize_g+1))
                   + (sxt(data_mult_i11, dsize_g+csize_g+1)
                      + sxt(data_mult_i10, dsize_g+csize_g+1))))

                +(((sxt(data_mult_i9, dsize_g+csize_g+1)
                    + sxt(data_mult_i8, dsize_g+csize_g+1))
                   + (sxt(data_mult_i7, dsize_g+csize_g+1)
                      + sxt(data_mult_i6, dsize_g+csize_g+1)))

                  +(((sxt(data_mult_i5, dsize_g+csize_g+1)
                      + sxt(data_mult_i4, dsize_g+csize_g+1))
                     + mult_i2_i3)
                    + mult_i0_i1));

  mult_q_add <= (((sxt(data_mult_q17, dsize_g+csize_g+1)
                   + sxt(data_mult_q16, dsize_g+csize_g+1))
                  + (sxt(data_mult_q15, dsize_g+csize_g+1)
                     + sxt(data_mult_q14, dsize_g+csize_g+1)))

                 +((sxt(data_mult_q13, dsize_g+csize_g+1)
                    + sxt(data_mult_q12, dsize_g+csize_g+1))
                   + (sxt(data_mult_q11, dsize_g+csize_g+1)
                      + sxt(data_mult_q10, dsize_g+csize_g+1))))

                +(((sxt(data_mult_q9, dsize_g+csize_g+1)
                    + sxt(data_mult_q8, dsize_g+csize_g+1))
                   + (sxt(data_mult_q7, dsize_g+csize_g+1)
                      + sxt(data_mult_q6, dsize_g+csize_g+1)))

                  +(((sxt(data_mult_q5, dsize_g+csize_g+1)
                      + sxt(data_mult_q4, dsize_g+csize_g+1))
                     + (sxt(data_mult_q3, dsize_g+csize_g+1)
                        + sxt(data_mult_q2, dsize_g+csize_g+1)))

                    + (sxt(data_mult_q1, dsize_g+csize_g+1)
                       + sxt(data_mult_q0, dsize_g+csize_g+1))));
  -------------------------------------------------------------------
  -- Delay adder output.
  --  
  adder_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      mult_i_add_accu_ff <= (others => '0');
      mult_q_add_accu_ff <= (others => '0');
    elsif clk'event and clk = '1' then
      
      if equalizer_init_n = '0' then             
        mult_i_add_accu_ff <= (others => '0');   
        mult_q_add_accu_ff <= (others => '0');   
        
      elsif div_counter = RESET_ACCU_CT then
        mult_i_add_accu_ff <= (others => '0');
        mult_q_add_accu_ff <= (others => '0');
      else
        mult_i_add_accu_ff <= filter_i_sum;
        mult_q_add_accu_ff <= filter_q_sum;
      end if;
    end if;                                                          
  end process adder_pr;
  -------------------------------------------------------------------  
  filter_i_sum <= mult_i_add + mult_i_add_accu_ff;
  filter_q_sum <= mult_q_add + mult_q_add_accu_ff;
  -------------------------------------------------------------------    
  -- Delay adder output.  
  dly_adder_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      filter_i_out_int <= (others => '0');
      filter_q_out_int <= (others => '0');
      data_i_ff18_int  <= (others => '0');
      data_q_ff18_int  <= (others => '0');
     
    elsif clk'event and clk = '1' then
             
      if div_counter = FILTER_SAMP_CT then
        filter_i_out_int <= filter_i_sum(filter_i_sum'high -3
               downto filter_i_sum'high-2-outsize_g);
        filter_q_out_int <= filter_q_sum(filter_q_sum'high -3
               downto filter_q_sum'high-2-outsize_g);
        -- resynchromize data_i_ff17

        data_i_ff18_int <= data_i_ff17;   
        data_q_ff18_int <= data_q_ff17;           
      end if;
      
      -- Do not propagate garbage 
      if equalizer_init_n = '0' then            
        filter_i_out_int <= (others => '0');    
        filter_q_out_int <= (others => '0');    
      end if;          
            
    end if;                                                          
  end process dly_adder_pr;
  -------------------------------------------------------------------  
  -- when the equalizer is disabled, the output is the input data
  -- in the middle of the filter.
  filter_i_out <= filter_i_out_int when equalizer_disb = '0' else data_i_ff18_int & '0';
  filter_q_out <= filter_q_out_int when equalizer_disb = '0' else data_q_ff18_int & '0' ;

  tk_i_out <= filter_i_out_int when equalizer_init_n = '1' else (others => '0');
  tk_q_out <= filter_q_out_int when equalizer_init_n = '1' else (others => '0');

end RTL;
