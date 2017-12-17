
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: barker_cor.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Barker Correlator. Correlates the input data with a Barker
--               sequence to find DSSS synchronization. The output data is
--               sent to a peak detector.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/barker_cor/vhdl/rtl/barker_cor.vhd,v  
--  Log: barker_cor.vhd,v  
-- Revision 1.6  2003/09/18 08:35:35  Dr.A
-- Added registers for outputs.
--
-- Revision 1.5  2002/11/28 09:33:34  Dr.A
-- Added data saturation.
--
-- Revision 1.4  2002/11/19 12:48:26  Dr.A
-- Debugged accu reset.
--
-- Revision 1.3  2002/07/31 06:51:21  Dr.A
-- Added correclator reset.
--
-- Revision 1.2  2002/07/11 12:14:23  Dr.A
-- Cleaned code and changed adders size.
-- Removed packet_sync.
--
-- Revision 1.1  2002/03/05 14:47:44  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_signed.all; 
use ieee.std_logic_arith.all;

--library barker_cor_rtl;
library work;
--use barker_cor_rtl.barker_cor_pkg.all;
use work.barker_cor_pkg.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity barker_cor is
  generic (
    dsize_g : integer := 6
  );
  port (
    -- clock and reset.
    reset_n      : in  std_logic; -- Global reset.
    clk          : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).
    correl_rst_n : in  std_logic; -- Correlator reset.
    barker_sync  : in  std_logic; -- Correlator output synchronization.
    -- Input data.
    sampl_i      : in  std_logic_vector(dsize_g-1 downto 0); -- I sample input.
    sampl_q      : in  std_logic_vector(dsize_g-1 downto 0); -- Q sample input.
    -- Saturated correlated outputs.
    peak_data_i  : out std_logic_vector(7 downto 0);  
    peak_data_q  : out std_logic_vector(7 downto 0) 
  );

