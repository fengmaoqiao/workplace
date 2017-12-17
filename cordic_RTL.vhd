
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Cordic
--    ,' GoodLuck ,'      RCSfile: cordic.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.10   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Coordinate Rotation on a Digital Computer
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic/vhdl/rtl/cordic.vhd,v  
--  Log: cordic.vhd,v  
-- Revision 1.10  2003/07/08 13:50:58  Dr.C
-- Updated sensitivity lists
--
-- Revision 1.9  2003/07/07 08:27:22  Dr.C
-- Increased output size and debugged pi value for scaling mode 1
--
-- Revision 1.8  2003/05/07 13:36:53  Dr.J
-- Added enable on the output
--
-- Revision 1.7  2003/05/07 13:34:08  Dr.J
-- Added enable
--
-- Revision 1.6  2003/05/05 08:59:33  Dr.C
-- Debugged arctan table.
--
-- Revision 1.5  2002/09/16 16:08:05  Dr.J
-- Added constants for Synopsys
--
-- Revision 1.4  2002/08/01 09:06:56  Dr.J
-- Added description
--
-- Revision 1.3  2002/06/11 09:20:26  Dr.F
-- added 1 bit in z_match_interval.
--
-- Revision 1.2  2002/06/10 12:55:35  Dr.J
-- Changed the size of the outputs
--
-- Revision 1.1  2002/05/21 15:38:57  Dr.J
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all; 

--library cordic_rtl;
library work;
--use cordic_rtl.cordic_pkg.all;
use work.cordic_pkg.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity cordic is
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

