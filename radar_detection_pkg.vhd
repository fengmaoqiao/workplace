--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 19246 $
--/ $Date: 2011-12-09 11:43:28 +0100 (Fri, 09 Dec 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : Package for radar_detection.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/IPs/WLAN/HW/RW_WLAN_11H/RADAR_DETECT/radar_detection/vhdl/rtl/radar_detection_pkg.vhd $
--/
--////////////////////////////////////////////////////////////////////////////



--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package radar_detection_pkg is

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: /share/projects/WLAN/WLAN_IP_MAXIM/HW/IPs/WLAN/HW/RW_WLAN_11H/RADAR_DETECT/radar_data_processing/vhdl/rtl/radar_data_processing.vhd
----------------------
  component radar_data_processing
  port (
    fe_radar11h_fifo_gclk     : in  std_logic;  -- Clock 
    fe_radar11h_fifo_reset_n  : in  std_logic;  -- active low reset
    en_20m               : in  std_logic;  -- 20MHz data enable   
    -- Registers
    reg_sampledly        : in  std_logic_vector(4 downto 0);  -- SAMPLE DELAY
    reg_sampleadv        : in  std_logic_vector(4 downto 0);  -- SAMPLE ADVANCE
    -- AGC data
    y_radar_i            : in  std_logic_vector(9 downto 0);  -- 20 MHz Data inputs
    y_radar_q            : in  std_logic_vector(9 downto 0);
    y_valid              : in std_logic;
    -- Radar Trigger
    start_algo           : in std_logic; --pulse trigger
    pulse_rise_fall      : in std_logic; --pulse rise: 1, fall:0
    --Radar HW Filtering
    radfom               : out std_logic_vector(3 downto 0);
    radfreq              : out std_logic_vector(5 downto 0);
    fom_valid            : out std_logic;  
    -- Diagnostic Output
    cycle_counter_diag   : out std_logic_vector(3 downto 0);
    control_state_diag   : out std_logic_vector(2 downto 0));
 
  end component;


----------------------
-- File: /share/projects/WLAN/WLAN_IP_MAXIM/HW/IPs/WLAN/HW/RW_WLAN_11H/RADAR_DETECT/radar_registers/vhdl/rtl/radar_registers.vhd
----------------------
  component radar_registers
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n         : in  std_logic; -- Reset.
    pclk            : in  std_logic; -- APB clock.

    --------------------------------------------
    -- Registers
    --------------------------------------------
    -- RADARINTSTAT register.
    npulse_cnt                   : in  std_logic_vector(2 downto 0);
    radar_int                    : in  std_logic;
    -- RADARFIFO register.
    radar_fifo_value             : in  std_logic_vector(31 downto 0);
    -- RADARCNTL register.
    reg_pulse2_satevent_en       : out std_logic;
    reg_pulse_mid_meas_en        : out std_logic;
    reg_pulse2_det_en            : out std_logic;
    -- RADARINTEN register.
    reg_fifo_int_thr             : out std_logic_vector(1 downto 0);
    reg_int_en                   : out std_logic;
    -- RADARAPOWR register.
    reg_apowf_thrdbm_add         : out std_logic_vector(4 downto 0);
    reg_apowf_thrdbm             : out std_logic_vector(6 downto 0);
    reg_apowr_thrdbm             : out std_logic_vector(6 downto 0);
    -- RADARPULSE_CONF1 register.
    reg_pulse2fdbmadd            : out std_logic_vector(4 downto 0);
    reg_pulse2fdbm               : out std_logic_vector(4 downto 0);
    reg_pulse1fdbmadd            : out std_logic_vector(4 downto 0);
    reg_pulse1fdbm               : out std_logic_vector(4 downto 0);
    -- RADARPULSE_CONF2 register.
    reg_pulse2f_cnt              : out std_logic_vector(2 downto 0);
    reg_pulse1f_cnt              : out std_logic_vector(2 downto 0);
    reg_pulse2r_cnt              : out std_logic_vector(2 downto 0);
    reg_pulse1r_cnt              : out std_logic_vector(2 downto 0);
    reg_pulse2f_thrchng          : out std_logic_vector(7 downto 0);
    reg_pulse1f_thrchng          : out std_logic_vector(7 downto 0);
    -- RADARPULSE_CONF3 register.
    reg_pulse_lenmax             : out std_logic_vector(7 downto 0);
    reg_pulse_lenmin             : out std_logic_vector(2 downto 0);
    reg_pulse2_lenmin            : out std_logic_vector(4 downto 0);
    reg_pulse1_lenmin            : out std_logic_vector(4 downto 0);
    reg_pulse2_jmpdbm            : out std_logic_vector(4 downto 0);
    -- RADARPULSE_GAP register.
    reg_pul1f_pul2f_gapmin       : out std_logic_vector(7 downto 0);
    reg_pul2_pul1_gapmin         : out std_logic_vector(8 downto 0);
    reg_pulse_gapmin             : out std_logic_vector(8 downto 0);
    -- RADARDELAY register.
    reg_pow_updtdly              : out std_logic_vector(3 downto 0);
    reg_mid_falldly              : out std_logic_vector(2 downto 0);
    reg_sampledly                : out std_logic_vector(4 downto 0);
    reg_sampleadv                : out std_logic_vector(4 downto 0);
    reg_mid_meas_cnt             : out std_logic_vector(8 downto 0);
    -- RADARFOM register.
    reg_minfreq_fom_len_chk      : out std_logic_vector(5 downto 0);
    reg_pulsef_fom_valid_length  : out std_logic_vector(5 downto 0);
    reg_fom_chk_invalid          : out std_logic_vector(3 downto 0);
    reg_fom_fallmin              : out std_logic_vector(3 downto 0);
    reg_fom_midmin               : out std_logic_vector(3 downto 0);
    reg_fom_risemin              : out std_logic_vector(3 downto 0);
    -- RADARFREQ_CONF1 register.
    reg_freq_to_reject           : out std_logic_vector(5 downto 0);
    reg_freq_chk_invalid         : out std_logic_vector(5 downto 0);
    reg_freq_chkdc               : out std_logic_vector(5 downto 0);
    -- RADARFREQ_CONF2 register.
    reg_freq_fallmax             : out std_logic_vector(5 downto 0);
    reg_freq_fallmin             : out std_logic_vector(5 downto 0);
    reg_freq_risemax             : out std_logic_vector(5 downto 0);
    reg_freq_risemin             : out std_logic_vector(5 downto 0);
    -- RADARFREQ_CONF3 register.
    reg_nonvalid_lenmin          : out std_logic_vector(7 downto 0);
    reg_nonvalid_lenmax          : out std_logic_vector(7 downto 0);
    reg_freq_midmax              : out std_logic_vector(5 downto 0);
    reg_freq_midmin              : out std_logic_vector(5 downto 0);

    fifo_value_read              : out std_logic;
    interrupt                    : out std_logic;   

    --------------------------------------------
    -- APB slave
    --------------------------------------------
    psel            : in  std_logic; -- Device select.
    penable         : in  std_logic; -- Defines the enable cycle.
    pwrite          : in  std_logic; -- Write signal.
    paddr           : in  std_logic_vector(5 downto 0); -- Address.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata          : out std_logic_vector(31 downto 0)  -- Read data.

    
  );

  end component;


