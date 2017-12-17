--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 19120 $
--/ $Date: 2011-12-06 11:54:02 +0100 (Tue, 06 Dec 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : Timers for the CCA generator. Consists in a 1 us pre-counter 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/cca_maxim/vhdl/rtl/cca_timers_maxim.vhd $
--/
--////////////////////////////////////////////////////////////////////////////

--               and a timer based on the us top.

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all; 
 
library cca_maxim_rtl;
use cca_maxim_rtl.cca_maxim_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity cca_timers_maxim is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk              : in  std_logic;
    reset_n          : in  std_logic;

    --------------------------------------
    -- Controls from registers
    --------------------------------------
    -- Delay between end of air activity and AGC reset
    reg_rampdown     : in  std_logic_vector(2 downto 0); -- us
    -- RF bias setting time
    reg_biasdel      : in  std_logic_vector(2 downto 0); -- us
    -- OFDM end of packet
    reg_ofdmrxdel    : in  std_logic_vector(3 downto 0); -- us
    -- DSSS-CCK end of packet
    reg_dcckrxdel    : in  std_logic_vector(3 downto 0); -- us
    
    --------------------------------------
    -- Controls from modem
    --------------------------------------
    phy_rxstartend_ind : in  std_logic; -- HIGH during modem RX processing
    -- DSSS-CCK
    b_psdu_duration    : in  std_logic_vector(15 downto 0); -- us
    -- OFDM
    rxv_length         : in  std_logic_vector(11 downto 0); -- rx psdu length  
    rxv_datarate       : in  std_logic_vector( 3 downto 0); -- rx data rate

    --------------------------------------
    -- Controls from CCA state machines
    --------------------------------------
    -- Modems enable
    ofdm_rx_en       : in  std_logic;
    dcck_rx_en       : in  std_logic;
    -- Timer control
    load_timer       : in  std_logic;
    enable_timer     : in  std_logic;
    cca_dec_state    : in  std_logic_vector(4 downto 0);
    --
    timeout_it       : out std_logic -- Pulse when CCA timer reaches zero
    );

