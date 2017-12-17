
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_sm.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.27  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : BuP2 state machines.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_sm/vhdl/rtl/bup2_sm.vhd,v  
--  Log: bup2_sm.vhd,v  
-- Revision 1.27  2006/02/03 08:36:26  Dr.A
-- #BugId:1140#
-- Support of IAC IFS
--
-- Revision 1.26  2005/10/04 12:15:10  Dr.A
-- #BugId:1288#
-- removed unused signal
--
-- Revision 1.25  2005/03/29 08:16:00  Dr.A
-- #BugId:1152#
-- Removed ARTIM counter
--
-- Revision 1.24  2005/03/22 10:14:04  Dr.A
-- #BugId:1152#
-- New ports for arrival time counter enable
--
-- Revision 1.23  2005/02/18 16:21:03  Dr.A
-- #BugId:1070#
-- iacaftersifs bit is set if iac_txenable occurs in the last txstartdel us of the complete SIFS period.
--
-- Revision 1.22  2005/02/09 17:48:24  Dr.A
-- #BugId:1016#
-- Listen to CCA during NORMSIFS
--
-- Revision 1.21  2005/01/21 15:41:58  Dr.A
-- #BugId:822,978#
-- TX immediate stop debug. Added output to timers.
--
-- Revision 1.20  2005/01/13 14:02:25  Dr.A
-- #BugId:903,956#
-- New diag ports (903)
-- Rewrote RX state machine for fake bytes and control structure memory accesses. 'rx' signal to the memory sequencer now comes from the RX state machine (956)
--
-- Revision 1.19  2005/01/10 12:50:37  Dr.A
-- #BugId:912#
-- Removed enable_bup
--
-- Revision 1.18  2004/12/22 17:09:16  Dr.A
-- #BugId:906#
-- Removed ring buffer mechanism and added new checks for end of buffer.
--
-- Revision 1.17  2004/12/20 17:00:33  Dr.A
-- #BugId:850#
-- Added IAC after SIFS mechanism.
--
-- Revision 1.16  2004/12/20 13:02:17  Dr.A
-- #BugId:822#
-- Connected txend status line
--
-- Revision 1.15  2004/12/17 12:54:50  Dr.A
-- #BugId:606#
-- RX end interrupt must be sent to the timers after end of Abort (CCA back to idle)
--
-- Revision 1.14  2004/12/10 10:36:35  Dr.A
-- #BugId:606#
-- Added RX abort after address 1 mismatch
--
-- Revision 1.13  2004/12/06 09:12:41  Dr.A
-- #BugId:836#
-- Adress1 field now checked as soon as received, using mask from register.
--
-- Revision 1.12  2004/12/02 10:28:37  Dr.A
-- #BugId:822#
-- Added tx abort controlled by tx immediate stop register
--
-- Revision 1.11  2004/11/09 14:12:47  Dr.A
-- #BugId:835#
-- New ports for new fields in RX and TX control structures.
--
-- Revision 1.10  2004/05/18 10:47:04  Dr.A
-- Only one input port for phy_cca_ind.
--
-- Revision 1.9  2004/04/14 16:10:42  Dr.A
-- Removed unused signal last_word_size.
--
-- Revision 1.8  2004/02/10 18:32:30  Dr.F
-- port map changed.
--
-- Revision 1.7  2004/02/06 14:46:15  Dr.F
-- removed testdata_rec.
--
-- Revision 1.6  2004/02/05 18:27:29  Dr.F
-- removed modsel.
--
-- Revision 1.5  2004/01/26 08:49:18  Dr.F
-- added ready_load.
--
-- Revision 1.4  2004/01/06 15:03:41  pbressy
-- bugzilla 331 fix
--
-- Revision 1.3  2003/12/09 15:55:53  Dr.F
-- port map changed.
--
-- Revision 1.2  2003/11/25 07:51:55  Dr.F
-- port map changed.
--
-- Revision 1.1  2003/11/19 16:26:22  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------
-- Taken from revision 1.15 of bup_sm.
--
-- Revision 1.15  2003/11/15 14:37:32  Dr.F
-- txpwr_level size changed.
--
-- Revision 1.14  2003/11/13 18:33:36  Dr.F
-- port map changed.
--
-- Revision 1.13  2003/10/09 07:05:54  Dr.F
-- added diag port.
--------------------------------------------------------------------------------


library ieee; 
use ieee.std_logic_1164.all; 

--library bup2_sm_rtl;
library work;
--use bup2_sm_rtl.bup2_sm_pkg.all;      
use work.bup2_sm_pkg.all;      

