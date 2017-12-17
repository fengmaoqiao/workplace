
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: iq_calibration_gen.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Signal generator for the IQ/DC calibration.
--              Generates a complex-valued sinusoid
--              with programmable gain and frequency.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/iq_calibration_gen/vhdl/rtl/iq_calibration_gen.vhd,v  
--  Log: iq_calibration_gen.vhd,v  
-- Revision 1.2  2003/04/07 13:24:17  Dr.A
-- Reduced data size.
--
-- Revision 1.1  2003/03/27 13:03:00  Dr.A
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
 
--library sine_table_rom_rtl;
library work;
--use sine_table_rom_rtl.sine_table_rom_pkg.all;
use work.sine_table_rom_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity iq_calibration_gen is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------

    clk          : in  std_logic; -- Module clock.
    reset_n      : in  std_logic; -- Asynchronous reset.
    --------------------------------------
    -- Controls
    --------------------------------------
    calfrq0_i    : in  std_logic_vector(22 downto 0); -- Phase increment.
    calgain_i    : in  std_logic_vector( 2 downto 0); -- Gain parameter.
    data_ready_i : in  std_logic; -- Next block is ready to accept data.
    --------------------------------------
    -- Data
    --------------------------------------
    sig_im_o     : out std_logic_vector(7 downto 0);
    sig_re_o     : out std_logic_vector(7 downto 0) 
  );

