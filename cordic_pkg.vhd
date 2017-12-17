--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Cordic
--    ,' GoodLuck ,'      RCSfile: cordic_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for cordic.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic/vhdl/rtl/cordic_pkg.vhd,v  
--  Log: cordic_pkg.vhd,v  
-- Revision 1.7  2003/09/05 09:07:58  Dr.C
-- Removed commonlib call.
--
-- Revision 1.6  2003/07/07 08:31:55  Dr.C
-- Increased cordic outputs size
--
-- Revision 1.5  2003/05/07 13:34:25  Dr.J
-- Added enable
--
-- Revision 1.4  2003/05/05 08:59:58  Dr.C
-- Added scaling generic.
--
-- Revision 1.3  2002/11/08 13:45:00  Dr.J
-- Removed clk and reset in shift_adder
--
-- Revision 1.2  2002/06/10 12:58:56  Dr.J
-- Updated with the new port map
--
-- Revision 1.1  2002/05/21 15:39:06  Dr.J
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
package cordic_pkg is

  --------------------------------------------
  -- Types
  --------------------------------------------
  type ArrayOfSLV32 is array (natural range <>) of 
                           std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: shift_adder.vhd
----------------------
  component shift_adder
  generic (                                                           
    data_length_g : integer := 16;
    stage_g       : integer := 0
  );                                                                  
  port (                                                              
        z_sign   : in  std_logic; -- 1 : neg ; 0 : pos
        x_in     : in  std_logic_vector(data_length_g downto 0);  
        y_in     : in  std_logic_vector(data_length_g downto 0);
         
        x_out    : out std_logic_vector(data_length_g downto 0);
        y_out    : out std_logic_vector(data_length_g downto 0)
  );                                                                  
  end component;


----------------------
-- File: cordic_combstage.vhd
----------------------
  component cordic_combstage
  generic (                                                           
    data_length_g  : integer := 16;
    angle_length_g : integer := 16;
    start_stage_g  : integer := 0;
    nbr_stage_g    : integer := 4;
    nbr_input_g    : integer := 1
  );                                                                  
  port (                                                              
        clk      : in  std_logic;                                
        reset_n  : in  std_logic; 
        enable   : in  std_logic;
        -- angle with which the inputs must be rotated :                          
        z_in     : in  std_logic_vector(angle_length_g-1 downto 0);
        
        -- inputs to be rotated :
        x0_in    : in  std_logic_vector(data_length_g downto 0);  
        y0_in    : in  std_logic_vector(data_length_g downto 0);
        x1_in    : in  std_logic_vector(data_length_g downto 0);  
        y1_in    : in  std_logic_vector(data_length_g downto 0);
        x2_in    : in  std_logic_vector(data_length_g downto 0);  
        y2_in    : in  std_logic_vector(data_length_g downto 0);
        x3_in    : in  std_logic_vector(data_length_g downto 0);  
        y3_in    : in  std_logic_vector(data_length_g downto 0);
         
        -- Arctangent reference table
        arctan_array_ref : in ArrayOfSLV32(nbr_stage_g-1 downto 0);
        
        -- remaining angle with which outputs have not been rotated : 
        z_out    : out std_logic_vector(angle_length_g-1 downto 0);
        
        -- rotated output. They have been rotated of (z_in-z_out) :
        x0_out   : out std_logic_vector(data_length_g downto 0);
        y0_out   : out std_logic_vector(data_length_g downto 0);
        x1_out   : out std_logic_vector(data_length_g downto 0);
        y1_out   : out std_logic_vector(data_length_g downto 0);
        x2_out   : out std_logic_vector(data_length_g downto 0);
        y2_out   : out std_logic_vector(data_length_g downto 0);
        x3_out   : out std_logic_vector(data_length_g downto 0);
        y3_out   : out std_logic_vector(data_length_g downto 0)
  );                                                                  
  end component;


----------------------
-- File: cordic.vhd
----------------------
  component cordic
  generic (
    -- number of bits for the complex data :                                                           
    data_length_g   : integer := 16;
    -- number of bits for the input angle z_in :                                                           
    angle_length_g  : integer := 16;
    -- number of microrotation stages in a combinational path :
    nbr_combstage_g : integer := 4; -- must be > 0
    -- number of pipes
    nbr_pipe_g      : integer := 4; -- must be > 0
    -- NOTE : the total number of microrotations is nbr_combstage_g * nbr_pipe_g
    -- number of input used
    nbr_input_g     : integer := 1; -- must be > 0
    -- 1:Use all the amplitude (pi/2 = 2^errosize_g=~ 01111....)
    -- (-pi/2 = -2^errosize_g= 100000....)
    scaling_g     : integer := 0
  );                                                                  
  port (                                                              
        clk      : in  std_logic;                                
        reset_n  : in  std_logic; 
        enable   : in  std_logic; 
        
        -- angle with which the inputs must be rotated :                          
        z_in     : in  std_logic_vector(angle_length_g-1 downto 0);
        
        -- inputs to be rotated :
        x0_in    : in  std_logic_vector(data_length_g-1 downto 0);  
        y0_in    : in  std_logic_vector(data_length_g-1 downto 0);
        x1_in    : in  std_logic_vector(data_length_g-1 downto 0);  
        y1_in    : in  std_logic_vector(data_length_g-1 downto 0);
        x2_in    : in  std_logic_vector(data_length_g-1 downto 0);  
        y2_in    : in  std_logic_vector(data_length_g-1 downto 0);
        x3_in    : in  std_logic_vector(data_length_g-1 downto 0);  
        y3_in    : in  std_logic_vector(data_length_g-1 downto 0);
         
        -- rotated output. They have been rotated of z_in :
        x0_out   : out std_logic_vector(data_length_g+1 downto 0);
        y0_out   : out std_logic_vector(data_length_g+1 downto 0);
        x1_out   : out std_logic_vector(data_length_g+1 downto 0);
        y1_out   : out std_logic_vector(data_length_g+1 downto 0);
        x2_out   : out std_logic_vector(data_length_g+1 downto 0);
        y2_out   : out std_logic_vector(data_length_g+1 downto 0);
        x3_out   : out std_logic_vector(data_length_g+1 downto 0);
        y3_out   : out std_logic_vector(data_length_g+1 downto 0)
 
  );                                                                  

  end component;



 
end cordic_pkg;