--------------------------------------------
-- Entity
--------------------------------------------
entity bup2_sm is
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- BuP Registers
    -------------------------------------- 
    tximmstop           : in  std_logic; -- Stop TX when high.
    vcs_enable          : in  std_logic; -- Virtual carrier sense enable.
    enable_1mhz         : in  std_logic; -- 1 MHz signal
    --
    bup_sm_idle         : out std_logic; -- indicates that the state machines 
                                         -- are in idle mode

    buptxptr            : in  std_logic_vector(31 downto 0); -- tx buffer ptr
    buprxptr            : in  std_logic_vector(31 downto 0); -- rx buffer ptr
    buprxoff            : in  std_logic_vector(15 downto 0); -- start address of
                                                             -- next packet
    buprxsize           : in  std_logic_vector(15 downto 0); -- size of ring buf
    buprxunload         : in  std_logic_vector(15 downto 0); -- rx unload ptr
    iacptr              : in  std_logic_vector(31 downto 0); -- IAC ctrl struct ptr

    -- Pulse to reset bcon_txenable.
    reset_bcon_txen  : out std_logic;
    -- Pulse to reset acp_txenable.
    reset_acp_txen   : out std_logic_vector(7 downto 0);
    -- Pulse to reset iac_txenable.
    reset_iac_txen   : out std_logic;
    rx_abortend      : out std_logic; -- end of packet or end of RX abort.
    
    bufempty         : in  std_logic; -- 1 when RX buffer emptied.
    rx_fullbuf       : out std_logic; -- rx buffer full detected when high
    rx_errstat       : out std_logic_vector(1 downto 0); -- error from modem
    rxend_stat       : out std_logic_vector(1 downto 0); -- RX end status
    txend_stat       : out std_logic_vector(1 downto 0); -- TX end status
    rx_fcs_err       : out std_logic; -- end of packet and FCS error detected
    reg_frmcntl      : out std_logic_vector(15 downto 0); -- Frame Control
    reg_durid        : out std_logic_vector(15 downto 0); -- Duration / Id
    reg_bupaddr1     : in  std_logic_vector(47 downto 0); -- Address1 field
    reg_addr1mskh    : in  std_logic_vector( 3 downto 0); -- Mask Address1(43:40)
    reg_addr1mskl    : in  std_logic_vector( 3 downto 0); -- Mask Address1(27:24)
    reg_enrxabort    : in  std_logic; -- Enable abort of RX packets
    -- Number of bytes to save after an RX abort.
    reg_rxabtcnt     : in  std_logic_vector( 5 downto 0);
    reg_rxlen        : out std_logic_vector(11 downto 0); -- rxlen
    reg_rxserv       : out std_logic_vector(15 downto 0); -- rxservice
    reg_rxrate       : out std_logic_vector(3 downto 0); -- rxrate
    reg_rxrssi       : out std_logic_vector(6 downto 0); -- rssi
    reg_rxccaaddinfo : out std_logic_vector( 7 downto 0); -- CCA additional information
    reg_rxant        : out std_logic; -- Antenna used for reception.
    reg_a1match      : out std_logic; -- high when received addr1 matches
    -- IAC after SIFS sticky bit
    iacaftersifs_ack : in  std_logic; -- Acknowledge
    iacaftersifs     : out std_logic; -- Status.
    --------------------------------------
    -- Modem test mode
    -------------------------------------- 
    testenable          : in  std_logic; -- enable BuP test mode
    bup_testmode        : in  std_logic_vector(1 downto 0); -- selects the type of test
    datatype            : in  std_logic_vector(1 downto 0); -- selects the data pattern
    fcsdisb             : in  std_logic; -- disable FCS computation
    testdata            : in  std_logic_vector(31 downto 0); --data test pattern
    --------------------------------------
    -- Interrupts
    -------------------------------------- 
    ccabusy_it          : out std_logic; -- pulse for interrupt on CCA BUSY
    ccaidle_it          : out std_logic; -- pulse for interrupt on CCA IDLE
    rxstart_it          : out std_logic; -- pulse for interrupt on RX packet start
    txstart_it          : out std_logic; -- pulse on start of packet transmition
    rxend_it            : out std_logic; -- pulse for interrupt on RX packet end
    txend_it            : out std_logic; -- pulse for interrupt on TX packet end

    sifs_timer_it       : in  std_logic; -- interrupt when sifs reaches 0.
    backoff_timer_it    : in  std_logic; -- interrupt when backoff reaches 0.
    txstartdel_flag     : in  std_logic; -- Flag set when SIFS count reaches txstartdel.
    iac_txenable        : in  std_logic;
    --------------------------------------------
    -- Bup timers interface
    --------------------------------------------
    iac_without_ifs      : in  std_logic;  -- flag set when no IFS in IAC queue
    -- queue that generated the it :
    --          1000 : IAC
    --          1001 : Beacon
    --   0000 - 0111 : ACP[0-7]
    queue_it_num         : in  std_logic_vector(3 downto 0);
    sampled_queue_it_num : out std_logic_vector(3 downto 0);
    rx_packet_type       : out std_logic;  -- 0 : modem b RX packet; 1 modem a RX packet
    tx_packet_type       : out std_logic;  -- 0 : modem b TX packet; 1 modem a TX packet
    tximmstop_sm         : out std_logic;  -- Immediate stop from the state machines
    --------------------------------------
    -- Memory Sequencer
    -------------------------------------- 
    mem_seq_ready       : in  std_logic; -- memory sequencer is ready (data valid)
    mem_seq_data        : in  std_logic_vector(7 downto 0); -- mem seq data
    --
    mem_seq_req         : out std_logic; -- request to mem seq for new byte
    mem_seq_ind         : out std_logic; -- Indicates to Mem Seq that new byte
                                         -- is ready
    data_to_mem_seq     : out std_logic_vector(7 downto 0);-- byte data to Mem Seq
    mem_seq_rx_mode     : out std_logic; -- Bup in reception mode
    mem_seq_tx_mode     : out std_logic; -- Bup in transmit mode
    last_word           : out std_logic; -- indicates next bytes are part
                                         -- of last word
    mem_seq_rxptr       : out std_logic_vector(31 downto 0);-- rxptr for mem_seq
    mem_seq_txptr       : out std_logic_vector(31 downto 0);-- txptr for mem_seq
    load_ptr            : out std_logic; -- pulse for mem seq to load new ptr
    ready_load          : in  std_logic;        -- ready 4 new load_ptr
    -- access type for endianness converter.
    acctype             : out std_logic_vector(1 downto 0); 

    --------------------------------------
    -- FCS generator
    -------------------------------------- 
    fcs_data_1st        : in  std_logic_vector(7 downto 0); -- First FCS data
    fcs_data_2nd        : in  std_logic_vector(7 downto 0); -- Second FCS data
    fcs_data_3rd        : in  std_logic_vector(7 downto 0); -- Third FCS data
    fcs_data_4th        : in  std_logic_vector(7 downto 0); -- Fourth FCS data
    --
    fcs_init            : out std_logic; -- init FCS computation
    fcs_data_valid      : out std_logic; -- compute FCS on mem seq data
    data_to_fcs         : out std_logic_vector(7 downto 0); -- byte data to FCS
    --------------------------------------
    -- Modem
    -------------------------------------- 
    phy_cca_ind         : in  std_logic; -- CCA status from modems
                                         -- 0 => no signal detected 
                                         -- 1 => busy channel detected 
    phy_data_conf       : in  std_logic; -- last byte was read, ready for new one
    phy_txstartend_conf : in  std_logic; -- transmission started, ready for data
                                         -- or transmission ended
    phy_rxstartend_ind  : in  std_logic; -- preamble detected 
                                         -- or end of received packet
    phy_data_ind        : in  std_logic; -- received byte ready
    rxv_length          : in  std_logic_vector(11 downto 0);-- RX PSDU length
    bup_rxdata          : in  std_logic_vector( 7 downto 0);-- data from Modem
    rxe_errorstat       : in  std_logic_vector( 1 downto 0);-- packet reception 
                                                            -- status
    rxv_datarate        : in  std_logic_vector( 3 downto 0);-- RX PSDU rate
    rxv_service         : in  std_logic_vector(15 downto 0);-- value of RX SERVICE
                                                            -- field (802.11a only)
    rxv_ccaaddinfo      : in  std_logic_vector( 7 downto 0);
    rxv_rxant           : in  std_logic; -- Antenna used during reception.
    -- RX SERVICE field available on rising edge
    rxv_service_ind     : in  std_logic;
    rxv_rssi            : in  std_logic_vector( 6 downto 0);-- preamble RSSI 
                                                            -- (802.11a only)
    rxv_macaddr_match   : out std_logic; -- Address1 match flag.
    --
    phy_data_req        : out std_logic; -- request to send a byte
    phy_txstartend_req  : out std_logic; -- request to start a packet transmission
                                         -- or request for end of transmission
    bup_txdata          : out std_logic_vector(7 downto 0); -- data to Modem
    txv_datarate        : out std_logic_vector( 3 downto 0);-- TX PSDU rate
    txv_length          : out std_logic_vector(11 downto 0);-- TX packet size 
    txpwr_level         : out std_logic_vector( 3 downto 0);-- TX power level
    txv_service         : out std_logic_vector(15 downto 0);-- value of TX SERVICE
                                                            -- field (802.11a only)
    -- Additional transmission control
    txv_txaddcntl       : out std_logic_vector( 1 downto 0);
    -- Index into the PABIAS table to select the PA bias programming
    txv_paindex         : out std_logic_vector( 4 downto 0);
    txv_txant           : out std_logic; -- Antenna to be used for transmission
    ackto               : out std_logic_vector(8 downto 0); -- Time-out for ACK transmission
    ackto_en            : out std_logic; -- Enable ACK time-out generation
    --------------------------------------------
    -- Diag
    --------------------------------------------
    bup_sm_diag         : out std_logic_vector(17 downto 0)    
  );
