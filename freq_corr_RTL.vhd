
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: freq_corr.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.7  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Frequency correction
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/freq_corr/vhdl/rtl/freq_corr.vhd,v  
--  Log: freq_corr.vhd,v  
-- Revision 1.7  2004/12/20 08:54:21  Dr.C
-- #BugId:910#
-- Reduce freq_off_est to 20-bit.
--
-- Revision 1.6  2004/12/14 16:54:53  Dr.C
-- #BugId:810#
-- Added freq_corr_sum output for debug (link to register).
--
-- Revision 1.5  2003/09/05 08:19:58  Dr.B
-- empty the shift registers on sync_reset_n = '0'.
--
-- Revision 1.4  2003/08/07 16:19:15  Dr.C
-- Replaced LUT with a cordic
--
-- Revision 1.3  2003/04/11 08:56:44  Dr.C
-- Removed sample_cnt and replaced it with start_of_symbol
-- Debugged phase generation
--
-- Revision 1.2  2003/04/04 16:43:48  Dr.C
-- Removed fine_freq_data_ready_o and added fine_freq_update
--
-- Revision 1.1  2003/03/27 14:45:06  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--library cordic_rtl;
library work;

--library freq_corr_rtl;
library work;
--use freq_corr_rtl.freq_corr_pkg.all;
use work.freq_corr_pkg.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity freq_corr is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in std_logic;
    reset_n      : in std_logic;
    sync_reset_n : in std_logic;

    --------------------------------------
    -- I & Q
    --------------------------------------
    i_i : in  std_logic_vector(10 downto 0);
    q_i : in  std_logic_vector(10 downto 0);
    i_o : out std_logic_vector(10 downto 0);
    q_o : out std_logic_vector(10 downto 0);

    --------------------------------------
    -- Data control
    --------------------------------------
    data_valid_i            : in  std_logic;  -- Input data is valid
    data_ready_i            : in  std_logic;
    start_of_burst_i        : in  std_logic;  -- New burst starts 
    start_of_symbol_i       : in  std_logic;  -- Next data belongs to next symb.
    t1t2premux_data_ready_o : out std_logic;  -- Indicates to T1T2premux whether
                                         -- to fetch data from sample FIFO or not
    data_valid_o            : out std_logic;  -- Output data is valid
    start_of_burst_o        : out std_logic;  -- Start of burst for T1T2 demux
    start_of_symbol_o       : out std_logic;  -- Start of symbol for T1T2 demux

    --------------------------------------
    -- Frequency
    --------------------------------------
    coarsefreq_i        : in std_logic_vector(23 downto 0);  -- Coarse
                                                          -- frequency estimate
    coarsefreq_valid_i  : in std_logic;
    finefreq_i          : in std_logic_vector(23 downto 0);  -- Fine frequency
                                                             --  estimate
    finefreq_valid_i    : in std_logic;  -- Fine frequency input valid
 
    --------------------------------------
    -- Debug
    --------------------------------------
    freq_off_est        : out std_logic_vector(19 downto 0) -- coarse + fine
    );

