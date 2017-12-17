
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_kernel_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.40  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for bup2_kernel.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_kernel/vhdl/rtl/bup2_kernel_pkg.vhd,v  
--  Log: bup2_kernel_pkg.vhd,v  
-- Revision 1.40  2006/03/13 08:46:12  Dr.A
-- #BugId:2328#
-- Increased size of reg_clk32cntl to support 131.072 kHz config
--
-- Revision 1.39  2006/02/03 08:37:42  Dr.A
-- #BugId:1140#
-- Debug of IAC IFS
--
-- Revision 1.38  2006/02/02 15:37:54  Dr.A
-- #BugId:1204#
-- Use two clocks for BuP timers block (gated and not)
--
-- Revision 1.37  2006/02/02 08:28:59  Dr.A
-- #BugId:1213#
-- Added bit to ignore VCS for channel assessment
--
-- Revision 1.36  2005/10/21 13:29:07  Dr.A
-- #BugId:1246#
-- Added absolute count timers
--
-- Revision 1.35  2005/04/19 07:59:11  Dr.A
-- #BugId:1181#
-- Connected ports for ackto enable
--
-- Revision 1.34  2005/03/29 08:45:13  Dr.A
-- #BugId:907#
-- Added TX force disable
--
-- Revision 1.33  2005/03/25 11:12:43  Dr.A
-- #BugId:1152#
-- Removed ARTIM counter
--
-- Revision 1.32  2005/03/22 10:16:37  Dr.A
-- #BugId:1152#
-- Connected arrival time counter enable. Cleaned write_bckoff ports.
--
-- Revision 1.31  2005/02/18 16:21:54  Dr.A
-- #BugId:1070#
-- Connected txstartdel_flag. Added iac_txenable to the diags.
--
-- Revision 1.30  2005/02/09 17:50:05  Dr.A
-- #BugId:974#
-- reset_bufempty now coming from memory sequencer.
--
-- Revision 1.29  2005/01/21 15:51:31  Dr.A
-- #BugId:964,978#
-- Connected registers and immediate stop control to BuP timers.
--
-- Revision 1.28  2005/01/13 14:03:19  Dr.A
-- #BugId:903#
-- New diag ports.
--
-- Revision 1.27  2005/01/10 13:15:24  Dr.A
-- #BugId:912#
-- Removed enable_bup
--
-- Revision 1.26  2004/12/20 17:02:18  Dr.A
-- #BugId:850#
-- Added IAC after SIFS mechanism.
--
-- Revision 1.25  2004/12/20 12:55:18  Dr.A
-- #BugId:702,822#
-- Connecte ACK time-out interrupt lines (702).
-- Connected txend_stat status line (822)
--
-- Revision 1.24  2004/12/17 13:59:12  Dr.A
-- #BugId:912#
-- Package update
--
-- Revision 1.23  2004/12/17 13:04:14  Dr.A
-- #BugId:606,912#
-- New signal from RX FSM used as 'rx end' for timers (606)
-- Enable bit removed from registers (912)
--
-- Revision 1.22  2004/12/10 10:37:58  Dr.A
-- #BugId:606#
-- Connected RX abort and ack time-out registers
--
-- Revision 1.21  2004/12/06 09:14:20  Dr.A
-- #BugId:836#
-- Adress1 mask register connected to state machine
--
-- Revision 1.20  2004/12/03 14:18:19  Dr.A
-- #BugId:837#
-- Added channel assessment timers to bup2_timers port map and connected misc. registers to default values.
--
-- Revision 1.19  2004/12/02 10:29:34  Dr.A
-- #BugId:822#
-- Connect tx_immstop to state machines and output port.
--
-- Revision 1.18  2004/11/10 10:35:33  Dr.A
-- #BugId:837#
-- New registers for channel assessment and multi SSID
--
-- Revision 1.17  2004/11/09 14:13:50  Dr.A
-- #BugId:835#
-- New rxv_ and txv_ ports connected to state machines
--
-- Revision 1.16  2004/11/03 17:18:55  Dr.A
-- #BugId:820#
-- enable_1mhz input now synchronous to BuP clocks
--
-- Revision 1.15  2004/08/26 17:07:39  Dr.A
-- Removed mode32k in resync block.
--
-- Revision 1.14  2004/08/05 16:15:07  Dr.A
-- Added mode32k resync. Moved resync to a separate block.
--
-- Revision 1.13  2004/07/20 07:52:07  Dr.A
-- enable_1mhz synchronized with buptimer_clk.
--
-- Revision 1.12  2004/05/18 10:50:30  Dr.A
-- Only one input port for phy_cca_ind, and resync removed.
--
-- Revision 1.11  2004/04/14 16:11:30  Dr.A
-- Removed unused signal last_word_size.
--
-- Revision 1.10  2004/02/06 14:51:02  Dr.F
-- updated ports.
--
-- Revision 1.9  2004/02/06 14:48:04  Dr.F
-- added buptestdin.
--
-- Revision 1.8  2004/02/05 18:29:32  Dr.F
-- removed modeselect.
--
-- Revision 1.7  2004/01/26 08:51:50  Dr.F
-- added ready_load.
--
-- Revision 1.6  2004/01/09 08:16:55  Dr.F
-- added gpo.
--
-- Revision 1.5  2004/01/06 15:10:29  pbressy
-- bugzilla 331 fix
--
-- Revision 1.4  2003/12/05 09:11:54  Dr.F
-- port map changed.
--
-- Revision 1.3  2003/11/25 14:20:12  Dr.F
-- added prdata1.
--
-- Revision 1.2  2003/11/25 07:57:26  Dr.F
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


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package bup2_kernel_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/PROC_SYSTEM/master_interface/vhdl/rtl/master_interface.vhd
----------------------
  component master_interface
  generic 
      (
      gotoaddr_g         : integer := 0;
      burstlinkcapable_g : integer := 1
      ) ;

  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hclk            : in  std_logic;
    hreset_n        : in  std_logic;
    
    --------------------------------------
    -- Signal to/from logic part of master
    --------------------------------------
    --write           : in  std_logic;
    burst           : in  std_logic_vector(2 downto 0);
    busreq          : in  std_logic;
    unspeclength    : in  std_logic;
    busy            : in  std_logic;
    buserror        : out std_logic;     
    inc_addr        : out std_logic;    
    valid_data      : out std_logic;
    decr_addr       : out std_logic;    
    grant_lost      : out std_logic;
    end_add         : out std_logic;
    end_data        : out std_logic;
    free            : out std_logic;
   
    --------------------------------------
    -- AHB control signals
    --------------------------------------
    hready          : in  std_logic;
    hresp           : in  std_logic_vector(1 downto 0);
    hgrant          : in  std_logic;
    htrans          : out std_logic_vector(1 downto 0);
    hbusreq         : out std_logic

  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDBuP2/mem2_seq/vhdl/rtl/mem2_seq.vhd
