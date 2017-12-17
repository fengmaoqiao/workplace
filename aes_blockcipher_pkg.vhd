
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Stream_Processing
--    ,' GoodLuck ,'      RCSfile: aes_blockcipher_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for aes_blockcipher.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/aes_blockcipher/vhdl/rtl/aes_blockcipher_pkg.vhd,v  
--  Log: aes_blockcipher_pkg.vhd,v  
-- Revision 1.2  2003/11/14 18:08:27  Dr.A
-- aes_sm port map update.
--
-- Revision 1.1  2003/09/01 16:35:02  Dr.A
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
-- Package
--------------------------------------------------------------------------------
package aes_blockcipher_pkg is

constant IDLE_ST_CT : std_logic_vector(3 downto 0) := "0000";
constant READ_ST_CT : std_logic_vector(3 downto 0) := "0001";
constant KEY_ST_CT  : std_logic_vector(3 downto 0) := "0010";
constant ADD_ST_CT  : std_logic_vector(3 downto 0) := "0011";
constant SUB0_ST_CT : std_logic_vector(3 downto 0) := "0100";
constant SUB1_ST_CT : std_logic_vector(3 downto 0) := "0101";
constant SUB2_ST_CT : std_logic_vector(3 downto 0) := "0110";
constant SUB3_ST_CT : std_logic_vector(3 downto 0) := "0111";
constant CALC_ST_CT : std_logic_vector(3 downto 0) := "1000";

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: aes_sm.vhd
----------------------
  component aes_sm
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
  end component;


----------------------
-- File: aes_keyschedule.vhd
----------------------
  component aes_keyschedule
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
  end component;


----------------------
-- File: aes_subbytes.vhd
----------------------
  component aes_subbytes
  port (
    word_in      : in  std_logic_vector (31 downto 0); -- Input word.
    word_out     : out std_logic_vector (31 downto 0)  -- Transformed word.
  );
  end component;


----------------------
-- File: aes_shiftrows.vhd
----------------------
  component aes_shiftrows
  port (
    -- State in:
    state_in_w0 : in  std_logic_vector (31 downto 0); -- Input State word 0.
    state_in_w1 : in  std_logic_vector (31 downto 0); -- Input State word 1.
    state_in_w2 : in  std_logic_vector (31 downto 0); -- Input State word 2.
    state_in_w3 : in  std_logic_vector (31 downto 0); -- Input State word 3.
    -- State out:
    state_out_w0: out std_logic_vector (31 downto 0); -- Output State word 0.
    state_out_w1: out std_logic_vector (31 downto 0); -- Output State word 1.
    state_out_w2: out std_logic_vector (31 downto 0); -- Output State word 2.
    state_out_w3: out std_logic_vector (31 downto 0)  -- Output State word 3.
  );
  end component;


----------------------
-- File: aes_mixcolumns.vhd
----------------------
  component aes_mixcolumns
  port (
    -- State in:
    state_in_w0 : in  std_logic_vector (31 downto 0); -- Input State word 0.
    state_in_w1 : in  std_logic_vector (31 downto 0); -- Input State word 1.
    state_in_w2 : in  std_logic_vector (31 downto 0); -- Input State word 2.
    state_in_w3 : in  std_logic_vector (31 downto 0); -- Input State word 3.
    -- State in:
    state_out_w0: out std_logic_vector (31 downto 0); -- Output State word 0.
    state_out_w1: out std_logic_vector (31 downto 0); -- Output State word 1.
    state_out_w2: out std_logic_vector (31 downto 0); -- Output State word 2.
    state_out_w3: out std_logic_vector (31 downto 0)  -- Output State word 3.
  );
  end component;


----------------------
-- File: aes_encrypt.vhd
----------------------
  component aes_encrypt
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
  end component;


----------------------
-- File: aes_invsubbytes.vhd
----------------------
  component aes_invsubbytes
  port (
    word_in      : in  std_logic_vector (31 downto 0); -- Input word.
    word_out     : out std_logic_vector (31 downto 0)  -- Transformed word.
  );
  end component;


