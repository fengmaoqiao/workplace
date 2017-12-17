
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: padding.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This unit builds the complete WLAN frame, starting with the
--              tx_start_end_req_i signal. The SIGNAL and SERVICE field are built
--              from the input parameters rate, length, and service. Parity and
--              tail bits are added. Then the incoming data octets from data_i
--              are taken, when validated with data_valid_i. After the data
--              bits, the tail and (if necessary) the pad bits are appended.
-- 
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/padding/vhdl/rtl/padding.vhd,v  
--  Log: padding.vhd,v  
-- Revision 1.4  2004/12/14 10:54:53  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.3  2003/05/26 15:40:04  Dr.A
-- Wait for enable to generate marker_o and start_of_burst_o.
--
-- Revision 1.2  2003/04/02 16:56:05  Dr.A
-- Debugged symbol_cnt wrap around in data_tail state.
--
-- Revision 1.1  2003/03/13 15:00:20  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity padding is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                : in std_logic;
    reset_n            : in std_logic;

    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i           : in  std_logic;
    data_ready_o       : out std_logic;
    data_ready_i       : in  std_logic;
    data_valid_i       : in  std_ulogic;
    tx_start_end_req_i : in  std_logic;
    prbs_sel_i         : in  std_logic_vector(1 downto 0);
    prbs_inv_i         : in  std_logic;
    prbs_init_i        : in  std_logic_vector(22 downto 0);
    --
    data_valid_o       : out std_logic;
    marker_o           : out std_logic;
    coding_rate_o          : out std_logic_vector(1 downto 0);  -- data coding rate
    qam_mode_o         : out std_logic_vector(1 downto 0);  -- qam mode
    start_burst_o      : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    txv_length_i       : in  std_logic_vector(11 downto 0);  -- Length of frame 1
    txv_rate_i         : in  std_logic_vector(3 downto 0);  -- Rate for frame 1
    txv_service_i      : in  std_logic_vector(15 downto 0);  -- Service field
    data_i             : in  std_logic_vector(7 downto 0);  -- Input data octet
    --
    data_o             : out std_logic


    );

