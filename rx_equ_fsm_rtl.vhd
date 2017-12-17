

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_equ_fsm.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.3  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Equalizer state machine.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_equ/vhdl/rtl/rx_equ_fsm.vhd,v  
--  Log: rx_equ_fsm.vhd,v  
-- Revision 1.3  2003/03/28 15:53:15  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.2  2003/03/17 17:06:25  Dr.F
-- removed debug signals.
--
-- Revision 1.1  2003/03/17 10:01:21  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--library rx_equ_rtl;
library work;
--use rx_equ_rtl.rx_equ_pkg.all;
use work.rx_equ_pkg.all;


--------------------------------------------
-- Entity
--------------------------------------------
entity rx_equ_fsm is
  port (
    clk                 : in    std_logic; --Clock input
    reset_n             : in    std_logic; --Asynchronous negative reset
    sync_reset_n        : in    std_logic; --'0': The control state of the module will be reset
    i_i                 : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    q_i                 : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    data_valid_i        : in    std_logic; 
    data_ready_o        : out   std_logic; 
    ich_i               : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    qch_i               : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    data_valid_ch_i     : in    std_logic; 
    data_ready_ch_o     : out   std_logic; 
    burst_rate_i        : in    std_logic_vector(BURST_RATE_WIDTH_CT - 1 downto 0); 
    signal_field_valid_i: in    std_logic; 
    data_ready_i        : in    std_logic; 
    start_of_burst_i    : in    std_logic; 
    start_of_symbol_i   : in    std_logic; 
    start_of_burst_o    : out   std_logic;
    start_of_symbol_o   : out   std_logic; 

    i_saved_o           : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    q_saved_o           : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); 
    ich_saved_o         : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    qch_saved_o         : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); 
    module_enable_o     : out   std_logic;

    burst_rate_o        : out   std_logic_vector(BURST_RATE_WIDTH_CT - 1 downto 0);
    burst_rate_4_hist_o : out   std_logic_vector(BURST_RATE_WIDTH_CT - 1 downto 0);
    pipeline_en_o       : out   std_logic;
    cumhist_en_o        : out   std_logic;
    ctr_input_o         : out   std_logic_vector(1 downto 0);

    current_symb_o      : out   std_logic_vector(1 downto 0);

    data_valid_last_stage_i      : in    std_logic; 
    start_of_symbol_last_stage_i : in    std_logic
  );

end rx_equ_fsm;


--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_equ_fsm is

  type STATE_T is (hist_eval, wait_symbol, soft_eval, wait_data, wait_ch);

  signal i_saved                  : std_logic_vector (FFT_WIDTH_CT-1 downto 0);
  signal q_saved                  : std_logic_vector (FFT_WIDTH_CT-1 downto 0);
  signal i_saved_d                : std_logic_vector (FFT_WIDTH_CT-1 downto 0);
  signal q_saved_d                : std_logic_vector (FFT_WIDTH_CT-1 downto 0);
  signal ich_saved                : std_logic_vector (CHMEM_WIDTH_CT-1 downto 0);
  signal qch_saved                : std_logic_vector (CHMEM_WIDTH_CT-1 downto 0);
  signal qch_saved_d              : std_logic_vector (CHMEM_WIDTH_CT-1 downto 0);
  signal ich_saved_d              : std_logic_vector (CHMEM_WIDTH_CT-1 downto 0);
  signal state_d                  : STATE_T;
  signal state                    : STATE_T;
  signal cnt_d                    : integer range 1 to EQU_SYMB_LENGTH_CT;
  signal cnt                      : integer range 1 to EQU_SYMB_LENGTH_CT;
  signal store_burst_rate_d       : std_logic_vector (BURST_RATE_WIDTH_CT - 1 downto 0);
  signal store_burst_rate         : std_logic_vector (BURST_RATE_WIDTH_CT - 1 downto 0);
  signal burst_rate_d             : std_logic_vector (BURST_RATE_WIDTH_CT - 1 downto 0);
  signal burst_rate_tmp           : std_logic_vector (BURST_RATE_WIDTH_CT - 1 downto 0);
  signal my_data_ready_d          : std_logic;
  signal my_data_ready            : std_logic;
  signal my_data_ready_ch_d       : std_logic;
  signal my_data_ready_ch         : std_logic;
  signal start_of_symbol_save_d   : std_logic;
  signal start_of_symbol_save     : std_logic;
  signal start_of_symbol_d        : std_logic;
  signal start_of_burst_save_d    : std_logic;
  signal start_of_burst_save      : std_logic;
  signal start_of_burst_d         : std_logic;
  signal module_enable_tmp        : std_logic;
  signal current_symb_d           : std_logic_vector (1 downto 0);
  signal current_symb_tmp         : std_logic_vector (1 downto 0);
  signal pipeline_en_tmp          : std_logic;

begin


