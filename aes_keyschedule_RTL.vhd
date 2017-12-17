--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processor
--    ,' GoodLuck ,'      RCSfile: aes_keyschedule.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block performs the Key Expansion in the
--               AES encryption algorithm.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/aes_blockcipher/vhdl/rtl/aes_keyschedule.vhd,v  
--  Log: aes_keyschedule.vhd,v  
-- Revision 1.1  2003/09/01 16:35:18  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--
-- Log history:
--
-- Source: Good
-- Log: aes_keyschedule.vhd,v
-- Revision 1.2  2003/07/16 13:37:42  Dr.A
-- Updated key size.
--
-- Revision 1.1  2003/07/03 14:01:25  Dr.A
-- Initial revision
--
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity aes_keyschedule is
  port (
    -- Clocks and resets
    clk          : in  std_logic;       -- System clock.
    reset_n      : in  std_logic;       -- System reset. Inverted logic.
    -- Flags:
    key_load4    : in  std_logic;       -- Signal to save the first 4 key bytes.
    key_load8    : in  std_logic;       -- Signal to save the last 4 key bytes.
    start_expand : in  std_logic;       -- Signal that starts the key expansion.
    expand_done  : out std_logic;       -- Flag indicating expansion done.
    -- Registers:
    aes_ksize    : in  std_logic_vector(5 downto 0);-- Size of key in bytes (Nk)
    -- Interruption:
    stopop       : in  std_logic;       -- Stops the keyschedule.
    -- Initial Key values:
    init_key_w0  : in  std_logic_vector(31 downto 0);-- Initial key word no.0.
    init_key_w1  : in  std_logic_vector(31 downto 0);-- Initial key word no.1.
    init_key_w2  : in  std_logic_vector(31 downto 0);-- Initial key word no.2.
    init_key_w3  : in  std_logic_vector(31 downto 0);-- Initial key word no.3.
    init_key_w4  : in  std_logic_vector(31 downto 0);-- Initial key word no.4.
    init_key_w5  : in  std_logic_vector(31 downto 0);-- Initial key word no.5.
    init_key_w6  : in  std_logic_vector(31 downto 0);-- Initial key word no.6.
    init_key_w7  : in  std_logic_vector(31 downto 0);-- Initial key word no.7.
    -- Key Storage Memory:
    memo_wrdata  : out std_logic_vector(127 downto 0);-- KeyWord to save in memo
    memo_address : out std_logic_vector( 3 downto 0);-- Address to save KeyWord.
    memo_wen     : out std_logic;       -- Memo Write Enable line. Inverted log.
    -- AES_SubByte block:
    subword      : in  std_logic_vector(31 downto 0);-- Result word.
    keyword      : out std_logic_vector(31 downto 0) -- Input word to SubBlock.
  );
end aes_keyschedule;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of aes_keyschedule is

--------------------------------------------------------------- Type declaration
type KEY_STATE_TYPE is (idle_state,     -- Idle phase
                        store0_state,   -- Stores the encrypted data in the SRAM
                        store1_state,   -- Stores the encrypted data in the SRAM
                        keysub0_state,  -- First SubByte for Key word.
                        keysub1_state); -- Second SubByte for Key word.

type KEYSCHED_TYPE  is array (16 downto 0)
                    of std_logic_vector (31 downto 0); -- Array of 16 words.
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------- Signal declaration
-- State Machine:
signal key_state     : KEY_STATE_TYPE;  -- State in the keyschedule state mach.
signal next_key_state: KEY_STATE_TYPE;  -- Next state in the keyschedule SM.
-- Key:
signal rcon_counter : std_logic_vector( 3 downto 0);-- Rcon counter.
signal rcon         : std_logic_vector( 7 downto 0);-- Last element in Rcon.
signal number_rounds: std_logic_vector( 7 downto 0);-- Number of rounds in AES.
signal round        : std_logic_vector( 7 downto 0);-- Current round number.
signal rotword      : std_logic_vector(31 downto 0);-- Rotword.
-- Internal Key Storage:
signal key_record0  : std_logic_vector(31 downto 0);-- First Stored Key Word.
signal key_record1  : std_logic_vector(31 downto 0);-- Second Stored Key Word.
signal key_record2  : std_logic_vector(31 downto 0);-- Third Stored Key Word.
signal key_record3  : std_logic_vector(31 downto 0);-- Fourth Stored Key Word.
signal key_record4  : std_logic_vector(31 downto 0);-- Fifth Stored Key Word.
signal key_record5  : std_logic_vector(31 downto 0);-- Sixth Stored Key Word.
signal key_record6  : std_logic_vector(31 downto 0);-- Seventh Stored Key Word.
signal key_record7  : std_logic_vector(31 downto 0);-- Eigth Stored Key Word.
signal newkey_0     : std_logic_vector(31 downto 0);-- 1st Combinational Key W.
signal newkey_1     : std_logic_vector(31 downto 0);-- 2nd Combinational Key W.
signal newkey_2     : std_logic_vector(31 downto 0);-- 3rd Combinational Key W.
signal newkey_3     : std_logic_vector(31 downto 0);-- 4th Combinational Key W.
signal newkey_4     : std_logic_vector(31 downto 0);-- 5th Combinational Key W.
signal newkey_5     : std_logic_vector(31 downto 0);-- 6th Combinational Key W.
signal newkey_6     : std_logic_vector(31 downto 0);-- 7th Combinational Key W.
signal newkey_7     : std_logic_vector(31 downto 0);-- 8th Combinational Key W.
signal old_key4     : std_logic_vector(31 downto 0);-- Old Key number 4.
signal old_key5     : std_logic_vector(31 downto 0);-- Old Key number 5.
-- Data Storage (SRAM):
signal int_memo_address:std_logic_vector(3 downto 0);--Internal memo_address.
signal save1n2      : std_logic;        -- Indicates if we need to save the data
                                        -- once (1) or twice (0) (for Nk = 6).
