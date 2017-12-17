

--------------------------------------------------------------------------------
--       ------------      Project : GoodLuck Package
--    ,' GoodLuck ,'      RCSfile: cnt_max_min_e.vhd,v  
--   '-----------'     Only for Study  
--
--  Revision: 1.7  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Counter with min and max count, enable and final count interrupt.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/packages/commonlib/vhdl/rtl/cnt_max_min_e.vhd,v  
--  Log: cnt_max_min_e.vhd,v  
-- Revision 1.7  2001/12/06 09:18:31  Dr.J
-- Added description and project name
--
-- Revision 1.6  2001/02/13 09:49:14  omilou
-- counter reset to 0
--
-- Revision 1.5  2001/02/13 09:38:21  omilou
-- corrected sensitivity list
--
-- Revision 1.4  2000/07/20 14:33:58  igimeno
-- Added default value to generic.
--
-- Revision 1.3  2000/02/02 16:45:12  igimeno
-- minval changes dynamically.
--
-- Revision 1.2  2000/01/21 13:50:52  igimeno
-- Changed the generic parameter name 'N' into 'depth_g'.
--
-- Revision 1.1  2000/01/20 17:59:04  dbchef
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- MOdULe decLaRaTION
--------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

--library commonlib;
library work;
--    use commonlib.slv_pkg.all;
use work.slv_pkg.all;


entity cnt_max_min_e is
  generic ( depth_g        : integer := 4); -- Word depth
  port( reset_n      : in slv1;  -- active low reset
        clk          : in slv1;  -- clock
        enable       : in slv1;  -- count enable
        minval       : in std_logic_vector(depth_g-1 downto 0);
        maxval       : in std_logic_vector(depth_g-1 downto 0);
        q            : out std_logic_vector(depth_g-1 downto 0)
       );

end cnt_max_min_e;


--------------------------------------------------------------------------------
-- aRcHITecTURe decLaRaTION
--------------------------------------------------------------------------------
architecture rtl of cnt_max_min_e is


--------------------------------------------------------------------------------
-- SIGNaL decLaRaTION
--------------------------------------------------------------------------------
  signal q_o : std_logic_vector(depth_g-1 downto 0);


begin
--------------------------------------------------------------------------------
-- cONcURReNT aSSIGNMeNTS
--------------------------------------------------------------------------------

q <= q_o;
--------------------------------------------------------------------------------
-- PROceSSeS
--------------------------------------------------------------------------------

cnt : process (clk, reset_n, minval)
begin
  if reset_n = '0' then
    q_o <= (others => '0');
  elsif(clk'event and clk = '1') then
    if q_o < minval then
      q_o <= minval;
    elsif enable = '1' then
      if q_o < maxval then
        q_o <= q_o +1;
      else
        q_o <= minval;
      end if;
    end if;
  end if;
end process cnt;


end rtl;
