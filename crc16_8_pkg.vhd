
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: crc16_8_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for crc16_8.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/crc16_8/vhdl/rtl/crc16_8_pkg.vhd,v  
--  Log: crc16_8_pkg.vhd,v  
-- Revision 1.1  2002/01/29 16:04:33  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--library CommonLib;
library work;
--    use CommonLib.slv_pkg.all;
use work.slv_pkg.all;


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package crc16_8_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: crc16_8.vhd
----------------------
  component crc16_8
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

  end component;


----------------------
-- File: crc16_8_pkg.vhd
----------------------
-- No entity declaration



 
end crc16_8_pkg;
