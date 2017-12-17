
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Stream Processor
--    ,' GoodLuck ,'      RCSfile: stream_processor_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.19   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for stream_processor.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/stream_processor/vhdl/rtl/stream_processor_pkg.vhd,v  
--  Log: stream_processor_pkg.vhd,v  
-- Revision 1.19  2005/05/31 15:47:49  Dr.A
-- #BugId:938#
-- New diags
--
-- Revision 1.18  2004/05/04 09:43:15  Dr.A
-- rc4_crc kaddr added in port map.
--
-- Revision 1.17  2003/11/26 08:43:51  Dr.A
-- registers update.
--
-- Revision 1.16  2003/11/12 16:33:58  Dr.A
-- Added endianness converter.
--
-- Revision 1.15  2003/09/29 16:00:37  Dr.A
-- Added crc_debug and removed aes_ksize.
--
-- Revision 1.14  2003/09/23 14:09:59  Dr.A
-- misc changes.
--
-- Revision 1.13  2003/09/03 13:55:48  Dr.A
-- Changed diag_port size.
--
-- Revision 1.12  2003/08/28 15:28:48  Dr.A
-- Changed bsize.
--
-- Revision 1.11  2003/07/16 13:44:47  Dr.A
-- Updated for version 0.09.
--
-- Revision 1.10  2003/07/03 14:41:02  Dr.A
-- Updated.
--
-- Revision 1.9  2003/01/07 09:38:59  Dr.B
-- rs_dec_packet_finished added.
--
-- Revision 1.8  2002/12/12 18:10:23  Dr.B
-- remove extended size.
--
-- Revision 1.7  2002/11/20 11:02:25  Dr.B
-- add addrmax_g generic.
--
-- Revision 1.6  2002/11/13 17:43:26  Dr.B
-- some ports removed.
--
-- Revision 1.5  2002/11/07 16:55:46  Dr.B
-- aes and rs_enc_inter port changes.
--
-- Revision 1.4  2002/10/31 16:11:25  Dr.B
-- changes on subblocks.
--
-- Revision 1.3  2002/10/25 14:08:32  Dr.B
-- sp_loop_access added.
--
-- Revision 1.2  2002/10/25 08:03:43  Dr.B
-- reed solomon and nonce signals added.
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
package stream_processor_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/endianness_converter/vhdl/rtl/endianness_converter.vhd
----------------------
  component endianness_converter
  port (
    --------------------------------------
    -- Data busses
    --------------------------------------
    -- Little endian master interface.
    wdata_i    : in  std_logic_vector(31 downto 0);
    rdata_o    : out std_logic_vector(31 downto 0);
    -- Big endian system interface.
    wdata_o    : out std_logic_vector(31 downto 0);
    rdata_i    : in  std_logic_vector(31 downto 0);

    --------------------------------------
    -- Controls
    --------------------------------------
    acctype    : in  std_logic_vector( 1 downto 0) -- Type of data accessed.
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/STREAM_PROCESSOR/aes_ccm/vhdl/rtl/aes_ccm.vhd
----------------------
  component aes_ccm
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
  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/STREAM_PROCESSOR/rc4_crc/vhdl/rtl/rc4_crc.vhd
----------------------
  component rc4_crc
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk            : in  std_logic;     -- AHB clock.
    reset_n        : in  std_logic;     -- AHB reset. Inverted logic.
    --------------------------------------
    -- Interrupts
    --------------------------------------
    process_done   : out std_logic;     -- Pulse indicating encryption finished.
    crc_int        : out std_logic;     -- Indicates error in CRC.
    mic_int        : out std_logic;     -- Indicates error in MIC.
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
    -- Sizes in bytes
    rc4_ksize      : in  std_logic_vector( 7 downto 0);-- Key size.
    rc4_bsize_lsb  : in  std_logic_vector( 3 downto 0);-- Data buffer size LSB.
    -- Number of data states (16 bytes) to process.
    state_number   : in  std_logic_vector(12 downto 0);
    -- Addresses
    rc4_csaddr     : in  std_logic_vector(31 downto 0);-- Control structure.
    rc4_kaddr      : in  std_logic_vector(31 downto 0);-- Key.
    rc4_saddr      : in  std_logic_vector(31 downto 0);-- Source buffer.
    rc4_daddr      : in  std_logic_vector(31 downto 0);-- Destination buffer.
    rc4_maddr      : in  std_logic_vector(31 downto 0);-- Control structure.
    --------------------------------------
    -- Control structure
    --------------------------------------
    packet_num     : in  std_logic_vector(47 downto 0);
    --------------------------------------
    -- Signals for Michael processing
    --------------------------------------
    -- Hardware compliancy with IEEE 802.11i drafts, D4.0 against D6.0 and after
    comply_d6_d4n  : in  std_logic;     -- Low for MIC IV compliancy with D4.0.
    -- Michael Control signals
    firstpack      : in  std_logic;     -- High if MPDU is the first of an MSDU.
    lastpack       : in  std_logic;     -- High if MPDU is the last of an MSDU.
    -- Michael initial values (from the control structure).
    l_michael_init : in  std_logic_vector(31 downto 0);
    r_michael_init : in  std_logic_vector(31 downto 0);
    -- Michael IV data.
    priority       : in  std_logic_vector( 7 downto 0); -- Priority field.
    --------------------------------------
    -- Read Interface
    --------------------------------------
    -- Controls
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
    -- Write Interface:
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
    -- RC4 SRAM
    --------------------------------------
    sram_wdata     : out std_logic_vector(7 downto 0);-- Data to be written.
    sram_address   : out std_logic_vector(8 downto 0);-- Address.
    sram_wen       : out std_logic;     -- Write Enable. Inverted logic.
    sram_cen       : out std_logic;     -- Chip Enable. Inverted logic.
    --
    sram_rdata     : in  std_logic_vector(7 downto 0);-- Data read.
    --------------------------------------
    -- Diagnostic port
    --------------------------------------
    rc4_diag       : out std_logic_vector(7 downto 0)

  );
  end component;


