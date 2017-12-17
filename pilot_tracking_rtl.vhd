

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: pilot_tracking.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Pilot tracking top level.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/pilot_tracking.vhd,v  
--  Log: pilot_tracking.vhd,v  
-- Revision 1.4  2003/11/24 11:29:01  Dr.C
-- Updated inv_matrix port map.
--
-- Revision 1.3  2003/06/25 16:16:24  Dr.F
-- generic name changed.
--
-- Revision 1.2  2003/04/01 16:31:46  Dr.F
-- new equ_pilot.
--
-- Revision 1.1  2003/03/27 07:48:55  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--library pilot_tracking_rtl;
library work;
--use pilot_tracking_rtl.pilot_tracking_pkg.all;
use work.pilot_tracking_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity pilot_tracking is

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

end pilot_tracking;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of pilot_tracking is

  constant NBIT_PILOTS_EQ_CT  : integer := 12;
  constant NBIT_PH_CT         : integer := 13;
  constant NBIT_INV_MATRIX_CT : integer := 12;
  constant NBIT_STO_MEAS_CT   : integer := 14;
  constant NBIT_CPE_MEAS_CT   : integer := 16;
  constant NBIT_PREDICTION_CT : integer := 17;
  constant NBIT_WEIGHT_CT     : integer := 6;


  signal pilot_m21_i_eq    : std_logic_vector(NBIT_PILOTS_EQ_CT-1 downto 0);
  signal pilot_m21_q_eq    : std_logic_vector(NBIT_PILOTS_EQ_CT-1 downto 0);
  signal pilot_m7_i_eq     : std_logic_vector(NBIT_PILOTS_EQ_CT-1 downto 0);
  signal pilot_m7_q_eq     : std_logic_vector(NBIT_PILOTS_EQ_CT-1 downto 0);
  signal pilot_p7_i_eq     : std_logic_vector(NBIT_PILOTS_EQ_CT-1 downto 0);
  signal pilot_p7_q_eq     : std_logic_vector(NBIT_PILOTS_EQ_CT-1 downto 0);
  signal pilot_p21_i_eq    : std_logic_vector(NBIT_PILOTS_EQ_CT-1 downto 0);
  signal pilot_p21_q_eq    : std_logic_vector(NBIT_PILOTS_EQ_CT-1 downto 0);
  signal ph_m21            : std_logic_vector(NBIT_PH_CT-1 downto 0);
  signal ph_m7             : std_logic_vector(NBIT_PH_CT-1 downto 0);
  signal ph_p7             : std_logic_vector(NBIT_PH_CT-1 downto 0);
  signal ph_p21            : std_logic_vector(NBIT_PH_CT-1 downto 0);
  signal angle_valid       : std_logic;
  signal ext_sto_cpe_valid : std_logic;
  signal eq_done_o         : std_logic;
  signal matrix_data_valid : std_logic;
  signal mag_valid         : std_logic;
  signal sto_meas          : std_logic_vector(NBIT_STO_MEAS_CT-1 downto 0);
  signal cpe_meas          : std_logic_vector(NBIT_CPE_MEAS_CT-1 downto 0);
  signal p11               : std_logic_vector(NBIT_INV_MATRIX_CT-1 downto 0);
  signal p12               : std_logic_vector(NBIT_INV_MATRIX_CT-1 downto 0);
  signal p13               : std_logic_vector(NBIT_INV_MATRIX_CT-1 downto 0);
  signal p14               : std_logic_vector(NBIT_INV_MATRIX_CT-1 downto 0);
  signal p21               : std_logic_vector(NBIT_INV_MATRIX_CT-1 downto 0);
  signal p22               : std_logic_vector(NBIT_INV_MATRIX_CT-1 downto 0);
  signal p23               : std_logic_vector(NBIT_INV_MATRIX_CT-1 downto 0);
  signal p24               : std_logic_vector(NBIT_INV_MATRIX_CT-1 downto 0);
  signal skip_cpe          : std_logic_vector(1 downto 0);
  signal sto_pred          : std_logic_vector(NBIT_PREDICTION_CT-1 downto 0);
  signal cpe_pred          : std_logic_vector(NBIT_PREDICTION_CT-1 downto 0);
  signal weight_ch_m21     : std_logic_vector(NBIT_WEIGHT_CT-1 downto 0);
  signal weight_ch_m7      : std_logic_vector(NBIT_WEIGHT_CT-1 downto 0);
  signal weight_ch_p7      : std_logic_vector(NBIT_WEIGHT_CT-1 downto 0);
  signal weight_ch_p21     : std_logic_vector(NBIT_WEIGHT_CT-1 downto 0);
  signal estimate_done     : std_logic;

