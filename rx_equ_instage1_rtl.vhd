
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_equ_instage1.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.4  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Equalizer input stage 1.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_equ/vhdl/rtl/rx_equ_instage1.vhd,v  
--  Log: rx_equ_instage1.vhd,v  
-- Revision 1.4  2003/05/19 07:16:08  Dr.F
-- removed start_of_symbol and start_of_burst.
--
-- Revision 1.3  2003/03/28 15:53:29  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.2  2003/03/17 17:06:49  Dr.F
-- removed debug signals.
--
-- Revision 1.1  2003/03/17 10:01:30  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--library rx_equ_rtl;
library work;
--use rx_equ_rtl.rx_equ_pkg.all;
use work.rx_equ_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity rx_equ_instage1 is
  port (
    clk                 : in  std_logic; -- Clock input
    reset_n             : in  std_logic; -- Asynchronous negative reset
    module_enable_i     : in  std_logic; -- '1': Internal enable for clock gating
    sync_reset_n        : in  std_logic; -- synchronous negative reset

    current_symb_i      : in  std_logic_vector(1 downto 0);
    data_valid_i        : in  std_logic;
    cumhist_valid_i     : in  std_logic;
    clean_hist_i        : in  std_logic;

    hpowman_i           : in  std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0);
    cormanr_i           : in  std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    cormani_i           : in  std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);

    satmaxncarr_54_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_48_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_36_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_24_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_18_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_12_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_09_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
    satmaxncarr_06_i    : in  std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); 
   
    burst_rate_i        : in  std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);
    burst_rate_4_hist_i : in  std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);

    hpowman_o           : out std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0);
    cormanr_o           : out std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    cormani_o           : out std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    
    hpowexp_o           : out std_logic_vector(HPOWEXP_WIDTH_CT-1 downto 0);
    histexpz_signal_o   : out std_logic_vector(HISTEXPZ_WIDTH_CT-1 downto 0);
    histexpz_data_o     : out std_logic_vector(HISTEXPZ_WIDTH_CT-1 downto 0);


    burst_rate_o        : out std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);
    current_symb_o      : out std_logic_vector(1 downto 0);
    data_valid_o        : out std_logic
  );