end iq_calibration_gen;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of iq_calibration_gen is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signal generator phase.
  signal nco_phase     : std_logic_vector(23 downto 0);
  -- Sign to apply to the sinusoid tables values.
  signal sin_sgn       : std_logic;
  signal cos_sgn       : std_logic;
  -- Sinusoid tables address.
  signal sin_addr      : std_logic_vector(9 downto 0);
  signal cos_addr      : std_logic_vector(9 downto 0);
  signal addr_image    : std_logic_vector(9 downto 0);
  -- Values read from the sinusoid tables.
  signal sin_coeff     : std_logic_vector(9 downto 0);
  signal cos_coeff     : std_logic_vector(9 downto 0);
  -- Values read from the sinusoid tables inverted. 
  signal sin_coeff_neg : std_logic_vector(7 downto 0);
  signal cos_coeff_neg : std_logic_vector(7 downto 0);
  -- Correct values, chosen between _coeff and _coeff_neg signals.
  signal sin_correct   : std_logic_vector(7 downto 0);
  signal cos_correct   : std_logic_vector(7 downto 0);
  
  signal sig_im_nxt    : std_logic_vector(7 downto 0);
  signal sig_re_nxt    : std_logic_vector(7 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- This process calculates parameters for signal generation (phase increment).
  nco_phase_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      nco_phase <= (others => '0');
    elsif clk'event and clk = '1' then
      -- If next unit is ready or no data has been set.
      if data_ready_i = '1' then 
        -- Calculate a new phase value. 
        nco_phase <= nco_phase + calfrq0_i;
      end if;
    end if;
  end process nco_phase_p;
  

  -- Sine and Cosine tables address processing.
  addr_image <= (others => '1') when nco_phase(21 downto 12) = "0000000000"
                else not(nco_phase(21 downto 12)) + 1;
  sin_addr <= nco_phase(21 downto 12) when nco_phase(22) = '0' else addr_image;
  cos_addr <= nco_phase(21 downto 12) when nco_phase(22) = '1' else addr_image;

  
  -- Sinusoid ROM tables.
  sin_rom : sine_table_rom
    port map (
      addr_i => sin_addr,
      sin_o  => sin_coeff
      );

  cos_rom : sine_table_rom
    port map (
      addr_i => cos_addr,
      sin_o  => cos_coeff
      );

  -- Sign extension. Use only 7 bits from the tables.
  sin_coeff_neg <= not('0' & sin_coeff(9 downto 3)) + 1;
  cos_coeff_neg <= not('0' & cos_coeff(9 downto 3)) + 1;
  
  -- Locate the quadrant to know if sin and cos values must be inverted.
  sin_sgn <= nco_phase(23);
  cos_sgn <= nco_phase(23) xor nco_phase(22);
  
  -- Assign sinusoid value with correct sign.
  sin_correct <= '0' & sin_coeff(9 downto 3) when sin_sgn = '0'
    else sin_coeff_neg;
  cos_correct <= '0' & cos_coeff(9 downto 3) when cos_sgn = '0'
    else cos_coeff_neg;

  -- This process adapts the IQ signal gain calibration following the settings
  -- of calgain_i.
  gain_adjustment_p : process (sin_correct, cos_correct, calgain_i)
    variable tmp_sig_im : std_logic_vector(8 downto 0);
    variable tmp_sig_re : std_logic_vector(8 downto 0);
  begin
    -- Increase the number of bits with 1 before right-shift and rounding.
    
    -- Division by 2^calgain.
    case calgain_i is
      
      when "000" => -- division by 1 (No shifting should be done).
        tmp_sig_im := sin_correct & '0';
        tmp_sig_re := cos_correct & '0';

      when "001" =>
        tmp_sig_im := sin_correct(7) & sin_correct(7 downto 0);
        tmp_sig_re := cos_correct(7) & cos_correct(7 downto 0);

      when "010" =>
        tmp_sig_im(8 downto 7) := (others => sin_correct(7));
        tmp_sig_im(6 downto 0) :=  sin_correct(7 downto 1);
        tmp_sig_re(8 downto 7) := (others => cos_correct(7));
        tmp_sig_re(6 downto 0) :=  cos_correct(7 downto 1);
                  
      when "011" =>
        tmp_sig_im(8 downto 6) := (others => sin_correct(7));
        tmp_sig_im(5 downto 0) :=  sin_correct(7 downto 2);
        tmp_sig_re(8 downto 6) := (others => cos_correct(7));
        tmp_sig_re(5 downto 0) :=  cos_correct(7 downto 2);
                 
      when "100" =>
        tmp_sig_im(8 downto 5) := (others => sin_correct(7));
        tmp_sig_im(4 downto 0) :=  sin_correct(7 downto 3);
        tmp_sig_re(8 downto 5) := (others => cos_correct(7));
        tmp_sig_re(4 downto 0) :=  cos_correct(7 downto 3);

      when "101" =>
        tmp_sig_im(8 downto 4) := (others => sin_correct(7));
        tmp_sig_im(3 downto 0) :=  sin_correct(7 downto 4);
        tmp_sig_re(8 downto 4) := (others => cos_correct(7));
        tmp_sig_re(3 downto 0) :=  cos_correct(7 downto 4);
                 
      when "110" =>
        tmp_sig_im(8 downto 3) := (others => sin_correct(7));
        tmp_sig_im(2 downto 0) :=  sin_correct(7 downto 5);
        tmp_sig_re(8 downto 3) := (others => cos_correct(7));
        tmp_sig_re(2 downto 0) :=  cos_correct(7 downto 5);
                 
      when others => -- "111"
        tmp_sig_im(8 downto 2) := (others => sin_correct(7));
        tmp_sig_im(1 downto 0) :=  sin_correct(7 downto 6);
        tmp_sig_re(8 downto 2) := (others => cos_correct(7));
        tmp_sig_re(1 downto 0) :=  cos_correct(7 downto 6);
                 
    end case;
    
    -- Rounding (y = (2x+1)/2 )       
    tmp_sig_im := tmp_sig_im + 1;
    tmp_sig_re := tmp_sig_re + 1;

    sig_im_nxt <= tmp_sig_im(8 downto 1);
    sig_re_nxt <= tmp_sig_re(8 downto 1);
    
  end process gain_adjustment_p;


  -- This process registers the outputs.
  reg_out : process (clk, reset_n)
  begin
    if reset_n = '0' then
      sig_im_o <= (others => '0');
      sig_re_o <= (others => '0');
    elsif clk'event and clk = '1' then
      -- If next unit is ready or no data has been set.
      if data_ready_i = '1' then
        -- Set next output values.
        sig_im_o <= sig_im_nxt;
        sig_re_o <= sig_re_nxt;
      end if;
    end if;
  end process reg_out;


end RTL;
