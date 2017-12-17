
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: modem_tx_sm.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.19   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Modem 802.11b transmission state machine.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/modem_sm_b/vhdl/rtl/modem_tx_sm.vhd,v  
--  Log: modem_tx_sm.vhd,v  
-- Revision 1.19  2005/02/02 14:51:45  arisse
-- #BugId:983#
-- Removed txv_datarate_resync and txv_length_resync because they are busses.
--
-- Revision 1.18  2004/12/23 14:29:21  arisse
-- #BugId:596#
-- Teated txv_immstop in idle_state after setting other data. Revision 1.17 has a wrong log file.
--
-- Revision 1.17  2004/12/23 08:44:30  arisse
-- #BugId:854#
-- Added check on 13th MSB of the length to verify that it's not bigger than 4095.
--
-- Revision 1.16  2004/12/14 16:50:42  arisse
-- #BugId:596#
-- Added BT co-existence feature.
--
-- Revision 1.15  2003/11/18 17:57:02  Dr.F
-- resynchronized txv_datarate and txv_length due to timing problems.
--
-- Revision 1.14  2003/09/01 15:05:42  Dr.F
-- debugged falling edge of txonoff_req.
--
-- Revision 1.13  2003/01/30 08:33:22  Dr.F
-- debugged activate_seria : it was not activated when reg_prepre=0.
--
-- Revision 1.12  2003/01/28 17:34:30  Dr.F
-- activate_seria set at end of prepre state.
--
-- Revision 1.11  2002/12/13 18:18:33  Dr.F
-- reset state machines when phy_txstartend_req = 0.
--
-- Revision 1.10  2002/11/07 16:23:51  Dr.F
-- added rf control ports.
--
-- Revision 1.9  2002/11/05 10:06:11  Dr.F
-- removed txv_modulation.
--
-- Revision 1.8  2002/10/21 13:57:03  Dr.F
-- added reg_prepre and txv_service.
--
-- Revision 1.7  2002/07/11 13:18:35  Dr.F
-- debugged plcp_data at start of preamble.
--
-- Revision 1.6  2002/06/14 16:37:15  Dr.F
-- reduced txv_length size.
--
-- Revision 1.5  2002/04/30 12:25:37  Dr.B
-- phy_data_req/conf are switched signals.
--
-- Revision 1.4  2002/02/28 15:48:38  omilou
-- added statement in others case to avoid latch at synthesis
--
-- Revision 1.3  2002/02/26 12:11:34  omilou
-- psk_mode and speed are set one cycle later.
-- cahnged the length calculation, using a division by 11
--
-- Revision 1.2  2002/01/29 16:07:22  omilou
-- adapted to spec 0.06
--
-- Revision 1.1  2002/01/17 10:16:27  omilou
-- Initial revision
--
--
--
--
--------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 


