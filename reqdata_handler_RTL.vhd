
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: reqdata_handler.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.40   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Request and data handler:
--               * Manage access priority to the radio interface controller
--               * Process data sent or received
--               * Controls RF switches and enable
-- 
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/radioctrl/vhdl/rtl/reqdata_handler.vhd,v  
--  Log: reqdata_handler.vhd,v  
-- Revision 1.40  2005/10/04 12:27:18  Dr.A
-- #BugId:1398#
-- Completed sensitivity list in registers and reqdata_handler.
-- Removed unused signals and rf_goto_sleep port
--
-- Revision 1.39  2005/03/10 08:47:03  sbizet
-- #BugId:907,948,946#
-- new diag ports
--
-- Revision 1.38  2005/03/02 12:59:33  sbizet
-- #BugId:907#
-- Signal wait_end_tx not generated in Tx
--
-- Revision 1.37  2005/02/11 14:47:56  sbizet
-- #BugId:953#
-- Renamed resync FF
--
-- Revision 1.36  2005/01/21 08:31:36  sbizet
-- #BugId:953,713,948,907#
-- o Added wait end of Rx software rf off
-- o Write access possible in Rx
-- o AGC RF reseted when a Rx is stopped to
-- insure several Rx can be performed
-- o b_txbbonoff_req resynchronized -> 0.18 um issue
--
-- Revision 1.35  2005/01/06 17:19:04  sbizet
-- #BugId:907,948,946,947#
-- Added:
-- o software radio off request
-- o Tx immediate stop
-- o radio off when MACADDR does not match
-- o Avoid generating read time out when maxresp =0
--
-- Revision 1.34  2004/12/15 14:53:33  sbizet
-- #BugId:907#
-- Added txv_txant port
--
-- Revision 1.33  2004/10/29 15:54:09  sbizet
-- #BugId:804#
-- Resynchronized b_txdatavalid on bus_gclk
--
-- Revision 1.32  2004/10/25 13:39:55  sbizet
-- #BugId:801#
-- Analog TX IQ swap stuff put in the same generate as
-- RX IQ swap stuff
--
-- Revision 1.31  2004/07/16 07:42:11  Dr.B
-- add pabias info feature
--
-- Revision 1.30  2004/06/04 13:51:50  Dr.C
-- Changed to only one port for Tx/Rx data.
--
-- Revision 1.29  2004/02/19 17:29:54  Dr.B
-- add b_antsel.
--
-- Revision 1.28  2004/01/12 13:46:13  Dr.B
-- retried_parity_err is a pulse.
--
-- Revision 1.27  2004/01/07 13:16:01  Dr.B
-- remove ab_mode condition.
--
-- Revision 1.26  2004/01/07 09:22:18  Dr.B
-- delay rxon_req by masking it when txon_req_ff1 = 1 (instead of txon_req).
--
-- Revision 1.25  2004/01/06 18:07:34  Dr.B
-- mask rxon_req when txon_req.
--
-- Revision 1.24  2003/12/23 16:49:08  Dr.B
-- in hiss mode, startacc is 2 periods.
--
-- Revision 1.23  2003/12/17 15:22:21  Dr.B
-- remove rf_rx when hiss only,
--
-- Revision 1.22  2003/12/08 08:47:43  Dr.B
-- change rxon_reg_req conditions for compensating control signals of modem A.
--
-- Revision 1.21  2003/12/04 10:54:19  Dr.B
-- agc_rxonoff_conf goes to low only when agc has been reset.
--
-- Revision 1.20  2003/12/04 08:30:36  Dr.B
-- add condition on txpwr_req.
--
-- Revision 1.19  2003/12/03 17:33:19  Dr.B
-- add diagport.
--
-- Revision 1.18  2003/12/03 08:17:02  Dr.B
-- reset read time out counter when parity err.
--
-- Revision 1.17  2003/12/01 13:24:33  Dr.B
-- debug txonoff_conf when txstartdel = 0
--
-- Revision 1.16  2003/12/01 10:02:49  Dr.B
-- delay txonoff_req for timings matters.
--
-- Revision 1.15  2003/11/27 10:26:11  Dr.B
-- memo of data when idle.
--
-- Revision 1.14  2003/11/26 16:09:58  Dr.B
-- soft_req delayed.
--
-- Revision 1.13  2003/11/21 17:58:47  Dr.B
-- debug conflict accesses + increase clk switch time out.
--
-- Revision 1.12  2003/11/20 11:29:20  Dr.B
-- conflict access included.
--
-- Revision 1.11  2003/11/17 14:52:36  Dr.B
-- add modem request.
--
-- Revision 1.10  2003/11/05 08:32:36  Dr.B
-- add a_txbbronoff_req.
--
-- Revision 1.9  2003/11/03 16:01:18  Dr.B
-- output pa_on.
--
-- Revision 1.8  2003/10/31 08:38:23  Dr.B
-- change enable of the adc order.
--
-- Revision 1.7  2003/10/31 08:11:31  Dr.B
-- no enable of the ADC in hiss mode.
--
-- Revision 1.6  2003/10/30 16:37:27  Dr.B
-- change txpwr size.
--
-- Revision 1.5  2003/10/30 14:42:51  Dr.B
-- update to spec 0.06.
--
-- Revision 1.4  2003/10/24 09:10:46  Dr.C
-- Debugged txonoffconf
--
-- Revision 1.3  2003/10/09 08:30:50  Dr.C
-- Removed glitch found
--
-- Revision 1.2  2003/09/25 12:36:56  Dr.C
-- Added glitch found processing
--
-- Revision 1.1  2003/09/23 13:10:30  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity reqdata_handler is
  generic (
    ana_digital_g : integer := 3);  -- Selects between analog and HISS interface
                                    -- 0: reserved
                                    -- 1: analog interface
                                    -- 2: digital interface
                                    -- 3: both
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in std_logic;        -- APB clock
    sampling_clk : in std_logic;        -- Sampling clock
    reset_n      : in std_logic;

    --------------------------------------
    -- Tx data
    --------------------------------------
    hiss_rxi_i         : in  std_logic_vector(10 downto 0);
    hiss_rxq_i         : in  std_logic_vector(10 downto 0);
    hiss_rxdatavalid_i : in  std_logic;  -- Toggles when new data is valid
    ana_rxi_i          : in  std_logic_vector(7 downto 0);
    ana_rxq_i          : in  std_logic_vector(7 downto 0);
    --
    hiss_txi_o         : out std_logic_vector(9 downto 0);
    hiss_txq_o         : out std_logic_vector(9 downto 0);
    hiss_txdatavalid_o : out std_logic;  -- Toggles when new data is valid
    ana_txi_o          : out std_logic_vector(7 downto 0);
    ana_txq_o          : out std_logic_vector(7 downto 0);
    
    --------------------------------------
    -- AGCs data
    --------------------------------------
    agc_busy_i             : in std_logic;  -- Indicates RF access restricted to AGC
    agc_bb_switch_ant_tog  : in std_logic;  -- toggle when switch antenna request
    agc_rf_switch_ant_tog  : in std_logic;  -- toggle when switch antenna request
    agc_rxonoff_req_i      : in std_logic;  -- Request to conf. Rx mode
    agc_stream_enable_i    : in std_logic;  -- Enable hiss 'pipe' on reception
    agc_rfoff              : in std_logic;  -- Request from the AGC to stop the
                                            -- radio(MACADDR does not match)
    --
    agc_rxonoff_conf_o     : out  std_logic;   -- Ack to conf. Rx mode
    --------------------------------------
    -- Bup data
    --------------------------------------
    -- modem
    txv_immstop      : in std_logic; -- Bup Tx immediate stop
    txpwr_req_i      : in std_logic; -- Power level programming req.
                                     --(actually connected to phy_txstartend_req
                                     -- to know when BuP requests for Tx)
    txpwr_i          : in std_logic_vector(3 downto 0);  -- Power level
    paindex_i        : in std_logic_vector(4 downto 0); -- index in the PA bias table -
                                                        -- valid with txpwr_req (paindex(0) = PAINDEXL)
    txv_txant_i      : in std_logic;       -- Tx antenna used
    --
    txpwr_conf_o     : out std_logic;   -- Power level programming conf.

    --------------------------------------
    -- Modem data
    --------------------------------------
    a_txdatavalid_i   : in  std_logic;
    b_txdatavalid_i   : in  std_logic;
    a_txonoff_req_i   : in  std_logic;  -- Request to conf. Tx mode
    a_txbbonoff_req_i : in  std_logic;  -- Same as previous but stop when no data in bb
    b_txonoff_req_i   : in  std_logic;  -- Request to conf. Tx mode
    b_txbbonoff_req_i : in  std_logic;  -- Same as previous but stop when no data in bb
    --
    a_rxdatavalid_o   : out std_logic;
    b_rxdatavalid_o   : out std_logic;
    a_txonoff_conf_o  : out std_logic;  -- Conf. Tx mode
    b_txonoff_conf_o  : out std_logic;  -- Conf. Tx mode   
    --
    txi_i             : in  std_logic_vector(9 downto 0);
    txq_i             : in  std_logic_vector(9 downto 0);
    --
    rxi_o             : out std_logic_vector(10 downto 0);
    rxq_o             : out std_logic_vector(10 downto 0);
    
    --------------------------------------
    -- Bup & AGC
    --------------------------------------
    agc_req_i     : in std_logic;       -- AGC requests RF access
    agc_addr_i    : in std_logic_vector(2 downto 0);  -- RF reg. address
    agc_wrdata_i  : in std_logic_vector(7 downto 0);  -- RF reg write data
    agc_wr_i      : in std_logic;       -- RF reg access type
    agc_adcen_i   : in std_logic;       -- Request AGC switch on
    agc_ab_mode_i : in std_logic;       -- Mode of received packet
    tx_ab_mode_i  : in std_logic;       -- Indicates type of packet transmitted
    --
    agc_conf_o    : out std_logic;       -- Conf. to AGC request
    agc_rddata_o  : out std_logic_vector(7 downto 0);   -- RF reg. read data
    
    --------------------------------------
    -- HISS interface
    --------------------------------------
    parityerr_tog_i   : in std_logic;     -- Parity error during access
    agcerr_tog_i      : in std_logic;     -- AGC error parity toggle
    cs_error_i        : in std_logic;     -- CS error when high (pulse whem high)
    protocol_err_i    : in std_logic;     -- Protocol error during access
    clockswitch_req_i : in std_logic;     -- Clock switch has been requested
    clock_switched_i  : in std_logic;     -- Clock has been switched

    --------------------------------------
    -- RF control
    --------------------------------------
    ana_rxen_o           : out std_logic;  -- Enable Rx path
    ana_txen_o           : out std_logic;  -- Enable Tx path
    rf_sw_o              : out std_logic_vector(3 downto 0);  -- RF switches
    pa_on_o              : out std_logic; -- high when PA is on
    ana_adc_en_o         : out std_logic_vector(1 downto 0);  -- ADC enable
    ana_dac_en_o         : out std_logic;  -- DAC enable
    hiss_rxen_o          : out std_logic;  -- Enable reception in Hiss mode
    hiss_txen_o          : out std_logic;  -- Enable transmission in Hiss mode
    txon_req_o           : out std_logic;  -- txon_req
    rf_off_reg_req_o     : out std_logic;  -- additional access to switch off radio
    txv_immstop_masked_o : out std_logic;

    --------------------------------------
    -- Radio interface controller
    --------------------------------------
    ana_accend_i      : in std_logic;   -- Analog int. access finished
    hiss_accend_i     : in std_logic;   -- HISS int. access finished
    ana_rddata_i      : in std_logic_vector(15 downto 0);  -- Analog IF read data
    hiss_rddata_i     : in std_logic_vector(15 downto 0);  -- HISS IF read data
    --
    startacc_o  : out std_logic;        -- Triggers RF controller
    writeacc_o  : out std_logic;        -- RF access type
    rf_addr_o   : out std_logic_vector(5 downto 0);  -- Radio register address
    rf_wrdata_o : out std_logic_vector(15 downto 0);  -- Radio register address
    
    
    --------------------------------------
    -- Register
    --------------------------------------
    soft_req_i     : in  std_logic;  -- Software requests access to RF
    soft_addr_i    : in  std_logic_vector(5 downto 0);  -- RF register address
    soft_wrdata_i  : in  std_logic_vector(15 downto 0);  -- Write data
    soft_acctype_i : in  std_logic;  -- Write data
    rfmode_i       : in  std_logic;  -- Selects HISS/Analog interface
    txiqswap_i     : in  std_logic;  -- Swap Tx I&Q
    rxiqswap_i     : in  std_logic;  -- Swap Rx I&Q
    maxresp_i      : in  std_logic_vector(5 downto 0);  -- Max. response time for
                                                        -- a read access
    maxparerr_i    : in  std_logic_vector(2 downto 0);  -- Max parity errors accepted
    paondel_i      : in  std_logic_vector(7 downto 0);  -- Delay to switch PA on
    forcedacon_i   : in  std_logic; -- when high, always enable dac
    forceadcon_i   : in  std_logic; -- when high, always enable adc
    txstartdel_i   : in  std_logic_vector(7 downto 0);  -- Delay to wait bef send tx_onoff_conf
    band_i         : in  std_logic;     -- Select between 2.4/5 GHz
