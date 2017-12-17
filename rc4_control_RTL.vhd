--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream_Processing
--    ,' GoodLuck ,'      RCSfile: rc4_control.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.16   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : State machine and control lines for the RC4 block.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/rc4_crc/vhdl/rtl/rc4_control.vhd,v  
--  Log: rc4_control.vhd,v  
-- Revision 1.16  2005/05/31 15:43:53  Dr.A
-- #BugId:938#
-- New diags
--
-- Revision 1.15  2004/05/04 16:05:14  Dr.A
-- Cleaned comments.
--
-- Revision 1.14  2004/05/04 09:44:39  Dr.A
-- First release of changes to correct MIC on fragmented MSDUs.
--
-- Revision 1.13  2003/12/04 09:31:53  Dr.A
-- Added registers to ease synthesis.
--
-- Revision 1.12  2003/11/26 08:39:18  Dr.A
-- Added D6.0 compliant Michael IV, enabled by register bit.
--
-- Revision 1.11  2003/09/29 16:02:52  Dr.A
-- Added crc_debug.
--
-- Revision 1.10  2003/09/23 14:06:00  Dr.A
-- State_number and read_done_dly moved to str_proc_control. bsize set to 16 bits.
--
-- Revision 1.9  2003/09/15 08:40:44  Dr.A
-- Diagnostic port.
--
-- Revision 1.8  2003/09/10 07:11:17  Dr.A
-- Corrected MIC init value oading. Small FSM changes.
--
-- Revision 1.7  2003/09/03 12:20:09  Dr.A
-- Debugged write address.
--
-- Revision 1.6  2003/09/02 09:24:16  Dr.A
-- Debugged state machine (wait for CRC done before leaving wr_kstr).
-- Changed crc_int generation.
--
-- Revision 1.5  2003/08/28 15:03:51  Dr.A
-- Reworked state machine to pipeline key stream and AHB accesses.
--
-- Revision 1.4  2003/08/21 16:16:34  Dr.A
-- Corrected length of control pulses.
--
-- Revision 1.3  2003/08/13 16:21:56  Dr.A
-- Removed unused port.
--
-- Revision 1.2  2003/08/06 13:48:03  Dr.A
-- Corrected bug in state machine to begin key mixing.
-- Removed useless test when setting saddr and daddr.
--
-- Revision 1.1  2003/07/16 13:20:27  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity rc4_control is
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

end rc4_control;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of rc4_control is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant NULL_CT         : std_logic_vector(31 downto 0) := (others =>'0');
  constant MIC_PADDING_CT  : std_logic_vector(31 downto 0) -- X"0000005A"
                           := "00000000000000000000000001011010";
  -- Constants for MIC and CRC processing.
  constant CRC_SIZE_CT     : std_logic_vector(3 downto 0) := "0100"; -- 4 bytes
  constant MIC_SIZE_CT     : std_logic_vector(3 downto 0) := "1000"; -- 8 bytes
  constant MIC_CRC_SIZE_CT : std_logic_vector(3 downto 0) := "1100"; -- 12 bytes
  constant MIC_FRAG_SIZE_CT     : std_logic_vector(3 downto 0) := "1100"; -- 12b
  constant MIC_FRAG_CRC_SIZE_CT : std_logic_vector(3 downto 0) := "0000"; -- 16b

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type RC4_STATE_TYPE is (idle_state,       -- Idle phase.
                      --
                      rd_mac4_state,      -- Extract SA and DA from MAC header
                      rd_mac8_state,      -- Extract SA and DA from MAC header
                      --
                      rd_frag_state,      -- Read FRAG field from ctrl structure
                      rd_key_state,       -- Read TKIP key from ctrl structure
                      keymix_phase1_state,-- TKIP key mixing, phase 1.
                      keymix_phase2_state,-- TKIP key mixing, phase 2.
                      keytransfer_state,  -- Key_Transfer phase.
                      sboxgenerate_state, -- S-Box Generation phase.
                      --
                      mic_iv0_state,      -- MIC IV processing (four steps for
                      mic_iv1_state,      -- four 32 bits words), done only if
                      mic_iv2_state,      -- first fragment of a TKIP packet 
                      mic_iv3_state,      -- (firstpack = 1).
                      -- States to request AHB access before write data ready.
                      wr_req_state,       -- Set bus request.
                      wr_grant_state,     -- Wait for bus grant (best case).
                      -- Key stream and AHB access pipelined states.
                      rd_kstr_state,      -- RC4 keystream + read next data.
                      wr_kstr_state,      -- RC4 keystream + write result data
                      --
                      select_mic_state,   -- Choose which MIC state to enter.
                      mic_data0_state,    -- MIC processing on message data,
                      mic_data1_state,    -- up to four steps for four 32bit 
                      mic_data2_state,    -- words.
                      mic_data3_state,
                      mic_frag_state,     -- MIC processing on frag and/or pad.
                      mic_padding1_state, -- Michael on a 32bits "0" padding.
                      mic_end_state,      -- End of Michael states.
                      --
                      -- States to request AHB access before write data ready.
                      wrmic_req_state,    -- Set bus request.
                      wrmic_grant_state,  -- Wait for bus grant (best case).
                      wr_miccrc_state,    -- Encryption: write CRC(+MIC) phase.
                      crc_on_mic_state,   -- Decryption: CRC on received MIC.
                      wrcs_req_state,     -- Set bus request.
                      wrcs_grant_state,   -- Wait for bus grant (best case).
                      wr_miccrc_cs_state  -- Write MIC/CRC/both to ctrl struct.
                      );

