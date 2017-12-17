
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_rx_sm.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.28  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : RX BuP2 state machine.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_sm/vhdl/rtl/bup2_rx_sm.vhd,v  
--  Log: bup2_rx_sm.vhd,v  
-- Revision 1.28  2005/04/19 07:45:00  Dr.A
-- #BugId:906#
-- Corrected buffer full detection when only 8 bytes left in buffer.
--
-- Revision 1.27  2005/03/29 14:06:30  Dr.A
-- #BugId:1162#
-- Control structure not written after FCS error
--
-- Revision 1.26  2005/02/18 16:12:18  Dr.A
-- #BugId:1064#
-- FCS error flag not set after A1 match abort
--
-- Revision 1.25  2005/02/11 13:55:14  Dr.A
-- #BugId:906#
-- access_cnt size reduced
--
-- Revision 1.24  2005/02/10 12:58:35  Dr.A
-- #BugId:906,974#
-- reset_bufempty removed (now coming from memory sequencer) (974)
-- Debugged last wrote access in case of buffer full (906)
--
-- Revision 1.23  2005/01/21 15:41:08  Dr.A
-- #BugId:974#
-- Bufempty flag reset on first memory write access.
--
-- Revision 1.22  2005/01/13 14:02:20  Dr.A
-- #BugId:903,956#
-- New diag ports (903)
-- Rewrote RX state machine for fake bytes and control structure memory accesses. 'rx' signal to the memory sequencer now comes from the RX state machine (956)
--
-- Revision 1.21  2004/12/23 10:19:26  Dr.A
-- #BugId:835#
-- rxrssi bit8 stuck to 1 in control structure
--
-- Revision 1.20  2004/12/22 17:09:12  Dr.A
-- #BugId:906#
-- Removed ring buffer mechanism and added new checks for end of buffer.
--
-- Revision 1.19  2004/12/17 12:54:46  Dr.A
-- #BugId:606#
-- RX end interrupt must be sent to the timers after end of Abort (CCA back to idle)
--
-- Revision 1.18  2004/12/10 10:36:32  Dr.A
-- #BugId:606#
-- Added RX abort after address 1 mismatch
--
-- Revision 1.17  2004/12/06 09:12:35  Dr.A
-- #BugId:836#
-- Address1 field now checked as soon as received, using mask from register.
--
-- Revision 1.16  2004/11/09 14:12:45  Dr.A
-- #BugId:835#
-- New ports for new fields in RX and TX control structures.
--
-- Revision 1.15  2004/04/14 16:10:19  Dr.A
-- Removed unused signal last_word_size.
-- Sampled rxe_errorstat in rx_errstat register at phy_rxstartend_ind falling edge, and reset rx_errstat at the beginning of a new reception.
-- Cleaned state machines (no more test on rxe_errorstat not registered).
--
-- Revision 1.14  2004/02/26 18:14:59  Dr.F
-- added reset of the write_data_sm.
--
-- Revision 1.13  2004/02/20 10:45:36  Dr.F
-- wait until phy_rxstartend_ind = 0 when there is a buffer collision.
--
-- Revision 1.12  2004/02/10 18:30:48  Dr.F
-- removed testmode.
--
-- Revision 1.11  2004/02/06 14:46:04  Dr.F
-- removed testdata_rec.
--
-- Revision 1.10  2004/01/29 17:54:06  Dr.F
-- fixed problem when there is a modem error.
--
-- Revision 1.9  2004/01/26 08:49:01  Dr.F
-- added ready_load.
--
-- Revision 1.8  2004/01/13 17:06:20  Dr.F
-- fixed rx_acc_type for the last RX control structure write access.
--
-- Revision 1.7  2004/01/06 10:50:35  Dr.F
-- changed condition to go in check_rx_state from idle_state.
--
-- Revision 1.6  2003/12/17 19:22:58  Dr.F
-- Fixed the fake bytes write.
--
-- Revision 1.5  2003/12/16 16:30:39  Dr.F
-- fixed end of rx.
--
-- Revision 1.4  2003/12/09 15:55:36  Dr.F
-- fixed load_ptr.
--
-- Revision 1.3  2003/11/25 08:47:35  Dr.F
-- access types in rx ctrl struct are now woed instead of half word.
--
-- Revision 1.2  2003/11/25 07:51:03  Dr.F
-- implemented modification for 2.0 revision.
--
-- Revision 1.1  2003/11/19 16:26:20  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------
-- Taken from revision 1.25 of bup_rx_sm.
--
-- Revision 1.25  2003/11/18 18:03:20  Dr.F
-- resynchronized phy_data_ind due to timing problems.
--
-- Revision 1.24  2003/11/14 10:02:14  Dr.F
-- fixed sensitivity list.
--
-- Revision 1.23  2003/11/13 18:33:00  Dr.F
-- added rx_packet_type for SIFS selection.
--------------------------------------------------------------------------------


