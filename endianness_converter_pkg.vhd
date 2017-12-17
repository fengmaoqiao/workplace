
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : ENDIANNESS_CONVERTER
--    ,' GoodLuck ,'      RCSfile: endianness_converter_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for endianness_converter.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/endianness_converter/vhdl/rtl/endianness_converter_pkg.vhd,v  
--  Log: endianness_converter_pkg.vhd,v  
-- Revision 1.1  2003/10/31 15:59:46  Dr.A
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
package endianness_converter_pkg is

  -- Define constants for accessed data type.
  constant WORD_CT  : std_logic_vector(1 downto 0) := "00";
  constant HWORD_CT : std_logic_vector(1 downto 0) := "01";
  constant BYTE_CT  : std_logic_vector(1 downto 0) := "10";
  
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: endianness_converter.vhd
----------------------
  component endianness_converter
  port (
    --------------------------------------
    -- Data busses
    --------------------------------------
    -- Little endian master interface.
    wdata_i    : in  std_logic_vector(31 downto 0);
    rdata_o    : out std_logic_vector(31 downto 0);
    -- Big endian system interface.
    wdata_o    : out std_logic_vector(31 downto 0);
    rdata_i    : in  std_logic_vector(31 downto 0);

    --------------------------------------
    -- Controls
    --------------------------------------
    acctype    : in  std_logic_vector( 1 downto 0) -- Type of data accessed.
    
  );

  end component;



 
end endianness_converter_pkg;
