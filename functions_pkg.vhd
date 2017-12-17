
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: functions_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Functions for mapping.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/mapping/vhdl/rtl/functions_pkg.vhd,v  
--  Log: functions_pkg.vhd,v  
-- Revision 1.5  2002/04/30 12:08:26  Dr.B
-- adapted for code checker.
--
-- Revision 1.4  2002/03/06 14:23:47  Dr.B
-- signal in prot map readded.
--
-- Revision 1.3  2002/03/06 13:35:53  Dr.B
-- completed port map information, _number => number
--
-- Revision 1.2  2002/01/29 16:25:11  Dr.B
-- function angle_add_barker added.
--
-- Revision 1.1  2001/12/20 12:51:36  Dr.B
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
package functions_pkg is

--------------------------------------------------------------------------------
-- function angle_add : perform a angle addition : 2 bits + 2 bits => 2 bits
--------------------------------------------------------------------------------
function angle_add 
  (
  constant phi1 : std_logic_vector (1 downto 0);
  constant phi2 : std_logic_vector (1 downto 0)
  ) 
  return std_logic_vector;

--------------------------------------------------------------------------------
-- function angle_add_barker : perform a angle addition with 0 (00) or pi (11)
--------------------------------------------------------------------------------
function angle_add_barker 
  (
  constant phi_bark : std_logic;
  constant phi2     : std_logic_vector (1 downto 0)
  ) 
  return std_logic_vector;

--------------------------------------------------------------------------------
-- function qpsk_enc : QPSK encoding
--------------------------------------------------------------------------------
function qpsk_enc 
  (
  constant d1 : std_logic;
  constant d2 : std_logic
  ) 
  return std_logic_vector;

end functions_pkg;
