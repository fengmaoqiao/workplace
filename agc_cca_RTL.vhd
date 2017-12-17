
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: agc_cca.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.17   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Automatic gain control and Clear Channel Assessment
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/agc_cca/vhdl/rtl/agc_cca.vhd,v  
--  Log: agc_cca.vhd,v  
-- Revision 1.17  2003/03/07 16:24:38  Dr.C
-- Debugged case: RSSI null.
--
-- Revision 1.16  2003/02/13 07:50:08  Dr.C
-- Added adcpdmod
--
-- Revision 1.15  2003/02/11 19:20:18  Dr.C
-- Added diag port
--
-- Revision 1.14  2003/02/03 08:28:27  Dr.J
-- Changed value of RSSI for saturation
--
-- Revision 1.13  2003/01/20 11:36:33  Dr.C
-- Debugged transition TX/RX and added disable input for radio prog.
--
-- Revision 1.12  2003/01/09 15:29:18  Dr.C
-- Updated to new procedure
--
-- Revision 1.11  2002/12/03 13:23:26  Dr.C
-- Increased packet_length size.
--
-- Revision 1.10  2002/11/28 10:24:06  Dr.C
-- Aded plcp_error port and changed ADCs enable
--
-- Revision 1.9  2002/11/20 13:22:45  Dr.C
-- Changed CCA busy gen. and packet timer reset
--
-- Revision 1.8  2002/11/07 16:25:36  Dr.C
-- Added accoup input and cleaned code
--
-- Revision 1.7  2002/10/31 16:15:03  Dr.C
-- Updated power estimation size
--
-- Revision 1.6  2002/10/25 17:02:43  Dr.C
-- Updated to spec version 0.15
--
-- Revision 1.5  2002/09/13 14:51:26  Dr.C
-- Changed cs_stat generation
--
-- Revision 1.4  2002/09/09 14:26:31  Dr.C
-- Updated to detection protocol
--
-- Revision 1.3  2002/07/31 08:15:43  Dr.C
-- Changed vectors size and removec correlator enable.
--
-- Revision 1.2  2002/07/11 13:26:33  Dr.C
-- Debugged timers
--
-- Revision 1.1  2002/06/26 16:37:05  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library agc_cca_rtl;
library work;
--use agc_cca_rtl.agc_cca_pkg.all;
use work.agc_cca_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity agc_cca is
  generic (
    m_size_g : integer := 4);           -- Size of I and Q
  port (
    -----------------------
    -- clock and reset
    -----------------------
    clk             : in  std_logic;    -- System clock
    reset_n         : in  std_logic;
    -----------------------
    -- Bup
    -----------------------
    bup_rst_req     : in  std_logic;    -- CCA state machine reset request
    bup_rst_conf    : out std_logic;    -- CCA state machine reset done
    -----------------------
    -- radio
    -----------------------
    rf_rssi            : in  std_logic_vector(6 downto 0);   -- signal strength
    -- 
    rf_antswitch       : out std_logic;    -- antenna switch 
    -----------------------
    -- Radio controller
    -----------------------
    rf_pgc             : out std_logic_vector(6 downto 0);   -- gain 
    rf_cmd_req         : out std_logic;    -- Radio prog. request
    rf_lna             : out std_logic;    -- Switch on/off LNA
    rf_accoup          : out std_logic;    -- AC coupling
    -----------------------
    -- Power estimation
    -----------------------
    power_estim     : in  std_logic_vector(20 downto 0);
                                        -- Power estimation
    -- 
    power_estim_en  : out std_logic;    -- Enable the power estim block
    integration_end : out std_logic;    -- Indicates end of integration
    -----------------------
    -- State machine
    -----------------------
    modem_transmit  : in  std_logic;    -- Modem transmitting
    packet_length   : in  std_logic_vector(15 downto 0);  -- Packet length
    correct_header  : in  std_logic;
    plcp_state      : in  std_logic;    -- Currently plagc_cca.vhdcp part in packet
    plcp_error      : in  std_logic;    -- Error occured during reception
    rxv_rssi        : out std_logic_vector(7 downto 0);
    agcproc_end     : out std_logic;    -- AGC procedure ended

    -----------------------
    -- Registers
    -----------------------
    radioprog_disb : in  std_logic;     -- Disable radio programming
    adcpdmod       : in  std_logic;     -- Force ADCs to be always powered on
    antmod         : in  std_logic_vector(1 downto 0);  -- Antenna diversity
    antsel         : in  std_logic;           -- Select antenna when only antenna
    cca_mode       : in  std_logic_vector(2 downto 0);  -- CCA mode
    ed_thres       : in  std_logic_vector(6 downto 0);  -- Energy detection
                                                  --            threshold
    sq_thres       : in  std_logic_vector(4 downto 0);
    delpgc1        : in  std_logic_vector(4 downto 0);  -- Delays for AGC
    delpgc0        : in  std_logic_vector(3 downto 0);  -- state
    deldet         : in  std_logic_vector(3 downto 0);
    delrssi        : in  std_logic_vector(3 downto 0);
    delant         : in  std_logic_vector(3 downto 0);
    delrssirip     : in  std_logic_vector(2 downto 0);
    rssislope      : in  std_logic_vector(11 downto 0); -- Slope for RSSIrconversion
                   -- 1 bit for sign, 1 for whole part and the rest for mantissa
                                           -- to IC input level
    rssi_offset    : in  std_logic_vector(7 downto 0); -- Offset for RSSI conversion
                                         -- to IC input level
    accoup         : in  std_logic_vector(4 downto 0);  -- ac coupling filter gain
                                                     --     compensation
    kil            : in  std_logic_vector(3 downto 0);  -- offset for rssi to IL
                                                     -- conversion
    kilp           : in  std_logic_vector(3 downto 0);  -- offset for power estim
                                                     --  to IL conversion
    rssirip        : in  std_logic_vector(2 downto 0);  -- Margin to detect plateau
    ilramp1        : in  std_logic_vector(2 downto 0);  -- Margin to detect ramp up
    ilramp2        : in  std_logic_vector(3 downto 0);  -- Margin to detect ramp up
    
    
    --
    cca_busy       : out std_logic;           -- CCA busy
    ed_stat        : out std_logic;           -- Signal energy status
    cs_stat        : out std_logic;           -- Carrier sense status

    -----------------------
    -- SFD comparator
    -----------------------
    sfd_detected : in std_logic;        -- SFD field detected

    -----------------------
    -- Correlator
    -----------------------
    symbol_sync  : in  std_logic;       -- Synchronisation of incoming symbol
    correl_rst_n : out std_logic;       -- Correlator reset
    
    -----------------------
    -- Peak detector
    -----------------------
    signal_quality  : in std_logic_vector(24 downto 0);

    -----------------------
    -- ADCs
    -----------------------
    rf_rssiadc_en : out std_logic;         -- RSSI ADC enable
    rf_adc_en     : out std_logic_vector(1 downto 0); -- I & Q ADCs enable

    -- Misc
    diag_port : out std_logic_vector(15 downto 0)
    );

