
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: data_shift.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Right shift input data of a number of bits
--               given in an input register (max 15).
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/phase_estimation/vhdl/rtl/data_shift.vhd,v  
--  Log: data_shift.vhd,v  
-- Revision 1.2  2002/05/02 07:40:43  Dr.A
-- Added work-around for Synopsys synthesis.
--
-- Revision 1.1  2002/03/28 12:42:05  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity data_shift is
  generic (
    dsize_g : integer := 30 -- Data size
  );
  port (
    shift_reg      : in  std_logic_vector(3 downto 0);
    data_in        : in  std_logic_vector(dsize_g-1 downto 0);
    --
    shifted_data   : out std_logic_vector(dsize_g+14 downto 0)
  );

end data_shift;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of data_shift is

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  shift_pr: process (shift_reg, data_in)
  -- temp variable used for Synopsys work around (HDL-123)
  variable temp : std_logic_vector(14 downto 0);

  begin
    temp := (others => data_in(dsize_g-1));
    case shift_reg is
      when "0000" =>
        shifted_data(dsize_g+14 downto 15) <= data_in;
        shifted_data(14 downto 0) <= (others => '0');
      
      when "0001" =>
        shifted_data(dsize_g+14) <= data_in(dsize_g-1);
        shifted_data(dsize_g+13 downto 14) <= data_in;
        shifted_data(13 downto 0) <= (others => '0');
      
      when "0010" =>
        shifted_data(dsize_g+14 downto dsize_g+13) <= temp (1 downto 0);
--         (others => data_in(dsize_g-1));
        shifted_data(dsize_g+12 downto 13) <= data_in;
        shifted_data(12 downto 0) <= (others => '0');
      
      when "0011" =>
        shifted_data(dsize_g+14 downto dsize_g+12) <= temp (2 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+11 downto 12) <= data_in;
        shifted_data(11 downto 0) <= (others => '0');
      
      when "0100" =>
        shifted_data(dsize_g+14 downto dsize_g+11) <= temp (3 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+10 downto 11) <= data_in;
        shifted_data(10 downto 0) <= (others => '0');
      
      when "0101" =>
        shifted_data(dsize_g+14 downto dsize_g+10) <= temp (4 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+9 downto 10) <= data_in;
        shifted_data(9 downto 0) <= (others => '0');
      
      when "0110" =>
        shifted_data(dsize_g+14 downto dsize_g+9) <= temp (5 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+8 downto 9) <= data_in;
        shifted_data(8 downto 0) <= (others => '0');
      
      when "0111" =>
        shifted_data(dsize_g+14 downto dsize_g+8) <= temp (6 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+7 downto 8) <= data_in;
        shifted_data(7 downto 0) <= (others => '0');
      
      when "1000" =>
        shifted_data(dsize_g+14 downto dsize_g+7) <= temp (7 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+6 downto 7) <= data_in;
        shifted_data(6 downto 0) <= (others => '0');
      
      when "1001" =>
        shifted_data(dsize_g+14 downto dsize_g+6) <= temp (8 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+5 downto 6) <= data_in;
        shifted_data(5 downto 0) <= (others => '0');
      
      when "1010" =>
        shifted_data(dsize_g+14 downto dsize_g+5) <= temp (9 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+4 downto 5) <= data_in;
        shifted_data(4 downto 0) <= (others => '0');
      
      when "1011" =>
        shifted_data(dsize_g+14 downto dsize_g+4) <= temp (10 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+3 downto 4) <= data_in;
        shifted_data(3 downto 0) <= (others => '0');
      
      when "1100" =>
        shifted_data(dsize_g+14 downto dsize_g+3) <= temp (11 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+2 downto 3) <= data_in;
        shifted_data(2 downto 0) <= (others => '0');
      
      when "1101" =>
        shifted_data(dsize_g+14 downto dsize_g+2) <= temp (12 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g+1 downto 2) <= data_in;
        shifted_data(1 downto 0) <= (others => '0');
      
      when "1110" =>
        shifted_data(dsize_g+14 downto dsize_g+1) <= temp (13 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g downto 1) <= data_in;
        shifted_data(0) <= '0';
      
      when others =>
        shifted_data(dsize_g+14 downto dsize_g) <= temp (14 downto 0);
--          (others => data_in(dsize_g-1));
        shifted_data(dsize_g-1 downto 0) <= data_in;
        
    end case;
    
      
  end process shift_pr;

end RTL;
