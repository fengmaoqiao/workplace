
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: comp_angle.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Compute angle.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/comp_angle.vhd,v  
--  Log: comp_angle.vhd,v  
-- Revision 1.6  2004/05/27 07:54:21  Dr.C
-- Debugged unwrap phase calculation.
--
-- Revision 1.5  2003/07/17 13:55:03  Dr.F
-- added saturation on computed and estimated phases.
--
-- Revision 1.4  2003/06/25 16:10:45  Dr.F
-- code cleaning.
--
-- Revision 1.3  2003/04/02 11:42:52  Dr.F
-- changed unwrap process.
--
-- Revision 1.2  2003/04/01 16:30:48  Dr.F
-- optimizations.
--
-- Revision 1.1  2003/03/27 07:48:41  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--library pilot_tracking_rtl;
library work;
--use pilot_tracking_rtl.pilot_tracking_pkg.all;
use work.pilot_tracking_pkg.all;

--library cordic_vectoring_rtl;
library work;

--------------------------------------------
-- Entity
--------------------------------------------
entity comp_angle is
  generic (Nbit_ph_g     : integer := 13;
           Nbit_pilots_g : integer := 12;
           Nbit_pred_g   : integer := 17
           );

  port (clk           : in std_logic;
        reset_n       : in std_logic;
        sync_reset_n  : in std_logic;
        data_valid_i  : in std_logic;
        pilot_p21_i_i : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_p21_q_i : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_p7_i_i  : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_p7_q_i  : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_m21_i_i : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_m21_q_i : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_m7_i_i  : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_m7_q_i  : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        cpe_pred_i    : in std_logic_vector(Nbit_pred_g-1 downto 0);
        sto_pred_i    : in std_logic_vector(Nbit_pred_g-1 downto 0);
        
        data_valid_o : out std_logic;
        ph_m21_o     : out std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_m7_o      : out std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_p7_o      : out std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_p21_o     : out std_logic_vector(Nbit_ph_g-1 downto 0)
        );


end comp_angle;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of comp_angle is

  -- number of microrotation stages in a combinational path :
  constant NBR_COMBSTAGE_CT : integer := 3;  -- must be > 0
  -- number of pipes
  constant NBR_PIPE_CT      : integer := 4;  -- must be > 0
  -- NOTE : the total number of microrotations is nbr_combstage_g * nbr_pipe_g


  constant PI2_CT : std_logic_vector(12 downto 0) := "0110010010001";  -- 2*pi with 9Bit fraction
  constant PI_CT  : std_logic_vector(11 downto 0) := "011001001000";  -- pi with 9Bit fraction

  -- phases out of the cordic algorithm (still with wrapping)
  signal ph      : std_logic_vector(Nbit_ph_g-2 downto 0);
  signal pilot_i : std_logic_vector(Nbit_pilots_g-1 downto 0);
  signal pilot_q : std_logic_vector(Nbit_pilots_g-1 downto 0);

  signal step : integer range 15 downto 0;

  -- First symbol of the packet information
  signal not_first_symbol : std_logic;

