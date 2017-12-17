
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: rc4_crc_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.15   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rc4_crc.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/rc4_crc/vhdl/rtl/rc4_crc_pkg.vhd,v  
--  Log: rc4_crc_pkg.vhd,v  
-- Revision 1.15  2005/05/31 15:44:03  Dr.A
-- #BugId:938#
-- New diags
--
-- Revision 1.14  2004/05/04 09:44:41  Dr.A
-- First release of changes to correct MIC on fragmented MSDUs.
--
-- Revision 1.13  2003/11/26 08:40:08  Dr.A
-- Added D4/D6 compliancy bit.
--
-- Revision 1.12  2003/09/29 16:03:23  Dr.A
-- Added crc_debug.
--
-- Revision 1.11  2003/09/23 14:06:26  Dr.A
-- Changed bsize length, added ports.
--
-- Revision 1.10  2003/09/15 08:41:03  Dr.A
-- diagnostic potr.
--
-- Revision 1.9  2003/08/28 15:06:02  Dr.A
-- Added done_early signals. Changed bsize_length.
--
-- Revision 1.8  2003/08/13 16:22:18  Dr.A
-- rc4_control port map updated.
--
-- Revision 1.7  2003/07/16 13:30:16  Dr.A
-- Added rc4_control and tkip_key_mixing.
--
-- Revision 1.6  2003/07/03 14:14:33  Dr.A
-- Changes for TKIP.
--
-- Revision 1.5  2002/12/17 17:10:24  elama
-- Updated some ports in rc4_keystream and rc4_keyloading.
--
-- Revision 1.4  2002/11/19 15:23:23  elama
-- Finished the implementation of the addrmax_g generic.
--
-- Revision 1.3  2002/10/25 09:06:54  elama
-- Changed bsize to 25 bits.
--
-- Revision 1.2  2002/10/16 16:47:30  elama
-- Removed the read_error and write_error ports.
-- Changed the read_size and write_size to 4 bits.
--
-- Revision 1.1  2002/10/15 13:20:11  elama
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
package rc4_crc_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/crc32/vhdl/rtl/crc32_8.vhd
----------------------
  component crc32_8
  port (
    -- clock and reset
    clk          : in  std_logic;                    
    resetn       : in  std_logic;                   
     
    -- inputs
    data_in      : in  std_logic_vector ( 7 downto 0);
    --             8-bits inputs for parallel computing. 
    ld_init      : in  std_logic;
    --             initialize the CRC
    calc         : in  std_logic;
    --             ask of calculation of the available data.
 
    -- outputs
    crc_out_1st  : out std_logic_vector (7 downto 0); 
    crc_out_2nd  : out std_logic_vector (7 downto 0); 
    crc_out_3rd  : out std_logic_vector (7 downto 0); 
    crc_out_4th  : out std_logic_vector (7 downto 0) 
    --          CRC result
   );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/STREAM_PROCESSOR/tkip_key_mixing/vhdl/rtl/tkip_key_mixing.vhd
----------------------
  component tkip_key_mixing
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n      : in  std_logic;
    clk          : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    key1_key2n   : in  std_logic; -- Indicates the key mixing phase.
    start_keymix : in  std_logic; -- Pulse to start the key mixing phase.
    --
    keymix1_done : out std_logic; -- High when key mixing phase 1 is done.
    keymix2_done : out std_logic; -- High when key mixing phase 2 is done.
    --------------------------------------
    -- Data
    --------------------------------------
    tsc          : in  std_logic_vector(47 downto 0); -- Sequence counter.
    address2     : in  std_logic_vector(47 downto 0); -- A2 MAC header field.
    -- Temporal key (128 bits)
    temp_key_w3  : in  std_logic_vector(31 downto 0);
    temp_key_w2  : in  std_logic_vector(31 downto 0);
    temp_key_w1  : in  std_logic_vector(31 downto 0);
    temp_key_w0  : in  std_logic_vector(31 downto 0);
    -- TKIP key (128 bits)
    tkip_key_w3  : out std_logic_vector(31 downto 0);
    tkip_key_w2  : out std_logic_vector(31 downto 0);
    tkip_key_w1  : out std_logic_vector(31 downto 0);
    tkip_key_w0  : out std_logic_vector(31 downto 0)
  );

  end component;