----------------------
  component mem2_seq
  port (
    --------------------------------------------
    -- Clock & reset
    --------------------------------------------
    hclk          : in  std_logic;                      -- AHB clock 
    hreset_n      : in  std_logic;                      -- AHB reset
    
    --------------------------------------------
    -- Bup registers
    --------------------------------------------
    buprxptr      : in  std_logic_vector(31 downto 0);  -- receive buffer addr
    buptxptr      : in  std_logic_vector(31 downto 0);  -- trans buffer addr
    load_ptr      : in  std_logic;                      -- pulse to load new ptr 
    
    --------------------------------------------
    -- Bup state machine
    --------------------------------------------
    req           : in  std_logic;                      -- request for new byte
    ind           : in  std_logic;                      -- new byte is ready
    data_rec      : in  std_logic_vector(7 downto 0);   -- byte received
    last_word     : in  std_logic;                      -- last bytes
    tx            : in  std_logic;                      -- transmission 
    rx            : in  std_logic;                      -- reception
    ready         : out std_logic;                      -- data is valid
    trans_data    : out std_logic_vector(7 downto 0);   -- data to transmit
    ready_load    : out std_logic;                      -- ready 4 new load_ptr
    reset_bufempty: out std_logic;                      -- reset bufempty when RX buffer written
        
    --------------------------------------------
    -- AHB master interface
    --------------------------------------------
    inc_addr      : in  std_logic;                      -- increment address 
    decr_addr     : in  std_logic;                      -- decrement address
    valid_data    : in  std_logic;                      -- data is valid
    end_add       : in  std_logic;                      -- last address
    end_data      : in  std_logic;                      -- last data
    free          : in  std_logic;                      -- master busy          
    busreq        : out std_logic;                      -- bus request
    unspeclength  : out std_logic;                      -- stop incr. burst

    
    --------------------------------------------
    -- AHB bus
    --------------------------------------------
    hrdata        : in std_logic_vector (31 downto 0);  -- AHB read data
    hlock         : out std_logic;                      -- bus lock
    hwrite        : out std_logic;                      -- write transaction
    hsize         : out std_logic_vector (2 downto 0);  -- transfer size
    hburst        : out std_logic_vector (2 downto 0);  -- burst type
    hprot         : out std_logic_vector (3 downto 0);  -- protection
    haddr         : out std_logic_vector (31 downto 0); -- AHB address
    hwdata        : out std_logic_vector (31 downto 0)  -- AHB write data
  );

  end component;


