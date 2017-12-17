
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: mapper.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Mapping of the OFDM data to the constellation defined by the
--              coding rate.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/mapper/vhdl/rtl/mapper.vhd,v  
--  Log: mapper.vhd,v  
-- Revision 1.3  2004/12/14 10:50:39  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.2  2003/03/26 13:05:35  Dr.A
-- Added start of sgnal marker.
--
-- Revision 1.1  2003/03/13 14:58:17  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity mapper is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk            : in  std_logic; -- Module clock
    reset_n        : in  std_logic; -- asynchronous reset
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i       : in  std_logic; -- TX path enable.
    data_valid_i   : in  std_logic; -- High when input data is valid.
    data_ready_i   : in  std_logic; -- Next block ready to accept data.
    start_signal_i : in  std_logic; -- 'start of signal' marker.
    end_burst_i    : in  std_logic; -- 'end of burst' marker.
    qam_mode_i     : in  std_logic_vector(1 downto 0);
    null_carrier_i : in  std_logic; -- '1' when data for null carrier
    --
    data_valid_o   : out std_logic; -- High when output data is valid.
    data_ready_o   : out std_logic; -- Block ready to accept data.
    start_signal_o : out std_logic; -- 'start of signal' marker.
    end_burst_o    : out std_logic; -- 'end of burst' marker.
    --------------------------------------
    -- Data
    --------------------------------------
    data_i         : in  std_logic_vector(5 downto 0);
    -- Mapped data.
    data_i_o       : out std_logic_vector(7 downto 0);
    data_q_o       : out std_logic_vector(7 downto 0)

    
  );

end mapper;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of mapper is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Constants for coding rate.
  constant QAM64_CT         : std_logic_vector( 1 downto 0) := "00"; 
  constant QAM16_CT         : std_logic_vector( 1 downto 0) := "10"; 
  constant QPSK_CT          : std_logic_vector( 1 downto 0) := "01"; 
  constant BPSK_CT          : std_logic_vector( 1 downto 0) := "11";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal data_i_int     : std_logic_vector(7 downto 0);
  signal data_q_int     : std_logic_vector(7 downto 0);
  signal data_valid_int : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- A different normalization factor is applied on the output. It depends on
  -- the modulation mode, and is used to obtain the same average power for all 
  -- mappings.
  mapping_p : process (data_i, qam_mode_i, null_carrier_i)
  begin
    
    -- Send '0' on outputs for null carriers.
    if null_carrier_i = '1' then
      data_i_int <= (others => '0');
      data_q_int <= (others => '0');
    else
      case qam_mode_i is
        when QAM64_CT => 
          case data_i(5 downto 3) is
            when "000" =>
              data_i_int <= "10011110"; -- -98
            when "001" =>
              data_i_int <= "10111010"; -- -70
            when "010" =>
              data_i_int <= "11110010"; -- -14
            when "011" =>
              data_i_int <= "11010110"; -- -42
            when "100" =>
              data_i_int <= "01100010"; -- 98
            when "101" =>
              data_i_int <= "01000110"; -- 70
            when "110" =>
              data_i_int <= "00001110"; -- 14
            when others =>
              data_i_int <= "00101010"; -- 42
          end case;

          case data_i(2 downto 0) is
            when "000" =>
              data_q_int <= "10011110"; -- -98
            when "001" =>
              data_q_int <= "10111010"; -- -70
            when "010" =>
              data_q_int <= "11110010"; -- -14
            when "011" =>
              data_q_int <= "11010110"; -- -42
            when "100" =>
              data_q_int <= "01100010"; -- 98
            when "101" =>
              data_q_int <= "01000110"; -- 70
            when "110" =>
              data_q_int <= "00001110"; -- 14
            when others =>
              data_q_int <= "00101010"; -- 42
          end case;

        when QPSK_CT =>
          case data_i(5) is
            when '0' =>
              data_i_int <= "11000000"; -- -64
            when others =>
              data_i_int <= "01000000"; -- 64
          end case;
          
          case data_i(2) is
            when '0' =>
              data_q_int <= "11000000"; -- -64
            when others =>
              data_q_int <= "01000000"; -- 64
          end case;
          
        when QAM16_CT =>
          case data_i(5 downto 4) is
            when "00" =>
              data_i_int <= "10101010"; -- -86
            when "01" =>
              data_i_int <= "11100011"; -- -29
            when "10" =>
              data_i_int <= "01010110"; -- 86
            when others =>
              data_i_int <= "00011101"; -- 29
          end case;
          
          case data_i(2 downto 1) is
            when "00" =>
              data_q_int <= "10101010"; -- -86
            when "01" =>
              data_q_int <= "11100011"; -- -29
            when "10" =>
              data_q_int <= "01010110"; -- 86
            when others =>
              data_q_int <= "00011101"; -- 29
          end case;
          
        when others => -- BPSK_CT
          data_q_int <= (others => '0');
          case data_i(5) is
            when '0' =>
              data_i_int <= "10100101";
            when others =>
              data_i_int <= "01011011";
          end case;

      end case;
    end if;
  end process mapping_p;

  -- This process registers data outputs and control signals.
  output_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_i_o       <= (others => '0');
      data_q_o       <= (others => '0');
      data_valid_int <= '0';
      start_signal_o <= '0';
      end_burst_o    <= '0';
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        data_i_o       <= (others => '0');
        data_q_o       <= (others => '0');
        data_valid_int <= '0';
        start_signal_o <= '0';
        end_burst_o    <= '0';
      else
        if data_ready_i = '1' or data_valid_int = '0' then
          data_i_o       <= data_i_int;
          data_q_o       <= data_q_int;
          data_valid_int <= data_valid_i;
          start_signal_o <= start_signal_i;
          end_burst_o    <= end_burst_i;
        end if;
      end if;
    end if;
  end process output_p;

  -- Assign output ports.
  data_valid_o <= data_valid_int;
  data_ready_o <= data_ready_i or not data_valid_int;


end RTL;
