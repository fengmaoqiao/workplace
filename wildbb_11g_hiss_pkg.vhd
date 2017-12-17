
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: wildbb_11g_hiss_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.17  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for wildbb_11g_hiss.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBB_11G_HISS/wildbb_11g_hiss/vhdl/rtl/wildbb_11g_hiss_pkg.vhd,v  
--  Log: wildbb_11g_hiss_pkg.vhd,v  
-- Revision 1.17  2005/10/21 13:35:00  Dr.A
-- #BugId:1246#
-- Added generic for absolute timers
--
-- Revision 1.16  2005/10/04 12:29:42  Dr.A
-- #BugId:1288#
-- Removed unused signals and rf_goto_sleep port
--
-- Revision 1.15  2005/04/07 08:41:05  sbizet
-- #BugId:1191#
-- Added port select_clk80
--
-- Revision 1.14  2005/01/19 09:23:40  pbressy
-- #BugId:936#
-- rewiring of wlanrxind to the top, to go to platform
--
-- Revision 1.13  2005/01/13 14:12:16  Dr.A
-- #BugId:903#
-- New diag ports.
--
-- Revision 1.12  2005/01/04 13:45:08  sbizet
-- #BugId:907#
-- Added agc_busy outport
--
-- Revision 1.11  2004/12/14 17:43:52  sbizet
-- #BugId:907#
-- modem and radioctrl port map updated
--
-- Revision 1.10  2004/11/09 14:15:35  Dr.A
-- #BugId:835#
-- New bup2_kernel ports
--
-- Revision 1.9  2004/10/07 16:36:41  Dr.A
-- #BugId:780#
-- radio_interface_g hard-coded to '2'
--
-- Revision 1.8  2004/08/27 09:17:16  Dr.A
-- Radio controller generic set to accept 44 MHz clock.
--
-- Revision 1.7  2004/07/01 08:29:15  Dr.A
-- Added hiss_reset_n
--
-- Revision 1.6  2004/06/04 14:13:24  Dr.C
-- Updated modem802_11g_wildrf and radioctrl.
--
-- Revision 1.5  2004/05/18 13:32:52  Dr.A
-- Added bup_clk input for BuP-Modem synchro blocks.
-- Use only one phy_cca_ind input for A and B modems.
--
-- Revision 1.4  2004/05/07 09:47:40  pbressy
-- corrected error
--
-- Revision 1.3  2004/05/06 15:50:05  pbressy
-- added clk80 for modem
--
-- Revision 1.2  2004/04/08 14:49:51  pbressy
-- removed all analog ports
--
-- Revision 1.1  2004/04/06 13:40:32  pbressy
-- initial release
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
package wildbb_11g_hiss_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- Source: Good
----------------------
  component bup2_kernel
  generic (
    num_queues_g      : integer := 8;
    num_abstimer_g    : integer := 8
    );
  port (    
    --------------------------------------------
    -- Clock and reset.
    --------------------------------------------
    reset_n          : in std_logic; -- Global reset.
    hclk             : in std_logic; -- AHB clock.
    buptimer_clk     : in std_logic; -- buptimer clock (not gated)
    enable_1mhz      : in std_logic; -- 1 MHz enable
    mode32k          : in std_logic; -- buptimer_clk = 32kHz when high
    
    --------------------------------------------
    -- AHB master 
    --------------------------------------------
    hgrant           : in  std_logic;                      -- Bus grant.
    hready           : in  std_logic;                      -- Ready (Active LOW)
    hrdata           : in  std_logic_vector(31 downto 0);  -- AHB read data.
    hresp            : in  std_logic_vector( 1 downto 0);  -- Transfer status.
    --
    hbusreq          : out std_logic;                      -- Bus request.
    hlock            : out std_logic;                      -- Bus lock.
    hwrite           : out std_logic;                      -- Write transaction.
    htrans           : out std_logic_vector( 1 downto 0);  -- Transfer type.
    hsize            : out std_logic_vector( 2 downto 0);  -- Transfer size.
    hburst           : out std_logic_vector( 2 downto 0);  -- Burst type.
    hprot            : out std_logic_vector( 3 downto 0);  -- Protection.
    haddr            : out std_logic_vector(31 downto 0);  -- AHB address.
    hwdata           : out std_logic_vector(31 downto 0);  -- AHB write data.
    -- access type for endianness converter
    acctype          : out std_logic_vector(1 downto 0);   -- access type
    --------------------------------------------
    -- APB slave
    --------------------------------------------  
    -- From master 0  
    psel0            : in  std_logic;                      -- Device select.
    penable0         : in  std_logic;                      -- Enable.
    paddr0           : in  std_logic_vector( 7 downto 0);  -- Address.
    pwrite0          : in  std_logic;                      -- Write signal.
    pwdata0          : in  std_logic_vector(31 downto 0);  -- Write data.
    --
    prdata0          : out std_logic_vector(31 downto 0);  -- Read data.
    -- From master 1
    psel1            : in  std_logic;                      -- Device select.
    penable1         : in  std_logic;                      -- Enable.
    paddr1           : in  std_logic_vector( 7 downto 0);  -- Address.
    pwrite1          : in  std_logic;                      -- Write signal.
    pwdata1          : in  std_logic_vector(31 downto 0);  -- Write data.
    --
    prdata1          : out std_logic_vector(31 downto 0);  -- Read data.

    --------------------------------------------
    -- Modem
    --------------------------------------------    
    -- Data
    bup_rxdata          : in  std_logic_vector(7 downto 0);
    -- Modem Status signals
    phy_txstartend_conf : in  std_logic; -- transmission started, ready for
                                         -- data, or transmission ended.
    phy_rxstartend_ind  : in  std_logic; -- preamble detected
                                         -- or end of rx packet
    phy_data_conf       : in  std_logic; -- last byte read, ready for new one.
    phy_data_ind        : in  std_logic; -- received byte ready.
    
    rxv_datarate        : in  std_logic_vector( 3 downto 0); -- RX PSDU rate.
    rxv_length          : in  std_logic_vector(11 downto 0); -- RX PSDU length.
    rxv_errorstat       : in  std_logic_vector( 1 downto 0); -- packet status.
    phy_cca_ind         : in  std_logic; -- CCA status from modems.
    
    rxv_rssi            : in  std_logic_vector( 6 downto 0); -- preamble RSSI.
    -- bits (15:8) of the CCA data field received from the radio.
    rxv_ccaaddinfo     	: in  std_logic_vector( 7 downto 0);
    rxv_rxant           : in  std_logic; -- Antenna used during reception.
    rxv_service         : in  std_logic_vector(15 downto 0); -- RX SERVICE field.
    rxv_service_ind     : in  std_logic; -- Service field is ready for Modem A.
    phy_ccarst_conf     : in  std_logic; -- confirmation of CCA sm reset.    
    -- Modem Control signals
    phy_txstartend_req  : out std_logic; -- req. to start a packet transmission
    phy_ccarst_req      : out std_logic; -- request to reset CCA state machine
                                         -- or request for end of transmission.
    phy_data_req        : out std_logic; -- request to send a byte.
    -- Indication that MAC Address 1 of received packet matches
    rxv_macaddr_match   : out std_logic;
    --------------------------------------------
    -- BuP
    --------------------------------------------    
    txv_datarate     : out std_logic_vector( 3 downto 0); -- TX PSDU rate.
    txv_length       : out std_logic_vector(11 downto 0); -- TX PSDU length.
    txpwr_level      : out std_logic_vector( 3 downto 0); -- TX power level.
    txv_service      : out std_logic_vector(15 downto 0); -- TX SERVICE 802.11a
    -- Index into the PABIAS table to select PA bias programming value
    txv_paindex      : out std_logic_vector( 4 downto 0);
    txv_txant        : out std_logic; -- Antenna to be used for transmission
    -- Additional transmission control
    txv_txaddcntl    : out std_logic_vector( 1 downto 0);
    -- TX immediate stop status
    txv_immstop      : out std_logic;
    bup_txdata       : out std_logic_vector( 7 downto 0);
    
    --------------------------------------------
    -- Interrupt lines
    --------------------------------------------    
    bup_irq          : out std_logic; -- BuP normal interrupt line.
    bup_fiq          : out std_logic; -- BuP fast interrupt line.
    
    --------------------------------------------
    -- GPO (General Purpose Output)
    -- connected to the testdata registers
    --------------------------------------------
    gpo              : out std_logic_vector(31 downto 0);

    --------------------------------------------
    -- General Purpose Input
    --------------------------------------------
    buptestdin       : in  std_logic_vector(31 downto 0);
    
    --------------------------------------------
    -- Diag signals
    --------------------------------------------
    bup_diag0        : out std_logic_vector(15 downto 0);
    bup_diag1        : out std_logic_vector(15 downto 0);
    bup_diag2        : out std_logic_vector(15 downto 0);
    bup_diag3        : out std_logic_vector(15 downto 0)
    
    
  );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_IP_MII/IPs/WILD/STREAM_PROCESSOR/stream_processor/vhdl/rtl/stream_processor.vhd
