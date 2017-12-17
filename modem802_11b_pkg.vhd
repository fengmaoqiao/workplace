

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: modem802_11b_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.62   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for modem802_11b.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/modem802_11b/vhdl/rtl/modem802_11b_pkg.vhd,v  
--  Log: modem802_11b_pkg.vhd,v  
-- Revision 1.62  2005/09/20 09:54:01  arisse
-- #BugId:1386#
-- Removed agc_cca block which is not used anymore.
--
-- Revision 1.61  2005/03/01 16:16:31  arisse
-- #BugId:983#
-- Added globals.
--
-- Revision 1.60  2005/02/11 14:51:44  arisse
-- #BugId:953#
-- Removed resynchronization of Rho (bus).
-- Added globals.
--
-- Revision 1.59  2005/01/24 15:34:17  arisse
-- #BugId:624,684,795#
-- Added interp_max_stage.
-- Added generic for front-end registers.
--
-- Revision 1.58  2004/12/22 13:40:29  arisse
-- #BugId:854#
-- Added hard-coded registers rxlenchken and rxmaxlength.
--
-- Revision 1.57  2004/12/20 16:24:22  arisse
-- #BugId:596#
-- Updated tx_path_core with txv_immstop for BT Co-existence.
--
-- Revision 1.56  2004/12/14 16:52:52  arisse
-- #BugId:596#
-- Added BT Co-existence feature.
--
-- Revision 1.55  2004/09/13 08:46:20  arisse
-- Added modemb_registers_if block.
--
-- Revision 1.54  2004/08/24 13:43:06  arisse
-- Added globals for testbench.
--
-- Revision 1.53  2004/05/05 09:05:32  pbressy
-- updated package
--
-- Revision 1.52  2004/05/03 16:40:26  pbressy
-- removed modem11b
--
-- Revision 1.51  2004/04/27 09:46:00  arisse
-- Updated mu in rx_path_core.
--
-- Revision 1.50  2004/03/24 18:09:32  arisse
-- Went back to version 1.48.
--
-- Revision 1.49  2004/03/24 17:44:06  arisse
-- Removed modem802_11b.vhd.
--
-- Revision 1.48  2004/02/10 14:39:01  Dr.C
-- Updated core.
--
-- Revision 1.47  2003/12/03 09:38:48  arisse
-- Resynchronization of signals.
--
-- Revision 1.46  2003/12/02 09:32:41  arisse
-- Modified registers declaration.
--
-- Revision 1.45  2003/11/28 17:13:59  arisse
-- Resynchronized ed_stat and cca_busy.
--
-- Revision 1.44  2003/11/03 15:10:22  Dr.B
-- add txenddel.
--
-- Revision 1.43  2003/10/16 16:34:21  arisse
-- Changed diag_error_i/q to 8 bits instead of 9 bits.
--
-- Revision 1.42  2003/10/16 14:22:54  arisse
-- Added diag ports.
--
-- Revision 1.41  2003/10/13 08:39:33  Dr.C
-- Updated core.
--
-- Revision 1.40  2003/10/09 08:50:07  Dr.B
-- Updated modemb_registers port with reg_interfildisb output.
--
-- Revision 1.39  2003/10/09 08:15:43  Dr.B
-- Added interfildisb and scaling ports.
--
-- Revision 1.38  2003/09/09 13:32:44  Dr.C
-- Updated rx_path_core.
--
-- Revision 1.37  2003/07/29 06:32:30  Dr.F
-- port map changed.
--
-- Revision 1.36  2003/07/28 07:18:13  Dr.B
-- remove clk.
--
-- Revision 1.35  2003/07/26 15:19:08  Dr.F
-- added clk port on modem802_11b_core.
--
-- Revision 1.34  2003/07/25 17:23:11  Dr.B
-- new port of modemb_core (new linked to rx_b_frontend).
--
-- Revision 1.33  2003/07/18 09:04:33  Dr.B
-- fir_phi_out_tog + tx_activated changed.
--
-- Revision 1.32  2003/04/29 09:21:38  Dr.C
-- Added tx_path_core & rx_path_core.
--
-- Revision 1.31  2003/04/08 14:06:24  Dr.J
-- Added dc_offset disable
--
-- Revision 1.30  2003/02/13 07:53:11  Dr.C
-- Added adcpdmod
--
-- Revision 1.29  2003/02/11 20:21:24  Dr.C
-- Added agc diag port
--
-- Revision 1.28  2003/01/20 11:40:55  Dr.C
-- Added agc disable
--
-- Revision 1.27  2003/01/09 15:33:02  Dr.F
-- updated registers and agc port map.
--
-- Revision 1.26  2002/12/03 13:28:45  Dr.F
-- added sfd_detect_enable.
--
-- Revision 1.25  2002/11/28 10:29:09  Dr.A
-- Registers update for v0.17 + agc_cca update.
--
-- Revision 1.24  2002/11/26 08:22:34  Dr.F
-- added plcp_error.
--
-- Revision 1.23  2002/11/07 16:30:28  Dr.F
-- port map changed.
--
-- Revision 1.22  2002/11/06 17:37:14  Dr.A
-- Misc update.
--
-- Revision 1.21  2002/11/05 10:26:31  Dr.F
-- port map changed.
--
-- Revision 1.20  2002/10/31 16:32:05  Dr.J
-- New AGC and RX Path
--
-- Revision 1.19  2002/10/29 17:33:21  Dr.A
-- rx_path update.
--
-- Revision 1.18  2002/10/27 10:49:10  Dr.C
-- Updated agc_cca port map and added new ports for radio controller
--
-- Revision 1.17  2002/10/21 14:05:59  Dr.F
-- port map changed.
--
-- Revision 1.16  2002/10/10 15:31:37  Dr.F
-- port changed.
--
-- Revision 1.15  2002/10/04 16:25:48  Dr.A
-- New registers block.
--
-- Revision 1.14  2002/09/20 15:14:59  Dr.F
-- port map changed.
--
-- Revision 1.13  2002/09/12 14:25:42  Dr.F
-- added comp_disb to disable the error calculation.
--
-- Revision 1.12  2002/09/09 14:24:57  Dr.F
-- registers and agc_cca changed.
--
-- Revision 1.11  2002/08/08 16:57:12  Dr.F
-- port map changed.
--
-- Revision 1.10  2002/07/31 16:12:10  Dr.F
-- ports changed and added rx_ctrl.
--
-- Revision 1.9  2002/07/12 13:08:01  Dr.A
-- Updated registers, tx_path, rx_path.
--
-- Revision 1.8  2002/07/11 13:30:25  Dr.F
-- port map changed.
--
-- Revision 1.7  2002/07/03 16:27:36  Dr.F
-- added rx_path and agc_cca.
--
-- Revision 1.6  2002/06/14 16:51:54  Dr.F
-- added rx ports.
--
-- Revision 1.5  2002/06/07 13:22:35  Dr.A
-- Added component declarations.
--
-- Revision 1.4  2002/06/03 16:17:49  Dr.A
-- Changed paddr size.
--
-- Revision 1.3  2002/04/30 07:29:53  Dr.B
-- paddr changed.
--
-- Revision 1.2  2002/02/06 17:50:09  Dr.B
-- tx_path port map -> modem port map corrected.
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
package modem802_11b_pkg is


