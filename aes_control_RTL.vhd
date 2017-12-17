
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream_Processing
--    ,' GoodLuck ,'      RCSfile: aes_control.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.11   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : State machine and controls for the AES Cryptographic Processor.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/aes_ccm/vhdl/rtl/aes_control.vhd,v  
--  Log: aes_control.vhd,v  
-- Revision 1.11  2005/05/31 15:45:13  Dr.A
-- #BugId:938#
-- New diags
--
-- Revision 1.10  2003/12/04 09:26:10  Dr.A
-- Register for process_done.
--
-- Revision 1.9  2003/11/26 08:30:06  Dr.A
-- Removed mask on AAD QC field (D7.0).
--
-- Revision 1.8  2003/10/13 16:40:33  Dr.A
-- Register for data size.
--
-- Revision 1.7  2003/10/09 16:39:53  Dr.A
-- Cleaned.
--
-- Revision 1.6  2003/09/29 15:47:50  Dr.A
-- Key size is always 16 bytes: removed unused code.
--
-- Revision 1.5  2003/09/23 14:02:39  Dr.A
-- Cleaned code. Added MIC written to control structure for debug. buffer size length set to 16 bits. state_counter moved in str_proc_control.
--
-- Revision 1.4  2003/09/16 08:04:16  Dr.A
-- Cleaned code.
--
-- Revision 1.3  2003/09/01 16:02:34  Dr.A
-- Optimized state machine to write data while cipher is running.
--
-- Revision 1.2  2003/08/28 15:12:16  Dr.A
-- Removed unused states. Changed bsize length.
--
-- Revision 1.1  2003/07/16 13:38:50  Dr.A
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
use IEEE.STD_LOGIC_ARITH.ALL; 
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity aes_control is
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

