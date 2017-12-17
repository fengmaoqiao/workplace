
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_tx_sm.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.17  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Transmission BuP2 state machine.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_sm/vhdl/rtl/bup2_tx_sm.vhd,v  
--  Log: bup2_tx_sm.vhd,v  
-- Revision 1.17  2005/03/17 16:34:11  Dr.A
-- #BugId:1087#
-- Rewrote control structure read state because it was not working with the bus granted to the BuP by default.
--
-- Revision 1.16  2005/03/16 14:54:00  Dr.A
-- #BugId:1087#
-- Added state to change PSDUs
--
-- Revision 1.15  2005/03/01 10:04:48  Dr.A
-- #BugId:1087#
-- New state machine for memory sequencer control.
--
-- Revision 1.14  2005/01/21 15:42:06  Dr.A
-- #BugId:822,978#
-- TX immediate stop debug. Added output to timers.
--
-- Revision 1.13  2005/01/10 12:50:44  Dr.A
-- #BugId:912#
-- Removed enable_bup
--
-- Revision 1.12  2004/12/20 13:02:24  Dr.A
-- #BugId:822#
-- Connected txend status line
--
-- Revision 1.11  2004/12/10 10:35:25  Dr.A
-- #BugId:702#
-- Read ack time-out fields from TX control structure
--
-- Revision 1.10  2004/12/02 10:28:48  Dr.A
-- #BugId:822#
-- Added tx abort controlled by tx immediate stop register
--
-- Revision 1.9  2004/11/09 14:12:51  Dr.A
-- #BugId:835#
-- New ports for new fields in RX and TX control structures.
--
-- Revision 1.8  2004/04/14 08:29:03  Dr.A
-- Syntax error corrected.
--
-- Revision 1.7  2004/04/09 12:11:06  Dr.A
-- Removed redundant signal byte_tx_done, use phy_data_conf_pulse instead.
--
-- Revision 1.6  2004/02/10 18:32:08  Dr.F
-- begugged when FCS is disabled.
--
-- Revision 1.5  2004/01/13 17:05:43  Dr.F
-- fixed acc_type for control structure access.
--
-- Revision 1.4  2003/12/17 13:19:06  Dr.F
-- fixed guard_time_expired flag.
--
-- Revision 1.3  2003/12/09 15:56:40  Dr.F
-- resynchronized some signals due to timing problems.
--
-- Revision 1.2  2003/11/25 07:51:30  Dr.F
-- implemented modification according to 2.0 revision.
--
-- Revision 1.1  2003/11/19 16:26:24  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------
-- Taken from revision 1.24 of bup_tx_sm.
--
-- Revision 1.24  2003/11/18 18:04:06  Dr.F
-- delayed txrate_read_done due to timing problems.
--
-- Revision 1.23  2003/11/15 14:37:19  Dr.F
-- txpwr_level size changed.
--
-- Revision 1.22  2003/11/13 18:35:05  Dr.F
-- added tx_packet_type for SIFS selection.
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
entity bup2_tx_sm is
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
end bup2_tx_sm;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of bup2_tx_sm is

  --------------------------------------------
  -- Constant
  --------------------------------------------
  constant A_TIME_BEFORE_READ_CT : std_logic_vector(4 downto 0) 
                   := conv_std_logic_vector(14, 5);
  constant B_TIME_BEFORE_READ_CT : std_logic_vector(4 downto 0) 
                   := conv_std_logic_vector(25, 5);
  
--------------------------------------------------------------------------------
-- types
--------------------------------------------------------------------------------
type BYTE_TX_STATE_TYPE_T is (idle_state,      -- idle state     
                            tx_req_state);     -- request to transmit a byte  

type TX_STATE_TYPE_T is (tx_abort_state,  -- abort transmission
                       idle_state,        -- idle state     
                       tx_start_state,    -- start packet transmission  
                       transmit_state,    -- start byte transmission  
                       tx_conf_state,     -- wait byte transmission confirmation  
                       transmit_fcs_state,-- send FCS data  
                       tx_fcs_conf_state, -- wait FCS bytes transmission 
                                          -- confirmation  
                       tx_end_state);     -- end of transmission

type READ_STATE_TYPE_T is (idle_state,          -- idle state     
                         read_ctrlstr_state,    -- read control structure
                         read_psdu_state,       -- read PSDU
                         change_psdu_state,     -- Change to next PSDU data buffer
                         wait_end_state,        -- Wait for TX end
                         wait_abort_state);     -- Wait for end of abort

--------------------------------------------------------------------------------
-- Signals
--------------------------------------------------------------------------------
  --------------------------------------
  -- Byte transmission state machine
  -------------------------------------- 
  signal byte_tx_state      : BYTE_TX_STATE_TYPE_T; -- byte tx state
  signal next_byte_tx_state : BYTE_TX_STATE_TYPE_T; -- Next byte_tx_state
  signal transmit_byte      : std_logic; -- request to start a byte transmission
  signal byte_to_transmit   : std_logic_vector(7 downto 0); -- byte transmitted 
                                                            -- to Modem
  --------------------------------------
  -- transmission state machine
  -------------------------------------- 
  signal tx_state           : TX_STATE_TYPE_T; -- tx state
  signal next_tx_state      : TX_STATE_TYPE_T; -- Next tx_state
  -- Counter for sent bytes. Ends transmission when txlen bytes sent.
  signal tx_count           : std_logic_vector(11 downto 0);
  -- Counter for sent bytes in the current PSDU. Chenge to next non-null PSDU
  -- when psdu0_len bytes sent.
  signal tx_psdu_count      : std_logic_vector(11 downto 0); 
  -- Signals used to detect when the state machine enters 'read_psdu_state'.
  signal enter_psdu_state   : std_logic;
  signal enter_psdu_state_ff: std_logic;
  -- Signal HIGH when the next PSDU parameters are loaded.
  signal psdu_changed       : std_logic;
  
  signal select_data        : std_logic_vector( 2 downto 0);-- select the FCS 
                                                            -- data source 
                                                            -- sent to Modem
  signal start_tx           : std_logic; -- Start of TX detected from main state machine.
  signal tx_end_o           : std_logic; -- end of transmit packet
  signal tximmstop_stat     : std_logic; -- TX status, high after immediate stop.
  signal tximmstop_latch    : std_logic; -- tximmstop latched during abort.
  signal test_data_1st      : std_logic_vector(7 downto 0); -- First test data
  signal test_data_2nd      : std_logic_vector(7 downto 0); -- Second test data
  signal test_data_3rd      : std_logic_vector(7 downto 0); -- Third test data
  signal test_data_4th      : std_logic_vector(7 downto 0); -- Fourth test data

  signal phy_data_conf_ff1  : std_logic;
  signal phy_data_conf_pulse: std_logic;
  signal phy_data_req_o     : std_logic;
  signal phy_txstartend_req_o : std_logic;
  
  -- packet header parameters
  signal read_state           : READ_STATE_TYPE_T;    -- read access state machine
  signal next_read_state      : READ_STATE_TYPE_T;    -- read access state machine
  signal txlen                : std_logic_vector(11 downto 0); -- TX PSDU length
  signal txrate               : std_logic_vector( 3 downto 0); -- TX PSDU rate
  signal txrate_read_done     : std_logic; -- goes high when txrate is read
  signal txrate_read_done_ff1 : std_logic; -- delay txrate_read_done
  signal invalid_length       : std_logic; -- High when packet is too small

  -- control structure pointer
  signal ctrl_struc_ptr      : std_logic_vector(31 downto 0);
  -- PSDU lengths and pointers
  signal psdu_num            : std_logic_vector(2 downto 0);
  signal psdu0_len           : std_logic_vector(11 downto 0);
  signal psdu0_ptr           : std_logic_vector(31 downto 0);
  signal psdu1_len           : std_logic_vector(11 downto 0);
  signal psdu1_ptr           : std_logic_vector(31 downto 0);
  signal psdu2_len           : std_logic_vector(11 downto 0);
  signal psdu2_ptr           : std_logic_vector(31 downto 0);
  signal last_word_tx_count  : std_logic_vector(11 downto 0);
  signal last_now            : std_logic; -- Flag set when last_word must be set with load_txptr.
  -- access counter
  signal access_cnt          : std_logic_vector(5 downto 0);
  
  -- guarantied time counter
  signal guar_time_cnt        : std_logic_vector(4 downto 0);
  signal guar_time_cnt_max    : std_logic_vector(4 downto 0);
  signal guar_time_cnt_enable : std_logic;
  signal guar_time_expired    : std_logic;
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------

