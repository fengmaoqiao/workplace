
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: aes_sm.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block contains the state machine of the AES Cryptographic
--              Processor.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/aes_blockcipher/vhdl/rtl/aes_sm.vhd,v  
--  Log: aes_sm.vhd,v  
-- Revision 1.2  2003/11/14 18:08:36  Dr.A
-- Removed unused sram_data port.
--
-- Revision 1.1  2003/09/01 16:35:26  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--
-- Log history:
--
-- Source: Good
-- Log: aes_sm.vhd,v
-- Revision 1.2  2003/09/01 16:14:48  Dr.A
-- Added ciph_done_early.
--
-- Revision 1.1  2003/08/28 15:19:57  Dr.A
-- Initial revision
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

--library aes_blockcipher_rtl; 
library work;
--use aes_blockcipher_rtl.aes_blockcipher_pkg.ALL; 
use work.aes_blockcipher_pkg.ALL; 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity aes_sm is
  generic (
    ccm_mode_g      : integer := 0   -- 1 to use the AES cipher in CCM mode.
  );
  port (
    -- Clocks and resets
    clk             : in  std_logic; -- AHB clock.
    reset_n         : in  std_logic; -- AHB reset. Inverted logic.
    -- Control lines
    opmode          : in  std_logic; -- Indicates Rx (0) or Tx (1) mode.
    aes_ksize       : in  std_logic_vector( 5 downto 0);-- Key size in bytes.
    start_expand    : in  std_logic; -- Pulse to start Key Schedule.
    start_cipher    : in  std_logic; -- Pulse to encrypt/decrypt one state.
    expand_done     : in  std_logic; -- Indicates key Schedule done.
    --
    cipher_done     : out std_logic; -- Indicates encryption/decryption done.
    ciph_done_early : out std_logic; -- Flag set 2 cycles before cipher_done.
    number_rounds   : out std_logic_vector(4 downto 0); -- Number of AES rounds.
    round           : out std_logic_vector(4 downto 0); -- Current round number.
    decoded_state   : out std_logic_vector(3 downto 0); -- AES FSM state.
    next_dec_state  : out std_logic_vector(3 downto 0); -- AES next FSM state.
    -- Interrupt
    stopop          : in  std_logic; -- Stops the encryption/decryption.
    -- Encryption state
    state_w0        : in  std_logic_vector(31 downto 0);
    state_w1        : in  std_logic_vector(31 downto 0);
    state_w2        : in  std_logic_vector(31 downto 0);
    state_w3        : in  std_logic_vector(31 downto 0);
    -- Decryption state
    invstate_w0     : in  std_logic_vector(31 downto 0);
    invstate_w1     : in  std_logic_vector(31 downto 0);
    invstate_w2     : in  std_logic_vector(31 downto 0);
    invstate_w3     : in  std_logic_vector(31 downto 0);
    -- Result (Encrypted/decrypted state)
    result_w0       : out std_logic_vector(31 downto 0);
    result_w1       : out std_logic_vector(31 downto 0);
    result_w2       : out std_logic_vector(31 downto 0);
    result_w3       : out std_logic_vector(31 downto 0);
    -- SRAM controls from KeySchedule block
    wr_memo_address : in  std_logic_vector( 3 downto 0); -- Address to save key.
    wr_memo_wen     : in  std_logic; -- Write enable.
    -- AES SRAM interface
    sram_address    : out std_logic_vector(  3 downto 0); -- Address.
    sram_wen        : out std_logic; -- Write Enable. Inverted logic.
    sram_cen        : out std_logic  -- Chip Enable. Inverted logic.
    );
end aes_sm;


--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of aes_sm is

--------------------------------------------------------------- Type declaration
type aesbc_state_type is (idle_state,      -- Idle phase
                        readcycle_state,   -- Reads the first key expansion.
                        keyschedule_state, -- Key Expansion phase.
                        addroundkey_state, -- State Storage phase.
                        statesub0_state,   -- SubByte for State(0).
                        statesub1_state,   -- SubByte for State(1).
                        statesub2_state,   -- SubByte for State(2).
                        statesub3_state,   -- SubByte for State(3).
                        calculate_state);  -- Calculation phase.
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------ Signals declaration
signal aesbc_state       : aesbc_state_type; -- State in the main state machine.
signal next_aesbc_state  : aesbc_state_type; -- Next state in the state machine.
signal int_number_rounds : std_logic_vector(4 downto 0);-- Number of AES rounds.
signal int_round         : std_logic_vector(4 downto 0);-- Current round number.
signal rd_memo_address   : std_logic_vector(3 downto 0);-- Address to read key.
signal int_ciph_early    : std_logic; -- Internal cip_done_early register.
----------------------------------------------------- End of Signals declaration