------------------------------------------------------------------------------
-- Signals
------------------------------------------------------------------------------
--------------------------------------
-- Main State Machine
--------------------------------------
signal rc4_state          : RC4_STATE_TYPE; -- State in the main state machine.
signal next_rc4_state     : RC4_STATE_TYPE; -- Next state in the state machine.
-- "startop" signal memorized till the end of S-Box initialisation.
signal startop_mem        : std_logic;
-- Number of states (16 bytes) en/decrypted.
signal state_counter      : std_logic_vector(12 downto 0);
--------------------------------------
-- Data processing
--------------------------------------
-- Size of the data to process during MIC states: 0 -> less than 1 32bits word,
-- 1 -> between one and two words,  ... 4 -> between 4 and 5 words.
signal mic_size_msb       : std_logic_vector( 2 downto 0);
signal size_key_datan     : std_logic;     -- Control for data size mux.
-- Input/Output Interfaces
signal data_start_read    : std_logic;     -- Flag to start reading data on AHB.
signal int_start_write    : std_logic;     -- Flag to start writing data to AHB.
signal int_read_size      : std_logic_vector( 3 downto 0);-- Read size in bytes
signal int_read_addr      : std_logic_vector(31 downto 0);-- Read/write address.
signal data_size          : std_logic_vector( 3 downto 0);-- Size of data block.
signal data_size_minus1   : std_logic_vector( 3 downto 0);-- data_size - 1.
signal data_saddr         : std_logic_vector(31 downto 0);-- Address to read.
signal data_daddr         : std_logic_vector(31 downto 0);-- Address to write.
signal mic_addr           : std_logic_vector(31 downto 0);-- MIC address.
-- Encryption/Decryption result words.
signal result_w0          : std_logic_vector(31 downto 0);
signal result_w1          : std_logic_vector(31 downto 0);
signal result_w2          : std_logic_vector(31 downto 0);
signal result_w3          : std_logic_vector(31 downto 0);
--------------------------------------
-- Michael data processing
--------------------------------------
-- Bytes remaining from last MPDU, read from control structure.
signal frag               : std_logic_vector(23 downto 0);
-- Number of frag bytes (0 to 3), read from control structure.
signal nb_frag            : std_logic_vector( 1 downto 0);
-- "To DS" and "From DS" MAC header fields, used to find SA and DA among A1-A4.
signal mac_ds             : std_logic_vector( 1 downto 0);
-- SA and DA fields from Mac Header, used in Michael IV.
signal michael_da         : std_logic_vector(47 downto 0);
signal michael_sa         : std_logic_vector(47 downto 0);
-- Third MIC IV word, containing 'priority' field and 0.
signal mic_iv_word3       : std_logic_vector(31 downto 0);
-- Data fed to Michael in first mic_data_state.
signal l_michael_w0       : std_logic_vector(31 downto 0);
signal r_michael_w0       : std_logic_vector(31 downto 0);
-- Plain text data (read_words in TX, result_words in RX).
signal plaindata_w0       : std_logic_vector(31 downto 0);
signal plaindata_w1       : std_logic_vector(31 downto 0);
signal plaindata_w2       : std_logic_vector(31 downto 0);
signal plaindata_w3       : std_logic_vector(31 downto 0);
-- Data sent to Michael block: plain text data shifted to include frag bytes
signal data2mic_w0        : std_logic_vector(31 downto 0);
signal data2mic_w1        : std_logic_vector(31 downto 0);
signal data2mic_w2        : std_logic_vector(31 downto 0);
signal data2mic_w3        : std_logic_vector(31 downto 0);
-- data2mic words used in different mic_data states (data 0 to data3, frag).
signal l_michael_in_w0    : std_logic_vector(31 downto 0);
signal l_michael_in_w1    : std_logic_vector(31 downto 0);
signal l_michael_in_w2    : std_logic_vector(31 downto 0);
signal l_michael_in_w3    : std_logic_vector(31 downto 0);
signal r_michael_in_w0    : std_logic_vector(31 downto 0);
signal r_michael_in_w1    : std_logic_vector(31 downto 0);
signal r_michael_in_w2    : std_logic_vector(31 downto 0);
signal r_michael_in_w3    : std_logic_vector(31 downto 0);
signal l_michael_in_frag  : std_logic_vector(31 downto 0);
signal r_michael_in_frag  : std_logic_vector(31 downto 0);
-- FRAG data completed with Michael padding.
signal frag2mic_pad       : std_logic_vector(31 downto 0);
--------------------------------------
-- Key Stream
--------------------------------------
signal int_kstr_size      : std_logic_vector( 3 downto 0);-- Size of keystream.
--------------------------------------
-- Diagnostic ports
--------------------------------------
signal rc4_state_diag     : std_logic_vector( 3 downto 0);
------------------------------------------------------ End of Signal declaration


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  ----------------------------------------------------- Internal copies of ports
  kstr_size  <= int_kstr_size;
  write_size <= data_size;
  read_size  <= int_read_size;
  read_addr  <= int_read_addr;
  -- Diagnostic port.
  rc4_diag(7 downto 6) <= "00";
  rc4_diag(5 downto 4) <= mac_ds;
  rc4_diag(3 downto 0) <= rc4_state_diag;
  ---------------------------------------------- End of Internal copies of ports

  ------------------------------------------------------- startop_mem Generation
  -- This process creates the signal 'startop_mem', used in the main state
  -- machine. This signal memorizes the 'startop' pulse when it is received
  -- during the S-Box initialisation. The signal is reset when the S-Box
  -- initialization is over: a 'startop' pulse received after initialisation
  -- is read directly by the state machine. When the RC4 is disabled, the FSM
  -- starts even if the S-Box init is not over, so the startop_mem signal is
  -- reset.
  startop_mem_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      startop_mem <= '0';
    elsif (clk'event and clk = '1') then
      if sbinit_done = '0' and enablecrypt = '1' then
        if startop = '1' then
          startop_mem <= '1';
        end if;
      else
        startop_mem <= '0';
      end if;
    end if;
  end process startop_mem_pr;
  ------------------------------------------------ End of startop_mem Generation

  ----------------------------------------------------------- Main State Machine
  -- This is the State Machine of the RC4 processor. It goes through the
  -- following steps:
  --  * First, the S-Box is initialized.
  --  * When a cryptographic operation is launched, the key must be computed. In
  -- TKIP mode, the key is first mixed in the tkip_key_mixing block. In others
  -- modes, this step is skippped. Then, the key is loaded into the RC4 SRAM and
  -- the S-Box generation is done. in TKIP mode, four MIC IV states are done
  -- during the key transfer state if the firstpack flag is set.
  --  * The rd*_mac_state states are used to retreive data from the MAC header 
  -- when necessary (TKIP key mixing and Michael IV processing). The rd_frag
  -- state is used to retreive frag data from the control structure (fragment
  -- of the last MPDU that must be processed with the current MPDU)
  --  * The basic RC4 scheme is a rd_kstr_data state, where the data is read
  -- from the source buffer while a RC4 key stream is generated, followed by the
  -- wr_kstr_state state, where the read data xor'ed with the key stream is
  -- written in the destination buffer while the next RC4 key stream generation
  -- begins.
  --  * In TKIP mode, Michael processing is added on the plaintext data. That is
  -- why MIC states take place when the data has just been read in encryption
  -- mode, and when the data is ready to be written in decryption mode.
  --  * Following the mode, the encrypted CRC and MIC must be written at the end
  -- of the destination buffer. The plaintext CRC and MIC must be written in the
  -- control structure. The frag data is also updated in the control structure.
  
  fsm_comb_pr: process (enablecrc, enablecrypt, enablemic, firstpack,
                        keyload_done, keymix1_done, keymix2_done, kstr_done,
                        kstr_done_early, lastpack, mac_ds, mic_size_msb,
                        michael_done, opmode, rc4_state, read_done,
                        read_done_dly, s2b_done, s2b_done_early, sbinit_done,
                        sboxgen_done, startop, startop_mem, state_counter,
                        state_number, stopop, write_done)
  begin
    if stopop = '1' then
      next_rc4_state <= idle_state;
    else
      case rc4_state is


        --------------------------------------------
        -- Idle state.
        --------------------------------------------

        -- Idle state: the S-Box is initialized with the values 0-255.
        when idle_state =>
          if (startop = '1' or startop_mem = '1') then -- order to start.
            -- RC4 disabled, no need to wait for end of S-Box init.
            if (enablecrypt = '0') then
              next_rc4_state <= rd_kstr_state;
            elsif (sbinit_done = '1') then  -- S-Box initialized.
              if enablemic = '1' then       -- Go to TKIP key mixing states.
                next_rc4_state <= rd_mac4_state;
              else                          -- No key mixing.
                next_rc4_state <= keytransfer_state;
              end if;
            else
              next_rc4_state <= idle_state; -- Wait for S-Box init.
            end if;
          else
            next_rc4_state <= idle_state;   -- Wait for startop.
          end if;
             

        --------------------------------------------
        -- States for TKIP key mixing.
        --------------------------------------------

        -- Read first four words of MAC header.
        when rd_mac4_state =>
          -- Wait one more clock cycle (read_done_dly), so that read result 
          -- mac_ds is registered.
          if read_done = '1' and read_done_dly = '1' then
            -- DA and SA found in mac4, or not used, no need to read more.
            -- Read the frag control structure field.
            if mac_ds = "00" or firstpack = '0' then
              next_rc4_state <= rd_frag_state;
            else -- Read end of MAC header.
              next_rc4_state <= rd_mac8_state;
            end if;
          else   -- Wait for end of read.
            next_rc4_state <= rd_mac4_state;
          end if;

        -- Read 4 last MAC header words.
        when rd_mac8_state =>
          if read_done = '1' then -- Read the frag control structure field.
            next_rc4_state <= rd_frag_state;
          else                    -- Wait for end of read.
            next_rc4_state <= rd_mac8_state;
          end if;
          
        -- Read the frag control structure field.
        when rd_frag_state =>
          if read_done = '1' then -- Read the temporal key for key mixing.
            next_rc4_state <= rd_key_state;
          else                    -- Wait for end of read.
            next_rc4_state <= rd_frag_state;
          end if;
        
        -- Read the temporal key for key mixing.
        when rd_key_state =>
          if read_done = '1' then -- Start key mixing phase 1.
            next_rc4_state <= keymix_phase1_state;
          else                    -- Wait for end of read.
            next_rc4_state <= rd_key_state;
          end if;
        
        -- TKIP key mixing phase 1.  
        when keymix_phase1_state =>
          if keymix1_done = '1' then -- Start key mixing phase 2.
            next_rc4_state <= keymix_phase2_state;
          else                       -- Wait for end of key mixing first phase.
            next_rc4_state <= keymix_phase1_state;
          end if;
            
        -- TKIP key mixing phase 2.  
        when keymix_phase2_state =>
          if keymix2_done = '1' then -- Load key in SRAM.
            next_rc4_state <= keytransfer_state;
          else                       -- Wait for end of key mixing phase 2.
            next_rc4_state <= keymix_phase2_state;
          end if;
            

        --------------------------------------------
        -- States for key load and Michael IV processing.
        --------------------------------------------

        -- Key transfer: the key is loaded in the SRAM.
        when keytransfer_state =>
          -- In case of firstpack fragment, compute MIC IV at the same time.
          if firstpack = '1' then
            next_rc4_state <= mic_iv0_state;
          -- No MIC IV to compute, generate S-Box after Key transfer.
          elsif keyload_done = '1' then
            next_rc4_state <= sboxgenerate_state;
          else -- Key transfer not yet finished.
            next_rc4_state <= keytransfer_state;
          end if;

        -- The IV block is 16-bytes long. Michael IV processing takes 4 steps.
        when mic_iv0_state =>
          if michael_done = '1' then
            next_rc4_state <= mic_iv1_state;
          else
            next_rc4_state <= mic_iv0_state;
          end if;

        -- Michael IV processing.
        when mic_iv1_state =>
          if michael_done = '1' then
            next_rc4_state <= mic_iv2_state;
          else
            next_rc4_state <= mic_iv1_state;
          end if;

        -- Michael IV processing.
        when mic_iv2_state =>
          if michael_done = '1' then
            next_rc4_state <= mic_iv3_state;
          else
            next_rc4_state <= mic_iv2_state;
          end if;

        -- Last Michael IV processing state.
        when mic_iv3_state =>
          -- Exit the state when keyload (begun in keytransfer_state) is done.
          if michael_done = '1' and keyload_done = '1' then
            next_rc4_state <= sboxgenerate_state;
          else
            next_rc4_state <= mic_iv3_state;
          end if;

        -- Generate S-Box values.
        when sboxgenerate_state =>
          if sboxgen_done = '1' then  -- S-Box generation finished.
            next_rc4_state <= rd_kstr_state; -- Start data processing.
          else                        -- S-Box generation not yet finished.
            next_rc4_state <= sboxgenerate_state;
          end if;
        

        --------------------------------------------
        -- States for en/decryption and AHB accesses.
        --------------------------------------------
        
        -- Key stream and AHB accesses are pipelined in the following way, so
        -- that the RC4 block cipher is used at full speed:
        --
        --                 <- Key stream for Data2 -->
        --                           <-- Data2 AHB accesses --->
        --  ________ ______ _________ ________ ______ _________ ________ ______
        -- X_read_1_-_wait_X_write_1_X_read_2_-_wait_X_write_2_X_read_3_-_wait_X
        --  _______________ _________________________ _________________________
        -- X_kstr_1________X_________kstr_2__________X________kstr_3___________X
        --                 |                         |                         |
        --             kstr_done                 kstr_done             kstr_done
        --  _______________|_________ _______________|_________ _______________|
        -- X____rd_kstr____X_wr_kstr_X____rd_kstr____X_wr_kstr_X____rd_kstr____X
        --
        --  The states used in the FSM are the rd_kstr and wr_kstr states.
        --

        -- The MIC must be computed on decrypted data. Therefore, it is computed
        -- when read is done on encryption mode, and in parallel with write
        -- states on decryption mode.
        
        -- For encryptions, the last key stream state is a wr_kstr_state where
        -- the last encrypted data is saved while the key stream is
        -- generated to encrypt the CRC (and MIC) if needed.
        -- For decryptions, the last key stream state is a rd_kstr_state where
        -- the CRC (and MIC) are read from the source buffer while the key
        -- stream is generated to encrypt the computed CRC (and MIC). This
        -- last state is skipped when RC4 is disabled.
        
        -- The wr_kstr_state / wr_crcmic_state / wr_crcmic_cs_state are the
        -- states where data to write is available. Two others states are used
        -- before to request the bus. So, when the next state is a write access,
        -- the current state must be exited two clock cycles before it really
        -- ends. This is done using the *_done_early signals. Note that a 
        -- write_done_early signal is not needed, because write_done is asserted
        -- as soon as the bus is released. 
        
        -- Generate key stream for next data and read next data.
        when rd_kstr_state =>          
          if read_done = '1' then -- Read data available.
            
            -- In case of encryption in TKIP mode, launch Michael on read data.
            if (opmode = '1') and (enablemic = '1') then
              next_rc4_state <= select_mic_state; -- Go to Michael states.
            
            -- Michael processing not enabled, or decryption.
            elsif kstr_done_early = '1' then -- Key stream almost done.
              
              -- Detect last RX state.
              if (state_counter > state_number) and (opmode = '0') then

                if enablemic = '1' then         -- TKIP mode.
                  if (lastpack = '1') then      -- Last packet: run CRC on MIC.
                    if kstr_done = '1' then     -- Wait for end of key stream.
                      next_rc4_state <= crc_on_mic_state;
                    else
                      next_rc4_state <= rd_kstr_state;
                    end if;
                  else                          -- other packet: save MIC + CRC.
                    next_rc4_state <= wrcs_req_state;
                  end if;

                else                            -- WEP mode.
                  next_rc4_state <= wrcs_req_state; -- Save CRC.
                end if; -- This test should not be reached in RC4 mode.

              else -- Process next data.
                next_rc4_state <= wr_req_state;
              end if;

            else -- Wait for end of key stream processsing.
              next_rc4_state <= rd_kstr_state;
            end if;            
          else -- Wait for end of read.
            next_rc4_state <= rd_kstr_state;
          end if;

        -- Wait while bus request is sent.
        when wr_req_state =>
          next_rc4_state <= wr_grant_state;
                  
        -- Wait while bus is granted.
        when wr_grant_state =>
          next_rc4_state <= wr_kstr_state;
                  
        -- Generate key stream for next data and write current data.
        when wr_kstr_state =>
          
          -- Encryption.
          if opmode = '1' then
            if write_done = '1' then
              
              -- Detect last TX state.
              if state_counter > state_number then -- Last data written.
                if enablecrc = '0' then            -- RC4 mode, or RC4 disabled
                  if (kstr_done = '1' and s2b_done = '1') then
                    next_rc4_state <= idle_state;  -- End of processing
                  else -- wait for end of key stream / CRC.
                    next_rc4_state <= wr_kstr_state;
                  end if;
                else -- WEP or TKIP mode, write MIC/CRC in destination buffer.
                  if (kstr_done_early = '1' and s2b_done_early = '1') then
                    next_rc4_state <= wrmic_req_state;
                  else
                    next_rc4_state <= wr_kstr_state;
                  end if; -- wait for end of key stream / CRC.
                end if;
              else
                if s2b_done = '1' then               -- Encrypt next data
                  next_rc4_state <= rd_kstr_state;
                else -- wait for end of CRC.
                  next_rc4_state <= wr_kstr_state;
                end if;
              end if;
            else -- wait for end of write.
              next_rc4_state <= wr_kstr_state;
            end if;

          -- Decryption.
          else
            if enablemic = '1' then                -- TKIP mode.
              next_rc4_state <= select_mic_state;  -- Michael on decrypted data.

            elsif enablecrc = '1' then             -- WEP mode.
              if (write_done = '1' and kstr_done = '1' and s2b_done = '1') then
                next_rc4_state <= rd_kstr_state;   -- Decrypt next data.
              else                                 -- Wait for write/key stream.
                next_rc4_state <= wr_kstr_state;
              end if;

            else                                   -- RC4 mode, or RC4 disabled.
              if write_done = '1' then
                if state_counter > state_number then
                  next_rc4_state <= idle_state;    -- Last data decrypted.
                else
                  next_rc4_state <= rd_kstr_state; -- Decrypt next data.
                end if;
              else
                next_rc4_state <= wr_kstr_state;   -- Wait for end of write.
              end if;
            end if;
          end if;

          
        --------------------------------------------
        -- States for Michael data processing.
        --------------------------------------------
        
        -- The Michael algorithm operates on a 32bits word. A typical data state
        -- of 16 bytes will hence go through 4 MIC states.
        -- If the MIC data size is not 16 bytes:
        --  * If the MIC data size is not modulo 32 bits, the last bits must be
        -- processed separately as frag bytes. Michael algorithm is run on these
        -- bytes only if lastpack is set.
        --  * MIC states 0 to 2 can be skipped, so that the last MIC state is
        -- always mic_data3_state (followed by mic_frag_state if lastpack is
        -- set)
        -- When lastpack is set, 0x5a padding is included in the frag data and
        -- a 0x00000000 padding state is added.
                
        -- This state is added to improve the code readibility. It redirects
        -- the state machine to the relevant MIC state depending on the number
        -- of 32bit words to process.
        when select_mic_state =>
          -- Test the number of 32bit words to process.
          case mic_size_msb is
            when "000" =>   -- 1  to  3 bytes to process (1 MIC states).
              if (lastpack = '0') then
                -- Less than 32 bits to process, do not run michael algorithm.
                next_rc4_state <= mic_end_state;
              else
                next_rc4_state <= mic_frag_state;
              end if;
            when "001" =>   -- 4 to  7  bytes to process (2 MIC states).
              next_rc4_state <= mic_data3_state;
            when "010" =>   -- 8 to  11 bytes to process (3 MIC states).
              next_rc4_state <= mic_data2_state;
            when "011" =>   -- 12 to 15 bytes to process (4 MIC states).
              next_rc4_state <= mic_data1_state;
            when others =>  -- 16 to 19 bytes to process (5 MIC states).
              next_rc4_state <= mic_data0_state;
          end case;

        -- Michael processing of the first 32-bit data word.
        when mic_data0_state =>
          if michael_done = '1' then
            next_rc4_state <= mic_data1_state;
          else
            next_rc4_state <= mic_data0_state;
          end if;

        -- Michael processing of the second 32-bit data word.
        when mic_data1_state =>
          if michael_done = '1' then
            next_rc4_state <= mic_data2_state;
          else
            next_rc4_state <= mic_data1_state;
          end if;

        -- Michael processing of the third 32-bit data word.
        when mic_data2_state =>
          if michael_done = '1' then
            next_rc4_state <= mic_data3_state;
          else
            next_rc4_state <= mic_data2_state;
          end if;

        -- Michael processing of the last 32-bit data word.
        when mic_data3_state =>
          if michael_done = '1' then
            
            -- Detect last data state of lastpack fragment to go to padding
            -- state.
            if (lastpack = '1') and
                 ((opmode = '1' and state_counter = state_number)
               or (opmode = '0' and state_counter > state_number)) then
              next_rc4_state <= mic_frag_state;
            else -- Go on with data processing.
              next_rc4_state <= mic_end_state;
            end if;

          else -- Wait for end of Michael processing.
            next_rc4_state <= mic_data3_state;
          end if;

        -- Michael processing of frag bytes + padding.
        when mic_frag_state =>
          if michael_done = '1' then -- Go to next padding state.
            next_rc4_state <= mic_padding1_state;
          else                       -- Wait for end of Michael processing.
            next_rc4_state <= mic_frag_state;
          end if;

        -- Additional MIC state with 0x00000000 padding.
        when mic_padding1_state =>
          if michael_done = '1' then
            next_rc4_state <= mic_end_state;
          else -- Wait for end of Michael processing.
            next_rc4_state <= mic_padding1_state;
          end if;
          
        -- End of MIC states, go on with data processing.
        when mic_end_state =>
          -- In encryption mode, wait for end of keystream processing.
          if opmode = '1' then
            if (kstr_done_early = '1' and write_done = '1'
                and s2b_done_early = '1') then
              next_rc4_state <= wr_req_state;    -- Write encrypted data.
            else                                 -- Wait for end of Michael.
              next_rc4_state <= mic_end_state;
            end if;

          -- In decryption mode, decrypt next data or MIC/CRC.   
          else
            -- MIC was launched during wr_kstr_state, along with CRC.
            -- Check write and CRC state2byte are over.
            if (write_done = '1') and (s2b_done = '1') then
              next_rc4_state <= rd_kstr_state;
            else -- Wait for end of write or CRC.
              next_rc4_state <= mic_end_state;
            end if;
          end if;


        --------------------------------------------
        -- States to save CRC and MIC.
        --------------------------------------------
        
        -- Wait while bus request is sent.
        when wrmic_req_state =>
          next_rc4_state <= wrmic_grant_state;
                  
        -- Wait while bus is granted.
        when wrmic_grant_state =>
          next_rc4_state <= wr_miccrc_state;
                  
        -- Encryption: write encrypted MIC + CRC to destination buffer.
        when wr_miccrc_state =>
          if write_done = '1' then
            next_rc4_state <= wrcs_req_state;
          else
            next_rc4_state <= wr_miccrc_state;
          end if;

        -- Wait while bus request is sent.
        when wrcs_req_state =>
          next_rc4_state <= wrcs_grant_state;
                  
        -- Wait while bus is granted.
        when wrcs_grant_state =>
          next_rc4_state <= wr_miccrc_cs_state;
                  
        -- Write CRC to control structure for debug.
        -- in TKIP mode, write intermediary MIC and frag field.
        when wr_miccrc_cs_state =>
          if write_done = '1' then
            next_rc4_state <= idle_state;
          else
            next_rc4_state <= wr_miccrc_cs_state;
          end if;

        -- Decryption: compute CRC on decrypted MIC data.
        when crc_on_mic_state =>
          if s2b_done_early = '1' then -- CRC done.
            next_rc4_state <= wrcs_req_state;
          else
            next_rc4_state <= crc_on_mic_state;
          end if;

        when others =>
          next_rc4_state <= idle_state;

      end case;
    end if;
  end process fsm_comb_pr;
  
  -- State machine sequential process
  fsm_seq_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      rc4_state <= idle_state;          -- State Machine starts on idle state.
    elsif clk'event and clk = '1' then
      rc4_state <= next_rc4_state;      -- Update the State Machine.
    end if;
  end process fsm_seq_pr;

  ---------------------------------------------------- End of Main State Machine

  ------------------------------------------------- process_done flag generation
  -- The flag process_done is set to '1' when the encryption/decryption 
  -- operation has finished.  
  done_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      process_done <= '1';
    elsif clk'event and clk = '1' then
      if (next_rc4_state = idle_state
          and startop_mem = '0' and startop = '0') then
        process_done <= '1';
      else
        process_done <= '0';
      end if;
    end if;
  end process done_pr;
  ------------------------------------------ End of process_done flag generation

  -------------------------------------------------------- MAC header processing
  -- The SA and DA fields must be retrieved from the MAC header to be used as
  -- Michael IV data. The A2 (address 2) field is used in TKIP key mixing.
  -- When reading the MAC header first part, the Frame Control field is decoded
  -- to know which of the four address fields (A1, A2, A3, A4) contain SA and
  -- DA.
  mac_header_pr: process (clk, reset_n)
    variable to_ds_v    : std_logic;
    variable from_ds_v  : std_logic;
  begin
    if reset_n = '0' then
      to_ds_v    := '0';
      from_ds_v  := '0';
      michael_sa <= (others => '0');
      michael_da <= (others => '0');
      mac_ds     <= (others => '0');
      address2   <= (others => '0');

    elsif (clk'event and clk = '1') then

      -- First part of the MAC is available on read_wordX.
      if rc4_state = rd_mac4_state and read_done = '1' then
        -- Register to_ds and from_ds.
        from_ds_v  := read_word0(9);
        to_ds_v    := read_word0(8);
        mac_ds     <= to_ds_v & from_ds_v;
        -- Decode DS field.
        if to_ds_v = '0' then   -- DA occupies field A1.
          michael_da <= read_word2(15 downto 0) & read_word1;
        end if;
        if from_ds_v = '0' then -- SA occupies field A2.
          michael_sa <= read_word3 & read_word2(31 downto 16);
        end if;
        -- Save address2 field.
        address2     <= read_word3 & read_word2(31 downto 16);

      -- Second part of the MAC is available on read_wordX.
      elsif rc4_state = rd_mac8_state and read_done = '1' then
        -- Decode DS field.
        case mac_ds is
          when "01" => -- SA occupies field A3.
            michael_sa <= read_word1(15 downto 0) & read_word0;
          when "10" => -- DA occupies field A3.
            michael_da <= read_word1(15 downto 0) & read_word0;
          when "11" => -- DA occupies field A3 and SA field A4.
            michael_da <= read_word1(15 downto 0) & read_word0;
            michael_sa <= read_word3(15 downto 0) & read_word2;
          when others => -- DA and SA loaded during rd_mac4_state.
            null;
        end case;
      end if;

    end if;
  end process mac_header_pr;
  ------------------------------------------------- End of MAC header processing

  ------------------------------------------------------- Block Selector decoder
  -- This process decodes the state in the main state machine to start the
  -- different blocks composing the RC4.
  selector_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      start_sbinit   <= '1';
      start_keyload  <= '0';
      start_sboxgen  <= '0';
      init_keystr    <= '0';
      start_keystr   <= '0';
      start_michael  <= '0';
      start_keymix   <= '0';
      key1_key2n     <= '1';
      
    elsif clk'event and clk = '1' then
      if enablecrypt = '1' then         -- Enable encryption/decryption.
        if next_rc4_state /= rc4_state then -- At the beginning of the state.
          -- Reset all signals (pulses).
          start_keyload  <= '0';
          start_sboxgen  <= '0';
          init_keystr    <= '0';
          start_keystr   <= '0';
          start_michael  <= '0';
          start_keymix   <= '0';

          case next_rc4_state is

            when idle_state =>          
              start_sbinit   <= '1';    -- Start S-Box initialisation and
              init_keystr    <= '1';    -- reset the Key Stream block.
              
            when keymix_phase1_state =>
              start_keymix   <= '1';    -- Start key mixing block.
              key1_key2n     <= '1';    -- Select phase 1.

            when keymix_phase2_state =>
              start_keymix   <= '1';    -- Start key mixing block.
              key1_key2n     <= '0';    -- Select phase 2.

            when keytransfer_state =>
              start_keyload  <= '1';    -- Start the Key Loading.

            when sboxgenerate_state =>  
              start_sboxgen  <= '1';    -- Start the S-Box generation.

            when mic_data0_state | mic_data1_state |
                 mic_data2_state | mic_data3_state |
                   mic_iv0_state | mic_iv1_state   | mic_padding1_state |
                   mic_iv2_state | mic_iv3_state   | mic_frag_state  =>
              start_michael  <= '1';    -- Start the Michael block function.

            when wr_kstr_state =>
              -- Last key stream (state_counter = state_number) is to encrypt
              -- the CRC. Do not start key stream during last wr_kstr_state if
              -- CRC is not enabled.
              if (state_counter < state_number) or (enablecrc = '1') then
                start_keystr <= '1';    -- Start the KeyStream process.
              end if;
              
            when rd_kstr_state =>
              -- Key stream is started on first rd_kstr_state only. Else it is 
              -- started on wr_kstr_state.
              if state_counter = 0 then
                start_keystr <= '1';    -- Start the KeyStream process.
              end if;
              
            when others =>
              null;

          end case;
        else
          -- Reset all signals (pulses).
          start_keyload  <= '0';
          start_sboxgen  <= '0';
          init_keystr    <= '0';
          start_keystr   <= '0';
          start_michael  <= '0';
          start_keymix   <= '0';
          -- First startop after reset (next_rc4_state = rc4_state = idle_state)
          if (next_rc4_state = idle_state  
              and sbinit_done = '0' and startop = '1') then
            start_sbinit   <= '1';    -- Start S-Box initialisation.
          else
            start_sbinit <= '0';      -- Reset start_sbinit (pulse).
          end if;
        end if;
      else -- RC4 disabled.
        start_sbinit   <= '0';
        start_keyload  <= '0';
        start_sboxgen  <= '0';
        init_keystr    <= '0';
        start_keystr   <= '0';
        start_michael  <= '0';
      end if;
    end if;
  end process selector_pr;
  ------------------------------------------------ End of Block Selector decoder

  --------------------------------------------------------- SRAM lines Selection
  -- This process multiplexes the address and data lines of the differents
  -- blocks to access the SRAM.
  mux_ram_pr: process (key_sr_address, key_sr_cen, key_sr_wdata, key_sr_wen,
                       kstr_sr_address, kstr_sr_cen, kstr_sr_wdata,
                       kstr_sr_wen, rc4_state, sboxgen_address, sboxgen_cen,
                       sboxgen_wdata, sboxgen_wen, sboxinit_address,
                       sboxinit_cen, sboxinit_wdata, sboxinit_wen)
  begin
    case rc4_state is
      when idle_state =>                -- The S_Box is being initialised.
        sram_address <= '0' & sboxinit_address;
        sram_wdata   <= sboxinit_wdata;
        sram_wen     <= sboxinit_wen;
        sram_cen     <= sboxinit_cen;

      -- The MIC IV states are done during key transfer.
      when keytransfer_state | mic_iv0_state | mic_iv1_state |
                               mic_iv2_state | mic_iv3_state =>
        sram_address <= key_sr_address;
        sram_wdata   <= key_sr_wdata;
        sram_wen     <= key_sr_wen;
        sram_cen     <= key_sr_cen;

      when sboxgenerate_state =>
        sram_address <= sboxgen_address;
        sram_wdata   <= sboxgen_wdata;
        sram_wen     <= sboxgen_wen;
        sram_cen     <= sboxgen_cen;

      -- The MIC states are done during keystream generation. The *_req_state 
      -- can happen at the end of key stream (kstr_done_early)
      when wr_kstr_state | rd_kstr_state | select_mic_state | mic_end_state |
              mic_data0_state | mic_data1_state | mic_padding1_state |
              mic_data2_state | mic_data3_state | mic_frag_state |
                 wr_req_state | wrmic_req_state | wrcs_req_state =>
        sram_address <= kstr_sr_address;
        sram_wdata   <= kstr_sr_wdata;
        sram_wen     <= kstr_sr_wen;
        sram_cen     <= kstr_sr_cen;

      when others =>
        sram_address <= (others => '0');
        sram_wdata   <= (others => '0');
        sram_wen     <= '1';
        sram_cen     <= '1';

    end case;
  end process mux_ram_pr;
  -------------------------------------------------- End of SRAM lines Selection

  ------------------------------------------ start_read & start_write Generation
  -- This process creates the start_read and start_write signals, sent to the
  -- sp_ahb_access block.
  start_read_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_start_read <= '0';
      int_start_write <= '0';

    elsif clk'event and clk = '1' then
      -- Reset signals (pulses).
      data_start_read <= '0';
      int_start_write <= '0';
      
      if next_rc4_state /= rc4_state then  -- Only when it enters the state.

        case next_rc4_state is -- The signals will be set with rc4_state.

          -- Read the data to en/decrypt from source buffer.
          when rd_kstr_state | rd_frag_state | rd_key_state |
               rd_mac4_state | rd_mac8_state =>
            data_start_read <= '1';
            int_start_write <= '0';

          -- Write the result/MIC+CRC.
          when wr_req_state | wrmic_req_state | wrcs_req_state =>
            data_start_read <= '0';
            int_start_write <= '1';

          when others =>
            null;

        end case;
      end if;
    end if;
  end process start_read_pr;

  -- generate signals for the sp_ahb_access block.
  start_read  <= data_start_read or keyload_start_read;
  start_write <= int_start_write;
  ----------------------------------- End of start_read & start_write Generation
  data_size_minus1 <= data_size - 1;
  
  ----------------------------------------------- Data size & address Generation
  -- MIC IV processing is launched during keytransfer state, so send 
  -- keyload_rd_size on int_read_size during keytransfer_state and all MIC IV
  -- states. Else use data_size.
  -- Register mux selection signal to ease synthesis.
  read_sel_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      size_key_datan <= '0'; -- Data size.
    elsif clk'event and clk = '1' then
      if (next_rc4_state = keytransfer_state
          or next_rc4_state = mic_iv0_state
          or next_rc4_state = mic_iv1_state
          or next_rc4_state = mic_iv2_state
          or next_rc4_state = mic_iv3_state) then
        size_key_datan <= '1'; -- Size from keyload block.
      else
        size_key_datan <= '0'; -- Data size.
      end if;
    end if;
  end process read_sel_p;
    
  int_read_size  <= keyload_rd_size when size_key_datan = '1'
              else data_size;

  -- MIC IV processing is launched during keytransfer state, so send 
  -- keyload_rd_addr on int_read_addr during keytransfer_state and all MIC IV
  -- states. Use specific offset in the control structure to read the key. Use
  -- value in the maddr field to read the MAC header. Else use data buffer
  -- source address.
  int_read_addr  <= keyload_rd_addr when (rc4_state = keytransfer_state
                                        or rc4_state = mic_iv0_state
                                        or rc4_state = mic_iv1_state
                                        or rc4_state = mic_iv2_state
                                        or rc4_state = mic_iv3_state)
              else rc4_csaddr + "100100" when rc4_state = rd_frag_state
              else rc4_kaddr             when rc4_state = rd_key_state
              else rc4_maddr             when rc4_state = rd_mac4_state
              else rc4_maddr + "10000"   when rc4_state = rd_mac8_state
              else data_saddr;

  -- Register MIC address to ease synthesis path.
  mic_addr_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      mic_addr <= (others => '0');
    elsif clk'event and clk = '1' then
      if startop = '1' then
        mic_addr <= rc4_csaddr + "011100";
      end if;
    end if;
  end process mic_addr_p;
  
  -- Write address is destination data buffer address, except when the CRC or
  -- the CRC+MIC are written in the control structure.
  write_addr <= mic_addr when rc4_state = wr_miccrc_cs_state
           else data_daddr;
  
  ---------------------------------------- End of data size & address Generation

  ----------------------------------------------------- state_counter Generation
  -- This process counts the number of data states (16 bytes) processed through
  -- the RC4 cipher.
  state_counter_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      state_counter <= (others => '0');

    elsif clk'event and clk = '1' then
      if next_rc4_state /= rc4_state then -- At the beginning of the state.

        case next_rc4_state is

          when idle_state =>    -- Reset counter.
            state_counter  <= (others => '0');

          when wr_kstr_state => -- Increment when a new state is processed.
            state_counter <= state_counter + 1;

          when rd_kstr_state => -- Increment when a new state is processed.
            if state_counter = 0 then -- First data state only.
              state_counter <= state_counter + 1;
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process state_counter_pr;
  ---------------------------------------------- End of state_counter Generation

  --------------------------------------------------------- kstr_size Generation
  
  -- This process generates the signal kstr_size, used to give to the keystream
  -- block the size of the data to en/decrypt.
  int_kstr_size_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      int_kstr_size <= (others => '0');

    elsif clk'event and clk = '1' then
      if next_rc4_state /= rc4_state then

        case next_rc4_state is -- At the beginning of the state.

          -- Set kstr_size to 16 bytes to read MAC header.
          when idle_state =>
            int_kstr_size <= (others => '0');

          -- Set kstr_size to rc4_bsize LSB if data buffer is less than 16 bytes
          when sboxgenerate_state =>
            if state_number = 1 then -- Only one data state (data <= 16 bytes).
              int_kstr_size <= rc4_bsize_lsb;
            else                     -- First data block will be 16 bytes.
              int_kstr_size <= (others => '0'); -- block of 16 bytes.
            end if;

          -- Set kstr_size to process data state, or MIC / CRC.
          when wr_kstr_state =>
            if state_counter = state_number then     -- All data encrypted.
              if lastpack = '1' then 
                int_kstr_size <= MIC_CRC_SIZE_CT;    -- Encrypt MIC+CRC
              else
                int_kstr_size <= CRC_SIZE_CT;        -- Encrypt CRC only.
              end if;
            else                                     -- Data processing.
              if state_counter = state_number-1 then -- Last data to encrypt.
                int_kstr_size <= rc4_bsize_lsb;
              else
                int_kstr_size <= (others => '0');    -- block of 16 bytes.
              end if;
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process int_kstr_size_pr;
  -------------------------------------------------- End of kstr_size Generation

  ------------------------------------------------ Addresses and size generation
  -- This process generate the data source and destination address, and the
  -- data size for AHB accesses. Due to the pipeline between the keystream and
  -- the AHB accesses, the kstr_size signal is delayed to set the AHB data size.
  addr_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_size  <= (others => '0');
      data_saddr <= (others => '0');
      data_daddr <= (others => '0');

    elsif clk'event and clk = '1' then
      if next_rc4_state /= rc4_state then

        case rc4_state is -- When leaving the state.
          
          when idle_state => -- Get ready to read first data or control struct.
            data_saddr <= rc4_saddr;
            data_daddr <= rc4_daddr;
            -- Data to read is <= 16 bytes, and no access to the ctrl structure.
            if state_number = 1 and enablemic = '0' then
              data_size <= rc4_bsize_lsb;
            else -- First access is to the CS, or to read an entire data state.
              data_size <= (others => '0'); -- Read 16 first bytes.
            end if;
            
          when sboxgenerate_state =>        -- Get ready to read first data.
            if state_number = 1 then        -- Data to read is <= 16 bytes.
              data_size <= rc4_bsize_lsb;
            else                            -- Data to read is > 16 bytes.
              data_size <= (others => '0'); -- Read 16 first bytes.
            end if;
            
          when wr_kstr_state =>
            -- Update data size and address at the end of write. In encryption,
            -- and in WEP and RC4 decryptions, this is when leaving
            -- wr_kstr_state.
            if opmode = '1' or enablemic = '0' then
              data_size  <= int_kstr_size;
              -- Update addresses following the size of the previous access.
              if (data_size = 0) then 
                data_saddr(24 downto 4) <= data_saddr(24 downto 4) + 1;
                data_daddr(24 downto 4) <= data_daddr(24 downto 4) + 1;
              else
                data_saddr <= data_saddr + data_size;
                data_daddr <= data_daddr + data_size;
              end if;
            end if;

          -- Update data size and address at the end of write.
          -- Detect end of write for TKIP decryption.
          when mic_end_state =>
            if (opmode = '0') and (next_rc4_state = rd_kstr_state) then
              data_size <= int_kstr_size;
              -- Update addresses following the size of the previous access.
              if (data_size = 0) then 
                data_saddr(24 downto 4) <= data_saddr(24 downto 4) + 1;
                data_daddr(24 downto 4) <= data_daddr(24 downto 4) + 1;
              else
                data_saddr <= data_saddr + data_size;
                data_daddr <= data_daddr + data_size;
              end if;
            end if;

          -- Write MIC+CRC in control structure for TKIP decryption.
          -- (crc_on_mic_state if lastpack, else rd_kstr_state + test)
          when crc_on_mic_state | rd_kstr_state =>
            if ( (state_counter > state_number)
                 and (opmode = '0') and (enablemic = '1') ) then
              if crc_debug = '1' then -- Write MIC + frag field + CRC.
                data_size <= MIC_FRAG_CRC_SIZE_CT;
              else                    -- Write only MIC + frag field.
                data_size <= MIC_FRAG_SIZE_CT;
              end if;
            end if;
          
          -- Write MIC+CRC in control structure for TKIP encryption.
          when wr_miccrc_state =>
            if enablemic = '1' then
              if crc_debug = '1' then -- Write MIC + frag field + CRC.
                data_size <= MIC_FRAG_CRC_SIZE_CT;
              else                    -- Write only MIC + frag field.
                data_size <= MIC_FRAG_SIZE_CT;
              end if;
            end if;
          
          when others =>
            null;

        end case;
      end if;
    end if;
  end process addr_pr;
  ------------------------------------------ End of adresses and size generation

  ---------------------------------------------------------------- XOR Operation
  -- The encrypted/decrypted data is the result of the XOR operation between
  -- the input data and the Key Stream bytes, or only the read_word if the RC4
  -- is not enabled.
  result_w0 <= read_word0 xor kstr_word0 when enablecrypt = '1'-- RC4 enabled.
          else read_word0;                                     -- RC4 disabled.
  result_w1 <= read_word1 xor kstr_word1 when enablecrypt = '1'
          else read_word1;
  result_w2 <= read_word2 xor kstr_word2 when enablecrypt = '1'
          else read_word2;
  result_w3 <= read_word3 xor kstr_word3 when enablecrypt = '1'
          else read_word3;
  --------------------------------------------------------- End of XOR Operation

  ----------------------------------------------------------- Mux for write data
  -- The data to write is the result_wX words, the MIC or the CRC depending on
  -- the state.
  write_data_pr: process(crc_out_1st, crc_out_2nd, crc_out_3rd, crc_out_4th,
                         enablemic, frag, kstr_word0, kstr_word1, kstr_word2,
                         l_michael_out, lastpack, nb_frag, r_michael_out,
                         rc4_state, result_w0, result_w1, result_w2, result_w3)
  begin

    case rc4_state is

      -- Write encrypted MIC and CRC at the end of the destination buffer.
      when wr_miccrc_state =>
        if lastpack = '1' then -- Write MIC and CRC.
          write_word0 <= l_michael_out xor kstr_word0;
          write_word1 <= r_michael_out xor kstr_word1;
          write_word2 <= (crc_out_4th & crc_out_3rd & crc_out_2nd & crc_out_1st)
                          xor kstr_word2;
        else                   -- Write only CRC.
          write_word0 <= (crc_out_4th & crc_out_3rd & crc_out_2nd & crc_out_1st)
                          xor kstr_word0;
          write_word1 <= result_w1; -- Default value is write data.
          write_word2 <= result_w2; -- Default value is write data.
        end if;
        write_word3 <= result_w3;

      -- Write plaintext MIC and CRC + FRAG field in the control structure.
      when wr_miccrc_cs_state =>
        -- If MIC is enabled, write l_mic + r_mic + frag field + CRC.
        if enablemic = '1' then
          write_word0 <= l_michael_out;
        else -- Else, write only CRC.
          write_word0 <= crc_out_4th & crc_out_3rd & crc_out_2nd & crc_out_1st;
        end if;
        -- If MIC is not enabled, data_size is set to 4 so that write_word1 to
        -- write_word3 are not used.
        write_word1 <= r_michael_out;
        -- Write 'zero' if lastpack, else update FRAG information.
        if lastpack = '1' then
          write_word2 <= (others => '0');
        else
          write_word2 <= "000000" & nb_frag & frag;
        end if;
        write_word3 <= crc_out_4th & crc_out_3rd & crc_out_2nd & crc_out_1st;

      -- Write result data in the destination buffer.
      when others =>
        write_word0 <= result_w0;
        write_word1 <= result_w1;
        write_word2 <= result_w2;
        write_word3 <= result_w3;

    end case;

  end process write_data_pr;
    
  ---------------------------------------------------- End of Mux for write data

--==================================== CRC ===================================--

  -------------------------------------------------------------- CRC Multiplexer
  -- This is the process that multiplexes the data lines into the CRC Calculator
  -- During an encryption, the data fed to the CRC is the plaintext message read
  -- from source buffer (read_wordX). In TKIP mode, the MIC is fed to the CRC on
  -- wr_kstr_state (the CRC will be started only on the last wr_kstr_state).
  -- During a decryption, the data fed to the CRC is the decrypted data, i.e.
  -- after XOR operation (result_wX).
  data2crc_w0 <= l_michael_out when (opmode = '1' and lastpack = '1'
                                     and rc4_state = wr_kstr_state)
                 else read_word0 when opmode = '1' -- Encryption.
                 else result_w0;                   -- Decryption.

  data2crc_w1 <= r_michael_out when (opmode = '1' and lastpack = '1'
                                     and rc4_state = wr_kstr_state)
                 else read_word1 when opmode = '1'
                 else result_w1;

  data2crc_w2 <= read_word2 when opmode = '1' else result_w2;

  data2crc_w3 <= read_word3 when opmode = '1' else result_w3;

  ------------------------------------------------------- End of CRC Multiplexer

  ------------------------------------------------------- 'start_s2b' Generation
  -- This process generates the line 'start_s2b' which is a pulse that starts
  -- the CRC calculation. On reception (decryption) it should activate when the
  -- result words are ready to be written. On transmission (encryption) it
  -- should activate when the ReadData block has finished reading the AHB words
  -- and they are ready on the init_wordX lines.

  -- This pulse starts the State2Byte block, which prepares data for the CRC.
  start_s2b_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      start_s2b <= '0';

    elsif clk'event and clk = '1' then
      start_s2b <= '0'; -- Pulse.
      
      if enablecrc = '1' then
        if (rc4_state /= next_rc4_state) then
          if -- When leaving rd_kstr_state (i.e. when read_done) in encryption,
             -- run CRC on plaintext data.
             (rc4_state = rd_kstr_state and opmode = '1'
               and state_counter <= state_number)
             -- When leaving wr_grant_state (i.e. when kstr_done) in
             -- decryption, run CRC on decrypted data.
             or (rc4_state = wr_grant_state and opmode = '0'
               and state_counter <= state_number)
             -- For TKIP mode last packet, run CRC one more time (state_counter
             -- reaches state_number+1 in decryption), on the decrypted MIC.
             or (rc4_state = rd_kstr_state and opmode = '0'
               and state_counter > state_number and lastpack = '1')
             -- When entering last TKIP encryption wr_kstr_state, run CRC on
             -- plaintext MIC.
             or (next_rc4_state = wr_kstr_state and opmode = '1'
                 and lastpack = '1' and state_counter = state_number) then
            start_s2b <= '1';
          end if;
        end if; -- (state change)
      end if; -- (CRC enabled)
    end if;
  end process start_s2b_pr;


  -- CRC size is 8 when it is computed over the MIC (TKIP lastpack).
  state2byte_size <= MIC_SIZE_CT when ( (opmode = '1' and lastpack = '1'
                                         and rc4_state = wr_kstr_state
                                         and state_counter > state_number) -- TX
                                     or (rc4_state = crc_on_mic_state) )   -- RX
                else data_size;

  -- Initialize the CRC when RC4 is launched.
  crc_ld_init <= '1' when rc4_state = idle_state and startop = '1'
            else '0';

  ------------------------------------------------ End of 'start_s2b' Generation

  -------------------------------------------------------- 'crc_calc' Generation
  -- This process generates the signal crc_calc which calculates the CRC for
  -- the available data on every positive edge of the clock. The CRC is launched
  -- one clock cycle after the State2Byte block, and stopped when s2b_done goes
  -- high.
  crc_calc_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      crc_calc <= '0';
    elsif clk'event and clk = '1' then
      crc_calc <= not(s2b_done);
    end if;
  end process crc_calc_pr;
  ------------------------------------------------- End of 'crc_calc' Generation

  -------------------------------------------- CRC and MIC interrupts generation
  -- This process generates the signals which indicates that there has been an
  -- error in the CRC or MIC checking (decryption).
  crc_int_pr: process (clk, crc_out_1st, crc_out_2nd, crc_out_3rd, crc_out_4th,
                       reset_n)
    variable crc_word_v : std_logic_vector(31 downto 0);
  begin
    crc_word_v := (crc_out_4th & crc_out_3rd & crc_out_2nd & crc_out_1st);
    if reset_n = '0' then
      crc_int <= '0';
      mic_int <= '0';

    elsif clk'event and clk = '1' then
      -- Pulse interrupts.
      crc_int <= '0';
      mic_int <= '0';

      -- Check at the end of the decryption.
      if (next_rc4_state = idle_state and rc4_state = wr_miccrc_cs_state
                                      and opmode = '0') then
        if lastpack = '0' then -- CRC check only.
          if crc_word_v /= result_w0 then
            crc_int <= '1';    -- CRC incorrect.
          end if;
        else                   -- TKIP last packet: check also MIC.
          if (l_michael_out /= result_w0 or
              r_michael_out /= result_w1) then
            mic_int <= '1';    -- MIC incorrect.
          end if;
          if crc_word_v /= result_w2 then
            crc_int <= '1';    -- CRC incorrect.
          end if;
        end if; -- (Detect TKIP last packet)
      end if; -- (Detect end of decryption)
    end if;
  end process crc_int_pr;
  ------------------------------------- End of CRC and MIC interrupts generation

--============================ Michael processing ============================--

  ----------------------------------------- Select Michael block function inputs
  -- Always send plaintext data to the Michael block function.
  plaindata_w0 <= read_word0 when opmode = '1' else result_w0;
  plaindata_w1 <= read_word1 when opmode = '1' else result_w1;
  plaindata_w2 <= read_word2 when opmode = '1' else result_w2;
  plaindata_w3 <= read_word3 when opmode = '1' else result_w3;
  
  -- In case the preceeding MPDU's size was not modulo 32 bits, nb_frag bytes
  -- stored in the frag register must be processed before the plaintext data.
  -- This process reorders data before sending it to the Michael algorithm
  -- and update the frag fields.
  data2mic_p : process (clk, reset_n)
    -- variables to compute next values of frag and data to MIC.
    variable data2mic_w0_v : std_logic_vector(31 downto 0);
    variable data2mic_w1_v : std_logic_vector(31 downto 0);
    variable data2mic_w2_v : std_logic_vector(31 downto 0);
    variable data2mic_w3_v : std_logic_vector(31 downto 0);
    variable frag_v        : std_logic_vector(23 downto 0);
    -- variable to compute the number of words sent to Michael algorithm.
    variable mic_size_v    : std_logic_vector( 4 downto 0);
  begin
    if reset_n = '0' then
      -- Reset variables.
      data2mic_w0_v := (others => '0');
      data2mic_w1_v := (others => '0');
      data2mic_w2_v := (others => '0');
      data2mic_w3_v := (others => '0');
      frag_v        := (others => '0');
      mic_size_v    := (others => '0');
      -- Reset data registers.
      data2mic_w0   <= (others => '0');
      data2mic_w1   <= (others => '0');
      data2mic_w2   <= (others => '0');
      data2mic_w3   <= (others => '0');
      -- Register for fragment of data not processed yet.
      frag          <= (others => '0');
      -- Number of bytes saved in frag register.
      nb_frag       <= (others => '0');
      -- Size of the data state including frag bytes (in 32bits words).
      mic_size_msb  <= (others => '0');

    elsif clk'event and clk = '1' then

      -- Read frag and nb_frag in the control structure.
      if (rc4_state = rd_frag_state) then
        frag        <= read_word0(23 downto  0);
        nb_frag     <= read_word0(25 downto 24);

      -- Compute mic_size to use it in select_mic_state.
      elsif (next_rc4_state = select_mic_state) then

        if (data_size /= 0) then
          mic_size_v := ('0' & data_size) + nb_frag;
        else
          mic_size_v := "100" & nb_frag;
        end if;
        -- Keep only MSBs.
        mic_size_msb <= mic_size_v(4 downto 2);

      -- Prepare data to send to the Michael algorithm.
      elsif (rc4_state = select_mic_state) then
        frag_v := (others => '0');

        -- Next nb_frag value.
        nb_frag <= data_size(1 downto 0) + nb_frag;

        -- Process nb_frag bytes from frag register before the block data, and
        -- store unprocessed block bytes in frag register to be processed with
        -- next block.
        case nb_frag is
          when "00" =>  -- No frag bytes to process, data is unchanged.
            data2mic_w0_v := plaindata_w0;
            data2mic_w1_v := plaindata_w1;
            data2mic_w2_v := plaindata_w2;
            data2mic_w3_v := plaindata_w3;

          when "01" =>  -- Shift data to add one frag byte.
            data2mic_w0_v := plaindata_w0(23 downto 0) & frag(7 downto 0);
            data2mic_w1_v := plaindata_w1(23 downto 0) & plaindata_w0(31 downto 24);
            data2mic_w2_v := plaindata_w2(23 downto 0) & plaindata_w1(31 downto 24);
            data2mic_w3_v := plaindata_w3(23 downto 0) & plaindata_w2(31 downto 24);
            frag_v(7 downto 0) := plaindata_w3(31 downto 24);

          when "10" =>  -- Shift data to add two frag byte.
            data2mic_w0_v := plaindata_w0(15 downto 0) & frag(15 downto 0);
            data2mic_w1_v := plaindata_w1(15 downto 0) & plaindata_w0(31 downto 16);
            data2mic_w2_v := plaindata_w2(15 downto 0) & plaindata_w1(31 downto 16);
            data2mic_w3_v := plaindata_w3(15 downto 0) & plaindata_w2(31 downto 16);
            frag_v(15 downto 0) := plaindata_w3(31 downto 16);

          when others => -- Shift data to add three frag byte.
            data2mic_w0_v := plaindata_w0(7 downto 0) & frag;
            data2mic_w1_v := plaindata_w1(7 downto 0) & plaindata_w0(31 downto 8);
            data2mic_w2_v := plaindata_w2(7 downto 0) & plaindata_w1(31 downto 8);
            data2mic_w3_v := plaindata_w3(7 downto 0) & plaindata_w2(31 downto 8);
            frag_v := plaindata_w3(31 downto 8);

        end case;

        -- If less than 16 bytes are processed, Michael states 0 to 2 may be
        -- skipped. This redirects the data2mic words towards the signal used
        -- in the Michael state.
        case mic_size_msb is
          when "000" =>   -- Only Michael frag state used.
            frag_v        := data2mic_w0_v(23 downto 0);

          when "001" =>   -- Only Michael state 3 used.
            frag_v        := data2mic_w1_v(23 downto 0);
            data2mic_w3_v := data2mic_w0_v;

          when "010" =>   -- Michael states 2 to 3 used.
            frag_v        := data2mic_w2_v(23 downto 0);
            data2mic_w3_v := data2mic_w1_v;
            data2mic_w2_v := data2mic_w0_v;

          when "011" =>   -- Michael states 1 to 3 used.
            frag_v        := data2mic_w3_v(23 downto 0);
            data2mic_w3_v := data2mic_w2_v; 
            data2mic_w2_v := data2mic_w1_v; 
            data2mic_w1_v := data2mic_w0_v; 

          when others => -- Michael state 0 to 3 used (default values).
            null;

        end case;

        -- Update registers.
        data2mic_w0 <= data2mic_w0_v;
        data2mic_w1 <= data2mic_w1_v;
        data2mic_w2 <= data2mic_w2_v;
        data2mic_w3 <= data2mic_w3_v;
        frag        <= frag_v;

      end if;
    end if;                        
    
  end process data2mic_p;  


  -- *_michael_w0 values are used during the first MIC data state, which can be
  -- data 0 to 3 or mic_frag_state depending on mic_size_msb. This process sends
  -- *_michael_w0 values to the relevant signal.
  l_micdata_pr : process (l_michael_out, l_michael_w0, mic_size_msb,
                          r_michael_out, r_michael_w0)
  begin
    -- Default values.
    l_michael_in_w0   <= l_michael_w0;
    l_michael_in_w1   <= l_michael_out;
    l_michael_in_w2   <= l_michael_out;
    l_michael_in_w3   <= l_michael_out;
    l_michael_in_frag <= l_michael_out;
    --
    r_michael_in_w0   <= r_michael_w0;
    r_michael_in_w1   <= r_michael_out;
    r_michael_in_w2   <= r_michael_out;
    r_michael_in_w3   <= r_michael_out;
    r_michael_in_frag <= r_michael_out;
    
    case mic_size_msb is
      when "000" =>
        -- Only mic_frag_state used.
        l_michael_in_frag <= l_michael_w0;
        r_michael_in_frag <= r_michael_w0;

      when "001" =>
        l_michael_in_w3 <= l_michael_w0;
        r_michael_in_w3 <= r_michael_w0;

      when "010" =>   -- Michael states 2 to 3 used.
        -- First MIC state is state 2.
        l_michael_in_w2 <= l_michael_w0;
        r_michael_in_w2 <= r_michael_w0;

      when "011" =>   -- Michael states 1 to 3 used.
        -- First MIC state is state 1.
        l_michael_in_w1 <= l_michael_w0;
        r_michael_in_w1 <= r_michael_w0;

      when others => -- Michael state 0 to 3 used (default values).
        -- First MIC state is state 0.
        l_michael_in_w0 <= l_michael_w0;
        r_michael_in_w0 <= r_michael_w0;

    end case;
  end process l_micdata_pr;  
  ---------------------------------- End of select Michael block function inputs

  ----------------------------------------------------- Data padding for Michael
  -- This process completes frag2mic_pad with the MIC padding pattern.
  pad3_pr: process (frag, nb_frag)
  begin
    case nb_frag is
      when "00" =>
        frag2mic_pad    <= MIC_PADDING_CT;
      when "01" =>
        frag2mic_pad    <= MIC_PADDING_CT(23 downto 0) & frag(7 downto 0);
      when "10" =>
        frag2mic_pad    <= MIC_PADDING_CT(15 downto 0)
                         & frag(15 downto 0);
      when others =>
        frag2mic_pad    <= MIC_PADDING_CT( 7 downto 0)
                         & frag;
    end case;
  end process pad3_pr;
  ---------------------------------------------- End of data padding for Michael
  
  ----------------------------------------------- Mux for michael_blkfunc inputs
  -- If the firstpack flag is set, the Michael init states have been loaded
  -- during the mic_iv0_state. Else, they must be loaded during the first 
  -- MIC state. This is during first key stream in encryption mode (MIC on 
  -- plaintext data) and during second key stream in decryption mode (MIC on 
  -- decrypted data).
  l_michael_w0  <= l_michael_init when (firstpack = '0')
                                   and ( (state_counter = 1 and opmode = '1') or
                                         (state_counter = 2 and opmode = '0') )
    else l_michael_out;
  
  r_michael_w0  <= r_michael_init when (firstpack = '0')
                                   and ( (state_counter = 1 and opmode = '1') or
                                         (state_counter = 2 and opmode = '0') )
    else r_michael_out;
  
  -- The priority and '0' fields are inverted between Draft 4.0 and Draft 6.0
  -- of the IEEE 802.11i standard. The comply_d6_d4n register bit is used to be
  -- compliant with both drafts.
  mic_iv_word3 <=  (NULL_CT(23 downto 0) & priority) when comply_d6_d4n = '0'
    else (priority & NULL_CT(23 downto 0));
  
  -- Select input data for the Michael block function:
  -- L data in is L data out XOR the data to process (plain text data or MIC IV)
  with rc4_state select
    l_michael_in <=
      -- Michael IV block processing.
      l_michael_init  xor  michael_da(31 downto 0)          when mic_iv0_state,
      l_michael_out   xor (michael_sa(15 downto 0) & michael_da(47 downto 32))
                                                            when mic_iv1_state,
      l_michael_out   xor  michael_sa(47 downto 16)         when mic_iv2_state,
      l_michael_out   xor  mic_iv_word3                     when mic_iv3_state,
      -- Standard Michael data block processing.
      l_michael_in_w0 xor data2mic_w0     when mic_data0_state,
      l_michael_in_w1 xor data2mic_w1     when mic_data1_state,
      l_michael_in_w2 xor data2mic_w2     when mic_data2_state,
      l_michael_in_w3 xor data2mic_w3     when mic_data3_state,
      l_michael_in_frag xor frag2mic_pad  when mic_frag_state,
      -- MIC padding states.
      l_michael_out when others; -- xor "0" in mic_padding1_state.

  with rc4_state select
    r_michael_in <=
      r_michael_init    when mic_iv0_state,
      -- Standard Michael data block processing.
      r_michael_in_w0   when mic_data0_state,
      r_michael_in_w1   when mic_data1_state,
      r_michael_in_w2   when mic_data2_state,
      r_michael_in_w3   when mic_data3_state,
      r_michael_in_frag when mic_frag_state,
      r_michael_out     when others; -- MIC padding state.
  ----------------------------------------- End of mux for michael_blkfunc inputs

  ----------------------------------------------------  Diagnostic for RC4 state
  diag_p : process (rc4_state)
  begin
    case rc4_state is
      when idle_state =>     
        rc4_state_diag <= (others => '0');
      when rd_mac4_state =>
        rc4_state_diag <= "0001";      
      when rd_mac8_state | rd_frag_state | rd_key_state =>
        rc4_state_diag <= "0010";      
      when keymix_phase1_state | keymix_phase2_state | keytransfer_state =>
        rc4_state_diag <= "0011";      
      when sboxgenerate_state |
           mic_iv0_state | mic_iv1_state | mic_iv2_state | mic_iv3_state =>
        rc4_state_diag <= "0100";      
      when rd_kstr_state =>
        rc4_state_diag <= "0101";      
      when wr_kstr_state =>
        rc4_state_diag <= "0110";      
      when select_mic_state | mic_data0_state | mic_data1_state | 
           mic_data2_state | mic_data3_state | mic_frag_state | 
           mic_padding1_state | mic_end_state =>
        rc4_state_diag <= "0111";      
      when wr_miccrc_state =>
        rc4_state_diag <= "1000";      
      when crc_on_mic_state =>
        rc4_state_diag <= "1001";      
      when wr_miccrc_cs_state  =>
        rc4_state_diag <= "1010";      
      when wr_req_state | wr_grant_state | wrmic_req_state | wrmic_grant_state |
           wrcs_req_state | wrcs_grant_state =>
        rc4_state_diag <= "1011";   
      when others =>
        rc4_state_diag <= "1111";   
    end case;
       
  end process diag_p;
  
  ---------------------------------------------  End of Diagnostic for RC4 state
end RTL;
