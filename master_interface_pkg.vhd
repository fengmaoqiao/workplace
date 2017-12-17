
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Master interface
--    ,' GoodLuck ,'      RCSfile: master_interface_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Master interface pkg file.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/PROC_SYSTEM/master_interface/vhdl/rtl/master_interface_pkg.vhd,v  
--  Log: master_interface_pkg.vhd,v  
-- Revision 1.6  2003/07/03 12:30:58  Dr.A
-- Removed use slv_pkg.
--
-- Revision 1.5  2002/03/06 10:03:31  Dr.C
-- Added generic gotoaddr_g
--
-- Revision 1.4  2002/01/30 07:42:58  Dr.C
-- Added ports
--
-- Revision 1.3  2001/12/03 14:02:16  Dr.C
-- Added generic burstlinkcapable_g
--
-- Revision 1.2  2001/07/24 09:14:23  Dr.B
-- pipeline mode added.
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
package master_interface_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: master_interface.vhd
----------------------
  component master_interface
  generic 
      (
      gotoaddr_g         : integer := 0;
      burstlinkcapable_g : integer := 1
      ) ;

  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hclk            : in  std_logic;
    hreset_n        : in  std_logic;
    
    --------------------------------------
    -- Signal to/from logic part of master
    --------------------------------------
    --write           : in  std_logic;
    burst           : in  std_logic_vector(2 downto 0);
    busreq          : in  std_logic;
    unspeclength    : in  std_logic;
    busy            : in  std_logic;
    buserror        : out std_logic;     
    inc_addr        : out std_logic;    
    valid_data      : out std_logic;
    decr_addr       : out std_logic;    
    grant_lost      : out std_logic;
    end_add         : out std_logic;
    end_data        : out std_logic;
    free            : out std_logic;
   
    --------------------------------------
    -- AHB control signals
    --------------------------------------
    hready          : in  std_logic;
    hresp           : in  std_logic_vector(1 downto 0);
    hgrant          : in  std_logic;
    htrans          : out std_logic_vector(1 downto 0);
    hbusreq         : out std_logic

  );

  end component;



 
end master_interface_pkg;
