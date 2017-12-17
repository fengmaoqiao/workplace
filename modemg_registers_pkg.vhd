
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: modemg_registers_pkg.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for modemg_registers.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11g/modemg_registers/vhdl/rtl/modemg_registers_pkg.vhd,v  
--  Log: modemg_registers_pkg.vhd,v  
-- Revision 1.6  2005/03/23 08:30:08  Dr.J
-- #BugId:720#
-- Added Energy Detect register
--
-- Revision 1.5  2004/12/14 15:56:55  Dr.J
-- #BugId:727,837#
-- Added MDMg11H & MDMgADDESTIMDUR registers
--
-- Revision 1.4  2004/06/04 13:15:31  Dr.C
-- Added iq swap for tx and rx.
--
-- Revision 1.3  2003/11/20 16:33:57  Dr.J
-- Updated for agc_hiss_bb
--
-- Revision 1.2  2003/11/14 15:51:54  Dr.C
-- Updated.
--
-- Revision 1.1  2003/05/12 15:32:41  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package modemg_registers_pkg is

  -- registers address 
  constant MDMgVERSION_ADDR_CT    : std_logic_vector(5 downto 0) := "000000";
  constant MDMgCNTL_ADDR_CT       : std_logic_vector(5 downto 0) := "000100";
  constant MDMgAGCCCA_ADDR_CT     : std_logic_vector(5 downto 0) := "001000";
  constant MDMgADDESTMDUR_ADDR_CT : std_logic_vector(5 downto 0) := "001100";
  constant MDMg11hCNTL_ADDR_CT    : std_logic_vector(5 downto 0) := "010000";
  constant MDMg11hSTAT_ADDR_CT    : std_logic_vector(5 downto 0) := "010100";


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: modemg_registers.vhd
----------------------
  component modemg_registers
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n         : in  std_logic; -- Reset.
    pclk            : in  std_logic; -- APB clock.

    --------------------------------------------
    -- APB slave
    --------------------------------------------
    psel            : in  std_logic; -- Device select.
    penable         : in  std_logic; -- Defines the enable cycle.
    paddr           : in  std_logic_vector( 5 downto 0); -- Address.
    pwrite          : in  std_logic; -- Write signal.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata          : out std_logic_vector(31 downto 0); -- Read data.
  
    --------------------------------------------
    -- Modem Registers Inputs
    --------------------------------------------
    -- MDMg11hCNTL register.
    ofdmcoex         : in  std_logic_vector(7 downto 0); -- Current value of the 
                                                         -- OFDM Preamble Existence counter   
    -- MDMgAGCCCA register.
    edtransmode_reset : in std_logic; -- Reset the edtransmode register     
    --------------------------------------------
    -- Modem Registers Outputs
    --------------------------------------------
    reg_modeabg      : out std_logic_vector(1 downto 0);  -- Operating mode.
    reg_tx_iqswap    : out std_logic;                     -- Swap I/Q in Tx.
    reg_rx_iqswap    : out std_logic;                     -- Swap I/Q in Rx.
    -- MDMgAGCCCA register.
    reg_deldc2       : out std_logic_vector(4 downto 0);   -- DC waiting period.
    reg_longslot     : out std_logic;
    reg_cs_max       : out std_logic_vector(3 downto 0);
    reg_sig_max      : out std_logic_vector(3 downto 0);
    reg_agc_disb     : out std_logic;
    reg_modeant      : out std_logic;
    reg_edtransmode  : out std_logic; -- Energy Detect Transitional Mode
    reg_edmode       : out std_logic; -- Energy Detect Mode
    -- MDMgADDESTMDUR register.
    reg_addestimdura : out std_logic_vector(3 downto 0); -- additional time duration 11a
    reg_addestimdurb : out std_logic_vector(3 downto 0); -- additional time duration 11b
    reg_rampdown     : out std_logic_vector(2 downto 0); -- ramp-down time duration
    -- MDMg11hCNTL register.
    reg_rstoecnt     : out std_logic                     -- Reset OFDM Preamble Existence cnounter

    );

  end component;



 
end modemg_registers_pkg;
