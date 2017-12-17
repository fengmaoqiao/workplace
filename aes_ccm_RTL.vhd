
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: aes_ccm.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.9  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block is the top of the AES Cryptographic Processor.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/aes_ccm/vhdl/rtl/aes_ccm.vhd,v  
--  Log: aes_ccm.vhd,v  
-- Revision 1.9  2005/05/31 15:45:06  Dr.A
-- #BugId:938#
-- New diags
--
-- Revision 1.8  2003/11/26 08:30:42  Dr.A
-- Updated diag.
--
-- Revision 1.7  2003/09/29 15:46:33  Dr.A
-- Removed unused key size port.
--
-- Revision 1.6  2003/09/23 14:03:47  Dr.A
-- updated for new aes_control.
--
-- Revision 1.5  2003/09/01 16:38:11  Dr.A
-- Moved cipher files to another block.
--
-- Revision 1.4  2003/09/01 16:03:06  Dr.A
-- Added early signal.
--
-- Revision 1.3  2003/08/28 15:18:45  Dr.A
-- Changed bsize length. Added generic.
--
-- Revision 1.2  2003/07/16 13:39:20  Dr.A
-- Updated for version 0.09. Moved state machine and controls to a separated entity.
--
-- Revision 1.1  2003/07/03 14:04:59  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 

--library aes_ccm_rtl; 
library work;
--use aes_ccm_rtl.aes_ccm_pkg.ALL; 
use work.aes_ccm_pkg.ALL; 

--library aes_blockcipher_rtl;
library work;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity aes_ccm is
  generic (
    addrmax_g  : integer := 32          -- AHB Address bus width (max. 32 bits).
  );
  port (
    --------------------------------------
    -- Clocks and resets
    --------------------------------------
    clk        : in  std_logic;         -- AHB clock.
    reset_n    : in  std_logic;         -- AHB reset. Inverted logic.

    --------------------------------------
    -- Interrupts
    --------------------------------------
    process_done : out std_logic;       -- High when en/decryption finished.
    mic_int      : out std_logic;       -- Indicates an error in the CCMP MIC.

    --------------------------------------
    -- Registers
    --------------------------------------
    startop    : in  std_logic;         -- Pulse that starts the encryption.
    stopop     : in  std_logic;         -- Stops the encryption/decryption.

    --------------------------------------
    -- Control structure fields
    --------------------------------------
    opmode     : in  std_logic;         -- Indicates Rx (0) or Tx (1) mode.
    priority   : in  std_logic_vector( 7 downto 0);      -- Priority field.
    aes_packet_num  : in  std_logic_vector(47 downto 0); -- Packet number.
    -- Addresses
    aes_csaddr : in  std_logic_vector(addrmax_g-1 downto 0); -- Control struct.
    aes_saddr  : in  std_logic_vector(addrmax_g-1 downto 0); -- Source data.
    aes_daddr  : in  std_logic_vector(addrmax_g-1 downto 0); -- Destination data
    aes_maddr  : in  std_logic_vector(addrmax_g-1 downto 0); -- MAC header.
    aes_kaddr  : in  std_logic_vector(addrmax_g-1 downto 0); -- Key address.
    enablecrypt: in  std_logic;         -- Enables(1) or disables the encryption
    -- Sizes (in bytes)
    aes_msize  : in  std_logic_vector( 5 downto 0); -- Size of the MAC header.
    aes_bsize  : in  std_logic_vector(15 downto 0); -- Size of the data buffer.
    -- Number of data states (16 bytes) to process.
    state_number : in  std_logic_vector(12 downto 0);

    --------------------------------------
    -- Read Interface
    --------------------------------------
    start_read : out std_logic;         -- Pulse to start read access.
    read_size  : out std_logic_vector( 3 downto 0); -- Size of data to read.
    read_addr  : out std_logic_vector(addrmax_g-1 downto 0); -- Read address.
    --
    read_done  : in  std_logic;         -- Indicates read access is over.
    -- Read data words.
    read_word0 : in  std_logic_vector(31 downto 0);
    read_word1 : in  std_logic_vector(31 downto 0);
    read_word2 : in  std_logic_vector(31 downto 0);
    read_word3 : in  std_logic_vector(31 downto 0);

    --------------------------------------
    -- Write Interface
    --------------------------------------
    start_write: out std_logic;         -- Pulse to start write access.
    write_size : out std_logic_vector( 3 downto 0); -- Size of data to write.
    write_addr : out std_logic_vector(addrmax_g-1 downto 0); -- Write address.
    -- Words of data to write.
    write_word0: out std_logic_vector(31 downto 0);
    write_word1: out std_logic_vector(31 downto 0);
    write_word2: out std_logic_vector(31 downto 0);
    write_word3: out std_logic_vector(31 downto 0);
    --
    write_done : in  std_logic;         -- Indicates write access is over.

    --------------------------------------
    -- AES SRAM interface
    --------------------------------------
    sram_wdata : out std_logic_vector(127 downto 0); -- Data to be written.
    sram_addr  : out std_logic_vector(  3 downto 0); -- Address.
    sram_wen   : out std_logic;         -- Write Enable. Inverted logic.
    sram_cen   : out std_logic;         -- Chip Enable. Inverted logic.
    --
    sram_rdata : in  std_logic_vector(127 downto 0); -- Data read.

    --------------------------------------
    -- Diagnostic port
    --------------------------------------
    aes_diag   : out std_logic_vector(7 downto 0)
  );
