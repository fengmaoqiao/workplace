
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: t1t2_demux.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.8  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : T1T2 Demultiplexer
--               This block directs the long preamble (T1 and T2) symbols to the
--               fine frequency estimation block, to calculate the frequency
--               correction required, and to TCombine_preamble_mux for further
--               processing.
--               data_ready, which has a long path, is registered. A data
--               buffer is needed to take into account the delay inserted.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/t1t2_demux/vhdl/rtl/t1t2_demux.vhd,v  
--  Log: t1t2_demux.vhd,v  
-- Revision 1.8  2004/01/12 15:31:24  Dr.B
-- complete sensitivity list.
--
-- Revision 1.7  2003/04/11 14:33:42  Dr.B
-- add symbol_i_memo on sm transition long_preamble -> rest_of_data.
--
-- Revision 1.6  2003/04/11 13:04:02  Dr.B
-- added memorization of start_of_symbol_i when data_ready 1 ->0.
--
-- Revision 1.5  2003/04/11 09:06:08  Dr.B
-- changes for start_of_symbol gen.
--
-- Revision 1.4  2003/04/03 15:16:17  Dr.B
-- register input data only when data_valid_i = '1'.
--
-- Revision 1.3  2003/04/01 13:54:52  Dr.B
-- memorize data when data_ready => '0'.
--
-- Revision 1.2  2003/03/28 12:53:21  Dr.B
-- bug on data_valid generation corrected.
--
-- Revision 1.1  2003/03/27 17:18:05  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity t1t2_demux is
  generic (
    data_size_g : integer := 11);       -- size of data (i_i/q_i/i_o/q_i)
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                        : in  std_logic;  -- clock (80 MHz)
    reset_n                    : in  std_logic;  -- asynchronous negative reset
    sync_reset_n               : in  std_logic;  -- synchronous negative reset
    --------------------------------------
    -- Controls
    --------------------------------------
    i_i                        : in  std_logic_vector(data_size_g-1 downto 0);
    q_i                        : in  std_logic_vector(data_size_g-1 downto 0);
    data_valid_i               : in  std_logic;  -- input data valid
    start_of_burst_i           : in  std_logic;  -- next valid data input belongs to the next burst
    start_of_symbol_i          : in  std_logic;  -- next valid data input belongs to the next symbol
    ffe_data_ready_i           : in  std_logic;  -- 0 do not output more data (from ffe)  
    tcombmux_data_ready_i      : in  std_logic;  -- 0 do not output more data (from tcombmux)
    --
    data_ready_o               : out std_logic;  -- do not input more data    
    ffe_start_of_burst_o       : out std_logic;  -- next valid data output belongs to the next burst (for ffe)   
    ffe_start_of_symbol_o      : out std_logic;  -- next valid data output belongs to the next symbol (for ffe)   
    ffe_data_valid_o           : out std_logic;  -- output data valid for the ffe   
    tcombmux_data_valid_o      : out std_logic;  -- output data valid for the tcombmux   
    tcombmux_start_of_symbol_o : out std_logic;  -- next valid data output belongs to the next symbol (for tcomb mux)
    i_o                        : out std_logic_vector(data_size_g-1 downto 0);
    q_o                        : out std_logic_vector(data_size_g-1 downto 0)


  );

