
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_registers.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.27  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : WILD Burst Processor 2 Registers.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_registers/vhdl/rtl/bup2_registers.vhd,v  
--  Log: bup2_registers.vhd,v  
-- Revision 1.27  2006/03/13 08:43:13  Dr.A
-- #BugId:2328#
-- Increased size of reg_clk32cntl to support 131.072 kHz config
--
-- Revision 1.26  2006/02/03 08:34:37  Dr.A
-- #BugId:1140#
-- Send IAC IFS write indication to the timers
--
-- Revision 1.25  2006/02/02 08:28:23  Dr.A
-- #BugId:1213#
-- Added bit to ignore VCS for channel assessment
--
-- Revision 1.24  2005/10/21 13:22:07  Dr.A
-- #BugId:1246#
-- Added absolute count timers
--
-- Revision 1.23  2005/03/29 08:45:44  Dr.A
-- #BugId:907#
-- Added TX force disable
--
-- Revision 1.22  2005/03/25 11:12:16  Dr.A
-- #BugId:1152#
-- Removed ARTIM counter
--
-- Revision 1.21  2005/03/22 10:15:21  Dr.A
-- #BugId:1152#
-- Arrival time counter enable. Cleaned write_bckoff ports.
--
-- Revision 1.20  2005/02/10 15:20:32  Dr.A
-- #BugId:1041#
-- Use apb0 instead of apb1 to reset CHASSTIM
--
-- Revision 1.19  2005/02/09 16:11:27  Dr.A
-- #BugId:1037#
-- RX buffer registers all aligned on 8bytes boundary
--
-- Revision 1.18  2004/12/23 10:19:56  Dr.A
-- #BugId:835#
-- rxrssi bit 8 stuck to 1 in register read
--
-- Revision 1.17  2004/12/22 17:10:53  Dr.A
-- #BugId:850#
-- Connected iacaftersifs acknowledge
--
-- Revision 1.16  2004/12/20 12:53:03  Dr.A
-- #BugId:702#
-- Added ACK time-out interrupt acknowledge
--
-- Revision 1.15  2004/12/17 13:03:13  Dr.A
-- #BugId:912#
-- Removed 'enable' register
--
-- Revision 1.14  2004/12/10 10:10:39  Dr.A
-- #BugId:640#
-- Added registers for ccaaddinfo and rxant.
-- rxabtcnt min value set to 13.
--
-- Revision 1.13  2004/12/03 14:15:58  Dr.A
-- #BugId:606#
-- Added registers from spec v2.3, for bugs #606, #821/822, #850, #702.
--
-- Revision 1.12  2004/11/10 10:34:01  Dr.A
-- #BugId:837#
-- Added registers for Channel assessment and multi ssid
--
-- Revision 1.11  2004/11/09 14:11:10  Dr.A
-- #BugId:835#
-- RSSI field is now only 7 bits
--
-- Revision 1.10  2004/04/08 14:38:17  Dr.A
-- Added register on prdata busses.
--
-- Revision 1.9  2004/02/06 14:45:05  Dr.F
-- added testdata_in.
--
-- Revision 1.8  2004/02/05 18:28:11  Dr.F
-- removed modsel.
--
-- Revision 1.7  2004/01/21 17:40:54  Dr.F
-- beautified version register.
--
-- Revision 1.6  2004/01/13 07:31:12  Dr.F
-- fixed sensitivity list.
--
-- Revision 1.5  2003/12/12 12:53:55  pbressy
-- correct error on apb write cycle, apb1 insteand of apb0
-- corrected error on apb write cycle, apb1 insteand of apb0
--
-- Revision 1.4  2003/12/11 17:46:10  Dr.F
-- removed multiple drive.
--
-- Revision 1.3  2003/12/11 09:56:55  Dr.F
-- removed multiple drive on int_rssi.
--
-- Revision 1.2  2003/12/05 08:36:48  pbressy
-- added new registers (Coldfire)
--
-- Revision 1.1  2003/11/19 16:25:34  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------
-- Taken from revision 1.9 of bup_registers
--
-- Revision 1.9  2003/11/13 18:42:44  Dr.F
-- added SIFS and low power clock freq selection.
--
-- Revision 1.8  2003/10/21 13:05:38  Dr.A
-- Debugged enablea/b read access.
--
-- Revision 1.7  2003/10/17 13:48:59  sbizet
-- Debugged reg_enablea/b
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.std_logic_unsigned.ALL; 
 
--library bup2_registers_rtl; 
library work;
--use bup2_registers_rtl.bup2_registers_pkg.all;
use work.bup2_registers_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity bup2_registers is
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

