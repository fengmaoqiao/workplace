


--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : CORDIC
--    ,' GoodLuck ,'      RCSfile: comb_stage_vectoring.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block is composed of nbr_comb_stage_g microrotation 
--               stages. These microrotations are performed to align the
--               input samle with the X axis.
--               The microrotation stages are performed in a combinational
--               way, without any flip-flop between stages.
-- WARNING : The following signals are multidimensional arraies :
--             z_i, x0_i, y0_i, x1_i, y1_i, x2_i, y2_i, x3_i, y3_i,
--             arctan_array and arctan_array_ref.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic_vectoring/vhdl/rtl/comb_stage_vectoring.vhd,v  
--  Log: comb_stage_vectoring.vhd,v  
-- Revision 1.2  2003/06/11 16:06:55  Dr.F
-- changed port map instanciation of microrotation.
--
-- Revision 1.1  2003/03/17 07:49:56  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_unsigned.all; 

--library cordic_vectoring_rtl;
library work;
--use cordic_vectoring_rtl.cordic_vectoring_pkg.all;
use work.cordic_vectoring_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity comb_stage_vectoring is
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
end comb_stage_vectoring;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of comb_stage_vectoring is

  --------------------------------------------
  -- Types
  --------------------------------------------
  type DATA_ARRAY_T    is array (natural range <>) of 
                           std_logic_vector(data_length_g downto 0);
  type ANGLE_ARRAY_T   is array (natural range <>) of 
                           std_logic_vector(angle_length_g-1 downto 0);

  --------------------------------------------
  -- Signals
  --------------------------------------------
  --remaining angle after each microrotation stage
  signal z            : ANGLE_ARRAY_T(nbr_comb_stage_g downto 0);

  -- y sign for each stage : 1 : neg ; 0 : pos
  signal y_sign       : std_logic_vector(nbr_comb_stage_g-1 downto 0);
  
  --intermediate rotated outputs of microrotation :
  signal x            : DATA_ARRAY_T(nbr_comb_stage_g downto 0);
  signal y            : DATA_ARRAY_T(nbr_comb_stage_g downto 0);
  
  -- Arctangent reference values (32-bit).
  signal arctan_array : ANGLE_ARRAY_T(nbr_comb_stage_g-1 downto 0);
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  z(0) <= z_i;
  x(0) <= x_i;
  y(0) <= y_i;
  
  gen_stage : for i in 0 to nbr_comb_stage_g-1 generate
  
    --------------------------------------------
    -- Z computation
    --------------------------------------------
    y_sign(i) <= y(i)(data_length_g);
    arctan_array(i) <= "00" & arctan_array_ref(i)(31 downto 31 - angle_length_g + 3) when y_sign(i) = '0'
              else (not("00" & arctan_array_ref(i)(31 downto 31 - angle_length_g + 3)) + '1');
    z(i+1) <= z(i) + arctan_array(i);
  
    --------------------------------------------
    -- Stage of microrotations 
    --------------------------------------------
    microrotation_i : microrotation
      generic map ( data_length_g => data_length_g,
                    stage_g       => i+start_stage_g)
      port map    ( x_i           => x(i),
                    y_i           => y(i),
                    x_o           => x(i+1),
                    y_o           => y(i+1)
      );
  end generate;
      

  --------------------------------------------
  -- Samples the generated outputs
  --------------------------------------------
  sample_out_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      z_o <= (others => '0');
      x_o <= (others => '0');
      y_o <= (others => '0');
    elsif (clk'event and clk = '1') then
      z_o <= z(nbr_comb_stage_g);
      x_o <= x(nbr_comb_stage_g);
      y_o <= y(nbr_comb_stage_g);
    end if;
  end process sample_out_p;
      
end rtl;
