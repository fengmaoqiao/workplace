

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: residual_dc_offset.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.3  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Residual DC offset estimation and compensation.
--               This block is used in the Base-Band part of the Rx .11a path.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/residual_dc_offset/vhdl/rtl/residual_dc_offset.vhd,v  
--  Log: residual_dc_offset.vhd,v  
-- Revision 1.3  2005/03/11 10:14:16  Dr.C
-- #BugId:1120#
-- Removed i/q_ff1 and cleaned procedure.
--
-- Revision 1.2  2005/01/26 09:23:09  Dr.C
-- #BugId:986#
-- Updated Kalman filter coeff and resynchronized m_i and m_q for synthesis.
--
-- Revision 1.1  2005/01/19 17:08:51  Dr.C
-- #BugId:737#
-- First revision.
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--library residual_dc_offset_rtl;
library work;
--use residual_dc_offset_rtl.residual_dc_offset_pkg.all;
use work.residual_dc_offset_pkg.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity residual_dc_offset is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic; -- Module clock. 80 MHz
    reset_n      : in  std_logic; -- Asynchronous reset
    sync_reset_n : in  std_logic; -- Synchronous reset.

    --------------------------------------
    -- I & Q
    --------------------------------------
    i_i          : in  std_logic_vector(10 downto 0);
    q_i          : in  std_logic_vector(10 downto 0);
    data_valid_i : in  std_logic; -- toggle when a new data is available
    --
    i_o          : out std_logic_vector(10 downto 0);
    q_o          : out std_logic_vector(10 downto 0);
    data_valid_o : out std_logic; -- toggle when a new data is available

    --------------------------------------
    -- Registers
    --------------------------------------
    dcoffset_disb : in  std_logic; -- Disable the dc offset correction
    
    --------------------------------------
    -- Synchronization
    --------------------------------------
    cp2_detected  : in  std_logic   -- Synchronisation found
    );