end bup2_registers;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of bup2_registers is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type SLV26_ARRAY is array(natural range <>) of std_logic_vector(25 downto 0);
  type SLV10_ARRAY is array(natural range <>) of std_logic_vector(9 downto 0);
  type SLV8_ARRAY  is array(natural range <>) of std_logic_vector(7 downto 0);
  type SLV7_ARRAY  is array(natural range <>) of std_logic_vector(7 downto 0);
  type SLV4_ARRAY  is array(natural range <>) of std_logic_vector(3 downto 0);
  
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Use a signal because arrays of constants are not translated correctly
  -- by the vhdl2verilog tool.
  signal BUPTXCNTL_ACP_ADDR_CT: SLV7_ARRAY(7 downto 0);
  signal BUPABSCNT_ADDR_CT    : SLV8_ARRAY(15 downto 0);

  -- BuPversion register.
  signal int_build       : std_logic_vector(15 downto 0); -- Build number of BuP
  signal int_rel         : std_logic_vector( 7 downto 0); -- Release number.
  signal int_upg         : std_logic_vector( 7 downto 0); -- Upgrade number.

  -- BuPcntl register.
  signal int_forcetxdis  : std_logic; -- Disable all TX queues.
  signal int_tximmstop   : std_logic; -- TX immediate stop.
  signal int_bufempty    : std_logic; -- '1' when RX buffer has been emptied.
  signal int_enrxabort   : std_logic; -- Enable abort of RX packets
  -- low power clock frequency selection
  signal int_clk32sel    : std_logic_vector( 1 downto 0);
  signal int_cntxtsel    : std_logic; -- Select context.

  -- BuPvcs register.
  signal int_vcsenable   : std_logic; -- Virtual carrier sense enable.
  signal int_vcs         : std_logic_vector(25 downto 0); -- VCS time tag.
  
  -- BuPabscnt registers.
  signal int_abstime     : SLV26_ARRAY(15 downto 0);
  signal int_abscnt_irqsel: std_logic_vector(15 downto 0);
  
  -- BuPintmask register: enable/disable interrupts on the following events.
  -- Absolute counter interrupt.
  signal int_abscnt_en   : std_logic_vector(15 downto 0);
  signal int_timewrap_en : std_logic; -- Wrapping around of buptime.
  signal int_ccabusy_en  : std_logic; -- ccabusy.
  signal int_ccaidle_en  : std_logic; -- ccaidle.
  signal int_rxstart_en  : std_logic; -- Rx packet start.
  signal int_rxend_en    : std_logic; -- Rx packet end.
  signal int_txend_en    : std_logic; -- Tx packet end.
  signal int_txstartirq_en : std_logic; -- Tx packet start.
  signal int_txstartfiq_en : std_logic; -- TX packet start (fast interrupt).
  signal int_ackto_en    : std_logic; -- Enable interrupt on ACK packet time-out

  -- BuPcount register (Durations expressed in us).
  signal int_txdstartdel : std_logic_vector(2 downto 0); -- TX start delay.
  signal int_macslot     : std_logic_vector(7 downto 0); -- MAC slots.
  signal int_txsifsb     : std_logic_vector(5 downto 0); -- SIFS period after TX (modem b)
  signal int_rxsifsb     : std_logic_vector(5 downto 0); -- SIFS period after RX (modem b)
  signal int_txsifsa     : std_logic_vector(5 downto 0); -- SIFS period after TX (modem a)
  signal int_rxsifsa     : std_logic_vector(5 downto 0); -- SIFS period after RX (modem a)
  signal int_sifs        : std_logic_vector(5 downto 0); -- SIFS after CCAidle or
                                                         -- absolute count events
  -- Buptxcntl_bcon register:
  signal int_bcon_bakenable : std_logic; -- '1' to enable backoff counter.
  signal int_bcon_txenable  : std_logic; -- '1' to enable packets transmission.
  -- Number of MAC slots to add to create Beacon inter-frame spacing.
  signal int_bcon_ifs       : std_logic_vector( 3 downto 0);
  -- Beacon Backoff counter init value.
  signal int_bcon_backoff   : std_logic_vector( 9 downto 0);

  -- BuPtxcntl_acp register: 
  -- '1' to enable backoff counter.
  signal int_acp_bakenable  : std_logic_vector(7 downto 0);
  -- '1' to enable packets transmission.
  signal int_acp_txenable   : std_logic_vector(7 downto 0);
  -- Number of MAC slots to add to create ACP inter-frame spacing.
  signal int_acp_ifs        : SLV4_ARRAY(7 downto 0);
  -- Signals for verilog conversion.
  signal int_acp_ifs7       : std_logic_vector(3 downto 0);
  signal int_acp_ifs6       : std_logic_vector(3 downto 0);
  signal int_acp_ifs5       : std_logic_vector(3 downto 0);
  signal int_acp_ifs4       : std_logic_vector(3 downto 0);
  signal int_acp_ifs3       : std_logic_vector(3 downto 0);
  signal int_acp_ifs2       : std_logic_vector(3 downto 0);
  signal int_acp_ifs1       : std_logic_vector(3 downto 0);
  signal int_acp_ifs0       : std_logic_vector(3 downto 0);
  -- ACP Backoff counter init value.
  signal int_acp_backoff    : SLV10_ARRAY(7 downto 0);
  
  -- Buptxcntl_iac register:
  signal int_iac_txenable  : std_logic; -- '1' to enable packets transmission.
  -- Number of MAC slots to add to create IAC inter-frame spacing.
  signal int_iac_ifs       : std_logic_vector( 3 downto 0);

  -- BuPtxptr register: Start address of the transmit buffer.
  signal int_buptxptr    : std_logic_vector(31 downto 0);

  -- BuPrxptr register: Start address of the receive buffer.
  signal int_buprxptr    : std_logic_vector(28 downto 0);

  -- BuPrxoff register: Start address of the next packet to be stored inside
  -- the RX ring buffer.
  signal int_rxoff       : std_logic_vector(12 downto 0);

  -- BuPrxsize register: size in bytes of the Rx ring buffer.
  signal int_rxsize      : std_logic_vector(12 downto 0); 

  -- BuPrxunload register: pointer to the next packet to be retreived from 
  signal int_rxunload    : std_logic_vector(12 downto 0); -- RX buffer.

  -- Bupaddr1l/h registers.
  signal int_addr1       : std_logic_vector(47 downto 0); -- Address 1.

  -- Bupaddr1mask register.
  signal int_addr1mskh   : std_logic_vector( 3 downto 0); -- Mask Addr1(43:40)
  signal int_addr1mskl   : std_logic_vector( 3 downto 0); -- Mask Addr1(27:24)

  -- BupRxAbtCnt register: Number of bytes to store after an RX abort.
  signal int_rxabtcnt    : std_logic_vector(5 downto 0);

  -- BuPTest register.
  signal int_testenable  : std_logic; -- '1' for test mode.
  signal int_datatype    : std_logic_vector( 1 downto 0); -- Select test pattern
  signal int_fcsdisb     : std_logic; -- '0' to enable FCS computation.
  signal int_buptestmode : std_logic_vector( 1 downto 0); -- Select test type.

  -- BuPTestdata register read (transmit mode).
  -- Continuous transmit test mode: data pattern for transmission test.
  signal int_testpattern : std_logic_vector(31 downto 0);
  signal reg_testdata_in : std_logic_vector(31 downto 0);

  -- Pointer to the IAC control structure
  signal int_csiac_ptr   : std_logic_vector(31 downto 0);

  -- Scratch registers
  signal int_scratch0    : std_logic_vector(31 downto 0); 
  signal int_scratch1    : std_logic_vector(31 downto 0); 
  signal int_scratch2    : std_logic_vector(31 downto 0); 
  signal int_scratch3    : std_logic_vector(31 downto 0); 

  -- Channel load registers
  signal int_chassen     : std_logic;
  signal int_ignvcs      : std_logic;
  
  -- Combinational signals for prdata buses.
  signal next_apb0_prdata: std_logic_vector(31 downto 0);
  signal next_apb1_prdata: std_logic_vector(31 downto 0);
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- Array used in generate statement.
  BUPTXCNTL_ACP_ADDR_CT(7) <= BUPTXCNTL_ACP7_ADDR_CT;
  BUPTXCNTL_ACP_ADDR_CT(6) <= BUPTXCNTL_ACP6_ADDR_CT;
  BUPTXCNTL_ACP_ADDR_CT(5) <= BUPTXCNTL_ACP5_ADDR_CT;
  BUPTXCNTL_ACP_ADDR_CT(4) <= BUPTXCNTL_ACP4_ADDR_CT;
  BUPTXCNTL_ACP_ADDR_CT(3) <= BUPTXCNTL_ACP3_ADDR_CT;
  BUPTXCNTL_ACP_ADDR_CT(2) <= BUPTXCNTL_ACP2_ADDR_CT;
  BUPTXCNTL_ACP_ADDR_CT(1) <= BUPTXCNTL_ACP1_ADDR_CT;
  BUPTXCNTL_ACP_ADDR_CT(0) <= BUPTXCNTL_ACP0_ADDR_CT;
  
  BUPABSCNT_ADDR_CT(0)  <= BUPABSCNT0_ADDR_CT;
  BUPABSCNT_ADDR_CT(1)  <= BUPABSCNT1_ADDR_CT;
  BUPABSCNT_ADDR_CT(2)  <= BUPABSCNT2_ADDR_CT;
  BUPABSCNT_ADDR_CT(3)  <= BUPABSCNT3_ADDR_CT;
  BUPABSCNT_ADDR_CT(4)  <= BUPABSCNT4_ADDR_CT;
  BUPABSCNT_ADDR_CT(5)  <= BUPABSCNT5_ADDR_CT;
  BUPABSCNT_ADDR_CT(6)  <= BUPABSCNT6_ADDR_CT;
  BUPABSCNT_ADDR_CT(7)  <= BUPABSCNT7_ADDR_CT;
  BUPABSCNT_ADDR_CT(8)  <= BUPABSCNT8_ADDR_CT;
  BUPABSCNT_ADDR_CT(9)  <= BUPABSCNT9_ADDR_CT;
  BUPABSCNT_ADDR_CT(10) <= BUPABSCNT10_ADDR_CT;
  BUPABSCNT_ADDR_CT(11) <= BUPABSCNT11_ADDR_CT;
  BUPABSCNT_ADDR_CT(12) <= BUPABSCNT12_ADDR_CT;
  BUPABSCNT_ADDR_CT(13) <= BUPABSCNT13_ADDR_CT;
  BUPABSCNT_ADDR_CT(14) <= BUPABSCNT14_ADDR_CT;
  BUPABSCNT_ADDR_CT(15) <= BUPABSCNT15_ADDR_CT;
  
  -- Signals for verilog conversion.
  -- int_acp_ifs
  int_acp_ifs7 <= int_acp_ifs(7);
  int_acp_ifs6 <= int_acp_ifs(6);
  int_acp_ifs5 <= int_acp_ifs(5);
  int_acp_ifs4 <= int_acp_ifs(4);
  int_acp_ifs3 <= int_acp_ifs(3);
  int_acp_ifs2 <= int_acp_ifs(2);
  int_acp_ifs1 <= int_acp_ifs(1);
  int_acp_ifs0 <= int_acp_ifs(0);

  ------------------------------------------------------------------------------
  -- Assign register outputs.
  ------------------------------------------------------------------------------
  -- BuPcntl register.
  reg_forcetxdis   <= int_forcetxdis;
  reg_tximmstop    <= int_tximmstop;
  reg_bufempty     <= int_bufempty;
  reg_cntxtsel     <= int_cntxtsel;
  reg_enrxabort    <= int_enrxabort;
  reg_clk32sel     <= int_clk32sel;
  -- BuPvcs register.
  reg_vcsenable    <= int_vcsenable;
  reg_vcs          <= int_vcs;
  -- BuPintmask register.
  reg_timewrap_en  <= int_timewrap_en;  
  reg_ccabusy_en   <= int_ccabusy_en;  
  reg_ccaidle_en   <= int_ccaidle_en;  
  reg_rxstart_en   <= int_rxstart_en;  
  reg_rxend_en     <= int_rxend_en;  
  reg_txend_en     <= int_txend_en;  
  reg_txstartirq_en <= int_txstartirq_en;  
  reg_txstartfiq_en <= int_txstartfiq_en;  
  reg_ackto_en     <= int_ackto_en;  
  -- BuPcount register.
  reg_txdstartdel  <= int_txdstartdel;
  reg_macslot      <= int_macslot;
  reg_txsifsb      <= int_txsifsb;
  reg_rxsifsb      <= int_rxsifsb;
  reg_txsifsa      <= int_txsifsa;
  reg_rxsifsa      <= int_rxsifsa;
  reg_sifs         <= int_sifs;
  -- BuPtxcntl_bcon register.
  reg_bcon_bakenable <= int_bcon_bakenable;
  reg_bcon_txenable  <= int_bcon_txenable;
  reg_bcon_ifs       <= int_bcon_ifs;
  reg_bcon_backoff   <= int_bcon_backoff; 
  
  -- BuPabscnt registers.
  abs15_gen: if (num_abstimer_g > 15) generate
    reg_abstime15         <= int_abstime(15);
    reg_abscnt_irqsel(15) <= int_abscnt_irqsel(15);
    reg_abscnt_en(15)     <= int_abscnt_en(15);  
  end generate abs15_gen;
  abs14_gen: if (num_abstimer_g > 14) generate
    reg_abstime14         <= int_abstime(14);
    reg_abscnt_irqsel(14) <= int_abscnt_irqsel(14);
    reg_abscnt_en(14)     <= int_abscnt_en(14);  
  end generate abs14_gen;
  abs13_gen: if (num_abstimer_g > 13) generate
    reg_abstime13         <= int_abstime(13);
    reg_abscnt_irqsel(13) <= int_abscnt_irqsel(13);
    reg_abscnt_en(13)     <= int_abscnt_en(13);  
  end generate abs13_gen;
  abs12_gen: if (num_abstimer_g > 12) generate
    reg_abstime12         <= int_abstime(12);
    reg_abscnt_irqsel(12) <= int_abscnt_irqsel(12);
    reg_abscnt_en(12)     <= int_abscnt_en(12);  
  end generate abs12_gen;
  abs11_gen: if (num_abstimer_g > 11) generate
    reg_abstime11         <= int_abstime(11);
    reg_abscnt_irqsel(11) <= int_abscnt_irqsel(11);
    reg_abscnt_en(11)     <= int_abscnt_en(11);  
  end generate abs11_gen;
  abs10_gen: if (num_abstimer_g > 10) generate
    reg_abstime10         <= int_abstime(10);
    reg_abscnt_irqsel(10) <= int_abscnt_irqsel(10);
    reg_abscnt_en(10)     <= int_abscnt_en(10);  
  end generate abs10_gen;
  abs9_gen: if (num_abstimer_g > 9) generate
    reg_abstime9          <= int_abstime(9);
    reg_abscnt_irqsel(9)  <= int_abscnt_irqsel(9);
    reg_abscnt_en(9)      <= int_abscnt_en(9);  
  end generate abs9_gen;
  abs8_gen: if (num_abstimer_g > 8) generate
    reg_abstime8          <= int_abstime(8);
    reg_abscnt_irqsel(8)  <= int_abscnt_irqsel(8);
    reg_abscnt_en(8)      <= int_abscnt_en(8);  
  end generate abs8_gen;
  abs7_gen: if (num_abstimer_g > 7) generate
    reg_abstime7          <= int_abstime(7);
    reg_abscnt_irqsel(7)  <= int_abscnt_irqsel(7);
    reg_abscnt_en(7)      <= int_abscnt_en(7);  
  end generate abs7_gen;
  abs6_gen: if (num_abstimer_g > 6) generate
    reg_abstime6          <= int_abstime(6);
    reg_abscnt_irqsel(6)  <= int_abscnt_irqsel(6);
    reg_abscnt_en(6)      <= int_abscnt_en(6);  
  end generate abs6_gen;
  abs5_gen: if (num_abstimer_g > 5) generate
    reg_abstime5          <= int_abstime(5);
    reg_abscnt_irqsel(5)  <= int_abscnt_irqsel(5);
    reg_abscnt_en(5)      <= int_abscnt_en(5);  
  end generate abs5_gen;
  abs4_gen: if (num_abstimer_g > 4) generate
    reg_abstime4          <= int_abstime(4);
    reg_abscnt_irqsel(4)  <= int_abscnt_irqsel(4);
    reg_abscnt_en(4)      <= int_abscnt_en(4);  
  end generate abs4_gen;
  abs3_gen: if (num_abstimer_g > 3) generate
    reg_abstime3          <= int_abstime(3);
    reg_abscnt_irqsel(3)  <= int_abscnt_irqsel(3);
    reg_abscnt_en(3)      <= int_abscnt_en(3);  
  end generate abs3_gen;
  abs2_gen: if (num_abstimer_g > 2) generate
    reg_abstime2          <= int_abstime(2);
    reg_abscnt_irqsel(2)  <= int_abscnt_irqsel(2);
    reg_abscnt_en(2)      <= int_abscnt_en(2);  
  end generate abs2_gen;
  abs1_gen: if (num_abstimer_g > 1) generate
    reg_abstime1          <= int_abstime(1);
    reg_abscnt_irqsel(1)  <= int_abscnt_irqsel(1);
    reg_abscnt_en(1)      <= int_abscnt_en(1);  
  end generate abs1_gen;
  abs0_gen: if (num_abstimer_g > 0) generate
    reg_abstime0          <= int_abstime(0);
    reg_abscnt_irqsel(0)  <= int_abscnt_irqsel(0);
    reg_abscnt_en(0)      <= int_abscnt_en(0);  
  end generate abs0_gen;



  -- ACP registers.
  acp7_gen: if (num_queues_g > 7) generate
    -- Buptxcntl_acp register.
    reg_acp_bakenable7 <= int_acp_bakenable(7);
    reg_acp_txenable7  <= int_acp_txenable(7);
    reg_acp_ifs7       <= int_acp_ifs7; 
    reg_acp_backoff7   <= int_acp_backoff(7);
  end generate acp7_gen;
  
  acp6_gen: if (num_queues_g > 6) generate
    -- Buptxcntl_acp register.
    reg_acp_bakenable6 <= int_acp_bakenable(6);
    reg_acp_txenable6  <= int_acp_txenable(6);
    reg_acp_ifs6       <= int_acp_ifs6; 
    reg_acp_backoff6   <= int_acp_backoff(6);
  end generate acp6_gen;
  
  acp5_gen: if (num_queues_g > 5) generate
    -- Buptxcntl_acp register.
    reg_acp_bakenable5 <= int_acp_bakenable(5);
    reg_acp_txenable5  <= int_acp_txenable(5);
    reg_acp_ifs5       <= int_acp_ifs5; 
    reg_acp_backoff5   <= int_acp_backoff(5);
  end generate acp5_gen;
  
  acp4_gen: if (num_queues_g > 4) generate
    -- Buptxcntl_acp register.
    reg_acp_bakenable4 <= int_acp_bakenable(4);
    reg_acp_txenable4  <= int_acp_txenable(4);
    reg_acp_ifs4       <= int_acp_ifs4; 
    reg_acp_backoff4   <= int_acp_backoff(4);
  end generate acp4_gen;
  
  acp3_gen: if (num_queues_g > 3) generate
    -- Buptxcntl_acp register.
    reg_acp_bakenable3 <= int_acp_bakenable(3);
    reg_acp_txenable3  <= int_acp_txenable(3);
    reg_acp_ifs3       <= int_acp_ifs3; 
    reg_acp_backoff3   <= int_acp_backoff(3);
  end generate acp3_gen;
  
  acp2_gen: if (num_queues_g > 2) generate
    -- Buptxcntl_acp register.
    reg_acp_bakenable2 <= int_acp_bakenable(2);
    reg_acp_txenable2  <= int_acp_txenable(2);
    reg_acp_ifs2       <= int_acp_ifs2; 
    reg_acp_backoff2   <= int_acp_backoff(2);
  end generate acp2_gen;
  
  acp1_gen: if (num_queues_g > 1) generate
    -- Buptxcntl_acp register.
    reg_acp_bakenable1 <= int_acp_bakenable(1);
    reg_acp_txenable1  <= int_acp_txenable(1);
    reg_acp_ifs1       <= int_acp_ifs1; 
    reg_acp_backoff1   <= int_acp_backoff(1);
  end generate acp1_gen;
  
  acp0_gen: if (num_queues_g > 0) generate
    -- Buptxcntl_acp register.
    reg_acp_bakenable0 <= int_acp_bakenable(0);
    reg_acp_txenable0  <= int_acp_txenable(0);
    reg_acp_ifs0       <= int_acp_ifs0; 
    reg_acp_backoff0   <= int_acp_backoff(0);
  end generate acp0_gen;

  -- BuPtxcntl_iac register.
  -- iac_txenable is gated here because it goes to several blocks.
  -- Others queues enables are gated in the BuP timers.
  reg_iac_txenable  <= int_iac_txenable and not int_forcetxdis;
  reg_iac_ifs       <= int_iac_ifs;
  -- BuPtxptr    register.
  reg_buptxptr     <= int_buptxptr;
  -- BuPrxptr register.
  reg_buprxptr     <= int_buprxptr & "000";
  -- BuPrxoff register.
  reg_rxoff        <= int_rxoff & "000";
  -- BuPrxsize register.
  reg_rxsize       <= int_rxsize & "000";
  -- BuPrxunload register.
  reg_rxunload     <= int_rxunload & "000";
  -- Bupaddr1l/h registers.
  reg_addr1        <= int_addr1;
  -- Bupaddr1mask register.
  reg_addr1mskh    <= int_addr1mskh;
  reg_addr1mskl    <= int_addr1mskl;
  -- BupTest register.
  reg_testenable   <= int_testenable;
  reg_datatype     <= int_datatype;
  reg_fcsdisb      <= int_fcsdisb;
  reg_buptestmode  <= int_buptestmode;  
  -- BuPTestdata register.
  reg_testpattern  <= int_testpattern;
  -- Buprxabtcnt register.
  reg_rxabtcnt     <= int_rxabtcnt;
  -- Channel assessment registers.
  reg_chassen      <= int_chassen;
  reg_ignvcs       <= int_ignvcs;
  -- Pointer to the IAC control structure
  reg_csiac_ptr    <= int_csiac_ptr; 
  
  ------------------------------------------------------------------------------
  -- Fixed registers.
  ------------------------------------------------------------------------------
  -- BuPversion register.
  int_build        <= BUPBUILD_CT;
  int_rel          <= BUPRELEASE_CT;
  int_upg          <= BUPUPGRADE_CT;


  ------------------------------------------------------------------------------
  -- Register write
  ------------------------------------------------------------------------------
  -- The write cycle follows the timing shown in page 5-5 of the AMBA
  -- Specification.

  apb_write_pr: process (pclk, reset_n)
  begin
    if (reset_n = '0') then
      -- Reset BuPcntl.
      reg_ccarst      <= '0';
      int_forcetxdis  <= '0';
      int_tximmstop   <= '0';
      int_bufempty    <= '0';
      genirq          <= '0';
      int_enrxabort   <= '0';
      int_clk32sel    <= "00";
      int_cntxtsel    <= '0';
      
      -- Reset BuPvcs.
      int_vcsenable   <= '0';
      int_vcs         <= (others => '0');
      -- Reset BupTime register.
      reg_buptimer    <= (others => '0');
      write_buptimer  <= '0';
      -- Reset BuPintmask.
      int_timewrap_en <= '0';
      int_ccabusy_en  <= '0'; 
      int_ccaidle_en  <= '0'; 
      int_rxstart_en  <= '0'; 
      int_rxend_en    <= '0'; 
      int_txend_en    <= '0'; 
      int_txstartirq_en <= '0';
      int_txstartfiq_en <= '0';
      int_ackto_en    <= '0';
      -- Reset BuPintack.
      reg_iacaftersifs_ack   <= '0';
      reg_genirq_ack   <= '0';
      reg_timewrap_ack <= '0';
      reg_ccabusy_ack  <= '0';
      reg_ccaidle_ack  <= '0';
      reg_rxstart_ack  <= '0';
      reg_rxend_ack    <= '0';
      reg_txend_ack    <= '0';
      reg_txstartirq_ack <= '0';
      reg_txstartfiq_ack <= '0';
      reg_ackto_ack    <= '0';
      -- Reset BuPcount.
      int_txdstartdel <= (others => '0');
      int_macslot     <= MACSLOT_INIT_CT;
      int_txsifsb     <= (others => '0');
      int_rxsifsb     <= (others => '0');
      int_txsifsa     <= (others => '0');
      int_rxsifsa     <= (others => '0');
      int_sifs        <= (others => '0');
      -- Reset BuPtxcntl_bcon
      int_bcon_bakenable <= '0';
      int_bcon_txenable  <= '0';
      int_bcon_ifs       <= (others => '0');
      int_bcon_backoff   <= (others => '0');
      write_bcon_bkoff   <= '0';
      -- Reset BuPtxcntl_iac
      int_iac_txenable   <= '0';
      int_iac_ifs        <= (others => '0');
      write_iac_bkoff    <= '0';
      -- Reset BuPtxptr.
      int_buptxptr    <= (others => '0');
      -- Reset BuPrxptr.
      int_buprxptr    <= (others => '0');
      -- Reset BuPrxoff.
      int_rxoff       <= (others => '0');
      -- Reset BuPrxsize.
      int_rxsize      <= (others => '0');
      -- Reset BuPrxunload.
      int_rxunload    <= (others => '0');
      -- Reset Bupaddr1l/h.
      int_addr1       <= (others => '0');
      -- Reset Bupaddr1mask.
      int_addr1mskh   <= (others => '0');
      int_addr1mskl   <= (others => '0');
      -- Reset BuPtest.
      int_testenable  <= '0';
      int_datatype    <= (others => '0');  
      int_fcsdisb     <= '0';
      int_buptestmode <= (others => '0');
      -- Reset BuPtestdata register.
      int_testpattern <= (others => '0');
      reg_testdata_in <= (others => '0');
      -- Reset BuPRXabtcnt register.
      int_rxabtcnt    <= RXABTCNT_MIN_CT;
      
      -- IAC Tx control Structure ptr
      int_csiac_ptr   <= (others => '0');
     
      int_scratch0    <= (others => '0');
      int_scratch1    <= (others => '0');
      int_scratch2    <= (others => '0');
      int_scratch3    <= (others => '0');
      
      -- Channel assessment registers
      reset_chassbsy  <= '0';
      reset_chasstim  <= '0';
      int_chassen     <= '0';
      int_ignvcs      <= '0';

      
    elsif (pclk'event and pclk = '1') then
      reg_iacaftersifs_ack     <= '0';
      reg_genirq_ack     <= '0';
      reg_timewrap_ack   <= '0';
      reg_ccabusy_ack    <= '0';
      reg_ccaidle_ack    <= '0';
      reg_rxstart_ack    <= '0';
      reg_rxend_ack      <= '0';
      reg_txend_ack      <= '0';
      reg_txstartirq_ack <= '0';
      reg_txstartfiq_ack <= '0';
      reg_ackto_ack      <= '0';
      
      genirq             <= '0';
      
      reg_testdata_in    <= testdata_in;
      
      -- Reset reg_ccarst when phy_ccarst_conf is received.
      if (phy_ccarst_conf = '1') then
        reg_ccarst     <= '0';
      end if;

      -- Reset int_vcsenable at VCS time tag.
      if (reset_vcs = '1') then
        int_vcsenable   <= '0';
      end if;

      -- Timer updated, reset write_buptimer.
      if (write_buptimer_done = '1') then
        write_buptimer <= '0';
      end if;
      
      -- Beacon backoff timer updated, reset write_bcon_bkoff.
      write_bcon_bkoff <= '0';
      
      -- IAC IFS timer updated, reset write_iac_bkoff.
      write_iac_bkoff  <= '0';
      
      -- Reset acp_txenable after transmission of the packet.
      if (reset_iac_txen = '1') then
        int_iac_txenable <= '0';
      end if;

      -- Reset bcon_txenable after transmission of the packet.
      if (reset_bcon_txen = '1') then
        int_bcon_txenable <= '0';
      end if;

      -- New packet stored in RX buffer, reset bufempty.
      if (reset_bufempty = '1') then
        int_bufempty <= '0';
      end if;

      -- Channel assessment timer reset signals are pulses.
      reset_chassbsy <= '0';
      reset_chasstim <= '0';
      
            
      if (apb1_penable = '1' and apb1_psel = '1' and apb1_pwrite = '1') then
        case apb1_paddr is

          when BUPCNTL_ADDR_CT      =>  
            reg_ccarst      <= apb1_pwdata(14);
            int_forcetxdis  <= apb1_pwdata(13);
            int_tximmstop   <= apb1_pwdata(12);
            int_bufempty    <= apb1_pwdata(9);
            genirq          <= apb1_pwdata(8); 
            int_enrxabort   <= apb1_pwdata(4);
            int_clk32sel    <= apb1_pwdata(2 downto 1);
            int_cntxtsel    <= apb1_pwdata(0);

          when BUPVCS_ADDR_CT       =>  
            int_vcsenable   <= apb1_pwdata(31);
            int_vcs         <= apb1_pwdata(25 downto 0);

          when BUPTIME_ADDR_CT      =>       
            reg_buptimer    <= apb1_pwdata(25 downto 0);
            write_buptimer  <= '1'; -- Timer must be updated with the new value.

          when BUPINTMASK_ADDR_CT   =>
            int_ackto_en    <= apb1_pwdata(10);
            int_txstartfiq_en <= apb1_pwdata(9);
            int_timewrap_en <= apb1_pwdata(6);
            int_ccabusy_en  <= apb1_pwdata(5);
            int_ccaidle_en  <= apb1_pwdata(4);
            int_rxstart_en  <= apb1_pwdata(3);
            int_rxend_en    <= apb1_pwdata(2);
            int_txend_en    <= apb1_pwdata(1);
            int_txstartirq_en <= apb1_pwdata(0);

          when BUPINTACK_ADDR_CT    =>  
            reg_iacaftersifs_ack <= apb1_pwdata(31);
            reg_ackto_ack        <= apb1_pwdata(10);
            reg_txstartfiq_ack   <= apb1_pwdata(9);
            reg_genirq_ack   <= apb1_pwdata(8);
            reg_timewrap_ack <= apb1_pwdata(6);
            reg_ccabusy_ack  <= apb1_pwdata(5);
            reg_ccaidle_ack  <= apb1_pwdata(4);
            reg_rxstart_ack  <= apb1_pwdata(3);
            reg_rxend_ack    <= apb1_pwdata(2);
            reg_txend_ack    <= apb1_pwdata(1);
            reg_txstartirq_ack <= apb1_pwdata(0);

          when BUPCOUNT0_ADDR_CT     =>
            int_txdstartdel <= apb1_pwdata(31 downto 29);
            int_txsifsb     <= apb1_pwdata(21 downto 16);
            int_rxsifsb     <= apb1_pwdata(13 downto 8);
            int_sifs        <= apb1_pwdata( 5 downto 0);

          when BUPCOUNT1_ADDR_CT     =>
            int_txsifsa     <= apb1_pwdata(21 downto 16);
            int_rxsifsa     <= apb1_pwdata(13 downto 8);

          when BUPCOUNT2_ADDR_CT  =>
            int_macslot     <= apb1_pwdata( 7 downto 0);

          when BUPTXCNTL_BCON_ADDR_CT =>
            int_bcon_bakenable <= apb1_pwdata(24);
            int_bcon_txenable  <= apb1_pwdata(23);
            int_bcon_ifs       <= apb1_pwdata(19 downto 16);
            int_bcon_backoff   <= apb1_pwdata( 9 downto 0);
            write_bcon_bkoff   <= '1';

          when BUPTXCNTL_IAC_ADDR_CT =>
            int_iac_txenable   <= apb1_pwdata(23);
            int_iac_ifs        <= apb1_pwdata(19 downto 16);
            write_iac_bkoff    <= '1';

          when BUPTXPTR_ADDR_CT     =>  
            int_buptxptr    <= apb1_pwdata(31 downto 0);

          when BUPRXPTR_ADDR_CT     =>
            int_buprxptr    <= apb1_pwdata(31 downto 3);

          when BUPRXOFF_ADDR_CT     =>
            int_rxoff       <= apb1_pwdata(15 downto 3);

          when BUPRXSIZE_ADDR_CT     =>
            int_rxsize      <= apb1_pwdata(15 downto 3);

          when BUPRXUNLOAD_ADDR_CT  =>
            int_rxunload    <= apb1_pwdata(15 downto 3);

          when BUPADDR1L_ADDR_CT    =>
            int_addr1(31 downto 0) <= apb1_pwdata(31 downto 0);

          when BUPADDR1H_ADDR_CT    =>
            int_addr1(47 downto 32) <= apb1_pwdata(15 downto 0);

          when BUPTEST_ADDR_CT      =>
            int_testenable  <= apb1_pwdata(15);
            int_datatype    <= apb1_pwdata(13 downto 12);
            int_fcsdisb     <= apb1_pwdata(6);
            int_buptestmode <= apb1_pwdata( 1 downto 0);

          when BUPTESTDATA_ADDR_CT  =>
            int_testpattern <= apb1_pwdata(31 downto 0);

          when BUPCSPTR_IAC_ADDR_CT =>
            int_csiac_ptr   <= apb1_pwdata(31 downto 0);

          when BUPSCRATCH0_ADDR_CT =>
            int_scratch0    <= apb1_pwdata(31 downto 0);

          when BUPSCRATCH1_ADDR_CT =>
            int_scratch1    <= apb1_pwdata(31 downto 0);

          when BUPSCRATCH2_ADDR_CT =>
            int_scratch2    <= apb1_pwdata(31 downto 0);

          when BUPSCRATCH3_ADDR_CT =>
            int_scratch3    <= apb1_pwdata(31 downto 0);

          when BUPADDR1MSK_ADDR_CT    =>
            int_addr1mskh   <= apb1_pwdata(11 downto 8);
            int_addr1mskl   <= apb1_pwdata( 3 downto 0);

          when BUPRXABTCNT_ADDR_CT    =>
            if apb1_pwdata( 5 downto 0) < RXABTCNT_MIN_CT then
              int_rxabtcnt  <= RXABTCNT_MIN_CT;
            else
              int_rxabtcnt  <= apb1_pwdata( 5 downto 0);
            end if;

          when BUPCHASSBSY_ADDR_CT    =>
            if apb1_pwdata(25 downto 0) = 0 then
              reset_chassbsy <= '1';
            end if;

          when BUPCHASSTIM_ADDR_CT    =>
            int_chassen     <= apb1_pwdata(31);
            int_ignvcs      <= apb1_pwdata(30);
            if apb1_pwdata(25 downto 0) = 0 then
              reset_chasstim <= '1';
            end if;

          when others =>
            null;

        end case;
      end if;
 
      if (apb0_penable = '1' and apb0_psel = '1' and apb0_pwrite = '1') then
        case apb0_paddr is

          when BUPCNTL_ADDR_CT      =>  
            reg_ccarst      <= apb0_pwdata(14);
            int_forcetxdis  <= apb0_pwdata(13);
            int_tximmstop   <= apb0_pwdata(12);
            int_bufempty    <= apb0_pwdata(9);
            genirq          <= apb0_pwdata(8); 
            int_enrxabort   <= apb0_pwdata(4);
            int_clk32sel    <= apb0_pwdata(2 downto 1);
            int_cntxtsel    <= apb0_pwdata(0);

          when BUPVCS_ADDR_CT       =>  
            int_vcsenable   <= apb0_pwdata(31);
            int_vcs         <= apb0_pwdata(25 downto 0);

          when BUPTIME_ADDR_CT      =>       
            reg_buptimer    <= apb0_pwdata(25 downto 0);
            write_buptimer  <= '1'; -- Timer must be updated with the new value.

          when BUPINTMASK_ADDR_CT   =>
            int_ackto_en    <= apb0_pwdata(10);
            int_txstartfiq_en <= apb0_pwdata(9);
            int_timewrap_en <= apb0_pwdata(6);
            int_ccabusy_en  <= apb0_pwdata(5);
            int_ccaidle_en  <= apb0_pwdata(4);
            int_rxstart_en  <= apb0_pwdata(3);
            int_rxend_en    <= apb0_pwdata(2);
            int_txend_en    <= apb0_pwdata(1);
            int_txstartirq_en <= apb0_pwdata(0);

          when BUPINTACK_ADDR_CT    =>  
            reg_iacaftersifs_ack <= apb0_pwdata(31);
            reg_ackto_ack        <= apb0_pwdata(10);
            reg_txstartfiq_ack   <= apb0_pwdata(9);
            reg_genirq_ack   <= apb0_pwdata(8);
            reg_timewrap_ack <= apb0_pwdata(6);
            reg_ccabusy_ack  <= apb0_pwdata(5);
            reg_ccaidle_ack  <= apb0_pwdata(4);
            reg_rxstart_ack  <= apb0_pwdata(3);
            reg_rxend_ack    <= apb0_pwdata(2);
            reg_txend_ack    <= apb0_pwdata(1);
            reg_txstartirq_ack <= apb0_pwdata(0);

          when BUPCOUNT0_ADDR_CT     =>
            int_txdstartdel <= apb0_pwdata(31 downto 29);
            int_txsifsb     <= apb0_pwdata(21 downto 16);
            int_rxsifsb     <= apb0_pwdata(13 downto 8);
            int_sifs        <= apb0_pwdata( 5 downto 0);

          when BUPCOUNT1_ADDR_CT     =>
            int_txsifsa     <= apb0_pwdata(21 downto 16);
            int_rxsifsa     <= apb0_pwdata(13 downto 8);

          when BUPCOUNT2_ADDR_CT  =>
            int_macslot     <= apb0_pwdata( 7 downto 0);

          when BUPTXCNTL_BCON_ADDR_CT =>
            int_bcon_bakenable <= apb0_pwdata(24);
            int_bcon_txenable  <= apb0_pwdata(23);
            int_bcon_ifs       <= apb0_pwdata(19 downto 16);
            int_bcon_backoff   <= apb0_pwdata( 9 downto 0);
            write_bcon_bkoff   <= '1';

          when BUPTXCNTL_IAC_ADDR_CT =>
            int_iac_txenable   <= apb0_pwdata(23);
            int_iac_ifs        <= apb0_pwdata(19 downto 16);
            write_iac_bkoff    <= '1';

          when BUPTXPTR_ADDR_CT     =>  
            int_buptxptr    <= apb0_pwdata(31 downto 0);

          when BUPRXPTR_ADDR_CT     =>
            int_buprxptr    <= apb0_pwdata(31 downto 3);

          when BUPRXOFF_ADDR_CT     =>
            int_rxoff       <= apb0_pwdata(15 downto 3);

          when BUPRXSIZE_ADDR_CT     =>
            int_rxsize      <= apb0_pwdata(15 downto 3);

          when BUPRXUNLOAD_ADDR_CT  =>
            int_rxunload    <= apb0_pwdata(15 downto 3);

          when BUPADDR1L_ADDR_CT    =>
            int_addr1(31 downto 0) <= apb0_pwdata(31 downto 0);

          when BUPADDR1H_ADDR_CT    =>
            int_addr1(47 downto 32) <= apb0_pwdata(15 downto 0);

          when BUPTEST_ADDR_CT      =>
            int_testenable  <= apb0_pwdata(15);
            int_datatype    <= apb0_pwdata(13 downto 12);
            int_fcsdisb     <= apb0_pwdata(6);
            int_buptestmode <= apb0_pwdata( 1 downto 0);

          when BUPTESTDATA_ADDR_CT  =>
            int_testpattern <= apb0_pwdata(31 downto 0);

          when BUPCSPTR_IAC_ADDR_CT =>
            int_csiac_ptr   <= apb0_pwdata(31 downto 0);

          when BUPSCRATCH0_ADDR_CT =>
            int_scratch0    <= apb0_pwdata(31 downto 0);

          when BUPSCRATCH1_ADDR_CT =>
            int_scratch1    <= apb0_pwdata(31 downto 0);

          when BUPSCRATCH2_ADDR_CT =>
            int_scratch2    <= apb0_pwdata(31 downto 0);

          when BUPSCRATCH3_ADDR_CT =>
            int_scratch3    <= apb0_pwdata(31 downto 0);

          when BUPADDR1MSK_ADDR_CT    =>
            int_addr1mskh   <= apb0_pwdata(11 downto 8);
            int_addr1mskl   <= apb0_pwdata( 3 downto 0);

          when BUPRXABTCNT_ADDR_CT    =>
            if apb0_pwdata( 5 downto 0) < RXABTCNT_MIN_CT then
              int_rxabtcnt  <= RXABTCNT_MIN_CT;
            else
              int_rxabtcnt  <= apb0_pwdata( 5 downto 0);
            end if;

          when BUPCHASSBSY_ADDR_CT    =>
            if apb0_pwdata(25 downto 0) = 0 then
              reset_chassbsy <= '1';
            end if;

          when BUPCHASSTIM_ADDR_CT    =>
            int_chassen     <= apb0_pwdata(31);
            int_ignvcs      <= apb0_pwdata(30);
            if apb0_pwdata(25 downto 0) = 0 then
              reset_chasstim <= '1';
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process apb_write_pr;







--################################################################################
  ------------------------------------------------------------------------------
  -- Registers read
  ------------------------------------------------------------------------------
  -- The read cycle follows the timing shown in page 5-6 of the AMBA
  -- Specification.
  -- psel is used to detect the beginning of the two-clock-cycle-long APB
  -- read access. This way, the second cycle can be used to register prdata
  -- and comply with interfaces timing requirements.
  apb0_read_comb_pr: process (acp0_bkoff_timer, acp1_bkoff_timer,
                              acp2_bkoff_timer, acp3_bkoff_timer,
                              acp4_bkoff_timer, acp5_bkoff_timer,
                              acp6_bkoff_timer, acp7_bkoff_timer, apb0_paddr,
                              apb0_psel, bcon_bkoff_timer, bup_timer,
                              int_abscnt_en, int_abscnt_irqsel, int_abstime,
                              int_ackto_en, int_acp_bakenable, int_acp_ifs0,
                              int_acp_ifs1, int_acp_ifs2, int_acp_ifs3,
                              int_acp_ifs4, int_acp_ifs5, int_acp_ifs6,
                              int_acp_ifs7, int_acp_txenable, int_addr1,
                              int_addr1mskh, int_addr1mskl, int_bcon_bakenable,
                              int_bcon_ifs, int_bcon_txenable, int_bufempty,
                              int_build, int_buprxptr, int_buptestmode,
                              int_buptxptr, int_ccabusy_en, int_ccaidle_en,
                              int_chassen, int_clk32sel, int_cntxtsel,
                              int_csiac_ptr, int_datatype, int_enrxabort,
                              int_fcsdisb, int_forcetxdis, int_iac_ifs,
                              int_iac_txenable, int_ignvcs, int_macslot,
                              int_rel, int_rxabtcnt, int_rxend_en, int_rxoff,
                              int_rxsifsa, int_rxsifsb, int_rxsize,
                              int_rxstart_en, int_rxunload, int_scratch0,
                              int_scratch1, int_scratch2, int_scratch3,
                              int_sifs, int_testenable, int_testpattern,
                              int_timewrap_en, int_txdstartdel, int_txend_en,
                              int_tximmstop, int_txsifsa, int_txsifsb,
                              int_txstartfiq_en, int_txstartirq_en, int_upg,
                              int_vcs, int_vcsenable, reg_a1match_stat,
                              reg_abscnt_src, reg_abscntfiq_src,
                              reg_abscntirq_src, reg_ackto_src,
                              reg_ccabusy_src, reg_ccaidle_src, reg_chassbsy,
                              reg_chasstim, reg_durid, reg_errstat,
                              reg_fcserr_stat, reg_frmcntl, reg_fullbuf_stat,
                              reg_genirq_src, reg_iacaftersifs, reg_inttime,
                              reg_rxend_src, reg_rxendstat, reg_rxstart_src,
                              reg_testdata_in, reg_timewrap_src, reg_txend_src,
                              reg_txendstat, reg_txqueue, reg_txstartfiq_src,
                              reg_txstartirq_src, rxant, rxccaaddinfo, rxlen,
                              rxrate, rxrssi, rxserv)
  begin
    next_apb0_prdata <= (others => '0');
  
    -- Test only psel to detect first cycle of the two-cycles APB read access.
    if (apb0_psel = '1') then

      case apb0_paddr is
        when BUPVERSION_ADDR_CT   =>
          next_apb0_prdata <= int_build & int_rel & int_upg;

        when BUPCNTL_ADDR_CT      =>
          next_apb0_prdata(13)          <= int_forcetxdis;
          next_apb0_prdata(12)          <= int_tximmstop;
          next_apb0_prdata(9)           <= int_bufempty;
          next_apb0_prdata(4)           <= int_enrxabort;
          next_apb0_prdata(2 downto 1)  <= int_clk32sel;
          next_apb0_prdata(0)           <= int_cntxtsel;

        when BUPVCS_ADDR_CT       =>
          next_apb0_prdata(31)           <= int_vcsenable;
          next_apb0_prdata(25 downto 0)  <= int_vcs;

        when BUPTIME_ADDR_CT      =>       
          next_apb0_prdata(25 downto 0)  <= bup_timer;

        when BUPABSCNT0_ADDR_CT   =>
          next_apb0_prdata(28)           <= int_abscnt_irqsel(0);
          next_apb0_prdata(25 downto  0) <= int_abstime(0);

        when BUPABSCNT1_ADDR_CT   =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(1);
          next_apb0_prdata(25 downto  0) <= int_abstime(1);

        when BUPABSCNT2_ADDR_CT   =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(2);
          next_apb0_prdata(25 downto  0) <= int_abstime(2);

        when BUPABSCNT3_ADDR_CT   =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(3);
          next_apb0_prdata(25 downto  0) <= int_abstime(3);

        when BUPABSCNT4_ADDR_CT   =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(4);
          next_apb0_prdata(25 downto  0) <= int_abstime(4);

        when BUPABSCNT5_ADDR_CT   =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(5);
          next_apb0_prdata(25 downto  0) <= int_abstime(5);

        when BUPABSCNT6_ADDR_CT   =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(6);
          next_apb0_prdata(25 downto  0) <= int_abstime(6);

        when BUPABSCNT7_ADDR_CT   =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(7);
          next_apb0_prdata(25 downto  0) <= int_abstime(7);

        when BUPABSCNT8_ADDR_CT   =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(8);
          next_apb0_prdata(25 downto  0) <= int_abstime(8);

        when BUPABSCNT9_ADDR_CT   =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(9);
          next_apb0_prdata(25 downto  0) <= int_abstime(9);

        when BUPABSCNT10_ADDR_CT  =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(10);
          next_apb0_prdata(25 downto  0) <= int_abstime(10);

        when BUPABSCNT11_ADDR_CT  =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(11);
          next_apb0_prdata(25 downto  0) <= int_abstime(11);

        when BUPABSCNT12_ADDR_CT  =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(12);
          next_apb0_prdata(25 downto  0) <= int_abstime(12);

        when BUPABSCNT13_ADDR_CT  =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(13);
          next_apb0_prdata(25 downto  0) <= int_abstime(13);

        when BUPABSCNT14_ADDR_CT  =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(14);
          next_apb0_prdata(25 downto  0) <= int_abstime(14);

        when BUPABSCNT15_ADDR_CT  =>      
          next_apb0_prdata(28)           <= int_abscnt_irqsel(15);
          next_apb0_prdata(25 downto  0) <= int_abstime(15);

        when BUPABSCNTMASK_ADDR_CT  =>      
          next_apb0_prdata(15 downto  0) <= int_abscnt_en;

        when BUPABSCNTSTAT_ADDR_CT  =>      
          next_apb0_prdata(num_abstimer_g-1 downto  0) <= reg_abscnt_src;

        when BUPINTMASK_ADDR_CT   =>
          next_apb0_prdata(10)           <= int_ackto_en;
          next_apb0_prdata( 9)           <= int_txstartfiq_en;
          next_apb0_prdata( 6 downto  0) <= int_timewrap_en
                                     & int_ccabusy_en & int_ccaidle_en 
                                     & int_rxstart_en & int_rxend_en
                                     & int_txend_en & int_txstartirq_en;

        when BUPINTSTAT_ADDR_CT   =>
          next_apb0_prdata(31)           <= reg_iacaftersifs;    
          next_apb0_prdata(27 downto 24) <= reg_txqueue;    
          next_apb0_prdata(22)           <= reg_fcserr_stat; 
          next_apb0_prdata(19)           <= reg_fullbuf_stat;
          next_apb0_prdata(18)           <= reg_a1match_stat;
          next_apb0_prdata(17 downto 16) <= reg_errstat;
          next_apb0_prdata(15 downto 14) <= reg_rxendstat;
          next_apb0_prdata(13 downto 12) <= reg_txendstat;
          next_apb0_prdata(11)           <= reg_abscntfiq_src;
          next_apb0_prdata(10)           <= reg_ackto_src;
          next_apb0_prdata( 9 downto  0) <= reg_txstartfiq_src & reg_genirq_src
                                & reg_abscntirq_src & reg_timewrap_src
                                & reg_ccabusy_src & reg_ccaidle_src 
                                & reg_rxstart_src & reg_rxend_src
                                & reg_txend_src & reg_txstartirq_src;
                               

        when BUPINTTIME_ADDR_CT   =>
          next_apb0_prdata(25 downto  0) <= reg_inttime;

        when BUPCOUNT0_ADDR_CT  =>
          next_apb0_prdata(31 downto 29) <= int_txdstartdel;
          next_apb0_prdata(21 downto 16) <= int_txsifsb;
          next_apb0_prdata(13 downto 8)  <= int_rxsifsb;
          next_apb0_prdata( 5 downto 0)  <= int_sifs;

        when BUPCOUNT1_ADDR_CT  =>
          next_apb0_prdata(21 downto 16) <= int_txsifsa;
          next_apb0_prdata(13 downto 8)  <= int_rxsifsa;

        when BUPCOUNT2_ADDR_CT  =>
          next_apb0_prdata( 7 downto 0)  <= int_macslot;

        when BUPTXCNTL_BCON_ADDR_CT    =>
          next_apb0_prdata(24)           <= int_bcon_bakenable;
          next_apb0_prdata(23)           <= int_bcon_txenable;
          next_apb0_prdata(19 downto 16) <= int_bcon_ifs;
          next_apb0_prdata( 9 downto 0)  <= bcon_bkoff_timer;    

        when BUPTXCNTL_ACP7_ADDR_CT    =>
          next_apb0_prdata(24)           <= int_acp_bakenable(7);
          next_apb0_prdata(23)           <= int_acp_txenable(7);
          next_apb0_prdata(19 downto 16) <= int_acp_ifs7;
          next_apb0_prdata( 9 downto 0)  <= acp7_bkoff_timer;

        when BUPTXCNTL_ACP6_ADDR_CT    =>
          next_apb0_prdata(24)           <= int_acp_bakenable(6);
          next_apb0_prdata(23)           <= int_acp_txenable(6);
          next_apb0_prdata(19 downto 16) <= int_acp_ifs6;
          next_apb0_prdata( 9 downto 0)  <= acp6_bkoff_timer;

        when BUPTXCNTL_ACP5_ADDR_CT    =>
          next_apb0_prdata(24)           <= int_acp_bakenable(5);
          next_apb0_prdata(23)           <= int_acp_txenable(5);
          next_apb0_prdata(19 downto 16) <= int_acp_ifs5;
          next_apb0_prdata( 9 downto 0)  <= acp5_bkoff_timer;

        when BUPTXCNTL_ACP4_ADDR_CT    =>
          next_apb0_prdata(24)           <= int_acp_bakenable(4);
          next_apb0_prdata(23)           <= int_acp_txenable(4);
          next_apb0_prdata(19 downto 16) <= int_acp_ifs4;
          next_apb0_prdata( 9 downto 0)  <= acp4_bkoff_timer;

        when BUPTXCNTL_ACP3_ADDR_CT    =>
          next_apb0_prdata(24)           <= int_acp_bakenable(3);
          next_apb0_prdata(23)           <= int_acp_txenable(3);
          next_apb0_prdata(19 downto 16) <= int_acp_ifs3;
          next_apb0_prdata( 9 downto 0)  <= acp3_bkoff_timer;

        when BUPTXCNTL_ACP2_ADDR_CT    =>
          next_apb0_prdata(24)           <= int_acp_bakenable(2);
          next_apb0_prdata(23)           <= int_acp_txenable(2);
          next_apb0_prdata(19 downto 16) <= int_acp_ifs2;
          next_apb0_prdata( 9 downto 0)  <= acp2_bkoff_timer;

        when BUPTXCNTL_ACP1_ADDR_CT    =>
          next_apb0_prdata(24)           <= int_acp_bakenable(1);
          next_apb0_prdata(23)           <= int_acp_txenable(1);
          next_apb0_prdata(19 downto 16) <= int_acp_ifs1;
          next_apb0_prdata( 9 downto 0)  <= acp1_bkoff_timer;

        when BUPTXCNTL_ACP0_ADDR_CT    =>
          next_apb0_prdata(24)           <= int_acp_bakenable(0);
          next_apb0_prdata(23)           <= int_acp_txenable(0);
          next_apb0_prdata(19 downto 16) <= int_acp_ifs0;
          next_apb0_prdata( 9 downto 0)  <= acp0_bkoff_timer;

        when BUPTXCNTL_IAC_ADDR_CT     =>
          next_apb0_prdata(23)           <= int_iac_txenable;
          next_apb0_prdata(19 downto 16) <= int_iac_ifs;

        when BUPTXPTR_ADDR_CT     =>  
          next_apb0_prdata(31 downto  0) <= int_buptxptr;

        when BUPRXPTR_ADDR_CT     =>  
          next_apb0_prdata(31 downto  0) <= int_buprxptr & "000";

        when BUPRXOFF_ADDR_CT     =>
          next_apb0_prdata(15 downto  0) <= int_rxoff & "000";

        when BUPRXSIZE_ADDR_CT    =>
          next_apb0_prdata(15 downto  0) <= int_rxsize & "000";

       when BUPRXUNLOAD_ADDR_CT   =>
          next_apb0_prdata(15 downto  0) <= int_rxunload & "000";

        when BUPMACHDR_ADDR_CT    =>
          next_apb0_prdata(31 downto 16) <= reg_durid;
          next_apb0_prdata(15 downto  0) <= reg_frmcntl; 

        when BUPADDR1L_ADDR_CT    =>
          next_apb0_prdata(31 downto 0)  <= int_addr1(31 downto 0);

        when BUPADDR1H_ADDR_CT    =>
          next_apb0_prdata(15 downto 0)  <= int_addr1(47 downto 32);

        when BUPTEST_ADDR_CT      => 
          next_apb0_prdata(15)           <= int_testenable;
          next_apb0_prdata(13 downto 12) <= int_datatype;  
          next_apb0_prdata(6)            <= int_fcsdisb; 
          next_apb0_prdata( 1 downto 0)  <= int_buptestmode;   

        when BUPTESTDATA_ADDR_CT  =>
          case int_buptestmode is
            when "10"      =>
              next_apb0_prdata  <= int_testpattern;
            when others  =>
              next_apb0_prdata  <= reg_testdata_in;
          end case;

        when BUPTESTDIN_ADDR_CT  =>
          next_apb0_prdata  <= reg_testdata_in;

        when BUPCSPTR_IAC_ADDR_CT =>
          next_apb0_prdata <= int_csiac_ptr(31 downto 0);

        when BUPRXCS0_ADDR_CT =>
          next_apb0_prdata(31 downto 16) <= rxserv;
          next_apb0_prdata(11 downto 0)  <= rxlen;


        when BUPRXCS1_ADDR_CT =>
          next_apb0_prdata(31 downto 24) <= rxccaaddinfo;
          next_apb0_prdata(19 downto 16) <= rxrate;
          next_apb0_prdata(8)            <= rxant;
          next_apb0_prdata(7  downto 0)  <= '1' & rxrssi;

       
        when BUPSCRATCH0_ADDR_CT =>
          next_apb0_prdata <= int_scratch0(31 downto 0);

        when BUPSCRATCH1_ADDR_CT =>
          next_apb0_prdata <= int_scratch1(31 downto 0);

        when BUPSCRATCH2_ADDR_CT =>
          next_apb0_prdata <= int_scratch2(31 downto 0);

        when BUPSCRATCH3_ADDR_CT =>
          next_apb0_prdata <= int_scratch3(31 downto 0);

        when BUPADDR1MSK_ADDR_CT    =>
          next_apb0_prdata(11 downto 8) <= int_addr1mskh;
          next_apb0_prdata( 3 downto 0) <= int_addr1mskl;

        when BUPRXABTCNT_ADDR_CT    =>
          next_apb0_prdata( 5 downto 0) <= int_rxabtcnt;

        when BUPCHASSBSY_ADDR_CT    =>
          next_apb0_prdata(25 downto 0) <= reg_chassbsy;

        when BUPCHASSTIM_ADDR_CT    =>
          next_apb0_prdata(31)          <= int_chassen;
          next_apb0_prdata(30)          <= int_ignvcs;
          next_apb0_prdata(25 downto 0) <= reg_chasstim;

        when others =>
          next_apb0_prdata <= (others => '0');

      end case;
    
    end if;
  end process apb0_read_comb_pr;
  
  -- Register prdata0 output.
  apb0_read_seq_pr: process (pclk, reset_n)
  begin
    if reset_n = '0' then
      apb0_prdata <= (others => '0');      
    elsif pclk'event and pclk = '1' then
      if apb0_psel = '1' then
        apb0_prdata <= next_apb0_prdata;
      end if;
    end if;
  end process apb0_read_seq_pr;
  

--################################################################################
  ------------------------------------------------------------------------------
  -- Registers read
  ------------------------------------------------------------------------------
  -- The read cycle follows the timing shown in page 5-6 of the AMBA
  -- Specification.
  -- psel is used to detect the beginning of the two-clock-cycle-long APB
  -- read access. This way, the second cycle can be used to register prdata
  -- and comply with interfaces timing requirements.
  apb1_read_comb_pr: process (acp0_bkoff_timer, acp1_bkoff_timer,
                              acp2_bkoff_timer, acp3_bkoff_timer,
                              acp4_bkoff_timer, acp5_bkoff_timer,
                              acp6_bkoff_timer, acp7_bkoff_timer, apb1_paddr,
                              apb1_psel, bcon_bkoff_timer, bup_timer,
                              int_abscnt_en, int_abscnt_irqsel, int_abstime,
                              int_ackto_en, int_acp_bakenable, int_acp_ifs0,
                              int_acp_ifs1, int_acp_ifs2, int_acp_ifs3,
                              int_acp_ifs4, int_acp_ifs5, int_acp_ifs6,
                              int_acp_ifs7, int_acp_txenable, int_addr1,
                              int_addr1mskh, int_addr1mskl, int_bcon_bakenable,
                              int_bcon_ifs, int_bcon_txenable, int_bufempty,
                              int_build, int_buprxptr, int_buptestmode,
                              int_buptxptr, int_ccabusy_en, int_ccaidle_en,
                              int_chassen, int_clk32sel, int_cntxtsel,
                              int_csiac_ptr, int_datatype, int_enrxabort,
                              int_fcsdisb, int_forcetxdis, int_iac_ifs,
                              int_iac_txenable, int_ignvcs, int_macslot,
                              int_rel, int_rxabtcnt, int_rxend_en, int_rxoff,
                              int_rxsifsa, int_rxsifsb, int_rxsize,
                              int_rxstart_en, int_rxunload, int_scratch0,
                              int_scratch1, int_scratch2, int_scratch3,
                              int_sifs, int_testenable, int_testpattern,
                              int_timewrap_en, int_txdstartdel, int_txend_en,
                              int_tximmstop, int_txsifsa, int_txsifsb,
                              int_txstartfiq_en, int_txstartirq_en, int_upg,
                              int_vcs, int_vcsenable, reg_a1match_stat,
                              reg_abscnt_src, reg_abscntfiq_src,
                              reg_abscntirq_src, reg_ackto_src,
                              reg_ccabusy_src, reg_ccaidle_src, reg_chassbsy,
                              reg_chasstim, reg_durid, reg_errstat,
                              reg_fcserr_stat, reg_frmcntl, reg_fullbuf_stat,
                              reg_genirq_src, reg_iacaftersifs, reg_inttime,
                              reg_rxend_src, reg_rxendstat, reg_rxstart_src,
                              reg_testdata_in, reg_timewrap_src, reg_txend_src,
                              reg_txendstat, reg_txqueue, reg_txstartfiq_src,
                              reg_txstartirq_src, rxant, rxccaaddinfo, rxlen,
                              rxrate, rxrssi, rxserv)
  begin
    next_apb1_prdata <= (others => '0');
  
    -- Test only psel to detect first cycle of the two-cycles APB read access.
    if (apb1_psel = '1') then

      case apb1_paddr is
        when BUPVERSION_ADDR_CT   =>
          next_apb1_prdata <= int_build & int_rel & int_upg;

        when BUPCNTL_ADDR_CT      =>
          next_apb1_prdata(13)          <= int_forcetxdis;
          next_apb1_prdata(12)          <= int_tximmstop;
          next_apb1_prdata(9)           <= int_bufempty;
          next_apb1_prdata(4)           <= int_enrxabort;
          next_apb1_prdata(2 downto 1)  <= int_clk32sel;
          next_apb1_prdata(0)           <= int_cntxtsel;

        when BUPVCS_ADDR_CT       =>
          next_apb1_prdata(31)           <= int_vcsenable;
          next_apb1_prdata(25 downto 0)  <= int_vcs;

        when BUPTIME_ADDR_CT      =>       
          next_apb1_prdata(25 downto 0)  <= bup_timer;

        when BUPABSCNT0_ADDR_CT   =>
          next_apb1_prdata(28)           <= int_abscnt_irqsel(0);
          next_apb1_prdata(25 downto  0) <= int_abstime(0);

        when BUPABSCNT1_ADDR_CT   =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(1);
          next_apb1_prdata(25 downto  0) <= int_abstime(1);

        when BUPABSCNT2_ADDR_CT   =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(2);
          next_apb1_prdata(25 downto  0) <= int_abstime(2);

        when BUPABSCNT3_ADDR_CT   =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(3);
          next_apb1_prdata(25 downto  0) <= int_abstime(3);

        when BUPABSCNT4_ADDR_CT   =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(4);
          next_apb1_prdata(25 downto  0) <= int_abstime(4);

        when BUPABSCNT5_ADDR_CT   =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(5);
          next_apb1_prdata(25 downto  0) <= int_abstime(5);

        when BUPABSCNT6_ADDR_CT   =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(6);
          next_apb1_prdata(25 downto  0) <= int_abstime(6);

        when BUPABSCNT7_ADDR_CT   =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(7);
          next_apb1_prdata(25 downto  0) <= int_abstime(7);

        when BUPABSCNT8_ADDR_CT   =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(8);
          next_apb1_prdata(25 downto  0) <= int_abstime(8);

        when BUPABSCNT9_ADDR_CT   =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(9);
          next_apb1_prdata(25 downto  0) <= int_abstime(9);

        when BUPABSCNT10_ADDR_CT  =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(10);
          next_apb1_prdata(25 downto  0) <= int_abstime(10);

        when BUPABSCNT11_ADDR_CT  =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(11);
          next_apb1_prdata(25 downto  0) <= int_abstime(11);

        when BUPABSCNT12_ADDR_CT  =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(12);
          next_apb1_prdata(25 downto  0) <= int_abstime(12);

        when BUPABSCNT13_ADDR_CT  =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(13);
          next_apb1_prdata(25 downto  0) <= int_abstime(13);

        when BUPABSCNT14_ADDR_CT  =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(14);
          next_apb1_prdata(25 downto  0) <= int_abstime(14);

        when BUPABSCNT15_ADDR_CT  =>      
          next_apb1_prdata(28)           <= int_abscnt_irqsel(15);
          next_apb1_prdata(25 downto  0) <= int_abstime(15);

        when BUPABSCNTMASK_ADDR_CT  =>      
          next_apb1_prdata(15 downto  0) <= int_abscnt_en;

        when BUPABSCNTSTAT_ADDR_CT  =>      
          next_apb1_prdata(num_abstimer_g-1 downto  0) <= reg_abscnt_src;

        when BUPINTMASK_ADDR_CT   =>
          next_apb1_prdata(10)           <= int_ackto_en;
          next_apb1_prdata( 9)           <= int_txstartfiq_en;
          next_apb1_prdata( 6 downto  0) <= int_timewrap_en
                                     & int_ccabusy_en & int_ccaidle_en 
                                     & int_rxstart_en & int_rxend_en
                                     & int_txend_en & int_txstartirq_en;

        when BUPINTSTAT_ADDR_CT   =>
          next_apb1_prdata(31)           <= reg_iacaftersifs;    
          next_apb1_prdata(27 downto 24) <= reg_txqueue;    
          next_apb1_prdata(22)           <= reg_fcserr_stat; 
          next_apb1_prdata(19)           <= reg_fullbuf_stat;
          next_apb1_prdata(18)           <= reg_a1match_stat;
          next_apb1_prdata(17 downto 16) <= reg_errstat;
          next_apb1_prdata(15 downto 14) <= reg_rxendstat;
          next_apb1_prdata(13 downto 12) <= reg_txendstat;
          next_apb1_prdata(11)           <= reg_abscntfiq_src;
          next_apb1_prdata(10)           <= reg_ackto_src;
          next_apb1_prdata( 9 downto  0) <= reg_txstartfiq_src & reg_genirq_src
                                     & reg_abscntirq_src & reg_timewrap_src
                                     & reg_ccabusy_src & reg_ccaidle_src 
                                     & reg_rxstart_src & reg_rxend_src
                                     & reg_txend_src & reg_txstartirq_src;
                               

        when BUPINTTIME_ADDR_CT   =>
          next_apb1_prdata(25 downto  0) <= reg_inttime;

        when BUPCOUNT0_ADDR_CT  =>
          next_apb1_prdata(31 downto 29) <= int_txdstartdel;
          next_apb1_prdata(21 downto 16) <= int_txsifsb;
          next_apb1_prdata(13 downto 8)  <= int_rxsifsb;
          next_apb1_prdata( 5 downto 0)  <= int_sifs;

        when BUPCOUNT1_ADDR_CT  =>
          next_apb1_prdata(21 downto 16) <= int_txsifsa;
          next_apb1_prdata(13 downto 8)  <= int_rxsifsa;

        when BUPCOUNT2_ADDR_CT  =>
          next_apb1_prdata( 7 downto 0)  <= int_macslot;

        when BUPTXCNTL_BCON_ADDR_CT    =>
          next_apb1_prdata(24)           <= int_bcon_bakenable;
          next_apb1_prdata(23)           <= int_bcon_txenable;
          next_apb1_prdata(19 downto 16) <= int_bcon_ifs;
          next_apb1_prdata( 9 downto 0)  <= bcon_bkoff_timer;    

        when BUPTXCNTL_ACP7_ADDR_CT    =>
          next_apb1_prdata(24)           <= int_acp_bakenable(7);
          next_apb1_prdata(23)           <= int_acp_txenable(7);
          next_apb1_prdata(19 downto 16) <= int_acp_ifs7;
          next_apb1_prdata( 9 downto 0)  <= acp7_bkoff_timer;

        when BUPTXCNTL_ACP6_ADDR_CT    =>
          next_apb1_prdata(24)           <= int_acp_bakenable(6);
          next_apb1_prdata(23)           <= int_acp_txenable(6);
          next_apb1_prdata(19 downto 16) <= int_acp_ifs6;
          next_apb1_prdata( 9 downto 0)  <= acp6_bkoff_timer;

        when BUPTXCNTL_ACP5_ADDR_CT    =>
          next_apb1_prdata(24)           <= int_acp_bakenable(5);
          next_apb1_prdata(23)           <= int_acp_txenable(5);
          next_apb1_prdata(19 downto 16) <= int_acp_ifs5;
          next_apb1_prdata( 9 downto 0)  <= acp5_bkoff_timer;

        when BUPTXCNTL_ACP4_ADDR_CT    =>
          next_apb1_prdata(24)           <= int_acp_bakenable(4);
          next_apb1_prdata(23)           <= int_acp_txenable(4);
          next_apb1_prdata(19 downto 16) <= int_acp_ifs4;
          next_apb1_prdata( 9 downto 0)  <= acp4_bkoff_timer;

        when BUPTXCNTL_ACP3_ADDR_CT    =>
          next_apb1_prdata(24)           <= int_acp_bakenable(3);
          next_apb1_prdata(23)           <= int_acp_txenable(3);
          next_apb1_prdata(19 downto 16) <= int_acp_ifs3;
          next_apb1_prdata( 9 downto 0)  <= acp3_bkoff_timer;

        when BUPTXCNTL_ACP2_ADDR_CT    =>
          next_apb1_prdata(24)           <= int_acp_bakenable(2);
          next_apb1_prdata(23)           <= int_acp_txenable(2);
          next_apb1_prdata(19 downto 16) <= int_acp_ifs2;
          next_apb1_prdata( 9 downto 0)  <= acp2_bkoff_timer;

        when BUPTXCNTL_ACP1_ADDR_CT    =>
          next_apb1_prdata(24)           <= int_acp_bakenable(1);
          next_apb1_prdata(23)           <= int_acp_txenable(1);
          next_apb1_prdata(19 downto 16) <= int_acp_ifs1;
          next_apb1_prdata( 9 downto 0)  <= acp1_bkoff_timer;

        when BUPTXCNTL_ACP0_ADDR_CT    =>
          next_apb1_prdata(24)           <= int_acp_bakenable(0);
          next_apb1_prdata(23)           <= int_acp_txenable(0);
          next_apb1_prdata(19 downto 16) <= int_acp_ifs0;
          next_apb1_prdata( 9 downto 0)  <= acp0_bkoff_timer;

        when BUPTXCNTL_IAC_ADDR_CT     =>
          next_apb1_prdata(23)           <= int_iac_txenable;
          next_apb1_prdata(19 downto 16) <= int_iac_ifs;

        when BUPTXPTR_ADDR_CT     =>  
          next_apb1_prdata(31 downto  0) <= int_buptxptr;

        when BUPRXPTR_ADDR_CT     =>  
          next_apb1_prdata(31 downto  0) <= int_buprxptr & "000";

        when BUPRXOFF_ADDR_CT     =>
          next_apb1_prdata(15 downto  0) <= int_rxoff & "000";

        when BUPRXSIZE_ADDR_CT    =>
          next_apb1_prdata(15 downto  0) <= int_rxsize & "000";

       when BUPRXUNLOAD_ADDR_CT   =>
          next_apb1_prdata(15 downto  0) <= int_rxunload & "000";

        when BUPMACHDR_ADDR_CT    =>
          next_apb1_prdata(31 downto 16) <= reg_durid;
          next_apb1_prdata(15 downto  0) <= reg_frmcntl; 

        when BUPADDR1L_ADDR_CT    =>
          next_apb1_prdata(31 downto 0)  <= int_addr1(31 downto 0);

        when BUPADDR1H_ADDR_CT    =>
          next_apb1_prdata(15 downto 0)  <= int_addr1(47 downto 32);

        when BUPTEST_ADDR_CT      => 
          next_apb1_prdata(15)           <= int_testenable;
          next_apb1_prdata(13 downto 12) <= int_datatype;  
          next_apb1_prdata(6)            <= int_fcsdisb; 
          next_apb1_prdata( 1 downto 0)  <= int_buptestmode;   

        when BUPTESTDATA_ADDR_CT  =>
          case int_buptestmode is
            when "10"      =>
              next_apb1_prdata  <= int_testpattern;
            when others  =>
              next_apb1_prdata  <= reg_testdata_in;
          end case;

        when BUPTESTDIN_ADDR_CT  =>
          next_apb1_prdata  <= reg_testdata_in;


        when BUPCSPTR_IAC_ADDR_CT =>
          next_apb1_prdata <= int_csiac_ptr(31 downto 0);

        when BUPRXCS0_ADDR_CT =>
          next_apb1_prdata(31 downto 16) <= rxserv;
          next_apb1_prdata(11 downto 0)  <= rxlen;


        when BUPRXCS1_ADDR_CT =>
          next_apb1_prdata(31 downto 24) <= rxccaaddinfo;
          next_apb1_prdata(19 downto 16) <= rxrate;
          next_apb1_prdata(8)            <= rxant;
          next_apb1_prdata(7  downto 0)  <= '1' & rxrssi;

       
        when BUPSCRATCH0_ADDR_CT =>
          next_apb1_prdata <= int_scratch0(31 downto 0);

        when BUPSCRATCH1_ADDR_CT =>
          next_apb1_prdata <= int_scratch1(31 downto 0);

        when BUPSCRATCH2_ADDR_CT =>
          next_apb1_prdata <= int_scratch2(31 downto 0);

        when BUPSCRATCH3_ADDR_CT =>
          next_apb1_prdata <= int_scratch3(31 downto 0);

        when BUPADDR1MSK_ADDR_CT    =>
          next_apb1_prdata(11 downto 8) <= int_addr1mskh;
          next_apb1_prdata( 3 downto 0) <= int_addr1mskl;

        when BUPRXABTCNT_ADDR_CT    =>
          next_apb1_prdata( 5 downto 0) <= int_rxabtcnt;

        when BUPCHASSBSY_ADDR_CT    =>
          next_apb1_prdata(25 downto 0) <= reg_chassbsy;

        when BUPCHASSTIM_ADDR_CT    =>
          next_apb1_prdata(31)          <= int_chassen;
          next_apb1_prdata(30)          <= int_ignvcs;
          next_apb1_prdata(25 downto 0) <= reg_chasstim;

        when others =>
          next_apb1_prdata <= (others => '0');

      end case;
    
    end if;
  end process apb1_read_comb_pr;

  -- Register prdata1 output.
  apb1_read_seq_pr: process (pclk, reset_n)
  begin
    if reset_n = '0' then
      apb1_prdata <= (others => '0');      
    elsif pclk'event and pclk = '1' then
      if apb1_psel = '1' then
        apb1_prdata <= next_apb1_prdata;
      end if;
    end if;
  end process apb1_read_seq_pr;


--################################################################################


  acp_gen: for i in 0 to num_queues_g-1 generate
    ------------------------------------------------------------------------------
    -- Register write
    ------------------------------------------------------------------------------
    -- The write cycle follows the timing shown in page 5-5 of the AMBA
    -- Specification.
    apb_writeacp_pr: process (pclk, reset_n)
    begin
      if (reset_n = '0') then
        int_acp_bakenable(i) <= '0';
        int_acp_txenable(i)  <= '0';
        int_acp_ifs(i)       <= (others => '0');
        int_acp_backoff(i)   <= (others => '0');
        write_acp_bkoff(i)   <= '0';
  
      elsif (pclk'event and pclk = '1') then
        -- Backoff timer updated, reset write_acp_bkoff.
        write_acp_bkoff(i) <= '0';
      
        -- Reset acp_txenable after transmission of the packet.
        if (reset_acp_txen(i) = '1') then
          int_acp_txenable(i) <= '0';
        end if;
  
        if (apb0_penable = '1' and apb0_psel = '1' and apb0_pwrite = '1') then
          if (apb0_paddr = BUPTXCNTL_ACP_ADDR_CT(i)) then
            int_acp_bakenable(i) <= apb0_pwdata(24);
            int_acp_txenable(i)  <= apb0_pwdata(23);
            int_acp_ifs(i)       <= apb0_pwdata(19 downto 16);
            int_acp_backoff(i)   <= apb0_pwdata( 9 downto 0);
            write_acp_bkoff(i)   <= '1';
          end if; 
        end if;
  
  
        if (apb1_penable = '1' and apb1_psel = '1' and apb1_pwrite = '1') then
          if (apb1_paddr = BUPTXCNTL_ACP_ADDR_CT(i)) then
            int_acp_bakenable(i) <= apb1_pwdata(24);
            int_acp_txenable(i)  <= apb1_pwdata(23);
            int_acp_ifs(i)       <= apb1_pwdata(19 downto 16);
            int_acp_backoff(i)   <= apb1_pwdata( 9 downto 0);
            write_acp_bkoff(i)   <= '1';
          end if; 
        end if;
  
      end if;
      
    end process apb_writeacp_pr;

  end generate acp_gen;

  no_acp_gen: for j in num_queues_g to 7 generate
    int_acp_bakenable(j) <= '0';
    int_acp_txenable(j)  <= '0';
    int_acp_ifs(j)       <= (others => '0');
    int_acp_backoff(j)   <= (others => '0');
  end generate no_acp_gen;
    
  
  abs_gen: for i in 0 to num_abstimer_g-1 generate
    ------------------------------------------------------------------------------
    -- Register write
    ------------------------------------------------------------------------------
    -- The write cycle follows the timing shown in page 5-5 of the AMBA
    -- Specification.
    apb_writeabs_pr: process (pclk, reset_n)
    begin
      if (reset_n = '0') then
        int_abstime(i)       <= (others => '0');
        int_abscnt_irqsel(i) <= '0';
        int_abscnt_en(i)     <= '0';
        reg_abscnt_ack(i)    <= '0';
  
      elsif (pclk'event and pclk = '1') then
        reg_abscnt_ack(i)    <= '0';

        if (apb0_penable = '1' and apb0_psel = '1' and apb0_pwrite = '1') then
          if (apb0_paddr = BUPABSCNT_ADDR_CT(i)) then
            int_abstime(i)       <= apb0_pwdata(25 downto  0);
            int_abscnt_irqsel(i) <= apb0_pwdata(28);
          elsif (apb0_paddr = BUPABSCNTMASK_ADDR_CT) then
            int_abscnt_en(i)   <= apb0_pwdata(i);
          elsif (apb0_paddr = BUPABSCNTACK_ADDR_CT) then
            reg_abscnt_ack(i)   <= apb0_pwdata(i);
          end if;
        end if;
  
  
        if (apb1_penable = '1' and apb1_psel = '1' and apb1_pwrite = '1') then
          if (apb1_paddr = BUPABSCNT_ADDR_CT(i)) then
            int_abstime(i)       <= apb1_pwdata(25 downto  0);
            int_abscnt_irqsel(i) <= apb1_pwdata(28);
          elsif (apb1_paddr = BUPABSCNTMASK_ADDR_CT) then
            int_abscnt_en(i)   <= apb1_pwdata(i);
          elsif (apb1_paddr = BUPABSCNTACK_ADDR_CT) then
            reg_abscnt_ack(i)   <= apb1_pwdata(i);
          end if;
        end if;
  
      end if;
      
    end process apb_writeabs_pr;

  end generate abs_gen;

  no_abs_gen: for i in num_abstimer_g to 15 generate
    int_abstime(i)       <= (others => '0');
    int_abscnt_irqsel(i) <= '0';
    int_abscnt_en(i)     <= '0';
  end generate no_abs_gen;

end RTL;