-------------------------------------------------------------------
-- Control flow
-------------------------------------------------------------------

  -- Internal enable generation
  -- if data_ready_i is 1, my block can operate.
  -- if data_ready_i is 0 my block can still operate if it is not ready to
  -- output data or a marker yet.
  module_enable_tmp  <= data_ready_i or 
              (not (start_of_symbol_last_stage_i  or data_valid_last_stage_i ));


  -- Data ready generation
  data_ready_o    <= my_data_ready    and module_enable_tmp; 
  data_ready_ch_o <= my_data_ready_ch and module_enable_tmp; 

  --------------------------------------------
  -- store_burst_rate generation
  --------------------------------------------
  store_burst_rate_p : process (burst_rate_i, signal_field_valid_i, 
                                store_burst_rate)
  begin
    if signal_field_valid_i = '1' then
       store_burst_rate_d <= burst_rate_i;
    else
       store_burst_rate_d <= store_burst_rate;
    end if;
  end process store_burst_rate_p;
  
  burst_rate_4_hist_o <= store_burst_rate;

  --------------------------------------------
  -- Main control fsm
  --------------------------------------------
  fsm_ctr_p : process (state, cnt, start_of_symbol_i, data_valid_i, 
                       data_valid_ch_i, ich_i, qch_i, i_i, q_i, burst_rate_tmp,
                       store_burst_rate, i_saved, q_saved, ich_saved, 
                       qch_saved, start_of_symbol_save, start_of_burst_save, 
                       current_symb_tmp)
  begin
   
    -- default 
    state_d                <= state;
    my_data_ready_d        <= '0';
    my_data_ready_ch_d     <= '0';
    cnt_d                  <= cnt;
    cumhist_en_o           <= '0';
    pipeline_en_tmp        <= '0';
    start_of_symbol_d      <= '0';
    start_of_symbol_save_d <= start_of_symbol_save;
    start_of_burst_d       <= '0';
    start_of_burst_save_d  <= start_of_burst_save;
    burst_rate_d           <= burst_rate_tmp;
    ctr_input_o            <= DEFAULT_INPUT_CT;
    
    i_saved_d              <= i_saved;
    q_saved_d              <= q_saved;
    ich_saved_d            <= ich_saved;
    qch_saved_d            <= qch_saved;

    current_symb_d         <= current_symb_tmp;
    
    case state is

      when hist_eval =>   
        my_data_ready_ch_d <= '1';
        if (data_valid_ch_i = '1') then
          cumhist_en_o          <= '1';
          if cnt = EQU_SYMB_LENGTH_CT then 
            -- go to signal field symbol
            current_symb_d     <= SIGNAL_FIELD_CT; 
            state_d            <= wait_symbol;
            my_data_ready_ch_d <= '0';
            cnt_d              <= 1;
          else
            cnt_d              <= cnt + 1;
          end if;
        end if;

      when wait_symbol =>   
        my_data_ready_d    <= '1';
        if (start_of_symbol_i = '1') then
          state_d                <= soft_eval;
          start_of_symbol_save_d <= '1';
          my_data_ready_ch_d     <= '1';
          burst_rate_d           <= store_burst_rate;
        end if;

      when soft_eval =>   
        my_data_ready_d    <= '1';
        my_data_ready_ch_d <= '1';

        -- sample data and channel estimate value both available
        if (data_valid_i = '1' and data_valid_ch_i = '1') then
          pipeline_en_tmp        <= '1';
          -- load start_of_symbol in the pipeline
          -- it is 1 clock cycle ahead the data
          start_of_symbol_d      <= start_of_symbol_save; 
                                                          
          start_of_symbol_save_d <= '0';  -- restore '0';
          -- load start_of_burst in the pipeline
          -- it is 1 clock cycle ahead the data
          start_of_burst_d       <= start_of_burst_save; 
                                                          
          start_of_burst_save_d  <= '0';   -- restore '0';
          if cnt = EQU_SYMB_LENGTH_CT then 
            -- go to data field
            current_symb_d     <= DATA_FIELD_CT;         
            state_d            <= wait_symbol;
            my_data_ready_ch_d <= '0';
            cnt_d              <= 1;
          else
            cnt_d              <= cnt + 1;
          end if;

        -- only channel estimate value available
        elsif (data_valid_i= '0' and data_valid_ch_i= '1') then
          state_d            <= wait_data;
          my_data_ready_ch_d <= '0';
          ich_saved_d        <= ich_i;
          qch_saved_d        <= qch_i;
          
        -- only sample data available
        elsif (data_valid_i= '1' and data_valid_ch_i= '0') then
          state_d          <= wait_ch;
          my_data_ready_d  <= '0';
          i_saved_d        <= i_i;
          q_saved_d        <= q_i;
        end if;

      -- wait for sample data availability
      when wait_data => 
        my_data_ready_d    <= '1';
        -- tell the stage0 to take saved ch data instead of direct ch data.
        ctr_input_o        <= SAVED_CHMEM_CT;
        if (data_valid_i='1') then
          pipeline_en_tmp        <= '1';
          -- load start_of_symbol in the pipeline
          -- it is 1 clock cycle ahead the data
          start_of_symbol_d      <= start_of_symbol_save;
          start_of_symbol_save_d <= '0';                  -- restore '0';

          -- load start_of_burst in the pipeline
          -- it is 1 clock cycle ahead the data
          start_of_burst_d      <= start_of_burst_save;
          start_of_burst_save_d <= '0';                  -- restore '0';
          state_d               <= soft_eval;
          my_data_ready_ch_d    <= '1';
          if cnt = EQU_SYMB_LENGTH_CT then 
           state_d            <= wait_symbol;
           my_data_ready_ch_d <= '0';
           cnt_d              <= 1;
          else
            cnt_d             <= cnt + 1;
          end if;
        end if;
      
      -- wait for channel estimate value availability
      when wait_ch => 
        my_data_ready_ch_d <= '1';
        -- tell the stage0 to take saved data instead of direct data.
        ctr_input_o          <= SAVED_DATA_CT;
        if (data_valid_ch_i = '1') then
          pipeline_en_tmp        <= '1';
          -- load start_of_symbol in the pipeline
          -- it is 1 clock cycle ahead the data
          start_of_symbol_d      <= start_of_symbol_save;
          start_of_symbol_save_d <= '0';                  -- restore '0';

          -- load start_of_burst in the pipeline
          -- it is 1 clock cycle ahead the data
          start_of_burst_d      <= start_of_burst_save;
          start_of_burst_save_d <= '0';                  -- restore '0';
          state_d               <= soft_eval;
          my_data_ready_d       <= '1';
          if cnt = EQU_SYMB_LENGTH_CT then 
            state_d            <= wait_symbol;
            my_data_ready_ch_d <= '0';
            cnt_d              <= 1;
          else
            cnt_d              <= cnt + 1;
          end if;
        end if;

      when others =>  
        null;

    end case;

  end process fsm_ctr_p;


  --------------------------------------------
  -- Sequencial part
  --------------------------------------------
  seq_p: process( reset_n, clk )
    begin
    if reset_n = '0' then
      state                <= hist_eval;
      current_symb_tmp     <= PREAMBLE_CT;
      burst_rate_tmp       <= RATE_6_CT;
      store_burst_rate     <= RATE_6_CT;
      cnt                  <= 1;
      my_data_ready        <='0';
      my_data_ready_ch     <='1';

      start_of_symbol_save <='0';
      start_of_symbol_o    <='0';
      start_of_burst_save  <='0';
      start_of_burst_o     <='0';

      i_saved              <= (others =>'0');
      q_saved              <= (others =>'0');
      ich_saved            <= (others =>'0');
      qch_saved            <= (others =>'0');

    elsif clk'event and clk='1' then
      if (sync_reset_n = '0') then
        state                <= hist_eval;
        current_symb_tmp     <= PREAMBLE_CT;
        burst_rate_tmp       <= RATE_6_CT;
        store_burst_rate     <= RATE_6_CT;
        cnt                  <= 1;
        my_data_ready        <='0';
        my_data_ready_ch     <='1';

        start_of_symbol_save <='0';
        start_of_symbol_o    <='0';
        start_of_burst_save  <='0';
        start_of_burst_o     <='0';

        i_saved              <= (others =>'0');
        q_saved              <= (others =>'0');
        ich_saved            <= (others =>'0');
        qch_saved            <= (others =>'0');

      elsif start_of_burst_i = '1' then
        state                <= hist_eval;
        current_symb_tmp     <= PREAMBLE_CT;
        burst_rate_tmp       <= RATE_6_CT;
        store_burst_rate     <= RATE_6_CT;
        cnt                  <= 1;
        my_data_ready        <= '0';
        my_data_ready_ch     <= '1';

        start_of_symbol_save <= '0';
        start_of_symbol_o    <= '0';
        start_of_burst_save  <= '1';
        start_of_burst_o     <= '0';

        i_saved              <= (others =>'0');
        q_saved              <= (others =>'0');
        ich_saved            <= (others =>'0');
        qch_saved            <= (others =>'0');

      else
        store_burst_rate    <= store_burst_rate_d;
        if module_enable_tmp = '1' then
          state                <= state_d;
          current_symb_tmp     <= current_symb_d;
          burst_rate_tmp       <= burst_rate_d;
          cnt                  <= cnt_d;
          my_data_ready        <= my_data_ready_d;
          my_data_ready_ch     <= my_data_ready_ch_d;

          i_saved              <= i_saved_d;
          q_saved              <= q_saved_d;
          ich_saved            <= ich_saved_d;
          qch_saved            <= qch_saved_d;
          start_of_symbol_save <= start_of_symbol_save_d;
          start_of_symbol_o    <= start_of_symbol_d;
          start_of_burst_save  <= start_of_burst_save_d;
          start_of_burst_o     <= start_of_burst_d;
        end if;
      end if;
    end if;
  end process seq_p;

  -- dummy assignment
  module_enable_o <= module_enable_tmp;
  i_saved_o       <= i_saved;
  q_saved_o       <= q_saved;
  ich_saved_o     <= ich_saved;
  qch_saved_o     <= qch_saved;
  burst_rate_o    <= burst_rate_tmp;
  current_symb_o  <= current_symb_tmp;
  pipeline_en_o   <= pipeline_en_tmp;

end rtl;
