
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: wiener_multadd2.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Multiplier and adder.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/wiener_filter/vhdl/rtl/wiener_multadd2.vhd,v  
--  Log: wiener_multadd2.vhd,v  
-- Revision 1.2  2003/03/28 15:48:46  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.1  2003/03/14 07:42:53  Dr.F
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

--library wiener_filter_rtl;
library work;
--use wiener_filter_rtl.wiener_filter_pkg.all;
use work.wiener_filter_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity wiener_multadd2 is
  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    module_enable_i   : in  std_logic;
    data1_i           : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data2_i           : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    chanwien_c0_i     : in  std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    chanwien_c1_i     : in  std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    en_add_reg_i      : in  std_logic;
    add_o             : out std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0)  
  );

end wiener_multadd2;


--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of wiener_multadd2 is


  -- data output from multipliers, divided by 64
  signal mult1_scaled : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-2 downto 0);
  signal mult2_scaled : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-2 downto 0);

begin

  --------------------------------------------
  -- Combinational computation
  --------------------------------------------
  data_comb : process (data1_i, data2_i, chanwien_c0_i, chanwien_c1_i)
    variable mult1_v      : std_logic_vector(FFT_WIDTH_CT+WIENER_COEFF_WIDTH_CT-1 downto 0);
    variable mult2_v      : std_logic_vector(FFT_WIDTH_CT+WIENER_COEFF_WIDTH_CT-1 downto 0);
    variable mult1_shr_v  : std_logic_vector(FFT_WIDTH_CT+WIENER_COEFF_WIDTH_CT-1 downto 0);
    variable mult2_shr_v  : std_logic_vector(FFT_WIDTH_CT+WIENER_COEFF_WIDTH_CT-1 downto 0);
  begin

    mult1_v      := signed(data1_i) * signed(chanwien_c0_i);
    mult2_v      := signed(data2_i) * signed(chanwien_c1_i);
    
    mult1_shr_v  := std_logic_vector(SHR(signed(mult1_v),conv_unsigned(WIENER_FIRSTROUND_WIDTH_CT+1,mult1_v'length)));
    mult2_shr_v  := std_logic_vector(SHR(signed(mult2_v),conv_unsigned(WIENER_FIRSTROUND_WIDTH_CT+1,mult2_v'length)));

    mult1_scaled <= mult1_shr_v(WIENER_FIRSTADD_WIDTH_CT-2 downto 0);
    mult2_scaled <= mult2_shr_v(WIENER_FIRSTADD_WIDTH_CT-2 downto 0);
  end process data_comb;

  --------------------------------------------
  -- Registered output
  --------------------------------------------
  data_reg : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      add_o <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if module_enable_i = '1' then
        if en_add_reg_i = '1' then
          add_o <= SXT(mult1_scaled, WIENER_FIRSTADD_WIDTH_CT) + 
                   SXT(mult2_scaled, WIENER_FIRSTADD_WIDTH_CT);
        end if;
      end if;
    end if;
  end process data_reg;

end rtl;
