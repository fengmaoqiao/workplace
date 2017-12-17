
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: master_deseria.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.8   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Deserialize data for rx_filter (from wild_rf)
-- or prdata from WiLD RF registers 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/master_hiss/vhdl/rtl/master_deseria.vhd,v  
--  Log: master_deseria.vhd,v  
-- Revision 1.8  2004/07/16 07:35:48  Dr.B
-- add cca_add_info feature
--
-- Revision 1.7  2004/03/03 11:12:56  Dr.B
-- initialize alternate_mode.
--
-- Revision 1.6  2003/11/20 11:17:18  Dr.B
-- output on mem_reg.
--
-- Revision 1.5  2003/10/30 14:36:07  Dr.B
-- add deserialization of the CCA.
--
-- Revision 1.4  2003/10/09 08:22:26  Dr.B
-- simplify start condition.
--
-- Revision 1.3  2003/09/25 12:20:11  Dr.B
-- change get_conf info.
--
-- Revision 1.2  2003/09/22 09:30:53  Dr.B
-- remove cycle_count + add markers.
--
-- Revision 1.1  2003/07/21 09:54:42  Dr.B
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

--library serial_parity_rtl;
library work;

--library master_hiss_rtl;
library work;
--use master_hiss_rtl.master_hiss_pkg.all;
use work.master_hiss_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity master_deseria is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hiss_clk             : in  std_logic;
    reset_n              : in  std_logic;
    --------------------------------------
    -- Interface with BB (synchronized inside SM)
    --------------------------------------
    rf_rxi_i             : in  std_logic;  -- Received Real Part 
    rf_rxq_i             : in  std_logic;  -- Received Imaginary Part 
    --------------------------------------
    -- Interface with SM
    --------------------------------------
    start_rx_data_i      : in  std_logic;  -- high when there are rx data to deserialize
    get_reg_pulse_i      : in  std_logic;  -- get data (return from WildRF)
    cca_info_pulse_i     : in  std_logic;  -- get data (cca from WildRF)
    abmode_i             : in  std_logic;  -- 0 = A - 1 = B
    --
    get_reg_cca_conf_o   : out std_logic;  -- high (pulse) = data is ready
    --------------------------------------
    -- Interface with Rx Filters 60 MHz speed
    --------------------------------------
    -- Data for Rx Filter A or B -12 bits are output as it can contain info on unused bit.
    memo_i_reg_o         : out std_logic_vector(11 downto 0); --  CCA / RDATA or RX data
    memo_q_reg_o         : out std_logic_vector(11 downto 0); --  CCA / RDATA or RX data
    rx_val_tog_o         : out std_logic;  -- high = data is valid
    --------------------------------------
    --  Interface with Radio Controller sm 
    --------------------------------------
    hiss_enable_n_i      : in  std_logic;  -- enable block 
    -- Data (from read-access)
    parity_err_tog_o     : out std_logic;  -- toggle when parity error on reg deseria
    parity_err_cca_tog_o : out std_logic;  -- toggle when parity error on CCA deseria
    cca_tog_o            : out std_logic
  );

