

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: pilot_tracking_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for pilot_tracking.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/pilot_tracking_pkg.vhd,v  
--  Log: pilot_tracking_pkg.vhd,v  
-- Revision 1.5  2004/05/18 14:56:17  Dr.C
-- Updated paths.
--
-- Revision 1.4  2003/11/24 11:29:17  Dr.C
-- Updated inv_matrix.
--
-- Revision 1.3  2003/06/25 16:16:51  Dr.F
-- generic changed.
--
-- Revision 1.2  2003/04/01 16:32:06  Dr.F
-- new port map.
--
-- Revision 1.1  2003/03/27 07:48:57  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package pilot_tracking_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/cordic_vectoring/vhdl/rtl/cordic_vectoring.vhd
----------------------
  component cordic_vectoring
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
  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/divider/vhdl/rtl/divider.vhd
----------------------
  component divider

  generic (nbit_input_g       : integer := 25;
           nbit_quotient_g    : integer := 12;
           nintbit_quotient_g : integer := 1);

  port(clk         : in  std_logic;
       reset_n     : in  std_logic;
       start       : in  std_logic;  -- start division on pulse
       dividend    : in  std_logic_vector(nbit_input_g-1 downto 0);
       divisor     : in  std_logic_vector(nbit_input_g-1 downto 0);
       quotient    : out std_logic_vector(nbit_quotient_g-1 downto 0);
       value_ready : out std_logic); -- quotient is available on pulse




  end component;


----------------------
-- File: comp_angle.vhd
----------------------
  component comp_angle
  generic (Nbit_ph_g     : integer := 13;
           Nbit_pilots_g : integer := 12;
           Nbit_pred_g   : integer := 17
           );

  port (clk           : in std_logic;
        reset_n       : in std_logic;
        sync_reset_n  : in std_logic;
        data_valid_i  : in std_logic;
        pilot_p21_i_i : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_p21_q_i : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_p7_i_i  : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_p7_q_i  : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_m21_i_i : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_m21_q_i : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_m7_i_i  : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        pilot_m7_q_i  : in std_logic_vector(Nbit_pilots_g-1 downto 0);
        cpe_pred_i    : in std_logic_vector(Nbit_pred_g-1 downto 0);
        sto_pred_i    : in std_logic_vector(Nbit_pred_g-1 downto 0);
        
        data_valid_o : out std_logic;
        ph_m21_o     : out std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_m7_o      : out std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_p7_o      : out std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_p21_o     : out std_logic_vector(Nbit_ph_g-1 downto 0)
        );


  end component;


----------------------
-- File: complex_mult.vhd
----------------------
  component complex_mult

  generic (NBit_input1_g : integer := 10;
           NBit_input2_g : integer := 10);

  port (clk      : in  std_logic;
        reset_n  : in  std_logic;
        real_1_i : in  std_logic_vector(NBit_input1_g-1 downto 0);
        imag_1_i : in  std_logic_vector(NBit_input1_g-1 downto 0);
        real_2_i : in  std_logic_vector(NBit_input2_g-1 downto 0);
        imag_2_i : in  std_logic_vector(NBit_input2_g-1 downto 0);
        real_o   : out std_logic_vector(NBit_input1_g+NBit_input2_g downto 0);
        imag_o   : out std_logic_vector(NBit_input1_g+NBit_input2_g downto 0)
        );


  end component;


