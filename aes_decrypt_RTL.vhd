--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: aes_decrypt.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block contains the decryption processing for the AES
--               Cryptographic Processor. It receives the Key and the State as
--               inputs and performs all the decrytion protocol on one state,
--               under control of the AES cipher state machine.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/aes_blockcipher/vhdl/rtl/aes_decrypt.vhd,v  
--  Log: aes_decrypt.vhd,v  
-- Revision 1.1  2003/09/01 16:35:04  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--
-- Log history:
--
-- Source: Good
-- Log: aes_decrypt.vhd,v
-- Revision 1.1  2003/08/28 15:19:46  Dr.A
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
entity aes_decrypt is
  port (
    -- Clocks and resets
    clk            : in  std_logic; -- AHB clock.
    reset_n        : in  std_logic; -- AHB reset. Inverted logic.
    -- Data to decrypt
    init_state_w0  : in  std_logic_vector(31 downto 0);
    init_state_w1  : in  std_logic_vector(31 downto 0);
    init_state_w2  : in  std_logic_vector(31 downto 0);
    init_state_w3  : in  std_logic_vector(31 downto 0);
    -- Result state
    invstate_w0    : out std_logic_vector(31 downto 0);
    invstate_w1    : out std_logic_vector(31 downto 0);
    invstate_w2    : out std_logic_vector(31 downto 0);
    invstate_w3    : out std_logic_vector(31 downto 0);
    -- Controls
    enable         : in  std_logic; -- Enable the decryption block.
    number_rounds  : in  std_logic_vector(4 downto 0); -- Nb of rounds in AES.
    round          : in  std_logic_vector(4 downto 0); -- Current round number.
    decoded_state  : in  std_logic_vector(3 downto 0); -- Current AES state.
    next_dec_state : in  std_logic_vector(3 downto 0); -- Next AES state.
    -- AES SRAM
    sram_rdata     : in  std_logic_vector(127 downto 0) -- Data read.
  );
end aes_decrypt;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of aes_decrypt is

------------------------------------------------------------- Signal declaration
-- Internal signals for the decrypted state (inverse state).
signal int_invstate_w0 : std_logic_vector(31 downto 0);
signal int_invstate_w1 : std_logic_vector(31 downto 0);
signal int_invstate_w2 : std_logic_vector(31 downto 0);
signal int_invstate_w3 : std_logic_vector(31 downto 0);
-- Signals for the decrypted state before it is registered.
signal invnewstate_w0  :std_logic_vector(31 downto 0);
signal invnewstate_w1  :std_logic_vector(31 downto 0);
signal invnewstate_w2  :std_logic_vector(31 downto 0);
signal invnewstate_w3  :std_logic_vector(31 downto 0);
-- Signals for the InvSubByte block.
signal invsubbyte_wr   : std_logic_vector(31 downto 0);-- Input word.
signal invsubbyte_rs   : std_logic_vector(31 downto 0);-- Result word.
signal invsubbyte_rs_g : std_logic_vector(31 downto 0);-- Result word gated.
-- Registered outputs of the InvSubByte block.
signal invsubbyte_w0   : std_logic_vector(31 downto 0);
signal invsubbyte_w1   : std_logic_vector(31 downto 0);
signal invsubbyte_w2   : std_logic_vector(31 downto 0);
signal invsubbyte_w3   : std_logic_vector(31 downto 0);
-- Inputs of the InvShiftRow block.
signal input_isr_w0    : std_logic_vector(31 downto 0);
signal input_isr_w1    : std_logic_vector(31 downto 0);
signal input_isr_w2    : std_logic_vector(31 downto 0);
signal input_isr_w3    : std_logic_vector(31 downto 0);
-- Outputs of the InvShiftRow block.
signal invshiftrow_w0  :std_logic_vector(31 downto 0);
signal invshiftrow_w1  :std_logic_vector(31 downto 0);
signal invshiftrow_w2  :std_logic_vector(31 downto 0);
signal invshiftrow_w3  :std_logic_vector(31 downto 0);
-- AddRoundKey state, input to the InvMixColumn block.
signal addroundkey_w0  :std_logic_vector(31 downto 0);
signal addroundkey_w1  :std_logic_vector(31 downto 0);
signal addroundkey_w2  :std_logic_vector(31 downto 0);
signal addroundkey_w3  :std_logic_vector(31 downto 0);
-- Outputs of the InvMixColumn block.
signal invmixcolumn_w0 :std_logic_vector(31 downto 0);
signal invmixcolumn_w1 :std_logic_vector(31 downto 0);
signal invmixcolumn_w2 :std_logic_vector(31 downto 0);
signal invmixcolumn_w3 :std_logic_vector(31 downto 0);
-- sram_rdata gated by the enable input.
signal sram_rdata_g : std_logic_vector(127 downto 0);
------------------------------------------------------ End of Signal declaration