----------------------
-- File: rc4_control.vhd
----------------------
  component rc4_control
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk            : in  std_logic;     -- AHB clock.
    reset_n        : in  std_logic;     -- AHB reset. Inverted logic.
    --------------------------------------
    -- Global controls
    --------------------------------------
    crc_debug      : in  std_logic;     -- Enable CRC stored for debug.
    opmode         : in  std_logic;     -- Indicates Rx (0) or Tx (1) mode.
    startop        : in  std_logic;     -- Pulse that starts the encryption.
    stopop         : in  std_logic;     -- Stops the encryption.
    enablecrypt    : in  std_logic;     -- Enables(1) or disables the encryption
    enablecrc      : in  std_logic;     -- Enables (1) or disables CRC operation
    enablemic      : in  std_logic;     -- Enables (1) or disables MIC operation
    -- Controls for sizes.
    rc4_bsize_lsb  : in  std_logic_vector( 3 downto 0);-- Data buffer size LSB.
    -- Number of data states (16 bytes) to process.
    state_number   : in  std_logic_vector(12 downto 0);
    -- Addresses
    rc4_csaddr     : in  std_logic_vector(31 downto 0);-- Control structure.
    rc4_saddr      : in  std_logic_vector(31 downto 0);-- Source buffer.
    rc4_daddr      : in  std_logic_vector(31 downto 0);-- Destination buffer.
    rc4_maddr      : in  std_logic_vector(31 downto 0);-- Control structure.
    rc4_kaddr      : in  std_logic_vector(31 downto 0);-- Key in control struct.
    -- Interrupts
    process_done   : out std_logic;     -- Pulse indicating encryption finished.
    crc_int        : out std_logic;     -- Indicates error in CRC.
    mic_int        : out std_logic;     -- Indicates error in MIC.
    --------------------------------------
    -- Commands
    --------------------------------------
    start_sbinit   : out std_logic;     -- Start S-Box initialisation.
    start_keymix   : out std_logic;     -- Start TKIP key mixing.
    key1_key2n     : out std_logic;     -- Indicates the TKIP key mixing phase.
    start_keyload  : out std_logic;     -- Start key loading in RAM.
    start_sboxgen  : out std_logic;     -- Start S-Box generation.
    init_keystr    : out std_logic;     -- Start key stream initialisation.
    start_keystr   : out std_logic;     -- Start key stream generation.
    start_michael  : out std_logic;     -- Start Michael processing.
    start_s2b      : out std_logic;     -- Start CRC serializer (state to bytes)
    crc_ld_init    : out std_logic;     -- Initialises CRC calculation.
    crc_calc       : out std_logic;     -- Pulse to compute CRC byte.
    --
    sbinit_done    : in  std_logic;     -- S-Box initialisation done.
    keymix1_done   : in  std_logic;     -- TKIP key mixing phase 1 done.
    keymix2_done   : in  std_logic;     -- TKIP key mixing phase 2 done.
    keyload_done   : in  std_logic;     -- High when Key is stored in SRAM.
    sboxgen_done   : in  std_logic;     -- S-Box generation done.
    kstr_done      : in  std_logic;     -- Indicates Key Stream calculated.
    michael_done   : in  std_logic;     -- Michael block function done.
    s2b_done       : in  std_logic;     -- Flag indicating CRC calculated.
    -- 'done' signals asserted two cycles earlier to pipeline next AHB access.
    kstr_done_early: in  std_logic;     -- Key Stream calculated.
    s2b_done_early : in  std_logic;     -- CRC calculated.
    --------------------------------------
    -- Signals from control structure / MAC header
    --------------------------------------
    firstpack      : in  std_logic;     -- High if MPDU is the first of an MSDU.
    lastpack       : in  std_logic;     -- High if MPDU is the last of an MSDU.
    priority       : in  std_logic_vector( 7 downto 0); -- Priority field.
    --
    address2       : out std_logic_vector(47 downto 0); -- Address 2 field.
    --------------------------------------
    -- Signals for Michael processing
    --------------------------------------
    -- Hardware compliancy with IEEE 802.11i drafts, D4.0 against D6.0 and after
    comply_d6_d4n  : in  std_logic;     -- Low for MIC IV compliancy with D4.0.
    -- Michael initial values.
    l_michael_init : in  std_logic_vector(31 downto 0);
    r_michael_init : in  std_logic_vector(31 downto 0);
    -- Michael block function interface.
    l_michael_out  : in  std_logic_vector(31 downto 0); -- L Michael result.
    r_michael_out  : in  std_logic_vector(31 downto 0); -- R Michael result.
    --
    l_michael_in   : out std_logic_vector(31 downto 0); -- L Michael input.
    r_michael_in   : out std_logic_vector(31 downto 0); -- R Michael input.    
    --------------------------------------
    -- Read Interface
    --------------------------------------
    -- Controls from Keyload block.
    keyload_start_read : in  std_logic; -- Start read process
    keyload_rd_size    : in  std_logic_vector( 3 downto 0);-- Size of read data.
    keyload_rd_addr    : in  std_logic_vector(31 downto 0);-- Add to read data.
    -- Controls from/to AHB interface
    start_read     : out std_logic;     -- Start reading data.
    read_size      : out std_logic_vector( 3 downto 0);-- Size of data to read.
    read_addr      : out std_logic_vector(31 downto 0);-- Address to read data.
    --
    read_done      : in  std_logic;     -- All data read.
    read_done_dly  : in  std_logic;     -- read_done delayed by one clock cycle.
    -- Data
    read_word0     : in  std_logic_vector(31 downto 0);-- Read word 0.
    read_word1     : in  std_logic_vector(31 downto 0);-- Read word 1.
    read_word2     : in  std_logic_vector(31 downto 0);-- Read word 2.
    read_word3     : in  std_logic_vector(31 downto 0);-- Read word 3.
    --------------------------------------
    -- Write Interface
    --------------------------------------
    -- Controls
    start_write    : out std_logic;     -- Start writing data.
    write_size     : out std_logic_vector( 3 downto 0);-- Size of data to write.
    write_addr     : out std_logic_vector(31 downto 0);-- Address to write data.
    --
    write_done     : in  std_logic;     -- All data written.
    -- Data
    write_word0    : out std_logic_vector(31 downto 0);-- Word 0 to be written.
    write_word1    : out std_logic_vector(31 downto 0);-- Word 1 to be written.
    write_word2    : out std_logic_vector(31 downto 0);-- Word 2 to be written.
    write_word3    : out std_logic_vector(31 downto 0);-- Word 3 to be written.
    --------------------------------------
    -- Key Stream
    --------------------------------------
    kstr_word0     : in  std_logic_vector(31 downto 0);
    kstr_word1     : in  std_logic_vector(31 downto 0);
    kstr_word2     : in  std_logic_vector(31 downto 0);
    kstr_word3     : in  std_logic_vector(31 downto 0);
    --
    kstr_size      : out std_logic_vector( 3 downto 0);-- Size of data.
    --------------------------------------
    -- CRC
    --------------------------------------
    -- Data fed to the state to byte serializer.
    data2crc_w0    : out std_logic_vector(31 downto 0);
    data2crc_w1    : out std_logic_vector(31 downto 0);
    data2crc_w2    : out std_logic_vector(31 downto 0);
    data2crc_w3    : out std_logic_vector(31 downto 0);
    -- CRC results.
    crc_out_1st    : in  std_logic_vector( 7 downto 0);
    crc_out_2nd    : in  std_logic_vector( 7 downto 0);
    crc_out_3rd    : in  std_logic_vector( 7 downto 0);
    crc_out_4th    : in  std_logic_vector( 7 downto 0);
    -- Number of bytes to serialize
    state2byte_size: out std_logic_vector( 3 downto 0);
    --------------------------------------
    -- SRAM interface
    --------------------------------------
    -- Address, write data, write enable and chip enable from S_Box init.
    sboxinit_address: in  std_logic_vector( 7 downto 0);
    sboxinit_wdata : in  std_logic_vector( 7 downto 0);
    sboxinit_wen   : in  std_logic;
    sboxinit_cen   : in  std_logic;
    -- Address, write data, write enable and chip enable from Key loading.
    key_sr_address : in  std_logic_vector( 8 downto 0);
    key_sr_wdata   : in  std_logic_vector( 7 downto 0);
    key_sr_wen     : in  std_logic;
    key_sr_cen     : in  std_logic;
    -- Address, write data, write enable and chip enable from S-Box Generation.
    sboxgen_address: in  std_logic_vector( 8 downto 0);
    sboxgen_wdata  : in  std_logic_vector( 7 downto 0);
    sboxgen_wen    : in  std_logic;
    sboxgen_cen    : in  std_logic;
    -- Address, write data, write enable and chip enable from Key Stream block.
    kstr_sr_address: in  std_logic_vector( 8 downto 0);
    kstr_sr_wdata  : in  std_logic_vector( 7 downto 0);
    kstr_sr_wen    : in  std_logic;
    kstr_sr_cen    : in  std_logic;
    -- SRAM lines.
    sram_wdata     : out std_logic_vector(7 downto 0);-- Data to be written.
    sram_address   : out std_logic_vector(8 downto 0);-- Address.
    sram_wen       : out std_logic;     -- Write Enable. Inverted logic.
    sram_cen       : out std_logic;     -- Chip Enable. Inverted logic.
    --------------------------------------
    -- Diagnostic port
    --------------------------------------
    rc4_diag       : out std_logic_vector(7 downto 0)
    
  );

  end component;