library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all;

--library bup2_sm_rtl;
library work;
--use bup2_sm_rtl.bup2_sm_pkg.all;      
use work.bup2_sm_pkg.all;      

--------------------------------------------
-- Entity
--------------------------------------------
entity bup2_rx_sm is
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
end bup2_rx_sm;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of bup2_rx_sm is

--------------------------------------------------------------------------------
-- types
--------------------------------------------------------------------------------

type RX_STATE_TYPE is (idle_state,         -- idle state     
                       wait_byte_state,    -- wait new byte from Modem  
                       fcs_state,          -- receive FCS from Modem  
                       check_rx_state,     -- check received packet  
                       wait_ctrcl_struct_done_state);
                       
type WRITE_DATA_SM_TYPE is (idle_state,          -- idle state     
                            rxdata_state,        -- write rx data
                            fake_byte_state,     -- complete last word to 32bits
                            rxctrlstruct_state); -- write rx ctrl struct

--------------------------------------------------------------------------------
-- Signals
--------------------------------------------------------------------------------

  --------------------------------------
  -- rx state machine
  -------------------------------------- 
  signal rx_state           : RX_STATE_TYPE; -- rx state
  signal next_rx_state      : RX_STATE_TYPE; -- Next rx_state
  signal write_data_sm      : WRITE_DATA_SM_TYPE; -- write_data sm
  signal rx_end_o           : std_logic; -- end of received packet
  signal rx_fcs_err_o       : std_logic; -- end of packet 
                                         -- and FCS error detected (flag)
  signal rx_fcs_err_it_o    : std_logic; -- end of packet 
                                         -- and FCS error detected (pulse)
  signal rx_err_o           : std_logic; -- unexpected end of packet
  signal start_new_rx       : std_logic; -- Indicates a new reception.  


  -------------------------------------- 
  -- Signals to compute the length of the received packet.
  -------------------------------------- 
  signal rx_count           : std_logic_vector(11 downto 0);-- number of bytes
                                                            -- received
  signal rx_packet_size     : std_logic_vector(11 downto 0);-- number of bytes to
                                                            -- store in memory
  signal rxunload_count     : std_logic_vector(15 downto 0);-- max value for rx_count
                                                            -- before reaching rxunload
  signal fcs_data           : std_logic_vector(31 downto 0);-- FCS data computed
                                                            -- on data received
  signal fcs_received       : std_logic_vector(31 downto 0);-- FCS data received
                                                            -- from Modem
  -- last_word_* contain rx counter value on the first byte of the last 32bit
  -- word sent to the memory sequencer, in the following conditions:
  signal last_word_rx_count : std_logic_vector(11 downto 0);-- packet end
  signal last_word_rxabtcnt : std_logic_vector( 5 downto 0);-- packet aborted
  signal last_word_unload   : std_logic_vector(15 downto 0);-- packet colliding
                                                            -- with unload pointer.
  signal last_word_rxsize   : std_logic_vector(15 downto 0);-- packet colliding
                                                            -- with buffer end.
  signal buffer_collision   : std_logic; -- high when rx packet collides with 
                                         -- unload pointer, or end of buffer.
  

  -------------------------------------- 
  -- Information extracted from RX packet
  -------------------------------------- 
  signal rxlen           : std_logic_vector(11 downto 0);-- RX packet size 
  signal rxrate          : std_logic_vector( 3 downto 0);-- RX PSDU rate
  signal rxservice       : std_logic_vector(15 downto 0);-- RX SERVICE field
                                                         -- (802.11a only)
  signal rxccaaddinfo    : std_logic_vector( 7 downto 0);
  signal rxant           : std_logic; -- Antenna used during reception.
  signal rxrssi          : std_logic_vector( 6 downto 0);-- preamble RSSI  
                                                         -- (802.11a only)
  signal frmcntl         : std_logic_vector(15 downto 0); -- Frame Control
  signal durid           : std_logic_vector(15 downto 0); -- Duration / Id
  signal bupaddr1        : std_logic_vector(47 downto 0); -- Address1 field
  -- Address 1 field with some bits masked.
  signal bupaddr1_masked : std_logic_vector(47 downto 0);
  -- Address 1 register with some bits masked.
  signal reg_bupaddr1_masked : std_logic_vector(47 downto 0);
  -- Comparison status between bupaddr1_masked and reg_bupaddr1_masked.
  signal a1match         : std_logic;
  -- Set when conditions to abort RX after address1 mismatch are all met.
  signal next_a1match_abort : std_logic; -- Combinational value
  signal a1match_abort      : std_logic; -- Value registered when valid
  -- Sample rxe_errorstat at phy_rxstartend_ind falling edge.
  signal rx_errstat_o    : std_logic_vector(1 downto 0);


  -------------------------------------- 
  -- Signals from Modem synchronized to detect edges
  -------------------------------------- 
  signal phy_data_ind_ff1      : std_logic; -- phy_data_ind sync once
  signal phy_data_ind_ff2      : std_logic; -- phy_data_ind sync twice
  signal rxv_service_ind_ff1   : std_logic;
  signal phy_rxstartend_ind_ff1: std_logic;  
  

  -------------------------------------- 
  -- Pointers for RX packet.
  -------------------------------------- 
  signal buprxptr_latch   : std_logic_vector(31 downto 0); -- rx pointer
  signal buprxoff_latch   : std_logic_vector(15 downto 0); -- rxoff pointer
  signal buprxunload_latch: std_logic_vector(15 downto 0); -- unload pointer
  signal buprxdata_offset : std_logic_vector(16 downto 0); -- offset of first data
  signal bufempty_latch   : std_logic; -- bufempty flag


  -------------------------------------- 
  -- control structure access counter
  -------------------------------------- 
  signal access_cnt       : std_logic_vector(3 downto 0); -- current pointer
  signal ctrl_strct_done  : std_logic;
  
  -------------------------------------- 
  -- signals for diag
  -------------------------------------- 
  signal rx_fsm_diag      : std_logic_vector(1 downto 0);
  signal last_word_o      : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------

