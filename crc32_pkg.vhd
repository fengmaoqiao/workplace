
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : CRC
--    ,' GoodLuck ,'      RCSfile: crc32_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for crc32.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/crc32/vhdl/rtl/crc32_pkg.vhd,v  
--  Log: crc32_pkg.vhd,v  
-- Revision 1.3  2002/09/26 13:57:30  Dr.B
-- removed slv_pkg package.
--
-- Revision 1.2  2002/02/05 15:47:02  Dr.B
-- four outputs instead of 1.
--
-- Revision 1.1  2001/12/13 13:12:32  Dr.B
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
-- Package
--------------------------------------------------------------------------------
package crc32_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: crc32_4.vhd
----------------------
  component crc32_4
  port (
    -- clock and reset
    clk          : in  std_logic;                    
    resetn       : in  std_logic;                   
     
    -- inputs
    data_in      : in  std_logic_vector ( 3 downto 0);
    --             4-bits inputs for parallel computing. 
    ld_init      : in  std_logic;
    --             initialize the CRC
    calc         : in  std_logic;
    --             ask of calculation of the available data.
 
    -- outputs
    crc_out_1st  : out std_logic_vector (7 downto 0); 
    crc_out_2nd  : out std_logic_vector (7 downto 0); 
    crc_out_3rd  : out std_logic_vector (7 downto 0); 
    crc_out_4th  : out std_logic_vector (7 downto 0) 
    --             CRC result
   );

  end component;


----------------------
-- File: crc32_8.vhd
----------------------
  component crc32_8
  port (
    -- clock and reset
    clk          : in  std_logic;                    
    resetn       : in  std_logic;                   
     
    -- inputs
    data_in      : in  std_logic_vector ( 7 downto 0);
    --             8-bits inputs for parallel computing. 
    ld_init      : in  std_logic;
    --             initialize the CRC
    calc         : in  std_logic;
    --             ask of calculation of the available data.
 
    -- outputs
    crc_out_1st  : out std_logic_vector (7 downto 0); 
    crc_out_2nd  : out std_logic_vector (7 downto 0); 
    crc_out_3rd  : out std_logic_vector (7 downto 0); 
    crc_out_4th  : out std_logic_vector (7 downto 0) 
    --          CRC result
   );

  end component;



 
end crc32_pkg;
