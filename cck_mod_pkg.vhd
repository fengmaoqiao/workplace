
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: cck_mod_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for cck_mod.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/cck_mod/vhdl/rtl/cck_mod_pkg.vhd,v  
--  Log: cck_mod_pkg.vhd,v  
-- Revision 1.4  2004/12/20 16:20:44  arisse
-- #BugId:596#
-- Added txv_immstop for BT Co-existence.
--
-- Revision 1.3  2002/07/04 08:40:29  Dr.B
-- unused generic removed.
--
-- Revision 1.2  2002/04/30 11:55:16  Dr.B
-- enable => activate.
--
-- Revision 1.1  2002/02/06 14:32:41  Dr.B
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
package cck_mod_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: cck_form.vhd
----------------------
  component cck_form
  port (
    -- clock and reset
    clk             : in  std_logic;                    
    resetn          : in  std_logic;                   
     
    -- inputs
    cck_form_in    : in  std_logic_vector ( 7 downto 0);
    --               byte from the buffer 
    phy_data_req   : in  std_logic; 
    --               BuP send a Tx octet to the Modem
    cck_speed      : in  std_logic; 
    --               5.5 Mbits/s = 0 - 11 Mbits/s = 1 
    cck_form_activate: in  std_logic; 
    --               activate the cck_form block.
    shift_pulse    : in  std_logic;
    --               reduce shift frequency.
    txv_immstop    : in std_logic;
    --               immediate stop from Bup for BT Co-existence.
    
    -- outputs
    cck_form_out   : out std_logic_vector (7 downto 0);
    --               byte output   
    phy_data_conf  : out std_logic;
    --               The modem indicates that the Tx path has read the new octet
    --               A new one should be presented as soon as possible.
    scramb_reg     : out std_logic;
    --               Indicate to the scrambler that it can register the
    --               last data. (pulse)
    shift_mapping  : out std_logic;
    --               shift mapping (save last_phi)
    first_data     : out std_logic;
    --               indicate that the first data is sent (even data)
    new_data       : out std_logic;
    --               indicate to cck_mod that a new data is valid.
    fol_bl_activate  : out std_logic
    --               manage the enable of the following blocks to finish byte.
  
  );

  end component;


----------------------
-- File: cck_mod.vhd
----------------------
  component cck_mod
  port (
    -- clock and reset
    clk                : in  std_logic;                    
    resetn             : in  std_logic;                   
     
    -- inputs
    cck_mod_in         : in  std_logic_vector (7 downto 2);
    --                   input data
    cck_mod_activate     : in  std_logic;
    --                   enable cck_mod block
    first_data         : in  std_logic;
    --                   indicate that the first data is sent (even data)
    new_data           : in  std_logic;
    --                   a new data is available and valid 
    phi_map            : in  std_logic_vector (1 downto 0);
    --                   for phi1 calculated from mapping
    shift_pulse        : in  std_logic;
    --                   reduce shift ferquency.
    -- outputs
    phi_out            : out std_logic_vector (1 downto 0)
  );

  end component;



 
end cck_mod_pkg;
