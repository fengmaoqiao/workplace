
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLDBuP2
--    ,' GoodLuck ,'      RCSfile: backoff2.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.9  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Backoff timer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_timers/vhdl/rtl/backoff2.vhd,v  
--  Log: backoff2.vhd,v  
-- Revision 1.9  2005/03/22 10:10:57  Dr.A
-- #BugId:1150#
-- Test Tximmstop before starting TX when IFS = backoff = 0. Cleaned write_bckoff ports.
--
-- Revision 1.8  2005/02/22 13:26:46  Dr.A
-- #BugId:1086#
-- Delayed context switch if TX is about to start.
--
-- Revision 1.7  2005/02/18 16:16:14  Dr.A
-- #BugId:1065#
-- Immediate TX if txenable is set less than txstartdel us before end of complete SIFS period.
--
-- Revision 1.6  2005/02/02 17:55:02  Dr.A
-- #BugId:979,980,1009#
-- Backoff reenabled by SW write access (979)
-- All backoff counters aligned on txstartdel when one counts the last slot (980)
-- Backoff interrupt generated only when context is selected (1009)
--
-- Revision 1.5  2005/01/21 15:38:29  Dr.A
-- #BugId:978#
-- Backoff stopped when immediate stop is set
--
-- Revision 1.4  2005/01/20 14:45:16  Dr.A
-- #BugId:964#
-- Counter sizes increased in backoff and sifs counters.
--
-- Revision 1.3  2005/01/10 13:13:58  Dr.A
-- #BugId:912,931,637,941#
-- Removed enable_bup (bug 912)
-- New output to indicate when txstartdel must be removed from SIFS (bug 931)
-- Backenable LOW now freezes backoff instead of cancelling it (bug 941)
-- Backoff re-written with counters incrementing instead of decrementing to allow max value update during count (bug 637)
--
-- Revision 1.2  2004/12/20 12:50:32  Dr.A
-- #BugId:702#
-- Added ACK time-out mechanism.
--
-- Revision 1.1  2003/11/19 16:26:56  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------
-- Taken from revision 1.8 of backoff :
--
-- Revision 1.8  2003/11/13 18:38:18  Dr.F
-- go to wait_state when reg_vcs = 1.
--
-- Revision 1.7  2003/09/10 07:08:35  Dr.F
-- debuged txstartdelay.
--
-- Revision 1.6  2003/06/27 15:12:57  Dr.F
-- reordered libraries declaration.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_arith.ALL; 
use ieee.std_logic_unsigned.all;

--library bup2_timers_rtl; 
library work;
--use bup2_timers_rtl.bup2_timers_pkg.all;
use work.bup2_timers_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity backoff2 is
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