----------------------
-- Source: Good
----------------------
  component bup2_registers
  generic (
    num_queues_g    : integer := 8; -- number of data queues.
    num_abstimer_g  : integer := 16 -- number of absolute count timers (max is 16)
    );
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n         : in  std_logic; -- Reset.
    pclk            : in  std_logic; -- APB clock.

    --------------------------------------------
    -- APB slave 0
    --------------------------------------------
    apb0_psel       : in  std_logic; -- Device select.
    apb0_penable    : in  std_logic; -- Defines the enable cycle.
    apb0_paddr      : in  std_logic_vector( 7 downto 0); -- Address.
    apb0_pwrite     : in  std_logic; -- Write signal.
    apb0_pwdata     : in  std_logic_vector(31 downto 0); -- Write data.
    --
    apb0_prdata     : out std_logic_vector(31 downto 0); -- Read data.
    
    --------------------------------------------
    -- APB slave 1
    --------------------------------------------
    apb1_psel       : in  std_logic; -- Device select.
    apb1_penable    : in  std_logic; -- Defines the enable cycle.
    apb1_paddr      : in  std_logic_vector( 7 downto 0); -- Address.
    apb1_pwrite     : in  std_logic; -- Write signal.
    apb1_pwdata     : in  std_logic_vector(31 downto 0); -- Write data.
    --
    apb1_prdata     : out std_logic_vector(31 downto 0); -- Read data.
    
    --------------------------------------------
    -- BuP registers inputs
    --------------------------------------------
    -- BuPtime register when read
    bup_timer       : in  std_logic_vector(25 downto 0);
    -- Beacon backoff register when read
    bcon_bkoff_timer: in  std_logic_vector( 9 downto 0);
    -- ACP backoff registers when read
    acp7_bkoff_timer: in  std_logic_vector( 9 downto 0);
    acp6_bkoff_timer: in  std_logic_vector( 9 downto 0);
    acp5_bkoff_timer: in  std_logic_vector( 9 downto 0);
    acp4_bkoff_timer: in  std_logic_vector( 9 downto 0);
    acp3_bkoff_timer: in  std_logic_vector( 9 downto 0);
    acp2_bkoff_timer: in  std_logic_vector( 9 downto 0);
    acp1_bkoff_timer: in  std_logic_vector( 9 downto 0);
    acp0_bkoff_timer: in  std_logic_vector( 9 downto 0);
    -- BuPintstat register.
    reg_iacaftersifs: in  std_logic; -- Set when IAC tx request arrived after SIFS
    reg_txqueue     : in  std_logic_vector( 3 downto 0); -- Tx packet queue.
    -- Reception and transmission status. Bit set when:
    reg_fcserr_stat : in  std_logic; -- FCS is incorrect.
    reg_fullbuf_stat: in  std_logic; -- Rx buffer full, packet truncated.
    reg_a1match_stat: in  std_logic; -- Address1 field matches BUPADDR1L/H reg.
    reg_errstat     : in  std_logic_vector( 1 downto 0); -- Reception status.
    reg_rxendstat   : in  std_logic_vector( 1 downto 0); -- RX reception status.
    reg_txendstat   : in  std_logic_vector( 1 downto 0); -- TX reception status.
    -- Interrupt sources:
    reg_ackto_src   : in  std_logic; -- ACK time-out status.
    reg_genirq_src  : in  std_logic; -- Software interrupt.
    -- Absolute counter interrupts.
    reg_abscntirq_src : in  std_logic;
    reg_abscntfiq_src : in  std_logic;
    reg_abscnt_src  : in  std_logic_vector(num_abstimer_g-1 downto 0);
    reg_timewrap_src: in  std_logic; -- Wrapping around of buptime.
    reg_ccabusy_src : in  std_logic; -- Ccabusy.
    reg_ccaidle_src : in  std_logic; -- Ccaidle.
    reg_rxstart_src : in  std_logic; -- Rx packet start.
    reg_rxend_src   : in  std_logic; -- Rx packet end.
    reg_txend_src   : in  std_logic; -- Tx packet end.
    reg_txstartirq_src : in  std_logic; -- Tx packet start.
    reg_txstartfiq_src : in  std_logic; -- Tx packet start (fast interrupt).
    -- BuPinttime register.
    reg_inttime     : in  std_logic_vector(25 downto 0); -- Interrupt time tag.
    -- BuPmachdr register: values from the received MAC header.
    reg_durid       : in  std_logic_vector(15 downto 0); -- Duration/Id field.
    reg_frmcntl     : in  std_logic_vector(15 downto 0); -- Frame control field.
    -- BuPTestdata input register for validation purpose
    testdata_in     : in  std_logic_vector(31 downto 0);
    -- Channel assessment timers
    reg_chassbsy    : in  std_logic_vector(25 downto 0);
    reg_chasstim    : in  std_logic_vector(25 downto 0);
    -- RX control structure 0 fields:
    -- service field of received packet
    rxserv          : in std_logic_vector(15 downto 0);
    rxlen           : in std_logic_vector(11 downto 0); -- length of PSDU received
    -- RX control structure 1 fields:
    rxccaaddinfo    : in std_logic_vector( 7 downto 0); -- CCA additional information
    rxrate          : in std_logic_vector( 3 downto 0); -- Rate received packet
    rxant           : in std_logic; -- Antenna used for reception.
    -- Radio signal strength of received packet
    rxrssi          : in std_logic_vector(6 downto 0);

    --------------------------------------------
    -- BuP Registers outputs
    --------------------------------------------
    -- BuPcntl register.
    reg_forcetxdis  : out std_logic; -- Disable all TX queues.
    reg_tximmstop   : out std_logic; -- TX immediate stop.
    reg_ccarst      : out std_logic; -- Reset the CCA state machines.
    reg_enrxabort   : out std_logic; -- Enable abort of RX packets
    reg_bufempty    : out std_logic; -- '1' when RX buffer has been emptied.
    genirq          : out std_logic; -- Software interrupt (pulse).
    reg_cntxtsel    : out std_logic; -- Select context.
    -- low power clock freq selection : 0 : 32kHz; 1 : 32.768kHz
    reg_clk32sel    : out std_logic_vector(1 downto 0); 
    -- BuPvcs register.
    reg_vcsenable   : out std_logic; -- Virtual carrier sense enable.
    reg_vcs         : out std_logic_vector(25 downto 0); -- VCS time tag.
    -- BuPtime register.
    reg_buptimer    : out std_logic_vector(25 downto 0); -- Time counter written.
    -- BuPabscnt registers.
    reg_abstime0          : out std_logic_vector(25 downto 0);
    reg_abstime1          : out std_logic_vector(25 downto 0);
    reg_abstime2          : out std_logic_vector(25 downto 0);
    reg_abstime3          : out std_logic_vector(25 downto 0);
    reg_abstime4          : out std_logic_vector(25 downto 0);
    reg_abstime5          : out std_logic_vector(25 downto 0);
    reg_abstime6          : out std_logic_vector(25 downto 0);
    reg_abstime7          : out std_logic_vector(25 downto 0);
    reg_abstime8          : out std_logic_vector(25 downto 0);
    reg_abstime9          : out std_logic_vector(25 downto 0);
    reg_abstime10         : out std_logic_vector(25 downto 0);
    reg_abstime11         : out std_logic_vector(25 downto 0);
    reg_abstime12         : out std_logic_vector(25 downto 0);
    reg_abstime13         : out std_logic_vector(25 downto 0);
    reg_abstime14         : out std_logic_vector(25 downto 0);
    reg_abstime15         : out std_logic_vector(25 downto 0);
    -- Register for abscount interrupt type
    reg_abscnt_irqsel     : out std_logic_vector(num_abstimer_g-1 downto 0);
    -- BuPintmask register: enable/disable interrupts on the following events.
    -- Absolute counter interrupt.
    reg_abscnt_en   : out std_logic_vector(num_abstimer_g-1 downto 0);
    reg_timewrap_en : out std_logic; -- Wrapping around of buptime.
    reg_ccabusy_en  : out std_logic; -- Ccabusy.
    reg_ccaidle_en  : out std_logic; -- Ccaidle.
    reg_rxstart_en  : out std_logic; -- Rx packet start.
    reg_rxend_en    : out std_logic; -- Rx packet end.
    reg_txend_en    : out std_logic; -- Tx packet end.
    reg_txstartirq_en : out std_logic; -- Tx packet start.
    reg_txstartfiq_en : out std_logic; -- TX packet start (fast interrupt).
    reg_ackto_en    : out std_logic; -- ACK packet time-out.
    -- BuPintack register: acknowledge of the following interrupts
    reg_iacaftersifs_ack  : out std_logic; -- IAC after SIFS sticky bit.
    reg_genirq_ack  : out std_logic; -- Software interrupt.
    -- Absolute counter interrupt.
    reg_abscnt_ack  : out std_logic_vector(num_abstimer_g-1 downto 0);
    reg_timewrap_ack: out std_logic; -- Wrapping around of buptime.
    reg_ccabusy_ack : out std_logic; -- Ccabusy.
    reg_ccaidle_ack : out std_logic; -- Ccaidle.
    reg_rxstart_ack : out std_logic; -- Rx packet start.
    reg_rxend_ack   : out std_logic; -- Rx packet end.
    reg_txend_ack   : out std_logic; -- Tx packet end.
    reg_txstartirq_ack : out std_logic; -- Tx packet start.
    reg_txstartfiq_ack : out std_logic; -- Tx packet start (fast interrupt).
    reg_ackto_ack   : out std_logic; -- ACK packet time-out.
    -- BuPcount register (Durations expressed in us).
    reg_txdstartdel : out std_logic_vector(2 downto 0); -- TX start delay.
    reg_macslot     : out std_logic_vector(7 downto 0); -- MAC slots.
    reg_txsifsb     : out std_logic_vector(5 downto 0); -- SIFS period after TX (modem b)
    reg_rxsifsb     : out std_logic_vector(5 downto 0); -- SIFS period after RX (modem b)
    reg_txsifsa     : out std_logic_vector(5 downto 0); -- SIFS period after TX (modem a)
    reg_rxsifsa     : out std_logic_vector(5 downto 0); -- SIFS period after RX (modem a)
    reg_sifs        : out std_logic_vector(5 downto 0); -- SIFS after CCAidle or
                                                        -- absolute count events
    -- Buptxcntl_bcon register:
    reg_bcon_bakenable  : out std_logic; -- '1' to enable backoff counter.
    reg_bcon_txenable   : out std_logic; -- '1' to enable packets transmission.
    -- Number of MAC slots to add to create Beacon inter-frame spacing.
    reg_bcon_ifs        : out std_logic_vector( 3 downto 0);
    -- Beacon Backoff counter init value.
    reg_bcon_backoff    : out std_logic_vector( 9 downto 0);
    -- Channel assessment register.
    reg_chassen         : out std_logic; -- Channel assessment enable
    reg_ignvcs          : out std_logic; -- Include VCS in measurement when HIGH
    
    --------------------------------------------
    -- Access Priority Context Registers.
    --------------------------------------------
    -- Buptxcntl_acp7 register:
    reg_acp_bakenable7  : out std_logic; -- '1' to enable backoff counter.
    reg_acp_txenable7   : out std_logic; -- '1' to enable packets transmission.
    -- Number of MAC slots to add to create ACP inter-frame spacing.
    reg_acp_ifs7        : out std_logic_vector( 3 downto 0);
    -- ACP Backoff counter init value.
    reg_acp_backoff7    : out std_logic_vector( 9 downto 0);
    -- Buptxcntl_acp6 register:
    reg_acp_bakenable6  : out std_logic;
    reg_acp_txenable6   : out std_logic;
    reg_acp_ifs6        : out std_logic_vector( 3 downto 0);
    reg_acp_backoff6    : out std_logic_vector( 9 downto 0);
    -- Buptxcntl_acp5 register:
    reg_acp_bakenable5  : out std_logic;
    reg_acp_txenable5   : out std_logic;
    reg_acp_ifs5        : out std_logic_vector( 3 downto 0);
    reg_acp_backoff5    : out std_logic_vector( 9 downto 0);
    -- Buptxcntl_acp4 register:
    reg_acp_bakenable4  : out std_logic;
    reg_acp_txenable4   : out std_logic;
    reg_acp_ifs4        : out std_logic_vector( 3 downto 0);
    reg_acp_backoff4    : out std_logic_vector( 9 downto 0);
    -- Buptxcntl_acp3 register:
    reg_acp_bakenable3  : out std_logic;
    reg_acp_txenable3   : out std_logic;
    reg_acp_ifs3        : out std_logic_vector( 3 downto 0);
    reg_acp_backoff3    : out std_logic_vector( 9 downto 0);
    -- Buptxcntl_acp2 register:
    reg_acp_bakenable2  : out std_logic;
    reg_acp_txenable2   : out std_logic;
    reg_acp_ifs2        : out std_logic_vector( 3 downto 0);
    reg_acp_backoff2    : out std_logic_vector( 9 downto 0);
    -- Buptxcntl_acp1 register:
    reg_acp_bakenable1  : out std_logic;
    reg_acp_txenable1   : out std_logic;
    reg_acp_ifs1        : out std_logic_vector( 3 downto 0);
    reg_acp_backoff1    : out std_logic_vector( 9 downto 0);
    -- Buptxcntl_acp0 register:
    reg_acp_bakenable0  : out std_logic;
    reg_acp_txenable0   : out std_logic;
    reg_acp_ifs0        : out std_logic_vector( 3 downto 0);
    reg_acp_backoff0    : out std_logic_vector( 9 downto 0);
    
    -- Tx register for Immediate Action Control context:
    reg_iac_txenable    : out std_logic; -- '1' to enable packets transmission.
    -- Number of MAC slots to add to create IAC inter-frame spacing.
    reg_iac_ifs         : out std_logic_vector( 3 downto 0);
    
    -- BuPtxptr register: Start address of the transmit buffer.
    reg_buptxptr    : out std_logic_vector(31 downto 0);
    -- BuPrxptr register: Start address of the receive buffer.
    reg_buprxptr    : out std_logic_vector(31 downto 0);
    -- BuPrxoff register: Start address of the next packet to be stored inside
    -- the RX ring buffer.
    reg_rxoff       : out std_logic_vector(15 downto 0);
    -- BuPrxsize register: size in bytes of theRx ring buffer.
    reg_rxsize      : out std_logic_vector(15 downto 0); 
    -- BuPrxunload register: pointer to the next packet to be retreived from 
    reg_rxunload    : out std_logic_vector(15 downto 0); -- RX buffer.
    -- Bupaddr1l/h registers.
    reg_addr1       : out std_logic_vector(47 downto 0); -- Address 1.
    -- Bupaddr1mask register.
    reg_addr1mskh   : out std_logic_vector( 3 downto 0); -- Mask Address1(43:40)
    reg_addr1mskl   : out std_logic_vector( 3 downto 0); -- Mask Address1(27:24)
    -- BuPTest register.
    reg_testenable  : out std_logic; -- '1' for test mode.
    reg_datatype    : out std_logic_vector( 1 downto 0); -- Select test pattern.
    reg_fcsdisb     : out std_logic; -- '0' to enable FCS computation.
    reg_buptestmode : out std_logic_vector( 1 downto 0); -- Select test type.
    -- BuPTestdata register read (transmit mode).
    -- Continuous transmit test mode: data pattern for transmission test.
    reg_testpattern : out std_logic_vector(31 downto 0);
    -- Buprxabtcnt register.
    reg_rxabtcnt    : out std_logic_vector( 5 downto 0);
    -- Pointer to the IAC control structure
    reg_csiac_ptr   : out std_logic_vector(31 downto 0);

    --------------------------------------------
    -- Timers Control
    --------------------------------------------
    -- BuP Timer
    write_buptimer      : out std_logic; -- update buptimer with register value.
    write_buptimer_done : in  std_logic; -- update done.

    -- Beacon Backoff Timer.
    write_bcon_bkoff        : out std_logic; -- reinit beacon backoff timer.
    -- ACP Backoff Timers.
    write_acp_bkoff         : out std_logic_vector( 7 downto 0); -- reinit.
    -- IAC IFS Timer.
    write_iac_bkoff         : out std_logic; -- reinit.

    -- Channel Assessment timers.
    reset_chassbsy      : out std_logic; -- Reset channel busy timer
    reset_chasstim      : out std_logic; -- Reset channel timer
    
    --------------------------------------------
    -- Misc. control
    --------------------------------------------
    phy_ccarst_conf : in  std_logic; -- Reset reg_ccarst.
    reset_bufempty  : in  std_logic; -- A new packet is stored in RX buffer.
    -- Pulse to reset bcon_txenable.
    reset_bcon_txen : in  std_logic;
    -- Pulse to reset acp_txenable.
    reset_acp_txen  : in  std_logic_vector(7 downto 0);
    -- Pulse to reset iac_txenable.
    reset_iac_txen  : in  std_logic;
    reset_vcs       : in  std_logic

  );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/WILDBuP2/bup2_intgen/vhdl/rtl/bup2_intgen.vhd
