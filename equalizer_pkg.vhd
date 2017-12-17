
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: equalizer_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.13   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for equalizer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/equalizer/vhdl/rtl/equalizer_pkg.vhd,v  
--  Log: equalizer_pkg.vhd,v  
-- Revision 1.13  2005/01/24 14:15:36  arisse
-- #BugId:624#
-- Added status signal for registers.
--
-- Revision 1.12  2003/10/16 16:19:35  arisse
-- Changed diag_error_i/q to 8 bits instead of 9 bits.
--
-- Revision 1.11  2003/10/16 14:21:33  arisse
-- Added diag ports.
--
-- Revision 1.10  2003/09/18 08:38:46  Dr.A
-- generic changes.
--
-- Revision 1.9  2003/09/09 12:59:11  Dr.C
-- Updated ffwd_filter and equalizer.
--
-- Revision 1.8  2002/12/03 15:08:32  Dr.B
-- change condition on multipliers sharing.
--
-- Revision 1.7  2002/11/06 17:17:09  Dr.A
-- Changed abs_2 signals size.
--
-- Revision 1.6  2002/10/18 15:34:35  Dr.J
-- Removed the DC Offset
--
-- Revision 1.5  2002/09/19 17:01:09  Dr.A
-- New ports to access a multiplier. Data size debug.
--
-- Revision 1.4  2002/07/31 13:09:02  Dr.B
-- new size.
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
package equalizer_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: delay_line18.vhd
----------------------
  component delay_line18
  generic (
    dsize_g : integer := 6 -- Data size
  );
  port (
    -- Clock and reset.
    reset_n       : in  std_logic;
    clk           : in  std_logic;
    -- 
    data_in       : in  std_logic_vector(dsize_g-1 downto 0); -- Data to delay.
    shift         : in  std_logic;                            -- Shift signal.
    -- Delayed data parallel outputs.
    data_ff0      : out std_logic_vector(dsize_g-1 downto 0);
    data_ff1      : out std_logic_vector(dsize_g-1 downto 0);
    data_ff2      : out std_logic_vector(dsize_g-1 downto 0);
    data_ff3      : out std_logic_vector(dsize_g-1 downto 0);
    data_ff4      : out std_logic_vector(dsize_g-1 downto 0);
    data_ff5      : out std_logic_vector(dsize_g-1 downto 0);
    data_ff6      : out std_logic_vector(dsize_g-1 downto 0);
    data_ff7      : out std_logic_vector(dsize_g-1 downto 0);
    data_ff8      : out std_logic_vector(dsize_g-1 downto 0);
    data_ff9      : out std_logic_vector(dsize_g-1 downto 0);
    
    data_ff10     : out std_logic_vector(dsize_g-1 downto 0);
    data_ff11     : out std_logic_vector(dsize_g-1 downto 0);
    data_ff12     : out std_logic_vector(dsize_g-1 downto 0);
    data_ff13     : out std_logic_vector(dsize_g-1 downto 0);
    data_ff14     : out std_logic_vector(dsize_g-1 downto 0);
    data_ff15     : out std_logic_vector(dsize_g-1 downto 0);
    data_ff16     : out std_logic_vector(dsize_g-1 downto 0);
    data_ff17     : out std_logic_vector(dsize_g-1 downto 0)
  );

  end component;


----------------------
-- File: delay_line36.vhd
----------------------
  component delay_line36
  generic (
    dsize_g : integer := 6
  );
  port (
    -- Clock and reset
    reset_n       : in  std_logic;
    clk           : in  std_logic;
    -- 
    data_in       : in  std_logic_vector(dsize_g-1 downto 0); -- Data to delay.
    shift         : in  std_logic;                            -- Shift signal.
    -- Delayed data parallel outputs.
    data_ff0_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff1_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff2_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff3_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff4_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff5_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff6_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff7_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff8_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff9_dly  : out std_logic_vector(dsize_g-1 downto 0);
    
    data_ff10_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff11_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff12_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff13_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff14_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff15_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff16_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff17_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff18_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff19_dly : out std_logic_vector(dsize_g-1 downto 0);
    
    data_ff20_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff21_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff22_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff23_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff24_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff25_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff26_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff27_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff28_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff29_dly : out std_logic_vector(dsize_g-1 downto 0);
    
    data_ff30_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff31_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff32_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff33_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff34_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff35_dly : out std_logic_vector(dsize_g-1 downto 0)
  );

  end component;