----------------------
-- File: equalize_pilots.vhd
----------------------
  component equalize_pilots

  port (clk               : in  std_logic;
        reset_n           : in  std_logic;
        sync_reset_n      : in  std_logic;
        start_of_symbol_i : in  std_logic;
        start_of_burst_i  : in  std_logic;
        -- pilots from fft
        pilot_p21_i_i     : in  std_logic_vector(11 downto 0);
        pilot_p21_q_i     : in  std_logic_vector(11 downto 0);
        pilot_p7_i_i      : in  std_logic_vector(11 downto 0);
        pilot_p7_q_i      : in  std_logic_vector(11 downto 0);
        pilot_m21_i_i     : in  std_logic_vector(11 downto 0);
        pilot_m21_q_i     : in  std_logic_vector(11 downto 0);
        pilot_m7_i_i      : in  std_logic_vector(11 downto 0);
        pilot_m7_q_i      : in  std_logic_vector(11 downto 0);
        -- channel coefficients
        ch_m21_coef_i_i   : in  std_logic_vector(11 downto 0);
        ch_m21_coef_q_i   : in  std_logic_vector(11 downto 0);
        ch_m7_coef_i_i    : in  std_logic_vector(11 downto 0);
        ch_m7_coef_q_i    : in  std_logic_vector(11 downto 0);
        ch_p7_coef_i_i    : in  std_logic_vector(11 downto 0);
        ch_p7_coef_q_i    : in  std_logic_vector(11 downto 0);
        ch_p21_coef_i_i   : in  std_logic_vector(11 downto 0);
        ch_p21_coef_q_i   : in  std_logic_vector(11 downto 0);
        -- equalized pilots
        pilot_p21_i_o     : out std_logic_vector(11 downto 0);
        pilot_p21_q_o     : out std_logic_vector(11 downto 0);
        pilot_p7_i_o      : out std_logic_vector(11 downto 0);
        pilot_p7_q_o      : out std_logic_vector(11 downto 0);
        pilot_m21_i_o     : out std_logic_vector(11 downto 0);
        pilot_m21_q_o     : out std_logic_vector(11 downto 0);
        pilot_m7_i_o      : out std_logic_vector(11 downto 0);
        pilot_m7_q_o      : out std_logic_vector(11 downto 0);
        
        eq_done_o : out std_logic
        );


  end component;


----------------------
-- File: est_mag.vhd
----------------------
  component est_mag

  port (clk             : in  std_logic;
        reset_n         : in  std_logic;
        sync_reset_n    : in  std_logic;
        data_valid_i    : in  std_logic;
        ch_m21_coef_i_i : in  std_logic_vector(11 downto 0);
        ch_m21_coef_q_i : in  std_logic_vector(11 downto 0);
        ch_m7_coef_i_i  : in  std_logic_vector(11 downto 0);
        ch_m7_coef_q_i  : in  std_logic_vector(11 downto 0);
        ch_p7_coef_i_i  : in  std_logic_vector(11 downto 0);
        ch_p7_coef_q_i  : in  std_logic_vector(11 downto 0);
        ch_p21_coef_i_i : in  std_logic_vector(11 downto 0);
        ch_p21_coef_q_i : in  std_logic_vector(11 downto 0);
        data_valid_o    : out std_logic;
        weight_ch_m21_o : out std_logic_vector(5 downto 0);
        weight_ch_m7_o  : out std_logic_vector(5 downto 0);
        weight_ch_p7_o  : out std_logic_vector(5 downto 0);
        weight_ch_p21_o : out std_logic_vector(5 downto 0)
        );

  end component;


----------------------
-- File: ext_sto_cpe.vhd
----------------------
  component ext_sto_cpe
  generic (Nbit_ph_g         : integer := 13;
           Nbit_inv_matrix_g : integer := 12
           );

  port (clk                 : in  std_logic;
        reset_n             : in  std_logic;
        sync_reset_n        : in  std_logic;
        matrix_data_valid_i : in  std_logic;
        cordic_data_valid_i : in  std_logic;
        ph_m21_i            : in  std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_m7_i             : in  std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_p7_i             : in  std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_p21_i            : in  std_logic_vector(Nbit_ph_g-1 downto 0);
        p11_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p12_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p13_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p14_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p21_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p22_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p23_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p24_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        data_valid_o        : out std_logic;
        sto_meas_o          : out std_logic_vector(13 downto 0);
        cpe_meas_o          : out std_logic_vector(15 downto 0)
        );

  end component;


