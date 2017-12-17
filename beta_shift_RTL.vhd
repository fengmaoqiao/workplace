
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: beta_shift.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Right shifts input data of a number of bits
--               given by beta.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/equalizer/vhdl/rtl/beta_shift.vhd,v  
--  Log: beta_shift.vhd,v  
-- Revision 1.3  2003/12/12 15:18:30  Dr.B
-- change shift and remove round truncation.
--
-- Revision 1.2  2002/11/22 08:15:10  Dr.B
-- change truncature.
--
-- Revision 1.1  2002/07/31 13:26:11  Dr.B
-- Initial revision
--
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity beta_shift is
  generic (
    dsize_g : integer := 30 -- Data size
  );
  port (
    beta           : in  std_logic_vector(2 downto 0);
    data_in        : in  std_logic_vector(dsize_g-1 downto 0);
    --
    shifted_data   : out std_logic_vector(dsize_g+1 downto 0)
  );

end beta_shift;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of beta_shift is

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin


  shift_pr: process (beta, data_in)
  begin
    case beta is     
      when "000" =>
        shifted_data <= data_in & "00";
      
      when "001" =>
        shifted_data <= sxt(data_in, dsize_g+1) & '0';

      when "010" =>
        shifted_data <= sxt(data_in, dsize_g+2);

      when "011" =>
        shifted_data <= sxt(data_in(data_in'high downto 1), dsize_g+2);
      
      when "100" =>
        shifted_data <= sxt(data_in(data_in'high downto 2), dsize_g+2);
      
      when "101" => 
        shifted_data <= sxt(data_in(data_in'high downto 3), dsize_g+2);

      when others => --"110"
        shifted_data <= sxt(data_in(data_in'high downto 4), dsize_g+2);
    end case;
    
      
  end process shift_pr;

end RTL;