-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  signal signal_quality_int_gbl : std_logic_vector(24 downto 0); 
--  signal synctime_enable_gbl    : std_logic;
--  signal applied_beta_gbl       : std_logic_vector( 2 downto 0);
--  signal applied_alpha_gbl      : std_logic_vector( 2 downto 0);
--  signal rx_data_gbl            : std_logic_vector(7 downto 0);
--  
--  signal cca_busy_gbl           : std_logic;
--  signal equalizer_activate_gbl : std_logic;
--  signal equalizer_disb_gbl     : std_logic;
--  signal equalizer_init_n_gbl   : std_logic;
--  signal reset_n_modem_gbl      : std_logic;
--  signal phy_data_ind_bcore_gbl       : std_logic; -- received byte ready                  
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/rx_path/vhdl/rtl/rx_path.vhd
----------------------
  component rx_path

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
    reset_n           : in  std_logic;  -- Global reset.
    clk               : in  std_logic;  -- Clock for Modem 802.11b (44 Mhz).
    rx_path_b_gclk    : in  std_logic;  -- Gated Clock for RX Path (44 Mhz).
    --
    clkskip           : out std_logic;  -- skip one clock cycle in RX path

    --------------------------------------------
    -- Data In.
    --------------------------------------------
    data_in_i         : in  std_logic_vector(6 downto 0);
    data_in_q         : in  std_logic_vector(6 downto 0);

    --------------------------------------------
    -- Control for 2's_complement.
    --------------------------------------------
    c2disb            : in  std_logic;  -- disable the 2's Complement when high 

    --------------------------------------------
    -- Control for interpolator.
    --------------------------------------------
    interp_disb       : in  std_logic;  -- disable the interpolation when high 
    clock_lock        : in  std_logic;  -- High when the clocks are locked.
    tlockdisb         : in  std_logic;  -- Use clock_lock input when low.

    --------------------------------------------
    -- Control for RX filter.
    --------------------------------------------
    rx_filter_disable : in  std_logic;  -- disable rx_filter when high 

    --------------------------------------------
    -- Control for gain compensation.
    --------------------------------------------
    gain_enable       : in  std_logic;  -- enable gain compensation when high
    
    --------------------------------------------
    -- Control for dc_offset compensation.
    --------------------------------------------
    dcoffdisb         : in  std_logic;  -- disable dc_offset compensation when high

    --------------------------------------------
    -- Control for IQ Mismatch Compensation
    --------------------------------------------
    iq_estimation_enable   : in  std_logic;  -- enable the I/Q estimation when high
    iq_compensation_enable : in  std_logic;  -- enable the I/Q compensation when high

    --------------------------------------------
    -- Control for equalization
    --------------------------------------------
    equ_activate      : in  std_logic;  -- enable the equalizer when high.
    equalizer_disb    : in  std_logic;  -- disable the equalizer filter when high.
    equalizer_init_n  : in  std_logic;  -- equalizer filter coeffs set to 0 when low.
    alpha_accu_disb   : in  std_logic;  -- stop coeff accu when high.
    beta_accu_disb    : in  std_logic;  -- stop dc accu when high.
    alpha             : in  std_logic_vector(2 downto 0);  -- alpha parameter value.
    beta              : in  std_logic_vector(2 downto 0);  -- beta parameter value.

    --------------------------------------------
    -- Control for DSSS / CCK demodulation
    --------------------------------------------
    rx_enable         : in  std_logic;  -- enable rx path when high 
    mod_type          : in  std_logic;  -- '0' for DSSS, '1' for CCK.
    enable_error      : in  std_logic;  -- Enable error calculation when high.
    precomp_enable    : in  std_logic;  -- Reload the omega accumulator.
    demod_rate        : in  std_logic;  -- '0' for BPSK, '1' for QPSK.
    cck_rate          : in  std_logic;  -- '0' for 5.5 Mhz, '1' for 11 Mhz.
    rho               : in  std_logic_vector(1 downto 0);  -- rho parameter value
    mu                : in  std_logic_vector(1 downto 0);  -- mu parameter value.

    --------------------------------------------
    -- Control for Decode Path
    --------------------------------------------
    scrambling_disb      : in  std_logic;  -- scrambling disable (test mode) 
    decode_path_activate : in  std_logic;  -- enable the differential decoder
    diff_decod_first_val : in  std_logic;  -- initialize the diff_decoder block
    sfd_detect_enable    : in  std_logic;  -- enable the sfd detection 
    -- Number of errors allowed.
    sfderr               : in  std_logic_vector (2 downto 0);
    -- Number of pramble bits used for Start Frame Delimiter search.
    sfdlen               : in  std_logic_vector (2 downto 0);
    -- Receive mode: 0=BPSK, 1=QPSK, 2=CCK5.5, 3=CCK11.
    rec_mode             : in  std_logic_vector (1 downto 0);

    --------------------------------------------
    -- Debug interface
    --------------------------------------------
    -- Data In (Only used for the debug).
    data_equa_in_i    : in  std_logic_vector(data_length_g-1 downto 0);
    data_equa_in_q    : in  std_logic_vector(data_length_g-1 downto 0);
    -- Angles (Only used for the debug).
    -- Compensation angle.
    phi               : in  std_logic_vector(angle_length_g-1 downto 0);
    -- Precompensation angle.
    omega             : in  std_logic_vector(11 downto 0);
    -- before equalizer estimation
    sigma             : in  std_logic_vector(9 downto 0);

    --------------------------------------------
    -- Remodulation interface
    --------------------------------------------
    remod_data        : in  std_logic_vector(1 downto 0);  -- Data from the TX path
    --
    remod_enable      : out std_logic;  -- High when the remodulation is enabled
    remod_data_req    : out std_logic;  -- request to send a byte 
    remod_type        : out std_logic;  -- CCK : 0 ; PBCC : 1
    remod_bq          : out std_logic;  -- BPSK = 0 - QPSK = 1 
    demod_data        : out std_logic_vector(7 downto 0);  -- Data to the TX path

    --------------------------------------------
    -- AGC-CCA interface
    --------------------------------------------
    pw_estim_activate : in  std_logic;  -- enable Power estimation when high.
    integration_end   : in  std_logic;  -- Indicates end of integration.
    correl_rst_n      : in  std_logic;  -- reset the Barker correlator when low
    synchro_en        : in  std_logic;  -- enable the synchronisation when high 
    --
    symbol_synchro    : out std_logic;  -- pulse at the beginning of a symbol.
    power_estimation  : out std_logic_vector(20 downto 0); -- Integrated value.
    signal_quality    : out std_logic_vector(24 downto 0); -- Signal quality.

    --------------------------------------------
    -- Modem B state machines interface
    --------------------------------------------
    sfd_found         : out std_logic;  -- sfd found when high
    preamble_type     : out std_logic;  -- Type of preamble 
    phy_data_ind      : out std_logic;  -- pulse when an RX byte is available.
    data_to_bup       : out std_logic_vector(7 downto 0); -- RX data.
    -------------------------------
    -- Diag ports
    -------------------------------
    diag_error_i     : out std_logic_vector(data_length_g-2 downto 0); 
    diag_error_q     : out std_logic_vector(data_length_g-2 downto 0)
    );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/rx_path/vhdl/rtl/rx_path_core.vhd
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


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/tx_path/vhdl/rtl/tx_path_core.vhd
----------------------
  component tx_path_core
  generic(
   dec_freq_g : integer := 1 -- shift the register every dec_freq_g period.
                               -- (1 to 8) - should correspond to 11 MHz.
          );
  port (
   -- clocks and reset
   clk                : in  std_logic;
   reset_n            : in  std_logic;
   
   --------------------------------------------
   -- Interface with Modem State Machines
   --------------------------------------------
   low_r_flow_activate: in  std_logic;   
   --                   made high by the state machines for 1 or 2 Mb/s trans
   psk_mode           : in  std_logic;    
   --                   BPSK = 0 - QPSK = 1
   shift_period       : in  std_logic_vector (3 downto 0); 
   --                   period to shift of the serializer (1010 for low rate)  
   cck_flow_activate  : in  std_logic;            
   --                   made high by the state machines for CCK 5.5 or 11 Mb/s
   cck_speed          : in  std_logic;                     
   --                   5.5 Mbits/s = 0 - 11 Mbits/s = 1
   tx_activated       : out std_logic;
   --                   indicate to the sm when the tx_path is activated
   
   --------------------------------------------
   -- Interface with Wild Bup - via or not Modem State Machines
   --------------------------------------------
   -- inputs signals                                                           
   scrambling_disb    : in std_logic;
   --                   disable the scrambler when high (for modem tests) 
   spread_disb        : in std_logic;
   --                   disable the spreading when high (for modem tests) 
   bup_txdata         : in  std_logic_vector(7 downto 0); 
   --                   data to send
   phy_data_req       : in  std_logic; 
   --                   request to send a byte                  
   txv_prtype         : in  std_logic; 
   --                   def the type of preamble (short or long)
   txv_immstop        : in std_logic;
   --                   for BT co-existence, stop tx immediately if high.
   -- outputs signals                                                          
   phy_data_conf      : out std_logic; 
   --                   last byte was read, ready for new one 

   --------------------------------------------
   -- Interface with the RX Path for the remodulation
   --------------------------------------------
   remod_enable     : in  std_logic; -- High when the remodulation is enabled
   remod_data_req   : in  std_logic; -- request to send a byte 
   remod_type       : in  std_logic; -- CCK : 0 ; PBCC : 1
   remod_bq         : in  std_logic; -- BPSK = 0 - QPSK = 1 
   demod_data       : in  std_logic_vector(7 downto 0); -- Data to the TX path
   --
   remod_data       : out std_logic_vector(1 downto 0); -- Data from the TX path

   --------------------------------------------
   -- FIR controls
   --------------------------------------------
   init_fir         : out std_logic;
   fir_activate     : out std_logic;
   fir_phi_out_tog_o: out std_logic; -- when toggle a new data has arrived
   fir_phi_out      : out std_logic_vector (1 downto 0)
   );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/modem_sm_b/vhdl/rtl/modem_sm_b.vhd
