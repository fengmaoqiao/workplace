
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_sm_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.27  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for bup2_sm.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_sm/vhdl/rtl/bup2_sm_pkg.vhd,v  
--  Log: bup2_sm_pkg.vhd,v  
-- Revision 1.27  2006/02/03 08:36:33  Dr.A
-- #BugId:1140#
-- Support of IAC IFS
--
-- Revision 1.26  2005/04/19 07:56:34  Dr.A
-- #BugId:1212#
-- Removed top entity component from package
--
-- Revision 1.25  2005/03/29 08:17:42  Dr.A
-- #BugId:1152#
-- Removed ARTIM counter
--
-- Revision 1.24  2005/03/22 10:14:07  Dr.A
-- #BugId:1152#
-- New ports for arrival time counter enable
--
-- Revision 1.23  2005/02/18 16:21:06  Dr.A
-- #BugId:1070#
-- iacaftersifs bit is set if iac_txenable occurs in the last txstartdel us of the complete SIFS period.
--
-- Revision 1.22  2005/02/09 17:48:27  Dr.A
-- #BugId:1016#
-- Listen to CCA during NORMSIFS
--
-- Revision 1.21  2005/01/21 15:42:02  Dr.A
-- #BugId:822,978#
-- TX immediate stop debug. Added output to timers.
--
-- Revision 1.20  2005/01/13 14:02:29  Dr.A
-- #BugId:903,956#
-- New diag ports (903)
-- Rewrote RX state machine for fake bytes and control structure memory accesses. 'rx' signal to the memory sequencer now comes from the RX state machine (956)
--
-- Revision 1.19  2005/01/10 12:50:41  Dr.A
-- #BugId:912#
-- Removed enable_bup
--
-- Revision 1.18  2004/12/22 17:09:19  Dr.A
-- #BugId:906#
-- Removed ring buffer mechanism and added new checks for end of buffer.
--
-- Revision 1.17  2004/12/20 17:00:37  Dr.A
-- #BugId:850#
-- Added IAC after SIFS mechanism.
--
-- Revision 1.16  2004/12/20 13:02:21  Dr.A
-- #BugId:822#
-- Connected txend status line
--
-- Revision 1.15  2004/12/17 12:54:53  Dr.A
-- #BugId:606#
-- RX end interrupt must be sent to the timers after end of Abort (CCA back to idle)
--
-- Revision 1.14  2004/12/10 10:36:39  Dr.A
-- #BugId:606#
-- Added RX abort after address 1 mismatch
--
-- Revision 1.13  2004/12/06 09:12:48  Dr.A
-- #BugId:836#
-- Adress1 field now checked as soon as received, using mask from register.
--
-- Revision 1.12  2004/12/02 10:28:40  Dr.A
-- #BugId:822#
-- Added tx abort controlled by tx immediate stop register
--
-- Revision 1.11  2004/11/09 14:12:49  Dr.A
-- #BugId:835#
-- New ports for new fields in RX and TX control structures.
--
-- Revision 1.10  2004/05/18 10:47:07  Dr.A
-- Only one input port for phy_cca_ind.
--
-- Revision 1.9  2004/04/14 16:10:48  Dr.A
-- Removed unused signal last_word_size.
--
-- Revision 1.8  2004/02/10 18:32:37  Dr.F
-- port map changed.
--
-- Revision 1.7  2004/02/06 14:46:20  Dr.F
-- removed testdata_rec.
--
-- Revision 1.6  2004/02/05 18:27:32  Dr.F
-- removed modsel.
--
-- Revision 1.5  2004/01/26 08:49:23  Dr.F
-- added ready_load.
--
-- Revision 1.4  2004/01/06 15:03:19  pbressy
-- bugzilla 331 fix
--
-- Revision 1.3  2003/12/09 15:56:00  Dr.F
-- port map changed.
--
-- Revision 1.2  2003/11/25 07:52:11  Dr.F
-- port map changed.
--
-- Revision 1.1  2003/11/19 16:26:23  Dr.F
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
package bup2_sm_pkg is

  -- Define constants for accessed data type.
  constant WORD_CT  : std_logic_vector(1 downto 0) := "00";
  constant HWORD_CT : std_logic_vector(1 downto 0) := "01";
  constant BYTE_CT  : std_logic_vector(1 downto 0) := "10";

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: bup2_general_sm.vhd
----------------------
  component bup2_general_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn            : in  std_logic; -- AHB reset line.
    hclk               : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- Generic BuP Registers
    -------------------------------------- 
    bup_sm_idle        : out std_logic; -- indicates that the state machines 
                                        -- are in idle mode
    -- Pulse to reset bcon_txenable.
    reset_bcon_txen    : out std_logic;
    -- Pulse to reset acp_txenable.
    reset_acp_txen     : out std_logic_vector(7 downto 0);
    -- Pulse to reset iac_txenable.
    reset_iac_txen     : out std_logic;
    -- queue that generated the it :
    --          1000 : IAC
    --          1001 : Beacon
    --   0000 - 0111 : ACP[0-7]
    queue_it_num       : in  std_logic_vector(3 downto 0);

    --------------------------------------
    -- Commands from BuP Registers
    -------------------------------------- 
    vcs_enable         : in  std_logic; -- Virtual carrier sense enable.
    tximmstop          : in  std_logic; -- Immediate stop
    
    --------------------------------------
    -- Modem test mode
    -------------------------------------- 
    testenable         : in  std_logic; -- enable BuP test mode
    bup_testmode       : in  std_logic_vector(1 downto 0); -- type of test
    --------------------------------------
    -- Interrupt Generator
    -------------------------------------- 
    ccabusy_it         : out std_logic; -- pulse for interrupt on CCA BUSY
    ccaidle_it         : out std_logic; -- pulse for interrupt on CCA IDLE
    --------------------------------------
    -- Timers
    -------------------------------------- 
    backoff_timer_it   : in  std_logic; -- interrupt when backoff reaches 0.
    sifs_timer_it      : in  std_logic; -- interrupt when sifs reaches 0.
    txstartdel_flag    : in  std_logic; -- Flag set when SIFS count reaches txstartdel.
    iac_without_ifs    : in  std_logic; -- flag set when no IFS in IAC queue
    --------------------------------------
    -- Modem
    -------------------------------------- 
    phy_cca_ind        : in  std_logic; -- CCA status from modems
                                        -- 0 => no signal detected 
                                        -- 1 => busy channel detected 
    phy_rxstartend_ind : in  std_logic; -- preamble detected 
    --------------------------------------
    -- RX/TX state machine
    -------------------------------------- 
    rxend_stat         : in  std_logic_vector(1 downto 0); -- RX end status.
    rx_end             : in  std_logic; -- end of packet and no auto resp needed
    rx_err             : in  std_logic; -- unexpected end of packet 
    tx_end             : in  std_logic; -- end of transmit packet
    iac_txenable       : in  std_logic;
    iacaftersifs_ack   : in  std_logic; -- IAC after SIFS sticky bit acknowledge
    --
    tx_mode            : out std_logic; -- Bup in transmit mode
    rx_mode            : out std_logic; -- Bup in reception mode
    rxv_macaddr_match  : out std_logic; -- Address1 match flag.
    rx_abortend        : out std_logic; -- End of packet or end of RX abort.
    iacaftersifs       : out std_logic;
    --------------------------------------
    -- Diag
    --------------------------------------
    gene_sm_diag       : out std_logic_vector(2 downto 0)

    );
  end component;


