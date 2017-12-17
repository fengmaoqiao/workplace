
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: rx11b_demod_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.16   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rx11b_demod.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/rx11b_demod/vhdl/rtl/rx11b_demod_pkg.vhd,v  
--  Log: rx11b_demod_pkg.vhd,v  
-- Revision 1.16  2005/10/04 08:28:47  arisse
-- #BugId:1396#
-- Added globals
--
-- Revision 1.15  2005/01/24 14:20:23  arisse
-- #BugId:624#
-- Added status signal for registers.
--
-- Revision 1.14  2004/08/24 13:43:37  arisse
-- Added globals for testbench.
--
-- Revision 1.13  2004/04/30 15:07:51  arisse
-- Added input cck_demod_enable in fwt entity.
--
-- Revision 1.12  2004/04/16 14:23:44  arisse
-- Changed generation of signal valid_symbol sent to decode_path.
--
-- Revision 1.11  2003/07/07 08:29:49  Dr.J
-- Updated with the new size of the cordic
--
-- Revision 1.10  2003/05/07 13:53:22  Dr.J
-- Added enable on the cordic
--
-- Revision 1.9  2002/10/15 15:49:38  Dr.J
-- Added interpolation enable
--
-- Revision 1.8  2002/10/10 15:02:40  Dr.J
-- Added tau
--
-- Revision 1.7  2002/08/19 14:20:37  Dr.A
-- Added tau and interpolation enable.
--
-- Revision 1.6  2002/08/14 18:15:18  Dr.J
-- Updated
--
-- Revision 1.5  2002/07/31 13:07:40  Dr.J
-- Renamed omega_load by precomp_enable
--
-- Revision 1.4  2002/07/11 12:29:11  Dr.J
-- Updated with the new data size
--
-- Revision 1.3  2002/06/28 16:24:33  Dr.J
-- Updated port map
--
-- Revision 1.2  2002/06/11 15:21:51  Dr.J
-- Added data_out_sync
--
-- Revision 1.1  2002/06/11 10:18:45  Dr.F
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
package rx11b_demod_pkg is

-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
   -- precompensed data from precompensation_cordic_1
--  signal precomp_data_i_glob : std_logic_vector(9 downto 0);
--  signal precomp_data_q_glob : std_logic_vector(9 downto 0);
--  
  -- demodulated data from dsss_demod_1
--  signal demod_dsss_data_i_glob : std_logic_vector(9 + 4 downto 0);
--  signal demod_dsss_data_q_glob : std_logic_vector(9 + 4 downto 0);
--  
  -- compensed data from compensation_cordic_1
--  signal comp_data_i_glob       : std_logic_vector(9 + 3 downto 0);
--  signal comp_data_q_glob       : std_logic_vector(9 + 3 downto 0);
--
  -- demapped data from demapping_1
--  signal demap_data_glob       : std_logic_vector(1 downto 0);
--
  -- For save_modem.vhd