begin
  -- Assign internal signals to output ports
  phy_data_req       <= phy_data_req_o;
  phy_txstartend_req <= phy_txstartend_req_o;
  txv_datarate       <= txrate;
  txv_length         <= txlen;
  txend_stat         <= '0' & tximmstop_stat;
  -- Immediate stop signal sent to timers: signal from register,
  -- or signal from state machines.
  tximmstop_sm       <= tximmstop or tximmstop_latch;
  
  guar_time_cnt_max <= A_TIME_BEFORE_READ_CT when txrate(3) = '1' 
                  else B_TIME_BEFORE_READ_CT;
  
  --------------------------------------------
  -- Guarantied time counter generation.
  -- This counter is used to guaranty a minimum time
  -- between the start of the packet and the start of read
  -- of the PSDU. Thus, this allows the software to modify the
  -- beginning of the PSDU (MAC header) on tx start interrupt.
  --------------------------------------------
  guar_time_cnt_p: process (hclk, hresetn)
    variable enable_1mhz_ff1_v : std_logic;
  begin
    if hresetn = '0' then
      guar_time_cnt        <= (others => '0');
      guar_time_cnt_enable <= '0';
      enable_1mhz_ff1_v    := '0';
      guar_time_expired    <= '0';
    elsif (hclk'event and hclk = '1') then
      -- reset the guarantied time counter when in idle state
      if (tx_state = idle_state) then
        guar_time_cnt        <= (others => '0');
        guar_time_cnt_enable <= '0';
        guar_time_expired    <= '0';
      end if;  
      -- as soon as the packet starts to be transmitted,
      -- the guarantied time counter is enabled.
      if (txrate_read_done = '1') and (tx_state = tx_start_state) and
         (guar_time_expired = '0') then
        guar_time_cnt_enable <= '1';
      end if;
      -- the guarantied time counter is incremented every microsecond
      -- when enabled.
      -- As enable_1mhz is generated with bup_clk and can thus be high
      -- during 2 hclk clock cycles, we look at rising edge of enable_1mhz.
      if (enable_1mhz = '1') and (enable_1mhz_ff1_v = '0') and
         (guar_time_cnt_enable = '1') then
        guar_time_cnt <= guar_time_cnt + '1';
      end if;
      -- stop the counter when it reaches the guarantied time.
      if (guar_time_cnt = guar_time_cnt_max) then
        guar_time_cnt        <= (others => '0');
        guar_time_cnt_enable <= '0';
        guar_time_expired    <= '1';
      end if;
      
      enable_1mhz_ff1_v := enable_1mhz;
    end if;
  end process guar_time_cnt_p;
  
  
  --------------------------------------------
  -- pulse generation
  --------------------------------------------
  pulse_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      phy_data_conf_ff1       <= '0';
    elsif (hclk'event and hclk = '1') then
      phy_data_conf_ff1       <= phy_data_conf;
    end if;
  end process pulse_p;
  phy_data_conf_pulse <= phy_data_conf xor phy_data_conf_ff1;
  
  ------------------------------------------------------------------------------
  -- Byte transmission state machine
  ------------------------------------------------------------------------------
  byte_tx_sm_comb_p: process(byte_tx_state, phy_data_conf_pulse, transmit_byte,
                             tximmstop_latch)
  begin
    
    case byte_tx_state is
      
      -- Idle state
      -- No need to check for immediate stop: in case of abort, tx_state 
      -- = tx_abort_state or tx_end_state and transmit_byte = 0.
      when idle_state =>
        if (transmit_byte = '1') then             
          next_byte_tx_state <= tx_req_state;
        else
          next_byte_tx_state <= idle_state;
        end if;
        
      -- Request to transmit a byte to modem
      -- The data is presented to the modem at the same time.
      -- Wait for a Modem confirmation (ready for new byte)
      -- Go back to idle if TX is aborted.
      when tx_req_state =>
        if (phy_data_conf_pulse = '1') or (tximmstop_latch = '1') then
          next_byte_tx_state <= idle_state;
        else
          next_byte_tx_state <= tx_req_state;
        end if;
          
      when others => 
        next_byte_tx_state <= idle_state;

    end case;
  end process byte_tx_sm_comb_p;

 
  -- Byte transmission state machine sequencial process
  -- the state machine is also reset to idle_state
  -- when the BuP is disabled or when the state machines are reseted 
  byte_tx_sm_seq_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      byte_tx_state <= idle_state;
    elsif (hclk'event and hclk = '1') then
      byte_tx_state <= next_byte_tx_state;
    end if;
  end process byte_tx_sm_seq_p;
 

  -- Byte transmission signals to modem management. 
  -- This set the request signal to modem and the data to be transmited.
  -- This also indicates when the byte transmission is done.
  tx_modem_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      phy_data_req_o <= '0';
      bup_txdata     <= (others => '0');

    elsif (hclk'event and hclk = '1') then

      case next_byte_tx_state is
        
        when idle_state =>
          if (tx_state = idle_state) then
            phy_data_req_o <= '0';
          end if;
                    
        when tx_req_state =>
          if byte_tx_state = idle_state then
            phy_data_req_o <= not phy_data_req_o;
            bup_txdata     <= byte_to_transmit;
          end if;  
            
        when others => 

      end case;
    end if;
  end process tx_modem_p;


  ------------------------------------------------------------------------------
  -- General transmission state machine
  ------------------------------------------------------------------------------
  -- Signal to start TX, used in several state machines
  start_tx <= '1' when (tximmstop = '0') and (tx_mode = '1') and (tx_end_o = '0')
    else '0';
  
  invalid_length <= '1' when ((txlen <= 4) and (fcsdisb = '0'))
                           or ((txlen = 0) and (fcsdisb = '1'))
    else '0';
  
  tx_sm_comb_p: process(bup_testmode, enter_psdu_state, fcsdisb,
                        guar_time_expired, invalid_length, mem_seq_ready,
                        phy_data_conf_pulse, phy_txstartend_conf,
                        phy_txstartend_req_o, read_state, start_tx, testenable,
                        tx_count, tx_state, tximmstop, txlen)
  begin
    
    case tx_state is
      
      -- TX abort
      -- wait for conf from modem in TX abort state, and then go to tx_end
      when tx_abort_state =>
        if phy_txstartend_req_o = phy_txstartend_conf then
          next_tx_state <= tx_end_state;
        else
          next_tx_state <= tx_abort_state;
        end if;
                
      -- idle state
      -- if a tx mode request is sent and immediate stop is not set, start transmission
      when idle_state =>
        if (start_tx = '1') then             
          next_tx_state <= tx_start_state;
        else
          next_tx_state <= idle_state;
        end if;
        
      -- Request sent to modem to start a packet transmission.
      -- The modem will start to send the preamble.
      -- Waiting for a tx start confirmation and a mem seq ready
      -- to start PSDU transmission. 
      when tx_start_state =>
        if tximmstop = '1' then
          next_tx_state <= tx_abort_state;
        else
          next_tx_state <= tx_start_state;
          if (phy_txstartend_conf = '1') then
            -- if the length is null, abort the transmission.
            if (invalid_length = '1') then
              next_tx_state <= tx_end_state;
            -- when the control structure is read :
            elsif (enter_psdu_state = '1') and (mem_seq_ready = '1') then
              -- if testmode, go to FCS
              if (testenable = '1') and (bup_testmode = "10") then
                next_tx_state <= transmit_fcs_state;
              -- if guarantied time expired, go to transmit.
              elsif (guar_time_expired = '1') then
                next_tx_state <= transmit_state;
              end if;
            end if;
          end if;
        end if;
          
      -- PSDU transmission state
      -- this state is used to launch the transmission of one byte
      when transmit_state =>
        if tximmstop = '1' then
          next_tx_state <= tx_abort_state;
        -- Transmit data up to txlen.
        elsif ((mem_seq_ready = '1') and (read_state = read_psdu_state)) or (read_state = wait_end_state) then
          next_tx_state <= tx_conf_state;
        else
          next_tx_state <= transmit_state;
        end if;    

      -- PSDU transmission 
      -- waiting a confirm from Modem and a mem seq ready
      -- if there are still bytes to send, send next byte
      -- otherway end transmission
      when tx_conf_state =>
        if tximmstop = '1' then
          next_tx_state <= tx_abort_state;
        elsif (phy_data_conf_pulse = '1') then
          if (tx_count = txlen) and (fcsdisb = '1') then
            next_tx_state <= tx_end_state;
          elsif (tx_count = txlen - "100") and (fcsdisb = '0') then
            next_tx_state <= transmit_fcs_state;
          else
            next_tx_state <= transmit_state;
          end if;
        else
          next_tx_state <= tx_conf_state;
        end if;      

      -- FCS transmission state
      when transmit_fcs_state =>
        if tximmstop = '1' then
          next_tx_state <= tx_abort_state;
        else
          next_tx_state <= tx_fcs_conf_state;
        end if;

      -- send FCS data
      when tx_fcs_conf_state =>
        if tximmstop = '1' then
          next_tx_state <= tx_abort_state;
        else
          if phy_data_conf_pulse = '1'then 
            if tx_count = 4 and 
             (testenable = '0' or 
             (testenable = '1' and bup_testmode /= "10")) then
              next_tx_state <= tx_end_state;
            else
              next_tx_state <= transmit_fcs_state;
            end if;
          else
            next_tx_state <= tx_fcs_conf_state;
          end if;      
        end if;      

      -- end of transmission
      when tx_end_state =>
        if phy_txstartend_conf = '0' then
          next_tx_state <= idle_state;
        else
          next_tx_state <= tx_end_state;
        end if;
      
      when others => 
        next_tx_state <= idle_state;

    end case;
  end process tx_sm_comb_p;

 
  -- Byte transmission state machine sequencial process
  -- the state machine is also reset to idle_state
  -- when the BuP is disabled or when the state machines are reseted 
  tx_sm_seq_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      tx_state <= idle_state;
    elsif (hclk'event and hclk = '1') then
      tx_state <= next_tx_state;
    end if;
  end process tx_sm_seq_p;
 

  -- Byte transmission control signals management. 
  -- This controls the byte transmission state machine,
  -- the memory sequencer, the FCS generation and the general sm.
  tx_control_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      transmit_byte        <= '0';
      tx_count             <= (others => '0');
      tx_psdu_count        <= (others => '0');
      fcs_data_valid       <= '0';
      fcs_init             <= '0';
      tx_end_o             <= '0';
      select_data          <= "000";
      phy_txstartend_req_o <= '0';
      tximmstop_stat       <= '0';
      tximmstop_latch      <= '0';
      
    elsif (hclk'event and hclk = '1') then

      case tx_state is
        
        --------------------------------------------
        -- Wait for start of TX packet
        --------------------------------------------
        when idle_state =>
          transmit_byte       <= '0';
          tx_count            <= (others => '0');
          tx_psdu_count       <= (others => '0');
          fcs_data_valid      <= '0';
          fcs_init            <= '0';
          tx_end_o            <= '0';
          select_data         <= "000";
          phy_txstartend_req_o  <= '0';
          tximmstop_latch     <= tximmstop;
          
        --------------------------------------------
        -- Wait for confirmation from the modem and
        -- read the control structure
        --------------------------------------------
        when tx_start_state =>
          -- Reset flags from last tx.
          tximmstop_stat    <= '0';
          tximmstop_latch   <= tximmstop;
          
          transmit_byte     <= '0';
          tx_count          <= (others => '0');
          fcs_data_valid    <= '0';
          fcs_init          <= '1';
          select_data       <= "000";
          tx_end_o          <= '0';
          if (txrate_read_done = '1') then
            phy_txstartend_req_o <= '1';
          end if;
          if (phy_txstartend_conf = '1') and (invalid_length = '1') then
            phy_txstartend_req_o <= '0';
          end if;  
          
        -- launch byte transmission, FCS valid
        when transmit_state =>
          tximmstop_latch  <= tximmstop;
          -- Transmit bytes up to PSDU length, when memory sequencer is ready.
          if (mem_seq_ready = '1') and (read_state = read_psdu_state) and
             (tx_psdu_count < psdu0_len) then
            transmit_byte  <= '1';
            fcs_data_valid <= '1';
            tx_count       <= tx_count + 1;
            tx_psdu_count  <= tx_psdu_count + 1;
          elsif (read_state = wait_end_state) then
            transmit_byte  <= '1';
            tx_count       <= tx_count + 1;
            fcs_data_valid <= '1';
          end if;
          tx_end_o       <= '0';
          select_data    <= "000";
          fcs_init       <= '0';

        -- increment byte counter if not end of packet
        -- request data to memory sequencer
        when tx_conf_state =>
          -- Reset PSDU count when changing PSDU pointer.
          if (read_state = change_psdu_state) then
            tx_psdu_count <= (others => '0');
          end if;
          tximmstop_latch <= tximmstop;
          transmit_byte  <= '0';
          fcs_data_valid <= '0';
          fcs_init       <= '0';
          tx_end_o       <= '0';
          if (phy_data_conf_pulse = '1') then
            if (tx_count = txlen) and (fcsdisb = '1') then
              tx_count            <= (others => '0');
              select_data         <= "000";
              phy_txstartend_req_o  <= '0';
            elsif (tx_count = txlen - "100") and (fcsdisb = '0') then
              tx_count     <= (others => '0');
              select_data  <= "000";
            end if;      
          end if;      
        
        -- transmit FCS byte data
        when transmit_fcs_state =>
          tximmstop_latch <= tximmstop;
          transmit_byte   <= '1';
          if testenable = '1' then
            fcs_data_valid <= '1';
            tx_count       <= "000000000100";
            if select_data = 4 then
              select_data  <= "001";
            else
              select_data  <= select_data + 1;
            end if;    
          else
            fcs_data_valid <= '0';
            tx_count       <= tx_count + 1;
            select_data    <= select_data + 1;
          end if;    
          fcs_init       <= '0';
          tx_end_o       <= '0';
          
        -- increment byte counter and select_data
        when tx_fcs_conf_state =>
          tximmstop_latch  <= tximmstop;
          transmit_byte  <= '0';
          fcs_data_valid <= '0';
          fcs_init       <= '0';
          tx_end_o       <= '0';
          if (phy_data_conf_pulse = '1' and tx_count = 4 and 
             (testenable = '0' or bup_testmode /= "10")) then
            tx_count     <= (others => '0');
            select_data  <= "000";
            phy_txstartend_req_o  <= '0';
          end if;      

        -- end of transmission
        when tx_end_state =>
          -- If end of aborted TX, tximmstop status is preserved till next transmission.
          -- Else scan tximmstop.
          if (tximmstop_latch = '0') then
            tximmstop_latch  <= tximmstop;
          end if;
          phy_txstartend_req_o  <= '0';
          transmit_byte       <= '0';
          tx_count            <= (others => '0');
          fcs_data_valid      <= '0';
          fcs_init            <= '0';
          select_data         <= "000";
          -- TX end status: abort or not
          tximmstop_stat      <= tximmstop_latch;
          if next_tx_state = idle_state then
            tx_end_o <= '1';
          end if;

        -- Transmission abort
        when tx_abort_state =>
          -- reset all controls, except phy_txstartend_req
          transmit_byte       <= '0';
          tx_count            <= (others => '0');
          tx_psdu_count       <= (others => '0');
          fcs_data_valid      <= '0';
          fcs_init            <= '0';
          tx_end_o            <= '0';
          select_data         <= "000";
          -- Flag indicating TX is aborting. This flag will be used instead of
          -- tximmstop register bit, in case SW reset tximmstop during abort.
          tximmstop_latch     <= '1';

        when others => 

      end case;
    end if;
  end process tx_control_p;


  --------------------------------------------
  -- Read memory accesses state machine.
  --------------------------------------------
  -- comb part
  read_mem_sm_comb_p: process (access_cnt, guar_time_expired, psdu0_len,
                               psdu_changed, psdu_num, read_state, start_tx,
                               tx_end_o, tx_psdu_count, tximmstop)
  begin
    case read_state is
      --------------------------------------------             
      -- Wait for start of TX packet                           
      --------------------------------------------             
      when idle_state =>
        -- Read control structure at TX start.
        if (start_tx = '1') then
          next_read_state <= read_ctrlstr_state;
        else
          next_read_state <= idle_state;
        end if;
                                                               
      --------------------------------------------              
      -- Read the control structure                             
      --------------------------------------------              
      when read_ctrlstr_state =>
        -- If TX is aborted, wait for main state machine
        if (tximmstop = '1') then
          next_read_state <= wait_abort_state;
        else
          if (tx_end_o = '1') then
            next_read_state <= idle_state;
          elsif (access_cnt = 46) and
             (guar_time_expired = '1') then
            next_read_state <= change_psdu_state;
          else
            next_read_state <= read_ctrlstr_state;
          end if;
        end if;

      --------------------------------------------                      
      -- Read the PSDU                                                  
      --------------------------------------------                      
      when read_psdu_state =>
        -- If TX is aborted, wait for main state machine
        if (tximmstop = '1') then
          next_read_state <= wait_abort_state;
        else
          if (tx_end_o = '1') then
            next_read_state <= idle_state;
          elsif (tx_psdu_count = psdu0_len) then
            -- Change pointer to next PSDU buffer
            next_read_state <= change_psdu_state;
          else
            next_read_state <= read_psdu_state;
          end if;
        end if;
        
      --------------------------------------------                      
      -- Change pointer to next PSDU buffer
      --------------------------------------------                      
      when change_psdu_state =>
        -- If TX is aborted, wait for main state machine
        if (tximmstop = '1') then
          next_read_state <= wait_abort_state;
        else
          if (tx_end_o = '1') then
            next_read_state <= idle_state;
          else
            if (psdu_changed = '1') then
              if (psdu_num < 4) then -- Go to next PSDU
                next_read_state <= read_psdu_state;
              else -- All PSDU read or null, wait for up to txlen bytes sent.
                next_read_state <= wait_end_state;
              end if;  
            else
              next_read_state <= change_psdu_state;
            end if;
          end if;
        end if;
        
      --------------------------------------------                      
      -- Wait for end of transmission: FCS or additional bytes in case of length error.
      --------------------------------------------                      
      when wait_end_state =>
        -- If TX is aborted, wait for main state machine
        if (tximmstop = '1') then
          next_read_state <= wait_abort_state;
        else -- Wait for all bytes sent
          if (tx_end_o = '1') then
            next_read_state <= idle_state;
          else
            next_read_state <= wait_end_state;
          end if;
        end if;
              
      --------------------------------------------                      
      -- TX aborted: wait for end of abort in main state machine                                                  
      --------------------------------------------                      
      when wait_abort_state =>
        if (tx_end_o = '1') then
          next_read_state <= idle_state;
        else
          next_read_state <= wait_abort_state;
        end if;
          
      when others =>
        next_read_state <= idle_state;

    end case;
  end process read_mem_sm_comb_p;
  
  -- seq part
  read_mem_sm_seq_p: process (hclk, hresetn)
  begin
    if (hresetn = '0') then
      read_state <= idle_state;
    elsif (hclk'event and hclk = '1') then
      read_state <= next_read_state;
    end if;
  end process read_mem_sm_seq_p;
  
  
  --------------------------------------------
  -- Read memory accesses. This process performs
  -- the memory access for the control structure
  -- and the PSDU.
  --------------------------------------------
  read_mem_p: process (hclk, hresetn)
  begin
    if (hresetn = '0') then
      mem_seq_req       <= '0';
      load_txptr        <= '0';
      mem_seq_txptr     <= (others => '0');
      txlen             <= (others => '0');
      txv_service       <= (others => '0');
      txrate            <= (others => '0');
      tx_packet_type    <= '0';
      txpwr_level       <= (others => '0');
      txv_txaddcntl     <= (others => '0');
      txv_paindex       <= (others => '0');
      txv_txant         <= '0';
      ackto             <= (others => '0');
      ackto_en          <= '0';
      ctrl_struc_ptr    <= (others => '0');
      psdu_num          <= (others => '0');
      psdu0_len         <= (others => '0');
      psdu0_ptr         <= (others => '0');
      psdu1_len         <= (others => '0');
      psdu1_ptr         <= (others => '0');
      psdu2_len         <= (others => '0');
      psdu2_ptr         <= (others => '0');
      access_cnt        <= (others => '0');
      txrate_read_done  <= '0';
      last_word         <= '0';
      sampled_queue_it_num <= (others => '0');
      tx_acc_type       <= WORD_CT;
      enter_psdu_state  <= '0';
      enter_psdu_state_ff  <= '0';
      psdu_changed      <= '0';

    elsif (hclk'event and hclk = '1') then

      enter_psdu_state_ff <= enter_psdu_state;

      case read_state is
        
        --------------------------------------------
        -- Wait for start of TX packet
        --------------------------------------------
        when idle_state =>
          psdu_changed      <= '0';
          access_cnt        <= (others => '0');
          load_txptr        <= '0';
          txrate_read_done  <= '0';
          mem_seq_req       <= '0';
          last_word         <= '0';
          psdu_num          <= (others => '0');
          -- control structure pointer is a word
          tx_acc_type       <= WORD_CT;
          enter_psdu_state  <= '0';
          
          if (start_tx = '1') then
            sampled_queue_it_num <= queue_it_num;
            if (queue_it_num = "1000") then
              -- if IAC, read the control structure pointer from register
              ctrl_struc_ptr <= iacptr;
              access_cnt <= conv_std_logic_vector(5, access_cnt'length);
            else
              -- launch the read of the control structure pointer
              mem_seq_txptr   <= buptxptr + (queue_it_num & "00");
              load_txptr      <= '1';
              last_word       <= '1';
            end if;
          end if;
                  
        --------------------------------------------
        -- Read the control structure
        --------------------------------------------
        when read_ctrlstr_state =>
          psdu_changed      <= '0';
          load_txptr        <= '0';
          last_word         <= '0';

          case conv_integer(access_cnt) is
            
            -- Read the control structure pointer
            --------------------------------------------
            when 0 =>
              mem_seq_req  <= '1'; -- Req for byte 1
              access_cnt   <= access_cnt + 1;
            when 1 =>
              if (mem_seq_ready = '1') then                   -- Byte 0 ready
                mem_seq_req                <= '1';            -- Req for byte 2
                ctrl_struc_ptr(7 downto 0) <= mem_seq_data;   -- Read byte 0
                access_cnt                 <= access_cnt + 1;
              end if;
            when 2 =>
              if (mem_seq_ready = '1') then                   -- Byte 1 ready
                mem_seq_req                  <= '1';          -- Req for byte 3
                ctrl_struc_ptr(15 downto 8)  <= mem_seq_data; -- Read byte 1
                access_cnt                   <= access_cnt + 1;
              end if;
            when 3 =>
              mem_seq_req  <= '0';  -- No more data to request.
              if (mem_seq_ready = '1') then                   -- Byte 2 ready
                ctrl_struc_ptr(23 downto 16) <= mem_seq_data; -- Read byte 2
                access_cnt                   <= access_cnt + 1;
              end if;
            when 4 =>
              if (mem_seq_ready = '1') then                   -- Byte 3 ready
                ctrl_struc_ptr(31 downto 24) <= mem_seq_data; -- Read byte 3
                access_cnt                   <= access_cnt + 1; 
              end if;
              
            -- Read txlen
            --------------------------------------------
            when 5 =>
              mem_seq_txptr       <= ctrl_struc_ptr;
              load_txptr          <= '1';  -- Req for byte 0
              -- the following control structure fields are half words
              tx_acc_type         <= HWORD_CT;
              access_cnt          <= access_cnt + 1;
            when 6 => -- Wait for mem_seq_ready low
              mem_seq_req         <= '1'; -- Req for byte 1
              access_cnt          <= access_cnt + 1;
            when 7 =>
              if (mem_seq_ready = '1') then                      -- Byte 0 ready
                mem_seq_req       <= '1';                        -- Req for byte 2
                txlen(7 downto 0) <= mem_seq_data;               -- Read byte 0
                access_cnt        <= access_cnt + 1;
              end if;
            when 8 =>
              if (mem_seq_ready = '1') then                      -- Byte 1 ready
                mem_seq_req         <= '1';                      -- Req for byte 3
                txlen(11 downto 8)  <= mem_seq_data(3 downto 0); -- Read byte 1
                access_cnt          <= access_cnt + 1;
              end if;
              
            -- Read txv_service
            --------------------------------------------
            when 9 =>
              if (mem_seq_ready = '1') then                      -- Byte 2 ready
                mem_seq_req               <= '1';                -- Req for byte 0
                txv_service(7 downto 0) <= mem_seq_data;         -- Read byte 2
                access_cnt              <= access_cnt + 1;
              end if;
            when 10 =>
              mem_seq_req                <= '0';
              if (mem_seq_ready = '1') then                      -- Byte 3 ready
                txv_service(15 downto 8) <= mem_seq_data;        -- Read byte 3
                access_cnt               <= access_cnt + 1;
              end if;
 
            -- Read txpwr_level
            --------------------------------------------
            when 11 =>
              if (mem_seq_ready = '1') then                      -- Byte 0 ready
                mem_seq_req    <= '1';                           -- Req for byte 1
                txpwr_level    <= mem_seq_data(3 downto 0);      -- Read byte 0
                txv_txant      <= mem_seq_data(4);
                access_cnt     <= access_cnt + 1;
                -- the following control structure fields that will be
                -- read from memory are words
                tx_acc_type    <= WORD_CT;
              end if;
            when 12 =>
              mem_seq_req      <= '1';                           -- Req for byte 2
              access_cnt       <= access_cnt + 1;
            when 13 =>
              if (mem_seq_ready = '1') then                      -- Byte 1 ready
                mem_seq_req    <= '1';                           -- Req for byte 3
                txv_txaddcntl  <= mem_seq_data(7 downto 6);      -- Read byte 1
                txv_paindex    <= mem_seq_data(4 downto 0);
                access_cnt     <= access_cnt + 1;
              end if;
              
            -- Read txrate
            --------------------------------------------
            when 14 =>
              if (mem_seq_ready = '1') then                     -- Byte 2 ready
                mem_seq_req       <= '1';                       -- Req for byte 0
                ackto(0)          <= mem_seq_data(7);           -- Read byte 2
                ackto_en          <= mem_seq_data(6);
                txrate            <= mem_seq_data(3 downto 0);
                access_cnt        <= access_cnt + 1;
                txrate_read_done  <= '1';    
              end if;
            when 15 =>
              mem_seq_req         <= '0';
              tx_packet_type      <= txrate(3);
              if (mem_seq_ready = '1') then                     -- Byte 3 ready
                ackto(8 downto 1) <= mem_seq_data;              -- Read byte 3
                access_cnt        <= access_cnt + 1;
              end if;

            -- Read PSDU0 length
            --------------------------------------------
            when 16 =>
              if (mem_seq_ready = '1') then                          -- Byte 0 ready   
                mem_seq_req             <= '1';                      -- Req for byte 1
                psdu0_len(7 downto 0)   <= mem_seq_data;             -- Read byte 0
                access_cnt              <= access_cnt + 1;
              end if;
            when 17 =>
              mem_seq_req               <= '1';                      -- Req for byte 2
              access_cnt                <= access_cnt + 1;
            when 18 =>
              if (mem_seq_ready = '1') then                          -- Byte 1 ready   
                mem_seq_req             <= '1';                      -- Req for byte 3
                psdu0_len(11 downto 8)  <= mem_seq_data(3 downto 0); -- Read byte 1
                access_cnt              <= access_cnt + 1;
              end if;
            when 19 => -- Skip byte 2
              if (mem_seq_ready = '1') then
                mem_seq_req             <= '1';                      -- Req for byte 0
                access_cnt              <= access_cnt + 1;
              end if;
            when 20 => -- Skip byte 3
              mem_seq_req  <= '0';
              if (mem_seq_ready = '1') then
                access_cnt              <= access_cnt + 1;
              end if;

            -- Read PSDU0 pointer
            --------------------------------------------
            when 21 =>
              if (mem_seq_ready = '1') then                          -- Byte 0 ready
                mem_seq_req             <= '1';                      -- Req for bytes 1
                psdu0_ptr(7 downto 0)   <= mem_seq_data;             -- Read byte 0
                access_cnt              <= access_cnt + 1;
              end if;
            when 22 =>
              mem_seq_req               <= '1';                      -- Req for byte 2
              access_cnt                <= access_cnt + 1;
            when 23 =>
              if (mem_seq_ready = '1') then                          -- Byte 1 ready
                mem_seq_req             <= '1';                      -- Req for byte 3
                psdu0_ptr(15 downto 8)  <= mem_seq_data;             -- Read byte 1
                access_cnt              <= access_cnt + 1;
              end if;
            when 24 =>
              if (mem_seq_ready = '1') then                          -- Byte 2 ready
                mem_seq_req             <= '1';                      -- Req for byte 0
                psdu0_ptr(23 downto 16) <= mem_seq_data;             -- Read byte 2
                access_cnt              <= access_cnt + 1;
              end if;
            when 25 =>
              mem_seq_req               <= '0';
              if (mem_seq_ready = '1') then                          -- Byte 3 ready
                psdu0_ptr(31 downto 24) <= mem_seq_data;             -- Read byte 3
                access_cnt              <= access_cnt + 1;
              end if;
              
            -- Read PSDU1 length
            --------------------------------------------
            when 26 =>
              if (mem_seq_ready = '1') then                          -- Byte 0 ready
                mem_seq_req             <= '1';                      -- Req for byte 1
                psdu1_len(7 downto 0)   <= mem_seq_data;             -- Read byte 0
                access_cnt              <= access_cnt + 1;
              end if;
            when 27 =>
              mem_seq_req               <= '1';                      -- Req for byte 2
              access_cnt                <= access_cnt + 1;
            when 28 =>
              if (mem_seq_ready = '1') then                          -- Byte 1 ready
                mem_seq_req             <= '1';                      -- Req for byte 3
                psdu1_len(11 downto 8)  <= mem_seq_data(3 downto 0); -- Read byte 1
                access_cnt              <= access_cnt + 1;
              end if;
            when 29 => -- Skip byte 2
              if (mem_seq_ready = '1') then
                mem_seq_req             <= '1';                      -- Req for byte 0
                access_cnt              <= access_cnt + 1;
              end if;
            when 30 => -- Skip byte 3
              mem_seq_req               <= '0';
              if (mem_seq_ready = '1') then
                access_cnt              <= access_cnt + 1;
              end if;

            -- Read PSDU1 pointer
            --------------------------------------------
            when 31 =>
              if (mem_seq_ready = '1') then                          -- Byte 0 ready
                mem_seq_req             <= '1';                      -- Req for byte 1
                psdu1_ptr(7 downto 0)   <= mem_seq_data;             -- Read byte 0
                access_cnt              <= access_cnt + 1;
              end if;
            when 32 =>
              mem_seq_req               <= '1';                      -- Req for byte 2
              access_cnt                <= access_cnt + 1;
            when 33 =>
              if (mem_seq_ready = '1') then                          -- Byte 1 ready
                mem_seq_req             <= '1';                      -- Req for byte 3
                psdu1_ptr(15 downto 8)  <= mem_seq_data;             -- Read byte 1
                access_cnt              <= access_cnt + 1;
              end if;
            when 34 =>
              if (mem_seq_ready = '1') then                          -- Byte 2 ready
                mem_seq_req             <= '1';                      -- Req for byte 0
                psdu1_ptr(23 downto 16) <= mem_seq_data;             -- Read byte 2
                access_cnt              <= access_cnt + 1;
              end if;
            when 35 =>
              mem_seq_req               <= '0';
              if (mem_seq_ready = '1') then                          -- Byte 3 ready
                psdu1_ptr(31 downto 24) <= mem_seq_data;             -- Read byte 3
                access_cnt              <= access_cnt + 1;
              end if;
              
            -- Read PSDU2 length
            --------------------------------------------
            when 36 =>
              if (mem_seq_ready = '1') then                          -- Byte 0 ready
                mem_seq_req             <= '1';                      -- Req for byte 1
                psdu2_len(7 downto 0) <= mem_seq_data;               -- Read byte 0
                access_cnt            <= access_cnt + 1;
              end if;
            when 37 =>
              mem_seq_req             <= '1';                        -- Req for byte 2
              access_cnt              <= access_cnt + 1;
            when 38 =>
              if (mem_seq_ready = '1') then                          -- Byte 3 ready
                mem_seq_req             <= '1';                      -- Req for byte 3
                psdu2_len(11 downto 8)  <= mem_seq_data(3 downto 0); -- Read byte 1
                access_cnt              <= access_cnt + 1;
              end if;
            when 39 => -- Skip byte 2
              if (mem_seq_ready = '1') then
                mem_seq_req             <= '1';                      -- Req for byte 0
                access_cnt              <= access_cnt + 1;
                last_word               <= '1';
              end if;
            when 40 => -- Skip byte 3
              mem_seq_req               <= '0';
              if (mem_seq_ready = '1') then
                access_cnt              <= access_cnt + 1;
              end if;

            -- Read PSDU2 pointer
            --------------------------------------------
            when 41 =>
              if (mem_seq_ready = '1') then                          -- Byte 0 ready
                mem_seq_req             <= '1';                      -- Req for byte 1
                psdu2_ptr(7 downto 0)   <= mem_seq_data;             -- read byte 0
                access_cnt              <= access_cnt + 1;
              end if;
            when 42 =>
              mem_seq_req               <= '1';                      -- Req for byte 2
              access_cnt                <= access_cnt + 1;
            when 43 =>
              if (mem_seq_ready = '1') then                          -- Byte 1 ready
                mem_seq_req             <= '1';                      -- Req for byte 3
                psdu2_ptr(15 downto 8)  <= mem_seq_data;             -- Read byte 1
                access_cnt              <= access_cnt + 1;
              end if;
            when 44 =>
              if (mem_seq_ready = '1') then                          -- Byte 2 ready
                mem_seq_req             <= '1';                      -- Req for byte 0
                psdu2_ptr(23 downto 16) <= mem_seq_data;             -- Read byte 2
                access_cnt              <= access_cnt + 1;
              end if;
            when 45 =>
              mem_seq_req               <= '0';
              if (mem_seq_ready = '1') then                          -- Byte 3 ready
                psdu2_ptr(31 downto 24) <= mem_seq_data;             -- Read byte 3
                access_cnt              <= access_cnt + 1;
              end if;
              
            when 46 =>
              if (guar_time_expired = '1') then
                access_cnt     <= (others => '0');
                mem_seq_txptr  <= psdu0_ptr;
                -- tx data are byte considered
                tx_acc_type    <= BYTE_CT;
              end if;
            
            when others =>
          end case;
        
        --------------------------------------------
        -- Read the PSDU
        --------------------------------------------
        when read_psdu_state =>
          psdu_changed      <= '0';
          enter_psdu_state  <= '1';
          if last_now = '0' then
            last_word       <= '0';
          end if;
            
          -- Load pointer when entering read_psdu_state, so that last_word can
          -- be set at the same time if needed.
          if (enter_psdu_state = '0') then
            load_txptr <= '1';
            if last_now = '1' then
              last_word <= '1';
            end if;  
          else
            load_txptr <= '0';
          end if;
          
          -- Wait for 2 clock cycles in 'read_psdu_state', to let time to mem_seq_ready
          -- to go down if necessary.
          if (enter_psdu_state_ff = '1') and (enter_psdu_state = '1') then
            if (tx_psdu_count = last_word_tx_count) and (mem_seq_ready = '1') then
              last_word <= '1';
            end if;
          end if;

          -- Request for new byte to send on bup_txdata.
          if (mem_seq_ready = '1') and (tx_state = transmit_state) then
            mem_seq_req    <= '1';
          else
            mem_seq_req    <= '0';
          end if;  
          
        --------------------------------------------
        -- Switch to next PSDU pointer
        --------------------------------------------
        when change_psdu_state =>
          psdu_changed      <= '0';
          enter_psdu_state  <= '0';
          last_word         <= '0';
          mem_seq_req       <= '0';
          -- Test next pointer till a non-null pointer is found.
          if (psdu_changed = '0') then
            case psdu_num is
              when "000" =>
                psdu_num         <= "001";
                if (psdu0_len /= 0) then -- Change to PSDU1
                  mem_seq_txptr    <= psdu0_ptr;
                  psdu_changed     <= '1';
                end if;
              when "001" =>
                psdu_num         <= "010";
                if (psdu1_len /= 0) then -- Change to PSDU1
                  psdu0_len        <= psdu1_len;
                  psdu0_ptr        <= psdu1_ptr;
                  mem_seq_txptr    <= psdu1_ptr;
                  psdu_changed     <= '1';
                end if;
              when "010" => 
                psdu_num         <= "011";
                if (psdu2_len /= 0) then -- Change to PSDU2
                  psdu0_len        <= psdu2_len;
                  psdu0_ptr        <= psdu2_ptr;
                  mem_seq_txptr    <= psdu2_ptr;
                  psdu_changed     <= '1';
                end if;
              when others => -- Last PSDU tested
                psdu_num         <= "100";
                psdu_changed     <= '1';
            end case;
          end if;
        
        --------------------------------------------
        -- Wait for end of transmission: FCS data sent or bytes up to txlen in case
        -- of length mismatch.
        --------------------------------------------
        when wait_end_state =>
          psdu_changed  <= '0';
          mem_seq_req   <= '0'; -- No memory requests.
        
        --------------------------------------------
        -- Abort: stop all memory accesses
        --------------------------------------------
        when wait_abort_state =>
          -- Reset control signals.
          psdu_changed      <= '0';
          access_cnt        <= (others => '0');
          load_txptr        <= '0';
          txrate_read_done  <= '0';
          mem_seq_req       <= '0';
          last_word         <= '0';
          enter_psdu_state  <= '0';
          psdu_num          <= (others => '0');
          
                            
        when others => 

      end case;
      
    end if;
  end process read_mem_p;


  --------------------------------------------
  -- tx_start_it generation
  -- pulse on start of packet transmition
  -- used by the interrupt generator
  --------------------------------------------
  tx_start_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      tx_start_it <= '0';
      txrate_read_done_ff1 <= '0';
    elsif (hclk'event and hclk = '1') then
      txrate_read_done_ff1 <= txrate_read_done;
      if (txrate_read_done = '1') and (txrate_read_done_ff1 = '0') then
        tx_start_it <= '1';
      else  
        tx_start_it <= '0';
      end if;  
    end if;
  end process tx_start_p;

  tx_end_it        <= tx_end_o;

  -- select the data that will be sent to Modem
  byte_to_transmit <= 
           fcs_data_1st  when select_data = "001" and testenable = '0' else           
           test_data_1st when select_data = "001" and testenable = '1' else           
           fcs_data_2nd  when select_data = "010" and testenable = '0' else                                
           test_data_2nd when select_data = "010" and testenable = '1' else                                
           fcs_data_3rd  when select_data = "011" and testenable = '0' else                                
           test_data_3rd when select_data = "011" and testenable = '1' else                                
           fcs_data_4th  when select_data = "100" and testenable = '0' else                                
           test_data_4th when select_data = "100" and testenable = '1' else                                
           mem_seq_data;                                                             
     
  -- test data
  test_data_1st <= fcs_data_1st when datatype = "10" else
                   testdata(7 downto 0);
  test_data_2nd <= fcs_data_2nd when datatype = "10" else
                   testdata(15 downto 8);
  test_data_3rd <= fcs_data_3rd when datatype = "10" else
                   testdata(23 downto 16);
  test_data_4th <= fcs_data_4th when datatype = "10" else
                   testdata(31 downto 24);


  -- Detect when to indicates to the memory sequencer that the next access is the last one.
  last_word_count_p: process(psdu0_len, psdu0_ptr)
  begin
    -- Additional flag, set when 'last_word' must be set at the same time as 'load_txptr'
    last_now <= '0';
    case psdu0_ptr(1 downto 0) is
      when "00" =>
        if psdu0_len <= 4 then
          last_now <= '1';
          last_word_tx_count <= (others => '0');
        elsif psdu0_len <= 8 then
          last_word_tx_count <= (others => '0');          
        elsif psdu0_len(1 downto 0) = "00" then
          last_word_tx_count <= (psdu0_len(11 downto 2) & "00") - 7;
        else
          last_word_tx_count <= (psdu0_len(11 downto 2) & "00") - 3;
        end if;
      when "01" =>
        if psdu0_len <= 3 then
          last_now <= '1';
          last_word_tx_count <= (others => '0');          
        else
          last_word_tx_count <= (psdu0_len(11 downto 2) & "00") - 4;
        end if;
      when "10" =>
        if psdu0_len <= 2 then
          last_now <= '1';
          last_word_tx_count <= (others => '0');          
        elsif psdu0_len <= 6 then
          last_word_tx_count <= (others => '0');          
        elsif psdu0_len(1 downto 0) = "11" then
          last_word_tx_count <= (psdu0_len(11 downto 2) & "00") - 1;
        else
          last_word_tx_count <= (psdu0_len(11 downto 2) & "00") - 5;
        end if;
      when others => -- "11"
        if psdu0_len <= 1 then
          last_now <= '1';
          last_word_tx_count <= (others => '0');          
        elsif psdu0_len <= 5 then
          last_word_tx_count <= (others => '0');          
        elsif psdu0_len(1 downto 0) >= "01" then
          last_word_tx_count <= (psdu0_len(11 downto 2) & "00") - 2;
        else
          last_word_tx_count <= (psdu0_len(11 downto 2) & "00") - 6;
        end if;
    end case;
    
  end process last_word_count_p;
 
   -- diag
   
  tx_sm_diag_p : process(tx_state)
  begin
    case tx_state is
      when idle_state =>
        tx_sm_diag <= "000";
      when tx_start_state =>
        tx_sm_diag <= "001";
      when transmit_state =>
        tx_sm_diag <= "010";
      when tx_conf_state =>
        tx_sm_diag <= "011";
      when transmit_fcs_state =>
        tx_sm_diag <= "100";
      when tx_fcs_conf_state =>
        tx_sm_diag <= "101";
      when tx_end_state =>
        tx_sm_diag <= "110";
        
      when others =>
        tx_sm_diag <= "111";
        
    end case;
  end process tx_sm_diag_p;
  
  tx_read_sm_diag_p : process(read_state)
  begin
    case read_state is
      when idle_state =>
        tx_read_sm_diag <= "00";
      when read_ctrlstr_state =>
        tx_read_sm_diag <= "01";
      when read_psdu_state =>
        tx_read_sm_diag <= "10";
      when others =>
        tx_read_sm_diag <= "11";
        
    end case;
  end process tx_read_sm_diag_p;
  
end RTL;