----------------------
-- Source: Good
----------------------
  component sp_ahb_access
  generic (
    addrmax_g  : integer := 32          -- AHB Address bus width. Minimum = 5.
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic;     
    reset_n      : in  std_logic;      

    --------------------------------------
    -- Interrupts
    --------------------------------------
    sp_init      : in  std_logic;       -- Interrupt occurs -> reinit
    --
    ahb_interrupt : out std_logic;      -- Interrupt line.    

    --------------------------------------
    -- Read Accesses
    --------------------------------------
    start_read   : in  std_logic;       -- Pulse to start read access.
    read_size    : in  std_logic_vector( 3 downto 0); -- Read size in bytes.
    read_addr    : in  std_logic_vector(addrmax_g-1 downto 0); -- Read address.
    --
    read_done    : out std_logic;       -- Flag indicating read done.
    -- Read data words.
    read_word0   : out std_logic_vector(31 downto 0);
    read_word1   : out std_logic_vector(31 downto 0);
    read_word2   : out std_logic_vector(31 downto 0);
    read_word3   : out std_logic_vector(31 downto 0);

    --------------------------------------
    -- Write Accesses
    --------------------------------------
    start_write  : in  std_logic;       -- Pulse to start write access.
    write_size   : in  std_logic_vector( 3 downto 0); -- Write size in bytes.
    write_addr   : in  std_logic_vector(addrmax_g-1 downto 0); -- Write address.
    -- Data to write.
    write_word0  : in  std_logic_vector(31 downto 0);
    write_word1  : in  std_logic_vector(31 downto 0);
    write_word2  : in  std_logic_vector(31 downto 0);
    write_word3  : in  std_logic_vector(31 downto 0);
    --
    write_done   : out std_logic;       -- Flag indicating data written.

    --------------------------------------
    -- AHB Master interface
    --------------------------------------
    hgrant        : in  std_logic;                      -- Bus grant.
    hready        : in  std_logic;                      -- AHB Slave ready.
    hresp         : in  std_logic_vector( 1 downto 0);  -- AHB Transfer response.
    hrdata        : in  std_logic_vector(31 downto 0);  -- AHB Read data bus.
    --
    hwdata        : out std_logic_vector(31 downto 0);  -- AHB Write data bus.
    hbusreq       : out std_logic;                      -- Bus request.
    htrans        : out std_logic_vector( 1 downto 0);  -- AHB Transfer type.
    hwrite        : out std_logic;                      -- Write request
    haddr         : out std_logic_vector(addrmax_g-1 downto 0); -- AHB Address.
    hburst        : out std_logic_vector( 2 downto 0);  -- Burst transfer.
    hsize         : out std_logic_vector( 2 downto 0);  -- Transfer size.

    --------------------------------------
    -- Diagnostic port
    --------------------------------------
    diag          : out std_logic_vector(7 downto 0)
  );

  end component;


