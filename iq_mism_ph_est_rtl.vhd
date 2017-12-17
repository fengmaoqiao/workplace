
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: iq_mism_ph_est.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.11  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : IQ Phase Mismatch Estimation block.
--               Bit-true with MATLAB 23/10/03
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/iq_estimation/vhdl/rtl/iq_mism_ph_est.vhd,v  
--  Log: iq_mism_ph_est.vhd,v  
-- Revision 1.11  2004/11/02 15:08:54  Dr.C
-- #BugId:703#
-- Removed Kgs coefficient in the phase estimation.
--
-- Revision 1.10  2003/12/22 16:11:08  Dr.C
-- Increase ph_step and ph_step_inv by one bit.
--
-- Revision 1.9  2003/12/03 14:46:06  rrich
-- Fixed problem with initialisation (see top-level comment).
--
-- Revision 1.8  2003/12/02 13:18:27  rrich
-- Mods to allow ph_est to be initialised (converted to correct format)
-- immediately after loading presets.
--
-- Revision 1.7  2003/11/25 18:28:04  Dr.C
-- Change condition for init value.
--
-- Revision 1.6  2003/11/03 10:40:52  rrich
-- Addded new IQMMEST input.
--
-- Revision 1.5  2003/10/23 13:11:26  rrich
-- Bit-true with MATLAB
--
-- Revision 1.4  2003/10/23 11:45:54  rrich
-- Removed old architecture, causing problems.
--
-- Revision 1.3  2003/10/23 07:56:16  rrich
-- Complete revision of estimation post-processing algorithm.
--
-- Revision 1.2  2003/08/26 14:51:29  rrich
-- Bit-truified phase estimate.
--
-- Revision 1.1  2003/06/04 15:23:41  rrich
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
entity iq_mism_ph_est is
  generic (
    iq_accum_width_g : integer := 7;   -- Width of input accumulated IQ signals
    phase_width_g    : integer := 6;   -- Phase mismatch width
    preset_width_g   : integer := 16); -- Preset width
  
  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    
    ---------------------------------------------------------------------------
    -- Data in
    ---------------------------------------------------------------------------
    iq_accum     : in  std_logic_vector(iq_accum_width_g-1 downto 0);
    
    --------------------------------------
    -- Controls
    --------------------------------------
    iqmm_est     : in  std_logic; -- IQMMEST register
    est_start    : in  std_logic; -- Start estimation
    est_en       : in  std_logic; -- Estimation enable
    est_reset    : in  std_logic; -- Restart estimation
    ph_pset      : in  std_logic_vector(preset_width_g-1 downto 0);
    ph_step_in   : in  std_logic_vector(7 downto 0); 
    ctrl_cnt     : in  std_logic_vector(5 downto 0);
    initialise   : in  std_logic; -- Initialising estimation
    
    --------------------------------------
    -- Estimate out
    --------------------------------------
    ph_est_valid : out std_logic;
    ph_est       : out std_logic_vector(phase_width_g-1 downto 0);
    phase_accum  : out std_logic_vector(preset_width_g-1 downto 0));
    
end iq_mism_ph_est;


-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture rtl of iq_mism_ph_est is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant STEP_SIZE_CT        : integer := 8;
  constant ADDEND_SIZE_CT      : integer := STEP_SIZE_CT+1;
  constant IQ_ACCU_SIZE_CT     : integer := iq_accum_width_g;
  constant PH_EST_SIZE_CT      : integer := phase_width_g;
  constant PH_PSET_SIZE_CT     : integer := preset_width_g;
  constant AV_PH_SIZE_CT       : integer := 20;-- internal accumulator size

  constant AV_PH_MAX_CT         : std_logic_vector(AV_PH_SIZE_CT-1 downto 0) := (others => '1');
  constant AV_PH_MIN_CT         : std_logic_vector(AV_PH_SIZE_CT-1 downto 0) := (others => '0');

  constant PH_EST_SEL_CT       : integer := AV_PH_SIZE_CT-PH_EST_SIZE_CT;
  constant ZEROS_AV_PH_M_G_EST_CT : std_logic_vector(PH_EST_SEL_CT-1 downto 0)
                                     := (others => '0');
  constant ZEROS_PSET_PAD_CT   : std_logic_vector(AV_PH_SIZE_CT-PH_PSET_SIZE_CT-1 downto 0)
                                   := (others => '0');
  constant ZEROS_STEP_SIZE_CT  : std_logic_vector(STEP_SIZE_CT-1 downto 0)
                                   := (others => '0');
  constant ZEROS_AV_PH_SIZE_CT : std_logic_vector(AV_PH_SIZE_CT-1 downto 0)
                                   := (others => '0');
  constant ZEROS_PH_EST_M1_CT : std_logic_vector(PH_EST_SIZE_CT-2 downto 0)
                                   := (others => '0');

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal av_ph_reg       : std_logic_vector(AV_PH_SIZE_CT-1 downto 0);
  signal ph_est_psat     : std_logic_vector(PH_EST_SIZE_CT-1 downto 0);
  signal ph_est_rnd_word : std_logic_vector(PH_EST_SIZE_CT-1 downto 0);
  signal ph_est_sat_word : std_logic_vector(PH_EST_SIZE_CT-1 downto 0);

  signal av_ph_valid     : std_logic;
  signal ph_est_sat      : std_logic;
  signal ph_est_rnd      : std_logic;
  signal sum_start       : std_logic;
  
  signal x_reg           : std_logic_vector(ADDEND_SIZE_CT-1 downto 0);
  signal y_reg           : std_logic_vector(AV_PH_SIZE_CT-1 downto 0);
  signal sum_xy_bit      : std_logic;  
  signal sum_xy_reg      : std_logic_vector(AV_PH_SIZE_CT downto 0);
  signal ph_step         : std_logic_vector(STEP_SIZE_CT downto 0);
  signal ph_step_inv     : std_logic_vector(STEP_SIZE_CT downto 0);

  
