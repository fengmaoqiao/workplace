
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: rc4_keystream.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block is part of the RC4 Cryptographic Processor.
-- In this block the Key Stream is calculated. The key is XORed with the
-- data read from AHB to encrypt them and the encrypted data sent back to
-- the AHB.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/rc4_crc/vhdl/rtl/rc4_keystream.vhd,v  
--  Log: rc4_keystream.vhd,v  
-- Revision 1.7  2003/08/28 14:43:45  Dr.A
-- Added done_early output.
--
-- Revision 1.6  2003/07/16 13:18:09  Dr.A
-- Removed addtion_X registers (useless).
--
-- Revision 1.5  2003/07/03 14:11:05  Dr.A
-- Debugged keystr_done asserted one clock cycle too early.
--
-- Revision 1.4  2002/12/17 17:07:06  elama
-- Reduced the size of sram_counter and kstr_size to 4 bits.
--
-- Revision 1.3  2002/10/16 16:26:45  elama
-- Solved bug in sram_counter.
--
-- Revision 1.2  2002/10/16 16:07:07  elama
-- Changed kstr_size to 5 bits.
--
-- Revision 1.1  2002/10/15 13:18:22  elama
-- Initial revision
--
--
--------------------------------------------------------------------------------

library IEEE; 
  use IEEE.STD_LOGIC_1164.ALL; 
  use IEEE.STD_LOGIC_UNSIGNED.ALL;
  use IEEE.STD_LOGIC_ARITH.ALL;

entity rc4_keystream is
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
end rc4_keystream;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of rc4_keystream is

--------------------------------------------------------------- Type declaration
type SRAM_STATE_TYPE is (idle_state,     -- Idle phase
                        read_si_state,   -- Read Si phase.
                        wait_si_state,   -- Wait for Si data to be available.
                        read_sj_state,   -- Read Sj phase.
                        write_in_j_state,-- Write Si in address j.
                        read_st_state,   -- Read St phase.
                        write_in_i_state);-- Write Sj in address i.
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------- Signal declaration
signal key_w_pointer : std_logic_vector(3 downto 0);-- Pointer to the internal
                                        -- register that stores the key stream.
signal index_i       : std_logic_vector(7 downto 0);-- Index i.
signal index_j       : std_logic_vector(7 downto 0);-- Index t.
signal index_t       : std_logic_vector(7 downto 0);-- Index j.
signal data_si       : std_logic_vector(7 downto 0);-- Data Si.
signal data_sj       : std_logic_vector(7 downto 0);-- Data Sj.
signal data_st       : std_logic_vector(7 downto 0);-- Data St.
signal key           : std_logic_vector(7 downto 0);-- Key.
signal sram_state    : SRAM_STATE_TYPE; -- State in the SRAM state machine.
signal next_sram_state:SRAM_STATE_TYPE; -- Next state in the SRAM state machine
signal sram_counter  : std_logic_vector( 3 downto 0);-- Counts the number of
                                        -- calculated key-stream bytes.
signal key_reg       : std_logic_vector(127 downto 0);-- Register to store the
                                        -- Key Stream.
signal write_in_i_flag:std_logic;       -- Flag that indicates that
                                        -- sram_state = write_in_i_state.
signal write_in_i_flag_dly:std_logic;   -- write_in_i_flag delayed 1 clk cycle.
signal fsm_idle      :std_logic;        -- Detect idle state.
signal fsm_idle_early:std_logic;        -- Detect 2 cycles before idle state.
------------------------------------------------------ End of Signal declaration