--  signal precomp_data_i_gbl : std_logic_vector(10 downto 0);
--  signal precomp_data_q_gbl : std_logic_vector(10 downto 0);
--  signal dsss_cck_data_i_gbl   : std_logic_vector(11 downto 0);
--  signal dsss_cck_data_q_gbl   : std_logic_vector(11 downto 0);
--  signal symbol_sync_ff5_gbl   : std_logic;
--  signal omega_est_gbl       : std_logic_vector(11 downto 0);
--  signal sigma_est_gbl      : std_logic_vector(9 downto 0);
--  signal cordic_x0_out_gbl    : std_logic_vector(13 downto 0);
--  signal cordic_y0_out_gbl    : std_logic_vector(13 downto 0); 
--  signal phi_est_gbl         : std_logic_vector(14 downto 0);
--  signal symbol_sync_ff6_gbl   : std_logic;
--  
--  signal cordic_x1_out_gbl    : std_logic_vector(13 downto 0);
--  signal cordic_y1_out_gbl    : std_logic_vector(13 downto 0);
--  signal cordic_x2_out_gbl    : std_logic_vector(13 downto 0);
--  signal cordic_y2_out_gbl    : std_logic_vector(13 downto 0);
--  signal cordic_x3_out_gbl    : std_logic_vector(13 downto 0);
--  signal cordic_y3_out_gbl    : std_logic_vector(13 downto 0);
--  signal biggest_index_int_gbl : std_logic_vector(5 downto 0);
--  signal demod_cck_i_gbl : std_logic_vector(12 downto 0);
--  signal demod_cck_q_gbl : std_logic_vector(12 downto 0);
--  signal fwt_out1_i_int_gbl   : std_logic_vector (11 downto 0);
--  signal fwt_out1_q_int_gbl   : std_logic_vector (11 downto 0);
--  signal fwt_out2_i_int_gbl   : std_logic_vector (11 downto 0);
--  signal fwt_out2_q_int_gbl   : std_logic_vector (11 downto 0);
--  signal fwt_out3_i_int_gbl   : std_logic_vector (11 downto 0);
--  signal fwt_out3_q_int_gbl   : std_logic_vector (11 downto 0);
--  signal demod_out_i_gbl      : std_logic_vector(12 downto 0);
--  signal demod_out_q_gbl      : std_logic_vector(12 downto 0);
--  
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/NLWARE/DSP/cordic/vhdl/rtl/cordic.vhd
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


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/phase_estimation/vhdl/rtl/phase_estimation.vhd
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


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/dsss_demod/vhdl/rtl/dsss_demod.vhd
----------------------
  component dsss_demod
  generic (
    dsize_g : integer := 6
  );
  port (
    -- clock and reset.
    reset_n      : in  std_logic; -- Global reset.
    clk          : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).
    --
    symbol_sync  : in  std_logic; -- Symbol synchronization at 1 Mhz.
    x_i          : in  std_logic_vector(dsize_g-1 downto 0); -- dsss input.
    x_q          : in  std_logic_vector(dsize_g-1 downto 0); -- dsss input.
    -- 
    demod_i      : out std_logic_vector(dsize_g+3 downto 0); -- dsss output.
    demod_q      : out std_logic_vector(dsize_g+3 downto 0)  -- dsss output.
    
  );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/demapping/vhdl/rtl/demapping.vhd
----------------------
  component demapping
  generic (
    dsize_g : integer := 6 -- Data size.
  );
  port (
    -- Demodulated data in
    demap_i      : in  std_logic_vector(dsize_g-1 downto 0); -- Real part.
    demap_q      : in  std_logic_vector(dsize_g-1 downto 0); -- Imaginary part.
    demod_rate   : in  std_logic; -- Demodulation rate: 0 for BPSK, 1 for QPSK.
    --
    demap_data   : out std_logic_vector(1 downto 0)
  );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/fwt/vhdl/rtl/fwt.vhd
----------------------
  component fwt
generic (
  data_length : integer := 6            -- Number of bits for data Input ports.
                                        -- 3 more bits for data output ports.
);
port (
  reset_n     : in  std_logic;          -- System reset. Active LOW.
  clk         : in  std_logic;          -- System clock.
  cck_demod_enable : in std_logic;
  start_fwt   : in  std_logic;          -- Start the fwt.
  end_fwt     : out std_logic;          -- Flag indicating fwt is finished.
  data_valid  : out std_logic;          -- Flag indicating output data valid.
--
  input0_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in0
  input0_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in0.
  input1_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in1
  input1_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in1.
  input2_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in2
  input2_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in2.
  input3_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in3
  input3_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in3.
  input4_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in4
  input4_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in4.
  input5_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in5
  input5_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in5.
  input6_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in6
  input6_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in6.
  input7_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in7
  input7_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in7.
--
  output0_re  : out std_logic_vector (data_length+2 downto 0);--R part of out0.
  output0_im  : out std_logic_vector (data_length+2 downto 0);--Im part of out0.
  output1_re  : out std_logic_vector (data_length+2 downto 0);--R part of out1.
  output1_im  : out std_logic_vector (data_length+2 downto 0);--Im part of out1.
  output2_re  : out std_logic_vector (data_length+2 downto 0);--R part of out2.
  output2_im  : out std_logic_vector (data_length+2 downto 0);--Im part of out2.
  output3_re  : out std_logic_vector (data_length+2 downto 0);--R part of out3.
  output3_im  : out std_logic_vector (data_length+2 downto 0) --Im part of out3.
);
  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/biggest_picker/vhdl/rtl/biggest_picker.vhd