----------------------
-- File: hardware_filtering.vhd
----------------------
  component hardware_filtering
  generic (
    addr_width_g : integer := 3
  );
  port (
    -----------------------------------------
    -- Clocks & Reset
    -----------------------------------------
    fe_radar11h_fifo_reset_n : in std_logic;
    fe_radar11h_fifo_gclk    : in std_logic;  -- Gated clock with radar detection enable  
                                              -- when system in receive mode
    fe_radar11h_reset_n      : in std_logic;
    fe_radar11h_gclk         : in std_logic;  -- Gated clock with radar detection enable
    en_20m                   : in std_logic;  -- 20 MHz data enable from OFDM filter

    -----------------------------------------
    -- Registers IF
    -----------------------------------------

     reg_fom_risemin         : in std_logic_vector (3 downto 0); -- Min FOM value at rise edge
     reg_fom_midmin          : in std_logic_vector (3 downto 0); -- Min FOM value at fall edge
     reg_fom_fallmin         : in std_logic_vector (3 downto 0); -- Min FOM value at fall edge
     reg_fom_chk_invalid     : in std_logic_vector (3 downto 0); -- Invalid FOM value  
     reg_pulse_lenmax        : in std_logic_vector (7 downto 0); -- Max pulse length
     reg_pulse_lenmin        : in std_logic_vector (2 downto 0); -- Min pulse length
     reg_freq_risemin        : in std_logic_vector (5 downto 0); -- Min Freq which can be detected
     reg_freq_risemax        : in std_logic_vector (5 downto 0); -- Max Freq which can be detected
     reg_freq_midmin         : in std_logic_vector (5 downto 0); -- Min Freq which can be detected
     reg_freq_midmax         : in std_logic_vector (5 downto 0); -- Max Freq which can be detected
     reg_freq_fallmin        : in std_logic_vector (5 downto 0); -- Min Freq which can be detected
     reg_freq_fallmax        : in std_logic_vector (5 downto 0); -- Max Freq which can be detected
     reg_pulsef_fom_valid_length : in std_logic_vector (5 downto 0); --Min length above which invalid 
                                                             -- pulse FOM measurements are filtered
     reg_nonvalid_lenmax     : in std_logic_vector (7 downto 0); -- Max len below which pulse is invalid
     reg_nonvalid_lenmin     : in std_logic_vector (7 downto 0); -- Min len above which pulse is invalid
     reg_minfreq_fom_len_chk : in std_logic_vector (5 downto 0); -- Minimum FREQuency for the FOM and 
                                                                 -- Length check
     reg_freq_to_reject      : in std_logic_vector (5 downto 0);                           
     reg_freq_chkdc          : in std_logic_vector (5 downto 0); -- zero freq   
     reg_freq_chk_invalid    : in std_logic_vector (5 downto 0); -- Invalid freq value 
     reg_fifo_int_thr        : in std_logic_vector (1 downto 0); -- Threshold value to generate interrupt
     fifo_value_read         : in std_logic;
     radar_fifo_value        : out std_logic_vector (31 downto 0); -- Read Data
     radar_fifo_value_valid  : out std_logic; -- indicates that value on radar_fifo_value signal is valid
     rad_pulse_counter       : out std_logic_vector (addr_width_g - 1 downto 0); -- Number of pulses
     rad_pulse_cnt_valid     : out std_logic; -- indicates that value on rad_pulse_counter signal is valid
     radar_interrupt         : out std_logic;                    -- Interrupt when new pulse is stored  
    

     -------------------------------------------
     -- Radar Trigger Block IF
     -------------------------------------------
     pulse1_rise_detect     : in std_logic; --Pulse1 rise detected
     pulse2_rise_detect     : in std_logic; --Pulse2 rise detected
     pulse1_mid_meas        : in std_logic; --Pulse1 mid measurement is triggered 
     pulse2_mid_meas        : in std_logic; --Pulse2 mid measurement is triggered                   
     pulse2_fall_detect     : in std_logic; --Pulse2 fall detected
     pulse1_fall_detect     : in std_logic; --Pulse1 fall detected
     pulse2_fall_missed     : in std_logic; --Pulse2 fall missed
     pulse_rise_power_in    : in std_logic_vector (7 downto 0); --Power of Pulse rise event 
     pulse_length_in        : in std_logic_vector (7 downto 0); --Pulse Length

     --------------------------------------------
     -- Radar Data Processing Block IF
     --------------------------------------------
     fom_valid              : in std_logic; -- high when FOM and Freq to be read
     radfom                 : in std_logic_vector (3 downto 0); -- FOM
     radfreq                : in std_logic_vector (5 downto 0); -- Frequency   
  
     --------------------------------------------
     -- Diag Ports
     --------------------------------------------
     rad_pulse_valid_diag   : out std_logic;   -- Asserted when a valid radar pulse is detected
     pulse_three_meas_diag  : out std_logic;  -- Asserted when three measurements are available
     rd_ptr_lsb_diag        : out std_logic

         
  );
  end component;


