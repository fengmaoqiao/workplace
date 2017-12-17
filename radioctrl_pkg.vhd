
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: radioctrl_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.26   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for radioctrl.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/radioctrl/vhdl/rtl/radioctrl_pkg.vhd,v  
--  Log: radioctrl_pkg.vhd,v  
-- Revision 1.26  2005/10/04 12:27:10  Dr.A
-- #BugId:1398#
-- Completed sensitivity list in registers and reqdata_handler.
-- Removed unused signals and rf_goto_sleep port
--
-- Revision 1.25  2005/03/10 08:46:36  sbizet
-- #BugId:907,948,946#
-- new diag ports
--
-- Revision 1.24  2005/03/02 13:07:54  sbizet
-- #BugId:907#
-- Added comment
--
-- Revision 1.23  2005/01/06 17:08:47  sbizet
-- #BugId:907,948,946,643#
-- txv_immstop, rfint, agc_rfoff ports added
--
-- Revision 1.22  2004/12/14 16:34:52  sbizet
-- #BugId:713#
-- Port map for 1.2 functions
--
-- Revision 1.21  2004/07/16 07:41:57  Dr.B
-- add pabias info feature
--
-- Revision 1.20  2004/06/04 13:51:43  Dr.C
-- Changed to only one port for Tx/Rx data.
--
-- Revision 1.19  2004/03/29 13:04:57  Dr.B
-- add clk44_possible_g generic.
--
-- Revision 1.18  2004/02/19 17:29:04  Dr.B
-- add hiss_reset_n + b_antsel.
--
-- Revision 1.17  2003/12/17 15:21:31  Dr.B
-- remove rf_rx when hiss only.
--
-- Revision 1.16  2003/12/03 17:32:33  Dr.B
-- add diagport.
--
-- Revision 1.15  2003/11/20 16:26:58  Dr.B
-- remove hiss_clk_n, add rf_goto_sleep.
--
-- Revision 1.14  2003/11/20 13:07:01  Dr.B
-- remove rf_goto_slepp.
--
-- Revision 1.13  2003/11/20 11:35:42  Dr.B
-- readd hiss_clk_n for compatibility with wildcore port map.
--
-- Revision 1.12  2003/11/20 11:28:33  Dr.B
-- remove hiss_clk_n.
--
-- Revision 1.11  2003/11/17 14:54:36  Dr.B
-- add clk_switch.
--
-- Revision 1.10  2003/11/05 08:43:29  Dr.B
-- add agc_stream_enable and a_txbbonoff_req.
--
-- Revision 1.9  2003/11/03 16:01:32  Dr.B
-- output pa_on.
--
-- Revision 1.8  2003/10/30 16:37:43  Dr.B
-- change txpwr size.
--
-- Revision 1.7  2003/10/30 14:42:18  Dr.B
-- update to spec 0.06.
--
-- Revision 1.6  2003/10/09 08:30:14  Dr.C
-- Updated hiss master port map
--
-- Revision 1.5  2003/09/25 12:46:37  Dr.C
-- Updated Hiss interface
--
-- Revision 1.4  2003/09/23 13:09:05  Dr.C
-- Updated to spec 0.05
--
-- Revision 1.3  2003/07/15 08:41:00  Dr.C
-- Updated to spec 0.04
--
-- Revision 1.2  2002/06/25 12:49:58  Dr.C
-- Added pclk_n as input
--
-- Revision 1.1  2002/04/26 12:18:37  Dr.C
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
package radioctrl_pkg is

  constant RCCNTL_ADDR_CT    : std_logic_vector(6 downto 0) := "0000000";
  constant RCCMD_ADD_CT      : std_logic_vector(6 downto 0) := "0000100";
  constant RCINTSTAT_ADDR_CT : std_logic_vector(6 downto 0) := "0001000";
  constant RCINTACK_ADDR_CT  : std_logic_vector(6 downto 0) := "0001100";


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: /share/hw_projects/PROJECTS/WILD_SYS_FPGA/IPs/WILD/WILDRF_FRONTEND/master_hiss/vhdl/rtl/master_hiss.vhd
----------------------
  component master_hiss
  generic (
    rx_a_size_g      : integer := 11;   -- size of data of rx_filter A
    rx_b_size_g      : integer := 8;    -- size of data of rx_filter B
    tx_a_size_g      : integer := 10;   -- size of data input of tx_filter A
    tx_b_size_g      : integer := 1;    -- size of data input of tx_filter B
    clk44_possible_g : integer := 0);  -- when 1 - the radioctrl can work with a
  -- 44 MHz clock instead of the normal 80 MHz.
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hiss_clk              : in  std_logic; -- 240 MHz clock
    rfh_fastclk           : in  std_logic; -- 240 MHz clock without clktree directly from pad)
    pclk                  : in  std_logic; -- 80  MHz clock
    reset_n               : in  std_logic;
    hiss_reset_n          : in  std_logic;
    --------------------------------------
    -- Interface with Wild_RF
    --------------------------------------
    rf_rxi_i              : in  std_logic;  -- Real Part received
    rf_rxq_i              : in  std_logic;  -- Imaginary Part received 
    -- 
    rf_txi_o              : out std_logic;  -- Real Part to send 
    rf_txq_o              : out std_logic;  -- Imaginary Part to send
    rf_txen_o             : out std_logic;  -- Enable the rf_txi/rf_txq output when high
    rf_rxen_o             : out std_logic;  -- Enable the inputs rf_rx when high
    rf_en_o               : out std_logic;  -- Control Signal - enable transfers
    --------------------------------------
    -- Interface with muxed tx path
    --------------------------------------
    -- Data from Tx Filter A and B
    tx_ai_i               : in  std_logic_vector(tx_a_size_g-1 downto 0);
    tx_aq_i               : in  std_logic_vector(tx_a_size_g-1 downto 0);
    tx_val_tog_a_i        : in  std_logic;   -- toggle = data is valid
    --
    tx_b_i                : in  std_logic_vector(2*tx_b_size_g-1 downto 0);
    tx_val_tog_b_i        : in  std_logic;   -- toggle = data is valid
    --------------------------------------
    -- Interface with Rx Paths 
    --------------------------------------
    hiss_enable_n_i      : in  std_logic;  -- enable block 60 MHz
    -- Data from Rx Filter A or B
    rx_i_o               : out std_logic_vector(rx_a_size_g-1 downto 0); -- B data are on LSB
    rx_q_o               : out std_logic_vector(rx_a_size_g-1 downto 0); -- B data are on LSB
    rx_val_tog_o         : out std_logic;  -- toggle = data is valid
    clk_2skip_tog_o      : out std_logic;  -- tog when 2 clock-skip is needed | gated 44 MHz clk
    --------------------------------------
    -- Interface with Radio Controller sm 
    --------------------------------------
    -- 80 MHz signals Inputs (from Radio Controller)
    rf_en_force_i         : in  std_logic;  -- clock reset force rf_en in order to wake up hiss clock.
    tx_abmode_i           : in  std_logic;  -- transmission mode : 0 = A , 1 = B
    rx_abmode_i           : in  std_logic;  -- reception mode : 0 = A , 1 = B
    force_hiss_pad_i      : in  std_logic;  -- when high the receivers/drivers are always activated
    apb_access_i          : in  std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_i              : in  std_logic;  -- wr_nrd = '1' => write access
    rd_time_out_i         : in  std_logic;  -- time out : no reg val from RF
    clkswitch_time_out_i  : in  std_logic;  -- time out : no clock switch happens
    wrdata_i              : in  std_logic_vector(15 downto 0); -- data to write in reg
    add_i                 : in  std_logic_vector( 5 downto 0); -- add of the reg access
    sync_found_i          : in  std_logic;  -- high and remain high when sync is found
    -- BuP control
    txv_immstop_i         : in std_logic;   -- BuP asks for immediate transmission stop
    -- Control signals Inputs (from Radio Controller)   
    recep_enable_i        : in  std_logic;  -- high = BB accepts incoming data (after CCA detect)
    trans_enable_i        : in  std_logic;  -- high = there are data to transmit
    --
    -- Data (from read-access)
    parity_err_tog_o      : out std_logic;  -- toggle when parity check error (no data will be sent)
    rddata_o              : out std_logic_vector(15 downto 0);
    -- Control Signals    
    cca_search_i          : in  std_logic;  -- wait for CCA (wait for pr_detected_o)
    --
    cca_info_o            : out std_logic_vector(5 downto 0);  -- CCA information
    cca_add_info_o        : out std_logic_vector(15 downto 0); -- CCA additional information
    cca_o                 : out std_logic;  -- high during a 80 MHz period
    parity_err_cca_tog_o  : out std_logic;  -- toggle when parity err during CCA info
    cs_error_o            : out std_logic;  -- when high : error on CS
    switch_ant_tog_o      : out std_logic;  -- toggle = antenna switch
    cs_o                  : out std_logic_vector(1 downto 0);  -- CS info for AGC/CCA
    cs_valid_o            : out std_logic;  -- high when the CS is valid
    acc_end_o             : out std_logic;  -- toggle => acc finished
    prot_err_o            : out std_logic;  -- "long signal" : error on the protocol
    clk_switch_req_o      : out std_logic;  -- pulse: clk swich req for time out
    clk_div_o             : out std_logic_vector(2 downto 0); -- val of rf_fastclk speed
    clk_switched_tog_o    : out std_logic;   -- toggle, the clock will switch
    clk_switched_80_o     : out std_logic;   -- pulse, the clock will switch (80 MHz)
    --
    hiss_diagport_o       : out std_logic_vector(15 downto 0)
  );

  end component;


