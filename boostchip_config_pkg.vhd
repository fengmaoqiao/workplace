
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : BOOST Core
--    ,' GoodLuck ,'      RCSfile: boostchip_config_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.8   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/PROJECTS/WILD_IP_LIB/packages/config/vhdl/pkg/boostchip_config_pkg.vhd,v  
--  Log: boostchip_config_pkg.vhd,v  
-- Revision 1.8  2000/11/21 16:24:51  dbchef
-- Name updated.
--
-- Revision 1.7  2000/11/21 16:23:11  dbchef
-- Package name updated.
--
-- Revision 1.6  2000/11/21 16:14:30  dbchef
-- Updated without APB constant.
--
-- Revision 1.5  2000/11/20 14:25:18  parnould
-- TARGET_t removed.
--
-- Revision 1.4  2000/11/15 15:08:55  parnould
-- Updated.
--
-- Revision 1.3  2000/11/15 10:08:49  parnould
-- Name updated.
--
-- Revision 1.2  2000/11/15 07:58:06  parnould
-- Name updated.
--
-- Revision 1.1  2000/11/15 07:41:00  parnould
-- Initial revision
--
--
--------------------------------------------------------------------------------



library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package boostchip_config_pkg is

  ------------------------------------------------------------------------------
  -- Constants for internal SRAM
  ------------------------------------------------------------------------------
  constant SRAM_WIDTH_CT : integer := 15;
  	
end boostchip_config_pkg;