----------------------
-- File: rc4_sboxinit.vhd
----------------------
  component rc4_sboxinit
  generic (
    addrmax_g  : integer := 8           -- SRAM Address bus width.
  );
  port (
    -- Clocks and resets
    clk         : in  std_logic;        -- Clock.
    reset_n     : in  std_logic;        -- Reset. Inverted logic.
    -- Selector
    start_sbinit: in  std_logic;        -- Starts s-box initialisation.
    sbinit_done : out std_logic;        -- S-box initialisation done.
    -- SRAM:
    sr_wdata    : out std_logic_vector(7 downto 0);-- SRAM write data.
    sr_address  : out std_logic_vector(addrmax_g-1 downto 0);-- SRAM address.
    sr_wen      : out std_logic;        -- SRAM write enable. Inverted logic.
    sr_cen      : out std_logic         -- SRAM Chip Enable. Inverted logic.
  );
  end component;


----------------------
-- File: rc4_keyloading.vhd
----------------------
  component rc4_keyloading
  port (
    -- Clocks and resets
    clk        : in  std_logic;         -- AHB clock.
    reset_n    : in  std_logic;         -- AHB reset. Inverted logic.
    -- Selector
    tkip_mode  : in  std_logic;         -- High when TKIP key mixing used.
    start_keyload:in std_logic;         -- Positive edge starts key loading.
    keyload_done:out std_logic;         -- Flag indicating Key stored in SRAM.
    -- Interrupt
    stopop     : in  std_logic;         -- Stop operation. Stop key loading.
    -- Read Data interface
    rd_size    : out std_logic_vector( 3 downto 0);-- Size of data to read.
    rd_addr    : out std_logic_vector(31 downto 0);-- Addr to read data
    rd_start_read:out std_logic;        -- Positive edge starts read process.
    rd_read_done:in  std_logic;         -- Flag indicating read process done.
    rd_word0   : in  std_logic_vector(31 downto 0);-- Word read.
    rd_word1   : in  std_logic_vector(31 downto 0);-- Word read.
    rd_word2   : in  std_logic_vector(31 downto 0);-- Word read.
    rd_word3   : in  std_logic_vector(31 downto 0);-- Word read.
    tkip_key_w0: in  std_logic_vector(31 downto 0);-- Mixed TKIP key.
    tkip_key_w1: in  std_logic_vector(31 downto 0);-- Mixed TKIP key.
    tkip_key_w2: in  std_logic_vector(31 downto 0);-- Mixed TKIP key.
    tkip_key_w3: in  std_logic_vector(31 downto 0);-- Mixed TKIP key.
    -- SRAM
    sr_wdata   : out std_logic_vector( 7 downto 0);-- SRAM Write data.
    sr_address : out std_logic_vector( 8 downto 0);-- SRAM Address bus.
    sr_wen     : out std_logic;                    -- SRAM write enable.
    sr_cen     : out std_logic;                    -- SRAM chip enable.
    sr_rdata   : in  std_logic_vector( 7 downto 0);-- SRAM Read data.
    -- Registers
    rc4_ksize  : in  std_logic_vector( 7 downto 0);-- Size of the key in bytes
    rc4_kaddr  : in  std_logic_vector(31 downto 0) -- Address of the key.
  );
  end component;


