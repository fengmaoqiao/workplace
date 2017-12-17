
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: max_picker_2.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block gives the max among the 2 inputs. It also provides
--              the index corresponding to the selected input :
--                if max = operande0 then index = 0
--                if max = operande1 then index = 1
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/biggest_picker/vhdl/rtl/max_picker_2.vhd,v  
--  Log: max_picker_2.vhd,v  
-- Revision 1.1  2002/06/10 09:19:04  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity max_picker_2 is
  generic (
    data_length_g : integer := 16            -- Number of bits for data I/O ports.
  );
  port (
          operande0   : in  std_logic_vector (data_length_g-1 downto 0);
          operande1   : in  std_logic_vector (data_length_g-1 downto 0);

          max         : out std_logic_vector (data_length_g-1 downto 0);--Im part of out.
          index       : out std_logic
  );        
end max_picker_2;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of max_picker_2 is

  signal index_o   : std_logic;
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  index   <= index_o;
  index_o <= '1' when (operande1 > operande0) else '0';
  max     <= operande1 when (index_o = '1') else operande0;
  
end rtl;