end aes_control;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of aes_control is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type AES_STATE_TYPE is (
    idle_state,              -- Idle phase
    rd_key4_state,           -- Key Initialisation. Load first 4 words.
    expansion_state,         -- Key Expansion.
    ciph_b0_state,           -- Use nonce as cipher input (MIC generation).
    rd_mac4_state,           -- MAC header initialisation. Load first 4 words.
    ciphb1_rdmac8_state,     -- Use AAD from MAC header LSB as cipher input,
                             -- and read MAC last words.
    ciphb2_state,            -- Use AAD from MAC header MSB as cipher input.
    rd_ciphctr_state,        -- Encrypt counter while reading data.
    wrciph_req_state,        -- Set bus request.
    wrciph_grant_state,      -- Wait for bus grant.
    wr_ciphformic_state,     -- Encrypt message for MIC generation.  
    cipha0_rdmic_state,      -- Encryption phase to compute the MIC. During
                             -- decryption, read the rx MIC at the same time.
    wrmiccs_req_state,       -- Set bus request.
    wrmiccs_grant_state,     -- Wait for bus grant.
    wr_miccs_state,          -- Store the MIC in the control structure.
    wrmic_req_state,         -- Set bus request.
    wrmic_grant_state,       -- Wait for bus grant.
    wr_mic_state             -- Store the MIC at the end of the encrypted data.
    );

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Flags used in AES init states in CCM MIC encryption phase.
  constant CCM_BFLAGS  : std_logic_vector( 7 downto 0) := "01011001";
  -- Flags used in AES init states in CCM data encryption phase.
  constant CCM_AFLAGS  : std_logic_vector( 7 downto 0) := "00000001";
  -- Mask on Frame control field to construct the CCMP AAD.
  constant FC_MASK_CT  : std_logic_vector(15 downto 0) := "1100011110001111";
  -- Constant for MIC processing.
  constant MIC_SIZE_CT     : std_logic_vector( 3 downto 0) := "1000"; -- 8 bytes
  -- Offset to reach MIC address in the control structure.
  constant MICCS_OFFSET_CT : std_logic_vector( 5 downto 0) := "011100";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- State Machine
  signal aes_state     : AES_STATE_TYPE; -- State in the AES state machine.
  signal next_aes_state: AES_STATE_TYPE; -- Next state in the AES SM.
  -- Counter of processed data states.
  signal next_state_counter : std_logic_vector (12 downto 0);
  signal state_counter : std_logic_vector (12 downto 0);
  -- MAC header signals
  signal mac_address2  : std_logic_vector(47 downto 0); -- Address 2 field.
  -- AES blockcipher result, stored while AES is run to compute CCMP MIC.
  signal ccm_result_w0 : std_logic_vector(31 downto 0);
  signal ccm_result_w1 : std_logic_vector(31 downto 0);
  signal ccm_result_w2 : std_logic_vector(31 downto 0);
  signal ccm_result_w3 : std_logic_vector(31 downto 0);
  -- Decrypted data with '0' padding.
  signal decrypt_w0    : std_logic_vector(31 downto 0);
  signal decrypt_w1    : std_logic_vector(31 downto 0);
  signal decrypt_w2    : std_logic_vector(31 downto 0);
  signal decrypt_w3    : std_logic_vector(31 downto 0);
  -- Addresses.
  signal state_saddr   : std_logic_vector(addrmax_g-1 downto 0);-- Source address.
  signal state_daddr   : std_logic_vector(addrmax_g-1 downto 0);-- Dest. address.
  -- Internal signals.
  signal data_size     : std_logic_vector(3 downto 0);-- Size of processed data.
  signal start_cipher_int  : std_logic;
  -- Size of authentication data.
  signal aad_len       : std_logic_vector(15 downto 0);
  -- Diagnostic ports
  signal aes_state_diag: std_logic_vector( 3 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- Diagnostic port
  aes_ctrl_diag(7 downto 4) <= (others => '0');
  aes_ctrl_diag(3 downto 0) <= aes_state_diag;
  
  -- AAD length is MAC header length minus 2 bytes (removed Duration ID field).
  aad_len(15 downto 6) <= (others => '0');
  aad_len( 5 downto 0) <= aes_msize - 2; -- 24 <= aes_msize <= 32.

  --------------------------------------------------- Send write data on the AHB
  -- This process multiplexes the different outputs to be written in the AHB
  -- depending on the current state.
  wrdata_multiplexor_pr: process (aes_state, ccm_result_w0, ccm_result_w1,
                                  enablecrypt, read_word0, read_word1,
                                  read_word2, read_word3, result_w0, result_w1,
                                  result_w2, result_w3)
  begin
    -- Encryption not enabled, write back read data.
    if enablecrypt = '0' then
      write_word0 <= read_word0;
      write_word1 <= read_word1;
      write_word2 <= read_word2;
      write_word3 <= read_word3;
    else  
      case aes_state is

        -- Write CCM encrypted/decrypted data in memory.
        when wr_ciphformic_state =>
          -- CCM : en/decrypted data is read data xor'ed with AES cipher result.
          write_word0 <= result_w0 xor read_word0;
          write_word1 <= result_w1 xor read_word1;
          write_word2 <= result_w2 xor read_word2;
          write_word3 <= result_w3 xor read_word3;

        -- Write CCM MIC in memory.
        when wr_mic_state =>
          write_word0 <= result_w0 xor ccm_result_w0;
          write_word1 <= result_w1 xor ccm_result_w1;
          write_word2 <= (others => '0');
          write_word3 <= (others => '0');

        -- Write not encrypted CCM MIC in control structure.
        when wr_miccs_state =>
          write_word0 <= ccm_result_w0;
          write_word1 <= ccm_result_w1;
          write_word2 <= (others => '0');
          write_word3 <= (others => '0');

        when others =>
          write_word0 <= (others => '0');
          write_word1 <= (others => '0');
          write_word2 <= (others => '0');
          write_word3 <= (others => '0');

      end case;
    end if;
  end process wrdata_multiplexor_pr;
  -------------------------------------------- End of Send write data on the AHB

  ----------------------------------------------------------- Decrypted data mux
  -- This process compute the data to feed to the ciph_formic AES process in
  -- decryption mode. It is the decrypted data, padded with zeros if there is
  -- less than 16 bytes of data.
  decrypt_data_pr : process (data_size, read_word0, read_word1, read_word2,
                             read_word3, result_w0, result_w1, result_w2,
                             result_w3)
  begin   
    -- CCM : decrypted data is read data xor'ed with AES cipher result.
    decrypt_w0 <= result_w0 xor read_word0;
    decrypt_w1 <= result_w1 xor read_word1;
    decrypt_w2 <= result_w2 xor read_word2;
    decrypt_w3 <= result_w3 xor read_word3;
    -- Pad with zeros.
    case data_size is
      when "1111" => 
        decrypt_w3 (31 downto 24) <= (others => '0');
      when "1110" => 
        decrypt_w3 (31 downto 16) <= (others => '0');
      when "1101" => 
        decrypt_w3 (31 downto  8) <= (others => '0');
      when "1100" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
      when "1011" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto 24) <= (others => '0');
      when "1010" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto 16) <= (others => '0');
      when "1001" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto  8) <= (others => '0');
      when "1000" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto  0) <= (others => '0');
      when "0111" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto  0) <= (others => '0');
        decrypt_w1 (31 downto 24) <= (others => '0');
      when "0110" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto  0) <= (others => '0');
        decrypt_w1 (31 downto 16) <= (others => '0');
      when "0101" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto  0) <= (others => '0');
        decrypt_w1 (31 downto  8) <= (others => '0');
      when "0100" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto  0) <= (others => '0');
        decrypt_w1 (31 downto  0) <= (others => '0');
      when "0011" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto  0) <= (others => '0');
        decrypt_w1 (31 downto  0) <= (others => '0');
        decrypt_w0 (31 downto 24) <= (others => '0');
      when "0010" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto  0) <= (others => '0');
        decrypt_w1 (31 downto  0) <= (others => '0');
        decrypt_w0 (31 downto 16) <= (others => '0');
      when "0001" => 
        decrypt_w3 (31 downto  0) <= (others => '0');
        decrypt_w2 (31 downto  0) <= (others => '0');
        decrypt_w1 (31 downto  0) <= (others => '0');
        decrypt_w0 (31 downto  8) <= (others => '0');
      when others =>
        null; -- keep default values.
    end case;
  end process decrypt_data_pr;
  

  ----------------------------------------------------------- Main State Machine
  -- This is the main State Machine of the AES processor.
  --   * First, it reads the key words from the AHB memory. It takes one or two
  --   states depending on the key size (KeyInit_State).
  --   * Then, it does the key expansion (KeySchedule_State).
  --
  -- In case of CCM chaining mode, the state machine goes on as follows:
  --   * First, Additional Authentication Data from the MAC header is encrypted
  --   (cipher states B0, B1, B2). This will be used to compute the MIC.
  --   * Then, the AES algorithm is run twice for each data block: once to
  --   compute the CCMP MIC (wr_ciphformic_state), and once to en/decrypt the
  --   data (ciphcnt_rddata_state). En/decrypted data is written to the memory
  --   (wr_data_state).
  --   * A last cipher state (A0) is used to encrypt the MIC. In encryption
  --   mode, the MIC is written in memory (wr_mic_state). In decryption mode, it
  --   is checked again the expected MIC.
  --
  main_fsm_comb_pr: process (aes_state, ciph_done_early, cipher_done,
                             expand_done, opmode, read_done, startop,
                             state_counter, state_number, stopop, write_done)
  begin
    if stopop = '1' then
      next_aes_state <= idle_state;
    else
      case aes_state is
        
                
        --------------------------------------------
        -- Idle state
        --------------------------------------------
        
        when idle_state =>
          if startop = '1' then         -- Start cryptography.
            next_aes_state <= rd_key4_state;
          else
            next_aes_state <= idle_state;
          end if;
        
        
        --------------------------------------------
        -- Key initialisation and expansion
        --------------------------------------------
        
        -- Key Initialisation. The key size is 16 bytes.
        when rd_key4_state =>
          if read_done = '1' then
            next_aes_state <= expansion_state;
          else
            next_aes_state <= rd_key4_state;
          end if;
          
        -- Key expansion.
        when expansion_state =>
          if expand_done = '1' then     -- Key expansion done.
            next_aes_state <= rd_mac4_state; -- Compute CCM MIC.
          else
            next_aes_state <= expansion_state;
          end if;


        --------------------------------------------
        -- CCM: Read MAC + CCM header encryption
        --------------------------------------------
        
        -- CCM: read MAC header first 4 words in memory.
        when rd_mac4_state =>
          if read_done = '1' then
            next_aes_state <= ciph_b0_state;
          else
            next_aes_state <= rd_mac4_state;
          end if;

        -- CCM: encrypt B0 ( Flags + Nonce + l(m) )
        when ciph_b0_state =>
          if cipher_done = '1' then     -- Round finished.
            next_aes_state <= ciphb1_rdmac8_state;
          else
            next_aes_state <= ciph_b0_state;
          end if;

        -- CCM: encrypt B1 (AAD from MAC header).
        when ciphb1_rdmac8_state =>
          if read_done = '1' and cipher_done = '1' then -- Encription finished.
           next_aes_state <= ciphb2_state;
          else
            next_aes_state <= ciphb1_rdmac8_state;
          end if;

        -- CCM: encrypt B2 (AAD from MAC header).
        when ciphb2_state =>
          if cipher_done = '1' then -- Encription finished.
            next_aes_state <= rd_ciphctr_state;
          else
            next_aes_state <= ciphb2_state;
          end if;
        
        
        --------------------------------------------
        -- Payload encryption
        --------------------------------------------
               
        -- Read data to process in memory, and encrypt counter for CCMP.
        when rd_ciphctr_state =>
          -- Data read, and cipher almost done.
          if read_done = '1' and ciph_done_early = '1' then
            next_aes_state <= wrciph_req_state;
          else
            next_aes_state <= rd_ciphctr_state;
          end if;

        -- Wait while bus request is sent.
        when wrciph_req_state =>
          next_aes_state <= wrciph_grant_state;
                  
        -- Wait while bus is granted.
        when wrciph_grant_state =>
          next_aes_state <= wr_ciphformic_state;
                  
        -- Store processed data in memory, and run cipher to generate TAG.
        when wr_ciphformic_state =>
          -- Data written, and cipher almost done.
          if write_done = '1' and cipher_done = '1' then
            if state_counter < state_number then
              next_aes_state <= rd_ciphctr_state;   -- process next state.
            else                                    -- Whole buffer encrypted.
              next_aes_state <= cipha0_rdmic_state; -- Encrypt MIC.
            end if;
          else                                      -- Wait for write/cipher.
            next_aes_state <= wr_ciphformic_state;
          end if;

        
        --------------------------------------------
        -- CCM: MIC encryption, check and store
        --------------------------------------------        
        
        -- CCM: encrypt A0 ( Flags + Nonce + Counter at 0).
        -- In decryption mode, read the expected MIC in memory.
        when cipha0_rdmic_state =>
          if opmode = '1' then                     -- Encryption.
            if ciph_done_early = '1' then          -- Round finished (A0).
              next_aes_state <= wrmic_req_state;   -- Write MIC to dest. buffer.
            else
              next_aes_state <= cipha0_rdmic_state;
            end if;
          else                                     -- Decryption.
            if read_done = '1' and cipher_done = '1' then -- Expected MIC read.
              next_aes_state <= wrmiccs_req_state; -- Write MIC to ctrl struct.
            else
              next_aes_state <= cipha0_rdmic_state;
            end if;
          end if;

        -- Wait while bus request is sent.
        when wrmic_req_state =>
          next_aes_state <= wrmic_grant_state;
                  
        -- Wait while bus is granted.
        when wrmic_grant_state =>
          next_aes_state <= wr_mic_state;
                  
        -- CCM: Store Message Integrity Code in destination buffer.
        when wr_mic_state =>
          if write_done = '1' then               -- MIC stored.
            next_aes_state <= wrmiccs_req_state; -- Write MIC to control struct.
          else
            next_aes_state <= wr_mic_state;
          end if;

        -- Wait while bus request is sent.
        when wrmiccs_req_state =>
          next_aes_state <= wrmiccs_grant_state;
                  
        -- Wait while bus is granted.
        when wrmiccs_grant_state =>
          next_aes_state <= wr_miccs_state;
                  
        -- CCM: Store Message Integrity Code in the control structure.
        when wr_miccs_state =>
          if write_done = '1' then               -- MIC stored.
            next_aes_state <= idle_state;
          else
            next_aes_state <= wr_miccs_state;
          end if;

        when others =>
          next_aes_state <= idle_state;
      end case;

    end if;
  end process main_fsm_comb_pr;
  
  main_fsm_seq_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      aes_state <= idle_state;     -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      aes_state <= next_aes_state; -- Update the State Machine.
    end if;
  end process main_fsm_seq_pr;
  ---------------------------------------------------- End of Main State Machine

  ------------------------------------------------------ TAG saving and checking
  -- This process computes and checks the CCM Message Integrity Code (MIC).
  -- The CCM TAG, result of wr_ciphformic_states encryption, has been saved in
  -- the ccm_result words.
  -- In decryption mode, the MIC read in memory is decrypted and compared to the
  -- tag before entering idle state. If the two values differ, the mic_int
  -- interrupt is sent.
  tagsaving_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      mic_int <= '0'; -- Reset MIC interrupt.

    elsif (clk'event and clk = '1') then
      mic_int <= '0'; -- mic_int is a pulse.
      
      -- Check Integrity code before entering idle_state.
      if (next_aes_state = idle_state) and (aes_state /= idle_state) then
        if opmode = '0' then -- Decryption.
          -- Check CCM tag against decrypted MIC.
          if (ccm_result_w1 /= (read_word1 xor result_w1))
             or (ccm_result_w0 /= (read_word0 xor result_w0)) then
            mic_int <= '1';
          end if;
        end if;
      end if;

    end if;
  end process tagsaving_pr;
  ----------------------------------------------- End of Tag saving and checking

  ----------------------------------------------------- Save AES results for CCM
  -- In CCM mode, two AES chains are working in parallel. This process saves the
  -- AES results words of the chain computing the CCM MIC (wr_ciphformic_state)
  -- before the AES is used for CCM (rd_ciphctr_state). It also saves the tag 
  -- value before entering cipha0_rdmic_state.
  ccm_aes_save_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      ccm_result_w0 <= (others => '0');
      ccm_result_w1 <= (others => '0');
      ccm_result_w2 <= (others => '0');
      ccm_result_w3 <= (others => '0');
    elsif (clk'event and clk = '1') then
      if ( (aes_state = rd_ciphctr_state or aes_state = cipha0_rdmic_state)
            and start_cipher_int = '1') then
        ccm_result_w0 <= result_w0;
        ccm_result_w1 <= result_w1;
        ccm_result_w2 <= result_w2;
        ccm_result_w3 <= result_w3;
      end if;
    end if;
  end process ccm_aes_save_pr;
  ---------------------------------------------- End of save AES results for CCM
  
  -------------------------------------------------------- MAC header processing
  -- When reading the MAC header first part, save the A2 field to use it in the
  -- nonce.
  mac_header_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      mac_address2 <= (others => '0');
    elsif (clk'event and clk = '1') then
      if aes_state = rd_mac4_state and read_done = '1' then
        mac_address2 <= read_word3 & read_word2(31 downto 16);
      end if;
    end if;
  end process mac_header_pr;
  ------------------------------------------------- End of MAC header processing

  --------------------------------------------------------- AES State Generation
  -- This process multiplexes the different inputs to the AES_BlockCipher
  -- depending on the current state.
  state_multiplexor_pr: process (aad_len, aes_bsize, aes_packet_num, aes_state,
                                 ccm_result_w0, ccm_result_w1, ccm_result_w2,
                                 ccm_result_w3, decrypt_w0, decrypt_w1,
                                 decrypt_w2, decrypt_w3, mac_address2, opmode,
                                 priority, read_word0, read_word1, read_word2,
                                 read_word3, result_w0, result_w1, result_w2,
                                 result_w3, state_counter)
  begin
    case aes_state is

      -- CCM: AES input is B0: l(m) & nonce & flags. l(m) is sent MSByte first.
      when ciph_b0_state =>
        -- Nonce = aes_packet_num - mac_address2 - priority
        aes_state_w3 <= aes_bsize(7 downto 0) & aes_bsize(15 downto 8)
                       & aes_packet_num(7 downto 0)
                       & aes_packet_num(15 downto 8);
        aes_state_w2 <= aes_packet_num(23 downto 16)
                       & aes_packet_num(31 downto 24)
                       & aes_packet_num(39 downto 32)
                       & aes_packet_num(47 downto 40);
        aes_state_w1 <= mac_address2(47 downto 16);
        aes_state_w0 <= mac_address2(15 downto 0) & priority & CCM_BFLAGS;

      -- CCM: AES input is B1 xor AES(B0) result.
      when ciphb1_rdmac8_state =>
        -- B1 = AAD (14 bytes) & l(a) (2 bytes). l(a) is sent MSByte first.
        -- The Additional Authentication Data is built from the MAC header data,
        -- still available in the read_wordX registers. (Frame Control, A1, A2).
        aes_state_w3 <= read_word3 xor result_w3; -- A2.
        aes_state_w2 <= read_word2 xor result_w2; -- A2 - A1.
        aes_state_w1 <= read_word1 xor result_w1; -- A1. Skip Duration Id.
        aes_state_w0(31 downto 16) <= (read_word0(15 downto 0) and FC_MASK_CT)
                                    xor result_w0(31 downto 16); -- FC masked.
        aes_state_w0(15 downto 0) <= (aad_len( 7 downto 0)
                                     & aad_len(15 downto 8))
                                    xor result_w0(15 downto 0);

      -- CCM: AES input is B2 xor AES(B1) result.
      when ciphb2_state =>
        -- B2 = end of AAD and zero padding (if needed).
        -- The Additional Authentication Data is built from the MAC header data,
        -- still available in the read_wordX registers. (A3, Sequence Control,
        -- optionnaly A4 and Quality Control). Zero padding is done in the AHB
        -- access block (read size is set according to MAC header size).
        aes_state_w3 <= read_word3 xor result_w3;        
        aes_state_w2 <= read_word2 xor result_w2;

        -- Sequence Control is on read_word1(31 downto 16). The Sequence Number
        -- ( read_word1(31 downto 20) ) is masked.
        aes_state_w1(31 downto 20) <= result_w1(31 downto 20); -- SN Mask.
        aes_state_w1(19 downto 0)  <= read_word1(19 downto 0)
                                    xor result_w1(19 downto 0); -- SC - A3.
        aes_state_w0 <= read_word0 xor result_w0; -- A3.
                                                         
      -- CCM: AES chain to compute the MIC: AES input is Bi xor AES(Bi-1) result
      when wr_ciphformic_state =>
        -- Bi = plaintext payload (read_wordX in TX, decrypt_wX in RX).
        if opmode= '1' then
          aes_state_w0 <= read_word0 xor ccm_result_w0;
          aes_state_w1 <= read_word1 xor ccm_result_w1;
          aes_state_w2 <= read_word2 xor ccm_result_w2;
          aes_state_w3 <= read_word3 xor ccm_result_w3;
        else
          aes_state_w0 <= decrypt_w0 xor ccm_result_w0;
          aes_state_w1 <= decrypt_w1 xor ccm_result_w1;
          aes_state_w2 <= decrypt_w2 xor ccm_result_w2;
          aes_state_w3 <= decrypt_w3 xor ccm_result_w3;
        end if;
                                                                   
      -- CCM: CTR mode: AES input is Ai = counter + nonce + flags.
      when rd_ciphctr_state | wrciph_req_state| wrciph_grant_state =>
        -- Nonce = aes_packet_num - mac_address2 - priority
        aes_state_w3 <= state_counter( 7 downto 0)
                       & "000" & state_counter(12 downto 8)
                       & aes_packet_num( 7 downto 0)
                       & aes_packet_num(15 downto 8);
        aes_state_w2 <= aes_packet_num(23 downto 16)
                       & aes_packet_num(31 downto 24)
                       & aes_packet_num(39 downto 32)
                       & aes_packet_num(47 downto 40);
        aes_state_w1 <= mac_address2(47 downto 16);
        aes_state_w0 <= mac_address2(15 downto 0) & priority & CCM_AFLAGS;
                                                         
      -- CCM: CTR mode with counter at 0.
      when cipha0_rdmic_state | wrmic_req_state| wrmic_grant_state =>
        -- A0 = counter=0 + nonce + flags.
        aes_state_w3 <= "0000000000000000" & aes_packet_num(7 downto 0)
                                            & aes_packet_num(15 downto 8);
        aes_state_w2 <= aes_packet_num(23 downto 16)
                       & aes_packet_num(31 downto 24)
                       & aes_packet_num(39 downto 32)
                       & aes_packet_num(47 downto 40);
        aes_state_w1 <= mac_address2(47 downto 16);
        aes_state_w0 <= mac_address2(15 downto 0) & priority & CCM_AFLAGS;
                                                         
      when others => -- not CCM Encryption/decryption State, or don't care.
        aes_state_w0 <= read_word0;
        aes_state_w1 <= read_word1;
        aes_state_w2 <= read_word2;
        aes_state_w3 <= read_word3;
        
    end case;
  end process state_multiplexor_pr;
  -------------------------------------------------- End of AES State Generation

  ---------------------------------------------- I/O Size and Address Generation
  -- This block generates the address signals to control read and write
  -- accesses to the memory.
  addr_mux_pr: process (aes_kaddr, aes_maddr, aes_state, state_saddr)
  begin
    case aes_state is

      -- Read key (16 bytes).
      when rd_key4_state =>
        read_addr <= aes_kaddr;         -- Key address.

      -- CCM: Read MAC header first 16 bytes.
      when rd_mac4_state =>
        read_addr <= aes_maddr;

      -- CCM: Read MAC header last bytes.
      when ciphb1_rdmac8_state =>
        -- MAC header address +16.
        read_addr(addrmax_g-1 downto 4) <= aes_maddr(addrmax_g-1 downto 4) + 1;
        read_addr(3 downto 0)           <= aes_maddr(3 downto 0);

      -- CCM: Read MIC, and set write controls to write MIC.
      when wrmic_req_state| wrmic_grant_state | cipha0_rdmic_state =>
        -- The MIC is stored at the end of the source buffer.
        read_addr <= state_saddr;  -- Data buffer address.

      -- CCM: Store MIC.
      when wr_mic_state |
           wrmiccs_req_state| wrmiccs_grant_state | wr_miccs_state =>
        read_addr <= (others => '0');

      -- Read and write AES data.
      when others =>
        read_addr <= state_saddr;       -- Data Buffer address.
        
    end case;
  end process addr_mux_pr;

  -- This block generates the size signal to control read and write accesses to
  -- the memory.  
  data_size_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_size <= (others => '0');

    elsif clk'event and clk = '1' then
      if (aes_state /= next_aes_state) then -- When entering the state.
        case next_aes_state is
          -- Read key (16 bytes).
          when rd_key4_state =>
            data_size <= (others => '0');   -- Read 16 bytes.

          -- CCM: Read MAC header first 16 bytes.
          when rd_mac4_state =>
            data_size <= (others => '0');

          -- CCM: Read MAC header last bytes.
          when ciphb1_rdmac8_state =>
            if aes_msize(5) = '1' then      -- Mac header size = 10 0000b = 32 bytes
              data_size <= (others => '0'); -- Read the last 16 bytes.
            else                            -- Read less than 16 bytes.
              data_size <= aes_msize(3 downto 0);
            end if;

          -- CCM: Read MIC, and set write controls to write MIC.
          when wrmic_req_state| wrmic_grant_state | cipha0_rdmic_state =>
            data_size <= MIC_SIZE_CT;  -- Read/store 8 bytes.

          -- CCM: Store MIC.
          when wr_mic_state |
               wrmiccs_req_state| wrmiccs_grant_state | wr_miccs_state =>
            data_size <= MIC_SIZE_CT;  -- Store 8 bytes.

          -- Read and write AES data. State counter is incremented when entering
          -- this state, so test the next value.
          when rd_ciphctr_state =>
            if next_state_counter < state_number then -- en/decryption not finished.
              data_size  <= (others => '0');          -- State size (16 bytes).
            else -- Last round, of less than 16 bytes.
              data_size  <= aes_bsize(3 downto 0);    -- Last bytes.
            end if;

          -- Read and write AES data.
          when others =>
            if state_counter < state_number then   -- en/decryption not finished.
              data_size  <= (others => '0');       -- State size (16 bytes).
            else -- Last round, of less than 16 bytes.
              data_size  <= aes_bsize(3 downto 0); -- Last bytes.
            end if;

        end case;
      end if;
      
    end if;
  end process data_size_pr;

  read_size  <= data_size;
  write_size <= data_size;
  --------------------------------------- End of I/O Size and Address Generation

  ----------------------------------------- Source Buffer Address incrementation
  -- This process generates the address of the data to be encrypted and the
  -- destination address.
  state_addr_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      state_saddr <= (others => '0');
      state_daddr <= (others => '0');
    elsif (clk'event and clk = '1') then

      if next_aes_state /= aes_state then -- Update when leaving the state.

        case aes_state is

          -- Load addresses during rd_key4_state.
          when rd_key4_state =>
            state_daddr <= aes_daddr;
            state_saddr <= aes_saddr;

          -- Increment source address after each data read access.
          when wrciph_grant_state =>
            -- Add the size of the last read access.
            if data_size = 0 then -- Add 16 bytes.
              state_saddr(addrmax_g-1 downto 4) <=
                             state_saddr(addrmax_g-1 downto 4) + 1;
            else
              state_saddr <= state_saddr + data_size;
            end if;

          -- Increment destination address after each data write access.
          when wr_ciphformic_state =>
            -- Add the size of the last write access.
            if data_size = 0 then -- Add 16 bytes.
              state_daddr(addrmax_g-1 downto 4) <=
                             state_daddr(addrmax_g-1 downto 4) + 1;
            else
              state_daddr <= state_daddr + data_size;
            end if;

          when cipha0_rdmic_state =>
            -- Set destination address to write in the control structure (RX).
            if opmode = '0' then
              state_daddr <= aes_csaddr + MICCS_OFFSET_CT;
            end if;
            
          when wr_mic_state =>
            -- Set destination address to write in the control structure (TX).
            state_daddr <= aes_csaddr + MICCS_OFFSET_CT;
            
          when others =>
            null;
        end case;

      end if;
    end if;
  end process state_addr_pr;

  write_addr <= state_daddr;
  ---------------------------------- End of Source Buffer Address incrementation

  ------------------------------------------------------- Block Selector decoder
  -- This process selects the active sub-block. It gives a pulse to the
  -- corresponding sub-block when the AES State Machine enters the adequate
  -- state.
  selector_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      key_load4       <= '0';
      start_read      <= '0';
      start_expand    <= '0';
      start_cipher_int<= '0';
      start_write     <= '0';
    elsif (clk'event and clk = '1') then
      -- All signals are pulses.
      key_load4        <= '0';
      start_read       <= '0';
      start_expand     <= '0';
      start_cipher_int <= '0';
      start_write      <= '0';
      if next_aes_state /= aes_state then   -- Pulse when entering the state
        case next_aes_state is
          when rd_key4_state | rd_mac4_state =>
            start_read     <= '1';          -- Pulse to start read.

          when expansion_state =>
            start_expand <= '1';            -- Pulse to start key expansion.
            key_load4    <= '1';

          when cipha0_rdmic_state =>
            start_cipher_int <= '1';        -- Pulse to start the state encryption.
            start_read       <= not(opmode);-- If decryption, read the MIC.

          when rd_ciphctr_state |ciphb1_rdmac8_state =>
            start_cipher_int <= '1';        -- Pulse to start the state encryption.
            start_read       <= '1';        -- Read data.

          when ciph_b0_state | ciphb2_state | wr_ciphformic_state =>
            start_cipher_int <= '1';        -- Pulse to start the state encryption.

          when wrciph_req_state | wrmic_req_state | wrmiccs_req_state=>
            start_write      <= '1';        -- Pulse to start the state encryption.

          when others => null;
        end case;
      else                              -- Reset the signals after 1 clk.
        key_load4        <= '0';
        start_read       <= '0';
        start_expand     <= '0';
        start_cipher_int <= '0';
        start_write      <= '0';
      end if;
    end if;
  end process selector_pr;

  start_cipher <= start_cipher_int;
  ------------------------------------------------ End of Block Selector decoder

  ----------------------------------------------------- state_counter Generation
  -- This process generates the signal state_counter which indicates the
  -- number of data states (16 bytes) that have been processed. This signal is
  -- initialised to zero and incremented in 1 unit in every cycle.
  next_state_counter <= state_counter + 1;

  state_counter_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      state_counter <= (others => '0');
    elsif (clk'event and clk = '1') then
      if aes_state /= next_aes_state then -- When entering the state.
        case next_aes_state is
          when idle_state =>
            -- Initialise state_counter.
            state_counter <= (others => '0');
          when rd_ciphctr_state =>
            -- state_counter = state_counter+1
            state_counter <= next_state_counter;
          when others =>
            null;
        end case;
      end if;
    end if;
  end process state_counter_pr;
  ---------------------------------------------- End of state_counter Generation

  ------------------------------------------------- process_done flag generation
  -- The flag process_done is set to '1' when the encryption/decryption 
  -- operation has finished.
  done_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      process_done <= '1';
    elsif clk'event and clk = '1' then
      if (aes_state /= idle_state or startop = '1') then
        process_done <= '0';
      else
        process_done <= '1';
      end if;
    end if;
  end process done_pr;
  ------------------------------------------ End of process_done flag generation

  ----------------------------------------------------  Diagnostic for RC4 state
  diag_p : process (aes_state)
  begin
    case aes_state is
      when idle_state =>
        aes_state_diag <= (others => '0');
      when rd_key4_state =>
        aes_state_diag <= "0001";
      when expansion_state =>
        aes_state_diag <= "0010";
      when ciph_b0_state =>
        aes_state_diag <= "0011";
      when rd_mac4_state =>
        aes_state_diag <= "0100";
      when ciphb1_rdmac8_state =>
        aes_state_diag <= "0101";
                    
      when ciphb2_state =>
        aes_state_diag <= "0110";
      when rd_ciphctr_state =>
        aes_state_diag <= "0111";
      when wr_ciphformic_state =>
        aes_state_diag <= "1000";
      when cipha0_rdmic_state =>
        aes_state_diag <= "1001";
                    
      when wr_miccs_state =>
        aes_state_diag <= "1010";
      when wr_mic_state =>        
        aes_state_diag <= "1011";
      when wrciph_req_state | wrciph_grant_state | wrmiccs_req_state | wrmiccs_grant_state |
           wrmic_req_state | wrmic_grant_state =>
        aes_state_diag <= "1100";
       when others =>
        aes_state_diag <= (others => '1');
    end case;
  end process diag_p;
  ---------------------------------------------  End of Diagnostic for RC4 state
end RTL;