----------------------
-- File: radar_trigger.vhd
----------------------
  component radar_trigger
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    fe_radar11h_fifo_reset_n  : in std_logic;
    fe_radar11h_fifo_gclk     : in std_logic;  -- Gated clock with radar detection enable
    en_20m                    : in std_logic;  -- 20 MHz data enable from OFDM filter
 
    --------------------------------------
    -- Registers
    --------------------------------------

    reg_apowr_thrdbm       : in std_logic_vector(6 downto 0); -- dBm threshold for pulse1 detect,
    reg_apowf_thrdbm       : in std_logic_vector(6 downto 0); -- dBm threshold for pulse1 fall detect, 
    reg_apowf_thrdbmadd    : in std_logic_vector(4 downto 0); 
    reg_pulse1fdbm         : in std_logic_vector(4 downto 0); -- fall of power for pulse1 fall detect, 
    reg_pulse1fdbmadd      : in std_logic_vector(4 downto 0);   
    reg_pulse2fdbm         : in std_logic_vector(4 downto 0); -- fall of power for pulse2 fall detect, 
    reg_pulse2fdbmadd      : in std_logic_vector(4 downto 0);
    reg_pulse1f_thrchng    : in std_logic_vector(7 downto 0); -- no.of cc, after which the reg_pulse1fdbmadd changes.  
    reg_pulse2f_thrchng    : in std_logic_vector(7 downto 0); -- no.of cc, after which the reg_pulse2fdbmadd changes.  
    reg_pulse1r_cnt        : in std_logic_vector(2 downto 0); -- no. of instances for pulse power > threshold,
    reg_pulse2r_cnt        : in std_logic_vector(2 downto 0); -- no. of instances for pulse power > threshold,
    reg_pulse1f_cnt        : in std_logic_vector(2 downto 0); -- no. of instances for pulse power < threshold, 
    reg_pulse2f_cnt        : in std_logic_vector(2 downto 0); -- no. of instances for pulse power < threshold, 
    reg_pulse2_jmpdbm      : in std_logic_vector(4 downto 0); -- rise of power for pulse2 detect,
    reg_pulse1_lenmin      : in std_logic_vector(4 downto 0); -- min duration of pulse1 length,
    reg_pulse2_lenmin      : in std_logic_vector(4 downto 0); -- min duration of pulse2 length,
    reg_pulse_gapmin       : in std_logic_vector(8 downto 0); -- min gap bet' pulse fall trig, pulse rise trig
    reg_pul2_pul1_gapmin   : in std_logic_vector(8 downto 0); -- min gap bet' pulse1 rise trig,pulse2 rise trig
    reg_pul1f_pul2f_gapmin : in std_logic_vector(7 downto 0); -- min gap bet' pulse1 fall trig,pulse2 fall trig
    reg_pow_updtdly        : in std_logic_vector(3 downto 0); -- no. of cc, after which rise power is updated
    reg_mid_meas_cnt       : in std_logic_vector(8 downto 0); -- no. of cc, after which the pulse middle measurement is taken
    reg_mid_falldly        : in std_logic_vector(2 downto 0); -- no. of cc, between mid meas and fall event 
    pulse2_det_en          : in std_logic;
    pulse_mid_meas_en      : in std_logic;
    pulse2_satevent_en     : in std_logic;

    --------------------------------------
    -- AGC
    --------------------------------------
    pradar_dbm            : in std_logic_vector(7 downto 0); -- In-band power est in dBm
    y_valid               : in std_logic;                    -- validates pradar_dbm
    sat_event             : in std_logic; 
    cs_flag_radar         : in std_logic;

    -------------------------------------------------------
    -- Radar detection block (Data proc and FOM calc block)
    -------------------------------------------------------
    start_algo            : out std_logic;                    -- triggers the fom calculation
    pulse_rise_fall       : out std_logic;                    -- 1 indicates pulse rise event
                                                              -- 0 indicates pulse fall event
    -------------------------------------------------------
    -- HW filtering block Interface
    -------------------------------------------------------
    pulse1_rise_detect    : out std_logic;                    -- Indicates trigger for pulse1 rise is issued
    pulse2_rise_detect    : out std_logic;                    -- Indicates trigger for pulse2 rise is issued
    pulse1_mid_meas       : out std_logic;                    -- Indicates trigger for pulse1 mid measurements is issued 
    pulse2_mid_meas       : out std_logic;                    -- Indicates trigger for pulse2 mid measurements is issued
    pulse2_fall_detect    : out std_logic;                    -- Indicates trigger for pulse2 fall is issued 
    pulse1_fall_detect    : out std_logic;                    -- Indicates trigger for pulse1 fall is issued
    pulse2_fall_missed    : out std_logic;                    -- Indicates that pulse2 fall is missed  
    pulse_rise_power      : out std_logic_vector(7 downto 0); -- pulse rise power 
    pulse_length          : out std_logic_vector(7 downto 0); -- Pulse Duration in steps of 0.8 us 

    --------------------------------------------------------------
    -- Diag ports
    --------------------------------------------------------------
    pulse1_detect_diag    : out std_logic;
    pulse2_detect_diag    : out std_logic
                                                                
  );
  
  end component;


