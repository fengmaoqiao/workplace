
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: rx_mac_if.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : RX MAC interface. Provides the rx data and the data indication
--               signal to the MAC.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/rx_mac_if/vhdl/rtl/rx_mac_if.vhd,v  
--  Log: rx_mac_if.vhd,v  
-- Revision 1.5  2005/03/09 12:03:50  Dr.C
-- #BugId:1123#
-- Added packet_end_i input to avoid data taken into account 2 times by the bup at the end of the reception.
--
-- Revision 1.4  2003/11/18 18:00:47  Dr.F
-- resynchronized rx_data and rx_data_ind due to timing problems.
--
-- Revision 1.3  2003/06/27 15:54:35  Dr.F
-- fixed sensitivity list.
--
-- Revision 1.2  2003/06/27 15:49:23  Dr.F
-- rx_data_ind is now generated as a transitional signal instead of a pulse.
--
-- Revision 1.1  2003/03/14 14:17:16  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity rx_mac_if is
  port(
    -- asynchronous reset
    reset_n               : in  std_logic; 
    -- synchronous reset
    sync_reset_n          : in  std_logic; 
    -- clock
    clk                   : in  std_logic; 

    -- data coming from the rx path
    data_i                : in  std_logic;
    -- data valid indication. When 1, data_i is valid.
    data_valid_i          : in  std_logic;
    -- start of burst (packet) when 1.
    start_of_burst_i      : in  std_logic;
    
    data_ready_o          : out std_logic;
    -- end of packet
    packet_end_i          : in  std_logic;
    -- BuP interface
    rx_data_o             : out std_logic_vector(7 downto 0);
    rx_data_ind_o         : out std_logic
  );
end rx_mac_if;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_mac_if is

  -- bit counter
  signal counter        : std_logic_vector(2 downto 0);
  signal d_counter      : std_logic_vector(2 downto 0);

  -- shift register
  signal shift_data     : std_logic_vector(7 downto 0);

  -- data availability indication
  signal rx_data_ind      : std_logic;
  signal rx_data_ind_s_o  : std_logic;
  signal d_rx_data_ind    : std_logic;

begin

  -- register that stores the value of the output "byte-ready" (control path)
  -- reset_n resets asynchronously the register.
  -- packet_end_i resets synchronously the register after rx_start_end_ind low,
  -- to avoid data to be taken into account two times by the bup.
  byte_ctrl_reg_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then
      rx_data_ind     <= '0';
      rx_data_ind_s_o <= '0';
    elsif clk'event and clk = '1' then
      if packet_end_i = '1' then
        rx_data_ind     <= '0';
        rx_data_ind_s_o <= '0';
      else
        rx_data_ind     <= d_rx_data_ind;
        rx_data_ind_s_o <= rx_data_ind;
      end if;
    end if;
  end process byte_ctrl_reg_p;

  -- "byte-ready" combinational logic
  -- if the data-in is valid and counter reachs 000, 
  -- the indicator for "byte-ready" is set.
  -- Thus, a new byte is ready when 8 valid bits have been received.
  byte_ctrl_comb: process (counter, data_valid_i, rx_data_ind)
  begin
    -- default values
    d_rx_data_ind <= rx_data_ind;
    if counter = "000" and data_valid_i = '1' then
      d_rx_data_ind <= not(rx_data_ind);
    end if;
  end process byte_ctrl_comb;
 

  -- Shift-register (data path) : we shift-in the data-in 
  -- if this data-in is valid.
  -- reset_n resets asynchronously the register.
  shift_reg_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then
      shift_data <= (others => '0');
    elsif clk'event and clk = '1' then
      if data_valid_i = '1' then
        shift_data(6 downto 0) <= shift_data(7 downto 1); 
        shift_data(7)          <= data_i;
      end if;
    end if;
  end process shift_reg_p;
  
  
  -- Decounter combinational logic
  -- if the data-in is valid, the counter is decremented
  counter_ctrl_p: process (counter, data_valid_i)
  begin
    -- default values
    d_counter <= counter;
    if data_valid_i = '1' then
      d_counter <= counter - '1';
    end if;
  end process counter_ctrl_p;

  -- register that stores the value of the counter (control path)
  -- reset_n resets asynchronously the register.
  -- sync_reset_n resets asynchronously the register.
  counter_reg_p: process (clk, reset_n)
  begin  
    if reset_n = '0' then
      counter <= (others => '1');
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' or start_of_burst_i = '1' then
        counter <= (others => '1');
      else
        counter <= d_counter;
      end if;
    end if;
  end process counter_reg_p;


  data_ready_o  <= '1';
  rx_data_ind_o <= rx_data_ind_s_o;
  
  data_resync_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then
      rx_data_o       <= (others => '0');
    elsif clk'event and clk = '1' then
      if rx_data_ind_s_o /= rx_data_ind then
        rx_data_o     <= shift_data;
      end if;
    end if;
  end process data_resync_p;

end rtl;
