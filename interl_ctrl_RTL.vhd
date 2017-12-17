
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: interl_ctrl.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block has three functionnalities:
--              - Control of the memory used for the first data permutation,
--              - Second data permutation on the first permutated data,
--              - Carrier reordering.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/interleaver/vhdl/rtl/interl_ctrl.vhd,v  
--  Log: interl_ctrl.vhd,v  
-- Revision 1.4  2004/12/14 10:48:45  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.3  2003/05/19 09:11:51  Dr.A
-- Remove unused begin_read from sensitivity list.
--
-- Revision 1.2  2003/03/26 10:57:47  Dr.A
-- Modified marker outputs generation for FFT compliancy.
--
-- Revision 1.1  2003/03/13 14:50:51  Dr.A
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
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity interl_ctrl is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk               : in  std_logic; -- Module clock
    reset_n           : in  std_logic; -- Asynchronous reset.
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i          : in  std_logic; -- TX path enable.
    data_valid_i      : in  std_logic;
    data_ready_i      : in  std_logic;
    qam_mode_i        : in  std_logic_vector(1 downto 0);
    marker_i          : in  std_logic;
    --
    pilot_ready_o     : out std_logic;
    start_signal_o    : out std_logic; -- 'start of signal' marker.
    end_burst_o       : out std_logic; -- 'end of burst' marker.
    data_valid_o      : out std_logic;
    data_ready_o      : out std_logic;
    null_carrier_o    : out std_logic; -- '1' data for null carriers.
    qam_mode_o        : out std_logic_vector( 1 downto 0); -- coding rate.
    --------------------------------------
    -- Memory interface
    --------------------------------------
    data_p1_i         : in  std_logic_vector( 5 downto 0); -- data from memory.
    --
    addr_o            : out std_logic_vector( 4 downto 0); -- address.
    mask_wr_o         : out std_logic_vector( 5 downto 0); -- write mask.
    rd_wrn_o          : out std_logic; -- '1' to read, '0' to write.
    msb_lsbn_o        : out std_logic; -- '1' to read MSB, '0' to read LSB.
    --------------------------------------
    -- Data
    --------------------------------------
    pilot_scr_i       : in  std_logic; -- Data for the 4 pilot carriers.
    --
    data_o            : out std_logic_vector( 5 downto 0) -- Interleaved data.
    
  );