----------------------
-- File: inv_matrix.vhd
----------------------
  component inv_matrix

  generic (Nbit_weight_g     : integer := 6;
           Nbit_inv_matrix_g : integer := 12);

  port (clk             : in  std_logic;
        reset_n         : in  std_logic;
        sync_reset_n    : in  std_logic;
        data_valid_i    : in  std_logic;
        weight_ch_m21_i : in  std_logic_vector(Nbit_weight_g-1 downto 0);
        weight_ch_m7_i  : in  std_logic_vector(Nbit_weight_g-1 downto 0);
        weight_ch_p7_i  : in  std_logic_vector(Nbit_weight_g-1 downto 0);
        weight_ch_p21_i : in  std_logic_vector(Nbit_weight_g-1 downto 0);
        p11_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p12_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p13_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p14_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p21_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p22_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p23_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p24_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        data_valid_o    : out std_logic;

        p11_dbg         : out std_logic_vector(23 downto 0);
        p12_dbg         : out std_logic_vector(23 downto 0);
        p13_dbg         : out std_logic_vector(23 downto 0);
        p14_dbg         : out std_logic_vector(23 downto 0);
        p21_dbg         : out std_logic_vector(23 downto 0);
        p22_dbg         : out std_logic_vector(23 downto 0);
        p23_dbg         : out std_logic_vector(23 downto 0);
        p24_dbg         : out std_logic_vector(23 downto 0)
        );

  end component;


----------------------
-- File: kalman.vhd
----------------------
  component kalman
  generic (Nbit_sto_meas_g   : integer := 14;
           Nbit_cpe_meas_g   : integer := 16;
           Nbit_prediction_g : integer := 17);

  port (clk             : in  std_logic;
        reset_n         : in  std_logic;
        sync_reset_n    : in  std_logic;
        start_of_burst_i: in  std_logic;
        sto_cpe_valid_i : in  std_logic;
        sto_measured_i  : in  std_logic_vector(Nbit_sto_meas_g-1 downto 0);
        cpe_measured_i  : in  std_logic_vector(Nbit_cpe_meas_g-1 downto 0);        
        skip_cpe_i      : in  std_logic_vector(1 downto 0);        
        data_ready_o    : out std_logic;
        sto_pred_o      : out std_logic_vector(Nbit_prediction_g-1 downto 0);
        cpe_pred_o      : out std_logic_vector(Nbit_prediction_g-1 downto 0));

  end component;


----------------------
-- File: mon_sto_cpe.vhd
----------------------
  component mon_sto_cpe

  generic (nbit_sto_cpe_g : integer := 17
    );
  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    data_valid_i      : in  std_logic;
    start_of_burst_i  : in  std_logic;
    sto_i             : in  std_logic_vector(nbit_sto_cpe_g-1 downto 0);
    cpe_i             : in  std_logic_vector(nbit_sto_cpe_g-1 downto 0);
    skip_cpe_o        : out std_logic_vector(1 downto 0)
  );

  end component;


