
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: rx_path_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.39   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rx_path.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/rx_path/vhdl/rtl/rx_path_pkg.vhd,v  
--  Log: rx_path_pkg.vhd,v  
-- Revision 1.39  2005/01/24 13:56:07  arisse
-- #BugId:624#
-- Added status signals.
--
-- Revision 1.38  2004/08/24 13:42:35  arisse
-- Added globals for testbench.
--
-- Revision 1.37  2004/05/03 13:50:54  pbressy
-- modified list file to remove unused lib and files
--
-- Revision 1.36  2004/04/27 09:23:33  arisse
-- Added one bit to mu.
--
-- Revision 1.35  2004/03/24 18:18:54  arisse
-- Went back to version 1.33.
--
-- Revision 1.34  2004/03/24 17:34:06  arisse
-- Removed unused library.
--
-- Revision 1.33  2003/11/29 16:09:30  arisse
-- Resynchronized rx_enable.
--
-- Revision 1.32  2003/10/16 16:21:07  arisse
-- Changed diag_error_i/q to 8 bits instead of 9 bits.
--
-- Revision 1.31  2003/10/16 14:20:17  arisse
-- Added diag ports.
--
-- Revision 1.30  2003/10/16 14:16:22  arisse
-- Added diag ports.
--
-- Revision 1.29  2003/09/18 08:41:38  Dr.A
-- Added barker_sync.
--
-- Revision 1.28  2003/09/09 13:10:38  Dr.C
-- Updated equalizer and power_estim.
--
-- Revision 1.27  2003/07/25 17:14:50  Dr.B
-- changes ports of rx_path_core (rx-front-end blocks removed).
--
-- Revision 1.26  2003/07/07 08:33:19  Dr.J
-- Updated with the new size of the cordic
--
-- Revision 1.25  2003/05/07 13:57:27  Dr.J
-- Updated Cordic port map.
--
-- Revision 1.24  2003/04/23 07:26:56  Dr.C
-- Added rx_path_core.
--
-- Revision 1.23  2003/04/08 14:13:38  Dr.J
-- Updated
--
-- Revision 1.22  2003/04/08 14:09:26  Dr.J
-- Added dc_offset disable\
--
-- Revision 1.21  2002/12/03 13:25:52  Dr.J
-- Added signal sfd_detect_enable\
--
-- Revision 1.20  2002/11/28 10:18:55  Dr.A
-- Cleaned code.
--
-- Revision 1.19  2002/11/08 14:54:38  Dr.J
-- Updated
--
-- Revision 1.18  2002/11/06 17:15:19  Dr.A
-- Misc updates.
--
-- Revision 1.17  2002/10/31 16:32:59  Dr.J
-- Added c2disb.
--
-- Revision 1.16  2002/10/28 15:17:59  Dr.C
-- Added timing offset estimation
--
-- Revision 1.15  2002/10/28 09:12:13  Dr.J
-- Updated with the new power_estim
--
-- Revision 1.14  2002/10/24 17:10:43  Dr.A
-- New peak_detect port map.
--
-- Revision 1.13  2002/10/21 14:02:15  Dr.J
-- Added iq_mismatch
--
-- Revision 1.12  2002/10/17 08:25:14  Dr.A
-- New peak_detect block.
--
-- Revision 1.11  2002/10/15 15:51:15  Dr.J
-- Added interpolator
--
-- Revision 1.10  2002/10/11 07:47:28  Dr.J
-- Added interpolator
--
-- Revision 1.9  2002/09/19 17:03:06  Dr.A
-- New equalizer.
--
-- Revision 1.8  2002/09/13 11:23:56  Dr.J
-- Added pragmas
--
-- Revision 1.7  2002/07/31 17:57:13  Dr.J
-- Change the deserializer
--
-- Revision 1.6  2002/07/31 13:15:18  Dr.J
-- Port map updated
--
-- Revision 1.5  2002/07/12 13:06:22  Dr.A
-- Added sfdlen port.
--
-- Revision 1.4  2002/07/11 12:32:22  Dr.J
-- New data size
--
-- Revision 1.3  2002/07/01 16:07:19  Dr.J
-- Updated
--
-- Revision 1.2  2002/07/01 08:07:12  Dr.J
-- Updated with the new equalizer
--
-- Revision 1.1  2002/07/01 07:33:16  Dr.J
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
package rx_path_pkg is