--    useant_i       : in  std_logic;     -- Indicates which antenna to use
    useant_i       : in  std_logic;     -- Indicates which antenna to use
    antforce_i     : in  std_logic;     -- Forces antenna switch
    swcase_i       : in  std_logic_vector(1 downto 0);  -- Antenna configuration
    sw_rfoff_req_i : in  std_logic;     -- Request to switch off the RF
    --
    rf_off_done_o         : out std_logic;  -- RF has been switched off(Pulse Interrupt)
    b_antsel_o            : out std_logic;  -- give info on the antenna selection for B
    soft_accend_o         : out std_logic;  -- Indicates end of software request
    soft_rddata_o         : out std_logic_vector(15 downto 0);  -- Software read data
    clockswitch_timeout_o : out std_logic;  -- Clock switch time out
    retried_parityerr_o   : out std_logic;  -- Max parity error number reached
    parityerr_o           : out std_logic;  -- a parity error happens
    agcerr_o              : out std_logic;  -- AGC error parity
    conflict_o            : out std_logic;  -- Conflict : RD / RX
    readacc_timeout_o     : out std_logic   -- Read access time out
    
  );

end reqdata_handler;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of reqdata_handler is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant CLK_SWITCH_TIMEOUT_CT  : std_logic_vector(12 downto 0) := "1011101110000";  -- 15 us
  constant RFTXGAIN_CT            : std_logic_vector(5 downto 0) := "000011";

  -- Address of the WILD_RF RFDYNCNTL register (only on HiSS mode)
  constant RFDYNCNTL_ADDR_CT : std_logic_vector(5 downto 0):="000010";
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type REQ_HANDLER_STATE_TYPE is (idle_state ,     -- Idle state
                                  modem_req_state, -- Modem request is being
                                                   -- processed
                                  rf_off_state,    -- Radio switch off is being
                                                   -- processed
                                  soft_req_state   -- Software request is being
                                                   -- processed
                                  );

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Request
  signal req_handler_state      : REQ_HANDLER_STATE_TYPE;  -- Request handler 
  signal req_handler_next_state : REQ_HANDLER_STATE_TYPE;  -- state

  signal startacc         : std_logic;  -- Triggers radio interface controller
                                        -- to start a new access
  signal startacc_long    : std_logic;  -- Triggers radio interface controller
                                        -- to start a new access
  signal writeacc         : std_logic;  -- Radio access type
  signal accend           : std_logic;  -- Radio access finished
  signal modem_req        : std_logic;  -- All modem requests
  signal rddata_mux       : std_logic_vector(15 downto 0);  -- HISS and analog read 
                                                      -- data mux
  signal soft_req_masked  : std_logic;     -- Software request is processed to
                                        -- avoid requesting an access to the
                                        -- HISS radio interface when it is not
                                        --  possible
  
  -- Errors
  signal parityerr_tog_ff1   : std_logic;  -- parity error resync
  signal agcerr_tog_ff1      : std_logic;  -- agc parity error resync
  signal retry_counter       : std_logic_vector(2 downto 0);  -- Counts up nb of tries
  signal clockswitch_counter : std_logic_vector(12 downto 0);  -- Counts up clock
  --  cycles until clock frequency is switched 

  signal readacc_counter : std_logic_vector(5 downto 0);  -- Counts up cc during 
                                                          -- read accesses
  signal parityerr           : std_logic;  -- parity errors
  signal retried_parityerr   : std_logic;  -- Max number of parity errors reached
  signal clockswitch_timeout : std_logic;  -- PLL did not lock within 10 us
  signal readacc_timeout     : std_logic;  -- Read access time out
  signal access_error        : std_logic;  -- Compiles all error sources
  signal all_error           : std_logic;  --  Error that must stop the access
  signal conflict            : std_logic;  -- Error when RD before RX
  
  -- Data
  signal rf_txi       : std_logic_vector(7 downto 0);   -- Intermediate tx data
  signal rf_txq       : std_logic_vector(7 downto 0);
  signal rf_rxi       : std_logic_vector(10 downto 0);  -- Intermediate rx data
  signal rf_rxq       : std_logic_vector(10 downto 0);
  signal tx_datavalid : std_logic;      -- Toggles when a new data is valid

  -- RF control
  signal rxon_req           : std_logic;  -- Modems requested to switch on Rx path
  signal txon_req           : std_logic;  -- Modems requested to switch on Tx path
  signal rxon_reg_req       : std_logic;  -- Ask to switch to rx by wr on wild_rf reg
  signal txon_reg_req       : std_logic;  -- Ask to switch to tx by wr on wild_rf reg
  signal reset_agc_req      : std_logic;  -- Ask to reset agc by wr on wild_rf reg
  signal rf_off_reg_req     : std_logic;  -- Ask to switch off the radio
  signal txon_req_ff1       : std_logic;  -- memorized txonoff_req
  signal rxon_req_ff1       : std_logic;  -- memorized rxonoff_req
  signal agc_conf           : std_logic;  -- ack rxon_reg_req, txon_reg_req, reset_agc_req, agc_req
  signal radio_off          : std_logic;  -- Indicates if radio is on(1) or off(0), no matter Rx or Tx
  signal force_radio_off    : std_logic;  -- Initiates an access to radio to switch it off
  signal force_radio_off_ff1: std_logic;  -- Initiates an access to radio to switch it off(resynchronized)
  signal wait_end_tx        : std_logic;  -- Indicates the end of the Tx to Rx radio switching
  signal wait_end_tx_ff1    : std_logic;  -- Indicates the end of the Tx to Rx radio switching
  signal wait_end_rx        : std_logic;  -- Indicates the end of the Rx radio switching
  signal wait_end_rx_ff1    : std_logic;  -- Indicates the end of the Rx radio switching
  signal sw_rfoff_req_ff1   : std_logic;  -- Request to switch off the radio resynchonized
  signal agc_rfoff_ff1      : std_logic;  -- Request from the AGC to stop the radio(MACADDR does not match)
  
  signal txstartdel_counter : std_logic_vector(7 downto 0);  -- Counts up cc before
                                                             -- ack txon
  signal a_txonoff_conf_int : std_logic;
  signal b_txonoff_conf_int : std_logic;
  signal pa_on_int          : std_logic;  -- Switch PA on
  signal rfswitch           : std_logic;  -- Parameter to compute RF switch
  signal ana_txen           : std_logic;  -- Enable Tx path

  -- Ant Select Gen
  signal b_antsel              : std_logic; -- select which antenna to use
  signal agc_bb_sw_ant_tog_ff0 : std_logic; -- mem agc_bb_switch_ant_tog
  signal agc_rf_sw_ant_tog_ff0 : std_logic; -- mem agc_rf_switch_ant_tog

  -- ADC/DAC Control
  signal ana_adc_en            : std_logic_vector(1 downto 0);  -- ADC enable

  -- TXON_OFF_REQ resynchro
  signal a_txonoff_req_ff0     : std_logic;
  signal b_txonoff_req_ff0     : std_logic;
  signal agc_rxonoff_req_ff0   : std_logic;
  signal txv_immstop_masked    : std_logic;
  signal txv_immstop_ff0       : std_logic;
  signal wait_txon_req         : std_logic;
  -- Modem B datapath resynchro
  signal b_txdatavalid_ff1_resync     : std_logic;
  signal b_txdatavalid_ff2_resync     : std_logic;
  signal b_txbbonoff_req_ff1_resync   : std_logic;
  signal b_txbbonoff_req_ff2_resync   : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- Resynchronize txonoff_req - rxonoff_req
  -----------------------------------------------------------------------------
  -- Remark: It is important to resynchronize rxonoffreq as txonoff_req and rxonoff_req
  -- can change at the same moment. So, as txonoff_req requires to be
  -- registered (coming from 44 MHz domain), the rx_onoff must also be
  -- registered, to come at the same moment in modem A mode.
  
  txon_off_req_p: process (clk, reset_n)
  begin  -- process txon_off_req_p
    if reset_n = '0' then              
      a_txonoff_req_ff0   <= '0';
      b_txonoff_req_ff0   <= '0';
      agc_rxonoff_req_ff0 <= '0';
    elsif clk'event and clk = '1' then  
      a_txonoff_req_ff0   <= a_txonoff_req_i;
      b_txonoff_req_ff0   <= b_txonoff_req_i;
      agc_rxonoff_req_ff0 <= agc_rxonoff_req_i;
    end if;
  end process txon_off_req_p;
  
  -----------------------------------------------------------------------------
  -- Request handler SM
  -----------------------------------------------------------------------------
  -- Computes request handler next state
  req_handler_next_state_p: process (accend, access_error, maxresp_i,
                                     modem_req, req_handler_state,
                                     rf_off_reg_req, soft_req_masked, writeacc)
  begin
    case req_handler_state is
      -------------------------------------
      -- Idle state: no request pending
      -------------------------------------
      when idle_state =>
        if modem_req = '1' then
          -- new modem req
          req_handler_next_state <= modem_req_state;
        elsif rf_off_reg_req = '1' then
          -- switch off radio request
          req_handler_next_state <= rf_off_state;
        elsif soft_req_masked = '1' then
          -- soft request (can be a waiting one)
          req_handler_next_state <= soft_req_state;
        else          
          req_handler_next_state <= idle_state;
        end if;        
                         
      -------------------------------------
      -- Modem request: the modem request is processed
      -------------------------------------
      when modem_req_state =>
        if accend = '1'
        or (access_error = '1' and writeacc = '0') then
          -- access is finished
          -- or an error occured during a read access
          -- Rmq: write access will always finish correctly
          req_handler_next_state <= idle_state;
        else
          req_handler_next_state <= modem_req_state;          
        end if;
        -- no direct soft access, as a certain delay is required by the HiSS
        -- between 2 accesses
      
      --------------------------------------------
      -- Radio switch off request
      --------------------------------------------
      when rf_off_state =>
        if accend = '1'
        or (access_error = '1' and writeacc = '0') then
          -- access is finished
          -- or an error occured during a read access
          -- Rmq: write access will always finish correctly
          req_handler_next_state <= idle_state;
        else
          req_handler_next_state <= rf_off_state;          
        end if;
      
      -------------------------------------
      -- Sotware request: the software request is processed
      -------------------------------------
      when soft_req_state =>
        if accend = '1'          
        or (access_error = '1' and writeacc = '0')
        or (maxresp_i = "000000" and writeacc = '0') then
          -- access is finished
          -- or an error occured during a read access
          -- or read asked and maxresp set to 0 after request(prevents
          -- staying stuck in that case)
          -- Rmq: write access will always finish correctly
          req_handler_next_state <= idle_state;
        else
          req_handler_next_state <= soft_req_state;
        end if;
                              
      when others =>
        req_handler_next_state <= idle_state;
    end case;    
  end process req_handler_next_state_p;

  req_handler_state_p: process (clk, reset_n)
  begin
    if reset_n = '0' then   
      req_handler_state <= idle_state;
    elsif clk'event and clk = '1' then
        req_handler_state <= req_handler_next_state;        
    end if;
  end process req_handler_state_p;

  -----------------------------------------------------------------------------
  -- Request Generation
  -----------------------------------------------------------------------------
  -- From rxonoff_req txonoff_req define 3 different req
  -- reset_agc_req , rxon_reg_req, txon_reg_req.
  -- Keep the req until the conf to memorize in case of several access
  -- Remark:  req cannot happen at the same moment.
  generate_req: process (clk, reset_n)
  begin  -- process generate_req
    if reset_n = '0' then              
      reset_agc_req       <= '0';
      rxon_reg_req        <= '0';
      txon_reg_req        <= '0';
      rf_off_reg_req      <= '0';
      rxon_req_ff1        <= '0';
      txon_req_ff1        <= '0';
      force_radio_off_ff1 <= '0';
      wait_end_tx_ff1     <= '0';
      wait_end_rx_ff1     <= '0';
      agc_rfoff_ff1       <= '0';
    elsif clk'event and clk = '1' then
      -------------------------------------------------------------------------
      -- Memorize to detect rising/falling edge.
      -------------------------------------------------------------------------
      rxon_req_ff1        <= rxon_req;
      txon_req_ff1        <= txon_req;
      force_radio_off_ff1 <= force_radio_off;
      wait_end_tx_ff1     <= wait_end_tx;
      wait_end_rx_ff1     <= wait_end_rx;
      agc_rfoff_ff1       <= agc_rfoff;
      
      if rfmode_i = '0' then            -- Only on HiSS mode
        -------------------------------------------------------------------------
        -- Find txon_reg_req
        -------------------------------------------------------------------------
        if txon_req_ff1 = '0' and txon_req = '1' then
          -- rising edge of txonoff_req
          txon_reg_req <= '1';
        elsif req_handler_next_state = idle_state 
        and req_handler_state = modem_req_state then    -- access is
          -- finished and ok
          txon_reg_req <= '0';
        end if;

        -------------------------------------------------------------------------
        -- Find rxon_reg_req
        -------------------------------------------------------------------------
        if txon_req_ff1 = '1' and txon_req = '0' then
          -- falling edge of txonoff_req
          rxon_reg_req <= '1';
        elsif req_handler_next_state = idle_state 
        and req_handler_state = modem_req_state then       -- access is finished
          rxon_reg_req <= '0';          
        end if;

        -------------------------------------------------------------------------
        -- Find reset_agc_req
        -------------------------------------------------------------------------
        if (rxon_req_ff1 = '1' and rxon_req = '0') and (txon_req = '0') then
          -- falling edge of rxonoff_req and not a transmission started
          -- (possible in A mode)
          reset_agc_req <= '1';
        elsif req_handler_next_state = idle_state
        and req_handler_state = modem_req_state then       -- access is finished
          reset_agc_req <= '0';
        end if;
        
        --------------------------------------------
        -- Find rf_off_reg_req
        --------------------------------------------
        if (force_radio_off = '1' and force_radio_off_ff1 = '0' and wait_end_tx = '0' and wait_end_rx = '0') or
          (force_radio_off = '1' and wait_end_tx = '0' and wait_end_tx_ff1 = '1') or
          (force_radio_off = '1' and wait_end_rx = '0' and wait_end_rx_ff1 = '1') or
          (agc_rfoff = '1' and agc_rfoff_ff1 = '0') then
          -- rising edge of force_radio_off(when nothing's happening) or
          -- falling edge of wait_end_tx when Tx to Rx switch in progress or
          -- falling edge of wait_end_rx when Tx to Rx switch in progress or
          -- radio off when MACADDR does not match(agc_rfoff)
          rf_off_reg_req <= '1';
        elsif req_handler_next_state = idle_state
        and req_handler_state = rf_off_state then       -- access is finished
          rf_off_reg_req <= '0';
        end if;
        
      else
        reset_agc_req   <= '0';
        rxon_reg_req    <= '0';
        txon_reg_req    <= '0';
        rf_off_reg_req  <= '0';
      end if;
    end if;
  end process generate_req; 
  
  -- All modem requests : agc request or bup req
  modem_req <= agc_req_i         -- not on hiss mode
           or (txpwr_req_i and rfmode_i) -- not on hiss mode
           or rxon_reg_req       -- after each transmission
           or txon_reg_req       -- before each transmission
           or reset_agc_req;     -- after each reception


  -- Modem request is first processed because it is not possible to configure
  -- the registers when transmitting with the HISS interface
  -- * write access is possible on rx access (not on tx as the lines are used for
  -- tx data.
  -- * read access is only possible when there is no rx or tx access, as it
  -- requires both lines.
  soft_req_masked <= soft_req_i when rfmode_i = '1' -- no restriction on analog mode
                  or (txon_req='0' and txon_req_ff1 = '0'
                      and a_txonoff_conf_int = '0' and b_txonoff_conf_int = '0'
                      and (agc_busy_i ='0' or
                      (agc_busy_i ='1' and soft_acctype_i = '1' and rxon_req ='1'))) -- write possible on Rx,
                                                                                     -- if a write happens while
                                                                                     -- agc_reset, it is delayed
                 else '0'; -- soft access is not allowed.

  -- End Software Request when a read access is being processed, and a rx data
  -- stream is requested. The read access has not the priority. An interrupt
  -- happens and the conflict bit is set high.
  conflict <= '1' when req_handler_state = soft_req_state
                   and soft_acctype_i = '0' -- software is performing a read access 
                   and agc_stream_enable_i = '1' -- AGC ask for rx stream
                   and rfmode_i = '0' -- hiss mode
                   and accend = '0' -- not just the end of the access.
              else '0';

  conflict_o <= conflict;
  
  
  -- Mask Tx immediate stop when no transmission requested
  txv_immstop_masked_p : process(clk, reset_n)
  begin
  if(reset_n='0') then
    txv_immstop_masked <= '0';
    txv_immstop_ff0    <= '0';
    wait_txon_req      <= '0';
  elsif(clk'event and clk='1') then
    -- To find rising and falling edges
    txv_immstop_ff0 <= txv_immstop;
    
    -- Unmask txv_immstop when tx starts
    if (wait_txon_req = '1' and txon_req = '1' and txon_req_ff1 = '0') then
      txv_immstop_masked <= '1';
      wait_txon_req      <= '0';
    elsif (txv_immstop = '1' and txv_immstop_ff0 = '0' and txon_req = '0') then
    -- Rising-edge of txv_immstop before txon_req => mask txv_immstop_masked until txon_req rising-edge
      txv_immstop_masked <= '0';
      wait_txon_req      <= '1';
    elsif(txv_immstop = '1' and txv_immstop_ff0 = '0' and txon_req = '1') then
    -- Rising-edge of txv_immstop and txon_req asserted => unmask txv_immstop_masked
      txv_immstop_masked <= '1';
      wait_txon_req      <= '0';
    elsif(txv_immstop = '0' and txv_immstop_ff0 = '1') then
    -- Falling-edge of txv_immstop => deassert txv_immstop_masked
      txv_immstop_masked <= '0';
      wait_txon_req      <= '0';
    end if;
  end if;
  end process txv_immstop_masked_p;
  
    
  -----------------------------------------------------------------------------
  -- Proceed the Request
  -----------------------------------------------------------------------------
  -- Compiles all possible errors that can occur during the RF access
  all_error <= parityerr or protocol_err_i
                  or readacc_timeout or conflict;

  -- Error that must stop the access. (parity err has reached the max val)
  access_error <= retried_parityerr or protocol_err_i
                  or readacc_timeout or conflict;
 
  
  -- The radio interface controller is triggered and all access parameters are
  -- transmitted
  accinit_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      rf_addr_o     <= (others => '0');
      rf_wrdata_o   <= (others => '0');
      writeacc      <= '0';
      startacc      <= '0';
      startacc_long <= '0';
      radio_off     <= '0';
   elsif clk'event and clk = '1' then

      -- At each state transition, if the next state is not idle then
      -- an RF access starts
      if (req_handler_next_state /= idle_state and
        req_handler_next_state /= req_handler_state)  -- access started
      or (parityerr = '1' and
          retry_counter <maxparerr_i  ) then -- restart access as last one processed a parity err
        -- Start Access
        startacc      <= '1';
        startacc_long <= '1';
      else
        startacc       <= '0';
        -- startacc_long is startacc with 2 periods in hiss mode
        if startacc = '1' and rfmode_i = '0' then
          startacc_long  <= '1';
        else
          startacc_long  <= '0';
        end if;
     end if;

      -- Defines address and data to write in the RF register
      case req_handler_next_state is
        
        when modem_req_state =>
          if (txpwr_req_i = '1' and rfmode_i = '1') then
            -- only in analog mode
            rf_addr_o   <= RFTXGAIN_CT;
            rf_wrdata_o <= ext(txpwr_i,16);
            writeacc    <= '1';
            radio_off   <= '0';
          elsif agc_req_i = '1' then
            rf_addr_o   <= ext(agc_addr_i,6);  -- !!! TBD: convert AGC address
                                               -- into the physical register address
            rf_wrdata_o <= ext(agc_wrdata_i,16);
            writeacc  <= agc_wr_i;
            radio_off     <= '0';
          elsif txon_reg_req = '1' then
            radio_off     <= '0';
            -- Configure for Transmission
            rf_addr_o   <= RFDYNCNTL_ADDR_CT;
            writeacc    <= '1';            
            rf_wrdata_o (15 downto 12)   <= paindex_i(4 downto 1); -- Index of PA table
            rf_wrdata_o (11 downto 8)    <= txpwr_i;          -- txgain
            rf_wrdata_o ( 7)             <= paindex_i(0);     -- Index of PA table
            rf_wrdata_o ( 6)             <= txv_txant_i;      -- Tx antenna used
            rf_wrdata_o ( 5 )            <= '1';              -- TXON = 1
            rf_wrdata_o ( 4 )            <= '0';              -- RXON = 0
            rf_wrdata_o ( 3 )            <= '0';              -- RSTAGCCCA = 0
            rf_wrdata_o ( 2 downto 1)    <= (others => '0');  -- not used
            rf_wrdata_o ( 0 )            <= tx_ab_mode_i;     -- ABMODE
          elsif rxon_reg_req = '1' and sw_rfoff_req_i = '0' then
            radio_off     <= '0';
            -- Configure for Reception
            rf_addr_o   <= RFDYNCNTL_ADDR_CT;
            writeacc    <= '1';            
            rf_wrdata_o (15 downto 12) <= paindex_i(4 downto 1); -- Index of PA table
            rf_wrdata_o (11 downto 8)  <= txpwr_i;          -- txgain / dont care
            rf_wrdata_o ( 7)             <= paindex_i(0);     -- Index of PA table
            rf_wrdata_o ( 6)             <= '0';              -- not used
            rf_wrdata_o ( 5 )            <= '0';              -- TXON = 0
            rf_wrdata_o ( 4 )            <= '1';              -- RXON = 1
            rf_wrdata_o ( 3 )            <= '0';              -- RSTAGCCCA = 0
            rf_wrdata_o ( 2 downto 1)  <= (others => '0'); -- not used
            rf_wrdata_o ( 0 )            <= '0';              -- ABMODE = A mode
          elsif reset_agc_req = '1' and sw_rfoff_req_i = '0' then
            radio_off     <= '0';
            -- Reset AGC/CCA
            rf_addr_o   <= RFDYNCNTL_ADDR_CT;
            writeacc    <= '1';            
            rf_wrdata_o (15 downto 12) <= paindex_i(4 downto 1); -- Index of PA table
            rf_wrdata_o (11 downto 8)  <= txpwr_i;              -- txgain / dont care
            rf_wrdata_o ( 7)             <= paindex_i(0);       -- Index of PA table
            rf_wrdata_o ( 6)             <= '0';                -- not used
            rf_wrdata_o ( 5 )            <= '0';                -- TXON = 0
            rf_wrdata_o ( 4 )            <= '1';                -- RXON = 1
            rf_wrdata_o ( 3 )            <= '1';                -- RSTAGCCCA = 1
            rf_wrdata_o ( 2 downto 1)  <= (others => '0');      -- not used
            rf_wrdata_o ( 0 )            <= '0';                -- ABMODE = A mode          
          elsif (rxon_reg_req = '1' or reset_agc_req = '1') and sw_rfoff_req_i = '1'
            and force_radio_off = '0' and wait_end_tx = '0' and wait_end_rx = '0' then
            -- Switch off radio with an automatic procedure at the end
            -- of transmission or reception instead of switching to Rx
            radio_off   <= '1';
            rf_addr_o   <= RFDYNCNTL_ADDR_CT;
            writeacc    <= '1';            
            rf_wrdata_o (15 downto 6)    <= (others => '0');              
            rf_wrdata_o ( 5 )            <= '0';              -- TXON = 0
            rf_wrdata_o ( 4 )            <= '0';              -- RXON = 0
            rf_wrdata_o ( 3 )            <= '1';              -- RSTAGCCCA = 1
            rf_wrdata_o ( 2 downto 0)  <= (others => '0');    -- not used
          end if;
        
        when rf_off_state =>
            -- Force radio switching off and reset agc RF so that next B
            -- reception can start(because cca_flags are always received
            -- in A mode)
            radio_off   <= '1';
            rf_addr_o   <= RFDYNCNTL_ADDR_CT;
            writeacc    <= '1';            
            rf_wrdata_o (15 downto 6)    <= (others => '0');              
            rf_wrdata_o ( 5 )            <= '0';              -- TXON = 0
            rf_wrdata_o ( 4 )            <= '0';              -- RXON = 0
            rf_wrdata_o ( 3 )            <= '1';              -- RSTAGCCCA = 1
            rf_wrdata_o ( 2 downto 0)  <= (others => '0');    -- not used
        
        when soft_req_state =>
          rf_addr_o   <= soft_addr_i;
          rf_wrdata_o <= soft_wrdata_i;
          writeacc    <= soft_acctype_i;
        when others =>
          -- To reset radio_off when several consecutive Rx
          radio_off   <= '0';
      end case;
    end if;
  end process accinit_p;

  startacc_o <= startacc_long; -- will be 2 periods long in hiss mode
                               --         1 period  long in analog mode    

  -----------------------------------------------------------------------------
  -- Acknowledge the request and provides the read data
  -----------------------------------------------------------------------------
  -- agc_conf is used * in ana mode to acknowledge agc_req
  --                  * in hiss mode to acknowledge rxon_reg_req, txon_reg_req
  --                    and reset_agc_req  (no agc_req on hiss)
  access_end_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      txpwr_conf_o     <= '0';
      agc_conf         <= '0';
      agc_rddata_o     <= (others => '0');
        
    elsif clk'event and clk = '1' then

      -- Acknowledge the current request
      -- No Acknowledgement when parity_err, in order to retry)
      if req_handler_next_state = idle_state 
        and req_handler_state = modem_req_state then
        agc_conf       <= agc_req_i;
        txpwr_conf_o   <= txpwr_req_i;
      else
        agc_conf       <= '0';
        txpwr_conf_o   <= '0';
      end if;

      -- Update read data output
      if accend = '1' and writeacc = '0' and
                        req_handler_state = modem_req_state then
        agc_rddata_o <= rddata_mux(7 downto 0);
      end if;
    end if;
  end process access_end_p;

  -- Access is finished: (come from analog or hiss interface)
  accend        <= ana_accend_i or hiss_accend_i;

  -- Mux rddata source and link it to output
  rddata_mux    <= hiss_rddata_i when rfmode_i = '0' else ana_rddata_i;

  memo_rddata_p: process (clk, reset_n)
  begin  -- process memo_rddata_p
    if reset_n = '0' then              
      soft_rddata_o <= (others => '0');
    elsif clk'event and clk = '1' then  
      if accend = '1' and  req_handler_state = soft_req_state
      and soft_acctype_i = '0' then
        soft_rddata_o <= rddata_mux;
      end if;
    end if;
  end process memo_rddata_p;
  
  --  Indicate that the soft access is finished (even if it is not ok)
  soft_accend_o <= '1' when req_handler_state = soft_req_state
                        and req_handler_next_state = idle_state
            else '0';

  -- output linking
  writeacc_o    <= writeacc;
  agc_conf_o    <= agc_conf;

  -----------------------------------------------------------------------------
  -- Errors handler
  -----------------------------------------------------------------------------
  -- Counts up nb of retry
  --                       __            __
  -- startacc ____________|  |__________|  |_______________
  --                               ________________
  -- parity_err_tog ______________|                |___________
  --               ___________ ____________ ___________ _______  
  -- retry_counter __0________X_______1____X___2_______X___0___
  --                                  __             __
  -- parityerr ______________________|  |___________|  |______
  --                                                 __
  -- retried_parityerr _____________________________|  |_______
  --
  -- In this Example, only 2 tries are permitted (maxparerr_i = '1')

  retry_counter_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      retry_counter <= (others => '0');
      parityerr_tog_ff1 <= '0';
      parityerr         <= '0';
      retried_parityerr <= '0'; 
    elsif clk'event and clk = '1' then
      parityerr_tog_ff1 <= parityerr_tog_i;
      parityerr         <= '0';
      retried_parityerr <= '0'; 

      -------------------------------------------------------------------------
      -- Counter
      -------------------------------------------------------------------------
      if startacc = '1' then
        -- new try : increment counter
        retry_counter <= retry_counter + '1';
      elsif req_handler_next_state = idle_state then
        -- access is finished : reinit counter
        retry_counter <= (others => '0');
      end if;

      -------------------------------------------------------------------------
      -- Parityerr and retried_parityerr
      -------------------------------------------------------------------------
      if parityerr_tog_ff1 /= parityerr_tog_i then
        parityerr     <= '1'; -- a parity error occured
        -- If the maximum number of parity errors has been reached, an error is
        -- reported 
        if retry_counter = maxparerr_i and rfmode_i = '0' then
          retried_parityerr <= '1';
        end if;
      end if;
    end if;
  end process retry_counter_p;

  parityerr_o         <= parityerr;
  retried_parityerr_o <= retried_parityerr;

  -- AGC Err : toggle => pulse
  agc_err_p: process (clk, reset_n)
  begin  -- process agc_err_p
    if reset_n = '0' then              
      agcerr_tog_ff1 <= '0';
      agcerr_o       <= '0';
    elsif clk'event and clk = '1' then  
      -- memorize for catching pulse
      agcerr_tog_ff1 <= agcerr_tog_i;
      if agcerr_tog_i /= agcerr_tog_ff1 or cs_error_i = '1' then
        -- CCA or CS error
        agcerr_o <= '1'; 
      else
        agcerr_o <= '0';
      end if;
    end if;
  end process agc_err_p;
  
  -- Counts up 10 us from clock switch request
  clockswitch_counter_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then 
      clockswitch_counter   <= (others => '0');
      clockswitch_timeout   <= '0';
    elsif clk'event and clk = '1' then
      if clockswitch_timeout = '1'  or clock_switched_i = '1' then
       clockswitch_counter <= (others => '0');        
      elsif clockswitch_req_i = '1' or clockswitch_counter /= 0 then
        clockswitch_counter <= clockswitch_counter + '1';        
      end if;

      -- The PLL should lock within 10 us. If it not happens an error is
      -- reported
      if clockswitch_counter = CLK_SWITCH_TIMEOUT_CT then
        clockswitch_timeout <= '1';
      else
        clockswitch_timeout <= '0';        
      end if;      
    end if;
  end process clockswitch_counter_p;

  clockswitch_timeout_o <= clockswitch_timeout;

  -- Read access counter: counts up clock cycles needed to get the read data
  readacc_counter_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then          
      readacc_counter <= (others => '0');
      readacc_timeout  <= '0';
    elsif clk'event and clk = '1' then
      readacc_timeout <= '0';           
      if req_handler_state = idle_state
        or  readacc_counter = maxresp_i
        or parityerr = '1' then
        -- maximum reached or access is finished
        readacc_counter <= (others => '0');
      elsif (startacc = '1' and writeacc= '0') or readacc_counter /= 0 then
        -- read access started
        readacc_counter <= readacc_counter + '1';   
      end if;
      
      -- If the read access does not end within maxresp c.c., a read time out
      -- is reported.
      -- In case of conflict, master hiss sm should not remain in
      -- wait_return_reg state, so the readacc_timeout is sent.
      -- The read acc_timeout must not be sent when maxresp_i =0 because no
      -- access is requested in that case
      if  readacc_counter = maxresp_i and maxresp_i /= "000000" then
        readacc_timeout <= '1';
      else
        readacc_timeout <= '0';        
      end if;
    end if;
  end process readacc_counter_p;

  readacc_timeout_o <= readacc_timeout;
  
  
  -----------------------------------------------------------------------------
  -- IQ Swapping
  -----------------------------------------------------------------------------
  -- The IQ-SWAP will only be performed in case of analog interface.
  -- In case of HiSS interface, the IQ-SWAP is done in the front-end of the radio.
  --
  -- Generates data output: swap I&Q if necessary
  ANA_INT_GEN: if ana_digital_g = 1 or ana_digital_g = 3 generate
    -----------------------------------------------------------------------------
    -- RX Path
    -----------------------------------------------------------------------------
    -- hiss_rxi ___________________|\      
    --                  ____       | |____  modem_a path 
    -- ana_rxi  _______|swap|______| |      modem_b path
    --                 |_/\_|      |/
    --
    rx_data_out_p : process (reset_n, sampling_clk)
    begin
      if reset_n = '0' then
        rf_rxi <= (others => '0');
        rf_rxq <= (others => '0');
        
      elsif sampling_clk'event and sampling_clk = '1' then
        -------------------------------------------------------------------------
        -- Analog Mode
        -------------------------------------------------------------------------
        if rfmode_i = '1' then
          -- Swap Rx I & Q
          if rxiqswap_i = '1' then
            -- swap
            rf_rxi <= "000" & ana_rxq_i;  -- unsigned value
            rf_rxq <= "000" & ana_rxi_i;  -- unsigned value
          else
            rf_rxi <= "000" & ana_rxi_i;  -- unsigned value
            rf_rxq <= "000" & ana_rxq_i;  -- unsigned value
          end if;
        end if;
      end if;
    end process rx_data_out_p;
    
    -----------------------------------------------------------------------------
    -- TX Path
    -----------------------------------------------------------------------------
    --                    ____ 
    --  tx_i ------------|swap|-------> DAC
    --  tx_q     |       |_/\_|
    --           |
    --           |-------------------->  HiSS Interface
    --
    -----------------------------------------------------------------------------

    -- Generates data output: swap I&Q if necessary
    tx_data_out_p: process (reset_n, sampling_clk)
    begin 
      if reset_n = '0' then            
        rf_txi             <= (others => '0');
        rf_txq             <= (others => '0');
        
      elsif sampling_clk'event and sampling_clk = '1' then
        if rfmode_i = '1' then -- Analog Mode
          if txiqswap_i = '1' then
            -- swap Tx I & Q
            rf_txi <= txq_i(7 downto 0);
            rf_txq <= txi_i(7 downto 0);
          else
            rf_txi <= txi_i(7 downto 0);
            rf_txq <= txq_i(7 downto 0);
          end if;
        else
          rf_txi             <= (others => '0');
          rf_txq             <= (others => '0');       
        end if;
       end if;
    end process tx_data_out_p;
    
    ana_txi_o  <= rf_txi;
    ana_txq_o  <= rf_txq;
    
  end generate ANA_INT_GEN;

  NO_ANA_INT_GEN: if ana_digital_g = 2  generate
    rf_rxi    <= (others => '0');
    rf_rxq    <= (others => '0');
    rf_txi    <= (others => '0');
    rf_txq    <= (others => '0');
    ana_txi_o <= (others => '0');
    ana_txq_o <= (others => '0');
  end generate NO_ANA_INT_GEN;
  
  -- Output Linking: generate data_valid only when mode selected
  rxi_o <= rf_rxi when rfmode_i = '1'      -- Data from anal inter
      else hiss_rxi_i;                     -- Data from hiss inter
  rxq_o <= rf_rxq when rfmode_i = '1'      -- Data from anal inter
      else hiss_rxq_i;                     -- Data from hiss inter

  a_rxdatavalid_o <= hiss_rxdatavalid_i and (not agc_ab_mode_i);
  b_rxdatavalid_o <= hiss_rxdatavalid_i and agc_ab_mode_i;

  -------------------------------------------------------
  -- Modem B datavalid resynchronization(44MHz to 80MHz)
  -- Only datavalid resynchronized because delayed and
  -- guarantees data validity
  -------------------------------------------------------
  resync_hiss_data_p : process (clk, reset_n)
  begin
    if reset_n ='0' then
      b_txdatavalid_ff1_resync    <= '0';
      b_txdatavalid_ff2_resync    <= '0';
      b_txbbonoff_req_ff1_resync  <= '0';
      b_txbbonoff_req_ff2_resync  <= '0';
    elsif clk'event and clk ='1' then
      b_txdatavalid_ff1_resync <= b_txdatavalid_i;
      b_txdatavalid_ff2_resync <= b_txdatavalid_ff1_resync;
      b_txbbonoff_req_ff1_resync  <= b_txbbonoff_req_i;
      b_txbbonoff_req_ff2_resync  <= b_txbbonoff_req_ff1_resync;
      
    end if;
  end process resync_hiss_data_p;

  -- tx_datavalid is multiplexed according to transmission mode
  tx_datavalid <= a_txdatavalid_i  when tx_ab_mode_i = '0' else b_txdatavalid_ff2_resync;
    

  -- HiSS Interface
  -- hiss_txen_o becomes low when there are no data any more to transmit.
  hiss_txen_o <=  a_txbbonoff_req_i or b_txbbonoff_req_ff2_resync;
  
    -- enable reception of HiSS only when asked by the AGC/CCA
  hiss_rxen_o <= agc_stream_enable_i;
  
  hiss_txdatavalid_o <= tx_datavalid;
  hiss_txi_o         <= txi_i;
  hiss_txq_o         <= txq_i;
  
  
  -----------------------------------------------------------------------------
  -- Radio control:
  -- Acknowledge the txonoff_req after a certain time defined by the txstartdel
  -- reg, and evaluate the PA activation time according to the paondel reg.
  -- Generate ana_txen/rxen signals
  -----------------------------------------------------------------------------
  paondel_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      txstartdel_counter <= (others => '0');
      pa_on_int            <= '0';
      ana_txen             <= '0';
      ana_rxen_o           <= '0';
      a_txonoff_conf_int   <= '0';
      b_txonoff_conf_int   <= '0';
      agc_rxonoff_conf_o   <= '0';
    elsif clk'event and clk = '1' then
      -------------------------------------------------------------------------
      -- PA_ON generation
      -------------------------------------------------------------------------
      if txstartdel_counter >= paondel_i and txon_reg_req = '0' and txon_req = '1'
        and txon_req_ff1 = '1' then
        -- The power amplifier is switched on after a delay
        -- (at least after RFDYNCNTL configuration)
        pa_on_int         <= '1';
      elsif txon_req = '1' and txon_req_ff1 = '1' and txon_reg_req = '0' then
        -- Start counter only when wr access to WILD_RF is finished
        -- The max val has not been reached ... continue counting...
        pa_on_int        <= '0';

      else
        -- Reinit for next time
        pa_on_int        <= '0';    
      end if;
      
      -------------------------------------------------------------------------
      -- TB conf gen generation
      -------------------------------------------------------------------------
      if txv_immstop_masked = '0' then
          
          if txstartdel_counter = txstartdel_i and txon_reg_req = '0' and txon_req = '1'
            and txon_req_ff1 = '1' then
          -- The conf is sent after a delay (and the txon access is finished)
            a_txonoff_conf_int <= a_txonoff_req_ff0;
            b_txonoff_conf_int <= b_txonoff_req_ff0;
        
          elsif txon_req = '1' and txon_req_ff1 = '1' and txon_reg_req = '0' then
          -- Start counter only when wr access to WILD_RF is finished
          -- The max val has not been reached ... continue counting...        
            txstartdel_counter <= txstartdel_counter + '1';
          elsif txon_req_ff1 = '0' and rxon_reg_req = '1' and req_handler_next_state = idle_state
            and req_handler_state = modem_req_state then
          -- Reinit for next time at the end of Tx(end of radio Rx config.)
            txstartdel_counter  <= (others => '0');  -- reinit for next time
            a_txonoff_conf_int    <= '0';
            b_txonoff_conf_int    <= '0';
          end if;
      
      elsif txv_immstop_masked = '1' then
          
          if txstartdel_counter = txstartdel_i and txon_reg_req = '0'
            and ((rxon_reg_req = '0' and txon_req = '1' and txon_req_ff1 = '1')
                 or (rxon_reg_req = '1' and accend = '1')) then
          -- Immediate stop and txstartdel elapsed(data transmission or forced to txstartdel_i)
          -- In immediate stop, the conf is sent after having configured the WILD_RF in Rx (write access)
            a_txonoff_conf_int <= a_txonoff_req_ff0;
            b_txonoff_conf_int <= b_txonoff_req_ff0;
            -- reinitialize counter when radio switched to Rx
            if rxon_reg_req = '1' and req_handler_next_state = idle_state and req_handler_state = modem_req_state then
              txstartdel_counter <= (others => '0');
            end if;
            
          elsif txon_reg_req = '0' and txon_req = '1' then
          -- Force txstartdel counter when not elapsed(immstop asked before paon)
          -- and when RF has already been configured to Tx mode(immstop asked before txon_req='1')
            txstartdel_counter <= txstartdel_i;
          end if;
      
      end if;
      
      -------------------------------------------------------------------------
      -- ana_txen/rxen
      -------------------------------------------------------------------------
      ana_rxen_o         <= rxon_req and rfmode_i;
      ana_txen           <= txon_req and rfmode_i;
      agc_rxonoff_conf_o <= rxon_req_ff1 or reset_agc_req;-- wait the end of the reset of agc
    end if;
  end process paondel_p;
  
  
  ------------------------------------------------
  -- Pulse indicating radio has been switched off
  ------------------------------------------------
  rf_off_done_p : process(clk, reset_n)
  begin
    if(reset_n='0') then
      rf_off_done_o <= '0';
    elsif(clk'event and clk='1') then
      -- Radio has been switched off when:
      --  o it has been requested to
      --  o the radio was not already off(do not gen IT when switching to Tx)
      --  o end of reception(with end of radio config) 
      --  o end of transmission(Radio configured in Rx: xor guarantees the interrupt
      --    happens at the end of rf_off_reg_req when both are asserted, happens in b mode
      --    because of signals resynchronizations, 2 clock cycles without
      --    any rf_off_req/conf asserted)
      if (sw_rfoff_req_i = '1' and radio_off  = '1' and accend = '1'
        and ((reset_agc_req = '1' and agc_busy_i = '1') or (rxon_reg_req = '1' xor rf_off_reg_req = '1'))) then
        rf_off_done_o <= '1';
      else
        rf_off_done_o <= '0';
      end if;
    end if;
  end process rf_off_done_p;
  
  ----------------------------------------------------------------------
  -- Initiate a radio access to switch off the radio
  ----------------------------------------------------------------------
  -- This happens setting the sw_rfoff_req_i when:
  --  o no reception or transmission is happening
  --  o end of transmission (req has been unset => an access to
  --    RFDYNDNTL is being processed => must delay rf off access)
  --
  -- In the other cases, the radio switching off is automatic
  -- at the end of Tx or Rx
  ----------------------------------------------------------------------
  switch_off_radio_p : process(clk, reset_n)
  begin
  if(reset_n='0') then
    force_radio_off   <= '0';
    sw_rfoff_req_ff1  <= '0';
    wait_end_tx       <= '0';
    wait_end_rx       <= '0';
  elsif(clk'event and clk='1') then
    sw_rfoff_req_ff1 <= sw_rfoff_req_i;
    
    -- Signal which detects the Tx to Rx switch to avoid asserting the
    -- radio_off flag when performing the Tx to Rx switch
    if (sw_rfoff_req_ff1 = '0' and sw_rfoff_req_i = '1' and txon_req_ff1 ='0'
        and agc_busy_i ='0') or rxon_reg_req = '1' then
      wait_end_tx <= '1';
    else
      wait_end_tx <= '0';
    end if;
    
    -- Signal which detects the Tx to Rx switch to avoid asserting the
    -- radio_off flag when performing the Tx to Rx switch
    if (sw_rfoff_req_ff1 = '0' and sw_rfoff_req_i = '1' and agc_rxonoff_req_ff0 = '0' and txon_req_ff1 ='0')
        or  reset_agc_req = '1' then
      wait_end_rx <= '1';
    else
      wait_end_rx <= '0';
    end if;
    
    
    -- Depending on when the rising-edge of radio switch off req happens, an additional access must
    -- be done to switch off the radio:
    -- o when no transmission or end of Tx(end register access to switch to Rx)
    -- o when no reception happens or end of Rx(end register access to reset AGC rf)
    if sw_rfoff_req_ff1 = '0' and sw_rfoff_req_i = '1' and  -- Find rising-edge of radio switch off req
      ((txon_req_ff1 = '0' and txpwr_req_i = '0' and agc_busy_i = '0') or  -- and not in Tx
       (rxon_req  = '0'    and agc_busy_i = '1')) then        -- and not in Rx
      force_radio_off <= '1';
    elsif accend = '1' and radio_off  = '1' then
    -- Find falling-edge of radio switch off req
      force_radio_off <= '0';
    end if;
  end if;
  end process switch_off_radio_p;


  -- Mask the rx request of the AGC, as it comes too early. 
  rxon_req   <= agc_rxonoff_req_ff0 and not txon_req_ff1;
  
  txon_req   <= a_txonoff_req_ff0 or b_txonoff_req_ff0;
  
  -- Diagports
  rf_off_reg_req_o     <= rf_off_reg_req;
  txon_req_o           <= txon_req;
  txv_immstop_masked_o <= txv_immstop_masked;
  
  ana_txen_o <= ana_txen;

  pa_on_o     <= pa_on_int;
  a_txonoff_conf_o  <= a_txonoff_conf_int;
  b_txonoff_conf_o  <= b_txonoff_conf_int;
  
  ----------------------------------------------------------------------------- 
  -- RF switch
  -----------------------------------------------------------------------------
  -- The rf_sw0 and rf_sw1 codes are forced when ANTFORCE = 1 and during case 2
  -- and A mode or during case 0. In these cases, USEANT select which antenna to select. 
  --------------------------------------
  -- select antenna switch
  --------------------------------------
  rf_switch_p: process (clk, reset_n)
  begin
    if reset_n = '0' then     
      rf_sw_o <= (others => '0');
    elsif clk'event and clk = '1' then
      -------------------------------
      -- rf_sw3 / rf_sw2  gen
      -------------------------------
      rf_sw_o(3) <= pa_on_int and (not band_i); -- PA is on / band = 0 : rf_sw3/5GHz selected
      rf_sw_o(2) <= pa_on_int and (band_i);      -- PA is on / band = 1 : rf_sw2/2.4GHz selected

      -------------------------------
      -- rf_sw0 / rf_sw1  gen
      -------------------------------
      if swcase_i = "11" then  -- Case 3 : two single-band ant or an unique dual-band antenna
        rf_sw_o(1) <= not(rfswitch) and rxon_req and not(txon_req);
        rf_sw_o(0) <= rfswitch and rxon_req and not(txon_req);
       
      else -- other cases
        rf_sw_o(1) <= (rfswitch and (not rxon_req) and txon_req) or
                  (not(rfswitch) and rxon_req and not(txon_req));             
        rf_sw_o(0) <= ((not rfswitch) and (not rxon_req) and txon_req) or
                  (rfswitch and rxon_req and not(txon_req));                    
      end if;

    end if;
  end process rf_switch_p;
   
  --------------------------------------
  -- rfswitch generation (define what the ref is)
  --------------------------------------
  -- In case 2, the diversity switch is used only when
  --          - the antennas are not forced.(forced val useant will be used)
  with swcase_i select
    rfswitch <=
--    useant_i                                             when "00", -- case 0
    useant_i                                             when "00", -- case 0
    band_i                                               when "01", -- case 1
    (useant_i and (antforce_i)) or
    (b_antsel and (not antforce_i))                    when "10", -- case 2
    band_i                                               when others; -- case 3
  
   --------------------------------------
   -- b_ant_sel generation
   --------------------------------------
  b_antsel_p: process (clk, reset_n)
  begin  -- process b_antsel_p
    if reset_n = '0' then              
      b_antsel <= '0';
      agc_bb_sw_ant_tog_ff0 <= '0';
      agc_rf_sw_ant_tog_ff0 <= '0';
    elsif clk'event and clk = '1' then  
      -- memorize to catch toggle
      agc_bb_sw_ant_tog_ff0 <= agc_bb_switch_ant_tog;
      agc_rf_sw_ant_tog_ff0 <= agc_rf_switch_ant_tog;

      -- when 1 of the 2 signals toggles => switch antenna
      if (agc_bb_switch_ant_tog /= agc_bb_sw_ant_tog_ff0)
      or (agc_rf_switch_ant_tog /= agc_rf_sw_ant_tog_ff0) then
        b_antsel <= not b_antsel;
      end if;      
    end if;
  end process b_antsel_p;
  
  b_antsel_o <= b_antsel;

  -----------------------------------------------------------------------------
  -- ADC/DAC control
  -----------------------------------------------------------------------------
  adc_dac_en_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      ana_adc_en <= (others => '0');
    elsif clk'event and clk = '1' then
      if rfmode_i = '1' then
        -- ADC: there are 3 modes, on, off and sleep
        if agc_adcen_i = '1' then
          ana_adc_en <= "10";          -- On mode
        elsif rxon_req = '1' then
          ana_adc_en <= "11";           -- Sleep mode
        else
          ana_adc_en <= "01";           -- Off mode
        end if;
      else
        -- HiSS Mode, disable adc
        ana_adc_en <= "01";      
      end if;
    end if;
  end process adc_dac_en_p;

  -- Force activation with forceadcon_i = '1'
  ana_adc_en_o <= "10" when forceadcon_i = '1' else ana_adc_en;
       
  -- DAC are swithed on when transmitting and if analog interface is used and
  -- forced to on when forcedacon_i = '1'
  ana_dac_en_o <= '1' when forcedacon_i = '1' else ana_txen;
  
end RTL;
