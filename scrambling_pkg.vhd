
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: scrambling_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for scrambling.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/scrambling/vhdl/rtl/scrambling_pkg.vhd,v  
--  Log: scrambling_pkg.vhd,v  
-- Revision 1.5  2004/12/20 16:16:12  arisse
-- #BugId:596#
-- Added txv_immstop for BT Co-existence.
--
-- Revision 1.4  2002/07/03 11:36:42  Dr.B
-- new ports for descrambling.
--
-- Revision 1.3  2002/04/30 11:58:10  Dr.B
-- phy_data_conf => scramb_reg . enable => activate.
--
-- Revision 1.2  2002/01/29 15:59:10  Dr.B
-- phy_data_ind / phy_data_conf input added.
--
-- Revision 1.1  2001/12/12 14:41:12  Dr.B
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
package scrambling_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: scrambling8_8.vhd
----------------------
  component scrambling8_8
  port (
    -- clock and reset
    clk       : in  std_logic;                    
    resetn    : in  std_logic;                   
     
    -- inputs
    scr_in          : in  std_logic_vector (7 downto 0);
    --                8-bits input
    scr_activate    : in  std_logic;
    --                start and scramble
    scramb_reg      : in std_logic;
    --                confirmation from modem of a new byte tranfer.
    txv_prtype      : in std_logic; 
    --                0 for short sync packets / 1 for long sync packets.
    scrambling_disb : in std_logic;
    --                disable the scrambler when high (for modem tests)
    txv_immstop     : in std_logic;
    --                immediate stop from Bup.
    
    -- outputs
    scr_out         : out std_logic_vector (7 downto 0) 
    --                scrambled data
    );
  end component;


----------------------
-- File: descrambling8_8.vhd
----------------------
  component descrambling8_8
  port (
    -- clock and reset
    clk     : in std_logic;
    reset_n : in std_logic;

    dscr_activate   : in std_logic;     -- activate the block
    scrambling_disb : in std_logic;     -- disable the descr.when high 
    dscr_mode       : in std_logic;     -- 0 : serial - 1 : parallel

    -- Signals for serial descrambling
    bit_fr_diff_dec : in  std_logic;    -- bit from differential decoder
    symbol_sync     : in  std_logic;    -- chip synchronisation
    --
    dscr_bit_out    : out std_logic;

    -- Signals for parallel descrambling   
    byte_fr_des : in  std_logic_vector (7 downto 0);  -- byte from deseria.
    byte_sync   : in  std_logic;                      --  sync from deseria
    --
    data_to_bup : out std_logic_vector (7 downto 0)

    );

  end component;


----------------------
-- File: scrambling_pkg.vhd
----------------------
-- No entity declaration



 
end scrambling_pkg;
