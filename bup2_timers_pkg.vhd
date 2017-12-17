
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_timers_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.15  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for bup2_timers.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_timers/vhdl/rtl/bup2_timers_pkg.vhd,v  
--  Log: bup2_timers_pkg.vhd,v  
-- Revision 1.15  2006/02/02 08:27:39  Dr.A
-- #BugId:1213#
-- Added bit to ignore VCS for channel assessment
--
-- Revision 1.14  2005/10/21 13:26:57  Dr.A
-- #BugId:1246#
-- Added absolute count timers
--
-- Revision 1.13  2005/04/19 07:25:57  Dr.A
-- #BugId:1181#
-- Ackto counter reset when ackto interrupt disabled.
--
-- Revision 1.12  2005/03/29 08:46:21  Dr.A
-- #BugId:907#
-- Added TX force disable
--
-- Revision 1.11  2005/03/22 10:11:56  Dr.A
-- #BugId:1150#
-- Cleaned write_bckoff ports
--
-- Revision 1.10  2005/02/22 13:26:55  Dr.A
-- #BugId:1086#
-- Delayed context switch if TX is about to start.
--
-- Revision 1.9  2005/02/18 16:19:24  Dr.A
-- #BugId:1070#
-- Added txstartdel_flag output
--
-- Revision 1.8  2005/02/02 17:55:15  Dr.A
-- #BugId:979,980,1009#
-- Backoff reenabled by SW write access (979)
-- All backoff counters aligned on txstartdel when one counts the last slot (980)
-- Backoff interrupt generated only when context is selected (1009)
--
-- Revision 1.7  2005/01/21 15:38:36  Dr.A
-- #BugId:978#
-- Backoff stopped when immediate stop is set
--
-- Revision 1.6  2005/01/20 14:45:26  Dr.A
-- #BugId:964#
-- Counter sizes increased in backoff and sifs counters.
--
-- Revision 1.5  2005/01/13 13:52:19  Dr.A
-- #BugId:903#
-- New diag ports.
--
-- Revision 1.4  2005/01/10 13:11:07  Dr.A
-- #BugId:912,931#
-- Removed enable_bup (bug 912).
-- New output from backoff timer indicating when txstartdel must be removed from SIFS (bug 931).
--
-- Revision 1.3  2004/12/20 12:50:43  Dr.A
-- #BugId:702#
-- Added ACK time-out mechanism.
--
-- Revision 1.2  2004/12/03 14:09:25  Dr.A
-- #BugId:837#
-- Added channel assessment timers
--
-- Revision 1.1  2003/11/19 16:26:58  Dr.F
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
package bup2_timers_pkg is

  constant CHASSTIM_MAX_CT : std_logic_vector(25 downto 0) := (others => '1');
  
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: backoff2.vhd
----------------------
  component backoff2
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n             : in  std_logic; -- Reset.
    pclk                : in  std_logic; -- APB clock.

    --------------------------------------------
    -- Port for 1 Mhz enable.
    --------------------------------------------
    enable_1mhz         : in  std_logic; -- Enable at 1 MHz.

    --------------------------------------------
    -- Backoff Timer Control.
    --------------------------------------------
    reg_backoff         : in  std_logic_vector( 9 downto 0); -- Backoff init value
    write_backoff       : in  std_logic; -- update backoff timer with init value
    -- BuPbackoff register when read
    backoff_timer       : out std_logic_vector( 9 downto 0);
    backoff_timer_end   : out std_logic; -- interrupt when backoff reaches 0.
    tx_without_backoff  : out std_logic; -- TX will start without backoff,
                      -- do not wait for backoff end to remove txstartdel from SIFS
    -- indicates when high that this is the last MACslot
    last_slot           : out std_logic;

    -- 
    global_last_slot    : in  std_logic;
    context_change      : in  std_logic; -- Pulse at ACP/BCON context switch request
    reg_vcs             : in  std_logic; -- Virtual carrier sense.
    cca_busy            : in  std_logic; -- CCA busy
    backenable          : in  std_logic; -- backoff counter enable
    tx_enable           : in  std_logic; -- transmit enable coming from reg.
    tximmstop_sm        : in  std_logic; -- Immediate stop from the state machines
    sifs_end            : in  std_logic; -- end of SIFS counter
    bup_sm_idle         : in  std_logic; -- no packet in progress when high
    global_backoff_it   : in  std_logic; -- pulse when another backoff counter
                                         -- has reached 0 
    ackto_timer_on      : in  std_logic; -- ACK time-out counter is running.
    reg_macslot         : in  std_logic_vector(7 downto 0); -- Slot duration (us)
    reg_ifs             : in  std_logic_vector(3 downto 0); -- nbr of MACslots
                                     -- that should be added after SIFS
    txstartdel          : in  std_logic_vector(2 downto 0) -- Nb of us to remove
                                     -- from last slot before TX.
    
    );

  end component;


----------------------
-- File: chass_timers.vhd
----------------------
  component chass_timers
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

  end component;


----------------------
-- File: ackto_timer.vhd
----------------------
  component ackto_timer
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n             : in  std_logic; -- Reset.
    clk                 : in  std_logic; -- Clock.
    enable_1mhz         : in  std_logic; -- Enable at 1 MHz.
    mode32k             : in  std_logic; -- High in low-power mode.

    --------------------------------------
    -- Controls
    --------------------------------------
    txstart_it          : in  std_logic; -- Start of transmission pulse
    txend_it            : in  std_logic; -- End of transmission pulse
    rxstart_it          : in  std_logic; -- Start of reception pulse
    -- Control fields from tx packet control structure:
    ackto_count         : in  std_logic_vector(8 downto 0); -- Time-out value
    -- Enable ACK time-out generation
    ackto_en            : in  std_logic; -- From TX control struture
    reg_ackto_en        : in  std_logic; -- From registers
    --
    ackto_it            : out std_logic; -- Time-out pulse
    ackto_timer_on      : out std_logic  -- High while timer is running.
    
  );

  end component;


----------------------
-- File: abscnt_timers.vhd
----------------------
  component abscnt_timers
  generic (
    num_abstimer_g : integer := 16
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n               : in std_logic;
    clk                   : in std_logic;

    --------------------------------------
    -- Controls
    --------------------------------------
    mode32k               : in std_logic;
    bup_timer             : in  std_logic_vector(25 downto 0);

    --------------------------------------
    -- Timers time tags
    --------------------------------------
    abstime0              : in  std_logic_vector(25 downto 0);
    abstime1              : in  std_logic_vector(25 downto 0);
    abstime2              : in  std_logic_vector(25 downto 0);
    abstime3              : in  std_logic_vector(25 downto 0);
    abstime4              : in  std_logic_vector(25 downto 0);
    abstime5              : in  std_logic_vector(25 downto 0);
    abstime6              : in  std_logic_vector(25 downto 0);
    abstime7              : in  std_logic_vector(25 downto 0);
    abstime8              : in  std_logic_vector(25 downto 0);
    abstime9              : in  std_logic_vector(25 downto 0);
    abstime10             : in  std_logic_vector(25 downto 0);
    abstime11             : in  std_logic_vector(25 downto 0);
    abstime12             : in  std_logic_vector(25 downto 0);
    abstime13             : in  std_logic_vector(25 downto 0);
    abstime14             : in  std_logic_vector(25 downto 0);
    abstime15             : in  std_logic_vector(25 downto 0);
    --------------------------------------
    -- Timers interrupts
    --------------------------------------
    abscount_it           : out std_logic_vector(num_abstimer_g-1 downto 0)    
  );

  end component;



 
end bup2_timers_pkg;
