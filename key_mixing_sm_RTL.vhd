
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Stream_Processing
--    ,' GoodLuck ,'      RCSfile: key_mixing_sm.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : State machine for the TKIP key mixing block.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/tkip_key_mixing/vhdl/rtl/key_mixing_sm.vhd,v  
--  Log: key_mixing_sm.vhd,v  
-- Revision 1.2  2003/08/28 14:34:55  Dr.A
-- Added register for key_mix_done.
--
-- Revision 1.1  2003/07/16 13:24:38  Dr.A
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
 
--library tkip_key_mixing_rtl;
library work;
--use tkip_key_mixing_rtl.tkip_key_mixing_pkg.all;
use work.tkip_key_mixing_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity key_mixing_sm is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic;
    clk            : in  std_logic;

    --------------------------------------
    -- Controls
    --------------------------------------
    key1_key2n     : in  std_logic; -- High during phase 1, low during phase 2.
    start_keymix   : in  std_logic; -- Pulse to start the key mixing phase.
    --
    keymix1_done   : out std_logic; -- High when key mixing phase 1 is done.
    keymix2_done   : out std_logic; -- High when key mixing phase 2 is done.
    loop_cnt       : out std_logic_vector(2 downto 0); -- Loop counter.
    state_cnt      : out std_logic_vector(2 downto 0); -- State counter for P1.
    in_even_state  : out std_logic; -- Indicates the FSM is in even state.

    --------------------------------------
    -- S-Box interface
    --------------------------------------
    sbox_addr1     : in  std_logic_vector(15 downto 0); -- Sbox address for P1.
    sbox_addr2     : in  std_logic_vector(15 downto 0); -- Sbox address for P2.
    --
    sbox_data      : out std_logic_vector(15 downto 0);

    --------------------------------------
    -- Data
    --------------------------------------
    address2       : in  std_logic_vector(47 downto 0); -- A2 MAC header field.
    tsc            : in  std_logic_vector(47 downto 0); -- Sequence counter.
    -- Values to update internal registers.
    next_keymix1_reg_w  : in std_logic_vector(15 downto 0); -- from P1.
    next_keymix2_reg_w  : in std_logic_vector(15 downto 0); -- from P2.
    -- Registers out.
    keymix_reg_w5  : out std_logic_vector(15 downto 0);
    keymix_reg_w4  : out std_logic_vector(15 downto 0);
    keymix_reg_w3  : out std_logic_vector(15 downto 0);
    keymix_reg_w2  : out std_logic_vector(15 downto 0);
    keymix_reg_w1  : out std_logic_vector(15 downto 0);
    keymix_reg_w0  : out std_logic_vector(15 downto 0)
  );

