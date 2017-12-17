
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: rx_ctrl_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.9   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rx_ctrl.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/rx_ctrl/vhdl/rtl/rx_ctrl_pkg.vhd,v  
--  Log: rx_ctrl_pkg.vhd,v  
-- Revision 1.9  2004/04/27 09:19:48  arisse
-- Added one bit to applied_mu.
--
-- Revision 1.8  2002/12/03 13:23:08  Dr.F
-- added sfd_detect_enable.
--
-- Revision 1.7  2002/11/28 10:20:31  Dr.A
-- Updated to modem v0.17 registers.
--
-- Revision 1.6  2002/11/06 17:38:58  Dr.F
-- port map changed.
--
-- Revision 1.5  2002/11/05 10:02:35  Dr.F
-- port map changed.
--
-- Revision 1.4  2002/10/21 13:59:17  Dr.F
-- port map changed.
--
-- Revision 1.3  2002/09/20 15:12:53  Dr.F
-- added comp_disb port.
--
-- Revision 1.2  2002/09/09 14:21:00  Dr.F
-- removed one_us_it port.
--
-- Revision 1.1  2002/07/31 08:11:04  Dr.F
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
package rx_ctrl_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: rx_ctrl.vhd
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



 
end rx_ctrl_pkg;
