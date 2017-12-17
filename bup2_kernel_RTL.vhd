
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_kernel.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.47  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : WILD Burst Processor 2 kernel.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_kernel/vhdl/rtl/bup2_kernel.vhd,v  
--  Log: bup2_kernel.vhd,v  
-- Revision 1.47  2006/03/13 08:45:31  Dr.A
-- #BugId:2328#
-- Increased size of reg_clk32cntl to support 131.072 kHz config
--
-- Revision 1.46  2006/02/03 08:37:35  Dr.A
-- #BugId:1140#
-- Debug of IAC IFS
--
-- Revision 1.45  2006/02/02 15:37:51  Dr.A
-- #BugId:1204#
-- Use two clocks for BuP timers block (gated and not)
--
-- Revision 1.44  2006/02/02 08:28:55  Dr.A
-- #BugId:1213#
-- Added bit to ignore VCS for channel assessment
--
-- Revision 1.43  2005/10/21 13:29:02  Dr.A
-- #BugId:1246#
-- Added absolute count timers
--
-- Revision 1.42  2005/10/04 12:12:24  Dr.A
-- #BugId:1288#
-- Removed unused signals
--
-- Revision 1.41  2005/04/19 08:52:29  Dr.A
-- #BugId:938#
-- Updated diags
--
-- Revision 1.40  2005/04/19 07:59:08  Dr.A
-- #BugId:1181#
-- Connected ports for ackto enable
--
-- Revision 1.39  2005/03/29 08:45:08  Dr.A
-- #BugId:907#
-- Added TX force disable
--
-- Revision 1.38  2005/03/25 11:12:40  Dr.A
-- #BugId:1152#
-- Removed ARTIM counter
--
-- Revision 1.37  2005/03/22 10:16:34  Dr.A
-- #BugId:1152#
-- Connected arrival time counter enable. Cleaned write_bckoff ports.
--
-- Revision 1.36  2005/03/18 14:58:32  Dr.A
-- #BugId:938#
-- Changed some SW diags
--
-- Revision 1.35  2005/02/18 16:21:51  Dr.A
-- #BugId:1070#
-- Connected txstartdel_flag. Added iac_txenable to the diags.
--
-- Revision 1.34  2005/02/09 17:50:02  Dr.A
-- #BugId:974#
-- reset_bufempty now coming from memory sequencer.
--
-- Revision 1.33  2005/01/21 15:51:27  Dr.A
-- #BugId:964,978#
-- Connected registers and immediate stop control to BuP timers.
--
-- Revision 1.32  2005/01/13 14:03:16  Dr.A
-- #BugId:903#
-- New diag ports.
--
-- Revision 1.31  2005/01/10 13:15:20  Dr.A
-- #BugId:912#
-- Removed enable_bup
--
-- Revision 1.30  2004/12/20 17:02:14  Dr.A
-- #BugId:850#
-- Added IAC after SIFS mechanism.
--
-- Revision 1.29  2004/12/20 12:55:12  Dr.A
-- #BugId:702,822#
-- Connecte ACK time-out interrupt lines (702).
-- Connected txend_stat status line (822)
--
-- Revision 1.28  2004/12/17 13:04:08  Dr.A
-- #BugId:606,912#
-- New signal from RX FSM used as 'rx end' for timers (606)
-- Enable bit removed from registers (912)
--
-- Revision 1.27  2004/12/10 10:37:55  Dr.A
-- #BugId:606#
-- Connected RX abort and ack time-out registers
--
-- Revision 1.26  2004/12/06 09:14:15  Dr.A
-- #BugId:836#
-- Adress1 mask register connected to state machine
--
-- Revision 1.25  2004/12/03 14:18:12  Dr.A
-- #BugId:837#
-- Added channel assessment timers to bup2_timers port map and connected misc. registers to default values.
--
-- Revision 1.24  2004/12/02 10:29:32  Dr.A
-- #BugId:822#
-- Connect tx_immstop to state machines and output port.
--
-- Revision 1.23  2004/11/10 10:35:30  Dr.A
-- #BugId:837#
-- New registers for channel assessment and multi SSID
--
-- Revision 1.22  2004/11/09 14:13:48  Dr.A
-- #BugId:835#
-- New rxv_ and txv_ ports connected to state machines
--
-- Revision 1.21  2004/11/03 17:18:53  Dr.A
-- #BugId:820#
-- enable_1mhz input now synchronous to BuP clocks
--
-- Revision 1.20  2004/08/26 17:07:37  Dr.A
-- Removed mode32k in resync block.
--
-- Revision 1.19  2004/08/06 16:17:57  Dr.A
-- Do not used resync. mode32k
--
-- Revision 1.18  2004/08/05 16:15:05  Dr.A
-- Added mode32k resync. Moved resync to a separate block.
--
-- Revision 1.17  2004/07/21 16:34:53  Dr.A
-- Use ungated clock buptimer_clk for interrupt generator (Bugzilla # 677)
--
-- Revision 1.16  2004/07/20 07:52:05  Dr.A
-- enable_1mhz synchronized with buptimer_clk.
--
-- Revision 1.15  2004/05/18 10:50:28  Dr.A
-- Only one input port for phy_cca_ind, and resync removed.
--
-- Revision 1.14  2004/04/14 16:11:29  Dr.A
-- Removed unused signal last_word_size.
--
-- Revision 1.13  2004/02/26 18:13:23  Dr.F
-- resynchonized enable_1mhz.
--
-- Revision 1.12  2004/02/06 14:47:58  Dr.F
-- added buptestdin.
--
-- Revision 1.11  2004/02/06 13:55:28  pbressy
-- 8 acp queues
--
-- Revision 1.10  2004/02/05 18:29:27  Dr.F
-- removed modeselect.
--
-- Revision 1.9  2004/01/26 08:51:45  Dr.F
-- added ready_load.
--
-- Revision 1.8  2004/01/09 08:16:48  Dr.F
-- added gpo.
--
-- Revision 1.7  2004/01/06 15:10:51  pbressy
-- bugzilla 331 fix
--
-- Revision 1.6  2003/12/09 16:03:46  Dr.F
-- fixed acctype.
--
-- Revision 1.5  2003/12/05 09:11:34  Dr.F
-- changed paddr size and resynchronized some signals.
--
-- Revision 1.4  2003/12/05 08:36:13  pbressy
-- added connectivity for new bup register
--
-- Revision 1.3  2003/11/25 14:20:05  Dr.F
-- added prdata1.
--
-- Revision 1.2  2003/11/25 07:57:19  Dr.F
-- port map changed.
--
-- Revision 1.1  2003/11/19 16:33:01  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
--library bup2_kernel_rtl;
library work;
--use bup2_kernel_rtl.bup2_kernel_pkg.all;
use work.bup2_kernel_pkg.all;

--library mem2_seq_rtl;
library work;
--library bup2_registers_rtl;
library work;
--library bup2_intgen_rtl;
library work;
--library crc32_rtl;
library work;
--library bup2_sm_rtl;
library work;
--library master_interface_rtl;
library work;
--library bup2_timers_rtl;
library work;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity bup2_kernel is
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

end bup2_kernel;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of bup2_kernel is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal logic0               : std_logic;
 
  ------------------------------------------------------------------------------
  -- Registers.
  ------------------------------------------------------------------------------
  signal reg_forcetxdis         : std_logic; -- Disable all TX queues.
  signal reg_tximmstop          : std_logic; -- TX immediate stop.
  signal reg_enrxabort          : std_logic; -- High to enable RX abort.
  -- queue that generated the it :
  --          1000 : IAC
  --          1001 : Beacon
  --   0000 - 0111 : ACP[0-7]
  -- Set when IAC tx request arrived after the end of a SIFS period.
  signal iacaftersifs           : std_logic;
  signal reg_txqueue            : std_logic_vector( 3 downto 0);
  signal txqueue_from_timer     : std_logic_vector( 3 downto 0);
  signal reg_cntxtsel           : std_logic;
  signal reg_clk32sel           : std_logic_vector(1 downto 0);
  signal reg_txdstartdel        : std_logic_vector(2 downto 0);
  signal reg_rxoff              : std_logic_vector(15 downto 0);
  signal reg_rxsize             : std_logic_vector(15 downto 0);
  -- Backoff registers when read
  signal bcon_bkoff_timer       : std_logic_vector( 9 downto 0);
  signal acp7_bkoff_timer       : std_logic_vector( 9 downto 0);
  signal acp6_bkoff_timer       : std_logic_vector( 9 downto 0);
  signal acp5_bkoff_timer       : std_logic_vector( 9 downto 0);
  signal acp4_bkoff_timer       : std_logic_vector( 9 downto 0);
  signal acp3_bkoff_timer       : std_logic_vector( 9 downto 0);
  signal acp2_bkoff_timer       : std_logic_vector( 9 downto 0);
  signal acp1_bkoff_timer       : std_logic_vector( 9 downto 0);
  signal acp0_bkoff_timer       : std_logic_vector( 9 downto 0);
  -- Controls.
  signal write_bcon_bkoff       : std_logic;
  signal write_iac_bkoff        : std_logic;
  signal write_acp_bkoff        : std_logic_vector( 7 downto 0);
  signal reset_acp_txen         : std_logic_vector(7 downto 0);
  signal reset_iac_txen         : std_logic;
  signal reset_bcon_txen        : std_logic;
  -- Channel assessment timers
  signal reg_chassbsy           : std_logic_vector(25 downto 0);
  signal reset_chassbsy         : std_logic;
  signal reg_chasstim           : std_logic_vector(25 downto 0);
  signal reset_chasstim         : std_logic;
  signal reg_chassen            : std_logic;
  signal reg_ignvcs             : std_logic;
  -- ACK time-out
  -- Time-out for ACK transmission, in us.
  signal ackto                  : std_logic_vector(8 downto 0);
  signal ackto_en               : std_logic; -- Enable ACK time-out generation

  --------------------------------------------
  -- Signals for Memory Sequencer.
  --------------------------------------------
  -- AHB Master interface.
  signal hburst_o         : std_logic_vector( 2 downto 0); -- transfer type.
  signal busreq           : std_logic; -- bus request.
  signal unspeclength     : std_logic; -- stop incremental burst.
  signal inc_addr         : std_logic; -- increment address.
  signal valid_data       : std_logic; -- data is valid.
  signal decr_addr        : std_logic; -- decrement address.
  signal free             : std_logic; -- no transfer is actually proceeded.
  signal end_add          : std_logic; -- last address.
  signal end_data         : std_logic; -- last data.
  -- Registers.
  -- Start address of the receive buffer.
  signal reg_buprxptr     : std_logic_vector(31 downto 0);
  -- Start address of the transmit buffer.
  signal reg_buptxptr     : std_logic_vector(31 downto 0);


  ------------------------------------------------------------------------------
  -- Signals for Interrupts
  ------------------------------------------------------------------------------

  -- Interrupt lines.
  -------------------------------------------------------------------------
  signal sw_irq           : std_logic; -- Software interrupt.
  -- Pulse interrupt sent on buptime wrapping around.
  signal timewrap_it      : std_logic;
  -- Pulse interrupts sent when absolute counter time tag is reached.
  signal abscount_it      : std_logic_vector(num_abstimer_g-1 downto 0);
  -- Pulse interrupts sent by state machines.
  signal ccabusy_it       : std_logic; -- pulse for interrupt on CCA BUSY.
  signal ccaidle_it       : std_logic; -- pulse for interrupt on CCA IDLE.
  signal rxstart_it       : std_logic; -- pulse for interrupt on RX packet start
  signal txstart_it       : std_logic; -- pulse for interrupt on TX packet start
  signal rxend_it         : std_logic; -- pulse for interrupt on RX packet end.
  signal txend_it         : std_logic; -- pulse for interrupt on TX packet end.
  signal ackto_it         : std_logic; -- pulse for interrupt on ACK time-out.
  signal rx_abortend      : std_logic;  -- end of packet or end of abort

  -- Registers for Interrupt Generator.
  -------------------------------------------------------------------------
  -- BuPintstat register.
  -- Reception and transmission status. Bit set when:
  signal reg_fcserr_stat  : std_logic; -- FCS is incorrect.
  signal reg_fullbuf_stat : std_logic; -- Rx buffer full, packet truncated.
  signal reg_a1match_stat : std_logic; -- Address1 field matches BUPADDR1L/H.
  signal rx_errstat       : std_logic_vector( 1 downto 0);
  signal rxend_stat       : std_logic_vector( 1 downto 0);
  signal txend_stat       : std_logic_vector( 1 downto 0);
  -- Interrupt sources
  signal reg_genirq_src   : std_logic; -- Software interrupt.
  signal reg_timewrap_src : std_logic; -- Wrapping around of buptime.
  signal reg_ccabusy_src  : std_logic; -- Ccabusy.
  signal reg_ccaidle_src  : std_logic; -- Ccaidle.
  signal reg_rxstart_src  : std_logic; -- Rx packet start.
  signal reg_rxend_src    : std_logic; -- Rx packet end.
  signal reg_txend_src    : std_logic; -- Tx packet end.
  signal reg_txstartirq_src  : std_logic; -- Tx packet start.
  signal reg_txstartfiq_src  : std_logic; -- Tx packet start (fast interrupt).
  signal reg_ackto_src    : std_logic; -- ACK time-out (fast interrupt).
  -- Absolute count interrupt sources
  signal reg_abscntirq_src   : std_logic;
  signal reg_abscntfiq_src   : std_logic;
  signal reg_abscnt_src   : std_logic_vector(num_abstimer_g-1 downto 0);
  -- BuPinttime register.
  signal reg_inttime      : std_logic_vector(25 downto 0); -- Interrupt time tag
  -- BuPintack register: acknowledge of the following interrupts.
  signal reg_iacaftersifs_ack   : std_logic; -- IAC after SIFS sticky bit.
  signal reg_genirq_ack   : std_logic; -- Software interrupt.
  signal reg_timewrap_ack : std_logic; -- Wrapping around of buptime.
  signal reg_ccabusy_ack  : std_logic; -- Ccabusy.
  signal reg_ccaidle_ack  : std_logic; -- Ccaidle.
  signal reg_rxstart_ack  : std_logic; -- Rx packet start.
  signal reg_rxend_ack    : std_logic; -- Rx packet end.
  signal reg_txend_ack    : std_logic; -- Tx packet end.
  signal reg_txstartirq_ack  : std_logic; -- Tx packet start.
  signal reg_txstartfiq_ack  : std_logic; -- Tx packet start (fast interrupt).
  signal reg_ackto_ack    : std_logic; -- ACK time-out (fast interrupt).
  -- BuPintack register: acknowledge of the absolue count interrupts.
  signal reg_abscnt_ack   : std_logic_vector(num_abstimer_g-1 downto 0);
  -- BuPintmask register: enable/disable interrupts on the following events.
  signal reg_timewrap_en  : std_logic; -- Wrapping around of buptime.
  signal reg_ccabusy_en   : std_logic; -- Ccabusy.
  signal reg_ccaidle_en   : std_logic; -- Ccaidle.
  signal reg_rxstart_en   : std_logic; -- Rx packet start.
  signal reg_rxend_en     : std_logic; -- Rx packet end.
  signal reg_txend_en     : std_logic; -- Tx packet end.
  signal reg_txstartirq_en   : std_logic; -- Tx packet start.
  signal reg_txstartfiq_en   : std_logic; -- Tx packet start (fast interrupt).
  signal reg_ackto_en     : std_logic; -- ACK time-out status.
  -- BuPintmask register: enable/disable interrupts on absolute count.
  signal reg_abscnt_en    : std_logic_vector(num_abstimer_g-1 downto 0);

  ------------------------------------------------------------------------------
  -- Signals for BuP Timers
  ------------------------------------------------------------------------------
  -- BuPtime register written by software.
  signal reg_buptimer     : std_logic_vector(25 downto 0);
  signal write_buptimer   : std_logic; -- Update buptimer.
  signal write_buptimer_done  : std_logic; -- Update done.
  -- BuPtime register when read
  signal bup_timer        : std_logic_vector(25 downto 0);
  -- Beacon control.
  signal bcon_bakenable   : std_logic;
  signal bcon_txenable    : std_logic;
  signal bcon_ifs         : std_logic_vector( 3 downto 0);
  signal bcon_backoff     : std_logic_vector( 9 downto 0);
  -- ACP control.
  signal acp_bakenable7   : std_logic;
  signal acp_txenable7    : std_logic;
  signal acp_ifs7         : std_logic_vector( 3 downto 0);
  signal acp_backoff7     : std_logic_vector( 9 downto 0);
  signal acp_bakenable6   : std_logic;
  signal acp_txenable6    : std_logic;
  signal acp_ifs6         : std_logic_vector( 3 downto 0);
  signal acp_backoff6     : std_logic_vector( 9 downto 0);
  signal acp_bakenable5   : std_logic;
  signal acp_txenable5    : std_logic;
  signal acp_ifs5         : std_logic_vector( 3 downto 0);
  signal acp_backoff5     : std_logic_vector( 9 downto 0);
  signal acp_bakenable4   : std_logic;
  signal acp_txenable4    : std_logic;
  signal acp_ifs4         : std_logic_vector( 3 downto 0);
  signal acp_backoff4     : std_logic_vector( 9 downto 0);
  signal acp_bakenable3   : std_logic;
  signal acp_txenable3    : std_logic;
  signal acp_ifs3         : std_logic_vector( 3 downto 0);
  signal acp_backoff3     : std_logic_vector( 9 downto 0);
  signal acp_bakenable2   : std_logic;
  signal acp_txenable2    : std_logic;
  signal acp_ifs2         : std_logic_vector( 3 downto 0);
  signal acp_backoff2     : std_logic_vector( 9 downto 0);
  signal acp_bakenable1   : std_logic;
  signal acp_txenable1    : std_logic;
  signal acp_ifs1         : std_logic_vector( 3 downto 0);
  signal acp_backoff1     : std_logic_vector( 9 downto 0);
  signal acp_bakenable0   : std_logic;
  signal acp_txenable0    : std_logic;
  signal acp_ifs0         : std_logic_vector( 3 downto 0);
  signal acp_backoff0     : std_logic_vector( 9 downto 0);
  -- IAC register. 
  signal iac_txenable     : std_logic;
  signal iac_ifs          : std_logic_vector( 3 downto 0);
  -- BuPvcs register.
  signal reg_vcsenable    : std_logic;
  signal reg_vcs          : std_logic_vector(25 downto 0);
  -- BuPcount register (Durations expressed in us).
  signal reg_macslot      : std_logic_vector(7 downto 0); -- MAC slots. 
  -- sifs periods after modem b packet           
  signal reg_txsifsb      : std_logic_vector(5 downto 0); -- SIFS period after TX.
  signal reg_rxsifsb      : std_logic_vector(5 downto 0); -- SIFS period after RX.
  -- sifs periods after modem a packet           
  signal reg_txsifsa      : std_logic_vector(5 downto 0); -- SIFS period after TX.
  signal reg_rxsifsa      : std_logic_vector(5 downto 0); -- SIFS period after RX.
  signal reg_sifs         : std_logic_vector(5 downto 0); -- SIFS after CCAidle.
  -- BuPabscnt registers.
  signal reg_abstime0     : std_logic_vector(25 downto 0);
  signal reg_abstime1     : std_logic_vector(25 downto 0);
  signal reg_abstime2     : std_logic_vector(25 downto 0);
  signal reg_abstime3     : std_logic_vector(25 downto 0);
  signal reg_abstime4     : std_logic_vector(25 downto 0);
  signal reg_abstime5     : std_logic_vector(25 downto 0);
  signal reg_abstime6     : std_logic_vector(25 downto 0);
  signal reg_abstime7     : std_logic_vector(25 downto 0);
  signal reg_abstime8     : std_logic_vector(25 downto 0);
  signal reg_abstime9     : std_logic_vector(25 downto 0);
  signal reg_abstime10    : std_logic_vector(25 downto 0);
  signal reg_abstime11    : std_logic_vector(25 downto 0);
  signal reg_abstime12    : std_logic_vector(25 downto 0);
  signal reg_abstime13    : std_logic_vector(25 downto 0);
  signal reg_abstime14    : std_logic_vector(25 downto 0);
  signal reg_abstime15    : std_logic_vector(25 downto 0);
  signal reg_abscnt_irqsel: std_logic_vector(num_abstimer_g-1 downto 0);
  signal reset_vcs        : std_logic;
  
  signal rx_packet_type   : std_logic;
  signal tx_packet_type   : std_logic;
  signal tximmstop_sm     : std_logic;
  
  ------------------------------------------------------------------------------
  -- Signals for State Machines
  ------------------------------------------------------------------------------
  -- Timers interface
  signal bup_sm_idle      : std_logic; -- State machines idle. 
  signal sifs_timer_it    : std_logic; -- interrupt when SIFS reaches 0.
  signal backoff_timer_it : std_logic; -- interrupt when backoff reaches 0.
  signal txstartdel_flag  : std_logic; -- flag set when SIFS count reaches txstartdel
  signal iac_without_ifs  : std_logic; -- flag set when no IFS in IAC queue
  -- Memory Sequencer interface
  signal mem_seq_ready    : std_logic; -- Data is valid.
  signal mem_seq_data     : std_logic_vector(7 downto 0); -- Data to transmit.
  signal mem_seq_req      : std_logic; -- Request for new byte.
  signal mem_seq_ind      : std_logic; -- new byte is ready.  
  signal data_to_mem_seq  : std_logic_vector(7 downto 0); -- Byte received.
  signal mem_seq_rx_mode  : std_logic; -- Transmission. 
  signal mem_seq_tx_mode  : std_logic; -- Reception. 
  signal last_word        : std_logic; -- Last bytes. 
  signal mem_seq_rxptr    : std_logic_vector(31 downto 0);-- rxptr for mem_seq
  signal mem_seq_txptr    : std_logic_vector(31 downto 0);-- rxptr for mem_seq
  signal load_ptr         : std_logic;                 -- pulse to load new ptr 
  signal ready_load       : std_logic;                 -- ready 4 new load_ptr
  -- CRC interface
  signal fcs_data_1st     : std_logic_vector(7 downto 0); -- First FCS data.
  signal fcs_data_2nd     : std_logic_vector(7 downto 0); -- Second FCS data.
  signal fcs_data_3rd     : std_logic_vector(7 downto 0); -- Third FCS data.
  signal fcs_data_4th     : std_logic_vector(7 downto 0); -- Fourth FCS data.
  signal fcs_init         : std_logic; -- Init FCS computation.
  signal fcs_data_valid   : std_logic; -- Compute FCS on mem seq data.
  signal data_to_fcs      : std_logic_vector(7 downto 0); -- Byte data to FCS.
  -- Registers for state machines
  signal reg_testenable   : std_logic; -- '1' for test mode.
  signal reg_datatype     : std_logic_vector(1 downto 0); -- Select test pattern
  signal reg_fcsdisb      : std_logic; -- '0' to enable FCS computation.
  signal reg_buptestmode  : std_logic_vector( 1 downto 0); -- Select test type.
  signal reg_testpattern  : std_logic_vector(31 downto 0); -- Tx test pattern.
  signal reg_bufempty     : std_logic;
  signal reg_rxunload     : std_logic_vector(15 downto 0);
  signal reg_iacptr       : std_logic_vector(31 downto 0);
  signal reg_addr1        : std_logic_vector(47 downto 0);
  signal reg_addr1mskh    : std_logic_vector( 3 downto 0); -- Mask Address1(43:40)
  signal reg_addr1mskl    : std_logic_vector( 3 downto 0); -- Mask Address1(27:24)
  signal reg_durid        : std_logic_vector(15 downto 0);
  signal reg_frmcntl      : std_logic_vector(15 downto 0);
  signal reset_bufempty   : std_logic;
  -- Buprxabtcnt register.
  signal reg_rxabtcnt     : std_logic_vector( 5 downto 0);
  -- Bup rx cs0
  signal reg_rxserv       : std_logic_vector(15 downto 0); -- service field of packet
  signal reg_rxlen        : std_logic_vector(11 downto 0); -- length of PSDU received
  -- Bup rx cs1
  signal reg_rxrate       : std_logic_vector(3 downto 0);  -- rate setting of received
                                                           -- packet
  signal reg_rxrssi       : std_logic_vector(6 downto 0);  -- radio signal strength of
                                                           -- received packet
  signal reg_rxccaaddinfo : std_logic_vector( 7 downto 0); -- CCA additional information
  signal reg_rxant        : std_logic; -- Antenna used for reception.

  ------------------------------------------------------------------------------
  -- Signals for Master interface
  ------------------------------------------------------------------------------
  signal buserror         : std_logic; 
  signal grant_lost       : std_logic; 

  ------------------------------------------------------------------------------
  -- Signals for output ports used internally
  ------------------------------------------------------------------------------
  signal phy_txstartend_req_o  : std_logic;
  signal phy_data_req_o        : std_logic;
  signal bup_fiq_o             : std_logic;
  signal rxv_macaddr_match_o   : std_logic;
  signal bup_txdata_o          : std_logic_vector( 7 downto 0);
  signal txv_datarate_o        : std_logic_vector( 3 downto 0); -- TX PSDU rate.

  ------------------------------------------------------------------------------
  -- Signals for diagnostic port
  ------------------------------------------------------------------------------
  signal bup_sm_diag           : std_logic_vector(17 downto 0);
  signal bup_data_diag         : std_logic_vector( 7 downto 0);
  signal bup_timers_diag       : std_logic_vector( 7 downto 0);
  signal txstart_diag          : std_logic;
  signal rate_diag             : std_logic_vector( 3 downto 0);
  
 
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------

begin
  
  
  -- Constant signal.
  logic0 <= '0';
    
  -- Assign output ports.
  hburst             <= hburst_o;  
  phy_txstartend_req <= phy_txstartend_req_o;
  phy_data_req       <= phy_data_req_o;
  bup_fiq            <= bup_fiq_o;
  bup_txdata         <= bup_txdata_o;
  gpo                <= reg_testpattern;
  txv_immstop        <= reg_tximmstop;
  rxv_macaddr_match  <= rxv_macaddr_match_o;
  txv_datarate       <= txv_datarate_o;
  
  --------------------------------------------
  -- diag signals
  --------------------------------------------
  txstart_diag  <= reg_txstartirq_src or reg_txstartfiq_src;
  bup_data_diag <= bup_rxdata   when phy_rxstartend_ind = '1' else bup_txdata_o;
  rate_diag     <= rxv_datarate when phy_rxstartend_ind = '1' else txv_datarate_o;
  
  -- tx
  bup_diag0 <= phy_txstartend_req_o &         -- 15
               phy_txstartend_conf &          -- 14
               phy_data_req_o &               -- 13
               phy_data_conf &                -- 12
               iac_txenable &                 -- 11
               iacaftersifs &                 -- 10
               bup_timers_diag( 7 downto 3) & --  9:5
               bup_sm_diag(10 downto 6);      --  4:0

  -- rx
  bup_diag1 <= bup_fiq_o &                    -- 15
               phy_cca_ind &                  -- 14
               phy_rxstartend_ind &           -- 13
               phy_data_ind &                 -- 12
               reg_fcserr_stat &              -- 11
               rxv_macaddr_match_o &          -- 10
               bup_sm_diag(13 downto 11) &    --  9:7
               bup_sm_diag( 5 downto 0) &     --  6:1
               busreq;                        --  0
               
  -- sm
  bup_diag2 <= rate_diag &                    -- 15:12
               bup_sm_diag(17 downto 11) &    -- 11:3
               bup_sm_diag(8 downto 4);       --  4:0

  -- SW diag: useful interrupts + TX and RX data, muxed using phy_rxstartend_ind
  bup_diag3 <= bup_fiq_o &                    -- 15
               txstart_diag &                 -- 14
               bup_timers_diag(4) &           -- 13 (ackto_timer_on)
               reg_tximmstop &                -- 12
               reg_rxend_src &                -- 11
               phy_cca_ind &                  -- 10
               reg_forcetxdis &               --  9
               phy_rxstartend_ind &           --  8
               bup_data_diag;                 --  7:0

  --------------------------------------------
  -- Master AHB Interface.
  --------------------------------------------
  master_interface_1: master_interface
  generic map (                 -- indicates if the master is allowed 
    burstlinkcapable_g => 0,    -- to make consecutive accesses on bus.
                                -- 0 means not capable.
    gotoaddr_g         => 1     -- choose the transition for incrementing bursts
  )
  port map(
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hclk            =>  hclk,         -- AHB clock.
    hreset_n        =>  reset_n,      -- Reset.
    
    --------------------------------------
    -- Memory Sequencer Interface
    --------------------------------------
    burst           =>  hburst_o,     -- type of transfer.
    busreq          =>  busreq,       -- bus request.
    unspeclength    =>  unspeclength, -- end of a burst with unspecified length
    busy            =>  logic0,       -- master busy.
    --
    buserror        =>  buserror,     -- error on the bus.
    inc_addr        =>  inc_addr,     -- increment address.
    valid_data      =>  valid_data,   -- the data is valid on the bus.
    decr_addr       =>  decr_addr,    -- decrement address.
    grant_lost      =>  grant_lost,   -- master lost bus ownership.
    free            =>  free,         -- no transfer is actually proceeded.
    end_add         =>  end_add,      -- last address of the transfer.
    end_data        =>  end_data,     -- last data of the transfer.
   
    --------------------------------------
    -- AHB control signals
    --------------------------------------
    hready          => hready,        -- Ready (Active LOW).
    hresp           => hresp,         -- Transfer status.
    hgrant          => hgrant,        -- Bus grant.
    --
    htrans          => htrans,        -- Transfer type.
    hbusreq         => hbusreq        -- Bus request.
  );

  
  --------------------------------------------
  -- Memory Sequencer.
  --------------------------------------------
  mem2_seq_1 : mem2_seq
  port map (
    --------------------------------------------
    -- Clock & reset
    --------------------------------------------
    hclk                => hclk,               -- AHB clock.
    hreset_n            => reset_n,            -- AHB reset.
    
    --------------------------------------------
    -- Bup Registers
    --------------------------------------------
    buprxptr            => mem_seq_rxptr,      -- receive buffer address.
    buptxptr            => mem_seq_txptr,      -- transmit buffer address.
    load_ptr            => load_ptr,           -- pulse to load new pointer
    reset_bufempty      => reset_bufempty,     -- reset bufempty on packet reception
    
    --------------------------------------------
    -- Bup State Machine
    --------------------------------------------
    req                 => mem_seq_req,        -- request for new byte.
    ind                 => mem_seq_ind,        -- new byte is ready.
    data_rec            => data_to_mem_seq,    -- byte received.
    last_word           => last_word,          -- last bytes.
    tx                  => mem_seq_tx_mode,    -- reception.
    rx                  => mem_seq_rx_mode,    -- transmission.
    ready               => mem_seq_ready,      -- data is valid.
    trans_data          => mem_seq_data,       -- data to transmit.
    ready_load          => ready_load,
                                                
    --------------------------------------------
    -- AHB Master Interface
    --------------------------------------------
    inc_addr            => inc_addr,           -- increment address.
    valid_data          => valid_data,         -- data is valid.
    decr_addr           => decr_addr,          -- decrement address.
    end_add             => end_add,            -- last address.
    end_data            => end_data,           -- last data.
    free                => free,               -- no transfer.
    busreq              => busreq,             -- bus request.
    unspeclength        => unspeclength,       -- stop incremental burst.

    --------------------------------------------
    -- AHB bus
    --------------------------------------------
    hrdata              => hrdata,             -- AHB read data.
    hlock               => hlock,              -- bus lock.
    hwrite              => hwrite,             -- type of transaction.
    hsize               => hsize,              -- transfer size.
    hburst              => hburst_o,           -- burst type.
    hprot               => hprot,              -- protection.
    haddr               => haddr,              -- AHB address.
    hwdata              => hwdata              -- AHB write data.
  );

  
  --------------------------------------------
  -- Registers.
  --------------------------------------------  
  bup2_registers_1 : bup2_registers
  generic map (
    num_queues_g   => num_queues_g,
    num_abstimer_g => num_abstimer_g
    )
  port map (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n                => reset_n,         -- Reset.
    pclk                   => hclk,            -- APB clock.
 
    --------------------------------------------
    -- APB slave 0
    --------------------------------------------
    apb0_psel                   => psel0,           -- Device select.
    apb0_penable                => penable0,        -- Defines the enable cycle.
    apb0_paddr                  => paddr0,          -- Address.
    apb0_pwrite                 => pwrite0,         -- Write signal.
    apb0_pwdata                 => pwdata0,         -- Write data.
    --
    apb0_prdata                 => prdata0,          -- Read data.
    
    --------------------------------------------
    -- APB slave 1
    --------------------------------------------
    apb1_psel                   => psel1,           -- Device select.
    apb1_penable                => penable1,        -- Defines the enable cycle.
    apb1_paddr                  => paddr1,          -- Address.
    apb1_pwrite                 => pwrite1,         -- Write signal.
    apb1_pwdata                 => pwdata1,         -- Write data.
    --
    apb1_prdata                 => prdata1,          -- Read data.
  

    --------------------------------------------
    -- BuP registers inputs
    --------------------------------------------
    -- BuPtime register when read
    bup_timer              => bup_timer,
    -- BuPintstat register.
    -- Reception and transmission status. Bit set when:
    reg_iacaftersifs       => iacaftersifs,      -- Set when IAC tx request arrived after SIFS
    reg_txqueue            => reg_txqueue,
    reg_fcserr_stat        => reg_fcserr_stat,   -- FCS is incorrect.
    reg_fullbuf_stat       => reg_fullbuf_stat,  -- Rx buffer full, packet truncated.
    reg_a1match_stat       => reg_a1match_stat,  -- Address1 field matches BUPADDR1L/H reg
    reg_errstat            => rx_errstat,        -- Reception status.
    reg_rxendstat          => rxend_stat,        -- RX reception status.
    reg_txendstat          => txend_stat,        -- TX reception status.
    -- Interrupt sources
    reg_genirq_src         => reg_genirq_src,    -- Software interrupt.
    reg_timewrap_src       => reg_timewrap_src,  -- Wrapping around of buptime.
    reg_ccabusy_src        => reg_ccabusy_src,   -- Ccabusy.
    reg_ccaidle_src        => reg_ccaidle_src,   -- Ccaidle.
    reg_rxstart_src        => reg_rxstart_src,   -- Rx packet start.
    reg_rxend_src          => reg_rxend_src,     -- Rx packet end.
    reg_txend_src          => reg_txend_src,     -- Tx packet end.
    reg_txstartirq_src     => reg_txstartirq_src,-- Tx packet start.
    reg_txstartfiq_src     => reg_txstartfiq_src,-- Tx packet start.
    reg_ackto_src          => reg_ackto_src,     -- ACK packet time-out.
    -- Absolute count interrupt sources
    reg_abscntirq_src      => reg_abscntirq_src,  
    reg_abscntfiq_src      => reg_abscntfiq_src,  
    reg_abscnt_src         => reg_abscnt_src,  
    -- BuPinttime register.
    reg_inttime            => reg_inttime,        -- Interrupt time tag.
    -- Backoff registers when read.
    bcon_bkoff_timer       => bcon_bkoff_timer,
    acp7_bkoff_timer       => acp7_bkoff_timer,
    acp6_bkoff_timer       => acp6_bkoff_timer,
    acp5_bkoff_timer       => acp5_bkoff_timer,
    acp4_bkoff_timer       => acp4_bkoff_timer,
    acp3_bkoff_timer       => acp3_bkoff_timer,
    acp2_bkoff_timer       => acp2_bkoff_timer,
    acp1_bkoff_timer       => acp1_bkoff_timer,
    acp0_bkoff_timer       => acp0_bkoff_timer,
    -- BuPmachdr register: values from the received MAC header.
    reg_durid              => reg_durid,
    reg_frmcntl            => reg_frmcntl,
    -- BuPTestdata register written (receive mode).
    -- Transparent receive test mode: data from reception test.
    testdata_in            => buptestdin,

    --------------------------------------------
    -- BuP Registers outputs
    --------------------------------------------
    -- BuPcntl register.
    reg_forcetxdis         => reg_forcetxdis,  -- Disable all TX queues.
    reg_tximmstop          => reg_tximmstop,   -- TX immediate stop.
    reg_enrxabort          => reg_enrxabort,   -- High to enable RX abort.
    reg_ccarst             => phy_ccarst_req,  -- Reset the CCA state machines.
    reg_bufempty           => reg_bufempty,    -- 1 when RX buffer emptied.
    genirq                 => sw_irq,          -- Software interrupt (pulse).
    reg_cntxtsel           => reg_cntxtsel,    -- Select context.
    reg_clk32sel           => reg_clk32sel,
    -- BuPvcs register.
    reg_vcsenable          => reg_vcsenable,   -- Virtual carrier sense enable.
    reg_vcs                => reg_vcs,         -- VCS time tag.
    -- BuPtime register written by software.
    reg_buptimer           => reg_buptimer,    -- Time counter.
    -- BuPabscnt registers: Time tag to generate an interrupt
    reg_abstime0           => reg_abstime0,
    reg_abstime1           => reg_abstime1,
    reg_abstime2           => reg_abstime2,
    reg_abstime3           => reg_abstime3,
    reg_abstime4           => reg_abstime4,
    reg_abstime5           => reg_abstime5,
    reg_abstime6           => reg_abstime6,
    reg_abstime7           => reg_abstime7,
    reg_abstime8           => reg_abstime8,
    reg_abstime9           => reg_abstime9,
    reg_abstime10          => reg_abstime10,
    reg_abstime11          => reg_abstime11,
    reg_abstime12          => reg_abstime12,
    reg_abstime13          => reg_abstime13,
    reg_abstime14          => reg_abstime14,
    reg_abstime15          => reg_abstime15,
    -- IRQ/FIQ select for absolute counter interrupts
    reg_abscnt_irqsel      => reg_abscnt_irqsel,
    -- BuPintmask register: enable/disable interrupts on the following events:
    reg_timewrap_en        => reg_timewrap_en, -- Wrapping around of buptime.
    reg_ccabusy_en         => reg_ccabusy_en,  -- Ccabusy.
    reg_ccaidle_en         => reg_ccaidle_en,  -- Ccaidle.
    reg_rxstart_en         => reg_rxstart_en,  -- Rx packet start.
    reg_rxend_en           => reg_rxend_en,    -- Rx packet end.
    reg_txend_en           => reg_txend_en,    -- Tx packet end.
    reg_txstartirq_en      => reg_txstartirq_en,  -- Tx packet start.
    reg_txstartfiq_en      => reg_txstartfiq_en,  -- Tx packet start.
    reg_ackto_en           => reg_ackto_en,    -- ACK packet time-out.
    -- BuPAbscntintmask register: enable/disable interrupts on absolute count
    reg_abscnt_en          => reg_abscnt_en,        
    -- BuPintack register: acknowledge of the following interrupts
    reg_iacaftersifs_ack   => reg_iacaftersifs_ack,  -- IAC after SIFS.
    reg_genirq_ack         => reg_genirq_ack,  -- Software interrupt.
    reg_timewrap_ack       => reg_timewrap_ack,-- Wrapping around of buptime.
    reg_ccabusy_ack        => reg_ccabusy_ack, -- Ccabusy.
    reg_ccaidle_ack        => reg_ccaidle_ack, -- Ccaidle.
    reg_rxstart_ack        => reg_rxstart_ack, -- Rx packet start.
    reg_rxend_ack          => reg_rxend_ack,   -- Rx packet end.
    reg_txend_ack          => reg_txend_ack,   -- Tx packet end.
    reg_txstartirq_ack     => reg_txstartirq_ack, -- Tx packet start.
    reg_txstartfiq_ack     => reg_txstartfiq_ack, -- Tx packet start.
    reg_ackto_ack          => reg_ackto_ack,      -- ACK packet time-out.
    -- BuPAbscntintack register: acknowledge of the absolute count interrupts
    reg_abscnt_ack         => reg_abscnt_ack,   
    -- BuPcount register (Durations expressed in us).
    reg_txdstartdel        => reg_txdstartdel,
    reg_macslot            => reg_macslot,     -- MAC slots.
    reg_txsifsb            => reg_txsifsb,     -- SIFS period after TX.
    reg_rxsifsb            => reg_rxsifsb,     -- SIFS period after RX.
    reg_txsifsa            => reg_txsifsa,     -- SIFS period after TX.
    reg_rxsifsa            => reg_rxsifsa,     -- SIFS period after RX.
    reg_sifs               => reg_sifs,        -- SIFS after CCAidle or
                                               -- absolute count events
    -- BuPtxptr register: Start address of the transmit buffer.
    reg_buptxptr           => reg_buptxptr,
    -- Beacon control register.
    reg_bcon_bakenable     => bcon_bakenable,  -- '1' to enable backoff counter.
    reg_bcon_txenable      => bcon_txenable,   -- '1' to enable packets TX.
    reg_bcon_ifs           => bcon_ifs,        -- MAC slots nb for inter-frame.
    reg_bcon_backoff       => bcon_backoff,    -- Backoff counter init value.
    -- ACP control registers.
    reg_acp_bakenable7     => acp_bakenable7,
    reg_acp_txenable7      => acp_txenable7,
    reg_acp_ifs7           => acp_ifs7,
    reg_acp_backoff7       => acp_backoff7,
    reg_acp_bakenable6     => acp_bakenable6,
    reg_acp_txenable6      => acp_txenable6,
    reg_acp_ifs6           => acp_ifs6,
    reg_acp_backoff6       => acp_backoff6,
    reg_acp_bakenable5     => acp_bakenable5,
    reg_acp_txenable5      => acp_txenable5,
    reg_acp_ifs5           => acp_ifs5,
    reg_acp_backoff5       => acp_backoff5,
    reg_acp_bakenable4     => acp_bakenable4,
    reg_acp_txenable4      => acp_txenable4,
    reg_acp_ifs4           => acp_ifs4,
    reg_acp_backoff4       => acp_backoff4,
    reg_acp_bakenable3     => acp_bakenable3,
    reg_acp_txenable3      => acp_txenable3,
    reg_acp_ifs3           => acp_ifs3,
    reg_acp_backoff3       => acp_backoff3,
    reg_acp_bakenable2     => acp_bakenable2,
    reg_acp_txenable2      => acp_txenable2,
    reg_acp_ifs2           => acp_ifs2,
    reg_acp_backoff2       => acp_backoff2,
    reg_acp_bakenable1     => acp_bakenable1,
    reg_acp_txenable1      => acp_txenable1,
    reg_acp_ifs1           => acp_ifs1,
    reg_acp_backoff1       => acp_backoff1,
    reg_acp_bakenable0     => acp_bakenable0,
    reg_acp_txenable0      => acp_txenable0,
    reg_acp_ifs0           => acp_ifs0,
    reg_acp_backoff0       => acp_backoff0,
    -- IAC control registers.
    reg_iac_txenable       => iac_txenable,
    reg_iac_ifs            => iac_ifs,
    -- BuPrxptr register: Start address of the receive buffer.
    reg_buprxptr           => reg_buprxptr,
    -- BuPrxoff register: Start address of the next packet to be stored inside
    -- the RX ring buffer.
    reg_rxoff              => reg_rxoff,
    -- BuPrxsize register: size in bytes of theRx ring buffer.
    reg_rxsize             => reg_rxsize,
    -- BuPrxunload register: pointer to the next packet to be retreived from 
    reg_rxunload           => reg_rxunload,
    -- Bupaddr1l/h registers.
    reg_addr1              => reg_addr1,
    -- Bupaddr1mask register.
    reg_addr1mskh          => reg_addr1mskh,
    reg_addr1mskl          => reg_addr1mskl,
    -- BuPTest register.
    reg_testenable         => reg_testenable,  -- '1' for test mode.
    reg_datatype           => reg_datatype,    -- Select test pattern.
    reg_fcsdisb            => reg_fcsdisb,     -- '0' to enable FCS computation.
    reg_buptestmode        => reg_buptestmode, -- Select test type.
    reg_testpattern        => reg_testpattern, -- Tx test pattern.
    -- Buprxabtcnt register.
    reg_rxabtcnt           => reg_rxabtcnt,    -- RX abort counter
     
    --------------------------------------------
    -- Timers Control
    --------------------------------------------
    -- BuP Timer
    write_buptimer         => write_buptimer,      -- Update buptimer.
    write_buptimer_done    => write_buptimer_done, -- Update done.
    -- Beacon Backoff Timer.
    write_bcon_bkoff       => write_bcon_bkoff,
    -- IAC IFS Timer.
    write_iac_bkoff        => write_iac_bkoff,
    -- ACP Backoff Timers.
    write_acp_bkoff        => write_acp_bkoff,
    -- Channel assessment timers.
    reg_chassbsy           => reg_chassbsy,
    reset_chassbsy         => reset_chassbsy,
    reg_chasstim           => reg_chasstim,
    reset_chasstim         => reset_chasstim,
    reg_chassen            => reg_chassen,
    reg_ignvcs             => reg_ignvcs,
    
    --------------------------------------------
    -- Misc. control.
    --------------------------------------------
    phy_ccarst_conf        => phy_ccarst_conf,     -- End of CCA reset.
    reset_bufempty         => reset_bufempty,      -- New packet in RX buffer.
    -- Pulse to reset acp_txenable.
    reset_acp_txen         => reset_acp_txen,
    -- Pulse to reset bcon_txenable.
    reset_bcon_txen        => reset_bcon_txen,
    -- Pulse to reset iac_txenable.
    reset_iac_txen         => reset_iac_txen,
    reset_vcs              => reset_vcs,

    --------------------------------------------
    -- Bup2 add on.
    --------------------------------------------
    reg_csiac_ptr          => reg_iacptr,
    rxserv                 => reg_rxserv,
    rxlen                  => reg_rxlen,
    rxccaaddinfo           => reg_rxccaaddinfo,
    rxrate                 => reg_rxrate,
    rxant                  => reg_rxant,
    rxrssi                 => reg_rxrssi
    
  );


  --------------------------------------------
  -- Interrupt Generator.
  --------------------------------------------
  bup2_intgen_1 : bup2_intgen
  generic map (
    num_abstimer_g => num_abstimer_g
    )
  port map (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n             => reset_n,            -- Reset.
    clk                 => buptimer_clk,       -- Not gated clock.

    --------------------------------------------
    -- BuP registers inputs
    --------------------------------------------
    -- BuPtime register.
    reg_buptime         => bup_timer,           -- BuP timer.
    -- BuPintack register: acknowledge of the following interrupts
    reg_genirq_ack       => reg_genirq_ack,     -- Select FIQ/IRQ generation on RxEnd.
    reg_timewrap_ack     => reg_timewrap_ack,   -- Wrapping around of buptime.
    reg_ccabusy_ack      => reg_ccabusy_ack,    -- Ccabusy.
    reg_ccaidle_ack      => reg_ccaidle_ack,    -- Ccaidle.
    reg_rxstart_ack      => reg_rxstart_ack,    -- Rx packet start.
    reg_rxend_ack        => reg_rxend_ack,      -- Rx packet end.
    reg_txend_ack        => reg_txend_ack,      -- Tx packet end.
    reg_txstartirq_ack   => reg_txstartirq_ack, -- Tx packet start.
    reg_txstartfiq_ack   => reg_txstartfiq_ack, -- Tx packet start.
    reg_ackto_ack        => reg_ackto_ack,      -- ACK packet time-out.
    -- BuPAbscntintack register: acknowledge of the absolute count interrupts
    reg_abscnt_ack       => reg_abscnt_ack,   
    -- BuPintmask register: enable/disable interrupts on the following events.
    reg_timewrap_en      => reg_timewrap_en,    -- Wrapping around of buptime.
    reg_ccabusy_en       => reg_ccabusy_en,     -- ccabusy.
    reg_ccaidle_en       => reg_ccaidle_en,     -- ccaidle.
    reg_rxstart_en       => reg_rxstart_en,     -- Rx packet start.
    reg_rxend_en         => reg_rxend_en,       -- Rx packet end.
    reg_txend_en         => reg_txend_en,       -- Tx packet end.
    reg_txstartirq_en    => reg_txstartirq_en,  -- Tx packet start.
    reg_txstartfiq_en    => reg_txstartfiq_en,  -- Tx packet start.
    reg_ackto_en         => reg_ackto_en,       -- ACK packet time-out.
    -- BuPAbscntintmask register: enable/disable interrupts on absolute count
    reg_abscnt_en        => reg_abscnt_en,        
    -- IRQ/FIQ select for absolute counter interrupts
    reg_abscnt_irqsel    => reg_abscnt_irqsel,

    --------------------------------------------
    -- Interrupt inputs
    --------------------------------------------
    sw_irq              => sw_irq,             -- Software interrupt (pulse).
    -- From BuP timers
    timewrap            => timewrap_it,        -- buptime wrapping around.
    -- Interrupts when absolute count reached.
    abscount_it         => abscount_it,
    -- From BuP state machines
    ccabusy_it          => ccabusy_it, -- Pulse for interrupt on CCA BUSY.
    ccaidle_it          => ccaidle_it, -- Pulse for interrupt on CCA IDLE.
    rxstart_it          => rxstart_it, -- Pulse for interrupt on RX packet start
    rxend_it            => rxend_it,   -- Pulse for interrupt on RX packet end.
    txend_it            => txend_it,   -- Pulse for interrupt on TX packet end.
    txstart_it          => txstart_it, -- pulse on start of packet transmition
    ackto_it            => ackto_it,   -- pulse on sACK packet time-out.
  
    --------------------------------------------
    -- Interrupt outputs
    --------------------------------------------
    bup_irq             => bup_irq,            -- BuP normal interrupt line.
    bup_fiq             => bup_fiq_o,          -- BuP fast interrupt line.
    -- BuPintstat register. Interrupt source is:
    reg_genirq_src      => reg_genirq_src,     -- software interrupt.
    reg_timewrap_src    => reg_timewrap_src,   -- wrapping around of buptime.
    reg_ccabusy_src     => reg_ccabusy_src,    -- ccabusy.
    reg_ccaidle_src     => reg_ccaidle_src,    -- ccaidle.
    reg_rxstart_src     => reg_rxstart_src,    -- rx packet start.
    reg_rxend_src       => reg_rxend_src,      -- rx packet end.
    reg_txend_src       => reg_txend_src,      -- tx packet end.
    reg_txstartirq_src  => reg_txstartirq_src, -- tx packet start.
    reg_txstartfiq_src  => reg_txstartfiq_src, -- tx packet start.
    reg_ackto_src       => reg_ackto_src,      -- ACK packet time-out.
    -- Absolute count interrupt sources
    reg_abscntirq_src   => reg_abscntirq_src,  
    reg_abscntfiq_src   => reg_abscntfiq_src,  
    reg_abscnt_src      => reg_abscnt_src,  
    -- BuPinttime register.
    reg_inttime         => reg_inttime         -- Interrupt time tag.
  );

  
  --------------------------------------------
  -- State Machines.
  --------------------------------------------
  bup2_sm_1 : bup2_sm
  port map (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn           => reset_n,          -- AHB reset line.
    hclk              => hclk,             -- AHB clock line.
    --------------------------------------
    -- BuP Registers
    -------------------------------------- 
    tximmstop         => reg_tximmstop,    -- TX immediate stop.
    vcs_enable        => reg_vcsenable,
    enable_1mhz       => enable_1mhz,      -- 1 MHz signal.
    --
    bup_sm_idle       => bup_sm_idle,      -- The state machines are idle.
    reset_bcon_txen   => reset_bcon_txen,
    reset_acp_txen    => reset_acp_txen,
    reset_iac_txen    => reset_iac_txen,
    
    buptxptr          => reg_buptxptr,     -- tx buffer ptr
    buprxptr          => reg_buprxptr,     -- rx buffer ptr
    buprxoff          => reg_rxoff,        -- start offset of next rx packet
    buprxsize         => reg_rxsize,       -- size of ring buffer
    buprxunload       => reg_rxunload,     -- rx unload ptr
    iacptr            => reg_iacptr,       -- IAC ctrl struct ptr

    bufempty          => reg_bufempty,     -- 1 when RX buffer emptied.
    rx_fullbuf        => reg_fullbuf_stat, -- rx buffer full detected when high
    rx_errstat        => rx_errstat,       -- error from the modem
    rxend_stat        => rxend_stat,       -- RX end status
    txend_stat        => txend_stat,       -- TX end status
    rx_fcs_err        => reg_fcserr_stat,  -- FCS error detected when high
    reg_frmcntl       => reg_frmcntl,   
    reg_durid         => reg_durid,     
    reg_bupaddr1      => reg_addr1,
    -- Bupaddr1mask register.
    reg_addr1mskh     => reg_addr1mskh,
    reg_addr1mskl     => reg_addr1mskl,
    reg_enrxabort     => reg_enrxabort,    -- RX abort enable
    reg_rxabtcnt      => reg_rxabtcnt,     -- RX abort counter
    reg_rxlen         => reg_rxlen,
    reg_rxserv        => reg_rxserv, 
    reg_rxrate        => reg_rxrate, 
    reg_rxrssi        => reg_rxrssi,
    reg_rxccaaddinfo  => reg_rxccaaddinfo,
    reg_rxant         => reg_rxant,
    reg_a1match       => reg_a1match_stat,
    -- IAC after SIFS sticky bit
    iacaftersifs_ack  => reg_iacaftersifs_ack,  -- Acknowledge
    iacaftersifs      => iacaftersifs,      -- Status.
    --------------------------------------
    -- Modem test mode
    -------------------------------------- 
    testenable        => reg_testenable,   -- enable BuP test mode.
    bup_testmode      => reg_buptestmode,  -- selects the type of test.
    datatype          => reg_datatype,     -- selects the data pattern
    fcsdisb           => reg_fcsdisb,      -- disable FCS computation
    testdata          => reg_testpattern,  -- Tx test pattern.
    --------------------------------------
    -- Interrupt Generator
    -------------------------------------- 
    ccabusy_it        => ccabusy_it,  -- pulse for interrupt on CCA BUSY.
    ccaidle_it        => ccaidle_it,  -- pulse for interrupt on CCA IDLE.
    rxstart_it        => rxstart_it,  -- pulse for interrupt on RX packet start.
    txstart_it        => txstart_it,  -- pulse on start of packet transmition
    rxend_it          => rxend_it,    -- pulse for interrupt on RX packet end.
    txend_it          => txend_it,    -- pulse for interrupt on TX packet end.
    sifs_timer_it     => sifs_timer_it, -- interrupt when SIFS reaches 0.
    backoff_timer_it  => backoff_timer_it, -- interrupt when backoff reaches 0.
    txstartdel_flag   => txstartdel_flag,  -- Flag set when SIFS count reaches txstartdel.
    iac_txenable      => iac_txenable,
    --------------------------------------------
    -- Bup timers interface
    --------------------------------------------
    iac_without_ifs      => iac_without_ifs,-- Set if no IFS in IAC queue
    rx_abortend          => rx_abortend,
    queue_it_num         => txqueue_from_timer,
    sampled_queue_it_num => reg_txqueue,
    rx_packet_type       => rx_packet_type,
    tx_packet_type       => tx_packet_type,
    tximmstop_sm         => tximmstop_sm,   -- Immediate stop processed in the
                                            -- state machines.
    --------------------------------------
    -- Memory Sequencer
    -------------------------------------- 
    mem_seq_ready     => mem_seq_ready,     -- Mem Seq is ready (data valid).
    mem_seq_data      => mem_seq_data,      -- data to transmit.
    --
    mem_seq_req       => mem_seq_req,       -- request for new byte.
    mem_seq_ind       => mem_seq_ind,       -- new byte is ready.
    data_to_mem_seq   => data_to_mem_seq,   -- byte data to Memory Sequencer
    mem_seq_rx_mode   => mem_seq_rx_mode,   -- Bup in reception mode.
    mem_seq_tx_mode   => mem_seq_tx_mode,   -- Bup in transmit mode.
    last_word         => last_word,         -- next bytes are part of last word
    mem_seq_rxptr     => mem_seq_rxptr,     -- rxptr for mem_seq
    mem_seq_txptr     => mem_seq_txptr,     -- txptr for mem_seq
    load_ptr          => load_ptr,          -- pulse to load new pointer
    ready_load        => ready_load,        
    acctype           => acctype,           -- access type for endianness converter.    
    
    --------------------------------------
    -- FCS generator
    -------------------------------------- 
    fcs_data_1st      => fcs_data_1st,      -- First FCS data.
    fcs_data_2nd      => fcs_data_2nd,      -- Second FCS data.
    fcs_data_3rd      => fcs_data_3rd,      -- Third FCS data.
    fcs_data_4th      => fcs_data_4th,      -- Fourth FCS data.
    --
    fcs_init          => fcs_init,          -- init FCS computation.
    fcs_data_valid    => fcs_data_valid,    -- compute FCS on mem seq data.
    data_to_fcs       => data_to_fcs,       -- byte data to FCS.
    --------------------------------------
    -- Modem
    -------------------------------------- 
    phy_cca_ind       => phy_cca_ind,      -- CCA status from Modems.
    phy_data_conf     => phy_data_conf,    -- Last byte read,ready for new one
    phy_txstartend_conf => phy_txstartend_conf, -- tx started, ready for data
                                                -- or transmission ended.
    phy_rxstartend_ind => phy_rxstartend_ind, -- preamble detected
                                              -- or end of received packet.
    phy_data_ind      => phy_data_ind,
    rxv_length        => rxv_length,        -- RX PSDU length.
    bup_rxdata        => bup_rxdata,        -- data from Modem.
    rxe_errorstat     => rxv_errorstat,     -- packet reception status.
    rxv_datarate      => rxv_datarate,      -- RX PSDU rate.
    rxv_service       => rxv_service,       -- RX SERVICE field (802.11a only).
    rxv_service_ind   => rxv_service_ind,
    rxv_rssi          => rxv_rssi,          -- preamble RSSI (802.11a only).
    rxv_macaddr_match => rxv_macaddr_match_o, -- A1match status
    rxv_ccaaddinfo    => rxv_ccaaddinfo,    
    rxv_rxant         => rxv_rxant,    
    --
    phy_data_req      => phy_data_req_o,    -- request to send a byte.
    phy_txstartend_req => phy_txstartend_req_o, -- to start a packet transmission
                                          -- or request for end of transmission.
    bup_txdata        => bup_txdata_o,      -- data to Modem.
    txv_datarate      => txv_datarate_o,    -- TX PSDU rate.
    txv_length        => txv_length,        -- TX packet size.
    txpwr_level       => txpwr_level,       -- TX power level.
    txv_service       => txv_service,       -- TX SERVICE field (802.11a only).
    txv_txaddcntl     => txv_txaddcntl,
    txv_paindex       => txv_paindex,
    txv_txant         => txv_txant,
    ackto             => ackto,
    ackto_en          => ackto_en,
    -- diag
    bup_sm_diag       => bup_sm_diag
  );

  --------------------------------------------
  -- Other Processing.
  --------------------------------------------
  crc32_8_1 : crc32_8
  port map (
    -- clock and reset
    clk                 => hclk,            -- clock.
    resetn              => reset_n,         -- reset.
    -- 
    data_in             => data_to_fcs,     -- 8-bits input.
    ld_init             => fcs_init,        -- initialize the CRC.
    calc                => fcs_data_valid,  -- ask of calculation.
    -- CRC result.
    crc_out_1st         => fcs_data_1st,    -- First FCS data.
    crc_out_2nd         => fcs_data_2nd,    -- Second FCS data.
    crc_out_3rd         => fcs_data_3rd,    -- Third FCS data.
    crc_out_4th         => fcs_data_4th     -- Fourth FCS data.
  );

  ------------------------------------------------------------------------------
  -- Timers
  ------------------------------------------------------------------------------
  bup2_timers_1 : bup2_timers
  generic map (
    num_queues_g   => num_queues_g,
    num_abstimer_g => num_abstimer_g
    )
  port map (
    -- clock and reset
    reset_n                 => reset_n,
    pclk                    => hclk,
    buptimer_clk            => buptimer_clk,
    -- 1 Mhz enable.
    enable_1mhz             => enable_1mhz,
    -- 32k mode
    mode32k                 => mode32k,
    -- BuP Timer Control.
    reg_buptimer            => reg_buptimer,
    write_buptimer          => write_buptimer,
    write_buptimer_done     => write_buptimer_done,
    bup_timer               => bup_timer,
    timewrap_interrupt      => timewrap_it,
    -- Channel Assessment Timers.
    phy_txstartend_conf     => phy_txstartend_conf,
    reg_chassen             => reg_chassen,
    reg_ignvcs              => reg_ignvcs,
    reset_chassbsy          => reset_chassbsy,
    reset_chasstim          => reset_chasstim,
    reg_chassbsy            => reg_chassbsy,
    reg_chasstim            => reg_chasstim,
    -- ACK time-out timer
    ackto_count             => ackto,
    ackto_en                => ackto_en,
    reg_ackto_en            => reg_ackto_en,
    txstart_it              => txstart_it,
    txend_it                => txend_it,
    rxstart_it              => rxstart_it,
    --
    ackto_it                => ackto_it,
    -- Backoff Timer Control.
    reg_backoff_bcon        => bcon_backoff,
    reg_backoff_acp0        => acp_backoff0,
    reg_backoff_acp1        => acp_backoff1,
    reg_backoff_acp2        => acp_backoff2,
    reg_backoff_acp3        => acp_backoff3,
    reg_backoff_acp4        => acp_backoff4,
    reg_backoff_acp5        => acp_backoff5,
    reg_backoff_acp6        => acp_backoff6,
    reg_backoff_acp7        => acp_backoff7,

    write_backoff_bcon      => write_bcon_bkoff,
    write_backoff_iac       => write_iac_bkoff,
    write_backoff_acp0      => write_acp_bkoff(0),
    write_backoff_acp1      => write_acp_bkoff(1),
    write_backoff_acp2      => write_acp_bkoff(2),
    write_backoff_acp3      => write_acp_bkoff(3),
    write_backoff_acp4      => write_acp_bkoff(4),
    write_backoff_acp5      => write_acp_bkoff(5),
    write_backoff_acp6      => write_acp_bkoff(6),
    write_backoff_acp7      => write_acp_bkoff(7),

    backoff_timer_bcon      => bcon_bkoff_timer,
    backoff_timer_acp0      => acp0_bkoff_timer,
    backoff_timer_acp1      => acp1_bkoff_timer,
    backoff_timer_acp2      => acp2_bkoff_timer,
    backoff_timer_acp3      => acp3_bkoff_timer,
    backoff_timer_acp4      => acp4_bkoff_timer,
    backoff_timer_acp5      => acp5_bkoff_timer,
    backoff_timer_acp6      => acp6_bkoff_timer,
    backoff_timer_acp7      => acp7_bkoff_timer,

    backenable_bcon         => bcon_bakenable,
    backenable_acp0         => acp_bakenable0,
    backenable_acp1         => acp_bakenable1,
    backenable_acp2         => acp_bakenable2,
    backenable_acp3         => acp_bakenable3,
    backenable_acp4         => acp_bakenable4,
    backenable_acp5         => acp_bakenable5,
    backenable_acp6         => acp_bakenable6,
    backenable_acp7         => acp_bakenable7,
    
    txenable_iac            => iac_txenable,
    txenable_bcon           => bcon_txenable,
    txenable_acp0           => acp_txenable0,
    txenable_acp1           => acp_txenable1,
    txenable_acp2           => acp_txenable2,
    txenable_acp3           => acp_txenable3,
    txenable_acp4           => acp_txenable4,
    txenable_acp5           => acp_txenable5,
    txenable_acp6           => acp_txenable6,
    txenable_acp7           => acp_txenable7,
    forcetxdis              => reg_forcetxdis,  -- Disable all TX queues.

    ifs_iac                 => iac_ifs,
    ifs_bcon                => bcon_ifs,
    ifs_acp0                => acp_ifs0,
    ifs_acp1                => acp_ifs1,
    ifs_acp2                => acp_ifs2,
    ifs_acp3                => acp_ifs3,
    ifs_acp4                => acp_ifs4,
    ifs_acp5                => acp_ifs5,
    ifs_acp6                => acp_ifs6,
    ifs_acp7                => acp_ifs7,

    sifs_timer_it           => sifs_timer_it,
    backoff_timer_it        => backoff_timer_it,
    txstartdel_flag         => txstartdel_flag,
    queue_it_num            => txqueue_from_timer,
    iac_without_ifs         => iac_without_ifs, -- Set if no IFS in IAC queue
    
    -- BuPvcs register.
    vcs_enable              => reg_vcsenable,
    vcs                     => reg_vcs,
    reset_vcs               => reset_vcs,
    
    -- BUPControl register
    reg_cntxtsel            => reg_cntxtsel,
    reg_clk32sel            => reg_clk32sel,
    -- BuPcount register (Durations expressed in us).
    reg_txstartdel          => reg_txdstartdel,
    reg_macslot             => reg_macslot,
    reg_txsifsb             => reg_txsifsb,      -- SIFS period after TX.
    reg_rxsifsb             => reg_rxsifsb,      -- SIFS period after RX.
    reg_txsifsa             => reg_txsifsa,      -- SIFS period after TX.
    reg_rxsifsa             => reg_rxsifsa,      -- SIFS period after RX.
    reg_sifs                => reg_sifs,
    -- Events to trigger the SIFS counter
    tx_end                  => txend_it,
    rx_end                  => rx_abortend,
    phy_cca_ind             => phy_cca_ind,      -- CCA status.
    bup_sm_idle             => bup_sm_idle,      -- The state machines are idle.
    rx_packet_type          => rx_packet_type,
    tx_packet_type          => tx_packet_type,
    tximmstop_sm            => tximmstop_sm,     -- Immediate stop processed in the
                                                 -- state machines.
    -- BuPabscnt registers.
    reg_abstime0            => reg_abstime0,
    reg_abstime1            => reg_abstime1,
    reg_abstime2            => reg_abstime2,
    reg_abstime3            => reg_abstime3,
    reg_abstime4            => reg_abstime4,
    reg_abstime5            => reg_abstime5,
    reg_abstime6            => reg_abstime6,
    reg_abstime7            => reg_abstime7,
    reg_abstime8            => reg_abstime8,
    reg_abstime9            => reg_abstime9,
    reg_abstime10           => reg_abstime10,
    reg_abstime11           => reg_abstime11,
    reg_abstime12           => reg_abstime12,
    reg_abstime13           => reg_abstime13,
    reg_abstime14           => reg_abstime14,
    reg_abstime15           => reg_abstime15,
    --
    abscount_it             => abscount_it,
    -- Diagnostic ports
    bup_timers_diag         => bup_timers_diag
    );


end RTL;
