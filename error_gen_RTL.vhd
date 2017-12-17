
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: error_gen.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.8   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Error generator for phase and carrier offset estimation.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/phase_estimation/vhdl/rtl/error_gen.vhd,v  
--  Log: error_gen.vhd,v  
-- Revision 1.8  2003/04/03 13:48:19  Dr.B
-- scaling_g added.
--
-- Revision 1.7  2003/03/10 17:24:47  Dr.B
-- phase_estimation_pkg added.
--
-- Revision 1.6  2003/03/10 17:05:59  Dr.B
-- remove call of cordic_vect_pkg.
--
-- Revision 1.5  2002/10/28 10:39:44  Dr.C
-- Changed library name
--
-- Revision 1.4  2002/07/31 07:58:05  Dr.J
-- beautified.
--
-- Revision 1.3  2002/07/11 12:24:21  Dr.J
-- Changed the data size
--
-- Revision 1.2  2002/06/10 13:15:02  Dr.J
-- Removed the modulo PI
--
-- Revision 1.1  2002/03/28 12:42:09  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.std_logic_unsigned.all;  
 
--library phase_estimation_rtl;
library work;
--use phase_estimation_rtl.phase_estimation_pkg.all;
use work.phase_estimation_pkg.all;

--library cordic_vect_rtl;
library work;
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity error_gen is
  generic (
    datasize_g  : integer := 28;-- Max value is 28.
    errorsize_g : integer := 28 -- Max value is 28.
  );
  port (
    -- clock and reset.
    clk          : in  std_logic;                   
    reset_n      : in  std_logic;    
    --
    symbol_sync  : in  std_logic; -- Symbol synchronization pulse.
    -- Demodulated datain (real and im).
    data_i       : in  std_logic_vector(datasize_g-1 downto 0); 
    data_q       : in  std_logic_vector(datasize_g-1 downto 0);
    -- Demapped data.
    demap_data   : in  std_logic_vector(1 downto 0);         
    enable_error : in  std_logic;    
    --
    -- Error detected.
    phase_error  : out std_logic_vector(errorsize_g-1 downto 0); 
    -- Error ready.
    error_ready  : out std_logic                             
  );

end error_gen;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of error_gen is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for multiplication of demodulated data with demapped data conjugate
  signal neg_data_i    : std_logic_vector(datasize_g-1 downto 0); -- (- data_i).
  signal neg_data_q    : std_logic_vector(datasize_g-1 downto 0); -- (- data_q).
  -- Detected error, cartesian coordonates.
  signal error_cart_i  : std_logic_vector(datasize_g-1 downto 0); -- real part.
  signal error_cart_q  : std_logic_vector(datasize_g-1 downto 0); -- Imaginary part
 
  signal phase_error_o : std_logic_vector(errorsize_g-1 downto 0); -- Error detected.
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- error_cart = input data * demap_data conjugate.
  neg_data_i <= not(data_i) + '1';
  neg_data_q <= not(data_q) + '1';
  
  with demap_data select
    error_cart_i <=
      data_i      when "00",
      data_q      when "01",
      neg_data_q  when "10",
      neg_data_i  when others;

  with demap_data select
    error_cart_q <=
      data_q      when "00",
      neg_data_i  when "01",
      data_i      when "10",
      neg_data_q  when others;
           
                  
  -- Block for cordic algorithm: the angle output belongs to [-pi/2, pi/2].
  cordic_vect_1 : cordic_vect
    generic map (
      datasize_g          =>  datasize_g,
      errorsize_g         =>  errorsize_g,
      scaling_g           =>  0 -- no scaling needed
      
      )
    port map (
      -- clock and reset.
      clk                 => clk,
      reset_n             => reset_n,
      --
      load                => symbol_sync,  -- Load input values.
      x_in                => error_cart_i, -- Real part in.
      y_in                => error_cart_q, -- Imaginary part in.
      --
      angle_out           => phase_error_o,  -- Angle out.
      cordic_ready        => error_ready   -- Angle ready.
      );
      
      
  phase_error <= phase_error_o when enable_error='1' else (others=> '0');
    
end RTL;
