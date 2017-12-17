
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: tx_activ_gen.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Generate the tx_activate : add a delay of txenddel_reg clock cycles
-- from the tx_activated of the tx_path_core.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/modem_sm_b/vhdl/rtl/tx_activ_gen.vhd,v  
--  Log: tx_activ_gen.vhd,v  
-- Revision 1.1  2003/11/03 15:07:52  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity tx_activ_gen is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- Signals
    --------------------------------------
    txenddel_reg        : in  std_logic_vector(7 downto 0);
    tx_acti_tx_path     : in  std_logic; -- tx_activate from tx_path_core
    tx_activated_long   : out std_logic  -- tx_activate longer of txenddel_reg periods
    
  );

end tx_activ_gen;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of tx_activ_gen is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- signals for generating tx_activated
  signal tx_acti_tx_path_ff0 : std_logic;
  signal activate_counter    : std_logic_vector(7 downto 0); 


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -- The tx_activate from the tx_path_core must be prolongated by the delay of
  -- the front-end.
  --
  --                 __________________________          
  -- tx_acti_tx_path                           \____________________
  --                    _________________________
  -- tx_acti_tx_path_ff0                         \__________________
  --                   ___________________________ _ _ _ _ ___________
  -- activate_counter  ___________0_______________X4X3X2X1X_____0_____
  --                   _____________________________________
  -- tx_activate_long                                       \_________
  
  tx_activated_p: process (hclk, hresetn)
  begin  -- process tx_activated_p
    if hresetn = '0' then
      tx_acti_tx_path_ff0 <= '0';
      tx_activated_long   <= '0';
      activate_counter    <= (others => '0');
    elsif hclk'event and hclk = '1' then
      tx_acti_tx_path_ff0 <= tx_acti_tx_path;
      -- *** Counter *** 
      if tx_acti_tx_path = '0' and tx_acti_tx_path_ff0 = '1' then
        -- last data has been sent => init with max val
        activate_counter <= txenddel_reg;
      elsif activate_counter /= "00000" then
        -- count down
        activate_counter <= activate_counter - '1';        
      end if;

      -- *** tx_activated gen ***
      if tx_acti_tx_path = '1' or tx_acti_tx_path_ff0 = '1'
        or activate_counter /= "00000" then
        tx_activated_long <= '1';
      else
        tx_activated_long <= '0';
      end if;
    end if;
  end process tx_activated_p;



end RTL;
