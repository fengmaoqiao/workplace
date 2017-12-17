--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: iq_estimation_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.9   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for iq_estimation.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/iq_estimation/vhdl/rtl/iq_estimation_pkg.vhd,v  
--  Log: iq_estimation_pkg.vhd,v  
-- Revision 1.9  2004/11/02 15:08:48  Dr.C
-- #BugId:703#
-- Removed Kgs coefficient in the phase estimation.
--
-- Revision 1.8  2004/06/18 09:40:31  Dr.C
-- Added rx_iqmm_out_dis.
--
-- Revision 1.7  2003/12/03 14:45:33  rrich
-- Fixed problem with initialisation (see top level comment).
--
-- Revision 1.6  2003/12/02 13:16:52  rrich
-- Mods to allow initialisation of g_est and ph_est immediately after loading
-- presets.
--
-- Revision 1.5  2003/11/25 18:27:30  Dr.C
-- Updated iq_estimation.
--
-- Revision 1.4  2003/11/03 10:40:28  rrich
-- Added new IQMMEST input.
--
-- Revision 1.3  2003/10/23 07:54:04  rrich
-- Added inputs for gain and phase step.
--
-- Revision 1.2  2003/08/26 14:50:55  rrich
-- Bit-truified gain and phase estimate calculations.
--
-- Revision 1.1  2003/06/04 15:23:33  rrich
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
package iq_estimation_pkg is

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: iq_mism_g_est.vhd
----------------------
  component iq_mism_g_est
  generic (
    iq_accum_width_g : integer := 10;  -- Width of input accumulated IQ signals
    gain_width_g     : integer := 9;   -- Gain mismatch width
    preset_width_g   : integer := 16); -- Preset width 
  
  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    
    ---------------------------------------------------------------------------
    -- Data in
    ---------------------------------------------------------------------------
    i_accum : in  std_logic_vector(iq_accum_width_g-1 downto 0);
    q_accum : in  std_logic_vector(iq_accum_width_g-1 downto 0);

    --------------------------------------
    -- Controls
    --------------------------------------
    iqmm_est  : in  std_logic; -- IQMMEST register
    est_start : in  std_logic; -- Start estimation
    est_en    : in  std_logic; -- Estimation enable
    est_reset : in  std_logic; -- Restart estimation
    g_pset    : in  std_logic_vector(preset_width_g-1 downto 0);
    g_step_in : in  std_logic_vector(7 downto 0);
    ctrl_cnt  : in  std_logic_vector(5 downto 0);
    initialise: in  std_logic; -- Initialising estimation
    
    --------------------------------------
    -- Estimate out
    --------------------------------------
    g_est_valid : out std_logic;
    g_est       : out std_logic_vector(gain_width_g-1 downto 0);
    gain_accum  : out std_logic_vector(preset_width_g-1 downto 0));

    
  end component;


----------------------
-- File: iq_mism_ph_est.vhd
----------------------
  component iq_mism_ph_est
  generic (
    iq_accum_width_g : integer := 7;   -- Width of input accumulated IQ signals
    phase_width_g    : integer := 6;   -- Phase mismatch width
    preset_width_g   : integer := 16); -- Preset width
  
  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    
    ---------------------------------------------------------------------------
    -- Data in
    ---------------------------------------------------------------------------
    iq_accum     : in  std_logic_vector(iq_accum_width_g-1 downto 0);
    
    --------------------------------------
    -- Controls
    --------------------------------------
    iqmm_est     : in  std_logic; -- IQMMEST register
    est_start    : in  std_logic; -- Start estimation
    est_en       : in  std_logic; -- Estimation enable
    est_reset    : in  std_logic; -- Restart estimation
    ph_pset      : in  std_logic_vector(preset_width_g-1 downto 0);
    ph_step_in   : in  std_logic_vector(7 downto 0); 
    ctrl_cnt     : in  std_logic_vector(5 downto 0);
    initialise   : in  std_logic; -- Initialising estimation
    
    --------------------------------------
    -- Estimate out
    --------------------------------------
    ph_est_valid : out std_logic;
    ph_est       : out std_logic_vector(phase_width_g-1 downto 0);
    phase_accum  : out std_logic_vector(preset_width_g-1 downto 0));
    
  end component;


----------------------
-- File: iq_estimation.vhd
----------------------
  component iq_estimation

  generic (
    iq_i_width_g   : integer := 11;   -- Width of the input IQ signals
    gain_width_g   : integer := 9;    -- Gain  mismatch estimate width
    phase_width_g  : integer := 6;    -- Phase mismatch estimate width
    preset_width_g : integer := 16    -- Estimate presets width 
  );
  
  port (
    clk             : in  std_logic; -- Module clock
    reset_n         : in  std_logic; -- Asynchronous reset

    --------------------------------------
    -- Controls
    --------------------------------------
    rx_iqmm_est     : in  std_logic; -- Enable from register
    rx_iqmm_est_en  : in  std_logic; -- Estimation enable (high during data)
    rx_iqmm_out_dis : in  std_logic; -- Outputs disable (high after signal field error)
    rx_iqmm_reset   : in  std_logic; -- Restart estimation
    rx_packet_end   : in  std_logic; -- Packet end
    rx_iqmm_g_pset  : in  std_logic_vector(preset_width_g-1 downto 0);
    rx_iqmm_ph_pset : in  std_logic_vector(preset_width_g-1 downto 0);
    rx_iqmm_g_step  : in  std_logic_vector(7 downto 0);
    rx_iqmm_ph_step : in  std_logic_vector(7 downto 0);
    --
    iqmm_reset_done : out std_logic; -- Restart estimation done

    --------------------------------------
    -- Data in
    --------------------------------------
    data_valid_in   : in  std_logic; -- High when a new data is available
    i_in            : in  std_logic_vector(iq_i_width_g-1 downto 0);
    q_in            : in  std_logic_vector(iq_i_width_g-1 downto 0);

    --------------------------------------
    -- Estimates out
    --------------------------------------
    rx_iqmm_g_est         : out std_logic_vector(gain_width_g-1 downto 0);
    rx_iqmm_ph_est        : out std_logic_vector(phase_width_g-1 downto 0);
    gain_accum            : out std_logic_vector(preset_width_g-1 downto 0);
    phase_accum           : out std_logic_vector(preset_width_g-1 downto 0)
  );

  end component;




end iq_estimation_pkg;
