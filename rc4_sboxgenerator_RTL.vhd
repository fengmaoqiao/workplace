
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: rc4_sboxgenerator.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block is part of the RC4 Cryptographic Processor.
-- It generates the S-Box according to the following algorithm:.
-- for i=0 to 255
--   j=(j+Si+Ki) mod 256
--   swap Si and Sj
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/rc4_crc/vhdl/rtl/rc4_sboxgenerator.vhd,v  
--  Log: rc4_sboxgenerator.vhd,v  
-- Revision 1.2  2003/07/16 13:11:48  Dr.A
-- Removed addition signal (useless).
--
-- Revision 1.1  2002/10/15 13:17:47  elama
-- Initial revision
--
--
--------------------------------------------------------------------------------
-- Revision 1.2  2002/09/16 14:07:38  elama
-- Inverted the sr_we line.
-- Added the sr_cen line.
--
-- Revision 1.1  2002/07/30 09:50:24  elama
-- Initial revision
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity rc4_sboxgenerator is
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
end rc4_sboxgenerator;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of rc4_sboxgenerator is

--------------------------------------------------------------- Type declaration
type sboxgen_state_type is (idle_state,    -- Idle phase
                        read_si_state,     -- Read Si phase.
                        read_ki_state,     -- Read Ki phase.
                        calculate_j_state, -- Calculate j phase.
                        read_sj_state,     -- Read Sj phase.
                        write_in_j_state,  -- Write Si in address j.
                        write_in_i_state); -- Write Sj in address i.
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------- Signal declaration
signal index_i       : std_logic_vector(7 downto 0);-- Incrementing index i.
signal index_j       : std_logic_vector(7 downto 0);-- Index j.
signal data_si       : std_logic_vector(7 downto 0);-- Data Si.
signal data_sj       : std_logic_vector(7 downto 0);-- Data Sj.
signal sbox_state    : sboxgen_state_type;-- State in the sbox state machine.
signal next_sbox_state:sboxgen_state_type;-- Next state in the sbox state mach.
------------------------------------------------------ End of Signal declaration

