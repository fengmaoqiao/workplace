
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: fft_serial.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Serializer for the FFT parallel outputs.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/fft_serial/vhdl/rtl/fft_serial.vhd,v  
--  Log: fft_serial.vhd,v  
-- Revision 1.2  2004/12/14 10:46:01  Dr.C
-- #BugId:595#
-- Added a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.1  2003/03/28 13:27:16  Dr.A
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

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity fft_serial is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic;
    reset_n              : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------  
    sync_reset_n         : in  std_logic; -- Synchronous reset
    start_serial_i       : in  std_logic; -- 'start of signal' marker.
    last_serial_i        : in  std_logic; -- Indicates the last symbol.
    data_ready_i         : in  std_logic; -- Next block is ready to accept data.
    --
    data_ready_o         : out std_logic; -- High when waiting for new data.
    marker_o             : out std_logic; -- 'end of burst' marker.
    --------------------------------------
    -- Data
    --------------------------------------  
    x_fft_data_i         : in  FFT_ARRAY_T; -- Parallel I data from FFT.
    y_fft_data_i         : in  FFT_ARRAY_T; -- Parallel Q data from FFT.
    -- Serialized I and Q data.
    x_fft_data_o         : out std_logic_vector(9 downto 0);
    y_fft_data_o         : out std_logic_vector(9 downto 0)
  );

