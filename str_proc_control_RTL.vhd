
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: str_proc_control.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.9   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Controls for the Stream Processor.
--               Contains the state machine and the mux/decode logic between
--               RC4 and AES signals.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/stream_processor/vhdl/rtl/str_proc_control.vhd,v  
--  Log: str_proc_control.vhd,v  
-- Revision 1.9  2003/12/04 09:57:38  Dr.A
-- Added registers to ease synthesis.
--
-- Revision 1.8  2003/11/12 16:32:20  Dr.A
-- Changes for big endain interface: added acctype control signal.
-- Grouped bursts by access type for control structure accesses.
--
-- Revision 1.7  2003/10/13 16:38:54  Dr.A
-- Register for state_number.
--
-- Revision 1.6  2003/10/07 14:45:52  Dr.A
-- firstpack and lastpack read from control structure only in TKIP mode.
--
-- Revision 1.5  2003/09/23 14:08:40  Dr.A
-- Added read_done_dly and state_number. Debuged control structure read (use of cryptmode).
--
-- Revision 1.4  2003/08/28 15:23:28  Dr.A
-- Changed bsize length.
--
-- Revision 1.3  2003/08/13 16:24:48  Dr.A
-- Removed unused write control signals.
--
-- Revision 1.2  2003/07/16 13:42:49  Dr.A
-- Updated for version 0.09.
--
-- Revision 1.1  2003/07/03 14:39:26  Dr.A
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
 
--library endianness_converter_rtl;
library work;
--use endianness_converter_rtl.endianness_converter_pkg.ALL;
use work.endianness_converter_pkg.ALL;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity str_proc_control is
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

