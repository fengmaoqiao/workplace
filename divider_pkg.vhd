
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Divider
--    ,' GoodLuck ,'      RCSfile: divider_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for divider.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/divider/vhdl/rtl/divider_pkg.vhd,v  
--  Log: divider_pkg.vhd,v  
-- Revision 1.2  2003/06/10 13:56:14  Dr.F
-- comments added.
--
-- Revision 1.1  2003/03/27 07:38:09  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package divider_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: srt_div.vhd
----------------------
  component srt_div

  generic (nbit_input_g    : integer := 10;
           nbit_quotient_g : integer := 10);

  port(clk         : in  std_logic;
       reset_n     : in  std_logic;
       start       : in  std_logic;  -- start division on pulse
       dividend    : in  std_logic_vector(nbit_input_g-1 downto 0);
       divisor     : in  std_logic_vector(nbit_input_g-1 downto 0);
       quotient    : out std_logic_vector(nbit_quotient_g-1 downto 0);
       value_ready : out std_logic); -- quotient is available on pulse

  end component;


----------------------
-- File: divider.vhd
----------------------
  component divider

  generic (nbit_input_g       : integer := 25;
           nbit_quotient_g    : integer := 12;
           nintbit_quotient_g : integer := 1);

  port(clk         : in  std_logic;
       reset_n     : in  std_logic;
       start       : in  std_logic;  -- start division on pulse
       dividend    : in  std_logic_vector(nbit_input_g-1 downto 0);
       divisor     : in  std_logic_vector(nbit_input_g-1 downto 0);
       quotient    : out std_logic_vector(nbit_quotient_g-1 downto 0);
       value_ready : out std_logic); -- quotient is available on pulse




  end component;



 
end divider_pkg;
