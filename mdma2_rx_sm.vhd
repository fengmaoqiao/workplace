--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 4919 $
--/ $Date: 2010-08-11 13:54:04 +0200 (Wed, 11 Aug 2010) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : State machine of the rx path.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/IPs/WLAN/HW/MODEM802_11a2/RX_TOP/mdma2_rx_sm/vhdl/rtl/mdma2_rx_sm.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library modem802_11a2_pkg;
use work.modem802_11a2_pack.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity mdma2_rx_sm is
  generic (
    -- time needed for the channel decoder to decode the 
    -- signal field from his input
    delay_chdec_sig_g   : integer := 105; 
    -- delay from CCA_flag_i(carry_lost) to intput of channel decoder 
    delay_datapath_g    : integer := 416; 
    -- worse case delay for the channel decoder
    worst_case_chdec_g  : integer := 150;
    -- radio type : 1 for RW_WLANRF, 0 for IFX
    radio_type_g        : integer := 1   
    );
  port (
    clk                       : in  std_logic;  -- Module clock
    reset_n                   : in  std_logic;  -- asynchronous reset
    mdma_sm_rst_n             : in  std_logic;  -- synchronous reset
    reset_dp_modules_n_o      : out std_logic;  -- `0': Reset data path modules.
    --
    calmode_i                 : in  std_logic;  -- IQ calibration mode.
    rx_start_end_ind_o        : out std_logic;  -- rising edge: PHY_RXSTART.ind
                                             -- falling edge: PHY_RXEND.ind
    tx_dac_on_i               : in  std_logic;  -- From TX
    rxactive_req_o            : out std_logic;  -- To RF Control
    rxactive_conf_i           : in  std_logic;  -- From RF Control
    rx_packet_end_o           : out std_logic;  -- pulse on end of RX packet
    enable_iq_estim_o         : out std_logic;  -- `1': enable iq estimation block.
    disable_output_iq_estim_o : out std_logic;  -- `1': disable iq estimation outputs.

    --------------------------------------------
    -- I/F to MAC
    --------------------------------------------
    rx_error_o             : out std_logic_vector(1 downto 0);  --RXERROR 
                                   -- vector is valid at     
                                   -- the falling edge of rx_start_end_ind_o.
                                   -- The coding is as follows:
                                   -- 0b00: No Error
                                   -- 0b01: Format Violation
                                   -- 0b10: Carrier lost
                                   -- 0b11: Unsupported rate
    rxv_length_o           : out std_logic_vector(11 downto 0);  -- RXVECTOR 
                                   -- length parameter is valid when
                                   -- rx_start_end_ind_o goes from 0 to 1.
    -- RXVECTOR rate parameter       
    rxv_rate_o             : out std_logic_vector(3 downto 0);
    rx_cca_ind_o           : out std_logic;  -- 0: IDLE 
                                             -- 1: BUSY 
    --
    rx_ccareset_req_i      : in  std_logic; -- CCA Reset
    rx_ccareset_confirm_o  : out std_logic;
    --------------------------------------------
    -- SIGNAL Field from channel decoder
    --------------------------------------------
    signal_field_unsup_rate_i   : in  std_logic;  -- 1: The rate computed in
                                        -- the signal field is not valid
    signal_field_unsup_length_i : in  std_logic;  -- 1: The length computed in
                                        -- the signal field is not valid
    -- This contains the RATE, LENGTH the reserved bit and the parity bit
    signal_field_i              : in  std_logic_vector(17 downto 0);
    signal_field_parity_error_i : in  std_logic;
    signal_field_valid_i        : in  std_logic;  -- 1: The signal field has 
                                        -- been decoded and the data is
                                        -- available. This signal is active
                                        -- for one cycle.
    --------------------------------------------
    -- End of channel decoder
    --------------------------------------------
    channel_decoder_end_i        : in std_logic;
    --------------------------------------------
    -- AGC/Power estimation blocks
    --------------------------------------------
    listen_start_o              : out std_logic;  -- high when start to listen
    rssi_abovethr_i             : in  std_logic;  -- RSSI above threshold
    rssi_enable_o               : out std_logic;  -- RSSI ADC Enable
    --------------------------------------------
    -- Preamble detection from Init sync
    --------------------------------------------
    -- Confirm preamble detection
    tdone_i                     : in std_logic;  
    --------------------------------------------
    -- I and Q ADCs control
    --------------------------------------------
    adc_powerdown_dyn_i         : in  std_logic;  -- From control regs
    adc_powctrl_o               : out std_logic_vector(1 downto 0);
    --------------------------------------------
    -- Internal state for debug
    --------------------------------------------
    rx_gsm_state_o              : out std_logic_vector(3 downto 0)
    
  );

end mdma2_rx_sm;


--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of mdma2_rx_sm is

  constant NB_CLK_PERIOD_CT : integer := 320 - 1;  -- nummber of clk
                                                -- periode in 4 us
                                                -- 4 us / 12.5 ns = 320

  -- Number of clk cycle between SIGNAL field detected and end of first data
  -- symbol at the output of decimation filter.
  constant NSIGNAL2DATA0END_CT : integer 
                         := 320*2 - (delay_datapath_g + delay_chdec_sig_g);
  -- I/Q ADC wake up time from sleep to on, in 80 MHz clock cycles.
  -- According to the mixed signal requirement.
  constant SLEEP2ON_CT : integer := 8;
  -- Delay of data path from RX input up to decimation filter output (i.e.
  -- initsync input). Used to delay the deassertion of initsync reset wrt data
  -- path reset. In number of 80 MHz cycles.
  constant INDATADELAY_CT : integer := 8*4;  -- 8 samples at 20 Msamples/s

  -- The iq_estim block is enabled just after the signal symbol.
  -- The reference time is taken from the tdone_i pulse,indicating that the sync
  -- has been found. We have thus to count until the end of CP1 + CP2 + signal,
  -- ie (64 + 64 + 80)*4 = 208*4 clock cycles. This value must be reduced due to
  -- internal delay.
  -- For number -4 comes from the delay of the iq_compensation.
  constant TIME_BEFORE_IQ_ESTIM_ENABLE_CT : integer := (208-4)*4-2; 

  -- This value indicates when the final sample is being received on the 
  -- modem input. It is based on the time_cnt counter during the last symbol.
  constant END_OF_RF_RX_CT : integer := 120; 

  type STATE_T is (TX, RESET, RX_IDLE, ADC_PU, WAIT_PREAMB, WAIT_SIG_F,
         WAIT_CCA_LOW, SIG_ERROR, IN_DATA, WAIT_WCASE_CHDEC, IQ_CALIB, INIT_RX);
  type ADC_MODE_T is (ADC_PD, ADC_ON, ADC_SLEEP);

  -- I and Q ADC mode
  signal adc_mode             : ADC_MODE_T;
  signal adc_mode_rs          : ADC_MODE_T;
  signal cur_state            : STATE_T;
  signal next_state           : STATE_T;
  signal adcoff               : std_logic;
  signal rx_error             : std_logic_vector(1 downto 0);
  signal rx_error_rs          : std_logic_vector(1 downto 0);
  signal rx_rate              : std_logic_vector(3 downto 0);
  signal rx_rate_rs           : std_logic_vector(3 downto 0);
  signal rx_length            : std_logic_vector(11 downto 0);
  signal rx_length_rs         : std_logic_vector(11 downto 0);
  signal rx_start_end_ind     : std_logic;
  signal rx_start_end_ind_rs  : std_logic;
  signal rx_start_end_ind_cnt : std_logic_vector(1 downto 0);
  -- Number of bit/symbol, computed once from SIGNAL FIELD (RATE)
  -- range from 24 to 216
  signal nb_bit_p_symb       : std_logic_vector(7 downto 0);
  signal nb_bit_p_symb_rs    : std_logic_vector(7 downto 0);
  -- Lenght of the burst in bit. Decremented every 4us by nb_bit_p_symb_rs
  -- The range is 0 to 4095*8
  signal length_burst        : std_logic_vector(14 downto 0);
  signal length_burst_rs     : std_logic_vector(14 downto 0);
  -- Counter used in different places. All the delays are calculated at the
  -- input of the channel decoder.
  -- During WAIT_SIG_F to calculate the time of the end of D0 at the output of
  -- the decimation filter.
  -- During IN_DATA to count the 4us (the count starts at the start of symbol
  -- at the input of channel decoder.
  -- During WAIT_WCASE_CHDEC to wait for the worst case delay of the channel
  -- decoder before indicating RXEND.
  signal time_cnt            : std_logic_vector(10 downto 0);
  signal time_cnt_rs         : std_logic_vector(10 downto 0);

  signal rx_cca_ind          : std_logic;
  -- Internal CCA Flag (contribution from state machine to PHY_CCA.ind)
  signal cca_flag            : std_logic;             
  signal cca_flag_rs         : std_logic;           
                                                            
  signal rssi_enable           : std_logic;
  signal reset_dp_modules_n    : std_logic;
  signal reset_dp_modules_n_rs : std_logic;

  signal enable_iq_estim_cnt_enable : std_logic;
  signal disable_output_iq_estim    : std_logic;
  signal enable_iq_estim_cnt        : std_logic_vector(9 downto 0);
  
  signal presumed_end_of_rx         : std_logic;
  
  signal rx_packet_end_d       : std_logic;
  signal rx_packet_end         : std_logic;
  signal listen_start_s        : std_logic;

  attribute mark_debug:string;
  attribute mark_debug of rx_start_end_ind:signal is "true";
  attribute mark_debug of rx_error:signal is "true";
  attribute mark_debug of cur_state:signal is "true";

  --------------------------------------------
  -- Function to calculate the number of bits per symbol for each RATE
  --------------------------------------------
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

begin

  rx_packet_end_o <= rx_packet_end;
  
  --------------------------------------------time_cnt
  -- Combinational part of state machine
  --------------------------------------------
  fsm_comb_p : process (reset_dp_modules_n_rs, 
                 tdone_i, tx_dac_on_i,
                 rx_ccareset_req_i, rssi_abovethr_i,
                 cur_state, rx_rate_rs, rx_length_rs,
                 signal_field_i, signal_field_unsup_rate_i, 
                 signal_field_unsup_length_i, signal_field_valid_i,     
                 nb_bit_p_symb_rs, rx_start_end_ind_rs, time_cnt_rs, 
                 length_burst_rs,
                 rx_error_rs, signal_field_parity_error_i, adc_mode_rs,
                 calmode_i,
                 presumed_end_of_rx,
                 rx_start_end_ind_cnt, channel_decoder_end_i)

  begin
    -- default values
    reset_dp_modules_n   <= reset_dp_modules_n_rs;
    rx_packet_end_d      <= '0';
    adc_mode             <= adc_mode_rs;
    rx_start_end_ind     <= rx_start_end_ind_rs;
    rx_error             <= rx_error_rs;
    rx_rate              <= rx_rate_rs;
    rx_length            <= rx_length_rs;
    nb_bit_p_symb        <= nb_bit_p_symb_rs;
    length_burst         <= length_burst_rs;
    time_cnt             <= time_cnt_rs;
    next_state           <= cur_state;
    rssi_enable          <= '1';
    cca_flag             <= '0';
    disable_output_iq_estim <= '0';

    -- if calibration is enabled
    if calmode_i='1' then
      next_state <= IQ_CALIB;
    else
      case cur_state is  
        
        --------------------------------------------
        -- I/Q calibration.
        -- We stay here until calmode_i = '0'
        --------------------------------------------
        when IQ_CALIB =>
          next_state <= RESET;
                 
        --------------------------------------------
        -- Reset state. Wait for a valid RSSI measurement.
        --------------------------------------------
        when RESET =>
          reset_dp_modules_n <= '0';
          rx_start_end_ind   <= '0';
          adc_mode           <= ADC_PD;
          if (radio_type_g = IFX_RF_CT) then
            if rssi_abovethr_i = '1' then
              time_cnt   <= conv_std_logic_vector(SLEEP2ON_CT, 11);    
              next_state <= ADC_PU;
            else
              next_state <= RX_IDLE;
            end if;
          elsif (radio_type_g = RW_WLAN_RF_CT) then
            next_state <= RX_IDLE;
          end if;

        --------------------------------------------
        -- Init Rx state. Reset Rx path before Tx state.
        --------------------------------------------
        when INIT_RX =>
          next_state <= TX;

        --------------------------------------------
        -- Transmit state. Wait for DAC off.
        --------------------------------------------
        when TX =>
          rx_start_end_ind <= '0';
          rssi_enable      <= '0';
          adc_mode         <= ADC_PD;
          if tx_dac_on_i = '0' then
            next_state <= RESET;
          end if;

        --------------------------------------------
        -- Wait for a valid and strong enough RSSI level
        --------------------------------------------
        when RX_IDLE =>
          reset_dp_modules_n <= '0';
          -- Redundant in most of the case except SIGNAL field errors
          rx_start_end_ind   <= '0';
          adc_mode           <= ADC_SLEEP;
          disable_output_iq_estim <= '0';
          -- goes to TX state when DAC are activated
          if tx_dac_on_i = '1' then
            next_state <= TX;
          else

            if rssi_abovethr_i = '1' then
              -- goes directly to WAIT_PREAMB when RSSI is good for RW_WLANRF radio
              -- no need of ADC_PU state due to ADC controlled by RF controller
              if (radio_type_g = RW_WLAN_RF_CT) then
                -- initialize the counter to ~16us for time out detection.
                time_cnt   <= conv_std_logic_vector(4*NB_CLK_PERIOD_CT, 11);
                next_state <= WAIT_PREAMB;
              else
                -- goes to ADC_PU when RSSI is good for IFX radio
                time_cnt   <= conv_std_logic_vector(SLEEP2ON_CT, 11);
                next_state <= ADC_PU;
              end if;
            end if;
          end if;

        --------------------------------------------
        -- Waiting for the ADC to power on from the sleep state, in order to
        -- avoid garbage values to feed the data path (especially initsync).
        -- Only with IFX radio, for RW_WLANRF, ADC are control by the RF controller
        --------------------------------------------
        when ADC_PU =>
          reset_dp_modules_n <= '0';
          adc_mode           <= ADC_ON;
          cca_flag           <= '1';
          if tx_dac_on_i = '1' then
            next_state <= TX;
          else
            if time_cnt_rs = 0 then
              next_state <= WAIT_PREAMB;
              -- initialize the counter to ~16us for time out detection.
              time_cnt   <= conv_std_logic_vector(4*NB_CLK_PERIOD_CT, 11);
            else
              time_cnt   <= time_cnt_rs - '1';
            end if;
          end if;

        --------------------------------------------
        -- Wait for preamble detection
        --------------------------------------------
        when WAIT_PREAMB =>
          reset_dp_modules_n <= '1';
          -- Redundant in most of the case except SIGNAL field errors
          rx_start_end_ind   <= '0';
          if rx_ccareset_req_i = '1' then
            rx_packet_end_d <= '1';
          else
           cca_flag <= '1';
           adc_mode <= ADC_ON;
            -- preamble detected
            if tdone_i = '1' then
              -- NOTE: this is NOT the same flag used for CCA, it is a
              -- successful preamble detection.
              next_state <= WAIT_SIG_F;
            end if;
            
            -- If the preamble is not detected after time out,
            -- come back to idle.
            time_cnt   <= time_cnt_rs - '1';
            if time_cnt_rs = 0 then
              next_state      <= RX_IDLE;
              rx_packet_end_d <= '1';
            end if;

            -- If AGC relaxs cca_busy to 0, come back to idle.
            if rssi_abovethr_i = '0' then
              next_state         <= RX_IDLE;
              reset_dp_modules_n <= '0';
            end if;

            -- If a transmission occurs, go to INIT_RX mode for reset rx path
            -- before going to TX mode.
            if tx_dac_on_i = '1' then
              next_state <= INIT_RX;
              reset_dp_modules_n <= '0';
            end if;
          end if;
               
        --------------------------------------------
        -- Receive the signal field
        --------------------------------------------
        when WAIT_SIG_F =>                    -- Wait for signal field
          if rx_ccareset_req_i = '1' then
            rx_packet_end_d <= '1';
          else
            cca_flag <= '1';
            --signal_field_i有效时说明SIG域的解算已完成，时间已到SIG的末尾，应转入data域
            if signal_field_valid_i = '1' then  -- signal field valid
              -- error in signal field
              if signal_field_parity_error_i = '1' or
                 signal_field_unsup_rate_i = '1'   or
                 signal_field_unsup_length_i = '1' then
                -- Rising edge in order to validate the RX error on the
                -- falling edge (in WAIT_PREAMB or in RX_IDLE)
                rx_start_end_ind   <= '1';
                reset_dp_modules_n <= '0';    -- reset data path
                -- No need to use the validation signal for RSSI here
                next_state <= SIG_ERROR;
                
              -- signal field ok
              else
                rx_error         <= "00";
                rx_rate          <= signal_field_i(3 downto 0);
                rx_length        <= signal_field_i(16 downto 5);
                rx_start_end_ind <= '1';
                nb_bit_p_symb    <= def_nb_bit_p_symb(signal_field_i(3 downto 0));
                -- length burst = service + length * 8 + tail bits
                -- Number of bit in the burst, including D0
                length_burst     <= EXT(signal_field_i(16 downto 5)&"000", length_burst'length) + 
                                    conv_std_logic_vector(22, length_burst'length);
                -- The reference (time_cnt) is moved to the output of the
                -- decimation filter (end of D0).
                time_cnt         <= conv_std_logic_vector(NSIGNAL2DATA0END_CT, 11);
                next_state       <= IN_DATA;
              end if;
            end if;
          end if;

          -- If AGC relaxs cca_busy to 0, come back to idle.
          if rssi_abovethr_i = '0' then
            next_state         <= RX_IDLE;
            reset_dp_modules_n <= '0';
          end if;

          -- If a transmission occurs, go to INIT_RX mode for reset rx path
          -- before going to TX mode.
          if tx_dac_on_i = '1' then
            next_state <= INIT_RX;
            reset_dp_modules_n <= '0';
          end if;

        --------------------------------------------
        -- On signal error, go to wait_cca_low before come back to idle.
        --------------------------------------------
        when SIG_ERROR =>
     
          -- Generate error
          if signal_field_parity_error_i = '1' or
             signal_field_unsup_rate_i   = '1' or
             signal_field_unsup_length_i = '1' then
             rx_error <= "01";
          end if;

          if rx_start_end_ind_cnt = "11" then -- rx_start_end_ind must have 3 clk activate for bup & cca
            rx_start_end_ind <= '0';
            next_state      <= WAIT_CCA_LOW;
            rx_packet_end_d <= '1';
          end if;

          -- Disable output of IQ estimation : allow not to give a false
          -- estimation to the next packet.
          disable_output_iq_estim <= '1';

        --------------------------------------------
        -- Receive the data
        --------------------------------------------
        when IN_DATA =>
           
          --final sample is being received on the modem input
          if (presumed_end_of_rx = '1') then
            adc_mode <= ADC_SLEEP;
          end if;

          -- From signal decoded, to the end of D(N-1)
          -- at the output of the decimation filter
          if rx_ccareset_req_i = '1' then
            rx_packet_end_d <= '1';
          else
            -- Carrier lost check
            cca_flag <= '1';
            -- We continue in the sequence even in the case of carrier lost to
            -- keep the CCA busy until the expected end of burst.
            if time_cnt_rs = 0 then         -- each 4 us
              time_cnt <= conv_std_logic_vector(NB_CLK_PERIOD_CT, 11);
              -- Check how many bits are left.
              -- Note : The number of total bits are never multiple of the
              -- number of bit per symbol, for every rate and number of bytes.
              -- Therefore the "<=" is not necessary, only "<".
              if length_burst_rs < EXT(nb_bit_p_symb_rs, length_burst_rs'length) then  -- last data symbol
                next_state   <= WAIT_WCASE_CHDEC;
                time_cnt     <= conv_std_logic_vector(delay_chdec_sig_g + worst_case_chdec_g, 11);
              else
                -- remove one symbol to length_burst
                length_burst <= length_burst_rs - EXT(nb_bit_p_symb_rs, length_burst'length);
              end if;
            else
              time_cnt <= time_cnt_rs - '1';
            end if;
          end if;

          -- If AGC relaxs cca_busy to 0, come back to idle.
          if rssi_abovethr_i = '0' then
            next_state         <= RX_IDLE;
            reset_dp_modules_n <= '0';
          end if;

          -- If a transmission occurs, go to INIT_RX mode for reset rx path
          -- before going to TX mode.
          if tx_dac_on_i = '1' then
            next_state <= INIT_RX;
            reset_dp_modules_n <= '0';
          end if;

        --------------------------------------------
        -- wait until channel decoder is finished (worse case)
        --------------------------------------------
        when WAIT_WCASE_CHDEC =>
          if rx_ccareset_req_i = '1' then
            rx_packet_end_d <= '1';
          else
            if channel_decoder_end_i = '1' then
              reset_dp_modules_n <= '0';  -- reset datapath when channel decoder
            end if;                       -- is finished
            if time_cnt_rs = 0 then 
               -- when channel decoder is finished
              rx_start_end_ind   <= '0'; -- indicate rx end
              reset_dp_modules_n <= '0'; -- reset datapath (initsync already reset).
              next_state         <= WAIT_CCA_LOW;
              rx_packet_end_d    <= '1';
            else
              time_cnt           <= time_cnt_rs - '1';
            end if;
          end if;

        --------------------------------------------
        -- wait until AGC force low rssi_abovethr_i
        --------------------------------------------
        when WAIT_CCA_LOW =>
          if (rssi_abovethr_i = '0') then
            next_state       <= RX_IDLE;
          end if;

        when others  =>
          null;
      
      end case;
    end if;
  end process fsm_comb_p;


  --------------------------------------------
  -- Sequential part of state machine
  --------------------------------------------
  fsm_seq_p : process (clk, reset_n)
  begin
    if reset_n = '0' then                 -- asynchronous reset (active low)
      cur_state                 <= RESET;
      adc_mode_rs               <= ADC_PD;
      rx_start_end_ind_rs       <= '0';
      rx_rate_rs                <= (others => '0');
      rx_length_rs              <= (others => '0');
      nb_bit_p_symb_rs          <= (others => '0');
      length_burst_rs           <= (others => '0');
      time_cnt_rs               <= (others => '0');
      cca_flag_rs               <= '0';
      rx_error_rs               <= (others => '0');
      rx_cca_ind_o              <= '0';
      rssi_enable_o             <= '0';
      reset_dp_modules_n_rs     <= '0';
      rx_packet_end             <= '0';
      disable_output_iq_estim_o <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if rx_ccareset_req_i = '1' or mdma_sm_rst_n = '0' then
        cur_state                 <= RESET;
        rx_start_end_ind_rs       <= '0';
        rx_rate_rs                <= (others => '0');
        rx_length_rs              <= (others => '0');
        nb_bit_p_symb_rs          <= (others => '0');
        length_burst_rs           <= (others => '0');
        time_cnt_rs               <= (others => '0');
        rx_error_rs               <= (others => '0');
        rx_cca_ind_o              <= '0';
        rssi_enable_o             <= '0';
        cca_flag_rs               <= '0';
        adc_mode_rs               <= ADC_PD;
        reset_dp_modules_n_rs     <= '0';
        rx_packet_end             <= '0';
        disable_output_iq_estim_o <= '0';
      else
        rx_start_end_ind_rs   <= rx_start_end_ind;
        cur_state             <= next_state;
        rx_rate_rs            <= rx_rate;
        rx_length_rs          <= rx_length;
        nb_bit_p_symb_rs      <= nb_bit_p_symb;
        length_burst_rs       <= length_burst;
        time_cnt_rs           <= time_cnt;
        rx_error_rs           <= rx_error;
        rx_cca_ind_o          <= rx_cca_ind;
        rssi_enable_o         <= rssi_enable;
        cca_flag_rs           <= cca_flag;
        adc_mode_rs           <= adc_mode;
        reset_dp_modules_n_rs <= reset_dp_modules_n;
        rx_packet_end         <= rx_packet_end_d;
        disable_output_iq_estim_o <= disable_output_iq_estim;
      end if;
    end if;
  end process fsm_seq_p;

  -- PHYCCA indication
  rx_cca_ind <= cca_flag_rs;

  -- Confirm of CCAReset
  ccarst_p : process(clk, reset_n)
  begin
    if reset_n = '0' then
      rx_ccareset_confirm_o <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if rx_ccareset_req_i = '1' then
        rx_ccareset_confirm_o <= '1';
      else
        rx_ccareset_confirm_o <= '0';
      end if;
    end if;
  end process ccarst_p;

  -- Keep rx_start_end_ind to 1 during 3 clk cycle when SIG_ERROR
  rx_start_end_ind_cnt_p : process(clk, reset_n)
  begin
    if reset_n = '0' then
      rx_start_end_ind_cnt <= "00";
    elsif clk'event and clk = '1' then  -- rising clock edge
      if rx_start_end_ind_cnt = "00" and signal_field_valid_i = '1' then
        rx_start_end_ind_cnt <= "01";
      elsif rx_start_end_ind_cnt = "01" then
        rx_start_end_ind_cnt <= "10";
      elsif rx_start_end_ind_cnt = "10" then
        rx_start_end_ind_cnt <= "11";
      else
        rx_start_end_ind_cnt <= "00";
      end if;
    end if;
  end process rx_start_end_ind_cnt_p;
  
  rxv_length_o       <= rx_length_rs;
  rxv_rate_o         <= rx_rate_rs;
  rx_start_end_ind_o <= rx_start_end_ind_rs;
  rx_error_o         <= rx_error_rs;

  --------------------------------------------
  -- Reset all the modules
  --------------------------------------------
  reset_dp_modules_n_o <= reset_dp_modules_n_rs;   
  
  --------------------------------------------
  -- enable iq estimation module
  --------------------------------------------
  iq_estim_enable_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      presumed_end_of_rx         <= '0';
      enable_iq_estim_o          <= '0';
      enable_iq_estim_cnt_enable <= '0';
      enable_iq_estim_cnt        <= (others => '0');
    elsif (clk'event and clk = '1') then
      if mdma_sm_rst_n = '0' then
        presumed_end_of_rx         <= '0';
        enable_iq_estim_o          <= '0';
        enable_iq_estim_cnt_enable <= '0';
        enable_iq_estim_cnt        <= (others => '0');
      else
      
        if (length_burst < EXT(nb_bit_p_symb, length_burst'length)) and
           (time_cnt = conv_std_logic_vector(END_OF_RF_RX_CT, 11)) then
          -- final sample should be received on the modem input.
          presumed_end_of_rx <= '1';
        else
          presumed_end_of_rx <= '0';
        end if;
        if ((cur_state = IN_DATA) and (presumed_end_of_rx = '1')) or
             cur_state = SIG_ERROR then
          enable_iq_estim_o          <= '0';
          enable_iq_estim_cnt_enable <= '0';
          enable_iq_estim_cnt        <= (others => '0');
        end if;
      
        if (tdone_i = '1') then
          enable_iq_estim_cnt_enable <= '1';
        end if;
      
        if (enable_iq_estim_cnt_enable = '1') then
          enable_iq_estim_cnt <= enable_iq_estim_cnt + '1';
        end if;
      
        if (enable_iq_estim_cnt = TIME_BEFORE_IQ_ESTIM_ENABLE_CT) then
          enable_iq_estim_o          <= '1';
          enable_iq_estim_cnt_enable <= '0';
          enable_iq_estim_cnt        <= (others => '0');
        end if;

      end if;
    end if;
  end process iq_estim_enable_p;


  -- purpose: Decoding of ADC modes
  -- type   : combinational
  -- inputs : adc_mode_rs
  -- outputs: adc_powctrl_o
  adc_p : process (adc_mode_rs, adc_powerdown_dyn_i)
  begin
    if adc_powerdown_dyn_i = '1' then
      adc_powctrl_o  <= "10";
      rxactive_req_o <= '1';
      adcoff         <= '1';
    else
      case adc_mode_rs is
        when ADC_PD =>
          adc_powctrl_o  <= "00";
          rxactive_req_o <= '0';
          adcoff         <= '1';          
        when ADC_ON =>
          adc_powctrl_o  <= "10";
          rxactive_req_o <= '1';
          adcoff         <= '0';     
        when ADC_SLEEP =>
          adc_powctrl_o  <= "11";
          if (radio_type_g = RW_WLAN_RF_CT) then
            rxactive_req_o <= '1';
          else
            rxactive_req_o <= '0';
          end if;
          adcoff         <= '1';
        when others =>
          adc_powctrl_o  <= "00";
          rxactive_req_o <= '0';
          adcoff         <= '1';
      end case;
    end if;
  end process adc_p;


  -- purpose: Decoding of internal state for debug
  -- type   : combinational
  -- inputs : cur_state
  -- outputs: rx_gsm_state
  rxstate_p: process (cur_state)
  begin
    case cur_state is
      when RESET            => 
        rx_gsm_state_o <= "0000";
      when TX               => 
        rx_gsm_state_o <= "0001";
      when RX_IDLE          => 
        rx_gsm_state_o <= "0010";
      when WAIT_PREAMB      => 
        rx_gsm_state_o <= "0011";
      when WAIT_SIG_F       => 
        rx_gsm_state_o <= "0100";
      when SIG_ERROR        => 
        rx_gsm_state_o <= "0111";
      when IN_DATA          => 
        rx_gsm_state_o <= "0101";
      when WAIT_WCASE_CHDEC => 
        rx_gsm_state_o <= "0110";
      when ADC_PU           => 
        rx_gsm_state_o <= "1000";
      when INIT_RX          => 
        rx_gsm_state_o <= "1001";
      when WAIT_CCA_LOW     => 
        rx_gsm_state_o <= "1010";
      when others           => 
        rx_gsm_state_o <= "1111";
    end case;
  end process rxstate_p;

  --------------------------------------------
  -- Listen_start generation
  --------------------------------------------
  listen_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      listen_start_s <= '1';
    elsif (clk'event and clk = '1') then
      if (rx_ccareset_req_i = '0') then
        case next_state is
          when RESET | SIG_ERROR =>
            listen_start_s <= '1';
            
          when RX_IDLE =>
            if (cur_state /= RX_IDLE) then
              listen_start_s <= '1';
            else
              listen_start_s <= '0';
            end if;

          when WAIT_WCASE_CHDEC =>
            if (time_cnt_rs = 0) and (cur_state = WAIT_WCASE_CHDEC)  then       -- when channel decoder is finished
              listen_start_s <= '1';
              if (rssi_abovethr_i = '0') then
                listen_start_s <= '0';
              end if;
            else
              listen_start_s <= '0';
            end if;

          when others =>
            listen_start_s <= '0';
            
        end case;
        if (cur_state = RESET) then
          listen_start_s <= '1';
        end if;
      else
        listen_start_s <= '0';
      end if;
    end if;
  end process listen_p;
  listen_start_o <= listen_start_s;
  
end rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