end bup2_sm;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of bup2_sm is

--------------------------------------------------------------------------------
-- Signals
--------------------------------------------------------------------------------

  signal rxend_stat_i      : std_logic_vector(1 downto 0); -- RX end status
  signal rx_end            : std_logic;  -- end of packet and no auto resp needed
  signal rx_err            : std_logic;  -- unexpected end of packet or CRC error
  signal tx_end            : std_logic;  -- end of transmit packet
  signal tx_mode           : std_logic;  -- Bup in transmit mode            
  signal rx_mode           : std_logic;  -- Bup in reception mode
  signal rx_fcs_init       : std_logic;  -- RX init FCS computation
  signal rx_fcs_data_valid : std_logic;  -- RX compute FCS on mem seq data
  signal tx_fcs_init       : std_logic;  -- TX init FCS computation
  signal tx_fcs_data_valid : std_logic;  -- TX compute FCS on mem seq data
  signal data_to_mem_seq_o : std_logic_vector(7 downto 0); -- byte data to Mem Seq
  signal load_rxptr        : std_logic;  -- pulse for mem seq to load rxptr
  signal load_txptr        : std_logic;  -- pulse for mem seq to load txptr
  signal last_word_rx      : std_logic;  -- next RX bytes are part of last word
  signal last_word_tx      : std_logic;  -- next TX bytes are part of last word
  signal sampled_queue     : std_logic_vector(3 downto 0);  -- sampled tx queue
  -- access type for endianness converter
  signal rx_acc_type       : std_logic_vector(1 downto 0);
  signal tx_acc_type       : std_logic_vector(1 downto 0);