----------------------
  component stream_processor
  generic (
    big_endian_g : integer := 0;        -- 1 => Big endian bus interface.
    aes_enable_g : integer := 1         -- Enables AES. 0 => RC4 only.
                                        --              1 => AES and RC4.
                                        --              2 => AES only.
  );
  port (
    -- Clocks and resets
    clk          : in  std_logic;       -- AHB and APB clock.
    reset_n      : in  std_logic;       -- AHB and APB reset. Inverted logic.
    -- AHB Master
    hgrant       : in  std_logic;       -- Bus grant.
    hready       : in  std_logic;       -- AHB Slave ready.
    hresp        : in  std_logic_vector( 1 downto 0);-- AHB Transfer response.
    hrdata       : in  std_logic_vector(31 downto 0);-- AHB Read data bus.
    hbusreq      : out std_logic;       -- Bus request.
    hlock        : out std_logic;       -- Locked transfer.
    htrans       : out std_logic_vector( 1 downto 0);-- AHB Transfer type.
    haddr        : out std_logic_vector(31 downto 0);-- AHB Address.
    hwrite       : out std_logic;       -- Transfer direction. 1=>Write;0=>Read
    hsize        : out std_logic_vector( 2 downto 0);-- AHB Transfer size.
    hburst       : out std_logic_vector( 2 downto 0);-- AHB Burst information.
    hprot        : out std_logic_vector( 3 downto 0);-- Protection information.
    hwdata       : out std_logic_vector(31 downto 0);-- AHB Write data bus.
    -- APB Slave
    paddr        : in  std_logic_vector(4 downto 0);-- APB Address.
    psel         : in  std_logic;       -- Selection line.
    pwrite       : in  std_logic;       -- 0 => Read; 1 => Write.
    penable      : in  std_logic;       -- APB enable line.
    pwdata       : in  std_logic_vector(31 downto 0);-- APB Write data bus.
    prdata       : out std_logic_vector(31 downto 0);-- APB Read data bus.
    -- Interrupt line
    interrupt    : out std_logic;       -- Interrupt line.
    -- AES SRAM:
    aesram_di_o  : out std_logic_vector(127 downto 0);-- Data to be written.
    aesram_a_o   : out std_logic_vector(  3 downto 0);-- Address.
    aesram_rw_no : out std_logic;       -- Write Enable. Inverted logic.
    aesram_cs_no : out std_logic;       -- Chip Enable. Inverted logic.
    aesram_do_i  : in  std_logic_vector(127 downto 0);-- Data read.
    -- RC4 SRAM:
    rc4ram_di_o  : out std_logic_vector(7 downto 0);-- Data to be written.
    rc4ram_a_o   : out std_logic_vector(8 downto 0);-- Address.
    rc4ram_rw_no : out std_logic;       -- Write Enable. Inverted logic.
    rc4ram_cs_no : out std_logic;       -- Chip Enable. Inverted logic.
    rc4ram_do_i  : in  std_logic_vector(7 downto 0); -- Data read.
    -- Diagnostic ports
    test_vector  : out std_logic_vector(31 downto 0)
  );
  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_IP_MII/IPs/WILD/WILDRF_FRONTEND/modem802_11g_wildrf/vhdl/rtl/modem802_11g_wildrf.vhd
