
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: modem_rx_sm.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.33   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Modem 802.11b state machines for reception.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/modem_sm_b/vhdl/rtl/modem_rx_sm.vhd,v  
--  Log: modem_rx_sm.vhd,v  
-- Revision 1.33  2005/03/29 09:37:17  arisse
-- #BugId:983#
-- Removed carrier lost information : not used at all.
--
-- Revision 1.32  2005/03/22 14:05:20  arisse
-- #BugId:854#
-- Check of length only if we had not rate error before.
--
-- Revision 1.31  2005/03/09 16:59:59  arisse
-- #BugId:854#
-- Checked rate error only if there is no CRC error.
--
-- Revision 1.30  2005/03/01 16:10:07  arisse
-- #BugId:854#
-- Changed rate error generation (bit 3 of service field and ERP-DSSS-OFDM packet).
--
-- Revision 1.29  2005/02/16 09:25:00  arisse
-- #BugId:1057#
-- Looked at rising edge of byte_ind because otherwise, high during two clock cycles if in the same time of a clock skip.
--
-- Revision 1.28  2005/02/02 14:49:40  arisse
-- #BugId:955#
-- Added phy_txstartend_req input in case of a IAC.
--
-- Revision 1.27  2005/01/11 10:20:42  arisse
-- #BugId:854#
-- Romved possiblity of error_rate, added format_error for wrong length (too small or too big).
--
-- Revision 1.26  2004/12/23 14:30:40  arisse
-- #BugId:854#
-- Added check on 13th MSB of the rxv_length to verify that it's not bigger than 4095.
--
-- Revision 1.25  2004/12/22 14:30:10  arisse
-- #BugId:854#
-- Added rxlenchken and rxmaxlength.
-- Modified delay on rx_psk_mode with a counter instead of registers.
--
-- Revision 1.24  2004/08/06 12:12:56  arisse
-- Reset rx_psk_mode_o_ff0...39 to 0 between two packets.
--
-- Revision 1.23  2004/06/28 08:38:43  sbizet
-- Added cca_busy=0 condition in psdu_state to end reception
--
-- Revision 1.22  2004/06/14 14:02:01  arisse
-- Added delay on rx_psk_mode.
--
-- Revision 1.21  2003/11/03 16:03:13  arisse
-- Modified diag ports.
--
-- Revision 1.20  2003/10/16 14:13:37  arisse
-- Added diag ports.
--
-- Revision 1.19  2003/09/22 16:13:25  arisse
-- Removed rx_psk_mode2 signal wich was not used any more.
--
-- Revision 1.18  2003/08/06 13:38:08  Dr.C
-- debugged falling edge detection of tx_activated.
--
-- Revision 1.17  2003/07/29 15:20:14  Dr.F
-- debugged listen_start generation.
--
-- Revision 1.16  2003/07/29 07:47:37  Dr.F
-- debugged listen_start_o.
--
-- Revision 1.15  2003/07/29 07:38:50  Dr.F
-- wait for cca_busy to be 0 at end of rx.
--
-- Revision 1.14  2003/07/25 05:40:28  Dr.F
-- added listen_start_o.
--
-- Revision 1.13  2003/06/27 15:44:45  Dr.F
-- phy_data_ind is now created as a transitional signal instead of a pulse.
--
-- Revision 1.12  2002/12/03 13:24:24  Dr.F
-- increased psdu_duration size.
--
-- Revision 1.11  2002/11/26 08:13:31  Dr.F
-- added plcp_error.
-- generate a pulse on phy_rxstartend_ind on rate and format error.
--
-- Revision 1.10  2002/11/05 10:05:32  Dr.F
-- removed rxv_modulation and cck_enable.
--
-- Revision 1.9  2002/10/21 13:56:42  Dr.F
-- added rxv_service.
--
-- Revision 1.8  2002/09/12 14:21:54  Dr.F
-- removed test on cca_busy when in psdu state.
--
-- Revision 1.7  2002/09/09 14:22:14  Dr.F
-- removed one_us_it and added rx_plcp_state.
--
-- Revision 1.6  2002/08/08 16:52:07  Dr.F
-- removed agc_setting_end.
--
-- Revision 1.5  2002/07/31 08:24:09  Dr.F
-- rx_path interface changed.
-- removed rx_ctrl instanciation because now it is an external sub-block.
--
-- Revision 1.4  2002/07/11 13:15:09  Dr.F
-- added rx_patrh control signals.
--
-- Revision 1.3  2002/07/03 16:21:48  Dr.F
-- added some ports to control rx_path.
--
-- Revision 1.2  2002/06/19 10:10:11  Dr.A
-- Added parenthesis on rx_length_times11 computation.
--
-- Revision 1.1  2002/06/14 16:37:44  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use IEEE.STD_LOGIC_arith.ALL; 