----------------------
-- File: aes_invshiftrows.vhd
----------------------
  component aes_invshiftrows
  port (
    -- State in:
    state_in_w0 : in  std_logic_vector (31 downto 0); -- Input State word 0.
    state_in_w1 : in  std_logic_vector (31 downto 0); -- Input State word 1.
    state_in_w2 : in  std_logic_vector (31 downto 0); -- Input State word 2.
    state_in_w3 : in  std_logic_vector (31 downto 0); -- Input State word 3.
    -- State out:
    state_out_w0: out std_logic_vector (31 downto 0); -- Output State word 0.
    state_out_w1: out std_logic_vector (31 downto 0); -- Output State word 1.
    state_out_w2: out std_logic_vector (31 downto 0); -- Output State word 2.
    state_out_w3: out std_logic_vector (31 downto 0)  -- Output State word 3.
  );
  end component;


----------------------
-- File: aes_invmixcolumns.vhd
----------------------
  component aes_invmixcolumns
  port (
    -- State in:
    state_in_w0 : in  std_logic_vector (31 downto 0); -- Input State word 0.
    state_in_w1 : in  std_logic_vector (31 downto 0); -- Input State word 1.
    state_in_w2 : in  std_logic_vector (31 downto 0); -- Input State word 2.
    state_in_w3 : in  std_logic_vector (31 downto 0); -- Input State word 3.
    -- State out:
    state_out_w0: out std_logic_vector (31 downto 0); -- Output State word 0.
    state_out_w1: out std_logic_vector (31 downto 0); -- Output State word 1.
    state_out_w2: out std_logic_vector (31 downto 0); -- Output State word 2.
    state_out_w3: out std_logic_vector (31 downto 0)  -- Output State word 3.
  );
  end component;


----------------------
-- File: aes_decrypt.vhd
----------------------
  component aes_decrypt
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
  end component;


----------------------
-- File: aes_blockcipher.vhd
----------------------
  component aes_blockcipher
  generic (
    ccm_mode_g  : integer := 0          -- 1 to use the AES cipher in CCM mode.
  );
  port (
    -- Clocks and resets
    clk           : in  std_logic; -- AHB clock.
    reset_n       : in  std_logic; -- AHB reset. Inverted logic.
    -- Control lines
    opmode        : in  std_logic; -- Indicates Rx (0) or Tx (1) mode.
    aes_ksize     : in  std_logic_vector( 5 downto 0); -- Key size in bytes.
    key_load4     : in  std_logic; -- Signal to save the first 4 key bytes.
    key_load8     : in  std_logic; -- Signal to save the last 4 key bytes.
    start_expand  : in  std_logic; -- Signal to start Key Schedule.
    start_cipher  : in  std_logic; -- Signal to encrypt/decrypt one state.
    --
    expand_done   : out std_logic; -- Key Schedule done.
    cipher_done   : out std_logic; -- Indicates encryption/decryption done.
    ciph_done_early: out std_logic;-- Flag set 2 cycles before cipher_done.
    -- Interrupt
    stopop        : in  std_logic; -- Stops the encryption/decryption.
    -- Initial key words
    init_key_w0   : in  std_logic_vector(31 downto 0);
    init_key_w1   : in  std_logic_vector(31 downto 0);
    init_key_w2   : in  std_logic_vector(31 downto 0);
    init_key_w3   : in  std_logic_vector(31 downto 0);
    init_key_w4   : in  std_logic_vector(31 downto 0);
    init_key_w5   : in  std_logic_vector(31 downto 0);
    init_key_w6   : in  std_logic_vector(31 downto 0);
    init_key_w7   : in  std_logic_vector(31 downto 0);
    -- State to encrypt/decrypt
    init_state_w0 : in  std_logic_vector(31 downto 0);
    init_state_w1 : in  std_logic_vector(31 downto 0);
    init_state_w2 : in  std_logic_vector(31 downto 0);
    init_state_w3 : in  std_logic_vector(31 downto 0);
    -- Result (Encrypted/decrypted State)
    result_w0     : out std_logic_vector(31 downto 0);
    result_w1     : out std_logic_vector(31 downto 0);
    result_w2     : out std_logic_vector(31 downto 0);
    result_w3     : out std_logic_vector(31 downto 0);
    -- AES SRAM Interface
    sram_wdata    : out std_logic_vector(127 downto 0); -- Data to be written.
    sram_address  : out std_logic_vector(  3 downto 0); -- Address.
    sram_wen      : out std_logic; -- Write Enable. Inverted logic.
    sram_cen      : out std_logic; -- Chip Enable. Inverted logic.
    --
    sram_rdata    : in  std_logic_vector(127 downto 0) -- Data read.
  );
  end component;



 
end aes_blockcipher_pkg;
