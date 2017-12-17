
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: state2byte.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block serialises the state (4 words) in groups of 8 bits
--               to calculate the CRC.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/rc4_crc/vhdl/rtl/state2byte.vhd,v  
--  Log: state2byte.vhd,v  
-- Revision 1.6  2003/12/04 09:29:12  Dr.A
-- Register for s2bdone_early.
--
-- Revision 1.5  2003/08/28 15:00:52  Dr.A
-- Added done_early output.
--
-- Revision 1.4  2003/07/03 14:09:25  Dr.A
-- Removed internal registers.
--
-- Revision 1.3  2002/11/26 10:54:33  elama
-- Solved bug in Output_byte process.
--
-- Revision 1.2  2002/11/21 16:31:22  elama
-- Removed a negative clock.
--
-- Revision 1.1  2002/10/15 13:19:27  elama
-- Initial revision
--
--
--------------------------------------------------------------------------------
-- Revision 1.3  2002/10/14 13:26:21  elama
-- Added the "size" port and modified the structure
-- of the block accordingly.
--
-- Revision 1.2  2002/09/16 14:18:09  elama
-- Added the wait_cycle input line.
--
-- Revision 1.1  2002/07/30 09:51:13  elama
-- Initial revision
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 

entity state2byte is
  port (
    -- Clocks and resets:
    clk         : in  std_logic;        -- AHB clock.
    reset_n     : in  std_logic;        -- AHB reset. Inverted logic.
    -- Flags:
    start_s2b   : in  std_logic;        -- Positive edge starts the state2byte.
    s2b_done    : out std_logic;        -- Flag indicating state2byte finished.
    s2b_done_early: out std_logic;      -- Flag set two cycles before s2b_done.
    -- Size:
    size        : in  std_logic_vector(3 downto 0);-- Number of bytes to
                                        -- serialize ("0001" -> 1 byte      )
                                        --           ("0010" -> 2 bytes     ?)
    -- Input state:                     --           ("0000" -> all 16 bytes)
    state_word0 : in  std_logic_vector(31 downto 0);-- First state word.
    state_word1 : in  std_logic_vector(31 downto 0);-- Second state word.
    state_word2 : in  std_logic_vector(31 downto 0);-- Third state word.
    state_word3 : in  std_logic_vector(31 downto 0);-- Fourth state word.
    -- Wait:
    wait_cycle  : in  std_logic;        -- Wait line.
    -- Output byte.
    byte_to_crc : out std_logic_vector( 7 downto 0)-- Output byte.
  );
end state2byte;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of state2byte is

--------------------------------------------------------------- Type declaration
type S2B_STATE_TYPE is (idle_state,       -- Idle phase
                        byte0_state,      -- First serialised byte.
                        byte1_state,
                        byte2_state,
                        byte3_state,
                        byte4_state,
                        byte5_state,
                        byte6_state,
                        byte7_state,
                        byte8_state,
                        byte9_state,
                        byte10_state,
                        byte11_state,
                        byte12_state,
                        byte13_state,
                        byte14_state,
                        byte15_state);    -- Last serialised byte.
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------- Signal declaration
signal s2b_state       : S2B_STATE_TYPE;-- state in the s2b state machine.
signal next_s2b_state  : S2B_STATE_TYPE;-- next state in the s2b state machine.
signal s2b_done_early_int : std_logic;  -- s2b_done_early before register.
signal s2b_done_int    : std_logic;     -- s2b_done before register.
------------------------------------------------------ End of Signal declaration

