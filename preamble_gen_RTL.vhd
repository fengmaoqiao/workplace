

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: preamble_gen.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Preamble generation. The preamble patterns are read from ROMS.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/preamble_gen/vhdl/rtl/preamble_gen.vhd,v  
--  Log: preamble_gen.vhd,v  
-- Revision 1.3  2004/12/14 10:58:05  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.2  2003/04/15 09:59:06  Dr.A
-- Outputs no more registered.
--
-- Revision 1.1  2003/03/13 15:04:55  Dr.A
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
 
--library preamble_gen_rtl;
library work;
--use preamble_gen_rtl.preamble_gen_pkg.all;
use work.preamble_gen_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity preamble_gen is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk             : in  std_logic; -- Module clock
    reset_n         : in  std_logic; -- Asynchronous reset
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i        : in  std_logic; -- TX path enable.
    data_ready_i    : in  std_logic; -- '1' when next block ready to accept data
    add_short_pre_i : in  std_logic_vector(1 downto 0); -- pre-preamble value.
    --
    end_preamble_o  : out std_logic; -- High at the end of the preamble.
    --------------------------------------
    -- Data
    --------------------------------------
    i_out           : out std_logic_vector(9 downto 0); -- I preamble data.
    q_out           : out std_logic_vector(9 downto 0)  -- Q preamble data.
  );

end preamble_gen;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of preamble_gen is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  -- Type for the preamble generation state machine.
  type PREAMBLE_STATE_T is (idle_state, -- idle state.
                   short_pre_state,     -- short sequence state.
                   long_pre_dec_state,  -- Long sequence, decrementing state.
                   long_pre_inc_state); -- Long sequence, incrementing state.

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for the preamble generation state machine.
  signal prea_state_cur  : PREAMBLE_STATE_T;
  signal prea_state_next : PREAMBLE_STATE_T;
  signal index           : std_logic_vector(4 downto 0);
  signal index_rs        : std_logic_vector(4 downto 0);
  -- The rep_cnt counter indicates how many times a symbol must be sent.
  signal rep_cnt         : std_logic_vector(3 downto 0);
  signal rep_cnt_rs      : std_logic_vector(3 downto 0);
  -- init value = 10 + add_short_pre_i
  signal rep_cnt_init    : std_logic_vector(3 downto 0);
          