----------------------
  component modem_sm_b
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- TX path block
    -------------------------------------- 
    seria_data_conf     : in  std_logic; -- Serializer is ready for new data
    tx_activated        : in  std_logic; -- the tx_path is transmitting    
    -- 
    scr_data_in         : out std_logic_vector(7 downto 0); -- data sent to scrambler
    sm_data_req         : out std_logic; -- State machines data request
    tx_psk_mode         : out std_logic; -- 0 = BPSK; 1 = QPSK
    activate_seria      : out std_logic; -- activate Serializer
    shift_period        : out std_logic_vector(3 downto 0); -- Serializer speed
    activate_cck        : out std_logic; -- activate CCK modulator
    tx_cck_rate         : out std_logic; -- CCK speed (0 = 5.5 Mbit/s; 1 = 11 Mbit/s)
    preamble_type_tx    : out std_logic; -- preamble type (0 = short; 1 = long)
    --------------------------------------
    -- RX path block
    -------------------------------------- 
    cca_busy            : in  std_logic; -- CCA busy
    preamble_type_rx    : in  std_logic; -- 1: long preamble ; 0: short preamble
    sfd_found           : in  std_logic; -- pulse when SFD is detected
    byte_ind            : in  std_logic; -- byte indication  
    rx_data             : in  std_logic_vector(7 downto 0); -- rx descrambled data
    --
    decode_path_activate: out std_logic; -- decode path activate
    diff_decod_first_val: out std_logic; -- pulse on first byte to decode
    rec_mode            : out std_logic_vector(1 downto 0); -- BPSK, QPSK, CCK5.5, CCK 11
    mod_type            : out std_logic; -- 0 : DSSS ; 1 : CCK
    rx_psk_mode         : out std_logic; -- 0 = BPSK; 1 = QPSK
    rx_cck_rate         : out std_logic; -- CCK rate (0 = 5.5 Mb/s; 1 = 11 Mb/s)
    rx_idle_state       : out std_logic; -- high when sm is idle
    rx_plcp_state       : out std_logic; -- high when sm is in plcp state
    --------------------------------------------
    -- Registers
    --------------------------------------------
    reg_prepre          : in  std_logic_vector(5 downto 0); -- pre-preamble count.
    txenddel_reg        : in  std_logic_vector(7 downto 0);
    rxlenchken          : in  std_logic; -- select ckeck on rx data lenght.
    rxmaxlength         : in  std_logic_vector(11 downto 0); -- Max accepted received length.    
    --------------------------------------------
    -- CCA
    --------------------------------------------
    psdu_duration       : out std_logic_vector(15 downto 0); --length in us
    correct_header      : out std_logic; -- high when header is correct.
    plcp_error          : out std_logic; -- high when plcp error occures
    listen_start_o      : out std_logic; -- high when start to listen
   --------------------------------------
    -- CRC
    -------------------------------------- 
    crc_data_1st        : in  std_logic_vector(7 downto 0); -- CRC data
    crc_data_2nd        : in  std_logic_vector(7 downto 0); -- CRC data
    --
    crc_init            : out std_logic; -- init CRC computation
    crc_data_valid      : out std_logic; -- compute CRC on packet header
    data_to_crc         : out std_logic_vector(7 downto 0); -- byte data to CRC
    --------------------------------------------
    -- Radio controller interface
    --------------------------------------------
    rf_txonoff_req     : out std_logic;  -- tx on off request
    rf_txonoff_conf    : in  std_logic;  -- tx on off confirmation
    rf_rxonoff_req     : out std_logic;  -- rx on off request
    rf_rxonoff_conf    : in  std_logic;  -- rx on off confirmation
    --------------------------------------
    -- BuP
    -------------------------------------- 
    -- TX
    phy_txstartend_req  : in  std_logic; -- request to start a packet transmission
                                         -- or request for end of transmission
    txv_service         : in  std_logic_vector(7 downto 0); -- service field
    phy_data_req        : in  std_logic; -- request from BuP to send a byte
    txv_datarate        : in  std_logic_vector( 3 downto 0); -- PSDU transmission rate
    txv_length          : in  std_logic_vector(11 downto 0); -- packet length in bytes
    bup_txdata          : in  std_logic_vector( 7 downto 0); -- data from BuP
    phy_txstartend_conf : out std_logic; -- transmission started, ready for data
                                         -- or transmission ended
    txv_immstop         : in std_logic;  -- request from Bup to stop tx.
    -- RX
    phy_cca_ind         : out  std_logic; -- indication of a carrier
    phy_rxstartend_ind  : out  std_logic; -- indication of a received PSDU
    rxv_service         : out  std_logic_vector(7 downto 0); -- service field
    phy_data_ind        : out  std_logic; -- indication of a received byte
    rxv_datarate        : out  std_logic_vector( 3 downto 0); -- PSDU RX rate
    rxv_length          : out  std_logic_vector(11 downto 0); -- packet length in bytes
    rxe_errorstat       : out  std_logic_vector(1 downto 0); -- error
    bup_rxdata          : out  std_logic_vector( 7 downto 0);  -- data to BuP
    --------------------------------------
    -- Diag
    --------------------------------------
    rx_state_diag       : out std_logic_vector(2 downto 0)  -- Diag port
    );
  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/rx_ctrl/vhdl/rtl/rx_ctrl.vhd