begin

  ----------------------------------------------------- State2byte State Machine
  -- This is the state machine that serialises the 4 input words into bytes.
  -- It consists on 16 states (+Idle) each of them sends out one of the bytes.
  s2b_sm: process (s2b_state, start_s2b, wait_cycle, size)
  begin
    case s2b_state is
      when idle_state =>
        if (start_s2b = '1' and wait_cycle = '0') then-- The process starts.
          next_s2b_state <= byte0_state;
        else
          next_s2b_state <= idle_state;
        end if;

      when byte0_state =>
        if wait_cycle = '0' then
          if size = "0001" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte1_state;
          end if;
        else
          next_s2b_state <= byte0_state;
        end if;

      when byte1_state =>
        if wait_cycle = '0' then
          if size = "0010" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte2_state;
          end if;
        else
          next_s2b_state <= byte1_state;
        end if;

      when byte2_state =>
        if wait_cycle = '0' then
          if size = "0011" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte3_state;
          end if;
        else
          next_s2b_state <= byte2_state;
        end if;

      when byte3_state =>
        if wait_cycle = '0' then
          if size = "0100" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte4_state;
          end if;
        else
          next_s2b_state <= byte3_state;
        end if;

      when byte4_state =>
        if wait_cycle = '0' then
          if size = "0101" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte5_state;
          end if;
        else
          next_s2b_state <= byte4_state;
        end if;

      when byte5_state =>
        if wait_cycle = '0' then
          if size = "0110" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte6_state;
          end if;
        else
          next_s2b_state <= byte5_state;
        end if;

      when byte6_state =>
        if wait_cycle = '0' then
          if size = "0111" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte7_state;
          end if;
        else
          next_s2b_state <= byte6_state;
        end if;

      when byte7_state =>
        if wait_cycle = '0' then
          if size = "1000" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte8_state;
          end if;
        else
          next_s2b_state <= byte7_state;
        end if;

      when byte8_state =>
        if wait_cycle = '0' then
          if size = "1001" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte9_state;
          end if;
        else
          next_s2b_state <= byte8_state;
        end if;

      when byte9_state =>
        if wait_cycle = '0' then
          if size = "1010" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte10_state;
          end if;
        else
          next_s2b_state <= byte9_state;
        end if;

      when byte10_state =>
        if wait_cycle = '0' then
          if size = "1011" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte11_state;
          end if;
        else
          next_s2b_state <= byte10_state;
        end if;

      when byte11_state =>
        if wait_cycle = '0' then
          if size = "1100" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte12_state;
          end if;
        else
          next_s2b_state <= byte11_state;
        end if;

      when byte12_state =>
        if wait_cycle = '0' then
          if size = "1101" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte13_state;
          end if;
        else
          next_s2b_state <= byte12_state;
        end if;

      when byte13_state =>
        if wait_cycle = '0' then
          if size = "1110" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte14_state;
          end if;
        else
          next_s2b_state <= byte13_state;
        end if;

      when byte14_state =>
        if wait_cycle = '0' then
          if size = "1111" then
            next_s2b_state <= idle_state;
          else
            next_s2b_state <= byte15_state;
          end if;
        else
          next_s2b_state <= byte14_state;
        end if;

      when byte15_state =>
        if wait_cycle = '0' then
          next_s2b_state <= idle_state;
        else
          next_s2b_state <= byte15_state;
        end if;

      when others =>
        next_s2b_state <= idle_state;
    end case;
  end process s2b_sm;

  s2b_sm_clk: process (reset_n, clk)
  begin
    if reset_n = '0' then
      s2b_state <= idle_state;          -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      s2b_state <= next_s2b_state;      -- Update the CRC State Machine.
    end if;
  end process s2b_sm_clk;
  ---------------------------------------------- End of State2byte State Machine

  ------------------------------------------------------- Output byte Generation
  -- This process selects the byte to be sent to the ouput from the state input.
  ouput_byte_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      byte_to_crc <= (others => '0');
    elsif (clk'event and clk = '1') then
      case next_s2b_state is
        when byte0_state =>
          byte_to_crc <= state_word0 ( 7 downto  0);

        when byte1_state =>
          byte_to_crc <= state_word0 (15 downto  8);

        when byte2_state =>
          byte_to_crc <= state_word0 (23 downto 16);

        when byte3_state =>
          byte_to_crc <= state_word0 (31 downto 24);

        when byte4_state =>
          byte_to_crc <= state_word1 ( 7 downto  0);

        when byte5_state =>
          byte_to_crc <= state_word1 (15 downto  8);

        when byte6_state =>
          byte_to_crc <= state_word1 (23 downto 16);

        when byte7_state =>
          byte_to_crc <= state_word1 (31 downto 24);

        when byte8_state =>
          byte_to_crc <= state_word2 ( 7 downto  0);

        when byte9_state =>
          byte_to_crc <= state_word2 (15 downto  8);

        when byte10_state =>
          byte_to_crc <= state_word2 (23 downto 16);

        when byte11_state =>
          byte_to_crc <= state_word2 (31 downto 24);

        when byte12_state =>
          byte_to_crc <= state_word3 ( 7 downto  0);

        when byte13_state =>
          byte_to_crc <= state_word3 (15 downto  8);

        when byte14_state =>
          byte_to_crc <= state_word3 (23 downto 16);

        when byte15_state=>
          byte_to_crc <= state_word3 (31 downto 24);

        when others =>
          null;
      end case;
    end if;
  end process ouput_byte_pr;
  ------------------------------------------------ End of Output byte Generation

  ---------------------------------------------------------- crc_done Generation
  -- This process creates the signal 's2b_done' which indicates that
  -- the process is finished.
  s2b_done <= '1' when next_s2b_state = idle_state
         else '0';

  -- The s2b_done_early flag must be set two clock cycles before s2b_done.
  -- It can be used only when a 16 bytes state is processed and no wait states.
  done_early_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      s2b_done_early_int <= '1';
    elsif clk'event and clk = '1' then
      if (next_s2b_state = idle_state or next_s2b_state = byte15_state
     or next_s2b_state = byte14_state or next_s2b_state = byte13_state) then
        s2b_done_early_int <= '1';
      else
        s2b_done_early_int <= '0';
      end if;
    end if;
  end process done_early_p;
  s2b_done_early <= s2b_done_early_int and not start_s2b;
  --------------------------------------------------- End of crc_done Generation

end RTL;
