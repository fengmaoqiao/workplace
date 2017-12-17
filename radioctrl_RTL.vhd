
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: radioctrl.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.29   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Radio controller
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/radioctrl/vhdl/rtl/radioctrl.vhd,v  
--  Log: radioctrl.vhd,v  
-- Revision 1.29  2006/02/27 15:08:10  Dr.J
-- #BugId:1509#
-- Removed the ECO for TSC and changed the agc_cca_hissbb in order to remove the bug 1509
--
-- Revision 1.28  2006/02/27 15:05:08  Dr.J
-- #BugId:1509#
-- ECO for TSC
--
-- Revision 1.27  2005/10/04 12:27:05  Dr.A
-- #BugId:1398#
-- Completed sensitivity list in registers and reqdata_handler.
-- Removed unused signals and rf_goto_sleep port
--
-- Revision 1.26  2005/03/10 08:45:59  sbizet
-- #BugId:907,948,946#
-- new diag ports
--
-- Revision 1.25  2005/01/06 17:07:08  sbizet
-- #BugId:907,948,946,643#
-- Added:
-- o software radio off request(sw_rfoff_req)
-- o Tx immediate stop feature(txv_immstop_i)
-- o radio off when MACADDR does not match(agc_rfoff)
-- o radar detection interrupt handling(rfint)
--
-- Revision 1.24  2004/12/14 16:31:15  sbizet
-- #BugId:713#
-- Updated port map for 1.2 functions
--
-- Revision 1.23  2004/11/03 10:00:08  sbizet
-- #BugId:804#
-- b_tx_data_val_tog resynchronized on bus_gclk
--
-- Revision 1.22  2004/07/16 07:41:43  Dr.B
-- add pabias info feature.
--
-- Revision 1.21  2004/06/04 13:51:37  Dr.C
-- Changed to only one port for Tx/Rx data.
--
-- Revision 1.20  2004/03/29 13:04:45  Dr.B
-- add clk44_possible_g generic.
--
-- Revision 1.19  2004/02/19 17:28:20  Dr.B
-- add hiss_reset_n + b_antsel.
--
-- Revision 1.18  2003/12/17 15:21:04  Dr.B
-- remove rf_rx when hiss only.
--
-- Revision 1.17  2003/12/03 17:32:58  Dr.B 
-- add diagport.
--
-- Revision 1.16  2003/11/27 12:20:21  Dr.B
-- add default value of rf_switch_ant when no hiss.
--
-- Revision 1.15  2003/11/20 16:26:41  Dr.B
-- add hiss_clk_n and rf_goto_sleep.
--
-- Revision 1.14  2003/11/20 13:06:29  Dr.B
-- remove rf_gotosleep port.
--
-- Revision 1.13  2003/11/20 11:35:15  Dr.B
-- readd hiss_clk_n temporarly for compatibilty with wildcore portmap.
--
-- Revision 1.12  2003/11/20 11:28:20  Dr.B
-- remove hiss_clk_n
--
-- Revision 1.11  2003/11/17 14:54:21  Dr.B
-- acc clk_switch_tog.
--
-- Revision 1.10  2003/11/05 09:19:42  Dr.B
-- add a_txbbonoff_req an agc_stream_enable.
--
-- Revision 1.9  2003/11/03 16:01:49  Dr.B
-- output pa_on.
--
-- Revision 1.8  2003/10/30 16:37:58  Dr.B
-- change txpwr size.
--
-- Revision 1.7  2003/10/30 14:42:02  Dr.B
-- update to spec 0.06.
--
-- Revision 1.6  2003/10/09 08:29:59  Dr.C
-- Updated hiss master port map
--
-- Revision 1.5  2003/09/25 12:46:26  Dr.C
-- Updated Hiss interface
--
-- Revision 1.4  2003/09/23 13:08:47  Dr.C
-- Updated to spec 0.05
--
-- Revision 1.3  2003/07/15 08:40:17  Dr.C
-- Updated to spec 0.04
--
-- Revision 1.2  2002/06/25 12:48:51  Dr.C
-- Modified rf_clk and data generation
--
-- Revision 1.1  2002/04/26 12:18:15  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all; 

--library radioctrl_rtl;
library work;
--use radioctrl_rtl.radioctrl_pkg.all;
use work.radioctrl_pkg.all;