end str_proc_control;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of str_proc_control is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type SP_STATE_TYPE is (idle_state,            -- Idle phase
                         -- Read control structure contents:
                         rd_ctrl_struct0_state, -- First 4 words.
                         rd_ctrl_struct1_state, -- Words 4 to 7.
                         rd_ctrl_struct2_state, -- Word 8.
                         aes_state,             -- Run AES State Machine.
                         rc4_state);            -- Run RC4 State Machine.

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal sp_state        : SP_STATE_TYPE;-- State in the main state machine.
  signal next_sp_state   : SP_STATE_TYPE;-- Next state in the main SM.

  -- Signals from the str_proc_control FSM.
  signal sp_start_read   : std_logic; -- Start AHB read access.
  signal sp_read_size    : std_logic_vector( 3 downto 0); -- Size of read access
  signal sp_read_addr    : std_logic_vector(31 downto 0); -- Read address.

  -- Encryption mode read in the control structure.
  signal cryptmode       : std_logic_vector( 2 downto 0);
  signal crypttype       : std_logic; -- Selects RC4(0) or AES(1) algorithm.

  -- Output ports used internally.
  signal read_done_dly_int : std_logic; -- read_done delayed by one clk cycle.
  signal strpbsize_int     : std_logic_vector(15 downto 0);
  signal rc4_startop_int : std_logic;
  signal aes_startop_int : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- Diagnostic port.
  ctrl_diag(7 downto 3) <= (others => '0');
  ctrl_diag(2 downto 0) <= cryptmode;  

  -- Combination of all MIC errors
  mic_int    <= aes_mic_int or rc4_mic_int;
  
  -- acctype output: Key, MAC header and data are defined with bytes. They are
  -- read/written in AES and RC4 states. Control structure data is defined
  -- with words, except MIC data, read in rd_ctrl_struct2_state.
  acctype <= BYTE_CT when (sp_state = rd_ctrl_struct2_state) or 
                          (sp_state = rc4_state) or (sp_state = aes_state)
        else WORD_CT;
  
  ----------------------------------------------------- state_number computation
  -- This signal indicates how many groups of 4 words (16 bytes) have to be
  -- encrypted/decrypted. If the source buffer is aligned with the 32-bit
  -- boundaries the number of states (16 bytes) will be the 4 most significant
  -- bits, otherwise one more group will have to be calculated.  
  state_nb_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      state_number <= (others => '0');

    elsif clk'event and clk = '1' then

      -- Set state_number when strpbsize is read from control structure.
      if (sp_state = rd_ctrl_struct0_state) and
         (next_sp_state = rd_ctrl_struct1_state) then
        if ( strpbsize_int(3 downto 0) = 0 ) then
          state_number <= ( '0' & strpbsize_int(15 downto 4) );
        else
          state_number <= ( '0' & strpbsize_int(15 downto 4) ) + 1;
        end if;
      end if;

    end if;
  end process state_nb_pr;
  ---------------------------------------------- End of state_number computation

  -------------------------------------------------------------- Delay read_done
  read_done_dly <= read_done_dly_int;
  read_done_dly_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      read_done_dly_int <= '1';
    elsif clk'event and clk = '1' then
      read_done_dly_int <= read_done;
    end if;
  end process read_done_dly_pr;
  ------------------------------------------------------- End of delay read_done
  
  ----------------------------------------------------------- Main State Machine
  -- This is the main State Machine in the Stream Processor. It loads data from
  -- the control structure and goes on with RC4 or AES processing consequently.
  fsm_comb_pr: process (aes_process_done, aes_startop_int, crypttype,
                        rc4_process_done, rc4_startop_int, read_done,
                        read_done_dly_int, sp_state, startop, stopop)
  begin
    if stopop = '1' then -- End of operation interrupt.
      next_sp_state <= idle_state;
    else
      case sp_state is

        -- Wait for signal to satrt en/decryption.
        when idle_state =>
          if startop = '1' then -- Start of operation.
            next_sp_state <= rd_ctrl_struct0_state;
          else
            next_sp_state <= idle_state;
          end if;

        -- Read the control structure words 0 to 3.
        when rd_ctrl_struct0_state =>
          -- Wait for read_done_delay to use data registered after read_done.
          if read_done = '1' and read_done_dly_int = '1' then -- End of read.
            next_sp_state <= rd_ctrl_struct1_state;
          else
            next_sp_state <= rd_ctrl_struct0_state;
          end if;

        -- Read the control structure words 4 to 7.
        when rd_ctrl_struct1_state =>
          if read_done = '1' then
            if crypttype = '0' then -- RC4 encryption/decryption.
              next_sp_state <= rd_ctrl_struct2_state;
            else -- AES encryption/decryption.
              next_sp_state <= aes_state;
            end if;  
          else
            next_sp_state <= rd_ctrl_struct1_state;
          end if;

        -- Read the control structure word 8.
        when rd_ctrl_struct2_state =>
          if read_done = '1' then
            next_sp_state <= rc4_state;
          else
            next_sp_state <= rd_ctrl_struct2_state;
          end if;

        -- RC4 processing.
        when rc4_state =>
          if (rc4_process_done = '1') and (rc4_startop_int = '0') then
            next_sp_state <= idle_state;
          else
            next_sp_state <= rc4_state;
          end if;

        -- AES processing.
        when aes_state =>
          if (aes_process_done = '1') and (aes_startop_int = '0') then
            next_sp_state <= idle_state;
          else
            next_sp_state <= aes_state;
          end if;

        when others =>
          next_sp_state <= idle_state;
      end case;

    end if;
  end process fsm_comb_pr;
  
  fsm_seq_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      sp_state <= idle_state;           -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      sp_state <= next_sp_state;        -- Update the State Machine.
    end if;
  end process fsm_seq_pr;

  -- Assert 'done' flag when the state machine is idle.
  done_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      process_done <= '1';
    elsif clk'event and clk = '1' then
      if (next_sp_state = idle_state) then
        process_done <= '1';
      else
        process_done <= '0';
      end if;
    end if;
  end process done_pr;
  
  ---------------------------------------------------- End of Main State Machine

  -------------------------------------------------------------- Control Signals
  -- This process generates the control signals for the subblocks.
  control_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      rc4_startop_int <= '0';
      aes_startop_int <= '0';
      sp_start_read   <= '0';

    elsif clk'event and clk = '1' then
      if next_sp_state /= sp_state then   -- Beginning of state.
        case next_sp_state is
          
          when rd_ctrl_struct0_state | rd_ctrl_struct1_state |
               rd_ctrl_struct2_state =>
            sp_start_read   <= '1';        -- Launch read operation.

          when rc4_state =>
            rc4_startop_int <= '1';        -- Start RC4 encryption/decryption.

          when aes_state =>
            aes_startop_int <= '1';        -- Start AES encryption/decryption.

          when others =>
            null;
            
        end case;
      else -- These signals are only one clock-cycle pulses.
        rc4_startop_int <= '0';
        aes_startop_int <= '0';
        sp_start_read   <= '0';
      end if;
    end if;
  end process control_pr;

  start_read  <= aes_start_read or rc4_start_read or sp_start_read;
  start_write <= aes_start_write or rc4_start_write;
  rc4_startop <= rc4_startop_int;
  aes_startop <= aes_startop_int;
  ------------------------------------------------------- End of Control Signals

  -------------------------------------------------------- AHB R/W Address lines
  -- This process generates the address and size lines for the AHB read 
  -- procedure.
  rwaddress_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      sp_read_size  <= (others => '0');
      sp_read_addr  <= (others => '0');

    elsif (clk'event and clk = '1') then
      if next_sp_state /= sp_state then -- Done at the beginning of the state.

        case next_sp_state is

          -- The control structure is read in three burst: first 4 32bit words,
          -- then 3, then 2. This is to isolate in the last burst the control
          -- structure data which structure is defined with bytes, and easily
          -- generate a control signal for the endianness converter. 
          when rd_ctrl_struct0_state =>
            sp_read_addr <= strpcsaddr;  -- Control structure address.
            sp_read_size <= "0000";      -- Read 16 bytes.

          when rd_ctrl_struct1_state =>
            -- Increment address by size of last access.
            sp_read_addr <= sp_read_addr + ('1' & sp_read_size);
            sp_read_size <= "1100";      -- Read 12 bytes.

          when rd_ctrl_struct2_state =>
            -- Increment address by size of last access.
            sp_read_addr <= sp_read_addr + sp_read_size;
            sp_read_size <= "1000";      -- Read 8 bytes.

          when others =>
            null;
            
        end case;
      end if;
    end if;
  end process rwaddress_pr;


  -- Register read size (needed for synthesis). The delay is not a problem
  -- because in the ahb_access block, read size is not used during the first
  -- two clock cycles of the read cycle (bus access request/grant).
  read_size_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      read_size <= (others => '0');
    elsif clk'event and clk = '1' then
      case sp_state is
        when aes_state =>
          read_size <= aes_read_size;
        when rc4_state =>
          read_size <= rc4_read_size;
        when others =>
          read_size <= sp_read_size;
      end case;
    end if;
  end process read_size_p;
  
  -- Select AES/RC4 read address.
  with sp_state select
    read_addr <= 
      aes_read_addr when aes_state,
      rc4_read_addr when rc4_state,
      sp_read_addr  when others;
      
  -- Select AES/RC4 write size.
  write_size <= aes_write_size when sp_state = aes_state
           else rc4_write_size;
  
  -- Select AES/RC4 write address.
  write_addr <= aes_write_addr when sp_state = aes_state
           else rc4_write_addr;
  ------------------------------------------------- End of AHB R/W Address lines

  --------------------------------------------------------- AHB write Data lines
  -- Select origin of the data to write
  result_w0 <= aes_result_w0 when sp_state = aes_state 
          else rc4_result_w0 when sp_state = rc4_state 
          else read_word0;

  result_w1 <= aes_result_w1 when sp_state = aes_state 
          else rc4_result_w1 when sp_state = rc4_state 
          else read_word1;

  result_w2 <= aes_result_w2 when sp_state = aes_state 
          else rc4_result_w2 when sp_state = rc4_state 
          else read_word2;

  result_w3 <= aes_result_w3 when sp_state = aes_state 
          else rc4_result_w3 when sp_state = rc4_state 
          else read_word3;

  -------------------------------------------------- End of AHB write Data lines

  ------------------------------------------------------- Load control structure
  -- This process registers data read from the control structure, to use it in
  -- data processing.
  ctrl_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      rc4_firstpack  <= '0';
      rc4_lastpack   <= '0';
      opmode         <= '0';
      cryptmode      <= (others => '0');
      strpksize      <= (others => '0');
      priority       <= (others => '0');
      aes_msize      <= (others => '0');
      strpbsize_int  <= (others => '0');
      strpsaddr      <= (others => '0');
      strpdaddr      <= (others => '0');
      strpmaddr      <= (others => '0');
      packet_num     <= (others => '0');
      michael_w0     <= (others => '0');
      michael_w1     <= (others => '0');

    elsif clk'event and clk = '1' then
      if read_done = '1' then -- Read data available.
        case sp_state is
          
          when rd_ctrl_struct0_state =>
            if (read_word0(6 downto 4) = "011") then -- TKIP mode
              rc4_firstpack <= read_word0(0);
              rc4_lastpack  <= read_word0(1);
            else
              rc4_firstpack <= '0';
              rc4_lastpack  <= '0';
            end if;
            opmode                   <= read_word0(2);
            cryptmode                <= read_word0( 6 downto 4);
            strpksize                <= read_word0(15 downto 8);
            priority                 <= read_word0(23 downto 16);
            aes_msize                <= read_word0(29 downto 24);
            strpbsize_int            <= read_word1(15 downto 0);
            strpsaddr                <= read_word2;
            strpdaddr                <= read_word3;

          when rd_ctrl_struct1_state =>
            strpmaddr                <= read_word0;
            packet_num(31 downto 0)  <= read_word1;
            packet_num(47 downto 32) <= read_word2(15 downto 0);
            
          when rd_ctrl_struct2_state =>
            michael_w0               <= read_word0;
            michael_w1               <= read_word1;
            
          when others =>
            null;
            
        end case;
      end if;        
    end if;
  end process ctrl_pr;
  strpbsize <= strpbsize_int;


  -- This process generates control signals for the AES and RC4 sub-blocks from
  -- the cryptmode value read in the control structure.
  cryptmode_pr : process (cryptmode)
  begin
    case cryptmode is
      when "000" => -- No encryption.
        crypttype     <= '0';
        enablecrypt   <= '0';
        enablecrc     <= '0';
        enablemic     <= '0';
      when "001" => -- RC4 only.
        crypttype     <= '0';
        enablecrypt   <= '1';
        enablecrc     <= '0';
        enablemic     <= '0';
      when "010" => -- WEP.
        crypttype     <= '0';
        enablecrypt   <= '1';
        enablecrc     <= '1';
        enablemic     <= '0';
      when "011" => -- TKIP.
        crypttype     <= '0';
        enablecrypt   <= '1';
        enablecrc     <= '1';
        enablemic     <= '1';
      when others => -- AES
        crypttype     <= '1';
        enablecrypt   <= '1';
        enablecrc     <= '0';
        enablemic     <= '0';
    end case;
  end process cryptmode_pr;
  
  ------------------------------------------------ End of Load control structure

end RTL;