begin


  equalize_pilots2_i1 : equalize_pilots
    port map (clk               => clk,
              reset_n           => reset_n,
              sync_reset_n      => sync_reset_n,
              start_of_symbol_i => start_of_symbol_i,
              start_of_burst_i  => start_of_burst_i,
              -- pilots from fft
              pilot_p21_i_i     => pilot_p21_i_i,
              pilot_p21_q_i     => pilot_p21_q_i,
              pilot_p7_i_i      => pilot_p7_i_i,
              pilot_p7_q_i      => pilot_p7_q_i,
              pilot_m21_i_i     => pilot_m21_i_i,
              pilot_m21_q_i     => pilot_m21_q_i,
              pilot_m7_i_i      => pilot_m7_i_i,
              pilot_m7_q_i      => pilot_m7_q_i,
              -- channel coefficients
              ch_m21_coef_i_i => ch_m21_coef_i_i,
              ch_m21_coef_q_i => ch_m21_coef_q_i,
              ch_m7_coef_i_i  => ch_m7_coef_i_i,
              ch_m7_coef_q_i  => ch_m7_coef_q_i,
              ch_p7_coef_i_i  => ch_p7_coef_i_i,
              ch_p7_coef_q_i  => ch_p7_coef_q_i,
              ch_p21_coef_i_i => ch_p21_coef_i_i,
              ch_p21_coef_q_i => ch_p21_coef_q_i,
              -- equalized pilots
              pilot_p21_i_o     => pilot_p21_i_eq,
              pilot_p21_q_o     => pilot_p21_q_eq,
              pilot_p7_i_o      => pilot_p7_i_eq,
              pilot_p7_q_o      => pilot_p7_q_eq,
              pilot_m21_i_o     => pilot_m21_i_eq,
              pilot_m21_q_o     => pilot_m21_q_eq,
              pilot_m7_i_o      => pilot_m7_i_eq,
              pilot_m7_q_o      => pilot_m7_q_eq,

              eq_done_o => eq_done_o
              );



  comp_angle_i1 : comp_angle
    generic map (Nbit_ph_g     => NBIT_PH_CT,
                 Nbit_pilots_g => NBIT_PILOTS_EQ_CT,
                 Nbit_pred_g   => NBIT_PREDICTION_CT
                 )

    port map(clk           => clk,
             reset_n       => reset_n,
             sync_reset_n  => sync_reset_n,
             data_valid_i  => eq_done_o,
             pilot_p21_i_i => pilot_p21_i_eq,
             pilot_p21_q_i => pilot_p21_q_eq,
             pilot_p7_i_i  => pilot_p7_i_eq,
             pilot_p7_q_i  => pilot_p7_q_eq,
             pilot_m21_i_i => pilot_m21_i_eq,
             pilot_m21_q_i => pilot_m21_q_eq,
             pilot_m7_i_i  => pilot_m7_i_eq,
             pilot_m7_q_i  => pilot_m7_q_eq,
             cpe_pred_i    => cpe_pred,
             sto_pred_i    => sto_pred,

             data_valid_o => angle_valid,
             ph_m21_o     => ph_m21,
             ph_m7_o      => ph_m7,
             ph_p7_o      => ph_p7,
             ph_p21_o     => ph_p21
             );


  ext_sto_cpe_i1 : ext_sto_cpe
    generic map(Nbit_ph_g         => NBIT_PH_CT,
                Nbit_inv_matrix_g => NBIT_INV_MATRIX_CT
                )

    port map(clk                 => clk,
             reset_n             => reset_n,
             sync_reset_n        => sync_reset_n,
             matrix_data_valid_i => matrix_data_valid,
             cordic_data_valid_i => angle_valid,
             ph_m21_i            => ph_m21,
             ph_m7_i             => ph_m7,
             ph_p7_i             => ph_p7,
             ph_p21_i            => ph_p21,
             p11_i               => p11,
             p12_i               => p12,
             p13_i               => p13,
             p14_i               => p14,
             p21_i               => p21,
             p22_i               => p22,
             p23_i               => p23,
             p24_i               => p24,
             data_valid_o        => ext_sto_cpe_valid,
             sto_meas_o          => sto_meas,
             cpe_meas_o          => cpe_meas
             );



  kalman_i1 : kalman
    generic map(Nbit_sto_meas_g   => NBIT_STO_MEAS_CT,
                Nbit_cpe_meas_g   => NBIT_CPE_MEAS_CT,
                Nbit_prediction_g => NBIT_PREDICTION_CT)

    port map(clk              => clk,
             reset_n          => reset_n,
             sync_reset_n     => sync_reset_n,
             start_of_burst_i => start_of_burst_i,
             sto_cpe_valid_i  => ext_sto_cpe_valid,
             sto_measured_i   => sto_meas,
             cpe_measured_i   => cpe_meas,
             skip_cpe_i       => skip_cpe,
             data_ready_o     => estimate_done,
             sto_pred_o       => sto_pred,
             cpe_pred_o       => cpe_pred
             );




  est_mag_i1 : est_mag
    port map(clk             => clk,
             reset_n         => reset_n,
             sync_reset_n    => sync_reset_n,
             data_valid_i    => ch_valid_i,
             ch_m21_coef_i_i => ch_m21_coef_i_i,
             ch_m21_coef_q_i => ch_m21_coef_q_i,
             ch_m7_coef_i_i  => ch_m7_coef_i_i,
             ch_m7_coef_q_i  => ch_m7_coef_q_i,
             ch_p7_coef_i_i  => ch_p7_coef_i_i,
             ch_p7_coef_q_i  => ch_p7_coef_q_i,
             ch_p21_coef_i_i => ch_p21_coef_i_i,
             ch_p21_coef_q_i => ch_p21_coef_q_i,
             data_valid_o    => mag_valid,
             weight_ch_m21_o => weight_ch_m21,
             weight_ch_m7_o  => weight_ch_m7,
             weight_ch_p7_o  => weight_ch_p7,
             weight_ch_p21_o => weight_ch_p21
             );


  inv_matrix_i1 : inv_matrix
    generic map(Nbit_weight_g     => NBIT_WEIGHT_CT,
                Nbit_inv_matrix_g => NBIT_INV_MATRIX_CT
                )

    port map(clk             => clk,
             reset_n         => reset_n,
             sync_reset_n    => sync_reset_n,
             data_valid_i    => mag_valid,
             weight_ch_m21_i => weight_ch_m21,
             weight_ch_m7_i  => weight_ch_m7,
             weight_ch_p7_i  => weight_ch_p7,
             weight_ch_p21_i => weight_ch_p21,
             p11_o           => p11,
             p12_o           => p12,
             p13_o           => p13,
             p14_o           => p14,
             p21_o           => p21,
             p22_o           => p22,
             p23_o           => p23,
             p24_o           => p24,
             data_valid_o    => matrix_data_valid,
             -- debug signals
             p11_dbg         => p11_f_dbg,
             p12_dbg         => p12_f_dbg,
             p13_dbg         => p13_f_dbg,
             p14_dbg         => p14_f_dbg,
             p21_dbg         => p21_f_dbg,
             p22_dbg         => p22_f_dbg,
             p23_dbg         => p23_f_dbg,
             p24_dbg         => p24_f_dbg
             );


  mon_sto_cpe_i1 : mon_sto_cpe
    generic map(nbit_sto_cpe_g => NBIT_PREDICTION_CT
                )
    port map(clk               => clk,
             reset_n           => reset_n,
             sync_reset_n      => sync_reset_n,
             data_valid_i      => estimate_done,
             start_of_burst_i  => start_of_burst_i,
             sto_i             => sto_pred,
             cpe_i             => cpe_pred,
             skip_cpe_o        => skip_cpe
             );