--library master_hiss_rtl;
library work;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity radioctrl is
  generic (
    ana_digital_g : integer := 2;  -- Selects between analog and HISS interface
                                    -- 0: reserved
                                    -- 1: analog interface
                                    -- 2: digital interface
                                    -- 3: both
    clk44_possible_g : integer := 0);  -- when 1 - the radioctrl can work with a
  -- 44 MHz clock instead of the normal 80 MHz.
    port (
    -------------------------------------------
    -- Clocks and reset                         
    -------------------------------------------
    reset_n      : in  std_logic;  -- general reset
    hiss_reset_n : in  std_logic;  -- reset for 240 MHz flip-flops
    sampling_clk : in  std_logic;
    hiss_clk     : in  std_logic; -- 240 MHz clock with mini clocktree
    rfh_fastclk  : in  std_logic; -- 240 MHz clock without clktree (directly from pad) 
    clk          : in  std_logic;       -- bus_clk
    clk_n        : in  std_logic;       -- bus_clk_n
   
    -------------------------------------------
    -- APB interface                           
    -------------------------------------------
    psel         : in  std_logic;
    penable      : in  std_logic;
    paddr        : in  std_logic_vector(5 downto 0);
    pwrite       : in  std_logic;
    pclk         : in  std_logic;
    pwdata       : in  std_logic_vector(31 downto 0);
    prdata       : out std_logic_vector(31 downto 0);

    -------------------------------------------
    -- AGC                       
    -------------------------------------------
    agc_ant_switch_tog : in  std_logic;  -- Ask of antenna switch when toggle
    agc_req            : in  std_logic;  -- Triggers an access to RF reg.
    agc_addr           : in  std_logic_vector(2 downto 0);  -- Register address
    agc_wrdata         : in  std_logic_vector(7 downto 0);  -- Write data for reg
    agc_wr             : in  std_logic;  -- Access type requested write = '1'
    agc_adc_enable     : in  std_logic;  -- Request ADC switch on
    agc_ab_mode        : in  std_logic;  -- Mode of received packet
    agc_busy           : in  std_logic;  -- Prevents software to access to RF
    agc_rxonoff_req    : in  std_logic;  -- Request switch to Rx mode
    agc_stream_enable  : in  std_logic;  -- Enable hiss 'pipe' on reception
    agc_rfint          : in  std_logic;  -- Interrupt from AGC RF decoded by AGC BB
    agc_rfoff          : in  std_logic;  -- AGC Request to stop the RF
    sw_rfoff_req       : out std_logic;  -- Pulse to request RF stop by software
    --
    agc_cs             : out std_logic_vector(1 downto 0);-- CS info for AGC/CCA
    agc_cs_valid       : out std_logic;  -- high when the CS is valid
    agc_conf           : out std_logic;  -- Acknowledge AGC access
    agc_rddata         : out std_logic_vector(7 downto 0);  -- AGC read data
    agc_ccamarker      : out std_logic; -- pulse when valid
    agc_ccaflags       : out std_logic_vector(5 downto 0);  -- CCA information   
    agc_cca_add_flags  : out std_logic_vector(15 downto 0);  -- CCA additional information   
    agc_rxonoff_conf   : out  std_logic;  -- Acknowledge switch to Rx mode
    
    -------------------------------------------
    -- Modem 802.11a                         
    -------------------------------------------
    a_txonoff_req   : in  std_logic;    -- Request switch to Tx mode
    a_txbbonoff_req : in  std_logic;  -- Same as previous but stop when no data in bb
    a_txdatavalid   : in  std_logic;
    --
    a_rxdatavalid   : out std_logic;
    a_txonoff_conf  : out std_logic;    -- Confirm switch to Tx mode
    
    -------------------------------------------
    -- Modem 802.11b                         
    -------------------------------------------
    b_txonoff_req   : in  std_logic;    -- Request switch to Tx mode
    b_txbbonoff_req : in  std_logic;    -- Same as previous but stop when no data in bb
    b_txdatavalid   : in  std_logic;    -- Indicates tx valid data
    --
    b_rxdatavalid   : out std_logic;    -- Indicates rx valid data
    b_txonoff_conf  : out std_logic;    -- Confirm switch to Tx mode

    -------------------------------------------
    -- Modem signals
    -------------------------------------------
    txi             : in  std_logic_vector(9 downto 0);   -- TX data
    txq             : in  std_logic_vector(9 downto 0);
    --
    rxi             : out std_logic_vector(10 downto 0);  -- RX data
    rxq             : out std_logic_vector(10 downto 0);

    -------------------------------------------
    -- BuP                 
    -------------------------------------------
    txv_immstop     : in  std_logic;                     -- Tx Immediate stop from BuP register
    txpwr_req       : in  std_logic;                     -- Request to program power level
    txpwr           : in  std_logic_vector(3 downto 0);  -- Tx power level
    txv_paindex     : in  std_logic_vector(4 downto 0);  -- index in the PA bias table -
                                                         -- valid with txpwr_req (paindex(0) = PAINDEXL)
    txv_txant       : in  std_logic;                     -- Antenna selected for transmission
    txv_txaddcntl   : in  std_logic_vector(1 downto 0);  -- Additionnal transmission control
    --
    txpwr_conf      : out std_logic;                     -- Confirm tx power level prog.
    -------------------------------------------
    -- Analog radio interface                        
    -------------------------------------------
    ana_rxi         : in  std_logic_vector(7 downto 0);  -- Rx data
    ana_rxq         : in  std_logic_vector(7 downto 0);
    ana_3wdatain    : in  std_logic;                     -- 3 wire data
    ana_3wenablein  : in  std_logic;                     -- 3 wire enable
    --
    ana_txi         : out std_logic_vector(7 downto 0);  -- Tx data
    ana_txq         : out std_logic_vector(7 downto 0);
    ana_3wclk       : out std_logic;    -- 3 wire interface clock
    ana_3wdataout   : out std_logic;    -- 3 wire data to write
    ana_3wdataen    : out std_logic;    -- Data enable
    ana_3wenableout : out std_logic;    -- 3 wire enable
    ana_3wenableen  : out std_logic;    -- enable enable signal
    ana_xoen        : out std_logic;    -- Enable crystal oscillator
    ana_rxen        : out std_logic;    -- Enable rx path
    ana_txen        : out std_logic;    -- Enable tx path
    ana_dacen       : out std_logic;    -- DAC enable
    ana_adcen       : out std_logic_vector(1 downto 0);
                                        -- ADC enable (1) paonbias (0) sleep

    -------------------------------------------
    -- Hiss radio interface                        
    -------------------------------------------
    rf_en_force  : in  std_logic;       -- Forces rf_en to '1'
    hiss_rxi     : in  std_logic;       -- Rx data
    hiss_rxq     : in  std_logic;
    --
    hiss_txi     : out std_logic;       -- Tx data
    hiss_txq     : out std_logic;
    hiss_txen    : out std_logic;       -- Enable Tx data outputs
    hiss_rxen    : out std_logic;       -- Enable Rx data inputs
    rf_en        : out std_logic;       -- Tx data
    hiss_biasen  : out std_logic;       -- enable HiSS drivers and receivers
    hiss_replien : out std_logic;       -- enable HiSS drivers and receivers
    hiss_clken   : out std_logic;       -- Enable HiSS clock receivers
    hiss_curr    : out std_logic;  -- Select high/low-current mode for HiSS drivers

    -------------------------------------------
    -- Radio control                       
    -------------------------------------------
    rf_sw         : out std_logic_vector(3 downto 0);  -- Radio switch
    pa_on         : out std_logic; -- high when PA is on

    -------------------------------------------
    -- Clock controller           
    -------------------------------------------
    clkdiv             : out std_logic_vector(2 downto 0);  -- Fast clock freq.
    clock_switched_tog : out std_logic;       -- Clock freq. switched
    
    -------------------------------------------
    -- Misc           
    -------------------------------------------
    rfmode         : in  std_logic;     -- 0 when hiss in enabled / 1 when ana
    sync_found     : in  std_logic;     -- Synchronization found active high
    tx_ab_mode     : in  std_logic;     -- TX a/b mode
    clk_2skip_tog  : out std_logic;     -- Clock skip of 2 per when toggle
    interrupt      : out std_logic;     -- Radio controller interrupt
    diag_port0     : out std_logic_vector(15 downto 0);  -- Diagnostic port 0
    diag_port1     : out std_logic_vector(15 downto 0)   -- Diagnostic port HiSS
    
    
  );

