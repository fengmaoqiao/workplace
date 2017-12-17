
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: core_filter.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.13   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Core front-end filter for tx_rx_filter block
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/tx_rx_filter/vhdl/rtl/core_filter.vhd,v  
--  Log: core_filter.vhd,v  
-- Revision 1.13  2005/01/18 13:13:21  Dr.C
-- #BugId:960#
-- Added dc_pre_estim_4_agc outputs and reduce dc_pre_estim to 11-bit.
--
-- Revision 1.12  2004/12/08 16:05:56  Dr.C
-- #BugId:888#
-- Change counter constant value for DC offset pre-estimation.
--
-- Revision 1.11  2004/10/27 14:15:37  Dr.C
-- #BugId:799#
-- Added dc pre-estimation calculation.
--
-- Revision 1.10  2004/05/13 14:48:06  Dr.C
-- Added use_sync_reset_g generic.
--
-- Revision 1.9  2004/04/07 13:43:32  Dr.C
-- Change architecture for reduce gate count.
--
-- Revision 1.8  2003/11/29 11:28:46  Dr.C
-- Changed architecture.
--
-- Revision 1.7  2003/08/29 16:13:00  Dr.C
-- Added clear_buffer input.
--
-- Revision 1.6  2003/07/02 13:30:35  Dr.C
-- Changed structure.
--
-- Revision 1.5  2003/06/11 09:26:36  Dr.C
-- Removed last version.
--
-- Revision 1.4  2003/06/04 15:04:04  Dr.C
-- Changed coefs & structure.
--
-- Revision 1.3  2003/04/02 08:18:16  Dr.C
-- Debugged saturation constants.
--
-- Revision 1.2  2003/04/01 14:40:09  Dr.C
-- Debugged buf_mul assignment.
--
-- Revision 1.1  2003/03/17 15:33:27  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--library target_config_pkg;
library work;
--use target_config_pkg.target_config_pkg.all;
use work.target_config_pkg.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity core_filter is
  generic (
    size_in_g        : integer := 10; -- Size of Core filter input
    size_out_g       : integer := 15; -- Size of Core filter output
    --
--    use_sync_reset_g : integer := 1   -- when 1 clear_buffer input is used
    use_sync_reset_g : integer := 1   -- when 1 clear_buffer input is used
    );                                -- else the reset_n input must be separately
  port (                              -- controlled by the reset controller
    ------------------------------------------------
    -- Clock and reset
    ------------------------------------------------
    clk          : in std_logic;       -- 60 Mhz
    reset_n      : in std_logic;
        
    ------------------------------------------------
    -- Clear buffer during transition Tx/Rx or Rx/Tx
    ------------------------------------------------
    clear_buffer : in std_logic;
    
    ------------------------------------------------
    -- Filter buffer input
    ------------------------------------------------
    fil_buf_i    : in std_logic_vector(size_in_g-1 downto 0);

    ------------------------------------------------
    -- Addition stage output with saturation
    ------------------------------------------------
    add_stage_o  : out std_logic_vector(size_out_g-1 downto 0);
    
    ------------------------------------------------
    -- DC offset pre-estimation
    ------------------------------------------------
    sel_dc_mode        : in std_logic;
    dc_pre_estim_valid : in std_logic;
    tx_active          : in std_logic; -- stop dc pre-estimation when tx active
    --
    dc_pre_estim       : out std_logic_vector(10 downto 0);
    dc_pre_estim_4_agc : out std_logic_vector(10 downto 0)
    );