end agc_cca;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of agc_cca is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant RSSI_SAT_CT : std_logic_vector(6 downto 0) := "1111100";
  constant NULL_CT     : std_logic_vector(6 downto 0) := (others => '0');
  -- RSSI saturated 
  constant ONEUS_CT   : std_logic_vector(5 downto 0) := "101100";
  constant TWOUS_CT   : std_logic_vector(6 downto 0) := "1010111";                                                                   
  constant FOURUS_CT  : std_logic_vector(8 downto 0) := "010101111";
  constant SIXUS_CT   : std_logic_vector(8 downto 0) := "100000111";
  
  constant CCK_MAX_CT : std_logic_vector(15 downto 0) :=  "0000111001000010";
                                                                    -- CCK packet max length

  constant SFD_DETECTION_CT : std_logic_vector(15 downto 0) := "0000000010000001";
                                                -- Time to SFD
  constant MINUS45_CT : std_logic_vector(7 downto 0) := "11010011";
  constant MINUS40_CT : std_logic_vector(7 downto 0) := "11011000";

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type AGC_STATE_TYPE is (init_gainsett_state,
                          first_il_state,
                          scd_il_state,
                          store_il1_state,
                          store_il2_state,
                          corrgain_state,
                          monitoring_state,
                          rssiplat_state,
                          rssimeas_scdant_state,
                          rssisaturated_state,
                          coarse_gainsett_state,
                          powerestim_bestantenna_state,
                          rssi_scdant_scd_state,
                          nosig_state,
                          firstant_saturated_state,
                          interm_gainsett_state,
                          powerestim_worseantenna_state,
                          fine_gainsett_state,
                          receiving_state
                          );

  type IL_TYPE is array(1 downto 0) of std_logic_vector(7 downto 0);
  type RSSIDB_TYPE is array(1 downto 0) of std_logic_vector(8 downto 0);
  
  -- Store the rssimeasures

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- State machine
  signal agc_state      : AGC_STATE_TYPE;  -- AGC state
  signal agc_next_state : AGC_STATE_TYPE;  -- AGC next state

  -- Outputs for registers
  signal ed_stat_o      : std_logic;    -- Energy detect status
  signal cca_busy_o     : std_logic;    -- CCA busy
  signal cca_busy_ff1   : std_logic;    -- CCA busy
  signal cca_busy_timer : std_logic;    -- CCA busy of packet timer
  signal cs_stat_o      : std_logic;     -- Carrier sense
  signal sq_threshold   : std_logic_vector(25 downto 0);  -- Signal quality threshold
                         -- Conversion of sq_thres register into threshold value

  -- Counters
  signal state_end         : std_logic;  -- Indicates end of current state
  signal state_end_ff1     : std_logic;  -- Indicates end of current state
  signal state_counter_max : std_logic_vector(9 downto 0);  -- State counter max
  signal state_counter     : std_logic_vector(9 downto 0);  -- State counter 
  signal packet_timer      : std_logic_vector(15 downto 0); -- Packet timer
  signal gain_counter      : std_logic_vector(3 downto 0);  -- Timer for gain
                                                            --   compensation
  signal timer_max         : std_logic_vector(15 downto 0);  -- Timer max value
  signal packet_end        : std_logic;  -- End of received packet
  signal rssi_counter      : std_logic_vector(3 downto 0);  -- RSSI enable counter
  signal one_us_counter    : std_logic_vector(5 downto 0);  -- One us counter
  
  -- CCA procedure
  signal ant1sat      : std_logic;  -- The first antenna measure was saturated
  signal skiprssimeas : std_logic;      -- Skip the second RSSI measure
  signal radioprog    : std_logic;      -- Radio programmed after reset
  signal firstantenna : std_logic;      -- Antenna where the signal
                                        --            was first detected

  -- Radio controller
  signal rf_cmd_req_o   : std_logic;             -- Request to radio controller
  signal rf_lna_o       : std_logic;             -- RF_LNA switch
  signal pgc_o          : std_logic_vector(7 downto 0);  -- PGC
  signal rf_antswitch_o : std_logic;   -- Antenna switch

  -- Gain computation
  signal rssi_icinput      : std_logic_vector(7 downto 0);  -- IC input
  signal rssi_icinput_pgc  : std_logic_vector(7 downto 0);  -- IC input
  signal best_rssi_ic      : std_logic_vector(7 downto 0);
  signal rssi_db           : std_logic_vector(8 downto 0);
  signal rssi_mul          : std_logic_vector(18 downto 0);
  signal best_rssi         : std_logic_vector(8 downto 0);  -- Best rssi measure 
  signal rssi_db_off       : std_logic_vector(8 downto 0);  -- RSSI_DB + kil
  signal rssi_db_off_pgc   : std_logic_vector(8 downto 0);  -- RSSI_DB + kil
  signal rssimeas          : RSSIDB_TYPE;  -- Store RSSI measures
  signal pwr_estim_icinput : std_logic_vector(7 downto 0);  -- IC input
                                           -- computed with power estimation
  signal best_pwr_estim_icinput: std_logic_vector(7 downto 0);
  signal power_estim_best  : std_logic_vector(7 downto 0);  -- Power estimation
                                                            -- on best antenna
  signal lna_best : std_logic;  -- Keep lna for best antenna
  signal lna_ic   : std_logic_vector(7 downto 0);  -- LNA value in dB for last
                                                   -- radio programming
  signal logstart : std_logic;          -- Trigger log computation

  signal lna_vect : std_logic_vector(7 downto 0);  -- LNA value in dB
  signal pgc1     : std_logic_vector(7 downto 0);  -- PGC 1
  signal icinput  : std_logic_vector(7 downto 0);  -- IC input
  signal first_power_estim : std_logic_vector(20 downto 0);
  signal final_power_estim : std_logic_vector(20 downto 0);
  signal power_estim_int : std_logic_vector(20 downto 0);

  -- References at the beginning of AGC procedure
  signal il_meas  : IL_TYPE;  -- IC input
  signal il_ref   : IL_TYPE;  -- IC input
  signal rssiplateau_reached : std_logic;  -- RSSI plateau has been reached
  signal rssi_db_dif : std_logic_vector(8 downto 0);
  signal rampup      : std_logic;           -- Ramp up detected
  signal rampdown    : std_logic;           -- Ramp up detected
  signal max_il      : std_logic_vector(7 downto 0);  -- Max input level 
  signal max_il_ref  : std_logic_vector(7 downto 0);  -- Max input level ref
  signal il_dif      : std_logic_vector(7 downto 0);  -- Input level difference
  
  -- outputs
  signal integration_end_o : std_logic;
  signal power_estim_en_o  : std_logic;

  signal bup_rst_req_ff1   : std_logic; 
  signal modem_transmit_ff1   : std_logic;

  -- Diag port
  signal state_diag : std_logic_vector(4 downto 0);  -- AGC state for diag
  
