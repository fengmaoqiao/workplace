
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: deintpun_control.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.5  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Deinterleaver & depuncturer control block.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/deintpun/vhdl/rtl/deintpun_control.vhd,v  
--  Log: deintpun_control.vhd,v  
-- Revision 1.5  2005/02/21 13:04:25  Dr.C
-- #BugId:1083#
-- Defined range to bits_per_symbol signal.
--
-- Revision 1.4  2004/07/22 13:31:31  Dr.C
-- Added FFs on outputs.
--
-- Revision 1.3  2003/05/16 16:34:18  Dr.J
-- Changed the type of field_length_i
--
-- Revision 1.2  2003/03/28 15:33:37  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.1  2003/03/18 14:29:07  Dr.C
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

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--library deintpun_rtl;
library work;
--use deintpun_rtl.deintpun_pkg.all;
use work.deintpun_pkg.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity deintpun_control is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic;  -- Async Reset
    clk            : in  std_logic;  -- Clock
    sync_reset_n   : in  std_logic;  -- Software reset

    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i       : in  std_logic;  -- Enable signal
    data_valid_i   : in  std_logic;  -- Data Valid signal for input
    data_valid_o   : out std_logic;  -- Data Valid signal for following block

    data_ready_o   : out std_logic;  -- reading phase ready
    
    start_field_i  : in  std_logic;  -- start either signal or data field 
    field_length_i : in  std_logic_vector (15 downto 0);
    qam_mode_i     : in  std_logic_vector (1 downto 0);
    pun_mode_i     : in  std_logic_vector (1 downto 0);

    enable_read_o  : out std_logic;  -- enable softbit output
    enable_write_o : out std_logic;  -- write softbits to deint registers

    write_addr_o   : out CARR_T;
    read_carr_x_o  : out CARR_T;
    read_carr_y_o  : out CARR_T;
    read_soft_x_o  : out SOFT_T;
    read_soft_y_o  : out SOFT_T;
    read_punc_x_o  : out PUNC_T;     -- give out dontcare on soft_x_o
    read_punc_y_o  : out PUNC_T      -- give out dontcare on soft_y_o
  );

