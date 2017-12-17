

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: wild_config_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.13   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : WILD Configuration package.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/PROJECTS/WILD_IP_LIB/packages/wild_config/vhdl/pkg/wild_config_pkg.vhd,v  
--  Log: wild_config_pkg.vhd,v  
-- Revision 1.13  2003/08/28 08:15:06  sbizet
-- Disabled etm7
--
-- Revision 1.12  2003/08/28 08:03:25  sbizet
-- Enabled etm7
--
-- Revision 1.11  2003/08/28 07:36:59  sbizet
-- Disabled ETM7
--
-- Revision 1.10  2002/11/13 07:40:31  Dr.A
-- use integer type for external_arm_ct.
--
-- Revision 1.9  2002/10/24 17:22:08  Dr.A
-- Added constant for NL Analyzer.
--
-- Revision 1.8  2002/10/08 09:37:02  Dr.J
-- Enable the ETM7
--
-- Revision 1.7  2002/10/01 15:38:12  Dr.A
-- Use_uart set to true.
--
-- Revision 1.6  2002/09/25 17:53:28  Dr.A
-- Revert to previous version.
--
-- Revision 1.5  2002/09/25 17:47:17  Dr.A
-- Added constants for synchronizer cells.
--
-- Revision 1.4  2002/06/19 16:08:34  Dr.J
-- Use an internal ARM
--
-- Revision 1.3  2002/04/25 09:00:35  Dr.J
-- Added the ENABLE_ETM7_CT constant
--
-- Revision 1.2  2002/03/27 13:40:57  Dr.J
-- Used BOOLEAN constants
--
-- Revision 1.1  2002/03/27 10:33:19  Dr.J
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
package wild_config_pkg is

  -------------------------------  
  -- WILD Platform Configuration
  -------------------------------
    -- Use an External ARM. 
    -- Possible value : true or false
  constant EXTERNAL_ARM_CT  : INTEGER := 0; 

    -- Use the ETM7.
    -- Possible value : true or false
  constant ENABLE_ETM7_CT   : BOOLEAN := false;

    -- Use an Internal UART.
    -- Possible value : true or false
  constant USE_UART_CT      : BOOLEAN := true;

    -- Use the GoodLuck Analyzer.
    -- Possible value : true or false
  constant USE_NL_ANALYZER_CT  : BOOLEAN := false;

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------

 
end wild_config_pkg;