--------------------------------------------
-- Diag signals
--------------------------------------------
signal tx_sm_diag          : std_logic_vector(2 downto 0);
signal tx_read_sm_diag     : std_logic_vector(1 downto 0);
signal rx_sm_diag          : std_logic_vector(7 downto 0);
signal gene_sm_diag        : std_logic_vector(2 downto 0);

------------------------------------------------------ End of Signal declaration

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------

begin
  
  rxend_stat <= rxend_stat_i;
  
  sampled_queue_it_num <= sampled_queue;
  
  bup_sm_diag <= sampled_queue &                   -- 17:14
                 gene_sm_diag &                    -- 13:11
                 tx_read_sm_diag &                 -- 10:9
                 tx_sm_diag &                      --  8:6
                 rx_sm_diag(7 downto 2);           --  5:0
                 
--------------------------------------------------------------------------------
-- General state machine
--------------------------------------------------------------------------------

  bup2_general_sm_1 : bup2_general_sm
    port map (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn            => hresetn,
    hclk               => hclk,
    --------------------------------------
    -- Generic BuP Registers
    -------------------------------------- 
    bup_sm_idle        => bup_sm_idle,
    reset_bcon_txen    => reset_bcon_txen,
    reset_acp_txen     => reset_acp_txen,
    reset_iac_txen     => reset_iac_txen,
    queue_it_num       => queue_it_num,

    --------------------------------------
    -- Commands from BuP Registers
    -------------------------------------- 
    vcs_enable         => vcs_enable,
    tximmstop          => tximmstop,
    --------------------------------------
    -- Modem test mode
    -------------------------------------- 
    testenable         => testenable,
    bup_testmode       => bup_testmode,
    --------------------------------------
    -- Interrupt Generator
    -------------------------------------- 
    ccabusy_it         => ccabusy_it,
    ccaidle_it         => ccaidle_it,
    --------------------------------------
    -- Timers
    -------------------------------------- 
    backoff_timer_it   => backoff_timer_it,
    sifs_timer_it      => sifs_timer_it,
    txstartdel_flag    => txstartdel_flag,
    iac_without_ifs    => iac_without_ifs,  -- Set if no IFS in IAC queue
    --------------------------------------
    -- Modem
    -------------------------------------- 
    phy_cca_ind        => phy_cca_ind, 
    phy_rxstartend_ind => phy_rxstartend_ind,
    --------------------------------------
    -- RX/TX state machine
    -------------------------------------- 
    rxend_stat         => rxend_stat_i,      
    rx_end             => rx_end,      
    rx_err             => rx_err,      
    tx_end             => tx_end,     
    iac_txenable       => iac_txenable,
    iacaftersifs_ack   => iacaftersifs_ack,
    --
    tx_mode            => tx_mode,       
    rx_mode            => rx_mode,
    rxv_macaddr_match  => rxv_macaddr_match,    
    rx_abortend        => rx_abortend,      
    iacaftersifs       => iacaftersifs,
    -------------------------------------- 
    -- Diag
    -------------------------------------- 
    gene_sm_diag       => gene_sm_diag
    );