----------------------
-- File: alpha_shift.vhd
----------------------
  component alpha_shift
  generic (
    dsize_g : integer := 30 -- Data size
  );
  port (
    alpha          : in  std_logic_vector(2 downto 0);
    data_in        : in  std_logic_vector(dsize_g-1 downto 0);
    --
    shifted_data   : out std_logic_vector(dsize_g+4 downto 0)
  );

  end component;


----------------------
-- File: beta_shift.vhd
----------------------
  component beta_shift
  generic (
    dsize_g : integer := 30 -- Data size
  );
  port (
    beta           : in  std_logic_vector(2 downto 0);
    data_in        : in  std_logic_vector(dsize_g-1 downto 0);
    --
    shifted_data   : out std_logic_vector(dsize_g+1 downto 0)
  );

  end component;


----------------------
-- File: qerr_mult.vhd
----------------------
  component qerr_mult
  generic (
    dsize_g : integer := 6 -- Data size
  );
  port (
    data_in_re     : in  std_logic_vector(dsize_g-1 downto 0);
    data_in_im     : in  std_logic_vector(dsize_g-1 downto 0);
    error_quant    : in  std_logic_vector(1 downto 0);
    --
    -- the addition does not need an extra extended bit (data calibrated)
    data_out_re    : out std_logic_vector(dsize_g downto 0);  
    data_out_im    : out std_logic_vector(dsize_g downto 0)
  );

  end component;


----------------------
-- File: ffwd_estimation.vhd
----------------------
  component ffwd_estimation
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

  end component;


----------------------
-- File: complex_4mult.vhd
----------------------
  component complex_4mult
  generic (
    dsize_g : integer := 8; -- data size
    csize_g : integer := 9  -- coeff size
  );
  port (
    -- Inputs :
    -- coefficients
    coeff0_i      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff1_i      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff2_i      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff3_i      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff0_q      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff1_q      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff2_q      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff3_q      : in  std_logic_vector(csize_g-1 downto 0);
    -- data
    data0_i       : in  std_logic_vector(dsize_g-1 downto 0);
    data1_i       : in  std_logic_vector(dsize_g-1 downto 0); 
    data2_i       : in  std_logic_vector(dsize_g-1 downto 0); 
    data3_i       : in  std_logic_vector(dsize_g-1 downto 0);
    data0_q       : in  std_logic_vector(dsize_g-1 downto 0); 
    data1_q       : in  std_logic_vector(dsize_g-1 downto 0); 
    data2_q       : in  std_logic_vector(dsize_g-1 downto 0); 
    data3_q       : in  std_logic_vector(dsize_g-1 downto 0);
    div_counter   : in  std_logic_vector(1 downto 0);
    
    -- Output results. 
    data_i1_mult  : out std_logic_vector(dsize_g+csize_g-1 downto 0);  
    data_i2_mult  : out std_logic_vector(dsize_g+csize_g-1 downto 0);  
    data_q1_mult  : out std_logic_vector(dsize_g+csize_g-1 downto 0);
    data_q2_mult  : out std_logic_vector(dsize_g+csize_g-1 downto 0)
  );

  end component;


----------------------
-- File: ffwd_filter.vhd
----------------------
  component ffwd_filter
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

  end component;


----------------------
-- File: equalizer.vhd
----------------------
  component equalizer
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

  end component;



 
end equalizer_pkg;