end cca_timers_maxim;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of cca_timers_maxim is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- 10 us = A'h
  constant SYNC_TIMEOUT_CT   : std_logic_vector(16 downto 0) := "00000000000001010";
  -- 20 us = 14'h
  constant HEADER_TIMEOUT_CT : std_logic_vector(16 downto 0) := "00000000000010100";
  -- 144 us = 90'h
  constant SFD_TIMEOUT_CT    : std_logic_vector(16 downto 0) := "00000000010010000";
  -- 52 us = 34'h
  constant PLCP_TIMEOUT_CT   : std_logic_vector(16 downto 0) := "00000000000110100";
  -- 5 clock cycles for RXEND time out
  constant RXEND_TIMEOUT_CT  : std_logic_vector(16 downto 0) := "00000000000000101";
  
  -- Constants for us counter (60 cycles)
  constant US_CT             : std_logic_vector(5 downto 0) := "111011";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Timer control
  signal cca_timer    : std_logic_vector(16 downto 0);
  signal us_counter   : std_logic_vector( 5 downto 0);
  signal top_1mhz     : std_logic;
  -- Time out
  signal timeout_it_i : std_logic; -- HIGH when CCA timer reaches zero
  -- Packet duration estimation
  signal phy_rxstartend_ind_ff1 : std_logic;
  signal psdu_duration_samp     : std_logic_vector(16 downto 0);
  signal dcck_calculation       : std_logic;
  signal rxv_datarate_samp      : std_logic_vector( 3 downto 0);
  signal ofdm_calculation       : std_logic;
  signal ofdm_stop_cca_timer    : std_logic;
  signal ofdm_cnt_mod4          : std_logic_vector( 1 downto 0);
  signal ofdm_cnt_mod4_end      : std_logic_vector( 1 downto 0);
  signal ofdm_cnt_mod4_finish   : std_logic;
  -- PSDU rec. length - register delay
  signal nb_bit_rest            : std_logic_vector(15 downto 0);
  
  ------------------------------------------------------------------------------
  -- Functions
  ------------------------------------------------------------------------------
  -- Function to calculate the number of bits per symbol for each RATE
  function def_nb_bit_p_symb (
    signal   rate : std_logic_vector(3 downto 0))
    return std_logic_vector is
    variable res  : std_logic_vector(7 downto 0);
  begin
    res     := (others => '0');
    case rate is
      when "1011" =>      -- 6 Mbits/s
        res := conv_std_logic_vector(24, 8);
      when "1111" =>      -- 9 Mbits/s
        res := conv_std_logic_vector(36, 8);
      when "1010" =>      -- 12 Mbits/s
        res := conv_std_logic_vector(48, 8);
      when "1110" =>      -- 18 Mbits/s
        res := conv_std_logic_vector(72, 8);
      when "1001" =>      -- 24 Mbits/s
        res := conv_std_logic_vector(96, 8);
      when "1101" =>      -- 36 Mbits/s
        res := conv_std_logic_vector(144, 8);
      when "1000" =>      -- 48 Mbits/s
        res := conv_std_logic_vector(192, 8);
      when "1100" =>      -- 54 Mbits/s
        res := conv_std_logic_vector(216, 8);
      when others => null;
    end case;
    return res;
  end def_nb_bit_p_symb;
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  ------------------------------------------
  -- us pre-counter
  ------------------------------------------
  us_counter_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      us_counter <= US_CT;
    elsif clk'event and clk = '1' then
      if enable_timer = '1' then
        -- Start us count on signal from CCA state machine
        if load_timer = '1' or us_counter = 0 then
          us_counter <= US_CT;
        -- Counter decrement
        else
          us_counter <= us_counter - 1;
        end if;
      else
        us_counter <= US_CT; -- Freeze counter
      end if;
    end if;
  end process us_counter_p;

  top_1mhz <= '1' when us_counter = 0 else '0';

  
  ------------------------------------------
  -- Packet duration estimation
  ------------------------------------------
  pack_duration_est_p: process (clk, reset_n)
    variable delay_offset_v : std_logic_vector(15 downto 0); -- Delay from reg
    variable nb_bit_v       : std_logic_vector(15 downto 0); -- PSDU rec. length
  begin
    if reset_n = '0' then
      phy_rxstartend_ind_ff1 <= '0';
      -- DSSS-CCK
      psdu_duration_samp     <= (others => '0');
      dcck_calculation       <= '0';
      -- OFDM
      rxv_datarate_samp      <= (others => '0');
      ofdm_calculation       <= '0';
      ofdm_cnt_mod4_finish   <= '0';
      ofdm_stop_cca_timer    <= '0';
      ofdm_cnt_mod4          <= (others => '0');
      ofdm_cnt_mod4_end      <= (others => '0');
      nb_bit_rest            <= (others => '0');
      nb_bit_v               := (others => '0');
      delay_offset_v         := (others => '0');
    elsif clk'event and clk = '1' then

      -- Clear dcck_calculation
      if timeout_it_i = '1' and cca_dec_state /= START_RECEPTION_ST_CT then
        dcck_calculation <= '0';
      end if;
      
      -- default value for pulse generation
      ofdm_cnt_mod4_finish <= '0';
      
      -- Sample modem info on RXSTART indication
      phy_rxstartend_ind_ff1 <= phy_rxstartend_ind;
      if phy_rxstartend_ind = '1' and phy_rxstartend_ind_ff1 = '0' then
        
        -- If DSSS-CCK -> copy b_psdu_duration directly
        if dcck_rx_en = '1' then
          psdu_duration_samp <= ext(b_psdu_duration-reg_dcckrxdel, psdu_duration_samp'length);
          dcck_calculation   <= '1';
        
        -- If OFDM -> sample length for calculation
        elsif ofdm_rx_en = '1' then
          rxv_datarate_samp <= rxv_datarate;
          ofdm_calculation   <= '1';
          
          -- Selection of the delay according to the reg_ofdmrxdel
          case reg_ofdmrxdel is
            
            when "0000" =>   -- 0 us
              ofdm_cnt_mod4_end <= "00";
              delay_offset_v    := (others => '0');
            when "0001" =>   -- 1 us
              ofdm_cnt_mod4_end <= "01";
              delay_offset_v    := (others => '0');
            when "0010" =>   -- 2 us
              ofdm_cnt_mod4_end <= "10";
              delay_offset_v    := (others => '0');
            when "0011" =>   -- 3 us
              ofdm_cnt_mod4_end <= "11";
              delay_offset_v    := (others => '0');
            when "0100" =>   -- 4 us
              ofdm_cnt_mod4_end <= "00";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate),delay_offset_v'length);
            when "0101" =>   -- 5 us
              ofdm_cnt_mod4_end <= "01";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate),delay_offset_v'length);
            when "0110" =>   -- 6 us
              ofdm_cnt_mod4_end <= "10";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate),delay_offset_v'length);
            when "0111" =>   -- 7 us
              ofdm_cnt_mod4_end <= "11";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate),delay_offset_v'length);
            when "1000" =>   -- 8 us
              ofdm_cnt_mod4_end <= "00";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate) & '0',delay_offset_v'length);
            when "1001" =>   -- 9 us
              ofdm_cnt_mod4_end <= "01";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate) & '0',delay_offset_v'length);
            when "1010" =>   -- 10 us
              ofdm_cnt_mod4_end <= "10";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate) & '0',delay_offset_v'length);
            when "1011" =>   -- 11 us
              ofdm_cnt_mod4_end <= "11";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate) & '0',delay_offset_v'length);
            when "1100" =>   -- 12 us
              ofdm_cnt_mod4_end <= "00";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate) & "00",delay_offset_v'length);
            when "1101" =>   -- 13 us
              ofdm_cnt_mod4_end <= "01";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate) & "00",delay_offset_v'length);
            when "1110" =>   -- 14 us
              ofdm_cnt_mod4_end <= "10";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate) & "00",delay_offset_v'length);
            when "1111" =>   -- 15 us
              ofdm_cnt_mod4_end <= "11";
              delay_offset_v := ext(def_nb_bit_p_symb(rxv_datarate) & "00",delay_offset_v'length);
            when others =>
              null;
          end case;

          -- nb_bit_rest = (length * 8) + (service + tail bits(=22)) - delay_offset
          -- Number of bit in the burst, including D0
          nb_bit_v := ext(unsigned(rxv_length & "000") + unsigned(conv_std_logic_vector(22, 6)), nb_bit_v'length);
          if nb_bit_v > delay_offset_v then
            nb_bit_rest <= ext(unsigned(nb_bit_v) - unsigned(delay_offset_v), nb_bit_rest'length);
          else
            nb_bit_rest <= (others => '0');
          end if;
          -- Init counter
          ofdm_cnt_mod4 <= "11";
          
        end if;
      end if;
      
      -- OFDM PSDU calculation
      if ofdm_calculation = '1' and cca_dec_state /= START_RECEPTION_ST_CT then
        if top_1mhz = '1' then
          
          -- Stop CCA timer
          ofdm_stop_cca_timer <= '1';
          
          -- Decrement 4us counter
          ofdm_cnt_mod4 <= ofdm_cnt_mod4 - 1;
          
          if ofdm_cnt_mod4 = "00" then
            ofdm_cnt_mod4 <= "11";
            nb_bit_rest   <= nb_bit_rest - ext(def_nb_bit_p_symb(rxv_datarate_samp), nb_bit_rest'length);
          end if;
          
          if ext(nb_bit_rest, nb_bit_rest'length) < ext(def_nb_bit_p_symb(rxv_datarate_samp), nb_bit_rest'length) then
            -- End of calculation -> sent pulse to time-out
            if ofdm_cnt_mod4 = ofdm_cnt_mod4_end then
              ofdm_cnt_mod4_finish <= '1';
              ofdm_calculation     <= '0';
              ofdm_stop_cca_timer  <= '0';
            else
              nb_bit_rest <= (others => '0');
            end if;  
          end if;
          
        end if;
      end if;
      
      -- Clear calculation in case of packet error
      if phy_rxstartend_ind = '0' and phy_rxstartend_ind_ff1 = '1' and 
         cca_dec_state = START_RECEPTION_ST_CT then
        ofdm_calculation    <= '0';
        ofdm_stop_cca_timer <= '0';
        dcck_calculation    <= '0';
      end if;
      
    end if;
  end process pack_duration_est_p;
  
  
  ------------------------------------------
  -- CCA timer
  ------------------------------------------
  -- End of count interrupts stay HIGH till next load (excluded)
  timeout_it  <= timeout_it_i and not (load_timer);

  -- The CCA timer decrements every us when enabled. It is reloaded with a value
  -- depending on the CCA state.
  cca_timer_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      cca_timer      <= (others => '0');
      timeout_it_i   <= '0';
      
    elsif clk'event and clk = '1' then

      -- Reload timer with new value
      if load_timer = '1' then
        timeout_it_i   <= '0';

        case cca_dec_state is

          when RF_BIAS_SETTING_ST_CT =>
            cca_timer <= ext(reg_biasdel, cca_timer'length);

          when OFDM_SEARCH2_ST_CT =>
            cca_timer <= SYNC_TIMEOUT_CT;

          when WAIT_OFDM_HEADER_ST_CT =>
            cca_timer <= HEADER_TIMEOUT_CT;

          when DSSS_SEARCH_ST_CT =>
            cca_timer <= SFD_TIMEOUT_CT;

          when WAIT_PLCP_HEADER_ST_CT =>
            cca_timer <= PLCP_TIMEOUT_CT;

          when START_RECEPTION_ST_CT =>
            cca_timer <= RXEND_TIMEOUT_CT;

          when RX_MODEM_AGC_ST_CT | RX_MODEM_ONLY_ST_CT =>
            if dcck_calculation = '1' then
              cca_timer <= psdu_duration_samp;
            else
              cca_timer <= (others => '1');
            end if;

          when WAIT_RAMP_DOWN1_ST_CT | WAIT_RAMP_DOWN2_ST_CT =>
            cca_timer <= ext(reg_rampdown, cca_timer'length);

          when WAIT_RAMP_DOWN_RF_BIAS_ST_CT =>
            if reg_biasdel > reg_rampdown then
              cca_timer <= (others => '0');
            else 
              cca_timer <= ext(reg_rampdown-reg_biasdel, cca_timer'length);
            end if;

          when others =>
            null;
        end case;

      -- Decrement timer
      else
        -- Interrupt to state machines when timer reaches zero or 
        -- when OFDM calculation is over.
        if cca_timer = 0 or ofdm_cnt_mod4_finish = '1' then
          timeout_it_i <= '1';
        end if;
        
        if ((top_1mhz = '1') or (cca_dec_state = START_RECEPTION_ST_CT)) 
          and (ofdm_stop_cca_timer = '0') then -- Avoid time-out generation via cca_timer
          cca_timer <= cca_timer - 1;          -- during OFDM calculation sequence
        end if;

      end if;
      
    end if;
  end process cca_timer_p;
  

end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