begin

  -------------------------------------- State Machine that interfaces with SRAM
  -- This state machine reads and writes the data from/to the SRAM. From the
  -- S-Box data it generates the key stream according to the following
  -- algorithm:
  -- i = (i + 1)
  -- j = (j + Si) mod 256
  -- Swap Si and Sj
  -- t = (Si + Sj) mod 256
  -- K = St
  keystream_fsm_comb_pr: process (sram_state, start_keystr, sram_counter,
                                 kstr_size)
  begin
    case sram_state is
      when idle_state =>
        if (start_keystr = '1') then -- or cont_keystr = '1') then
          next_sram_state <= read_si_state;
        else
          next_sram_state <= idle_state;
        end if;

      when read_si_state =>
        next_sram_state <= wait_si_state;

      when wait_si_state =>
        next_sram_state <= read_sj_state;

      when read_sj_state =>
        next_sram_state <= write_in_j_state;

      when write_in_j_state =>
        next_sram_state <= read_st_state;

      when read_st_state =>
        next_sram_state <= write_in_i_state;

      when write_in_i_state =>
        if sram_counter = kstr_size then-- All bytes calculated.
          next_sram_state <= idle_state;
        else                            -- Continue encoding/decoding.
          next_sram_state <= read_si_state;
        end if;

      when others =>
        next_sram_state <= idle_state;
    end case;
  end process keystream_fsm_comb_pr;

  keystream_fsm_seq_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      sram_state <= idle_state;         -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      sram_state <= next_sram_state;    -- Update the Keyload State Machine.
    end if;
  end process keystream_fsm_seq_pr;
  ------------------------------- End of State Machine that interfaces with SRAM

  ---------------------------------------------------------- Index_i Calculation
  -- This process calculates the 'index_i' variable. This variable is reseted
  -- at the beginning of the sequence and updated at the end on state
  -- write_in_i_state.
  index_i_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then               -- Reset index_i to 1.
      index_i <= "00000001";
    elsif (clk'event and clk = '1') then
      if init_keystr = '1' then         -- Initialise the variable.
        index_i <= "00000001";
      elsif sram_state = write_in_i_state then-- Update index_i.
        index_i <= index_i + "00000001"; -- i = (i + 1) mod 256.
      end if;
    end if;
  end process index_i_pr;
  --------------------------------------------------- End of Index_i Calculation

  ---------------------------------------------------------- Index_j Calculation
  -- This process calculates the 'index_j' variable. This variable is reseted
  -- at the beginning of the sequence and updated on state read_sj_state.
  index_j_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then               -- Reset index_j.
      index_j <= (others => '0');
    elsif (clk'event and clk = '1') then
      if init_keystr = '1' then         -- Initialise the variable.
        index_j <= (others => '0');
      elsif sram_state = wait_si_state then-- Update index_j.
        index_j <= index_j + sr_rdata;-- j = (j + Si) mod 256
      end if;
    end if;
  end process index_j_pr;
  --------------------------------------------------- End of Index_j Calculation

  ---------------------------------------------------------- Index_t Calculation
  -- This process calculates the 'index_t' variable. This variable is reseted
  -- at the beginning of the sequence and updated on state write_in_j_state.
  index_t_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then               -- Reset index_t.
      index_t <= (others => '0');
    elsif (clk'event and clk = '1') then
      if init_keystr = '1' then         -- Initialise the variable.
        index_t <= (others => '0');
      elsif sram_state = write_in_j_state then-- Update index_t.
        index_t <= data_si + sr_rdata; -- t=(Si+Sj) mod 256.
      end if;
    end if;
  end process index_t_pr;
  --------------------------------------------------- End of Index_t Calculation

  ------------------------------------------------------ SRAM Address Generation
  -- This process sets the correct address lines to write or read the SRAM.
  -- The data Si will be read on the read_si_state state.
  -- The data Sj will be read on the read_sj_state state.
  -- The data St will be read on the read_st_state state.
  -- The data Si will be written in j in write_in_j_state state.
  -- The data Sj will be written in i in write_in_i_state state.
  sram_address_pr: process (sram_state, index_i, index_j, index_t)
  begin
    case sram_state is
      when idle_state =>
        sr_address <= (others => '0');
      when read_si_state =>
        sr_address <= ('0' & index_i);  -- Read cycle to address i.
      when read_sj_state =>
        sr_address <= ('0' & index_j);  -- Read cycle to address j.
      when write_in_j_state =>
        sr_address <= ('0' & index_j);  -- Write cycle to address j.
      when read_st_state =>
        sr_address <= ('0' & index_t);  -- Read cycle to address t.
      when write_in_i_state =>
        sr_address <= ('0' & index_i);  -- Write cycle to address i.
      when others =>
        sr_address <= (others => '0');
    end case;
  end process sram_address_pr;
  ----------------------------------------------- End of SRAM Address Generation

  ---------------------------------------------------------- sr_wdata Generation
  -- This process generates the data to be written in the SRAM.
  -- The data to be written in the SRAM is:
  -- data_Si on state write_in_j_state.
  -- data_Sj on state write_in_i_state.
  sr_wdata <= data_si when sram_state = write_in_j_state
         else data_sj;
  --------------------------------------------------- End of sr_wdata Generation

  ------------------------------------------------- SRAM Write Enable Generation
  -- This process generates the SRAM signal 'sr_wen'. This signal should be
  -- active on states write_in_j_state and write_in_i_state.
  sr_wen <= '0' when (sram_state = write_in_j_state or
                      sram_state = write_in_i_state)
       else '1';
  ------------------------------------------ End of SRAM Write Enable Generation

  -------------------------------------------------- SRAM Chip Enable Generation
  -- This process generates the SRAM signal 'sr_cen'. This signal should be
  -- active on all states except idle_state.
  sr_cen <= '1' when sram_state = idle_state
       else '0';
  ------------------------------------------- End of SRAM Chip Enable Generation

  -------------------------------------------------------------- write_in_i Flag
  -- This process generates the flag 'write_in_i_flag' which indicates when
  -- the SRAM state machine is in the write_in_i_state. It also generates the
  -- signal 'write_in_i_flag_dly' which is the same as 'write_in_i_flag' but
  -- delayed in one clock cycle.
  -- These two signals are used in the data storage process and key generation.
  write_in_i_flag <= '1' when (sram_state = write_in_i_state)
                else '0';
  delay_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      write_in_i_flag_dly <= '0';
    elsif (clk'event and clk ='1') then
      write_in_i_flag_dly <= write_in_i_flag;
    end if;
  end process delay_pr;
  ------------------------------------------------------- End of write_in_i Flag

  ----------------------------------------------------------------- Data Storage
  -- The 'data_store_pr' process stores the data read from the SRAM at the
  -- appropriate state:
  -- data_Si is stored at the end of wait_si_state,
  -- data_Sj is stored at the end of write_in_j_state and
  -- data_St is stored the first time we are on write_in_i_state.
  data_store_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then               -- Reset data values.
      data_si <= (others => '0');
      data_sj <= (others => '0');
      data_st <= (others => '0');
    elsif (clk'event and clk = '1') then
      case sram_state is
        when wait_si_state =>
          data_si <= sr_rdata;
        when write_in_j_state =>
          data_sj <= sr_rdata;
        when write_in_i_state =>
          if write_in_i_flag = '1' and write_in_i_flag_dly = '0' then
            if index_i /= index_t then  -- Normal storage.
              data_st <= sr_rdata;
            else
              data_st <= data_sj;       -- Done to save one clock cycle...
            end if;
          end if;
        when others =>
          null;
      end case;
    end if;
  end process data_store_pr;
  ---------------------------------------------------------- End of Data Storage

  --------------------------------------------------------------- Key Generation
  -- This process generates the signal 'key', that has to be stored in the
  -- key_reg register to xor with the data.
  --                 ___     ___     ___     ___     ___     ___
  --          clk  _/   \___/   \___/   \___/   \___/   \___/   \___
  --               _________ _______________ _______________________
  --   sram_state  _________X___write_in_i__X_______________________
  --               _________________ _______ _______________________
  --      data_st  _________________X__key__X_______________________
  --               __________ ______ _______________________________
  --     sr_rdata  __________X_key__X_______________________________
  --

  key <= sr_rdata when (sram_state = write_in_i_state and
                        write_in_i_flag = '1' and write_in_i_flag_dly = '0'
                        and index_i /= index_t)
    else data_sj  when (sram_state = write_in_i_state and
                        write_in_i_flag = '1' and write_in_i_flag_dly = '0'
                        and index_i = index_t)
    else data_st;
  -------------------------------------------------------- End of Key Generation

  ------------------------------------------------------ SRAM-counter Generation
  -- This process counts the number of key-stream bytes calculated to XOR with
  -- the source data.
  sram_counter_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      sram_counter <= (others => '0');
    elsif (clk'event and clk = '1') then
      if next_sram_state = idle_state then
        sram_counter <= (others => '0');-- Reset SRAM counter.
      elsif (next_sram_state = read_si_state and
                 sram_state /= read_si_state) then-- Increment SRAM counter on
        sram_counter <= sram_counter + "0001";-- the first state of the S.M.
      end if;
    end if;
  end process sram_counter_pr;
  ----------------------------------------------- End of SRAM-counter Generation

  ----------------------------------------------------- key_w_pointer Generation
  -- This process generates the signal 'key_w_pointer'. This signal indicates
  -- in which position of the internal key register, the key stream byte must be
  -- stored.
  -- 'key_w_pointer' will be incremented once every cycle of the SRAM state
  -- machine.
  --   ______ _...._ ______ ______ ______ ______ ______ ______ ______ ______
  --  |      |      |      |      |      |      |      |      |      |      |
  --  | 1111 |      | 0111 | 0110 | 0101 | 0100 | 0011 | 0010 | 0001 | 0000 |
  --  |______|_...._|______|______|______|______|______|______|______|______|
  --                                                              ^
  --                                                              |
  --                                                        key_w_pointer

  key_pointer_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      key_w_pointer <= (others => '0');
    elsif (clk'event and clk = '1') then
      if sram_state = idle_state then
        -- Initialise key_w_pointer.
        key_w_pointer <= (others => '0');
      elsif (sram_state = write_in_i_state and
             next_sram_state = read_si_state) then
        -- Increment/Update key_w_pointer.
        key_w_pointer <= key_w_pointer + "0001";
      end if;
    end if;
  end process key_pointer_pr;
  ---------------------------------------------- End of key_w_pointer Generation

  -------------------------------------------------- key_reg register Generation
  -- This process creates the key_reg register with the key stream bytes that
  -- are calculated. These bytes are concatenated to obtain the size indicated
  -- in the kstr_size input line.
  key_reg_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      key_reg    <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (sram_state = write_in_i_state) then
        case key_w_pointer is
          when "1111" =>
            key_reg (127 downto 120) <= key;
          when "1110" =>
            key_reg (119 downto 112) <= key;
          when "1101" =>
            key_reg (111 downto 104) <= key;
          when "1100" =>
            key_reg (103 downto  96) <= key;
          when "1011" =>
            key_reg ( 95 downto  88) <= key;
          when "1010" =>
            key_reg ( 87 downto  80) <= key;
          when "1001" =>
            key_reg ( 79 downto  72) <= key;
          when "1000" =>
            key_reg ( 71 downto  64) <= key;
          when "0111" =>
            key_reg ( 63 downto  56) <= key;
          when "0110" =>
            key_reg ( 55 downto  48) <= key;
          when "0101" =>
            key_reg ( 47 downto  40) <= key;
          when "0100" =>
            key_reg ( 39 downto  32) <= key;
          when "0011" =>
            key_reg ( 31 downto  24) <= key;
          when "0010" =>
            key_reg ( 23 downto  16) <= key;
          when "0001" =>
            key_reg ( 15 downto   8) <= key;
          when "0000" =>
            key_reg (  7 downto   0) <= key;
          when others =>
            null;
        end case;
      end if;
    end if;
  end process key_reg_pr;

  key_stream3 <= key_reg (127 downto 96);
  key_stream2 <= key_reg ( 95 downto 64);
  key_stream1 <= key_reg ( 63 downto 32);
  key_stream0 <= key_reg ( 31 downto  0);
  ------------------------------------------- End of key_reg register Generation

  ------------------------------------------------------- keystr_done Generation
  -- This process generates the signal 'keystr_done' which indicates when all
  -- the necessary key stream bytes have been calculated.  
  done_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      fsm_idle <= '1';
    elsif clk'event and clk = '1' then
      if next_sram_state = idle_state then
        fsm_idle <= '1';
      else
        fsm_idle <= '0';
      end if;
    end if;
  end process done_pr;
  
  -- keystr_done must go low when start_keystr is received.
  keystr_done <= fsm_idle and not(start_keystr);

  -- This process generates the signal 'keystr_done_early' two clock cycles
  -- before the necessary key stream bytes have been calculated.
  done_early_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      fsm_idle_early <= '1';
    elsif clk'event and clk = '1' then
      if (next_sram_state = read_st_state) and (sram_counter = kstr_size) then
        fsm_idle_early <= '1';
      elsif start_keystr = '1' then
        fsm_idle_early <= '0';
      end if;
    end if;
  end process done_early_pr;
  
  -- keystr_done must go low when start_keystr is received.
  keystr_done_early <= fsm_idle_early and not(start_keystr);
  ------------------------------------------------ End of keystr_done Generation

end RTL;