--library modem_sm_b_rtl;
library work;
--use modem_sm_b_rtl.modem_sm_b_pkg.all;      
use work.modem_sm_b_pkg.all;      

entity modem_rx_sm is
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- RX path block
    -------------------------------------- 
    cca_busy            : in  std_logic; -- CCA busy
    preamble_type       : in  std_logic; -- 1: long preamble ; 0: short preamble
    sfd_found           : in  std_logic; -- pulse when SFD is detected
    byte_ind            : in  std_logic; -- byte indication  
    tx_activated        : in  std_logic; -- the tx_path is transmitting    
    rx_data             : in  std_logic_vector(7 downto 0); -- received descrambled data
    --
    decode_path_activate: out std_logic; -- decode path activate
    diff_decod_first_val: out std_logic; -- pulse on first byte to decode
    rec_mode            : out std_logic_vector(1 downto 0); -- BPSK, QPSK, CCK5.5, CCK 11
    mod_type            : out std_logic; -- 0 : DSSS ; 1 : CCK
    rx_psk_mode         : out std_logic; -- 0 = BPSK; 1 = QPSK
    cck_rate            : out std_logic; -- CCK rate (0 = 5.5 Mb/s; 1 = 11 Mb/s)
    rx_idle_state       : out std_logic; -- high when sm is idle
    rx_plcp_state       : out std_logic; -- high when sm is in plcp state
    --------------------------------------------
    -- CCA
    --------------------------------------------
    psdu_duration       : out std_logic_vector(15 downto 0); --length in us
    correct_header      : out std_logic; -- high when header is correct.
    plcp_error          : out std_logic; -- high when plcp error occures
    listen_start_o      : out std_logic; -- high when start to listen
    --------------------------------------
    -- CRC
    -------------------------------------- 
    crc_data_1st        : in  std_logic_vector(7 downto 0); -- CRC data
    crc_data_2nd        : in  std_logic_vector(7 downto 0); -- CRC data
    --
    crc_init            : out std_logic; -- init CRC computation
    crc_data_valid      : out std_logic; -- compute CRC on packet header
    data_to_crc         : out std_logic_vector(7 downto 0); -- byte data to CRC
    --------------------------------------
    -- BuP
    -------------------------------------- 
    phy_txstartend_req  : in  std_logic; -- request to start a packet transmission
                                         -- or request for end of transmission
    phy_cca_ind         : out  std_logic; -- indication of a carrier
    phy_rxstartend_ind  : out  std_logic; -- indication of a recieved PSDU
    rxv_service         : out  std_logic_vector(7 downto 0); -- service field
    phy_data_ind        : out  std_logic; -- indication of a recieved byte
    rxv_datarate        : out  std_logic_vector( 3 downto 0); -- PSDU RX rate
    rxv_length          : out  std_logic_vector(11 downto 0); -- packet length in bytes
    rxe_errorstat       : out  std_logic_vector(1 downto 0); -- error
    bup_rxdata          : out  std_logic_vector( 7 downto 0);  -- data to BuP
    --------------------------------------
    -- Registers
    --------------------------------------
    rxlenchken          : in  std_logic; -- select ckeck on rx data lenght.
    rxmaxlength         : in  std_logic_vector(11 downto 0); -- Max accepted received length.
    --------------------------------------
    -- Diag
    --------------------------------------
    rx_state_diag       : out std_logic_vector(2 downto 0)  -- Diag port
    );
