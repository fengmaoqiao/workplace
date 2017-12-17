
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: cordic_vect.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.14   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Cordic algoritm for cartesian to polar conversion,
--               used to get the angle from a complex value.
--               Input must be between (-pi/2,pi/2)
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic_vect/vhdl/rtl/cordic_vect.vhd,v  
--  Log: cordic_vect.vhd,v  
-- Revision 1.14  2004/08/24 15:48:47  arisse
-- Added globals for test purpose.
--
-- Revision 1.13  2003/06/30 15:43:08  Dr.C
-- Modified to be synopsys compliant
--
-- Revision 1.12  2003/06/27 14:26:00  Dr.B
-- saturate output on scaled mode.
--
-- Revision 1.11  2003/06/24 13:42:58  Dr.B
-- xn : signed => unsigned for getting 1 bit of precision and avoiding overflo
--
-- Revision 1.10  2003/04/17 14:35:19  Dr.B
-- index continue counting until data_ready (included).
--
-- Revision 1.9  2003/04/03 13:43:03  Dr.B
-- add scaling_g generic.
--
-- Revision 1.8  2003/03/19 08:39:27  Dr.B
-- when datasize + 1 < errorsize, datasize + 1 iterations.
--
-- Revision 1.7  2003/03/11 15:31:14  Dr.B
-- angle_out = 0 only when x_in/y_in=0 and load=1 (memo).
--
-- Revision 1.6  2002/12/13 18:33:01  Dr.J
-- Changed index to be checked by the formal verification tool
--
-- Revision 1.5  2002/10/28 10:01:58  Dr.C
-- Changed library name
--
-- Revision 1.4  2002/07/11 12:24:05  Dr.J
-- Changed the data size
--
-- Revision 1.3  2002/06/10 13:13:43  Dr.J
-- Updated the angle size
--
-- Revision 1.2  2002/05/02 07:37:28  Dr.A
-- Added work around for Synopsys synthesis.
--
-- Revision 1.1  2002/03/28 12:42:00  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
--library cordic_vect_rtl;
library work;
--use cordic_vect_rtl.cordic_vect_pkg.all;
use work.cordic_vect_pkg.all;
 
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity cordic_vect is
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

