
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: rc4_keyloading.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.8   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block is part of the RC4 Cryptographic Processor.
-- It loads the key from the memory to the SRAM. The address and size of the key
-- is given by the registers RC4_KSIZE and RC4_KADDR.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/rc4_crc/vhdl/rtl/rc4_keyloading.vhd,v  
--  Log: rc4_keyloading.vhd,v  
-- Revision 1.8  2003/09/15 12:20:05  Dr.A
-- Debugged key loading for key > 16 bytes. Added 256 bytes load for key size = 0.
--
-- Revision 1.7  2003/07/16 13:17:12  Dr.A
-- Modified to accept a key from the tkip_key_mixing block in tkip_mode.
--
-- Revision 1.6  2003/07/03 14:12:40  Dr.A
-- Removed generic.
--
-- Revision 1.5  2002/12/17 17:07:36  elama
-- Reduced the size of rd_size, bytes_written, init_size and init_size_dly
-- to 4 bits.
--
-- Revision 1.4  2002/11/26 13:00:59  elama
-- Solved bug in the addrmax_g generic.
--
-- Revision 1.3  2002/11/19 15:22:32  elama
-- Finished the implementation of the addrmax_g generic.
--
-- Revision 1.2  2002/10/16 16:31:09  elama
-- Changed rd_size to 5 bits.
--
-- Revision 1.1  2002/10/15 13:17:13  elama
-- Initial revision
--
--
--------------------------------------------------------------------------------
-- Revision 1.4  2002/10/15 13:40:00  elama
-- Added the stopop port.
--
-- Revision 1.3  2002/10/14 13:22:36  elama
-- Solved bugs in the address generation.
--
-- Revision 1.2  2002/09/16 13:59:20  elama
-- Re-designed the block to make it bus independant.
--
-- Revision 1.1  2002/07/30 09:50:05  elama
-- Initial revision
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
entity rc4_keyloading is
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
end rc4_keyloading;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of rc4_keyloading is

--------------------------------------------------------------- Type declaration
type keyloading_type is (idle_state,    -- Idle phase.
                         read1st_state, -- Read first 16 AHB bytes.
                         read_state,    -- Read 16 AHB bytes loop phase.
                         wait_state,    -- Waits until AHB data read and SRAM
                                        -- data written.
                         store_state,   -- Last 16 bytes written in the SRAM.
                         readsram_state,-- Read SRAM to repeat key pattern.
                         writesram_state);-- Write SRAM to repeat key pattern.

type writesram_type is (idle_state,     -- Idle phase.
                        load_state,     -- Loads the bytes to be written.
                        write_state);   -- Writes the data into the SRAM.
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------- Signal declaration
signal inc_wsram    : std_logic_vector( 7 downto 0);-- Incrementing Address
                                        -- of the key to be written in the SRAM.
signal inc_rsram    : std_logic_vector( 7 downto 0);-- Incrementing Address
                                        -- of the SRAM to be read by State Mach.
signal key_state    : keyloading_type;  -- State in the keyload state machine.
signal next_key_state:keyloading_type;  -- Next state in the keyload state m.
signal wrsram_state : writesram_type;   -- State in the WriteSRAM state machine.
signal next_wrsram_state:writesram_type;-- Next state in the WriteSRAM S.M.
signal state_counter: std_logic_vector (4 downto 0);-- Number of states (groups
                                        -- of 16 bytes) read from the AHB.
signal key_states   : std_logic_vector (4 downto 0);-- Size of the key in groups
                                        -- of 16 bytes (states).