------------------------------------------------------ End of Signal declaration

begin

  ----------------------------------------------------------- Main State Machine
  -- This is the main State Machine in the AES Key Schedule. It is composed of
  -- five states: idle, store0, store1, keysub0 and keysub1. Storedata saves the
  -- generated keyExpansion words into the SRAM. Keysub0 generates the first
  -- four or six new key words. If Nk=8, the SM goes to keysub1 where the
  -- last four key words are calculated.
  main_pr: process (key_state, start_expand, aes_ksize, round, number_rounds,
                    save1n2, stopop)
  begin
    if stopop = '1' then
      next_key_state <= idle_state;
    else
      case key_state is
        when idle_state =>
          if start_expand = '1' then      -- Start Key Schedule.
            next_key_state <= store0_state;
          else
            next_key_state <= idle_state;
          end if;

        when store0_state =>
          if aes_ksize (5 downto 2) = "1000" or   -- Nk = 8.
            (aes_ksize (5 downto 2) = "0110" and save1n2 = '0') then-- Nk = 6 and
            next_key_state <= store1_state;                         -- save twice.
          else                            -- Save data only once.
            if round = number_rounds then -- Whole buffer encrypted.
              next_key_state <= idle_state;
            else                          -- Calculate more Key Expansion words.
              next_key_state <= keysub0_state;
            end if;
          end if;

        when store1_state =>
          if round = number_rounds then   -- Whole buffer encrypted.
            next_key_state <= idle_state;
          else                            -- Calculate more Key Expansion words.
            next_key_state <= keysub0_state;
          end if;

        when keysub0_state =>
          if aes_ksize (5 downto 2) = "1000" then-- Nk = 8. Calculate last 4 words
            next_key_state <= keysub1_state;
          else                            -- Store the calculated words.
            next_key_state <= store0_state;
          end if;

        when keysub1_state =>             -- 8 words calculated. Store them in RAM
          next_key_state <= store0_state;

        when others =>
          next_key_state <= idle_state;
      end case;
    end if;
  end process main_pr;
  
  main_seq_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      key_state <= idle_state;          -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      key_state <= next_key_state;      -- Update the State Machine.
    end if;
  end process main_seq_pr;
  ---------------------------------------------------- End of Main State Machine

  ---------------------------------------------------------------- Nr Calculator
  -- This process calculates the number of KeyStates necessary for the
  -- Key Schedule algorithm.
  -- Nk = aes_ksize [5..2] = 4 => number of key words = 10*4
  --                           => numer of rounds = 10*4/4 = 10
  -- Nk = aes_ksize [5..2] = 6 => number of key words = 12*4
  --                           => numer of rounds = 12*4/6 = 8
  -- Nk = aes_ksize [5..2] = 8 => number of key words = 14*4/8 = 7
  number_rounds <= "00000111" when aes_ksize (5 downto 2) = "1000"
              else "00001000" when aes_ksize (5 downto 2) = "0110"
              else "00001010";
  --------------------------------------------------------- End of Nr Calculator

  -------------------------------------------------------------- Round Generator
  -- This process generates the signal 'round' which indicates on which round
  -- in the algorithm the state machine is.
  round_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      round <= (others => '0');
    elsif (clk'event and clk = '1') then
      case key_state is
        when idle_state =>
          round <= (others => '0');

        when store0_state =>
          if next_key_state /= store1_state then
            round <= round + "00000001";
          end if;

        when store1_state =>
          round <= round + "00000001";

        when others =>
          null;
      end case;
    end if;
  end process round_pr;
  ------------------------------------------------------- End of Round Generator

  ------------------------------------------------------------- Rcon Calculation
  -- This process calculates the Rcon vector. The last element in the vector is
  -- x^[(i/Nk)-1]. This can be simplified knowing that Rcon is only needed
  -- when (i mod Nk = 0). This means the last element can be initialised to 0
  -- and incremented in one unit everytime Nk elements are generated, that is
  -- every time the state machine goes through state keysub0_state.
  -- the signal 'rcon' only contains the last element in the Rcon vector,
  -- knowing that the other elements are zero.
  rcon_counter_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      rcon_counter <= (others => '0');
    elsif (clk'event and clk = '1') then
      case next_key_state is
        when idle_state =>
          rcon_counter <= (others => '0');
        when store0_state =>             -- Increment the counter except in the
          if key_state /= idle_state then-- first round (key_state=idle_state).
            rcon_counter <= rcon_counter + "0001";
          end if;
        when others =>
          null;
      end case;
    end if;
  end process rcon_counter_pr;

  rcon_vector_pr: process (rcon_counter)
  begin
    case rcon_counter is
      when "0000" =>
        rcon <= "00000001"; -- 01
      when "0001" =>
        rcon <= "00000010"; -- Shift(01) = 02
      when "0010" =>
        rcon <= "00000100"; -- Shift(02) = 04
      when "0011" =>
        rcon <= "00001000"; -- Shift(04) = 08
      when "0100" =>
        rcon <= "00010000"; -- Shift(08) = 10
      when "0101" =>
        rcon <= "00100000"; -- Shift(10) = 20
      when "0110" =>
        rcon <= "01000000"; -- Shift(20) = 40
      when "0111" =>
        rcon <= "10000000"; -- Shift(40) = 80
      when "1000" =>
        rcon <= "00011011"; -- Shift(80) = 100 => overflow => 00 + 1B = 1B
      when "1001" =>
        rcon <= "00110110"; -- Shift(1B) = 36
      when "1010" =>
        rcon <= "01101100"; -- Shift(36) = 6C
      when "1011" =>
        rcon <= "11011000"; -- Shift(6C) = D8
      when "1100" =>
        rcon <= "11011011"; -- Shift(D8) = 1B0 => overflow => B0 + 1B = DB
      when others =>
        rcon <= "10101101"; -- Shift(DB) = 1B6 => overflow => B6 + 1B = AD
    end case;
  end process rcon_vector_pr;
  ------------------------------------------------------ End of Rcon Calculation

  ------------------------------------------------------------------ Key Loading
  -- This process reloads the key words on every new round. Key_record0 through
  -- Key_record3 (or key_record5 if Nk=6) are calculated on state keysub0.
  -- The rest (key_record4 through key_record7) are calculated on state keysub1.
  newkey_0 <= key_record0 xor subword xor
                        ("000000000000000000000000" & rcon);
  newkey_1 <= key_record1 xor newkey_0;
  newkey_2 <= key_record2 xor newkey_1;
  newkey_3 <= key_record3 xor newkey_2;
  newkey_4 <= key_record4 xor newkey_3 when aes_ksize (4 downto 2) = "110"
         else key_record4 xor subword;  -- newkey_3 when Nk = 6 else subword
  newkey_5 <= key_record5 xor newkey_4;
  newkey_6 <= key_record6 xor newkey_5;
  newkey_7 <= key_record7 xor newkey_6;

  first_keyloading_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      key_record0 <= (others => '0');   -- Reset Init_key_W0.
      key_record1 <= (others => '0');
      key_record2 <= (others => '0');
      key_record3 <= (others => '0');
      key_record4 <= (others => '0');
      key_record5 <= (others => '0');
      key_record6 <= (others => '0');
      key_record7 <= (others => '0');
    elsif (clk'event and clk = '1') then
      case key_state is
        when idle_state =>              -- Values on initialisation.
          if key_load4 = '1' then
            key_record0 <= init_key_w0;
            key_record1 <= init_key_w1;
            key_record2 <= init_key_w2;
            key_record3 <= init_key_w3;
          elsif key_load8 = '1' then
            key_record4 <= init_key_w4;
            key_record5 <= init_key_w5;
            key_record6 <= init_key_w6;
            key_record7 <= init_key_w7;
          end if;

        when keysub0_state =>           -- Calculate first 4 or 6 key words.
          key_record0 <= newkey_0;
          key_record1 <= newkey_1;
          key_record2 <= newkey_2;
          key_record3 <= newkey_3;
          if aes_ksize (4 downto 2) = "110" then
            key_record4 <= newkey_4;
            key_record5 <= newkey_5;
          end if;

        when keysub1_state =>           -- Calculate last 4 key words.
          key_record4 <= newkey_4;
          key_record5 <= newkey_5;
          key_record6 <= newkey_6;
          key_record7 <= newkey_7;

        when others =>
          null;
      end case;
    end if;
  end process first_keyloading_pr;
  ----------------------------------------------------------- End of Key Loading

  ----------------------------------------------- Block SubByte Selector decoder
  -- This process decodes the state in the main state machine to select which
  -- word is connected to the SubByte and InvSubByte blocks.
  rotword <= key_record7 when aes_ksize (5 downto 2) = "1000" -- Nk = 8.
        else key_record5 when aes_ksize (5 downto 2) = "0110" -- Nk = 6.
        else key_record3;

  keyword <= key_record3 when (key_state = keysub1_state)
        else (rotword ( 7 downto  0) &
              rotword (31 downto 24) &
              rotword (23 downto 16) &
              rotword (15 downto  8));
  ---------------------------------------- End of SubByte Block Selector decoder

--============================================================================--
--          The following processes write the key words in the SRAM           --
--============================================================================--

  ------------------------------------------------------- Write Enable Generator
  -- This process generates the memo_wen signal which enables to write data in
  -- the SRAM. This line will be active on states Store0 and Store1.
  memo_wen <= '0' when key_state = store0_state or
                      key_state = store1_state
         else '1';
  ------------------------------------------------ End of Write Enable Generator

  ------------------------------------------------------- SRAM Address Generator
  -- This process generates the address lines to be sent to the SRAM. They are
  -- initialised to 0 and incremented every time 4 key words are stored.
  increment_address_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      int_memo_address <= (others => '0');
    elsif (clk'event and clk = '1') then
      case key_state is
        when idle_state =>
          int_memo_address <= (others => '0');
        when store0_state | store1_state =>
          int_memo_address <= int_memo_address + "0001";
        when others =>
          null;
      end case;
    end if;
  end process increment_address_pr;

  memo_address <= int_memo_address;
  ------------------------------------------------ End of SRAM Address Generator

  ------------------------------------------------------------ save1n2 Generator
  -- This process generates the line save1n2 which is used when Nk = 6. This is
  -- because in this case every second time, we need to write twice in the SRAM.
  save1n2_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      save1n2 <= '1';
    elsif (clk'event and clk = '1') then
      case key_state is
        when idle_state =>
          save1n2 <= '1';
        when store0_state =>
          save1n2 <= not save1n2;
        when others =>
          null;
      end case;
    end if;
  end process save1n2_pr;
  ----------------------------------------------------- End of save1n2 Generator

  -------------------------------------------------------- SRAM WRDATA Generator
  -- This process selects the data to be written in the SRAM. It will depend
  -- on the state, on Nk and on 'save1n2'. When Nk = 6 two of the words have
  -- to be kept (old_key4 and old_key5) to be saved in the next round with
  -- the next two other key words.
  memo_wrdata <= key_record7 & key_record6 & key_record5 & key_record4 when
              (key_state = store1_state and aes_ksize (5 downto 2) /= "0110")
            else key_record5 & key_record4 & key_record3 & key_record2 when
              (key_state = store1_state and aes_ksize (5 downto 2) = "0110")
            else key_record3 & key_record2 & key_record1 & key_record0 when
             ((key_state = store0_state and aes_ksize (5 downto 2) /= "0110") or
              (key_state = store0_state and aes_ksize (5 downto 2) = "0110" and
                                                               save1n2 = '1'))
            else key_record1 & key_record0 & old_key5 & old_key4;

  old_key_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      old_key4 <= (others => '0');
      old_key5 <= (others => '0');
    elsif (clk'event and clk = '1') then
      if key_state = store0_state then
        old_key4 <= key_record4;
        old_key5 <= key_record5;
      end if;
    end if;
  end process old_key_pr;
  ------------------------------------------------- End of SRAM WRDATA Generator

  --------------------------------------------------- write_done flag generation
  -- The flag expand_done is set to '1' when the keyschedule operation has
  -- finished.
  expand_done <= '1' when (next_key_state = idle_state)
            else '0';
  -------------------------------------------- End of write_done flag generation

end RTL;
