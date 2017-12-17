
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: aes_encrypt.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block contains the encryption processing for the AES
--               Cryptographic Processor. It receives the Key and the State as
--               inputs and performs all the encrytion protocol on one state,
--               under control of the AES cipher state machine.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/aes_blockcipher/vhdl/rtl/aes_encrypt.vhd,v  
--  Log: aes_encrypt.vhd,v  
-- Revision 1.1  2003/09/01 16:35:06  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--
-- Log history:
--
-- Source: Good
-- Log: aes_encrypt.vhd,v
-- Revision 1.1  2003/08/28 15:19:49  Dr.A
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
entity aes_encrypt is
  port (
    -- Clocks and resets
    clk            : in  std_logic; -- AHB clock.
    reset_n        : in  std_logic; -- AHB reset. Inverted logic.
    -- Interface to share SubByte block with the KeySchedule block
    keyword        : in  std_logic_vector(31 downto 0); -- Word to SubByte block
    key_subbyte_rs : out std_logic_vector(31 downto 0); -- SubByte result word.
    -- Data to encrypt
    init_state_w0  : in  std_logic_vector(31 downto 0);
    init_state_w1  : in  std_logic_vector(31 downto 0);
    init_state_w2  : in  std_logic_vector(31 downto 0);
    init_state_w3  : in  std_logic_vector(31 downto 0);
    -- Result state
    state_w0       : out std_logic_vector(31 downto 0);
    state_w1       : out std_logic_vector(31 downto 0);
    state_w2       : out std_logic_vector(31 downto 0);
    state_w3       : out std_logic_vector(31 downto 0);
    -- Controls
    enable         : in  std_logic; -- Enable the encryption block.
    number_rounds  : in  std_logic_vector(4 downto 0); -- Nb of rounds in AES.
    round          : in  std_logic_vector(4 downto 0); -- Current round number.
    decoded_state  : in  std_logic_vector(3 downto 0); -- Current AES state.
    next_dec_state : in  std_logic_vector(3 downto 0); -- Next AES state.
    -- AES SRAM
    sram_rdata     : in  std_logic_vector(127 downto 0) -- Data read.
  );
end aes_encrypt;


--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of aes_encrypt is

------------------------------------------------------------- Signal declaration
-- Internal signals for the encrypted state.
signal int_state_w0   : std_logic_vector(31 downto 0);
signal int_state_w1   : std_logic_vector(31 downto 0);
signal int_state_w2   : std_logic_vector(31 downto 0);
signal int_state_w3   : std_logic_vector(31 downto 0);
-- Signals for the encrypted state before it is registered.
signal newstate_w0    : std_logic_vector(31 downto 0);
signal newstate_w1    : std_logic_vector(31 downto 0);
signal newstate_w2    : std_logic_vector(31 downto 0);
signal newstate_w3    : std_logic_vector(31 downto 0);
-- Signals to select the newstate words according to the encryption round.
signal state_sel_w0   : std_logic_vector(31 downto 0);
signal state_sel_w1   : std_logic_vector(31 downto 0);
signal state_sel_w2   : std_logic_vector(31 downto 0);
signal state_sel_w3   : std_logic_vector(31 downto 0);
-- Signals for the SubByte block.
signal subbyte_wr     : std_logic_vector(31 downto 0);-- Input word.
signal int_subbyte_rs : std_logic_vector(31 downto 0);-- Result word.
-- Registered outputs of the SubByte block.
signal subbyte_w0     : std_logic_vector(31 downto 0);
signal subbyte_w1     : std_logic_vector(31 downto 0);
signal subbyte_w2     : std_logic_vector(31 downto 0);
signal subbyte_w3     : std_logic_vector(31 downto 0);
-- Outputs of the ShiftRow block.
signal shiftrow_w0    : std_logic_vector(31 downto 0);
signal shiftrow_w1    : std_logic_vector(31 downto 0);
signal shiftrow_w2    : std_logic_vector(31 downto 0);
signal shiftrow_w3    : std_logic_vector(31 downto 0);
-- Outputs of the MixColumn block.
signal mixcolumn_w0   : std_logic_vector(31 downto 0);
signal mixcolumn_w1   : std_logic_vector(31 downto 0);
signal mixcolumn_w2   : std_logic_vector(31 downto 0);
signal mixcolumn_w3   : std_logic_vector(31 downto 0);
-- sram_rdata gated by the enable input.
signal sram_rdata_g   : std_logic_vector(127 downto 0);
------------------------------------------------------ End of Signal declaration