begin

  ---------------------------------------------------------- Assign output ports
  -- Decrypted state.
  invstate_w0 <= int_invstate_w0;
  invstate_w1 <= int_invstate_w1;
  invstate_w2 <= int_invstate_w2;
  invstate_w3 <= int_invstate_w3;
  --------------------------------------------------- End of assign output ports

  ------------------------------------------------------ Inverse State Generator
  -- This process generates the InvState. It is initialised with the init_state
  -- words and updated with the calculated state bytes.
  --
  --                   ____
  --    init_state____| \  |
  --                  |  \ |                ___
  -- InvMixColumns____|   \|_______________|D Q|____ InvState
  --                  |   /|  New_InvState |   |
  --   AddRoundKey____|  / |               |>__|
  --                  |_/__|
  --                    |
  --                  round
  --
  --
  -- These lines select the transformation done on the state.
  --  * If the decryption block is not enabled, invnewstate_wX is set to zero.
  --  * Else, on the first round, state_sel_wX will be the initial state (input)
  --  * On the last round, state_sel_wX will be the AddRoundKey state.
  --  * On the others rounds, state_sel_wX will come from InvMixColumns block.
  invnewstate_w0 <= (others => '0') when enable = '0'
               else init_state_w0   when round = 0       -- First round.
               else invmixcolumn_w0 when round /= number_rounds-- Not last round
               else addroundkey_w0;                            -- Last round.
  invnewstate_w1 <= (others => '0') when enable = '0'
               else  init_state_w1   when round = 0       -- First round.
               else invmixcolumn_w1 when round /= number_rounds-- Not last round
               else addroundkey_w1;
  invnewstate_w2 <= (others => '0') when enable = '0'
               else  init_state_w2   when round = 0       -- First round.
               else invmixcolumn_w2 when round /= number_rounds-- Not last round
               else addroundkey_w2;
  invnewstate_w3 <= (others => '0') when enable = '0'
               else  init_state_w3   when round = 0       -- First round.
               else invmixcolumn_w3 when round /= number_rounds-- Not last round
               else addroundkey_w3;

  -- The invstate is updated with the New Inv State on every AddRoundKey State.
  invstate_update_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      int_invstate_w0 <= (others => '0');
      int_invstate_w1 <= (others => '0');
      int_invstate_w2 <= (others => '0');
      int_invstate_w3 <= (others => '0');
    elsif (clk'event and clk = '1') then
      if decoded_state = ADD_ST_CT then
        int_invstate_w0 <= invnewstate_w0;
        int_invstate_w1 <= invnewstate_w1;
        int_invstate_w2 <= invnewstate_w2;
        int_invstate_w3 <= invnewstate_w3;
      end if;
    end if;
  end process invstate_update_pr;

  ----------------------------------------------- End of Inverse State Generator

  ------------------------------------------------------- Block SubByte Selector
  -- This process decodes the state in the main state machine to select which
  -- word is connected to the InvSubByte blocks.
  invsubbyte_wr <= invshiftrow_w0 when decoded_state = SUB0_ST_CT else
                   invshiftrow_w1 when decoded_state = SUB1_ST_CT else
                   invshiftrow_w2 when decoded_state = SUB2_ST_CT else
                   invshiftrow_w3;

  -- The InvSubByte output is gated during encryption.
  invsubbyte_rs_g <= invsubbyte_rs when enable = '1' else (others => '0');

  -- This process registers the output of the InvSubByte block.
  decoder_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      invsubbyte_w0 <= (others => '0');
      invsubbyte_w1 <= (others => '0');
      invsubbyte_w2 <= (others => '0');
      invsubbyte_w3 <= (others => '0');
    elsif (clk'event and clk = '1') then
      case next_dec_state is
        when SUB1_ST_CT =>
          invsubbyte_w0 <= invsubbyte_rs_g;

        when SUB2_ST_CT =>
          invsubbyte_w1 <= invsubbyte_rs_g;

        when SUB3_ST_CT =>
          invsubbyte_w2 <= invsubbyte_rs_g;

        when CALC_ST_CT =>
          invsubbyte_w3 <= invsubbyte_rs_g;

        when others =>
          null;

      end case;
    end if;
  end process decoder_pr;
  ---------------------------------------- End of SubByte Block Selector decoder

  ------------------------------------------------------- AddRoundKey Generation
  -- Gate sram data to save power during encryption.
  sram_rdata_g <= sram_rdata when enable = '1' else (others => '0');

  -- This process generates the words corresponding to the AddRoundKey.
  -- sram_data contains the key_schedule.
  addroundkey_w0 <= invsubbyte_w0 xor sram_rdata_g(31 downto  0) when round /= 0
               else int_invstate_w0 xor sram_rdata_g(31 downto  0);
  addroundkey_w1 <= invsubbyte_w1 xor sram_rdata_g(63 downto 32) when round /= 0
               else int_invstate_w1 xor sram_rdata_g(63 downto 32);
  addroundkey_w2 <= invsubbyte_w2 xor sram_rdata_g(95 downto 64) when round /= 0
               else int_invstate_w2 xor sram_rdata_g(95 downto 64);
  addroundkey_w3 <= invsubbyte_w3 xor sram_rdata_g(127 downto 96) when round /= 0
               else int_invstate_w3 xor sram_rdata_g(127 downto 96);
  ------------------------------------------------ End of AddRoundKey Generation

  ------------------------------------------------- Port map for AES_InvSubBytes
  aes_invsubbytes_1: aes_invsubbytes
  port map(
    word_in      => invsubbyte_wr,      -- Input word.                    (IN)
    word_out     => invsubbyte_rs       -- Result word.                   (OUT)
  );
  ------------------------------------------ End of Port map for AES_InvSubBytes

  ------------------------------------------------ Port map for AES_InvShiftRows
  -- The input to this block will be invstate_wX except on the first round
  -- where the input lines will be addroundkey_wX.
  input_isr_w0 <= addroundkey_w0 when round = 0 else int_invstate_w0;
  input_isr_w1 <= addroundkey_w1 when round = 0 else int_invstate_w1;
  input_isr_w2 <= addroundkey_w2 when round = 0 else int_invstate_w2;
  input_isr_w3 <= addroundkey_w3 when round = 0 else int_invstate_w3;

  aes_invshiftrows_1: aes_invshiftrows
  port map(
    state_in_w0  => input_isr_w0,       -- Input word 0.                (IN)
    state_in_w1  => input_isr_w1,       -- Input word 1.                (IN)
    state_in_w2  => input_isr_w2,       -- Input word 2.                (IN)
    state_in_w3  => input_isr_w3,       -- Input word 3.                (IN)
    state_out_w0 => invshiftrow_w0,     -- Result word 0.               (OUT)
    state_out_w1 => invshiftrow_w1,     -- Result word 1.               (OUT)
    state_out_w2 => invshiftrow_w2,     -- Result word 2.               (OUT)
    state_out_w3 => invshiftrow_w3      -- Result word 3.               (OUT)
  );
  ----------------------------------------- End of Port map for AES_InvShiftRows

  ----------------------------------------------- Port map for AES_InvMixColumns
  aes_invmixcolumns_1: aes_invmixcolumns
  port map(
    state_in_w0  => addroundkey_w0,     -- Input word 0.                (IN)
    state_in_w1  => addroundkey_w1,     -- Input word 1.                (IN)
    state_in_w2  => addroundkey_w2,     -- Input word 2.                (IN)
    state_in_w3  => addroundkey_w3,     -- Input word 3.                (IN)
    state_out_w0 => invmixcolumn_w0,    -- Result word 0.               (OUT)
    state_out_w1 => invmixcolumn_w1,    -- Result word 1.               (OUT)
    state_out_w2 => invmixcolumn_w2,    -- Result word 2.               (OUT)
    state_out_w3 => invmixcolumn_w3     -- Result word 3.               (OUT)
  );
  ---------------------------------------- End of Port map for AES_InvMixColumns


end RTL;