signal write_done   : std_logic;        -- Write operation has finished.
signal start_wrsram : std_logic;        -- Pulse that starts writing in the SRAM
signal next_init_addr: std_logic_vector(31 downto 0);-- Next addr to rd data.
signal init_addr    : std_logic_vector(31 downto 0);-- Addr to rd data.
signal init_size    : std_logic_vector( 3 downto 0);-- Size of data to read.
signal init_size_dly: std_logic_vector( 3 downto 0);-- Delayed init_size.
signal bytes_written: std_logic_vector( 3 downto 0);-- Bytes written in the SRAM
signal init_word0   : std_logic_vector(31 downto 0);-- From SP_ReadData block.
signal init_word1   : std_logic_vector(31 downto 0);-- From SP_ReadData block.
signal init_word2   : std_logic_vector(31 downto 0);-- From SP_ReadData block.
signal init_word3   : std_logic_vector(31 downto 0);-- From SP_ReadData block.
signal int_sr_wdata : std_logic_vector(127 downto 0);-- Internal data
                            -- corresponding to the concatenation of init_wordX.
------------------------------------------------------ End of Signal declaration

begin


  ----------------------------------------------------- Internal copies of ports
  rd_size       <= init_size;
  rd_addr       <= init_addr;
  -- Detect number of states necessary to load key.
  key_states(4) <= '1' when rc4_ksize = 0 else '0';
  key_states(3 downto 0) <= rc4_ksize(7 downto 4) when rc4_ksize(3 downto 0) = 0
              else rc4_ksize (7 downto 4) + 1;
  -- When TKIP key mixing is used, USE computed TKIP key.
  init_word0    <= rd_word0 when tkip_mode = '0' else tkip_key_w0;
  init_word1    <= rd_word1 when tkip_mode = '0' else tkip_key_w1;
  init_word2    <= rd_word2 when tkip_mode = '0' else tkip_key_w2;
  init_word3    <= rd_word3 when tkip_mode = '0' else tkip_key_w3;
  ---------------------------------------------- End of Internal copies of ports

  ------------------------------------------- Main State Machine for Key Loading
  -- This is the main state machine in this block. On the idle state it waits
  -- for the signal start_keyload to start the key loading sequence. On the
  -- read1st_state the first 4 words of data are read. While these data are
  -- being stored in the memory, another group of 4 words is being read
  -- (read_state and wait_state). Once all the key has been read, the state
  -- machine goes to store_state where the last group of 4 words is stored.
  -- It may happen that the key is shorter than 255, in which case the key
  -- pattern has to be repeated. To free the AHB, instead of re-reading the
  -- AHB address, read cycles into the first addresses of the SRAM are
  -- performed to re-write them in the empty positions (readsram_state and
  -- writesram_state).
  keyloading_sm: process (inc_wsram, key_state, key_states, rd_read_done,
                          start_keyload, state_counter, stopop, tkip_mode,
                          write_done)
  begin
    if stopop = '1' then
      next_key_state <= idle_state;
    else
      case key_state is
        when idle_state =>
          if start_keyload = '1' then     -- Start the key transfer.
            -- Temporal key already available on rd_wordX lines.
            if tkip_mode = '1' then
              next_key_state <= store_state;
            else
              next_key_state <= read1st_state; -- Read the key.
            end if;
          else
            next_key_state <= idle_state;
          end if;

        when read1st_state =>
          if rd_read_done = '1' then         -- First 4 words read from AHB.
            if state_counter = key_states then-- All data read.
              next_key_state <= store_state;
            else
              next_key_state <= read_state;   -- Read a new state (16 bytes).
            end if;
          else
            next_key_state <= read1st_state;
          end if;

        when read_state =>
          next_key_state <= wait_state;

        when wait_state =>
          if (rd_read_done = '1' and write_done = '1') then
            if state_counter = key_states then-- All data read.
              next_key_state <= store_state;
            else
              next_key_state <= read_state;   -- Read a new state (16 bytes).
            end if;
          else
            next_key_state <= wait_state;
          end if;

        when store_state =>
          if write_done = '1' then
            if inc_wsram = "11111111" then-- Key loading finished.
              next_key_state <= idle_state;
            else                          -- KeyInitZone not full. Repeat pattern.
              next_key_state <= readsram_state;-- Ready to read data from SRAM.
            end if;
          else
            next_key_state <= store_state;
          end if;

        when readsram_state =>
          next_key_state <= writesram_state;

        when writesram_state =>
          if inc_wsram = "11111111" then  -- Key loading finished
            next_key_state <= idle_state;
          else                            -- KeyInitZone not full. Continue copy.
            next_key_state <= readsram_state;-- Continue to read data from SRAM.
          end if;

        when others =>
          next_key_state <= idle_state;
      end case;
    end if;
  end process keyloading_sm;

  keyloading_clk: process (clk, reset_n)
  begin
    if reset_n = '0' then
      key_state <= idle_state;          -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      key_state <= next_key_state;      -- Update the Keyload State Machine.
    end if;
  end process keyloading_clk;
  ------------------------------------ End of Main State Machine for Key Loading

  ---------------------------------------- State Machine for writing in the SRAM
  -- This is the state machine that writes the AHB read data into the SRAM.
  writesram_sm: process (bytes_written, init_size_dly, start_wrsram, stopop,
                         wrsram_state)
  begin
    if stopop = '1' then
      next_wrsram_state <= idle_state;
    else
      case wrsram_state is
        when idle_state =>
          if start_wrsram = '1' then
            next_wrsram_state <= load_state;
          else
            next_wrsram_state <= idle_state;
          end if;

        when load_state =>
          next_wrsram_state <= write_state;

        when write_state =>
          if bytes_written = init_size_dly then-- All data written.
            next_wrsram_state <= idle_state;
          else                            -- Continue writing data.
            next_wrsram_state <= write_state;
          end if;

        when others =>
          next_wrsram_state <= idle_state;
      end case;
    end if;
  end process writesram_sm;

  writesram_clk: process (clk, reset_n)
  begin
    if reset_n = '0' then
      wrsram_state <= idle_state;       -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      wrsram_state <= next_wrsram_state;-- Update the WriteSRAM State Machine.
    end if;
  end process writesram_clk;
  --------------------------------- End of State Machine for writing in the SRAM

  ----------------------------------------------------- state_counter Generation
  -- This process generates the signal state_counter which indicates how many
  -- groups of 4 words have been read from the key. This signal is initialized
  -- on the idle_state and incremented on the read1st_state and read_state.
  state_counter_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      state_counter <= (others => '0');
    elsif (clk'event and clk = '1') then
      if next_key_state /= key_state then
        case next_key_state is
          when idle_state =>
            state_counter <= (others => '0');

          when read1st_state | read_state =>
            state_counter <= state_counter + '1';

          when others =>
            null;
        end case;
      end if;
    end if;
  end process state_counter_pr;
  ---------------------------------------------- End of state_counter Generation

  -------------------------------------------------------- start_read Generation
  -- This process generates the signal rd_start_read which is the pulse that
  -- starts reading process into the AHB. This will be done every time the
  -- state machine enters the states read1st_state or read_state.
  start_rdahb_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      rd_start_read <= '0';
    elsif (clk'event and clk = '1') then
      if next_key_state /= key_state then
        if (next_key_state = read1st_state or
            next_key_state = read_state) then
          rd_start_read <= '1';
        else
          rd_start_read <= '0';
        end if;
      else
        rd_start_read <= '0';
      end if;
    end if;
  end process start_rdahb_pr;
  ------------------------------------------------- End of start_read Generation

  ------------------------------------------------------ start_wrsram Generation
  -- This process generates the signal start_wrsram which is the pulse that
  -- starts the State Machine that writes the data in the RC4 SRAM. This will
  -- be done every time the main state machine enters the read_state or the
  -- store_state.
  start_wrsram_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      start_wrsram <= '0';
    elsif (clk'event and clk = '1') then
      if next_key_state /= key_state then
        if (next_key_state = read_state or
            next_key_state = store_state) then
          start_wrsram <= '1';
        else
          start_wrsram <= '0';
        end if;
      else
        start_wrsram <= '0';
      end if;
    end if;
  end process start_wrsram_pr;
  ----------------------------------------------- End of start_wrsram Generation

  ----------------------------------------------------- bytes_written Generation
  -- This process generates the signal bytes_written which indicates the number
  -- of bytes that have been written in the SRAM.
  bytes_written_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      bytes_written <= (others =>'0');
    elsif (clk'event and clk = '1') then
      case next_wrsram_state is
        when idle_state =>              -- Reset counter.
          bytes_written <= (others =>'0');
        when write_state =>             -- Increment counter.
          bytes_written <= bytes_written + conv_std_logic_vector(1, 4);
        when others =>
          null;
      end case;
    end if;
  end process bytes_written_pr;
  ---------------------------------------------- End of bytes_written Generation

  ---------------------------------------------------------- InitSize Generation
  -- This process generates the signal 'init_size' which is used to read the
  -- data from the AHB. The size of the first data will be the least significant
  -- bits in the address. The size of the other data will be sixteen.
  initsize_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      init_size <= (others => '0');
    elsif (clk'event and clk = '1') then
      if next_key_state = read1st_state then
        init_size <= rc4_ksize(3 downto 0);
      else
        init_size <= "0000";
      end if;
    end if;
  end process initsize_pr;

  -- It also generates the signal 'init_size_dly' which is used to write the
  -- data in the SRAM. While one key state is being read from the AHB, the
  -- previous state is being written in the SRAM, that is why the size to
  -- write is delayed.
  initsizedly_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      init_size_dly <= (others => '0');
    elsif (clk'event and clk = '1') then
      if next_key_state /= key_state then
        if (next_key_state = read_state or next_key_state = store_state) then
          init_size_dly <= init_size;
        end if;
      end if;
    end if;
  end process initsizedly_pr;
  --------------------------------------------------- End of InitSize Generation

  ---------------------------------------------------------- InitAddr Generation
  -- This process generates the signal 'init_addr' which is used to read the
  -- data from the AHB.
  next_addr_pr: process(init_addr, init_size)
  begin
    if init_size = 0 then
      next_init_addr(31 downto 4) <= init_addr(31 downto 4) + 1;
      next_init_addr( 3 downto 0) <= init_addr( 3 downto 0);
    else
      next_init_addr <= init_addr + init_size;
    end if;
  end process next_addr_pr;
  
  initaddr_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      init_addr <= (others => '0');
    elsif (clk'event and clk = '1') then
      if next_key_state /= key_state then-- It is done only once per state.
        case next_key_state is
          when read1st_state =>         -- First AHB data read.
            init_addr <= rc4_kaddr;

          when read_state =>            -- Increment the AHB address.
            init_addr <= next_init_addr;

          when others =>
            null;
        end case;
      end if;
    end if;
  end process initaddr_pr;
  --------------------------------------------------- End of InitAddr Generation

  --------------------------------------------------------- SRAM data Generation
  -- This process generates the data to be stored in the SRAM. There are two
  -- stages: one while it is reading from the AHB and another one while it is
  -- reading from the SRAM.
  -- While it is reading from the AHB, the int_sr_wdata is used. That is the
  -- concatenated data corresponding to four words. Every time one byte is
  -- written, the data is shifted so that it is always the least significant
  -- byte the one stored in the SRAM.
  datashift_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      int_sr_wdata <= (others => '0');
    elsif (clk'event and clk = '1') then
      case wrsram_state is
        when load_state =>              -- Concatenate the read words.
          int_sr_wdata <= init_word3 & init_word2 & init_word1 & init_word0;
        when write_state =>             -- Shift the data.
          int_sr_wdata <= "00000000" & int_sr_wdata (127 downto 8);
        when others =>
          null;
      end case;
    end if;
  end process datashift_pr;

  sr_wdata <= sr_rdata when key_state = writesram_state -- Copying from the SRAM
         else int_sr_wdata(7 downto 0); -- Storing the read AHB data.
  -------------------------------------------------- End of SRAM data Generation

  ------------------------------------------------------ SRAM address generation
  -- The SRAM address where the key is stored is "000000000" through
  -- "011111111". The write address is incremented every time a data is written
  -- in the SRAM, which is in state write_state from the WriteSRAM State Machine
  -- and in state writesram_state from the KeyLoad State Machine. In
  -- this second stage the key is reloaded to complete the 255 bytes. In this
  -- second stage it is also necessary to increment the read address.

  sram_wraddr_gen: process (clk, reset_n)
  begin
    if reset_n = '0' then               -- Reset SRAM address.
      inc_wsram <= (others => '0');
    elsif (clk'event and clk = '1') then
      if key_state = idle_state then
        inc_wsram <= (others => '0');
      elsif (key_state = writesram_state or wrsram_state = write_state) then
        inc_wsram <= inc_wsram + "00000001"; -- Increment SRAM write address.
      end if;
    end if;
  end process sram_wraddr_gen;


  sram_rdaddr_gen: process (clk, reset_n)
  begin
    if reset_n = '0' then               -- Reset SRAM address.
      inc_rsram <= (others => '0');
    elsif (clk'event and clk = '1') then
      case key_state is
        when idle_state =>
          inc_rsram <= (others => '0');
        when readsram_state =>
          inc_rsram <= inc_rsram + "00000001"; -- Increment SRAM write address.
        when others =>
          null;
      end case;
    end if;
  end process sram_rdaddr_gen;
  ----------------------------------------------- End of SRAM address generation

  ------------------------------------------------- SRAM write enable generation
  -- This signal indicates when a write (sr_wen = '0') or a read (sr_wen = '1')
  -- cycle is taking place in the SRAM.
  -- A write cycle will take place on states writesram1_state, writesram2_state,
  -- writesram3_state and writesram4_state (four 1-byte transfers to SRAM for
  -- every 4-byte data read from AHB) and also on state writesram_state to
  -- repeat the key pattern until the 255 SRAM positions are full.
  sr_wen <= '0' when (key_state = writesram_state or
                      wrsram_state = write_state)
       else '1';
  ------------------------------------------ End of SRAM write enable generation

  -------------------------------------------------- SRAM Chip enable generation
  -- This process generates the signal sr_cen which enables the SRAM to perform
  -- read or write cycles.
  sr_cen <= '0' when (wrsram_state /= idle_state or
                      key_state = writesram_state or
                      key_state = readsram_state)
       else '1';
  ------------------------------------------- End of SRAM Chip enable generation

  -------------------------------------------------- SRAM Address bus generation
  -- The address on the SRAM will depend on the state of the Main State Machine.
  -- On the first part (from idle_state until writesram4_state) the only
  -- transfers to the SRAM are write cycles and the address bue corresponds to
  -- the incrementing 'inc_wsram' variable. On the second part (states
  -- readsram_state and writesram_state) there is a read cycle to the address
  -- indicated by 'inc_rsram' followed by a write cycle to the address
  -- 'inc_wsram' to copy the key until the SRAM is full.
  sr_address <= ('1' & inc_rsram) when key_state = readsram_state
           else ('1' & inc_wsram);
  ------------------------------------------- End of SRAM Address bus generation

  --------------------------------------------------- write_done flag generation
  -- The flag write_done is set to '1' when the all the bytes have been written
  -- in the SRAM.
  write_done <= '1' when next_wrsram_state = idle_state
           else '0';
  -------------------------------------------- End of write_done flag generation

  ----------------------------------------------- Keyload_finish flag generation
  -- The flag keyload_done is set to '1' when the keyloading operation has
  -- finished.
  keyload_done <= '1' when next_key_state = idle_state
             else '0';
  ---------------------------------------- End of Keyload_finish flag generation

end RTL;
