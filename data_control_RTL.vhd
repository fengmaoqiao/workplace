
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: data_control.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Data control of the Channel decoder
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/channel_decoder/vhdl/rtl/data_control.vhd,v  
--  Log: data_control.vhd,v  
-- Revision 1.1  2003/03/24 10:17:59  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity data_control is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n            : in  std_logic;  -- Async Reset
    clk                : in  std_logic;  -- Clock
    sync_reset_n       : in  std_logic;  -- Software reset

    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i           : in  std_logic;  -- Enable signal
    enable_o           : out std_logic;  -- Enable signal

    data_valid_i       : in  std_logic;  -- Data_valid input
    data_valid_o       : out std_logic;  -- Data_valid output

    start_data_field_i : in  std_logic;
    start_data_field_o : out std_logic;

    end_data_field_i   : in  std_logic;
    end_data_field_o   : out std_logic
  );

end data_control;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of data_control is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type DATA_CONTROL_STATE_T is (IDLE,
                                SEND_START_BURST,
                                DATA_DECODE,
                                SEND_END_BURST);

  type VALID_T is (INVALID,
                   VALID);
                                      
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal data_control_curr_state : DATA_CONTROL_STATE_T;
  signal data_control_next_state : DATA_CONTROL_STATE_T;
  signal data_valid_state        : VALID_T;
  signal end_field_state         : VALID_T;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  --------------------------------------
  -- Data control state sequential process
  --------------------------------------
  state_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      data_control_curr_state <= IDLE;
    elsif clk = '1' and clk'event then -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        data_control_curr_state <= IDLE;
      elsif enable_i = '1' then        --  enable condition (active high)
        data_control_curr_state <= data_control_next_state;
      end if;
    end if;
  end process state_sequential_p;


  --------------------------------------
  --  Data control combinational process
  --------------------------------------
  state_combinational_p: process (data_control_curr_state,
                                  enable_i, 
                                  data_valid_state,
                                  start_data_field_i,
                                  end_field_state)
  begin
    enable_o                <= '0';
    data_valid_o            <= '0';
    start_data_field_o      <= '0';
    end_data_field_o        <= '0';
    data_control_next_state <= data_control_curr_state;

    if start_data_field_i = '1' then
      data_control_next_state <= SEND_START_BURST;
    else

      case data_control_curr_state is

        when SEND_START_BURST => 
          if data_valid_state = VALID then
            enable_o                <= enable_i;
            start_data_field_o      <= '1';
            data_control_next_state <= DATA_DECODE;
          end if;

        when DATA_DECODE => 
          if data_valid_state = VALID then
            enable_o     <= enable_i;
            data_valid_o <= '1';
            if end_field_state = VALID then
              data_control_next_state  <=  SEND_END_BURST;
            end if;
          end if;
              
        when SEND_END_BURST => 
          enable_o                <= enable_i;
          data_valid_o            <= '1';
          end_data_field_o        <= '1';
          data_control_next_state <= IDLE;

        when others => 
          data_control_next_state <= IDLE;

      end case;
      
    end if;
  end process state_combinational_p;


  --------------------------------------
  -- Data valid sequential process
  --------------------------------------
  datavalid_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      data_valid_state <= INVALID;

    elsif clk = '1' and clk'event then -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        data_valid_state <= INVALID;
      elsif enable_i = '1' then        --  enable condition (active high)
        if data_valid_i = '1' then
          data_valid_state <= VALID; 
        else
          data_valid_state <= INVALID;
        end if;
      end if;
    end if;
  end process datavalid_sequential_p;


  --------------------------------------
  --  End field sequential process
  --------------------------------------
  endfield_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      end_field_state <= INVALID;

    elsif clk = '1' and clk'event then -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        end_field_state <= INVALID;
      elsif enable_i = '1' then        --  enable condition (active high)
        if end_data_field_i = '1' then
          end_field_state <= VALID; 
        else
          end_field_state <= INVALID;
        end if;
      end if;
    end if;
  end process endfield_sequential_p;


end RTL;
