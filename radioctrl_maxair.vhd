--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 9710 $
--/ $Date: 2011-01-27 15:58:31 +0100 (Thu, 27 Jan 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : The top level instantiation of Radio Controller.
--/                    The signals corresponding to ports are are assigned name
--/                    with suffix _s and also similarly for input and output 
--/                    with suffix _i and _o.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/radioctrl_maxair/vhdl/rtl/radioctrl_maxair.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library radioctrl_maxair_rtl;
library work;
use work.radioctrl_maxair_pkg.all;
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
-- use radioctrl_maxair_rtl.radioctrl_global_pkg.all;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------

entity radioctrl_maxair is
  port (
    -------------------------------------------
    -- General
    -------------------------------------------
    reset_n             : in  std_logic;
    clk                 : in  std_logic;

    -------------------------------------------
    -- APB interface
    -------------------------------------------
    psel                : in  std_logic;
    penable             : in  std_logic;
    paddr               : in  std_logic_vector(6 downto 0);
    pwdata              : in  std_logic_vector(31 downto 0);
    prdata              : out std_logic_vector(31 downto 0);
    pwrite              : in  std_logic;

    -------------------------------------------
    -- 3 wire serial interface
    -------------------------------------------
    ana_3wclk           : out std_logic;
    ana_3wdataout       : out std_logic;
    ana_3wdataen        : out std_logic;

    -------------------------------------------
    -- Analog interface
    -------------------------------------------
    -- ADC control
    adc_pwron           : out std_logic;
    adc_rxen            : out std_logic;
    force_adc_clk       : out std_logic;
    -- DAC control
    dac_pwron           : out std_logic;
    dac_txen            : out std_logic;
    force_dac_clk       : out std_logic;
    -- RSSI ADC control
    rf_rssi             : in  std_logic_vector(7 downto 0);
    --
    rssiadc_pwron       : out std_logic;
    rssiadc_rxen        : out std_logic;
    rssi_gclk           : out std_logic;

    -------------------------------------------
    -- Radio
    -------------------------------------------
    lock_detect         : in  std_logic;
    --
    rxen                : out std_logic;
    txen                : out std_logic;
    paon2g              : out std_logic;
    paon5g              : out std_logic;
    gaincontrol         : out std_logic_vector(6 downto 0);
    shutdown            : out std_logic;
    antsel              : out std_logic;
    rxhp                : out std_logic;

    ----------------------------------------------
    -- AGC BB
    ----------------------------------------------
    agc_rxonoff_req     : in  std_logic;
    agc_busy            : in  std_logic;
    agc_lock            : in  std_logic;
    agc_rise            : in  std_logic;
    rxv_rxant           : in  std_logic;
    agc_rxonoff_conf    : out std_logic;
    agc_bb_on           : out std_logic; 
    rx_gain_control     : in  std_logic_vector(6 downto 0);
    rx_ic_gain          : in  std_logic_vector(5 downto 0);
    switch_antenna      : in  std_logic;
    rxhp_radio          : in  std_logic;

    ----------------------------------------------
    -- RW_WLAN MODEM
    ----------------------------------------------
    -- Common to both modems
    phy_rxstartend_ind  : in  std_logic; -- indication of RX packet                     
    -- 802.11a side
    a_txend_preamble    : in  std_logic; -- End of OFDM preamble
    a_txonoff_req       : in  std_logic;
    a_txonoff_conf      : out std_logic;

    -- 802.11b side
    b_txend_preamble    : in  std_logic; -- End of DSSS-CCK preamble
    b_txonoff_req       : in  std_logic;
    b_txonoff_conf      : out std_logic;
    
    ----------------------------------------------
    -- RW_WLAN BuP
    ----------------------------------------------
    txpwr_level         : in  std_logic_vector(6 downto 0);
    txv_immstop         : in  std_logic;
    txv_txant           : in  std_logic;
     
    ----------------------------------------------
    -- Deep Sleep mode
    ---------------------------------------------
    clock_switched      : out std_logic;
    clk_div             : out std_logic_vector(2 downto 0);
    --
    rf_en_force         : in  std_logic
    );
 
 end radioctrl_maxair;

----------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------

architecture RTL of radioctrl_maxair is

  -- ---------------------------------------------------------------------------
  -- signal declarations
  -- ---------------------------------------------------------------------------
  signal force_rssiadc_on        : std_logic;
  signal rssi_capt_mode          : std_logic_vector(2 downto 0);
  signal rcrssi                  : std_logic_vector(7 downto 0);
  signal lnagain                 : std_logic_vector(1 downto 0);
  signal newwrp_s                : std_logic;
  signal regwrdata_s             : std_logic_vector(19 downto 0);
  signal txrxwrdata_s            : std_logic_vector(31 downto 0);
  signal rfinit_en_s             : std_logic;
  signal rfconfig_s              : std_logic;
  signal regconfig_s             : std_logic_vector(5 downto 0);
  signal clkratio_s              : std_logic_vector(11 downto 0);
  signal clkratio_temp           : std_logic_vector(9 downto 0);
  signal pgmchanp_s              : std_logic;
  signal channum_s               : std_logic_vector(7 downto 0);
  signal modeg_s                 : std_logic;
  signal shutdownstate_s         : std_logic;
  signal chanpgmdonep_s          : std_logic;
  signal pgmon_s                 : std_logic;
  signal txrampup_s              : std_logic_vector(8 downto 0);
  signal txrampupvga_s           : std_logic_vector(7 downto 0);
  signal txrampuppaon_s          : std_logic_vector(8 downto 0);
  signal txrampdn_s              : std_logic_vector(7 downto 0);
  signal pgmradiofreqp_s         : std_logic;
  signal currfreq_s              : std_logic_vector(7 downto 0);
  signal txantinv_s              : std_logic;
  signal paonpol_s               : std_logic;
  signal a_txonoff_conf_s        : std_logic;
  signal b_txonoff_conf_s        : std_logic;
  signal agc_bb_on_s             : std_logic;
  signal agc_rxonoff_conf_s      : std_logic;
  signal rxen_s                  : std_logic;
  signal txen_s                  : std_logic;
  signal antsel_s                : std_logic;
  signal gaincontrol_s           : std_logic_vector(6 downto 0);
  signal paon2g_s                : std_logic;
  signal paon5g_s                : std_logic;
  signal shutdown_s              : std_logic;
  signal serialclk_s             : std_logic;
  signal serialdata_s            : std_logic;
  signal le_s                    : std_logic;
  signal wrdonep_s               : std_logic;
  signal prdata_s                : std_logic_vector(31 downto 0);
  signal swtoidle_s              : std_logic;
  signal swtoidle_dsleep_i       : std_logic;
  signal pgmregp_s               : std_logic;
  signal pgmonfinal_s            : std_logic;
  signal initstate_s             : std_logic;
  signal txrxctrlidle_s          : std_logic;
  signal calibregp_s             : std_logic;
  signal calibon_s               : std_logic;
  signal rf_en_force_ff          : std_logic;
  signal deepsleep_i             : std_logic;
  signal deepsleep_s             : std_logic;
  signal pgmregwrdonep_s         : std_logic;
  signal pgmchandonep_s          : std_logic;
  signal rx_gain_control_s       : std_logic_vector(6 downto 0);
  signal tx_bias_mode_s          : std_logic;

  ------------------------------------------------------------------------------
  -- architecture body
  ------------------------------------------------------------------------------

begin
           
  ana_3wclk        <= serialclk_s;   
  ana_3wdataout    <= serialdata_s;
  ana_3wdataen     <= le_s;       
  agc_bb_on        <= agc_bb_on_s;   
  agc_rxonoff_conf <= agc_rxonoff_conf_s;
  a_txonoff_conf   <= a_txonoff_conf_s;
  b_txonoff_conf   <= b_txonoff_conf_s;
  shutdown         <= shutdown_s;     
  txen             <= txen_s;             
  rxen             <= rxen_s;             
  paon2g           <= paon2g_s;         
  paon5g           <= paon5g_s;         
  antsel           <= antsel_s;         
  gaincontrol      <= gaincontrol_s;
  prdata           <= prdata_s;         
  clkratio_s       <= "00" & clkratio_temp;
  rxhp             <= tx_bias_mode_s when txen_s = '1' else rxhp_radio;
  
-- global signals used in protocol monitor for radio controller in the 
-- top level testbench file

-- ambit synthesis off            
-- synopsys translate_off         
-- synthesis translate_off        
--  a_txonoff_req_global    <= a_txonoff_req;
--  b_txonoff_req_global    <= b_txonoff_req;
--  txpwrlvl_global         <= txpwr_level;
--  a_txonoff_conf_global   <= a_txonoff_conf_s;
--  b_txonoff_conf_global   <= b_txonoff_conf_s;
--  txv_immstop_global      <= txv_immstop;
--  agc_rxonoff_req_global  <= agc_rxonoff_req;
--  agc_rxonoff_conf_global <= agc_rxonoff_conf_s;
--  agc_bb_on_global        <= agc_bb_on_s;
--  agc_busy_global         <= agc_busy;
--  paonpol_global          <= paonpol_s;
--  modeg_global            <= modeg_s;  
--  txrampuppaon_global     <= txrampuppaon_s;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on


  swtoidle_dsleep_i <= swtoidle_s or deepsleep_i; 

  -- ---------------------------------------------------------------------------
  -- Instantiation of txrxcntrl
  -- ---------------------------------------------------------------------------
  u_txrxcntrl : txrxcntrl
  port map (
    clk              => clk,
    nhrdrst          => reset_n,
    a_txonoff_req    => a_txonoff_req,
    b_txonoff_req    => b_txonoff_req,
    agc_rxonoff_req  => agc_rxonoff_req,
    agc_busy         => agc_busy,
    txv_immstop      => txv_immstop,
    txpwrlvl         => txpwr_level,
    pgmon            => pgmon_s,
	  swtoidle         => swtoidle_dsleep_i, 
    calibon          => calibon_s,
    agcwd            => rx_gain_control_s(4 downto 0),
    newwrp           => newwrp_s,
	  wrdonep          => wrdonep_s,
    txrampuptime     => txrampup_s,
    txrampupvga      => txrampupvga_s,
    txrampuppaon     => txrampuppaon_s,
    txrampdntime     => txrampdn_s,
    pgmradiofreqp    => pgmradiofreqp_s,
    currfreqch       => currfreq_s,
    modeg            => modeg_s,
    attenoff         => rx_gain_control_s(6 downto 5),
    txantinv         => txantinv_s,
    rfinit_en        => rfinit_en_s,
    chanpgmdonep     => chanpgmdonep_s,
    paonpol          => paonpol_s,
    rfconfig         => rfconfig_s,
    switch_antenna   => switch_antenna,
    rxv_rxant        => rxv_rxant,
    txv_txant        => txv_txant,
    a_txonoff_conf   => a_txonoff_conf_s,
    b_txonoff_conf   => b_txonoff_conf_s,
    agc_bb_on        => agc_bb_on_s,
    agc_rxonoff_conf => agc_rxonoff_conf_s,
    rxen             => rxen_s,
    txen             => txen_s,
    tx_bias_mode     => tx_bias_mode_s,
    pgmchanp         => pgmchanp_s,
	  pgmregwrdonep    => pgmregwrdonep_s,
	  pgmchandonep     => pgmchandonep_s,
    channum          => channum_s,
    antsel           => antsel_s,
    agcpwr           => gaincontrol_s,
    shutdownstate    => shutdownstate_s,
    paon2g           => paon2g_s,
    paon5g           => paon5g_s,
    pgmregp          => pgmregp_s,
    calibregp        => calibregp_s,
    initstate        => initstate_s,
    txrxctrlidle     => txrxctrlidle_s,
    shutdown         => shutdown_s
    );

  txrxwrdata_s <= "000000000000" & regwrdata_s;
  
  
  -- ---------------------------------------------------------------------------
  -- Instantiation of serialif
  -- ---------------------------------------------------------------------------
  u_serialif : serialif
  port map(
    clk           => clk,
    nhrdrst       => reset_n,
    cntrlwd       => txrxwrdata_s,
    numcbits      => regconfig_s,
    ratio         => clkratio_s,
    rfconfig      => rfconfig_s,
    rfinit_en     => rfinit_en_s,
    pgmchanp      => pgmchanp_s,
    channum       => channum_s,
    modeg         => modeg_s,
    shutdownstate => shutdownstate_s,
    serialclk     => serialclk_s,
    serialdata    => serialdata_s,
    le            => le_s,
	  wrdonep       => wrdonep_s,
    calibon       => calibon_s,
    pgmon         => pgmon_s,
    pgmregp       => pgmregp_s,
    chanpgmdonep  => chanpgmdonep_s,
    calibregp     => calibregp_s
    ); 

  pgmonfinal_s <= pgmon_s or initstate_s;

  
  -- ---------------------------------------------------------------------------
  -- Instantiation of radioctrl_registers
  -- ---------------------------------------------------------------------------
  u_radioctrl_registers : radioctrl_registers
  port map(
     clk                => clk,
     reset_n            => reset_n,
     --
     psel_i             => psel,
     penable_i          => penable,
     paddr_i            => paddr,
     pwdata_i           => pwdata,
     pwrite_i           => pwrite,
     prdata_o           => prdata_s,
     --
     adc_pwron_o        => adc_pwron, 
     dac_pwron_o        => dac_pwron, 
     force_adc_on_o     => adc_rxen, 
     force_dac_on_o     => dac_txen, 
     force_adc_clk_o    => force_adc_clk,
     force_dac_clk_o    => force_dac_clk,
     rssiadc_pwron_o    => rssiadc_pwron,
     force_rssiadc_on_o => force_rssiadc_on,
     rssi_capt_mode_o   => rssi_capt_mode, 
     --
     rcrssi_i           => rcrssi, 
     lnagain_i          => lnagain,
     --
     txrampup_o         => txrampup_s,
     txrampupvga_o      => txrampupvga_s,
     txrampuppaon_o     => txrampuppaon_s,
     txrampdn_o         => txrampdn_s,
     currfreq_o         => currfreq_s,
     pgmradiofreqp_o    => pgmradiofreqp_s,
     modeg_o            => modeg_s,
     paonpol_o          => paonpol_s,
	   swtoidle_o         => swtoidle_s,
	   deepsleep_o        => deepsleep_s,
     clkratio_o         => clkratio_temp,
     regconfig_o        => regconfig_s,
     rfconfig_o         => rfconfig_s,
     wrdata_o           => regwrdata_s,
     newwrp_o           => newwrp_s,
	   pgmregwrdonep_i    => pgmregwrdonep_s,
	   pgmchandonep_i     => pgmchandonep_s,
     pgmon_i            => pgmonfinal_s,
     txrxctrlidle_i     => txrxctrlidle_s,
     shutdown_i         => shutdown_s,
     txantinv_o         => txantinv_s,
     rfinit_en_o        => rfinit_en_s,
     lock_detect_i      => lock_detect
     );

  rx_gain_control_s <= rx_gain_control;


  -- ---------------------------------------------------------------------------
  -- Deep sleep control
  -- ---------------------------------------------------------------------------
  -- logic added for deep sleep generation
  -- on falling edge of rf_en_force move out of deep sleep
  deepsleep_p : process(clk,reset_n)
  begin
    if reset_n = '0' then
      clk_div        <= "001"; -- active state
      clock_switched <= '0';
      deepsleep_i    <= '0';
      rf_en_force_ff <= '0';
    elsif clk'event and clk = '1' then
      rf_en_force_ff <= rf_en_force;
    	-- detect falling edge
    	if (rf_en_force_ff = '1' and rf_en_force = '0') then
    	  clock_switched <= '0';
    	  clk_div        <= "001";
    	  deepsleep_i    <= '0';
    	elsif (deepsleep_i = '1' and shutdown_s = '0') then
    	  clock_switched <= '1';
    	  clk_div        <= "000";
      elsif (deepsleep_s = '1') then
    	  deepsleep_i    <= '1';
    	end if;
    end if;
  end process deepsleep_p;


  -- ---------------------------------------------------------------------------
  -- Instantiation of rssi_ctrl
  -- ---------------------------------------------------------------------------
  rssi_ctrl_1 : rssi_ctrl
  port map (
    -- Clock and reset
    reset_n             => reset_n,
    clk                 => clk,
    -- RSSI ADC control
    rf_rssi             => rf_rssi,
    rssiadc_rxen        => rssiadc_rxen,
    rssi_gclk           => rssi_gclk,
    -- AGC BB
    agc_rxonoff_req     => agc_rxonoff_req,
    agc_lock            => agc_lock,
    agc_rise            => agc_rise,
    attenoff            => rx_gain_control_s(6 downto 5),
    -- Modem
    phy_rxstartend_ind  => phy_rxstartend_ind,
    -- 802.11a side
    a_txonoff_req       => a_txonoff_req,
    a_txend_preamble    => a_txend_preamble,
    -- 802.11b side
    b_txonoff_req       => b_txonoff_req,
    b_txend_preamble    => b_txend_preamble,
    -- From/to radio control registers
    force_rssiadc_on    => force_rssiadc_on,
    rssi_capt_mode      => rssi_capt_mode,
    rcrssi              => rcrssi,
    lnagain             => lnagain
    );

     
end RTL; 
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
