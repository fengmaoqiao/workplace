
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: fft_shell.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Shell to adapt the fft_2cordic to the Modem A2 data flow.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/fft_shell/vhdl/rtl/fft_shell.vhd,v  
--  Log: fft_shell.vhd,v  
-- Revision 1.6  2003/05/23 15:02:55  Dr.J
-- CHnaged the datat size of the fft
--
-- Revision 1.5  2003/04/02 08:05:29  Dr.A
-- Added sync reset. Removed 'else' on test on start_of_symbol.
--
-- Revision 1.4  2003/03/29 07:59:58  Dr.F
-- changed include lib.
--
-- Revision 1.3  2003/03/28 17:45:30  Dr.A
-- Completed sensitivity list.
--
-- Revision 1.2  2003/03/27 17:28:36  Dr.A
-- Simplified end_of_burst and made changes for use in rx.
--
-- Revision 1.1  2003/03/26 14:46:38  Dr.A
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

--library fft_shell_rtl;
library work;
--use fft_shell_rtl.fft_shell_pkg.all;
use work.fft_shell_pkg.all;

--library fft_2cordic_rtl;
library work;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity fft_shell is
  generic(
    data_size_g   : integer := 11;
    cordic_bits_g : integer := 10;
    ifft_norm_g   : integer := 0
    );
  port(
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    masterclk            : in  std_logic;
    reset_n              : in  std_logic;
    sync_reset_n         : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    -- signal to control the fft_mode
    tx_rxn_i             : in  std_logic; -- High for TX mode.
    --------------------------------------
    -- Controls for TX mode
    --------------------------------------
    -- signals from/to mapper.
    tx_start_of_signal_i : in  std_logic; -- 'start of signal' marker.
    tx_end_of_burst_i    : in  std_logic; -- 'end of burst' marker.
    tx_data_valid_i      : in  std_logic; -- High when input data is valid.
    tx_data_ready_i      : in  std_logic; -- Next block ready for data.
    --
    tx_data_ready_o      : out std_logic; -- FFT ready for data.
    tx_start_of_signal_o : out std_logic; -- 'start of signal' marker.
    tx_end_of_burst_o    : out std_logic; -- 'end of burst' marker.
    --------------------------------------
    -- Controls for RX mode
    --------------------------------------
    -- signals from/to preceeding module
    rx_start_of_burst_i  : in  std_logic;
    rx_start_of_symbol_i : in  std_logic;
    rx_data_valid_i      : in  std_logic;
    rx_data_ready_o      : out std_logic;
    -- signals from/to subsequent module
    rx_data_ready_i      : in  std_logic;
    rx_data_valid_o      : out std_logic;
    rx_start_of_burst_o  : out std_logic;
    rx_start_of_symbol_o : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    -- TX data in.
    tx_x_i               : in  std_logic_vector(data_size_g-1 downto 0);
    tx_y_i               : in  std_logic_vector(data_size_g-1 downto 0);
    -- RX data in.
    rx_x_i               : in  std_logic_vector(data_size_g-1 downto 0);
    rx_y_i               : in  std_logic_vector(data_size_g-1 downto 0);
    -- Data out.
    x_0_o                : out std_logic_vector(data_size_g downto 0);
    y_0_o                : out std_logic_vector(data_size_g downto 0);
    x_1_o                : out std_logic_vector(data_size_g downto 0);
    y_1_o                : out std_logic_vector(data_size_g downto 0);
    x_2_o                : out std_logic_vector(data_size_g downto 0);
    y_2_o                : out std_logic_vector(data_size_g downto 0);
    x_3_o                : out std_logic_vector(data_size_g downto 0);
    y_3_o                : out std_logic_vector(data_size_g downto 0);
    x_4_o                : out std_logic_vector(data_size_g downto 0);
    y_4_o                : out std_logic_vector(data_size_g downto 0);
    x_5_o                : out std_logic_vector(data_size_g downto 0);
    y_5_o                : out std_logic_vector(data_size_g downto 0);
    x_6_o                : out std_logic_vector(data_size_g downto 0);
    y_6_o                : out std_logic_vector(data_size_g downto 0);
    x_7_o                : out std_logic_vector(data_size_g downto 0);
    y_7_o                : out std_logic_vector(data_size_g downto 0);
    x_8_o                : out std_logic_vector(data_size_g downto 0);
    y_8_o                : out std_logic_vector(data_size_g downto 0);
    x_9_o                : out std_logic_vector(data_size_g downto 0);
    y_9_o                : out std_logic_vector(data_size_g downto 0);
    x_10_o               : out std_logic_vector(data_size_g downto 0);
    y_10_o               : out std_logic_vector(data_size_g downto 0);
    x_11_o               : out std_logic_vector(data_size_g downto 0);
    y_11_o               : out std_logic_vector(data_size_g downto 0);
    x_12_o               : out std_logic_vector(data_size_g downto 0);
    y_12_o               : out std_logic_vector(data_size_g downto 0);
    x_13_o               : out std_logic_vector(data_size_g downto 0);
    y_13_o               : out std_logic_vector(data_size_g downto 0);
    x_14_o               : out std_logic_vector(data_size_g downto 0);
    y_14_o               : out std_logic_vector(data_size_g downto 0);
    x_15_o               : out std_logic_vector(data_size_g downto 0);
    y_15_o               : out std_logic_vector(data_size_g downto 0);
    x_16_o               : out std_logic_vector(data_size_g downto 0);
    y_16_o               : out std_logic_vector(data_size_g downto 0);
    x_17_o               : out std_logic_vector(data_size_g downto 0);
    y_17_o               : out std_logic_vector(data_size_g downto 0);
    x_18_o               : out std_logic_vector(data_size_g downto 0);
    y_18_o               : out std_logic_vector(data_size_g downto 0);
    x_19_o               : out std_logic_vector(data_size_g downto 0);
    y_19_o               : out std_logic_vector(data_size_g downto 0);
    x_20_o               : out std_logic_vector(data_size_g downto 0);
    y_20_o               : out std_logic_vector(data_size_g downto 0);
    x_21_o               : out std_logic_vector(data_size_g downto 0);
    y_21_o               : out std_logic_vector(data_size_g downto 0);
    x_22_o               : out std_logic_vector(data_size_g downto 0);
    y_22_o               : out std_logic_vector(data_size_g downto 0);
    x_23_o               : out std_logic_vector(data_size_g downto 0);
    y_23_o               : out std_logic_vector(data_size_g downto 0);
    x_24_o               : out std_logic_vector(data_size_g downto 0);
    y_24_o               : out std_logic_vector(data_size_g downto 0);
    x_25_o               : out std_logic_vector(data_size_g downto 0);
    y_25_o               : out std_logic_vector(data_size_g downto 0);
    x_26_o               : out std_logic_vector(data_size_g downto 0);
    y_26_o               : out std_logic_vector(data_size_g downto 0);
    x_27_o               : out std_logic_vector(data_size_g downto 0);
    y_27_o               : out std_logic_vector(data_size_g downto 0);
    x_28_o               : out std_logic_vector(data_size_g downto 0);
    y_28_o               : out std_logic_vector(data_size_g downto 0);
    x_29_o               : out std_logic_vector(data_size_g downto 0);
    y_29_o               : out std_logic_vector(data_size_g downto 0);
    x_30_o               : out std_logic_vector(data_size_g downto 0);
    y_30_o               : out std_logic_vector(data_size_g downto 0);
    x_31_o               : out std_logic_vector(data_size_g downto 0);
    y_31_o               : out std_logic_vector(data_size_g downto 0);
    x_32_o               : out std_logic_vector(data_size_g downto 0);
    y_32_o               : out std_logic_vector(data_size_g downto 0);
    x_33_o               : out std_logic_vector(data_size_g downto 0);
    y_33_o               : out std_logic_vector(data_size_g downto 0);
    x_34_o               : out std_logic_vector(data_size_g downto 0);
    y_34_o               : out std_logic_vector(data_size_g downto 0);
    x_35_o               : out std_logic_vector(data_size_g downto 0);
    y_35_o               : out std_logic_vector(data_size_g downto 0);
    x_36_o               : out std_logic_vector(data_size_g downto 0);
    y_36_o               : out std_logic_vector(data_size_g downto 0);
    x_37_o               : out std_logic_vector(data_size_g downto 0);
    y_37_o               : out std_logic_vector(data_size_g downto 0);
    x_38_o               : out std_logic_vector(data_size_g downto 0);
    y_38_o               : out std_logic_vector(data_size_g downto 0);
    x_39_o               : out std_logic_vector(data_size_g downto 0);
    y_39_o               : out std_logic_vector(data_size_g downto 0);
    x_40_o               : out std_logic_vector(data_size_g downto 0);
    y_40_o               : out std_logic_vector(data_size_g downto 0);
    x_41_o               : out std_logic_vector(data_size_g downto 0);
    y_41_o               : out std_logic_vector(data_size_g downto 0);
    x_42_o               : out std_logic_vector(data_size_g downto 0);
    y_42_o               : out std_logic_vector(data_size_g downto 0);
    x_43_o               : out std_logic_vector(data_size_g downto 0);
    y_43_o               : out std_logic_vector(data_size_g downto 0);
    x_44_o               : out std_logic_vector(data_size_g downto 0);
    y_44_o               : out std_logic_vector(data_size_g downto 0);
    x_45_o               : out std_logic_vector(data_size_g downto 0);
    y_45_o               : out std_logic_vector(data_size_g downto 0);
    x_46_o               : out std_logic_vector(data_size_g downto 0);
    y_46_o               : out std_logic_vector(data_size_g downto 0);
    x_47_o               : out std_logic_vector(data_size_g downto 0);
    y_47_o               : out std_logic_vector(data_size_g downto 0);
    x_48_o               : out std_logic_vector(data_size_g downto 0);
    y_48_o               : out std_logic_vector(data_size_g downto 0);
    x_49_o               : out std_logic_vector(data_size_g downto 0);
    y_49_o               : out std_logic_vector(data_size_g downto 0);
    x_50_o               : out std_logic_vector(data_size_g downto 0);
    y_50_o               : out std_logic_vector(data_size_g downto 0);
    x_51_o               : out std_logic_vector(data_size_g downto 0);
    y_51_o               : out std_logic_vector(data_size_g downto 0);
    x_52_o               : out std_logic_vector(data_size_g downto 0);
    y_52_o               : out std_logic_vector(data_size_g downto 0);
    x_53_o               : out std_logic_vector(data_size_g downto 0);
    y_53_o               : out std_logic_vector(data_size_g downto 0);
    x_54_o               : out std_logic_vector(data_size_g downto 0);
    y_54_o               : out std_logic_vector(data_size_g downto 0);
    x_55_o               : out std_logic_vector(data_size_g downto 0);
    y_55_o               : out std_logic_vector(data_size_g downto 0);
    x_56_o               : out std_logic_vector(data_size_g downto 0);
    y_56_o               : out std_logic_vector(data_size_g downto 0);
    x_57_o               : out std_logic_vector(data_size_g downto 0);
    y_57_o               : out std_logic_vector(data_size_g downto 0);
    x_58_o               : out std_logic_vector(data_size_g downto 0);
    y_58_o               : out std_logic_vector(data_size_g downto 0);
    x_59_o               : out std_logic_vector(data_size_g downto 0);
    y_59_o               : out std_logic_vector(data_size_g downto 0);
    x_60_o               : out std_logic_vector(data_size_g downto 0);
    y_60_o               : out std_logic_vector(data_size_g downto 0);
    x_61_o               : out std_logic_vector(data_size_g downto 0);
    y_61_o               : out std_logic_vector(data_size_g downto 0);
    x_62_o               : out std_logic_vector(data_size_g downto 0);
    y_62_o               : out std_logic_vector(data_size_g downto 0);
    x_63_o               : out std_logic_vector(data_size_g downto 0);
    y_63_o               : out std_logic_vector(data_size_g downto 0)
    
  );

