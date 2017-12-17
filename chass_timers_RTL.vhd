
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: chass_timers.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : BuP timers for channel assessment.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_timers/vhdl/rtl/chass_timers.vhd,v  
--  Log: chass_timers.vhd,v  
-- Revision 1.2  2006/02/02 08:27:44  Dr.A
-- #BugId:1213#
-- Added bit to ignore VCS for channel assessment
--
-- Revision 1.1  2004/12/03 14:12:48  Dr.A
-- #BugId:837#
-- Channel assessment timers
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
 
--library bup2_timers_rtl;
library work;
--use bup2_timers_rtl.bup2_timers_pkg.all;
use work.bup2_timers_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity chass_timers is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n             : in  std_logic; -- Reset
    clk                 : in  std_logic; -- Clock
    enable_1mhz         : in  std_logic; -- Enable at 1 MHz
    mode32k             : in  std_logic; -- High during low-power mode

    --------------------------------------
    -- Controls
    --------------------------------------
    vcs_enable          : in  std_logic; -- Virtual carrier sense enable
    phy_cca_ind         : in  std_logic; -- CCA status
    phy_txstartend_conf : in  std_logic; -- Transmission status
    reg_chassen         : in  std_logic; -- Channel assessment enable
    reg_ignvcs          : in  std_logic; -- Ignore VCS in channel assessment
    reset_chassbsy      : in  std_logic; -- Reset channel busy timer
    reset_chasstim      : in  std_logic; -- Reset channel timer

    --------------------------------------
    -- Channel assessment timers
    --------------------------------------
    reg_chassbsy        : out std_logic_vector(25 downto 0);
    reg_chasstim        : out std_logic_vector(25 downto 0)
    
  );

end chass_timers;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of chass_timers is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal int_chassbsy        : std_logic_vector(25 downto 0);
  signal int_chasstim        : std_logic_vector(25 downto 0);
  signal channel_busy        : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- Assign output ports.
  reg_chassbsy <= int_chassbsy;
  reg_chasstim <= int_chasstim;
  
  -- Channel assessment counter increments every MHz when:
  -- * the low-power mode is not activated
  -- * channel assessment is enabled (reg_chassen)
  -- * it has not reached its max value
  chasstim_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      int_chasstim <= (others => '0');
    elsif clk'event and clk = '1' then

      -- Software request to reset the timer.
      if reset_chasstim = '1' then
        int_chasstim <= (others => '0');
      else
        if reg_chassen = '1' and int_chasstim /= CHASSTIM_MAX_CT
                             and enable_1mhz = '1' and mode32k = '0' then
          int_chasstim <= int_chasstim + 1;
        end if;
      end if;

    end if;
  end process chasstim_p;
  
  
  -- Channel busy condition.
  -- * ignore VCS if reg_ignvcs is HIGH.
  channel_busy <= (vcs_enable and not(reg_ignvcs))
                  or phy_cca_ind or phy_txstartend_conf;
  
  -- Channel busy counter increments every MHz when:
  -- * the low-power mode is not activated
  -- * channel assessment is enabled (reg_chassen)
  -- * chasstim has not reached its max value
  -- * the channel_busy condition is met.
  chassbsy_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      int_chassbsy <= (others => '0');

    elsif clk'event and clk = '1' then

      -- Software request to reset the timer.
      if reset_chassbsy = '1' then
        int_chassbsy <= (others => '0');
      else
        if reg_chassen = '1' and int_chasstim /= CHASSTIM_MAX_CT
                             and enable_1mhz = '1' and mode32k = '0'
                             and channel_busy = '1' then
          int_chassbsy <= int_chassbsy + 1;
        end if;
      end if;

    end if;
  end process chassbsy_p;
  
  

end RTL;