----------------------
  component rx_ctrl
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.

    --------------------------------------------
    -- Registers interface
    --------------------------------------------
    eq_disb             : in std_logic; --equalizer disable
    -- delay before enabling the precompensation :
    precomp             : in  std_logic_vector(5 downto 0); 
    -- delay before enabling the equalizer after energy detect
    eqtime              : in  std_logic_vector(3 downto 0); 
    -- delay before disabling the equalizer after last parameter update
    eqhold              : in  std_logic_vector(11 downto 0); 
    -- delay before enabling the phase correction after energy detect
    looptime            : in  std_logic_vector(3 downto 0); 
    -- delay before switching off the timing synchro after energy detect
    synctime            : in  std_logic_vector(5 downto 0); 
    -- initial value of equalizer parameters
    alpha               : in  std_logic_vector(1 downto 0); 
    beta                : in  std_logic_vector(1 downto 0); 
    -- initial value of phase estimation parameters
    mu                  : in  std_logic_vector(1 downto 0); 
    -- Talpha time intervals values for alpha equalizer parameter.
    talpha3             : in  std_logic_vector( 3 downto 0);
    talpha2             : in  std_logic_vector( 3 downto 0);
    talpha1             : in  std_logic_vector( 3 downto 0);
    talpha0             : in  std_logic_vector( 3 downto 0);
    -- Tbeta time intervals values for beta equalizer parameter.
    tbeta3              : in  std_logic_vector( 3 downto 0);
    tbeta2              : in  std_logic_vector( 3 downto 0);
    tbeta1              : in  std_logic_vector( 3 downto 0);
    tbeta0              : in  std_logic_vector( 3 downto 0);
    -- Tmu time interval value for phase correction mu parameter.
    tmu3                : in  std_logic_vector( 3 downto 0);
    tmu2                : in  std_logic_vector( 3 downto 0);
    tmu1                : in  std_logic_vector( 3 downto 0);
    tmu0                : in  std_logic_vector( 3 downto 0);

    --------------------------------------------
    -- Input control
    --------------------------------------------
    energy_detect       : in  std_logic;
    agcproc_end         : in  std_logic; -- pulse on AGC procedure end
    rx_psk_mode         : in  std_logic; -- 0 = BPSK; 1 = QPSK
    rx_idle_state       : in  std_logic;
    precomp_disb        : in  std_logic; -- disable the precompensation 
    comp_disb           : in  std_logic; -- disable the compensation 
                                         -- (error calculation)
    iqmm_disb           : in  std_logic; -- disable iq mismatch
    gain_disb           : in  std_logic; -- disable gain

    --------------------------------------------
    -- RX path control signals
    --------------------------------------------
    equalizer_activate  : out std_logic; -- equalizer enable
    equalizer_init_n    : out std_logic; -- equalizer initialization
    equalizer_disb      : out std_logic; -- equalizer disable
    precomp_enable      : out std_logic; -- frequency precompensation enable
    synctime_enable     : out std_logic; -- timing synchronization enable
    phase_estim_enable  : out std_logic; -- phase estimation enable
    iq_comp_enable      : out std_logic; -- iq mismatch compensation enable
    iq_estim_enable     : out std_logic; -- iq mismatch estimation enable
    gain_enable         : out std_logic; -- gain enable
    sfd_detect_enable   : out std_logic; -- enable SFD detection when high
    -- parameters value sent to the equalizer
    applied_alpha       : out std_logic_vector(2 downto 0);
    applied_beta        : out std_logic_vector(2 downto 0);
    alpha_accu_disb     : out std_logic;
    beta_accu_disb      : out std_logic;
    -- parameters value sent to the phase estimation
    applied_mu          : out std_logic_vector(2 downto 0)
    );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/modemb_registers/vhdl/rtl/modemb_registers.vhd