----------------------
-- File: radioctrl_registers.vhd
----------------------
  component radioctrl_registers
  generic (
    ana_digital_g : integer := 0); -- Selects between analog and HISS interface
  port (
    -------------------------------------------
    -- Reset                         
    -------------------------------------------
    reset_n : in std_logic;

    -------------------------------------------
    -- APB interface                           
    -------------------------------------------
    psel_i      : in  std_logic;
    penable_i   : in  std_logic;
    paddr_i     : in  std_logic_vector(5 downto 0);
    pwrite_i    : in  std_logic;
    pclk        : in  std_logic;
    pwdata_i    : in  std_logic_vector(31 downto 0);
    prdata_o    : out std_logic_vector(31 downto 0);
    -------------------------------------------
    -- AGC interrupt
    -------------------------------------------
    agc_rfint_i         : in std_logic;  -- AGC RF Interrupt decoded by AGC BB
    -------------------------------------------
    -- Request handler                         
    -------------------------------------------
    accend_i            : in std_logic;  -- Software access end
    rddata_i            : in std_logic_vector(15 downto 0);  -- Read data
    parityerr_i         : in std_logic;  -- Parity error
    retried_parityerr_i : in std_logic;  -- Parity error
    agcerr_i            : in std_logic;  -- Parity err on AGC transmission
    proterr_i           : in std_logic;  -- Protocol error
    conflict_i          : in std_logic;  -- Conflict: Read Access before a RX
    readto_i            : in std_logic;  -- Read access time out
    clkswto_i           : in std_logic;  -- Clock switch time out
    clksw_i             : in std_logic;  -- Clock freq. has been switched
    rf_off_done_i       : in std_logic;  -- RF has been switched off

    startacc_o : out std_logic;                      -- Start reg access
    acctype_o  : out std_logic;                      -- Access type
    edgemode_o : out std_logic;                      -- Clock edge active
    radad_o    : out std_logic_vector(5 downto 0);   -- Register address
    wrdata_o   : out std_logic_vector(15 downto 0);  -- Write data
    retry_o    : out std_logic_vector(2 downto 0);   -- Number of trials

    -------------------------------------------
    -- Radio interface            
    -------------------------------------------
    maxresp_o      : out std_logic_vector(5 downto 0);  -- Number of cc to wait 
                                        -- to abort a read access
    txiqswap_o     : out std_logic;     -- Swap TX I/Q lines
    rxiqswap_o     : out std_logic;     -- Swap RX I/Q lines

    -------------------------------------------
    -- HiSS interface            
    -------------------------------------------
    forcehisspad_o : out std_logic;     -- Force HISS pad to be always on
    hiss_biasen_o  : out std_logic; -- enable HiSS drivers and receivers
    hiss_replien_o : out std_logic; -- enable HiSS drivers and receivers
    hiss_clken_o   : out std_logic; -- Enable HiSS clock receivers
    hiss_curr_o    : out std_logic; -- Select high-current mode for HiSS drivers
    
    -------------------------------------------
    -- Radio             
    -------------------------------------------
    b_antsel_i     : in  std_logic;  -- give info on the antenna selection for B
    --
    xoen_o         : out std_logic;       -- Enable RF crystal oscillator
    band_o         : out std_logic;       -- Select 5/2.4 GHz power ampl.
    txstartdel_o   : out std_logic_vector(7 downto 0);  -- Delay to wait bef send tx_onoff_conf
    paondel_o      : out std_logic_vector(7 downto 0);  -- Delay to switch on PA
    forcedacon_o   : out std_logic; -- when high, always enable dac
    forceadcon_o   : out std_logic; -- when high, always enable adc
    swcase_o       : out std_logic_vector(1 downto 0);  -- RF switches
    antforce_o     : out std_logic;       -- Forces antenna switch
--    useant_o       : out std_logic;       -- Selects antenna to use
    useant_o       : out std_logic;       -- Selects antenna to use
    sw_rfoff_req_o : out std_logic;       -- Pulse to request RF stop by software

    -------------------------------------------
    -- Misc                 
    -------------------------------------------
    interrupt_o : out std_logic         -- Interrupt
    
  );

  end component;