begin

  ---------------------------------------------------------- Assign output ports
  -- Output of SubByte block used in KeySchedule block.
  key_subbyte_rs <= int_subbyte_rs;
  -- Encrypted data.
  state_w0       <= int_state_w0;
  state_w1       <= int_state_w1;
  state_w2       <= int_state_w2;
  state_w3       <= int_state_w3;
  --------------------------------------------------- End of assign output ports

  -------------------------------------------------------------- State Generator
  -- These lines select the transformation done on the state.
  --  * If the encryption block is not enabled, state_sel_wX is set to zero.
  --  * Else, on the first round, state_sel_wX will be the initial state (input)
  --  * On the last round, state_sel_wX will come from the ShiftRows block.
  --  * On the others rounds, state_sel_wX will come from the MixColumns block.

  state_sel_w0 <= (others => '0') when enable = '0'         -- Encrypt disabled.
             else init_state_w0 when round = 0              -- First round.
             else mixcolumn_w0  when round /= number_rounds -- Not last round.
             else shiftrow_w0;                              -- Last round.
  state_sel_w1 <= (others => '0') when enable = '0'         
             else init_state_w1 when round = 0              
             else mixcolumn_w1  when round /= number_rounds 
             else shiftrow_w1;                              
  state_sel_w2 <= (others => '0') when enable = '0'
             else init_state_w2 when round = 0              
             else mixcolumn_w2  when round /= number_rounds 
             else shiftrow_w2;
  state_sel_w3 <= (others => '0') when enable = '0'
             else init_state_w3 when round = 0              
             else mixcolumn_w3  when round /= number_rounds 
             else shiftrow_w3;

  -- Gate sram data to save power during decryption.
  sram_rdata_g <= sram_rdata when enable = '1' else (others => '0');

  -- These lines produce the XOR between the selected data and the key.
  -- sram_data contains the key_schedule.
  newstate_w0 <= state_sel_w0 xor sram_rdata_g ( 31 downto  0);
  newstate_w1 <= state_sel_w1 xor sram_rdata_g ( 63 downto 32);
  newstate_w2 <= state_sel_w2 xor sram_rdata_g ( 95 downto 64);
  newstate_w3 <= state_sel_w3 xor sram_rdata_g (127 downto 96);

  -- The state is updated with the new State on every AddRoundKey State.
  state_update_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      int_state_w0 <= (others => '0');
      int_state_w1 <= (others => '0');
      int_state_w2 <= (others => '0');
      int_state_w3 <= (others => '0');
    elsif (clk'event and clk = '1') then
      if decoded_state = ADD_ST_CT then
        int_state_w0 <= newstate_w0;
        int_state_w1 <= newstate_w1;
        int_state_w2 <= newstate_w2;
        int_state_w3 <= newstate_w3;
      end if;
    end if;
  end process state_update_pr;
  ------------------------------------------------------- End of State Generator

  ------------------------------------------------------- Block SubByte Selector
  -- This process decodes the state in the main state machine to select which
  -- word is connected to the SubByte block. This block is shared between the
  -- aes_encrypt and the aes_keyschedule block.
  subbyte_wr <= keyword when decoded_state = KEY_ST_CT else
               int_state_w0 when decoded_state = SUB0_ST_CT else
               int_state_w1 when decoded_state = SUB1_ST_CT else
               int_state_w2 when decoded_state = SUB2_ST_CT else
               int_state_w3;

  -- This process registers the output of the SubByte block.
  decoder_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      subbyte_w0    <= (others => '0');
      subbyte_w1    <= (others => '0');
      subbyte_w2    <= (others => '0');
      subbyte_w3    <= (others => '0');
    elsif (clk'event and clk = '1') then
      case next_dec_state is
        when SUB1_ST_CT =>
          subbyte_w0    <= int_subbyte_rs;

        when SUB2_ST_CT =>
          subbyte_w1    <= int_subbyte_rs;

        when SUB3_ST_CT =>
          subbyte_w2    <= int_subbyte_rs;

        when CALC_ST_CT =>
          subbyte_w3    <= int_subbyte_rs;

        when others =>
          null;

      end case;
    end if;
  end process decoder_pr;
  ---------------------------------------- End of SubByte Block Selector decoder

  ---------------------------------------------------- Port map for AES_SubBytes
  aes_subbytes_1: aes_subbytes
  port map(
    word_in      => subbyte_wr,         -- Input word.                    (IN)
    word_out     => int_subbyte_rs      -- Result word.                   (OUT)
  );
  --------------------------------------------- End of Port map for AES_SubBytes

  --------------------------------------------------- Port map for AES_ShiftRows
  aes_shiftrows_1: aes_shiftrows
  port map(
    state_in_w0  => subbyte_w0,         -- Input word 0.                  (IN)
    state_in_w1  => subbyte_w1,         -- Input word 1.                  (IN)
    state_in_w2  => subbyte_w2,         -- Input word 2.                  (IN)
    state_in_w3  => subbyte_w3,         -- Input word 3.                  (IN)
    state_out_w0 => shiftrow_w0,        -- Result word 0.                 (OUT)
    state_out_w1 => shiftrow_w1,        -- Result word 1.                 (OUT)
    state_out_w2 => shiftrow_w2,        -- Result word 2.                 (OUT)
    state_out_w3 => shiftrow_w3         -- Result word 3.                 (OUT)
  );
  -------------------------------------------- End of Port map for AES_ShiftRows

  -------------------------------------------------- Port map for AES_Mixcolumns
  aes_mixcolumns_1: aes_mixcolumns
  port map(
    state_in_w0  => shiftrow_w0,        -- Input word 0.                  (IN)
    state_in_w1  => shiftrow_w1,        -- Input word 1.                  (IN)
    state_in_w2  => shiftrow_w2,        -- Input word 2.                  (IN)
    state_in_w3  => shiftrow_w3,        -- Input word 3.                  (IN)
    state_out_w0 => mixcolumn_w0,       -- Result word 0.                 (OUT)
    state_out_w1 => mixcolumn_w1,       -- Result word 1.                 (OUT)
    state_out_w2 => mixcolumn_w2,       -- Result word 2.                 (OUT)
    state_out_w3 => mixcolumn_w3        -- Result word 3.                 (OUT)
  );
  ------------------------------------------- End of Port map for AES_Mixcolumns

end RTL;