begin
  
  rx_errstat <= rx_errstat_o;
  last_word  <= last_word_o;
  
  ------------------------------------------------------------------------------
  -- synchronize phy_data_ind
  ------------------------------------------------------------------------------
  -- this is done to detect an edge on phy_data_ind
  phy_data_ind_sync_p: process (hclk, hresetn)
  begin
    if (hresetn = '0') then
      phy_data_ind_ff1 <= '0';           
      phy_data_ind_ff2 <= '0';           
    elsif (hclk'event and hclk = '1') then
      phy_data_ind_ff1 <= phy_data_ind;           
      phy_data_ind_ff2 <= phy_data_ind_ff1;           
    end if;
  end process phy_data_ind_sync_p;
      
      
  ------------------------------------------------------------------------------
  -- resynchronize rxv_service_ind
  ------------------------------------------------------------------------------
  -- this is done to detect a rising edge of rxv_service_ind
  rxv_service_ind_sync_p: process (hclk, hresetn)
  begin
    if (hresetn = '0') then
      rxv_service_ind_ff1 <= '0';
    elsif (hclk'event and hclk = '1') then
      rxv_service_ind_ff1 <= rxv_service_ind;
    end if;
  end process rxv_service_ind_sync_p;
      
      

  ------------------------------------------------------------------------------
  -- Resynchronize phy_rxstartend_ind
  ------------------------------------------------------------------------------
  -- This is done to detect a falling edge of phy_rxstartend_ind and sample
  -- rxe_errorstat value. The rx_errstat register is reset at the beginning of
  -- the next reception.
  phy_rxstartend_ind_sync_p: process (hclk, hresetn)
  begin
    if (hresetn = '0') then
      phy_rxstartend_ind_ff1 <= '0';
      rx_errstat_o           <= (others => '0');
    elsif (hclk'event and hclk = '1') then
      phy_rxstartend_ind_ff1 <= phy_rxstartend_ind;
      -- Detect falling edge.
      if (phy_rxstartend_ind = '0') and (phy_rxstartend_ind_ff1 = '1') then
        rx_errstat_o <= rxe_errorstat;
      -- Reset register at the beginning of a new reception.
      elsif (rx_state = idle_state) and (next_rx_state /= idle_state) then
        rx_errstat_o <= (others => '0');
      end if;
    end if;
  end process phy_rxstartend_ind_sync_p;
      
      

  ------------------------------------------------------------------------------
  -- General reception state machine
  ------------------------------------------------------------------------------
  -- Start new reception when general BuP2 state machine is in rx state
  -- (rx_mode = 1) and previous reception is over (rx_end and rx_err reset).
  start_new_rx <= '1' when ( (rx_mode = '1') and
                             (rx_end_o = '0') and (rx_err_o = '0') )
    else '0';
  
  -- Process for next_state.
  rx_sm_comb_p: process(a1match_abort, ctrl_strct_done, phy_rxstartend_ind,
                        reg_rxabtcnt, rx_count, rx_errstat_o, rx_packet_size,
                        rx_state, start_new_rx)
  begin
    
    case rx_state is
      
      -- idle state
      when idle_state =>
        -- New reception.
        if (start_new_rx = '1') then
          next_rx_state <= wait_byte_state;
        else -- Wait for end of reception or start of new reception.
          next_rx_state <= idle_state;
        end if;
        
      -- Waiting for a byte from Modem.
      when wait_byte_state =>
        -- RX abort after address1 mismatch
        if (a1match_abort = '1' and rx_count = reg_rxabtcnt) or
           -- Error from Modem
           (phy_rxstartend_ind = '0') or
           -- End of PSDU
           (rx_count = rx_packet_size) then
          next_rx_state <= fcs_state;
        else
          next_rx_state <= wait_byte_state;
        end if;
          
      -- Receive FCS data.
      when fcs_state =>
        if ((a1match_abort = '1' and rx_count = reg_rxabtcnt) or -- RX abort
            (phy_rxstartend_ind = '0') or -- End of packet.
            (rx_errstat_o /= "00") or     -- Error from Modem in wait_byte_state
            (rx_count = 4) ) then         -- End of FCS.
          next_rx_state <= check_rx_state;
        else
          next_rx_state <= fcs_state;
        end if;

      -- Check FCS, packet size and MODEM status
      when check_rx_state =>
        if ctrl_strct_done = '1' then
          next_rx_state <= idle_state;
        else
          next_rx_state <= wait_ctrcl_struct_done_state;          
        end if;
        
      -- Wait until the control structure has been written
      when wait_ctrcl_struct_done_state =>
        if (ctrl_strct_done = '1') then
          next_rx_state <= idle_state;
        else
          next_rx_state <= wait_ctrcl_struct_done_state;   
        end if;
        
      when others => 
        next_rx_state <= idle_state;

    end case;
  end process rx_sm_comb_p;

 
  -- Reception state machine sequencial process
  rx_sm_seq_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      rx_state <= idle_state;
    elsif (hclk'event and hclk = '1') then
      rx_state <= next_rx_state;
    end if;
  end process rx_sm_seq_p;
 
  
  ------------------------------------------------------------------------------
  -- Address1 checking
  ------------------------------------------------------------------------------
  -- Mask some bits of Address 1 before performing matching.
  bupaddr1_masked <= bupaddr1(47 downto 44) &
                     (bupaddr1(43 downto 40) and not(reg_addr1mskh)) &
                     bupaddr1(39 downto 28) &
                     (bupaddr1(27 downto 24) and not(reg_addr1mskl)) &
                     bupaddr1(23 downto 0);
                     
  reg_bupaddr1_masked <= reg_bupaddr1(47 downto 44) &
                     (reg_bupaddr1(43 downto 40) and not(reg_addr1mskh)) &
                     reg_bupaddr1(39 downto 28) &
                     (reg_bupaddr1(27 downto 24) and not(reg_addr1mskl)) &
                     reg_bupaddr1(23 downto 0);
                     
  -- Detect matching of received address 1 field against register, using mask.
  a1match <= '1' when reg_bupaddr1_masked = bupaddr1_masked else '0';
  
  -- Detect condition of RX abort on address1 mismatch
  next_a1match_abort <= '1' when reg_enrxabort = '1'        -- RX abort enabled by software
                             and bupaddr1(0) = '0'          -- The packet is not a broadcast packet
                             and a1match = '0'              -- Masked address1 field does not match register
                             and reg_rxabtcnt < (rxlen-4)   -- (Packet length - FCS) bigger than minimum to store
                             else '0';
                     

  ------------------------------------------------------------------------------
  -- Control signals management. 
  ------------------------------------------------------------------------------
  -- This controls the reception state machine,
  -- the memory sequencer, the FCS generation and the general sm.
  rx_control_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      -- Pointers and counters for memory accesses
      rx_count          <= (others => '0');
      mem_seq_rxptr     <= (others => '0');
      -- BuP registers latched at reception start
      buprxptr_latch    <= (others => '0');
      buprxoff_latch    <= (others => '0');
      buprxunload_latch <= (others => '0');
      bufempty_latch    <= '0';
      -- Status and error flags
      rx_end_o          <= '0';
      rx_err_o          <= '0';
      rx_fcs_err_o      <= '0';
      rx_fcs_err_it_o   <= '0';
      rx_fullbuf        <= '0';
      rxend_stat        <= (others => '0');
      reg_a1match       <= '0';    
      rx_packet_type    <= '0';
      a1match_abort     <= '0';
      buffer_collision  <= '0';
      -- FCS control
      fcs_data_valid    <= '0';
      fcs_init          <= '0';
      fcs_received      <= (others => '0');
      -- Data read from control structure
      frmcntl           <= (others => '0');
      durid             <= (others => '0');
      rxlen             <= (others => '0');
      rxservice         <= (others => '0');        
      rxrate            <= (others => '0');
      rxrssi            <= (others => '0');
      rxccaaddinfo      <= (others => '0');
      rxant             <= '0';
      bupaddr1          <= (others => '0');
      -- Registers for control structure data
      reg_frmcntl       <= (others => '0');    
      reg_durid         <= (others => '0');
      reg_rxlen         <= (others => '0');
      reg_rxserv        <= (others => '0');
      reg_rxrate        <= (others => '0'); 
      reg_rxrssi        <= (others => '0');
      reg_rxccaaddinfo  <= (others => '0');
      reg_rxant         <= '0';

    elsif (hclk'event and hclk = '1') then
      case rx_state is
        
        --------------------------------------------
        -- Wait for start of RX packet
        --------------------------------------------
        when idle_state =>
          rx_count          <= (others => '0');
          fcs_received      <= (others => '0');
          rx_end_o          <= '0';
          rx_err_o          <= '0';
          rx_fcs_err_it_o   <= '0';
          buffer_collision  <= '0';
          -- Latch BuP registers values
          buprxptr_latch    <= buprxptr;    -- Start of RX buffer
          buprxoff_latch    <= buprxoff;    -- RX offset
          buprxunload_latch <= buprxunload; -- Unload pointer
          bufempty_latch    <= bufempty;    -- Bufempty flag
          -- Initialize the memory sequencer pointer:
          -- The PSDU is located just after the control structure (8 bytes)
          mem_seq_rxptr     <= buprxptr + buprxoff + "1000";
          
          -- Start of reception: next_rx_state = wait_byte_state.
          if (start_new_rx = '1') then  
            -- Reset A1 match bit, in case packet is smaller than 10 bytes.
            reg_a1match   <= '0';
            -- Reset abort flag.
            a1match_abort <= '0';
            
            -- Latch data from modem lines.
            rxlen        <= rxv_length;
            rxrate       <= rxv_datarate;
            rxrssi       <= rxv_rssi;
            rxservice    <= rxv_service;
            rxccaaddinfo <= rxv_ccaaddinfo;
            rxant        <= rxv_rxant;
            -- Reset FCS computation.
            fcs_init     <= '1';
            
          end if;
        
        --------------------------------------------
        -- store data from modem and 
        -- send indication to Mem Seq and FCS.  
        --------------------------------------------
        when wait_byte_state =>
          -- Reset fcs_init, set in idle_state
          fcs_init  <= '0';
          
          -- For 802.11a modem rxv_service availability is indicated by
          -- a rising edge of rxv_service_ind
          if (rxv_service_ind = '1') and (rxv_service_ind_ff1 = '0') then
            rxservice <= rxv_service;
          end if;        
                              
          -- New data
          if phy_data_ind_ff2 /= phy_data_ind_ff1 then
            -- New data for FCS
            fcs_data_valid  <= '1';
            
            -- Copy the MAC header Frame Control, Duration ID and Address1 fields
            -- (10 first bytes)
            case conv_integer(rx_count) is
              when 0 =>
                frmcntl(7 downto 0) <= bup_rxdata;
              when 1 =>
                frmcntl(15 downto 8) <= bup_rxdata;
              when 2 =>
                durid(7 downto 0) <= bup_rxdata;
              when 3 =>
                durid(15 downto 8) <= bup_rxdata;
              when 4 =>
                bupaddr1(7 downto 0) <= bup_rxdata;
              when 5 =>
                bupaddr1(15 downto 8) <= bup_rxdata;
              when 6 =>
                bupaddr1(23 downto 16) <= bup_rxdata;
              when 7 =>
                bupaddr1(31 downto 24) <= bup_rxdata;
              when 8 =>
                bupaddr1(39 downto 32) <= bup_rxdata;
              when 9 =>
                bupaddr1(47 downto 40) <= bup_rxdata;
              when others =>
                null;
            end case;
          else -- No new data
            fcs_data_valid  <= '0';
            if rx_count = 10 then 
              -- Check Address1 field.
              if a1match = '1' then
                reg_a1match <= '1';
              else
                reg_a1match <= '0';
              end if;
              -- Register RX abort command.
              a1match_abort <= next_a1match_abort;
            end if;
          end if;
          
          -- Increase rx_count each new data till end of packet.
          if (rx_count = rx_packet_size) then -- End of data to store in memory
            rx_count  <= (others => '0');
          -- New data byte to store in memory
          elsif phy_data_ind_ff2 /= phy_data_ind_ff1 then  
            rx_count  <= rx_count + '1';
            -- Detect buffer overrun (only when a new byte is received).
            if (ext(rx_count, 16) >= rxunload_count)      -- End of free buffer
               or (buprxdata_offset >= ext(buprxsize, 17)) -- No space for data between rxoff and end of buffer
               or ((buprxdata_offset + ext(rx_count, 17) + 1 >= buprxsize) -- End of buffer, 
                    and (rx_count < rx_packet_size-1)) then                -- and more data expected
              buffer_collision <= '1';
            end if;
          end if;

           
          
        --------------------------------------------
        -- Rceive the FCS data from Modem
        --------------------------------------------
        when fcs_state =>
          fcs_data_valid <= '0';
          -- Next memory access will be to store the control structure.
          -- The control structure is located at the beginning of the buffer.
          mem_seq_rxptr  <= buprxptr_latch + buprxoff_latch;
          -- Receive FCS data (4 bytes)
          if (phy_data_ind_ff2 /= phy_data_ind_ff1) and
             (rx_count < 4) then
            fcs_received(23 downto 0)  <= fcs_received(31 downto 8);
            fcs_received(31 downto 24) <= bup_rxdata;
            rx_count                   <= rx_count + 1;
          end if;
        
        --------------------------------------------
        -- Check the received data 
        --------------------------------------------
        when check_rx_state =>
          rx_end_o          <= '1'; -- End of packet.
          rx_count          <= (others => '0');
          -- Update BuP2 registers with information from packet just received.
          reg_frmcntl       <= frmcntl;
          reg_durid         <= durid;
          rx_packet_type    <= rxrate(3);
          reg_rxlen         <= rxlen;
          reg_rxserv        <= rxservice;
          reg_rxrate        <= rxrate;
          reg_rxrssi        <= rxrssi;
          reg_rxccaaddinfo  <= rxccaaddinfo;
          reg_rxant         <= rxant;
          -- RX end status
          rxend_stat        <= '0' & a1match_abort;
          -- Default values for error flags memorized till end of next RX.  
          rx_fcs_err_o      <= '0';
          rx_fullbuf        <= '0';                          
          -- Rx status: Update error flags.
          if rx_errstat_o /= "00" then
            rx_err_o        <= '1';           
          elsif (buffer_collision = '1') then
            rx_fullbuf      <= '1';
          -- FCS error flag is not set in case of aborted packet.
          elsif (fcs_received /= fcs_data) and (a1match_abort = '0') then
            rx_fcs_err_o    <= '1';
            rx_fcs_err_it_o <= '1';
          end if;

        --------------------------------------------
        -- Wait until the control structure has been written 
        --------------------------------------------
        when wait_ctrcl_struct_done_state =>
          -- Reset interrupt signals (pulses set in check_rx_state)
          rx_end_o          <= '0';
          rx_fcs_err_it_o   <= '0';
          
        when others => 

      end case;
    end if;
  end process rx_control_p;

  rx_end          <= rx_end_o;
  rx_err          <= rx_err_o;
  rx_fcs_err      <= rx_fcs_err_o;
 
  --------------------------------------------
  -- Write data in memory : buprxdata and rx control structure
  --------------------------------------------
  write_data_p : process(hclk, hresetn)
    variable access_cnt_int_v : integer;
    variable nbr_fake_byte_v  : std_logic_vector(1 downto 0);
  begin
    if (hresetn = '0') then
      write_data_sm     <= idle_state;
      mem_seq_ind       <= '0';
      data_to_mem_seq   <= (others => '0');
      access_cnt        <= (others => '0');
      last_word_o       <= '0';
      load_rxptr        <= '0';
      ctrl_strct_done   <= '0';
      rx_acc_type       <= BYTE_CT;
      nbr_fake_byte_v   := "00";

    elsif (hclk'event and hclk = '1') then

      case write_data_sm is
        --------------------------------------------
        -- Do nothing in idle state
        --------------------------------------------
        when idle_state =>
          mem_seq_ind       <= '0';
          data_to_mem_seq   <= (others => '0');
          access_cnt        <= (others => '0');
          last_word_o       <= '0';
          load_rxptr        <= '0';
          ctrl_strct_done   <= '0';
          nbr_fake_byte_v   := "00";
          if start_new_rx = '1' then             
            write_data_sm     <= rxdata_state;
            -- rx data are byte considered
            rx_acc_type       <= BYTE_CT;
            load_rxptr        <= '1'; -- Update pointer to store RX data.
          end if;
          
        --------------------------------------------
        -- Write the received data in memory
        --------------------------------------------
        when rxdata_state =>
          load_rxptr <= '0'; -- Reset pulse.
          
          -- indicates a new byte is available for the memory sequencer
          if phy_data_ind_ff2 /= phy_data_ind_ff1 then
            data_to_mem_seq <= bup_rxdata;
            if (buffer_collision = '0') then
              mem_seq_ind     <= '1';
            end if;
          else
            mem_seq_ind     <= '0'; -- Reset pulse.
          end if;
          
          -- indicates the last word before sending a pointer update to the memory sequencer.
          -- (end of packet or RX abort). If necessary, fake bytes will be sent to complete
          -- a 32-bit word. The new pointer will point to the control structure.
          if (a1match_abort = '1') then
            if (rx_count = ext(last_word_rxabtcnt, 12)) then
              last_word_o     <= '1';
              nbr_fake_byte_v := reg_rxabtcnt(1 downto 0);
            else
              last_word_o     <= '0';
            end if;  
          else -- No abort. Detect lat word: end of buffer, or end of packet without previous collision.
            if (ext(rx_count,16) = last_word_unload) or (ext(rx_count,16) = last_word_rxsize) 
               or ((rx_count = last_word_rx_count) and (buffer_collision = '0') ) then
              last_word_o     <= '1'; -- This is the first byte of the last word to store in memory.
              nbr_fake_byte_v := rx_packet_size(1 downto 0);
            else
              last_word_o     <= '0';
            end if;  
          end if;  
          
          -- when all data is received, or when reception is
          -- aborted, go to the next state
          if (rx_count = rx_packet_size)
            or (a1match_abort = '1' and rx_count = ext(reg_rxabtcnt, 12)) then
            if (nbr_fake_byte_v = "00") then
              write_data_sm <= rxctrlstruct_state;
            else
              write_data_sm <= fake_byte_state;
            end if;
            access_cnt <= (others => '0');
          end if;
          
          -- End of reception
          if (phy_rxstartend_ind = '0') then
            write_data_sm     <= rxctrlstruct_state;
            access_cnt        <= (others => '0');
          end if;

        --------------------------------------------
        -- send fake bytes to the memory sequency 
        -- to fill a 32-bit word
        --------------------------------------------
        when fake_byte_state =>
          mem_seq_ind      <= '0';
          if buffer_collision = '1' then
            -- The fake bytes or not written.
            write_data_sm     <= rxctrlstruct_state;
          else
            if (nbr_fake_byte_v = "00") then
              -- All fake bytes written
              write_data_sm     <= rxctrlstruct_state;
            else
              -- Access to complete a 32-bit word, i.e. to fill exactly the memory
              -- sequencer buffer. No risk of overflow, 'ind' can be sent each clock
              -- cycle.
              mem_seq_ind     <= '1';
              nbr_fake_byte_v := nbr_fake_byte_v + '1';            
            end if;
          end if;


        --------------------------------------------
        -- Write the received control structure in memory
        --------------------------------------------
        when rxctrlstruct_state =>
          last_word_o     <= '0';
          mem_seq_ind     <= '0';
          load_rxptr      <= '0'; -- Reset pulse
          
          -- If there is a buffer collision, or a reception error, the control
          -- structure is not written
          if (buffer_collision = '0') and (rx_errstat_o = "00") 
              and ((rx_fcs_err_it_o = '0') or (fcsdisb = '1')) then          
          
            -- The RX control structure is 8 bytes. It is written by filling both
            -- Modem and AHB buffers in the memory sequencer, in 8 clock cycles.
            -- The write operation is started when both buffers are empty and all 
            -- memory sequencer AHB accesses over (ready_load = 1).
            access_cnt_int_v := conv_integer(access_cnt);
            case access_cnt_int_v is
              when 0 =>
                -- Wait for end of data AHB accesses.
                if (ready_load = '1') then
                  -- load new pointer
                  load_rxptr      <= '1';
                  -- control structure fields are half words
                  rx_acc_type     <= WORD_CT;
                  access_cnt      <= access_cnt + '1';
                end if;
              -- write LSB of rxlen
              when 1 =>
                mem_seq_ind     <= '1';
                data_to_mem_seq <= rxlen(7 downto 0);
                access_cnt      <= access_cnt + '1';
              -- write MSB of rxlen
              when 2 =>
                mem_seq_ind     <= '1';
                data_to_mem_seq <= "0000" & rxlen(11 downto 8);
                access_cnt      <= access_cnt + '1';
              -- write LSB of rxv_service
              when 3 =>
                mem_seq_ind     <= '1';
                data_to_mem_seq <= rxservice(7 downto 0);
                access_cnt      <= access_cnt + '1';
              -- write MSB of rxv_service
              when 4 =>
                mem_seq_ind     <= '1';
                data_to_mem_seq <= rxservice(15 downto 8);
                access_cnt      <= access_cnt + '1';
              -- write RSSI
              when 5 =>
                mem_seq_ind     <= '1';
                data_to_mem_seq <= '1' & rxrssi;
                access_cnt      <= access_cnt + '1';
              -- write RXANT
              when 6 =>
                mem_seq_ind     <= '1';
                data_to_mem_seq <= "0000000" & rxant;
                access_cnt      <= access_cnt + '1';
              -- write rx data rate
              when 7 =>
                mem_seq_ind     <= '1';
                data_to_mem_seq <= "0000" & rxrate;
                access_cnt      <= access_cnt + '1';
              -- write CCa info
              when 8 =>
                last_word_o     <= '1'; -- Last control structure access.
                mem_seq_ind     <= '1';
                data_to_mem_seq <= rxccaaddinfo;
                access_cnt      <= access_cnt + '1';
              -- Wait for end of AHB control structure accesses.
              when 9 =>
                mem_seq_ind     <= '0';  -- No more accesses.
                if ready_load = '1' then -- AHB access over
                  ctrl_strct_done <= '1';
                end if;
              when others =>
            end case;
          
          else -- Error or buffer collision
            ctrl_strct_done <= '1';
          end if;
            
          -- When ctrl_strct_done flag is set (all accesses done or error or buffer
          -- collision), wait for main state machine to go back to idle state.
          if (ctrl_strct_done = '1') and (rx_state = idle_state) then
            write_data_sm     <= idle_state;
          end if;

        when others =>
          
      end case;
    end if;
  end process write_data_p;
  
  ------------------------------------------------------------------------------
  -- Packet size: number of bytes of data that will be saved in memory
  ------------------------------------------------------------------------------
  with fcsdisb select
    rx_packet_size <=
      rxlen          when '1',    -- FCS is saved in memory
      rxlen - "100"  when others; -- FCS is not saved in memory
        

  -- Offset of first data in RX buffer.
  buprxdata_offset <= ext(buprxoff_latch, 17) + 8;

  -- This process computes how many bytes can be stored in the memory buffer
  -- before reaching the rxunload pointer. In case the packet collides with rxunload,
  -- the last_word_unload signal indicates the first byte of the last 32bit word
  -- to store in memory. Else, last_word_unload is set to its max value.
  rxunload_count_p: process(bufempty_latch, buprxdata_offset, buprxoff_latch,
                            buprxunload_latch)
  begin
    -- Normal configuration: RX packet is stored after unload pointer.
    if (buprxunload_latch < buprxoff_latch) then
      rxunload_count    <= (others => '1');   -- Max value
      last_word_unload  <= (others => '1'); -- Signal not used
    -- Last received packet fitted exactly in free buffer, bufempty_latch
    -- indicates if it has already been unloaded or not.
    elsif (buprxunload_latch = buprxoff_latch) then
      if (bufempty_latch = '1') then       -- Empty buffer
        rxunload_count    <= (others => '1'); -- Max value
        last_word_unload  <= (others => '1'); -- Signal not used
      else                                 -- Full buffer
        rxunload_count    <= (others => '0'); -- Min value
        last_word_unload  <= (others => '1'); -- Signal not used
      end if;
    -- buprxunload_latch > buprxoff_latch: check if enough place for packet in free buffer.
    else
      -- No space for control structure
      if ( ext(buprxunload_latch, 17) < buprxdata_offset) then
        rxunload_count    <= (others => '0'); -- Min value
        last_word_unload  <= (others => '1'); -- Signal not used
      -- Space for some/all data up to rxunload_count
      else
        rxunload_count    <= buprxunload_latch - buprxdata_offset(15 downto 0);
        -- buprxunload is aligned on 8 bytes.
        last_word_unload  <= buprxunload_latch - 4;
      end if;
    end if;
  end process rxunload_count_p;


  ------------------------------------------------------------------------------
  -- Define the rx_counter value before last word
  ------------------------------------------------------------------------------
  last_word_rx_count  <= rx_packet_size - "100" 
                                  when rx_packet_size(1 downto 0) = "00" else
                        (rx_packet_size(11 downto 2) & "00");
  last_word_rxabtcnt  <= reg_rxabtcnt - "100" 
                                  when reg_rxabtcnt(1 downto 0) = "00" else
                        (reg_rxabtcnt(5 downto 2) & "00");
  -- End of buffer: remove offset + 8 bytes for the control structure + 4 bytes
  -- to reach last word (rxsize aligned on 8bytes boundary).
  -- Overflow is don't care because if no space for control structure, no byte
  -- is written to memory and last_word is not used.
  last_word_rxsize    <= buprxsize - buprxoff_latch - 12; 
  

  ------------------------------------------------------------------------------
  -- FCS data concatenation                      
  ------------------------------------------------------------------------------
  fcs_data <= fcs_data_4th & fcs_data_3rd & fcs_data_2nd & fcs_data_1st;
  
  
  ------------------------------------------------------------------------------
  -- Control for Memory sequencer
  ------------------------------------------------------------------------------  
  rx_mode_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      mem_seq_rx_mode <= '0';
    elsif hclk'event and hclk = '1' then
      if next_rx_state = idle_state then
        mem_seq_rx_mode <= '0';
      else
        mem_seq_rx_mode <= '1';
      end if;
    end if;
  end process rx_mode_p;
  
  

  ------------------------------------------------------------------------------
  -- diag
  ------------------------------------------------------------------------------
  
  rx_sm_diag <= rx_fsm_diag &       -- 7:6
                buffer_collision &  -- 5
                last_word_o &       -- 4
                ready_load &        -- 3
                ctrl_strct_done &   -- 2
                "00";               --

  rx_sm_diag_p : process(rx_state)
  begin
    case rx_state is
      when idle_state =>
        rx_fsm_diag <= "00";
      when wait_byte_state =>
        rx_fsm_diag <= "01";
      when fcs_state =>
        rx_fsm_diag <= "10";
      when check_rx_state =>
        rx_fsm_diag <= "11";

      when others =>
        rx_fsm_diag <= "11";
        
    end case;
  end process rx_sm_diag_p;

end RTL;