----------------------
-- File: radar_detection.vhd
----------------------
  component radar_detection
  generic (
    addr_width_g : integer := 3
  );  

  port (
  ----------------------------------------
  --  General
  ----------------------------------------
  fe_radar11h_fifo_reset_n : in std_logic;
  fe_radar11h_fifo_gclk    : in std_logic;  -- Gated clock with radar detection enable
  fe_radar11h_reset_n      : in std_logic;
  fe_radar11h_gclk         : in std_logic;
  en_20m                   : in std_logic;
  pclk                     : in std_logic;
  preset_n                 : in std_logic;
  interrupt                : out std_logic;  
  ----------------------------------------
  -- AGC
  ----------------------------------------
  pradar_dbm               : in std_logic_vector(7 downto 0);  -- In-band power est in dBm 
  y_valid                  : in std_logic;                    
  y_radar_i                : in std_logic_vector(9 downto 0);  -- 20 MHz Data inputs
  y_radar_q                : in std_logic_vector(9 downto 0);
  sat_event                : in std_logic;
  cs_flag_radar            : in std_logic;

  --------------------------------------------
  -- APB slave
  --------------------------------------------
  psel            : in  std_logic; -- Device select.
  penable         : in  std_logic; -- Defines the enable cycle.
  pwrite          : in  std_logic; -- Write signal.
  paddr           : in  std_logic_vector(5 downto 0);   -- Address.
  pwdata          : in  std_logic_vector(31 downto 0);  -- Write data.
  --
  prdata          : out std_logic_vector(31 downto 0);  -- Read data.
  
  --------------------------------------------
  -- Diagnostic port
  --------------------------------------------
  radar_diag      : out std_logic_vector(15 downto 0)
  
  
  );
  end component;


