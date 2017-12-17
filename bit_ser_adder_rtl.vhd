

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : bit_ser_adder
--    ,' GoodLuck ,'      RCSfile: bit_ser_adder.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Configurable bit-serial adder
--
--               - Inputs x and y must be supplied one bit at time
--                 LSB first.
--               - The output sum appears one bit at a time and should be
--                 shifted into an appropriately sized register.
--               - The addition of two k-bit numbers can be completed in k clk
--                 cycles.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/bit_ser_adder/vhdl/rtl/bit_ser_adder.vhd,v  
--  Log: bit_ser_adder.vhd,v  
-- Revision 1.1  2003/04/18 07:07:50  rrich
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

--library bit_ser_adder_rtl;
library work;
--use bit_ser_adder_rtl.bit_ser_adder_pkg.all;
use work.bit_ser_adder_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity bit_ser_adder is
  
  port (
    clk        : in  std_logic;
    reset_n    : in  std_logic;
    sync_reset : in  std_logic;
    x_in       : in  std_logic;
    y_in       : in  std_logic;
    sum_out    : out std_logic);

end bit_ser_adder;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------


architecture rtl of bit_ser_adder is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal c_in_reg : std_logic;
  signal c_out    : std_logic;
  
begin  -- rtl

  fa_0 : fa
    port map (
      x     => x_in,
      y     => y_in,
      c_in  => c_in_reg,
      s     => sum_out,
      c_out => c_out);
  
  carry_reg: process (clk, reset_n)
  begin  -- process carry_reg
    if reset_n = '0' then               -- asynchronous reset (active low)
      c_in_reg <= '0';  
    elsif clk'event and clk = '1' then  -- rising clock edge

      if sync_reset = '1' then
        c_in_reg <= '0';
      else
        c_in_reg <= c_out;    
      end if;

    end if;
  end process carry_reg;

end rtl;