----------------------
-- File: reqdata_handler.vhd
----------------------
  component reqdata_handler
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

  end component;


----------------------
-- File: ana_int_ctrl.vhd
----------------------
  component ana_int_ctrl
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n : in std_logic;
    clk     : in std_logic;
    clk_n   : in std_logic;
    
    --------------------------------------
    -- Registers
    --------------------------------------
    rfmode     : in  std_logic;
    edgemode   : in  std_logic;         -- Single or dual edge mode
    
    --------------------------------------
    -- Request handler
    --------------------------------------
    startacc     : in  std_logic;       -- Start access on 3w bus
    rf_addr      : in  std_logic_vector(5 downto 0);  -- Reg. address
    rf_wrdata    : in  std_logic_vector(15 downto 0);  -- Write data
    writeacc     : in  std_logic;       -- Access type
    read_timeout : in  std_logic;       -- Time out on read access
    accend       : out std_logic;       -- Access finished
    ana_rddata   : out std_logic_vector(15 downto 0);  -- Read data

    --------------------------------------
    -- 3w interface
    --------------------------------------
    rf_3wdatain  : in std_logic;
    rf_3wenablein: in std_logic;
    
    rf_3wclk       : out std_logic;
    rf_3wdataout   : out std_logic;
    rf_3wdataen    : out std_logic;
    rf_3wenableout : out std_logic;
    rf_3wenableen  : out std_logic;

    --------------------------------------
    -- Diag port
    --------------------------------------
    diag_port : out std_logic_vector(1 downto 0)

    );

  end component;


----------------------
-- File: radioctrl.vhd
----------------------
  component radioctrl
  generic (
    ana_digital_g : integer := 3;  -- Selects between analog and HISS interface
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

  end component;



 
end radioctrl_pkg;