----------------------
-- File: sp_registers.vhd
----------------------
  component sp_registers
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    pclk         : in  std_logic;   -- APB clock.
    presetn      : in  std_logic;   -- APB reset.Inverted logic.
    --------------------------------------
    -- APB interface
    --------------------------------------
    paddr        : in  std_logic_vector(4 downto 0);-- APB Address.
    psel         : in  std_logic;   -- Selection line.
    pwrite       : in  std_logic;   -- 0 => Read; 1 => Write.
    penable      : in  std_logic;   -- APB enable line.
    pwdata       : in  std_logic_vector(31 downto 0);-- APB Write data bus.
    --
    prdata       : out std_logic_vector(31 downto 0);-- APB Read data bus.
    --------------------------------------
    -- Interrupts
    --------------------------------------
    process_done : in  std_logic;   -- Pulse indicating encryption finished.
    dataflowerr  : in  std_logic;   -- Pulse indicating data flow error.
    crcerr       : in  std_logic;   -- Pulse indicating CRC error.
    micerr       : in  std_logic;   -- Pulse indicating MIC error.
    --
    interrupt    : out std_logic;   -- Stream Processor interrupt.
    --------------------------------------
    -- Registers
    --------------------------------------
    startop      : out std_logic;   -- Pulse that starts the en/decryption.
    stopop       : out std_logic;   -- Pulse that stops the en/decryption.
    crc_debug    : out std_logic;   -- Enable CRC written to control structure.
    strpcsaddr   : out std_logic_vector(31 downto 0); -- Control struct address.
    strpkaddr    : out std_logic_vector(31 downto 0); -- Key address.
    -- Hardware compliancy with IEEE 802.11i drafts, D4.0 against D6.0 and after
    comply_d6_d4n :out std_logic;   -- Low for MIC IV compliancy with D4.0.
    --------------------------------------
    -- Diagnostic port
    --------------------------------------
    reg_diag     : out std_logic_vector(7 downto 0)

  );
  end component;


