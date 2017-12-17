
--------------------------------------------------------------------------------
--       ------------      Project : GoodLuck Package
--    ,' GoodLuck ,'      RCSfile: block_pkg.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Counter with max count, enable and final count interrupt.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/packages/commonlib/vhdl/rtl/block_pkg.vhd,v  
--  Log: block_pkg.vhd,v  
-- Revision 1.4  2001/12/06 09:17:48  Dr.J
-- Added description and project name
--
-- Revision 1.3  2000/01/26 12:56:29  Dr.F
-- added cnt_max_pl_e_i, dec_sr_e_i and ones_cnt components.
--
-- Revision 1.2  2000/01/21 13:49:40  igimeno
-- Changed the generic parameter name 'N' into 'depth_g'.
--
-- Revision 1.1  2000/01/20 17:58:50  dbchef
-- Initial revision
--
--
--------------------------------------------------------------------------------


library ieee;
    use ieee.std_logic_1164.all;

--library commonlib;
library work;
--    use commonlib.slv_pkg.all;
use work.slv_pkg.all;


package block_pkg is

  component cnt_max_e_i
    generic ( depth_g        : integer := 4);
    port ( reset_n     :  in slv1;
           clk         :  in slv1;
           enable      :  in slv1;
           maxval      :  in std_logic_vector(depth_g-1 downto 0);
           termint     : out slv1;
           q           : out std_logic_vector(depth_g-1 downto 0)
         );
  end component;


  component cnt_max_sr_e_i
    generic ( depth_g        : integer := 4);
    port ( reset_n     :  in slv1;
           clk         :  in slv1;
           sreset      :  in slv1;
           enable      :  in slv1;
           maxval      :  in std_logic_vector(depth_g-1 downto 0);
           termint     : out slv1;
           q           : out std_logic_vector(depth_g-1 downto 0)
         );
  end component;


  component cnt_sr_e_i
    generic ( depth_g        : integer := 4);
    port ( reset_n     :  in slv1;
           clk         :  in slv1;
           sreset      :  in slv1;
           enable      :  in slv1;
           termint     : out slv1;
           q           : out std_logic_vector(depth_g-1 downto 0)
         );
  end component;


  component cnt_sr_e
    generic ( depth_g        : integer := 4);
    port ( reset_n     :  in slv1;
           clk         :  in slv1;
           sreset      :  in slv1;
           enable      :  in slv1;
           q           : out std_logic_vector(depth_g-1 downto 0)
         );
  end component;


  component cnt_max_min_e
    generic ( depth_g       : integer); -- Word depth
    port ( reset_n     : in slv1;  -- active low reset
           clk         : in slv1;  -- clock
           enable      : in slv1;  -- count enable
           minval      : in std_logic_vector(depth_g-1 downto 0);
           maxval      : in std_logic_vector(depth_g-1 downto 0);
           q           : out std_logic_vector(depth_g-1 downto 0)
         );
  end component;

  component cnt_max_pl_e_i
    generic ( depth_g        : integer := 4);
    port ( reset_n     :  in slv1;
           clk         :  in slv1;
           enable      :  in slv1;
           load_enable :  in slv1;
           load_data   :  in std_logic_vector(depth_g-1 downto 0);
           maxval      :  in std_logic_vector(depth_g-1 downto 0);
           termint     : out slv1;
           q           : out std_logic_vector(depth_g-1 downto 0)
         );
  end component;

  component dec_sr_e_i
    generic ( depth_g        : integer := 4);
    port ( reset_n     :  in slv1;
           clk         :  in slv1;
           sreset      :  in slv1;
           enable      :  in slv1;
           maxval      :  in std_logic_vector(depth_g-1 downto 0);
           termint     : out slv1;
           q           : out std_logic_vector(depth_g-1 downto 0)
         );
  end component;

  component ones_cnt
    generic ( depthin_g     : integer;
              depthout_g    : integer); -- Word depth
    port( vector_in    : in std_logic_vector(depthin_g-1 downto 0);
          ones_out     : out std_logic_vector(depthout_g-1 downto 0)
         );
  end component;


end block_pkg;