end radioctrl;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of radioctrl is


  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Data & request handler
  signal startacc            : std_logic;  -- Triggers RF controller
  signal writeacc            : std_logic;  -- RF access type
  signal rf_addr             : std_logic_vector(5 downto 0);  -- Radio register address
  signal rf_wrdata           : std_logic_vector(15 downto 0);  -- Radio register address
  signal clockswitch_timeout : std_logic;  -- Clock switch time out
  signal parityerr           : std_logic;  -- parity error
  signal retried_parityerr   : std_logic;  -- Max parity error number reached
  signal agcerr              : std_logic;  -- AGC parity error
  signal readacc_timeout     : std_logic;  -- Read access time out
  signal hiss_rxen_int       : std_logic;  -- Enable reception in Hiss mode
  signal hiss_txen_int       : std_logic;  -- Enable reception in Hiss mode
  signal conflict            : std_logic;  -- Conflict RD /RX
  signal interrupt_int       : std_logic;  -- Interrupt
  

  -- Registers
  signal txiqswap     : std_logic;      -- Swap Tx I&Q
  signal rxiqswap     : std_logic;      -- Swap Rx I&Q
  signal maxresp      : std_logic_vector(5 downto 0);  -- Max. response time for
  signal retry        : std_logic_vector(2 downto 0);  -- Max parity errors accepted
  signal soft_accend  : std_logic;      -- Indicates end of software request
  signal soft_rddata  : std_logic_vector(15 downto 0);  -- Software read data
  signal soft_req     : std_logic;      -- Software requests access to RF
  signal soft_addr    : std_logic_vector(5 downto 0);  -- RF register address
  signal soft_wrdata  : std_logic_vector(15 downto 0);  -- Write data
  signal soft_acctype : std_logic;      -- Write data
  signal edgemode     : std_logic;      -- Single/Dual edge mode
  signal forcehisspad : std_logic;      -- Force HISS pad to be always on
  signal swcase       : std_logic_vector(1 downto 0);  -- RF switch
  signal forcedacon   : std_logic;        -- when high, always enable dac
  signal forceadcon   : std_logic;        -- when high, always enable adc  
  signal paondel      : std_logic_vector(7 downto 0);  -- Delay to switch PA on
  signal txstartdel   : std_logic_vector(7 downto 0);  -- Delay to wait bef send tx_onoff_conf
  signal antforce     : std_logic;          -- Forces antenna switch
  signal useant       : std_logic;          -- Selects antenna to use
  signal band         : std_logic;          -- Select 2.4/5 GHz PA
  signal b_antsel     : std_logic;          -- give info on the antenna selection for B


  -- HISS
  signal parityerr_tog     : std_logic;  -- Parity error during access
  signal agcerr_tog        : std_logic;  -- AGC Parity error during access
  signal protocol_err      : std_logic;  -- Protocol error during acess
  signal clockswitch_req   : std_logic;  -- Clock switch has been requested
  signal clk_switched      : std_logic;  -- Clock has been switched
  signal sw_rfoff_req_int  : std_logic;  -- Request to switch off the RF
  signal rf_off_done       : std_logic;  -- RF has been switched off
  signal hiss_accend       : std_logic;  -- HISS int. access finished
  signal hiss_rddata       : std_logic_vector(15 downto 0);  -- HISS IF read data
  signal hiss_rxi_int      : std_logic_vector(10 downto 0);  -- Rx data received by HISS
  signal hiss_rxq_int      : std_logic_vector(10 downto 0);
  signal hiss_rxdatavalid  : std_logic;
  signal hiss_txi_int      : std_logic_vector(9 downto 0);  -- Tx data received by HISS
  signal hiss_txq_int      : std_logic_vector(9 downto 0);
  signal hiss_txdatavalid  : std_logic;
  signal tx_b              : std_logic_vector(1 downto 0);  -- Tx angle
  signal rf_switch_ant_tog : std_logic;  -- toggle when ask fo switch
  signal cs_error          : std_logic;  -- when high error on CS
  signal clk_2skip_tog_int : std_logic;  -- when pulse 2 clk_skip asked
  signal agc_cs_valid_int  : std_logic;  -- Carrier sense valid
  signal agc_cs_int        : std_logic_vector(1 downto 0);  -- Carrier Sense
  signal agc_ccaflags_int  : std_logic_vector(5 downto 0); -- CCA info
  signal agc_ccamarker_int : std_logic; -- CCA is valid
  
  -- Analog radio interface
  signal ana_accend          : std_logic;  -- Analog int. access finished
  signal ana_rddata          : std_logic_vector(15 downto 0);  -- Analog IF read data

  -- Diag port
  signal ana_int_diag        : std_logic_vector(1 downto 0);
  signal txon_req            : std_logic;
  signal rf_off_reg_req      : std_logic;
  signal txv_immstop_masked  : std_logic;
  signal clkdiv_int          : std_logic_vector(2 downto 0);
  

  -- BuP signal
  signal txv_immstop_resync  : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin


  ---------------------------------------------------------------
  -- txv_immstop resynchronization(1 FF since same clock domains)
  ---------------------------------------------------------------
  immstop_resync_p : process(reset_n , clk)
  begin
   if(reset_n='0') then
     txv_immstop_resync <= '0';
   elsif(clk'event and clk='1') then
     txv_immstop_resync <= txv_immstop;
   end if;
  end process immstop_resync_p;
  
  -----------------------------------------------------------------------------
  -- Request handler
  -----------------------------------------------------------------------------
  reqdata_handler_1: reqdata_handler
    generic map (
      ana_digital_g => ana_digital_g)
    port map (
      clk                   => clk,           -- APB clock
      sampling_clk          => sampling_clk,  -- Sampling clock
      reset_n               => reset_n,
      hiss_rxi_i            => hiss_rxi_int,
      hiss_rxq_i            => hiss_rxq_int,
      hiss_rxdatavalid_i    => hiss_rxdatavalid,
      ana_rxi_i             => ana_rxi,
      ana_rxq_i             => ana_rxq,
      hiss_txi_o            => hiss_txi_int,
      hiss_txq_o            => hiss_txq_int,
      hiss_txdatavalid_o    => hiss_txdatavalid,   -- Resynchronized on 80 MHz
      ana_txi_o             => ana_txi,
      ana_txq_o             => ana_txq,
      -- AGCs data
      agc_busy_i            => agc_busy,           -- Indicates RF access restricted
      agc_bb_switch_ant_tog => agc_ant_switch_tog, -- toggle when switch antenna request of AGC BB
      agc_rf_switch_ant_tog => rf_switch_ant_tog,  -- toggle when switch antenna request of AGC RF
      agc_rxonoff_req_i     => agc_rxonoff_req,    -- Request to conf. Rx mode
      agc_stream_enable_i   => agc_stream_enable,  -- Enable hiss 'pipe' on reception
      agc_rfoff             => agc_rfoff,          -- Request from the AGC to stop the
                                                   -- radio(MACADDR does not match)
      --
      agc_rxonoff_conf_o    => agc_rxonoff_conf,   --  Ack to conf. Rx mode
      -- Bup
      txv_immstop           => txv_immstop_resync,
      txpwr_req_i           => txpwr_req,      -- Power level programming req.
      txpwr_i               => txpwr,          -- Power level
      paindex_i             => txv_paindex,    -- Index of PA table
      txv_txant_i           => txv_txant,      -- Tx antenna used
      txpwr_conf_o          => txpwr_conf,     -- Power level programming conf.
      -- Modem
      a_txdatavalid_i       => a_txdatavalid,
      b_txdatavalid_i       => b_txdatavalid,
      a_txonoff_req_i       => a_txonoff_req,     -- Request to conf. Tx mode
      a_txbbonoff_req_i     => a_txbbonoff_req,   -- Request to conf. Tx mode
      b_txonoff_req_i       => b_txonoff_req,     -- Request to conf. Tx mode
      b_txbbonoff_req_i     => b_txbbonoff_req,   -- Request to conf. Tx mode
      --
      a_rxdatavalid_o       => a_rxdatavalid,
      b_rxdatavalid_o       => b_rxdatavalid,
      a_txonoff_conf_o      => a_txonoff_conf,    -- Conf. Tx mode
      b_txonoff_conf_o      => b_txonoff_conf,    -- Conf. Tx mode
      --
      txi_i                 => txi,
      txq_i                 => txq,
      --
      rxi_o                 => rxi,
      rxq_o                 => rxq,
      -- AGC
      agc_req_i             => agc_req,     -- AGC requests RF access
      agc_addr_i            => agc_addr,    -- RF reg. address
      agc_wrdata_i          => agc_wrdata,  -- RF reg write data
      agc_wr_i              => agc_wr,  -- RF reg access type
      agc_adcen_i           => agc_adc_enable,   -- Requests ADC to be switched on
      agc_ab_mode_i         => agc_ab_mode, -- Mode of received packet
      tx_ab_mode_i          => tx_ab_mode,  -- Indicates type of packet transmitted
      agc_conf_o            => agc_conf,    -- Conf. to AGC request
      agc_rddata_o          => agc_rddata,  -- RF reg. read data
      parityerr_tog_i       => parityerr_tog,    -- Parity error during access
      agcerr_tog_i          => agcerr_tog,       -- AGC error parity toggle
      cs_error_i            => cs_error,    -- CS error when pulse
      protocol_err_i        => protocol_err,  -- Protocol error during acess
      clockswitch_req_i     => clockswitch_req,  -- Clock switch has been requested
      clock_switched_i      => clk_switched,     -- Clock has been switched
      ana_rxen_o            => ana_rxen,    -- Enable Rx path
      ana_txen_o            => ana_txen,    -- Enable Tx path
      rf_sw_o               => rf_sw, -- RF switches
      pa_on_o               => pa_on, -- high when pa is on
      ana_adc_en_o          => ana_adcen,  -- ADC enable
      ana_dac_en_o          => ana_dacen,  -- DAC enable
      hiss_rxen_o           => hiss_rxen_int,  -- Enable reception in Hiss mode
      hiss_txen_o           => hiss_txen_int,  -- Enable transmission in Hiss mode
      txon_req_o            => txon_req,       -- Txon mode
      rf_off_reg_req_o      => rf_off_reg_req,
      txv_immstop_masked_o  => txv_immstop_masked,
      sw_rfoff_req_i        => sw_rfoff_req_int,  -- Request to switch off the RF
      rf_off_done_o         => rf_off_done,   -- RF has been switched off
      
      ana_accend_i          => ana_accend,  -- Analog int. access finished
      hiss_accend_i         => hiss_accend,  -- HISS int. access finished
      ana_rddata_i          => ana_rddata,  -- Analog IF read data
      hiss_rddata_i         => hiss_rddata,  -- HISS IF read data
      startacc_o            => startacc,    -- Triggers RF controller
      writeacc_o            => writeacc,    -- RF access type
      rf_addr_o             => rf_addr,     -- Radio register address
      rf_wrdata_o           => rf_wrdata,   -- Radio register address
      soft_req_i            => soft_req,    -- Software requests access to RF
      soft_addr_i           => soft_addr,   -- RF register address
      soft_wrdata_i         => soft_wrdata,  -- Write data
      soft_acctype_i        => soft_acctype,  -- Write data
      rfmode_i              => rfmode,      -- Selects HISS/Analog interface
      txiqswap_i            => txiqswap,    -- Swap Tx I&Q
      rxiqswap_i            => rxiqswap,    -- Swap Rx I&Q
      maxresp_i             => maxresp,     -- Max. response time for
      maxparerr_i           => retry,   -- Max parity errors accepted
      paondel_i             => paondel,  -- Delay to switch PA on
      forcedacon_i          => forcedacon,  -- when high, always enable dac
      forceadcon_i          => forceadcon,  -- when high, always enable adc
      txstartdel_i          => txstartdel,   --  Delay to wait bef send tx_onoff_conf
      band_i                => band,         -- Select between 2.4/5 GHz
--      useant_i              => useant,       -- Indicates which antenna to use
      useant_i              => useant,       -- Indicates which antenna to use
      antforce_i            => antforce,     -- Forces antenna switch
      swcase_i              => swcase,       -- Antenna configuration
      b_antsel_o            => b_antsel,     -- give info on the antenna selection for B
      soft_accend_o         => soft_accend,  -- Indicates end of software request
      soft_rddata_o         => soft_rddata,  -- Software read data
      clockswitch_timeout_o => clockswitch_timeout,  -- Clock switch time out
      retried_parityerr_o   => retried_parityerr,   -- Max parity error number reached
      parityerr_o           => parityerr,   -- parity error
      agcerr_o              => agcerr,      -- AGC parity error
      conflict_o            => conflict,   -- Conflict : RD / RX
      readacc_timeout_o     => readacc_timeout);   -- Read access time out

  -----------------------------------------------------------------------------
  -- Registers
  -----------------------------------------------------------------------------
  radioctrl_registers_1: radioctrl_registers
    generic map (
      ana_digital_g => ana_digital_g)
    port map (
      -- Reset                         
      reset_n             => reset_n,
      -- APB interface                           
      psel_i              => psel,
      penable_i           => penable,
      paddr_i             => paddr,
      pwrite_i            => pwrite,
      pclk                => pclk,
      pwdata_i            => pwdata,
      prdata_o            => prdata,
      -- AGC interrupt
      agc_rfint_i         => agc_rfint,     -- Interrupt from AGC RF decoded by AGC BB
      -- Request handler                         
      accend_i            => soft_accend,   -- Software access end
      rddata_i            => soft_rddata,   -- Read data
      parityerr_i         => parityerr,     -- Parity error
      retried_parityerr_i => retried_parityerr,    -- Parity error
      agcerr_i            => agcerr,        -- Parity err on AGC transmission
      proterr_i           => protocol_err,  -- Protocol error
      conflict_i          => conflict,      -- Conflict RD / RX
      readto_i            => readacc_timeout,      -- Read access time out
      clkswto_i           => clockswitch_timeout,  -- Clock switch time out
      clksw_i             => clk_switched,  -- Clock freq. has been switched
      sw_rfoff_req_o      => sw_rfoff_req_int, -- Request to switch off the RF
      rf_off_done_i       => rf_off_done,      -- RF has been switched off
      startacc_o          => soft_req,      -- Start 3w access
      acctype_o           => soft_acctype,  -- Access type
      edgemode_o          => edgemode,      -- Clock edge active
      radad_o             => soft_addr,     -- Register address
      wrdata_o            => soft_wrdata,   -- Write data
      maxresp_o           => maxresp,       -- Number of cc to wait
      retry_o             => retry,         -- Number of trials
      -- Radio interface            
      txiqswap_o     => txiqswap,      -- Swap TX I/Q lines
      rxiqswap_o     => rxiqswap,      -- Swap RX I/Q lines
      -- HiSS interface            
      forcehisspad_o => forcehisspad, -- Force HISS pad to be always on
      hiss_biasen_o  => hiss_biasen, -- enable HiSS drivers and receivers
      hiss_replien_o => hiss_replien,-- enable HiSS drivers and receivers
      hiss_clken_o   => hiss_clken,  -- Enable HiSS clock receivers
      hiss_curr_o    => hiss_curr,   -- Select high-current mode for HiSS drivers
      -- Radio             
      b_antsel_i     => b_antsel,   -- give info on the antenna selection for B
      xoen_o         => ana_xoen,          -- Enable RF crystal oscillator
      band_o         => band,         -- Select 5/2.4 GHz power ampl.
      txstartdel_o   => txstartdel,   -- Delay to wait bef send tx_onoff_conf
      paondel_o      => paondel,      -- Delay to switch on PA
      forcedacon_o   => forcedacon,   -- when high, always enable dac
      forceadcon_o   => forceadcon,   -- when high, always enable adc
      
      swcase_o       => swcase,        -- RF switches
      antforce_o     => antforce,    -- Forces antenna switch
--      useant_o       => useant,      -- Selects antenna to use
      useant_o       => useant,      -- Selects antenna to use
      
       -- Misc                 
      interrupt_o    => interrupt_int);    -- Interrupt

  interrupt <= interrupt_int;
  -----------------------------------------------------------------------------
  -- Radio interface
  -----------------------------------------------------------------------------

  ANA_INT_GEN: if ana_digital_g = 1 or ana_digital_g = 3 generate

    ana_int_ctrl_1: ana_int_ctrl
      port map (
        reset_n        => reset_n,
        clk            => clk,
        clk_n          => clk_n,
        rfmode         => rfmode,
        edgemode       => edgemode,
        startacc       => startacc,
        rf_addr        => rf_addr,
        rf_wrdata      => rf_wrdata,
        writeacc       => writeacc,
        read_timeout   => readacc_timeout,
        accend         => ana_accend,
        ana_rddata     => ana_rddata,
        rf_3wdatain    => ana_3wdatain,
        rf_3wenablein  => ana_3wenablein,
        rf_3wclk       => ana_3wclk,
        rf_3wdataout   => ana_3wdataout,
        rf_3wdataen    => ana_3wdataen,
        rf_3wenableout => ana_3wenableout,
        rf_3wenableen  => ana_3wenableen,
        diag_port      => ana_int_diag);
    
  end generate ANA_INT_GEN;

  NO_ANA_INT_GEN: if ana_digital_g = 2  generate
    ana_accend <= '0';
  end generate NO_ANA_INT_GEN;


  HISS_INT_GEN : if ana_digital_g = 2 or ana_digital_g = 3 generate



    master_hiss_1 : master_hiss
      generic map (
        rx_a_size_g      => 11,         -- size of data of rx_filter A
        rx_b_size_g      => 8,          -- size of data of rx_filter B
        tx_a_size_g      => 10,         -- size of data input of tx_filter A
        tx_b_size_g      => 1,          -- size of data input of tx_filter B
        clk44_possible_g => clk44_possible_g)   -- when 1 - the radioctrl can work with a
      
      port map (
       -- Clocks & Reset
        hiss_clk             => hiss_clk,   -- 240 MHz clock
        rfh_fastclk          => rfh_fastclk,  -- 240 MHz clock but without clk_tree(from pad)
        pclk                 => pclk,   -- 80  MHz clock
        reset_n              => reset_n,
        hiss_reset_n         => hiss_reset_n, 
        -- Interface with Wild_RF
        rf_rxi_i             => hiss_rxi,   -- Real Part received
        rf_rxq_i             => hiss_rxq,   -- Imaginary Part received
        --
        rf_txi_o             => hiss_txi,   -- Real Part to send
        rf_txq_o             => hiss_txq,   -- Imaginary Part to send
        rf_txen_o            => hiss_txen,  -- Enable the rf_txi/rf_txq output when high
        rf_rxen_o            => hiss_rxen,  -- Enable the inputs rf_rx when high
        rf_en_o              => rf_en,      -- Control Signal - enable transfers
        -- Interface with muxed tx path
        -- Data from Tx Filter A and B
        tx_ai_i              => txi,
        tx_aq_i              => txq,
        tx_val_tog_a_i       => a_txdatavalid,  -- toggle = data is valid
        --
        tx_b_i               => tx_b,
        tx_val_tog_b_i       => hiss_txdatavalid,  -- toggle = data is valid
        -- Interface with Rx Paths 
        hiss_enable_n_i      => rfmode,  -- enable block 60 MHz
        -- Data from Rx Filter A or B
        rx_i_o               => hiss_rxi_int,  -- B data are on LSB
        rx_q_o               => hiss_rxq_int,  -- B data are on LSB
        rx_val_tog_o         => hiss_rxdatavalid,  -- toggle = data is valid
        clk_2skip_tog_o      => clk_2skip_tog_int,  -- high when 2 clock-skip is needed | gated 44 MHz clk
        --
        rf_en_force_i        => rf_en_force,  -- clock reset force rf_en in order to wake up hiss clock.
        tx_abmode_i          => tx_ab_mode,  -- transmission mode : 0 = A , 1 = B
        rx_abmode_i          => agc_ab_mode,  -- reception mode : 0 = A , 1 = B
        force_hiss_pad_i     => forcehisspad,  -- when high the receivers/drivers are always activated
        apb_access_i         => startacc,   -- ask of apb access (wr or rd)
        wr_nrd_i             => writeacc,   -- wr_nrd = '1' => write access
        rd_time_out_i        => readacc_timeout,  -- time out : no reg val from RF
        clkswitch_time_out_i => clockswitch_timeout,  -- time out : no clock switch happens
        wrdata_i             => rf_wrdata,  -- data to write in reg
        add_i                => rf_addr,  -- add of the reg access
        sync_found_i         => sync_found,  -- high and remain high when sync is found
        -- BuP control
        txv_immstop_i        => txv_immstop_resync, -- BuP asks for immediate transmission stop
        -- Control signals Inputs (from Radio Controller)   
        recep_enable_i       => hiss_rxen_int,  -- high = BB accepts incoming data (after CCA detect)
        trans_enable_i       => hiss_txen_int,  -- high = there are data to transmit
        -- Data (from read-access)
        parity_err_tog_o     => parityerr_tog,  -- toggle when parity check error (no data will be sent)
        rddata_o             => hiss_rddata,
        -- Control Signals    
        cca_search_i         => agc_rxonoff_req,  -- wait for CCA (wait for pr_detected_o)
        --
        cca_info_o           => agc_ccaflags_int,   --  CCA information
        cca_add_info_o       => agc_cca_add_flags,   --  CCA additional information
        cca_o                => agc_ccamarker_int,  -- pulse when valid
        parity_err_cca_tog_o => agcerr_tog,     -- toggle when err during CCA access
        cs_error_o           => cs_error,   -- pulse, valid when high
        switch_ant_tog_o     => rf_switch_ant_tog,  -- toggle = antenna switch
        cs_o                 => agc_cs_int,   -- CS info for AGC/CCA
        cs_valid_o           => agc_cs_valid_int,   -- high when the CS is valid
        acc_end_o            => hiss_accend,  -- toggle => acc finished
        prot_err_o           => protocol_err,  -- "long signal" : error on the protocol
        clk_switch_req_o     => clockswitch_req,  -- pulse: clk swich req for time out
        clk_div_o            => clkdiv_int,   -- val of rf_fastclk speed
        clk_switched_tog_o   => clock_switched_tog,  --toggle, the clock will switch
        clk_switched_80_o    => clk_switched,      -- pulse, the clock will switch (80 MHz)
        --
        hiss_diagport_o      => open);
    
    tx_b <= hiss_txi_int(0) & hiss_txq_int(0);

    
  end generate HISS_INT_GEN;

  -- Output Linking
  clkdiv            <= clkdiv_int;
  clk_2skip_tog     <= clk_2skip_tog_int;
  -- Request to switch off the RF for the AGC BB
  sw_rfoff_req      <= sw_rfoff_req_int;
  
  agc_ccaflags  <= agc_ccaflags_int;
  agc_ccamarker <= agc_ccamarker_int;
  agc_cs        <= agc_cs_int;
  agc_cs_valid  <= agc_cs_valid_int;
 
  

  NO_HISS_INT_GEN: if ana_digital_g = 1 generate
    rf_switch_ant_tog    <= '0';
    protocol_err         <= '0';
    clock_switched_tog   <= '0';
    clk_switched         <= '0';
    parityerr_tog        <= '0';
    agcerr_tog           <= '0';
    hiss_accend          <= '0';
    hiss_rxi_int         <= (others => '0');
    hiss_rxq_int         <= (others => '0');
    hiss_rxdatavalid     <= '0';
    clockswitch_req      <= '0';
    hiss_rddata          <= (others => '0');
    clkdiv_int           <= (others => '0');
    hiss_rxen            <= '0';
    hiss_txen            <= '0';
    hiss_txi             <= '0';
    hiss_txq             <= '0';
    rf_en                <= '0';
    cs_error             <= '0';
    clk_2skip_tog_int    <= '0';

  end generate NO_HISS_INT_GEN;

  -- Diagport Link
  -----------------------------------------------------------------------------
  -- Diagport 0
  -----------------------------------------------------------------------------
  -- Registers Accesses Signals
  diag_port0(0) <= soft_req;
  diag_port0(1) <= conflict;
  diag_port0(2) <= interrupt_int;
  diag_port0(3) <= writeacc;
  diag_port0(4) <= txv_immstop_masked;
  diag_port0(5) <= hiss_accend or ana_accend;
  diag_port0(6) <= startacc;
  -- Clk Switch
  diag_port0(9 downto 7) <= clkdiv_int;
  diag_port0(10) <= clk_switched;
  diag_port0(11) <= clockswitch_req;
  -- Error Cases
  diag_port0(12) <= parityerr_tog when rfmode = '0' else ana_int_diag(0);
  diag_port0(13) <= cs_error      when rfmode = '0' else ana_int_diag(1);
  diag_port0(14) <= agcerr_tog;
  diag_port0(15) <= protocol_err;

  -----------------------------------------------------------------------------
  -- Diagport 1
  -----------------------------------------------------------------------------
  diag_port1(0) <= clk_2skip_tog_int;
  diag_port1(1) <= hiss_rxdatavalid;
  diag_port1(2) <= hiss_txen_int;
  diag_port1(3) <= txon_req;
  diag_port1(4) <= rf_off_reg_req;
  diag_port1(8 downto 5) <= agc_ccaflags_int(4 downto 1);
  diag_port1(9) <= agc_ccamarker_int;
  diag_port1(11 downto 10) <= agc_cs_int;
  diag_port1(12) <= agc_cs_valid_int;
  diag_port1(13) <= agc_busy;
  diag_port1(14) <= agc_rxonoff_req;
  diag_port1(15) <= agc_ab_mode;

  
end RTL;