end t1t2_demux;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of t1t2_demux is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type DMX_STATE_T is (idle_e,            -- wait for start_of_burst
                       long_preamble_e,   -- T1-T2 coarse - T1-T2 fine are sent to ffe
                       rest_of_data_e);   -- the rest of data are sent to tcomb

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Nb of symbol to send to ffe = 3 + 1 = T1-T2 coarse - T1-T2 fine
  constant NB_SYMBOL_CT             : std_logic_vector(1 downto 0) := "11"; 
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- State Machines
  signal dmx_state                  : DMX_STATE_T;
  signal dmx_next_state             : DMX_STATE_T;
  -- Symbol Counter (0->3 = ffe destination | after = tcombmux destination)
  signal symbol_count               : std_logic_vector(1 downto 0);
  -- Control Signals
  signal data_ready                 : std_logic;
  signal tcombmux_start_of_symbol   : std_logic;
  signal start_of_symb_memo         : std_logic;
  signal symbol_i_memo              : std_logic;
  signal ffe_start_of_symbol        : std_logic;
  signal one_data_in_buffer         : std_logic; -- high when 1 data hasn't been taken into account by tcomb/ffe
  -- Memorized input when data ready goes low (mem last data of prev block)
  signal i_memo                     : std_logic_vector(data_size_g-1 downto 0);
  signal q_memo                     : std_logic_vector(data_size_g-1 downto 0);
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- SM = Combinational Part
  -----------------------------------------------------------------------------
  dmx_fsm_p : process (dmx_state, ffe_data_ready_i, one_data_in_buffer,
                       start_of_burst_i, start_of_symbol_i, symbol_count,
                       symbol_i_memo)
  begin  -- process dmx_fsm
    -- After a start_of_burst from frequency correction, the data is forwarded to
    -- the fine frequency estimation. from the fifth symbol, the data is
    -- forwarded to the tcombpremux.
    if start_of_burst_i = '1' then
      dmx_next_state <= long_preamble_e; -- the long preamble is starting...
    else
       
      case dmx_state is
        
        -- Data are sent to Fine Freq Estim
        when long_preamble_e =>
          if (start_of_symbol_i = '1' or symbol_i_memo = '1') and ffe_data_ready_i = '1'
             and one_data_in_buffer = '0' and symbol_count = NB_SYMBOL_CT then
            -- after 4 start_of_symbol, the t1t2_demux sends the data to tcombmux.
            -- one_data_in_buffer should be '0' as all data should be sent before
            -- leaving the state. 
            dmx_next_state <= rest_of_data_e;
          else
            dmx_next_state <= long_preamble_e;
          end if;

        -- Data are sent to Tcomb
        when rest_of_data_e =>
          dmx_next_state <= rest_of_data_e;
          
        when others =>
          dmx_next_state <= idle_e;
      end case;
    end if;
  end process dmx_fsm_p;

  -----------------------------------------------------------------------------
  -- SM =  Sequential Part 
  -----------------------------------------------------------------------------
  seq_sm_p : process (clk, reset_n)
  begin  -- process control_registers
    if reset_n = '0' then                 -- asynchronous reset (active low)
      dmx_state                 <= idle_e;
    elsif clk'event and clk = '1' then    -- rising clock edge
      if sync_reset_n = '0' then
        dmx_state                <= idle_e;
      else
        dmx_state                <= dmx_next_state;
      end if;      
    end if;
  end process seq_sm_p;
  
  -----------------------------------------------------------------------------
  -- Control Process
  -----------------------------------------------------------------------------
    control_p : process (clk, reset_n)
    begin  -- process dmx_fsm
      if reset_n = '0' then
        ffe_start_of_burst_o       <= '0';
        ffe_start_of_symbol        <= '0';
        ffe_data_valid_o           <= '0';
        tcombmux_start_of_symbol   <= '0';
        start_of_symb_memo         <= '0';
        tcombmux_data_valid_o      <= '0';
        data_ready                 <= '1';
        symbol_count               <= "00";
      elsif clk'event and clk = '1' then
        if start_of_burst_i = '1' then
          ffe_start_of_burst_o       <= '1';
          ffe_start_of_symbol        <= '1';
          ffe_data_valid_o           <= '0';
          tcombmux_start_of_symbol   <= '0';
          start_of_symb_memo         <= '0';
          tcombmux_data_valid_o      <= '0';
          data_ready                 <= '1';
          symbol_count               <= "00";
        else
          ffe_start_of_burst_o       <= '0';
          data_ready                 <= '1';

          -- memorize the start_of_symbol_o position, as if it is high, input will
          -- remain high one period more than needed (because of delay of data_ready_o)
          start_of_symb_memo <= tcombmux_start_of_symbol or ffe_start_of_symbol;

          case dmx_next_state is

            when idle_e =>
              ffe_data_valid_o           <= '0'; 
              tcombmux_data_valid_o      <= '0';
              tcombmux_start_of_symbol   <= '0';
              start_of_symb_memo         <= '0';
              ffe_start_of_symbol        <= '0';
             
            -------------------------------------------------------------------
            -- Long Preamble = For FFE
            -------------------------------------------------------------------
            when long_preamble_e =>
              -- Data are for the Fine Freq Estim          
              tcombmux_data_valid_o      <= '0';
              tcombmux_start_of_symbol   <= '0';
              -- Data Ready is data_ready of the ffe
              data_ready          <= ffe_data_ready_i;
              
              if (start_of_symbol_i = '1' or symbol_i_memo = '1')
                                         and ffe_data_ready_i   = '1'
                                         and one_data_in_buffer = '0'
                                         and start_of_symb_memo = '0' then
              -- one_data_in_buffer should be '0' as all data should be sent before
              -- leaving the symbol. 
                symbol_count     <= symbol_count + '1'; -- a new symbol is arriving
                ffe_data_valid_o <= '0'; 
                 -- start of symbol for ffe
                ffe_start_of_symbol   <= '1';
                
              elsif ffe_data_ready_i = '1' then
                 ffe_start_of_symbol   <= '0'; -- 1-> 0 only when ready
               
                if (data_valid_i = '1' and data_ready = '1') or one_data_in_buffer = '1' then
                  -- new data for ffe
                  ffe_data_valid_o <= '1';
                else
                  ffe_data_valid_o <= '0'; -- 1-> 0 only when ready
                end if;
                 
              end if;

            -------------------------------------------------------------------
            -- Rest of Data = For Tcomb
            -------------------------------------------------------------------
            when rest_of_data_e =>
              -- Data are for the TCombPremux       
              ffe_data_valid_o      <= '0';
              ffe_start_of_symbol   <= '0';
              -- Data Ready is data_ready of the tcombmux
              data_ready   <= tcombmux_data_ready_i;
                           
              if (start_of_symbol_i = '1' or symbol_i_memo = '1')
                and ((tcombmux_data_ready_i = '1'
                      and tcombmux_start_of_symbol = '0'
                      and one_data_in_buffer = '0'
                      and start_of_symb_memo = '0')
                or dmx_state = long_preamble_e )then
                -- The TComb will put ready high only if start_of_symbol and
                -- other conditions
                tcombmux_data_valid_o      <= '0';                
                -- start of symbol for tcombmux
                tcombmux_start_of_symbol <= '1';
              elsif tcombmux_data_ready_i = '1' then
                tcombmux_start_of_symbol <= '0'; -- 1-> 0 only when ready
                if (data_valid_i = '1' and data_ready = '1') or one_data_in_buffer = '1'  then
                  -- new data for tcomb 
                  tcombmux_data_valid_o <= '1';
                else
                  tcombmux_data_valid_o <= '0'; -- 1-> 0 only when ready
                end if;
              end if;
              
            when others =>
              null;
              
          end case;
        end if;
      end if;
    end process control_p;

  -- data_ready should be low during the first start_of_symbol of the tcomb.
  data_ready_o <= '0' when start_of_symbol_i = '1' and dmx_next_state = rest_of_data_e and dmx_state = long_preamble_e
                  else data_ready;

  -- Control Signals Output Linking
  tcombmux_start_of_symbol_o <= tcombmux_start_of_symbol;
  ffe_start_of_symbol_o      <= ffe_start_of_symbol;

  -----------------------------------------------------------------------------
  -- Memorization of start_of_symbol_i
  -----------------------------------------------------------------------------
  -- When data_ready_i 1 -> 0, a start_of_symbol_i can be missed by the t1t2_demux.
  -- It needs to be memorized
  memo_symbol_p: process (clk, reset_n)
  begin  -- process memo_symbol_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      symbol_i_memo <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        -- init register
        symbol_i_memo <= '0';
        
      elsif (   (ffe_data_ready_i ='0'       and dmx_state = long_preamble_e)
          or (tcombmux_data_ready_i = '0' and dmx_state = rest_of_data_e))
       and start_of_symbol_i = '1' then
        -- memorize the start_of_symbol_i
        symbol_i_memo <= '1';
        
      elsif symbol_i_memo <= '1' and one_data_in_buffer = '0' 
           and ((ffe_data_ready_i = '1' and dmx_state = long_preamble_e)
          or    (tcombmux_data_ready_i = '1' and dmx_state = rest_of_data_e)) then
        -- the start_of_symbol_o will be sent - no memo any more
        symbol_i_memo <= '0';
      end if;
    end if;
  end process memo_symbol_p;
 
  -----------------------------------------------------------------------------
  -- Data path
  -----------------------------------------------------------------------------
  data_registers_p : process (clk, reset_n)
  begin  -- process data_registers
    if reset_n = '0' then  -- asynchronous reset (active low)
      i_o    <= (others => '0');
      q_o    <= (others => '0');
      i_memo <= (others => '0');
      q_memo <= (others => '0');
      one_data_in_buffer <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        one_data_in_buffer <= '0';
            
      -- Memorize data when data_ready_i goes down in order to not loose the
      -- last data that the freq_corr has generated. 
      elsif (ffe_data_ready_i = '0'   and data_ready = '1' and data_valid_i = '1'
                                      and dmx_next_state = long_preamble_e)
      or (tcombmux_data_ready_i = '0' and data_ready = '1' and data_valid_i = '1'
                                      and dmx_next_state = rest_of_data_e) then
        i_memo <= i_i;
        q_memo <= q_i;
        one_data_in_buffer <= '1'; -- and memorize that there is a data in the buffer
      end if;

      -- Store Registered Input
      if (ffe_data_ready_i = '1'        and data_ready = '0' and dmx_next_state = long_preamble_e)
        or (tcombmux_data_ready_i = '1' and data_ready = '0' and dmx_next_state = rest_of_data_e) then
        i_o <= i_memo;
        q_o <= q_memo;
        one_data_in_buffer <= '0'; -- the data has been treated

        -- Registered Input
      elsif ((ffe_data_ready_i = '1'     and dmx_next_state = long_preamble_e)
        or (tcombmux_data_ready_i = '1' and dmx_next_state = rest_of_data_e))
        and data_valid_i = '1' then
        -- must accept data if the data_ready  = '1'
        i_o <= i_i;
        q_o <= q_i;       
      end if;     
    end if;
  end process data_registers_p;
  
end RTL;
