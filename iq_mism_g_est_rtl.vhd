
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: iq_mism_g_est.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.13  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : IQ Gain Mismatch Estimation block.
--               Bit-true with MATLAB 23/10/03
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/iq_estimation/vhdl/rtl/iq_mism_g_est.vhd,v  
--  Log: iq_mism_g_est.vhd,v  
-- Revision 1.13  2004/11/02 15:08:51  Dr.C
-- #BugId:703#
-- Removed Kgs coefficient in the phase estimation.
--
-- Revision 1.12  2004/01/06 16:01:41  Dr.C
-- Changed init value of av_g_reg.
--
-- Revision 1.11  2003/12/22 16:10:20  Dr.C
-- Increase g_step & g_step_inv by one bit.
--
-- Revision 1.10  2003/12/03 16:10:27  Dr.C
-- Added G_EST_INIT_CT init value for g_est.
--
-- Revision 1.9  2003/12/03 14:45:51  rrich
-- Fixed initialisation problem (see top-level comment).
--
-- Revision 1.8  2003/12/02 13:18:01  rrich
-- Mods to allow g_est to be initialised immediately after loading presets.
--
-- Revision 1.7  2003/11/25 18:27:43  Dr.C
-- Change condition for init value.
--
-- Revision 1.6  2003/11/03 10:40:41  rrich
-- Added new IQMMEST input.
--
-- Revision 1.5  2003/10/23 13:11:08  rrich
-- Bit-true with MATLAB
--
-- Revision 1.4  2003/10/23 07:54:17  rrich
-- Complete revision of estimation post-processing algorithm, removal of divider
-- and square-root blocks.
--
-- Revision 1.3  2003/09/09 14:46:53  rrich
-- Changed reset value of gain estimate to 0x100 to avoid problems with
-- compensation block.
--
-- Revision 1.2  2003/08/26 14:51:13  rrich
-- Bit-truified gain estimate.
--
-- Revision 1.1  2003/06/04 15:23:37  rrich
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
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 

--library bit_ser_adder_rtl;
library work;
--use bit_ser_adder_rtl.bit_ser_adder_pkg.all;
use work.bit_ser_adder_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity iq_mism_g_est is
  generic (
    iq_accum_width_g : integer := 10;  -- Width of input accumulated IQ signals
    gain_width_g     : integer := 9;   -- Gain mismatch width
    preset_width_g   : integer := 16); -- Preset width 
  
  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    
    ---------------------------------------------------------------------------
    -- Data in
    ---------------------------------------------------------------------------
    i_accum : in  std_logic_vector(iq_accum_width_g-1 downto 0);
    q_accum : in  std_logic_vector(iq_accum_width_g-1 downto 0);

    --------------------------------------
    -- Controls
    --------------------------------------
    iqmm_est  : in  std_logic; -- IQMMEST register
    est_start : in  std_logic; -- Start estimation
    est_en    : in  std_logic; -- Estimation enable
    est_reset : in  std_logic; -- Restart estimation
    g_pset    : in  std_logic_vector(preset_width_g-1 downto 0);
    g_step_in : in  std_logic_vector(7 downto 0);
    ctrl_cnt  : in  std_logic_vector(5 downto 0);
    initialise: in  std_logic; -- Initialising estimation
    
    --------------------------------------
    -- Estimate out
    --------------------------------------
    g_est_valid : out std_logic;
    g_est       : out std_logic_vector(gain_width_g-1 downto 0);
    gain_accum  : out std_logic_vector(preset_width_g-1 downto 0));

    
end iq_mism_g_est;


