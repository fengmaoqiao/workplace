
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: signal_control.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Signal control of the Channel decoder
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/channel_decoder/vhdl/rtl/signal_control.vhd,v  
--  Log: signal_control.vhd,v  
-- Revision 1.1  2003/03/24 10:18:04  Dr.C
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
-- Entity
--------------------------------------------------------------------------------
entity signal_control is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n              : in  std_logic;  -- Async Reset
    clk                  : in  std_logic;  -- Clock
    sync_reset_n         : in  std_logic;  -- Software reset

    -----------------------------------------------------------------------
    -- Symbol Strobe
    -----------------------------------------------------------------------
    enable_i             : in  std_logic;  -- Enable signal
    enable_o             : out std_logic;  -- Enable signal

    data_valid_i         : in  std_logic;  -- Data_valid input
    data_valid_o         : out std_logic;  -- Data_valid output

    -----------------------------------------------------------------------
    -- Data Interface
    -----------------------------------------------------------------------
    start_signal_field_i : in std_logic;
    end_field_i          : in std_logic    
  );

end signal_control;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of signal_control is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type SIGNAL_CONTROL_STATE_T is (IDLE,
                                  DECODE,
                                  SEND_VALID
                                 );

  type SIGNAL_CONTROL_VALID_T is (INVALID,
                                  VALID);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal signal_control_curr_state : SIGNAL_CONTROL_STATE_T;
  signal signal_control_next_state : SIGNAL_CONTROL_STATE_T;
  signal data_valid_state          : SIGNAL_CONTROL_VALID_T;
  signal end_field_state           : SIGNAL_CONTROL_VALID_T;
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  --------------------------------------
  -- State sequential process
  --------------------------------------
  state_sequential_p : process (clk, reset_n)
  begin
    if (reset_n = '0') then                -- asynchronous reset (active low)
      signal_control_curr_state <= IDLE;

    elsif (clk = '1') and (clk'event) then -- rising clock edge
      if (sync_reset_n = '0') then         -- synchronous reset (active low)
        signal_control_curr_state <= IDLE;
      elsif (enable_i = '1') then          -- enable condition (active high)
        signal_control_curr_state <= signal_control_next_state;
      end if;

    end if;
  end process state_sequential_p;


  --------------------------------------
  -- State combinational process
  --------------------------------------
  state_combinational_p : process (start_signal_field_i,
                                   enable_i,
                                   signal_control_curr_state,
                                   data_valid_state,
                                   end_field_state)
  begin

    enable_o                  <= '0';
    data_valid_o              <= '0';
    signal_control_next_state <= signal_control_curr_state;

    if start_signal_field_i = '1' then
      enable_o <= enable_i;
      signal_control_next_state <= DECODE;
    else
      case signal_control_curr_state is

        when DECODE => 
          if data_valid_state = VALID then
            enable_o <= enable_i;
            if end_field_state = VALID then
              signal_control_next_state <= SEND_VALID;
            end if;
          end if;

        when SEND_VALID => 
          data_valid_o              <= '1';  
          signal_control_next_state <= IDLE;
              
        when others => 
          signal_control_next_state <= IDLE;

      end case;

    end if;
  end process state_combinational_p;


  --------------------------------------
  -- Data valid sequential process
  --------------------------------------
  datavalid_sequential_p : process (clk, reset_n)
  begin
    if (reset_n = '0') then             -- asynchronous reset (active low)
      data_valid_state <= INVALID;

    elsif (clk = '1') and (clk'event) then     -- rising clock edge
      if sync_reset_n = '0' then        --  synchronous reset (active low)
        data_valid_state <= INVALID;
      elsif enable_i = '1' then         --  enable condition (active high)

        if data_valid_i = '1' then
          data_valid_state <= VALID; 
        else
          data_valid_state <= INVALID;
        end if;
      end if;
    end if;
  end process datavalid_sequential_p;


  --------------------------------------
  -- End field sequential process
  --------------------------------------
  endfield_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      end_field_state <= INVALID;
      
    elsif (clk = '1') and (clk'event) then     -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        end_field_state <= INVALID;
      elsif enable_i = '1' then        --  enable condition (active high)
        if end_field_i = '1' then
          end_field_state <= VALID; 
        else
          end_field_state <= INVALID;
        end if;
      end if;
    end if;
  end process endfield_sequential_p;


end RTL;