----------------------
  component biggest_picker
  generic (
    data_length_g : integer := 16            -- Number of bits for data I/O ports.
  );
  port (
          reset_n     : in  std_logic;
          clk         : in  std_logic;
          start_picker: in  std_logic;
          cck_rate    : in  std_logic; -- CCK rate. 0: 5.5Mb/s ; 1: 11Mb/s
          input0_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input0_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input1_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input1_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input2_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input2_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input3_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input3_im   : in  std_logic_vector (data_length_g-1 downto 0);

          output_re   : out std_logic_vector (data_length_g-1 downto 0);--R part of out.
          output_im   : out std_logic_vector (data_length_g-1 downto 0);--Im part of out.
          index       : out std_logic_vector (5 downto 0);
          valid_symbol: out std_logic
  );        
  end component;


----------------------
-- File: rx11b_demod.vhd
----------------------
  component rx11b_demod
  generic (
    -- assignment of global signals :
    global_enable_g : integer := 0; -- 0 : no ; 1 : yes
    -- number of bits for the complex data :                                                         
    data_length_g          : integer := 9;                                            
    -- number of bits for the input angle z_in :                                                         
    angle_length_g         : integer := 15;                                            
    -- number of microrotation stages in a combinational path :
    nbr_cordic_combstage_g : integer := 3;   -- must be > 0                                         
    -- number of pipes in the cordic
    nbr_cordic_pipe_g      : integer := 4    -- must be > 0                                        
    -- NOTE : the total number of microrotations is :
    --          nbr_cordic_combstage_g * nbr_cordic_pipe_g = data_length_g
  );
  port (
    -- clock and reset.
    reset_n      : in  std_logic; -- Global reset.
    clk          : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).

    symbol_sync  : in  std_logic; -- Symbol synchronization at 1 Mhz.
    precomp_enable   : in  std_logic; -- Reload the omega accumulator

--    cck_demod_enable : in  std_logic; -- window when enabled
    mod_type     : in  std_logic; -- Modulation type: '0' for DSSS, '1' for CCK.
    demod_rate   : in  std_logic; -- '0' for BPSK, '1' for QPSK
    cck_rate     : in  std_logic; -- '0' for 5.5 Mhz, '1' for 11 Mhz
    enable_error : in  std_logic; -- Enable error calculation when high
    interpolation_enable : in std_logic; -- Enable the Interpolation.
    rho          : in  std_logic_vector(3 downto 0); -- rho parameter value.
    mu           : in  std_logic_vector(3 downto 0); -- mu parameter value.

    -- Angles.
        -- Compensation angle. (only used for the simulation of this block)
    phi          : in  std_logic_vector(angle_length_g-1 downto 0);
        -- Precompensation angle. (only used for the simulation of this block)
    omega        : in  std_logic_vector(11 downto 0);
       -- before equalizer estimation
    sigma        : out std_logic_vector(9 downto 0);
       -- Tau for interpolator
    tau          : out std_logic_vector(17 downto 0);
    
    -- Data In.
    data_in_i    : in  std_logic_vector(data_length_g-1 downto 0);
    data_in_q    : in  std_logic_vector(data_length_g-1 downto 0);

    -- Data Out.
    freqoffestim_stat: out std_logic_vector(7 downto 0);  -- Status register.
    demap_data_out   : out std_logic_vector(1 downto 0);
    biggest_index    : out std_logic_vector(5 downto 0);
    valid_symbol     : out std_logic;

    remod_type       : out std_logic;
    data_to_remod    : out std_logic_vector(7 downto 0);
    remod_data_sync  : out std_logic
  );

  end component;



 
end rx11b_demod_pkg;