----------------------
-- File: rc4_sboxgenerator.vhd
----------------------
  component rc4_sboxgenerator
  port (
    -- Clocks and resets
    clk        : in  std_logic;         -- AHB clock.
    reset_n    : in  std_logic;         -- AHB reset. Inverted logic.
    -- Selector
    start_sboxgen:in std_logic;         -- Positive edge starts s-box generation
    sboxgen_done:out std_logic;         -- Flag indicating s-box generation done
    -- SRAM
    sr_wdata   : out std_logic_vector( 7 downto 0);-- SRAM Write data.
    sr_address : out std_logic_vector( 8 downto 0);-- SRAM Address bus.
    sr_wen     : out std_logic;                    -- SRAM write enable.
    sr_cen     : out std_logic;                    -- SRAM chip enable.
    sr_rdata   : in  std_logic_vector( 7 downto 0) -- SRAM Read data.
  );
  end component;


----------------------
-- File: rc4_keystream.vhd
----------------------
  component rc4_keystream
  port (
    -- Clocks and resets
    clk        : in  std_logic;         -- AHB clock.
    reset_n    : in  std_logic;         -- AHB reset. Inverted logic.
    -- Selector
    init_keystr: in  std_logic;         -- Positive edge initialises Key Stream.
    start_keystr:in  std_logic;         -- Positive edge starts key stream.
    keystr_done: out std_logic;         -- Flag indicating key stream finished.
    keystr_done_early: out std_logic;   -- Flag set 2 cycles before keystr_done.
    -- Key Stream Words
    key_stream0: out std_logic_vector(31 downto 0);-- Key stream byte 0.
    key_stream1: out std_logic_vector(31 downto 0);-- Key stream byte 1.
    key_stream2: out std_logic_vector(31 downto 0);-- Key stream byte 2.
    key_stream3: out std_logic_vector(31 downto 0);-- Key stream byte 3.
    -- SRAM
    sr_wdata   : out std_logic_vector( 7 downto 0);-- SRAM Write data.
    sr_address : out std_logic_vector( 8 downto 0);-- SRAM Address bus.
    sr_wen     : out std_logic;         -- SRAM write enable. Inverted logic.
    sr_cen     : out std_logic;         -- SRAM chip enable. Inverted logic.
    sr_rdata   : in  std_logic_vector( 7 downto 0);-- SRAM Read data.
    -- Registers
    kstr_size  : in  std_logic_vector( 3 downto 0) -- Size of the data in bytes
  );
  end component;


----------------------
-- File: state2byte.vhd
----------------------
  component state2byte
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
  end component;


----------------------
-- File: michael_blkfunc.vhd
----------------------
  component michael_blkfunc
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

  end component;



 
end rc4_crc_pkg;