-- signal assignments
  estimate_done_o <= estimate_done;
  sto_o           <= sto_pred;
  cpe_o           <= cpe_pred;
  skip_cpe_o      <= skip_cpe;

-- assign debug signals
  -- equalized pilots 
  pilot_p21_i_dbg     <= pilot_p21_i_eq;
  pilot_p21_q_dbg     <= pilot_p21_q_eq;
  pilot_p7_i_dbg      <= pilot_p7_i_eq;
  pilot_p7_q_dbg      <= pilot_p7_q_eq;
  pilot_m21_i_dbg     <= pilot_m21_i_eq;
  pilot_m21_q_dbg     <= pilot_m21_q_eq;
  pilot_m7_i_dbg      <= pilot_m7_i_eq;
  pilot_m7_q_dbg      <= pilot_m7_q_eq;
  equalize_done_dbg   <= eq_done_o;
  -- unwrapped cordic phases
  ph_m21_dbg          <= ph_m21;
  ph_m7_dbg           <= ph_m7;
  ph_p7_dbg           <= ph_p7;
  ph_p21_dbg          <= ph_p21;
  cordic_done_dbg     <= angle_valid;
  -- ext_sto_cpe
  sto_meas_dbg        <= sto_meas;
  cpe_meas_dbg        <= cpe_meas;
  ext_done_dbg        <= ext_sto_cpe_valid;
  -- est_mag
  weight_ch_m21_dbg   <= weight_ch_m21;
  weight_ch_m7_dbg    <= weight_ch_m7;
  weight_ch_p7_dbg    <= weight_ch_p7;
  weight_ch_p21_dbg   <= weight_ch_p21;
  est_mag_done_dbg    <= mag_valid;
  -- inv_matrix
  p11_dbg             <= p11;
  p12_dbg             <= p12;
  p13_dbg             <= p13;
  p14_dbg             <= p14;
  p21_dbg             <= p21;
  p22_dbg             <= p22;
  p23_dbg             <= p23;
  p24_dbg             <= p24;
  inv_matrix_done_dbg <= matrix_data_valid;
    
end rtl;