end fft_shell;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of fft_shell is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- constants used to re-order FFT inputs.
  constant TX_MAX_INDEX_CT   : std_logic_vector(5 downto 0) := "111111"; -- 63
  constant RX_MAX_INDEX_CT   : std_logic_vector(5 downto 0) := "110111"; -- 55
  constant RX_START_INDEX_CT : std_logic_vector(5 downto 0) := "111000"; -- 56
  
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  -- Type definitions, used to build the buffers and the FSMs
  type BUF_ELEMENT_T is array (0 to 63)
       of std_logic_vector(data_size_g - 1 downto 0);
  type BUF_ELEMENT_P1_T is array (0 to 63)
       of std_logic_vector(data_size_g downto 0);
  type BUF1_STATE_T is (idle_e, read_input_e, store_e);
  type FFT_STATE_T  is (idle_e, read_input_e, processing_e, done_e);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals which build the two buffers
  signal x_buf1             : BUF_ELEMENT_T;
  signal y_buf1             : BUF_ELEMENT_T;
  signal x_buf3             : BUF_ELEMENT_P1_T;
  signal y_buf3             : BUF_ELEMENT_P1_T;
  signal x_fft_out          : BUF_ELEMENT_P1_T;
  signal y_fft_out          : BUF_ELEMENT_P1_T;
  -- States of FSMs
  signal buf1_state         : BUF1_STATE_T;
  signal fft_state          : FFT_STATE_T;
  -- Control signals for the buffers
  signal buf1_full          : std_logic; -- High when buffer 1 is full.
  -- Control signals for the FFT
  signal start_fft          : std_logic; -- Pulse to start the FFT.
  signal read_done          : std_logic; -- Pulse when the FFT has read buffer1.
  signal fft_done           : std_logic; -- High when FFT processing is over.
  -- Internal control signals, result of the multiplexer controled by tx_rxn_i
  signal burst_in           : std_logic;
  signal start_of_symbol_in : std_logic;
  signal data_valid_in      : std_logic;
  signal data_ready_in      : std_logic;
  signal x_in               : std_logic_vector(data_size_g-1 downto 0);
  signal y_in               : std_logic_vector(data_size_g-1 downto 0);
  signal data_ready_out     : std_logic;
  -- Signals which delay the "start/end_of_burst" and "start_of_symbol" signals
  signal burst1             : std_logic;
  signal symbol1            : std_logic;
  signal burst_fft          : std_logic;
  signal symbol_fft         : std_logic;
  signal burst3             : std_logic;
  signal symbol3            : std_logic;
  -- others
  signal data_valid_out     : std_logic;
  signal ifft_norm          : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin


  -- Multiplex the control signals
  tx_rxn_mux_p : process(burst3, data_ready_out, data_valid_out,
                         rx_data_ready_i, rx_data_valid_i, rx_start_of_burst_i,
                         rx_start_of_symbol_i, rx_x_i, rx_y_i, symbol3,
                         tx_data_ready_i, tx_data_valid_i, tx_end_of_burst_i,
                         tx_rxn_i, tx_start_of_signal_i, tx_x_i, tx_y_i)
  begin
    if tx_rxn_i = '1' then  -- transmit mode
      -- inputs
      burst_in             <= tx_end_of_burst_i;
      start_of_symbol_in   <= tx_start_of_signal_i;
      data_valid_in        <= tx_data_valid_i;
      data_ready_in        <= tx_data_ready_i;
      x_in                 <= tx_x_i;
      y_in                 <= tx_y_i;
      -- outputs
      tx_start_of_signal_o <= symbol3;
      tx_end_of_burst_o    <= burst3;
      tx_data_ready_o      <= data_ready_out;
      rx_start_of_burst_o  <= '0';
      rx_start_of_symbol_o <= '0';
      rx_data_valid_o      <= '0';
      rx_data_ready_o      <= '0';
    else                    -- receive mode
      -- inputs
      burst_in             <= rx_start_of_burst_i;
      start_of_symbol_in   <= rx_start_of_symbol_i;
      data_valid_in        <= rx_data_valid_i;
      data_ready_in        <= rx_data_ready_i;
      x_in                 <= rx_x_i;
      y_in                 <= rx_y_i;
      -- outputs
      rx_start_of_burst_o  <= burst3;
      rx_start_of_symbol_o <= symbol3;
      rx_data_valid_o      <= data_valid_out;
      rx_data_ready_o      <= data_ready_out;
      tx_start_of_signal_o <= '0';
      tx_end_of_burst_o    <= '0';
      tx_data_ready_o      <= '0';
    end if;
  end process tx_rxn_mux_p;

  -- This process controls buffer1
  fsm_buf1_p : process (masterclk, reset_n)
  begin
    if reset_n = '0' then
      buf1_state  <= idle_e;
      burst1      <= '0';
      symbol1     <= '0';
    elsif masterclk'event and masterclk = '1' then
        
      if sync_reset_n = '0' then
        buf1_state  <= idle_e;
        burst1      <= '0';
        symbol1     <= '0';
      else
        -- Save incoming markers.
        if burst_in = '1' then
          burst1  <= '1';
        end if;
        if start_of_symbol_in = '1' then
          symbol1 <= '1';
        end if;
        -- Definition of the State Machine
        case buf1_state is

          when idle_e =>
            -- Wait for first data valid.
            if data_valid_in = '1' then
              buf1_state   <= read_input_e;
            end if;

          when read_input_e =>
            -- Store 64 incoming data.
            if buf1_full = '1' then
              buf1_state <= store_e;
            end if;

          when store_e =>
            -- Go back to idle state when FFT has read the buffer contents.
            if read_done = '1' then
              buf1_state  <= idle_e;
              burst1      <= '0';
              symbol1     <= '0';
            end if;
            
          when others => null;

        end case;
      end if;
    end if;
  end process fsm_buf1_p;
  
  -- Mealy signals for buffer1
  data_ready_out <= '1' when buf1_state = idle_e or
                    (buf1_state = read_input_e and buf1_full = '0') else '0';

  start_fft <= '1' when fft_state = idle_e and
                  (buf1_full = '1' or buf1_state = store_e) else '0';

  -- This process keeps track of the state the FFT is in.
  fsm_fft_p : process (masterclk, reset_n)
  begin  -- process fsm_fft
    if reset_n = '0' then  -- asynchronous reset (active low)
      fft_state  <= idle_e;
      burst_fft  <= '0';
      symbol_fft <= '0';
    elsif masterclk'event and masterclk = '1' then  -- rising clock edge

      if sync_reset_n = '0' then  -- asynchronous reset (active low)
        fft_state  <= idle_e;
        burst_fft  <= '0';
        symbol_fft <= '0';
      else
        -- Definition of the State Machine
        case fft_state is

          when idle_e =>

            if start_fft = '1' then
              fft_state  <= read_input_e;
              burst_fft  <= burst1;
              symbol_fft <= symbol1;
            end if;

          -- Read buffer 1.
          when read_input_e =>
            if read_done = '1' then
              fft_state  <= processing_e;
            end if;

          when processing_e =>
            -- When processing done, go directly in idle state if next block
            -- ready for data. Else wait in done state.
            if fft_done = '1' then
              if data_ready_in='1' then
                fft_state  <= idle_e;
              else
                fft_state  <= done_e;
              end if;
            end if;

          -- Go to idle state when next block is ready for data.
          when done_e =>
            if data_ready_in = '1' then
              fft_state  <= idle_e;
              burst_fft  <= '0';
              symbol_fft <= '0';
            end if;

          when others => null;

        end case;
      end if;
    end if;
  end process fsm_fft_p;
  
  -- This is the first buffer, which takes the serial data and puts them into a
  -- 64 word wide buffer.
  buf1_p : process (masterclk, reset_n)
    variable index_v : std_logic_vector(5 downto 0);
  begin
    if reset_n = '0' then
      x_buf1    <= (others => (others => '0'));
      y_buf1    <= (others => (others => '0'));
      index_v   := (others => '0');
      buf1_full <= '0';
    elsif masterclk'event and masterclk = '1' then
      if sync_reset_n = '0' then
        x_buf1    <= (others => (others => '0'));
        y_buf1    <= (others => (others => '0'));
        index_v   := (others => '0');
        buf1_full <= '0';
      else
        -- Reset buf1_full when buffer emptied by FFT.
        if read_done = '1' then
          buf1_full <= '0';
        end if;
        -- Store 8 first RX data at the end of the buffer.
        if rx_start_of_symbol_i = '1' then
          index_v := RX_START_INDEX_CT; --56
        end if;

        -- Store incoming data when valid.
        if data_valid_in = '1' then
          x_buf1(conv_integer(index_v)) <= x_in;
          y_buf1(conv_integer(index_v)) <= y_in;

          -- Set buf1_full flag when storing last data.
          if (index_v = TX_MAX_INDEX_CT and tx_rxn_i = '1') or
             (index_v = RX_MAX_INDEX_CT and tx_rxn_i = '0') then
            buf1_full <= '1';
          end if;
          -- Keep index value when buffer in read mode.
          if buf1_state /= store_e then
            index_v := index_v + 1;
          end if;
        end if;

      end if;
    end if;
  end process buf1_p;

  -- Implements the second buffer. It's called buffer3 for historical reasons.
  -- The name was taken from the 3 buffer design, from which buffer2 was removed
  buf3_p: process (masterclk, reset_n)
  begin
    if reset_n = '0' then
      x_buf3         <= (others => (others => '0'));
      y_buf3         <= (others => (others => '0'));
      burst3         <= '0';
      symbol3        <= '0';
      data_valid_out <= '0';
    elsif masterclk'event and masterclk = '1' then
      if sync_reset_n = '0' then
        x_buf3         <= (others => (others => '0'));
        y_buf3         <= (others => (others => '0'));
        burst3         <= '0';
        symbol3        <= '0';
        data_valid_out <= '0';
      else
        -- Fill buffer after FFT processing.
        if (fft_done = '1' or fft_state = done_e) and data_ready_in = '1' then
          x_buf3         <= x_fft_out;
          y_buf3         <= y_fft_out;
          burst3         <= burst_fft;
          symbol3        <= symbol_fft;
          data_valid_out <= '1';               
        else
          burst3         <= '0';
          symbol3        <= '0';
          data_valid_out <= '0';
        end if;
      end if;
    end if;
  end process buf3_p;

  -- Signals, which set up the FFT block
  ifft_norm  <= '1' when ifft_norm_g = 1 else '0';

  -- Instantiation of the FFT block
  fft_block_1 : fft_2cordic
    generic map (
      data_size_g   => data_size_g,
      cordic_bits_g => cordic_bits_g)
    port map (
      masterclk     => masterclk,
      reset_n       => reset_n,
      sync_rst_ni   => sync_reset_n,
      start_fft_i   => start_fft,
      ifft_mode_i   => tx_rxn_i,
      ifft_norm_i   => ifft_norm,
      read_done_o   => read_done,
      fft_done_o    => fft_done,
      x_0_i         => x_buf1(0),
      y_0_i         => y_buf1(0),
      x_1_i         => x_buf1(1),
      y_1_i         => y_buf1(1),
      x_2_i         => x_buf1(2),
      y_2_i         => y_buf1(2),
      x_3_i         => x_buf1(3),
      y_3_i         => y_buf1(3),
      x_4_i         => x_buf1(4),
      y_4_i         => y_buf1(4),
      x_5_i         => x_buf1(5),
      y_5_i         => y_buf1(5),
      x_6_i         => x_buf1(6),
      y_6_i         => y_buf1(6),
      x_7_i         => x_buf1(7),
      y_7_i         => y_buf1(7),
      x_8_i         => x_buf1(8),
      y_8_i         => y_buf1(8),
      x_9_i         => x_buf1(9),
      y_9_i         => y_buf1(9),
      x_10_i        => x_buf1(10),
      y_10_i        => y_buf1(10),
      x_11_i        => x_buf1(11),
      y_11_i        => y_buf1(11),
      x_12_i        => x_buf1(12),
      y_12_i        => y_buf1(12),
      x_13_i        => x_buf1(13),
      y_13_i        => y_buf1(13),
      x_14_i        => x_buf1(14),
      y_14_i        => y_buf1(14),
      x_15_i        => x_buf1(15),
      y_15_i        => y_buf1(15),
      x_16_i        => x_buf1(16),
      y_16_i        => y_buf1(16),
      x_17_i        => x_buf1(17),
      y_17_i        => y_buf1(17),
      x_18_i        => x_buf1(18),
      y_18_i        => y_buf1(18),
      x_19_i        => x_buf1(19),
      y_19_i        => y_buf1(19),
      x_20_i        => x_buf1(20),
      y_20_i        => y_buf1(20),
      x_21_i        => x_buf1(21),
      y_21_i        => y_buf1(21),
      x_22_i        => x_buf1(22),
      y_22_i        => y_buf1(22),
      x_23_i        => x_buf1(23),
      y_23_i        => y_buf1(23),
      x_24_i        => x_buf1(24),
      y_24_i        => y_buf1(24),
      x_25_i        => x_buf1(25),
      y_25_i        => y_buf1(25),
      x_26_i        => x_buf1(26),
      y_26_i        => y_buf1(26),
      x_27_i        => x_buf1(27),
      y_27_i        => y_buf1(27),
      x_28_i        => x_buf1(28),
      y_28_i        => y_buf1(28),
      x_29_i        => x_buf1(29),
      y_29_i        => y_buf1(29),
      x_30_i        => x_buf1(30),
      y_30_i        => y_buf1(30),
      x_31_i        => x_buf1(31),
      y_31_i        => y_buf1(31),
      x_32_i        => x_buf1(32),
      y_32_i        => y_buf1(32),
      x_33_i        => x_buf1(33),
      y_33_i        => y_buf1(33),
      x_34_i        => x_buf1(34),
      y_34_i        => y_buf1(34),
      x_35_i        => x_buf1(35),
      y_35_i        => y_buf1(35),
      x_36_i        => x_buf1(36),
      y_36_i        => y_buf1(36),
      x_37_i        => x_buf1(37),
      y_37_i        => y_buf1(37),
      x_38_i        => x_buf1(38),
      y_38_i        => y_buf1(38),
      x_39_i        => x_buf1(39),
      y_39_i        => y_buf1(39),
      x_40_i        => x_buf1(40),
      y_40_i        => y_buf1(40),
      x_41_i        => x_buf1(41),
      y_41_i        => y_buf1(41),
      x_42_i        => x_buf1(42),
      y_42_i        => y_buf1(42),
      x_43_i        => x_buf1(43),
      y_43_i        => y_buf1(43),
      x_44_i        => x_buf1(44),
      y_44_i        => y_buf1(44),
      x_45_i        => x_buf1(45),
      y_45_i        => y_buf1(45),
      x_46_i        => x_buf1(46),
      y_46_i        => y_buf1(46),
      x_47_i        => x_buf1(47),
      y_47_i        => y_buf1(47),
      x_48_i        => x_buf1(48),
      y_48_i        => y_buf1(48),
      x_49_i        => x_buf1(49),
      y_49_i        => y_buf1(49),
      x_50_i        => x_buf1(50),
      y_50_i        => y_buf1(50),
      x_51_i        => x_buf1(51),
      y_51_i        => y_buf1(51),
      x_52_i        => x_buf1(52),
      y_52_i        => y_buf1(52),
      x_53_i        => x_buf1(53),
      y_53_i        => y_buf1(53),
      x_54_i        => x_buf1(54),
      y_54_i        => y_buf1(54),
      x_55_i        => x_buf1(55),
      y_55_i        => y_buf1(55),
      x_56_i        => x_buf1(56),
      y_56_i        => y_buf1(56),
      x_57_i        => x_buf1(57),
      y_57_i        => y_buf1(57),
      x_58_i        => x_buf1(58),
      y_58_i        => y_buf1(58),
      x_59_i        => x_buf1(59),
      y_59_i        => y_buf1(59),
      x_60_i        => x_buf1(60),
      y_60_i        => y_buf1(60),
      x_61_i        => x_buf1(61),
      y_61_i        => y_buf1(61),
      x_62_i        => x_buf1(62),
      y_62_i        => y_buf1(62),
      x_63_i        => x_buf1(63),
      y_63_i        => y_buf1(63),
      x_0_o         => x_fft_out(0),
      y_0_o         => y_fft_out(0),
      x_1_o         => x_fft_out(1),
      y_1_o         => y_fft_out(1),
      x_2_o         => x_fft_out(2),
      y_2_o         => y_fft_out(2),
      x_3_o         => x_fft_out(3),
      y_3_o         => y_fft_out(3),
      x_4_o         => x_fft_out(4),
      y_4_o         => y_fft_out(4),
      x_5_o         => x_fft_out(5),
      y_5_o         => y_fft_out(5),
      x_6_o         => x_fft_out(6),
      y_6_o         => y_fft_out(6),
      x_7_o         => x_fft_out(7),
      y_7_o         => y_fft_out(7),
      x_8_o         => x_fft_out(8),
      y_8_o         => y_fft_out(8),
      x_9_o         => x_fft_out(9),
      y_9_o         => y_fft_out(9),
      x_10_o        => x_fft_out(10),
      y_10_o        => y_fft_out(10),
      x_11_o        => x_fft_out(11),
      y_11_o        => y_fft_out(11),
      x_12_o        => x_fft_out(12),
      y_12_o        => y_fft_out(12),
      x_13_o        => x_fft_out(13),
      y_13_o        => y_fft_out(13),
      x_14_o        => x_fft_out(14),
      y_14_o        => y_fft_out(14),
      x_15_o        => x_fft_out(15),
      y_15_o        => y_fft_out(15),
      x_16_o        => x_fft_out(16),
      y_16_o        => y_fft_out(16),
      x_17_o        => x_fft_out(17),
      y_17_o        => y_fft_out(17),
      x_18_o        => x_fft_out(18),
      y_18_o        => y_fft_out(18),
      x_19_o        => x_fft_out(19),
      y_19_o        => y_fft_out(19),
      x_20_o        => x_fft_out(20),
      y_20_o        => y_fft_out(20),
      x_21_o        => x_fft_out(21),
      y_21_o        => y_fft_out(21),
      x_22_o        => x_fft_out(22),
      y_22_o        => y_fft_out(22),
      x_23_o        => x_fft_out(23),
      y_23_o        => y_fft_out(23),
      x_24_o        => x_fft_out(24),
      y_24_o        => y_fft_out(24),
      x_25_o        => x_fft_out(25),
      y_25_o        => y_fft_out(25),
      x_26_o        => x_fft_out(26),
      y_26_o        => y_fft_out(26),
      x_27_o        => x_fft_out(27),
      y_27_o        => y_fft_out(27),
      x_28_o        => x_fft_out(28),
      y_28_o        => y_fft_out(28),
      x_29_o        => x_fft_out(29),
      y_29_o        => y_fft_out(29),
      x_30_o        => x_fft_out(30),
      y_30_o        => y_fft_out(30),
      x_31_o        => x_fft_out(31),
      y_31_o        => y_fft_out(31),
      x_32_o        => x_fft_out(32),
      y_32_o        => y_fft_out(32),
      x_33_o        => x_fft_out(33),
      y_33_o        => y_fft_out(33),
      x_34_o        => x_fft_out(34),
      y_34_o        => y_fft_out(34),
      x_35_o        => x_fft_out(35),
      y_35_o        => y_fft_out(35),
      x_36_o        => x_fft_out(36),
      y_36_o        => y_fft_out(36),
      x_37_o        => x_fft_out(37),
      y_37_o        => y_fft_out(37),
      x_38_o        => x_fft_out(38),
      y_38_o        => y_fft_out(38),
      x_39_o        => x_fft_out(39),
      y_39_o        => y_fft_out(39),
      x_40_o        => x_fft_out(40),
      y_40_o        => y_fft_out(40),
      x_41_o        => x_fft_out(41),
      y_41_o        => y_fft_out(41),
      x_42_o        => x_fft_out(42),
      y_42_o        => y_fft_out(42),
      x_43_o        => x_fft_out(43),
      y_43_o        => y_fft_out(43),
      x_44_o        => x_fft_out(44),
      y_44_o        => y_fft_out(44),
      x_45_o        => x_fft_out(45),
      y_45_o        => y_fft_out(45),
      x_46_o        => x_fft_out(46),
      y_46_o        => y_fft_out(46),
      x_47_o        => x_fft_out(47),
      y_47_o        => y_fft_out(47),
      x_48_o        => x_fft_out(48),
      y_48_o        => y_fft_out(48),
      x_49_o        => x_fft_out(49),
      y_49_o        => y_fft_out(49),
      x_50_o        => x_fft_out(50),
      y_50_o        => y_fft_out(50),
      x_51_o        => x_fft_out(51),
      y_51_o        => y_fft_out(51),
      x_52_o        => x_fft_out(52),
      y_52_o        => y_fft_out(52),
      x_53_o        => x_fft_out(53),
      y_53_o        => y_fft_out(53),
      x_54_o        => x_fft_out(54),
      y_54_o        => y_fft_out(54),
      x_55_o        => x_fft_out(55),
      y_55_o        => y_fft_out(55),
      x_56_o        => x_fft_out(56),
      y_56_o        => y_fft_out(56),
      x_57_o        => x_fft_out(57),
      y_57_o        => y_fft_out(57),
      x_58_o        => x_fft_out(58),
      y_58_o        => y_fft_out(58),
      x_59_o        => x_fft_out(59),
      y_59_o        => y_fft_out(59),
      x_60_o        => x_fft_out(60),
      y_60_o        => y_fft_out(60),
      x_61_o        => x_fft_out(61),
      y_61_o        => y_fft_out(61),
      x_62_o        => x_fft_out(62),
      y_62_o        => y_fft_out(62),
      x_63_o        => x_fft_out(63),
      y_63_o        => y_fft_out(63));

  -- Assign output data signals
  x_0_o  <= x_buf3(0);
  y_0_o  <= y_buf3(0);
  x_1_o  <= x_buf3(1);
  y_1_o  <= y_buf3(1);
  x_2_o  <= x_buf3(2);
  y_2_o  <= y_buf3(2);
  x_3_o  <= x_buf3(3);
  y_3_o  <= y_buf3(3);
  x_4_o  <= x_buf3(4);
  y_4_o  <= y_buf3(4);
  x_5_o  <= x_buf3(5);
  y_5_o  <= y_buf3(5);
  x_6_o  <= x_buf3(6);
  y_6_o  <= y_buf3(6);
  x_7_o  <= x_buf3(7);
  y_7_o  <= y_buf3(7);
  x_8_o  <= x_buf3(8);
  y_8_o  <= y_buf3(8);
  x_9_o  <= x_buf3(9);
  y_9_o  <= y_buf3(9);
  x_10_o <= x_buf3(10);
  y_10_o <= y_buf3(10);
  x_11_o <= x_buf3(11);
  y_11_o <= y_buf3(11);
  x_12_o <= x_buf3(12);
  y_12_o <= y_buf3(12);
  x_13_o <= x_buf3(13);
  y_13_o <= y_buf3(13);
  x_14_o <= x_buf3(14);
  y_14_o <= y_buf3(14);
  x_15_o <= x_buf3(15);
  y_15_o <= y_buf3(15);
  x_16_o <= x_buf3(16);
  y_16_o <= y_buf3(16);
  x_17_o <= x_buf3(17);
  y_17_o <= y_buf3(17);
  x_18_o <= x_buf3(18);
  y_18_o <= y_buf3(18);
  x_19_o <= x_buf3(19);
  y_19_o <= y_buf3(19);
  x_20_o <= x_buf3(20);
  y_20_o <= y_buf3(20);
  x_21_o <= x_buf3(21);
  y_21_o <= y_buf3(21);
  x_22_o <= x_buf3(22);
  y_22_o <= y_buf3(22);
  x_23_o <= x_buf3(23);
  y_23_o <= y_buf3(23);
  x_24_o <= x_buf3(24);
  y_24_o <= y_buf3(24);
  x_25_o <= x_buf3(25);
  y_25_o <= y_buf3(25);
  x_26_o <= x_buf3(26);
  y_26_o <= y_buf3(26);
  x_27_o <= x_buf3(27);
  y_27_o <= y_buf3(27);
  x_28_o <= x_buf3(28);
  y_28_o <= y_buf3(28);
  x_29_o <= x_buf3(29);
  y_29_o <= y_buf3(29);
  x_30_o <= x_buf3(30);
  y_30_o <= y_buf3(30);
  x_31_o <= x_buf3(31);
  y_31_o <= y_buf3(31);
  x_32_o <= x_buf3(32);
  y_32_o <= y_buf3(32);
  x_33_o <= x_buf3(33);
  y_33_o <= y_buf3(33);
  x_34_o <= x_buf3(34);
  y_34_o <= y_buf3(34);
  x_35_o <= x_buf3(35);
  y_35_o <= y_buf3(35);
  x_36_o <= x_buf3(36);
  y_36_o <= y_buf3(36);
  x_37_o <= x_buf3(37);
  y_37_o <= y_buf3(37);
  x_38_o <= x_buf3(38);
  y_38_o <= y_buf3(38);
  x_39_o <= x_buf3(39);
  y_39_o <= y_buf3(39);
  x_40_o <= x_buf3(40);
  y_40_o <= y_buf3(40);
  x_41_o <= x_buf3(41);
  y_41_o <= y_buf3(41);
  x_42_o <= x_buf3(42);
  y_42_o <= y_buf3(42);
  x_43_o <= x_buf3(43);
  y_43_o <= y_buf3(43);
  x_44_o <= x_buf3(44);
  y_44_o <= y_buf3(44);
  x_45_o <= x_buf3(45);
  y_45_o <= y_buf3(45);
  x_46_o <= x_buf3(46);
  y_46_o <= y_buf3(46);
  x_47_o <= x_buf3(47);
  y_47_o <= y_buf3(47);
  x_48_o <= x_buf3(48);
  y_48_o <= y_buf3(48);
  x_49_o <= x_buf3(49);
  y_49_o <= y_buf3(49);
  x_50_o <= x_buf3(50);
  y_50_o <= y_buf3(50);
  x_51_o <= x_buf3(51);
  y_51_o <= y_buf3(51);
  x_52_o <= x_buf3(52);
  y_52_o <= y_buf3(52);
  x_53_o <= x_buf3(53);
  y_53_o <= y_buf3(53);
  x_54_o <= x_buf3(54);
  y_54_o <= y_buf3(54);
  x_55_o <= x_buf3(55);
  y_55_o <= y_buf3(55);
  x_56_o <= x_buf3(56);
  y_56_o <= y_buf3(56);
  x_57_o <= x_buf3(57);
  y_57_o <= y_buf3(57);
  x_58_o <= x_buf3(58);
  y_58_o <= y_buf3(58);
  x_59_o <= x_buf3(59);
  y_59_o <= y_buf3(59);
  x_60_o <= x_buf3(60);
  y_60_o <= y_buf3(60);
  x_61_o <= x_buf3(61);
  y_61_o <= y_buf3(61);
  x_62_o <= x_buf3(62);
  y_62_o <= y_buf3(62);
  x_63_o <= x_buf3(63);
  y_63_o <= y_buf3(63);

end RTL;