end modem_rx_sm;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of modem_rx_sm is

  --------------------------------------------
  -- Types
  --------------------------------------------
  type RX_STATE_TYPE is (idle_state,         -- idle state  
                         preamble_state,     -- looking for SFD sync   
                         plcp_state,         -- receive PCLP header  
                         psdu_state,         -- receive packet PSDU  
                         rx_end_state);      -- end of reception

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal rx_state              : RX_STATE_TYPE; -- tx state
  signal next_rx_state         : RX_STATE_TYPE; -- Next tx_state
  signal error_stat            : std_logic_vector(1 downto 0);
  signal byte_counter          : std_logic_vector(11 downto 0);
  signal cck_counter           : std_logic_vector(11 downto 0);
  signal cck_counter_enable    : std_logic;
  signal rx_psk_mode_o         : std_logic;
  signal format_error          : std_logic;
  signal rate_error            : std_logic;
  signal rate_error_int        : std_logic;  -- intermediate rate_error in case of crc error.
  signal plcp_end              : std_logic;
  signal psdu_end              : std_logic;
  signal length_ext            : std_logic;
  signal cca_busy_ff1          : std_logic;
  signal cca_falling           : std_logic;
  signal rx_rate               : std_logic_vector(3 downto 0);
  signal rx_rate_saved         : std_logic_vector(7 downto 0);
  signal rxv_length_o          : std_logic_vector(11 downto 0);
  signal rx_length             : std_logic_vector(15 downto 0);
  signal rx_length_times11     : std_logic_vector(18 downto 0);
  signal phy_data_ind_s        : std_logic;
  signal tx_activated_ff1      : std_logic;
  signal tx_end_pulse          : std_logic;
  signal phy_rxstartend_ind_int : std_logic;
  signal byte_ind_ff1          : std_logic;
  ----------------------------------------------- End of Signal declaration

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------