----------------------
  component modemb_registers
  generic (
    radio_interface_g : integer := 2   -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n         : in  std_logic; -- Reset.
    pclk            : in  std_logic; -- APB clock.

    --------------------------------------------
    -- APB slave
    --------------------------------------------
    psel            : in  std_logic; -- Device select.
    penable         : in  std_logic; -- Defines the enable cycle.
    paddr           : in  std_logic_vector( 5 downto 0); -- Address.
    pwrite          : in  std_logic; -- Write signal.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata          : out std_logic_vector(31 downto 0); -- Read data.
  
    --------------------------------------------
    -- Modem Registers Inputs
    --------------------------------------------

    -- MDMbSTAT0 register. 
    reg_eqsumq : in std_logic_vector(7 downto 0);
    reg_eqsumi : in std_logic_vector(7 downto 0);  
    reg_dcoffsetq : in std_logic_vector(5 downto 0);
    reg_dcoffseti : in std_logic_vector(5 downto 0);

    -- MDMbSTAT1 register.
    reg_iqgainestim : in std_logic_vector(6 downto 0);
    reg_freqoffestim : in std_logic_vector(7 downto 0);
    
    --------------------------------------------
    -- Modem Registers Outputs
    --------------------------------------------
    -- MDMbCNTL register.
    reg_tlockdisb        : out std_logic; -- '0': use timing lock from service field.
    reg_rxc2disb         : out std_logic; -- '1' to disable 2 complement.
    reg_interpdisb       : out std_logic; -- '0' to enable interpolator.
    reg_iqmmdisb         : out std_logic; -- '0' to enable I/Q mismatch compensation.
    reg_gaindisb         : out std_logic; -- '0' to enable the gain compensation.
    reg_precompdisb      : out std_logic; -- '0' to enable timing offset compensation
    reg_dcoffdisb        : out std_logic; -- '0' to enable the DC offset compensation
    reg_compdisb         : out std_logic; -- '0' to enable the compensation.
    reg_eqdisb           : out std_logic; -- '0' to enable the Equalizer.
    reg_firdisb          : out std_logic; -- '0' to enable the FIR.
    reg_spreaddisb       : out std_logic; -- '0' to enable spreading.                        
    reg_scrambdisb       : out std_logic; -- '0' to enable scrambling.
    reg_sfderr           : out std_logic_vector( 2 downto 0); -- Error number for SFD
    reg_interfildisb     : out std_logic; -- '1' to bypass rx_11b_interf_filter 
    reg_txc2disb         : out std_logic; -- '1' to disable 2 complement.   
    -- Number of preamble bits to be considered in short SFD comparison.
    reg_sfdlen      : out std_logic_vector( 2 downto 0);
    reg_prepre      : out std_logic_vector( 5 downto 0); -- pre-preamble count.
    
    -- MDMbPRMINIT register.
    -- Values for phase correction parameters.
    reg_rho         : out std_logic_vector( 1 downto 0);
    reg_mu          : out std_logic_vector( 1 downto 0);
    -- Values for phase feedforward equalizer parameters.
    reg_beta        : out std_logic_vector( 1 downto 0);
    reg_alpha       : out std_logic_vector( 1 downto 0);

    -- MDMbTALPHA register.
    -- TALPHA time interval value for equalizer alpha parameter.
    reg_talpha3     : out std_logic_vector( 3 downto 0);
    reg_talpha2     : out std_logic_vector( 3 downto 0);
    reg_talpha1     : out std_logic_vector( 3 downto 0);
    reg_talpha0     : out std_logic_vector( 3 downto 0);
    
    -- MDMbTBETA register.
    -- TBETA time interval value for equalizer beta parameter.
    reg_tbeta3      : out std_logic_vector( 3 downto 0);
    reg_tbeta2      : out std_logic_vector( 3 downto 0);
    reg_tbeta1      : out std_logic_vector( 3 downto 0);
    reg_tbeta0      : out std_logic_vector( 3 downto 0);
    
    -- MDMbTMU register.
    -- TMU time interval value for phase correction and offset comp. mu param
    reg_tmu3        : out std_logic_vector( 3 downto 0);
    reg_tmu2        : out std_logic_vector( 3 downto 0);
    reg_tmu1        : out std_logic_vector( 3 downto 0);
    reg_tmu0        : out std_logic_vector( 3 downto 0);

    -- MDMbCNTL1 register.
    reg_rxlenchken  : out std_logic;
    reg_rxmaxlength : out std_logic_vector(11 downto 0);
    
    -- MDMbRFCNTL register.
    -- AC coupling gain compensation.
    -- Value to be sent to the I data before the Tx packets for
    -- auto-calibration of the transmit path.
    reg_txconst     : out std_logic_vector(7 downto 0);
    -- Delay of the Tx front-end inside the WILD RF, in number of 44 MHz cycles.
    reg_txenddel    : out std_logic_vector(7 downto 0);

    -- MDMbCCA register.
    reg_ccamode     : out std_logic_vector( 2 downto 0); -- CCA mode select.

    -- MDMbEQCNTL register.
    -- Delay to stop the equalizer adaptation after the last param update, in 탎
    reg_eqhold      : out std_logic_vector(11 downto 0);
    -- Delay to start the compensation after the start of the estimation, in 탎.
    reg_comptime    : out std_logic_vector( 4 downto 0);
    -- Delay to start the estimation after the enabling of the equalizer, in 탎.
    reg_esttime     : out std_logic_vector( 4 downto 0);
    -- Delay to switch on the equalizer after the fine gain setting, in 탎.
    reg_eqtime      : out std_logic_vector( 3 downto 0);

    -- MDMbCNTL2 register
    reg_maxstage    : out std_logic_vector(5 downto 0);
    reg_precomp     : out std_logic_vector( 5 downto 0); -- in us.
    reg_synctime    : out std_logic_vector( 5 downto 0);
    reg_looptime    : out std_logic_vector( 3 downto 0)
  );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/crc16_8/vhdl/rtl/crc16_8.vhd