end rx_equ_instage1;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_equ_instage1 is

  signal histexpz_data_d     : std_logic_vector(HISTEXPZ_WIDTH_CT -1 downto 0);
  signal histexpz_data_tmp   : std_logic_vector(HISTEXPZ_WIDTH_CT -1 downto 0);
  signal histexpz_signal_d   : std_logic_vector(HISTEXPZ_WIDTH_CT -1 downto 0);
  signal histexpz_signal_tmp : std_logic_vector(HISTEXPZ_WIDTH_CT -1 downto 0);
  signal sum1_d              : SUM_T;
  signal sum1                : SUM_T;
  signal hpowexp_d           : std_logic_vector(HPOWEXP_WIDTH_CT -1   downto 0);
  signal hpowman_d           : std_logic_vector(MANTLEN_CT-1 downto 0);
  signal hpowman_ceil        : std_logic_vector(hpowman_i'range);

begin

  -- ceiling hpowman_i
  ceiling_p : process (hpowman_i)
    variable a1_v : std_logic_vector(hpowman_i'range);
    variable i    : integer;
  begin
    -- ceiling hpowman_i
    a1_v(hpowman_i'high) :=  hpowman_i(hpowman_i'high);
    for i in hpowman_i'high - 1 downto 0 loop
      a1_v(i) := hpowman_i(i) or a1_v (i+1);
    end loop;
    hpowman_ceil <= a1_v;
  end process ceiling_p;
  
  -------------------------------------------------------------------
  ---                    Input stage 1 (reduce arguments)
  -------------------------------------------------------------------

  ----------------------
  -- hpowexp calculation      
  ----------------------
  hpowexp_p : process (hpowman_ceil)
    variable hpowexp_v : std_logic_vector(HPOWEXP_WIDTH_CT downto 0); -- 0 to 19
    variable i         : integer;
  begin

    hpowexp_v := (others => '0'); 
    
    -- hpowexp calculation loop
    for i in 0 to hpowman_i'high loop 
      if hpowman_ceil(i) ='1' then
        hpowexp_v :=  hpowexp_v + '1';  
      end if;
    end loop;

    -- hpowexp compared with LENGTH_MANTISSE_CT
    if hpowexp_v > conv_std_logic_vector(LENGTH_MANTISSE_CT,hpowexp_v'length) then
      hpowexp_v := hpowexp_v - 
                   conv_std_logic_vector(LENGTH_MANTISSE_CT,hpowexp_v'length);
    else
      hpowexp_v := (others => '0'); 
    end if;
  
    hpowexp_d <= hpowexp_v(HPOWEXP_WIDTH_CT-1 downto 0);

  end process hpowexp_p;
     

  ------------------------------------------
  -- Sequential part stage reduction
  ------------------------------------------
  seq_p: process( reset_n, clk )
  begin
    if reset_n='0' then
      cormanr_o          <= (others =>'0');
      cormani_o          <= (others =>'0');
      hpowman_o          <= (others =>'0');
      hpowexp_o          <= (others =>'0');
      data_valid_o       <= '0';
      current_symb_o     <= PREAMBLE_CT;
      burst_rate_o       <= RATE_6_CT;

    elsif clk'event and clk='1' then
      if sync_reset_n = '0' then 
        data_valid_o       <= '0';
        current_symb_o     <= PREAMBLE_CT;
        hpowexp_o          <= (others =>'0');
        burst_rate_o       <= RATE_6_CT;
      elsif module_enable_i = '1' then 
        if data_valid_i = '1' then

          -- propagate corman and hpowman
          cormanr_o    <= cormanr_i;
          cormani_o    <= cormani_i;
          hpowman_o    <= hpowman_i;

          data_valid_o  <= '1';
          current_symb_o<= current_symb_i;
          hpowexp_o     <= hpowexp_d;
          burst_rate_o  <= burst_rate_i;
        else
          data_valid_o  <= '0';
        end if;

      end if;

    end if;
  end process seq_p;


  -------------------------------------------------------------------
  -- CUMULATIVE HISTOGRAM : calculated only on preamble
  -------------------------------------------------------------------

  cumulative_hist_p : process (sum1, histexpz_signal_tmp, 
                               histexpz_data_tmp, hpowman_ceil,
                               current_symb_i,burst_rate_4_hist_i,
                               satmaxncarr_06_i, satmaxncarr_09_i,
                               satmaxncarr_12_i, satmaxncarr_18_i,
                               satmaxncarr_24_i, satmaxncarr_36_i,
                               satmaxncarr_48_i, satmaxncarr_54_i)

    variable sum_v         : SUM_T;
    variable satmaxncarr_v : std_logic_vector (SATMAXNCARR_WIDTH_CT -1 downto 0);
    variable histexpz_v    : std_logic_vector (HISTEXPZ_WIDTH_CT -1 downto 0);
  begin

    -- default
    sum_v      := sum1;
    sum1_d     <= sum1;

    if current_symb_i = PREAMBLE_CT then   --accumulate histogram   
      -- sum1 (i) is the number of carriers with power greater or equal to 2**i 
      -- If a1_i (i) = '1' , then the current carrier has a power >= 2**i
      -- For any "i", let's increment ,if it is the case, the value of sum1 (i)
      for i in 1 to  hpowman_i'high loop  -- sum(i), with i=0 is useless
        if (hpowman_ceil(i) = '1') and (sum1(i) < EQU_SYMB_LENGTH_CT) then
          sum_v(i) := sum1(i) + 1;  
        end if;
      end loop;
      sum1_d      <= sum_v;
    end if;                       -- end accumulate histogram

    -- select satmaxncarr
    -- default, histexpz_sig is calculated during the preamble
    satmaxncarr_v  := satmaxncarr_06_i;        
    -- histexpz_sig is calculated during the signal field
    if (current_symb_i = SIGNAL_FIELD_CT)  then 
      case burst_rate_4_hist_i is
        when RATE_6_CT  => 
          satmaxncarr_v := satmaxncarr_06_i;
        when RATE_9_CT  => 
          satmaxncarr_v := satmaxncarr_09_i;
        when RATE_12_CT => 
          satmaxncarr_v := satmaxncarr_12_i;
        when RATE_18_CT => 
          satmaxncarr_v := satmaxncarr_18_i;
        when RATE_24_CT => 
          satmaxncarr_v := satmaxncarr_24_i;
        when RATE_36_CT => 
          satmaxncarr_v := satmaxncarr_36_i;
        when RATE_48_CT => 
          satmaxncarr_v := satmaxncarr_48_i;
        when RATE_54_CT => 
          satmaxncarr_v := satmaxncarr_54_i;
        when others    => null;
      end case;
    end if;

    -- the following comments has to be checked
    -- if sum1 (i) > SatMaxNCar then there is a number sum(i) > SatMaxNCar of 
    -- carriers  that have a power > 2**i . These carriers would saturate the
    -- mantissa if we choose an exp = i - mantlen_c + 1.
    -- Then, if we don't want to saturate these carriers, let's try with i+1.
    -- Note : SatMaxNcar = 48 means that we don't want to saturate any carrier
    -- for i in 0 to  hpowman_i'high-1 loop  
    -- sum(i), with i > (hpowman_i'high-1) is useless
    histexpz_v := (others => '0'); 
    for i in 1 to  hpowman_i'high loop  -- sum(i), with i=0 is useless
      if (sum_v (i) > conv_integer(satmaxncarr_v)) then
        histexpz_v := histexpz_v + '1';
      end if;
    end loop;

    
    -- save histexpz_data_tmp and histexp_signal for the next carrier evaluation
    histexpz_signal_d <= histexpz_signal_tmp;
    histexpz_data_d   <= histexpz_data_tmp;
    if current_symb_i = PREAMBLE_CT then -- preamble
      histexpz_signal_d <= histexpz_v;
    elsif current_symb_i = SIGNAL_FIELD_CT then
      histexpz_data_d   <= histexpz_v;
    end if;

  end process cumulative_hist_p;

  ------------------------------------------
  -- Sequential part stage 2
  ------------------------------------------
  cumhist_seq_p: process(reset_n, clk)
  begin
    if reset_n = '0' then
      sum1                  <= (others => 0);
      histexpz_signal_tmp   <= (others => '0');
      histexpz_data_tmp     <= (others => '0');
    elsif clk'event and clk='1' then
      if (sync_reset_n ='0') or (clean_hist_i = '1') then
        sum1                 <= (others => 0);
        histexpz_signal_tmp  <= (others => '0');
        histexpz_data_tmp    <= (others => '0');
      elsif (module_enable_i = '1') then
        if cumhist_valid_i = '1' then
          sum1                <= sum1_d;
          histexpz_signal_tmp <= histexpz_signal_d;
        else
          histexpz_data_tmp   <= histexpz_data_d;
        end if;
      end if;
    end if;
  end process cumhist_seq_p;


  -- dummy assignment
  histexpz_signal_o <= histexpz_signal_tmp;
  histexpz_data_o   <= histexpz_data_tmp;

end rtl;
