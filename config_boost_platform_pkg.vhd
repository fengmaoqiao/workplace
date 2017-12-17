
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : BOOSTCore platforms configuration
--    ,' GoodLuck ,'      RCSfile: config_boost_platform_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Constants definition for Boost Platform.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/PROJECTS/WILD_IP_LIB/packages/config/vhdl/pkg/config_boost_platform_pkg.vhd,v  
--  Log: config_boost_platform_pkg.vhd,v  
-- Revision 1.1  2002/03/18 17:34:04  ygilbert
-- Initial revision
--
--
--
--------------------------------------------------------------------------------


library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 
    use IEEE.std_logic_unsigned.all;
    use IEEE.std_logic_arith.all;

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package config_boost_platform_pkg is

  -----------------------------------------------------------------------------
  -- BOOST Platform Configuration Constants.
  -----------------------------------------------------------------------------
  
  -- Instantiate PCM & CVSD
  -- Possible value : true or false
  constant PCM_CVSD_CT           : BOOLEAN := true;

  -- Instantiate a/u law encoder between PCM & CVSD
  -- Possible value : true or false
  constant A_U_LAW_ENCODER_CT    : BOOLEAN := false;

  -- Uart to be instantiated
  -- Possible value: "00"    -> No uart instantiated
  --                 "01"    -> Uart1 instantiated
  --                 "10"    -> Uart2 instantiated
  --                 "11"    -> Uart1 & Uart2 instantiated
  constant UART_MASK_CT          : STD_LOGIC_VECTOR(1 downto 0) := "11"; 

  -- Use enhanced_uart16550 for uarts
  -- Possible value : true or false
  constant ENHANCED_UART16550_CT : BOOLEAN := false;


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------

 
end config_boost_platform_pkg;