entity modem_tx_sm is
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- TX path block
    -------------------------------------- 
    seria_data_conf     : in  std_logic; -- Serializer is ready for new data
    tx_activated        : in  std_logic; -- the tx_path is transmitting when high
    -- 
    scr_data_in         : out std_logic_vector(7 downto 0); -- data sent to scrambler
    sm_data_req         : out std_logic; -- State machines data request
    psk_mode            : out std_logic; -- 0 = BPSK; 1 = QPSK
    activate_seria      : out std_logic; -- activate Serializer
    shift_period        : out std_logic_vector(3 downto 0); -- Serializer speed
    activate_cck        : out std_logic; -- activate CCK modulator
    cck_speed           : out std_logic; -- CCK speed (0 = 5.5 Mbit/s; 1 = 11 Mbit/s)
    preamble_type       : out std_logic; -- preamble type (0 = short; 1 = long)
    --------------------------------------------
    -- Registers
    --------------------------------------------
    reg_prepre          : in  std_logic_vector(5 downto 0); -- pre-preamble count.

    --------------------------------------
    -- CRC
    -------------------------------------- 
    crc_data_1st        : in  std_logic_vector(7 downto 0); -- CRC data
    crc_data_2nd        : in  std_logic_vector(7 downto 0); -- CRC data
    --
    crc_init            : out std_logic; -- init CRC computation
    crc_data_valid      : out std_logic; -- compute CRC on packet header
    data_to_crc         : out std_logic_vector(7 downto 0); -- byte data to CRC
    --------------------------------------------
    -- Radio controller interface
    --------------------------------------------
    rf_txonoff_req      : out std_logic;  -- tx on off request
    rf_txonoff_conf     : in  std_logic;  -- tx on off confirmation
    rf_rxonoff_req      : out std_logic;  -- rx on off request
    rf_rxonoff_conf     : in  std_logic;  -- rx on off confirmation
    --------------------------------------
    -- BuP
    -------------------------------------- 
    phy_txstartend_req  : in  std_logic; -- request to start a packet transmission
                                         -- or request for end of transmission
    txv_service         : in  std_logic_vector(7 downto 0); -- service field
    phy_data_req        : in  std_logic; -- request from BuP to send a byte
    txv_datarate        : in  std_logic_vector( 3 downto 0); -- PSDU transmission rate
    txv_length          : in  std_logic_vector(11 downto 0); -- packet length in bytes
    bup_txdata          : in  std_logic_vector( 7 downto 0); -- data from BuP
    txv_immstop         : in std_logic;  -- request from Bup to stop tx.
    --
    phy_txstartend_conf : out std_logic -- transmission started, ready for data
                                        -- or transmission ended
    );
end modem_tx_sm;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of modem_tx_sm is

--------------------------------------------------------------------------------
-- types
--------------------------------------------------------------------------------
type PLCP_STATE_TYPE is (idle_state,     -- idle state  
                         sync_state,     -- send sync bytes
                         sfd_state,      -- send SFD bytes
                         signal_state,   -- send SIGNAL byte
                         service_state,  -- send SERVICE byte
                         length_state,   -- send length bytes
                         crc_state);     -- send CRC bytes  

type TX_STATE_TYPE is (idle_state,     -- idle state     
                       prepre_state,   -- TX filter sends data with input
                                       -- blocked to init value   
                       plcp_state,     -- send PCLP preamble and header  
                       psdu_state,     -- send packet PSDU  
                       tx_end_state);  -- end of transmission

type IMMSTOP_TYPE is (idle_state,            -- idle state
                      onoffconf_high_state,  --wait rf_txonoff_conf high
                      onoffconf_low_state);  -- wait rf_txonoff_conf low
--------------------------------------------------------------------------------
-- Signals
--------------------------------------------------------------------------------

--------------------------------------
-- PLCP transmission state machine
-------------------------------------- 
signal plcp_tx_state         : PLCP_STATE_TYPE; -- plcp state
signal next_plcp_tx_state    : PLCP_STATE_TYPE; -- Next plcp_state
signal plcp_done             : std_logic; -- PLCP is transmitted
signal plcp_counter          : std_logic_vector(5 downto 0); -- PLCP byte counterted


--------------------------------------
-- transmission state machine
-------------------------------------- 
signal tx_state              : TX_STATE_TYPE; -- tx state
signal next_tx_state         : TX_STATE_TYPE; -- Next tx_state
signal plcp_start            : std_logic; -- start preamble and header transmission
signal plcp_data             : std_logic_vector(7 downto 0); -- PLCP data to be send to scrambler
signal scr_source            : std_logic; -- data source for scrambler (PLCP or BuP)
signal plcp_data_req         : std_logic; -- PLCP data request for scrambler
signal plcp_data_req_ff1     : std_logic; -- plcp_data_req delayed by one clock cycle
signal memo_seria_data_conf  : std_logic; -- last value of phy_data_conf to get
                                          -- the switch state 0-> 1 -> 0 ....
--------------------------------------
-- immstop state machine
-------------------------------------- 
signal immstop_state         : IMMSTOP_TYPE;  -- immediate stop state.
signal next_immstop_state    : IMMSTOP_TYPE;  -- immediate stop state.