-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture rtl of iq_mism_g_est is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant IQ_ACCU_SIZE_CT     : integer := iq_accum_width_g;
  constant G_EST_SIZE_CT       : integer := gain_width_g;
  constant G_PSET_SIZE_CT      : integer := preset_width_g;
  constant AV_G_SIZE_CT        : integer := 20;
  constant ZEROS_AV_G_M_ACC_CT : std_logic_vector(AV_G_SIZE_CT-IQ_ACCU_SIZE_CT-1 downto 0)
                                   := (others => '0');
  constant STEP_SIZE_CT        : integer := 8;
  constant ZEROS_PSET_PAD_CT   : std_logic_vector(AV_G_SIZE_CT-G_PSET_SIZE_CT-1 downto 0)
                                   := (others => '0');
  constant AV_G_RESET_CT       : std_logic_vector(AV_G_SIZE_CT-1 downto 0)
                                   := ('1', others => '0');
                                   --conv_std_logic_vector(1, AV_G_SIZE_CT-(AV_G_SIZE_CT-G_PSET_SIZE_CT))
                                     --   & ZEROS_PSET_PAD_CT;

  constant AV_G_MAX_CT         : std_logic_vector(AV_G_SIZE_CT-1 downto 0) := (others => '1');
  constant AV_G_MIN_CT         : std_logic_vector(AV_G_SIZE_CT-1 downto 0) := (others => '0');

  constant G_EST_SEL_CT          : integer := AV_G_SIZE_CT-G_EST_SIZE_CT;
  constant ZEROS_AV_G_M_G_EST_CT : std_logic_vector(G_EST_SEL_CT-1 downto 0)
                                     := (others => '0');
  
  constant ZEROS_G_EST_M1_CT   : std_logic_vector(G_EST_SIZE_CT-2 downto 0) := (others => '0');

  constant ZEROS_G_EST_SIZEM1_CT   : std_logic_vector(G_EST_SIZE_CT-2 downto 0)
                                       := (others => '0');
  constant G_EST_INIT_CT           : std_logic_vector(G_EST_SIZE_CT-1 downto 0)
                                       := '1' & ZEROS_G_EST_SIZEM1_CT;
  
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal x_reg          : std_logic_vector(IQ_ACCU_SIZE_CT-1 downto 0);
  signal y_reg          : std_logic_vector(AV_G_SIZE_CT-1 downto 0);
  signal sum_xy_bit     : std_logic;  
  signal sum_xy_reg     : std_logic_vector(AV_G_SIZE_CT downto 0);
  signal av_g_reg       : std_logic_vector(AV_G_SIZE_CT-1 downto 0);

  signal bit_equal      : std_logic; -- bit-wise equal
  signal bit_greater    : std_logic; -- bit-wise greater than
  signal equal          : std_logic; -- equal result for whole words
  signal greater        : std_logic; -- greater than result for whole words
  signal next_equal     : std_logic;
  signal next_greater   : std_logic;
  signal i_ge_q         : std_logic;

  signal g_step         : std_logic_vector(STEP_SIZE_CT downto 0);
  signal g_step_inv     : std_logic_vector(STEP_SIZE_CT downto 0);
  signal add_g_step     : std_logic;
  signal sum_start      : std_logic;
  signal av_g_valid     : std_logic;
  signal g_est_rnd_word : std_logic_vector(G_EST_SIZE_CT-1 downto 0);
  signal g_est_rnd      : std_logic;
  signal g_est_sat_word : std_logic_vector(G_EST_SIZE_CT-1 downto 0);
  signal g_est_sat      : std_logic;
  signal g_est_psat     : std_logic_vector(G_EST_SIZE_CT-1 downto 0);
  
  
