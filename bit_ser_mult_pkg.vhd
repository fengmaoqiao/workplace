--------------------------------------------------------------------------------
--       ------------      Project : bit_ser_mult
--    ,' GoodLuck ,'      RCSfile: bit_ser_mult_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for bit_ser_mult.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/bit_ser_mult/vhdl/rtl/bit_ser_mult_pkg.vhd,v  
--  Log: bit_ser_mult_pkg.vhd,v  
-- Revision 1.2  2003/05/13 07:37:57  rrich
-- Added synchronous reset
--
-- Revision 1.1  2003/04/22 08:58:56  rrich
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package bit_ser_mult_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: bit_ser_mult.vhd
----------------------
  component bit_ser_mult
  
  generic (
    data_size_g : integer := 8);  -- bits in multiplicand and multiplier

  port (
    clk        : in  std_logic;
    reset_n    : in  std_logic;
    sync_reset : in  std_logic;
    x_par_in   : in  std_logic_vector(data_size_g-1 downto 0);
    y_ser_in   : in  std_logic;
    p_ser_out  : out std_logic);

  end component;



 
end bit_ser_mult_pkg;