----------------------
-- File: bup2_tx_sm.vhd
----------------------
  component bup2_tx_sm
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
    enable_1mhz         : in  std_logic; -- Enable at 1 MHz.
    buptxptr            : in  std_logic_vector(31 downto 0); -- tx buffer ptr
    iacptr              : in  std_logic_vector(31 downto 0); -- IAC ctrl struct ptr

    txend_stat          : out std_logic_vector(1 downto 0); -- TX status.
    -- queue that generated the it :
    --          1000 : IAC
    --          1001 : Beacon
    --   0000 - 0111 : ACP[0-7]
    queue_it_num        : in  std_logic_vector(3 downto 0);
    sampled_queue_it_num: out std_logic_vector(3 downto 0);

    --------------------------------------
    -- Modem test mode
    -------------------------------------- 
    testenable          : in  std_logic; -- enable BuP test mode
    bup_testmode        : in  std_logic_vector(1 downto 0); -- selects the type of test
    datatype            : in  std_logic_vector(1 downto 0); -- selects the data pattern
    fcsdisb             : in  std_logic; -- disable FCS computation
    testdata            : in  std_logic_vector(31 downto 0); -- data test pattern
    --------------------------------------
    -- Memory Sequencer
    -------------------------------------- 
    mem_seq_ready       : in  std_logic; -- memory sequencer is ready (data valid)
    mem_seq_data        : in  std_logic_vector(7 downto 0); -- mem seq data
    --
    mem_seq_req         : out std_logic; -- request to mem seq for new byte
    mem_seq_txptr       : out std_logic_vector(31 downto 0);-- txptr for mem_seq
    last_word           : out std_logic; -- last word to be read when high
    load_txptr          : out std_logic; -- pulse for mem seq to load txptr
    -- access type for endianness converter.
    tx_acc_type         : out std_logic_vector(1 downto 0); 
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
    --------------------------------------
    -- Modem
    -------------------------------------- 
    phy_data_conf       : in  std_logic; -- last byte was read, ready for new one
    phy_txstartend_conf : in  std_logic; -- transmission started, ready for data
                                         -- or transmission ended
    --
    phy_data_req        : out std_logic; -- request to send a byte
    phy_txstartend_req  : out std_logic; -- request to start a packet transmission
                                         -- or request for end of transmission
    bup_txdata          : out std_logic_vector( 7 downto 0);-- data to Modem
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
    tximmstop_sm        : out std_logic; -- Immediate stop from the state machines
    ackto               : out std_logic_vector(8 downto 0); -- Time-out for ACK transmission
    ackto_en            : out std_logic; -- Enable ACK time-out generation
    --------------------------------------
    -- BuP general state machine
    -------------------------------------- 
    tx_mode             : in  std_logic; -- Bup in transmit mode
    --
    tx_start_it         : out std_logic; -- start of transmit packet
    tx_end_it           : out std_logic; -- end of transmit packet
    tx_packet_type      : out std_logic; -- 0 : modem b packet; 1 modem a packet
    --------------------------------------------
    -- Diag
    --------------------------------------------
    tx_sm_diag          : out std_logic_vector(2 downto 0);
    tx_read_sm_diag     : out std_logic_vector(1 downto 0)
    
  );
  end component;