begin  -- rtl

  ------------------------------------------------------------------------------
  -- Gain mismatch estimation (320 cycles to complete)
  ------------------------------------------------------------------------------

  -- SumI >= SumQ 
  -- Implementation of bit-serial greater than or equal to using two registers
  -- and a handful of gates.
  ge_regs_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      equal   <= '1';
      greater <= '0';
    elsif clk'event and clk = '1' then
      if est_en = '1' then              -- estimation enabled
        if est_start = '1' then
          equal   <= '1';
          greater <= '0';
        else
          equal   <= next_equal;
          greater <= next_greater;
        end if;
      end if;
    end if;
  end process ge_regs_p;

  bit_equal   <= not(x_reg(0) xor y_reg(0));
  bit_greater <= x_reg(0) and (not y_reg(0));

  next_equal   <= bit_equal and equal;
  next_greater <= bit_greater or (bit_equal and greater);

  i_ge_q <= greater or equal;

  -- Select positive or negative step
  g_step_inv <= not ('0' & g_step_in) + '1';
  g_step     <= '0' & g_step_in when i_ge_q = '1' else g_step_inv;

  -- Build g_est rounding word
  g_est_rnd_word <= ZEROS_G_EST_M1_CT & av_g_reg(G_EST_SEL_CT-1);
    
  -- Bit-serial adder to perform av_g_reg + g_step and g_est rounding
  adder_1 : bit_ser_adder
    port map (
      clk        => clk,
      reset_n    => reset_n,
      sync_reset => sum_start,
      x_in       => x_reg(0),
      y_in       => y_reg(0),
      sum_out    => sum_xy_bit);


  -- Control process for adder addend shift registers 
  add_ctl_p : process (clk, reset_n)
  begin  -- process add0_ctl_p
    if reset_n = '0' then
      x_reg      <= (others => '0');
      y_reg      <= (others => '0');
      sum_xy_reg <= (others => '0');
    elsif clk'event and clk = '1' then
      if est_en = '1' or initialise = '1' then  -- estimation enabled or initialising
        
        if est_start = '1' then
          -- load registers for greater than or equal to evaluation
          x_reg <= i_accum;
          y_reg <= ZEROS_AV_G_M_ACC_CT & q_accum;
        elsif add_g_step = '1' then
          -- Load registers for addition of g_step
          x_reg <= sxt(g_step,IQ_ACCU_SIZE_CT);
          y_reg <= av_g_reg;
        elsif g_est_rnd = '1' then
          -- Load registers for g_est rounding 
          x_reg <= sxt(g_est_rnd_word,IQ_ACCU_SIZE_CT);
          y_reg <= ZEROS_AV_G_M_G_EST_CT & av_g_reg(AV_G_SIZE_CT-1 downto G_EST_SEL_CT);
        else
          -- Shift registers right 1-bit at a time to load bit-serial
          -- adder or perform greater than or equal to operation. Sign
          -- extension is performed on x_reg (g_step), but not y_reg.
          x_reg <= x_reg(IQ_ACCU_SIZE_CT-1) & x_reg(IQ_ACCU_SIZE_CT-1 downto 1);
          y_reg <= '0' & y_reg(AV_G_SIZE_CT-1 downto 1);
          -- sum appears from adder 1 bit at a time LSB first
          sum_xy_reg <= sum_xy_bit & sum_xy_reg(AV_G_SIZE_CT downto 1);
        end if;

      end if;
    end if;
  end process add_ctl_p;


  -- Timing derived control signals
  add_g_step <= '1' when ctrl_cnt = "001010" else '0';  -- 10
  av_g_valid <= '1' when ctrl_cnt = "100000" else '0';  -- 32
  g_est_rnd  <= '1' when ctrl_cnt = "100001" else '0';  -- 33
  g_est_sat  <= '1' when ctrl_cnt = "101100" else '0';  -- 44

  -- Initialise adder
  sum_start <= add_g_step or g_est_rnd;

  -- Build g_est_psat (pre-saturation) and g_est_sat_word, this is ORed with
  -- the pre-saturation value. This can be done because the rounding addition
  -- can only move the value in a positive direction.
  g_est_psat     <= sum_xy_reg(AV_G_SIZE_CT-1 downto G_EST_SEL_CT);
  g_est_sat_word <= (others => sum_xy_reg(AV_G_SIZE_CT));
  
  g_est_reg_p: process (clk, reset_n)
  begin  -- process g_est_reg_p
    if reset_n = '0' then
      g_est_valid <= '0';
      g_est       <= G_EST_INIT_CT;
      av_g_reg    <= AV_G_RESET_CT;
    elsif clk'event and clk = '1' then
      if est_reset = '1' then
        -- load av_g_reg preset estimate  
        av_g_reg <= g_pset & ZEROS_PSET_PAD_CT;
      else
        
        if av_g_valid = '1' and initialise = '0' then
          -- Detect overflow/underflow
          if sum_xy_reg(AV_G_SIZE_CT) = '1' then
            -- x_reg is sign extended g_step
            if x_reg(0) = '0' then
              -- Adding g_step so overflow
              av_g_reg <= AV_G_MAX_CT;
            else
              -- Subtracting g_step so underflow
              av_g_reg <= AV_G_MIN_CT;
            end if;
          else
            -- Load av_g_reg with new estimate
            av_g_reg <= sum_xy_reg(AV_G_SIZE_CT-1 downto 0);
          end if;          
        end if;

        -- g_est is simply the 9 MSBs of av_g_reg, rounded
        if g_est_sat = '1' then 
          g_est <= g_est_psat or g_est_sat_word;
        end if;

        g_est_valid <= g_est_sat;
        
      end if;
    end if;
  end process g_est_reg_p;

    
  -- Gain mismatch estimate assignment  
  gain_accum  <= av_g_reg(AV_G_SIZE_CT-1 downto AV_G_SIZE_CT-G_PSET_SIZE_CT);

  
end rtl;