----------------------
  component crc16_8
  port (
    -- clock and reset
    clk       : in  std_logic;                    
    resetn    : in  std_logic;                   
     
    -- inputs
    data_in   : in  std_logic_vector ( 7 downto 0);
    --          8-bits inputs for parallel computing. 
    ld_init   : in  std_logic;
    --          initialize the CRC
    calc      : in  std_logic;
    --          ask of calculation of the available data.
 
    -- outputs
    crc_out_1st  : out std_logic_vector (7 downto 0); 
    crc_out_2nd  : out std_logic_vector (7 downto 0) 
    --          CRC result
   );

  end component;


----------------------
-- File: modem802_11b_core.vhd
----------------------
  component modem802_11b_core
  generic (
    radio_interface_g : integer := 3   -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
   -- clocks and reset
   bus_clk             : in  std_logic; -- apb clock
   clk                 : in  std_logic; -- main clock (not gated)
   rx_path_b_gclk      : in  std_logic; -- gated clock for RX path
   tx_path_b_gclk      : in  std_logic; -- gated clock for TX path
   reset_n             : in  std_logic; -- global reset  
   --
   rx_gating           : out std_logic; -- Gating condition for Rx path
   tx_gating           : out std_logic; -- Gating condition for Tx path
  
   --------------------------------------------
   -- APB slave
   --------------------------------------------
   psel                : in  std_logic; -- Device select.
   penable             : in  std_logic; -- Defines the enable cycle.
   paddr               : in  std_logic_vector( 5 downto 0); -- Address.
   pwrite              : in  std_logic; -- Write signal.
   pwdata              : in  std_logic_vector(31 downto 0); -- Write data.
   --
   prdata              : out std_logic_vector(31 downto 0); -- Read data.
  
   --------------------------------------------
   -- Interface with Wild Bup
   --------------------------------------------
   -- inputs signals                                                           
   bup_txdata          : in  std_logic_vector(7 downto 0); -- data to send         
   phy_txstartend_req  : in  std_logic; -- request to start a packet transmission    
   phy_data_req        : in  std_logic; -- request to send a byte                  
   phy_ccarst_req      : in  std_logic; -- request to reset CCA state machine                 
   txv_length          : in  std_logic_vector(11 downto 0);  -- RX PSDU length     
   txv_service         : in  std_logic_vector(7 downto 0);  -- tx service field   
   txv_datarate        : in  std_logic_vector( 3 downto 0); -- PSDU transm. rate
   txpwr_level         : in  std_logic_vector( 2 downto 0); -- TX power level.
   txv_immstop         : in std_logic;  -- request from Bup to stop tx.
    
   -- outputs signals                                                          
   phy_txstartend_conf : out std_logic; -- transmission started, ready for data  
   phy_rxstartend_ind  : out std_logic; -- indication of RX packet                     
   phy_data_conf       : out std_logic; -- last byte was read, ready for new one 
   phy_data_ind        : out std_logic; -- received byte ready                  
   rxv_length          : out std_logic_vector(11 downto 0);  -- RX PSDU length  
   rxv_service         : out std_logic_vector(7 downto 0);  -- rx service field
   rxv_datarate        : out std_logic_vector( 3 downto 0); -- PSDU rec. rate
   rxe_errorstat       : out std_logic_vector(1 downto 0);-- packet recep. stat
   phy_cca_ind         : out std_logic; -- CCA status                           
   bup_rxdata          : out std_logic_vector(7 downto 0); -- data received      
   
   --------------------------------------------
   -- Radio controller interface
   --------------------------------------------
   rf_txonoff_conf     : in  std_logic;  -- Radio controller in TX mode conf
   rf_rxonoff_conf     : in  std_logic;  -- Radio controller in RX mode conf
   --
   rf_txonoff_req      : out std_logic;  -- Radio controller in TX mode req
   rf_rxonoff_req      : out std_logic;  -- Radio controller in RX mode req
   rf_dac_enable       : out std_logic;  -- DAC enable
   
   --------------------------------------------
   -- AGC
   --------------------------------------------
   agcproc_end         : in std_logic;
   cca_busy            : in std_logic;
   correl_rst_n        : in std_logic;
   agc_diag            : in std_logic_vector(15 downto 0);
   --
   psdu_duration       : out std_logic_vector(15 downto 0);
   correct_header      : out std_logic;
   plcp_state          : out std_logic;
   plcp_error          : out std_logic;
   listen_start_o      : out std_logic; -- high when start to listen
   -- registers
   interfildisb        : out std_logic;
   ccamode             : out std_logic_vector( 2 downto 0);
   --
   sfd_found           : out std_logic;
   symbol_sync2        : out std_logic;
   --------------------------------------------
   -- Data Inputs
   --------------------------------------------
   -- data from gain compensation (inside rx_b_frontend)
   rf_rxi              : in  std_logic_vector(7 downto 0);
   rf_rxq              : in  std_logic_vector(7 downto 0);
   
   --------------------------------------------
   -- Disable Tx & Rx filter
   --------------------------------------------
   fir_disb            : out std_logic;
   
   --------------------------------------------
   -- Tx FIR controls
   --------------------------------------------
   init_fir            : out std_logic;
   fir_activate        : out std_logic;
   fir_phi_out_tog_o   : out std_logic;
   fir_phi_out         : out std_logic_vector (1 downto 0);
   tx_const            : out std_logic_vector(7 downto 0);
   txc2disb            : out std_logic; -- Complement's 2 disable (from reg)
   
   --------------------------------------------
   -- Interface with RX Frontend
   --------------------------------------------
   -- Control from Registers
   rxc2disb            : out std_logic; -- Complement's 2 disable (from reg)
   interp_disb         : out std_logic; -- Interpolator disable
   clock_lock          : out std_logic;
   tlockdisb           : out std_logic;  -- use timing lock from service field.
   gain_enable         : out std_logic;  -- gain compensation control.
   tau_est             : out std_logic_vector(17 downto 0);
   enable_error        : out std_logic;
   interpmaxstage      : out std_logic_vector(5 downto 0);
   gaindisb_out        : out std_logic;  -- disable the gain compensation.
   --------------------------------------------
   -- Diagnostic port
   --------------------------------------------
   modem_diag          : out std_logic_vector(31 downto 0);
   modem_diag0         : out std_logic_vector(15 downto 0);
   modem_diag1         : out std_logic_vector(15 downto 0);
   modem_diag2         : out std_logic_vector(15 downto 0)    
  );

  end component;