end interl_ctrl;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of interl_ctrl is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  -- Type for the first permutation memory control.
  type P1_MEM_STATE_T is (mem_write_state, -- memory is written,
                          mem_read_state); -- memory is read.

  -- Type to identify the carrier type.
  type CARRIER_TYPE_T is (null_carrier_type,
                          data_carrier_type,
                          pilot_carrier_type,
                          pilot_inv_carrier_type);

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Constants for coding rate.
  constant QAM64_CT         : std_logic_vector( 1 downto 0) := "00"; 
  constant QAM16_CT         : std_logic_vector( 1 downto 0) := "10"; 
  constant QPSK_CT          : std_logic_vector( 1 downto 0) := "01"; 
  constant BPSK_CT          : std_logic_vector( 1 downto 0) := "11";
  -- Init value of the permutation 1 memory write mask.
  constant MASK_INIT_CT     : std_logic_vector( 5 downto 0) := "100000";
  -- Permutation 1 memory max address (the memory is 24 rows by 12 columns).
  constant ADDR_MAX_CT      : std_logic_vector( 4 downto 0) := "10111"; -- 23
  -- Because of carrier reordering, the first row read for the memory is row 4.
  constant ADDR_START_RD_CT : std_logic_vector( 4 downto 0) := "00100"; -- 4
  -- Init value for permutation 1 memory read counter.
  constant RD_CNT_INIT_CT   : std_logic_vector( 1 downto 0) := "10"; 
  -- Number of memory colums written for first permutation.
  constant NBCOL_QAM64_CT   : std_logic_vector( 2 downto 0) := "101"; -- 6 col.
  constant NBCOL_QAM16_CT   : std_logic_vector( 2 downto 0) := "011"; -- 4 col.
  constant NBCOL_QPSK_CT    : std_logic_vector( 2 downto 0) := "001"; -- 2 col.
  constant NBCOL_BPSK_CT    : std_logic_vector( 2 downto 0) := "000"; -- 1 col.
  -- Constants for second permutation schemes.
  constant PERM0_CT         : std_logic_vector( 1 downto 0) := "00"; 
  constant PERM1_CT         : std_logic_vector( 1 downto 0) := "01"; 
  constant PERM2_CT         : std_logic_vector( 1 downto 0) := "10";


  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  
  -- NOTE: _rs signals are the registered values of a combinational signal.
  
  signal carrier_type          : CARRIER_TYPE_T; -- Type of carrier.
  -- Counter for the 64 carriers used.
  signal carrier_cnt           : std_logic_vector(5 downto 0);
  signal carrier_cnt_rs        : std_logic_vector(5 downto 0);
  -- Signals for interleaver state machine.
  signal mem_state_cur         : P1_MEM_STATE_T;
  signal mem_state_next        : P1_MEM_STATE_T;
  signal in_readstate          : std_logic; -- high during memory read.
  -- These signals indicate the beginning of a memory phase:
  signal begin_write           : std_logic; -- writing phase,
  signal begin_read            : std_logic; -- reading phase.
  -- Signals to store QAM mode during DATA field.
  signal qam_mode              : std_logic_vector( 1 downto 0);
  signal qam_mode_rs           : std_logic_vector( 1 downto 0);
  -- Store incoming 'end of burst' marker till end of internal burst processing.
  signal marker_end_sav        : std_logic;
  signal marker_end_sav_rs     : std_logic;
  signal start_signal_sav        : std_logic;
  signal start_signal_sav_rs     : std_logic;
  -- Counter for first permutation memory address.
  signal addr_cnt              : std_logic_vector( 4 downto 0);
  signal addr_cnt_rs           : std_logic_vector( 4 downto 0);
  -- Counters for first permutation memory write.
  signal repeat_wr_cnt         : std_logic_vector( 2 downto 0);
  signal repeat_wr_cnt_rs      : std_logic_vector( 2 downto 0);
  signal repeat_wr_cnt_init    : std_logic_vector( 2 downto 0);
  signal repeat_wr_cnt_init_rs : std_logic_vector( 2 downto 0);
  -- Mask to write first permutation memory.
  signal mask_wr               : std_logic_vector( 5 downto 0);
  signal mask_wr_rs            : std_logic_vector( 5 downto 0);
  -- Indicates if MSB or LSB must be read in first permutation memory.
  signal msb_lsbn              : std_logic; -- '1' to read MSB.
  signal msb_lsbn_rs           : std_logic;
  -- Counter for first permutation memory read.
  signal rd_cnt                : std_logic_vector( 1 downto 0);
  signal rd_cnt_rs             : std_logic_vector( 1 downto 0);
  -- Counter for permutation 2.
  signal perm2_cnt             : std_logic_vector( 1 downto 0);
  signal perm2_cnt_rs          : std_logic_vector( 1 downto 0);
  signal perm2_cnt_max         : std_logic_vector( 1 downto 0);
  signal perm2_cnt_max_rs      : std_logic_vector( 1 downto 0);
  -- Data permutated twice.
  signal data_p2               : std_logic_vector( 5 downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -------------------------------------------------------------------------
  --
  -- Block overview:
  --
  -- The incoming data is the encoded OFDM symbol (48 to 288 bits depending on
  -- the coding rate). It must be interleaved by two permutations. The resulting
  -- 48 data carriers, plus 4 inserted pilot carriers and the null DC carrier,
  -- are mapped from tone -26 to +26 by the standard. They must be reordered in
  -- order to have only positive frequencies at the FFT input. Null carriers
  -- are added to fit with a 64-point IFFT.
  --
  -- To achieve the first permutation, the incoming data is written in the
  -- permutation 1 memory in a specific order, and read back in another order.
  -- The order is the same for all coding rates, except that a different number
  -- of memory columns need to be written for each rate.
  --
  -- Carrier reordering, pilot carrier insertion and second data permutation
  -- are performed directly on the data read back from the first permutation
  -- memory.
  -- 
  -------------------------------------------------------------------------
  

  -- This counter counts up the 64 carriers output from this block during the
  -- memory read phase.
  carrier_cnt_p : process (carrier_cnt_rs, mem_state_cur)
  begin
    if mem_state_cur = mem_write_state then
      carrier_cnt <= (others => '0');
    else -- increment carrier counter during write state
      carrier_cnt <= carrier_cnt_rs + 1;
    end if;
  end process carrier_cnt_p;
  
  -- This mux on carrier_cnt is used to detect the type of the carrier being
  -- sent, and therefore to know how pilot, null and data carriers must be
  -- reordered.
  -- Following the standard, the 48 data carriers stored in the memory are
  -- mapped to tones -26 to 26, with pilot carriers inserted at tones 7, 21,
  -- -7 and -21 and the DC carrier at tone 0.
  -- During the reading phase, the carriers are sent in the order corresponding
  -- to the IFFT inputs: the DC carrier is sent first, followed by positive
  -- frequency carriers. The space to the next carrier (negative frequency) is
  -- filled with null carriers, then the negative frequency carriers are sent.
  -- The following table shows the resulting carrier reordering.
  --
  --   ,-----------------------------------------.      
  --   | data in |            |    FFT input     |           
  --   | memory  |  standard  | = carrier_cnt_rs |
  --   -------------------------------------------
  --   |   D0    |  -26 (D)   |       38         |
  --   |   ...   |    ...     |       ...        |
  --   |   D4    |  -22 (D)   |       42         |
  --   |         |  -21 (P)   |       43         |
  --   |   D5    |  -20 (D)   |       44         |
  --   |   ...   |    ...     |       ...        |
  --   |   D17   |   -8 (D)   |       56         |
  --   |         |   -7 (P)   |       57         |
  --   |   D18   |   -6 (D)   |       58         |
  --   |   ...   |    ...     |       ...        |
  --   |   D23   |   -1 (D)   |       63         |
  --   |         |    0 (DC)  |        0         |
  --   |   D24   |    1 (D)   |        1         |
  --   |   ...   |    ...     |       ...        |
  --   |   D29   |    6 (D)   |        6         |
  --   |         |    7 (P)   |        7         |
  --   |   D30   |    8 (D)   |        8         |
  --   |   ...   |    ...     |       ...        |
  --   |   D42   |   20 (D)   |       20         |
  --   |         |   21 (P-)  |       21         |
  --   |   D43   |   22 (D)   |       22         |
  --   |   ...   |    ...     |       ...        |
  --   |   D47   |   26 (D)   |       26         |
  --   `-----------------------------------------'
    
  carrier_type_p : process (carrier_cnt_rs)
  begin
    case carrier_cnt_rs is
      
      when "010101" =>  -- FFT input 21
        carrier_type <= pilot_inv_carrier_type;
      
      when "000111" | "101011" | "111001" => -- FFT inputs 7, 43, and 57.
        carrier_type <= pilot_carrier_type;
      
      when others =>
        -- NULL carriers are carrier 0 and carriers between 27 and 37.
        if ((carrier_cnt_rs >= "011011") and (carrier_cnt_rs <= "100101"))
          or (carrier_cnt_rs = "000000") then
          carrier_type <= null_carrier_type;
        else -- Others are data carriers.
          carrier_type <= data_carrier_type;
        end if;
        
    end case;
  end process carrier_type_p;
  

  -------------------------------------------------------------------------
  -- Interleaver permutation 1 memory state machine
  -------------------------------------------------------------------------

  -- There are two states in the state machine: write and then read. First the
  -- write operation is repeated repeat_write_cnt * addr_cnt times. Then the
  -- read cycle begins. It ends when carrier_cnt_rs reaches 63.
  
  -- Conditions to begin the next read cycle: the FSM is in write state,
  -- the input data is valid, the repeat_wr_cnt_rs counter indicates there are
  -- no more write operation to process for the current address block and the
  -- addr_cnt_rs counter indicates all three address blocks have been written.
  begin_read <= '1' when mem_state_cur = mem_write_state and 
                         data_valid_i = '1' and
                         repeat_wr_cnt_rs = "000" and
                         addr_cnt_rs = ADDR_MAX_CT else
                '0';

  -- begin the next write cycle when all 64 carriers have been read and sent.
  begin_write <= '1' when carrier_cnt_rs = "111111" else '0';
            
  -- FSM combinational process.
  fsm_comb_pr : process (begin_read, begin_write, mem_state_cur)
  begin
    case mem_state_cur is

      when mem_write_state =>
        if begin_read = '1' then
          mem_state_next <= mem_read_state;
        else
          mem_state_next <= mem_write_state;
        end if;

      when others => -- Read cycle.
        if begin_write = '1' then
          mem_state_next <= mem_write_state;
        else
          mem_state_next <= mem_read_state;
        end if;

    end case;
  end process fsm_comb_pr;

  -- FSM sequential process.
  fsm_seq_pr : process (clk, reset_n)
  begin
    if reset_n = '0' then
      mem_state_cur <= mem_write_state;
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        mem_state_cur <= mem_write_state;
      else
        if data_ready_i = '1' or in_readstate = '0' then
          mem_state_cur <= mem_state_next;
        end if;
      end if;
    end if;
  end process fsm_seq_pr;

  -- Detect read state.
  in_readstate <= '1' when mem_state_cur = mem_read_state else '0';
          

  -------------------------------------------------------------------------
  -- Permutations controls.
  -------------------------------------------------------------------------
  -- This process initializes the parameters used in a write/read cycle.
  init_p : process (begin_write, marker_end_sav_rs, perm2_cnt_max_rs,
                    qam_mode_i, qam_mode_rs, repeat_wr_cnt_init_rs)
  begin
    -- Registered values.
    qam_mode           <= qam_mode_rs;
    repeat_wr_cnt_init <= repeat_wr_cnt_init_rs;
    perm2_cnt_max      <= perm2_cnt_max_rs;

    -- Load parameters init values at the beginning of a write/read cycle.
    if begin_write = '1' then

      -- At the end of the burst, prepare controls for the SIGNAL field (BPSK).
      if marker_end_sav_rs = '1' then
        qam_mode           <= BPSK_CT;
        repeat_wr_cnt_init <= NBCOL_BPSK_CT;
        perm2_cnt_max      <= PERM0_CT;
      -- For others write/read cycles the values depend on qam_mode_i.
      else
        qam_mode <= qam_mode_i;
        case qam_mode_i is
          when QAM64_CT =>
            repeat_wr_cnt_init <= NBCOL_QAM64_CT;
            perm2_cnt_max      <= PERM2_CT;
          when QPSK_CT =>
            repeat_wr_cnt_init <= NBCOL_QPSK_CT;
            perm2_cnt_max      <= PERM0_CT;
          when QAM16_CT =>
            repeat_wr_cnt_init <= NBCOL_QAM16_CT;
            perm2_cnt_max      <= PERM1_CT;
          when others => -- BPSK_CT
            repeat_wr_cnt_init <= NBCOL_BPSK_CT;
            perm2_cnt_max      <= PERM0_CT;
        end case;
      end if;
    end if;
  end process init_p;

  -- This process describes the permutation 2 counter.
  -- Three permutation schemes, refered as PERM0, PERM1 and PERM2, can be
  -- applied. During PERM0 the data is unchanged, so this scheme is used for
  -- QPSK and BPSK (no second permutation). For QAM16, PERM0 and PERM1 are used
  -- alternatively. For QAM64, PERM0, PERM1 and PERM2 are used alternatively.
  -- The perm2_cnt counter is therefore increased at each data carrier, with
  -- a maximal  value depending on the coding rate.
  -- Because of carrier reordering, the 24th data is sent first. This induces 
  -- changes only for QAM64: the first scheme used is PERM2, and the scheme
  -- count must be reset to PERM0 for data 0. This is done when PERM2 is
  -- reached during a null carrier.
  perm2_cnt_p : process (carrier_type, in_readstate, perm2_cnt_max_rs,
                         perm2_cnt_rs, rd_cnt_rs)    
  begin
    -- Permutation 2 is done on data read from the memory.
    if in_readstate = '1' then
      perm2_cnt <= perm2_cnt_rs;

      case carrier_type is

        when null_carrier_type =>
          -- return to permutation 0 during middle null carrier in QAM64.
          if perm2_cnt_rs = PERM1_CT then
            perm2_cnt <= PERM0_CT;
          end if;
        
        when data_carrier_type =>
          -- Each permutation scheme is applied on a group of three carriers.
          if rd_cnt_rs = "00" then
            -- Increase perm2_cnt up to perm2_cnt_max_rs.
            if perm2_cnt_rs = perm2_cnt_max_rs then
              perm2_cnt <= PERM0_CT;
            else
              perm2_cnt <= perm2_cnt_rs + 1;
            end if;
          end if;

        when others => null;

      end case;
    else -- write state
      perm2_cnt <= perm2_cnt_max_rs;   
    end if;

  end process perm2_cnt_p;

  -- This process handles the second permutation.
  permutation2_p : process (carrier_type, data_p1_i, perm2_cnt_rs, qam_mode_rs)    
  begin    
    data_p2 <= (others => '0');

    -- Only data carriers are permutated. Refer to the specification for
    -- permutation schemes for each coding rate. Depending on the coding
    -- rate, one to six bits are used for the data carrier.
    if carrier_type = data_carrier_type then

      case perm2_cnt_rs is

        -- Permutation 2 scheme 0.
        when PERM0_CT =>
          case qam_mode_rs is
            when QPSK_CT =>
              data_p2 <= data_p1_i(5) & "--" &
                         data_p1_i(4) & "--";
            when QAM16_CT =>
              data_p2 <= data_p1_i(5) & data_p1_i(4) & "-" &
                         data_p1_i(3) & data_p1_i(2) & "-";
            when BPSK_CT =>
              data_p2 <= data_p1_i(5) & "-----";
            when others => -- QAM64_CT
              data_p2 <= data_p1_i;
          end case;

        -- Permutation 2 scheme 1.
        when PERM1_CT =>

          if qam_mode_rs = QAM64_CT then
            data_p2 <= data_p1_i(4 downto 3) & data_p1_i(5) &
                       data_p1_i(1 downto 0) & data_p1_i(2);
          else -- QAM16
            data_p2 <= data_p1_i(4) & data_p1_i(5) & '-' &
                       data_p1_i(2) & data_p1_i(3) & '-';
          end if;

        -- Permutation 2 scheme 2 (only QAM 64).
        when PERM2_CT =>
          data_p2 <= data_p1_i(3) & data_p1_i(5 downto 4) &
                     data_p1_i(0) & data_p1_i(2 downto 1);

        when others => null;

      end case;

    end if;
  end process permutation2_p;

  -- This process generates output data and some data control signals.
  --  * null_carrier_o is set during NULL carriers.
  --  * qam_mode_o is set to QAM64 for NULL carriers and to BPSK for all PILOT
  -- carriers. For data carriers the information from qam_mode_i is used.
  data_out_p : process (carrier_type, data_p2, in_readstate, pilot_scr_i,
                     qam_mode_rs)    
  begin
    -- Default values.    
    data_o          <= (others => '0');
    qam_mode_o      <= QAM64_CT;
    null_carrier_o  <= '0';

    if in_readstate = '1' then

      case carrier_type is

        when data_carrier_type =>
          qam_mode_o <= qam_mode_rs; -- qam_mode_i saved.
          data_o     <= data_p2;     -- data from second permutation.

        when pilot_carrier_type =>
          qam_mode_o       <= BPSK_CT;
          data_o           <= pilot_scr_i & "-----";

        when pilot_inv_carrier_type                =>
          qam_mode_o       <= BPSK_CT;
          data_o           <= not(pilot_scr_i) & "-----";

        when others => -- null_carrier_type
          null_carrier_o  <= '1';
          qam_mode_o      <= QAM64_CT;

      end case;
    end if;

  end process data_out_p;
  
  -- The interleaver receives two markers: 'start of signal' and 'end of burst'.
  -- 'end of burst' arrives with begin_read, when there is no more data to
  -- write. It is saved in marker_end_sav till the end of the block symbol
  -- processing.
  marker_p : process (begin_read, begin_write, marker_end_sav_rs, marker_i)
  begin
    -- marker_i and begin_read indicate the last read cycle ('end of burst').
    if begin_read = '1' then
      marker_end_sav <= marker_i;
    -- Reset marker_end_sav for the next symbol.
    elsif begin_write = '1' then
      marker_end_sav <= '0';
    else
      marker_end_sav <= marker_end_sav_rs;
    end if;
  end process marker_p;

  -- The interleaver receives two markers: 'start of signal' and 'end of burst'.
  -- 'start of signal' arrives during the first write cycle.
  first_marker_p : process (begin_read, start_signal_sav_rs, marker_i)
  begin
    -- The first pulse on marker_i is the start of signal marker.
    if marker_i = '1' then
      start_signal_sav <= '1';
    -- Reset start_signal_sav for the next symbol.
    elsif begin_read = '1' then
      start_signal_sav <= '0';
    else
      start_signal_sav <= start_signal_sav_rs;
    end if;
  end process first_marker_p;

  -- start_signal_sav falling edge indicates the first output data is available.
  start_signal_o <= start_signal_sav_rs and not(start_signal_sav);
  -- marker_end_sav falling edge indicates the end of the interleaver
  -- processing.
  end_burst_o <= marker_end_sav_rs and not(marker_end_sav);

  -------------------------------------------------------------------------
  -- Permutations 1 memory controls.
  -------------------------------------------------------------------------

  -- Refer to the block specification for details.
  -- Memory write:
  -- The 24 rows by 12 columns memory is divided into three row blocks (0 to 7,
  -- 8 to 15 and 16 to 23). Depending on the coding rate, a different number of
  -- columns is written in each row block before going to the next block.
  -- repeat_wr_cnt and mask_wr controls the columns write.
  -- Memory read: 
  -- The first MSB data of each row block is read, followed by the first LSB
  -- data of ecah row block. Reading goes on with the second data of each block,
  -- then the third, till reading addresses 7/16/23.

  mem_ctrl_p : process (addr_cnt_rs, begin_write, carrier_type, data_valid_i,
                        mask_wr_rs, mem_state_cur, msb_lsbn_rs, rd_cnt_rs,
                        repeat_wr_cnt_init, repeat_wr_cnt_init_rs,
                        repeat_wr_cnt_rs)
  begin
    -- Default values.
    addr_cnt        <= addr_cnt_rs;
    rd_wrn_o        <= '1';
    mask_wr         <= MASK_INIT_CT;
    rd_cnt          <= RD_CNT_INIT_CT;
    msb_lsbn       <= '1';
    repeat_wr_cnt   <= repeat_wr_cnt_init_rs;

    case mem_state_cur is

      when mem_write_state =>

        if data_valid_i = '1' then -- New data to write.
          rd_wrn_o <= '0'; -- write cycle.
          
          if addr_cnt_rs(2 downto 0) = "111" then -- A block limit is reached.

            -- All columns used for the current rate are written.
            if repeat_wr_cnt_rs = "000" then 
              -- Reset controls for the next block.
              repeat_wr_cnt <= repeat_wr_cnt_init_rs;
              mask_wr       <= MASK_INIT_CT;
              -- Blocks 1 or 2 have been written, go to the next block.
              if addr_cnt_rs(4) = '0' then
                addr_cnt <= addr_cnt_rs + 1;
              else -- last block have been written, end of data write.
                addr_cnt <= ADDR_START_RD_CT;
              end if;
            else -- Repeat the write operation for the next columns.
              -- Decrement column counter.
              repeat_wr_cnt <= repeat_wr_cnt_rs - 1;
              -- Start over at the beginning of the current block:
              -- addr_cnt = addr_cnt - 7.
              addr_cnt      <= addr_cnt_rs(4 downto 3) & "000";
              -- Shift mask to match next columns.
              mask_wr       <= '0' & mask_wr_rs(5 downto 1);
            end if;
          else -- Go on with next column in the same group.
            addr_cnt      <= addr_cnt_rs + 1;
            repeat_wr_cnt <= repeat_wr_cnt_rs;
            mask_wr       <= mask_wr_rs;
          end if;
        else -- No new data to write: freeze write parameters and allow read.
          rd_wrn_o      <= '1'; -- read cycle.
          addr_cnt      <= addr_cnt_rs;
          mask_wr       <= mask_wr_rs;
          repeat_wr_cnt <= repeat_wr_cnt_rs;          
        end if;

      when others => -- mem_read_state
        if carrier_type = data_carrier_type then
          -- Read data three by three, first MSB, then LSB.
          if rd_cnt_rs = "00" then
            rd_cnt   <= RD_CNT_INIT_CT;
            msb_lsbn <= not(msb_lsbn_rs);
            -- MSB read, keep same addresses to read LSB
            if msb_lsbn_rs = '1' then
              addr_cnt <= "00" & addr_cnt_rs(2 downto 0); -- addr_cnt_rs - 16
            else
              if addr_cnt_rs = ADDR_MAX_CT then -- end of read.
                addr_cnt <= (others => '0');
              else -- Go to next three carriers (addr_cnt_rs - 15).
                addr_cnt <= "00" & addr_cnt_rs(2 downto 0) + 1; 
              end if;
            end if;
          else -- rd_cnt /= 0 : move to next of three carriers.
            addr_cnt  <= addr_cnt_rs + 8;
            rd_cnt    <= rd_cnt_rs - 1;
            msb_lsbn  <= msb_lsbn_rs;        
          end if;
        else -- carrier_type /= data_carrier_type
          addr_cnt   <= addr_cnt_rs;
          rd_cnt     <= rd_cnt_rs;
          msb_lsbn   <= msb_lsbn_rs;
        end if;  
        if begin_write = '1' then -- Reset controls for write phase.
          addr_cnt      <= (others => '0');
          repeat_wr_cnt <= repeat_wr_cnt_init;
        end if;

    end case;

  end process mem_ctrl_p;

  -- Assign output ports.
  data_valid_o    <= in_readstate;
  data_ready_o    <= not(in_readstate);
  mask_wr_o       <= mask_wr_rs;
  addr_o          <= addr_cnt_rs;
  msb_lsbn_o      <= msb_lsbn_rs;
  pilot_ready_o   <= begin_write;
  
  --------------------------------------------
  -- Registers
  --------------------------------------------
  -- Registers.
  registers : process (clk, reset_n)
  begin
    if reset_n = '0' then
      marker_end_sav_rs     <= '0';
      start_signal_sav_rs   <= '0';
      qam_mode_rs           <= BPSK_CT;
      addr_cnt_rs           <= (others => '0');
      repeat_wr_cnt_rs      <= (others => '0');
      repeat_wr_cnt_init_rs <= NBCOL_BPSK_CT;
      mask_wr_rs            <= MASK_INIT_CT;
      carrier_cnt_rs        <= (others => '0');
      msb_lsbn_rs           <= '1';
      rd_cnt_rs             <= (others => '0');
      perm2_cnt_rs          <= PERM0_CT;
      perm2_cnt_max_rs      <= PERM0_CT;
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
       marker_end_sav_rs     <= '0';
       start_signal_sav_rs   <= '0';
       qam_mode_rs           <= BPSK_CT;
       addr_cnt_rs           <= (others => '0');
       repeat_wr_cnt_rs      <= (others => '0');
       repeat_wr_cnt_init_rs <= NBCOL_BPSK_CT;
       mask_wr_rs            <= MASK_INIT_CT;
       carrier_cnt_rs        <= (others => '0');
       msb_lsbn_rs           <= '1';
       rd_cnt_rs             <= (others => '0');
       perm2_cnt_rs          <= PERM0_CT;
       perm2_cnt_max_rs      <= PERM0_CT;
      else
        if data_ready_i = '1' or in_readstate = '0' then
          marker_end_sav_rs     <= marker_end_sav;
          start_signal_sav_rs   <= start_signal_sav;
          qam_mode_rs           <= qam_mode;
          repeat_wr_cnt_rs      <= repeat_wr_cnt;
          repeat_wr_cnt_init_rs <= repeat_wr_cnt_init;
          mask_wr_rs            <= mask_wr;
          carrier_cnt_rs        <= carrier_cnt;
          perm2_cnt_max_rs      <= perm2_cnt_max;
          addr_cnt_rs           <= addr_cnt;
          perm2_cnt_rs          <= perm2_cnt;
          rd_cnt_rs             <= rd_cnt;
          msb_lsbn_rs           <= msb_lsbn;
        end if;
      end if;
    end if;
  end process registers;

end RTL;