begin
  
  ---------------------------------------------------------- Assign output ports
  number_rounds <= int_number_rounds;
  round         <= int_round;
  
  -- Decode aesbc_state to use it in others blocks.
  with aesbc_state select
    decoded_state <=
      IDLE_ST_CT when idle_state,     
      READ_ST_CT when readcycle_state,  
      KEY_ST_CT  when keyschedule_state,
      ADD_ST_CT  when addroundkey_state,
      SUB0_ST_CT when statesub0_state,  
      SUB1_ST_CT when statesub1_state,  
      SUB2_ST_CT when statesub2_state,  
      SUB3_ST_CT when statesub3_state,  
      CALC_ST_CT when others; 
  
  -- Decode next_aesbc_state to use it in others blocks.
  with next_aesbc_state select
    next_dec_state <=
      IDLE_ST_CT when idle_state,     
      READ_ST_CT when readcycle_state,  
      KEY_ST_CT  when keyschedule_state,
      ADD_ST_CT  when addroundkey_state,
      SUB0_ST_CT when statesub0_state,  
      SUB1_ST_CT when statesub1_state,  
      SUB2_ST_CT when statesub2_state,  
      SUB3_ST_CT when statesub3_state,  
      CALC_ST_CT when others; 
  --------------------------------------------------- End of assign output ports
  
  ----------------------------------------------------------- Main State Machine
  -- This is the main State Machine of the AES processor. It first generates
  -- the key expansion (KeySchedule_State) if necessary. Then it does all the
  -- calculations necessary to get the encrypted/decrypted state
  -- (AddRoundKey_State, StateSubX_State and Calculation_state).
  main_pr: process (aesbc_state, start_expand, start_cipher,
                    expand_done, int_round, int_number_rounds, stopop)
  begin
    if stopop = '1' then
      next_aesbc_state <= idle_state;
    else
      case aesbc_state is
        when idle_state =>
          if start_expand = '1' then      -- Start key Expansion.
            next_aesbc_state <= keyschedule_state;
          elsif start_cipher = '1' then   -- Start encryption/decryption.
            next_aesbc_state <= readcycle_state;
          else
            next_aesbc_state <= idle_state;
          end if;

        when keyschedule_state =>
          if expand_done = '1' then       -- Key Expansion finished.
            if start_cipher = '1' then    -- Start encoding/decoding
              next_aesbc_state <= readcycle_state;
            else                          -- Back to Idle.
              next_aesbc_state <= idle_state;
            end if;
          else                            -- Key Expansion not yet finished.
            next_aesbc_state <= keyschedule_state;
          end if;

        when readcycle_state =>
          next_aesbc_state <= addroundkey_state;

        when addroundkey_state =>
          if int_round < int_number_rounds then   -- Stay in the loop.
            next_aesbc_state <= statesub0_state;
          else                            -- Rounds finished => Store result.
            next_aesbc_state <= idle_state;
          end if;

        when statesub0_state =>           -- SubByte transformation for word0.
          next_aesbc_state <= statesub1_state;

        when statesub1_state =>           -- SubByte transformation for word1.
          next_aesbc_state <= statesub2_state;

        when statesub2_state =>           -- SubByte transformation for word2.
          next_aesbc_state <= statesub3_state;

        when statesub3_state =>           -- All SubByte transformations done.
          next_aesbc_state <= calculate_state;

        when calculate_state =>
          next_aesbc_state <= addroundkey_state;

        when others =>
          next_aesbc_state <= idle_state;
      end case;
    end if;
  end process main_pr;
  
  main_seq_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      aesbc_state <= idle_state;        -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      aesbc_state <= next_aesbc_state;  -- Update the State Machine.
    end if;
  end process main_seq_pr;
  ---------------------------------------------------- End of Main State Machine

  ---------------------------------------------------------------- Nr Calculator
  -- This process calculates the number of rounds necessary for the
  -- Key Schedule algorithm.
  -- Nk = aes_ksize [5..2] = 4 => Nr = number_rounds = 10
  -- Nk = aes_ksize [5..2] = 6 => Nr = number_rounds = 12
  -- Nk = aes_ksize [5..2] = 8 => Nr = number_rounds = 14
  no_ccm_rnd_gen: if ccm_mode_g = 0 generate
    int_number_rounds <= ("0" & aes_ksize (5 downto 2)) + "00110";
  end generate no_ccm_rnd_gen;
  -- In CCM mode the key size is always 16 bytes.
  ccm_rnd_gen: if ccm_mode_g = 1 generate
    int_number_rounds <= "01010";
  end generate ccm_rnd_gen;
  --------------------------------------------------------- End of Nr Calculator

  -------------------------------------------------------------- Round Generator
  -- This process generates the signal 'round' which indicates on which round
  -- in the algorithm the state machine is.
  round_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      int_round <= (others => '0');
    elsif (clk'event and clk = '1') then
      case aesbc_state is
        when idle_state =>
          int_round <= (others => '0');

        when calculate_state =>
          int_round <= int_round + 1;

        when others =>
          null;
      end case;
    end if;
  end process round_pr;
  ------------------------------------------------------- End of Round Generator

  ------------------------------------------------------------ SRAM Read Address
  -- This process creates the address to fetch the key in the SRAM.
  -- On encryption, it is initialised to 0 and incremented every time a new
  -- data is read.
  -- On decryption, it is initialised to 15 and decremented every time a new
  -- data is read.
  incr_memo_addr_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      rd_memo_address <= (others => '0');
    elsif (clk'event and clk = '1') then
      case next_aesbc_state is
        when idle_state | keyschedule_state | readcycle_state =>
          if opmode = '1' then          -- Encryption.
            rd_memo_address <= (others => '0');
          else                          -- Decryption.
            rd_memo_address <= int_number_rounds (3 downto 0);
          end if;
        when calculate_state =>
          if  opmode = '1' then         -- Encryption.
            rd_memo_address <= rd_memo_address + "0001";-- rd_memo_address + 1
          else                          -- Decryption.
            rd_memo_address <= rd_memo_address + "1111";-- rd_memo_address - 1
          end if;
        when others =>
          null;
      end case;
    end if;
  end process incr_memo_addr_pr;
  ----------------------------------------------------- End of SRAM Read Address

  ----------------------------------------------------------------- Result lines
  -- The words to be written will be those in state_wX for encryption and those
  -- in invstate_wX for decryption.
  no_ccm_res_gen: if ccm_mode_g = 0 generate
    result_w0 <= state_w0 when opmode = '1' else invstate_w0;
    result_w1 <= state_w1 when opmode = '1' else invstate_w1;
    result_w2 <= state_w2 when opmode = '1' else invstate_w2;
    result_w3 <= state_w3 when opmode = '1' else invstate_w3;
  end generate no_ccm_res_gen;

  -- In CCM mode, the AES cipher is always used in encryption mode.
  ccm_res_gen: if ccm_mode_g = 1 generate
    result_w0 <= state_w0;
    result_w1 <= state_w1;
    result_w2 <= state_w2;
    result_w3 <= state_w3;
  end generate ccm_res_gen;
  ---------------------------------------------------------- End of Result lines

  --------------------------------------------------------------- SRAM Selection
  -- The SRAM is used by the AES_KeySchedule subblock to load all the values
  -- of the expanded key (write cycles). The rest of the time, only read cycles
  -- will be performed by the AES_BlockCipher.
  sram_address <= wr_memo_address when aesbc_state = keyschedule_state
             else rd_memo_address;

  sram_wen <= wr_memo_wen when aesbc_state = keyschedule_state
        else '1';

  sram_cen <= '1' when (aesbc_state = idle_state and
                        next_aesbc_state = idle_state)
         else '0';
  -------------------------------------------------------- End of SRAM Selection

  -------------------------------------------------- cipher_done flag generation
  -- The flag cipher_done is set to '1' when the rounds have finished.
  cipher_done <= '1' when (next_aesbc_state = idle_state and
                                aesbc_state = idle_state)
            else '0';

  
  -- ciph_done_early is asserted two clock cycles before the end of the AES
  -- cipher. It will be used in the aes_control block to request AHB access
  -- before write data is available.
  done_early_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      int_ciph_early <= '1';
    elsif clk'event and clk = '1' then
      if ( (aesbc_state = statesub3_state)
           and (int_round = (int_number_rounds - 1)) ) then
        int_ciph_early <= '1';
      elsif (aesbc_state = idle_state and next_aesbc_state /= idle_state) then
        int_ciph_early <= '0';
      end if;
    end if;
  end process done_early_pr;
  
  ciph_done_early <= int_ciph_early and not(start_cipher);

  ------------------------------------------- End of cipher_done flag generation

end RTL;
