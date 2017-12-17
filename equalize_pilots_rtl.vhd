
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: equalize_pilots.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Equalize pilots.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/equalize_pilots.vhd,v  
--  Log: equalize_pilots.vhd,v  
-- Revision 1.6  2005/03/11 10:06:39  Dr.C
-- #BugId:1130#
-- Added second_start_of_symbol_v to delay pilot scrambling sequence of one symbol.
--
-- Revision 1.5  2004/05/18 14:57:39  Dr.C
-- Added a saturation after the multiplier in process round_p.
--
-- Revision 1.4  2003/10/30 08:29:34  ahemani
-- Shifted rounding of the shared multiplier
-- Modification done by Christoph Klausman
--
-- Revision 1.3  2003/04/24 06:16:36  Dr.F
-- does not generate scrambling for the first start_of_symbol.
-- internaly generate a pulse of start_of_symbol.
--
-- Revision 1.2  2003/04/01 16:31:02  Dr.F
-- optimizations.
--
-- Revision 1.1  2003/03/27 07:48:44  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library pilot_tracking_rtl;
library work;
--use pilot_tracking_rtl.pilot_tracking_pkg.all;
use work.pilot_tracking_pkg.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity equalize_pilots is

  port (clk               : in  std_logic;
        reset_n           : in  std_logic;
        sync_reset_n      : in  std_logic;
        start_of_symbol_i : in  std_logic;
        start_of_burst_i  : in  std_logic;
        -- pilots from fft
        pilot_p21_i_i     : in  std_logic_vector(11 downto 0);
        pilot_p21_q_i     : in  std_logic_vector(11 downto 0);
        pilot_p7_i_i      : in  std_logic_vector(11 downto 0);
        pilot_p7_q_i      : in  std_logic_vector(11 downto 0);
        pilot_m21_i_i     : in  std_logic_vector(11 downto 0);
        pilot_m21_q_i     : in  std_logic_vector(11 downto 0);
        pilot_m7_i_i      : in  std_logic_vector(11 downto 0);
        pilot_m7_q_i      : in  std_logic_vector(11 downto 0);
        -- channel coefficients
        ch_m21_coef_i_i   : in  std_logic_vector(11 downto 0);
        ch_m21_coef_q_i   : in  std_logic_vector(11 downto 0);
        ch_m7_coef_i_i    : in  std_logic_vector(11 downto 0);
        ch_m7_coef_q_i    : in  std_logic_vector(11 downto 0);
        ch_p7_coef_i_i    : in  std_logic_vector(11 downto 0);
        ch_p7_coef_q_i    : in  std_logic_vector(11 downto 0);
        ch_p21_coef_i_i   : in  std_logic_vector(11 downto 0);
        ch_p21_coef_q_i   : in  std_logic_vector(11 downto 0);
        -- equalized pilots
        pilot_p21_i_o     : out std_logic_vector(11 downto 0);
        pilot_p21_q_o     : out std_logic_vector(11 downto 0);
        pilot_p7_i_o      : out std_logic_vector(11 downto 0);
        pilot_p7_q_o      : out std_logic_vector(11 downto 0);
        pilot_m21_i_o     : out std_logic_vector(11 downto 0);
        pilot_m21_q_o     : out std_logic_vector(11 downto 0);
        pilot_m7_i_o      : out std_logic_vector(11 downto 0);
        pilot_m7_q_o      : out std_logic_vector(11 downto 0);
        
        eq_done_o : out std_logic
        );


end equalize_pilots;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of equalize_pilots is


  constant NBIT_PILOT_CT : integer := 12;
  constant NBIT_EQ_CT    : integer := 12;

  signal eq_pilot_i : std_logic_vector(NBIT_PILOT_CT + NBIT_EQ_CT downto 0);
  signal eq_pilot_q : std_logic_vector(NBIT_PILOT_CT + NBIT_EQ_CT downto 0);
  signal eq_coef_i  : std_logic_vector(NBIT_EQ_CT-1 downto 0);
  signal eq_coef_q  : std_logic_vector(NBIT_EQ_CT-1 downto 0);
  signal pilot_i    : std_logic_vector(NBIT_PILOT_CT-1 downto 0);
  signal pilot_q    : std_logic_vector(NBIT_PILOT_CT-1 downto 0);

  signal start_of_symbol_ff1    : std_logic;
  signal start_of_symbol_pulse  : std_logic;
  
  signal pilot_scr_seq : std_logic_vector(6 downto 0);

  signal step : integer range 7 downto 0;