end cordic_vect;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of cordic_vect is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant ZEROS_CT : std_logic_vector(datasize_g downto 0) := (others => '0');
  constant ONES_CT  : std_logic_vector(datasize_g downto 0) := (others => '1');
  -- Part of 001111111...  = pi/2 scaled
  constant PI2_SCALED_CT : std_logic_vector(errorsize_g-2 downto 0) := (others =>'1');
  -- Part of 110000000...  = - pi/2 scaled
  constant MPI2_SCALED_CT : std_logic_vector(errorsize_g-2 downto 0) := (others =>'0');
  

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type ArrayOfSLVdsize is array (natural range <>) of 
                                     std_logic_vector(datasize_g downto 0);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- arctan value from look-up table.
  signal arctan          : std_logic_vector(errorsize_g-1 downto 0);
  -- arctan value extended to align comas with z_n data.
  signal arctan_ext      : std_logic_vector(errorsize_g downto 0);
  -- The index value is the current step n.
  signal index           : std_logic_vector(4 downto 0);
  signal index_int       : integer range datasize_g downto 0;
  -- x, y and z values at time n and n+1.
  signal x_n             : std_logic_vector(datasize_g downto 0);
  signal y_n             : std_logic_vector(datasize_g downto 0);
  signal x_n1            : std_logic_vector(datasize_g downto 0);
  signal y_n1            : std_logic_vector(datasize_g downto 0);
  signal z_n             : std_logic_vector(errorsize_g downto 0); 
  signal z_n1            : std_logic_vector(errorsize_g downto 0); 
  signal z_n1_sat        : std_logic_vector(errorsize_g downto 0); 
  signal s_n             : std_logic; -- sign of z_n.
  -- x, y and z steps from time n to time n+1.
  signal xn_step         : std_logic_vector(datasize_g downto 0); 
  signal yn_step         : std_logic_vector(datasize_g downto 0); 
  signal zn_step         : std_logic_vector(errorsize_g downto 0); 
  -- x and y values shifted of n bits.
  signal xn_shift        : std_logic_vector(datasize_g downto 0); 
  signal yn_shift        : std_logic_vector(datasize_g downto 0); 
  signal xn_shift_array  : ArrayOfSLVdsize(datasize_g downto 0); 
  signal yn_shift_array  : ArrayOfSLVdsize(datasize_g downto 0); 

  signal angle_ready     : std_logic;
  signal angle_ready_ff  : std_logic;

  -- Signals for Synopsys work around (HDL-123)
  signal temp_syn_y            : std_logic_vector(datasize_g downto 0);

  -- Define the min of datasize_g/errorsize_g
  signal min_size              : integer;

  -- Memorize null x_in and y_in
  signal input_eq_zero : std_logic;

  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- Result Saturation
  -- When the cordic is scaled, there is a risk of saturation, with low value
  -- at pi/2, (eg :  [0,13] can give 99 deg). If it occurs, the result is saturated
  -- at 90 deg(-1) , which is more accurate.
  sat_scaled_gen: if scaling_g = 1 generate
    z_n1_sat <= "00" & PI2_SCALED_CT when z_n1(z_n1'high) = '0' and z_n1(z_n1'high-1) = '1'-- more than  90 deg => 90 deg
           else "11" &MPI2_SCALED_CT when z_n1(z_n1'high) = '1' and z_n1(z_n1'high-1) = '0'-- less than -90 deg => -90 deg
           else z_n1;   
  end generate sat_scaled_gen;

  no_sat_gen: if scaling_g = 0 generate
    z_n1_sat <= z_n1;   
  end generate no_sat_gen;

  
  -- Assign output port.
  -- angle(0, 0) = 0 for compatibility with matlab simulations.
  -- can be removed
  output_p: process(input_eq_zero, z_n1_sat)
  begin
    if input_eq_zero = '1' then
      angle_out <= (others => '0');
    else
      angle_out <= z_n1_sat(errorsize_g-1 downto 0);
    end if;
  end process output_p;


  
  -- Define the min of datasize_g/errorsize_g, which will be the nb of
  -- iterations. Indeed, no need to iterate more, when errorsize_g < datasize_g,
  -- as only zeros are added during the last iterations.
  min_size <= datasize_g when datasize_g  < errorsize_g else errorsize_g; 
  
  -- This process increases the index from 0 to dsize_g-1.
  -- The value in the index is the iteration number ('n').
  control_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      index_int      <= 0;
      angle_ready    <= '0';
      angle_ready_ff <= '0';
    elsif clk'event and clk = '1' then
      angle_ready_ff <= angle_ready;

      if load = '1' then              -- Reset index when a new value is loaded.
        angle_ready    <= '0';
        index_int      <= 0;       
      else
        if (index_int = min_size - 1) then
          angle_ready <= '1';
        end if;
        if (index_int <= min_size - 1) then
          index_int <= index_int + 1;  -- Increase index from 0 to min_size.          
        end if;
      end if;
    end if;
  end process control_p;
  cordic_ready <= angle_ready and not angle_ready_ff;

  -- Remaining angle sign, to determine direction of next microrotation.
  s_n <= y_n(y_n'high);
  
  -- Extend sign bit of arctan look-up table value.
  arctan_ext <=  "000" & arctan(errorsize_g-1 downto 2);
  
  -- Calculate next angle microrotation:
  --   z_n1 = z_n - s_n*arctan(2^-n)  with  s_n = -1  if z_n <  0 
  --                                               1  if z_n >= 0
  with s_n select
    zn_step <=
      arctan_ext             when '0',
      not(arctan_ext) + '1'  when others;
  z_n1 <= z_n + zn_step;

  -- Accu: load input value or store microrotation result.
  accu_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      x_n <= (others => '0');
      y_n <= (others => '0');
      z_n <= (others => '0');
      input_eq_zero <= '0';
    elsif clk'event and clk = '1' then
      if load = '1' then
        -- Load angle init value.
        x_n <= '0' & x_in;
        y_n <= sxt(y_in,datasize_g+1);
        z_n <= (others => '0');
        -- Memorize inputs eq to zero
        if x_in = ZEROS_CT(datasize_g-1 downto 0)
        and y_in = ZEROS_CT(datasize_g-1 downto 0) then
          input_eq_zero <= '1';
        else
          input_eq_zero <= '0';
        end if;

      else                             -- Store microrotation result.
        x_n <= x_n1;
        y_n <= y_n1;
        z_n <= z_n1;                   -- Angle microrotation.
      end if;    
    end if;
  end process accu_p;
  

  -- Microrotation to calculate x_n1 uses the value yn_shift = y_n*2^-n.
  -- The value n is stored in the index signal.
  shifty_p: process(index_int, yn_shift_array)
  begin
    yn_shift <= yn_shift_array(index_int);
  end process shifty_p;


  -- Microrotation to calculate y_n1 uses the value xn_shift = x_n*2^-n.
  -- The value n is stored in the index signal.
  shiftx_p: process(index_int, xn_shift_array)
  begin
    xn_shift <= xn_shift_array(index_int);
  end process shiftx_p;


  -- Calculate next X value:
  -- x_n1 = x_n - s_n*(2^-n)*y_n.
  with s_n select
    xn_step <=
      yn_shift             when '0',  
      not(yn_shift) + '1'  when others;
  x_n1 <= x_n + xn_step;
      
  -- Calculate next Y value:
  -- y_n1 = y_n + s_n*(2^-n)*x_n.
  with s_n select
    yn_step <=
      xn_shift             when '1',
      not(xn_shift) + '1'  when others;
  y_n1 <= y_n + yn_step;


  xn_shift_array(0) <=  x_n;
  yn_shift_array(0) <=  y_n;

  -- Use temp_syn signals for Synopsys work-around.
  temp_syn_y <= (others => y_n(datasize_g));
  array_gen: for i in 1 to datasize_g generate
  -- xn is always positive - MSB to add will always be 0 .
    xn_shift_array(i)(datasize_g downto datasize_g-i+1) <= ZEROS_CT(datasize_g downto datasize_g-i+1);
    xn_shift_array(i)(datasize_g-i downto 0) <=  x_n(datasize_g downto i);

  --  yn_shift_array(i)(datasize_g downto datasize_g-i+1) <= (others => y_n(datasize_g));
    yn_shift_array(i)(datasize_g downto datasize_g-i+1) <= temp_syn_y(datasize_g downto datasize_g-i+1);
    yn_shift_array(i)(datasize_g-i downto 0) <=  y_n(datasize_g downto i);
  end generate array_gen;
   
  ------------------------------------------------------------------------------
  -- Port map
  ------------------------------------------------------------------------------
  -- conv index_into into std_logic_vector
  index <= conv_std_logic_vector(index_int,5);
  arctan_lut_1 : arctan_lut
    generic map (
      dsize_g    => errorsize_g, -- To align comas.
      scaling_g  => scaling_g -- 1:Perform scaling (pi/2 = 2^errosize_g=~ 01111....) 
      )
    port map (
      index   => index,
      arctan  => arctan
      );

------------------------------------------------------------------------------
-- Global Signals for test
------------------------------------------------------------------------------
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  global_gen : if datasize_g=14 generate
--  x_n_gbl <= x_n;
--  y_n_gbl <= y_n;
--  end generate global_gen;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on

end RTL;