end master_deseria;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of master_deseria is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Number of cycle between 2 data (depend on the Mb/s) / or shift to perf on apb accesses
  constant RD_REG_SHIFT_CT : std_logic_vector(3 downto 0) := "1000";  -- 8 (x2 data only) 
  constant CCA_SHIFT_CT    : std_logic_vector(3 downto 0) := "1011";  -- 3 (x2 cca only) 
  constant A_SHIFT_CT      : std_logic_vector(3 downto 0) := "1011";  -- 12-1 
  constant B1_SHIFT_CT     : std_logic_vector(3 downto 0) := "1010";  -- 11-1 
  constant B2_SHIFT_CT     : std_logic_vector(3 downto 0) := "1001";  -- 10-1
  -- Adjustment
  constant B1_ADJUST_CT    : std_logic_vector(3 downto 0) := "1001";  -- 10-1 
  constant B2_ADJUST_CT    : std_logic_vector(3 downto 0) := "0000";  -- 1-1
  -- Values for generating control signals
  constant ONE4_CT         : std_logic_vector(3 downto 0) := "0001";
  constant TWO_CT          : std_logic_vector(3 downto 0) := "0010";
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -----------------------------
  -- Counters
  -----------------------------
  -- Count the nb of cycles in a data
  -- Special Counter for 11 MHz samples (10 x count 11  - shift 2
  --                                      1 x count 10  - shift 2)
  signal shift_counter      : std_logic_vector(3 downto 0);
  signal alternate_mode     : std_logic;
  signal alternate_mode_ff0 : std_logic;  -- delayed alternate_mode (used for deseria)
  signal adjust_counter     : std_logic_vector(3 downto 0);
  -----------------------------
  -- Shift Registers
  -----------------------------
  -- Shift register
  signal deseria_i_reg      : std_logic_vector(11 downto 0);
  signal deseria_q_reg      : std_logic_vector(11 downto 0);
  -----------------------------
  -- Parity Verification
  -----------------------------
  signal parity_err_tog     : std_logic;  -- parity error signal = toggle when parity check fails
  signal parity_err_cca_tog : std_logic;  -- parity error signal = toggle when parity check fails
  signal parity_is_valid    : std_logic;  -- combinational verif of parity
  signal parity_i_bit       : std_logic;  -- parity on i line
  signal parity_q_bit       : std_logic;  -- parity on q line
  signal deseria_ready      : std_logic;  -- used for init parity_gen
  signal not_deseria_ready  : std_logic;  -- used for init parity_gen
  signal cca_tog            : std_logic;  -- toggle when new cca data
  -----------------------------
  -- Others
  -----------------------------
  signal rx_val_tog         : std_logic;  -- data_valid of rx_b (toggle)
  signal get_reg_mem        : std_logic;  -- memorize that it is a reg_acces
  signal cca_mem            : std_logic;  -- memorize that it is a reg_acces
  signal data_mem           : std_logic;  -- memorize that it as a data transfer

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- Shift Counter
  -----------------------------------------------------------------------------
  -- Shift Counter : Determine the nb of shift operations between 2 data for each
  -- sort of data transfer.
  shift_count_p : process (hiss_clk, reset_n)
  begin  -- process shift_count_p
    if reset_n = '0' then
      shift_counter <= (others => '0');
      get_reg_mem   <= '0';
      cca_mem       <= '0';
      data_mem      <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then
      if hiss_enable_n_i = '0' then
        -------------------------
        -- Load shift Value
        -------------------------
        if get_reg_pulse_i = '1' then   -- Read Reg Access
          data_mem      <= '0';
          cca_mem       <= '0';
          get_reg_mem   <= '1';
          shift_counter <= RD_REG_SHIFT_CT;

        elsif cca_info_pulse_i = '1' then   -- CCA info Access
          data_mem      <= '0';
          cca_mem       <= '1';
          get_reg_mem   <= '0';
          shift_counter <= CCA_SHIFT_CT;

        elsif start_rx_data_i = '1' and abmode_i = '0'
          and shift_counter = "00000" then  -- A transmission
          data_mem      <= '1';
          cca_mem       <= '0';
          get_reg_mem   <= '0';
          shift_counter <= A_SHIFT_CT;

        elsif start_rx_data_i = '1' and abmode_i = '1'
          and shift_counter = "00000" then  -- B transmission
          data_mem      <= '1';
          cca_mem       <= '0';
          get_reg_mem   <= '0';
          if alternate_mode = '0' then
            shift_counter <= B1_SHIFT_CT;
          else
            shift_counter <= B2_SHIFT_CT;            
          end if;

        -- Decrement Counter
        elsif shift_counter /= "0000" then  -- shift
          shift_counter <= shift_counter - '1';

        else
          -- reinit for next time
          get_reg_mem   <= '0';
          data_mem      <= '0';          
          cca_mem       <= '0';
        end if;
      end if;
    end if;
  end process shift_count_p;

  -----------------------------------------------------------------------------
  -- Adjust Counter
  -----------------------------------------------------------------------------
  adjust_count_p : process (hiss_clk, reset_n)
  begin  -- process adjust_count_p
    if reset_n = '0' then
      alternate_mode     <= '0';
      alternate_mode_ff0 <= '0';
      adjust_counter <= B1_ADJUST_CT;
    elsif hiss_clk'event and hiss_clk = '1' then
      alternate_mode_ff0 <= alternate_mode;
      if start_rx_data_i = '1' and abmode_i = '1' and hiss_enable_n_i = '0' then
        -- B Mode
        if shift_counter = "00001" then
          -- watch for change in advance (cycle_counter = 1) 
         if adjust_counter = "0000" then
            alternate_mode <= not alternate_mode;
            -- Reinit Counter
            if alternate_mode = '0' then
              adjust_counter <= B2_ADJUST_CT;
            else
              adjust_counter <= B1_ADJUST_CT;
            end if;
          else
            -- decrement counter
            adjust_counter <= adjust_counter - '1';
          end if;
        end if;

      else
        alternate_mode <= '0';
        adjust_counter <= B1_ADJUST_CT;  -- reset counter for next time
      end if;
    end if;
  end process adjust_count_p;

  -----------------------------------------------------------------------------
  -- Deserialization - Shift Registers
  -----------------------------------------------------------------------------
  deseria_reg_p : process (hiss_clk, reset_n)
  begin  -- process deseria_reg_p
    if reset_n = '0' then
      deseria_i_reg <= (others => '0');
      deseria_q_reg <= (others => '0');
    elsif hiss_clk'event and hiss_clk = '1' then
      if (shift_counter /= "0000"         -- rd running
        or data_mem = '1'                 -- reception running
        or start_rx_data_i ='1'           -- transmission started
        or get_reg_pulse_i = '1'           -- return reg started
        or cca_info_pulse_i = '1')         -- cca info started
        and hiss_enable_n_i = '0' then
        -- get rf_tx val on MSB (LSB first will be on 0 at last)
        deseria_i_reg(11) <= rf_rxi_i;
        deseria_q_reg(11) <= rf_rxq_i;

        -- shift right ( MSB -> -> -> LSB)
        deseria_i_reg(10 downto 0) <= deseria_i_reg(11 downto 1);
        deseria_q_reg(10 downto 0) <= deseria_q_reg(11 downto 1);

      end if;
    end if;
  end process deseria_reg_p;

  -----------------------------------------------------------------------------
  -- Data_valid Generation
  -----------------------------------------------------------------------------
  -- When shift_counter = 1, the MSB is arriving, which means that the data
  -- will be available on next time => generate the data_valid of the
  -- associated signal.
  -- And generate this signal only for registers accesses to indicate to the sm
  -- that the reading of the info is finished. 
  d_valid_p : process (hiss_clk, reset_n)
  begin  -- process d_valid_p
    if reset_n = '0' then
      rx_val_tog         <= '0';
      parity_err_tog     <= '0';
      parity_err_cca_tog <= '0';
      memo_i_reg_o       <= (others => '0');
      memo_q_reg_o       <= (others => '0');
      get_reg_cca_conf_o <= '0';
      cca_tog            <= '0';

    elsif hiss_clk'event and hiss_clk = '1' then
      get_reg_cca_conf_o <= '0';
      if hiss_enable_n_i = '0' then
        if data_mem = '1' and shift_counter = "0000" then
          rx_val_tog <= not rx_val_tog;
          ----------------------------------------------------------------------
          -- data reception
          ----------------------------------------------------------------------
          -- There are 2 different size for b (depending to the nb of shift)
          -- They should be realigned 
          --   for B |in |fo |rm |b7 |b6 |b5 |b4 |b3 |b2 |b1 |b0 | X |   I/Q
          --         |in |fo |b7 |b6 |b5 |b4 |b3 |b2 |b1 |b0 | X | X |   I/Q
          --
          -- for A   |in |aA |a9 |a8 |a7 |a6 |a5 |a4 |a3 |a2 |a1 |a0 |   I/Q
          --

          if abmode_i = '0' then
            -------------------------------------------------------------------
            -- A Mode 
            -------------------------------------------------------------------
            memo_i_reg_o <= deseria_i_reg;
            memo_q_reg_o <= deseria_q_reg;
          else
            -------------------------------------------------------------------
            -- B Mode
            -------------------------------------------------------------------
            if alternate_mode_ff0 = '0' then
              memo_i_reg_o(11 downto 2) <= deseria_i_reg(10 downto 1);
              memo_q_reg_o(11 downto 2) <= deseria_q_reg(10 downto 1);
            else
              memo_i_reg_o <= deseria_i_reg;
              memo_q_reg_o <= deseria_q_reg;
            end if;
          end if;
          ----------------------------------------------------------------------
          -- rd acccess return
          ----------------------------------------------------------------------
          --  for RD |d7 |d6 |d5 |d4 |d3 |d2 |d1 |d0 | x | x | x | x |   I
          --         |dF |dE |dD |dC |dB |dA |d9 |d8 | x | x | x | x |   Q
          
        elsif shift_counter = ONE4_CT then

          if get_reg_mem = '1' then
            memo_i_reg_o <= deseria_i_reg;
            memo_q_reg_o <= deseria_q_reg;
            if parity_is_valid = '0' then
            -- there is an error on data -> do not send info to radio_ctrl
              parity_err_tog <= not parity_err_tog;  -- toggle parity_err signal
            else
              get_reg_cca_conf_o <= '1';    -- confirm the end of the access        
            end if;
          end if;
          if cca_mem = '1' then
            memo_i_reg_o <= deseria_i_reg;
            memo_q_reg_o <= deseria_q_reg;
            if parity_is_valid = '0' then
              -- there is an error on data -> do not send info to radio_ctrl
              parity_err_cca_tog <= not parity_err_cca_tog;  -- toggle parity_err signal
            else
              get_reg_cca_conf_o <= '1';    -- confirm the end of the access
              cca_tog            <= not cca_tog; -- toggle the cca valid
            end if;
          end if;
          
        end if;
      end if;
    end if;
  end process d_valid_p;

  -- output linking
  parity_err_cca_tog_o <= parity_err_cca_tog;
  parity_err_tog_o     <= parity_err_tog;
  rx_val_tog_o         <= rx_val_tog;
  cca_tog_o            <= cca_tog;
  -----------------------------------------------------------------------------
  -- Deseria_ready Generation
  -----------------------------------------------------------------------------
  -- Generate this signal for parity check
  deseria_ready_p: process (hiss_clk, reset_n)
  begin  -- process deseria_ready_p
    if reset_n = '0' then               
      deseria_ready <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then  
      if start_rx_data_i = '0' then
        -- It is a reg access
        if get_reg_pulse_i = '1' or cca_info_pulse_i = '1' then
          deseria_ready <= '1';       -- data can be observed by the parity check

        elsif shift_counter <= TWO_CT then
          deseria_ready <= '0';       -- next data will be the last
        end if;
      end if;
    end if;
  end process deseria_ready_p;

  not_deseria_ready <= not deseria_ready;

  -----------------------------------------------------------------------------
  -- Verify the Parity
  -----------------------------------------------------------------------------
  -- In order to avoid bad apb access, a parity bit is added after data (read)
  -- access. It is verified by the deserializer.
  -- Example :
  --               ______ ______... ______ ______  
  -- data_i       <__d0__X__d6__...X__d7__X__par_X
  --                      ______... ______ ______ ______  
  -- deseria_reg  -------<__d0__...X__d6__X__d7__X__par_X
  --               ______ ______... ______ ______  
  -- shift_counter<___0__X___8__...X___2__X___1__X
  --               ______      
  -- get_reg_puls |      |______...______________
  --                                              ________
  -- memo_reg     --------------...--------------<_add____
  --                      ___________...__
  -- deseria_ready ______|                |________
  --                                       ________
  -- parity_check ______________..._______|        |______(directly with rf_xi)
  --                                                _______
  -- get_reg_cca_conf_o_________...________________|
  -- 
  -- Remark : No need to set the deseria_ready high during the last time
  -- Parity Check = Compare par of data_i with comb res of serial_parity
  -- 1 (+) d0 (+) d1 (+) .... (+) d7 
  -- 
  --------------------------------
  -- Check Parity bits on q line
  --------------------------------            
  serial_parity_gen_1 : serial_parity_gen
    generic map (
      reset_val_g => 1)
    port map (
      clk               => hiss_clk,
      reset_n           => reset_n,
      data_i            => deseria_i_reg(11),
      init_i            => not_deseria_ready,
      data_valid_i      => deseria_ready,
      parity_bit_o      => parity_i_bit,
      parity_bit_ff_o   => open);

  --------------------------------
  -- Check Parity bits on q line
  --------------------------------            
  serial_parity_gen_2 : serial_parity_gen
    generic map (
      reset_val_g => 1)
    port map (
      clk               => hiss_clk,
      reset_n           => reset_n,
      data_i            => deseria_q_reg(11),
      init_i            => not_deseria_ready,
      data_valid_i      => deseria_ready,
      parity_bit_o      => parity_q_bit,
      parity_bit_ff_o   => open);

  
  -- Compare the received parity bits and the calculated parity bits :
  parity_is_valid <= '0' when shift_counter = ONE4_CT
                     and ((parity_i_bit /= rf_rxi_i) or
                          (parity_q_bit /= rf_rxq_i))
                     else '1';
 

end RTL;
