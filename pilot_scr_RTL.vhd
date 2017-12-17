
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: pilot_scr.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block scrambles '1' for pilot carriers.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/pilot_scr/vhdl/rtl/pilot_scr.vhd,v  
--  Log: pilot_scr.vhd,v  
-- Revision 1.2  2004/12/14 10:56:29  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.1  2003/03/13 15:02:26  Dr.A
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
-- Entity
--------------------------------------------------------------------------------
entity pilot_scr is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n           : in std_logic; -- asynchronous reset.
    clk               : in std_logic; -- Module clock.
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i          : in  std_logic; -- TX path enable.
    pilot_ready_i     : in  std_logic;
    init_pilot_scr_i  : in  std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    pilot_scr_o       : out std_logic  -- Data for the 4 pilot carriers.
    
  );

end pilot_scr;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of pilot_scr is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for the pseudo-noise generator
  signal next_pn_shift   : std_logic_vector(6 downto 0); -- Register next value.
  signal pn_shift        : std_logic_vector(6 downto 0); -- Shift register.
  signal pilot_ready_ff  : std_logic; -- Store pilot_ready_i for edge detection.
  signal pilot_scrambled : std_logic; -- Shift register input value.


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  pilot_scrambled <= pn_shift(6) xor pn_shift(3);
  -- Pilot scrambler input data is always '1'.
  pilot_scr_o     <= not(pilot_scrambled);
  
  -- Data shift.
  shift_comb_p : process (init_pilot_scr_i, pilot_ready_ff, pilot_ready_i,
                          pilot_scrambled, pn_shift)
  begin
    -- On init_pilot_scr_i, init the shift register with all '1'.
    if init_pilot_scr_i = '1' then
      next_pn_shift <= (others => '1');
    -- Shift on pilot_ready_i rise
    elsif (pilot_ready_i = '1' and pilot_ready_ff = '0') then
      next_pn_shift <= pn_shift(5 downto 0) & pilot_scrambled;
    else -- Keep value.
      next_pn_shift <= pn_shift;
    end if;
  end process shift_comb_p;

  -- Registers.
  seq_pr : process (clk, reset_n)
  begin
    if reset_n = '0' then
      pn_shift       <= (others => '1');
      pilot_ready_ff <= '0';
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        pn_shift       <= (others => '1');
        pilot_ready_ff <= '0';
      else
        pn_shift       <= next_pn_shift;
        pilot_ready_ff <= pilot_ready_i;
      end if;
    end if;
  end process seq_pr;

end RTL;
