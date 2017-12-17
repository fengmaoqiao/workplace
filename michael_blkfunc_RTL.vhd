--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: michael_blkfunc.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Block function for TKIP Michael message processing.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/rc4_crc/vhdl/rtl/michael_blkfunc.vhd,v  
--  Log: michael_blkfunc.vhd,v  
-- Revision 1.2  2003/08/28 14:39:00  Dr.A
-- Reworked the state machine to suppress idle_state. MIC block function lasts now only four clock cycles.
--
-- Revision 1.1  2003/07/03 14:13:18  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity michael_blkfunc is
  port (
    -- Clocks and resets
    clk           : in  std_logic; -- AHB clock.
    reset_n       : in  std_logic; -- AHB reset. Inverted logic.
    -- Controls
    start_michael : in  std_logic; -- Pos edge starts Michael block function.
    michael_done  : out std_logic; -- Flag indicating function finished.
    -- Data words
    l_michael_in  : in  std_logic_vector(31 downto 0);
    r_michael_in  : in  std_logic_vector(31 downto 0);
    --
    l_michael_out : out std_logic_vector(31 downto 0);
    r_michael_out : out std_logic_vector(31 downto 0)
  );

end michael_blkfunc;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of michael_blkfunc is

--------------------------------------------------------------- Type declaration
type MICHAEL_STATE_TYPE is (blk0_state,  -- Block function step 0.
                            blk1_state,  -- Block function step 1.
                            blk2_state,  -- Block function step 2.
                            blk3_state); -- Block function step 3.
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------- Signal declaration
signal mic_state        : MICHAEL_STATE_TYPE; -- State and next state in the
signal next_mic_state   : MICHAEL_STATE_TYPE; --       Michael state machine.
signal l_rotated        : std_logic_vector(31 downto 0); -- l_michael_in rotated
signal next_l           : std_logic_vector(31 downto 0); -- Comb. L value.
signal next_r           : std_logic_vector(31 downto 0); -- Comb. R value.
signal l_michael_int    : std_logic_vector(31 downto 0); -- Internal reg L value
signal r_michael_int    : std_logic_vector(31 downto 0); -- Internal reg R value
-- Intermediate values for *_michael_int computation.
signal l_michael_next   : std_logic_vector(31 downto 0);
signal r_michael_next   : std_logic_vector(31 downto 0);
signal michael_done_int : std_logic; -- Internal michael_done flag.
------------------------------------------------------ End of Signal declaration


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin


  -------------------------------------------------------- Michael state machine
  -- Michael state machine combinational process
  fsm_comp_pr: process (mic_state, start_michael)
  begin

    -- Default value: stay in current state.
    next_mic_state <= mic_state;

    case mic_state is
      
      --  A pulse on start_michael starts the state machine.
      when blk0_state =>
        if start_michael = '1' then
          next_mic_state <= blk1_state;
        end if;
        
      -- Then each state in one-clock-cycle long.
      when blk1_state =>
        next_mic_state <= blk2_state;
        
      when blk2_state =>
        next_mic_state <= blk3_state;
        
      when blk3_state =>
        next_mic_state <= blk0_state;
        
    end case;
  end process fsm_comp_pr;
  
  -- Michael state machine Sequential process
  fsm_seq_pr: process(clk, reset_n)
  begin
    if reset_n = '0' then
      mic_state <= blk0_state;
    elsif clk'event and clk = '1' then
      mic_state <= next_mic_state;
    end if;
  end process fsm_seq_pr;
  ------------------------------------------------- End of Michael state machine
  
  -------------------------------------------------------------- Michael L shift
  -- The Michael processing in done on the internal registers *_michael_int
  -- except in blk0_state, where these registers are not yet updated. Use the
  -- input ports *_michael_in instead.
  with mic_state select
  l_rotated <=
    -- blk1: l_rotated <= XSWAP(l_michael_int)
    l_michael_int(23 downto 16) & l_michael_int(31 downto 24)
  & l_michael_int( 7 downto  0) & l_michael_int(15 downto  8) when blk1_state,
    -- blk2: l_rotated <= l_michael_int <<< 3
    l_michael_int(28 downto  0) & l_michael_int(31 downto 29) when blk2_state,
    -- blk3: l_rotated <= l_michael_int >>> 2
    l_michael_int( 1 downto  0) & l_michael_int(31 downto  2) when blk3_state,
    -- blk0: l_rotated <= l_michael_in <<< 17
    l_michael_in(14 downto  0) & l_michael_in(31 downto 15) when others;
  ------------------------------------------------------- End of Michael L shift
    
  ---------------------------------------------- Michael internal L and R values
  -- The Michael processing in done on the internal registers *_michael_int
  -- except in blk0_state, where these registers are not yet updated. Use the
  -- input ports *_michael_in instead.
  l_michael_next <= l_michael_in when start_michael = '1' else l_michael_int;
  r_michael_next <= r_michael_in when start_michael = '1' else r_michael_int;
  
  next_r <= r_michael_next xor l_rotated;
  next_l <= l_michael_next + next_r; -- Adder is modulo 32 bits.
    
  -- Registers for internal Michael L and R values.
  mic_reg_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      l_michael_int <= (others => '0');
      r_michael_int <= (others => '0');
    elsif clk'event and clk = '1' then
      -- Update the registers when the state machine is running.
      if (mic_state /= blk0_state) or (start_michael = '1') then
        l_michael_int <= next_l;
        r_michael_int <= next_r;
      end if;
    end if;
  end process mic_reg_pr;
  --------------------------------------- End of Michael internal L and R values
  
  ----------------------------------------------------------------- Output ports
  -- Assign output ports.
  l_michael_out <= l_michael_int;
  r_michael_out <= r_michael_int;
  
  -- michael_done is asserted one clock-cycle BEFORE the data is correct on 
  -- *_michael_out ports. This allows for immediate restart of the state machine
  -- in the rc4_control block.
  done_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      michael_done_int <= '1';
    elsif clk'event and clk = '1' then
      if next_mic_state = blk1_state then
        michael_done_int <= '0';
      elsif mic_state = blk2_state then
        michael_done_int <= '1';
      end if;
    end if;
  end process done_pr;

  michael_done <= michael_done_int and not (start_michael);
  
  ---------------------------------------------------------- End of Output ports

end RTL;
