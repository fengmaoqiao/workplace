
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: mapping_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for mapping.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/mapping/vhdl/rtl/mapping_pkg.vhd,v  
--  Log: mapping_pkg.vhd,v  
-- Revision 1.3  2002/04/30 12:07:57  Dr.B
-- enable => activate.
--
-- Revision 1.2  2002/01/29 16:24:47  Dr.B
-- shift_mapping added.
--
-- Revision 1.1  2001/12/20 12:51:19  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--library CommonLib;
library work;
--    use CommonLib.slv_pkg.all;
use work.slv_pkg.all;


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package mapping_pkg is

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: mapping.vhd
----------------------
  component mapping
  port (
    -- clock and reset
    clk          : in  std_logic;                    
    resetn       : in  std_logic;    
    
    -- inputs
    map_activate : in  std_logic;  
    --             enable the mapping block
    map_first_val: in  std_logic;  
    --             initialize the mapping block the first value is sent. 
    --             (map_activate should be enabled).
    map_in       : in  std_logic_vector (1 downto 0); 
    --             mapping input
    shift_mapping: in  std_logic;
    --             shift mapping (from serializer or cck)

    -- outputs
    phi_map      : out std_logic_vector (1 downto 0) -- mapping output
                   
     
  );

  end component;



 
end mapping_pkg;
