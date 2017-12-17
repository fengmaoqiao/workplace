
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: mdm_math_func_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Mathematical Basic Functions 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/packages/commonlib/vhdl/rtl/mdm_math_func_pkg.vhd,v  
--  Log: mdm_math_func_pkg.vhd,v  
-- Revision 1.6  2004/05/18 14:07:58  Dr.C
-- Added sat_round_signed_sym_slv function for saturate a signed number between symmetrical value.
--
-- Revision 1.5  2003/10/23 08:06:43  Dr.B
-- Updated sat functions to accept sliced slv.
--
-- Revision 1.4  2003/04/01 15:42:00  Dr.F
-- added sat_round_signed_slv function.
--
-- Revision 1.3  2003/03/12 16:58:47  Dr.F
-- changed SSHR functions implementation.
--
-- Revision 1.2  2003/03/07 14:17:19  Dr.F
-- added SSH functions.
--
-- Revision 1.1  2003/03/06 08:55:50  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
    use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all; 

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package mdm_math_func_pkg is

--------------------------------------------------------------------------------
-- function sat_round_signed_slv : saturate and round a signed number
-- remove nb_to_rem MSB of sat_signed_slv and saturate the signal if needed by
-- "01111..." (positive numbers) or "1000....." (negative numbers)
--------------------------------------------------------------------------------
function sat_round_signed_slv
  (
  constant signed_slv    : std_logic_vector ;   -- slv to saturate
  constant nb_to_rem     : integer;             -- nb of bits to remove
  constant lsb           : integer              -- lsb or the rounded output
  
  ) 
  return std_logic_vector;

--------------------------------------------------------------------------------
-- function sat_round_signed_sym_slv : saturate and round a signed number
-- remove nb_to_rem MSB of sat_signed_slv and saturate the signal if needed by
-- "01111..." (positive numbers) or "1000....001" (negative symmetrical numbers)
--------------------------------------------------------------------------------
function sat_round_signed_sym_slv
  (
  constant signed_slv    : std_logic_vector ;   -- slv to saturate
  constant nb_to_rem     : integer;             -- nb of bits to remove
  constant lsb           : integer              -- lsb or the rounded output
  
  ) 
  return std_logic_vector;

--------------------------------------------------------------------------------
-- function sat_signed_slv : truncate and saturate a signed number
-- remove nb_to_rem MSB of sat_signed_slv and saturate the signal if needed by
-- "01111..." (positive numbers) or "1000....." (negative numbers)
--------------------------------------------------------------------------------
function sat_signed_slv
  (
  constant signed_slv    : std_logic_vector ;   -- slv to saturate
  constant nb_to_rem     : integer              -- nb of bits to remove
  ) 
  return std_logic_vector;

--------------------------------------------------------------------------------
-- function sat_unsigned_slv : truncate and saturate an unsigned number
-- remove nb_to_rem MSB of sat_unsigned_slv and saturate the signal if needed by
-- "1111....".
--------------------------------------------------------------------------------
function sat_unsigned_slv 
  (
  constant unsigned_slv  : std_logic_vector ;   -- slv to saturate
  constant nb_to_rem     : integer              -- nb of bits to remove
  ) 
  return std_logic_vector;

--------------------------------------------
-- Signed SHift Right : right shift the signed_slv input
-- by the number of bits indicated in nb_shift,
-- taking care of the sign (MSB).
-- NOTE : the number of shifts is indicated as a std_logic_vector.
--------------------------------------------
function SSHR (
  constant signed_slv    : std_logic_vector ;   -- slv to shift
  constant nb_shift      : std_logic_vector     -- nb shift 
  )
  return std_logic_vector;

--------------------------------------------
-- Signed SHift Right : right shift the signed_slv input
-- by the number of bits indicated in nb_shift,
-- taking care of the sign (MSB).
-- NOTE : the number of shifts is indicated as an integer.
--------------------------------------------
function SSHR (
  constant signed_slv    : std_logic_vector ;   -- slv to shift
  constant nb_shift      : integer              -- nb shift 
  )
  return std_logic_vector;

end mdm_math_func_pkg;
