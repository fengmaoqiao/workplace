--------------------------------------------------------------------------------
--       ------------      Project : GoodLuck Package
--    ,' GoodLuck ,'      RCSfile: ones_cnt.vhd,v  
--   '-----------'     Only for Study  
--
--  Revision: 1.6  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Ones counter.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/packages/commonlib/vhdl/rtl/ones_cnt.vhd,v  
--  Log: ones_cnt.vhd,v  
-- Revision 1.6  2001/12/06 09:18:47  Dr.J
-- Added description and project name
--
-- Revision 1.5  2000/07/20 14:34:20  igimeno
-- Added default value to generic.
--
-- Revision 1.4  2000/02/03 16:50:12  Dr.F
-- added begin. Oups...
--
-- Revision 1.3  2000/02/03 16:45:58  Dr.F
-- Removed internal signals and used a variable instead.
--
-- Revision 1.2  2000/01/26 13:04:32  Dr.F
-- added description.
--
-- Revision 1.1  2000/01/26 12:21:15  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- entity declaration
--------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;

--library commonlib;
library work;
--    use commonlib.slv_pkg.all;
use work.slv_pkg.all;


entity ones_cnt is
  generic ( depthin_g        : integer := 4;
            depthout_g       : integer := 4); -- Word depth
  port( vector_in            : in std_logic_vector(depthin_g-1 downto 0);
        ones_out             : out std_logic_vector(depthout_g-1 downto 0)
       );

end ones_cnt;


--------------------------------------------------------------------------------
-- architecture declaration
--------------------------------------------------------------------------------
architecture rtl of ones_cnt is
begin
  
  ----------------------------------------------------------------------------
  -- process
  ----------------------------------------------------------------------------
  cnt : process (vector_in)
    variable i : integer;
    variable ones_out_v   : std_logic_vector(depthout_g-1 downto 0);
  begin
    ones_out_v := (others => '0');
    for i in 0 to depthin_g-1 loop
      if vector_in(i) = '1' then
        ones_out_v := ones_out_v + '1';
      end if;
    end loop;
    ones_out <= ones_out_v;
  end process cnt;

end rtl;
