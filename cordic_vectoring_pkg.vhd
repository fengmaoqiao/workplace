
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : CORDIC
--    ,' GoodLuck ,'      RCSfile: cordic_vectoring_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for cordic_vectoring.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic_vectoring/vhdl/rtl/cordic_vectoring_pkg.vhd,v  
--  Log: cordic_vectoring_pkg.vhd,v  
-- Revision 1.2  2003/06/11 16:07:26  Dr.F
-- port map changed.
--
-- Revision 1.1  2003/03/17 07:50:01  Dr.F
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
package cordic_vectoring_pkg is

  --------------------------------------------
  -- Types
  --------------------------------------------
  type ARRAY_OF_SLV32_T is array (natural range <>) of 
                           std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: microrotation.vhd
----------------------
  component microrotation
  generic (                                                           
    data_length_g : integer := 16;
    stage_g       : integer := 0
  );                                                                  
  port (                                                              
    x_i      : in  std_logic_vector(data_length_g downto 0);  
    y_i      : in  std_logic_vector(data_length_g downto 0);
     
    x_o      : out std_logic_vector(data_length_g downto 0);
    y_o      : out std_logic_vector(data_length_g downto 0)
  );                                                                  
  end component;


----------------------
-- File: comb_stage_vectoring.vhd
----------------------
  component comb_stage_vectoring
  generic (                                                           
    data_length_g    : integer := 16;
    angle_length_g   : integer := 16;
    start_stage_g    : integer := 0;
    nbr_comb_stage_g : integer := 4
  );                                                                  
  port (                                                              
        clk      : in  std_logic;                                
        reset_n  : in  std_logic; 
        
        -- angle with which the inputs must be rotated :                          
        z_i      : in  std_logic_vector(angle_length_g-1 downto 0);
        
        -- inputs to be rotated :
        x_i      : in  std_logic_vector(data_length_g downto 0);  
        y_i      : in  std_logic_vector(data_length_g downto 0);
         
        -- Arctangent reference table
        arctan_array_ref : in ARRAY_OF_SLV32_T(nbr_comb_stage_g-1 downto 0);
        
        -- remaining angle with which outputs have not been rotated : 
        z_o      : out std_logic_vector(angle_length_g-1 downto 0);
        
        -- rotated output. They have been rotated of (z_in-z_out) :
        x_o      : out std_logic_vector(data_length_g downto 0);
        y_o      : out std_logic_vector(data_length_g downto 0)
  );                                                                  
  end component;


----------------------
-- File: cordic_vectoring.vhd
----------------------
  component cordic_vectoring
  generic (
    -- number of bits for the complex data :
    data_length_g   : integer := 12;
    -- number of bits for the output angle z_in :
    angle_length_g  : integer := 12;
    -- number of microrotation stages in a combinational path :
    nbr_combstage_g : integer := 3; -- must be > 0
    -- number of pipes
    nbr_pipe_g      : integer := 4  -- must be > 0
    -- NOTE : the total number of microrotations is nbr_combstage_g * nbr_pipe_g
  );                                                                  
  port (                                                              
        clk      : in  std_logic;                                
        reset_n  : in  std_logic; 
        
        -- input vector to be rotated :
        x_i    : in  std_logic_vector(data_length_g-1 downto 0);  
        y_i    : in  std_logic_vector(data_length_g-1 downto 0);
         
        -- angle of the input vector :                          
        z_o    : out std_logic_vector(angle_length_g-1 downto 0);
        -- magnitude of the input vector
        mag_o  : out std_logic_vector(data_length_g downto 0)
  );                                                                  
  end component;



 
end cordic_vectoring_pkg;
