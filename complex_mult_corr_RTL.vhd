
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: complex_mult_corr.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Partial Part of the multiplication
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/preprocessing/vhdl/rtl/complex_mult_corr.vhd,v  
--  Log: complex_mult_corr.vhd,v  
-- Revision 1.1  2003/03/27 16:36:40  Dr.B
-- Initial revision
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
entity complex_mult_corr is
  generic (
    size_in_g     : integer := 11      -- size of the data inputs
          );    
  port (

    --------------------------------------
    -- Signals
    --------------------------------------
    -- Data in
    data_in_i : in std_logic_vector(size_in_g - 1 downto 0);
    data_in_q : in std_logic_vector(size_in_g - 1 downto 0);
    -- Coeff
    coeff_i   : in std_logic_vector(1 downto 0);
    coeff_q   : in std_logic_vector(1 downto 0);
    -- Results (1 bit more because of the max negative value
    -- that can not be "-" with the same nb of bits
    operand_a_i : out std_logic_vector(size_in_g downto 0);
    operand_a_q : out std_logic_vector(size_in_g downto 0);
    operand_b_i : out std_logic_vector(size_in_g downto 0);
    operand_b_q : out std_logic_vector(size_in_g downto 0)   
  );

end complex_mult_corr;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of complex_mult_corr is

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  operand_a_p: process (coeff_i, data_in_i, data_in_q)
  begin  -- process operanda_0i_proc
    case coeff_i is
      when "00" =>  -- 0
        operand_a_i <= (others => '0');
        operand_a_q <= (others => '0');
      when "01" =>  -- 1
        operand_a_i <= sxt(data_in_i,size_in_g + 1);
        operand_a_q <= sxt(data_in_q,size_in_g + 1);
      when others => -- "11" = -1
        operand_a_i <= - signed(sxt(data_in_i,size_in_g + 1));
        operand_a_q <= - signed(sxt(data_in_q,size_in_g + 1));        
    end case;
  end process operand_a_p;
  
  operand_b_p: process (coeff_q, data_in_i, data_in_q)
  begin  -- process operanda_0i_proc
    case coeff_q is
      when "00" => -- 0
        operand_b_i <= (others => '0');
        operand_b_q <= (others => '0');
      when "01" => -- 1
        operand_b_i <= sxt(data_in_q,size_in_g + 1);
        operand_b_q <= - signed(sxt(data_in_i,size_in_g + 1));
      when others => -- "11" = -1
        operand_b_i <= - signed(sxt(data_in_q,size_in_g + 1));  
        operand_b_q <= sxt(data_in_i,size_in_g + 1);   
    end case;
  end process operand_b_p;

end RTL;