-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  signal global_sigma_est        : std_logic_vector(9 downto 0);
--  signal data_dc_i_gbl : std_logic_vector(7 downto 0);
--  signal data_dc_q_gbl : std_logic_vector(7 downto 0);
--  signal data_iq_i_gbl : std_logic_vector(7 downto 0);
--  signal data_iq_q_gbl : std_logic_vector(7 downto 0);
--  signal barker_sync_gbl         : std_logic; 
--  signal symbol_synchro_int_gbl  : std_logic; 
--  signal dc_offset_i_gbl : std_logic_vector(5 downto 0);
--  signal dc_offset_q_gbl : std_logic_vector(5 downto 0);
--  signal d_signed_peak_i_gbl   : std_logic_vector(7 downto 0);
--  signal d_signed_peak_q_gbl   : std_logic_vector(7 downto 0);
--  signal correl_rst_n_gbl      : std_logic; 
--  signal equalizer_data_out_i_gbl : std_logic_vector(8 downto 0);
--  signal equalizer_data_out_q_gbl : std_logic_vector(8 downto 0);
--  signal a_data_i_gbl         : std_logic_vector(9 downto 0);
--  signal a_data_q_gbl         : std_logic_vector(9 downto 0);
--  signal remod_data_i_gbl     : std_logic_vector(7 downto 0);
--  signal remod_data_q_gbl     : std_logic_vector(7 downto 0);
--  signal rho_int_gbl             : std_logic_vector(3 downto 0);
--  signal mu_int_gbl              : std_logic_vector(3 downto 0);
--  
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- Source: Good
----------------------
  component equalizer
  generic (
    dsize_g : integer := 8;  -- Input data size
    csize_g : integer := 8;  -- Coefficient size 
    coeff_g : integer := 36; -- Number of filter coefficients 
    delay_g : integer := 44; -- Delay for remodulation (in half-chip)
    
    -- for ffwd_estimation:
    -- generics for coefficients calculation
    shifta_g : integer := 14;  -- data size after shifting by alpha.
    cacsize_g: integer := 19;  -- accumulated coeff size  

    -- generics for DC_output calculation
    dccoeff_g : integer := 19; -- numbers of bits kept from coeff to calc sum.
    sum_g     : integer := 8; -- data size of the sum
    multerr_g : integer := 12; -- data size after the mult by error
    shiftb_g  : integer := 14; -- data size after shifting by beta
    dcacsize_g: integer := 17; -- accumulated dc_offset size  
    dcsize_g  : integer := 6;   -- DC_offset size (output)
    outsize_g : integer := 9;
    p_size_g  : integer := 4 -- nb of input bits from correlator for peak_detect
    
  );
  port (
    -------------------------------
    -- reset and clock
    -------------------------------
    reset_n         : in  std_logic; 
    clk             : in  std_logic;
    -------------------------------
    -- Control signals
    -------------------------------
    equ_activate    : in std_logic;  -- activate the block
    equalizer_init_n: in  std_logic; -- filter coeffs= 0  when low.
    equalizer_disb  : in  std_logic; -- Disable the filter when high.
                                     -- data_in are shifted to data_out 
    data_sync       : in  std_logic; -- Pulse at first data.
    alpha_accu_disb : in  std_logic; -- stop coeff accu when high
    beta_accu_disb  : in  std_logic; -- stop dc accu when high
    -------------------------------
    -- Equalizer inputs
    -------------------------------
    -- Incoming data stream at 22 MHz (I and Q).
    data_fil_i      : in  std_logic_vector(dsize_g-1 downto 0);
    data_fil_q      : in  std_logic_vector(dsize_g-1 downto 0);
    -- Remodulated data at 11 MHz (I and Q).
    remod_data_i    : in  std_logic_vector(outsize_g-1 downto 0);
    remod_data_q    : in  std_logic_vector(outsize_g-1 downto 0);
    -- Equalizer parameters.
    alpha           : in  std_logic_vector(2 downto 0);
    beta            : in  std_logic_vector(2 downto 0);
    -- Data to multiply  when equ is disable for peak detector
    d_signed_peak_i   : in  std_logic_vector(p_size_g-1 downto 0);
    d_signed_peak_q   : in  std_logic_vector(p_size_g-1 downto 0);
    -------------------------------
    -- Equalizer outputs
    -------------------------------
    equalized_data_i      : out std_logic_vector(outsize_g-1 downto 0);
    equalized_data_q      : out std_logic_vector(outsize_g-1 downto 0);    
    -- Output for peak_detect
    abs_2_corr            : out std_logic_vector (2*p_size_g-1 downto 0);

    -- Register stat
    coeff_sum_i_stat : out std_logic_vector(sum_g-1 downto 0);
    coeff_sum_q_stat : out std_logic_vector(sum_g-1 downto 0);
    
    -- DC Offset outputs.
    dc_offset_i      : out std_logic_vector(dcsize_g-1 downto 0);
    dc_offset_q      : out std_logic_vector(dcsize_g-1 downto 0);
    
    -------------------------------
    -- Diag ports
    -------------------------------
    diag_error_i     : out std_logic_vector(outsize_g-2 downto 0); 
    diag_error_q     : out std_logic_vector(outsize_g-2 downto 0)
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11b/barker_cor/vhdl/rtl/barker_cor.vhd
----------------------
  component barker_cor
  generic (
    dsize_g : integer := 6
  );
  port (
    -- clock and reset.
    reset_n      : in  std_logic; -- Global reset.
    clk          : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).
    correl_rst_n : in  std_logic; -- Correlator reset.
    barker_sync  : in  std_logic; -- Correlator output synchronization.
    -- Input data.
    sampl_i      : in  std_logic_vector(dsize_g-1 downto 0); -- I sample input.
    sampl_q      : in  std_logic_vector(dsize_g-1 downto 0); -- Q sample input.
    -- Saturated correlated outputs.
    peak_data_i  : out std_logic_vector(7 downto 0);  
    peak_data_q  : out std_logic_vector(7 downto 0) 
  );

  end component;


