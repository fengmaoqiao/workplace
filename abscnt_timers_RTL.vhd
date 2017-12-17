
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_MII
--    ,' GoodLuck ,'      RCSfile: abscnt_timers.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Set of absolute count timers generating an interrupt when they
--               reach the BuP timer value.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_timers/vhdl/rtl/abscnt_timers.vhd,v  
--  Log: abscnt_timers.vhd,v  
-- Revision 1.1  2005/10/21 13:26:32  Dr.A
-- #BugId:1246#
-- Added absolute count timers
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity abscnt_timers is
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

end abscnt_timers;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of abscnt_timers is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type ARRAY_SLV26 is array (natural range <>) of std_logic_vector(25 downto 0);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal absolute_count     : std_logic_vector(num_abstimer_g-1 downto 0);
  signal absolute_count_ff1 : std_logic_vector(num_abstimer_g-1 downto 0);
  signal abstime_arr        : ARRAY_SLV26(15 downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  ------------------------------------------------------------------------------
  -- inputs and outputs
  ------------------------------------------------------------------------------
  abstime_arr(0 ) <= abstime0; 
  abstime_arr(1 ) <= abstime1; 
  abstime_arr(2 ) <= abstime2; 
  abstime_arr(3 ) <= abstime3; 
  abstime_arr(4 ) <= abstime4; 
  abstime_arr(5 ) <= abstime5; 
  abstime_arr(6 ) <= abstime6; 
  abstime_arr(7 ) <= abstime7; 
  abstime_arr(8 ) <= abstime8; 
  abstime_arr(9 ) <= abstime9; 
  abstime_arr(10) <= abstime10;
  abstime_arr(11) <= abstime11;
  abstime_arr(12) <= abstime12;
  abstime_arr(13) <= abstime13;
  abstime_arr(14) <= abstime14;
  abstime_arr(15) <= abstime15;

  ------------------------------------------------------------------------------
  -- Absolute counters.
  ------------------------------------------------------------------------------
  abscnt_gen: for i in 0 to num_abstimer_g-1 generate

    -- Comparator to detect when the BuP timer reaches the absolute counter
    -- time tag.
    absolute_count(i) <= '1' when (bup_timer = abstime_arr(i) and mode32k = '0')
      else '1' when (bup_timer(25 downto 5) = abstime_arr(i)(25 downto 5) and mode32k = '1')
      else '0';

    -- Delay absolute_count to generate a pulse of one pclk clock-cycle.
    abscount_it_p: process (clk, reset_n)
    begin
      if (reset_n = '0') then
        absolute_count_ff1(i) <= '0';
      elsif clk'event and clk = '1' then
        absolute_count_ff1(i) <= absolute_count(i);
      end if;
    end process abscount_it_p;
    abscount_it(i) <= absolute_count(i) and not absolute_count_ff1(i);

  end generate abscnt_gen;

end RTL;