end fft_serial;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of fft_serial is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- For cyclic prefix insertion, read first data 48 to 63, then 0 to 63.
  constant CNT_START_CT : std_logic_vector(5 downto 0) := "110000"; -- 48
  constant CNT_MAX_CT   : std_logic_vector(5 downto 0) := "111111"; -- 63
  -- Constants to saturate outputs.
  constant OUT_MAX_CT   : std_logic_vector(9 downto 0) := "0111111111";
  constant OUT_MIN_CT   : std_logic_vector(9 downto 0) := "1000000000";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal serial_on_going     : std_logic; -- High during serializer processing.
  signal guard_done          : std_logic; -- High when guard interval sent.
  -- Store last_serial_i till end of current symbol processing.
  signal last_serial_sav     : std_logic;
  -- Counter for the FFT output data.
  signal data_cnt            : std_logic_vector(5 downto 0);
  -- Marker set at the end of the serializer processing.
  signal marker_int          : std_logic;
  -- Marker sent to the tx_mux (marker_o) when the last data has been sent.
  signal mux_marker          : std_logic;
  -- This counter counts a 20 MHz period between marker_int and mux_marker.
  signal marker_cnt          : std_logic_vector(1 downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- This process generates the counter used to serialize the data. It counts
  -- from 48 to 63 for the guard interval, and then from 0 to 63 for the data
  -- symbol. The counter is first updated on start_serial_i, and then when a 
  -- new data is requested (data_ready_i).
  data_cnt_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      data_cnt <= CNT_START_CT;
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        data_cnt <= CNT_START_CT;
      else
        if data_ready_i = '1' or start_serial_i = '1' then
          -- End of FFT data, prepare for next symbol.
          if data_cnt = CNT_MAX_CT and guard_done = '1' then
            data_cnt <= CNT_START_CT;
          -- Count up. Allow one wrap around for the guard interval.
          -- Freeze counter when marker_o is sent.
          elsif mux_marker = '0' then
            data_cnt <= data_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process data_cnt_p;

  -- The guard interval is done when data 48 to 63 have been sent.
  guard_done_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      guard_done  <= '0';
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        guard_done  <= '0';
      else
        -- Reset guard_done at the symbol beginning. This can be useful in case
        -- the former transmission was interrupted.
        if start_serial_i = '1' then
          guard_done  <= '0';
        -- Invert guard_done each time data 63 is sent.
        elsif data_ready_i = '1' and data_cnt = CNT_MAX_CT then
          guard_done <= not(guard_done);
        end if;
      end if;
    end if;
  end process guard_done_p;

  -- This process generates the data_ready_o signal. Data ready_o is asserted 
  -- low from start_serial_i to the end of the data serialization, except for
  -- one pulse every symbol to request new data. The serial_on_going signal
  -- indicates that a burst is processed. It is high from start_serial_i high
  -- to marker_o high.
  data_ready_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      serial_on_going  <= '0';
      data_ready_o     <= '1';
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        serial_on_going  <= '0';
        data_ready_o     <= '1';
      else
        if start_serial_i = '1' then
          serial_on_going <= '1'; -- Store start_serial_i.
        elsif mux_marker = '1' then 
          serial_on_going <= '0'; -- Reset serial_on_going at the end.
        end if;      

        -- Send a pulse on data_ready_o to request new data just before sending
        -- data 63. 
        if data_cnt = CNT_MAX_CT and guard_done = '1' then
          data_ready_o <= data_ready_i;
        else -- During symbol processing, data_ready_o is low.
          data_ready_o <= not(serial_on_going);
        end if;
      end if;
    end if;
  end process data_ready_p;

  -- This process stores the last_serial_i signal till the end of the internal
  -- data processing.
  last_serial_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      last_serial_sav <= '0';
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        last_serial_sav <= '0';
      else
        if start_serial_i = '1' then -- Reset last_serial_sav for the next symbol.
          last_serial_sav <= '0';
        elsif last_serial_i = '1' then
          last_serial_sav <= '1';
        end if;
      end if;
    end if;
  end process last_serial_p;

  -- The 'end of burst' marker is generated at the end of the serialization
  -- after last_serial_i has been received, when data_ready_i is high.
  marker_int <= '1' when (guard_done = '1') and (data_cnt = CNT_MAX_CT)
                   and (last_serial_sav = '1')
                   and (data_ready_i = '1') else '0';

  -- The marker sent to the tx_mux must arrive after the last data has been
  -- processed. marker_int is delayed by four clock-cycles.
  marker_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      mux_marker <= '0';
      marker_cnt <= (others => '0');
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        mux_marker <= '0';
        marker_cnt <= (others => '0');
      else
        if marker_int = '1' or marker_cnt /= 0 then
          marker_cnt <= marker_cnt + 1;
        end if;
        if marker_cnt = "11" then 
          mux_marker <= '1';
        else
          mux_marker <= '0';
        end if;
      end if;
    end if;
  end process marker_p;

  -- Assign output port.
  marker_o <= mux_marker;
    
  -- This process generates output data.
  output_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      x_fft_data_o <= (others => '0');     
      y_fft_data_o <= (others => '0');     
    elsif clk'event and clk = '1' then
      if start_serial_i = '1' or data_ready_i = '1' then 

        -- Saturate X output data on 10 bits.
        if x_fft_data_i(conv_integer(data_cnt))(11 downto 9) = "000" or
           x_fft_data_i(conv_integer(data_cnt))(11 downto 9) = "111" then
          x_fft_data_o <= x_fft_data_i(conv_integer(data_cnt))(9 downto 0);
        else -- Overflow detected.
          case x_fft_data_i(conv_integer(data_cnt))(11) is
            when '0' =>    -- Positive data.
              x_fft_data_o <= OUT_MAX_CT;
            when others => -- Negative data.
              x_fft_data_o <= OUT_MIN_CT;
          end case;
        end if;
        
        -- Saturate Y output data on 10 bits.
        if y_fft_data_i(conv_integer(data_cnt))(11 downto 9) = "000" or
           y_fft_data_i(conv_integer(data_cnt))(11 downto 9) = "111" then
          y_fft_data_o <= y_fft_data_i(conv_integer(data_cnt))(9 downto 0);
        else -- Overflow detected.
          case y_fft_data_i(conv_integer(data_cnt))(11) is
            when '0' =>    -- Positive data.
              y_fft_data_o <= OUT_MAX_CT;
            when others => -- Negative data.
              y_fft_data_o <= OUT_MIN_CT;
          end case;
        end if;
        
      end if;
    end if;
  end process output_p;

end RTL;