--------------------------------------------------------------------------------
-- TX state machine
--------------------------------------------------------------------------------

  bup2_tx_sm_1 : bup2_tx_sm
    port map (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn             => hresetn,
    hclk                => hclk,
    --------------------------------------
    -- BuP Registers
    -------------------------------------- 
    tximmstop           => tximmstop,
    enable_1mhz         => enable_1mhz,
    buptxptr            => buptxptr,
    iacptr              => iacptr,

    txend_stat          => txend_stat,
    queue_it_num        => queue_it_num,
    sampled_queue_it_num=> sampled_queue,
    --------------------------------------
    -- Modem test mode
    -------------------------------------- 
    testenable          => testenable,
    bup_testmode        => bup_testmode,
    datatype            => datatype,
    fcsdisb             => fcsdisb,
    testdata            => testdata,
    --------------------------------------
    -- Memory Sequencer
    -------------------------------------- 
    mem_seq_ready       => mem_seq_ready,
    mem_seq_data        => mem_seq_data, 
    --                     
    mem_seq_req         => mem_seq_req,
    mem_seq_txptr       => mem_seq_txptr,
    last_word           => last_word_tx,
    load_txptr          => load_txptr, 
    tx_acc_type         => tx_acc_type,
    --------------------------------------
    -- FCS generator
    -------------------------------------- 
    fcs_data_1st        => fcs_data_1st,      
    fcs_data_2nd        => fcs_data_2nd,      
    fcs_data_3rd        => fcs_data_3rd,      
    fcs_data_4th        => fcs_data_4th,      
    --                     
    fcs_init            => tx_fcs_init,      
    fcs_data_valid      => tx_fcs_data_valid,
    --------------------------------------
    -- Modem
    -------------------------------------- 
    phy_data_conf       => phy_data_conf,   
    phy_txstartend_conf => phy_txstartend_conf,
    --                  
    phy_data_req        => phy_data_req,    
    phy_txstartend_req  => phy_txstartend_req, 
    bup_txdata          => bup_txdata,     
    txv_datarate        => txv_datarate,   
    txv_length          => txv_length,     
    txpwr_level         => txpwr_level,    
    txv_service         => txv_service,    
    txv_txaddcntl       => txv_txaddcntl,
    txv_paindex         => txv_paindex,
    txv_txant           => txv_txant,
    tximmstop_sm        => tximmstop_sm,
    ackto               => ackto,
    ackto_en            => ackto_en,
    --------------------------------------
    -- BuP general state machine
    -------------------------------------- 
    tx_mode             => tx_mode,       
    --                     
    tx_start_it         => txstart_it,
    tx_end_it           => tx_end,
    tx_packet_type      => tx_packet_type,
    --------------------------------------------
    -- Diag
    --------------------------------------------
    tx_sm_diag          => tx_sm_diag,
    tx_read_sm_diag     => tx_read_sm_diag

  );


