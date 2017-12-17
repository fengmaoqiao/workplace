
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Cordic
--    ,' GoodLuck ,'      RCSfile: shift_adder.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This bloc computes the microrotation as defined in CORDIC
--               algorithm :
--                 x_out = x_in - (1-2*z_sign)*2^(-stage_g)*y_in
--                 y_out = y_in + (1-2*z_sign)*2^(-stage_g)*x_in
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic/vhdl/rtl/shift_adder.vhd,v  
--  Log: shift_adder.vhd,v  
-- Revision 1.3  2002/11/08 13:45:14  Dr.J
-- Removed clk and reset in shift adder
--
-- Revision 1.2  2002/09/16 16:08:26  Dr.J
-- Added Constants for Synopsys
--
-- Revision 1.1  2002/05/21 15:39:30  Dr.J
-- Initial revision
--
--
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_unsigned.all; 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity shift_adder is
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
end shift_adder;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of shift_adder is

  
  --------------------------------------------
  -- Constants
  --------------------------------------------
  constant DATA_LENGTH_G_MINUS_STAGE_G_CT : integer := data_length_g - stage_g;
  
  --------------------------------------------
  -- Signals
  --------------------------------------------
  signal shift_x_in    : std_logic_vector(data_length_g downto 0);
  signal shift_y_in    : std_logic_vector(data_length_g downto 0);
  signal internal_x_in : std_logic_vector(data_length_g downto 0);
  signal internal_y_in : std_logic_vector(data_length_g downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- The inputs are left shifted of stage_g bits (*2^(-stage_g)).
  shift_p : process(x_in, y_in)
  begin
    -- shift_x_in = 2^(-stage_g)*x_in :
    shift_x_in(data_length_g downto DATA_LENGTH_G_MINUS_STAGE_G_CT) <= (others => x_in(data_length_g));
    shift_x_in(DATA_LENGTH_G_MINUS_STAGE_G_CT downto 0) <= x_in(data_length_g downto stage_g);
    -- shift_y_in = 2^(-stage_g)*y_in :
    shift_y_in(data_length_g downto DATA_LENGTH_G_MINUS_STAGE_G_CT) <= (others => y_in(data_length_g));
    shift_y_in(DATA_LENGTH_G_MINUS_STAGE_G_CT downto 0) <= y_in(data_length_g downto stage_g);
  end process shift_p;

  -- shift_x_in and shift_y_in are 2 complemented.
  -- internal_x_in = (1-2*z_sign)*shift_x_in :
  internal_x_in <= shift_x_in when z_sign = '0' else not(shift_x_in) + '1';
  -- internal_y_in = -(1-2*z_sign)*shift_y_in :
  internal_y_in <= shift_y_in when z_sign = '1' else not(shift_y_in) + '1';
  
  -- Output generation
  -- x_out = x_in + internal_y_in :
  x_out <= x_in + internal_y_in;
  -- y_out = y_in + internal_x_in :
  y_out <= y_in + internal_x_in;

end rtl;
