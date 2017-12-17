
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: phase_estimation_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.14   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for phase_estimation.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/phase_estimation/vhdl/rtl/phase_estimation_pkg.vhd,v  
--  Log: phase_estimation_pkg.vhd,v  
-- Revision 1.14  2005/01/24 14:18:58  arisse
-- #BugId:624#
-- Added status signal for registers.
--
-- Revision 1.13  2004/06/14 14:06:05  arisse
-- Changed PRECOMP_PSI_MAX_CT.
--
-- Revision 1.12  2003/04/03 13:48:54  Dr.B
-- scaling_g added.
--
-- Revision 1.11  2002/10/29 09:11:15  Dr.A
-- Added components for cordic_vect files.
--
-- Revision 1.10  2002/10/28 10:40:09  Dr.C
-- Removed cordic and arctan_lut
--
-- Revision 1.9  2002/10/15 15:51:54  Dr.J
-- Port map of the filter updated
--
-- Revision 1.8  2002/08/14 18:12:49  Dr.J
-- Added tau output
--
-- Revision 1.7  2002/07/31 08:02:13  Dr.J
-- Renamed omega_load by precom_enable
--
-- Revision 1.6  2002/07/11 12:25:04  Dr.J
-- changed the data size
--
-- Revision 1.5  2002/06/28 16:13:42  Dr.J
-- Updated with sigma
--
-- Revision 1.4  2002/06/10 13:17:27  Dr.J
-- Updated portmap
--
-- Revision 1.3  2002/05/22 08:34:13  Dr.J
-- Added omega
--
-- Revision 1.2  2002/03/29 13:15:37  Dr.A
-- Added symbol_sync port on filter.
--
-- Revision 1.1  2002/03/28 12:42:52  Dr.A
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
package phase_estimation_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/cordic_vect/vhdl/rtl/arctan_lut.vhd
----------------------
  component arctan_lut
  generic (
    dsize_g       : integer := 32;                    -- max value = 32.
    scaling_g     : integer := 0   -- 1:Use all the amplitude (pi/2 = 2^errosize_g=~ 01111....) 
  );                               -- (-pi/2 = -2^errosize_g= 100000....) 
  port (
    index   : in  std_logic_vector(4 downto 0); -- i value.
    arctan  : out std_logic_vector(dsize_g-1 downto 0)
  );
 

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/cordic_vect/vhdl/rtl/cordic_vect.vhd
----------------------
  component cordic_vect
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

  end component;


----------------------
-- File: data_shift.vhd
----------------------
  component data_shift
  generic (
    dsize_g : integer := 30 -- Data size
  );
  port (
    shift_reg      : in  std_logic_vector(3 downto 0);
    data_in        : in  std_logic_vector(dsize_g-1 downto 0);
    --
    shifted_data   : out std_logic_vector(dsize_g+14 downto 0)
  );

  end component;


----------------------
-- File: error_gen.vhd
----------------------
  component error_gen
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

  end component;


----------------------
-- File: filter.vhd
----------------------
  component filter
  generic (
    esize_g  : integer := 13; -- size of error (must >= dsize_g).
    phisize_g    : integer := 15; -- size of angle phi
    omegasize_g  : integer := 12; -- size of angle omega
    sigmasize_g  : integer := 10; -- size of angle sigma
    tausize_g    : integer := 19  -- size of angle tau
  );
  port (
    -- clock and reset.
    clk            : in  std_logic;                   
    reset_n        : in  std_logic;    
    --
    load           : in  std_logic; -- Filter synchronization.
    precomp_enable : in  std_logic; -- Reload the omega accumulator
    interpolation_enable : in  std_logic; -- load the tau accumulator
    enable_error   : in std_logic; -- Enable the compensation.
    symbol_sync    : in  std_logic; -- Symbol synchronization.
    mod_type       : in  std_logic; -- Modulation type: '0' for DSSS, 
                                    -- '1' for CCK.
    phase_error    : in  std_logic_vector(esize_g-1 downto 0);-- Error
    rho            : in  std_logic_vector(3 downto 0); -- rho parameter value.
    mu             : in  std_logic_vector(3 downto 0); -- mu parameter value.

    -- Filter outputs.
    freqoffestim_stat : out std_logic_vector(7 downto 0);  -- Status register.
    phi            : out std_logic_vector(phisize_g-1 downto 0);  -- phi.
    sigma          : out std_logic_vector(sigmasize_g-1 downto 0);-- sigma.
    omega          : out std_logic_vector(omegasize_g-1 downto 0); -- omega.
    tau            : out std_logic_vector(tausize_g-1 downto 0) -- tau.
  
  );

  end component;


----------------------
-- File: phase_estimation.vhd
----------------------
  component phase_estimation
  generic (
    dsize_g      : integer := 13; -- size of data in
    esize_g      : integer := 13; -- size of error (must >= dsize_g).
    phisize_g    : integer := 15; -- size of angle phi
    omegasize_g  : integer := 12; -- size of angle omega
    sigmasize_g  : integer := 10; -- size of angle sigma
    tausize_g    : integer := 18  -- size of tau
  );
  port (
    -- clock and reset.
    clk                  : in  std_logic;
    reset_n              : in  std_logic;
    --
    symbol_sync          : in  std_logic;  -- Symbol synchronization pulse.
    precomp_enable       : in  std_logic;  -- Enable the precompensation
    interpolation_enable : in  std_logic;  -- Load the tau accumulator
    data_i               : in  std_logic_vector(dsize_g-1 downto 0);  -- Real data in
    data_q               : in  std_logic_vector(dsize_g-1 downto 0);  -- Im data in.
    demap_data           : in  std_logic_vector(1 downto 0);  -- Data from demapping.
    enable_error         : in  std_logic;  -- Enable the error calculation.
    mod_type             : in  std_logic;  -- Modulation type: '0' for DSSS, '1' for CCK.
    rho                  : in  std_logic_vector(3 downto 0);  -- rho parameter value.
    mu                   : in  std_logic_vector(3 downto 0);  -- mu parameter value.
    -- Filtered outputs.
    freqoffestim_stat    : out std_logic_vector(7 downto 0);  -- Status register.
    phi                  : out std_logic_vector(phisize_g-1 downto 0);  -- phi angle.
    sigma                : out std_logic_vector(sigmasize_g-1 downto 0);  -- sigma angle.
    omega                : out std_logic_vector(omegasize_g-1 downto 0);  -- omega angle.
    tau                  : out std_logic_vector(tausize_g-1 downto 0)   -- tau.
    );

  end component;



 
end phase_estimation_pkg;
