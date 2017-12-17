
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processor
--    ,' GoodLuck ,'      RCSfile: sp_ahb_access.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.17   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Read/Write Access to AHB.
--
-- It manages the request of writing/reading of the different blocks on the ahb
-- bus. It is able to manage a read and write access at the same time, by
-- giving the priority to the read access.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/sp_ahb_access/vhdl/rtl/sp_ahb_access.vhd,v  
--  Log: sp_ahb_access.vhd,v  
-- Revision 1.17  2005/05/31 15:46:29  Dr.A
-- #BugId:938#
-- New diags
--
-- Revision 1.16  2005/04/27 14:12:45  Dr.A
-- #BugId:1231#
-- Assert write_done when AHB data phase is over (end of wr_last_state).
--
-- Revision 1.15  2005/04/27 12:02:50  Dr.A
-- #BugId:1184#
-- Break burst when crossing 1kB boundary.
-- Maintain htrans till next inc_addr is high
--
-- Revision 1.14  2005/04/26 07:57:48  Dr.A
-- #BugId:1184#
-- Burst broken when hsize changes by setting htrans to NON_SEQ
--
-- Revision 1.13  2003/12/04 09:36:36  Dr.A
-- Removed mux on read data. read_done delayed according to this change.
--
-- Revision 1.12  2003/11/12 15:23:20  Dr.A
-- Put back read_addr LSB registers (required for synthesis).
--
-- Revision 1.11  2003/10/09 16:39:03  Dr.A
-- Cleaned.
--
-- Revision 1.10  2003/10/02 12:54:29  Dr.A
-- FSM returns to idle on interrupt debugged.
-- write_done asserted too early in case of AHB wait states debugged.
-- start_mem signals are now used to memorize start during last write phase only.
-- Removed unused mux on read_data, and register on rd_addr LSB.
--
-- Revision 1.9  2003/08/28 15:21:18  Dr.A
-- Cleaned code. Changed state machine to accept write data two clock cycles after strt_write is set (time to request the bus).
--
-- Revision 1.8  2003/07/03 14:16:15  Dr.A
-- data_read words are now registered and padded with '0' following read_size inside the AHB block.
--
-- Revision 1.7  2003/03/17 09:12:11  Dr.B
-- bug on multimaster mode corrected (gen of busreq).
--
-- Revision 1.6  2002/11/27 17:34:21  Dr.B
-- busreq debugged.
--
-- Revision 1.5  2002/11/20 10:59:39  Dr.B
-- add addrmax_g generic.
--
-- Revision 1.4  2002/11/13 17:34:32  Dr.B
-- complete if/else and some simplifications.
--
-- Revision 1.3  2002/11/07 16:51:13  Dr.B
-- wr_access removed.
--
-- Revision 1.2  2002/10/31 16:07:51  Dr.B
-- redesign + debug.
--
-- Revision 1.1  2002/10/25 14:14:10  Dr.B
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

--library ahb_config_pkg;
library work;
--use ahb_config_pkg.ahb_config_pkg.all;
use work.ahb_config_pkg.all;

--library master_interface_rtl;
library work;

--library sp_ahb_access_rtl;
library work;
--use sp_ahb_access_rtl.sp_ahb_access_pkg.all;
use work.sp_ahb_access_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity sp_ahb_access is
  generic (
    addrmax_g  : integer := 32          -- AHB Address bus width. Minimum = 5.
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic;     
    reset_n      : in  std_logic;      

    --------------------------------------
    -- Interrupts
    --------------------------------------
    sp_init      : in  std_logic;       -- Interrupt occurs -> reinit
    --
    ahb_interrupt : out std_logic;      -- Interrupt line.    

    --------------------------------------
    -- Read Accesses
    --------------------------------------
    start_read   : in  std_logic;       -- Pulse to start read access.
    read_size    : in  std_logic_vector( 3 downto 0); -- Read size in bytes.
    read_addr    : in  std_logic_vector(addrmax_g-1 downto 0); -- Read address.
    --
    read_done    : out std_logic;       -- Flag indicating read done.
    -- Read data words.
    read_word0   : out std_logic_vector(31 downto 0);
    read_word1   : out std_logic_vector(31 downto 0);
    read_word2   : out std_logic_vector(31 downto 0);
    read_word3   : out std_logic_vector(31 downto 0);

    --------------------------------------
    -- Write Accesses
    --------------------------------------
    start_write  : in  std_logic;       -- Pulse to start write access.
    write_size   : in  std_logic_vector( 3 downto 0); -- Write size in bytes.
    write_addr   : in  std_logic_vector(addrmax_g-1 downto 0); -- Write address.
    -- Data to write.
    write_word0  : in  std_logic_vector(31 downto 0);
    write_word1  : in  std_logic_vector(31 downto 0);
    write_word2  : in  std_logic_vector(31 downto 0);
    write_word3  : in  std_logic_vector(31 downto 0);
    --
    write_done   : out std_logic;       -- Flag indicating data written.

    --------------------------------------
    -- AHB Master interface
    --------------------------------------
    hgrant        : in  std_logic;                      -- Bus grant.
    hready        : in  std_logic;                      -- AHB Slave ready.
    hresp         : in  std_logic_vector( 1 downto 0);  -- AHB Transfer response.
    hrdata        : in  std_logic_vector(31 downto 0);  -- AHB Read data bus.
    --
    hwdata        : out std_logic_vector(31 downto 0);  -- AHB Write data bus.
    hbusreq       : out std_logic;                      -- Bus request.
    htrans        : out std_logic_vector( 1 downto 0);  -- AHB Transfer type.
    hwrite        : out std_logic;                      -- Write request
    haddr         : out std_logic_vector(addrmax_g-1 downto 0); -- AHB Address.
    hburst        : out std_logic_vector( 2 downto 0);  -- Burst transfer.
    hsize         : out std_logic_vector( 2 downto 0);  -- Transfer size.

    --------------------------------------
    -- Diagnostic port
    --------------------------------------
    diag          : out std_logic_vector(7 downto 0)
  );

