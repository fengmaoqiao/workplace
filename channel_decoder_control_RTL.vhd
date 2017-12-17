
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: channel_decoder_control.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.8  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Control of the Channel decoder
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/channel_decoder/vhdl/rtl/channel_decoder_control.vhd,v  
--  Log: channel_decoder_control.vhd,v  
-- Revision 1.8  2005/03/23 09:00:21  Dr.C
-- #BugId:704#
-- Re-init control_next_state when unsupported_length.
--
-- Revision 1.7  2005/03/04 10:32:04  Dr.C
-- #BugId:1119#
-- Updated MAX_LENGTH_DECODE_CT to 4095.
--
-- Revision 1.6  2004/12/14 17:47:55  Dr.C
-- #BugId:704#
-- Added unsupported length port.
--
-- Revision 1.5  2003/05/16 16:45:51  Dr.J
-- Changed the type of field_length_i
--
-- Revision 1.4  2003/03/31 12:48:02  Dr.C
-- Added unsigned library.
--
-- Revision 1.3  2003/03/31 12:18:37  Dr.C
-- Updated constants.
--
-- Revision 1.2  2003/03/28 15:37:03  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.1  2003/03/24 10:17:43  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

 
--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity channel_decoder_control is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n               : in  std_logic;  -- Async Reset
    clk                   : in  std_logic;  -- Clock
    sync_reset_n          : in  std_logic;  -- Software reset

    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    start_of_burst_i      : in  std_logic;  -- Initialization signal
    signal_field_valid_i  : in  std_logic;  -- Signal field ready
    end_of_data_i         : in  std_logic;  -- Data field ready
    data_ready_deintpun_i : in  std_logic;  -- Data ready signal
    --
    start_of_field_o      : out std_logic;  -- Init submodules
    signal_field_valid_o  : out std_logic;  -- Signal field valid
    data_ready_o          : out std_logic;  -- Data ready signal

    --------------------------------------
    -- Enable Signals
    --------------------------------------
    enable_i             : in  std_logic;   -- incoming enable signal
    --
    enable_deintpun_o    : out std_logic;   -- enable for deintpun
    enable_viterbi_o     : out std_logic;   -- enable for viterbi
    enable_signal_o      : out std_logic;   -- enable for signal field decoding
    enable_data_o        : out std_logic;   -- enable for data output

    --------------------------------------
    -- Rgister Interface
    --------------------------------------
    length_limit_i       : in  std_logic_vector(11 downto 0);
    rx_length_chk_en_i   : in  std_logic;

    --------------------------------------
    -- Data Interface
    --------------------------------------
    signal_field_i    : in  std_logic_vector(SIGNAL_FIELD_LENGTH_CT-1 downto 0);
    smu_table_i       : in  std_logic_vector(15 downto 0);
    --
    smu_partition_o      : out std_logic_vector(1 downto 0);
    field_length_o       : out std_logic_vector(15 downto 0);
    qam_mode_o           : out std_logic_vector(1 downto 0);
    pun_mode_o           : out std_logic_vector(1 downto 0);
    parity_error_o       : out std_logic;
    unsupported_rate_o   : out std_logic;
    unsupported_length_o : out std_logic
  );

