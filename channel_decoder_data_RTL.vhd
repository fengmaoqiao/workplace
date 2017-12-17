
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: channel_decoder_data.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Data of the Channel decoder
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/channel_decoder/vhdl/rtl/channel_decoder_data.vhd,v  
--  Log: channel_decoder_data.vhd,v  
-- Revision 1.1  2003/03/24 10:17:46  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 
 
--library channel_decoder_rtl;
library work;
--use channel_decoder_rtl.channel_decoder_pkg.all;
use work.channel_decoder_pkg.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity channel_decoder_data is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n            : in  std_logic;
    clk                : in  std_logic;
    sync_reset_n       : in  std_logic;
    
    -----------------------------------------------------------------------
    -- Symbol Strobe
    -----------------------------------------------------------------------
    enable_i           : in  std_logic;  -- Enable signal

    data_valid_i       : in  std_logic;  -- Data_valid input
    data_valid_o       : out std_logic;  -- Data_valid output

    start_data_field_i : in  std_logic;
    start_data_field_o : out std_logic;

    end_data_field_i   : in  std_logic;
    end_data_field_o   : out std_logic;

    -----------------------------------------------------------------------
    -- Data Interface
    -----------------------------------------------------------------------
    data_i             : in  std_logic;
    data_o             : out std_logic
  );

end channel_decoder_data;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of channel_decoder_data is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal enable_datapath : std_logic;
  signal data            : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  --------------------------------------
  -- DATA CONTROL
  --------------------------------------
  data_control_1 : data_control
    port map (
      -- Clock & Reset Interface
      reset_n            => reset_n,
      clk                => clk,
      sync_reset_n       => sync_reset_n,
      -- Symbol Strobe
      enable_i           => enable_i,        -- Enable signal for FSM
      enable_o           => enable_datapath, -- Enable signal for datapath

      data_valid_i       => data_valid_i,
      data_valid_o       => data_valid_o,

      start_data_field_i => start_data_field_i,
      start_data_field_o => start_data_field_o,

      end_data_field_i   => end_data_field_i,
      end_data_field_o   => end_data_field_o
      );


  --------------------------------------
  -- DATA DATAPATH
  --------------------------------------
  data_datapath_1 : data_datapath
    port map (
      -- Clock & Reset Interface
      reset_n  => reset_n,         -- Async Reset
      clk      => clk,             -- Clock
      -- Symbol Strobe
      enable_i => enable_datapath, -- enable signal from fsm
      -- Data Interfaces
      data_i   => data,            -- registered data from Viterbi
      data_o   => data_o           -- output signal
      );


  --------------------------------------
  -- Delay data process
  --------------------------------------
  delay_data_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      data  <= '0';
    elsif clk = '1' and clk'event then -- rising clock edge
      if enable_i = '1' and data_valid_i = '1' then
        data <= data_i;                --  enable condition (active high)
      end if;
    end if;
  end process delay_data_p;


end RTL;