----------------------
-- File: modemb_registers_if.vhd
----------------------
  component modemb_registers_if
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n : in std_logic;
    hclk    : in std_logic;             -- 44 MHz clock.

    --------------------------------------
    -- Controls
    --------------------------------------
    -- Registers inputs :
    reg_tlockdisb         : in  std_logic;  -- '0': use timing lock from service field.
    reg_rxc2disb          : in  std_logic;  -- '1' to disable 2 complement.
    reg_interpdisb        : in  std_logic;  -- '0' to enable interpolator.
    reg_iqmmdisb          : in  std_logic;  -- '0' to enable I/Q mismatch compensation.
    reg_gaindisb          : in  std_logic;  -- '0' to enable the gain compensation.
    reg_precompdisb       : in  std_logic;  -- '0' to enable timing offset compensation
    reg_dcoffdisb         : in  std_logic;  -- '0' to enable the DC offset compensation
    reg_compdisb          : in  std_logic;  -- '0' to enable the compensation.
    reg_eqdisb            : in  std_logic;  -- '0' to enable the Equalizer.
    reg_firdisb           : in  std_logic;  -- '0' to enable the FIR.
    reg_spreaddisb        : in  std_logic;  -- '0' to enable spreading.                        
    reg_scrambdisb        : in  std_logic;  -- '0' to enable scrambling.
    reg_interfildisb      : in  std_logic;  -- '1' to bypass rx_11b_interf_filter 
    reg_txc2disb          : in  std_logic;  -- '1' to disable 2 complement.   
    -- Registers outputs :
    reg_tlockdisb_sync    : out std_logic;  -- '0': use timing lock from service field.
    reg_rxc2disb_sync     : out std_logic;  -- '1' to disable 2 complement.
    reg_interpdisb_sync   : out std_logic;  -- '0' to enable interpolator.
    reg_iqmmdisb_sync     : out std_logic;  -- '0' to enable I/Q mismatch compensation.
    reg_gaindisb_sync     : out std_logic;  -- '0' to enable the gain compensation.
    reg_precompdisb_sync  : out std_logic;  -- '0' to enable timing offset compensation
    reg_dcoffdisb_sync    : out std_logic;  -- '0' to enable the DC offset compensation
    reg_compdisb_sync     : out std_logic;  -- '0' to enable the compensation.
    reg_eqdisb_sync       : out std_logic;  -- '0' to enable the Equalizer.
    reg_firdisb_sync      : out std_logic;  -- '0' to enable the FIR.
    reg_spreaddisb_sync   : out std_logic;  -- '0' to enable spreading.                        
    reg_scrambdisb_sync   : out std_logic;  -- '0' to enable scrambling.
    reg_interfildisb_sync : out std_logic;  -- '1' to bypass rx_11b_interf_filter 
    reg_txc2disb_sync     : out std_logic   -- '1' to disable 2 complement.   
    );

  end component;



 
end modem802_11b_pkg;