end backoff2;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of backoff2 is

  --------------------------------------------
  -- Types
  --------------------------------------------
  type BACKOFF_SM_TYPE is (idle_state,    -- Backoff idle, wait for end of SIFS
                           ifs_state,     -- Counts reg_ifs MAC slots after SIFS
                           backoff_state, -- Counts reg_backoff MAC slots
                           wait_state);   -- TX, RX or VCS: wait for BuP idle.
  
  --------------------------------------------
  -- Constants
  --------------------------------------------
  constant MAX_BACKOFF_CT : std_logic_vector(9 downto 0) := (others => '1');
  
  
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- backoff state machine
  signal backoff_sm        : BACKOFF_SM_TYPE; -- current state
  signal next_backoff_sm   : BACKOFF_SM_TYPE; -- next state
  
  -- MACSlot counter
  signal macslot_counter       : std_logic_vector(7 downto 0);
  signal next_macslot_counter  : std_logic_vector(7 downto 0);
  signal macslot_it            : std_logic; -- it

  -- IFS counter
  signal ifs_counter           : std_logic_vector(3 downto 0);
  signal next_ifs_counter      : std_logic_vector(3 downto 0);
  signal ifs_it                : std_logic; -- it
  
  -- Backoff counter
  signal backoff_counter       : std_logic_vector(9 downto 0);
  signal next_backoff_counter  : std_logic_vector(9 downto 0);
  signal backoff_it            : std_logic; -- interrupt on backoff end
  signal next_backoff_timer_end: std_logic; -- interrupt on backoff end
  signal backoff_ready         : std_logic; -- backoff counter enable
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- Indicate to the BuP SIFS timer that TX is ready to start at the end of the
  -- SIFS period, with no backoff and no IFS programmed: txstartdel must be
  -- removed from SIFS counter.
  tx_without_backoff <= '1' when (tx_enable = '1'
                                 and backoff_sm = idle_state and next_backoff_sm = idle_state
                                 and reg_backoff = 0 and reg_ifs = 0)
                   else '0';
  
  --------------------------------------------
  -- MACSlot counter
  --------------------------------------------
  -- combinational
  macslot_counter_comb_p : process (backoff_sm, enable_1mhz, macslot_counter,
                                    reg_macslot, tximmstop_sm)
  begin
    -- the counter is updated every microsecond when counting
    if (enable_1mhz = '1') and (tximmstop_sm = '0') and
       (backoff_sm /= idle_state) and (backoff_sm /= wait_state) then
      -- the counter is reinitialized to reg_macslot when it reaches 0
      if (macslot_counter = 0) then
        next_macslot_counter <= reg_macslot;
      else
        next_macslot_counter <= macslot_counter - '1';
      end if;
    else
      next_macslot_counter <= macslot_counter;
    end if;
  end process macslot_counter_comb_p;
  
  -- sequential
  macslot_counter_p : process (pclk, reset_n)
  begin
    if reset_n = '0' then
      macslot_counter  <= (others => '0');
    elsif pclk'event and pclk = '1' then
      if (backoff_sm = idle_state) then
        -- When the backoff is in idle, the MACSlot
        -- counter is initialized to reg_macslot.
        macslot_counter <= reg_macslot;
      else
        macslot_counter <= next_macslot_counter;
      end if;
    end if;
  end process macslot_counter_p;

  -- A MACSlot interrupt is generated when it reaches 0 or
  -- or when it reaches txstartdel if it is the last MACSlot
  macslot_it <= '1' when (enable_1mhz = '1') and
                         ((macslot_counter = 0) or
                          ((macslot_counter <= ext(txstartdel, macslot_counter'high)) and 
                           (global_last_slot = '1'))) else '0';

  --------------------------------------------
  -- IFS counter : increment IFS counter on 
  -- macslot Interrupt.
  --------------------------------------------
  -- combinational part
  ifs_counter_comb_p : process (backoff_sm, ifs_counter, macslot_it)
  begin
    if (backoff_sm = ifs_state) and (macslot_it = '1') then
      -- IFS counter is incremented in IFS state, on MACSlot interrupt.
      next_ifs_counter <= ifs_counter + 1;
    else
      next_ifs_counter <= ifs_counter;
    end if;
  end process ifs_counter_comb_p;
  
  -- sequencial part
  ifs_counter_p : process (pclk, reset_n)
  begin
    if reset_n = '0' then
      ifs_counter  <= (others => '0');
    elsif pclk'event and pclk = '1' then
      if (backoff_sm = idle_state) then
        -- initialized to 0 when not counting
        ifs_counter <= (others => '0');
      else
        ifs_counter <= next_ifs_counter;
      end if;
    end if;
  end process ifs_counter_p;

  -- An IFS interrupt is generated when ifs counter reaches reg_ifs.
  ifs_it <= '1' when (macslot_it = '1') and
                     (next_ifs_counter >= reg_ifs) and (backoff_sm = ifs_state)
            else '0';

  --------------------------------------------
  -- Backoff state machine
  --------------------------------------------
  -- combinational part
  backoff_sm_comb_p : process (ackto_timer_on, backoff_it, backoff_ready,
                               backoff_sm, bup_sm_idle, cca_busy,
                               context_change, global_backoff_it, ifs_it,
                               reg_backoff, reg_ifs, reg_vcs, sifs_end,
                               tx_enable, tximmstop_sm)
  begin
    next_backoff_timer_end <= '0';
    
    case backoff_sm is
      when idle_state =>
        if (backoff_ready = '1') and (tximmstop_sm = '0') then
        
          -- wait for end of SIFS period, idle carrier sense and end of ACK
          -- time-out.
          if (sifs_end = '1') and (bup_sm_idle = '1') and (global_backoff_it = '0') and
             (reg_vcs = '0') and (cca_busy = '0') and (ackto_timer_on = '0') then


            if (reg_ifs = 0) then           -- No MACSlot in the IFS
              if (reg_backoff = 0) then     -- No MACSlot in the Backoff
                -- Transmission is delayed if the context is about to swicth.
                if (tx_enable = '1') and (context_change = '0') then
                  next_backoff_sm        <= wait_state;
                  next_backoff_timer_end <= '1';        -- Start transmission.
                else                        -- Stay in idle.
                  next_backoff_sm        <= idle_state;
                end if;
              else                          -- Count backoff.
                next_backoff_sm <= backoff_state;
              end if;
            else                            -- Count IFS.
              next_backoff_sm <= ifs_state;
            end if;
          else                              -- BuP busy.
            next_backoff_sm <= idle_state;
          end if;
        else                              -- Backoff must be programmed again after TX.
          next_backoff_sm <= idle_state;
        end if;

      -- IFS period
      when ifs_state =>
        -- Stop backoff if CCA busy or VCS is received, or another backoff timer
        -- has elapsed, or ACK timer is counting.
        if (cca_busy = '1') or (reg_vcs = '1') or (ackto_timer_on = '1')
           or (global_backoff_it = '1') then  
          next_backoff_sm <= wait_state;
        
        -- End of IFS
        elsif (ifs_it = '1') then

          if (reg_backoff = 0) then       -- No MACSlot in the Backoff
            -- Transmission is delayed if the context is about to swicth.
            if (tx_enable = '1') and (context_change = '0') then
              next_backoff_sm        <= wait_state;
              next_backoff_timer_end <= '1';    -- Start transmission.
            else                          -- Stay in ifs_state.
              next_backoff_sm        <= ifs_state;
            end if;
          else                            -- Start backoff
            next_backoff_sm <= backoff_state;  
          end if;

        -- Wait for end of IFS
        else                                                   
          next_backoff_sm <= ifs_state;                    
        end if;                                                

      -- backoff period
      when backoff_state =>
        -- Stop backoff if CCA busy or VCS is received, or another backoff timer
        -- has elapsed, or ACK timer is counting.
        if (cca_busy = '1') or (reg_vcs = '1') or (ackto_timer_on = '1')
           or (global_backoff_it = '1') then  
          next_backoff_sm <= wait_state;
        
        -- End of backoff.
        elsif (backoff_it = '1') then
          -- Transmission is delayed if the context is about to swicth.
          if (tx_enable = '1') and (context_change = '0') then
            next_backoff_sm        <= wait_state;
            next_backoff_timer_end <= '1';
          else 
            next_backoff_sm        <= backoff_state;
          end if;

        -- Wait for end of backoff.
        else
          next_backoff_sm <= backoff_state;
        end if;
        
      when wait_state =>
        -- The BuP is going to be busy. Wait for beginning of BuP busy before
        -- going back to idle to wait for SIFS end.
        if (bup_sm_idle = '0') then
          next_backoff_sm  <= idle_state;
        else
          next_backoff_sm  <= wait_state;
        end if;
           
      when others =>
        next_backoff_sm  <= idle_state;

    end case;
    
  end process backoff_sm_comb_p;

  -- sequencial part
  backoff_sm_p : process (pclk, reset_n)
  begin
    if (reset_n = '0') then
      backoff_sm <= idle_state;
    elsif pclk'event and pclk = '1' then
      backoff_sm <= next_backoff_sm;
    end if;
  end process backoff_sm_p;


  -- Backoff control signals
  -- This process registers next_backoff_timer_end (pulse at end of backoff period)
  -- and set a flag when the MACslot counter is counting the last slot before TX.
  backoff_end_p : process (pclk, reset_n)
  begin
    if reset_n = '0' then
      backoff_timer_end        <= '0';
      last_slot                <= '0';

    elsif pclk'event and pclk = '1' then
      -- Flag indicating when backoff timer is finished
      backoff_timer_end <= next_backoff_timer_end;

      -- Detect last slot
      case backoff_sm is
        when idle_state | wait_state =>
          last_slot <= '0';
          
        when ifs_state =>
          -- Test is done on reg_ifs in case it is written by software after entering ifs_state
          if (reg_backoff = 0) and (tx_enable = '1')               -- There will be no backoff
              and ((next_ifs_counter >= reg_ifs-1) or (reg_ifs = 0)) then -- Last IFS MAC slot
            last_slot <= '1';
          else -- Reset flag if software update of reg_backoff or reg_ifs.
            last_slot <= '0';
          end if;
          
        when backoff_state =>
          -- Test is done on reg_backoff in case it is written by software after entering
          -- backoff_state.
          if (backenable = '1') and (tx_enable = '1') -- Ready to transmit after backoff
             and ((next_backoff_counter >= reg_backoff-1) or (reg_backoff = 0)) then
            last_slot <= '1';
          else -- Reset flag if software update of reg_backoff.
            last_slot <= '0';
          end if;

        when others =>
      end case;
      
    end if;
  end process backoff_end_p;
  
  --------------------------------------------
  -- Backoff counter
  --------------------------------------------
  -- combinational part
  backoff_counter_comb_p : process (backenable, backoff_counter, backoff_sm,
                                    macslot_it)
  begin
    -- the backoff counter is incremented on MACSlot interrupt when in backoff state.
    if (macslot_it = '1') and (backoff_sm = backoff_state) 
       and (backoff_counter < MAX_BACKOFF_CT)  -- No wrap
       and (backenable = '1') then             -- backenable freezes the counter when '0'.            
      next_backoff_counter <= backoff_counter + 1;
    else
      next_backoff_counter <= backoff_counter;
    end if;
  end process backoff_counter_comb_p;
                 
  -- sequencial part
  backoff_counter_p : process (pclk, reset_n)
  begin
    if reset_n = '0' then
      backoff_it               <= '0';
      backoff_counter          <= (others => '0');

    elsif pclk'event and pclk = '1' then
      
      -- Update the backoff counter
      if (write_backoff = '1') and 
         ( (backoff_sm = idle_state) or (backoff_sm = wait_state) ) then
        backoff_counter <= (others => '0');
      else
        backoff_counter <= next_backoff_counter;
      end if;  

      -- Backoff interrupt when backoff period is elapsed. Use >= to end count if software
      -- updates reg_backoff with a value smaller than already elapsed backoff.
      if (next_backoff_counter >= reg_backoff) and (backoff_sm = backoff_state) and
         (macslot_it = '1') then
        backoff_it <= '1';
      else
        backoff_it <= '0';
      end if;
      
    end if;
  end process backoff_counter_p;
  
  
  -- backoff timer current value
  backoff_read_p: process (pclk, reset_n)
  begin
    if reset_n = '0' then
      backoff_timer <= (others => '0');
    elsif pclk'event and pclk = '1' then
      if (backoff_counter >= reg_backoff) then
        backoff_timer <= (others => '0');
      else
        backoff_timer <= reg_backoff - backoff_counter;
      end if;
    end if;
  end process backoff_read_p;


  -- Set backoff_ready flag once the backoff has been programmed.
  -- Reset it when the queue is discarded, or when it transmits.
  backoff_ready_p: process (pclk, reset_n)
  begin
    if reset_n = '0' then
      backoff_ready <= '0';
    elsif pclk'event and pclk = '1' then
      if (write_backoff = '1') then
        backoff_ready <= '1';
      elsif (next_backoff_timer_end = '1') then
        -- Backoff disabled from TX to next write in the register.
        backoff_ready <= '0';
      end if;
    end if;
  end process backoff_ready_p;


end RTL;