----------------------
-- File: pilot_tracking.vhd
----------------------
  component pilot_tracking

  port (clk                 : in  std_logic;
        reset_n             : in  std_logic;
        sync_reset_n        : in  std_logic;
        start_of_burst_i    : in  std_logic;
        start_of_symbol_i   : in  std_logic;
        ch_valid_i          : in  std_logic;
        -- pilots
        pilot_p21_i_i       : in  std_logic_vector(11 downto 0);
        pilot_p21_q_i       : in  std_logic_vector(11 downto 0);
        pilot_p7_i_i        : in  std_logic_vector(11 downto 0);
        pilot_p7_q_i        : in  std_logic_vector(11 downto 0);
        pilot_m21_i_i       : in  std_logic_vector(11 downto 0);
        pilot_m21_q_i       : in  std_logic_vector(11 downto 0);
        pilot_m7_i_i        : in  std_logic_vector(11 downto 0);
        pilot_m7_q_i        : in  std_logic_vector(11 downto 0);
        -- channel response for the pilot subcarriers
        ch_m21_coef_i_i     : in  std_logic_vector(11 downto 0);
        ch_m21_coef_q_i     : in  std_logic_vector(11 downto 0);
        ch_m7_coef_i_i      : in  std_logic_vector(11 downto 0);
        ch_m7_coef_q_i      : in  std_logic_vector(11 downto 0);
        ch_p7_coef_i_i      : in  std_logic_vector(11 downto 0);
        ch_p7_coef_q_i      : in  std_logic_vector(11 downto 0);
        ch_p21_coef_i_i     : in  std_logic_vector(11 downto 0);
        ch_p21_coef_q_i     : in  std_logic_vector(11 downto 0);
        -- equalizer coefficients 1/(channel response)
        eq_p21_i_i          : in  std_logic_vector(11 downto 0);
        eq_p21_q_i          : in  std_logic_vector(11 downto 0);
        eq_p7_i_i           : in  std_logic_vector(11 downto 0);
        eq_p7_q_i           : in  std_logic_vector(11 downto 0);
        eq_m21_i_i          : in  std_logic_vector(11 downto 0);
        eq_m21_q_i          : in  std_logic_vector(11 downto 0);
        eq_m7_i_i           : in  std_logic_vector(11 downto 0);
        eq_m7_q_i           : in  std_logic_vector(11 downto 0);
        skip_cpe_o          : out std_logic_vector(1 downto 0);
        estimate_done_o     : out std_logic;
        sto_o               : out std_logic_vector(16 downto 0);
        cpe_o               : out std_logic_vector(16 downto 0);
        -- debug signals
        -- equalized pilots
        pilot_p21_i_dbg     : out std_logic_vector(11 downto 0);
        pilot_p21_q_dbg     : out std_logic_vector(11 downto 0);
        pilot_p7_i_dbg      : out std_logic_vector(11 downto 0);
        pilot_p7_q_dbg      : out std_logic_vector(11 downto 0);
        pilot_m21_i_dbg     : out std_logic_vector(11 downto 0);
        pilot_m21_q_dbg     : out std_logic_vector(11 downto 0);
        pilot_m7_i_dbg      : out std_logic_vector(11 downto 0);
        pilot_m7_q_dbg      : out std_logic_vector(11 downto 0);
        equalize_done_dbg   : out std_logic;
        -- unwrapped cordic phases
        ph_m21_dbg          : out std_logic_vector(12 downto 0);
        ph_m7_dbg           : out std_logic_vector(12 downto 0);
        ph_p7_dbg           : out std_logic_vector(12 downto 0);
        ph_p21_dbg          : out std_logic_vector(12 downto 0);
        cordic_done_dbg     : out std_logic;
        -- ext_sto_cpe
        sto_meas_dbg        : out std_logic_vector(13 downto 0);
        cpe_meas_dbg        : out std_logic_vector(15 downto 0);
        ext_done_dbg        : out std_logic;        
        -- est_mag
        weight_ch_m21_dbg   : out std_logic_vector(5 downto 0);
        weight_ch_m7_dbg    : out std_logic_vector(5 downto 0);
        weight_ch_p7_dbg    : out std_logic_vector(5 downto 0);
        weight_ch_p21_dbg   : out std_logic_vector(5 downto 0);
        est_mag_done_dbg    : out std_logic;
        -- inv_matrix
        p11_dbg             : out std_logic_vector(11 downto 0);
        p12_dbg             : out std_logic_vector(11 downto 0);
        p13_dbg             : out std_logic_vector(11 downto 0);
        p14_dbg             : out std_logic_vector(11 downto 0);
        p21_dbg             : out std_logic_vector(11 downto 0);
        p22_dbg             : out std_logic_vector(11 downto 0);
        p23_dbg             : out std_logic_vector(11 downto 0);
        p24_dbg             : out std_logic_vector(11 downto 0);
        -- inv matrix debug signals
        p11_f_dbg           : out std_logic_vector(23 downto 0);
        p12_f_dbg           : out std_logic_vector(23 downto 0);
        p13_f_dbg           : out std_logic_vector(23 downto 0);
        p14_f_dbg           : out std_logic_vector(23 downto 0);
        p21_f_dbg           : out std_logic_vector(23 downto 0);
        p22_f_dbg           : out std_logic_vector(23 downto 0);
        p23_f_dbg           : out std_logic_vector(23 downto 0);
        p24_f_dbg           : out std_logic_vector(23 downto 0);
        inv_matrix_done_dbg : out std_logic
        );

  end component;



 
end pilot_tracking_pkg;