-----------------------------------------------------------------------------
-- Architecture Body
-----------------------------------------------------------------------------
begin
   
  --------------------------------------------
  -- Preamble generation state machine
  --------------------------------------------
  -- The preamble consists in 10+add_short_pre_i short preamble symbols, 
  -- followed by a long preamble symbol cyclic prefix and two long preamble
  -- symbol. index_rs counts the data in a symbol. rep_cnt_rs counts how many
  -- times a symbol must be sent.
  
  -- Combinational process.
  fsm_comb_p : process (data_ready_i, index_rs, prea_state_cur, rep_cnt_rs)
  begin
    prea_state_next <= prea_state_cur;

    case prea_state_cur is

      when idle_state =>
        if data_ready_i = '1' then
          prea_state_next <= short_pre_state;
        end if;

      -- Go to long_pre_dec_state when the 16 data of the 10th short preamble
      -- symbol have been sent.
      when short_pre_state =>
        if data_ready_i = '1' and index_rs(3 downto 0) = "1111"
                              and rep_cnt_rs = "0000" then
          prea_state_next <= long_pre_dec_state;
        end if;

      when long_pre_dec_state =>
        -- Half a long symbol have been sent.
        if data_ready_i = '1' and index_rs = "00001" then
          -- No more symbol to send, end of preamble.
          if rep_cnt_rs(1 downto 0) = "00" then
            prea_state_next <= idle_state;
          else -- Send following half symbol.
            prea_state_next <= long_pre_inc_state;
          end if;
        end if;

      when long_pre_inc_state =>
        -- Half a long symbol have been sent, send second half.
        if data_ready_i = '1' and index_rs = "11111" then
          prea_state_next <= long_pre_dec_state;
        end if;

      when others => null;
    end case;
  end process fsm_comb_p;

  -- Preamble state machine sequential process.
  fsm_seq_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      prea_state_cur <= idle_state;
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        prea_state_cur <= idle_state;
      else
        prea_state_cur <= prea_state_next;
      end if;
    end if;
  end process fsm_seq_p;

  
  --------------------------------------------
  -- Preamble data generation and counters management
  --------------------------------------------
  
  -- rep_cnt init value is 10 (nb of symbols in the short preamble) + the value
  -- in add_short_pre_i (pre-preamble)
  rep_cnt_init <= "1001" + add_short_pre_i;

  preamble_gen_p : process (data_ready_i, index_rs, prea_state_cur,
                            rep_cnt_init, rep_cnt_rs)

    variable i_v           : std_logic_vector(9 downto 0);
    variable q_v           : std_logic_vector(9 downto 0);
    variable index_short_v : integer range 0 to 15;
    variable index_long_v  : integer range 0 to 32;

  begin
    index_short_v := conv_integer(index_rs(3 downto 0));
    index_long_v  := conv_integer(index_rs);

    -- Default values.
    index           <= index_rs;
    rep_cnt         <= rep_cnt_rs;
    end_preamble_o  <= '0';
    i_v             := (others => '0');
    q_v             := (others => '0');
    
    case prea_state_cur is

      when idle_state =>
        rep_cnt <= rep_cnt_init;
        -- Short preamble first data is sent on the outputs.
        i_v     := short_seq_re(index_short_v);
        q_v     := short_seq_im(index_short_v);
        -- Increment index_rs when going to short_pre_state.
        if data_ready_i = '1' then
          index <= index_rs + 1;
        end if;

      when short_pre_state =>
        i_v := short_seq_re(index_short_v);
        q_v := short_seq_im(index_short_v);
        -- Increment the index counter when the following block is ready to
        -- accept data.
        if data_ready_i = '1' then
          index <= index_rs + 1;
          -- Decrement rep_cnt when the 16 data of a data symbol are sent.
          if index_rs(3 downto 0) = "1111" then
            rep_cnt <= rep_cnt_rs - 1;
            -- Init index and rep_cnt for long_pre_dec_state when rep_cnt_init
            -- symbols have been sent.
            if rep_cnt_rs = "0000" then
              -- Send the second half of the long preamble symbol as cyclic
              -- prefix (guard interval).
              index   <= "00000";
              -- The pattern will be sent three times: 1 cyclic prefix and two
              -- long preamble symbols.
              rep_cnt <= "0010";
            end if;
          end if;
        end if;
        
      when long_pre_dec_state =>
        -- Due to symetry in the long preamble sample, only half of the long
        -- preamble symbol pattern is stored in long_seq_re table. Data 33 to 
        -- 63 are obtained by reading data 31 downto 1 and inverting the 
        -- imaginary part.
        if index_rs = "0000" then -- First value must be inverted.
          i_v := "1100011100";
        else
          i_v := long_seq_re(index_long_v);
        end if;
        q_v := not(long_seq_im(index_long_v)) + 1;

        -- Send data when the following block is ready.
        if data_ready_i = '1' then
          -- Decrement index to read data 31 downto 1.
          index <= index_rs - 1;
          if index_rs = "00001" then -- half symbol sent.
            rep_cnt <= rep_cnt_rs - 1;
            -- Set end_preamble when GI2 and two long symbols have been sent.
            if rep_cnt_rs(1 downto 0) = "00" then
              end_preamble_o  <= '1';
            end if;
          end if;
        end if;
        
      when long_pre_inc_state =>
        -- send first half of the long preamble symbol.
        i_v := long_seq_re(index_long_v);
        q_v := long_seq_im(index_long_v);
        if data_ready_i = '1' then
          index <= index_rs + 1;
        end if;

      when others => null;
    end case;
    
    -- Assign output signals.
    i_out <= i_v;
    q_out <= q_v;

  end process preamble_gen_p;


  --------------------------------------------
  -- Registers
  --------------------------------------------
  registers_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      index_rs   <= (others => '0');
      rep_cnt_rs <= (others => '0');
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        index_rs   <= (others => '0');
        rep_cnt_rs <= (others => '0');
      else
        index_rs   <= index;
        rep_cnt_rs <= rep_cnt;
      end if;
    end if;
  end process registers_p;

end RTL;
