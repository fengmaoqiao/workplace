
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : CORDIC
--    ,' GoodLuck ,'      RCSfile: cordic_fft2_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for cordic_fft2.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic_fft2/vhdl/rtl/cordic_fft2_pkg.vhd,v  
--  Log: cordic_fft2_pkg.vhd,v  
-- Revision 1.1  2003/03/17 07:59:02  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
    use ieee.std_logic_1164.all; 

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package cordic_fft2_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: cordic_fft2_stage.vhd
----------------------
  component cordic_fft2_stage
  generic (
    data_size_g  : integer;  
    stage_g      : integer  
  );
  port (
    x_i        : in  std_logic_vector(data_size_g-1 downto 0);   
    y_i        : in  std_logic_vector(data_size_g-1 downto 0);   
    delta_i    : in  std_logic;   

    x_o        : out std_logic_vector(data_size_g-1 downto 0);   
    y_o        : out std_logic_vector(data_size_g-1 downto 0)   
  );
  end component;


----------------------
-- File: cordic_fft2.vhd
----------------------
  component cordic_fft2
  generic (
    data_size_g    : integer := 12; -- should be between 10 and 32
    cordic_bits_g  : integer := 11  -- defines the nbr of stages, range 8 to 31
                                    -- data_size_g-1 >= cordic_bits_g
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    masterclk    : in  std_logic;   
    reset_n      : in  std_logic;   
    sync_rst_ni  : in  std_logic;
    --------------------------------------
    -- rotation data and angle
    --------------------------------------
    x_i          : in  std_logic_vector(data_size_g-1 downto 0);    
    y_i          : in  std_logic_vector(data_size_g-1 downto 0);    
    delta_i      : in  std_logic_vector(cordic_bits_g-1 downto 0);  
    --
    x_o          : out std_logic_vector(data_size_g-1 downto 0);    
    y_o          : out std_logic_vector(data_size_g-1 downto 0)     
       );
  end component;



 
end cordic_fft2_pkg;