begin


  -----------------------------------------------------------------------------
  -- 
  -- State machine
  -- 
  -----------------------------------------------------------------------------
  agc_next_state_p : process (agc_state, ant1sat, antmod, cca_busy_o, ed_thres,
                              modem_transmit, rampdown, rampup, rf_rssi,
                              rssiplateau_reached, signal_quality,
                              skiprssimeas, sq_threshold, state_end,
                              state_end_ff1)
  begin
    case agc_state is

      ------------------------------------------------------
      -- Initial gain setting state:                                        
      -- Program the radio with initial values
      ------------------------------------------------------
      when init_gainsett_state =>
        if state_end = '1' then
          agc_next_state <= first_il_state;
        else
          agc_next_state <= init_gainsett_state;
        end if;

      ------------------------------------------------------
      -- Take input level on first antenna:    
      -- Store the first input level value
      ------------------------------------------------------
      when first_il_state =>
        if state_end = '1' and antmod = "10" then
          agc_next_state <= scd_il_state;
        elsif  state_end = '1' then
          agc_next_state <= corrgain_state;
        else
          agc_next_state <= first_il_state;
        end if;

      ------------------------------------------------------
      -- Take input level on second antenna:    
      -- Store the first input level value
      ------------------------------------------------------
      when scd_il_state =>
        if state_end = '1'  then
          agc_next_state <= corrgain_state;
        else
          agc_next_state <= scd_il_state;
        end if;

      ------------------------------------------------------
      -- Program radio with new settings:    
      -- 
      ------------------------------------------------------
      when corrgain_state =>
        if state_end = '1'  then
          agc_next_state <= store_il1_state;
        else
          agc_next_state <= corrgain_state;
        end if;
        
      ------------------------------------------------------
      -- Take input level on second antenna:    
      -- Store the first input level value
      ------------------------------------------------------
      when store_il1_state =>
        if state_end = '1' and antmod = "10"  then
          agc_next_state <= store_il2_state;
        elsif state_end = '1' then
          agc_next_state <= monitoring_state;
        else
          agc_next_state <= store_il1_state;
        end if;

      ------------------------------------------------------
      -- Take input level on second antenna:    
      -- Store the first input level value
      ------------------------------------------------------
      when store_il2_state =>
        if state_end = '1'  then
          agc_next_state <= monitoring_state;
        else
          agc_next_state <= store_il2_state;
        end if;
        

      ------------------------------------------------------
      -- Monitoring state:                                        
      -- Switch between the 2 antennas to detect a frame    
      ------------------------------------------------------
      when monitoring_state =>
        if rf_rssi > ed_thres and state_end = '1' and
          modem_transmit = '0' and rampup = '1' then
          agc_next_state <= rssiplat_state;
        elsif state_end = '1' and
             (rampdown = '1' or  modem_transmit = '1') then
          agc_next_state <= init_gainsett_state;
        else
          agc_next_state <= monitoring_state;
        end if;
        
      ------------------------------------------------------
      -- RSSI plateau:
      -- Wait until RSSI plateau has been reached
      ------------------------------------------------------               
      when rssiplat_state =>
        if state_end = '1' and rssiplateau_reached = '1' then
          if rf_rssi >= RSSI_SAT_CT  then
            agc_next_state <= rssisaturated_state;
          elsif antmod = "10" then            
            agc_next_state <= rssimeas_scdant_state;
          else
            agc_next_state <= coarse_gainsett_state;
          end if;
        else
          agc_next_state <= rssiplat_state;
        end if;

        
      ------------------------------------------------------
      -- Measure RSSI on 2nd antenna
      ------------------------------------------------------               
      when rssimeas_scdant_state =>
        if state_end = '1' and rf_rssi >= RSSI_SAT_CT then
          agc_next_state <= rssisaturated_state;
        elsif state_end = '1' then
          agc_next_state <= coarse_gainsett_state;
        else
          agc_next_state <= rssimeas_scdant_state;
        end if;

      ------------------------------------------------------
      -- RSSI saturated:
      -- New measure is done after having reprogrammed the
      -- radio.
      ------------------------------------------------------               
      when rssisaturated_state =>
        if state_end = '1' then
          agc_next_state <= coarse_gainsett_state;
        else
          agc_next_state <= rssisaturated_state;
        end if;

      ------------------------------------------------------
      -- Coarse gain setting with best antenna
      ------------------------------------------------------               
      when coarse_gainsett_state =>
        if state_end = '1' then
          agc_next_state <= powerestim_bestantenna_state;
        else
          agc_next_state <= coarse_gainsett_state;
        end if;

        ------------------------------------------------------
        -- Power estimation with best antenna
        ------------------------------------------------------               
      when powerestim_bestantenna_state =>

        if state_end = '1' and
          signal_quality < ("0000000" & sq_threshold(25 downto 10))  then
          if antmod = "10" then
          -- No carrier sense, return to reference storage
            agc_next_state <= corrgain_state;
          else
            agc_next_state <= init_gainsett_state;
          end if;
        elsif state_end = '1' and
                    ((skiprssimeas = '1' and ant1sat = '0' and antmod = "10") or
                     (antmod = "00")) then
          -- RSSI(C) >> RSSI(D)
          agc_next_state <= fine_gainsett_state;
        elsif state_end = '1' then
          agc_next_state <= rssi_scdant_scd_state;
        elsif rampup = '1' and state_end_ff1 = '0' then
          -- Ramp up detected -> back to rssi plateau
          agc_next_state <= rssiplat_state;                    
        else
          agc_next_state <= powerestim_bestantenna_state;
        end if;

      ------------------------------------------------------
      -- Measure RSSI on second antenna
      ------------------------------------------------------               
      when rssi_scdant_scd_state =>
        if state_end = '1' and rf_rssi >= RSSI_SAT_CT then 
          agc_next_state <= firstant_saturated_state;
        elsif state_end = '1' and rf_rssi = NULL_CT then
           agc_next_state <= nosig_state; 
        elsif state_end = '1' then
          agc_next_state <=  interm_gainsett_state;
        else
          agc_next_state <= rssi_scdant_scd_state;
        end if;
        
        ------------------------------------------------------
        -- First RSSI measure saturated:
        -- A new measure is computed.
        ------------------------------------------------------               
      when firstant_saturated_state =>
        if state_end = '1' then
          agc_next_state <= interm_gainsett_state;
        else
          agc_next_state <= firstant_saturated_state;
        end if;

      ------------------------------------------------------
      -- No signal on antenna
      ------------------------------------------------------               
      when nosig_state =>
        if state_end = '1' then
          agc_next_state <= interm_gainsett_state;
        else
          agc_next_state <= nosig_state;
        end if;

        ------------------------------------------------------
        -- Intermediate gain setting state:                                         
        ------------------------------------------------------               
      when interm_gainsett_state =>
        if state_end = '1' then
          agc_next_state <= powerestim_worseantenna_state;
        else
          agc_next_state <= interm_gainsett_state;
        end if;


        ------------------------------------------------------
        -- Precise power estimation state                                        
        ------------------------------------------------------                 
      when powerestim_worseantenna_state =>
        if state_end = '1' then
          agc_next_state <= fine_gainsett_state;
        else
          agc_next_state <= powerestim_worseantenna_state;
        end if;

        ------------------------------------------------------
        -- Precise power estimation state                                        
        ------------------------------------------------------                 
      when fine_gainsett_state =>
        if state_end = '1' then
          agc_next_state <= receiving_state;
        else
          agc_next_state <= fine_gainsett_state;
        end if;

        ------------------------------------------------------
        -- Receiving a frame                               
        ------------------------------------------------------                         
      when receiving_state =>
        if state_end = '1' and cca_busy_o = '0' then
          agc_next_state <= init_gainsett_state;
        else
          agc_next_state <= receiving_state;
        end if;

      when others =>
        agc_next_state <= init_gainsett_state;
        
    end case;      
  end process agc_next_state_p;

  agc_state_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      agc_state <= init_gainsett_state;
    elsif clk'event and clk = '1' then
      if bup_rst_req = '1' or
        (modem_transmit = '0' and modem_transmit_ff1 = '1') then
        -- On reset generated by bup and end of transmission
        -- AGC state machine returns to idle state
        agc_state <= init_gainsett_state;
      else
        agc_state <= agc_next_state;
      end if;
    end if;
  end process agc_state_p;


  -----------------------------------------------------------------------------
  -- Radio controller 
  -----------------------------------------------------------------------------
  radioctrl_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      radioprog  <= '0';
      rf_cmd_req_o <= '0';
      pgc_o      <= (others => '0');
      rf_lna_o   <= '0';
    elsif clk'event and clk = '1' then
      radioprog <= '1';
      if modem_transmit = '1' or bup_rst_req = '1' or radioprog_disb = '1' then
        -- Nothing is transmitted to the radio when 
        --    *   Radio programming is disabled
        --    *   Modem is transmitting
        rf_cmd_req_o <= '0';
        pgc_o      <= (others => '0');
        rf_lna_o   <= '0';
      elsif radioprog = '0' or  (bup_rst_req = '0' and bup_rst_req_ff1 = '1' ) or
        (modem_transmit_ff1 = '1' and modem_transmit = '0' ) or
        (state_end = '1' and rampdown = '1' and agc_state = monitoring_state) or
        (state_end = '1' and agc_state = rssi_scdant_scd_state and
          rf_rssi = NULL_CT) or
        (state_end = '1' and cca_busy_o = '0' and agc_state = receiving_state) then
        -- Initial radio programming when *  power up
        --                                *  bup reset
        --                                *  modem transmission stops
        rf_cmd_req_o <= '1';
        pgc_o      <= "00110010"; -- 50 dB
        rf_lna_o   <= '1';
      elsif state_end = '1' and
            ((rf_rssi >= RSSI_SAT_CT and (agc_state = rssimeas_scdant_state or
                                    agc_state = rssi_scdant_scd_state or     
                (agc_state = rssiplat_state and rssiplateau_reached = '1' ))))
      then
        -- RSSI saturated 
        rf_cmd_req_o <= '1';
        pgc_o    <= (others => '0'); --0dB
        rf_lna_o <= '0';
      elsif state_end = '1' and
            (agc_state = scd_il_state or
            (agc_state = first_il_state and antmod /= "10") or 
            (agc_state = powerestim_bestantenna_state and
             signal_quality < ("0000000" & sq_threshold(25 downto 10)))) then
        -- After first references
        rf_cmd_req_o <= '1';
        if signed(max_il) < signed(MINUS45_CT) then
          rf_lna_o <= '1';
          pgc_o      <= "00110010"; -- 50 dB
        elsif signed(max_il) >= signed(MINUS40_CT) then  -- Max > -40
          rf_lna_o <= '0';
          pgc_o    <= (others => '0'); -- 0 dB
        else
          rf_lna_o <= '0';
          pgc_o    <=  "00001000"; -- 8 dB           
        end if;
      elsif state_end = '1' and
        (
          (agc_state = rssiplat_state and antmod /= "10"  and 
                    rssiplateau_reached = '1' and rf_rssi < RSSI_SAT_CT) or
           agc_state = rssisaturated_state or
           (agc_state = rssimeas_scdant_state and rf_rssi < RSSI_SAT_CT) or
           agc_state = firstant_saturated_state or
           agc_state = nosig_state or
           agc_state = rssi_scdant_scd_state or
           agc_state = powerestim_worseantenna_state or
           (agc_state = powerestim_bestantenna_state  and 
                                     (antmod = "00" or skiprssimeas = '1'))
        )
         then
        -- * Program the RF according to RSSI (C)
        -- * Program the RF according to RSSI(D)
        -- * Program RF according to the best value of power estimation
        rf_cmd_req_o <= '1';

        -- RF_LNA
        if signed(icinput) > -5 then
          rf_lna_o <= '0';
          pgc_o    <= "11111101";
         
        elsif  agc_state = powerestim_worseantenna_state or
              (agc_state = powerestim_bestantenna_state  and antmod = "00") or
              (agc_state = powerestim_bestantenna_state and skiprssimeas = '1') then
          -- For the last radio programming, the lna value is not changed
          -- pgc is determined according to icinput and lna
          pgc_o    <= not (icinput + lna_ic + 3) + '1';
          if lna_ic = "00100000" then
            rf_lna_o <= '1'; 
          else
            rf_lna_o <= '0'; 
          end if;
        elsif icinput>= "10101101"  and icinput <= "11011111" then
          rf_lna_o <= '1';
          pgc_o <= not (icinput + 32 + 3) + '1';
        else
          rf_lna_o <= '0';
          pgc_o <= not (icinput + 5 + 3) + '1';
        end if;         
      else
        rf_cmd_req_o <= '0';
      end if;
    end if;
  end process radioctrl_p;

  -- Rf outputs
  rf_pgc   <= pgc_o(6 downto 0);
  rf_lna   <= rf_lna_o;
  rf_cmd_req <= rf_cmd_req_o;

  -- Conversion for next pgc computation
  lna_vect <= "00100000" when rf_lna_o = '1' else "00000101";
  pgc1     <= "00001000" when signed(pgc_o) >=4 else (others => '0');


  -----------------------------------------------------------------------------
  -- ICinput computation
  -----------------------------------------------------------------------------
  
  -- Intermediate values and states are stored for future use in the AGC procedure
  stored_value_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      rssimeas          <= (others => (others => '0'));
      il_ref            <= (others => (others => '0'));
      il_meas           <= (others => (others => '0'));
      logstart          <= '0';
      power_estim_best  <= (others => '0');
      firstantenna      <= '0';
      ant1sat           <= '0';
      skiprssimeas      <= '0';
      first_power_estim <= (others => '0');
      lna_best          <= '0';
      modem_transmit_ff1<= '0';
    elsif clk'event and clk = '1' then
      
      modem_transmit_ff1 <= modem_transmit;
  
      -- Store RSSI and ic input values
      if state_end = '1' and  agc_state = init_gainsett_state then
        rssimeas         <= (others => (others => '0'));
        il_ref           <= (others => (others => '0'));
        il_meas          <= (others => (others => '0'));
        power_estim_best <= (others => '0');
        lna_best         <= '0';
      elsif state_end = '1' and (agc_state = rssimeas_scdant_state or
                                 agc_state = rssisaturated_state or
                                 agc_state = firstant_saturated_state or
                                 agc_state = nosig_state or
                                 agc_state = rssiplat_state or
                                 agc_state = monitoring_state or
                                 agc_state = rssiplat_state)
      then
        rssimeas(conv_integer(rf_antswitch_o)) <= rssi_db;
        il_meas(conv_integer(rf_antswitch_o))  <= rssi_icinput + 6;
      elsif (state_end = '1' and agc_state = powerestim_bestantenna_state) then
        -- Store icinput for best antenna
        power_estim_best <= pwr_estim_icinput;
        lna_best         <= rf_lna_o;
      elsif (state_end = '1' and (agc_state = first_il_state or
                                 agc_state = scd_il_state or
                                 agc_state = store_il1_state or
                                 agc_state = store_il2_state)) or
            (agc_next_state = powerestim_bestantenna_state and state_end_ff1 = '1')
        or (agc_state = powerestim_bestantenna_state and agc_next_state /= agc_state) 
      then
        -- Store input level
        il_ref(conv_integer(rf_antswitch_o)) <= rssi_icinput;
      end if;

      -- Trigger log computation at the end of integration
      if (state_counter = SIXUS_CT + 2
           and agc_state = powerestim_bestantenna_state) or
         (state_counter = FOURUS_CT + 2
           and agc_state = powerestim_worseantenna_state)  then
        logstart <= '1';
      else
        logstart <= '0';
      end if;

      -- Store the power estimation value after 2 microsecond
      if state_counter = TWOUS_CT + 3 and agc_state = powerestim_bestantenna_state
      then
        first_power_estim <= power_estim;
      end if;


      -- First antenna saturated
      if (agc_state = rssiplat_state and rf_rssi >= RSSI_SAT_CT
          and state_end = '1' and rssiplateau_reached = '1') then
        ant1sat <= '1';
      elsif agc_state = monitoring_state then
        ant1sat <= '0';
      end if;

      -- More than 6 dB difference between the 2 measures, second power estimation
      -- not needed
      if agc_state = rssimeas_scdant_state and
        ((signed(rssi_db) > signed(rssimeas(conv_integer(not rf_antswitch_o)))
          and rssi_db - rssimeas(conv_integer(not rf_antswitch_o)) > "00001110") or
         (signed(rssi_db) < signed(rssimeas(conv_integer(not rf_antswitch_o)))
          and rssimeas(conv_integer(not rf_antswitch_o)) - rssi_db > "000001110"))
        then
        skiprssimeas <= '1';
      elsif agc_state = monitoring_state then
        skiprssimeas <= '0';
      end if;
    end if;
  end process stored_value_p;

  -------------------------------
  -- State machine control signals
  -------------------------------
  rampup <= '1' when
                 ((il_dif > ilramp2 and
                                (agc_state = powerestim_bestantenna_state)) or
                  (il_dif > ilramp1 and agc_state /= powerestim_bestantenna_state)
                  ) and
                  signed(rssi_icinput) > signed(il_ref(conv_integer(rf_antswitch_o)))
            else
            '0';

  rampdown <= '1' when
                ((il_dif > ilramp2 and  agc_state = powerestim_bestantenna_state)  or
                (il_dif > ilramp1 and agc_state /= powerestim_bestantenna_state)) and
                   signed(rssi_icinput) < signed(il_ref(conv_integer(rf_antswitch_o)))
              else
              '0';
  
  il_dif <= rssi_icinput - il_ref(conv_integer(rf_antswitch_o))
             when
             signed(rssi_icinput) > signed(il_ref(conv_integer(rf_antswitch_o)))
            else
            il_ref(conv_integer(rf_antswitch_o)) - rssi_icinput;
                 
  rssiplateau_reached <= '1' when rssi_db_dif <= rssirip else '0';
  rssi_db_dif <= rssi_db - rssimeas(conv_integer(rf_antswitch_o)) 
                  when
                  signed(rssi_db) > signed(rssimeas(conv_integer(rf_antswitch_o)))
                 else
                 rssimeas(conv_integer(rf_antswitch_o))- rssi_db;   
                                                                     

  max_il <= pwr_estim_icinput when (agc_state = powerestim_bestantenna_state) else
            max_il_ref when agc_state = monitoring_state else
            il_ref(conv_integer(not rf_antswitch_o))
                       when (il_ref(conv_integer(not rf_antswitch_o)) >
                      rssi_icinput and antmod = "10") else
            rssi_icinput;
  max_il_ref <= il_ref(0) when il_ref(0) > il_ref(1) else il_ref(1);

  -------------------------------
  -- RSSI conversion        
  -------------------------------
  best_rssi <= rssi_db when
                          (agc_state = rssisaturated_state or
                           agc_state =  firstant_saturated_state or
                           agc_state = nosig_state) or
                          (rssimeas(conv_integer(not rf_antswitch_o)) < rssi_db
                                          and agc_state = rssimeas_scdant_state)
               else
               rssimeas(conv_integer(not rf_antswitch_o));

  rssi_mul <= rf_rssi * rssislope;  
  rssi_db  <= rssi_mul(18 downto 10)+ (rssi_offset&'0');
  rssi_db_off      <= rssi_db + sxt(kil,9);
  rssi_db_off_pgc  <= best_rssi + sxt(kil,9);  
  rssi_icinput     <= rssi_db_off(8 downto 1) - lna_vect - pgc1 ;
  rssi_icinput_pgc <= rssi_db_off(8 downto 1) - lna_vect - pgc1  + 6
                      when
                           agc_state = rssisaturated_state or
                           agc_state = firstant_saturated_state or
                           agc_state = nosig_state or
                          (rssimeas(conv_integer(not rf_antswitch_o)) < rssi_db
                                          and agc_state = rssimeas_scdant_state) or
                           antmod /= "10" or
                          agc_state = rssi_scdant_scd_state
               else
               il_meas(conv_integer(not rf_antswitch_o));

  
  -------------------------------
  -- ICinput  
  -- Two sources for icinput: RSSI  or power estimation
  -------------------------------
  icinput <= best_pwr_estim_icinput when
               (agc_state = powerestim_worseantenna_state or
               (agc_state = powerestim_bestantenna_state and antmod = "00") or
               (agc_state = powerestim_bestantenna_state and skiprssimeas = '1'))
             else
             rssi_icinput_pgc;
  
  -------------------------------
  -- Power estim icinput
  -------------------------------
  best_pwr_estim_icinput <= power_estim_best 
                                   when (signed(power_estim_best) > signed(pwr_estim_icinput))
                                         and antmod /= "00" and  agc_state /= powerestim_bestantenna_state
                            else pwr_estim_icinput;
  
  lna_ic <= lna_vect when (signed(power_estim_best) <= signed(pwr_estim_icinput))
               or  agc_state = powerestim_bestantenna_state or antmod = "00" else
            "00100000" when lna_best = '1' else
            "00000101";




  -----------------------------------------------------------------------------
  -- Power estimation logarithm
  -----------------------------------------------------------------------------
  pw_log_1: logarithm
  generic map (
    p_size_g => 21)
  port map(
    clk           => clk,          
    reset_n       => reset_n,
    accoup        => accoup,
    kilp          => kilp,
    lna           => lna_vect,          
    pgc           => pgc_o,          
    logstart      => logstart,     
    power_estim   => power_estim_int,  
    icinput       => pwr_estim_icinput      
    );

  -- Select source for logarithm:
  -- During the first power estimation phase, the value used is the difference
  -- between two measures of power estimation
  power_estim_int <= final_power_estim when agc_state = powerestim_bestantenna_state
                     else power_estim;
  
  final_power_estim <= power_estim - first_power_estim;
  
 
  
  -----------------------------------------------------------------------------
  -- AC coupling
  -----------------------------------------------------------------------------
  accoup_p: process (clk, reset_n)
    begin 
      if reset_n = '0' then            
        rf_accoup <= '0';
        agcproc_end <= '0';
      elsif clk'event and clk = '1' then
        agcproc_end <= '0';        
        if state_end = '1' and (agc_state = powerestim_worseantenna_state or
           (agc_state = powerestim_bestantenna_state and
            (skiprssimeas = '1' or antmod = "00")))
        then
          -- End of AGC procedure, AC coupling is switched on.
          rf_accoup <= '1';
          agcproc_end <= '1';
        elsif agc_state = init_gainsett_state then
          rf_accoup <= '0';
        end if;
      end if;
    end process accoup_p;


    
  -----------------------------------------------------------------------------
  -- Radio antenna switch
  -----------------------------------------------------------------------------
  rf_antswitch_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      rf_antswitch_o <= '0';
    elsif clk'event and clk = '1' then
      if bup_rst_req = '1' then
        rf_antswitch_o <= '0';
      elsif state_end = '1' and
        ((antmod = "10" and
        ( agc_state = first_il_state or
          agc_state = store_il1_state or
          agc_state = store_il2_state or         
         (agc_state = monitoring_state and (ed_stat_o = '0' or rampup = '0')
          and rampdown = '0') or
         (agc_state = rssiplat_state and rf_rssi < RSSI_SAT_CT and
          rssiplateau_reached = '1') or
         (agc_state = rssimeas_scdant_state and
                     rssi_db < rssimeas(conv_integer(not rf_antswitch_o)))))
         or
         (agc_state = powerestim_worseantenna_state and
                       signed(power_estim_best) > signed(pwr_estim_icinput))
         or
         (agc_state = powerestim_bestantenna_state and skiprssimeas = '0' and
          signal_quality > ("0000000" & sq_threshold(25 downto 10))
                            and (antmod = "10" or antmod = "01")) or
         (agc_state = powerestim_bestantenna_state and
             signal_quality <= ("0000000" & sq_threshold(25 downto 10))
          and antmod = "01")
         ) 
      then
        -- Antenna is switched when:
        -- * CCA is in monitoring state
        -- * First RSSI measure done and RSSI not saturated
        -- * Second RSSI measure done and RSSI not saturated
        -- * First power estimation done
        -- * Second power estimation done and P(C) > P(D)         
        rf_antswitch_o <= not rf_antswitch_o;

      elsif antmod = "00" then
        rf_antswitch_o <= antsel;
      end if;
    end if;
  end process rf_antswitch_p;

  rf_antswitch   <= rf_antswitch_o;


  -----------------------------------------------------------------------------
  -- CCA Busy
  -----------------------------------------------------------------------------

  -- CCA busy signal generation depends on the CCA mode
  -- Modes 2 and 3 are handled respectively as mode 4 and 5
  cca_busy_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      cca_busy_ff1   <= '0';
      cca_busy_timer <= '0';
    elsif clk'event and clk = '1' then
      cca_busy_ff1 <= cca_busy_o;
      -- If cs_stat_o and ed_stat are both active or a correct
      -- header has been received, busy is set
      -- It is reset if validation ends and no carrier is present
      -- or no SFD detected and timer out
      -- or the packet ended
      if state_end = '1' and agc_state = powerestim_bestantenna_state
        and cs_stat_o = '1' and cca_mode /= "001" then
        cca_busy_timer <= '1';
      elsif packet_end = '1' or bup_rst_req = '1' or
        (sfd_detected = '0' and (cca_mode = "101" or  cca_mode = "011") and
         packet_timer = SFD_DETECTION_CT) or
        plcp_error = '1'
      then

        cca_busy_timer <= '0';
      end if;
    end if;
  end process cca_busy_p;


  with cca_mode select
    cca_busy_o <=
    ed_stat_o                                  when "001",
     (ed_stat_o and cca_busy_ff1)
    or cca_busy_timer                           when "011" | "101",
     cca_busy_timer when "010" | "100",
    '0'                                         when others;

  cca_busy <= cca_busy_o;

  -- Packet timer: counts up the time after the beginning of the packet
  -- detection
  packet_timer_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      packet_timer   <= (others => '0');
      timer_max      <= (others => '0');
      one_us_counter <= (others => '0');
    elsif clk'event and clk = '1' then
      -- Timer for packet length:
      -- it is reseted when a correct header has been detected and
      -- after first acquisition
      if (correct_header = '1')
         or
         (cs_stat_o = '1' and agc_state = powerestim_bestantenna_state and
                   state_end = '1')
         then
        packet_timer <= (others => '0');
      elsif  one_us_counter = ONEUS_CT - 1  then
        packet_timer   <= packet_timer + 1;       
      end if;

      -- One microsecond counter
      if one_us_counter = ONEUS_CT - 1 or
        (cs_stat_o = '1' and agc_state = powerestim_bestantenna_state and
                   state_end = '1') or
        (symbol_sync = '1' and plcp_state = '1' and
                                        agc_state = receiving_state) then
        one_us_counter <= (others => '0'); 
      else
        one_us_counter <= one_us_counter +1;        
      end if;

      -- Timer max value:
      -- * Mode 2 or 4: time measured is 3.65 ms
      -- * Mode 3 or 5: time to detect SFD
      -- * Measures packet length
      if agc_state = monitoring_state and
                            (cca_mode = "010" or cca_mode = "100") then
        timer_max <= CCK_MAX_CT;
      elsif agc_state = monitoring_state and
                            (cca_mode = "011" or cca_mode = "101") then
        timer_max <= SFD_DETECTION_CT;
      elsif correct_header = '1' then
        timer_max <= packet_length;
      end if;
    end if;
  end process packet_timer_p;

  packet_end <= '1' when packet_timer = timer_max   else '0';


  -----------------------------------------------------------------------------
  -- ED and SQ status
  -----------------------------------------------------------------------------
  rec_status_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      ed_stat_o <= '0';
      cs_stat_o <= '0';
    elsif clk'event and clk = '1' then
      -- Energy detect flag
      if rf_rssi > ed_thres then
        ed_stat_o <= '1';
      else
        ed_stat_o <= '0';
      end if;
      if signal_quality >= "0000000" & sq_threshold(25 downto 10) then
        cs_stat_o <= '1';         
      else
        cs_stat_o <= '0';                
      end if;
    end if;
  end process rec_status_p;

  ed_stat <= ed_stat_o;
  cs_stat <= cs_stat_o;
  sq_threshold <= power_estim * (sq_thres + "10000");

  -----------------------------------------------------------------------------
  -- Rxv RSSI
  -----------------------------------------------------------------------------
  rxv_rssi_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then
     rxv_rssi <= (others => '0');
    elsif clk'event and clk = '1' then       
      if state_end = '1' and
        (
          (agc_state = powerestim_bestantenna_state and skiprssimeas = '1') or
          (agc_state = powerestim_bestantenna_state and skiprssimeas = '0'
           and ant1sat = '0') or
          agc_state = powerestim_worseantenna_state
          ) then
        rxv_rssi <= icinput;
      end if;
    end if;
  end process rxv_rssi_p;

  
  -----------------------------------------------------------------------------
  -- Power estimation block enable
  -----------------------------------------------------------------------------

  -- The power estimation block is enabled twice
  pwr_estim_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      power_estim_en_o  <= '0';
      integration_end_o <= '0';
      gain_counter      <= (others => '0');
    elsif clk'event and clk = '1' then
      if modem_transmit = '1' or bup_rst_req = '1' then
        gain_counter <= (others => '0');
        power_estim_en_o <= '0';
      elsif state_end = '1' and
        (agc_state = coarse_gainsett_state or
                               agc_state = interm_gainsett_state or
                               agc_state = fine_gainsett_state)  then
        power_estim_en_o <= '1';
        if agc_state = fine_gainsett_state then
          gain_counter <= (others => '0');
        end if;
      elsif (state_end = '1' and (agc_state = powerestim_bestantenna_state
                          or agc_state = powerestim_worseantenna_state))
         or (integration_end_o = '1' and agc_state = receiving_state) or
      (agc_state = powerestim_bestantenna_state and agc_state /= agc_next_state)
      then        
        power_estim_en_o <= '0';
      elsif state_end = '1' and agc_state = receiving_state and
            gain_counter <"1111" then
        gain_counter <= gain_counter + '1';
      end if;

      -- The result of power estimation is computed twice during the
      -- power estimation state for the best antenna.
      -- After 4 microsecond the result is computed for gain setting
      -- At the end of the state the result is used for carrier sense.
      -- The power estimation block is once again enabled after the AGC procedure
      -- during 14 us for the gain compensation
      if (state_counter = SIXUS_CT and agc_state = powerestim_bestantenna_state)
        or (state_counter = TWOUS_CT+1 and agc_state = powerestim_bestantenna_state)
        or (state_counter = FOURUS_CT and
                                agc_state = powerestim_worseantenna_state)
        or (state_counter = state_counter_max - 4 and
                                      agc_state = powerestim_bestantenna_state)
        or (gain_counter = "1101" and state_end = '1'
            and power_estim_en_o = '1' and agc_state = receiving_state)
      then
        integration_end_o <= '1';
      else
        integration_end_o <= '0';        
      end if;
    end if;
  end process pwr_estim_p;

  integration_end <= integration_end_o;
  power_estim_en  <= power_estim_en_o;
  
  -----------------------------------------------------------------------------
  -- ADCs
  -----------------------------------------------------------------------------

  -- The RSSI ADC is enabled during all reception and monitoring
  -- state. 
  rssi_adc_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      rf_rssiadc_en <= '0';
      rssi_counter  <= (others => '0');
    elsif clk'event and clk = '1' then
      if adcpdmod = '1' or
        (state_end = '1' and agc_state = init_gainsett_state) then
        rf_rssiadc_en <= '1';
      elsif modem_transmit = '1' then
        rf_rssiadc_en <= '0';
      end if;
    end if;
  end process rssi_adc_p;

  -- The I & Q ADCs are switched on for the power estimation
  iq_adc_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      rf_adc_en <= (others => '0');
    elsif clk'event and clk = '1' then
      if (modem_transmit = '1' or bup_rst_req = '1') and adcpdmod = '0' then
        rf_adc_en <= (others => '0');   -- ADCs are switched off
      elsif  adcpdmod = '1' or
            (rf_rssi > ed_thres and rampup = '1' and state_end = '1'
             and  modem_transmit = '0' and agc_state = monitoring_state) then
        rf_adc_en <= "10";              -- ADCs are switched on
      elsif state_end = '1' and agc_state = receiving_state
           and cca_busy_o = '0' then                
        rf_adc_en <= (others => '1');   -- Sleep mode
      end if;
    end if;
  end process iq_adc_p;

  -----------------------------------------------------------------------------
  -- Bup reset request
  -----------------------------------------------------------------------------
  bup_rst_req_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      bup_rst_conf    <= '0';
      bup_rst_req_ff1 <= '0';
    elsif clk'event and clk = '1' then
      bup_rst_req_ff1 <= bup_rst_req;
      if bup_rst_req = '1' then
        bup_rst_conf <= '1';
      else
        bup_rst_conf <= '0';
      end if;
    end if;
  end process bup_rst_req_p;

  -----------------------------------------------------------------------------
  -- Correlator reset and enable
  -----------------------------------------------------------------------------
  correlator_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      correl_rst_n <= '1';
    elsif clk'event and clk = '1' then
      -- Reset the correlator after one microsecond during the first
      -- power estimation
      if state_counter = ONEUS_CT - 1 and
                           agc_state = powerestim_bestantenna_state then
        correl_rst_n <= '0';
      else
        correl_rst_n <= '1';
      end if;
    end if;
  end process correlator_p;

  
  
  -----------------------------------------------------------------------------
  -- Counters
  -----------------------------------------------------------------------------

  -- It counts up the length of each cycle
  state_counter_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      state_counter <= (others => '0');
      state_end     <= '0';
      state_end_ff1 <= '0';
                   
    elsif clk'event and clk = '1' then
      state_end_ff1 <= state_end;
      if bup_rst_req = '1' or modem_transmit = '1' or
        state_counter = state_counter_max or
        (symbol_sync = '1' and plcp_state = '1' and agc_state = receiving_state)
        or (agc_next_state /= agc_state and agc_state = powerestim_bestantenna_state)
         or (agc_next_state /= agc_state and  agc_state = monitoring_state)
      then
        -- Symbol sync pulse is masked during the preamble
        if ((agc_next_state /= agc_state and agc_state = powerestim_bestantenna_state)
         or (agc_next_state /= agc_state and  agc_state = monitoring_state))
           and bup_rst_req = '0' and modem_transmit = '0' then
          state_counter(9 downto 1) <= (others => '0');
          state_counter(0) <= '1';
        else
          state_counter <= (others => '0');          
        end if;
        
        if state_counter = state_counter_max and conv_integer(delpgc0) /= 0
           and bup_rst_req  = '0' and modem_transmit = '0' then
          state_end  <= '1';
        else
          state_end  <= '0';
        end if;
      elsif conv_integer(delpgc0) /= 0 then        
        state_counter <= state_counter + 1;
        state_end     <= '0';
      end if;
    end if;
  end process state_counter_p;

  
  -- It determines the length of the current state
  state_counter_max_p : process(agc_state, delant, deldet, delpgc0, delpgc1,
                                delrssi, delrssirip)
  begin
    case agc_state is
      when monitoring_state | rssimeas_scdant_state | scd_il_state |
        store_il2_state | rssi_scdant_scd_state =>
        state_counter_max <= ("0000" & delrssi &"00") + ("000000" & delant) - '1';
      when receiving_state | first_il_state | store_il1_state =>
        state_counter_max <= "0000" & delrssi &"00" - '1';
      when rssisaturated_state | firstant_saturated_state |nosig_state  =>
        state_counter_max <= ("0000" & delrssi &"00") + ("0000" & delpgc0 &"00") - '1';
      when coarse_gainsett_state | interm_gainsett_state |
        fine_gainsett_state =>
        state_counter_max <= "000" & delpgc1 & "00" - '1';
      when init_gainsett_state | corrgain_state  =>
        state_counter_max <= "0000" & delpgc0 & "00" - '1';
      when powerestim_bestantenna_state =>
        state_counter_max <= deldet* ONEUS_CT + 3;
      when powerestim_worseantenna_state =>
        state_counter_max <= '0' & FOURUS_CT + 10;
      when rssiplat_state =>
         state_counter_max <=  "0000" & delrssirip &"000" - '1';
      when others =>
        state_counter_max <= "0000" & delrssi & "00" - '1';
    end case;
    
  end process state_counter_max_p;

  

  -----------------------------------------------------------------------------
  -- Diagnostic port
  -----------------------------------------------------------------------------
  state_diag_p: process (agc_state)
  begin
    case agc_state is
      when init_gainsett_state           => state_diag <= "00000";
      when first_il_state                => state_diag <= "00001";
      when scd_il_state                  => state_diag <= "00010";
      when store_il1_state               => state_diag <= "00011";
      when store_il2_state               => state_diag <= "00100";
      when corrgain_state                => state_diag <= "00101";
      when monitoring_state              => state_diag <= "00110";
      when rssiplat_state                => state_diag <= "00111";
      when rssimeas_scdant_state         => state_diag <= "01000";
      when rssisaturated_state           => state_diag <= "01001";
      when coarse_gainsett_state         => state_diag <= "01010";
      when powerestim_bestantenna_state  => state_diag <= "01011";
      when rssi_scdant_scd_state         => state_diag <= "01100";
      when nosig_state                   => state_diag <= "01101";
      when firstant_saturated_state      => state_diag <= "01110";
      when interm_gainsett_state         => state_diag <= "01111";
      when powerestim_worseantenna_state => state_diag <= "10000";
      when fine_gainsett_state           => state_diag <= "10001";
      when receiving_state               => state_diag <= "10010";
      when others                        => state_diag <= "10011"; 
    end case;
  end process state_diag_p;


    
   diag_port(0) <= ed_stat_o;
   diag_port(1) <= cs_stat_o;
   diag_port(2) <= cca_busy_o;
   diag_port(3) <= rf_cmd_req_o;
   diag_port(10 downto 4) <= icinput(6 downto 0);
   diag_port(15 downto 11)<= state_diag; 
  
  
  
end RTL;