----------------------
  component modem802_11g_wildrf
  generic (
    radio_interface_g : integer := 1   -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    modema_clk      : in  std_logic; -- Modem 802.11a main clock
    rx_path_a_gclk  : in  std_logic; -- Modem 802.11a gated clock for RX path
    tx_path_a_gclk  : in  std_logic; -- Modem 802.11a gated clock for TX path
    fft_gclk        : in  std_logic; -- Modem 802.11a FFT gated clock
    modemb_clk      : in  std_logic; -- Modem 802.11b main clock
    rx_path_b_gclk  : in  std_logic; -- Modem 802.11b gated clock for RX path
    tx_path_b_gclk  : in  std_logic; -- Modem 802.11b gated clock for TX path
    bus_clk         : in  std_logic; -- APB clock
    bup_clk         : in  std_logic; -- BuP clock
    sampling_clk    : in  std_logic; -- sampling clock
    filta_clk       : in  std_logic; -- sampling clock 11a filters
    filtb_clk       : in  std_logic; -- sampling clock 11b filters
    rcagc_main_clk  : in  std_logic; -- AGC clock at 80 MHz.
    reset_n         : in  std_logic; -- global reset
    select_clk80    : in  std_logic; -- Indicates clock frequency: '1' = 80 MHz
                                     --                            '0' = 44 MHz
    --
    rstn_non_srpg_wild_sync  : in  std_logic;  -- Added for PSO - Santhosh  
    --
    modema_rx_gating : out std_logic; -- Gating condition for Rx path .11a
    modema_tx_gating : out std_logic; -- Gating condition for Tx path .11a
    modemb_rx_gating : out std_logic; -- Gating condition for Rx path .11b
    modemb_tx_gating : out std_logic; -- Gating condition for Tx path .11b
    --
    clkskip         : out std_logic; -- skip one clock cycle in Rx path
    --
    calib_test      : out std_logic;
  
    --------------------------------------
    -- APB slave
    --------------------------------------
    psel_modema     : in  std_logic; -- Select. modem a registers
    psel_modemb     : in  std_logic; -- Select. modem b registers
    psel_modemg     : in  std_logic; -- Select. modem g registers
    penable         : in  std_logic; -- Defines the enable cycle.
    paddr           : in  std_logic_vector( 5 downto 0); -- Address.
    pwrite          : in  std_logic; -- Write signal.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata_modema   : out std_logic_vector(31 downto 0); -- Read modem a data.
    prdata_modemb   : out std_logic_vector(31 downto 0); -- Read modem b data.
    prdata_modemg   : out std_logic_vector(31 downto 0); -- Read modem g data.
    
    --------------------------------------------
    -- Interface with Wild Bup
    --------------------------------------------
    -- inputs signals                                                           
    bup_txdata          : in  std_logic_vector(7 downto 0); -- data to send         
    phy_txstartend_req  : in  std_logic; -- request to start a packet transmission    
    phy_data_req        : in  std_logic; -- request to send a byte                  
    phy_ccarst_req      : in  std_logic; -- request to reset CCA state machine                 
    txv_length          : in  std_logic_vector(11 downto 0);  -- RX PSDU length     
    txv_service         : in  std_logic_vector(15 downto 0);  -- tx service field   
    txv_datarate        : in  std_logic_vector( 3 downto 0); -- PSDU transm. rate
    txpwr_level         : in  std_logic_vector( 2 downto 0); -- TX power level.
    rxv_macaddr_match   : in  std_logic;                     -- Stop the reception because the mac 
                                                             -- addresss does not match  
    txv_immstop         : in  std_logic; -- request to stop the transmission               
    
    -- outputs signals                                                          
    phy_txstartend_conf : out std_logic; -- transmission started, ready for data  
    phy_rxstartend_ind  : out std_logic; -- indication of RX packet                     
    phy_ccarst_conf     : out std_logic; 
    phy_data_conf       : out std_logic; -- last byte was read, ready for new one 
    phy_data_ind        : out std_logic; -- received byte ready                  
    rxv_length          : out std_logic_vector(11 downto 0); -- RX PSDU length  
    rxv_service         : out std_logic_vector(15 downto 0); -- rx service field
    rxv_service_ind     : out std_logic;
    rxv_datarate        : out std_logic_vector( 3 downto 0); -- PSDU rec. rate
    rxe_errorstat       : out std_logic_vector( 1 downto 0); -- packet recep. stat
    phy_cca_ind         : out std_logic; -- CCA status from Modems
    bup_rxdata          : out std_logic_vector(7 downto 0); -- data received      
    rxv_rssi            : out std_logic_vector (6 downto 0);  -- Value of measured RSSI
    rxv_rxant           : out std_logic;                      -- Antenna used
    rxv_ccaaddinfo      : out std_logic_vector (15 downto 8); -- Additionnal data

    --------------------------------------
    -- HISS mode
    --------------------------------------
    hiss_mode_n         : in  std_logic;
    
    --------------------------------------
    -- Radio controller interface
    --------------------------------------
    -- 802.11a side
    a_txonoff_conf      : in  std_logic;
    a_txonoff_req       : out std_logic;
    a_txbbonoff_req_o   : out std_logic;
    a_txdatavalid       : out std_logic; -- toggle when new data (only on HiSS)
    a_dac_enable        : out std_logic;
    --
    a_rxonoff_conf      : in  std_logic;
    a_rxonoff_req       : out std_logic;
    a_rxdatavalid       : in  std_logic; -- toggle when new data (only on HiSS)
    -- 802.11b side
    b_txonoff_conf      : in  std_logic;
    b_txonoff_req       : out std_logic;
    b_txbbonoff_req     : out std_logic;
    b_txdatavalid       : out std_logic; -- toggle when new data (only on HiSS)
    b_dac_enable        : out std_logic;
    --
    b_rxonoff_conf      : in  std_logic;
    b_rxonoff_req       : out std_logic;
    b_rxdatavalid       : in  std_logic;  -- toggle when new data (only on HiSS)
    --
    clk_2skip_i         : in  std_logic;
    b_antswitch         : out std_logic;
    -- ADC/DAC
    rxi                 : in  std_logic_vector(10 downto 0);
    rxq                 : in  std_logic_vector(10 downto 0);
    txi                 : out std_logic_vector(9 downto 0);
    txq                 : out std_logic_vector(9 downto 0);
    -- misc
    pa_on               : in  std_logic; -- high when PA is on.
    gain_o              : out std_logic_vector(7 downto 0);
    sync_found          : out std_logic; -- Synchronization found active high

    --
    agc_cca_flags        : in std_logic_vector (5 downto 0);
                                       -- indicates cca procedure stat
    agc_cca_add_flags    : in std_logic_vector (15 downto 0);
                                       -- CCA additional data
    agc_cca_flags_marker : in  std_logic;  -- pulse to indicate cca_flags are val
    agc_cca_cs           : in  std_logic_vector (1 downto 0);
                                       -- carrier sense informati
    agc_cca_cs_valid     : in  std_logic;  -- pulse to indicate cca_cs are valid
    sw_rfoff_req         : in  std_logic; -- pulse resquest by SW to switch idle the WiLDRF  
    
    agc_rx_onoff_conf    : in std_logic; -- Acknowledges start/end of Rx  
    agc_ana_enable       : in std_logic; -- Enable the fake analog AGC
    rf_cca               : in std_logic; 

    agc_stream_enable    : out std_logic;  -- Enable hiss 'pipe' on reception
    agc_ab_mode          : out std_logic;  -- Mode of received packet
    agc_rx_onoff_req     : out std_logic; -- Indicates start/end of Rx  

    agc_rfoff            : out std_logic; -- Indicates that the WiLD RF can be switch off
    agc_rfint            : out std_logic; -- Interrupt from WiLDRF

    agc_busy             : out std_logic;   -- Indicates when receiving a packet(Including RF config)
    --------------------------------------
    -- WLAN Indication
    --------------------------------------
    wlanrxind            : out std_logic; -- Indicates a wlan reception
    
    --------------------------------------
    -- Diag. port
    --------------------------------------
    modem_diag0         : out std_logic_vector(15 downto 0); -- Modem b diag.
    modem_diag1         : out std_logic_vector(15 downto 0);
    modem_diag2         : out std_logic_vector(15 downto 0);
    modem_diag3         : out std_logic_vector(15 downto 0);
    --
    modem_diag4         : out std_logic_vector(15 downto 0); -- Common diag
    modem_diag5         : out std_logic_vector(15 downto 0);
    --
    modem_diag6         : out std_logic_vector(15 downto 0); -- Modem a diag.
    modem_diag7         : out std_logic_vector(15 downto 0);
    modem_diag8         : out std_logic_vector(15 downto 0);
    modem_diag9         : out std_logic_vector(15 downto 0);
    agc_cca_diag0       : out std_logic_vector(15 downto 0)
    );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_IP_MII/IPs/WILD/WILDRF_FRONTEND/radioctrl/vhdl/rtl/radioctrl.vhd
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


