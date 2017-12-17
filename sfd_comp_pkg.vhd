


--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: sfd_comp_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for sfd_comp.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/sfd_comp/vhdl/rtl/sfd_comp_pkg.vhd,v  
--  Log: sfd_comp_pkg.vhd,v  
-- Revision 1.3  2002/09/17 07:17:35  Dr.B
-- short packet sync added in long_sfd_comp.
--
-- Revision 1.2  2002/07/31 07:45:50  Dr.B
-- added sfdlen.
--
-- Revision 1.1  2002/07/03 11:48:38  Dr.B
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
package sfd_comp_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: sfd_comp_pkg.vhd
----------------------
-- No entity declaration


----------------------
-- File: short_sfd_comp.vhd
----------------------
  component short_sfd_comp
  port (
    -- clock and reset
    clk                  : in std_logic;
    reset_n              : in std_logic;

    -- inputs
    sh_sfd_comp_activate : in std_logic;  -- activate the block   
    demap_data0          : in std_logic;  -- bit 0 of PSK_demapping output data
    symbol_sync          : in std_logic;  -- chip synchronization
    sfderr               : in std_logic_vector (2 downto 0); -- allowed errs nb
    sfdlen               : in std_logic_vector (2 downto 0);

    -- output
    short_packet_sync    : out std_logic  -- indicate when detect of short SFD
    );

  end component;


----------------------
-- File: long_sfd_comp.vhd
----------------------
  component long_sfd_comp
  port (
     -- clock and reset
    clk                  : in std_logic;
    reset_n              : in std_logic;

    -- inputs
    lg_sfd_comp_activate : in std_logic;  -- activate the block   
    delta_phi0           : in std_logic;  -- bit 0 of PSK_demapping output data
    symbol_sync          : in std_logic;  -- chip synchronization

    -- output
    long_packet_sync     : out std_logic; -- indicate when detect of long SFD
    short_packet_sync    : out std_logic  -- indicate when detect of short SFD
 );

  end component;



 
end sfd_comp_pkg;