--------------------------------------
-- compute PLCP length field
--------------------------------------
--signal txv_datarate_resync   : std_logic_vector(3 downto 0); -- txv_datarate resynchronized
--signal txv_length_resync     : std_logic_vector(11 downto 0); -- txv_length resynchronized
signal txv_length_adjusted   : std_logic_vector(12 downto 0); -- txv_length or txv_length+1
                                                              -- depending on modulation 
signal plcp_length           : std_logic_vector(15 downto 0); -- PLCP length field
signal length_ext            : std_logic; -- length extension bit in SERVICE field
signal txv_length_for_div    : std_logic_vector(16 downto 0); -- txv_length x 8 or x 16
                                                              -- depending on data rate
signal div_result            : std_logic_vector(13 downto 0); -- division by 11 result
signal run_div_calc          : std_logic; -- run division by 11 calculation
signal div_rest              : std_logic_vector(4 downto 0);  -- division by 11 rest
signal rest_calc             : std_logic_vector(4 downto 0);  -- calculate the rest
signal count_div             : std_logic_vector(3 downto 0);  -- division counter
signal div_length_calc       : std_logic_vector(16 downto 0); -- txv_length_for_div shifted


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  ------------------------------------------------------------------------------
  -- PLCP transmission state machine
  ------------------------------------------------------------------------------

  plcp_sm_comb_p: process (memo_seria_data_conf, plcp_counter, plcp_start,
                           plcp_tx_state, seria_data_conf, txv_datarate)
  begin
    
    case plcp_tx_state is
      
      -- idle state
      -- if a request comes from tx state machine, start PLCP transmission
      when idle_state =>
        if plcp_start = '1' then
          next_plcp_tx_state <= sync_state;
        else
          next_plcp_tx_state <= idle_state;
        end if;
                  
      -- Send preamble SYNC.
      when sync_state =>
        if ((plcp_counter = 15 and txv_datarate(2) = '1') or
           (plcp_counter = 6  and txv_datarate(2) = '0')) and
           seria_data_conf = not memo_seria_data_conf then
          next_plcp_tx_state <= sfd_state;
        else
          next_plcp_tx_state <= sync_state;
        end if;
          
      -- Send preamble SFD.
      when sfd_state =>
        if plcp_counter = 1 and seria_data_conf = not memo_seria_data_conf then
          next_plcp_tx_state <= signal_state;
        else
          next_plcp_tx_state <= sfd_state;
        end if;    

      -- Send header SIGNAL.
      when signal_state =>
        if seria_data_conf = not memo_seria_data_conf then
          next_plcp_tx_state <= service_state;
        else
          next_plcp_tx_state <= signal_state;
        end if;    

      -- Send header SERVICE.
      when service_state =>
        if seria_data_conf = not memo_seria_data_conf then
          next_plcp_tx_state <= length_state;
        else
          next_plcp_tx_state <= service_state;
        end if;    

      -- Send header SERVICE.
      when length_state =>
        if plcp_counter = 1 and seria_data_conf = not memo_seria_data_conf then
          next_plcp_tx_state <= crc_state;
        else
          next_plcp_tx_state <= length_state;
        end if;    

      -- Send header CRC.
      when crc_state =>
        if plcp_counter = 1 and seria_data_conf = not memo_seria_data_conf then
          next_plcp_tx_state <= idle_state;
        else
          next_plcp_tx_state <= crc_state;
        end if;    
      
      when others => 
        next_plcp_tx_state <= idle_state;

    end case;
  end process plcp_sm_comb_p;

 
  -- PLCP transmission state machine sequencial process
  plcp_sm_seq_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      plcp_tx_state <= idle_state;
    elsif (hclk'event and hclk = '1') then
      if (phy_txstartend_req = '0') then
        plcp_tx_state <= idle_state;
      else
        plcp_tx_state <= next_plcp_tx_state;
      end if;
    end if;
  end process plcp_sm_seq_p;
 

  ------------------------------------------------------------------------------
  -- General transmission state machine
  ------------------------------------------------------------------------------

  tx_sm_comb_p: process(phy_txstartend_req, plcp_counter, plcp_done,
                        reg_prepre, rf_txonoff_conf, tx_activated, tx_state,
                        txv_datarate, txv_immstop)
  begin
    
    case tx_state is
      
      -- idle state
      -- if a tx request comes from BuP and last tx finished
      -- => start transmission
      when idle_state =>
        if phy_txstartend_req = '1' and txv_datarate(3) = '0'
          and tx_activated = '0' and rf_txonoff_conf = '1' and
          (txv_immstop = '0') then             
          if (reg_prepre = 0) then
            next_tx_state <= plcp_state;
          else
            next_tx_state <= prepre_state;
          end if;
        else
          next_tx_state <= idle_state;
        end if;
        
      when prepre_state =>
        if (txv_immstop = '1') then
          next_tx_state <= idle_state;
        elsif (plcp_counter = reg_prepre) then
          next_tx_state <= plcp_state;
        else
          next_tx_state <= prepre_state;
        end if;

      -- Send PLCP preamble and header.
      -- Wait that plcp state machine has finished. 
      when plcp_state =>
        
        if (txv_immstop = '1') then
          next_tx_state <= idle_state;
        elsif plcp_done = '1' then
          next_tx_state <= psdu_state;
        else
          next_tx_state <= plcp_state;
        end if;
          
      -- PSDU transmission state
      -- Wait that all bytes are sent.
      when psdu_state =>
        if (txv_immstop = '1') then
          next_tx_state <= idle_state;
        elsif phy_txstartend_req = '0' then
          next_tx_state <= tx_end_state;
        else
          next_tx_state <= psdu_state;
        end if;    

      -- end of transmission
      when tx_end_state =>
        next_tx_state <= idle_state;
     
      when others => 
        next_tx_state <= idle_state;

    end case;
  end process tx_sm_comb_p;

  -- Packet transmission state machine sequencial process
  tx_sm_seq_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      tx_state <= idle_state;
    elsif (hclk'event and hclk = '1') then
      if (phy_txstartend_req = '0') then
        tx_state <= idle_state;
      else
        tx_state <= next_tx_state;
      end if;
    end if;
  end process tx_sm_seq_p;

  -- Immstop combinatorial state machine.
  immstop_sm_p: process (immstop_state, rf_txonoff_conf, txv_immstop)
  begin
    if txv_immstop = '1' then
      case immstop_state is
        -- IDLE STATE
        when idle_state  =>
          if rf_txonoff_conf = '1' then
            next_immstop_state <= onoffconf_high_state;
          else
            next_immstop_state <= idle_state;
          end if;
        -- ONOFFCONF_HIGH_STAT
        when onoffconf_high_state =>
          if rf_txonoff_conf = '0' then
            next_immstop_state <= onoffconf_low_state;
          else
            next_immstop_state <= onoffconf_high_state;
          end if;
        -- ONOFFCONF_LOW_STATE
        when onoffconf_low_state =>
          next_immstop_state <= idle_state;
          
        when others =>
          next_immstop_state <= idle_state;
      end case;
    else
      next_immstop_state <= idle_state;
    end if;
  end process immstop_sm_p;

  -- Immstop state machine sequential process.
  immstop_sm_seq_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      immstop_state <= idle_state;
    elsif hclk'event and hclk = '1' then
      if txv_immstop = '1' then
        immstop_state <= next_immstop_state;
      else
        immstop_state <= idle_state;
      end if;
    end if;
  end process immstop_sm_seq_p;

  -- Transmission control signals management. 
  -- This controls the Transmission state machine,
  -- the scrambler, the serializer, the mapping,
  -- the spreading, the CCK modulator and the FEC encoder.
  tx_control_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      plcp_done           <= '0';
      plcp_counter        <= (others => '0');
      plcp_start          <= '0';
      scr_source          <= '0';
      plcp_data_req       <= '0';
      plcp_data           <= (others => '0');
      activate_cck        <= '0';
      psk_mode            <= '0';
      activate_seria      <= '0';
      shift_period        <= (others => '0');
      crc_init            <= '0';
      phy_txstartend_conf <= '0';
      rf_txonoff_req      <= '0';
      rf_rxonoff_req      <= '0';
      memo_seria_data_conf<= '0';
--      txv_length_resync   <= (others => '0');
--      txv_datarate_resync <= (others => '0');
    elsif (hclk'event and hclk = '1') then
--      txv_length_resync   <= txv_length;
--      txv_datarate_resync <= txv_datarate;
      case tx_state is
        
        when idle_state =>

          -- No txv_immstop
          memo_seria_data_conf <= '0';
          plcp_done            <= '0';
          plcp_counter         <= (others => '0');
          scr_source           <= '0';
          plcp_data            <= (others => '0');
          psk_mode             <= '0';
          shift_period         <= "1010";
          --rf_txonoff_req      <= '0';
          rf_rxonoff_req       <= '0';

          -- rf rx on req when idle
          if (phy_txstartend_req = '1') and (txv_datarate(3) = '0') and
            (tx_activated = '0') then
            rf_rxonoff_req <= '0';
          elsif (tx_activated = '0') then
            rf_rxonoff_req <= '1';
          end if;

          -- rf tx req when tx start req and rf rx off conf
          if (phy_txstartend_req = '1') and (txv_datarate(3) = '0') and
            (tx_activated = '0') and (rf_rxonoff_conf = '0') then
            rf_txonoff_req <= '1';
          end if;

--          if (txv_immstop) = '1' and (rf_txonoff_conf = '1') then
--            rf_txonoff_req <= '0';
--          end if;          

          if (tx_activated = '0') and (phy_txstartend_req = '0') then
            rf_txonoff_req <= '0';
          end if;

          if (tx_activated = '0') and (rf_txonoff_conf = '0') then
            phy_txstartend_conf <= '0';
--          elsif txv_immstop = '1' and rf_txonoff_conf = '1' then
--            phy_txstartend_conf <= '0';
          end if;

          if phy_txstartend_req = '1' and txv_datarate(3) = '0'
            and tx_activated = '0' and rf_txonoff_conf = '1' then
            if (reg_prepre = 0) then
              plcp_start     <= '1';
              activate_seria <= '1';
            end if;
            crc_init <= '1';
            if txv_datarate(2) = '1' then  -- long preamble even nb of bytes
              plcp_data_req        <= '1';
              memo_seria_data_conf <= '0';
              plcp_data            <= (others => '1');  -- long preamble
            else                        -- short preample odd nb of bytes 
              plcp_data_req        <= '0';
              memo_seria_data_conf <= '1';
              plcp_data            <= (others => '0');  -- short preamble
            end if;
          else
            plcp_start     <= '0';
            activate_cck   <= '0';
            activate_seria <= '0';
            crc_init       <= '0';
            plcp_data_req  <= '0';
          end if;
          
          
          -- TXV IMMSTOP
          if txv_immstop = '1' then
            -- IDLE STATE
            if immstop_state = idle_state then
            -- ONOFFCONF_HIGH_STAT
            elsif immstop_state = onoffconf_high_state then
              rf_txonoff_req <= '0';
              phy_txstartend_conf <= '1';
            -- ONOFFCONF_LOW_STATE
            elsif immstop_state = onoffconf_low_state then
              phy_txstartend_conf  <= '0';
--              plcp_done            <= '0';
--              plcp_counter         <= (others => '0');
--              plcp_start           <= '0';
--              scr_source           <= '0';
--              plcp_data_req        <= '0';
--              plcp_data            <= (others => '0');
--              activate_cck         <= '0';
--              psk_mode             <= '0';
--              activate_seria       <= '0';
--              shift_period         <= "1010";
--              crc_init             <= '0';
--              rf_txonoff_req       <= '0';
----              rf_rxonoff_req       <= '0';
--              memo_seria_data_conf <= '0';
--              txv_length_resync    <= (others => '0');
            end if;
          end if;

  
        when prepre_state =>
          if (txv_immstop = '1') then
            phy_txstartend_conf <= '1';
          else
            crc_init       <= '0';
            if (plcp_counter = reg_prepre) then
              activate_seria <= '1';
              plcp_counter   <= (others => '0');
              plcp_start     <= '1';
            else
              plcp_counter   <= plcp_counter + 1;
              plcp_start     <= '0';
            end if;
          end if;
          
        when plcp_state =>

          if (txv_immstop = '1') then
            phy_txstartend_conf <= '1';
          else
            plcp_start     <= '0';
            crc_init       <= '0';
            rf_rxonoff_req <= '0';
          
            case plcp_tx_state is
                         
              when sync_state =>
                if ((plcp_counter = 15 and txv_datarate(2) = '1')  or --lg prb
                    (plcp_counter = 6  and txv_datarate(2) = '0')) and--sh prb
                  seria_data_conf = not memo_seria_data_conf then
                  -- reset plcp_counter and go to sfd_state
                  plcp_counter   <= (others => '0');
                  plcp_data_req  <= not plcp_data_req;
                  memo_seria_data_conf <= seria_data_conf;
                elsif seria_data_conf = not memo_seria_data_conf then
                  -- sync not finished, but new byte to send
                  plcp_counter   <= plcp_counter + 1;
                  plcp_data_req  <= not plcp_data_req;
                  memo_seria_data_conf <= seria_data_conf;
                end if;
               
              when sfd_state =>
                if txv_datarate(2) = '0' then -- short preamble
                  if plcp_counter = 0 then
                    plcp_data      <= "11001111";  -- CF
                  else
                    plcp_data      <= "00000101";  -- 05
                  end if;    
                else                          -- long preamble
                  if plcp_counter = 0 then
                    plcp_data      <= "10100000";  -- A0
                  else
                    plcp_data      <= "11110011";  -- F3
                  end if;    
                end if;    
                if plcp_counter = 1 and seria_data_conf = not memo_seria_data_conf then
                  -- reset plcp_counter and go to signal_state
                  plcp_counter   <= (others => '0');
                  plcp_data_req  <= not plcp_data_req;
                  memo_seria_data_conf <= seria_data_conf;              
                  if txv_datarate(2) = '0' then
                    psk_mode         <= '1';  -- 2 Mbit/s
                  else
                    psk_mode         <= '0';  -- 1 Mbit/s
                  end if;    
                elsif seria_data_conf = not memo_seria_data_conf then
                  plcp_counter   <= plcp_counter + 1;
                  plcp_data_req  <= not plcp_data_req;
                  memo_seria_data_conf <= seria_data_conf;              
                end if;  

              when signal_state =>
                if txv_datarate(1 downto 0) = "00" then    -- 1Mb/s
                  plcp_data      <= "00001010";
                elsif txv_datarate(1 downto 0) = "01" then -- 2Mb/s
                  plcp_data      <= "00010100";
                elsif txv_datarate(1 downto 0) = "10" then -- 5.5Mb/s
                  plcp_data      <= "00110111";
                else                                       -- 11Mb/s
                  plcp_data      <= "01101110";
                end if;  
                if seria_data_conf = not memo_seria_data_conf then
                  -- reset plcp_counter and go to service_state
                  plcp_counter   <= (others => '0');
                  plcp_data_req  <= not plcp_data_req;
                  memo_seria_data_conf <= seria_data_conf;              
                end if;  
 
              when service_state =>
                plcp_data      <= length_ext & txv_service(6 downto 0);
                if seria_data_conf = not memo_seria_data_conf then
                  -- reset plcp_counter and go to lenght_state
                  plcp_counter   <= (others => '0');
                  plcp_data_req  <= not plcp_data_req;
                  memo_seria_data_conf <= seria_data_conf;              
                end if;  

              when length_state =>
                if plcp_counter = 0 then
                  plcp_data      <= plcp_length(7 downto 0);
                else
                  plcp_data      <= plcp_length(15 downto 8);
                end if;    
                if plcp_counter = 1 and seria_data_conf = not memo_seria_data_conf then
                  -- reset plcp_counter and go to crc_state                
                  plcp_counter   <= (others => '0');
                  plcp_data_req  <= not plcp_data_req;
                  memo_seria_data_conf <= seria_data_conf;              

                elsif seria_data_conf = not memo_seria_data_conf then
                  plcp_counter   <= plcp_counter + 1;
                  plcp_data_req  <= not plcp_data_req;
                  memo_seria_data_conf <= seria_data_conf;              
                end if;  

              when crc_state =>
                if plcp_counter = 0 then
                  plcp_data      <= crc_data_1st;
                else
                  plcp_data      <= crc_data_2nd;
                end if;    
                if plcp_counter = 1 and seria_data_conf = not memo_seria_data_conf then
                  -- reset plcp_counter and go to psdu states
                  plcp_counter        <= (others => '0');
                  scr_source          <= '1';
                  plcp_done           <= '1';
                  phy_txstartend_conf <= '1';
                  case txv_datarate(1 downto 0) is
                  
                    when "00" =>          -- 1 Mbit/s
                      psk_mode     <= '0';
                      shift_period <= "1010";

                    when "01" =>          -- 2 Mbit/s                    
                      psk_mode     <= '1';
                      shift_period <= "1010";
                    
                    when "10" =>          -- 5,5 Mbit/s  
                      psk_mode     <= '1';
                      shift_period <= "0001";
                      if txv_service(3) = '1' then
                        activate_cck   <= '0';
                        activate_seria <= '1';
                      else
                        activate_cck   <= '1';
                        activate_seria <= '0';
                      end if;

                    when "11" =>          -- 11 Mbit/s  
                      psk_mode     <= '1';
                      shift_period <= "0000";
                      activate_cck <= '1';
                      if txv_service(3) = '1' then
                        activate_cck   <= '0';
                        activate_seria <= '1';
                      else
                        activate_cck   <= '1';
                        activate_seria <= '0';
                      end if;
                    
                    when others =>  null;
                  end case;
                elsif seria_data_conf = not memo_seria_data_conf then
                  plcp_counter   <= plcp_counter + 1;
                  plcp_data_req  <= not plcp_data_req;
                  memo_seria_data_conf <= seria_data_conf;              
                end if;  
            
              when others => 

            end case;
          end if;
          
        when psdu_state =>
          if (txv_immstop = '1') then
            phy_txstartend_conf <= '1';
          else
            scr_source     <= '1';
            plcp_done      <= '0';
          end if;
          
        when tx_end_state =>
          scr_source          <= '1';
          phy_txstartend_conf <= '1';

        when others => 

      end case;
    end if;
  end process tx_control_p;

  data_to_crc   <= plcp_data;

  scr_data_in   <= plcp_data     when  scr_source = '0' else
                   bup_txdata;

  
  sm_data_req   <= plcp_data_req when  scr_source = '0' else
                   phy_data_req;
                   


  cck_speed <= '1' when txv_datarate(1 downto 0) = "11" else
               '0';

  -- CRC data valid generation
  -- should be set on each rising edge of plcp_data_req
  -- CRC is only computed on header 
  -- This means when in signal_state, service_state or length_state 
  plcp_data_req_sync_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      plcp_data_req_ff1 <= '0';
      crc_data_valid <= '0';
    elsif (hclk'event and hclk = '1') then
      plcp_data_req_ff1 <= plcp_data_req;
      if (plcp_data_req = not plcp_data_req_ff1) and
         (plcp_tx_state = signal_state  or 
          plcp_tx_state = service_state or 
          plcp_tx_state = length_state) then
        crc_data_valid <= '1';
      else
        crc_data_valid <= '0';
      end if;
    end if;
    
  end process plcp_data_req_sync_p;
 
 
---------------------------------------------------------------------
-- compute PLCP length field
---------------------------------------------------------------------
-- divide the length by 11
-- If the modulation is PBCC then add 1 before computing.
-- Before dividing by 11, first the multiplication by 8 is done.
-- In fact multiply by 8 at 11 Mbit/s and by 16 at 5.5 Mbit/s.
-- This is done to use the same division by 11.


  -- adjust the length according to modulation type 
  txv_length_adjusted <= ('0' & txv_length) + 1 when txv_service(3) = '1' else
                         -- PBCC modulation
                         '0' & txv_length;
                         -- CCK modulation


  -- multiply by 8 or 16 according to data rate
  txv_length_for_div <= txv_length_adjusted & "0000"       -- 5.5 Mbit/s (x 16)
                                      when txv_datarate(1 downto 0) = "10" else
                        '0' & txv_length_adjusted & "000"; -- 11 Mbit/s (x 8)
  
  -- this calculate the rest of the division
  rest_calc <= div_rest - "01011";

  -- this is the division by 11 process.
  -- The calculation starts each time a new packet is sent.
  -- The operation lasts 15 clock cycles.
  -- We don't need to indicate when the calculation is finished,
  -- since the result will be used much more later.
  -- Note that this is a classic binary division.
  plcp_div_calc_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      div_result       <= (others => '0');
      run_div_calc     <= '0';
      div_rest         <= (others => '0');
      count_div        <= (others => '0');
      div_length_calc  <= (others => '0');
    elsif (hclk'event and hclk = '1') then
      if plcp_start = '1' then
        run_div_calc       <= '1';
        div_rest           <= '0' & txv_length_for_div(16 downto 13);
        div_length_calc    <= txv_length_for_div;
        div_result         <= (others => '0');
      elsif run_div_calc = '1' then
        if div_rest < "01011" then
          div_result  <= div_result(12 downto 0) & '0';
          div_rest    <= div_rest(3 downto 0) & div_length_calc(12);
        else
          div_result  <= div_result(12 downto 0) & '1';
          div_rest    <= rest_calc(3 downto 0) & div_length_calc(12);
        end if;  
        if count_div = 13 then
          run_div_calc  <= '0';
          count_div     <= (others => '0');
        else  
          count_div     <= count_div + 1;
        end if;
        div_length_calc <= div_length_calc(15 downto 0) & '0';
      end if;    
    end if;
  end process plcp_div_calc_p;
  



  -- rounding is done up to the next integer
  -- When no rest, no need to round.
  -- Note that there is no difference between 11 and 5.5 Mbit/s
  -- since the differenciation is done before division by 11.
  plcp_length <= '0' & txv_length & "000"           -- 1 Mbit/s
                   when txv_datarate(1 downto 0) = "00" else   
                 "00" & txv_length & "00"      -- 2 Mbit/s
                   when txv_datarate(1 downto 0) = "01" else  
                 "00" & div_result            -- 11 or 5.5 Mbit/s with no rest
                   when div_rest(4 downto 1) = "0000" else 
                 ("00" & div_result) + 1;     -- 11 or 5.5 Mbit/s with rest
                 
                 
 
  -- the extension bit in SERVICE field
  -- is only when at 11 Mbit/s
  -- when the rounding is more or equal to 8/11
  -- this imply that the rest is less than 1 - 8/11
  -- and 1 - 8/11 = 0.010001011101   
  -- But this the rest of the division by 8/11.
  -- As the real rest calculated is the division by 11 
  -- this imply that the rest is less than 8 * (1 - 8/11)
  -- 8 * (1 - 8/11) = 2,1881818181       
  length_ext <= '1' when txv_datarate(1 downto 0) = "11"
                    and  (div_rest(4 downto 1) = "0010" 
                       or div_rest(4 downto 1) = "0001"
                       or div_rest(4 downto 0) = "00110") else           
                '0'; 
     
  preamble_type <= txv_datarate(2);             
 
end RTL;