----------------------
-- Source: Good
----------------------
  component peak_detect
  generic (
    accu_size_g : integer := 20
  );
  port (
    -- clock and reset.
    reset_n        : in  std_logic; -- Global reset.
    clk            : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).
    --
    accu_resetn    : in  std_logic; -- Reset the accumulator.
    synchro_en     : in  std_logic; -- '1' to enable timing synchronization.
    mod_type       : in  std_logic; -- Modulation type (0 for DSSS , 1 for CCK).
    -- Square module of the correlator output data.
    abs_2_corr     : in  std_logic_vector(15 downto 0);
    --
    barker_sync    : out std_logic; -- Synchronization signal to Correlator.
    symbol_sync    : out std_logic -- Indicates the correlator peak value.
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11b/symbol_sync/vhdl/rtl/symbol_sync.vhd
----------------------
  component symbol_sync
  generic (
    dsize_g : integer := 10
  );
  port (
    -- clock and reset.
    reset_n      : in  std_logic; -- Global reset.
    clk          : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).
    --
    corr_i       : in  std_logic_vector(dsize_g-1 downto 0); -- correlated 
    corr_q       : in  std_logic_vector(dsize_g-1 downto 0); -- inputs.
    symbol_sync  : in  std_logic; -- Symbol synchronization signal.
    --
    data_i       : out std_logic_vector(dsize_g-1 downto 0); -- Sampled
    data_q       : out std_logic_vector(dsize_g-1 downto 0)  -- outputs.
  
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11b/diff_decoder/vhdl/rtl/diff_decoder.vhd
----------------------
  component diff_decoder
  port (
    -- clock and reset
    clk     : in std_logic;
    reset_n : in std_logic;

    -- inputs
    diff_decod_activate  : in std_logic;  -- activate the diff_decoder block
    diff_decod_first_val : in std_logic;  -- initialize the diff_decoder block when
    -- the first symbol is received
    -- (diff_decod_activate should be set).
    diff_cck_mode        : in std_logic; -- indicate a CCK mode (pi to add)
    diff_decod_in        : in std_logic_vector (1 downto 0);  -- input
    shift_diff_decod     : in std_logic;  -- shift diff_decoder

    -- outputs
    delta_phi : out std_logic_vector (1 downto 0)  -- delta_phi output


    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11b/scrambling/vhdl/rtl/descrambling8_8.vhd
----------------------
  component descrambling8_8
  port (
    -- clock and reset
    clk     : in std_logic;
    reset_n : in std_logic;

    dscr_activate   : in std_logic;     -- activate the block
    scrambling_disb : in std_logic;     -- disable the descr.when high 
    dscr_mode       : in std_logic;     -- 0 : serial - 1 : parallel

    -- Signals for serial descrambling
    bit_fr_diff_dec : in  std_logic;    -- bit from differential decoder
    symbol_sync     : in  std_logic;    -- chip synchronisation
    --
    dscr_bit_out    : out std_logic;

    -- Signals for parallel descrambling   
    byte_fr_des : in  std_logic_vector (7 downto 0);  -- byte from deseria.
    byte_sync   : in  std_logic;                      --  sync from deseria
    --
    data_to_bup : out std_logic_vector (7 downto 0)

    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11b/deserializer/vhdl/rtl/deserializer.vhd
----------------------
  component deserializer
  port (
    -- clock and reset
    clk             : in  std_logic;                   
    reset_n         : in  std_logic;                  
     
    -- inputs
    d_from_diff_dec : in std_logic_vector (1 downto 0); 
    --               2-bits input from differential decoder (PSK)
    d_from_cck_dem  : in std_logic_vector (5 downto 0); 
    --               6-bits input from cck_demod (CCK)
    rec_mode        : in  std_logic_vector (1 downto 0);
    --               reception mode : BPSK QPSK CCK5.5 or CCK11
    symbol_sync     : in  std_logic;
    --               new chip available


    packet_sync    : in  std_logic;
    --               resynchronize (start a new byte)
    deseria_activate : in  std_logic;
    --               activate the deserializer. Beware to disable the deseria.
    --               when no transfer is performed to not get any 
    --               phy_data_ind pulse. 
    
    -- outputs
    deseria_out   : out std_logic_vector (7 downto 0);
    --              byte for the Bup
    byte_sync     : out std_logic;
    --              synchronisation for the descrambler (1 per bef phy_data_ind)
    --              as there should be glitches on transition of trans_count
    --              byte_sync must be used only to generate clocked signals !
    phy_data_ind  : out std_logic
    --              The modem indicates that a new byte is received.
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/cordic/vhdl/rtl/cordic.vhd
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
-- Source: Good
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


----------------------
-- Source: Good
----------------------
  component iq_mismatch
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                    : in  std_logic; -- clock
    reset_n                : in  std_logic; -- reset when low
    iq_estimation_enable   : in  std_logic; -- enable the estimation when high
    iq_compensation_enable : in  std_logic; -- enable the I/Q Mismatch when high
    --------------------------------------
    -- Datas signals
    --------------------------------------
    data_in_i              : in  std_logic_vector(7 downto 0); -- input data I
    data_in_q              : in  std_logic_vector(7 downto 0); -- input data Q
    iq_gain_sat_stat       : out std_logic_vector(6 downto 0);
    data_out_i             : out std_logic_vector(7 downto 0); -- output data I
    data_out_q             : out std_logic_vector(7 downto 0)  -- output data Q
    
  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11b/decode_path/vhdl/rtl/decode_path.vhd
----------------------
  component decode_path
  port (
    ---------------------
    -- clocks and reset
    ---------------------
    clk     : in std_logic;
    reset_n : in std_logic;

    ---------------------
    -- inputs
    ---------------------
    -- data
    demap_data     : in std_logic_vector (1 downto 0);  -- data from demapping
    d_from_cck_dem : in std_logic_vector (5 downto 0);  -- data from cck_demod

    -- blocks activation
    decode_path_activate : in std_logic;
    diff_decod_first_val : in std_logic;  -- initialize the diff_decoder block when
    -- the first symbol is received
    -- (diff_decod_activate should be set).     

    -- control signals
    sfderr            : in std_logic_vector (2 downto 0);  -- allowed errs nb
    sfdlen            : in std_logic_vector (2 downto 0);  -- nb of pr sig analyzed
    symbol_sync       : in std_logic;
    sfd_detect_enable : in std_logic; -- allow sfd detection (when data are stable)
    rec_mode          : in std_logic_vector (1 downto 0);
    --                0=BPSK 1=QPSK 2=CCK5.5 3=CCK11
    scrambling_disb   : in std_logic;   -- disable the descr.when high 

    ---------------------
    -- outputs
    ---------------------
    sfd_found     : out std_logic;      -- short or long sfd found
    preamble_type : out std_logic;      -- 0 = short - 1 = long
    phy_data_ind  : out std_logic;
    data_to_bup   : out std_logic_vector ( 7 downto 0)

    );

  end component;


----------------------
-- File: rx_path_core.vhd
----------------------
  component rx_path_core

  generic (
    -- number of bits for the complex data :
    data_length_g  : integer := 9;
    -- number of bits for the input angle z_in :
    angle_length_g : integer := 15
    );
  port (
    --------------------------------------------
    -- clocks and reset.
    --------------------------------------------
    reset_n                : in  std_logic;  -- Global reset.
    rx_path_b_gclk         : in  std_logic;  -- Gated Clock for RX Path (44 Mhz).

    --------------------------------------------
    -- Data In. (from gain compensation)
    --------------------------------------------
    data_in_i              : in  std_logic_vector(7 downto 0);
    data_in_q              : in  std_logic_vector(7 downto 0);

    --------------------------------------------
    -- Control for dc_offset compensation.
    --------------------------------------------
    dcoffdisb              : in  std_logic;  -- disable dc_offset compensation when high

    --------------------------------------------
    -- Control for IQ Mismatch Compensation
    --------------------------------------------
    iq_estimation_enable   : in  std_logic;  -- enable the I/Q estimation when high
    iq_compensation_enable : in  std_logic;  -- enable the I/Q compensation when high

    --------------------------------------------
    -- Control for equalization
    --------------------------------------------
    equ_activate           : in  std_logic;  -- enable the equalizer when high.
    equalizer_disb         : in  std_logic;  -- disable the equalizer filter when high.
    equalizer_init_n       : in  std_logic;  -- equalizer filter coeffs set to 0 when low.
    alpha_accu_disb        : in  std_logic;  -- stop coeff accu when high.
    beta_accu_disb         : in  std_logic;  -- stop dc accu when high.
    alpha                  : in  std_logic_vector(2 downto 0);  -- alpha parameter value.
    beta                   : in  std_logic_vector(2 downto 0);  -- beta parameter value.

    --------------------------------------------
    -- Control for DSSS / CCK demodulation
    --------------------------------------------
    interp_disb            : in  std_logic;  -- disable the interpolation when high
    rx_enable              : in  std_logic;  -- enable rx path when high 
    mod_type               : in  std_logic;  -- '0' for DSSS, '1' for CCK.
    enable_error           : in  std_logic;  -- Enable error calculation when high.
    precomp_enable         : in  std_logic;  -- Reload the omega accumulator.
    demod_rate             : in  std_logic;  -- '0' for BPSK, '1' for QPSK.
    cck_rate               : in  std_logic;  -- '0' for 5.5 Mhz, '1' for 11 Mhz.
    rho                    : in  std_logic_vector(1 downto 0);  -- rho parameter value
    mu                     : in  std_logic_vector(2 downto 0);  -- mu parameter value.
    --
    tau_est                : out std_logic_vector(17 downto 0);

    --------------------------------------------
    -- Control for Decode Path
    --------------------------------------------
    scrambling_disb        : in  std_logic;  -- scrambling disable (test mode) 
    decode_path_activate   : in  std_logic;  -- enable the differential decoder
    diff_decod_first_val   : in  std_logic;  -- initialize the diff_decoder block
    sfd_detect_enable      : in  std_logic;  -- enable the sfd detection 
    -- Number of errors allowed.
    sfderr                 : in  std_logic_vector (2 downto 0);
    -- Number of pramble bits used for Start Frame Delimiter search.
    sfdlen                 : in  std_logic_vector (2 downto 0);
    -- Receive mode        : 0=BPSK, 1=QPSK, 2=CCK5.5, 3=CCK11.
    rec_mode               : in  std_logic_vector (1 downto 0);

    --------------------------------------------
    -- Remodulation interface
    --------------------------------------------
    remod_data             : in  std_logic_vector(1 downto 0);  -- Data from the TX path
    --
    remod_enable           : out std_logic;  -- High when the remodulation is enabled
    remod_data_req         : out std_logic;  -- request to send a byte 
    remod_type             : out std_logic;  -- CCK : 0 ; PBCC : 1
    remod_bq               : out std_logic;  -- BPSK = 0 - QPSK = 1 
    demod_data             : out std_logic_vector(7 downto 0);  -- Data to the TX path

    --------------------------------------------
    -- AGC-CCA interface
    --------------------------------------------
    correl_rst_n           : in  std_logic;  -- reset the Barker correlator when low
    synchro_en             : in  std_logic;  -- enable the synchronisation when high 
    --
    symbol_synchro         : out std_logic;  -- pulse at the beginning of a symbol.

    --------------------------------------------
    -- Modem B state machines interface
    --------------------------------------------
    sfd_found              : out std_logic;  -- sfd found when high
    preamble_type          : out std_logic;  -- Type of preamble 
    phy_data_ind           : out std_logic;  -- pulse when an RX byte is available.
    data_to_bup            : out std_logic_vector(7 downto 0); -- RX data.
    --------------------------------------------
    -- Status registers.
    --------------------------------------------
    iq_gain_sat_stat       : out std_logic_vector(6 downto 0);
    dc_offset_i_stat       : out std_logic_vector(5 downto 0);
    dc_offset_q_stat       : out std_logic_vector(5 downto 0);
    coeff_sum_i_stat       : out std_logic_vector(7 downto 0);
    coeff_sum_q_stat       : out std_logic_vector(7 downto 0);
    freqoffestim_stat      : out std_logic_vector(7 downto 0);
    -------------------------------
    -- Diag ports
    -------------------------------
    diag_error_i     : out std_logic_vector(data_length_g-2 downto 0); 
    diag_error_q     : out std_logic_vector(data_length_g-2 downto 0)
    
    );

  end component;



 
end rx_path_pkg;
