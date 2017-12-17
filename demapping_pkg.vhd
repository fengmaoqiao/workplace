
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--    ,' GoodLuck ,'      RCSfile: demapping_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for demapping.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/demapping/vhdl/rtl/demapping_pkg.vhd,v  
--  Log: demapping_pkg.vhd,v  
-- Revision 1.1  2002/03/28 13:04:15  Dr.A
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
package demapping_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: demapping.vhd
----------------------
  component demapping
  generic (
    dsize_g : integer := 6 -- Data size.
  );
  port (
    -- Demodulated data in
    demap_i      : in  std_logic_vector(dsize_g-1 downto 0); -- Real part.
    demap_q      : in  std_logic_vector(dsize_g-1 downto 0); -- Imaginary part.
    demod_rate   : in  std_logic; -- Demodulation rate: 0 for BPSK, 1 for QPSK.
    --
    demap_data   : out std_logic_vector(1 downto 0)
  );

  end component;



 
end demapping_pkg;