end padding;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of padding is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Constants for Data Rate: 6, 9, 12, 18, 24, 36, 48 or 54 Mbits/s.
  constant DATA_RATE48_CT   : std_logic_vector(2 downto 0) := "000";
  constant DATA_RATE24_CT   : std_logic_vector(2 downto 0) := "001";
  constant DATA_RATE12_CT   : std_logic_vector(2 downto 0) := "010";
  constant DATA_RATE6_CT    : std_logic_vector(2 downto 0) := "011";
  constant DATA_RATE54_CT   : std_logic_vector(2 downto 0) := "100";
  constant DATA_RATE36_CT   : std_logic_vector(2 downto 0) := "101";
  constant DATA_RATE18_CT   : std_logic_vector(2 downto 0) := "110";
  constant DATA_RATE9_CT    : std_logic_vector(2 downto 0) := "111";
  -- Constants for Coding Rate: 1/2, 2/3 or 3/4.
  constant CODING_RATE12_CT : std_logic_vector(1 downto 0) := "00";
  constant CODING_RATE23_CT : std_logic_vector(1 downto 0) := "10";
  constant CODING_RATE34_CT : std_logic_vector(1 downto 0) := "11";
  -- Constants for Modulation type: BPSK, QPSK, 16-QAM and 64-QAM.
  constant MOD_64QAM_CT     : std_logic_vector(1 downto 0) := "00";
  constant MOD_QPSK_CT      : std_logic_vector(1 downto 0) := "01";
  constant MOD_16QAM_CT     : std_logic_vector(1 downto 0) := "10";
  constant MOD_BPSK_CT      : std_logic_vector(1 downto 0) := "11";
  -- Constants for the number of bits per symbol.
  constant NDBPS24_CT       : std_logic_vector(7 downto 0) := "00010111";
  constant NDBPS36_CT       : std_logic_vector(7 downto 0) := "00100011";
  constant NDBPS48_CT       : std_logic_vector(7 downto 0) := "00101111";
  constant NDBPS72_CT       : std_logic_vector(7 downto 0) := "01000111";
  constant NDBPS96_CT       : std_logic_vector(7 downto 0) := "01011111";
  constant NDBPS144_CT      : std_logic_vector(7 downto 0) := "10001111";
  constant NDBPS192_CT      : std_logic_vector(7 downto 0) := "10111111";
  constant NDBPS216_CT      : std_logic_vector(7 downto 0) := "11010111";


  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  -- The padding state machine builds up the PPDU frame.
  type PAD_STATE_T is (init_state,
                       -- States belonging to the PPDU Signal field
                       sig_rate_state,
                       sig_reserved_state,
                       sig_length_state,
                       sig_parity_state,
                       sig_tail_state,
                       -- States belonging to the PPDU Data field
                       data_service_state,
                       data_psdu_state,
                       data_tail_state,
                       data_padbits_state,
                       -- Test state: Pseudo-Random-Binary-Sequence
                       test_prbs_state);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- State and next state in the padding state machine.
  signal cur_pad_state       : PAD_STATE_T;
  signal next_pad_state      : PAD_STATE_T;
  -- Signals extracted from txv_rate_i.
  signal coding_rate         : std_logic_vector(1 downto 0); -- Coding rate.
  signal qam_mode            : std_logic_vector(1 downto 0); -- Modulation type.
  signal nb_bit_p_symb       : std_logic_vector(7 downto 0); -- Bits per symbol.
  -- Signals registered and sent to the outputs.
  signal coding_rate_ff      : std_logic_vector(1 downto 0);
  signal qam_mode_ff         : std_logic_vector(1 downto 0);
  signal nb_bit_p_symb_ff    : std_logic_vector(7 downto 0);
  -- Signal used to compute the parity of the SIGNAL field.
  signal parity_bit          : std_logic; -- Combinational.
  signal parity_bit_ff       : std_logic; -- Registered.
  -- tx_start_end_req registered for edge detection.
  signal tx_start_end_req_ff : std_logic;
  -- This signal indicates the start of the SIGNAL field.
  signal start_burst_int     : std_logic;
  -- Signals used during test mode.
  signal prbs_vec            : std_logic_vector(22 downto 0);
  signal prbs_vec_ff         : std_logic_vector(22 downto 0);
  -- Counters for the data stream.
  -- Counter used to build the OFDM frame.
  signal frame_cnt           : std_logic_vector(3 downto 0);
  -- Counts up to txv_length to send the correct numbert of data words.
  signal length_cnt          : std_logic_vector(11 downto 0);
  -- Count the number of bit sent modulo the required number of bits per symbol.
  signal symbol_cnt          : std_logic_vector(7 downto 0);
  -- Control signal fir PSDU unvalid data.
  signal psdu_unvalid        : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  ----------------------------------------------------------------------------
  -- TXV information decode.
  ----------------------------------------------------------------------------

  -- This process decodes the information contained in the txv_rate_i signal.
  rate_decode_p : process (coding_rate_ff, qam_mode_ff, nb_bit_p_symb_ff,
                           start_burst_int, txv_rate_i)
  begin
    -- Decode txv_rate_i at the beginning of the SIGNAL field.
    if start_burst_int = '1' then
      case txv_rate_i(2 downto 0) is

        when DATA_RATE6_CT =>                 -- 6 Mbits/s
          coding_rate   <= CODING_RATE12_CT;  -- 1/2
          qam_mode      <= MOD_BPSK_CT;       -- BPSK
          nb_bit_p_symb <= NDBPS24_CT;

        when DATA_RATE9_CT =>                 -- 9 Mbits/s
          coding_rate   <= CODING_RATE34_CT;  -- 3/4
          qam_mode      <= MOD_BPSK_CT;       -- BPSK
          nb_bit_p_symb <= NDBPS36_CT;

        when DATA_RATE12_CT =>                -- 12 Mbits/s
          coding_rate   <= CODING_RATE12_CT;  -- 1/2
          qam_mode      <= MOD_QPSK_CT;       -- QPSK
          nb_bit_p_symb <= NDBPS48_CT;

        when DATA_RATE18_CT =>                -- 18 Mbits/s
          coding_rate   <= CODING_RATE34_CT;  -- 3/4
          qam_mode      <= MOD_QPSK_CT;       -- QPSK
          nb_bit_p_symb <= NDBPS72_CT;

        when DATA_RATE24_CT =>                -- 24 Mbits/s
          coding_rate   <= CODING_RATE12_CT;  -- 1/2
          qam_mode      <= MOD_16QAM_CT;      -- 16-QAM
          nb_bit_p_symb <= NDBPS96_CT;

        when DATA_RATE36_CT =>                -- 36 Mbits/s
          coding_rate   <= CODING_RATE34_CT;  -- 3/4
          qam_mode      <= MOD_16QAM_CT;      -- 16-QAM
          nb_bit_p_symb <= NDBPS144_CT;

        when DATA_RATE48_CT =>                -- 48 Mbits/s
          coding_rate   <= CODING_RATE23_CT;  -- 2/3
          qam_mode      <= MOD_64QAM_CT;      -- 64-QAM
          nb_bit_p_symb <= NDBPS192_CT;

        when DATA_RATE54_CT =>                -- 54 Mbits/s
          coding_rate   <= CODING_RATE34_CT;  -- 3/4
          qam_mode      <= MOD_64QAM_CT;      -- 64-QAM
          nb_bit_p_symb <= NDBPS216_CT;

        when others =>
          coding_rate   <= coding_rate_ff;
          qam_mode      <= qam_mode_ff;
          nb_bit_p_symb <= nb_bit_p_symb_ff;
          
      end case;
    else
      coding_rate   <= coding_rate_ff;
      qam_mode      <= qam_mode_ff;
      nb_bit_p_symb <= nb_bit_p_symb_ff;
    end if;
  end process rate_decode_p;


  ----------------------------------------------------------------------------
  -- Padding counters.
  ----------------------------------------------------------------------------

  -- This signal indicates when the data is valid during data_psdu_state.
  psdu_unvalid <= '1' when (cur_pad_state = data_psdu_state)
                  and (data_valid_i = '0')
                  else '0';

  -- Counter for state machine.
  -- The frame_cnt counter is used to move to the next state and count the data
  -- sent on data_o. It is  reset at init_state and incremented for each valid
  -- data to sent.
  --  0 < frame_cnt <= 3                  : send rate
  --  frame_cnt = 4                       : reserved bit
  --  5 < frame_cnt <= 0 (wrap)           : send length
  --  frame_cnt = 1                       : parity bit
  --  2 < frame_cnt <= 7                  : send tail bits
  --  8 < frame_cnt <= 7 (wrap)           : send service
  --  8/0 < frame_cnt(2 downto 0) <= 15/7 : send data
  frame_cnt_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      frame_cnt <= (others => '0');
    elsif clk'event and clk = '1' then
      if cur_pad_state = init_state then
        frame_cnt <= (others => '0');
      elsif (data_ready_i = '1') and (psdu_unvalid = '0') then
        frame_cnt <= frame_cnt + '1';
      end if;
    end if;
  end process frame_cnt_p;

  -- Bits per symbol counter.
  -- This counter is used to know how many tail bits must be added to
  -- complete the last OFDM symbol. It counts the number of data bits sent
  -- modulo the number of bits per symbol.
  symb_cnt_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      symbol_cnt <= (others => '0');
    elsif clk'event and clk = '1' then
      -- Reset symbol_cnt at the end of the signal. Keep it still during init.
      if (cur_pad_state = sig_tail_state) or (cur_pad_state = init_state) then
        symbol_cnt <= (others => '0');
      elsif data_ready_i = '1' then -- Count up modulo nb_bit_p_symb_ff.
        if symbol_cnt = nb_bit_p_symb_ff then
          symbol_cnt <= (others => '0');
        elsif psdu_unvalid = '0' then
          symbol_cnt <= symbol_cnt + 1;
        end if;
      end if;
    end if;
  end process symb_cnt_p;


  -- Counter for data length.
  -- At the beginning of a transmission, the counter is set with the txv_length
  -- value. During data_psdu_state, it is decremented each 8 valid data.
  length_cnt_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      length_cnt <= (others => '0');
    elsif clk'event and clk = '1' then
      if (tx_start_end_req_i = '1' and tx_start_end_req_ff = '0') then
        length_cnt <= txv_length_i;
      elsif (data_ready_i = '1') and (data_valid_i = '1')
        and (frame_cnt(2 downto 0) = "111")
        and (cur_pad_state = data_psdu_state) then
        length_cnt <= length_cnt - '1';
      end if;
    end if;
  end process length_cnt_p;


  ----------------------------------------------------------------------------
  -- Padding State machine
  ----------------------------------------------------------------------------
  -- Combinational process. The state duration is based on frame_cnt.
  pad_fsm_comb_p : process (frame_cnt, cur_pad_state, symbol_cnt, data_ready_i,
                            data_valid_i, length_cnt, nb_bit_p_symb_ff,
                            prbs_sel_i, tx_start_end_req_ff,
                            tx_start_end_req_i)
  begin

    next_pad_state <= cur_pad_state;

    case cur_pad_state is

      -- Detect start of transmission with tx_start_end_req rising edge.
      when init_state =>
        if tx_start_end_req_i = '1' and tx_start_end_req_ff = '0' then
          next_pad_state <= sig_rate_state;
        end if;

      -- Count up to 4 RATE bits before going to RESERVED field.
      when sig_rate_state =>
        if data_ready_i = '1' then
          if frame_cnt = "0011" then
            next_pad_state <= sig_reserved_state;
          end if;
        end if;

      -- RESERVED field is one bit long.
      when sig_reserved_state =>
        if data_ready_i = '1' then
          next_pad_state <= sig_length_state;
        end if;

      -- Count up to 12 LENGTH bits before going to PARITY field.
      when sig_length_state =>
        if data_ready_i = '1' then
          if frame_cnt = "0000" then
            next_pad_state <= sig_parity_state;
          end if;
        end if;

      -- PARITY field is one bit long.
      when sig_parity_state =>
        if data_ready_i = '1' then
          next_pad_state <= sig_tail_state;
        end if;

      -- Count up to 6 TAIL bits before going to SERVICE field.
      when sig_tail_state =>
        if data_ready_i = '1' then
          if frame_cnt = "0111" then
            next_pad_state <= data_service_state;
          end if;
        end if;

      -- Count up to 16 SERVICE bits before going to PSDU field.
      -- Following the setting of prbs_sel_i, go to PSDU or PRBS state.
      when data_service_state =>
        if data_ready_i = '1' then
          if frame_cnt = "0111" then

            if prbs_sel_i(1) = '1' or prbs_sel_i(0) = '1' then
              next_pad_state <= test_prbs_state;
            else
              next_pad_state <= data_psdu_state;
            end if;

          end if;
        end if;

      -- Count up to the number of bits taken from txv_length.
      when data_psdu_state =>
        -- As long as a new data is presented to the block
        if data_valid_i = '1' then
          if data_ready_i = '1' then
            -- The PSDU is built with txv_length 8bits words.
            if frame_cnt(2 downto 0) = "111" then -- count 8 bits for each word.
              if length_cnt = "000000000001" then -- count up to txv_length.
                next_pad_state <= data_tail_state;
              end if;
            end if;
          end if;

        -- When data_valid_i = '0', check tx_start_end_req to know if more
        -- data is expected. frame_cnt = 0 when the 8 bits of the current
        -- data have been sent.
        elsif tx_start_end_req_i = '0' and frame_cnt(2 downto 0) = "000" then
          next_pad_state <= data_tail_state;
        end if;

      -- Count up to 6 TAIL bits before going to PADBITS field.
      when data_tail_state =>
        if data_ready_i = '1' then
          if frame_cnt(2 downto 0) = "101" then
            next_pad_state <= data_padbits_state;
          end if;
        end if;

      -- Add as many pad bits as needed to finish the current OFDM symbol.
      when data_padbits_state =>
        if data_ready_i = '1' then
          if symbol_cnt = nb_bit_p_symb_ff then
            next_pad_state <= init_state;
          end if;
        end if;

      -- Exit test_prbs_state only on reset.
      when test_prbs_state => null;

      when others => null;

    end case;
  end process pad_fsm_comb_p;

  -- Sequential process
  pad_fsm_seq_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      cur_pad_state <= init_state;
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        cur_pad_state <= init_state;
      else
        cur_pad_state <= next_pad_state;
      end if;
    end if;
  end process pad_fsm_seq_p;


  ----------------------------------------------------------------------------
  -- Markers generation.
  ----------------------------------------------------------------------------
  -- This process generates the 4 markers escorting the data output stream.
  --   Marker 1: Start of frame
  --   Marker 2: Start of SERVICE field
  --   Marker 3: Start of TAIL bits in the data field (here the following 
  -- scrambler can insert zeros)
  --   Marker 4: Start of PAD bits. This marker is inserted even if no padbits
  -- are actually appended.
  -- All markers are placed one data clock BEFORE the actual event.
  marker_p : process (cur_pad_state, next_pad_state, enable_i)
  begin
    
    if enable_i = '0' then

      start_burst_int <= '0';
      marker_o        <= '0';
      
    else

      start_burst_int <= '0';
      marker_o        <= '0';
      case next_pad_state is

        -- Generate markers 1, 2, 3, 4
        when init_state | data_service_state | data_tail_state |
             data_padbits_state =>
          if cur_pad_state /= next_pad_state then
            marker_o <= '1';
          end if;

        when sig_rate_state =>
          -- Send marker and start_burst before entering sig_rate_state.
          if cur_pad_state /= next_pad_state then
            start_burst_int <= '1';
            marker_o        <= '1';
          end if;

        when others =>
          start_burst_int <= '0';
          marker_o        <= '0';

      end case;
      
    end if;
    
  end process marker_p;


  ----------------------------------------------------------------------------
  -- Output data generation.
  ----------------------------------------------------------------------------
  -- This process generates the output data, i.e.:
  --  the RATE (LSB first) is sent during sig_rate_state,
  --  the LENGTH (LSB first) is sent during sig_length_state,
  --  the parity calculated on RATE and LENGTH is sent during sig_parity_state,
  --  the SERVICE (LSB first) is sent during data_service_state,
  --  the DATA (LSB first) is sent during data_psdu_state,
  --  an LFSR is used during test_prbs_state,
  --  else '0' is sent (reserved bit, tail and pad).
  --
  -- It is expected that data_i is held constant while data_valid_i is '1'.

  data_p : process (frame_cnt, cur_pad_state, data_i, data_ready_i, data_valid_i,
                    parity_bit_ff, prbs_inv_i, prbs_sel_i, prbs_vec_ff,
                    txv_length_i, txv_rate_i, txv_service_i,prbs_init_i)
    variable data_v : std_logic;
  begin
    -- Default values.
    data_v := '0';
    parity_bit <= parity_bit_ff;
    prbs_vec        <= prbs_init_i;

    case cur_pad_state is

      when init_state =>
        data_o          <= '0';
        parity_bit      <= '0';

      when sig_rate_state =>
        -- Send txv_rate_i, LSB first, on data_o.
        case frame_cnt is
          when "0000" =>
            data_v := txv_rate_i(0);
          when "0001" =>
            data_v := txv_rate_i(1);
          when "0010" =>
            data_v := txv_rate_i(2);
          when others =>
            data_v := txv_rate_i(3);
        end case;
        -- Compute parity bit.
        if data_ready_i = '1' and data_v = '1' then
          parity_bit <= not(parity_bit_ff);
        end if;
        data_o <= data_v;

      when sig_length_state =>
        -- Send txv_length_i, LSB first, on data_o.
        case frame_cnt is
          when "0101" =>
            data_v := txv_length_i(0);
          when "0110" =>
            data_v := txv_length_i(1);
          when "0111" =>
            data_v := txv_length_i(2);
          when "1000" =>
            data_v := txv_length_i(3);
          when "1001" =>
            data_v := txv_length_i(4);
          when "1010" =>
            data_v := txv_length_i(5);
          when "1011" =>
            data_v := txv_length_i(6);
          when "1100" =>
            data_v := txv_length_i(7);
          when "1101" =>
            data_v := txv_length_i(8);
          when "1110" =>
            data_v := txv_length_i(9);
          when "1111" =>
            data_v := txv_length_i(10);
          when others =>
            data_v := txv_length_i(11);
        end case;
        -- Compute parity bit.
        if data_ready_i = '1' and data_v = '1' then
          parity_bit <= not(parity_bit_ff);
        end if;
        data_o <= data_v;

      when sig_parity_state =>
        -- Send parity bit.
        data_o <= parity_bit_ff;

      when data_service_state =>       
        -- Send txv_service_i, LSB first, on data_o.
        case frame_cnt is
          when "1000" =>
            data_o <= txv_service_i(0);
          when "1001" =>
            data_o <= txv_service_i(1);
          when "1010" =>
            data_o <= txv_service_i(2);
          when "1011" =>
            data_o <= txv_service_i(3);
          when "1100" =>
            data_o <= txv_service_i(4);
          when "1101" =>
            data_o <= txv_service_i(5);
          when "1110" =>
            data_o <= txv_service_i(6);
          when "1111" =>
            data_o <= txv_service_i(7);
          when "0000" =>
            data_o <= txv_service_i(8);
          when "0001" =>
            data_o <= txv_service_i(9);
          when "0010" =>
            data_o <= txv_service_i(10);
          when "0011" =>
            data_o <= txv_service_i(11);
          when "0100" =>
            data_o <= txv_service_i(12);
          when "0101" =>
            data_o <= txv_service_i(13);
          when "0110" =>
            data_o <= txv_service_i(14);
          when others =>
            data_o <= txv_service_i(15);
        end case;

      when data_psdu_state =>
        if data_valid_i = '1' then
          -- Send data_i, LSB first, on data_o.
          case frame_cnt(2 downto 0) is
            when "000" =>
              data_o <= data_i(0);
            when "001" =>
              data_o <= data_i(1);
            when "010" =>
              data_o <= data_i(2);
            when "011" =>
              data_o <= data_i(3);
            when "100" =>
              data_o <= data_i(4);
            when "101" =>
              data_o <= data_i(5);
            when "110" =>
              data_o <= data_i(6);
            when others =>
              data_o <= data_i(7);
          end case;
        else
          data_o <= '0';
        end if;

      -- Generate a Pseudo-Random-Binary-Sequence for test.
      when test_prbs_state =>
        prbs_vec     <= prbs_vec_ff;
        -- take the bit 1 to be conform with cossap
        data_o <= prbs_vec_ff(1) xor prbs_inv_i;
        if data_ready_i = '1' then
          if prbs_sel_i(1) = '1' then     -- prbs 23
            prbs_vec(21 downto 0) <= prbs_vec_ff(22 downto 1);
            prbs_vec(22)          <= prbs_vec_ff(0) xor prbs_vec_ff(18);
          else                            -- prbs 15
            prbs_vec(13 downto 0) <= prbs_vec_ff(14 downto 1);
            prbs_vec(14)          <= prbs_vec_ff(0) xor prbs_vec_ff(14);
          end if;
        end if;

      when others => 
        data_o      <= '0';
        parity_bit  <= parity_bit_ff;

    end case;
  end process data_p;


  ----------------------------------------------------------------------------
  -- Register outputs.
  ----------------------------------------------------------------------------
  registers : process (clk, reset_n)
  begin
    if reset_n = '0' then
      coding_rate_ff      <= (others => '0');
      qam_mode_ff         <= (others => '0');
      nb_bit_p_symb_ff    <= (others => '0');
      parity_bit_ff       <= '0';
      tx_start_end_req_ff <= '0';
      prbs_vec_ff         <= (others => '1');
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        coding_rate_ff      <= (others => '0');
        qam_mode_ff         <= (others => '0');
        nb_bit_p_symb_ff    <= (others => '0');
        parity_bit_ff       <= '0';
        tx_start_end_req_ff <= '0';
        prbs_vec_ff         <= (others => '1');
      else
        coding_rate_ff      <= coding_rate;
        qam_mode_ff         <= qam_mode;
        nb_bit_p_symb_ff    <= nb_bit_p_symb;
        parity_bit_ff       <= parity_bit;
        tx_start_end_req_ff <= tx_start_end_req_i;
        prbs_vec_ff         <= prbs_vec;
      end if;
    end if;
  end process registers;


  ----------------------------------------------------------------------------
  -- Assign outputs.
  ----------------------------------------------------------------------------
  coding_rate_o <= coding_rate_ff;
  qam_mode_o    <= qam_mode_ff;
  start_burst_o <= start_burst_int;
  
  
  data_valid_o  <= '0' when cur_pad_state = init_state
                  else data_valid_i when cur_pad_state = data_psdu_state
                  else '1';
  
  -- When the octet is inserted in the data stream, the data_ready_o is
  -- activated, indicating that the unit is ready for the next data octet.
  data_ready_o <= '1' when (cur_pad_state = data_psdu_state
                 and (data_valid_i = '0' or
                      (data_ready_i = '1' and frame_cnt(2 downto 0) = "111")))
                  else '0';

end RTL;
