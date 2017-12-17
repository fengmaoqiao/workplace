
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Cordic
--    ,' GoodLuck ,'      RCSfile: cordic_combstage.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block is composed of a microrotation stage . 
--               It produces (x_out,y_out) rotated outputs with the remaining 
--               angle z_out to be rotated.
--               The microrotation stages are performed in a combinational
--               way, without any flip-flop between stages.
-- WARNING : The following signals are multidimensional arraies :
--             z_i, x0_i, y0_i, arctan_array and arctan_array_ref.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic/vhdl/rtl/cordic_combstage.vhd,v  
--  Log: cordic_combstage.vhd,v  
-- Revision 1.4  2003/05/07 13:34:17  Dr.J
-- Added爀nable
--
-- Revision 1.3  2002/11/08 13:44:45  Dr.J
-- Removed clk and reset in shift_adder
--
-- Revision 1.2  2002/06/10 12:58:12  Dr.J
-- Debugged the calculation of the angle
--
-- Revision 1.1  2002/05/21 15:39:03  Dr.J
-- Initial revision
--
--
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_unsigned.all; 

--library cordic_rtl;
library work;
--use cordic_rtl.cordic_pkg.all;
use work.cordic_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity cordic_combstage is
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
end cordic_combstage;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of cordic_combstage is

  --------------------------------------------
  -- Types
  --------------------------------------------
  type DataArray    is array (natural range <>) of 
                           std_logic_vector(data_length_g downto 0);
  type AngleArray   is array (natural range <>) of 
                           std_logic_vector(angle_length_g-1 downto 0);
                                     
  --------------------------------------------
  -- Signals
  --------------------------------------------
  --remaining angle after each microrotation stage
  signal z_i           : AngleArray(nbr_stage_g downto 0);

  -- angle sign for each z_i : 1 : neg ; 0 : pos
  signal z_sign        : std_logic_vector(nbr_stage_g-1 downto 0);
  
  --intermediate rotated outputs of microrotation :
  signal x0_i          : DataArray(nbr_stage_g downto 0);
  signal y0_i          : DataArray(nbr_stage_g downto 0);
  signal x1_i          : DataArray(nbr_stage_g downto 0);
  signal y1_i          : DataArray(nbr_stage_g downto 0);
  signal x2_i          : DataArray(nbr_stage_g downto 0);
  signal y2_i          : DataArray(nbr_stage_g downto 0);
  signal x3_i          : DataArray(nbr_stage_g downto 0);
  signal y3_i          : DataArray(nbr_stage_g downto 0);
  
  -- Arctangent reference values (32-bit).
  signal arctan_array     : AngleArray(nbr_stage_g-1 downto 0);
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  

  --------------------------------------------
  -- Samples the generated outputs and Inputs
  -- connection.
  --------------------------------------------


  z_i(0)  <= z_in;

  x0_i(0) <= x0_in;
  y0_i(0) <= y0_in;

  sample_out_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      z_out <= (others => '0');
      x0_out <= (others => '0');
      y0_out <= (others => '0');
    elsif (clk'event and clk = '1') then
      if enable = '1' then 
        z_out  <= z_i(nbr_stage_g);
        x0_out <= x0_i(nbr_stage_g);
        y0_out <= y0_i(nbr_stage_g);
      end if;  
    end if;
  end process sample_out_p;

  channel_1_g : if nbr_input_g >= 2 generate  
    x1_i(0) <= x1_in;
    y1_i(0) <= y1_in;

    sample_1_out_p : process(reset_n, clk)
    begin
      if (reset_n = '0') then
        x1_out <= (others => '0');
        y1_out <= (others => '0');
      elsif (clk'event and clk = '1') then
        if enable = '1' then 
          x1_out <= x1_i(nbr_stage_g);
          y1_out <= y1_i(nbr_stage_g);
        end if;
      end if;
    end process sample_1_out_p;
  end generate channel_1_g;

  channel_2_g : if nbr_input_g >= 3 generate  
    x2_i(0) <= x2_in;
    y2_i(0) <= y2_in;

    sample_2_out_p : process(reset_n, clk)
    begin
      if (reset_n = '0') then
        x2_out <= (others => '0');
        y2_out <= (others => '0');
      elsif (clk'event and clk = '1') then
        if enable = '1' then 
          x2_out <= x2_i(nbr_stage_g);
          y2_out <= y2_i(nbr_stage_g);
        end if;
      end if;
    end process sample_2_out_p;
  end generate channel_2_g;

  channel_3_g : if nbr_input_g >= 4 generate  
    x3_i(0) <= x3_in;
    y3_i(0) <= y3_in;

    sample_3_out_p : process(reset_n, clk)
    begin
      if (reset_n = '0') then
        x3_out <= (others => '0');
        y3_out <= (others => '0');
      elsif (clk'event and clk = '1') then
        if enable = '1' then 
          x3_out <= x3_i(nbr_stage_g);
          y3_out <= y3_i(nbr_stage_g);
        end if;
      end if;
    end process sample_3_out_p;
  end generate channel_3_g;
  
  gen_stage : for i in 0 to nbr_stage_g-1 generate
  
    --------------------------------------------
    -- Z computation
    --------------------------------------------
    z_sign(i) <= z_i(i)(angle_length_g - 1);
    arctan_array(i) <= "000" & arctan_array_ref(i)(31 downto 31 - angle_length_g + 4) when z_sign(i) = '1'
              else (not("000" & arctan_array_ref(i)(31 downto 31 - angle_length_g + 4)) + '1');
    z_i(i+1) <= z_i(i) + arctan_array(i);
  
    --------------------------------------------
    -- Stage of microrotations 
    --------------------------------------------
    shift_adder_0 : shift_adder
      generic map ( data_length_g => data_length_g,
                    stage_g       => i+start_stage_g)
      port map    ( z_sign        => z_sign(i),
                    x_in          => x0_i(i),
                    y_in          => y0_i(i),
                    x_out         => x0_i(i+1),
                    y_out         => y0_i(i+1)
      );

    shift_adder_1_g : if nbr_input_g >= 2 generate  
      shift_adder_1 : shift_adder
        generic map ( data_length_g => data_length_g,
                      stage_g       => i+start_stage_g)
        port map    ( z_sign        => z_sign(i),
                      x_in          => x1_i(i),
                      y_in          => y1_i(i),
                      x_out         => x1_i(i+1),
                      y_out         => y1_i(i+1)
        );
    end generate shift_adder_1_g;

    shift_adder_2_g : if nbr_input_g >= 3 generate  
      shift_adder_2 : shift_adder
        generic map ( data_length_g => data_length_g,
                      stage_g       => i+start_stage_g)
        port map    ( z_sign        => z_sign(i),
                      x_in          => x2_i(i),
                      y_in          => y2_i(i),
                      x_out         => x2_i(i+1),
                      y_out         => y2_i(i+1)
        );
    end generate shift_adder_2_g;

    shift_adder_3_g : if nbr_input_g >= 4 generate  
      shift_adder_3 : shift_adder
        generic map ( data_length_g => data_length_g,
                      stage_g       => i+start_stage_g)
        port map    ( z_sign        => z_sign(i),
                      x_in          => x3_i(i),
                      y_in          => y3_i(i),
                      x_out         => x3_i(i+1),
                      y_out         => y3_i(i+1)
        );
    end generate shift_adder_3_g;
      
  end generate gen_stage;

      

end rtl;