----------------------
-- File: wildbb_11g_hiss.vhd
----------------------
  component wildbb_11g_hiss
  generic (
    num_queues_g      : integer := 4;
    num_abstimer_g    : integer := 8
    );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n            : in  std_logic; -- Global reset.
    hiss_resetn        : in  std_logic; -- Reset for Radio Controller (synch to hiss_sclk).
    modema_clk         : in  std_logic; -- Clock for Modem 802.11a (80 MHz).
    rx_path_a_clk      : in  std_logic; -- Gated Clock for Modem 802.11a RX Path
    tx_path_a_clk      : in  std_logic; -- Gated Clock for Modem 802.11a TX Path
    fft_gclk           : in  std_logic; -- Gated clock for Modem 802.11a FFT
    modemb_clk         : in  std_logic; -- Clock for Modem 802.11b (44 MHz).
    rx_path_b_clk      : in  std_logic; -- Gated Clock for Modem 802.11b RX Path
    tx_path_b_clk      : in  std_logic; -- Gated Clock for Modem 802.11b TX Path
    bus_gclk           : in  std_logic; -- AHB and APB clock.
    bus_clk            : in  std_logic; -- AHB and APB clock (not gated).
    rcagc_main_clk     : in  std_logic; -- Sampling clock at 60 MHz for radio cntl.
    enable_1mhz        : in  std_logic; -- 1 MHz enable.
    strp_clk           : in  std_logic; -- Stream PRocessor Clock
    mode32k            : in  std_logic; -- bus_clk = 32kHz when high
    select_clk80       : in  std_logic; -- bus_clk running at 80MHz(1) or 44MHz(0)
    --
    rx_path_b_gclk_en  : out std_logic; -- High to enable rx_path_b_clk.
    tx_path_b_gclk_en  : out std_logic; -- High to enable tx_path_b_clk.
    rx_path_a_gclk_en  : out std_logic; -- High to enable rx_path_a_clk.
    tx_path_a_gclk_en  : out std_logic; -- High to enable tx_path_a_clk.
    --
    clkskip            : out std_logic; -- skip one clock cycle in 802.11b Rx path
    --
    calib_test         : out std_logic; -- RF calibration test mode
    
    --------------------------------------
    -- Interrupt lines
    --------------------------------------    
    bup_irq           : out std_logic; -- BuP interrupt
    bup_fiq           : out std_logic; -- BuP interrupt
    stream_proc_irq   : out std_logic; -- 802.11 stream processing interrupt
    radio_ctrl_irq    : out std_logic; -- Radio controller interrupt
   
    --------------------------------------
    -- PSO related signals
    --------------------------------------
    gate_clk_wild_sync       : in  std_logic;  -- Added for PSO - Santhosh  
    rstn_non_srpg_wild_sync  : in  std_logic;  -- Added for PSO - Santhosh  

    --------------------------------------
    -- AHB bus
    --------------------------------------
    hgrant_bup        : in  std_logic; -- BuP AHB Bus granted.
    hgrant_streamproc : in  std_logic; -- 802.11 stream proc. AHB Bus granted.
    hready            : in  std_logic; -- Ready signal. Active LOW.
    hresp             : in  std_logic_vector( 1 downto 0);-- Transfer status.
    hrdata            : in  std_logic_vector(31 downto 0);-- Read data bus.
    -- from BuP
    hbusreq_bup       : out std_logic; -- AHB Bus request.
    haddr_bup         : out std_logic_vector(31 downto 0);-- Address bus
    hwrite_bup        : out std_logic; -- Transfer direction. 1=>Write;0=>Read.
    htrans_bup        : out std_logic_vector( 1 downto 0);-- Transfer type.
    hsize_bup         : out std_logic_vector( 2 downto 0);-- Transfer size.
    hburst_bup        : out std_logic_vector( 2 downto 0);-- Burst information.
    hwdata_bup        : out std_logic_vector(31 downto 0);-- Write data bus.
    hlock_bup         : out std_logic; -- Lock transfer.
    hprot_bup         : out std_logic_vector( 3 downto 0);-- Protection mode.
    -- from 802.11 stream processing
    hbusreq_streamproc: out std_logic; -- AHB Bus request.
    haddr_streamproc  : out std_logic_vector(31 downto 0);-- Address bus
    hwrite_streamproc : out std_logic; -- Transfer direction. 1=>Write;0=>Read.
    htrans_streamproc : out std_logic_vector( 1 downto 0);-- Transfer type.
    hsize_streamproc  : out std_logic_vector( 2 downto 0);-- Transfer size.
    hburst_streamproc : out std_logic_vector( 2 downto 0);-- Burst information.
    hwdata_streamproc : out std_logic_vector(31 downto 0);-- Write data bus.
    hlock_streamproc  : out std_logic; -- Lock transfer.
    hprot_streamproc  : out std_logic_vector( 3 downto 0);-- Protection mode.
 
    --------------------------------------
    -- APB bus
    --------------------------------------
    paddr             : in  std_logic_vector(15 downto 0); -- APB Address bus.
    psel_modema       : in  std_logic; -- 802.11a modem selection line.
    psel_modemb       : in  std_logic; -- 802.11b modem selection line.
    psel_modemg       : in  std_logic; -- 802.11g modem selection line.
    psel_bup          : in  std_logic; -- BuP Selection line.
    psel_radio        : in  std_logic; -- Radio controller Selection line.
    psel_streamproc   : in  std_logic; -- Stream processing selection line.
    pwrite            : in  std_logic; -- 0 => Read; 1 => Write.
    penable           : in  std_logic; -- APB enable line.
    pwdata            : in  std_logic_vector(31 downto 0);-- APB Write data bus.
    --
    prdata_modema     : out std_logic_vector(31 downto 0);-- Modem a data bus.
    prdata_modemb     : out std_logic_vector(31 downto 0);-- Modem b data bus.
    prdata_modemg     : out std_logic_vector(31 downto 0);-- Modem g data bus.
    prdata_bup        : out std_logic_vector(31 downto 0);-- BuP data bus.
    prdata_radio      : out std_logic_vector(31 downto 0);-- Radio ctrl data bus
    prdata_streamproc : out std_logic_vector(31 downto 0);-- Str. proc. data bus

    -------------------------------------------
    -- Hiss radio interface                        
    -------------------------------------------
    hiss_rxi          : in  std_logic;
    hiss_rxq          : in  std_logic;
    rfh_fastclk       : in  std_logic; -- 240 MHz clock without clktree (directly from pad) 
    hiss_fastclk      : in  std_logic; -- 240 MHz clock
    hiss_en_force     : in  std_logic;
    --
    hiss_txi          : out std_logic;
    hiss_txq          : out std_logic;
    hiss_txen         : out std_logic;
    hiss_rxen         : out std_logic;
    rf_en             : out std_logic;
    hiss_biasen       : out std_logic;        -- enable HiSS drivers and receivers
    hiss_replien      : out std_logic;       -- enable HiSS drivers and receivers
    hiss_clken        : out std_logic;       -- Enable HiSS clock receivers
    hiss_curr         : out std_logic;       -- Select high/low-current mode for HiSS drivers

    -------------------------------------------
    -- Clock control                       
    -------------------------------------------

    clk_div           : out std_logic_vector(2 downto 0);
    clk_switched      : out std_logic;
    --------------------------------------DB !!!-----
    -- Radio control                       
    -------------------------------------------
    hiss_mode_n       : in  std_logic;

    rf_sw             : out std_logic_vector(3 downto 0);
    --------------------------------------------
    -- AES SRAM:
    --------------------------------------------
    aesram_do_i       : in  std_logic_vector(127 downto 0);-- Data read.
    --
    aesram_di_o       : out std_logic_vector(127 downto 0);-- Data to be written
    aesram_a_o        : out std_logic_vector(  3 downto 0);-- Address.
    aesram_rw_no      : out std_logic; -- Write Enable. Inverted logic.
    aesram_cs_no      : out std_logic; -- Chip Enable. Inverted logic.

    --------------------------------------------
    -- RC4 SRAM:
    --------------------------------------------
    rc4ram_do_i       : in  std_logic_vector(7 downto 0);-- Data read.
    --
    rc4ram_di_o       : out std_logic_vector(7 downto 0);-- Data to be written.
    rc4ram_a_o        : out std_logic_vector(8 downto 0);-- Address.
    rc4ram_rw_no      : out std_logic; -- Write Enable. Inverted logic.
    rc4ram_cs_no      : out std_logic; -- Chip Enable. Inverted logic.

    --------------------------------------
    -- Diagnostic port:
    --------------------------------------
    modem_diag0       : out std_logic_vector(15 downto 0); -- Modemb diag.
    modem_diag1       : out std_logic_vector(15 downto 0);
    modem_diag2       : out std_logic_vector(15 downto 0);
    modem_diag3       : out std_logic_vector(15 downto 0);
    modem_diag4       : out std_logic_vector(15 downto 0); -- Modem common diag.
    modem_diag5       : out std_logic_vector(15 downto 0);
    modem_diag6       : out std_logic_vector(15 downto 0); -- Modema diag.
    modem_diag7       : out std_logic_vector(15 downto 0);
    modem_diag8       : out std_logic_vector(15 downto 0);
    modem_diag9       : out std_logic_vector(15 downto 0);
    stream_proc_diag  : out std_logic_vector(31 downto 0);
    radio_ctrl_diag0  : out std_logic_vector(15 downto 0); 
    radio_ctrl_diag1  : out std_logic_vector(15 downto 0); 
    bup_diag0         : out std_logic_vector(15 downto 0);
    bup_diag1         : out std_logic_vector(15 downto 0);
    bup_diag2         : out std_logic_vector(15 downto 0);
    bup_diag3         : out std_logic_vector(15 downto 0);
    agc_cca_diag0     : out std_logic_vector(15 downto 0);

    --------------------------------------
    -- WLAN Indication
    --------------------------------------
    wlanrxind : out std_logic
    
    );

  end component;


  component CKLNQD1
    port (
	TE              : in  std_logic;
	E               : in  std_logic;
	CP              : in  std_logic;
	Q               : out std_logic
	); 
  end component;

end wildbb_11g_hiss_pkg;