end core_filter;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of core_filter is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Filter coefs
  constant COEF_F0_CT  : std_logic_vector(7 downto 0) := "11111110"; -- -(2^-6)
  constant COEF_F1_CT  : std_logic_vector(7 downto 0) := "11111101"; -- -(2^-6 + 2^-7)
  constant COEF_F2_CT  : std_logic_vector(7 downto 0) := "11111111"; -- -(2^-7)
  constant COEF_F3_CT  : std_logic_vector(7 downto 0) := "00000010"; -- 2^-6
  constant COEF_F4_CT  : std_logic_vector(7 downto 0) := "00000100"; -- 2^-5
  constant COEF_F5_CT  : std_logic_vector(7 downto 0) := "00000000"; -- 0
  constant COEF_F6_CT  : std_logic_vector(7 downto 0) := "11111010"; -- -(2^-5 + 2^-6)
  constant COEF_F7_CT  : std_logic_vector(7 downto 0) := "11111000"; -- -(2^-4)
  constant COEF_F8_CT  : std_logic_vector(7 downto 0) := "11111111"; -- -(2^-7)
  constant COEF_F9_CT  : std_logic_vector(7 downto 0) := "00001001"; -- 2^-4 + 2^-7
  constant COEF_F10_CT : std_logic_vector(7 downto 0) := "00001100"; -- 2^-4 + 2^-5
  constant COEF_F11_CT : std_logic_vector(7 downto 0) := "00000001"; -- 2^-7
  constant COEF_F12_CT : std_logic_vector(7 downto 0) := "11101101"; -- -(2^-3 + 2^-6 + 2^-7)
  constant COEF_F13_CT : std_logic_vector(7 downto 0) := "11100110"; -- -(2^-3 + 2^-4 + 2^-6)
  constant COEF_F14_CT : std_logic_vector(7 downto 0) := "11111110"; -- -(2^-6)
  constant COEF_F15_CT : std_logic_vector(7 downto 0) := "00110010"; -- 2^-2 + 2^-3 + 2^-6
  constant COEF_F16_CT : std_logic_vector(7 downto 0) := "01101001"; -- 2^-1 + 2^-2 + 2^-4 + 2^-7
  constant COEF_F17_CT : std_logic_vector(7 downto 0) := "01111111"; -- 2^-1 + 2^-2 + 2^-3 + 2^-4 + 2^-5 + 2^-6 + 2^-7
  -- Delay line length
  constant DELAY_LINE_LENGTH_CT : integer := 35;
  -- Multiplication by 947
  constant SCALE_CT    : std_logic_vector (9 downto 0) := "1110110011";-- 947

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- shift register
  type delay_line_type is array (DELAY_LINE_LENGTH_CT-1 downto 0)
                                      of std_logic_vector(size_in_g-1 downto 0);
  signal filter_shift : delay_line_type;

  -- First addition before multiplication
  signal add0  : std_logic_vector(size_in_g downto 0);
  signal add1  : std_logic_vector(size_in_g downto 0);
  signal add2  : std_logic_vector(size_in_g downto 0);
  signal add3  : std_logic_vector(size_in_g downto 0);
  signal add4  : std_logic_vector(size_in_g downto 0);
  signal add5  : std_logic_vector(size_in_g downto 0);
  signal add6  : std_logic_vector(size_in_g downto 0);
  signal add7  : std_logic_vector(size_in_g downto 0);
  signal add8  : std_logic_vector(size_in_g downto 0);
  signal add9  : std_logic_vector(size_in_g downto 0);
  signal add10 : std_logic_vector(size_in_g downto 0);
  signal add11 : std_logic_vector(size_in_g downto 0);
  signal add12 : std_logic_vector(size_in_g downto 0);
  signal add13 : std_logic_vector(size_in_g downto 0);
  signal add14 : std_logic_vector(size_in_g downto 0);
  signal add15 : std_logic_vector(size_in_g downto 0);
  signal add16 : std_logic_vector(size_in_g downto 0);
  signal add17 : std_logic_vector(size_in_g downto 0);

  -- Multiplier outputs
  signal filter_mul_0  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_1  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_2  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_3  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_4  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_5  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_6  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_7  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_8  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_9  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_10 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_11 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_12 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_13 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_14 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_15 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_16 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_mul_17 : std_logic_vector(size_in_g+8 downto 0);

  -- Multiplier intermediate signals to cut combinatory path
  signal filter_interm_mul_0  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_1  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_2  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_3  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_4  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_5  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_6  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_7  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_8  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_9  : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_10 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_11 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_12 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_13 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_14 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_15 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_16 : std_logic_vector(size_in_g+8 downto 0);
  signal filter_interm_mul_17 : std_logic_vector(size_in_g+8 downto 0);

  -- Addition result
  signal sum : std_logic_vector(size_in_g+13 downto 0);

  -- DC diff between delay line 32 and 0
  signal dc_diff         : std_logic_vector(11 downto 0);
  -- DC accumulation
  signal dc_accu         : std_logic_vector(14 downto 0);
  -- DC accumulation rounded
  signal dc_accu_rnd     : std_logic_vector(12 downto 0);
  -- DC accumulation multiplication by 947
  signal dc_accu_mul     : std_logic_vector (22 downto 0);
  signal dc_accu_mul_rnd : std_logic_vector (11 downto 0);
 
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------     NO SYNCHRONOUS RESET     ------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  NO_SYNC_RESET_GEN : if use_sync_reset_g = 0 generate

  -----------------------------------------------------------------------------
  -- Delay line : 35 stages
  -----------------------------------------------------------------------------
  filter_shift_p : process (reset_n, clk)
  begin
    if reset_n = '0' then
      filter_shift <= (others => (others => '0'));
    elsif clk'event and clk = '1' then
      filter_shift <= filter_shift(filter_shift'left - 1 downto 0) & fil_buf_i;
    end if;
  end process filter_shift_p;

  -----------------------------------------------------------------------------
  -- Additions of each pair of the delay line
  -----------------------------------------------------------------------------
  add0  <= sxt(filter_shift(0)(size_in_g-1 downto 0),add0'length)   +
           sxt(filter_shift(34)(size_in_g-1 downto 0),add0'length);
  add1  <= sxt(filter_shift(1)(size_in_g-1 downto 0),add1'length)   +
           sxt(filter_shift(33)(size_in_g-1 downto 0),add1'length);
  add2  <= sxt(filter_shift(2)(size_in_g-1 downto 0),add2'length)   +
           sxt(filter_shift(32)(size_in_g-1 downto 0),add2'length);
  add3  <= sxt(filter_shift(3)(size_in_g-1 downto 0),add3'length)   +
           sxt(filter_shift(31)(size_in_g-1 downto 0),add3'length);
  add4  <= sxt(filter_shift(4)(size_in_g-1 downto 0),add4'length)   +
           sxt(filter_shift(30)(size_in_g-1 downto 0),add4'length);
  add5  <= sxt(filter_shift(5)(size_in_g-1 downto 0),add5'length)   +
           sxt(filter_shift(29)(size_in_g-1 downto 0),add5'length);
  add6  <= sxt(filter_shift(6)(size_in_g-1 downto 0),add6'length)   +
           sxt(filter_shift(28)(size_in_g-1 downto 0),add6'length);
  add7  <= sxt(filter_shift(7)(size_in_g-1 downto 0),add7'length)   +
           sxt(filter_shift(27)(size_in_g-1 downto 0),add7'length);
  add8  <= sxt(filter_shift(8)(size_in_g-1 downto 0),add8'length)   +
           sxt(filter_shift(26)(size_in_g-1 downto 0),add8'length);
  add9  <= sxt(filter_shift(9)(size_in_g-1 downto 0),add9'length)   +
           sxt(filter_shift(25)(size_in_g-1 downto 0),add9'length);
  add10 <= sxt(filter_shift(10)(size_in_g-1 downto 0),add10'length) +
           sxt(filter_shift(24)(size_in_g-1 downto 0),add10'length);
  add11 <= sxt(filter_shift(11)(size_in_g-1 downto 0),add11'length) +
           sxt(filter_shift(23)(size_in_g-1 downto 0),add11'length);
  add12 <= sxt(filter_shift(12)(size_in_g-1 downto 0),add12'length) +
           sxt(filter_shift(22)(size_in_g-1 downto 0),add12'length);
  add13 <= sxt(filter_shift(13)(size_in_g-1 downto 0),add13'length) +
           sxt(filter_shift(21)(size_in_g-1 downto 0),add13'length);
  add14 <= sxt(filter_shift(14)(size_in_g-1 downto 0),add14'length) +
           sxt(filter_shift(20)(size_in_g-1 downto 0),add14'length);
  add15 <= sxt(filter_shift(15)(size_in_g-1 downto 0),add15'length) +
           sxt(filter_shift(19)(size_in_g-1 downto 0),add15'length);
  add16 <= sxt(filter_shift(16)(size_in_g-1 downto 0),add16'length) +
           sxt(filter_shift(18)(size_in_g-1 downto 0),add16'length);
  add17 <= sxt(filter_shift(17)(size_in_g-1 downto 0),add17'length);


  -----------------------------------------------------------------------------
  -- Mults : the additions are multiplied by the 35 filter coefficients
  -----------------------------------------------------------------------------

  -- f0 = f34 = -(2^-6)
  filter_mul_0 <= signed(add0) * signed(COEF_F0_CT);

  
  -- f1 = f33 = -(2^-6 + 2^-7)
  filter_mul_1 <= signed(add1) * signed(COEF_F1_CT);
                  
  
  -- f2 = f32 = -(2^-7)
  filter_mul_2 <= signed(add2) * signed(COEF_F2_CT);


  -- f3 = f31 = 2^-6
  filter_mul_3 <= signed(add3) * signed(COEF_F3_CT);


  -- f4 = f31 = 2^-5
  filter_mul_4 <= signed(add4) * signed(COEF_F4_CT);


  -- f5 = f29 = 0
  filter_mul_5 <= signed(add5) * signed(COEF_F5_CT);

  
  -- f6 = f28 = -(2^-5 + 2^-6)
  filter_mul_6 <= signed(add6) * signed(COEF_F6_CT);
  
  
  -- f7 = f27 = -(2^-4)
  filter_mul_7 <= signed(add7) * signed(COEF_F7_CT);


  -- f8 = f26 = -(2^-7)
  filter_mul_8 <= signed(add8) * signed(COEF_F8_CT);


  -- f9 = f25 = 2^-4 + 2^-7
  filter_mul_9 <= signed(add9) * signed(COEF_F9_CT);


  -- f10 = f24 = 2^-4 + 2^-5
  filter_mul_10 <= signed(add10) * signed(COEF_F10_CT);


  -- f11 = f23 = 2^-7
  filter_mul_11 <= signed(add11) * signed(COEF_F11_CT);


  -- f12 = f22 = -(2^-3 + 2^-6 + 2^-7)
  filter_mul_12 <= signed(add12) * signed(COEF_F12_CT);


  -- f13 = f21 = -(2^-3 + 2^-4 + 2^-6)
  filter_mul_13 <= signed(add13) * signed(COEF_F13_CT);


  -- f14 = f20 = -(2^-6)
  filter_mul_14 <= signed(add14) * signed(COEF_F14_CT);


  -- f15 = f19 = 2^-2 + 2^-3 + 2^-6
  filter_mul_15 <= signed(add15) * signed(COEF_F15_CT);


  -- f16 = f18 = 2^-1 + 2^-2 + 2^-4 + 2^-7
  filter_mul_16 <= signed(add16) * signed(COEF_F16_CT);


  -- f17 = 2^-1 + 2^-2 + 2^-3 + 2^-4 + 2^-5 + 2^-6 + 2^-7
  filter_mul_17 <= signed(add17) * signed(COEF_F17_CT);

  -----------------------------------------------------------------------------
  -- Intermediate value
  -- When fpga, cut combinatory path with FF
  -----------------------------------------------------------------------------
  ASIC_GEN : if TARGET_CT = ASIC generate
    
    filter_interm_mul_0  <= filter_mul_0;
    filter_interm_mul_1  <= filter_mul_1;
    filter_interm_mul_2  <= filter_mul_2;
    filter_interm_mul_3  <= filter_mul_3;
    filter_interm_mul_4  <= filter_mul_4;
    filter_interm_mul_5  <= filter_mul_5;
    filter_interm_mul_6  <= filter_mul_6;
    filter_interm_mul_7  <= filter_mul_7;
    filter_interm_mul_8  <= filter_mul_8;
    filter_interm_mul_9  <= filter_mul_9;
    filter_interm_mul_10 <= filter_mul_10;
    filter_interm_mul_11 <= filter_mul_11;
    filter_interm_mul_12 <= filter_mul_12;
    filter_interm_mul_13 <= filter_mul_13;
    filter_interm_mul_14 <= filter_mul_14;
    filter_interm_mul_15 <= filter_mul_15;
    filter_interm_mul_16 <= filter_mul_16;
    filter_interm_mul_17 <= filter_mul_17;
    
  end generate ASIC_GEN;


  FPGA_GEN : if TARGET_CT = FPGA generate
    
    filter_fpga_buffering_p : process (reset_n, clk)
    begin
      if reset_n = '0' then
        filter_interm_mul_0  <= (others => '0');
        filter_interm_mul_1  <= (others => '0');
        filter_interm_mul_2  <= (others => '0');
        filter_interm_mul_3  <= (others => '0');
        filter_interm_mul_4  <= (others => '0');
        filter_interm_mul_5  <= (others => '0');
        filter_interm_mul_6  <= (others => '0');
        filter_interm_mul_7  <= (others => '0');
        filter_interm_mul_8  <= (others => '0');
        filter_interm_mul_9  <= (others => '0');
        filter_interm_mul_10 <= (others => '0');
        filter_interm_mul_11 <= (others => '0');
        filter_interm_mul_12 <= (others => '0');
        filter_interm_mul_13 <= (others => '0');
        filter_interm_mul_14 <= (others => '0');
        filter_interm_mul_15 <= (others => '0');
        filter_interm_mul_16 <= (others => '0');
        filter_interm_mul_17 <= (others => '0');
      elsif clk'event and clk = '1' then
        filter_interm_mul_0  <= filter_mul_0;
        filter_interm_mul_1  <= filter_mul_1;
        filter_interm_mul_2  <= filter_mul_2;
        filter_interm_mul_3  <= filter_mul_3;
        filter_interm_mul_4  <= filter_mul_4;
        filter_interm_mul_5  <= filter_mul_5;
        filter_interm_mul_6  <= filter_mul_6;
        filter_interm_mul_7  <= filter_mul_7;
        filter_interm_mul_8  <= filter_mul_8;
        filter_interm_mul_9  <= filter_mul_9;
        filter_interm_mul_10 <= filter_mul_10;
        filter_interm_mul_11 <= filter_mul_11;
        filter_interm_mul_12 <= filter_mul_12;
        filter_interm_mul_13 <= filter_mul_13;
        filter_interm_mul_14 <= filter_mul_14;
        filter_interm_mul_15 <= filter_mul_15;
        filter_interm_mul_16 <= filter_mul_16;
        filter_interm_mul_17 <= filter_mul_17;
      end if;
    end process filter_fpga_buffering_p;

    
  end generate FPGA_GEN;


  -----------------------------------------------------------------------------
  -- Last stage : Additions of the branches
  -----------------------------------------------------------------------------
  sum <= ((((sxt(filter_interm_mul_0,sum'length)  + sxt(filter_interm_mul_1,sum'length))
             +
            (sxt(filter_interm_mul_2,sum'length)  + sxt(filter_interm_mul_3,sum'length)))
             +
           ((sxt(filter_interm_mul_4,sum'length)  + sxt(filter_interm_mul_5,sum'length))
             +           
            (sxt(filter_interm_mul_6,sum'length)  + sxt(filter_interm_mul_7,sum'length))))
             +           
          (((sxt(filter_interm_mul_8,sum'length)  + sxt(filter_interm_mul_9,sum'length))
             +           
            (sxt(filter_interm_mul_10,sum'length) + sxt(filter_interm_mul_11,sum'length)))
             +           
           ((sxt(filter_interm_mul_12,sum'length) + sxt(filter_interm_mul_13,sum'length))
             +           
            (sxt(filter_interm_mul_14,sum'length) + sxt(filter_interm_mul_15,sum'length)))))
             +           
            (sxt(filter_interm_mul_16,sum'length) + sxt(filter_interm_mul_17,sum'length));


  -----------------------------------------------------------------------------
  -- Output saturation : -(2^size_out_g - 1) < sum < 2^size_out_g
  -----------------------------------------------------------------------------
  
  -- Output saturation
  output_p: process (reset_n, clk)
  begin  
    if reset_n = '0' then               
      add_stage_o <= (others => '0');
    elsif clk'event and clk = '1' then
--------------------------------------------------------------------------------
-- function sat_signed_slv : truncate and saturate a signed number
-- remove nb_to_rem MSB of sat_signed_slv and saturate the signal if needed by
-- "01111..." (positive numbers) or "1000....." (negative numbers)
--------------------------------------------------------------------------------
      add_stage_o <= sat_signed_slv(sum(size_in_g+13 downto 3), size_in_g+13-1 - size_out_g -1);
    end if;
  end process output_p; 

  ------------------------------------------
  -- DC Offset pre-estimation
  ------------------------------------------

  -- Diff between sample 32 and 0
  dc_diff <= sxt(filter_shift(0),dc_diff'length) -
             sxt(filter_shift(32),dc_diff'length);

  -- DC accumulator
  dc_accu_p : process (reset_n, clk)
  begin
    if reset_n = '0' then
      dc_accu <= (others => '0');
    elsif clk'event and clk = '1' then
      if tx_active = '0' then
        dc_accu <= dc_accu + sxt(dc_diff,dc_accu'length);
      end if;
    end if;
  end process dc_accu_p;

  -- DC accumulator roundind 3 lsb
  dc_accu_rnd <= dc_accu(14 downto 2) + '1';
  
  -- Multiplier (dc_accu_rnd * 947)
  dc_accu_mul <= std_logic_vector'(signed(dc_accu_rnd(12 downto 1)) *
                                   signed('0' & SCALE_CT));

  -- Rounding after multiplier
  dc_accu_mul_rnd <= dc_accu_mul(21 downto 10) + '1';
  
  -- Output generation
  dc_pre_est_out_p : process (reset_n, clk)
  begin
    if reset_n = '0' then
      dc_pre_estim_4_agc <= (others => '0');
      dc_pre_estim       <= (others => '0');
    elsif clk'event and clk = '1' then
      if tx_active = '0' then
        -- DC Pre-estimation output
        if dc_pre_estim_valid = '0' then
          dc_pre_estim <= dc_accu_mul_rnd(11 downto 1);
        end if;
        -- DC Pre-estimation output fixed for AGC
        if sel_dc_mode = '0' or 
          (sel_dc_mode = '1' and dc_pre_estim_valid = '0') then
          dc_pre_estim_4_agc <= dc_accu_mul_rnd(11 downto 1);
        end if;
      end if;
    end if;
  end process dc_pre_est_out_p;

  end generate NO_SYNC_RESET_GEN;


  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  ------------------------     SYNCHRONOUS RESET     --------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  SYNC_RESET_GEN : if use_sync_reset_g = 1 generate

  -----------------------------------------------------------------------------
  -- Delay line : 35 stages
  -----------------------------------------------------------------------------
  filter_shift_p : process (reset_n, clk)
  begin
    if reset_n = '0' then
      filter_shift <= (others => (others => '0'));
    elsif clk'event and clk = '1' then
      if clear_buffer = '1' then
        filter_shift <= (others => (others => '0'));
      else
        filter_shift <= filter_shift(filter_shift'left - 1 downto 0) & fil_buf_i;
      end if;
    end if;
  end process filter_shift_p;

  -----------------------------------------------------------------------------
  -- Additions of each pair of the delay line
  -----------------------------------------------------------------------------
  add0  <= sxt(filter_shift(0)(size_in_g-1 downto 0),add0'length)   +
           sxt(filter_shift(34)(size_in_g-1 downto 0),add0'length);
  add1  <= sxt(filter_shift(1)(size_in_g-1 downto 0),add1'length)   +
           sxt(filter_shift(33)(size_in_g-1 downto 0),add1'length);
  add2  <= sxt(filter_shift(2)(size_in_g-1 downto 0),add2'length)   +
           sxt(filter_shift(32)(size_in_g-1 downto 0),add2'length);
  add3  <= sxt(filter_shift(3)(size_in_g-1 downto 0),add3'length)   +
           sxt(filter_shift(31)(size_in_g-1 downto 0),add3'length);
  add4  <= sxt(filter_shift(4)(size_in_g-1 downto 0),add4'length)   +
           sxt(filter_shift(30)(size_in_g-1 downto 0),add4'length);
  add5  <= sxt(filter_shift(5)(size_in_g-1 downto 0),add5'length)   +
           sxt(filter_shift(29)(size_in_g-1 downto 0),add5'length);
  add6  <= sxt(filter_shift(6)(size_in_g-1 downto 0),add6'length)   +
           sxt(filter_shift(28)(size_in_g-1 downto 0),add6'length);
  add7  <= sxt(filter_shift(7)(size_in_g-1 downto 0),add7'length)   +
           sxt(filter_shift(27)(size_in_g-1 downto 0),add7'length);
  add8  <= sxt(filter_shift(8)(size_in_g-1 downto 0),add8'length)   +
           sxt(filter_shift(26)(size_in_g-1 downto 0),add8'length);
  add9  <= sxt(filter_shift(9)(size_in_g-1 downto 0),add9'length)   +
           sxt(filter_shift(25)(size_in_g-1 downto 0),add9'length);
  add10 <= sxt(filter_shift(10)(size_in_g-1 downto 0),add10'length) +
           sxt(filter_shift(24)(size_in_g-1 downto 0),add10'length);
  add11 <= sxt(filter_shift(11)(size_in_g-1 downto 0),add11'length) +
           sxt(filter_shift(23)(size_in_g-1 downto 0),add11'length);
  add12 <= sxt(filter_shift(12)(size_in_g-1 downto 0),add12'length) +
           sxt(filter_shift(22)(size_in_g-1 downto 0),add12'length);
  add13 <= sxt(filter_shift(13)(size_in_g-1 downto 0),add13'length) +
           sxt(filter_shift(21)(size_in_g-1 downto 0),add13'length);
  add14 <= sxt(filter_shift(14)(size_in_g-1 downto 0),add14'length) +
           sxt(filter_shift(20)(size_in_g-1 downto 0),add14'length);
  add15 <= sxt(filter_shift(15)(size_in_g-1 downto 0),add15'length) +
           sxt(filter_shift(19)(size_in_g-1 downto 0),add15'length);
  add16 <= sxt(filter_shift(16)(size_in_g-1 downto 0),add16'length) +
           sxt(filter_shift(18)(size_in_g-1 downto 0),add16'length);
  add17 <= sxt(filter_shift(17)(size_in_g-1 downto 0),add17'length);


  -----------------------------------------------------------------------------
  -- Mults : the additions are multiplied by the 35 filter coefficients
  -----------------------------------------------------------------------------

  -- f0 = f34 = -(2^-6)
  filter_mul_0 <= signed(add0) * signed(COEF_F0_CT);

  
  -- f1 = f33 = -(2^-6 + 2^-7)
  filter_mul_1 <= signed(add1) * signed(COEF_F1_CT);
                  
  
  -- f2 = f32 = -(2^-7)
  filter_mul_2 <= signed(add2) * signed(COEF_F2_CT);


  -- f3 = f31 = 2^-6
  filter_mul_3 <= signed(add3) * signed(COEF_F3_CT);


  -- f4 = f31 = 2^-5
  filter_mul_4 <= signed(add4) * signed(COEF_F4_CT);


  -- f5 = f29 = 0
  filter_mul_5 <= signed(add5) * signed(COEF_F5_CT);

  
  -- f6 = f28 = -(2^-5 + 2^-6)
  filter_mul_6 <= signed(add6) * signed(COEF_F6_CT);
  
  
  -- f7 = f27 = -(2^-4)
  filter_mul_7 <= signed(add7) * signed(COEF_F7_CT);


  -- f8 = f26 = -(2^-7)
  filter_mul_8 <= signed(add8) * signed(COEF_F8_CT);


  -- f9 = f25 = 2^-4 + 2^-7
  filter_mul_9 <= signed(add9) * signed(COEF_F9_CT);


  -- f10 = f24 = 2^-4 + 2^-5
  filter_mul_10 <= signed(add10) * signed(COEF_F10_CT);


  -- f11 = f23 = 2^-7
  filter_mul_11 <= signed(add11) * signed(COEF_F11_CT);


  -- f12 = f22 = -(2^-3 + 2^-6 + 2^-7)
  filter_mul_12 <= signed(add12) * signed(COEF_F12_CT);


  -- f13 = f21 = -(2^-3 + 2^-4 + 2^-6)
  filter_mul_13 <= signed(add13) * signed(COEF_F13_CT);


  -- f14 = f20 = -(2^-6)
  filter_mul_14 <= signed(add14) * signed(COEF_F14_CT);


  -- f15 = f19 = 2^-2 + 2^-3 + 2^-6
  filter_mul_15 <= signed(add15) * signed(COEF_F15_CT);


  -- f16 = f18 = 2^-1 + 2^-2 + 2^-4 + 2^-7
  filter_mul_16 <= signed(add16) * signed(COEF_F16_CT);


  -- f17 = 2^-1 + 2^-2 + 2^-3 + 2^-4 + 2^-5 + 2^-6 + 2^-7
  filter_mul_17 <= signed(add17) * signed(COEF_F17_CT);

  -----------------------------------------------------------------------------
  -- Intermediate value
  -- When fpga, cut combinatory path with FF
  -----------------------------------------------------------------------------
  ASIC_GEN : if TARGET_CT = ASIC generate
    
    filter_interm_mul_0  <= filter_mul_0;
    filter_interm_mul_1  <= filter_mul_1;
    filter_interm_mul_2  <= filter_mul_2;
    filter_interm_mul_3  <= filter_mul_3;
    filter_interm_mul_4  <= filter_mul_4;
    filter_interm_mul_5  <= filter_mul_5;
    filter_interm_mul_6  <= filter_mul_6;
    filter_interm_mul_7  <= filter_mul_7;
    filter_interm_mul_8  <= filter_mul_8;
    filter_interm_mul_9  <= filter_mul_9;
    filter_interm_mul_10 <= filter_mul_10;
    filter_interm_mul_11 <= filter_mul_11;
    filter_interm_mul_12 <= filter_mul_12;
    filter_interm_mul_13 <= filter_mul_13;
    filter_interm_mul_14 <= filter_mul_14;
    filter_interm_mul_15 <= filter_mul_15;
    filter_interm_mul_16 <= filter_mul_16;
    filter_interm_mul_17 <= filter_mul_17;
    
  end generate ASIC_GEN;


  FPGA_GEN : if TARGET_CT = FPGA generate
    
    filter_fpga_buffering_p : process (reset_n, clk)
    begin
      if reset_n = '0' then
        filter_interm_mul_0  <= (others => '0');
        filter_interm_mul_1  <= (others => '0');
        filter_interm_mul_2  <= (others => '0');
        filter_interm_mul_3  <= (others => '0');
        filter_interm_mul_4  <= (others => '0');
        filter_interm_mul_5  <= (others => '0');
        filter_interm_mul_6  <= (others => '0');
        filter_interm_mul_7  <= (others => '0');
        filter_interm_mul_8  <= (others => '0');
        filter_interm_mul_9  <= (others => '0');
        filter_interm_mul_10 <= (others => '0');
        filter_interm_mul_11 <= (others => '0');
        filter_interm_mul_12 <= (others => '0');
        filter_interm_mul_13 <= (others => '0');
        filter_interm_mul_14 <= (others => '0');
        filter_interm_mul_15 <= (others => '0');
        filter_interm_mul_16 <= (others => '0');
        filter_interm_mul_17 <= (others => '0');
      elsif clk'event and clk = '1' then
        if clear_buffer = '1' then
          filter_interm_mul_0  <= (others => '0');
          filter_interm_mul_1  <= (others => '0');
          filter_interm_mul_2  <= (others => '0');
          filter_interm_mul_3  <= (others => '0');
          filter_interm_mul_4  <= (others => '0');
          filter_interm_mul_5  <= (others => '0');
          filter_interm_mul_6  <= (others => '0');
          filter_interm_mul_7  <= (others => '0');
          filter_interm_mul_8  <= (others => '0');
          filter_interm_mul_9  <= (others => '0');
          filter_interm_mul_10 <= (others => '0');
          filter_interm_mul_11 <= (others => '0');
          filter_interm_mul_12 <= (others => '0');
          filter_interm_mul_13 <= (others => '0');
          filter_interm_mul_14 <= (others => '0');
          filter_interm_mul_15 <= (others => '0');
          filter_interm_mul_16 <= (others => '0');
          filter_interm_mul_17 <= (others => '0');
        else
          filter_interm_mul_0  <= filter_mul_0;
          filter_interm_mul_1  <= filter_mul_1;
          filter_interm_mul_2  <= filter_mul_2;
          filter_interm_mul_3  <= filter_mul_3;
          filter_interm_mul_4  <= filter_mul_4;
          filter_interm_mul_5  <= filter_mul_5;
          filter_interm_mul_6  <= filter_mul_6;
          filter_interm_mul_7  <= filter_mul_7;
          filter_interm_mul_8  <= filter_mul_8;
          filter_interm_mul_9  <= filter_mul_9;
          filter_interm_mul_10 <= filter_mul_10;
          filter_interm_mul_11 <= filter_mul_11;
          filter_interm_mul_12 <= filter_mul_12;
          filter_interm_mul_13 <= filter_mul_13;
          filter_interm_mul_14 <= filter_mul_14;
          filter_interm_mul_15 <= filter_mul_15;
          filter_interm_mul_16 <= filter_mul_16;
          filter_interm_mul_17 <= filter_mul_17;
        end if;
      end if;
    end process filter_fpga_buffering_p;
    
  end generate FPGA_GEN;


  -----------------------------------------------------------------------------
  -- Last stage : Additions of the branches
  -----------------------------------------------------------------------------
  sum <= ((((sxt(filter_interm_mul_0,sum'length)  + sxt(filter_interm_mul_1,sum'length))
             +
            (sxt(filter_interm_mul_2,sum'length)  + sxt(filter_interm_mul_3,sum'length)))
             +
           ((sxt(filter_interm_mul_4,sum'length)  + sxt(filter_interm_mul_5,sum'length))
             +           
            (sxt(filter_interm_mul_6,sum'length)  + sxt(filter_interm_mul_7,sum'length))))
             +           
          (((sxt(filter_interm_mul_8,sum'length)  + sxt(filter_interm_mul_9,sum'length))
             +           
            (sxt(filter_interm_mul_10,sum'length) + sxt(filter_interm_mul_11,sum'length)))
             +           
           ((sxt(filter_interm_mul_12,sum'length) + sxt(filter_interm_mul_13,sum'length))
             +           
            (sxt(filter_interm_mul_14,sum'length) + sxt(filter_interm_mul_15,sum'length)))))
             +           
            (sxt(filter_interm_mul_16,sum'length) + sxt(filter_interm_mul_17,sum'length));


  -----------------------------------------------------------------------------
  -- Output saturation : -(2^size_out_g - 1) < sum < 2^size_out_g
  -----------------------------------------------------------------------------
  
  -- Output saturation
  output_p: process (reset_n, clk)
  begin  
    if reset_n = '0' then               
      add_stage_o <= (others => '0');
    elsif clk'event and clk = '1' then
      if clear_buffer = '1' then
        add_stage_o <= (others => '0');
      else
--------------------------------------------------------------------------------
-- function sat_signed_slv : truncate and saturate a signed number
-- remove nb_to_rem MSB of sat_signed_slv and saturate the signal if needed by
-- "01111..." (positive numbers) or "1000....." (negative numbers)
--------------------------------------------------------------------------------
        add_stage_o <= sat_signed_slv(sum(size_in_g+13 downto 3), size_in_g+13-1 - size_out_g -1);
      end if;
    end if;
  end process output_p; 


  ------------------------------------------
  -- DC Offset pre-estimation
  ------------------------------------------

  -- Diff between sample 32 and 0
  dc_diff <= sxt(filter_shift(0),dc_diff'length) -
             sxt(filter_shift(32),dc_diff'length);

  -- DC accumulator
  dc_accu_p : process (reset_n, clk)
  begin
    if reset_n = '0' then
      dc_accu <= (others => '0');
    elsif clk'event and clk = '1' then
      if clear_buffer = '1' then
        dc_accu <= (others => '0');
      elsif tx_active = '0' then
        dc_accu <= dc_accu + sxt(dc_diff,dc_accu'length);
      end if;
    end if;
  end process dc_accu_p;

  -- DC accumulator roundind 3 lsb
  dc_accu_rnd <= dc_accu(14 downto 2) + '1';
  
  -- Multiplier (dc_accu_rnd * 947)
  dc_accu_mul <= std_logic_vector'(signed(dc_accu_rnd(12 downto 1)) *
                                   signed('0' & SCALE_CT));

  -- Rounding after multiplier
  dc_accu_mul_rnd <= dc_accu_mul(21 downto 10) + '1';

  -- Output generation
  dc_pre_est_out_p : process (reset_n, clk)
  begin
    if reset_n = '0' then
      dc_pre_estim_4_agc <= (others => '0');
      dc_pre_estim       <= (others => '0');
    elsif clk'event and clk = '1' then
      if clear_buffer = '1' then
        dc_pre_estim_4_agc <= (others => '0');
        dc_pre_estim       <= (others => '0');
      elsif tx_active = '0' then
        -- DC Pre-estimation output
        if dc_pre_estim_valid = '0' then
          dc_pre_estim <= dc_accu_mul_rnd(11 downto 1);
        end if;
        -- DC Pre-estimation output fixed for AGC
        if sel_dc_mode = '0' or 
          (sel_dc_mode = '1' and dc_pre_estim_valid = '0') then
          dc_pre_estim_4_agc <= dc_accu_mul_rnd(11 downto 1);
        end if;
      end if;
    end if;
  end process dc_pre_est_out_p;


  end generate SYNC_RESET_GEN;


end RTL;