begin

  --------------------------------------- Main State Machine for S-Box Generator
  -- This is the main state machine in the S-Box Generator block. The sequence
  -- starts when the start_sboxgen signal is set to one by the RC4_Sequencer.
  -- The Si and Ki data are then read and the new j calculated. Sj is then read
  -- and Si and Sj are swapped.
  sboxgen_statemachine: process (sbox_state, start_sboxgen, index_i)
  begin
    case sbox_state is
      when idle_state =>
        if start_sboxgen = '1' then 
          next_sbox_state <= read_si_state;
        else
          next_sbox_state <= idle_state;
        end if;

      when read_si_state =>
        next_sbox_state <= read_ki_state;

      when read_ki_state =>
        next_sbox_state <= calculate_j_state;

      when calculate_j_state =>
        next_sbox_state <= read_sj_state;

      when read_sj_state =>
        next_sbox_state <= write_in_j_state;

      when write_in_j_state =>
        next_sbox_state <= write_in_i_state;

      when write_in_i_state =>
        if index_i = "011111111" then
          next_sbox_state <= idle_state;
        else
          next_sbox_state <= read_si_state;
        end if;

      when others =>
        next_sbox_state <= idle_state;

    end case;
  end process sboxgen_statemachine;

  sboxgen_clk: process (reset_n, clk)
  begin
    if reset_n = '0' then
      sbox_state <= idle_state;         -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      sbox_state <= next_sbox_state;    -- Update the S-Box State Machine.
    end if;
  end process sboxgen_clk;
  -------------------------------- End of Main State Machine for S-Box Generator

  ---------------------------------------------------------- Index_i Calculation
  -- This process generates the index_i. It is checked and incremented at the
  -- last state of the main state machine (write_in_j_state).
  index_i_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then               -- Reset the counter.
      index_i <= (others => '0');
    elsif (clk'event and clk = '1') then
      if sbox_state = write_in_i_state then
        if index_i = "11111111" then
          index_i <= (others => '0');   -- Reset the counter.
        else
          index_i <= index_i + "00000001";-- Increment the counter.
        end if;
      elsif sbox_state = idle_state then-- Reset the counter.
        index_i <= (others => '0');
      end if;
    end if;
  end process index_i_pr;
  --------------------------------------------------- End of Index_i Calculation

  ---------------------------------------------------------- Index_j Calculation
  -- This process generates the index_j. It is calculated in the transition
  -- from  state calculate_j_state to state read_sj_state following the
  -- formula j=(j+Si+Ki) mod 256.
  index_j_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then               -- Reset the index.
      index_j <= (others => '0');
    elsif (clk'event and clk = '1') then
      if sbox_state = calculate_j_state then
        index_j <= index_j + data_si + sr_rdata;  -- addition = (j+Si+Ki)
      elsif sbox_state = idle_state then-- Reset the index.
        index_j <= (others => '0');
      end if;
    end if;
  end process index_j_pr;
  --------------------------------------------------- End of Index_j Calculation

  ------------------------------------------------- SRAM output lines generation
  -- The address where the data is read/written depends on the state in the
  -- state machine:
  -- In state read_si_state the data is read from '0'&index_i.
  -- In state read_ki_state the data is read frm '1'&index_i.
  -- In state read_sj_state the data is read from '0'&index_j.
  -- In state write_in_j_state the data Si is written in '0'&index_j.
  -- In state write_in_i_state the data Sj is written in '0'&index_i.
  sr_out_variable_pr: process (sbox_state, index_i, index_j, data_sj, data_si)
  begin
    case sbox_state is
      when read_si_state =>             -- Read data from Si address.
        sr_address <= '0' & index_i;
        sr_wen     <= '1';
        sr_wdata   <= (others => '0');
      when read_ki_state =>             -- Read data from Ki address.
        sr_address <= '1' & index_i;
        sr_wen     <= '1';
        sr_wdata   <= (others => '0');
      when read_sj_state =>             -- Read data from Sj address.
        sr_address <= '0' & index_j;
        sr_wen     <= '1';
        sr_wdata   <= (others => '0');
      when write_in_j_state =>          -- Write Si data in j address.
        sr_address <= '0' & index_j;
        sr_wen     <= '0';
        sr_wdata   <= data_si;
      when write_in_i_state =>          -- Write Sj data in i address.
        sr_address <= '0' & index_i;
        sr_wen     <= '0';
        sr_wdata   <= data_sj;
      when others =>
        sr_address <= (others => '0');
        sr_wen     <= '1';
        sr_wdata   <= (others => '0');
    end case;
  end process sr_out_variable_pr;
  ------------------------------------------ End of SRAM output lines generation

  ------------------------------------------------------- chip enable generation
  -- This process generates the signal sr_cen, which enables the SRAM.
  sr_cen <= '1' when sbox_state = idle_state
       else '0';
  ------------------------------------------- End of SRAM chip enable generation

  ------------------------------------------------------- SRAM Read Data Storage
  -- The data read is stored in internal variable called data_si and data_sj.
  -- The data read is valid one clock cycle after the address has been sampled,
  -- that means that the data read in state read_si_state will be stored in
  -- state read_ki_state and so on.
  sr_rdata_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      data_si <= (others => '0');
      data_sj <= (others => '0');
    elsif (clk'event and clk = '1') then
      case sbox_state is
        when read_ki_state =>           -- Store Si.
          data_si <= sr_rdata;
        when write_in_j_state =>        -- Store Sj.
          data_sj <= sr_rdata;
        when others => null;
      end case;
    end if;
  end process sr_rdata_pr;
  ------------------------------------------------ End of SRAM Read Data Storage

  ------------------------------------------------------ sboxgen_done Generation
  -- The flag sboxgen_done indicates that the S-Box generation sequence has
  -- finished.
  sboxgen_done <= '1' when next_sbox_state = idle_state
             else '0';
  ----------------------------------------------- End of sboxgen_done Generation

end RTL;