end residual_dc_offset;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of residual_dc_offset is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type IQ_ARR_TYPE is array(15 downto 0) of std_logic_vector(10 downto 0);
                                                         -- IQ delay line

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant NULL_EIGHT_US_CT : std_logic_vector(3 downto 0) := "1111";-- 0.8 us
  constant K_MAX_CT : std_logic_vector(5 downto 0) := "111111";  -- 63
  constant FOUR_THIRD_CT : std_logic_vector(8 downto 0) := "101010101"; -- 4/3
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal data_valid_ff1 : std_logic;
  signal data_valid     : std_logic;
  -- I & Q downsampled at 20 MHz
  signal i_down : std_logic_vector(10 downto 0);
  signal q_down : std_logic_vector(10 downto 0);
  ----------------------------------------
  -- DC offset estimation
  ----------------------------------------
  -- Delay line for dc offset estimation
  signal dc_delay_line_i : IQ_ARR_TYPE;
  signal dc_delay_line_q : IQ_ARR_TYPE;
  -- Accumulation for DC offset estimation
  signal dc_accu_i       : std_logic_vector(14 downto 0);
  signal dc_accu_q       : std_logic_vector(14 downto 0);
  -- dc_accu after FF.
  signal dc_accu_i_ff1   : std_logic_vector(14 downto 0);
  signal dc_accu_q_ff1   : std_logic_vector(14 downto 0);
  -- 2*0.8 us delay for averaging
  signal i_delay_av      : std_logic_vector(14 downto 0);
  signal i_delay_av_ff1  : std_logic_vector(14 downto 0);
  signal sel_i_delay_av  : std_logic_vector(14 downto 0);
  signal q_delay_av      : std_logic_vector(14 downto 0);
  signal q_delay_av_ff1  : std_logic_vector(14 downto 0);
  signal sel_q_delay_av  : std_logic_vector(14 downto 0);
  -- Accumulation for averaging
  signal av_accu_i       : std_logic_vector(16 downto 0);
  signal av_accu_q       : std_logic_vector(16 downto 0);
  signal av_accu_i_ff1   : std_logic_vector(16 downto 0);
  signal av_accu_q_ff1   : std_logic_vector(16 downto 0);
  -- Counts up the estimates accumulated
  signal estim_counter   : std_logic_vector(2 downto 0);
  -- 2*0.8 us delay to count estimates
  signal delay_reached   : std_logic;
  -- Accu multiplied with kav
  signal av_accu_i_mul_int : std_logic_vector(26 downto 0);
  signal av_accu_q_mul_int : std_logic_vector(26 downto 0);
  signal av_accu_i_mul     : std_logic_vector(18 downto 0);
  signal av_accu_q_mul     : std_logic_vector(18 downto 0);
  -- Average DC offset value
  signal m_i               : std_logic_vector(10 downto 0);
  signal m_q               : std_logic_vector(10 downto 0);
  -- Indicates the first symbol of long preamble
  signal firstlongsymb_n     : std_logic;
  signal firstlongsymb_ff1_n : std_logic;
  -- Index of DC estimate
  signal k_index : std_logic_vector(5 downto 0);
  -- Multiplicative constants
  signal k       : std_logic_vector(9 downto 0);
  signal km      : std_logic_vector(9 downto 0);
  -- DC offset value
  signal i_dc_off_estim_o    : std_logic_vector(10 downto 0);
  signal q_dc_off_estim_o    : std_logic_vector(10 downto 0);
  -- Intermediate value of dc
  signal i_dc_off_estim_int  : std_logic_vector(10 downto 0);
  signal q_dc_off_estim_int  : std_logic_vector(10 downto 0);
  -- Intermediate combinatory value of dc
  signal i_dc_off_estim_comb : std_logic_vector(10 downto 0);
  signal q_dc_off_estim_comb : std_logic_vector(10 downto 0);
  -- DC offset after offset estimation
  signal i_dc_off_estim_kal_int : std_logic_vector(22 downto 0);
  signal dc_off_estim_kal       : std_logic_vector(22 downto 0);
  -- Multiplexed data to compute dc offset estimation
  signal dc_op_in     : std_logic_vector(10 downto 0);
  signal dc_op_in_mul : std_logic_vector(21 downto 0);
  signal dc_op_in_int : std_logic_vector(21 downto 0);
  -- Multiplicative constants
  signal k_mux  : std_logic_vector(9 downto 0);
  -- Compensation to apply to i and q
  signal i_comp : std_logic_vector(10 downto 0);
  signal q_comp : std_logic_vector(10 downto 0);
  ----------------------------------------
  -- Counters and enable
  ----------------------------------------
  -- 20 Mhz enable
  signal fifty_ns_en           : std_logic;
  -- 0.8 us enable <-> symbol length
  signal symbol_en             : std_logic;
  signal symbol_en_ff1         : std_logic;
  signal symbol_en_ff2         : std_logic;
  signal symbol_en_ff3         : std_logic;
  -- Synchronisation found
  signal sync_found            : std_logic;
  -- 0.8 us counter
  signal null_us_eigth_counter : std_logic_vector(3 downto 0);
  -- Resync cp2_detected
  signal cp2_detected_ff1      : std_logic;
  signal cp2_detected_ff2      : std_logic;
  signal cp2_detected_ff3      : std_logic;
  -- Pulse for sync found
  signal sync_pulse            : std_logic;
  -- 20 Mhz enable
  signal res_fifty_ns_en       : std_logic;
  -- 20 MHz counter
  signal res_fifty_ns_counter  : std_logic_vector(1 downto 0);
  signal res_fifty_ns_counter_en : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  
  -----------------------------------------------------------------------------
  -- Downsampling
  -----------------------------------------------------------------------------
  -- Data are downsampled at 20 MS/s
  downsamp_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      i_down <= (others => '0');
      q_down <= (others => '0');
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        i_down <= (others => '0');
        q_down <= (others => '0');
      elsif fifty_ns_en = '1' then
        i_down <= i_i;
        q_down <= q_i;
      end if;
    end if;
  end process downsamp_p;
  
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- DC offset estimation
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  ------------------------------------------------
  -- Delay line 16 stages
  ------------------------------------------------
  dc_delay_line_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      dc_delay_line_i <= (others => (others => '0'));
      dc_delay_line_q <= (others => (others => '0'));
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        dc_delay_line_i <= (others => (others => '0'));
        dc_delay_line_q <= (others => (others => '0'));
      elsif fifty_ns_en = '1' then
        dc_delay_line_i(15 downto 1) <= dc_delay_line_i(14 downto 0);
        dc_delay_line_i(0) <= i_down;
        dc_delay_line_q(15 downto 1) <= dc_delay_line_q(14 downto 0);
        dc_delay_line_q(0) <= q_down;
      end if;
    end if;
  end process dc_delay_line_p;

  ------------------------------------------------
  -- Accumulation on a symbol period
  ------------------------------------------------
  dc_accu_i <= sxt(i_down,dc_accu_i'length) -
               sxt(dc_delay_line_i(15),dc_accu_i'length) +
               dc_accu_i_ff1;
  dc_accu_q <= sxt(q_down,dc_accu_q'length) -
               sxt(dc_delay_line_q(15),dc_accu_q'length) +
               dc_accu_q_ff1;
 

  dc_accu_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      dc_accu_i_ff1 <= (others => '0');
      dc_accu_q_ff1 <= (others => '0');
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        dc_accu_i_ff1 <= (others => '0');  
        dc_accu_q_ff1 <= (others => '0');
      elsif fifty_ns_en = '1' then
        dc_accu_i_ff1 <= dc_accu_i;
        dc_accu_q_ff1 <= dc_accu_q;
      end if;
   end if;
  end process dc_accu_p;
  
  
  ------------------------------------------------
  -- Averaging
  ------------------------------------------------
  averaging_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      i_delay_av          <= (others => '0');
      i_delay_av_ff1      <= (others => '0');
      q_delay_av          <= (others => '0');
      q_delay_av_ff1      <= (others => '0');
      av_accu_i_ff1       <= (others => '0');
      av_accu_q_ff1       <= (others => '0');
      delay_reached       <= '0';
      firstlongsymb_n     <= '0';
      firstlongsymb_ff1_n <= '0';
      estim_counter       <= (others => '0');
    elsif clk'event and clk = '1' then
      
      -- Accumulation
      if sync_reset_n = '0' or sync_pulse = '1' or
        (estim_counter = "000" and sync_found = '1' and symbol_en = '1') then
        av_accu_i_ff1  <= (others => '0');
        av_accu_q_ff1  <= (others => '0');
      elsif symbol_en = '1' and (estim_counter < "011" or sync_found = '1') then
        av_accu_i_ff1  <= av_accu_i;
        av_accu_q_ff1  <= av_accu_q;
      end if;
      
      -- 2*0.8 us delay to discard the 2 last estimates from cp1 and cp2
      if sync_reset_n = '0' then
        i_delay_av     <= (others => '0');
        i_delay_av_ff1 <= (others => '0');
        q_delay_av     <= (others => '0');
        q_delay_av_ff1 <= (others => '0');
      elsif symbol_en = '1' and (estim_counter < "011" or sync_found = '1') then
        i_delay_av     <= dc_accu_i;
        i_delay_av_ff1 <= i_delay_av;
        q_delay_av     <= dc_accu_q;
        q_delay_av_ff1 <= q_delay_av;
      end if;
        
      -- Estimates counter:
      -- It is reset on packet start
      --                synchronisation
      --             after the 2 first counts to eliminate cp1 and cp2
      --             after 4*0.8 us on the long preamble signals
      --             after 5*0.8 us otherwise
      if sync_reset_n = '0' or sync_pulse = '1' or
        (estim_counter = "001" and delay_reached = '0' and symbol_en = '1') or
        (estim_counter = "011" and firstlongsymb_n = '0' and sync_found = '1'
         and  symbol_en = '1') or
        (estim_counter = "100" and sync_found = '1' and symbol_en = '1') then
        estim_counter   <= (others => '0');

        if sync_reset_n = '0' then
          delay_reached   <= '0';
        elsif estim_counter = "001" and delay_reached = '0' and symbol_en = '1'
          then
          -- Delay of 2*0.8 reached
          delay_reached   <= '1';
        end if;
        
        -- First long preamble symbol processed
        if sync_found = '1' then
          firstlongsymb_n <= '1';
        elsif sync_reset_n = '0' then
          firstlongsymb_n <= '0';
          firstlongsymb_ff1_n <= '0';
        end if;

      elsif symbol_en = '1' and
        ((estim_counter < "100" and sync_found = '1') or estim_counter < "011")
        then
        -- Not more than 4 values can be accumulated before synchronisation
        -- During the first estimation, maximum 4 symbols are accumulated
        case estim_counter is
          when "000"  => estim_counter <= "001";
          when "001"  => estim_counter <= "010";
          when "010"  => estim_counter <= "011";
          when "011"  => estim_counter <= "100";
          when others => null;
        end case;
        firstlongsymb_ff1_n <= firstlongsymb_n;
      end if;
      
    end if;
  end process averaging_p;

  -- Select delay_av for accumulation
  sel_i_delay_av <= i_delay_av when sync_found = '1' else i_delay_av_ff1;
  sel_q_delay_av <= q_delay_av when sync_found = '1' else q_delay_av_ff1;

  -- Accumulation
  av_accu_i <= av_accu_i_ff1 + sxt(sel_i_delay_av,av_accu_i'length);
  av_accu_q <= av_accu_q_ff1 + sxt(sel_q_delay_av,av_accu_q'length);

  -- Normalization by 4/3
  av_accu_i_mul_int <= signed(av_accu_i) * unsigned(FOUR_THIRD_CT);
  av_accu_q_mul_int <= signed(av_accu_q) * unsigned(FOUR_THIRD_CT);

  ------------------------------------------------
  -- Determines kav value according to the number
  -- of estimates accumulated
  ------------------------------------------------
  kav_lut_p: process (av_accu_i, av_accu_i_mul_int, av_accu_q,
                      av_accu_q_mul_int, estim_counter, sync_found)
  begin
    if sync_found = '1' then
      av_accu_i_mul <= sxt(av_accu_i,av_accu_i_mul'length);
      av_accu_q_mul <= sxt(av_accu_q,av_accu_q_mul'length);
    else
      case estim_counter is
        when "000"   => av_accu_i_mul <= av_accu_i & "00";
                        av_accu_q_mul <= av_accu_q & "00";
        when "001"   => av_accu_i_mul <= av_accu_i(16) & av_accu_i & '0';
                        av_accu_q_mul <= av_accu_q(16) & av_accu_q & '0';
        when "010"   => av_accu_i_mul <= av_accu_i_mul_int(26 downto 8);
                        av_accu_q_mul <= av_accu_q_mul_int(26 downto 8);
        when "011"   => av_accu_i_mul <= sxt(av_accu_i,av_accu_i_mul'length);
                        av_accu_q_mul <= sxt(av_accu_q,av_accu_q_mul'length);
        when others  => av_accu_i_mul <= sxt(av_accu_i,av_accu_i_mul'length);
                        av_accu_q_mul <= sxt(av_accu_q,av_accu_q_mul'length);
      end case;
    end if;
  end process kav_lut_p;


  ------------------------------------------------
  -- Kalman
  ------------------------------------------------
  kalman_coeff_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      k_index <= (others => '0');
    elsif clk'event and clk = '1' then
      if sync_pulse ='1' then
        k_index <= (others => '0');
      elsif (k_index < K_MAX_CT) and  symbol_en = '1' and
         ((estim_counter = "000" and firstlongsymb_n = '1' and
            firstlongsymb_ff1_n = '0'and sync_found = '1')
         or
         (estim_counter = "100" and sync_found = '1')) then
        k_index <= k_index + '1';
      end if;
    end if;
  end process kalman_coeff_p;

  -- Kalman LUT
  kalman_lut_1: kalman_lut
    port map (
      k_index => k_index,
      k_o     => k,
      km_o    => km
      );

  ------------------------------------------------
  -- Compute DC offset estimation
  ------------------------------------------------
  dc_offset_estim_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      i_dc_off_estim_o       <= (others => '0');
      q_dc_off_estim_o       <= (others => '0');
      i_dc_off_estim_int     <= (others => '0');
      q_dc_off_estim_int     <= (others => '0');
      i_dc_off_estim_kal_int <= (others => '0');
      dc_op_in_int           <= (others => '0');
      
    elsif clk'event and clk = '1' then
    
      if symbol_en_ff2 = '1' then
        i_dc_off_estim_kal_int <= dc_off_estim_kal;
      end if;
      
      if symbol_en_ff1 = '1' or symbol_en_ff3 = '1' then
        dc_op_in_int <= dc_op_in_mul;
      end if;
      
      -- Computes DC offset estimation
      if sync_reset_n = '0' then
        i_dc_off_estim_o   <= (others => '0');
        q_dc_off_estim_o   <= (others => '0');
        i_dc_off_estim_int <= (others => '0');
        q_dc_off_estim_int <= (others => '0');
      elsif sync_pulse = '1' then
        i_dc_off_estim_o   <= m_i;
        q_dc_off_estim_o   <= m_q;
        i_dc_off_estim_int <= m_i;
        q_dc_off_estim_int <= m_q;

      elsif sync_found = '1' and symbol_en = '1' and
        (estim_counter = "100" or
         (firstlongsymb_n = '1' and firstlongsymb_ff1_n = '0' and
          estim_counter = "000" )) then

        if estim_counter = "100" then
          -- DC(1) not put on the output but kept to compute DC(2)
          i_dc_off_estim_o <= i_dc_off_estim_comb;
          q_dc_off_estim_o <= q_dc_off_estim_comb;
        end if;
        i_dc_off_estim_int <= i_dc_off_estim_comb;
        q_dc_off_estim_int <= q_dc_off_estim_comb;
      end if;
    end if;
  end process dc_offset_estim_p;
  
  -- Computes DC offset estimation (combinatory)
  i_dc_off_estim_comb <= i_dc_off_estim_kal_int(20 downto 10) +
                         i_dc_off_estim_kal_int(9);
  q_dc_off_estim_comb <= dc_off_estim_kal(20 downto 10) +
                         dc_off_estim_kal(9);
  
  -- M(n)
  m_iq_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      m_i <= (others => '0');
      m_q <= (others => '0');
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        m_i <= (others => '0');
        m_q <= (others => '0');
      else
        m_i <= sat_round_signed_slv(av_accu_i_mul,2,6);
        m_q <= sat_round_signed_slv(av_accu_q_mul,2,6);
      end if;
    end if;
  end process m_iq_p;

  -- Multiplex data to compute DC offset estimation
  -- operation to compute is DC(n+1) = DC(n).Km(n) + K(n).M(n)
  -- for I and Q
  --  * I is computed first and Q after
  --  * DC(n).Km(n) is computed before K(n).M(n)
  dc_op_in <= i_dc_off_estim_int when symbol_en_ff1 = '1' else
              q_dc_off_estim_int when symbol_en_ff3 = '1' else
              m_i when symbol_en_ff2 = '1' else
              m_q;

  -- Multiplex k from Kalman LUT
  k_mux <= km when (symbol_en_ff1 = '1' or symbol_en_ff3 = '1') else k;
  
  -- Kalman Multiplication : Mi*Ki | DCi*Kmi
  dc_op_in_mul <= signed(dc_op_in) * unsigned(k_mux);
  
  -- Addition : DC(n+1) = DC(n).Km(n) + K(n).M(n)
  dc_off_estim_kal <= sxt(dc_op_in_mul,dc_off_estim_kal'length) +
                      sxt(dc_op_in_int,dc_off_estim_kal'length);
  

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- DC offset compensation
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  -- Select averaging / kalman filter compensation value
  i_comp  <= i_dc_off_estim_o when sync_found = '1' else m_i;
  q_comp  <= q_dc_off_estim_o when sync_found = '1' else m_q;


  -- Compensation
  dc_comp_p: process (reset_n, clk)
    variable i_v : std_logic_vector(11 downto 0);
    variable q_v : std_logic_vector(11 downto 0);
  begin
    if reset_n = '0' then
      i_v := (others => '0');
      q_v := (others => '0');
      i_o <= (others => '0');
      q_o <= (others => '0');
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        i_v := (others => '0');
        q_v := (others => '0');
        i_o <= (others => '0');
        q_o <= (others => '0');
      elsif dcoffset_disb = '1' then
        -- By-pass data
        i_o <= i_i;
        q_o <= q_i;
      elsif fifty_ns_en = '1' then
        -- compensation on 11-bit
        i_v := sxt(i_i,i_v'length) - sxt(i_comp,i_v'length);
        q_v := sxt(q_i,q_v'length) - sxt(q_comp,q_v'length);
        -- saturation on 10-bit
        i_o <= sat_signed_slv(i_v, 1);
        q_o <= sat_signed_slv(q_v, 1);
      end if;
    end if;
  end process dc_comp_p;
 
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- Counters and control
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  ------------------------------------------------
  -- Keep synchronisation found
  ------------------------------------------------
  sync_found_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      sync_found   <= '0';
      cp2_detected_ff1 <= '0';
      cp2_detected_ff2 <= '0';
      cp2_detected_ff3 <= '0';
    elsif clk'event and clk = '1' then
      cp2_detected_ff1 <= cp2_detected;
      cp2_detected_ff2 <= cp2_detected_ff1;
      cp2_detected_ff3 <= cp2_detected_ff2;
      
      if sync_reset_n = '0' then
        sync_found <= '0';
      elsif sync_pulse = '1' then
        sync_found <= '1';
      end if;
    end if;
  end process sync_found_p;
  
  sync_pulse <= not cp2_detected_ff3 and cp2_detected_ff2;

  ------------------------------------------------
  -- Generates a pulse each 50 ns
  ------------------------------------------------
  enable_20_mhz_p: process (reset_n, clk)
  begin 
    if reset_n = '0' then
      data_valid_ff1 <= '0';
    elsif clk'event and clk = '1' then
      -- data_valid_ff1 must not be synchronously reseted
      -- else it will generate glitch
      data_valid_ff1 <= data_valid_i;
    end if;
  end process enable_20_mhz_p;

  fifty_ns_en <= (data_valid_i xor data_valid_ff1)
    when sync_reset_n = '1' else '0';

  ------------------------------------------------
  -- Generates toggle on data_valid_o
  ------------------------------------------------
  data_valid_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      data_valid     <= '0';
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        data_valid     <= '0';
      elsif fifty_ns_en = '1' then
        data_valid <= not data_valid;
      end if;
    end if;
  end process data_valid_p;

  data_valid_o <= data_valid;

  ------------------------------------------------
  -- Generates a pulse each 50 ns
  -- The counter is reset when synchronisation if
  -- found.
  ------------------------------------------------
  res_enable_20_mhz_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      res_fifty_ns_counter    <= (others => '0');
      res_fifty_ns_counter_en <= '0';
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        res_fifty_ns_counter_en <= '0';
        res_fifty_ns_counter <= (others => '0');
      else
        -- Enable counter with the first data
        if fifty_ns_en = '1' then
          res_fifty_ns_counter_en <= '1';
        end if;
        
        -- Control of the counter
        if sync_pulse = '1' then
          res_fifty_ns_counter <= "00";
        elsif res_fifty_ns_counter = "11" then
          res_fifty_ns_counter <= (others => '0');
        elsif res_fifty_ns_counter_en = '1' then
          case res_fifty_ns_counter is
            when "00"   => res_fifty_ns_counter <= "01";
            when "01"   => res_fifty_ns_counter <= "10";
            when "10"   => res_fifty_ns_counter <= "11";
            when "11"   => res_fifty_ns_counter <= "00";
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process res_enable_20_mhz_p;

  res_fifty_ns_en <= '1' when res_fifty_ns_counter = "11" else '0';

  ------------------------------------------------
  -- Generates a pulse 0.8 us
  ------------------------------------------------
  enable_0_8_us_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      null_us_eigth_counter <= (others => '0');
      symbol_en_ff1 <= '0';
      symbol_en_ff2 <= '0';
      symbol_en_ff3 <= '0';
    elsif clk'event and clk = '1' then

      -- Pulse delayed
      if sync_reset_n = '0' then
        symbol_en_ff1 <= '0';
        symbol_en_ff2 <= '0';
        symbol_en_ff3 <= '0';
      else
        symbol_en_ff1 <= symbol_en;
        symbol_en_ff2 <= symbol_en_ff1;
        symbol_en_ff3 <= symbol_en_ff2;
      end if;
      
      -- 0.8 us counter
      if sync_pulse = '1' or sync_reset_n = '0' then
        null_us_eigth_counter <= (others => '0');
      elsif res_fifty_ns_en = '1' then
        if null_us_eigth_counter = NULL_EIGHT_US_CT then
          null_us_eigth_counter <= (others => '0');
        else
          -- Samples are counted up
          null_us_eigth_counter <= null_us_eigth_counter + '1';
        end if;
      end if;
    end if;
  end process enable_0_8_us_p;

  symbol_en <= '1' when 
      ((null_us_eigth_counter = NULL_EIGHT_US_CT and sync_found = '0') or
       (null_us_eigth_counter = "0000" and sync_found = '1')) and
        res_fifty_ns_en = '1'
          else '0';


  ------------------------------------------------
  -- Assign global signals
  ------------------------------------------------
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  residual_dc_accu_i_gbl <= dc_accu_i;
--  residual_dc_accu_q_gbl <= dc_accu_q;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
    
    
end RTL;