end sp_ahb_access;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of sp_ahb_access is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type STATE_TYPE_T is (idle_state, -- Idle phase.
                 wait_req_state,    -- Wait for master interface to set hbusreq.
                 wait_grant_state,  -- Wait for hbusreq to hgrant minimum delay.
                 wr_initbyte_state, -- Write initial bytes (bits 31:8).
                 wr_word_state,     -- Write 32bits words.
                 wr_endbyte_state,  -- Write end bytes (bits 23:0).
                 wr_last_state,     -- Put last write data on the bus.
                 rd_access_state,   -- Read access.
                 rd_last_state      -- Wait for last read data.
                 );    

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant BOUNDARY32_CT : std_logic_vector(9 downto 0) 
                         := "1111111100"; -- 1 kB - 4
  constant BOUNDARY8_CT  : std_logic_vector(9 downto 0) 
                         := "1111111111"; -- 1 kB - 1

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- *** STATES MACHINES ***
  signal acc_cur_state    : STATE_TYPE_T;-- Current state in the state machine.
  signal acc_next_state   : STATE_TYPE_T;-- Next state in the state machine.
  -- Signals to memorize 'start_read' or 'start_write' during wr_last_state.
  signal start_write_mem  : std_logic;   -- Memorize start_write.
  signal start_read_mem   : std_logic;   -- Memorize start_read.
  -- Signal asserted when read data is available on read_wordX output ports.
  signal read_done_reg    : std_logic;   -- Read_done reset after start_read.
  signal int_read_done    : std_logic;   -- Read_done including start_read.
  -- Signal to control the 5x32bit fifo.
  signal store_rdata      : std_logic;   -- Store hrdata into the fifo.
  signal next_to_shift    : std_logic;   -- Fifo must be shifted (init -> word,
                                         -- word -> end, init -> end)
  -- *** MASTER INTERFACE ***
  signal burst            : std_logic_vector(2 downto 0); -- type of transfer
  signal busreq           : std_logic; -- bus request
  signal unspeclength     : std_logic; -- Indicates the end of an incr. transfer
  signal busy             : std_logic; -- not used
  signal buserror         : std_logic; -- signals an error on the bus
  signal inc_addr         : std_logic; -- The master can write the next address.
  signal decr_addr        : std_logic; -- high during a retry/split
  signal valid_data       : std_logic; -- the data is valid on the bus 
  signal grant_lost       : std_logic; -- the master lost bus ownership
  
  -- *** READ/WRITE ACCESS SIGNALS ***
  signal int_5words_reg   : std_logic_vector(159 downto 0); -- 5 internal words.

  -- *** WRITE ACCESS SIGNALS ***
  signal int_wr_size      : std_logic_vector(4 downto 0); -- Internal write size
  -- Internal haddr.
  signal haddr_reg        : std_logic_vector(addrmax_g-1 downto 0);
  -- Signal int_haddrn contains haddr_reg + n.
  signal int_haddr1       : std_logic_vector(addrmax_g-1 downto 0);
  signal int_haddr4       : std_logic_vector(addrmax_g-1 downto 0);
  signal int_haddr8       : std_logic_vector(addrmax_g-1 downto 0);
  -- write address + 4.
  signal wr_addr4         : std_logic_vector(addrmax_g-1 downto 0);
  signal wr_addr_2lsb     : std_logic_vector(1 downto 0); -- Write address LSB.
  -- Address reached after the last write access.
  signal wr_final_addr    : std_logic_vector(addrmax_g-1 downto 0);
  
  -- *** READ ACCESS SIGNALS ***
  signal int_rd_size      : std_logic_vector( 2 downto 0); -- Internal read size
  signal last_read_done   : std_logic; -- Read done delayed by one clock cycle.
  -- Register for read_addr 2 LSB.
  signal rd_addr_2lsb_reg : std_logic_vector(1 downto 0);
  -- Number of words read from AHB.  
  signal rd_words         : std_logic_vector( 2 downto 0); -- Max value is 5.
  signal rd_words1        : std_logic_vector( 2 downto 0); -- rd_words+1.
  signal rd_words2        : std_logic_vector( 2 downto 0); -- rd_words+2.
  -- Number of words to read from AHB.
  signal rd_words_asked   : std_logic_vector( 2 downto 0);
  -- Indicates the words to be added to 'int_rd_size' to get rd_words_asked.  
  signal rd_add_words     : std_logic_vector( 2 downto 0);
  -- Data read on the AHB, not registered.
  signal int_read_word0   : std_logic_vector(31 downto 0);
  signal int_read_word1   : std_logic_vector(31 downto 0);
  signal int_read_word2   : std_logic_vector(31 downto 0);
  signal int_read_word3   : std_logic_vector(31 downto 0);
  -- Signals to break a burst when hsize changes.
  signal change_burst_size: std_logic;
  signal patch_htrans     : std_logic;
  signal htrans_int       : std_logic_vector(1 downto 0);
  -- Signals to break a burst whencrossing a 1kB address boundary.
  signal cross_1kboundary : std_logic;
  signal hsize_int        : std_logic_vector(2 downto 0);
  signal ahb_state_diag   : std_logic_vector(2 downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- ****** STATES MACHINES ***************************************************
  -----------------------------------------------------------------------------

  -- Control signals from addresses.
  wr_addr_2lsb          <= write_addr(1 downto 0); 
  -- Define signals from rd_words.
  rd_words1             <= rd_words + 1;
  rd_words2(2 downto 1) <= rd_words(2 downto 1) + 1;
  rd_words2(0)          <= rd_words(0);

  -- This process describes the combinational part of the state machine.
  acc_next_pr: process (acc_cur_state, buserror, haddr_reg, inc_addr,
                        int_haddr1, int_haddr4, int_haddr8, rd_words1,
                        rd_words2, rd_words_asked, read_done_reg, sp_init,
                        start_read, start_read_mem, start_write,
                        start_write_mem, valid_data, wr_addr4, wr_addr_2lsb,
                        wr_final_addr)
  begin
    if (sp_init = '1') or (buserror = '1') then     -- Operation interrupted.
      acc_next_state <= idle_state;
    else
      case acc_cur_state is

        -- Idle State: Wait for a read/write request.
        when idle_state =>
          if (start_read = '1') or (start_write = '1') then
            acc_next_state <= wait_req_state;
          else
            acc_next_state <= idle_state;
          end if;

        
        --------------------------------------------
        -- Bus request states
        --------------------------------------------
        
        -- Set the bus request. This step cannot be skipped even if the bus is
        -- already granted, because the stream processor drives the start_write
        -- signal two clock cycles before the correct write data and address.
        when wait_req_state =>
          acc_next_state <= wait_grant_state;

        -- Wait one clock-cycle for the bus grant (minimum delay). If a read and
        -- a write request are received at the same time, read access has the
        -- priority.
        when wait_grant_state =>
          if read_done_reg = '0' then  -- Read access
            acc_next_state <= rd_access_state;
          else                         -- Write access
            -- Detect the number of bytes to write in the next access.
            case wr_addr_2lsb is

              -- First access is not aligned with 32-bit boundary.
              when "01" | "10" | "11" =>
                acc_next_state <= wr_initbyte_state;

              -- Address aligned with 32-bit boundary.
              when others =>
                -- First access is less than 4 bytes.
                if wr_addr4 > wr_final_addr then
                  acc_next_state <= wr_endbyte_state;
                else -- First access is 32bits.
                  acc_next_state <= wr_word_state;
                end if;

            end case;

          end if;


        --------------------------------------------
        -- Write states
        --------------------------------------------
        
        -- Write non aligned bytes at address offsets 1, 2, and 3 (first bytes).
        when wr_initbyte_state =>
          if inc_addr = '1' then               -- Master ready for next address.

            -- Init bytes written in bus(31/23/15:8) and no more bytes to write.
            if int_haddr1 = wr_final_addr then
              acc_next_state <= wr_last_state;

            -- Init bytes written, write following bytes.
            elsif haddr_reg(1 downto 0) = "11" then
              if int_haddr4 >= wr_final_addr then -- Less than 4 bytes to write.
                acc_next_state <= wr_endbyte_state;
              else                                -- 4 bytes to write or more.
                acc_next_state <= wr_word_state;
              end if;

            -- Write following init bytes.
            else
              acc_next_state <= wr_initbyte_state;  
            end if;

          else -- Wait for master interface.
            acc_next_state <= wr_initbyte_state;
          end if;

        -- Write 32bit words.
        when wr_word_state =>
          if inc_addr = '1' then                  -- Master ready for next addr.
            if int_haddr4 = wr_final_addr then    -- All data written.
              acc_next_state <= wr_last_state;
            elsif int_haddr8 > wr_final_addr then -- Less than 4 bytes to write.
              acc_next_state <= wr_endbyte_state;
            else                                  -- 4 bytes to write or more.
              acc_next_state <= wr_word_state;
            end if;
          else                                    -- Wait for master interface.
            acc_next_state <= wr_word_state;
          end if;

        -- Write non aligned bytes at address offsets 0, 1, and 2 (last bytes).
        when wr_endbyte_state =>
          if inc_addr = '1' then                  -- Master ready for next addr.
            if int_haddr1 = wr_final_addr then    -- All data written.
              acc_next_state <= wr_last_state;
            else
              acc_next_state <= wr_endbyte_state; -- Write next byte.
            end if;
          else                                    -- Wait for master interface.
            acc_next_state <= wr_endbyte_state;         
          end if;

        -- Stay in wr_last_state until hwdata has been sampled (valid_data = 1).
        -- This impedes beginning a new access with the same hgrant and erasing
        -- hwdata with the next data to write (This is more likely to occur when
        -- the slave inserts a wait state on the bus before sampling hwdata).
        when wr_last_state =>
          if valid_data = '1' then                -- hwdata sampled by slave.
            -- In case of new request, go directly to wait_req_state.
            if (start_read = '1' or start_read_mem = '1')
              or (start_write = '1' or start_write_mem = '1') then
              acc_next_state <= wait_req_state;
            else
              acc_next_state <= idle_state;
            end if;
          else                                    -- Wait for end of write.
            acc_next_state <= wr_last_state;
          end if;


        --------------------------------------------
        -- Read states
        --------------------------------------------
        
        -- Read rd_words_asked words.
        -- The following timing diagrams show the two cases to test to detect
        -- the last read access. 'n' is set to 'rd_words_asked'.
        -- 'rd_last_state' must be entered when inc_addr is high. The diagram
        -- shows that following valid_data, two values of rd_words are possible.
        --
        -- case 1: two successive accesses.     case 2: last access was alone.
        --                __   :__    __            __   :__    __   
        --  hclk       __|  |__|  |__|  |_       __|  |__|  |__|  |_ 
        --             ________:                    _____:
        --  inc_addr           \__________       __/     \__________
        --             ________:_____                    :_____
        --  valid_data         :     \____       ________/     \____
        --             __ _____:_____ ____       __ _____:_____ ____
        --  rd_words   __X_n-2_X_n-1_X_n__       __X____n-1____X_n__
        --                     :                         :
        when rd_access_state =>
          -- Detect when last address has been sent on the bus.
          if (inc_addr = '1' and valid_data = '1'      -- Case 1.
                     and rd_words2 >= rd_words_asked)
             or (inc_addr = '1' and valid_data = '0'   -- Case 2.
                     and rd_words1 >= rd_words_asked) then
            acc_next_state <= rd_last_state;
          else
            acc_next_state <= rd_access_state;
          end if;

        -- Store last read data.
        when rd_last_state =>
          if valid_data = '1' then  -- Last data ready.
            acc_next_state <= idle_state;
          else                      -- Wait for last read data.
            acc_next_state <= rd_last_state;
          end if;

        when others =>
          acc_next_state <= idle_state;

      end case;

    end if;
  end process acc_next_pr;
  -----------------------------------------------------------------------------
  -- This process describes the sequential part of the state machine.
  acc_cur_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      acc_cur_state <= idle_state;      -- State Machine starts on idle state.
    elsif (clk'event and clk = '1') then
      acc_cur_state <= acc_next_state;  -- Update the State Machine.
    end if;
  end process acc_cur_pr;
  -----------------------------------------------------------------------------
  -- This process generates controls signals for the AHB access block.
  control_pr : process (clk, reset_n)
  begin
    if reset_n = '0' then
      start_write_mem <= '0';
      start_read_mem  <= '0';
      read_done_reg   <= '1';
      write_done      <= '1';
      store_rdata     <= '0';
      hwrite          <= '0';
      next_to_shift   <= '0';
    elsif clk'event and clk = '1' then
      store_rdata <= '0';              -- Pulse.

      -- Reset all signals if the operation is interrupted (sp_init).
      if sp_init = '1' then
        start_write_mem <= '0';
        start_read_mem  <= '0';
        read_done_reg   <= '1';
        write_done      <= '1';
        store_rdata     <= '0';
        hwrite          <= '0';
        next_to_shift   <= '0';
      else
        
        case acc_next_state is

          -- Reset signals used in previous access and detect new access.
          when idle_state | wait_req_state =>
            -- Assert write_done when entering idle state.
            if acc_cur_state = wr_last_state then
              write_done <= '1';
            end if;
            -- Assert read_done_reg when entering idle state.
            if acc_cur_state = rd_last_state then
              read_done_reg <= '1';
            end if;
            -- Write cycle over, reset start_write_mem and start_read_mem.
            start_write_mem <= '0';
            start_read_mem  <= '0';
            -- Reset write control signals.
            hwrite          <= '0';
            next_to_shift   <= '0';
            -- Detect new write access.
            if start_write = '1' then
              write_done <= '0';
            end if;
            -- Detect new read access.
            if start_read = '1' then
              read_done_reg <= '0';
            end if;

          -- Write states (except lasts).
          when wr_initbyte_state | wr_word_state =>
            hwrite <= '1';                -- Set AHB write signal.

          -- Write end bytes state.
          when wr_endbyte_state =>
            hwrite <= '1';                -- Set AHB write signal.
            if (acc_cur_state = wr_initbyte_state
                or acc_cur_state = wr_word_state) then -- Data written before.
              next_to_shift <= '1';
            elsif valid_data = '1' then
              next_to_shift <= '0';
            end if;

          -- Last write state.
          when wr_last_state =>
            -- start_write_mem and start_read_mem are used to memorize
            -- start_read and start_write during wr_last_state. Priority is 
            -- given to read access.
            if start_read = '1' then
              start_read_mem <= '1';
              read_done_reg  <= '0';
            elsif start_write = '1' then
              start_write_mem <= '1';
              write_done <= '0';
            end if;

          -- Read states.  
          when rd_access_state | rd_last_state =>
            hwrite <= '0';                -- Reset AHB write signal.

          when others => null;
        end case;

        -- Set store_rdata when hrdata must be sampled.
        if acc_cur_state = rd_access_state
           or acc_next_state = rd_last_state then
          store_rdata <= '1'; -- read_access
        end if;

      end if;
    end if;
  end process control_pr;
  -----------------------------------------------------------------------------
  -- 'done' signals generation.
  -- 
  -- It is not needed to assert write_done low when start_write is high, because
  -- the stream processor control state machines will sample write_done one
  -- clock cycle later. The following timing diagram illustrates this point:
  --                  ____      ____      ____      ____      ____      _
  --  clk          __|    |____|    |____|    |____|    |____|    |____| 
  --               __ _________ _________:_____________________________:_
  --  sp_state     __X_bus_req_X__grant__X__write______________________X_
  --                  _________          : <--- sample write_done ---> :
  --  start_write  __/         \_________:_____________________________:_
  --               ____________          :                    _________:_
  --  write_done               \_________:___________________/         :
  --                                     :                             :
  --
  -- On the contrary, as 'wait' and 'grant' states are not used for read
  -- accesses, read_done must be asserted as soon as read_state is entered.
  --                  ____      ____      ____      _
  --  clk          __|    |____|    |____|    |____| 
  --               __:_____________________________:_
  --  sp_state     __X__________read_______________X_
  --                 :_________                    :
  --  start_read   __/         \___________________:_
  --               __:                    _________:_
  --  read_done      \___________________/         :
  --                 : <---- sample read_done ---> :
  --
  
  -- internal value.
  int_read_done <= read_done_reg and not start_read;
  -- Output port.
  read_done     <= last_read_done and not start_read;

  -----------------------------------------------------------------------------
  -- ****** HTRANS Patch ******************************************************
  -----------------------------------------------------------------------------
  -- Detect when haddr will cross a 1 kB boundary.
  boundary_cross_p : process (haddr_reg, hsize_int)
  begin
    if (haddr_reg(9 downto 0) = BOUNDARY32_CT and hsize_int = WORD_CT)
      or (haddr_reg(9 downto 0) = BOUNDARY8_CT and hsize_int = BYTE_CT) then
      cross_1kboundary <= '1';
    else 
      cross_1kboundary <= '0';
    end if;
  end process boundary_cross_p;
  
  
  
  -- Detect when hsize is going to change (32 <-> 8 bits).
  change_burst_size <= '1'
    when (acc_cur_state = wr_initbyte_state and acc_next_state = wr_word_state)
      or (acc_cur_state = wr_word_state and acc_next_state = wr_endbyte_state)
                  else '0';
  
  -- Generate a control signal HIGH during the address phase with new hsize.
  htrans_patch_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      patch_htrans <= '0';
    elsif clk'event and clk = '1' then
      if (inc_addr = '1' ) then
        -- Necessary to begin a new burst.
        if (change_burst_size = '1') or (cross_1kboundary = '1') then
          patch_htrans <= '1';
        -- End of address phase.
        else
          patch_htrans <= '0';
        end if;
      end if;
    end if;
  end process htrans_patch_p;
  
  -- hsize cannot be changed during a burst. To begin a new burst when hsize 
  -- changes, htrans is set to NON_SEQ.
  patch_htrans_p: process(htrans_int, patch_htrans)
  begin
    if (htrans_int = "11" and patch_htrans = '1') then
      htrans <= "10";
    else
      htrans <= htrans_int;
    end if;
  end process patch_htrans_p;
  
  
  -----------------------------------------------------------------------------
  -- ****** MASTER INTERFACE **************************************************
  -----------------------------------------------------------------------------
 
  busy <= '0';      -- functionality not used
  burst <= INCR_CT; -- Only unspecified length bursts.

  -- This signal is set to indicate the end of an unspecified length burst.
  unspeclength <= '1' when acc_next_state = idle_state
                  or acc_next_state = rd_last_state
                  or acc_next_state = wr_last_state
                  else '0';

  -- The AHB specification requires that for unspecified length bursts, the bus
  -- must be requested until the start of the last access.
  busreq       <= not unspeclength;

  master_interface_1 : master_interface
    generic map (
      gotoaddr_g         => 0,
      burstlinkcapable_g => 0)
    port map (
      hclk         => clk,
      hreset_n     => reset_n,
      burst        => burst,
      busreq       => busreq,
      unspeclength => unspeclength,
      busy         => busy,
      buserror     => buserror,
      inc_addr     => inc_addr,
      valid_data   => valid_data,
      decr_addr    => decr_addr,
      grant_lost   => grant_lost,
      end_add      => open, -- functionality not used
      end_data     => open, -- functionality not used
      free         => open, -- functionality not used
      hready       => hready,
      hresp        => hresp,
      hgrant       => hgrant,
      htrans       => htrans_int,
      hbusreq      => hbusreq
      );

  -- Send an interrupt on error or retry/split responses.
  ahb_interrupt <= buserror or decr_addr;
  

  -----------------------------------------------------------------------------
  -- ****** READ/WRITE ACCESSES ***********************************************
  -----------------------------------------------------------------------------
  ------------------------------------------------------- AHB Address generation
  haddr_pr : process (clk, reset_n)
  begin
    if reset_n = '0' then
      haddr_reg         <= (others => '0');
      rd_addr_2lsb_reg  <= (others => '0');
      rd_words          <= (others => '0');
    elsif (clk'event and clk = '1') then
      case acc_cur_state is

        when wait_grant_state => -- Init AHB address.
          if acc_next_state = rd_access_state then   -- Read access.
            -- Read accesses are always aligned on 32bit boundaries.
            haddr_reg (31 downto 2) <= read_addr(31 downto 2);
            haddr_reg ( 1 downto 0) <= "00";
            -- Register read address two LSB for read data mux control.
            rd_addr_2lsb_reg        <= read_addr(1 downto 0);
            -- Reset the counter of the read words.
            rd_words                <= (others => '0');
          elsif acc_next_state = wr_initbyte_state
            or  acc_next_state = wr_endbyte_state
            or  acc_next_state = wr_word_state then  -- Write access.
            haddr_reg <= write_addr;            
          end if;          

        when rd_access_state | rd_last_state => -- Read access.
          if inc_addr = '1' then    -- Increment address.
            haddr_reg (31 downto 2) <= haddr_reg (31 downto 2) + '1';
          end if;
          if valid_data = '1' then  -- Read data is valid on bus.
            rd_words <= rd_words + '1';
          end if;

        when wr_initbyte_state | wr_endbyte_state => -- Write bytes.
          if inc_addr = '1' then    -- Increment AHB address in 1 byte.
            haddr_reg <= int_haddr1; 
          end if;

        when wr_word_state => -- Write 32bits.
          if inc_addr = '1' then    -- Increment AHB address in 1 word.
            haddr_reg <= int_haddr4;
          end if;
          
        when others => null;
      end case;
    end if;
  end process haddr_pr;

  haddr <= haddr_reg;
  ------------------------------------------------ End of AHB Address generation
  ------------------------------------------------- AHB Control lines generation
  -- This process generates the control lines to be sent to the AHB. These lines
  -- are sent together with the address lines, which means one clock earlier
  -- than the data.
  hsize_pr: process (clk, reset_n)
  begin
    if reset_n = '0' then
      hsize_int  <= BYTE_CT;
    elsif (clk'event and clk = '1') then
      if hready = '1' then
        case acc_next_state is

          when wr_initbyte_state | wr_endbyte_state =>
            hsize_int <= BYTE_CT;

          when wr_word_state | rd_access_state  =>
            hsize_int <= WORD_CT;

          when others => null;
        end case;
      end if;
    end if;
  end process hsize_pr;

  hsize  <= hsize_int;
  hburst <= burst; -- always incr transfers

  ------------------------------------------ End of AHB Control lines generation  
  --------------------------------------------------------- AHB  Data generation
  hdata_pr : process (clk, reset_n)
  begin
    if reset_n = '0' then
      int_5words_reg <= (others => '0');
    elsif (clk'event and clk = '1') then
      -------------------------------------------------------------------------
      -- Read Access
      -------------------------------------------------------------------------
      if store_rdata = '1' and valid_data = '1'then 
          case rd_words is
            when "000" =>
              int_5words_reg ( 31 downto 0)   <= hrdata;
            when "001" =>
              int_5words_reg ( 63 downto 32)  <= hrdata;
            when "010" =>
              int_5words_reg ( 95 downto 64)  <= hrdata;
            when "011" =>
              int_5words_reg (127 downto 96)  <= hrdata;
            when "100" =>
              int_5words_reg (159 downto 128) <= hrdata;
            when others =>
             null;
          end case;
      else
        -----------------------------------------------------------------------
        -- Write Access
        -----------------------------------------------------------------------
        case acc_cur_state is

          when wait_grant_state =>             -- Initialise internal register.
            if (acc_next_state = wr_initbyte_state
                or acc_next_state = wr_word_state 
                or acc_next_state = wr_endbyte_state) then -- Write access.

              case wr_addr_2lsb is
                when "01" =>
                  -- Destination address not aligned. One byte offset.
                  int_5words_reg <= "000000000000000000000000" & write_word3 &
                                write_word2 & write_word1 & write_word0 &
                                "00000000";
                  
                when "10" =>
                  -- Destination address not aligned. Two byte offset.
                  int_5words_reg <= "0000000000000000" & write_word3 & write_word2 &
                                write_word1 & write_word0 & "0000000000000000";
                  
                when "11" =>
                  -- Destination address not aligned. Three byte offset.
                  int_5words_reg <= "00000000" & write_word3 & write_word2 & 
                                write_word1 & write_word0 &
                                "000000000000000000000000";
                  
                when others =>          -- 32-bit alignement.
                  int_5words_reg <= "00000000000000000000000000000000" & write_word3 &
                                write_word2 & write_word1 & write_word0;
              end case;
            end if;


          when wr_word_state | wr_endbyte_state => -- Shift internal register.       
              if (valid_data = '1' and acc_cur_state = wr_word_state)
              or (valid_data = '1' and next_to_shift = '1'
                   and acc_cur_state = wr_endbyte_state) then
                int_5words_reg (31 downto 0)   <= int_5words_reg (63 downto 32);
                int_5words_reg (63 downto 32)  <= int_5words_reg (95 downto 64);
                int_5words_reg (95 downto 64)  <= int_5words_reg (127 downto 96);
                int_5words_reg (127 downto 96) <= int_5words_reg (159 downto 128);
              end if;
              
          when others => null;
        end case;
      end if;
    end if;
  end process hdata_pr;

  hwdata <= int_5words_reg (31 downto  0);
  
  -----------------------------------------------------End AHB  Data generation

  -----------------------------------------------------------------------------
  -- ****** WRITE ACCESSES ****************************************************
  -----------------------------------------------------------------------------

  ----------------------------------------------------- wr_final_addr Generation
  -- int_wr_size is the internal write size, knowing that when size = "0000",
  -- the number of bytes to write is 16.
  int_wr_size <= ('0' & write_size(3 downto 0))
              when write_size(3 downto 0) /= "0000"
         else "10000";
  -- final_addr indicates the address reached when all data is written.
  wr_final_addr <= write_addr + int_wr_size;
  ---------------------------------------------- End of wr_final_addr Generation

  ----------------------------------------------------------------------- Adders
  -- This process creates the adders to increment the internal address
  -- 'haddr_reg'. This address needs to be incremented in one unit when a byte
  -- is written, in 4 units when a word is written and in 8 units to compare
  -- it in the State Machine.
  --  int_haddr1 = haddr_reg + 1
  int_haddr1 <= haddr_reg + 1;
  --  int_haddr4 = haddr_reg + 4
  int_haddr4(addrmax_g-1 downto 2) <= haddr_reg(addrmax_g-1 downto 2) + 1;
  int_haddr4(1 downto 0)           <= haddr_reg(1 downto 0);
  --  int_haddr8 = haddr_reg + 8
  int_haddr8(addrmax_g-1 downto 3) <= haddr_reg(addrmax_g-1 downto 3) + 1;
  int_haddr8(2 downto 0)           <= haddr_reg(2 downto 0);
  --  wr_addr4 = haddr_reg + 4
  wr_addr4(addrmax_g-1 downto 2) <= write_addr(addrmax_g-1 downto 2) + 1;
  wr_addr4(1 downto 0)           <= write_addr(1 downto 0);
  ---------------------------------------------------------------- End of Adders

  -----------------------------------------------------------------------------
  -- ****** READ ACCESSES *****************************************************
  -----------------------------------------------------------------------------

  ---------------------------------------------------- rd_words_asked generation
  -- This process generates the signal rd_words_asked, which indicates the
  -- number of words to be read from the AHB. This number will vary depending on
  -- the address offset and data size.

  -- int_rd_size is the read size in words, knowing that when read_size = "0000"
  -- the number of bytes to read is 16. int_rd_size gives the correct word 
  -- number when read_size(1:0) = 0, else it gives the word number minus one.
  int_rd_size <= ('0' & read_size(3 downto 2))
              when read_size(3 downto 0) /= "0000"
         else "100";

  -- rd_add_words calculates the number of words to be added to int_rd_size 
  -- depending on the least significant bits of read_addr and read_size.
  --  * int_rd_size gives the word number minus one when read_size(1:0) /= 0 
  -- (see above), so one word must be added in that case.
  --  * If read_addr(1 downto 0) /= 0, the first read access will contain only
  -- X bytes, X < 4. Then, except if read_size 2 LSB show that one access of X
  -- bytes or less has to be done, read one more word to complete this first
  -- read.
  rd_add_words <= "000" when -- No need to add words, int_rd_size is correct.
           (read_addr(1 downto 0) = "00" and read_size(1 downto 0) = "00")
             else "010" when -- Add two words when 1st access does not contain
                             -- read_size LSB bytes.
           (read_addr(1 downto 0) = "10" and read_size(1 downto 0) = "11") or
           (read_addr(1 downto 0) = "11" and read_size(1 downto 0) >= "10")
             else "001";     -- Add one word to correct int_rd_size.

  -- rd_words_asked is the number of words to be read from the AHB. Max value is
  -- five words.
  rd_words_asked <= int_rd_size + rd_add_words;

  --------------------------------------------- End of rd_words_asked generation
 
  ---------------------------------------------------------------- Read data mux
  -- This process takes the correct byte from the data read on the AHB,
  -- following the read_addr 2 LSB.
  output_generation_pr: process (int_5words_reg, rd_addr_2lsb_reg, read_size)
  begin
    case rd_addr_2lsb_reg is
      when "01" =>
        int_read_word3 <= int_5words_reg (135 downto 104);
        int_read_word2 <= int_5words_reg (103 downto  72);
        int_read_word1 <= int_5words_reg ( 71 downto  40);
        int_read_word0 <= int_5words_reg ( 39 downto   8);
                         
      when "10" =>       
        int_read_word3 <= int_5words_reg (143 downto 112);
        int_read_word2 <= int_5words_reg (111 downto  80);
        int_read_word1 <= int_5words_reg ( 79 downto  48);
        int_read_word0 <= int_5words_reg ( 47 downto  16);
                         
      when "11" =>       
        int_read_word3 <= int_5words_reg (151 downto 120);
        int_read_word2 <= int_5words_reg (119 downto  88);
        int_read_word1 <= int_5words_reg ( 87 downto  56);
        int_read_word0 <= int_5words_reg ( 55 downto  24);
                         
      when others =>     
        int_read_word3 <= int_5words_reg (127 downto  96);
        int_read_word2 <= int_5words_reg ( 95 downto  64);
        int_read_word1 <= int_5words_reg ( 63 downto  32);
        int_read_word0 <= int_5words_reg ( 31 downto   0);

    end case;
    -- Unwanted data is replaced by zeros.
    case read_size is     -- Add zeros if read_size /= 0.
      when "1111" => 
        int_read_word3 (31 downto 24) <= (others => '0');
      when "1110" => 
        int_read_word3 (31 downto 16) <= (others => '0');
      when "1101" => 
        int_read_word3 (31 downto  8) <= (others => '0');
      when "1100" => 
        int_read_word3 (31 downto  0) <= (others => '0');
      when "1011" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto 24) <= (others => '0');
      when "1010" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto 16) <= (others => '0');
      when "1001" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto  8) <= (others => '0');
      when "1000" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto  0) <= (others => '0');
      when "0111" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto  0) <= (others => '0');
        int_read_word1 (31 downto 24) <= (others => '0');
      when "0110" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto  0) <= (others => '0');
        int_read_word1 (31 downto 16) <= (others => '0');
      when "0101" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto  0) <= (others => '0');
        int_read_word1 (31 downto  8) <= (others => '0');
      when "0100" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto  0) <= (others => '0');
        int_read_word1 (31 downto  0) <= (others => '0');
      when "0011" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto  0) <= (others => '0');
        int_read_word1 (31 downto  0) <= (others => '0');
        int_read_word0 (31 downto 24) <= (others => '0');
      when "0010" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto  0) <= (others => '0');
        int_read_word1 (31 downto  0) <= (others => '0');
        int_read_word0 (31 downto 16) <= (others => '0');
      when "0001" => 
        int_read_word3 (31 downto  0) <= (others => '0');
        int_read_word2 (31 downto  0) <= (others => '0');
        int_read_word1 (31 downto  0) <= (others => '0');
        int_read_word0 (31 downto  8) <= (others => '0');
      when others =>
          null;
    end case;
  end process output_generation_pr;
  --------------------------------------------------------- End of read data mux

  -------------------------------------------------------------  Read Data lines
  -- int_read_words are registered after each read access.
  read_reg_proc: process (clk, reset_n)
  begin
    if reset_n = '0' then
      read_word0 <= (others => '0');
      read_word1 <= (others => '0');
      read_word2 <= (others => '0');
      read_word3 <= (others => '0');
      last_read_done <= '1';
      
    elsif clk'event and clk = '1' then
      last_read_done <= int_read_done; -- Delay int_read_done.
      if int_read_done = '1' and last_read_done = '0' then -- read_done pulse.
        read_word0 <= int_read_word0;
        read_word1 <= int_read_word1;
        read_word2 <= int_read_word2;
        read_word3 <= int_read_word3;        
      end if;
    end if;
  end process read_reg_proc;
  
  ------------------------------------------------------- End of read Data lines

  ----------------------------------------------------  Diagnostic for AHB state
  diag_p : process (acc_cur_state)
  begin
    case acc_cur_state is
      when idle_state | wait_req_state | wait_grant_state =>
        ahb_state_diag <= (others => '0');
      when wr_initbyte_state =>
        ahb_state_diag <= "001";
      when wr_word_state     =>
        ahb_state_diag <= "010";
      when wr_endbyte_state  =>
        ahb_state_diag <= "011";
      when wr_last_state     =>
        ahb_state_diag <= "100";
      when rd_access_state   =>
        ahb_state_diag <= "101";
      when rd_last_state     =>
        ahb_state_diag <= "110";
      when others =>
        ahb_state_diag <= "111";
    end case;
  end process diag_p;
  
  diag <= "00" &          -- 7:6
          busreq &        -- 5
          patch_htrans &  -- 4
          inc_addr &      -- 3
          ahb_state_diag; -- 2:0
  
  ---------------------------------------------  End of Diagnostic for AHB state


end RTL;