----------------------
-- File: bup2_rx_sm.vhd
----------------------
  component bup2_rx_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn          : in  std_logic; -- AHB reset line.
    hclk             : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- BuP Registers
    -------------------------------------- 
    buprxptr         : in  std_logic_vector(31 downto 0); -- rx buffer ptr
    buprxoff         : in  std_logic_vector(15 downto 0); -- start address of
                                                           -- next packet
    buprxsize        : in  std_logic_vector(15 downto 0); -- size of ring buf
    buprxunload      : in  std_logic_vector(15 downto 0); -- rx unload ptr

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
    reg_rxrate       : out std_logic_vector( 3 downto 0); -- rxrate
    reg_rxrssi       : out std_logic_vector( 6 downto 0); -- rssi
    reg_rxccaaddinfo : out std_logic_vector( 7 downto 0); -- CCA additional information
    reg_rxant        : out std_logic; -- Antenna used for reception.
    reg_a1match      : out std_logic; -- high when received addr1 matches
 
    --------------------------------------
    -- Modem test mode
    -------------------------------------- 
    fcsdisb            : in  std_logic; -- disable FCS computation
    --------------------------------------
    -- Memory Sequencer
    -------------------------------------- 
    mem_seq_rx_mode    : out std_logic; -- Indicates a reception
    mem_seq_ind        : out std_logic; -- Indicates that new byte is ready
    data_to_mem_seq    : out std_logic_vector(7 downto 0); -- byte data 
                                                           --to Mem Seq
    last_word          : out std_logic; -- next bytes are part of last word
    mem_seq_rxptr      : out std_logic_vector(31 downto 0);-- rxptr for mem_seq
    load_rxptr         : out std_logic; -- pulse for mem seq to load rxptr
    ready_load         : in  std_logic;        -- ready 4 new load_ptr
    -- access type for endianness converter.
    rx_acc_type        : out std_logic_vector(1 downto 0); 
    --------------------------------------
    -- FCS generator
    -------------------------------------- 
    fcs_data_1st       : in  std_logic_vector(7 downto 0); -- First FCS data
    fcs_data_2nd       : in  std_logic_vector(7 downto 0); -- Second FCS data
    fcs_data_3rd       : in  std_logic_vector(7 downto 0); -- Third FCS data
    fcs_data_4th       : in  std_logic_vector(7 downto 0); -- Fourth FCS data
    --
    fcs_init           : out std_logic; -- init FCS computation
    fcs_data_valid     : out std_logic; -- compute FCS on mem seq data
    --------------------------------------
    -- Modem
    -------------------------------------- 
    phy_data_ind       : in  std_logic; -- received byte ready
    phy_rxstartend_ind : in  std_logic; -- end of received packet
    rxv_length         : in  std_logic_vector(11 downto 0);-- RX PSDU length
    bup_rxdata         : in  std_logic_vector( 7 downto 0);-- data from Modem
    rxe_errorstat      : in  std_logic_vector( 1 downto 0);-- packet reception 
                                                           -- status
    rxv_datarate       : in  std_logic_vector( 3 downto 0);-- RX PSDU rate
    rxv_service        : in  std_logic_vector(15 downto 0);-- RX SERVICE field
                                                           -- (802.11a only)
    -- RX SERVICE field available on rising edge
    rxv_service_ind    : in  std_logic;
    rxv_rssi           : in  std_logic_vector( 6 downto 0);-- preamble RSSI 
                                                           -- (802.11a only)
    rxv_ccaaddinfo     : in  std_logic_vector( 7 downto 0);
    rxv_rxant          : in  std_logic; -- Antenna used during reception.
    --------------------------------------
    -- BuP general state machine
    -------------------------------------- 
    rx_mode            : in  std_logic; -- Bup in reception mode
    --
    rx_end             : out std_logic; -- end of received packet
    rx_fullbuf         : out std_logic; -- rx buffer full detected when high
    bufempty           : in  std_logic; -- 1 when RX buffer emptied.
    rx_errstat         : out std_logic_vector(1 downto 0); -- error from modem
    rxend_stat         : out std_logic_vector(1 downto 0); -- RX status
    rx_fcs_err         : out std_logic; -- end of packet and FCS error detected
    rx_err             : out std_logic; -- unexpected end of packet 
    rx_packet_type     : out std_logic; -- 0 : modem b packet; 1 modem a packet
    -- diag
    rx_sm_diag         : out std_logic_vector(7 downto 0)
  );
  end component;



 
end bup2_sm_pkg;