--------------------------------------------------------------------------------
-- RX state machine
--------------------------------------------------------------------------------

  bup2_rx_sm_1 : bup2_rx_sm
    port map (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn            => hresetn,
    hclk               => hclk,
    --------------------------------------
    -- BuP Registers
    -------------------------------------- 
    buprxptr           => buprxptr,
    buprxoff           => buprxoff,
    buprxsize          => buprxsize,
    buprxunload        => buprxunload,
    reg_frmcntl        => reg_frmcntl,
    reg_durid          => reg_durid,
    reg_bupaddr1       => reg_bupaddr1,
    reg_addr1mskh      => reg_addr1mskh,
    reg_addr1mskl      => reg_addr1mskl,
    reg_rxlen          => reg_rxlen,
    reg_rxserv         => reg_rxserv,
    reg_rxrate         => reg_rxrate,
    reg_rxrssi         => reg_rxrssi,
    reg_rxccaaddinfo   => reg_rxccaaddinfo,
    reg_rxant          => reg_rxant,
    reg_a1match        => reg_a1match,
    reg_enrxabort      => reg_enrxabort,
    reg_rxabtcnt       => reg_rxabtcnt,
    
    --------------------------------------
    -- Modem test mode
    -------------------------------------- 
    fcsdisb            => fcsdisb,
    --------------------------------------
    -- Memory Sequencer
    -------------------------------------- 
    mem_seq_rx_mode    => mem_seq_rx_mode,
    mem_seq_ind        => mem_seq_ind,
    data_to_mem_seq    => data_to_mem_seq_o, 
    last_word          => last_word_rx, 
    mem_seq_rxptr      => mem_seq_rxptr,
    load_rxptr         => load_rxptr,
    ready_load         => ready_load,
    rx_acc_type        => rx_acc_type,
    --------------------------------------
    -- FCS generator
    -------------------------------------- 
    fcs_data_1st       => fcs_data_1st,      
    fcs_data_2nd       => fcs_data_2nd,      
    fcs_data_3rd       => fcs_data_3rd,      
    fcs_data_4th       => fcs_data_4th,      
    --                    
    fcs_init           => rx_fcs_init,      
    fcs_data_valid     => rx_fcs_data_valid,
    --------------------------------------
    -- Modem
    -------------------------------------- 
    phy_data_ind       => phy_data_ind,   
    phy_rxstartend_ind => phy_rxstartend_ind,
    rxv_length         => rxv_length,
    rxe_errorstat      => rxe_errorstat,  
    bup_rxdata         => bup_rxdata,
    rxv_datarate       => rxv_datarate,   
    rxv_service        => rxv_service, 
    rxv_service_ind    => rxv_service_ind,   
    rxv_rssi           => rxv_rssi,    
    rxv_ccaaddinfo     => rxv_ccaaddinfo,    
    rxv_rxant          => rxv_rxant,    
    --------------------------------------
    -- BuP general state machine
    -------------------------------------- 
    rx_mode            => rx_mode,      
    --                    
    rx_end             => rx_end,
    rx_fullbuf         => rx_fullbuf,
    bufempty           => bufempty,
    rxend_stat         => rxend_stat_i,      
    rx_errstat         => rx_errstat,
    rx_fcs_err         => rx_fcs_err,   
    rx_err             => rx_err,
    rx_packet_type     => rx_packet_type,
    --------------------------------------------
    -- Diag
    --------------------------------------------
    rx_sm_diag         => rx_sm_diag
        
  );


--------------------------------------------------------------------------------
-- FCS controls
--------------------------------------------------------------------------------

  fcs_init  <= rx_fcs_init when rx_mode = '1' else
               tx_fcs_init;

  fcs_data_valid  <= rx_fcs_data_valid when rx_mode = '1' else
                     tx_fcs_data_valid;

  data_to_fcs  <= data_to_mem_seq_o when rx_mode = '1' else
                  mem_seq_data;


--------------------------------------------------------------------------------
-- Memory Sequencer controls
--------------------------------------------------------------------------------
  
  data_to_mem_seq     <= data_to_mem_seq_o;
  mem_seq_tx_mode     <= tx_mode;
  load_ptr            <= load_rxptr or load_txptr;
  last_word           <= last_word_tx when tx_mode = '1' else last_word_rx;
  acctype             <= tx_acc_type when tx_mode = '1' else rx_acc_type;
  
--------------------------------------
-- Interrupt Generator pulses
-------------------------------------- 

  -- for RX start use rx_fcs_init, 
  -- since this indicates we start receiving a packet
  rxstart_it  <= rx_fcs_init;  
  rxend_it    <= rx_end;   
  txend_it    <= tx_end;   

end RTL;
