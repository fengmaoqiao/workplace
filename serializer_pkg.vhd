
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: serializer_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for serializer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/serializer/vhdl/rtl/serializer_pkg.vhd,v  
--  Log: serializer_pkg.vhd,v  
-- Revision 1.5  2004/12/20 16:13:40  arisse
-- #BugId:596#
-- Added txv_immstop to input ports.
--
-- Revision 1.4  2002/07/31 07:35:58  Dr.B
-- deserializer removed.
--
-- Revision 1.3  2002/04/30 12:18:15  Dr.B
-- enable => activate + scramb_reg added.
--
-- Revision 1.2  2002/01/29 16:20:22  Dr.B
-- control signals for other blocks added.
--
-- Revision 1.1  2001/12/20 09:30:17  Dr.B
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
package serializer_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: serializer.vhd
----------------------
  component serializer
  port (
    -- clock and reset
    clk             : in  std_logic;                    
    resetn          : in  std_logic;                   
     
    -- inputs
    seria_in       : in  std_logic_vector ( 7 downto 0);
    --               byte from the buffer 
    phy_data_req   : in  std_logic;
    --               the BuP send a Tx octet to the Modem (on switched signal)
    psk_mode       : in  std_logic;
    --               BPSK = 0 - QPSK = 1
    seria_activate : in  std_logic;
    --               activate the seria. when disabled the serializer finishes
    --               its last byte.
    shift_period   : in  std_logic_vector (3 downto 0);
    --               nb of (per-1) between 2 shifts(if clk=11MHz,1MHz is 10)
    shift_pulse    : in  std_logic;
    --               reduce shift ferquency.
    txv_prtype     : in  std_logic; 
    --               def the type of preamble (short or long)
    txv_immstop    : in std_logic;
    --               for BT co-existence, stop tx immediately if high.

    -- outputs
    seria_out      : out std_logic_vector (1 downto 0); 
    --               2-bits outputs 
    phy_data_conf  : out std_logic;
    --               The modem ind. that the Tx path has read the new octet.
    --               A new one should be presented as soon as possible.
    scramb_reg     : out std_logic;
    --               Indicate to the scrambler that it can register the
    --               last data. (pulse)
    shift_mapping  : out std_logic;
    --               ask of performing a new mapping op. (every dibits sent)
    map_first_val  : out std_logic;
    --               indicate the the mapping that the first data arrives.
    fol_bl_activate: out std_logic;
    --               manage the acti. of the following blocks to finish byte.
    cck_disact     : out std_logic
    --               keep high during bytes transfer.
    --               when high, the cck block does not see phy_data_req     
  
  );

  end component;



 
end serializer_pkg;