end cordic;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture RTL of cordic is

  --------------------------------------------
  -- Constants
  --------------------------------------------
  constant PI_DIV_2_CT : std_logic_vector(31 downto 0) := "00110010010000111111011010101000";
  constant PI_CT       : std_logic_vector(31 downto 0) := "01100100100001111110110101010001";
  constant PI_SCALED_CT       : std_logic_vector(30 downto 0) := (others => '0');
  constant MAX_INPUT_CT        : integer := 4;
  
  constant N_MICRO_ROTATION_CT : integer := nbr_combstage_g * nbr_pipe_g + 1;

  constant NBR_PIPE_G_PLUS_1_CT : integer := nbr_pipe_g+1;

  ------------------------------------------------------------------------------
  -- Types   
  ------------------------------------------------------------------------------
  type DataArray    is array (natural range <>) of 
                           std_logic_vector(data_length_g+1 downto 0);
  type AngleArray   is array (natural range <>) of 
                           std_logic_vector(angle_length_g-1 downto 0);

  --------------------------------------------
  -- Signals
  --------------------------------------------
  signal z_i_zero         : std_logic_vector(angle_length_g downto 0);

 
  signal z_in_ext         : std_logic_vector(angle_length_g + 1 downto 0);
  signal z_i_ext          : std_logic_vector(angle_length_g + 1 downto 0);

  signal z_i              : AngleArray(N_MICRO_ROTATION_CT - 1 downto 0);
  signal z_i_next         : AngleArray(N_MICRO_ROTATION_CT - 1 downto 0);
  signal z_in_neg         : std_logic_vector(angle_length_g-1 downto 0);
  signal z_match_interval : std_logic_vector(nbr_pipe_g+1 downto 0);
  
    -- angle sign for each z_i : 1 : neg ; 0 : pos
  signal z_sign           : std_logic_vector(N_MICRO_ROTATION_CT-1 downto 0);
  signal z_sign_next      : std_logic_vector(N_MICRO_ROTATION_CT-1 downto 0);

  -- Arctangent reference values (32-bit).
  signal arctan_array     : AngleArray(N_MICRO_ROTATION_CT - 1 downto 0);

  --intermediate rotated outputs of microrotation :
  signal x0_i          : DataArray(nbr_pipe_g downto 0);
  signal y0_i          : DataArray(nbr_pipe_g downto 0);
  signal x1_i          : DataArray(nbr_pipe_g downto 0);
  signal y1_i          : DataArray(nbr_pipe_g downto 0);
  signal x2_i          : DataArray(nbr_pipe_g downto 0);
  signal y2_i          : DataArray(nbr_pipe_g downto 0);
  signal x3_i          : DataArray(nbr_pipe_g downto 0);
  signal y3_i          : DataArray(nbr_pipe_g downto 0);
  

  -- Arctangent reference values (32-bit).
  signal arctan_array_ref : ArrayOfSLV32(31 downto 0);

  signal load_new_value   : std_logic;
  

  signal pi : std_logic_vector(31 downto 0); -- Pi value according to scale mode


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  pi      <= PI_CT when scaling_g = 0 else '1' & PI_SCALED_CT;
  
  x0_i(0) <= sxt(x0_in,data_length_g+2);
  y0_i(0) <= sxt(y0_in,data_length_g+2);
  
  input_1_g : if nbr_input_g >= 2 generate  
    x1_i(0) <= sxt(x1_in,data_length_g+2);
    y1_i(0) <= sxt(y1_in,data_length_g+2);
  end generate input_1_g;

  input_2_g : if nbr_input_g >= 3 generate  
    x2_i(0) <= sxt(x2_in,data_length_g+2);
    y2_i(0) <= sxt(y2_in,data_length_g+2);
  end generate input_2_g;

  input_3_g : if nbr_input_g >= 4 generate  
    x3_i(0) <= sxt(x3_in,data_length_g+2);
    y3_i(0) <= sxt(y3_in,data_length_g+2);
  end generate input_3_g;
    
  -- z_in must be within [-PI/2 ; +PI/2] interval. if z_in is within
  -- [PI/2 ; 3PI/2], z_in - PI will be used and the computed coordinate
  -- will be inverted.
  z_in_neg <= not(z_in) + '1';
  z_match_interval_p : process(pi, z_in, z_in_neg)
  begin
    if ((z_in > ('0'&pi(31 downto 31 - angle_length_g + 2)) and z_in(angle_length_g - 1) = '0')) or
       ((z_in_neg > ('0'&pi(31 downto 31 - angle_length_g + 2)) and z_in(angle_length_g - 1) = '1')) then
      z_match_interval(0) <= '0';
    else
      z_match_interval(0) <= '1';
    end if;
  end process z_match_interval_p;

  z_p : process(clk, reset_n)
  begin
    if (reset_n = '0') then
      z_i(0) <= (others => '0');
    elsif (clk'event and clk = '1') then
      if enable='1' then
        if (z_match_interval(0) = '1') then
          z_i(0) <= z_in;
        else
          if (z_in(angle_length_g - 1) = '0') then
            z_i(0) <= (z_in) - pi(31 downto 31 - angle_length_g + 1);
          else
            z_i(0) <= (z_in) + pi(31 downto 31 - angle_length_g + 1);
          end if;
        end if;
      end if;
    end if;
  end process z_p;

  z_in_ext <= z_in(angle_length_g - 1) & z_in(angle_length_g - 1) & z_in;
  z_i_ext <= (z_in_ext) + ('0' & '0' & pi(31 downto 31 - angle_length_g + 1));

  cycle_count_p : process(clk, reset_n)
  variable cycle_count : std_logic_vector(3 downto 0);
  begin
    if (reset_n = '0') then
      cycle_count := "0000";
      load_new_value <= '1';
    elsif (clk'event and clk = '1') then
      if enable='1' then
        cycle_count := cycle_count + '1';
      end if;
    end if;
  end process cycle_count_p;

  gen_cordic : for n_pipe in 0 to nbr_pipe_g-1 generate
  
    cordic_combstage_1 : cordic_combstage
      generic map (                                                         
        data_length_g  => data_length_g+1,
        angle_length_g => angle_length_g,
        start_stage_g  => n_pipe * nbr_combstage_g,
        nbr_stage_g    => nbr_combstage_g,
        nbr_input_g    => nbr_input_g
      )
      port map (                                                            
        clk      => clk,
        reset_n  => reset_n,
        enable   => enable,                                                                  
        -- angle with which the inputs must be rotated :                          
        z_in     => z_i(n_pipe),
                                                                          
        -- inputs to be rotated :                                         
        x0_in    => x0_i(n_pipe),
        y0_in    => y0_i(n_pipe),
        x1_in    => x1_i(n_pipe),
        y1_in    => y1_i(n_pipe),
        x2_in    => x2_i(n_pipe),
        y2_in    => y2_i(n_pipe),
        x3_in    => x3_i(n_pipe),
        y3_in    => y3_i(n_pipe),

        -- Arctangent reference table                    
        arctan_array_ref => arctan_array_ref((n_pipe+1)*nbr_combstage_g-1 downto n_pipe*nbr_combstage_g),
        
        -- remaining angle with which inputs have not been rotated :      
        z_out    => z_i(n_pipe+1),
                                                                          
        -- rotated output. They have been rotated of (z_in - z_out) :       
        x0_out   => x0_i(n_pipe+1),
        y0_out   => y0_i(n_pipe+1),
        x1_out   => x1_i(n_pipe+1),
        y1_out   => y1_i(n_pipe+1),
        x2_out   => x2_i(n_pipe+1),
        y2_out   => y2_i(n_pipe+1),
        x3_out   => x3_i(n_pipe+1),
        y3_out   => y3_i(n_pipe+1)
      );

  end generate gen_cordic;

    
  z_match_gen_p : process(clk, reset_n)
  begin
    if (reset_n = '0') then
      z_match_interval(NBR_PIPE_G_PLUS_1_CT downto 1) <= (others => '0');
    elsif (clk'event and clk = '1') then
      if enable='1' then
        z_match_interval(NBR_PIPE_G_PLUS_1_CT downto 1) <= 
                      z_match_interval(nbr_pipe_g downto 0);
      end if;
    end if;
  end process z_match_gen_p;




  --------------------------------------------
  -- Outputs
  --------------------------------------------
    
  output_0_gen_p : process(clk, reset_n)
  begin
    if (reset_n = '0') then
      x0_out <= (others => '0');
      y0_out <= (others => '0');
    elsif (clk'event and clk = '1') then
      if enable='1' then
        if (z_match_interval(nbr_pipe_g+1) = '1') then
          x0_out <= x0_i(nbr_pipe_g);
          y0_out <= y0_i(nbr_pipe_g);
        else
          x0_out <= not(x0_i(nbr_pipe_g)) + '1';
          y0_out <= not(y0_i(nbr_pipe_g)) + '1';
        end if;  
      end if;  
    end if;
  end process output_0_gen_p;


  output_1_g : if nbr_input_g >= 2 generate  

    output_1_gen_p : process(clk, reset_n)
    begin
      if (reset_n = '0') then
        x1_out <= (others => '0');
        y1_out <= (others => '0');
      elsif (clk'event and clk = '1') then
        if enable='1' then
          if (z_match_interval(nbr_pipe_g+1) = '1') then
            x1_out <= x1_i(nbr_pipe_g);
            y1_out <= y1_i(nbr_pipe_g);
          else
            x1_out <= not(x1_i(nbr_pipe_g)) + '1';
            y1_out <= not(y1_i(nbr_pipe_g)) + '1';
          end if;  
        end if;  
      end if;
    end process output_1_gen_p;

  end generate output_1_g;

  output_2_g : if nbr_input_g >= 3 generate  

    output_2_gen_p : process(clk, reset_n)
    begin
      if (reset_n = '0') then
        x2_out <= (others => '0');
        y2_out <= (others => '0');
      elsif (clk'event and clk = '1') then
        if enable='1' then
          if (z_match_interval(nbr_pipe_g+1) = '1') then
            x2_out <= x2_i(nbr_pipe_g);
            y2_out <= y2_i(nbr_pipe_g);
          else
            x2_out <= not(x2_i(nbr_pipe_g)) + '1';
            y2_out <= not(y2_i(nbr_pipe_g)) + '1';
          end if;  
        end if;  
      end if;
    end process output_2_gen_p;

  end generate output_2_g;

  output_3_g : if nbr_input_g >= 4 generate  

    output_3_gen_p : process(clk, reset_n)
    begin
      if (reset_n = '0') then
        x3_out <= (others => '0');
        y3_out <= (others => '0');
      elsif (clk'event and clk = '1') then
        if enable='1' then
          if (z_match_interval(nbr_pipe_g+1) = '1') then
            x3_out <= x3_i(nbr_pipe_g);
            y3_out <= y3_i(nbr_pipe_g);
          else
            x3_out <= not(x3_i(nbr_pipe_g)) + '1';
            y3_out <= not(y3_i(nbr_pipe_g)) + '1';
          end if;  
        end if;  
      end if;
    end process output_3_gen_p;

    end generate output_3_g;
    


  -----------------------------------------------------------------------------
  -- NO SCALING
  -----------------------------------------------------------------------------
  no_scaling_gen: if scaling_g = 0 generate
    -- reference values for arctan.
    arctan_array_ref(0)  <= "11001001000011111101101010100010";
    arctan_array_ref(1)  <= "01110110101100011001110000010110";
    arctan_array_ref(2)  <= "00111110101101101110101111110010";
    arctan_array_ref(3)  <= "00011111110101011011101010011011";
    arctan_array_ref(4)  <= "00001111111110101010110111011100";
    arctan_array_ref(5)  <= "00000111111111110101010101101111";
    arctan_array_ref(6)  <= "00000011111111111110101010101011";
    arctan_array_ref(7)  <= "00000001111111111111110101010101";
    arctan_array_ref(8)  <= "00000000111111111111111110101011";
    arctan_array_ref(9)  <= "00000000011111111111111111110101";
    arctan_array_ref(10) <= "00000000001111111111111111111111";
    arctan_array_ref(11) <= "00000000001000000000000000000000";
    arctan_array_ref(12) <= "00000000000100000000000000000000";
    arctan_array_ref(13) <= "00000000000010000000000000000000";
    arctan_array_ref(14) <= "00000000000001000000000000000000";
    arctan_array_ref(15) <= "00000000000000100000000000000000";
    arctan_array_ref(16) <= "00000000000000010000000000000000";
    arctan_array_ref(17) <= "00000000000000001000000000000000";
    arctan_array_ref(18) <= "00000000000000000100000000000000";
    arctan_array_ref(19) <= "00000000000000000010000000000000";
    arctan_array_ref(20) <= "00000000000000000001000000000000";
    arctan_array_ref(21) <= "00000000000000000000100000000000";
    arctan_array_ref(22) <= "00000000000000000000010000000000";
    arctan_array_ref(23) <= "00000000000000000000001000000000";
    arctan_array_ref(24) <= "00000000000000000000000100000000";
    arctan_array_ref(25) <= "00000000000000000000000010000000";
    arctan_array_ref(26) <= "00000000000000000000000001000000";
    arctan_array_ref(27) <= "00000000000000000000000000100000";
    arctan_array_ref(28) <= "00000000000000000000000000010000";
    arctan_array_ref(29) <= "00000000000000000000000000001000";
    arctan_array_ref(30) <= "00000000000000000000000000000100";
    arctan_array_ref(31) <= "00000000000000000000000000000010";
  end generate no_scaling_gen;


  -----------------------------------------------------------------------------
  -- SCALING = pi/4 => 111111111111111  
  -----------------------------------------------------------------------------
  scaling_gen: if scaling_g = 1 generate
    -- reference values for arctan.
    arctan_array_ref(0)  <= "11111111111111111111111111111111";
    arctan_array_ref(1)  <= "10010111001000000010100011101101";
    arctan_array_ref(2)  <= "01001111110110011100001011011011";
    arctan_array_ref(3)  <= "00101000100010001000111010100001";
    arctan_array_ref(4)  <= "00010100010110000110101000011000";
    arctan_array_ref(5)  <= "00001010001011101011111100001011";
    arctan_array_ref(6)  <= "00000101000101111011000011110011";
    arctan_array_ref(7)  <= "00000010100010111110001010101001";
    arctan_array_ref(8)  <= "00000001010001011111001010011010";
    arctan_array_ref(9)  <= "00000000101000101111100101110110";
    arctan_array_ref(10) <= "00000000010100010111110011000000";
    arctan_array_ref(11) <= "00000000001010001011111001100001";
    arctan_array_ref(12) <= "00000000000101000101111100110000";
    arctan_array_ref(13) <= "00000000000010100010111110011000";
    arctan_array_ref(14) <= "00000000000001010001011111001100";
    arctan_array_ref(15) <= "00000000000000101000101111100110";
    arctan_array_ref(16) <= "00000000000000010100010111110011";
    arctan_array_ref(17) <= "00000000000000001010001011111010";
    arctan_array_ref(18) <= "00000000000000000101000101111101";
    arctan_array_ref(19) <= "00000000000000000010100010111110";
    arctan_array_ref(20) <= "00000000000000000001010001011111";
    arctan_array_ref(21) <= "00000000000000000000101000110000";
    arctan_array_ref(22) <= "00000000000000000000010100011000";
    arctan_array_ref(23) <= "00000000000000000000001010001100";
    arctan_array_ref(24) <= "00000000000000000000000101000110";
    arctan_array_ref(25) <= "00000000000000000000000010100011";
    arctan_array_ref(26) <= "00000000000000000000000001010001";
    arctan_array_ref(27) <= "00000000000000000000000000101001";
    arctan_array_ref(28) <= "00000000000000000000000000010100";
    arctan_array_ref(29) <= "00000000000000000000000000001010";
    arctan_array_ref(30) <= "00000000000000000000000000000101";
    arctan_array_ref(31) <= "00000000000000000000000000000011";
  end generate scaling_gen;


end RTL;