----------------------
-- File: str_proc_control.vhd
----------------------
  component str_proc_control
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk             : in  std_logic; -- AHB and APB clock.
    reset_n         : in  std_logic; -- AHB and APB reset. Inverted logic.
    --------------------------------------
    -- Registers interface
    --------------------------------------
    startop         : in  std_logic; -- Pulse that starts the en/decryption.
    stopop          : in  std_logic; -- Pulse that stops the en/decryption.
    --
    process_done    : out std_logic; -- Pulse indicating en/decryption finished.
    mic_int         : out std_logic; -- Interrupt on MIC error.
    --------------------------------------
    -- RC4 Control lines
    --------------------------------------
    rc4_process_done: in  std_logic; -- Pulse indicating RC4 finished.
    rc4_start_read  : in  std_logic; -- Starts read sequence for the RC4.
    rc4_read_size   : in  std_logic_vector( 3 downto 0);  -- Read size.
    rc4_read_addr   : in  std_logic_vector(31 downto 0);  -- Read address.
    rc4_start_write : in  std_logic; -- Starts write sequence for the RC4.
    rc4_write_size  : in  std_logic_vector( 3 downto 0);  -- Write size.
    rc4_write_addr  : in  std_logic_vector(31 downto 0);  -- Write address.
    rc4_mic_int     : in  std_logic; -- Interrupt on RC4-TKIP MIC error.
    --
    rc4_startop     : out std_logic; -- Pulse to launch RC4 algorithm.
    --------------------------------------
    -- AES Control lines
    --------------------------------------
    aes_process_done: in  std_logic; -- Pulse indicating AES finished.
    aes_start_read  : in  std_logic; -- Starts read sequence for the AES.
    aes_read_size   : in  std_logic_vector( 3 downto 0);  -- Size of read data.
    aes_read_addr   : in  std_logic_vector(31 downto 0);  -- Read address.
    aes_start_write : in  std_logic; -- Positive edge starts AHB write.
    aes_write_size  : in  std_logic_vector( 3 downto 0);  -- Size of write data
    aes_write_addr  : in  std_logic_vector(31 downto 0);  -- Write address.
    aes_mic_int     : in  std_logic; -- Interrupt on AES-CCMP MIC error.
    --
    aes_startop     : out std_logic; -- Pulse to launch AES algorithm.
    --------------------------------------
    -- AHB interface control lines
    --------------------------------------
    read_done       : in  std_logic; -- AHB read done.
    --
    start_read      : out std_logic; -- Positive edge starts AHB read.
    read_size       : out std_logic_vector( 3 downto 0); -- Size of data to read
    read_addr       : out std_logic_vector(31 downto 0); -- Read address.
    read_done_dly   : out std_logic; -- AHB read done delayed by one clk cycle.
    start_write     : out std_logic; -- Positive edge starts AHB write.
    write_size      : out std_logic_vector( 3 downto 0); -- Size of data to write
    write_addr      : out std_logic_vector(31 downto 0); -- Write address.
    --------------------------------------
    -- Endianness controls
    --------------------------------------
    -- Type of data accessed: word, halfword, byte, for endian converter.
    acctype         : out std_logic_vector( 1 downto 0);
    --------------------------------------
    -- Data lines
    --------------------------------------
    -- Data read on the AHB.
    read_word0      : in  std_logic_vector(31 downto 0);
    read_word1      : in  std_logic_vector(31 downto 0);
    read_word2      : in  std_logic_vector(31 downto 0);
    read_word3      : in  std_logic_vector(31 downto 0);
    -- RC4 encryption / decryption result or data to write.
    rc4_result_w0   : in  std_logic_vector(31 downto 0); -- RC4 result word 0.
    rc4_result_w1   : in  std_logic_vector(31 downto 0); -- RC4 result word 1.
    rc4_result_w2   : in  std_logic_vector(31 downto 0); -- RC4 result word 2.
    rc4_result_w3   : in  std_logic_vector(31 downto 0); -- RC4 result word 3.
    -- AES encryption / decryption result or data to write.
    aes_result_w0   : in  std_logic_vector(31 downto 0); -- AES Result word 0.
    aes_result_w1   : in  std_logic_vector(31 downto 0); -- AES Result word 1.
    aes_result_w2   : in  std_logic_vector(31 downto 0); -- AES Result word 2.
    aes_result_w3   : in  std_logic_vector(31 downto 0); -- AES Result word 3.
    -- Encryption / decryption result or data to write to AHB interface.
    result_w0       : out std_logic_vector(31 downto 0); -- Result word 0.
    result_w1       : out std_logic_vector(31 downto 0); -- Result word 1.
    result_w2       : out std_logic_vector(31 downto 0); -- Result word 2.
    result_w3       : out std_logic_vector(31 downto 0); -- Result word 3.
    --------------------------------------
    -- Control structure
    --------------------------------------
    -- Address of control structure.
    strpcsaddr      : in  std_logic_vector(31 downto 0);
    --
    rc4_firstpack   : out std_logic;
    rc4_lastpack    : out std_logic;
    opmode          : out std_logic;
    priority        : out std_logic_vector( 7 downto 0);
    strpksize       : out std_logic_vector( 7 downto 0); -- Key size in bytes.
    aes_msize       : out std_logic_vector( 5 downto 0); -- MAC size in bytes.
    strpbsize       : out std_logic_vector(15 downto 0); -- data buffer size.
    state_number    : out std_logic_vector(12 downto 0); -- Nb of 16-byte states
    -- Address of source data.
    strpsaddr       : out std_logic_vector(31 downto 0);
    -- Address of destination data.
    strpdaddr       : out std_logic_vector(31 downto 0);
    strpmaddr       : out std_logic_vector(31 downto 0);
    michael_w0      : out std_logic_vector(31 downto 0);
    michael_w1      : out std_logic_vector(31 downto 0);
    packet_num      : out std_logic_vector(47 downto 0);
    enablecrypt     : out std_logic;   -- Enables (1) or disable (0) encryption
    enablecrc       : out std_logic;   -- Enables (1) or disables CRC operation
    enablemic       : out std_logic;   -- Enables (1) or disables MIC operation
    --------------------------------------
    -- Diagnostic port
    --------------------------------------
    ctrl_diag       : out std_logic_vector(7 downto 0)

  );

  end component;



 
end stream_processor_pkg;
