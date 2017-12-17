
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : bit_ser_adder
--    ,' GoodLuck ,'      RCSfile: bit_ser_adder_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for bit_ser_adder.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/bit_ser_adder/vhdl/rtl/bit_ser_adder_pkg.vhd,v  
--  Log: bit_ser_adder_pkg.vhd,v  
-- Revision 1.1  2003/04/18 07:07:52  rrich
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
package bit_ser_adder_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ha.vhd
----------------------
  component ha
  
  port (
    x : in  std_logic;
    y : in  std_logic;
    c : out std_logic;
    s : out std_logic);
    
  end component;


----------------------
-- File: fa.vhd
----------------------
  component fa
  
  port (
    x     : in  std_logic;
    y     : in  std_logic;
    c_in  : in  std_logic;
    s     : out std_logic;
    c_out : out std_logic);

  end component;


----------------------
-- File: bit_ser_adder.vhd
----------------------
  component bit_ser_adder
  
  port (
    clk        : in  std_logic;
    reset_n    : in  std_logic;
    sync_reset : in  std_logic;
    x_in       : in  std_logic;
    y_in       : in  std_logic;
    sum_out    : out std_logic);

  end component;



 
end bit_ser_adder_pkg;
