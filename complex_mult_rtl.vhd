--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: complex_mult.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Complex multiplier.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/complex_mult.vhd,v  
--  Log: complex_mult.vhd,v  
-- Revision 1.2  2003/06/25 16:11:13  Dr.F
-- code cleaning.
--
-- Revision 1.1  2003/03/27 07:48:42  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


--------------------------------------------
-- Entity
--------------------------------------------
entity complex_mult is

  generic (NBit_input1_g : integer := 10;
           NBit_input2_g : integer := 10);

  port (clk      : in  std_logic;
        reset_n  : in  std_logic;
        real_1_i : in  std_logic_vector(NBit_input1_g-1 downto 0);
        imag_1_i : in  std_logic_vector(NBit_input1_g-1 downto 0);
        real_2_i : in  std_logic_vector(NBit_input2_g-1 downto 0);
        imag_2_i : in  std_logic_vector(NBit_input2_g-1 downto 0);
        real_o   : out std_logic_vector(NBit_input1_g+NBit_input2_g downto 0);
        imag_o   : out std_logic_vector(NBit_input1_g+NBit_input2_g downto 0)
        );


end complex_mult;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of complex_mult is


begin

complexmult_p: process (clk, reset_n)
  variable rr_v : std_logic_vector(NBit_input1_g+NBit_input2_g-1 downto 0);
  variable ii_v : std_logic_vector(NBit_input1_g+NBit_input2_g-1 downto 0);
  variable ri_v : std_logic_vector(NBit_input1_g+NBit_input2_g-1 downto 0);
  variable ir_v : std_logic_vector(NBit_input1_g+NBit_input2_g-1 downto 0);

begin
  if reset_n = '0' then                 -- asynchronous reset (active low)
    real_o <= (others => '0');
    imag_o <= (others => '0');
    rr_v   := (others => '0');
    ii_v   := (others => '0');
    ri_v   := (others => '0');
    ir_v   := (others => '0');
  elsif clk'event and clk = '1' then    -- rising clock edge
    rr_v := signed(real_1_i)*signed(real_2_i);
    ii_v := signed(imag_1_i)*signed(imag_2_i);
    ri_v := signed(real_1_i)*signed(imag_2_i);
    ir_v := signed(imag_1_i)*signed(real_2_i);
    real_o <= SXT(rr_v,real_o'length) - SXT(ii_v,real_o'length);
    imag_o <= SXT(ri_v,imag_o'length) + SXT(ir_v,imag_o'length);
   
  end if;
end process complexmult_p;



end rtl;