end key_mixing_sm;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of key_mixing_sm is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  -- The state machine has a binary structure: two states are repeated (4 times
  -- each during phase 1, 1 time each during phase 2).
  type KEYMIX_STATE_TYPE is (idle_state,
                             even_state,
                             odd_state);

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Constants used to determine the length of a state. It corresponds to the
  -- number of 16bit words that are updated one after the other: 5 four the 80
  -- bit TTAK during phase 1, and six for the PPK used in phase 2.
  constant MAX_LOOP1_CT : std_logic_vector(2 downto 0) := "100";
  constant MAX_LOOP2_CT : std_logic_vector(2 downto 0) := "101";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- State and next state in the key mixing satte machine.
  signal keymix_state      : KEYMIX_STATE_TYPE;
  signal next_keymix_state : KEYMIX_STATE_TYPE;
  -- Internal values of state counters.
  signal int_state_cnt     : std_logic_vector(2 downto 0); -- State counter.
  signal int_loop_cnt      : std_logic_vector(2 downto 0); -- Loop counter.
  signal loop_cnt_max      : std_logic_vector(2 downto 0); -- loop_cnt max value
  -- Internal values for key mixing registers (TTAK in p1, PPK in P2)
  signal int_keymix_reg_w5 : std_logic_vector(15 downto 0);
  signal int_keymix_reg_w4 : std_logic_vector(15 downto 0);
  signal int_keymix_reg_w3 : std_logic_vector(15 downto 0);
  signal int_keymix_reg_w2 : std_logic_vector(15 downto 0);
  signal int_keymix_reg_w1 : std_logic_vector(15 downto 0);
  signal int_keymix_reg_w0 : std_logic_vector(15 downto 0);
  -- Initial values for int_keymix_reg_wX signals.
  signal keymix_init_w5    : std_logic_vector(15 downto 0);
  signal keymix_init_w4    : std_logic_vector(15 downto 0);
  signal keymix_init_w3    : std_logic_vector(15 downto 0);
  signal keymix_init_w2    : std_logic_vector(15 downto 0);
  signal keymix_init_w1    : std_logic_vector(15 downto 0);
  signal keymix_init_w0    : std_logic_vector(15 downto 0);
  -- Value used to update the int_keymix_reg_wX signals.
  signal next_keymix_reg_w : std_logic_vector(15 downto 0);
  -- Address of the S-box.
  signal sbox_addr         : std_logic_vector(15 downto 0);
  signal fsm_idle          : std_logic; -- High when the state machine is idle.
  signal keymix_done       : std_logic; -- High when key mixing phase is done.

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  
  --------------------------------------------
  -- Muxes for signals taking different values in phase 1 and phase 2.
  --------------------------------------------
    
  -- Loop counter max value.
  with key1_key2n select
    loop_cnt_max <= 
      MAX_LOOP1_CT when '1',
      MAX_LOOP2_CT when others;

  -- Direct correct address to the S-Box.
  with key1_key2n select
    sbox_addr <= 
      sbox_addr1 when '1',
      sbox_addr2 when others;

  -- Direct correct update value to the registers.
  with key1_key2n select
    next_keymix_reg_w <= 
      next_keymix1_reg_w when '1',
      next_keymix2_reg_w when others;

  -- Internal register init value.
  init_pr: process(address2, int_keymix_reg_w0, int_keymix_reg_w1,
                   int_keymix_reg_w2, int_keymix_reg_w3, int_keymix_reg_w4,
                   key1_key2n, tsc)
  begin
    case key1_key2n is
      
      when '1' =>    -- Init with address2 field and TKIP sequence counter.
        keymix_init_w5 <= (others => '0');
        keymix_init_w4 <= address2(47 downto 32);
        keymix_init_w3 <= address2(31 downto 16);
        keymix_init_w2 <= address2(15 downto  0);
        keymix_init_w1 <= tsc(47 downto 32);
        keymix_init_w0 <= tsc(31 downto  16);
        
      when others => -- Phase 2 input is phase 1 output (TTAK)
        keymix_init_w5 <= int_keymix_reg_w4 + tsc(15 downto 0);
        keymix_init_w4 <= int_keymix_reg_w4;
        keymix_init_w3 <= int_keymix_reg_w3;
        keymix_init_w2 <= int_keymix_reg_w2;
        keymix_init_w1 <= int_keymix_reg_w1;
        keymix_init_w0 <= int_keymix_reg_w0;
        
    end case;
  end process init_pr;
      
  --------------------------------------------
  -- Key mixing State Machine
  --------------------------------------------
  -- Combinational process.
  fsm_comb_pr: process(int_loop_cnt, int_state_cnt, keymix_state, loop_cnt_max,
                       start_keymix)
  begin
    case keymix_state is
      
      -- Start key mixing on start_keymix.
      when idle_state =>
        if start_keymix = '1' then 
          next_keymix_state <= even_state;
        else
          next_keymix_state <= idle_state;
        end if;
        
      -- Alternate odd and even states.
      when even_state =>
        if int_loop_cnt = loop_cnt_max then
          next_keymix_state <= odd_state;
        else
          next_keymix_state <= even_state;
        end if;
      
      -- The key mixing phase 1 takes 8 steps to complete. During phase 2
      -- int_state_cnt is set to 7.
      when odd_state =>
        if int_loop_cnt = loop_cnt_max then        
          if int_state_cnt = 7 then   -- All steps gone through.
            next_keymix_state <= idle_state;
          else                    -- Alternate odd and even states.
            next_keymix_state <= even_state;
          end if;
        else
          next_keymix_state <= odd_state;
        end if;
        
    end case;
    
  end process fsm_comb_pr;
  
  -- Sequential process.
  fsm_seq_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      keymix_state <= idle_state;
    elsif clk'event and clk = '1' then
      keymix_state <= next_keymix_state;
    end if;
  end process fsm_seq_pr;
  
  
  -- Counter for the state machine. Counts up to 8 even/odd actions.
  cnt_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      int_state_cnt <= (others => '0');
    elsif clk'event and clk = '1' then
      if key1_key2n = '0' then
        int_state_cnt <= (others => '1');      -- Not used during Phase 2.
      else
        if keymix_state = idle_state then      -- Reset counter at idle state.
          int_state_cnt <= (others => '0');
        elsif int_loop_cnt = loop_cnt_max then -- wait for end of state loop.
          int_state_cnt <= int_state_cnt + 1;
        end if;
      end if;
    end if;
  end process cnt_pr;
  
  -- Counter for the state machine. Counts up to the number of 16bits words
  -- to update during ecah state.
  loop_cnt_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      int_loop_cnt <= (others => '0');
    elsif clk'event and clk = '1' then
      if (keymix_state /= next_keymix_state)      -- Reset when changing state,
              or (keymix_state = idle_state) then -- or during idle state.
        int_loop_cnt <= (others => '0');
      else
        int_loop_cnt <= int_loop_cnt + 1;
      end if;
    end if;
  end process loop_cnt_pr;


  
  --------------------------------------------
  -- Data processing.
  --------------------------------------------

  -- This process loads init values in key mixing registers, and updates them
  -- in turn each clock cycle of the key mixing.
  load_ttak_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      int_keymix_reg_w5 <= (others => '0');
      int_keymix_reg_w4 <= (others => '0');
      int_keymix_reg_w3 <= (others => '0');
      int_keymix_reg_w2 <= (others => '0');
      int_keymix_reg_w1 <= (others => '0');
      int_keymix_reg_w0 <= (others => '0');
      
    elsif clk'event and clk = '1' then
      
      if start_keymix = '1' then -- Load init values.
        int_keymix_reg_w5 <= keymix_init_w5;
        int_keymix_reg_w4 <= keymix_init_w4;
        int_keymix_reg_w3 <= keymix_init_w3;
        int_keymix_reg_w2 <= keymix_init_w2;
        int_keymix_reg_w1 <= keymix_init_w1;
        int_keymix_reg_w0 <= keymix_init_w0;
        
      elsif keymix_state /= idle_state then -- Update with next values.
        case int_loop_cnt is
          when "000" =>
            int_keymix_reg_w0 <= next_keymix_reg_w;
          when "001" =>
            int_keymix_reg_w1 <= next_keymix_reg_w;
          when "010" =>
            int_keymix_reg_w2 <= next_keymix_reg_w;
          when "011" =>
            int_keymix_reg_w3 <= next_keymix_reg_w;
          when "100" =>
            int_keymix_reg_w4 <= next_keymix_reg_w;
          when "101" =>
            int_keymix_reg_w5 <= next_keymix_reg_w;
          when others =>
            null;
        end case;
      end if;
    end if;
  end process load_ttak_pr;

  -- Assign output ports.
  keymix_reg_w5 <= int_keymix_reg_w5;
  keymix_reg_w4 <= int_keymix_reg_w4;
  keymix_reg_w3 <= int_keymix_reg_w3;
  keymix_reg_w2 <= int_keymix_reg_w2;
  keymix_reg_w1 <= int_keymix_reg_w1;
  keymix_reg_w0 <= int_keymix_reg_w0;
  loop_cnt      <= int_loop_cnt;
  state_cnt     <= int_state_cnt;
  -- Decode state machine.
  in_even_state <= '1' when keymix_state = even_state else '0';

  -- Generate signal when state machine is idle.
  done_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      fsm_idle <= '1';
    elsif clk'event and clk = '1' then
      if next_keymix_state = idle_state then
        fsm_idle <= '1';
      else
        fsm_idle <= '0';
      end if;
    end if;
  end process done_pr;

  keymix_done <= fsm_idle and not(start_keymix);
  -- Assign the keymix_done signal to the correct output.
  keymix1_done <= keymix_done when key1_key2n = '1' else '1';
  keymix2_done <= keymix_done when key1_key2n = '0' else '1';

  
  --------------------------------------------
  -- Port map of Key mixing S-Box.
  --------------------------------------------
  key_mixing_sbox_0 : key_mixing_sbox
    port map (
      sbox_addr    => sbox_addr,
      sbox_data    => sbox_data
      );

end RTL;
