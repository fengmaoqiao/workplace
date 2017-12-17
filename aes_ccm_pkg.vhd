--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processor
--    ,' GoodLuck ,'      RCSfile: aes_ccm_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.8  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for aes_ccm.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/aes_ccm/vhdl/rtl/aes_ccm_pkg.vhd,v  
--  Log: aes_ccm_pkg.vhd,v  
-- Revision 1.8  2005/05/31 15:45:09  Dr.A
-- #BugId:938#
-- New diags
--
-- Revision 1.7  2003/09/29 15:47:00  Dr.A
-- Removed unused key size tests.
--
-- Revision 1.6  2003/09/23 14:03:28  Dr.A
-- aes_bize set to 16 bits. Added state_number.
--
-- Revision 1.5  2003/09/01 16:37:48  Dr.A
-- Moved cipher files to another block.
--
-- Revision 1.4  2003/09/01 16:03:16  Dr.A
-- Added early signal.
--
-- Revision 1.3  2003/08/28 15:40:56  Dr.A
-- New files and constants.
--
-- Revision 1.2  2003/07/16 13:39:50  Dr.A
-- Added aes_control.
--
-- Revision 1.1  2003/07/03 14:05:17  Dr.A
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
package aes_ccm_pkg is

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/STREAM_PROCESSOR/aes_blockcipher/vhdl/rtl/aes_blockcipher.vhd
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


----------------------
-- File: aes_control.vhd
----------------------
  component aes_control
  generic (
    addrmax_g     : integer := 32       -- AHB Address bus width (max. 32 bits).
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk           : in  std_logic;      -- AHB clock.
    reset_n       : in  std_logic;      -- AHB reset. Inverted logic.
    --------------------------------------
    -- Interrupts
    --------------------------------------
    process_done  : out std_logic;      -- High when en/decryption finished.
    mic_int       : out std_logic;      -- Indicates error when checking the MIC
    --------------------------------------
    -- Registers
    --------------------------------------
    startop       : in  std_logic;      -- Pulse that starts the encryption.
    stopop        : in  std_logic;      -- Stops the encryption/decryption.
    --------------------------------------
    -- Control structure
    --------------------------------------
    opmode        : in  std_logic;      -- Indicates Rx (0) or Tx (1) mode.
    priority      : in  std_logic_vector( 7 downto 0); -- Priority field.
    aes_packet_num: in  std_logic_vector(47 downto 0); -- Packet number.
    -- Addresses
    aes_csaddr    : in  std_logic_vector(addrmax_g-1 downto 0); --Control struct
    aes_saddr     : in  std_logic_vector(addrmax_g-1 downto 0); --Source.
    aes_daddr     : in  std_logic_vector(addrmax_g-1 downto 0); --Destination.
    aes_maddr     : in  std_logic_vector(addrmax_g-1 downto 0); --MAC header.
    aes_kaddr     : in  std_logic_vector(addrmax_g-1 downto 0); -- Key address.
    enablecrypt   : in  std_logic;      -- Enables(1) or disables the encryption
    -- Sizes (in bytes)
    aes_msize     : in  std_logic_vector( 5 downto 0); -- MAC header size.
    aes_bsize     : in  std_logic_vector(15 downto 0); -- Size of data buffer.
    -- Number of data states (16 bytes) to process.
    state_number  : in  std_logic_vector(12 downto 0);
    --------------------------------------
    -- Read Interface
    --------------------------------------
    start_read    : out std_logic;      -- Start reading data.
    read_size     : out std_logic_vector( 3 downto 0); -- Size of data to read.
    read_addr     : out std_logic_vector(addrmax_g-1 downto 0); -- Read address.
    -- 
    read_done     : in  std_logic;      -- All data read.
    -- Data read.
    read_word0    : in  std_logic_vector(31 downto 0);
    read_word1    : in  std_logic_vector(31 downto 0);
    read_word2    : in  std_logic_vector(31 downto 0);
    read_word3    : in  std_logic_vector(31 downto 0);
    --------------------------------------
    -- Write Interface
    --------------------------------------
    start_write   : out std_logic;      -- Start writing data.
    write_size    : out std_logic_vector( 3 downto 0); -- Size of data to write.
    write_addr    : out std_logic_vector(addrmax_g-1 downto 0); -- Write address
    -- Data to write.
    write_word0   : out std_logic_vector(31 downto 0);
    write_word1   : out std_logic_vector(31 downto 0);
    write_word2   : out std_logic_vector(31 downto 0);
    write_word3   : out std_logic_vector(31 downto 0);
    --
    write_done    : in  std_logic;      -- All data written.
    --------------------------------------
    -- Controls
    --------------------------------------
    key_load4     : out std_logic;      -- Signal to save the first 4 key bytes.
    start_expand  : out std_logic;      -- Positive edge starts Key expansion.
    start_cipher  : out std_logic;      -- Positive edge starts encryption round
    --
    expand_done   : in  std_logic;      -- Key expansion done.
    cipher_done   : in  std_logic;      -- Encryption/decryption round done.
    ciph_done_early:in  std_logic;      -- Flag set 2 cycles before cipher_done.
    --------------------------------------
    -- AES block cipher interface
    --------------------------------------
    -- AES state inputs
    aes_state_w0  : out std_logic_vector(31 downto 0);
    aes_state_w1  : out std_logic_vector(31 downto 0);
    aes_state_w2  : out std_logic_vector(31 downto 0);
    aes_state_w3  : out std_logic_vector(31 downto 0);
    -- AES blockcipher result
    result_w0     : in  std_logic_vector(31 downto 0);
    result_w1     : in  std_logic_vector(31 downto 0);
    result_w2     : in  std_logic_vector(31 downto 0);
    result_w3     : in  std_logic_vector(31 downto 0);
    --------------------------------------
    -- Diagnostic port
    --------------------------------------
    aes_ctrl_diag : out std_logic_vector(7 downto 0)
    
  );

  end component;



 
end aes_ccm_pkg;