begin

  --------------------------------------------
  -- CORDIC to compute angle
  --------------------------------------------
  cordic_vectoring_m21 : cordic_vectoring
    generic map (
      data_length_g   => Nbit_pilots_g,
      angle_length_g  => Nbit_ph_g-1,
      nbr_combstage_g => NBR_COMBSTAGE_CT,
      nbr_pipe_g      => NBR_PIPE_CT)
    port map (
      clk     => clk,
      reset_n => reset_n,
      x_i     => pilot_i,
      y_i     => pilot_q,
      z_o     => ph,
      mag_o   => open);


  --------------------------------------------
  -- Load the pilots in the CORDIC to compute their angles
  --------------------------------------------
  load_cordic_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      pilot_i     <= (others => '0');
      pilot_q     <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      case step is
        when 0 =>
          pilot_i <= pilot_m21_i_i;
          pilot_q <= pilot_m21_q_i;                                    
        when 1 =>
          pilot_i <= pilot_m7_i_i;
          pilot_q <= pilot_m7_q_i;
        when 2 =>
          pilot_i <= pilot_p7_i_i;
          pilot_q <= pilot_p7_q_i;
        when 3 =>
          pilot_i <= pilot_p21_i_i;
          pilot_q <= pilot_p21_q_i;        
        when others => null;
      end case;
      
    end if;
  end process load_cordic_p;


  --------------------------------------------
  -- Control signals generation
  --------------------------------------------
  gen_done_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      step           <= 15;
      data_valid_o   <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        step         <= 15;
        data_valid_o <= '0';
      else
        if step /= 15 then
          step  <= step +1;
        end if;

        if data_valid_i = '1' then
          step <= 0;
        end if;

        if step = 8 then
          data_valid_o <= '1';
        else
          data_valid_o <= '0';
        end if;

      end if;
    end if;
  end process gen_done_p;


  --------------------------------------------
  -- First symbol generation
  --------------------------------------------
  not_first_symbol_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      not_first_symbol <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        not_first_symbol <= '0';
      else
        if step = 14 and not_first_symbol = '0' then
          not_first_symbol <= '1';
        end if;
      end if;
    end if;
  end process not_first_symbol_p;


  --------------------------------------------
  -- Weighting
  --------------------------------------------
  weighting_p : process (clk, reset_n)

    variable ph_m21_est_v       : std_logic_vector(Nbit_ph_g+7 downto 0);
    variable ph_m7_est_v        : std_logic_vector(Nbit_ph_g+7 downto 0);
    variable ph_p7_est_v        : std_logic_vector(Nbit_ph_g+7 downto 0);
    variable ph_p21_est_v       : std_logic_vector(Nbit_ph_g+7 downto 0);

    variable ph_m21_short_est_v : std_logic_vector(Nbit_ph_g+3 downto 0);
    variable ph_m7_short_est_v  : std_logic_vector(Nbit_ph_g+3 downto 0);
    variable ph_p7_short_est_v  : std_logic_vector(Nbit_ph_g+3 downto 0);
    variable ph_p21_short_est_v : std_logic_vector(Nbit_ph_g+3 downto 0);

    variable ph_est_v           : std_logic_vector(Nbit_ph_g+3 downto 0);
    variable ph_v               : std_logic_vector(Nbit_ph_g-1 downto 0);
    variable abs_ph_v           : std_logic_vector(Nbit_ph_g-1 downto 0);
    
    variable phm21_v            : std_logic_vector(Nbit_ph_g-1 downto 0);
    variable phm7_v             : std_logic_vector(Nbit_ph_g-1 downto 0);
    variable php7_v             : std_logic_vector(Nbit_ph_g-1 downto 0);
    variable php21_v            : std_logic_vector(Nbit_ph_g-1 downto 0);
    -- ph_est_v - ph_v
    variable ph_est_m_ph_v      : std_logic_vector(Nbit_ph_g+3 downto 0);
    -- abs(ph_est_v - ph_v)
    variable abs_ph_est_m_ph_v  : std_logic_vector(Nbit_ph_g+3 downto 0);

  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      ph_m21_est_v       := (others => '0');
      ph_m7_est_v        := (others => '0');
      ph_p7_est_v        := (others => '0');
      ph_p21_est_v       := (others => '0');
      ph_m21_short_est_v := (others => '0');
      ph_m7_short_est_v  := (others => '0');
      ph_p7_short_est_v  := (others => '0');
      ph_p21_short_est_v := (others => '0');
      ph_est_v           := (others => '0');
      ph_m21_o           <= (others => '0');
      ph_m7_o            <= (others => '0');
      ph_p7_o            <= (others => '0');
      ph_p21_o           <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      
      -- Calculation must be done with all bits of cpe & sto predicted, else we
      -- lose too much precision with the truncature of 4 lsb
      ph_m21_est_v := SXT(cpe_pred_i, ph_m21_est_v'length) -          -- CPE
                      SXT(sto_pred_i & "0000", ph_m21_est_v'length) - -- -16*STO
                      SXT(sto_pred_i & "00", ph_m21_est_v'length) -   -- -4*STO
                      SXT(sto_pred_i, ph_m21_est_v'length);           -- -STO
                      
      ph_m7_est_v  := SXT(cpe_pred_i, ph_m7_est_v'length) -           -- CPE
                      SXT(sto_pred_i & "000", ph_m7_est_v'length) +   -- -8*STO
                      SXT(sto_pred_i, ph_m7_est_v'length);            -- +STO

      ph_p7_est_v  := SXT(cpe_pred_i, ph_p7_est_v'length) +           -- CPE
                      SXT(sto_pred_i & "000", ph_p7_est_v'length) -   -- +8*STO
                      SXT(sto_pred_i, ph_p7_est_v'length);            -- -STO
                      
      ph_p21_est_v := SXT(cpe_pred_i, ph_p21_est_v'length) +          -- CPE
                      SXT(sto_pred_i & "0000", ph_p21_est_v'length) + -- +16*STO
                      SXT(sto_pred_i & "00", ph_p21_est_v'length) +   -- +4*STO
                      SXT(sto_pred_i, ph_p21_est_v'length);           -- +STO

      -- Truncature -4 lsb
      ph_m21_short_est_v := ph_m21_est_v(ph_m21_est_v'high downto 4);
      ph_m7_short_est_v  := ph_m7_est_v(ph_m7_est_v'high downto 4);
      ph_p7_short_est_v  := ph_p7_est_v(ph_p7_est_v'high downto 4);
      ph_p21_short_est_v := ph_p21_est_v(ph_p21_est_v'high downto 4);

      -- unwrap phases
      -- NOTE : we remove the LSB of ph to have 8 bit after the coma,
      -- like in ph_est_v.
      
      -- compute the difference between the estimated pilots phases
      -- and the calculated ones.
      ph_est_m_ph_v := ph_est_v - SXT(ph, ph_est_m_ph_v'length);
      
      -- compute the absolute of this difference.
      if (ph_est_m_ph_v(ph_est_m_ph_v'high) = '1') then
        abs_ph_est_m_ph_v := not(ph_est_m_ph_v) + '1';
      else
        abs_ph_est_m_ph_v := ph_est_m_ph_v;
      end if;
      
      -- if the previously computed absolute difference is greater than PI,
      -- we add or substract PI. It is saturated to [-8;+8] in case of overflow.
      -- NOTE : we remove the LSB of PI_CT to have 8 bit after the coma.
      -- Must be done only after the first symbol, first symbol is not affected.
      if abs_ph_est_m_ph_v > SXT(PI_CT,abs_ph_est_m_ph_v'length) and
         not_first_symbol = '1' then
        
        -- look the sign of the difference for add or substract PI.
        if ph_est_m_ph_v(ph_est_m_ph_v'high) = '0' then
          ph_v := SXT(ph,ph_v'length) + PI2_CT;
          -- overflow
          if (ph_v(ph_v'high) = '1') then
            ph_v := "0111111111111";
          end if;
        else
          ph_v := SXT(ph,ph_v'length) - PI2_CT;
          -- overflow
          if (ph_v(ph_v'high) = '0') then
            ph_v := "1000000000000";
          end if;
        end if;
      else
        ph_v := SXT(ph,ph_v'length);
      end if;

      -- take back the computed angle
      case step is
        when 4 =>
          ph_est_v := ph_m21_short_est_v;
        when 5  =>
          ph_est_v := ph_m7_short_est_v;
          ph_m21_o <= ph_v;
          phm21_v := SXT(ph,phm21_v'length);
        when 6 =>
          ph_est_v := ph_p7_short_est_v;
          ph_m7_o <= ph_v;
          phm7_v := SXT(ph,phm7_v'length);
        when 7 =>
          ph_est_v := ph_p21_short_est_v;
          ph_p7_o <= ph_v;
          php7_v := SXT(ph,php7_v'length);
        when 8 =>
          ph_p21_o <= ph_v;
          php21_v := SXT(ph,php21_v'length);
        when others => 
          null;
      end case;
      -- saturate the estimated pilots phases between [-8;+8]
      ph_est_v := SXT(sat_signed_slv(ph_est_v, 4), ph_est_v'length);

    end if;
  end process weighting_p;

end rtl;