end deintpun_control;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of deintpun_control is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type STATE_T is (IDLE,
                   WRITE_SYMBOL,
                   READ_SYMBOL
                   );

  type DATA_VALID_STATE_T is (DATA_INVALID,
                              DATA_VALID);

  subtype SYMBOL_COUNTER_STATE_T is integer range 0 to 34000;
  -- 34000 = 8 * 4095 + 16 + 6 + pad_bits
  subtype SOFTBIT_COUNTER_STATE_T is integer range 1 to 217;
  
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant SOFTBIT_COUNTER_RESET_VALUE_CT : SOFTBIT_COUNTER_STATE_T := 1;
  constant SOFTBIT_COUNTER_INCREMENT_CT   : SOFTBIT_COUNTER_STATE_T := 1;
  constant SYMBOL_COUNTER_RESET_VALUE_CT  : SYMBOL_COUNTER_STATE_T  := 0;

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal curr_state                 : STATE_T;
  signal next_state                 : STATE_T;
  signal data_valid_state           : DATA_VALID_STATE_T;
  signal curr_softbit_counter_state : SOFTBIT_COUNTER_STATE_T;
  signal next_softbit_counter_state : SOFTBIT_COUNTER_STATE_T;  
  signal softbit_counter_condition  : std_logic;
  signal softbit_counter_reset      : std_logic;
  signal curr_symbol_counter_state  : SYMBOL_COUNTER_STATE_T;
  signal next_symbol_counter_state  : SYMBOL_COUNTER_STATE_T;  
  signal symbol_counter_condition   : std_logic;
  signal symbol_counter_reset       : std_logic;

  signal field_length   : FIELD_LENGTH_T;
  signal qam_mode       : std_logic_vector(1 downto 0);
  signal pun_mode       : std_logic_vector(1 downto 0);
  signal data_valid_int : std_logic;
  signal data_ready_int : std_logic;

  signal bits_per_symbol : integer range 1 to 216;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  --------------------------------------
  -- State sequential process
  --------------------------------------
  state_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      curr_state <= IDLE;
    elsif clk = '1' and clk'event then -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        curr_state <= IDLE;
      elsif enable_i = '1' then        --  enable condition (active high)
        curr_state <= next_state;
      end if;
    end if;
  end process state_sequential_p;


  --------------------------------------
  -- State combinational process
  --------------------------------------
  state_combinational_p : process (start_field_i, enable_i, curr_state,
                                   curr_softbit_counter_state,
                                   curr_symbol_counter_state, field_length,
                                   data_valid_state, bits_per_symbol)
  begin
    enable_write_o <= '0';
    enable_read_o  <= '0';
    data_valid_int <= '0';
    data_ready_int <= '0';
    next_state     <= curr_state;
    softbit_counter_condition <= '0';
    softbit_counter_reset     <= '1';

    symbol_counter_condition  <= '0';
    symbol_counter_reset      <= '1';

    if start_field_i = '1' then
      next_state <= WRITE_SYMBOL;
    else

      case curr_state is

        when WRITE_SYMBOL =>
          data_ready_int        <= '1';
          softbit_counter_reset <= '0';
          symbol_counter_reset  <= '0';

          if data_valid_state = DATA_VALID then
            softbit_counter_condition <= '1';
            enable_write_o <= enable_i;
            if curr_softbit_counter_state = SUBCARRIER_PER_SYMBOL_CT then
              softbit_counter_reset    <= '1';
              symbol_counter_condition <= '1';
              data_ready_int           <= '0';
              next_state               <= READ_SYMBOL;
            end if;
          end if;

        when READ_SYMBOL =>
          softbit_counter_reset     <= '0';
          softbit_counter_condition <= '1';
          symbol_counter_reset      <= '0';
          enable_read_o             <= enable_i;
          data_valid_int            <= '1';
          if curr_softbit_counter_state = bits_per_symbol then
            softbit_counter_reset <= '1';
            if curr_symbol_counter_state < field_length  then
              next_state <= WRITE_SYMBOL;
            else
              next_state <= IDLE;
            end if;
          end if;

        when others => 
          next_state <= IDLE;

      end case;

    end if;
  end process state_combinational_p;


  --------------------------------------
  -- Softbit counter combinational process
  --------------------------------------
  softbit_counter_combinational_p : process(curr_softbit_counter_state,
                                            softbit_counter_reset,
                                            softbit_counter_condition)
  begin
    if softbit_counter_reset = '1' then
      next_softbit_counter_state <= SOFTBIT_COUNTER_RESET_VALUE_CT ; 
    elsif softbit_counter_condition = '1' then
      next_softbit_counter_state <= curr_softbit_counter_state
                                    + SOFTBIT_COUNTER_INCREMENT_CT;
    else
      next_softbit_counter_state <= curr_softbit_counter_state;
    end if;
  end process softbit_counter_combinational_p;


  --------------------------------------
  -- Softbit counter sequential process
  --------------------------------------
  softbit_counter_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      curr_softbit_counter_state <= SOFTBIT_COUNTER_RESET_VALUE_CT;
    elsif clk = '1' and clk'event then -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        curr_softbit_counter_state <= SOFTBIT_COUNTER_RESET_VALUE_CT;
      elsif enable_i = '1' then        --  enable condition (active high)
        curr_softbit_counter_state <= next_softbit_counter_state;
      end if;
    end if;
  end process softbit_counter_sequential_p;

  --------------------------------------
  -- Symbol counter combinational process
  --------------------------------------
  symbol_counter_combinational_p : process(curr_symbol_counter_state,
                                           symbol_counter_reset,
                                           symbol_counter_condition,
                                           bits_per_symbol)
  begin
    if symbol_counter_reset = '1' then
      next_symbol_counter_state <= SOFTBIT_COUNTER_RESET_VALUE_CT;
    elsif symbol_counter_condition = '1' then
      next_symbol_counter_state <= curr_symbol_counter_state + bits_per_symbol;
    else
      next_symbol_counter_state <= curr_symbol_counter_state;
    end if;
  end process symbol_counter_combinational_p;


  --------------------------------------
  -- Symbol counter sequential process
  --------------------------------------
  symbol_counter_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      curr_symbol_counter_state <= SYMBOL_COUNTER_RESET_VALUE_CT;
    elsif clk = '1' and clk'event then -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        curr_symbol_counter_state <= SYMBOL_COUNTER_RESET_VALUE_CT;
      elsif enable_i = '1' then        --  enable condition (active high)
        curr_symbol_counter_state <= next_symbol_counter_state;
      end if;
    end if;
  end process symbol_counter_sequential_p;


  --------------------------------------
  -- Datavalid sequential process
  --------------------------------------
  datavalid_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      data_valid_state <= DATA_INVALID;
    elsif clk = '1' and clk'event then -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        data_valid_state <= DATA_INVALID;
      elsif enable_i = '1' then        --  enable condition (active high)
        if start_field_i = '1' then
          data_valid_state <= DATA_INVALID;
        elsif data_valid_i = '1' then
          data_valid_state <= DATA_VALID;
        else
          data_valid_state <= DATA_INVALID;
        end if;
      end if;
    end if;
  end process datavalid_sequential_p;

  --------------------------------------
  -- Output sequential process
  --------------------------------------
  control_out_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      data_valid_o <= '0';
      data_ready_o <= '0';
    elsif clk = '1' and clk'event then -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        data_valid_o <= '0';
        data_ready_o <= '0';
      elsif enable_i = '1' then        --  enable condition (active high)
        data_valid_o <= data_valid_int;
        data_ready_o <= data_ready_int;
      end if;
    end if;
  end process control_out_sequential_p;

  --------------------------------------
  -- Write address mapping process
  --------------------------------------
  write_address_mapping_p : process(curr_state, curr_softbit_counter_state)
  begin
    if curr_state = WRITE_SYMBOL then
      write_addr_o <= TABLE_WRITE_CT(curr_softbit_counter_state);
    else
      write_addr_o <= 0;
    end if;
  end process write_address_mapping_p;


  --------------------------------------
  -- Bits per symbol table process
  --------------------------------------
  bits_per_symbol_table_p : process (pun_mode, qam_mode)
  begin
    case pun_mode is

      when "00" =>     -- 1/2

        case qam_mode is
          when "11" =>            -- BPSK
            bits_per_symbol <= BITS_PER_SYMBOL_BPSK_1_2_CT;
          when "10" =>            -- QPSK
            bits_per_symbol <= BITS_PER_SYMBOL_QPSK_1_2_CT;
          when others =>          -- 16QAM
            bits_per_symbol <= BITS_PER_SYMBOL_QAM16_1_2_CT;
        end case;
        
      when "10" =>     -- 2/3
        case qam_mode is
          when others =>          -- QAM64
            bits_per_symbol <= BITS_PER_SYMBOL_QAM64_2_3_CT;
        end case;

      when others =>    -- 3/4
        case qam_mode is
          when "11" =>            -- BPSK
            bits_per_symbol <= BITS_PER_SYMBOL_BPSK_3_4_CT;
          when "10" =>            -- QPSK
            bits_per_symbol <= BITS_PER_SYMBOL_QPSK_3_4_CT;
          when "01" =>            -- 16QAM
            bits_per_symbol <= BITS_PER_SYMBOL_QAM16_3_4_CT;
          when others =>          -- 64QAM
            bits_per_symbol <= BITS_PER_SYMBOL_QAM64_3_4_CT;
        end case;

    end case;
  end process bits_per_symbol_table_p;


  --------------------------------------
  -- Read address mapping process
  --------------------------------------
  read_address_mapping_p : process (curr_state, curr_softbit_counter_state,
                                    qam_mode, pun_mode)
  begin
    if curr_state = READ_SYMBOL then

      case pun_mode is

        when "00" =>     -- 1/2
          read_punc_x_o <= TABLE_PUNC_X_1_2_CT(curr_softbit_counter_state);
          read_punc_y_o <= TABLE_PUNC_Y_1_2_CT(curr_softbit_counter_state);
        
          case qam_mode is
          
            when "11" =>            -- BPSK
              read_carr_x_o <= TABLE_CARR_X_BPSK_1_2_CT(
                                                    curr_softbit_counter_state);
              read_carr_y_o <= TABLE_CARR_Y_BPSK_1_2_CT(
                                                    curr_softbit_counter_state);
              read_soft_x_o <= TABLE_SOFT_X_BPSK_1_2_CT(
                                                    curr_softbit_counter_state);
              read_soft_y_o <= TABLE_SOFT_Y_BPSK_1_2_CT(
                                                    curr_softbit_counter_state);

            when "10" =>            -- QPSK
              read_carr_x_o <= TABLE_CARR_X_QPSK_1_2_CT(
                                                    curr_softbit_counter_state);
              read_carr_y_o <= TABLE_CARR_Y_QPSK_1_2_CT(
                                                    curr_softbit_counter_state);
              read_soft_x_o <= TABLE_SOFT_X_QPSK_1_2_CT(
                                                    curr_softbit_counter_state);
              read_soft_y_o <= TABLE_SOFT_Y_QPSK_1_2_CT(
                                                    curr_softbit_counter_state);

            when others =>          -- 16QAM
              read_carr_x_o <= TABLE_CARR_X_QAM16_1_2_CT(
                                                    curr_softbit_counter_state);
              read_carr_y_o <= TABLE_CARR_Y_QAM16_1_2_CT(
                                                    curr_softbit_counter_state);
              read_soft_x_o <= TABLE_SOFT_X_QAM16_1_2_CT(
                                                    curr_softbit_counter_state);
              read_soft_y_o <= TABLE_SOFT_Y_QAM16_1_2_CT(
                                                    curr_softbit_counter_state);

          end case;

        when "10" =>     -- 2/3
          read_punc_x_o <= TABLE_PUNC_X_2_3_CT(curr_softbit_counter_state);
          read_punc_y_o <= TABLE_PUNC_Y_2_3_CT(curr_softbit_counter_state);

          case qam_mode is
            when others =>          -- QAM64
              read_carr_x_o <= TABLE_CARR_X_QAM64_2_3_CT(
                                                    curr_softbit_counter_state);
              read_carr_y_o <= TABLE_CARR_Y_QAM64_2_3_CT(
                                                    curr_softbit_counter_state);
              read_soft_x_o <= TABLE_SOFT_X_QAM64_2_3_CT(
                                                    curr_softbit_counter_state);
              read_soft_y_o <= TABLE_SOFT_Y_QAM64_2_3_CT(
                                                    curr_softbit_counter_state);
          end case;

        when others =>     -- 3/4
          read_punc_x_o <= TABLE_PUNC_X_3_4_CT(curr_softbit_counter_state);
          read_punc_y_o <= TABLE_PUNC_Y_3_4_CT(curr_softbit_counter_state);

          case qam_mode is

            when "11" =>            -- BPSK
              read_carr_x_o <= TABLE_CARR_X_BPSK_3_4_CT(
                                                    curr_softbit_counter_state);
              read_carr_y_o <= TABLE_CARR_Y_BPSK_3_4_CT(
                                                    curr_softbit_counter_state);
              read_soft_x_o <= TABLE_SOFT_X_BPSK_3_4_CT(
                                                    curr_softbit_counter_state);
              read_soft_y_o <= TABLE_SOFT_Y_BPSK_3_4_CT(
                                                    curr_softbit_counter_state);

            when "10" =>            -- QPSK
              read_carr_x_o <= TABLE_CARR_X_QPSK_3_4_CT(
                                                    curr_softbit_counter_state);
              read_carr_y_o <= TABLE_CARR_Y_QPSK_3_4_CT(
                                                    curr_softbit_counter_state);
              read_soft_x_o <= TABLE_SOFT_X_QPSK_3_4_CT(
                                                    curr_softbit_counter_state);
              read_soft_y_o <= TABLE_SOFT_Y_QPSK_3_4_CT(
                                                    curr_softbit_counter_state);

            when "01" =>            -- 16QAM
              read_carr_x_o <= TABLE_CARR_X_QAM16_3_4_CT(
                                                    curr_softbit_counter_state);
              read_carr_y_o <= TABLE_CARR_Y_QAM16_3_4_CT(
                                                    curr_softbit_counter_state);
              read_soft_x_o <= TABLE_SOFT_X_QAM16_3_4_CT(
                                                    curr_softbit_counter_state);
              read_soft_y_o <= TABLE_SOFT_Y_QAM16_3_4_CT(
                                                    curr_softbit_counter_state);

            when others =>          -- 64QAM
              read_carr_x_o <= TABLE_CARR_X_QAM64_3_4_CT(
                                                    curr_softbit_counter_state);
              read_carr_y_o <= TABLE_CARR_Y_QAM64_3_4_CT(
                                                    curr_softbit_counter_state);
              read_soft_x_o <= TABLE_SOFT_X_QAM64_3_4_CT(
                                                    curr_softbit_counter_state);
              read_soft_y_o <= TABLE_SOFT_Y_QAM64_3_4_CT(
                                                    curr_softbit_counter_state);

          end case;
        
      end case;

    else
      read_punc_x_o <= 0;
      read_punc_y_o <= 0;
      read_carr_x_o <= 0;
      read_carr_y_o <= 0;
      read_soft_x_o <= 0;
      read_soft_y_o <= 0;
    end if;
  end process read_address_mapping_p;


  --------------------------------------
  -- Read parameter process
  --------------------------------------
  read_parameter_p : process (clk, reset_n)
  begin
    if reset_n = '0' then                 -- asynchronous reset (active low)
      field_length <= SIGNAL_FIELD_LENGTH_CT;
      qam_mode     <= (others => '0');
      pun_mode     <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        field_length <= SIGNAL_FIELD_LENGTH_CT;
        qam_mode     <= (others => '0');
        pun_mode     <= (others => '0');
      elsif enable_i = '1' and start_field_i = '1'  then
        field_length <= conv_integer(field_length_i);
        qam_mode     <= qam_mode_i;
        pun_mode     <= pun_mode_i;
      end if;
    end if;
  end process read_parameter_p;


end RTL;