end aes_ccm;


--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of aes_ccm is

------------------------------------------------------------- Signal declaration
-- Control lines
signal key_load4       : std_logic; -- Signal to save the first 4 key bytes.
signal key_load8       : std_logic; -- Signal to save the last 4 key bytes.
signal start_expand    : std_logic; -- Positive edge starts Key expansion.
signal expand_done     : std_logic; -- Key expansion done.
signal start_cipher    : std_logic; -- Positive edge starts encryption round.
signal cipher_done     : std_logic; -- Encryption/decryption round done.
signal ciph_done_early : std_logic; -- Flag set 2 cycles before cipher_done.
signal aes_opmode      : std_logic; -- High to set AES cipher in encryption mode
signal aes_ksize       : std_logic_vector( 5 downto 0); -- Size of the key.
-- Data state sent to the AES block cipher for encryption or decryption.
signal aes_state_w0    : std_logic_vector(31 downto 0);
signal aes_state_w1    : std_logic_vector(31 downto 0);
signal aes_state_w2    : std_logic_vector(31 downto 0);
signal aes_state_w3    : std_logic_vector(31 downto 0);
-- AES blockcipher result words.
signal result_w0       : std_logic_vector(31 downto 0);
signal result_w1       : std_logic_vector(31 downto 0);
signal result_w2       : std_logic_vector(31 downto 0);
signal result_w3       : std_logic_vector(31 downto 0);
-- Diagnostic port from control sub-block.
signal aes_ctrl_diag   : std_logic_vector(7 downto 0);

------------------------------------------------------ End of Signal declaration