end barker_cor;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of barker_cor is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Constants for saturation of correlator outputs.
  constant MAX_PEAK_CT :  std_logic_vector(7 downto 0) := "01111111";
  constant MIN_PEAK_CT :  std_logic_vector(7 downto 0) := "10000000";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for I sample shift.
  signal sampl_i_ff1      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff2      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff3      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff4      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff5      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff6      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff7      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff8      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff9      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff10     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff11     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff12     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff13     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff14     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff15     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff16     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff17     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff18     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff19     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff20     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_i_ff21     : std_logic_vector(dsize_g-1 downto 0);

  -- Signals for Q sample shift.
  signal sampl_q_ff1      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff2      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff3      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff4      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff5      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff6      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff7      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff8      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff9      : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff10     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff11     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff12     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff13     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff14     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff15     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff16     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff17     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff18     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff19     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff20     : std_logic_vector(dsize_g-1 downto 0);
  signal sampl_q_ff21     : std_logic_vector(dsize_g-1 downto 0);
  -- Correlated data before saturation.
  signal corr_i           : std_logic_vector(dsize_g+3 downto 0);
  signal corr_q           : std_logic_vector(dsize_g+3 downto 0);
  -- Saturated correlated outputs (not registered).
  signal peak_data_i_nr   : std_logic_vector(7 downto 0);  
  signal peak_data_q_nr   : std_logic_vector(7 downto 0);
  -- This counter is used to obtain a 22 MHz sampling from the 44 MHz clock.
  signal count_22mhz      : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  


  -- Shift process for I registers, at 22 MHz.
  shift_i_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      sampl_i_ff1  <= (others => '0');
      sampl_i_ff2  <= (others => '0');
      sampl_i_ff3  <= (others => '0');
      sampl_i_ff4  <= (others => '0');
      sampl_i_ff5  <= (others => '0');
      sampl_i_ff6  <= (others => '0');
      sampl_i_ff7  <= (others => '0');
      sampl_i_ff8  <= (others => '0');
      sampl_i_ff9  <= (others => '0');
      sampl_i_ff10 <= (others => '0');
      sampl_i_ff11 <= (others => '0');
      sampl_i_ff12 <= (others => '0');
      sampl_i_ff13 <= (others => '0');
      sampl_i_ff14 <= (others => '0');
      sampl_i_ff15 <= (others => '0');
      sampl_i_ff16 <= (others => '0');
      sampl_i_ff17 <= (others => '0');
      sampl_i_ff18 <= (others => '0');
      sampl_i_ff19 <= (others => '0');
      sampl_i_ff20 <= (others => '0');
      sampl_i_ff21 <= (others => '0');
    elsif clk'event and clk = '1' then
      if correl_rst_n = '0' then
        sampl_i_ff1  <= (others => '0');
        sampl_i_ff2  <= (others => '0');
        sampl_i_ff3  <= (others => '0');
        sampl_i_ff4  <= (others => '0');
        sampl_i_ff5  <= (others => '0');
        sampl_i_ff6  <= (others => '0');
        sampl_i_ff7  <= (others => '0');
        sampl_i_ff8  <= (others => '0');
        sampl_i_ff9  <= (others => '0');
        sampl_i_ff10 <= (others => '0');
        sampl_i_ff11 <= (others => '0');
        sampl_i_ff12 <= (others => '0');
        sampl_i_ff13 <= (others => '0');
        sampl_i_ff14 <= (others => '0');
        sampl_i_ff15 <= (others => '0');
        sampl_i_ff16 <= (others => '0');
        sampl_i_ff17 <= (others => '0');
        sampl_i_ff18 <= (others => '0');
        sampl_i_ff19 <= (others => '0');
        sampl_i_ff20 <= (others => '0');
        sampl_i_ff21 <= (others => '0');
      elsif count_22mhz = '1' then
        sampl_i_ff1  <= sampl_i;         -- Store new value.
        sampl_i_ff2  <= sampl_i_ff1;     -- Shift all others registers.
        sampl_i_ff3  <= sampl_i_ff2 ;
        sampl_i_ff4  <= sampl_i_ff3 ;
        sampl_i_ff5  <= sampl_i_ff4 ;
        sampl_i_ff6  <= sampl_i_ff5 ;
        sampl_i_ff7  <= sampl_i_ff6 ;
        sampl_i_ff8  <= sampl_i_ff7 ;
        sampl_i_ff9  <= sampl_i_ff8 ;
        sampl_i_ff10 <= sampl_i_ff9 ;
        sampl_i_ff11 <= sampl_i_ff10;
        sampl_i_ff12 <= sampl_i_ff11;
        sampl_i_ff13 <= sampl_i_ff12;
        sampl_i_ff14 <= sampl_i_ff13;
        sampl_i_ff15 <= sampl_i_ff14;
        sampl_i_ff16 <= sampl_i_ff15;
        sampl_i_ff17 <= sampl_i_ff16;
        sampl_i_ff18 <= sampl_i_ff17;
        sampl_i_ff19 <= sampl_i_ff18;
        sampl_i_ff20 <= sampl_i_ff19;
        sampl_i_ff21 <= sampl_i_ff20;
      end if;
    end if;
  end process shift_i_pr;

  -- Adder for Q values, correlated with the Barker Sequence.
  -- corr_i <= - sampl_i_ff1  
  --         - sampl_i_ff3  
  --         - sampl_i_ff5  
  --         + sampl_i_ff7    
  --         + sampl_i_ff9    
  --         + sampl_i_ff11   
  --         - sampl_i_ff13
  --         + sampl_i_ff15  
  --         + sampl_i_ff17  
  --         - sampl_i_ff19
  --         + sampl_i_ff21; 
  
  corr_i_add_pr: process(sampl_i_ff1, sampl_i_ff3, sampl_i_ff5, sampl_i_ff7,
                         sampl_i_ff9, sampl_i_ff11, sampl_i_ff13, sampl_i_ff15,
                         sampl_i_ff17, sampl_i_ff19, sampl_i_ff21)
    -- First stage of adders is dsize_g+1 bits.
    variable add1_i1 : std_logic_vector(dsize_g downto 0);
    variable add2_i1 : std_logic_vector(dsize_g downto 0);
    variable add3_i1 : std_logic_vector(dsize_g downto 0);
    variable add4_i1 : std_logic_vector(dsize_g downto 0);
    variable add5_i1 : std_logic_vector(dsize_g downto 0);

    -- Second stage of adders is dsize_g+2 bits.
    variable add1_i2 : std_logic_vector(dsize_g+1 downto 0);
    variable sub2_i2 : std_logic_vector(dsize_g+1 downto 0);
    variable add3_i2 : std_logic_vector(dsize_g+1 downto 0);

    -- Third stage of adders is dsize_g+2 bits.
    variable add1_i3 : std_logic_vector(dsize_g+2 downto 0);

  begin

    -- These values will be added.
    add1_i1 := sxt(sampl_i_ff7, dsize_g+1)  + sxt(sampl_i_ff9, dsize_g+1);
    add2_i1 := sxt(sampl_i_ff11, dsize_g+1) + sxt(sampl_i_ff15, dsize_g+1);
    add3_i1 := sxt(sampl_i_ff17, dsize_g+1) + sxt(sampl_i_ff21, dsize_g+1);
    -- These values (and sampl_i_ff19) will be substracted.
    add4_i1 := sxt(sampl_i_ff1, dsize_g+1)  + sxt(sampl_i_ff3, dsize_g+1);
    add5_i1 := sxt(sampl_i_ff5, dsize_g+1)  + sxt(sampl_i_ff13, dsize_g+1);

    -- These values will be added.
    add1_i2 := sxt(add1_i1, dsize_g+2) + sxt(add2_i1, dsize_g+2);
    sub2_i2 := sxt(add3_i1, dsize_g+2) - sxt(sampl_i_ff19, dsize_g+2);
    --  This value will be substracted.
    add3_i2 := sxt(add4_i1, dsize_g+2) + sxt(add5_i1, dsize_g+2);

    -- This value will be added.
    add1_i3 := sxt(add1_i2, dsize_g+3) + sxt(sub2_i2, dsize_g+3);

    corr_i  <= sxt(add1_i3, dsize_g+4) - sxt(add3_i2, dsize_g+4);

  end process corr_i_add_pr;


  -- Shift process for Q registers, at 22 MHz.
  shift_q_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      sampl_q_ff1  <= (others => '0'); -- Reset all registers.
      sampl_q_ff2  <= (others => '0');
      sampl_q_ff3  <= (others => '0');
      sampl_q_ff4  <= (others => '0');
      sampl_q_ff5  <= (others => '0');
      sampl_q_ff6  <= (others => '0');
      sampl_q_ff7  <= (others => '0');
      sampl_q_ff8  <= (others => '0');
      sampl_q_ff9  <= (others => '0');
      sampl_q_ff10 <= (others => '0');
      sampl_q_ff11 <= (others => '0');
      sampl_q_ff12 <= (others => '0');
      sampl_q_ff13 <= (others => '0');
      sampl_q_ff14 <= (others => '0');
      sampl_q_ff15 <= (others => '0');
      sampl_q_ff16 <= (others => '0');
      sampl_q_ff17 <= (others => '0');
      sampl_q_ff18 <= (others => '0');
      sampl_q_ff19 <= (others => '0');
      sampl_q_ff20 <= (others => '0');
      sampl_q_ff21 <= (others => '0');
    elsif clk'event and clk = '1' then
      if correl_rst_n = '0' then
        sampl_q_ff1  <= (others => '0'); -- Reset all registers.
        sampl_q_ff2  <= (others => '0');
        sampl_q_ff3  <= (others => '0');
        sampl_q_ff4  <= (others => '0');
        sampl_q_ff5  <= (others => '0');
        sampl_q_ff6  <= (others => '0');
        sampl_q_ff7  <= (others => '0');
        sampl_q_ff8  <= (others => '0');
        sampl_q_ff9  <= (others => '0');
        sampl_q_ff10 <= (others => '0');
        sampl_q_ff11 <= (others => '0');
        sampl_q_ff12 <= (others => '0');
        sampl_q_ff13 <= (others => '0');
        sampl_q_ff14 <= (others => '0');
        sampl_q_ff15 <= (others => '0');
        sampl_q_ff16 <= (others => '0');
        sampl_q_ff17 <= (others => '0');
        sampl_q_ff18 <= (others => '0');
        sampl_q_ff19 <= (others => '0');
        sampl_q_ff20 <= (others => '0');
        sampl_q_ff21 <= (others => '0');
      elsif count_22mhz = '1' then
        sampl_q_ff1  <= sampl_q;
        sampl_q_ff2  <= sampl_q_ff1 ;    -- Store new value.
        sampl_q_ff3  <= sampl_q_ff2 ;    -- Shift all others registers.
        sampl_q_ff4  <= sampl_q_ff3 ;
        sampl_q_ff5  <= sampl_q_ff4 ;
        sampl_q_ff6  <= sampl_q_ff5 ;
        sampl_q_ff7  <= sampl_q_ff6 ;
        sampl_q_ff8  <= sampl_q_ff7 ;
        sampl_q_ff9  <= sampl_q_ff8 ;
        sampl_q_ff10 <= sampl_q_ff9 ;
        sampl_q_ff11 <= sampl_q_ff10;
        sampl_q_ff12 <= sampl_q_ff11;
        sampl_q_ff13 <= sampl_q_ff12;
        sampl_q_ff14 <= sampl_q_ff13;
        sampl_q_ff15 <= sampl_q_ff14;
        sampl_q_ff16 <= sampl_q_ff15;
        sampl_q_ff17 <= sampl_q_ff16;
        sampl_q_ff18 <= sampl_q_ff17;
        sampl_q_ff19 <= sampl_q_ff18;
        sampl_q_ff20 <= sampl_q_ff19;
        sampl_q_ff21 <= sampl_q_ff20;
      end if;
    end if;
  end process shift_q_pr;

  -- Adder for Q values, correlated with the Barker Sequence.
  -- corr_q <= - sampl_q_ff1  
  --         - sampl_q_ff3  
  --         - sampl_q_ff5  
  --         + sampl_q_ff7    
  --         + sampl_q_ff9    
  --         + sampl_q_ff11   
  --         - sampl_q_ff13
  --         + sampl_q_ff15  
  --         + sampl_q_ff17  
  --         - sampl_q_ff19
  --         + sampl_q_ff21; 
  corr_q_add_pr: process(sampl_q_ff1, sampl_q_ff3, sampl_q_ff5, sampl_q_ff7,
                         sampl_q_ff9, sampl_q_ff11, sampl_q_ff13, sampl_q_ff15,
                         sampl_q_ff17, sampl_q_ff19, sampl_q_ff21)
    -- First stage of adders is dsize_g+1 bits.
    variable add1_q1 : std_logic_vector(dsize_g downto 0);
    variable add2_q1 : std_logic_vector(dsize_g downto 0);
    variable add3_q1 : std_logic_vector(dsize_g downto 0);
    variable add4_q1 : std_logic_vector(dsize_g downto 0);
    variable add5_q1 : std_logic_vector(dsize_g downto 0);

    -- Second stage of adders is dsize_g+2 bits.
    variable add1_q2 : std_logic_vector(dsize_g+1 downto 0);
    variable sub2_q2 : std_logic_vector(dsize_g+1 downto 0);
    variable add3_q2 : std_logic_vector(dsize_g+1 downto 0);

    -- Third stage of adders is dsize_g+2 bits.
    variable add1_q3 : std_logic_vector(dsize_g+2 downto 0);

  begin

    -- These values will be added.
    add1_q1 := sxt(sampl_q_ff7, dsize_g+1)  + sxt(sampl_q_ff9, dsize_g+1);
    add2_q1 := sxt(sampl_q_ff11, dsize_g+1) + sxt(sampl_q_ff15, dsize_g+1);
    add3_q1 := sxt(sampl_q_ff17, dsize_g+1) + sxt(sampl_q_ff21, dsize_g+1);
    -- These values (and sampl_q_ff19) will be substracted.
    add4_q1 := sxt(sampl_q_ff1, dsize_g+1)  + sxt(sampl_q_ff3, dsize_g+1);
    add5_q1 := sxt(sampl_q_ff5, dsize_g+1)  + sxt(sampl_q_ff13, dsize_g+1);

    -- These values will be added.
    add1_q2 := sxt(add1_q1, dsize_g+2) + sxt(add2_q1, dsize_g+2);
    sub2_q2 := sxt(add3_q1, dsize_g+2) - sxt(sampl_q_ff19, dsize_g+2);
    --  This value will be substracted.
    add3_q2 := sxt(add4_q1, dsize_g+2) + sxt(add5_q1, dsize_g+2);

    -- This value will be added.
    add1_q3 := sxt(add1_q2, dsize_g+3) + sxt(sub2_q2, dsize_g+3);

    corr_q  <= sxt(add1_q3, dsize_g+4) - sxt(add3_q2, dsize_g+4);

  end process corr_q_add_pr;


  ------------------------------------------------------------------------------
  -- Saturate Correlator output to equalizer multiplier.
  ------------------------------------------------------------------------------
  sat_i_pr: process (corr_i)
  begin
    -- Check for overflow
    if (corr_i(11 downto 9) = "000") or (corr_i(11 downto 9) = "111") then
      peak_data_i_nr <= corr_i(9 downto 2);
    else -- Overflow detected, saturate peak_data_i.
      case corr_i(11) is
        when '1' =>
          peak_data_i_nr <= MIN_PEAK_CT;
        when others =>
          peak_data_i_nr <= MAX_PEAK_CT;
      end case;
    end if;
  end process sat_i_pr;
  
  sat_q_pr: process (corr_q)
  begin
    -- Check for overflow
    if corr_q(11 downto 9) = "000" or corr_q(11 downto 9) = "111" then
      peak_data_q_nr <= corr_q(9 downto 2);
    else -- Overflow detected, saturate peak_data_q.
      case corr_q(11) is
        when '1' =>
          peak_data_q_nr <= MIN_PEAK_CT;
        when others =>
          peak_data_q_nr <= MAX_PEAK_CT;
      end case;
    end if;
  end process sat_q_pr;

  --------------------------------------------
  -- Register outputs.
  --------------------------------------------  
  output_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      peak_data_i <= (others => '0');
      peak_data_q <= (others => '0');
    elsif clk'event and clk = '1' then
      if barker_sync = '1' then
        peak_data_i <= peak_data_i_nr;
        peak_data_q <= peak_data_q_nr;
      end if;
    end if;
  end process output_pr;
  
  
  --------------------------------------------
  -- Counter process.
  --------------------------------------------
  -- This counter is used to obtain a 22 MHz sampling from the 44 MHz clock.
  count_22mhz_pr: process (clk, reset_n)                              
  begin                                                              
    if reset_n = '0' then
      count_22mhz <= '0';
    elsif clk'event and clk = '1' then
      if correl_rst_n = '0' then
        count_22mhz <= '0';
      else
        count_22mhz <= not count_22mhz;
      end if;
    end if;                                                          
  end process count_22mhz_pr; 

end RTL;
