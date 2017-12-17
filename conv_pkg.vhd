
--------------------------------------------------------------------------------
-- end of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : GoodLuck Package
--    ,' GoodLuck ,'      RCSfile: conv_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.10   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Arithmetic functions dealing with Standard Logic Vector.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/packages/commonlib/vhdl/rtl/conv_pkg.vhd,v  
--  Log: conv_pkg.vhd,v  
-- Revision 1.10  2004/02/04 11:28:13  sbizet
-- Readded pragma
--
-- Revision 1.9  2004/01/21 13:49:20  sbizet
-- Added pragma
--
-- Revision 1.8  2003/12/17 14:26:42  sbizet
-- Added int2real function
--
-- Revision 1.7  2002/03/19 10:43:58  Dr.A
-- Added pragmas for synthesis.
--
-- Revision 1.6  2002/03/08 15:56:04  Dr.A
-- Added slv <-> real conversion functions.
--
-- Revision 1.5  2001/12/06 09:18:44  Dr.J
-- Added description and project name
--
-- Revision 1.4  2001/08/28 16:14:17  Dr.J
-- Debug power function
--
-- Revision 1.3  2001/06/12 10:08:58  Dr.F
-- changed int2slv function.
--
-- Revision 1.2  2001/06/11 12:55:27  Dr.F
-- added power function.
--
-- Revision 1.1  2000/01/20 18:04:40  dbchef
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- library synergy;
-- use synergy.signed_arith.all;

--library commonlib;
library work;
--use commonlib.slv_pkg.all;
use work.slv_pkg.all;


package conv_pkg is

  type FormatType is (HEX, DEC, BIN);
  
  function slv2str (a : std_logic_vector; format : FormatType) return string;
  function int2slv (a : integer; size : integer) return std_logic_vector;
  function str2slv (a      : string;
                    format : FormatType;
                    size   : integer) return std_logic_vector;
  -- function slv2int (L : STD_LOGIC_VECTOR) return INTEGER;
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  function slv2real (a : std_logic_vector; coma : integer) return real;
--  function real2slv (r        : real;
--                     slv_size : integer;
--                     coma     : integer) return std_logic_vector;
--  function int2real ( a       : integer) return real;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on

  
end conv_pkg;