----------------------
-- File: radar_registers_if.vhd
----------------------
  component radar_registers_if
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n                     : in std_logic; -- active low Reset 60 MHz
    preset_n                    : in std_logic; -- active low Reset 80 MHz
    pclk                        : in std_logic; -- APB clock - 80MHz
    fe_radar11h_gclk            : in std_logic; -- Radar Detection clock - 60MHz

    ---------------------------------------------
    -- Controls
    ---------------------------------------------
    --
    -- Inputs 
    --
    npulse_cnt                  : in std_logic_vector(2 downto 0); -- signals w.r.t 60MHz 
    npulse_cnt_valid            : in std_logic;
    radar_int                   : in std_logic;
    radar_fifo_value            : in std_logic_vector(31 downto 0);  
    radar_fifo_value_valid      : in std_logic;
    --
    reg_pulse2_satevent_en      : in std_logic; -- signals w.r.t 80MHz
    reg_pulse_mid_meas_en       : in std_logic;
    reg_pulse2_det_en           : in std_logic;
    fifo_value_read             : in std_logic;
    --
    -- Outputs
    -- 
    npulse_cnt_resync           : out std_logic_vector(2 downto 0); -- signals synchronized w.r.t 80MHz
    radar_int_resync            : out std_logic;
    radar_fifo_value_resync     : out std_logic_vector(31 downto 0);
    --
    reg_pulse2_satevent_en_sync : out std_logic; -- signals synchronized w.r.t 60MHz 
    reg_pulse_mid_meas_en_sync  : out std_logic;
    reg_pulse2_det_en_sync      : out std_logic;
    fifo_value_read_sync        : out std_logic
    );

  end component;


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
end radar_detection_pkg;
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