begin

  phy_rxstartend_ind <= phy_rxstartend_ind_int;
  diff_decod_first_val <= '0';
  
  rxe_errorstat  <= error_stat;
  rxv_datarate   <= rx_rate;
  rxv_length     <= rxv_length_o;
  phy_data_ind   <= phy_data_ind_s;
    
  -- rx_length * 11 = rx_length + 2 * rx_length + 8 * rx_length
  rx_length_times11 <= ("000" & rx_length) + 
                       ("00"  & rx_length & '0') + 
                               (rx_length & "000");
  psdu_duration <= rx_length;
  
  phy_cca_ind <= cca_busy_ff1;
  
  rx_idle_state <= '1' when next_rx_state = idle_state else '0';
  rx_plcp_state <= '1' when next_rx_state = plcp_state else '0';

  rx_psk_mod_ff_p: process (hclk, hresetn)
    variable counter_psk : std_logic_vector(5 downto 0);
  begin
    if hresetn = '0' then
      counter_psk := (others => '0');
      rx_psk_mode <= '0';
    elsif hclk'event and hclk = '1' then
      if next_rx_state = idle_state then
        counter_psk := (others => '0');
        rx_psk_mode <= '0';
      else
        if rx_psk_mode_o='1' then
          if counter_psk < "101000" then  -- counter<28h=40d
            counter_psk := counter_psk + '1';
            rx_psk_mode <= '0';
          elsif counter_psk = "101000" then  -- counter=28h=40d
            rx_psk_mode <= '1';
          end if;
        else
          rx_psk_mode <= '0';
        end if;
      end if;

      
    end if;
  end process rx_psk_mod_ff_p;

  
  --------------------------------------------
  -- generate a pulse on falling edge of cca_busy
  --------------------------------------------
  cca_falling_p : process(hresetn, hclk)
  begin
    if hresetn = '0' then
      cca_busy_ff1 <= '0';
      cca_falling  <= '0';
    elsif (hclk'event and hclk = '1') then
      cca_busy_ff1 <= cca_busy;
      if (cca_busy_ff1 = '1') and (cca_busy = '0') then
        cca_falling <= '1';
      else
        cca_falling <= '0';
      end if;
    end if;    
  end process cca_falling_p;
                            
                             
  --------------------------------------------
  -- Byte counter. This process counts bytes
  -- in the PLCP header and in the PSDU.
  --------------------------------------------
  byte_counter_p : process (hresetn, hclk)
  begin
    if hresetn = '0' then
      byte_counter <= (others => '0');
      byte_ind_ff1 <= '0';
    elsif (hclk'event and hclk = '1') then
      byte_ind_ff1 <= byte_ind;
      if (next_rx_state = idle_state) or
         ((next_rx_state = plcp_state) and (rx_state = preamble_state)) or
         ((next_rx_state = psdu_state) and (rx_state = plcp_state)) then
        byte_counter <= (others => '0');
      elsif (byte_ind = '1' and byte_ind_ff1 = '0') then
        byte_counter <= byte_counter + '1';
      end if;
    end if;
  end process byte_counter_p;
  
  
  --------------------------------------------
  -- mod_type generation
  --------------------------------------------
  mod_type_p : process(hclk, hresetn)
  begin
    if hresetn = '0' then
      cck_counter_enable <= '0';
      cck_counter        <= (others => '0');
      mod_type           <= '0';
      cck_rate           <= '0';
    elsif (hclk'event and hclk = '1') then
      if (rx_state = idle_state) then
        cck_counter_enable <= '0';
        cck_counter        <= (others => '0');
        mod_type           <= '0';
        cck_rate           <= '0';
      end if;
      if (rx_state = plcp_state) and (byte_ind = '1' and byte_ind_ff1 = '0') and 
         (byte_counter = 4) then
        cck_counter_enable <= '1';
      end if;
      if (cck_counter_enable = '1') then
        cck_counter <= cck_counter + '1';
      end if;
      if ((cck_counter = 292) and (rx_psk_mode_o = '0')) or
         ((cck_counter = 115) and (rx_psk_mode_o = '1')) then
        cck_counter_enable <= '0';
        cck_counter        <= (others => '0');
        if (rx_rate(1 downto 0) = "10") then
          mod_type     <= '1';
        end if;
        if (rx_rate(1 downto 0) = "11") then
          mod_type     <= '1';
          cck_rate     <= '1';
        end if;
      end if; 
    end if;
  end process mod_type_p;

    
  ------------------------------------------------------------------------------
  -- Packet reception state machine combinational process
  ------------------------------------------------------------------------------
  rx_sm_comb_p: process(cca_busy, format_error, phy_txstartend_req, plcp_end,
                        psdu_end, rate_error, rx_state, sfd_found,
                        tx_activated)     -- high when PSDU is over
  begin
    
    case rx_state is
      
      -- idle state
      when idle_state =>
        if (cca_busy = '1') and (tx_activated = '0')
          and (phy_txstartend_req='0') then  -- no tx requested
          next_rx_state <= preamble_state;
        else
          next_rx_state <= idle_state;
        end if;

      -- preamble state
      when preamble_state =>
        if (phy_txstartend_req = '1') then
          next_rx_state <= idle_state;
        elsif (cca_busy = '0') then
          next_rx_state <= rx_end_state;
        elsif (sfd_found = '1') then
          next_rx_state <= plcp_state;
        else
          next_rx_state <= preamble_state;
        end if;

      -- PLCP state
      when plcp_state =>
        if (phy_txstartend_req = '1') then
          next_rx_state <= idle_state;
        elsif (cca_busy = '0') or (format_error = '1') or (rate_error = '1') then
          next_rx_state <= rx_end_state;
        elsif (plcp_end = '1') then
          next_rx_state <= psdu_state;
        else
          next_rx_state <= plcp_state;
        end if;

      -- PSDU state
      when psdu_state =>
        if (phy_txstartend_req = '1') then
          next_rx_state <= idle_state;
          next_rx_state <= rx_end_state;          
        elsif (psdu_end = '1') or (cca_busy = '0') then
          next_rx_state <= rx_end_state;
        else
          next_rx_state <= psdu_state;
        end if;

      -- RX end state
      when rx_end_state =>
        if (phy_txstartend_req = '1') then
          next_rx_state <= idle_state;
        elsif (cca_busy = '0') then
          next_rx_state <= idle_state;
        else
          next_rx_state <= rx_end_state;
        end if;

      when others => 
        next_rx_state <= idle_state;

    end case;
  end process rx_sm_comb_p;

  -- Packet reception state machine sequencial process
  rx_sm_seq_p: process (hclk, hresetn)
  begin
    if hresetn = '0' then
      rx_state <= idle_state;
    elsif (hclk'event and hclk = '1') then
      rx_state <= next_rx_state;
    end if;
  end process rx_sm_seq_p;

  --------------------------------------------
  -- Reception control signals management. 
  -- This controls the reception path,
  -- the descrambler, the deserializer, the demapping,
  -- the DSSS / CCK demodulation and the FEC decoder.
  --------------------------------------------
  rx_control_p: process (hclk, hresetn)
    variable rxv_length_var : std_logic_vector(12 downto 0);
    variable phy_rxstartend_ind_counter : std_logic_vector(1 downto 0);
  begin
    if hresetn = '0' then
      crc_init            <= '0';
      crc_data_valid      <= '0';
      phy_rxstartend_ind_int  <= '0';
      phy_data_ind_s      <= '0';
      rxv_service         <= (others => '0');
      error_stat          <= "00";
      format_error        <= '0';
      rate_error          <= '0';
      rate_error_int      <= '0';
      plcp_end            <= '0';
      length_ext          <= '0';
      psdu_end            <= '0';
      rx_psk_mode_o        <= '0';
      correct_header       <= '0';
      plcp_error           <= '0';
      decode_path_activate <= '0';
      rec_mode            <= "00";
      rxv_length_o        <= (others => '0');
      rxv_length_var      := (others => '0');
      rx_rate             <= (others => '0');
      rx_rate_saved       <= (others => '0');
      rx_length           <= (others => '0');
      bup_rxdata          <= (others => '0');
      data_to_crc         <= (others => '0');
      phy_rxstartend_ind_counter := "00";
    elsif (hclk'event and hclk = '1') then
      -- phy_rxstartend_ind_int stays high when we have a format error
      -- during 2 clock cycles.
      -- If phy_rxstartend_ind_int goes high with no format error
      -- it stays high until rx_end_state.
      if phy_rxstartend_ind_int = '1' and format_error = '1' then
        if phy_rxstartend_ind_counter = "10" then
          phy_rxstartend_ind_int <= '0';
        else
          phy_rxstartend_ind_counter := phy_rxstartend_ind_counter + '1';
        end if;
      end if;

      
      case rx_state is
        
        -- idle state
        when idle_state =>
          phy_rxstartend_ind_counter := "00";
          rx_psk_mode_o      <= '0';
          correct_header     <= '0';
          plcp_error         <= '0';
          phy_data_ind_s     <= '0';
          phy_rxstartend_ind_int <= '0';
          rec_mode           <= "00";
          if (cca_busy = '1') and (tx_activated = '0') then
            decode_path_activate <= '1';
          else
            decode_path_activate <= '0';
          end if;
            
        -- preamble state
        when preamble_state =>
          rate_error   <= '0';
          rate_error_int<= '0';
          format_error <= '0';
          plcp_end     <= '0';
          psdu_end     <= '0';
          error_stat  <= "00"; -- no error
          if (cca_busy = '0') then
--            error_stat <= "10"; -- carrier lost
          elsif (sfd_found = '1') then
            error_stat  <= "00"; -- no error
            crc_init    <= '1';
            if (preamble_type = '0') then
              rec_mode <= "01"; -- 2Mb/s if short preample
            end if;
            rx_psk_mode_o <= not preamble_type;
          end if;

        -- PLCP state
        when plcp_state =>
          crc_init       <= '0';
          crc_data_valid <= '0';
          if (cca_busy = '0') then
--            error_stat <= "10"; -- carrier lost
            plcp_error <= '1';
          elsif (format_error = '1') then
            error_stat <= "01"; -- format violation
            plcp_error <= '1';
          elsif (rate_error = '1') then
            error_stat <= "11"; -- unsupported rate
            plcp_error <= '1';
          end if;
          -- packet header extraction
          if (byte_ind = '1' and byte_ind_ff1 = '0') then
            case conv_integer(byte_counter) is
              -- signal (rate)
              when 0 =>
                crc_data_valid <= '1';
                data_to_crc    <= rx_data;
                if (preamble_type = '1') then      
                  rx_rate(3 downto 2) <= "01";             
                else                               
                  rx_rate(3 downto 2) <= "00";             
                end if;
                rx_rate_saved <= rx_data;
                case rx_data is
                  when "00001010" => -- 1Mb/s
                    rx_rate(1 downto 0) <= "00";
                    if (preamble_type = '0') then
                      format_error <= '1';
                      phy_rxstartend_ind_int <= '1';
                    end if;
                  when "00010100" => -- 2Mb/s
                    rx_rate(1 downto 0) <= "01";
                  when "00110111" => -- 5.5Mb/s
                    rx_rate(1 downto 0) <= "10";
                  when "01101110" => -- 11Mb/s
                    rx_rate(1 downto 0) <= "11";
                  when "11011100" => -- 22Mb/s
                    rx_rate(1 downto 0) <= "00";
                  when "00100001" => -- 33Mb/s next step look at service field
                    rx_rate(1 downto 0) <= "00";
                  when "00011110" => -- ERP-DSSS-OFDM next step look at service field
                    rate_error_int <= '1';
                    rx_rate(1 downto 0) <= "00";
                  when others =>
                    rx_rate(1 downto 0) <= "00";
                    format_error <= '1';
                    phy_rxstartend_ind_int <= '1';
                end case;     
                    
              -- service
              when 1 =>
                crc_data_valid <= '1';
                data_to_crc    <= rx_data;
                rxv_service    <= rx_data;
                length_ext     <= rx_data(7);
                -- if modulation is PBCC (not supported)
                -- we produce a format violation
                if (rx_data(3) = '1') and  -- Bit(3) of service field = 1
                  (rx_rate_saved = "00110111" or  -- 5.5Mb/s
                   rx_rate_saved = "01101110" or  -- 11Mb/s
                   rx_rate_saved = "11011100" or  -- 22Mb/s
                   rx_rate_saved = "00100001") then  -- 33Mb/s
                  rate_error_int <= '1';
                elsif rx_data(3) = '0' and
                  (rx_rate_saved = "11011100" or  -- 22Mb/s
                   rx_rate_saved = "00100001") then  -- 33Mb/s
                  format_error <= '1';
                  phy_rxstartend_ind_int <= '1';                  
                end if;
                
              -- LSB length
              when 2 =>
                crc_data_valid <= '1';
                data_to_crc    <= rx_data;
                rx_length(7 downto 0) <= rx_data;
              -- MSB length
              when 3 =>
                crc_data_valid <= '1';
                data_to_crc    <= rx_data;
                rx_length(15 downto 8) <= rx_data;

              -- LSB CRC
              when 4 =>
                case rx_rate(1 downto 0) is
                  when "00" => -- 1Mb/s
                    rxv_length_o <= rx_length(14 downto 3);
                    rxv_length_var := rx_length(15 downto 3);
                  when "01" => -- 2Mb/s
                    rxv_length_o <= rx_length(13 downto 2);
                    rxv_length_var := rx_length(14 downto 2);
                  when "10" => -- 5.5Mb/s
                    rxv_length_o <= rx_length_times11(15 downto 4);
                    rxv_length_var := rx_length_times11(16 downto 4);
                  when "11" => -- 11Mb/s
                    rxv_length_o <= rx_length_times11(14 downto 3) - length_ext;
                    rxv_length_var := rx_length_times11(15 downto 3) - length_ext;
                  when others =>
                end case;
                
                -- CRC check
                -- If we found previously a rate_error, and we find now a crc_error
                -- then the error is format_error.
                if (rx_data /= crc_data_1st) then
                  if rate_error_int = '1' then
                    rate_error_int <= '0';
                  end if;
                  format_error <= '1';
                  phy_rxstartend_ind_int <= '1';
                -- Rxlength check only of no rate error before.
                elsif rxlenchken = '0' and rate_error_int = '0' then
                  -- We should have 1<=rx_length<=4095 bytes
                  if rxv_length_var(12 downto 0) < "0000000000001"  -- <1
                    or rxv_length_var(12) = '1' then  -- >4095
                    format_error <= '1';
                    phy_rxstartend_ind_int <= '1';
                  end if;
                elsif rate_error_int = '0' then
                  -- We should have 14<= rxv_length_var <= rxmaxlength
                  if rxv_length_var(12 downto 0) < "0000000001110"
                    or rxv_length_var > '0' & rxmaxlength then
                  format_error <= '1';
                  phy_rxstartend_ind_int <= '1';
                  end if;
                end if;
                
              -- MSB CRC
              when 5 =>
                phy_rxstartend_ind_int <= '1';
                rec_mode <= rx_rate(1 downto 0);
                case rx_rate(1 downto 0) is
                  when "00" =>
                    rx_psk_mode_o <= '0';
                  when "01" =>
                    rx_psk_mode_o <= '1';
                  when "10" =>
                    rx_psk_mode_o <= '1';
                  when "11" =>
                    rx_psk_mode_o <= '1';
                  when others =>
                    null;
                end case;

                -- CRC check
                -- If we found previously a rate_error, and we find now a crc_error
                -- then the error is format_error
                -- otherwise we set rate_error to 1.
                if (rx_data /= crc_data_2nd) then
                  if rate_error_int = '1' then
                    rate_error_int <= '0';
                  end if;
                  format_error <= '1';
                elsif rate_error_int = '1' then
                  rate_error <= '1';
                elsif (format_error = '0') then
                  plcp_end <= '1';
                  correct_header     <= '1';
                end if;
                
              when others =>
                
            end case;
          end if;

        -- PSDU state
        when psdu_state =>
          crc_data_valid <= '0';
          correct_header <= '0';
          if (rx_rate(1) = '1') then --if CCK
          end if;
          if (byte_ind = '1' and byte_ind_ff1 = '0') then
            phy_data_ind_s <= not(phy_data_ind_s);
            bup_rxdata     <= rx_data;
          end if;
          if (byte_counter = rxv_length_o) then
            psdu_end <= '1';
          end if;
          
        -- RX end state
        when rx_end_state =>
          crc_data_valid       <= '0';
          plcp_error           <= '0';
          decode_path_activate <= '0';
          phy_rxstartend_ind_int   <= '0';

        when others => 

      end case;

      if phy_txstartend_req = '1' then
        crc_init                   <= '0';
        crc_data_valid             <= '0';
        phy_rxstartend_ind_int     <= '0';
        phy_data_ind_s             <= '0';
        rxv_service                <= (others => '0');
        error_stat                 <= "00";
        format_error               <= '0';
        plcp_end                   <= '0';
        length_ext                 <= '0';
        psdu_end                   <= '0';
        rx_psk_mode_o              <= '0';
        correct_header             <= '0';
        plcp_error                 <= '0';
        decode_path_activate       <= '0';
        rec_mode                   <= "00";
        rxv_length_o               <= (others => '0');
        rxv_length_var             := (others => '0');
        rx_rate                    <= (others => '0');
        rx_length                  <= (others => '0');
        bup_rxdata                 <= (others => '0');
        data_to_crc                <= (others => '0');
        phy_rxstartend_ind_counter := "00";
      end if;
    end if;
  end process rx_control_p;

  --------------------------------------------
  -- tx_activated falling edge detection
  --------------------------------------------
  tx_end_p : process(hresetn, hclk)
  begin
    if (hresetn = '0') then
      tx_activated_ff1 <= '0';
      tx_end_pulse     <= '0';
    elsif (hclk'event and hclk = '1') then
      tx_activated_ff1 <= tx_activated;
      if (tx_activated = '0') and (tx_activated_ff1 = '1') then
        tx_end_pulse <= '1';
      else
        tx_end_pulse <= '0';
      end if;
    end if;
  end process tx_end_p;

  --------------------------------------------
  -- Listen_start generation
  --------------------------------------------
  listen_p : process(hresetn, hclk)
  begin
    if (hresetn = '0') then
      listen_start_o <= '0';
    elsif (hclk'event and hclk = '1') then
      if ((rx_state = rx_end_state) and (cca_busy = '1')) or
         (tx_end_pulse = '1') then
        listen_start_o <= '1';
      else
        listen_start_o <= '0';
      end if;
    end if;
  end process listen_p;

  --------------------------------------------
  -- Diag ports.
  --------------------------------------------
  diag_p: process (rx_state)
  begin
    case rx_state is
      when idle_state =>
        rx_state_diag <= "000";
      when preamble_state =>
        rx_state_diag <= "001";
      when plcp_state =>
        rx_state_diag <= "010";
      when psdu_state =>
        rx_state_diag <= "011";
      when rx_end_state =>
        rx_state_diag <= "100";
      when others =>
        rx_state_diag <= "000";
    end case;
  end process diag_p;

end RTL;