begin  -- rtl

  ------------------------------------------------------------------------------
  -- Phase mismatch estimation (320 cycles to complete)
  ------------------------------------------------------------------------------

  -- Select positive or negative step
  ph_step_inv <= not ('0' & ph_step_in) + '1';
  ph_step <= '0' & ph_step_in when iq_accum(IQ_ACCU_SIZE_CT-1) = '1' else ph_step_inv;
  
  -- Build g_est rounding word
  ph_est_rnd_word <= ZEROS_PH_EST_M1_CT & av_ph_reg(PH_EST_SEL_CT-1);

  -- Bit-serial adder to perform av_ph_reg + ph_step and rounding of ph_est
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
  begin
    if reset_n = '0' then
      x_reg      <= (others => '0');
      y_reg      <= (others => '0');
      sum_xy_reg <= (others => '0');
    elsif clk'event and clk = '1' then
      if est_en = '1' or initialise = '1' then  -- estimation enabled or initialising

        if est_start = '1' then
          -- load for addition of ph_step
          x_reg <= sxt(ph_step,ADDEND_SIZE_CT);
          y_reg <= av_ph_reg;
        elsif ph_est_rnd = '1' then
          -- Load registers for ph_est rounding 
          x_reg <= sxt(ph_est_rnd_word,ADDEND_SIZE_CT);
          y_reg <= ZEROS_AV_PH_M_G_EST_CT & av_ph_reg(AV_PH_SIZE_CT-1 downto PH_EST_SEL_CT);
        else
          -- addends supplied to adder 1 bit at a time LSB first
          x_reg <= x_reg(ADDEND_SIZE_CT-1)                -- sign extended
                            & x_reg(ADDEND_SIZE_CT-1 downto 1);
          y_reg <= y_reg(AV_PH_SIZE_CT-1)     -- sign extended 
                            & y_reg(AV_PH_SIZE_CT-1 downto 1);          
          -- sum appears from arithmetic 1 bit at a time LSB first
          sum_xy_reg <= sum_xy_bit & sum_xy_reg(AV_PH_SIZE_CT downto 1);
        end if;
      end if;
    end if;
  end process add_ctl_p;


  -- Timing derived control signals
  av_ph_valid   <= '1' when ctrl_cnt = "011001" else '0';  -- 25
  ph_est_rnd    <= '1' when ctrl_cnt = "011010" else '0';  -- 26
  ph_est_sat    <= '1' when ctrl_cnt = "100010" else '0';  -- 34

  -- Initialise adder
  sum_start  <= est_start or ph_est_rnd;
  
  -- Build ph_est_psat (pre-saturation) and ph_est_sat_word, this is ORed with
  -- the pre-saturation value. This can be done because the rounding addition
  -- can only move the value in a positive direction.
  ph_est_psat     <= sum_xy_reg(AV_PH_SIZE_CT-1 downto PH_EST_SEL_CT);
  ph_est_sat_word <= (others => sum_xy_reg(AV_PH_SIZE_CT));
 

  ph_est_reg_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      ph_est_valid <= '0';
      ph_est       <= (others => '0');
      av_ph_reg    <= (others => '0');
    elsif clk'event and clk = '1' then
      if est_reset = '1' then
        -- load av_g_reg preset estimate  
        av_ph_reg <= ph_pset & ZEROS_PSET_PAD_CT;
      else
        
        if av_ph_valid = '1' and initialise = '0' then
          -- Detect overflow/underflow
          if sum_xy_reg(AV_PH_SIZE_CT) = '1' then
            -- x_reg is sign extended g_step
            if x_reg(0) = '0' then
              -- Adding ph_step so overflow
              av_ph_reg <= AV_PH_MAX_CT;
            else
              -- Subtracting ph_step so underflow
              av_ph_reg <= AV_PH_MIN_CT;
            end if;
          else
            -- Load av_ph_reg with new estimate
            av_ph_reg <= sum_xy_reg(AV_PH_SIZE_CT-1 downto 0);
          end if;          
        end if;

        -- ph_est is simply the 6 MSBs of av_ph_reg, rounded
        if ph_est_sat = '1' then 
          ph_est <= ph_est_psat or ph_est_sat_word;
        end if;

        ph_est_valid <= ph_est_sat;
        
      end if;
    end if;
  end process ph_est_reg_p;

    
  -- Phase mismatch estimate assignment  
  phase_accum  <= av_ph_reg(AV_PH_SIZE_CT-1 downto AV_PH_SIZE_CT-PH_PSET_SIZE_CT);

  
end rtl;
