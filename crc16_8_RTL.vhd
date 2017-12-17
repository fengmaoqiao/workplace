
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: crc16_8.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description :  Parallel (8 input bits) Cyclic Redundancy Check 16
--                with the polynomial: G(x) = X^16 + X^12 + X^5 + 1
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/crc16_8/vhdl/rtl/crc16_8.vhd,v  
--  Log: crc16_8.vhd,v  
-- Revision 1.2  2002/01/29 16:05:04  Dr.B
-- bit reversal added.
--
-- Revision 1.1  2001/12/11 15:35:42  Dr.B
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
entity crc16_8 is
  port (
    -- clock and reset
    clk       : in  std_logic;                    
    resetn    : in  std_logic;                   
     
    -- inputs
    data_in   : in  std_logic_vector ( 7 downto 0);
    --          8-bits inputs for parallel computing. 
    ld_init   : in  std_logic;
    --          initialize the CRC
    calc      : in  std_logic;
    --          ask of calculation of the available data.
 
    -- outputs
    crc_out_1st  : out std_logic_vector (7 downto 0); 
    crc_out_2nd  : out std_logic_vector (7 downto 0) 
    --          CRC result
   );

end crc16_8;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of crc16_8 is


  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal crc_int : std_logic_vector (15 downto 0); -- crc register

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  crc_int_proc:process (clk, resetn)
  begin
    if resetn ='0' then
      crc_int <= (others => '1');     -- reset registers
    
    elsif (clk'event and clk = '1') then
      if ld_init = '1' then           -- reset registers for new calculation  
        crc_int <= (others => '1');
      
      elsif calc = '1' then           -- ask of calculation
        -- parallel computation of the CRC-32 according to specifications.
     crc_int(0 ) <= crc_int(12) xor data_in(7 ) xor crc_int(8 ) xor data_in(3 );
     crc_int(1 ) <= crc_int(13) xor data_in(6 ) xor data_in(2 ) xor crc_int(9 );
     crc_int(2 ) <= data_in(5 ) xor crc_int(14) xor data_in(1 ) xor crc_int(10);
     crc_int(3 ) <= data_in(4 ) xor crc_int(15) xor data_in(0 ) xor crc_int(11);
     crc_int(4 ) <= crc_int(12) xor data_in(3 );                                
     crc_int(5 ) <= crc_int(12) xor crc_int(13) xor data_in(7 ) xor crc_int(8 ) 
                                xor data_in(2 ) xor data_in(3 );                
     crc_int(6 ) <= crc_int(13) xor data_in(6 ) xor crc_int(14) xor data_in(1 ) 
                                xor data_in(2 ) xor crc_int(9 );                
     crc_int(7 ) <= data_in(5 ) xor crc_int(14) xor crc_int(15) xor data_in(0 ) 
                                xor data_in(1 ) xor crc_int(10);                
     crc_int(8 ) <= data_in(4 ) xor crc_int(15) xor data_in(0 ) xor crc_int(0 ) 
                                xor crc_int(11);                                
     crc_int(9 ) <= crc_int(12) xor crc_int(1 ) xor data_in(3 );                
     crc_int(10) <= crc_int(13) xor data_in(2 ) xor crc_int(2 );                
     crc_int(11) <= crc_int(3 ) xor crc_int(14) xor data_in(1 );                
     crc_int(12) <= crc_int(12) xor crc_int(4 ) xor data_in(7 ) xor crc_int(15) 
                                xor data_in(0 ) xor crc_int(8 ) xor data_in(3 );
     crc_int(13) <= crc_int(13) xor data_in(6 ) xor crc_int(5 ) xor data_in(2 ) 
                                xor crc_int(9);                                 
     crc_int(14) <= data_in(5 ) xor crc_int(14) xor crc_int(6 ) xor data_in(1 ) 
                                xor crc_int(10);                                
     crc_int(15) <= data_in(4 ) xor crc_int(15) xor data_in(0 ) xor crc_int(7 ) 
                                xor crc_int(11);                                   
                                                                                      
      end if;
    end if;
  end process;
  
  -- 1's complement + bit reversal 
 crc_out_1st (0) <= not crc_int (15);
 crc_out_1st (1) <= not crc_int (14);
 crc_out_1st (2) <= not crc_int (13);
 crc_out_1st (3) <= not crc_int (12);
 crc_out_1st (4) <= not crc_int (11);
 crc_out_1st (5) <= not crc_int (10);
 crc_out_1st (6) <= not crc_int ( 9);
 crc_out_1st (7) <= not crc_int ( 8);

 crc_out_2nd (0) <= not crc_int ( 7);
 crc_out_2nd (1) <= not crc_int ( 6);
 crc_out_2nd (2) <= not crc_int ( 5);
 crc_out_2nd (3) <= not crc_int ( 4);
 crc_out_2nd (4) <= not crc_int ( 3);
 crc_out_2nd (5) <= not crc_int ( 2);
 crc_out_2nd (6) <= not crc_int ( 1);
 crc_out_2nd (7) <= not crc_int ( 0);

end RTL;