----------------------
  component bup2_intgen
  generic (
    num_abstimer_g : integer := 16
  );
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n         : in  std_logic; -- Reset.
    clk             : in  std_logic; -- Clock.

    --------------------------------------------
    -- BuP registers inputs
    --------------------------------------------
    -- BuPtime register.
    reg_buptime     : in  std_logic_vector(25 downto 0); -- BuP timer.
    -- BuPintack register: acknowledge of the following interrupts
    reg_genirq_ack  : in  std_logic; -- Software interrupt.
    reg_timewrap_ack: in  std_logic; -- Wrapping around of buptime.
    reg_ccabusy_ack : in  std_logic; -- Ccabusy.
    reg_ccaidle_ack : in  std_logic; -- Ccaidle.
    reg_rxstart_ack : in  std_logic; -- Rx packet start.
    reg_rxend_ack   : in  std_logic; -- Rx packet end.
    reg_txend_ack   : in  std_logic; -- Tx packet end.
    reg_txstartirq_ack : in  std_logic; -- Tx packet start.
    reg_txstartfiq_ack : in  std_logic; -- Tx packet start (fast interrupt).
    reg_ackto_ack   : in  std_logic; -- ACK packet time-out.
    -- BuPAbscntintack register: acknowledge of the absolute count interrupts
    reg_abscnt_ack  : in  std_logic_vector(num_abstimer_g-1 downto 0);
    -- BuPintmask register: enable/disable interrupts on the following events.
    reg_timewrap_en : in  std_logic; -- Wrapping around of int_buptime.
    reg_ccabusy_en  : in  std_logic; -- Ccabusy.
    reg_ccaidle_en  : in  std_logic; -- Ccaidle.
    reg_rxstart_en  : in  std_logic; -- Rx packet start.
    reg_rxend_en    : in  std_logic; -- Rx packet end.
    reg_txend_en    : in  std_logic; -- Tx packet end.
    reg_txstartirq_en  : in  std_logic; -- Tx packet start.
    reg_txstartfiq_en  : in  std_logic; -- Tx packet start (fast interrupt).
    reg_ackto_en    : in  std_logic; -- ACK packet time-out.
    -- BuPAbscntintmask register: enable/disable interrupts on absolute count
    reg_abscnt_en      : in  std_logic_vector(num_abstimer_g-1 downto 0);
    -- IRQ/FIQ select for absolute counter interrupts
    reg_abscnt_irqsel  : in  std_logic_vector(num_abstimer_g-1 downto 0);

    --------------------------------------------
    -- Interrupt inputs
    --------------------------------------------
    sw_irq          : in  std_logic; -- Software interrupt (pulse).
    -- From BuP timers
    timewrap        : in  std_logic; -- Wrapping around of BuP timer.
    -- Absolute count interrupts
    abscount_it     : in  std_logic_vector(num_abstimer_g-1 downto 0);
    -- From BuP state machines
    txstart_it      : in  std_logic; -- TXSTART command executed.
    ccabusy_it      : in  std_logic; -- CCA busy.
    ccaidle_it      : in  std_logic; -- CCA idle.
    rxstart_it      : in  std_logic; -- Valid packet header detected.
    rxend_it        : in  std_logic; -- End of packet and no auto resp needed.
    txend_it        : in  std_logic; -- End of transmit packet.
    ackto_it        : in  std_logic; -- ACK packet time-out.
  
    --------------------------------------------
    -- Interrupt outputs
    --------------------------------------------
    bup_irq         : out std_logic; -- BuP normal interrupt line.
    bup_fiq         : out std_logic; -- BuP fast interrupt line.
    -- BuPintstat register. Interrupt source is:
    reg_genirq_src  : out std_logic; -- software interrupt.
    reg_timewrap_src: out std_logic; -- wrapping around of buptime.
    reg_ccabusy_src : out std_logic; -- ccabusy.
    reg_ccaidle_src : out std_logic; -- ccaidle.
    reg_rxstart_src : out std_logic; -- rx packet start.
    reg_rxend_src   : out std_logic; -- rx packet end.
    reg_txend_src   : out std_logic; -- tx packet end.
    reg_txstartirq_src : out std_logic; -- tx packet start.
    reg_txstartfiq_src : out std_logic; -- tx packet start (fast interrupt).
    reg_ackto_src   : out std_logic; -- ACK time-out (fast interrupt).
    -- Absolute count interrupt sources
    reg_abscntirq_src : out std_logic;
    reg_abscntfiq_src : out std_logic;
    reg_abscnt_src    : out std_logic_vector(num_abstimer_g-1 downto 0);
    -- BuPinttime register.
    reg_inttime     : out std_logic_vector(25 downto 0)  -- interrupt time tag.
  );

  end component;