begin
  
  -------------------------------------------------------------- Diagnostic port
  aes_diag <= start_expand & expand_done & start_cipher & cipher_done &
              aes_ctrl_diag(3 downto 0) ;
  ------------------------------------------------------- End of diagnostic port

  ----------------------------------------------- Port map for AES control block
  aes_control_1 : aes_control
    generic map (
      addrmax_g      => addrmax_g
      )
    port map (
      -- Clocks & Reset
      clk            => clk,            -- AHB clock.                    (IN)
      reset_n        => reset_n,        -- AHB reset. Inverted logic.    (IN)
      -- Interrupts  
      process_done   => process_done,   -- High when operation finished. (IN)
      mic_int        => mic_int,        -- Indicates an AES MIC error.   (IN)
      -- Control structure
      opmode         => opmode,         -- Indicates Rx(0) or Tx(1) mode.(IN)
      aes_msize      => aes_msize,      -- MAC header size.              (IN)
      priority       => priority,       -- Priority field.               (IN)
      aes_csaddr     => aes_csaddr,     -- Control structure address.    (IN)
      aes_saddr      => aes_saddr,      -- Source address.               (IN)
      aes_daddr      => aes_daddr,      -- Destination address.          (IN)
      aes_maddr      => aes_maddr,      -- MAC header address.           (IN)
      enablecrypt    => enablecrypt,    -- Enables(1) the en/decryption. (IN)
      aes_kaddr      => aes_kaddr,      -- Key address.                  (IN)
      aes_bsize      => aes_bsize,      -- Size of data buffer.          (IN)
      state_number   => state_number,   -- Nb of 16-byte data states.    (IN)
      aes_packet_num => aes_packet_num, -- Packet number.                (IN)
      -- Registers
      startop        => startop,        -- Start the en/decryption.      (IN)
      stopop         => stopop,         -- Stop the en/decryption.       (IN)
      -- Read Interface:
      start_read     => start_read,     -- Start reading data.           (OUT)
      read_size      => read_size,      -- Size of data to read.         (OUT)
      read_addr      => read_addr,      -- Address of data to read.      (OUT)
      --
      read_done      => read_done,      -- All data read.                (IN)
      read_word0     => read_word0,     -- Read word 0.                  (IN)
      read_word1     => read_word1,     -- Read word 1.                  (IN)
      read_word2     => read_word2,     -- Read word 2.                  (IN)
      read_word3     => read_word3,     -- Read word 3.                  (IN)
      -- Write Interface
      start_write    => start_write,    -- Start writing data.           (OUT)
      write_size     => write_size,     -- Size of data to write.        (OUT)
      write_addr     => write_addr,     -- Write address                 (OUT)
      write_word0    => write_word0,    -- Word 0 to be written.         (OUT)
      write_word1    => write_word1,    -- Word 1 to be written.         (OUT)
      write_word2    => write_word2,    -- Word 2 to be written.         (OUT)
      write_word3    => write_word3,    -- Word 3 to be written.         (OUT)
      --
      write_done     => write_done,     -- All data written.             (IN)
      -- Controls
      key_load4      => key_load4,     -- Save the first 4 key bytes.    (OUT)
      start_expand   => start_expand,  -- Starts Key expansion.          (OUT)
      start_cipher   => start_cipher,  -- Starts encryption round        (OUT)
      --
      expand_done    => expand_done,   -- Key expansion done.            (IN)
      cipher_done    => cipher_done,   -- En/decryption round done.      (IN)
      ciph_done_early=> ciph_done_early,-- Flag 2 cc before cipher_done.  (IN)
      -- AES block cipher interface
      -- Data to AES block cipher.
      aes_state_w0  => aes_state_w0, --                                (OUT)
      aes_state_w1  => aes_state_w1, --                                (OUT)
      aes_state_w2  => aes_state_w2, --                                (OUT)
      aes_state_w3  => aes_state_w3, --                                (OUT)
      -- Result from AES block cipher.
      result_w0      => result_w0,     --                                (IN)
      result_w1      => result_w1,     --                                (IN)
      result_w2      => result_w2,     --                                (IN)
      result_w3      => result_w3,     --                                (IN)
      -- Diagnostic port.
      aes_ctrl_diag  => aes_ctrl_diag  --                                (OUT)
      );
  ---------------------------------------- End of port map for AES control block

  ------------------------------------------------- Port map for AES_BlockCipher
  -- In CCM, the key size is always 16 bytes.
  aes_ksize  <= "010000";
  key_load8  <= '0';
  -- In CCM, the AES blockcipher is always used in encryption mode.
  aes_opmode <= '1';
  
  aes_blockcipher_1: aes_blockcipher
  generic map (
    ccm_mode_g   => 1                   -- 1 to use the AES cipher in CCM mode.
  )
  port map(
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          => clk,                -- AHB clock.                    (IN)
    reset_n      => reset_n,            -- AHB reset. Inverted logic.    (IN)
    --------------------------------------
    -- Control lines
    --------------------------------------
    opmode       => aes_opmode,         -- Indicates Rx(0) or Tx(1) mode.(IN)
    aes_ksize    => aes_ksize,          -- Size of the key in bytes.     (IN)
    key_load4    => key_load4,          -- Save the first 4 key bytes.   (IN)
    key_load8    => key_load8,          -- Save the last 4 key bytes.    (IN)
    start_expand => start_expand,       -- To start Key Schedule.        (IN)
    start_cipher => start_cipher,       -- To encrypt/decrypt one state. (IN)
    --
    expand_done  => expand_done,        -- Key Schedule done.            (OUT)
    cipher_done  => cipher_done,        -- Encryption/decryption done.   (OUT)
    ciph_done_early => ciph_done_early, -- Flag 2 cc before cipher_done. (IN)
    --------------------------------------
    -- Interrupt
    --------------------------------------
    stopop       => stopop,             -- Stops the encryption/decryption(IN)
    --------------------------------------
    -- Key words
    --------------------------------------
    init_key_w0  => read_word0,         -- Initial key word no.0.        (IN)
    init_key_w1  => read_word1,         -- Initial key word no.1.        (IN)
    init_key_w2  => read_word2,         -- Initial key word no.2.        (IN)
    init_key_w3  => read_word3,         -- Initial key word no.3.        (IN)
    init_key_w4  => read_word0,         -- Initial key word no.4.        (IN)
    init_key_w5  => read_word1,         -- Initial key word no.5.        (IN)
    init_key_w6  => read_word2,         -- Initial key word no.6.        (IN)
    init_key_w7  => read_word3,         -- Initial key word no.7.        (IN)
    --------------------------------------
    -- Data state to encrypt/decrypt
    --------------------------------------
    init_state_w0 => aes_state_w0,      -- Initial State word no.0.      (IN)
    init_state_w1 => aes_state_w1,      -- Initial State word no.1.      (IN)
    init_state_w2 => aes_state_w2,      -- Initial State word no.2.      (IN)
    init_state_w3 => aes_state_w3,      -- Initial State word no.3.      (IN)
    --------------------------------------
    -- Result (Encrypted/decrypted State)
    --------------------------------------
    result_w0    => result_w0,          -- Result word 0.                (OUT)
    result_w1    => result_w1,          -- Result word 1.                (OUT)
    result_w2    => result_w2,          -- Result word 2.                (OUT)
    result_w3    => result_w3,          -- Result word 3.                (OUT)
    --------------------------------------
    -- AES SRAM Interface
    --------------------------------------
    sram_wdata   => sram_wdata,         -- Data to be written.           (OUT)
    sram_address => sram_addr,          -- Address to write the data.    (OUT)
    sram_wen     => sram_wen,           -- Write Enable.                 (OUT)
    sram_cen     => sram_cen,           -- Chip Enable. Inverted logic.  (OUT)
    --
    sram_rdata   => sram_rdata          -- Data read from the SRAM.      (IN)
  );
  ------------------------------------------ End of Port map for AES_BlockCipher

end RTL;