begin


  complex_mult_i1 : complex_mult
    generic map (Nbit_input1_g => NBIT_PILOT_CT,
                 Nbit_input2_g => NBIT_EQ_CT)
    port map (clk              => clk,
              reset_n          => reset_n,
              real_1_i         => pilot_i,
              imag_1_i         => pilot_q,
              real_2_i         => eq_coef_i,
              imag_2_i         => eq_coef_q,
              real_o           => eq_pilot_i,
              imag_o           => eq_pilot_q);

  sos_gen_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      start_of_symbol_ff1       <= '0';
      start_of_symbol_pulse     <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      start_of_symbol_ff1 <= start_of_symbol_i;
      if (start_of_symbol_i = '1') and (start_of_symbol_ff1 = '0') then
        start_of_symbol_pulse <= '1';
      else
        start_of_symbol_pulse <= '0';
      end if;
    end if;
  end process sos_gen_p;
  

  load_mult_p : process (clk, reset_n)
  begin  -- process load_mult_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      pilot_i       <= (others => '0');
      pilot_q       <= (others => '0');
      eq_coef_i     <= (others => '0');
      eq_coef_q     <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      case step is
        
        when 0 =>
          pilot_i   <= pilot_m21_i_i;
          pilot_q   <= pilot_m21_q_i;
          eq_coef_i <= ch_m21_coef_i_i;
          eq_coef_q <= -signed(ch_m21_coef_q_i);
        when  1 =>
          pilot_i   <= pilot_m7_i_i;
          pilot_q   <= pilot_m7_q_i;
          eq_coef_i <= ch_m7_coef_i_i;
          eq_coef_q <= -signed(ch_m7_coef_q_i);
        when 2 =>
          pilot_i   <= pilot_p7_i_i;
          pilot_q   <= pilot_p7_q_i;
          eq_coef_i <= ch_p7_coef_i_i;
          eq_coef_q <= -signed(ch_p7_coef_q_i);
        when  3 =>
          pilot_i   <= pilot_p21_i_i;
          pilot_q   <= pilot_p21_q_i;
          eq_coef_i <= ch_p21_coef_i_i;
          eq_coef_q <= -signed(ch_p21_coef_q_i);

      when others => null;
      end case;
    end if;
  end process load_mult_p;
  
  
 round_p              : process (clk, reset_n)
    variable pilot_i_v : std_logic_vector(NBIT_PILOT_CT-1 downto 0);
    variable pilot_q_v : std_logic_vector(NBIT_PILOT_CT-1 downto 0);

  begin  -- process round_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      pilot_p21_i_o <= (others => '0');
      pilot_p21_q_o <= (others => '0');
      pilot_p7_i_o  <= (others => '0');
      pilot_p7_q_o  <= (others => '0');
      pilot_m21_i_o <= (others => '0');
      pilot_m21_q_o <= (others => '0');
      pilot_m7_i_o  <= (others => '0');
      pilot_m7_q_o  <= (others => '0');

      pilot_i_v := (others => '0');
      pilot_q_v := (others => '0');

    elsif clk'event and clk = '1' then  -- rising clock edge
      
        -- sat. & round the output of the shared multiplier
        pilot_i_v := sat_round_signed_sym_slv(eq_pilot_i, 3, eq_pilot_i'high -
                                                               NBIT_PILOT_CT-2);
        pilot_q_v := sat_round_signed_sym_slv(eq_pilot_q, 3, eq_pilot_i'high -
                                                               NBIT_PILOT_CT-2);

        -- assign the rounded multiplier outputs to the output ports
        -- depolarize the equalized pilots
        case step  is
          when 2 =>         
          if pilot_scr_seq(0) = '0' then
            pilot_m21_i_o <= (pilot_i_v);
            pilot_m21_q_o <= (pilot_q_v);
          else
            pilot_m21_i_o <= (not pilot_i_v) + 1;
            pilot_m21_q_o <= (not pilot_q_v) + 1;
          end if;

        when 3 => 
          if pilot_scr_seq(0) = '0' then
            pilot_m7_i_o <= (pilot_i_v);
            pilot_m7_q_o <= (pilot_q_v);
          else
            pilot_m7_i_o <= (not pilot_i_v) + 1;
            pilot_m7_q_o <= (not pilot_q_v) + 1;
          end if;

        when  4 =>
          if pilot_scr_seq(0) = '0' then
            pilot_p7_i_o  <= (pilot_i_v);
            pilot_p7_q_o  <= (pilot_q_v);
          else
            pilot_p7_i_o  <= (not pilot_i_v) + 1;
            pilot_p7_q_o  <= (not pilot_q_v) + 1;
          end if;
        when 5 => 
          if pilot_scr_seq(0) = '0' then
            pilot_p21_i_o <= (not pilot_i_v) + 1;
            pilot_p21_q_o <= (not pilot_q_v) + 1;
          else
            pilot_p21_i_o <= (pilot_i_v);
            pilot_p21_q_o <= (pilot_q_v);
          end if;
          
        when others => null;
        end case;

    end if;
  end process round_p;


  -- generate pilot scrambling sequence
  pilot_scr_seq_p : process (clk, reset_n)
    variable first_start_of_symbol_v  : std_logic;
    variable second_start_of_symbol_v : std_logic;
  begin  -- process pilot_scr_seq_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      pilot_scr_seq               <= (others => '0');
      first_start_of_symbol_v := '0';
      second_start_of_symbol_v := '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if start_of_burst_i = '1' then
        pilot_scr_seq             <= "1111100";  --(others => '1');
        first_start_of_symbol_v := '0';
        second_start_of_symbol_v := '0';
      elsif start_of_symbol_pulse = '1' then
        if (first_start_of_symbol_v = '0') then
          first_start_of_symbol_v := '1';
        elsif (first_start_of_symbol_v = '1' and 
               second_start_of_symbol_v = '0') then
          second_start_of_symbol_v := '1';
        else 
          pilot_scr_seq(0)          <= pilot_scr_seq(3) xor pilot_scr_seq(6);
          pilot_scr_seq(6 downto 1) <= pilot_scr_seq(5 downto 0);
        end if;
      end if;
    end if;
  end process pilot_scr_seq_p;


  step_p : process (clk, reset_n)
  begin  -- process step_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      step        <= 7;
      eq_done_o   <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        step      <= 7;
        eq_done_o <= '0';
      else
        if start_of_symbol_pulse = '1' then
          step    <= 0;
        end if;
        if step /= 7 then
          step    <= step +1;
        end if;

        if step = 5 then
          eq_done_o <= '1';
        else
          eq_done_o <= '0';
        end if;

      end if;
    end if;
  end process step_p;
end rtl;