----------------------
-- Source: Good
----------------------
  component bup2_timers
  generic (
    num_queues_g      : integer := 4;
    num_abstimer_g  : integer := 16 -- number of absolute count timers (max is 16)
    );
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n             : in  std_logic; -- Reset.
    pclk                : in  std_logic; -- APB clock.
    buptimer_clk        : in  std_logic; -- Clock not gated.
    enable_1mhz         : in  std_logic; -- Enable at 1 MHz.
    mode32k             : in  std_logic; -- buptimer_clk = 32kHz when high

    --------------------------------------------
    -- BuP Timer Control.
    --------------------------------------------
    reg_buptimer        : in  std_logic_vector( 25 downto 0); -- value from register
    write_buptimer      : in  std_logic; -- update buptimer with register value
    write_buptimer_done : out std_logic; -- update done.
    -- BuPtimer register when read
    bup_timer           : out std_logic_vector(25 downto 0);

    -- Pulse interrupt sent on buptime wrapping around.
    timewrap_interrupt  : out std_logic;
    
    --------------------------------------
    -- Channel assessment timers
    --------------------------------------
    phy_txstartend_conf : in  std_logic; -- Transmission status
    reg_chassen         : in  std_logic; -- Channel assessment enable
    reg_ignvcs          : in  std_logic; -- Ignore VCS in channel measurement
    reset_chassbsy      : in  std_logic; -- Reset channel busy timer
    reset_chasstim      : in  std_logic; -- Reset channel timer
    --
    reg_chassbsy        : out std_logic_vector(25 downto 0);
    reg_chasstim        : out std_logic_vector(25 downto 0);

    --------------------------------------
    -- ACK timer control
    --------------------------------------
    txstart_it          : in  std_logic; -- Start of transmission pulse
    txend_it            : in  std_logic; -- End of transmission pulse
    rxstart_it          : in  std_logic; -- Start of reception pulse
    -- Control fields from tx packet control structure:
    ackto_count         : in  std_logic_vector(8 downto 0); -- Time-out value
    -- Enable ACK time-out generation
    ackto_en            : in  std_logic; -- From TX control structure
    reg_ackto_en        : in  std_logic; -- From BuP registers
    --
    ackto_it            : out std_logic; -- Time-out pulse

    --------------------------------------------
    -- Backoff Timer Control.
    --------------------------------------------
    -- initial values from registers for beacon, IAC and ACP[0-7] backoff
    reg_backoff_bcon      : in  std_logic_vector( 9 downto 0); 
    reg_backoff_acp0      : in  std_logic_vector( 9 downto 0); 
    reg_backoff_acp1      : in  std_logic_vector( 9 downto 0); 
    reg_backoff_acp2      : in  std_logic_vector( 9 downto 0); 
    reg_backoff_acp3      : in  std_logic_vector( 9 downto 0); 
    reg_backoff_acp4      : in  std_logic_vector( 9 downto 0); 
    reg_backoff_acp5      : in  std_logic_vector( 9 downto 0); 
    reg_backoff_acp6      : in  std_logic_vector( 9 downto 0); 
    reg_backoff_acp7      : in  std_logic_vector( 9 downto 0); 

    -- update beacon, IAC and ACP[0-7] backoff timer with init value
    write_backoff_bcon      : in  std_logic;
    write_backoff_iac       : in  std_logic;
    write_backoff_acp0      : in  std_logic;
    write_backoff_acp1      : in  std_logic;
    write_backoff_acp2      : in  std_logic;
    write_backoff_acp3      : in  std_logic;
    write_backoff_acp4      : in  std_logic;
    write_backoff_acp5      : in  std_logic;
    write_backoff_acp6      : in  std_logic;
    write_backoff_acp7      : in  std_logic;

    -- Backoff registers when read
    backoff_timer_bcon    : out std_logic_vector( 9 downto 0);
    backoff_timer_acp0    : out std_logic_vector( 9 downto 0);
    backoff_timer_acp1    : out std_logic_vector( 9 downto 0);
    backoff_timer_acp2    : out std_logic_vector( 9 downto 0);
    backoff_timer_acp3    : out std_logic_vector( 9 downto 0);
    backoff_timer_acp4    : out std_logic_vector( 9 downto 0);
    backoff_timer_acp5    : out std_logic_vector( 9 downto 0);
    backoff_timer_acp6    : out std_logic_vector( 9 downto 0);
    backoff_timer_acp7    : out std_logic_vector( 9 downto 0);
    
    --------------------------------------------
    -- BUP TX control
    --------------------------------------------
    -- backoff timer enable
    backenable_bcon       : in  std_logic; 
    backenable_acp0       : in  std_logic; 
    backenable_acp1       : in  std_logic; 
    backenable_acp2       : in  std_logic; 
    backenable_acp3       : in  std_logic; 
    backenable_acp4       : in  std_logic; 
    backenable_acp5       : in  std_logic; 
    backenable_acp6       : in  std_logic; 
    backenable_acp7       : in  std_logic; 

    -- transmit enable
    txenable_iac          : in  std_logic;
    txenable_bcon         : in  std_logic;
    txenable_acp0         : in  std_logic;
    txenable_acp1         : in  std_logic;
    txenable_acp2         : in  std_logic;
    txenable_acp3         : in  std_logic;
    txenable_acp4         : in  std_logic;
    txenable_acp5         : in  std_logic;
    txenable_acp6         : in  std_logic;
    txenable_acp7         : in  std_logic;
    forcetxdis            : in  std_logic; -- Disable all TX queues.

    -- inter frame spacing : number of MACSlots added to SIFS
    ifs_iac               : in  std_logic_vector(3 downto 0);
    ifs_bcon              : in  std_logic_vector(3 downto 0);
    ifs_acp0              : in  std_logic_vector(3 downto 0);
    ifs_acp1              : in  std_logic_vector(3 downto 0);
    ifs_acp2              : in  std_logic_vector(3 downto 0);
    ifs_acp3              : in  std_logic_vector(3 downto 0);
    ifs_acp4              : in  std_logic_vector(3 downto 0);
    ifs_acp5              : in  std_logic_vector(3 downto 0);
    ifs_acp6              : in  std_logic_vector(3 downto 0);
    ifs_acp7              : in  std_logic_vector(3 downto 0);
    
    sifs_timer_it         : out std_logic; -- interrupt when sifs reaches 0.
    backoff_timer_it      : out std_logic; -- interrupt when backoff reaches 0.
    txstartdel_flag       : out std_logic; -- Flag set when less than txstartdel us left in SIFS
    iac_without_ifs       : out std_logic; -- flag set when no IFS in IAC queue
    -- queue that generated the it :
    --          1000 : IAC
    --          1001 : Beacon
    --   0000 - 0111 : ACP[0-7]
    queue_it_num          : out std_logic_vector(3 downto 0);

    -- BuPvcs register.
    vcs_enable   : in  std_logic; -- Virtual carrier sense enable.
    vcs          : in  std_logic_vector(25 downto 0); -- Time tag at which VCS should end
    reset_vcs    : out std_logic; -- reset vcs_enable
    
    -- BUPControl register
    reg_cntxtsel   : in std_logic; -- 0: select BCON context ; 
                                   -- 1: select ACP[0-7] context
    -- low power clock freq selection : 0 : 32kHz ; 1 : 32.768kHz
    reg_clk32sel   : in  std_logic_vector(1 downto 0); 
    
    -- BuPcount register (Durations expressed in us).
    reg_txstartdel : in  std_logic_vector(2 downto 0); -- TX start delay
    reg_macslot    : in  std_logic_vector(7 downto 0); -- MAC slots.
    reg_txsifsb    : in  std_logic_vector(5 downto 0); -- SIFS period after TX (modem b)
    reg_rxsifsb    : in  std_logic_vector(5 downto 0); -- SIFS period after RX (modem b)
    reg_txsifsa    : in  std_logic_vector(5 downto 0); -- SIFS period after TX (modem a)
    reg_rxsifsa    : in  std_logic_vector(5 downto 0); -- SIFS period after RX (modem a)
    reg_sifs       : in  std_logic_vector(5 downto 0); -- SIFS after CCAidle or
                                                       -- absolute count events
    -- Events to trigger the SIFS counter
    tx_end              : in  std_logic; -- end of transmitted packet
    rx_end              : in  std_logic; -- end of received packet
    phy_cca_ind         : in  std_logic; -- CCA status
    bup_sm_idle         : in  std_logic; -- no packet in progress when high
    -- Indicates what was the previous packet (TX or RX)
    rx_packet_type      : in  std_logic;  -- 0 : modem b RX packet; 1 modem a RX packet
    tx_packet_type      : in  std_logic;  -- 0 : modem b TX packet; 1 modem a TX packet
    tximmstop_sm        : in  std_logic; -- Immediate stop from the state machines
    
    --------------------------------------------
    -- Absolute count timers
    --------------------------------------------
    -- BuPabscnt registers.
    reg_abstime0          : in  std_logic_vector(25 downto 0);
    reg_abstime1          : in  std_logic_vector(25 downto 0);
    reg_abstime2          : in  std_logic_vector(25 downto 0);
    reg_abstime3          : in  std_logic_vector(25 downto 0);
    reg_abstime4          : in  std_logic_vector(25 downto 0);
    reg_abstime5          : in  std_logic_vector(25 downto 0);
    reg_abstime6          : in  std_logic_vector(25 downto 0);
    reg_abstime7          : in  std_logic_vector(25 downto 0);
    reg_abstime8          : in  std_logic_vector(25 downto 0);
    reg_abstime9          : in  std_logic_vector(25 downto 0);
    reg_abstime10         : in  std_logic_vector(25 downto 0);
    reg_abstime11         : in  std_logic_vector(25 downto 0);
    reg_abstime12         : in  std_logic_vector(25 downto 0);
    reg_abstime13         : in  std_logic_vector(25 downto 0);
    reg_abstime14         : in  std_logic_vector(25 downto 0);
    reg_abstime15         : in  std_logic_vector(25 downto 0);
    -- Pulse interrupt sent when absolute counter time tag is reached.
    abscount_it           : out std_logic_vector(num_abstimer_g-1 downto 0);

    --------------------------------------------
    -- Diag ports
    --------------------------------------------
    bup_timers_diag     : out std_logic_vector(7 downto 0)
    );

  end component;


----------------------
-- Source: Good
----------------------
  component bup2_sm
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
  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/crc32/vhdl/rtl/crc32_8.vhd
----------------------
  component crc32_8
  port (
    -- clock and reset
    clk          : in  std_logic;                    
    resetn       : in  std_logic;                   
     
    -- inputs
    data_in      : in  std_logic_vector ( 7 downto 0);
    --             8-bits inputs for parallel computing. 
    ld_init      : in  std_logic;
    --             initialize the CRC
    calc         : in  std_logic;
    --             ask of calculation of the available data.
 
    -- outputs
    crc_out_1st  : out std_logic_vector (7 downto 0); 
    crc_out_2nd  : out std_logic_vector (7 downto 0); 
    crc_out_3rd  : out std_logic_vector (7 downto 0); 
    crc_out_4th  : out std_logic_vector (7 downto 0) 
    --          CRC result
   );

  end component;



 
end bup2_kernel_pkg;