end freq_corr;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of freq_corr is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant SYMBOL_LENGTH_CT   : integer := 64;
  constant SYMBOL_NUM_CT      : integer := 8;
  constant SAMPLE_NUM_CT      : integer := 128;
  constant NORM_CT : std_logic_vector(12 downto 0) := "0100110110111";


  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type FREQ_CORR_STATE_TYPE is ( no_coarse_e,       -- No correction
                                 coarse_updated_e,  -- Update coarse estimate
                                 wait_coarse_e,     -- Wait for estimate update
                                 t1t2_coarse_e,     -- T1T2 corrected with coarse
                                                    --  estimate
                                 t1t2_fine_e,       -- T1T2 corrected with fine
                                                    --  estimate
                                 wait_fine_e,       -- Wait for estimate update
                                 coarse_fine_e) ;   -- Correction with fine and
                                                    -- coarse estimate

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- State machine
  signal freq_corr_state      : FREQ_CORR_STATE_TYPE;
  signal freq_corr_next_state : FREQ_CORR_STATE_TYPE;

  -- NCO phase
  signal phase            : std_logic_vector(23 downto 0);
  signal phase_reg        : std_logic_vector(23 downto 0);
  signal init_phase       : std_logic_vector(23 downto 0);
  signal phase_added      : std_logic_vector(23 downto 0);
  signal phase_est_x1     : std_logic_vector(23 downto 0);
  signal phase_est_x16    : std_logic_vector(23 downto 0);
  signal phase_est_x128   : std_logic_vector(23 downto 0);
  signal phase_2_add      : std_logic_vector(23 downto 0);

  -- Control signals
  signal mod_coarsefreq   : std_logic;
  signal mod_finefreq     : std_logic;
  signal init_phase_reg   : std_logic;
  signal phase_x16        : std_logic;
  signal phase_x128       : std_logic;
  signal finefreq_update  : std_logic;
  signal internal_en      : std_logic;
  
  -- Cordic
  signal i_ff1          : std_logic_vector(10 downto 0);
  signal q_ff1          : std_logic_vector(10 downto 0);
  signal i_ff2          : std_logic_vector(10 downto 0);
  signal q_ff2          : std_logic_vector(10 downto 0);
  signal i_rot : std_logic_vector(12 downto 0);  -- I rotated
  signal q_rot : std_logic_vector(12 downto 0);  -- Q rotated
  signal i_norm : std_logic_vector(25 downto 0);  -- I normalized
  signal q_norm : std_logic_vector(25 downto 0);  -- Q normalized
  signal i_trunc : std_logic_vector(11 downto 0);  -- I rotated
  signal q_trunc : std_logic_vector(11 downto 0);  -- Q rotated
  signal null_vect : std_logic_vector(10 downto 0);  -- Null signal for inputs
                                                     -- not used in the cordic
  
  -- Counters
  signal symbol_cnt            : integer range 0 to SYMBOL_NUM_CT - 1;

  -- Control signals
  signal start_of_symbol_shift : std_logic_vector(4 downto 0);
  -- Shift register to delay start of symbol
  signal data_valid_shift      : std_logic_vector(4 downto 0);
                                        -- Shift register to delay data_valid

  signal start_of_burst_shift : std_logic_vector(4 downto 0);
  signal start_of_symbol_delay : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  null_vect <= (others => '0');

  -----------------------------------------------------------------------------
  -- Frequency correction state machine
  -----------------------------------------------------------------------------
  freq_corr_next_state_p : process (coarsefreq_valid_i, finefreq_update,
                                    finefreq_valid_i, freq_corr_state,
                                    start_of_burst_i, start_of_symbol_i,
                                    symbol_cnt)
  begin
    case freq_corr_state is
      
      -----------------------------------------
      -- No correction: samples are ignored
      -----------------------------------------
      when no_coarse_e =>
        if coarsefreq_valid_i = '1' then
          if start_of_burst_i = '1' then
            freq_corr_next_state <= t1t2_coarse_e;
          else
            freq_corr_next_state <= coarse_updated_e;
          end if;
        else
          if start_of_burst_i = '1' then
            freq_corr_next_state <= wait_coarse_e;
          else
            freq_corr_next_state <= no_coarse_e;
          end if;
        end if;

      -----------------------------------------
      -- Coarse estimate updated
      -----------------------------------------        
      when coarse_updated_e =>
        if start_of_burst_i = '1' then
          freq_corr_next_state <= t1t2_coarse_e;
        else
          freq_corr_next_state <= coarse_updated_e;
        end if;

      -----------------------------------------
      -- Wait for coarse frequency estimate
      -----------------------------------------                 
      when wait_coarse_e =>
        if coarsefreq_valid_i = '1' then
          freq_corr_next_state <= t1t2_coarse_e;
        else
          freq_corr_next_state <= wait_coarse_e;
        end if;

      -----------------------------------------
      -- T1 & T2 corrected with coarse estimate
      -----------------------------------------             
      when t1t2_coarse_e =>
        if start_of_symbol_i = '1' and symbol_cnt = 2 then
          if finefreq_valid_i = '1' then
            freq_corr_next_state <= t1t2_fine_e;
          elsif finefreq_update = '1' then
            freq_corr_next_state <= t1t2_fine_e;
          else
            freq_corr_next_state <= wait_fine_e;
          end if;
        else
           freq_corr_next_state <= t1t2_coarse_e;
        end if;

        
      -----------------------------------------
      -- Wait for fine estimate
      -----------------------------------------   
      when wait_fine_e =>
        if finefreq_valid_i = '1' then
          freq_corr_next_state <= t1t2_fine_e;
        else
          freq_corr_next_state <= wait_fine_e;
        end if;

      -----------------------------------------
      -- T1 & T2 corrected with coarse estimate
      -----------------------------------------        
      when t1t2_fine_e =>
        if start_of_symbol_i = '1' and symbol_cnt = 4 then
          freq_corr_next_state <= coarse_fine_e;
        else
          freq_corr_next_state <= t1t2_fine_e;
        end if;

      -----------------------------------------
      -- Correction with coarse and fine estimate
      -----------------------------------------        
      when coarse_fine_e =>
        freq_corr_next_state <= coarse_fine_e;
          
      when others =>
        freq_corr_next_state <= no_coarse_e;
        
    end case;
  end process freq_corr_next_state_p;


  -- Update the current state of the machine with the next state
  freq_corr_state_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      freq_corr_state <= no_coarse_e;
    elsif clk'event and clk = '1' then
        if sync_reset_n = '0' then
          freq_corr_state <= no_coarse_e;
        elsif internal_en = '1' then
          freq_corr_state <= freq_corr_next_state;
        end if;
    end if;
  end process freq_corr_state_p;


  
  -----------------------------------------------------------------------------
  -- Internal enable
  -----------------------------------------------------------------------------
  internal_en <= data_ready_i;                 
 
  
  phase_est_p: process (clk, reset_n)
  begin  
    if reset_n = '0' then             
      phase_est_x1 <= (others => '0');
      freq_off_est <= (others => '0');
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        phase_est_x1 <= (others => '0');
      elsif coarsefreq_valid_i = '1'  then
        phase_est_x1 <= coarsefreq_i;
      elsif start_of_symbol_i = '1' and symbol_cnt = 2 and
            (finefreq_valid_i = '1' or finefreq_update = '1') then
        phase_est_x1 <= finefreq_i;
      elsif start_of_symbol_i = '1' and symbol_cnt = 4  then
        phase_est_x1 <= finefreq_i + coarsefreq_i;
      elsif start_of_symbol_i = '1' and symbol_cnt = 5  then
        freq_off_est <= phase_est_x1(19 downto 0);
      end if;   
    end if;
  end process phase_est_p;
  
  -- Store updates on fine and coarse frequency estimate
  estim_update_p: process (clk, reset_n)
  begin  
    if reset_n = '0' then            
      finefreq_update   <= '0';
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        finefreq_update   <= '0';
      else
        if finefreq_valid_i  = '1' then
          finefreq_update <= '1';
        end if;
      end if;      
    end if;
  end process estim_update_p;


  -----------------------------------------------------------------------------
  -- This process controls the phase register which is called phase.
  -- The phase is incremented for every valid samples incoming and when the
  -- block is ready to process the data (internal_en active).
  -- There are some exceptions in the increment of the phase register:
  -- o After each guard interval (16 samples), 16*phase_est_x1 is added
  -- o After T1&T2 long preamble, (128+16)*phase_est_x1 is added, that
  --   corresponds to the long preamble length + the guard interval
  -----------------------------------------------------------------------------
  phase_all_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      phase_reg <= (others => '0');
    elsif clk'event and clk = '1' then
        if sync_reset_n = '0' then
          phase_reg <= (others => '0');
        elsif internal_en = '1' and
              freq_corr_state /= wait_coarse_e and
              freq_corr_state /= wait_fine_e   and
             (data_valid_i = '1' or init_phase_reg = '1' or
              (phase_x16 = '1' and data_valid_i = '1')) then
            phase_reg <= phase_2_add + phase;  
        end if;
    end if;
  end process phase_all_p;



  phase        <= init_phase   when init_phase_reg = '1' else
                      phase_reg ;
  
  phase_added  <= phase_est_x16 + phase_est_x128;  -- phase_est_x1 + 

  init_phase <= phase_added   when phase_x128 = '1' else
                      (others => '0');--phase_est_x1;

  phase_2_add <=  phase_est_x16 + phase_est_x1 when phase_x16 = '1'  else
                      phase_est_x1;

  -- Estimates multiplied
  phase_est_x16  <= phase_est_x1(19 downto 0) & "0000" ;
  phase_est_x128 <= phase_est_x1(16 downto 0) & "0000000" ;
  
  -- Control signals

  -- The phase register is reinitialized with the estimates when
  -- * the long preamble is processed for the 1st time with the coarse estimate
  -- * the long preamble is processed with the fine estimate
  -- * the rest of the data are processed
  
  init_phase_reg  <= '1' when start_of_symbol_delay = '1' and
                              (symbol_cnt = 1 or symbol_cnt = 3 or
                                                           symbol_cnt = 5) else
                    '0';
  -- For each OFDM symbol, the GI is removed 
  phase_x16      <= '1' when start_of_symbol_delay = '1' and symbol_cnt >= 6 else
                    '0';
  -- After the long preamble, the phase of the whole preamble is added.
  phase_x128     <= '1' when start_of_symbol_delay = '1' and symbol_cnt = 5 else
                    '0';

  

  -----------------------------------------------------------------------------
  -- Symbol count: counts up the number of symbols coming in.
  -----------------------------------------------------------------------------
  symbol_count_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      symbol_cnt <= 0;
    elsif clk'event and clk = '1' then
        if sync_reset_n = '0' then
          symbol_cnt <= 0;
        elsif internal_en = '1' and start_of_symbol_i = '1'
          and symbol_cnt < SYMBOL_NUM_CT - 1 then
          symbol_cnt <= symbol_cnt + 1;
        else
          symbol_cnt <= symbol_cnt;
        end if;
    end if;
  end process symbol_count_p;

  -----------------------------------------------------------------------------
  -- Control signals: process the outputs from the current state
  -----------------------------------------------------------------------------
  mod_coarsefreq <= '1' when (freq_corr_state = wait_coarse_e or
                              freq_corr_state = t1t2_coarse_e or
                              freq_corr_state = coarse_fine_e)
                    else '0';
   
  mod_finefreq <= '1' when (freq_corr_state = wait_fine_e or
                            freq_corr_state = wait_fine_e or
                            freq_corr_state = t1t2_fine_e)
                  else '0';

  t1t2premux_data_ready_o <= '0' when (freq_corr_state = wait_coarse_e or
                                       freq_corr_state = wait_fine_e )
                             else data_ready_i;


  -----------------------------------------------------------------------------
  -- Cordic
  -----------------------------------------------------------------------------
  cordic_1 : cordic
     generic map(
       data_length_g   => 11,
       angle_length_g  => 24,
       nbr_combstage_g => 4,
       nbr_pipe_g      => 3,
       nbr_input_g     => 1,
       scaling_g       => 1
       )                                                                  
     port map(
       clk     => clk,
       reset_n => reset_n,
       enable  => data_ready_i,
       z_in    => phase,
       -- inputs to be rotated :
       x0_in   => i_ff2,
       y0_in   => q_ff2,
       x1_in   => null_vect,
       y1_in   => null_vect,
       x2_in   => null_vect,
       y2_in   => null_vect,
       x3_in   => null_vect,
       y3_in   => null_vect,
       -- rotated output. They have been rotated of z_in :
       x0_out  => i_rot,
       y0_out  => q_rot,
       x1_out  => open,
       y1_out  => open,
       x2_out  => open,
       y2_out  => open,
       x3_out  => open,
       y3_out  => open
       );

  -----------------------------------------------------------------------------
  -- Delay on inputs:
  -- This delay is due to the clock cycles spent to update the phase and
  -- the one in the cordic to process the phase
  -----------------------------------------------------------------------------
  delay_p: process (clk, reset_n)
  begin
    if reset_n = '0' then            
      i_ff1 <= (others => '0');
      i_ff2 <= (others => '0');
      q_ff1 <= (others => '0');
      q_ff2 <= (others => '0');
       
    elsif clk'event and clk = '1' then
      if data_ready_i = '1' then
        i_ff1 <= i_i;
        i_ff2 <= i_ff1;
        q_ff1 <= q_i;
        q_ff2 <= q_ff1;            
      end if;

    end if;
  end process delay_p;

  -----------------------------------------------------------------------------
  -- Cordic output normalization
  -----------------------------------------------------------------------------
  i_norm <=  signed(i_rot)*signed(NORM_CT);
  q_norm <=  signed(q_rot)*signed(NORM_CT);
 
  -----------------------------------------------------------------------------
  -- Output saturation
  -----------------------------------------------------------------------------
  i_trunc <= i_norm(23 downto 12);
  q_trunc <= q_norm(23 downto 12);
 
  i_o <= sat_signed_slv(i_trunc,1);
  q_o <= sat_signed_slv(q_trunc,1);
   


  -- The cordic computes the rotated outputs in several clock
  -- cycles. For this reason the control signals associated to
  -- the data are delayed via a shift register.
  ctrl_shift_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then
      start_of_symbol_shift <= (others => '0');
      data_valid_shift      <= (others => '0');
      start_of_burst_shift  <= (others => '0');
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        -- empty the shift registers
        start_of_symbol_shift <= (others => '0');
        data_valid_shift      <= (others => '0');
        start_of_burst_shift  <= (others => '0');
      else
        if data_ready_i = '1' then
          start_of_symbol_shift(0)          <= start_of_symbol_i;
          start_of_symbol_shift(4 downto 1) <= start_of_symbol_shift(3 downto 0);
          start_of_burst_shift(0)           <= start_of_burst_i;
          start_of_burst_shift(4 downto 1)  <= start_of_burst_shift(3 downto 0);

          if freq_corr_state = t1t2_coarse_e or freq_corr_state = t1t2_fine_e or
            freq_corr_state = coarse_fine_e then

            data_valid_shift(0)          <= data_valid_i;
            data_valid_shift(4 downto 1) <= data_valid_shift(3 downto 0);
          end if;
        end if;
      end if;
    end if;
  end process ctrl_shift_p;

  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------
  outputs_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then  
      start_of_burst_o  <= '0';
      start_of_symbol_o <= '0';
      data_valid_o      <= '0';
      start_of_symbol_delay <= '0';
    elsif clk'event and clk = '1' then 
      start_of_burst_o     <= '0';
      if sync_reset_n = '0' then
        start_of_burst_o  <= '0';
        start_of_symbol_o <= '0';
        data_valid_o      <= '0';        

      elsif start_of_burst_shift(4) = '1' then
        start_of_burst_o     <= '1';
        --start_of_symbol_o    <= '1';
        start_of_symbol_o    <= '0';
      elsif start_of_symbol_shift(4) = '1' and data_ready_i = '1' then
        -- start of symbol
        data_valid_o      <= '0';
        start_of_symbol_o <= '1';

      elsif data_ready_i = '1' then
        start_of_symbol_o <= '0';   -- 1-> 0 only when ready
        if freq_corr_state = t1t2_coarse_e or freq_corr_state = t1t2_fine_e
           or freq_corr_state = coarse_fine_e  then
          data_valid_o      <= data_valid_shift(4);
        
        end if;
      end if;
      
      if internal_en = '1' and start_of_symbol_i = '1' and
        (freq_corr_state /= wait_coarse_e and freq_corr_state /= coarse_updated_e)
      then
        start_of_symbol_delay <= '1';
      elsif data_valid_i = '1' then
        start_of_symbol_delay <= '0';
      end if;
    end if;
  end process outputs_p;


end RTL;