end channel_decoder_control;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of channel_decoder_control is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type CONTROL_STATE_T is (IDLE,
                           SIGNAL_START,
                           SIGNAL_DECODE,
                           DATA_START,
                           DATA_DECODE);

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- length limit enhance disable
  constant MIN_LENGTH_DECODE_CT     : std_logic_vector(11 downto 0) := "000000000001";
  constant MAX_LENGTH_DECODE_CT     : std_logic_vector(11 downto 0) := "111111111111";
  -- length limit enhance enable
  constant MIN_LENGTH_DECODE_CHK_CT : std_logic_vector(11 downto 0) := "000000001110";

  constant QAM_MODE_SIGNAL_CT      : std_logic_vector(1 downto 0) := "11";
  constant PUN_MODE_SIGNAL_CT      : std_logic_vector(1 downto 0) := "00";
  constant SMU_PARTITION_SIGNAL_CT : std_logic_vector(1 downto 0) := "00";
  constant FIELD_LENGTH_SIGNAL_CT  : FIELD_LENGTH_T := SIGNAL_FIELD_LENGTH_CT +
                                                    TAIL_BITS_CT;

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal control_curr_state : CONTROL_STATE_T;
  signal control_next_state : CONTROL_STATE_T;
  
  signal qam_mode_data      : std_logic_vector(1 downto 0);
  signal pun_mode_data      : std_logic_vector(1 downto 0);
  signal smu_partition_data : std_logic_vector(1 downto 0);
  signal field_length_data  : FIELD_LENGTH_T;

  signal parity             : std_logic;
  signal parity_error       : std_logic;
  signal unsupported_rate   : std_logic;
  signal unsupported_length : std_logic;
  signal min_length_decode  : std_logic_vector(11 downto 0);
  signal max_length_decode  : std_logic_vector(11 downto 0);

  ------------------------------------------------------------------------------
  -- Functions
  ------------------------------------------------------------------------------
  function even_parity (arg: std_logic_vector) return std_logic is
    variable r : std_logic;
  begin
    r := '0';
    for i in arg'range loop
      r := r xor arg(i);
    end loop;
    return r;
  end even_parity;
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin


  --------------------------------------
  -- Field sequential process
  --------------------------------------
  field_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      control_curr_state <= IDLE;
    elsif clk = '1' and clk'event then -- rising clock edge
      if sync_reset_n = '0' then       --  synchronous reset (active low)
        control_curr_state <= IDLE;
      elsif enable_i = '1' then        --  enable condition (active high)
        control_curr_state <= control_next_state;
      end if;
    end if;
  end process field_sequential_p;


  --------------------------------------
  -- Field combinational process
  --------------------------------------
  field_combinational_p : process(control_curr_state, enable_i,
                                  start_of_burst_i, signal_field_valid_i,
                                  end_of_data_i, parity_error,
                                  unsupported_rate, data_ready_deintpun_i,
                                  unsupported_length)
  begin
    enable_deintpun_o    <= '0';
    enable_viterbi_o     <= '0';
    enable_signal_o      <= '0';
    enable_data_o        <= '0';

    start_of_field_o     <= '0';
    signal_field_valid_o <= '0';
    data_ready_o         <= '1';
    
    control_next_state <= control_curr_state;

    case control_curr_state is
       
      when SIGNAL_START =>
        start_of_field_o    <= '1';            
        enable_deintpun_o   <= enable_i;
        enable_viterbi_o    <= enable_i;
        enable_signal_o     <= enable_i;
        data_ready_o        <= '0';
        if start_of_burst_i = '1' then
          control_next_state <= SIGNAL_START;
        else
          control_next_state <= SIGNAL_DECODE;
        end if;

      when SIGNAL_DECODE =>
        enable_deintpun_o <=  enable_i;
        enable_viterbi_o  <=  enable_i;
        enable_signal_o   <=  enable_i;
        data_ready_o      <= data_ready_deintpun_i;
        if start_of_burst_i = '1' then
          control_next_state <= SIGNAL_START;
        elsif signal_field_valid_i = '1' then
          control_next_state <= DATA_START;
        end if;

      when DATA_START =>
        signal_field_valid_o <= '1';
        start_of_field_o     <= '1';            
        enable_deintpun_o    <= enable_i;
        enable_viterbi_o     <= enable_i;
        enable_data_o        <= enable_i;
        data_ready_o         <= '0';
        if start_of_burst_i = '1' then
          control_next_state <= SIGNAL_START;
        elsif parity_error = '1' or 
              unsupported_rate = '1' or
              unsupported_length = '1' then
          control_next_state <= IDLE;
        else
          control_next_state <= DATA_DECODE;
        end if;

      when DATA_DECODE  =>
        enable_deintpun_o <= enable_i;
        enable_viterbi_o  <= enable_i;
        enable_data_o     <= enable_i;
        data_ready_o      <= data_ready_deintpun_i;
        if start_of_burst_i = '1' then
          control_next_state <= SIGNAL_START;
        elsif end_of_data_i = '1' then
          control_next_state <= IDLE;
        end if;

      when others => 
        if start_of_burst_i = '1' then
          control_next_state <= SIGNAL_START;
        else
          control_next_state <= IDLE;
        end if;
        
    end case;

  end process field_combinational_p;


  --------------------------------------
  -- Set datafield parameter process
  --------------------------------------
  set_datafield_parameter_p : process (signal_field_i, smu_table_i)
  begin
    unsupported_rate <= '0';
    
    case signal_field_i(3 downto 0) is
    
      when "1011" =>                   --  6Mbit/s BPSK 1/2
        qam_mode_data      <= "11";
        pun_mode_data      <= "00";
        smu_partition_data <= smu_table_i( 1 downto 0);
     
      when "1111" =>                   --  9Mbit/s BPSK 3/4
        qam_mode_data      <= "11";
        pun_mode_data      <= "11";
        smu_partition_data <= smu_table_i( 3 downto 2);
     
      when "1010" =>                   -- 12Mbit/s QPSK 1/2
        qam_mode_data      <= "10";
        pun_mode_data      <= "00";
        smu_partition_data <= smu_table_i( 5 downto 4);
     
      when "1110" =>                   -- 18Mbit/s QPSK 3/4
        qam_mode_data      <= "10";
        pun_mode_data      <= "11";
        smu_partition_data <= smu_table_i( 7 downto 6);
     
      when "1001" =>                   -- 24Mbit/s 16QAM 1/2
        qam_mode_data      <= "01";
        pun_mode_data      <= "00";
        smu_partition_data <= smu_table_i( 9 downto 8);
     
      when "1101" =>                   -- 36Mbit/s 16QAM 3/4
        qam_mode_data      <= "01";
        pun_mode_data      <= "11";
        smu_partition_data <= smu_table_i(11 downto 10);
     
      when "1000" =>                   -- 48Mbit/s 64QAM 2/3
        qam_mode_data      <= "00";
        pun_mode_data      <= "10";
        smu_partition_data <= smu_table_i(13 downto 12);
     
      when "1100" =>                   -- 54Mbit/s 64QAM 3/4
        qam_mode_data      <= "00";
        pun_mode_data      <= "11";
        smu_partition_data <= smu_table_i(15 downto 14);
     
      when others =>              -- data rate not supported
        qam_mode_data      <= "11";
        pun_mode_data      <= "00";
        smu_partition_data <= smu_table_i( 1 downto 0);
        unsupported_rate   <= '1';
        
    end case;
    
  end process set_datafield_parameter_p;

  ---------------------------------------
  -- Check length field parameter process
  ---------------------------------------
  check_lengthfield_parameter_p : process (signal_field_i, min_length_decode,
                                           max_length_decode)
  begin
    unsupported_length <= '0';
    if (signal_field_i(16 downto 5) < min_length_decode or
        signal_field_i(16 downto 5) > max_length_decode) then
      unsupported_length <= '1';
    end if;
  end process check_lengthfield_parameter_p;

  -- Min & max limit for length decoding
  min_length_decode <= MIN_LENGTH_DECODE_CHK_CT when rx_length_chk_en_i = '1'
                  else MIN_LENGTH_DECODE_CT;
  max_length_decode <= length_limit_i when rx_length_chk_en_i = '1'
                  else MAX_LENGTH_DECODE_CT;

  -- Parity check
  parity       <= even_parity(signal_field_i(SIGNAL_FIELD_LENGTH_CT-2 downto 0));
  parity_error <= parity xor signal_field_i(SIGNAL_FIELD_LENGTH_CT-1); 

  -- length of data burst in bits including service_field and tail_bits
  field_length_data <= conv_integer(signal_field_i(16 downto 5)&"000")
                       + SERVICE_FIELD_LENGTH_CT
                       + TAIL_BITS_CT;

  --------------------------------------
  -- Write burst parameter process
  --------------------------------------
  write_burst_parameter_p : process (clk, reset_n)
  begin
    if reset_n = '0' then                 -- asynchronous reset (active low)
      qam_mode_o           <= QAM_MODE_SIGNAL_CT;
      pun_mode_o           <= PUN_MODE_SIGNAL_CT;
      smu_partition_o      <= SMU_PARTITION_SIGNAL_CT;
      field_length_o       <= conv_std_logic_vector(FIELD_LENGTH_SIGNAL_CT,16);
      parity_error_o       <= '0';
      unsupported_rate_o   <= '0';
      unsupported_length_o <= '0';
    elsif clk'event and clk = '1' then    -- rising clock edge
      if sync_reset_n = '0' or (enable_i = '1' and start_of_burst_i = '1') then
        qam_mode_o           <= QAM_MODE_SIGNAL_CT;
        pun_mode_o           <= PUN_MODE_SIGNAL_CT;
        smu_partition_o      <= SMU_PARTITION_SIGNAL_CT;
        field_length_o       <= conv_std_logic_vector(FIELD_LENGTH_SIGNAL_CT,16);
        parity_error_o       <= '0';
        unsupported_rate_o   <= '0';
        unsupported_length_o <= '0';
      elsif enable_i = '1' and signal_field_valid_i = '1' then
        qam_mode_o           <= qam_mode_data;
        pun_mode_o           <= pun_mode_data;
        smu_partition_o      <= smu_partition_data;
        field_length_o       <= conv_std_logic_vector(field_length_data,16);
        parity_error_o       <= parity_error;
        unsupported_rate_o   <= unsupported_rate;
        unsupported_length_o <= unsupported_length;
      end if;
    end if;
  end process write_burst_parameter_p;

end RTL;
