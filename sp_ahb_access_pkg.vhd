
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Stream Processor
--    ,' GoodLuck ,'      RCSfile: sp_ahb_access_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for sp_ahb_access.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/sp_ahb_access/vhdl/rtl/sp_ahb_access_pkg.vhd,v  
--  Log: sp_ahb_access_pkg.vhd,v  
-- Revision 1.6  2005/04/26 07:57:55  Dr.A
-- #BugId:1184#
-- Burst broken when hsize changes by setting htrans to NON_SEQ
--
-- Revision 1.5  2003/10/02 12:56:54  Dr.A
-- cleaned.
--
-- Revision 1.4  2003/07/03 14:16:57  Dr.A
-- PKG update.
--
-- Revision 1.3  2002/11/20 10:59:54  Dr.B
-- add addrmax_g generic.
--
-- Revision 1.2  2002/10/31 16:08:23  Dr.B
-- sp_init added.
--
-- Revision 1.1  2002/10/25 14:14:35  Dr.B
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
package sp_ahb_access_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/PROC_SYSTEM/master_interface/vhdl/rtl/master_interface.vhd
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



 
end sp_ahb_access_pkg;
