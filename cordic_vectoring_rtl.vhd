

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : CORDIC
--    ,' GoodLuck ,'      RCSfile: cordic_vectoring.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Vectoring CORDIC. This CORDIC computes the angle and the
--               magnitude of a complex input sample.
--               The computation is performed using rotations to align the
--               input sample to with the X axis.
--               This CORDIC is configurable in term of pipelines and
--               number of microratation per clock cycle.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic_vectoring/vhdl/rtl/cordic_vectoring.vhd,v  
--  Log: cordic_vectoring.vhd,v  
-- Revision 1.4  2004/01/26 07:44:05  Dr.F
-- removed mag_o from process.
--
-- Revision 1.3  2004/01/14 13:54:56  Dr.F
-- removed piece of array in sensitivty list due to synopsys limitation.
--
-- Revision 1.2  2003/03/19 17:32:26  Dr.F
-- algorithm changed when the angle is not in [-PI/2;PI/2].
--
-- Revision 1.1  2003/03/17 07:49:59  Dr.F
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
entity cordic_vectoring is
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
end cordic_vectoring;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of cordic_vectoring is

  --------------------------------------------
  -- Constants
  --------------------------------------------
  constant PI_CT       : std_logic_vector(31 downto 0) := "01100100100001111110110101010001";
                       
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
  signal z                : ANGLE_ARRAY_T(nbr_pipe_g downto 0);
  signal z_in_neg         : std_logic_vector(angle_length_g-1 downto 0);
  signal z_match_interval : std_logic_vector(nbr_pipe_g downto 0);
    
  --intermediate rotated outputs of microrotation :
  signal x          : DATA_ARRAY_T(nbr_pipe_g downto 0);
  signal y          : DATA_ARRAY_T(nbr_pipe_g downto 0);
  
  -- sign is added on the last z. 
  signal ext_z_o    : std_logic_vector(angle_length_g-1 downto 0);
  
  -- x and y sign. 0: positive ; 1 : negative
  signal x_sign     : std_logic_vector(nbr_pipe_g-1 downto 0);
  signal y_sign     : std_logic_vector(nbr_pipe_g-1 downto 0);
  
  -- Arctangent reference values (32-bit).
  signal arctan_array_ref : ARRAY_OF_SLV32_T(31 downto 0);
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- initial angle set to 0
  z(0)      <= (others => '0');
  
  -- As the CORDIC algorithm computes angles between -PI/2 and PI/2,
  -- the input vector is negged if x is negative. 
  -- At the end of the CORDIC computation, the angle will be changed 
  -- depending on the x and y initial signs.
  x(0)      <= x_i(data_length_g-1) & x_i when x_i(data_length_g-1) = '0' else
               not(x_i(data_length_g-1) & x_i) + '1';

  y(0)      <= y_i(data_length_g-1) & y_i when x_i(data_length_g-1) = '0' else
               not(y_i(data_length_g-1) & y_i) + '1';

  -- pipeline the signs of the input samples
  sign_p : process(reset_n, clk)
    variable i : integer;
  begin
    if (reset_n = '0') then
      for i in 0 to nbr_pipe_g-1 loop
        x_sign(i) <= '0';
        y_sign(i) <= '0';
      end loop;
    elsif (clk'event and clk = '1') then
        x_sign(0) <= x_i(data_length_g-1);
        y_sign(0) <= y_i(data_length_g-1);
      for i in 1 to nbr_pipe_g-1 loop
        x_sign(i) <= x_sign(i-1);
        y_sign(i) <= y_sign(i-1);
      end loop;
    end if;
  end process sign_p;
  
  
  --------------------------------------------
  -- Pipeline generation.
  -- Each stage generates nbr_comb_stage microrotations.
  --------------------------------------------
  gen_pipe : for i in 0 to nbr_pipe_g-1 generate
  
    comb_stage_vectoring_i : comb_stage_vectoring
      generic map (                                                         
        data_length_g    => data_length_g,
        angle_length_g   => angle_length_g,
        start_stage_g    => i*nbr_combstage_g,
        nbr_comb_stage_g => nbr_combstage_g
      )
      port map (                                                            
        clk      => clk,
        reset_n  => reset_n,
                                                                          
        -- angle with which the input has been rotated before this stage                          
        z_i      => z(i),
                                                                          
        -- inputs to be rotated :                                         
        x_i      => x(i),
        y_i      => y(i),

        -- Arctangent reference table                    
        arctan_array_ref => arctan_array_ref((i+1)*nbr_combstage_g-1 downto i*nbr_combstage_g),
        
        -- angle with which the input has been rotated after this stage                          
        z_o      => z(i+1),
                                                                          
        -- rotated output. They have been rotated of (z_in-z_out) :       
        x_o      => x(i+1),
        y_o      => y(i+1)
      );
  end generate;
  
  --------------------------------------------
  -- outputs
  --------------------------------------------
  mag_o   <= x(nbr_pipe_g);
  ext_z_o <= z(nbr_pipe_g)(angle_length_g-1) & z(nbr_pipe_g)(angle_length_g-1 downto 1);
  output_gen_p : process(x_sign, y_sign, ext_z_o)
  begin
    if (x_sign(nbr_pipe_g-1) = '1') then
      if (y_sign(nbr_pipe_g-1) = '1') then
        -- if the sample is in the 3rd quadrant, the true angle is angle - PI.
        z_o <= ext_z_o - PI_CT(31 downto 31 - angle_length_g + 1);
      else
        -- if the sample is in the 2nd quadrant, the true angle is angle + PI.
        z_o <= ext_z_o + PI_CT(31 downto 31 - angle_length_g + 1);
      end if;
    else
      -- if the sample is in the 1st or 4th quadrant, the computed angle is in [-PI/2; PI/2].
      z_o <= ext_z_o;
    end if;
  end process output_gen_p;
  

  -- reference values for arctan.
  arctan_array_ref(0)  <= "11001001000011111101101010100010";
  arctan_array_ref(1)  <= "01110110101100011001110000010101";
  arctan_array_ref(2)  <= "00111110101101101110101111110010";
  arctan_array_ref(3)  <= "00011111110101011011101010011010";
  arctan_array_ref(4)  <= "00001111111110101010110111011011";
  arctan_array_ref(5)  <= "00000111111111110101010101101110";
  arctan_array_ref(6)  <= "00000011111111111110101010101011";
  arctan_array_ref(7)  <= "00000001111111111111110101010101";
  arctan_array_ref(8)  <= "00000000111111111111111110101010";
  arctan_array_ref(9)  <= "00000000011111111111111111110101";
  arctan_array_ref(10) <= "00000000001111111111111111111110";
  arctan_array_ref(11) <= "00000000000111111111111111111111";
  arctan_array_ref(12) <= "00000000000011111111111111111111";
  arctan_array_ref(13) <= "00000000000001111111111111111111";
  arctan_array_ref(14) <= "00000000000000111111111111111111";
  arctan_array_ref(15) <= "00000000000000011111111111111111";
  arctan_array_ref(16) <= "00000000000000001111111111111111";
  arctan_array_ref(17) <= "00000000000000000111111111111111";
  arctan_array_ref(18) <= "00000000000000000011111111111111";
  arctan_array_ref(19) <= "00000000000000000001111111111111";
  arctan_array_ref(20) <= "00000000000000000000111111111111";
  arctan_array_ref(21) <= "00000000000000000000011111111111";
  arctan_array_ref(22) <= "00000000000000000000001111111111";
  arctan_array_ref(23) <= "00000000000000000000000111111111";
  arctan_array_ref(24) <= "00000000000000000000000011111111";
  arctan_array_ref(25) <= "00000000000000000000000001111111";
  arctan_array_ref(26) <= "00000000000000000000000000111111";
  arctan_array_ref(27) <= "00000000000000000000000000100000";
  arctan_array_ref(28) <= "00000000000000000000000000010000";
  arctan_array_ref(29) <= "00000000000000000000000000001000";
  arctan_array_ref(30) <= "00000000000000000000000000000100";
  arctan_array_ref(31) <= "00000000000000000000000000000010";

end rtl;
