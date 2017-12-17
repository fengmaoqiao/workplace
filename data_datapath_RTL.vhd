
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: data_datapath.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Data datapath of the Channel decoder
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/channel_decoder/vhdl/rtl/data_datapath.vhd,v  
--  Log: data_datapath.vhd,v  
-- Revision 1.1  2003/03/24 10:18:02  Dr.C
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
entity data_datapath is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n  : in  std_logic;
    clk      : in  std_logic;
        
    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i : in  std_logic;   -- Enable signal bit
    
    --------------------------------------
    -- Data Interface
    --------------------------------------
    data_i   : in  std_logic;
    data_o   : out std_logic
    
  );

end data_datapath;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of data_datapath is


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  --------------------------------------
  -- Delay data process
  --------------------------------------
  delay_data_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      data_o  <= '0';
    elsif clk = '1' and clk'event then  -- rising clock edge
      if enable_i = '1' then            --  enable condition (active high)
        data_o <= data_i;
      end if;
    end if;
  end process delay_data_p;

end RTL;
