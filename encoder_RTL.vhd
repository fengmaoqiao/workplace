
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: encoder.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block encodes the OFDM symbols SIGNAL and DATA fields
--               with a convolutional encoder of coding rate 1/2. Higher rates
--               for the DATA field (2/3 or 3/4) will be derived from it later
--               using puncturing.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/encoder/vhdl/rtl/encoder.vhd,v  
--  Log: encoder.vhd,v  
-- Revision 1.2  2004/12/14 10:42:30  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.1  2003/03/13 14:37:59  Dr.A
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
entity encoder is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i     : in  std_logic;
    data_valid_i : in  std_logic;
    data_ready_i : in  std_logic;
    marker_i     : in  std_logic;
    --
    data_valid_o : out std_logic;
    data_ready_o : out std_logic;
    marker_o     : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    data_i       : in  std_logic; -- Data to encode.
    --
    x_o          : out std_logic; -- x encoded data at coding rate 1/2.
    y_o          : out std_logic  -- y encoded data at coding rate 1/2.
    
  );

end encoder;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of encoder is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal data_ready_int : std_logic; -- Internal data_ready_o.
  signal shiftreg       : std_logic_vector(5 downto 0); -- Shift register.
  signal init_shiftreg  : std_logic; -- '1' to reset the shift register.
  -- Counter to detect 'start of signal' marker.
  signal marker_cnt     : std_logic_vector(1 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- The encoder has zero cycles latency, therefore data_valid_i is propagated
  -- to data_valid_o, depending on enable_i and data_ready_i, in the same cycle.
  -- This holds for all control and data signals.    
  data_valid_o  <= data_valid_i;
  marker_o      <= marker_i;

  -- The encoder is ready to accept new data when the following block is ready
  -- (data_ready_i) or when there is no incoming data to process (data_valid_i).
  data_ready_int  <= '1' when (data_ready_i = '1' or data_valid_i = '0') else
                     '0';
  data_ready_o  <= data_ready_int;


  -- The following markers are received: 'start of signal', 'start of service
  -- field' and 'end of burst'. The marker_cnt counter is used to know which
  -- marker has been received last.
  marker_counter_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      marker_cnt  <= (others => '0');
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        marker_cnt  <= (others => '0');
      else
  -- The control path is enabled in TX state (enable_i) when the encoder is
  -- ready to accept data (data_ready_int).
        if marker_i = '1' and data_ready_int = '1' then
          if marker_cnt = "10" then -- marker for end of burst reached
            marker_cnt <= "00";
          else
            marker_cnt <= marker_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process marker_counter_p;

  -- The shift register must be reset to start encoding the SIGNAL field.
  -- It does not need to be reset before the DATA encoding: this has already
  -- been done by encoding the six '0' tail bits of SIGNAL.
  init_shiftreg <= '1' when marker_i = '1' and marker_cnt = "00" else
                   '0';

  -- The incoming data is shifted in a 6bits register, reset by init_shiftreg.
  shift_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      shiftreg       <= (others => '0');
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        shiftreg     <= (others => '0');
      else
        if init_shiftreg = '1' then
          shiftreg   <= (others => '0');
        elsif data_valid_i = '1' and data_ready_int = '1' then
          shiftreg <= shiftreg(4 downto 0) & data_i;
        end if;
      end if;
    end if;
  end process shift_p;

  -- For encoding, use industry-standard generator polynomials.
  x_o <= data_i xor shiftreg(1) xor shiftreg(2) xor shiftreg(4) xor shiftreg(5);
  y_o <= data_i xor shiftreg(0) xor shiftreg(1) xor shiftreg(2) xor shiftreg(5);

end RTL;
