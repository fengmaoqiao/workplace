
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Cordic in vectoring mode
--    ,' GoodLuck ,'      RCSfile: cordic_vect_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for cordic_vect.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic_vect/vhdl/rtl/cordic_vect_pkg.vhd,v  
--  Log: cordic_vect_pkg.vhd,v  
-- Revision 1.3  2004/08/24 15:48:59  arisse
-- Added globals for test purpose.
--
-- Revision 1.2  2003/04/03 13:43:42  Dr.B
-- add scaling_g generic.
--
-- Revision 1.1  2002/10/28 10:02:48  Dr.C
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
package cordic_vect_pkg is


-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  signal x_n_gbl             : std_logic_vector(14 downto 0);
--  signal y_n_gbl             : std_logic_vector(14 downto 0);
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: arctan_lut.vhd
----------------------
  component arctan_lut
  generic (
    dsize_g       : integer := 32;                    -- max value = 32.
    scaling_g     : integer := 0   -- 1:Use all the amplitude (pi/2 = 2^errosize_g=~ 01111....) 
  );                               -- (-pi/2 = -2^errosize_g= 100000....) 
  port (
    index   : in  std_logic_vector(4 downto 0); -- i value.
    arctan  : out std_logic_vector(dsize_g-1 downto 0)
  );
 

  end component;


----------------------
-- File: cordic_vect.vhd
----------------------
  component cordic_vect
  generic (
    datasize_g    : integer := 10; -- Data size. Max value is 30.
    errorsize_g   : integer := 10; -- Data size. Max value is 30.
    scaling_g     : integer := 0   -- 1:Use all the amplitude of angle_out
                                        --  pi/2 =^=  2^errosize_g =~ 01111... 
  );                                    -- -pi/2 =^= -2^errosize_g =  100000.. 
  port (
    -- clock and reset.
    clk          : in  std_logic;                   
    reset_n      : in  std_logic;    
    --
    load         : in  std_logic; -- Load input values.
    x_in         : in  std_logic_vector(datasize_g-1 downto 0); -- Real part in.
    y_in         : in  std_logic_vector(datasize_g-1 downto 0); -- Imaginary part.
    --
    angle_out    : out std_logic_vector(errorsize_g-1 downto 0); -- Angle out.
    cordic_ready : out std_logic                             -- Angle ready.
  );

  end component;



 
end cordic_vect_pkg;
