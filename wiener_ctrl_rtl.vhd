
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: wiener_ctrl.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Wiener filter controller.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/wiener_filter/vhdl/rtl/wiener_ctrl.vhd,v  
--  Log: wiener_ctrl.vhd,v  
-- Revision 1.4  2003/12/10 17:25:21  arisse
-- Changed cyclical incerementation of chanwien_a.
--
-- Revision 1.3  2003/03/28 15:48:31  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.2  2003/03/27 16:48:27  arisse
-- Modified data_valid_d into process gen_ctrl_p for
-- calc_count = 0 and count_data = 18, 32, 45 and 59.
-- These data correspond to the pilots.
--
-- Revision 1.1  2003/03/14 07:42:47  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--library wiener_filter_rtl;
library work;
--use wiener_filter_rtl.wiener_filter_pkg.all;
use work.wiener_filter_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity wiener_ctrl is

  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    wf_window_i       : in  std_logic_vector(1 downto 0);
    i_i               : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_i               : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data_valid_i      : in  std_logic;
    start_of_burst_i  : in  std_logic;
    start_of_symbol_i : in  std_logic;
    data_ready_i      : in  std_logic;
    data_ready_o      : out std_logic;
    i_o               : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_o               : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    data_valid_o      : out std_logic;
    start_of_symbol_o : out std_logic;
    start_of_burst_o  : out std_logic;
    -- ROM access
    chanwien_do_i     : in  std_logic_vector((4*WIENER_COEFF_WIDTH_CT)-1 downto 0);
    chanwien_a_o      : out std_logic_vector(WIENER_ADDR_WIDTH_CT-1 downto 0);
    chanwien_cs_no    : out std_logic;
    module_enable_o   : out std_logic;
    -- to multadd module
    i_add1_i          : in  std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0);
    q_add1_i          : in  std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0);
    i_add2_i          : in  std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0);
    q_add2_i          : in  std_logic_vector(WIENER_FIRSTADD_WIDTH_CT-1 downto 0);
    i_data1_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_data1_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    i_data2_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_data2_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    i_data3_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_data3_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    i_data4_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_data4_o         : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    chanwien_c0_o     : out std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    chanwien_c1_o     : out std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    chanwien_c2_o     : out std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    chanwien_c3_o     : out std_logic_vector(WIENER_COEFF_WIDTH_CT-1 downto 0);
    en_add_reg_o      : out std_logic
  );

end wiener_ctrl;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of wiener_ctrl is

  type PIPELINE_T is array (11 downto 0) of 
                       std_logic_vector(FFT_WIDTH_CT-1 downto 0);
                       
  constant DEMOD_CT : std_logic_vector(52 downto 0) :=
        "11110101001100000101011001011110101100111111010110011";  --bit 26 is multiplied by 0

  signal calc_count         : std_logic_vector(1 downto 0);
  signal module_enable      : std_logic;
  signal count_data         : std_logic_vector(6 downto 0); -- 0 to 66
  signal en_count_data      : std_logic;
  -- data_pipeline
  signal i_pipeline         : PIPELINE_T;
  signal q_pipeline         : PIPELINE_T;
  signal shift_pipeline     : std_logic;
  -- data from addition of add1 and add2
  -----------------------------------------------------------------------------
  -- add two values of WIENER_FIRSTADD_WIDTH_CT bits -> result will require
  -- WIENER_FIRSTADD_WIDTH_CT+1 bits
  -----------------------------------------------------------------------------
  signal i_add3             : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
  signal q_add3             : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
  -- result of accumulator addition
  -----------------------------------------------------------------------------
  -- add 3 values of WIENER_FIRSTADD_WIDTH_CT+1 bits -> result will require
  -- WIENER_FIRSTADD_WIDTH_CT+3 bits
  -----------------------------------------------------------------------------
  signal i_result           : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
  signal q_result           : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
  -- accumulator register
  signal load_acc           : std_logic;
  signal enable_acc         : std_logic;
  -----------------------------------------------------------------------------
  -- add 3 values of WIENER_FIRSTADD_WIDTH_CT+1 bits -> result will require
  -- WIENER_FIRSTADD_WIDTH_CT+4 bits
  -----------------------------------------------------------------------------
  signal i_acc              : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
  signal q_acc              : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
  signal i_acc_lim          : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
  signal q_acc_lim          : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
  -- ROM address
  signal chanwien_a         : std_logic_vector(WIENER_ADDR_WIDTH_CT-1 downto 0);
  signal load_coeff         : std_logic;
  signal address_incr       : std_logic;
  signal address_loop       : std_logic;
  signal predata_valid      : std_logic;
  signal data_valid         : std_logic;
  signal data_valid_d       : std_logic;
  signal prestart_of_symbol : std_logic;
  signal start_of_symbol    : std_logic;
  signal start_of_symbol_d  : std_logic;
  signal prestart_of_burst  : std_logic;
  signal start_of_burst     : std_logic;
  signal start_of_burst_d   : std_logic;
  signal my_data_ready      : std_logic;
  signal chanwien_cs_n_d    : std_logic;
  signal data_sel           : integer range 0 to 2;

  signal data_needed        : std_logic;

begin

  ---------------------------------------------------------------------------
  -- module will always be disabled if it needs new data, but is unable to
  -- receive it.
  ---------------------------------------------------------------------------
  module_enable     <= (not(data_needed) or data_valid_i) and
                       (data_ready_i or
                        (not ((start_of_symbol and not start_of_burst) or 
                              data_valid)));
  module_enable_o   <= module_enable;
  data_ready_o      <= (data_ready_i or
                       (not ((start_of_symbol and not start_of_burst) or 
                             data_valid)))
                       and my_data_ready;
  data_valid_o      <= data_valid;
  start_of_symbol_o <= start_of_symbol;
  start_of_burst_o  <= start_of_burst;

  chanwien_a_o      <= chanwien_a;

  --------------------------------------------
  -- Output of Wiener filter
  --------------------------------------------
  scale_limit_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      i_o <= (others => '0');
      q_o <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if module_enable = '1' then
        i_o <= i_acc_lim;
        q_o <= q_acc_lim;
      end if;
    end if;
  end process scale_limit_p;

  --------------------------------------------
  -- Control signals of the filter
  --------------------------------------------
  gen_ctrl_p : process (calc_count, count_data, data_valid_i)
  begin
    case conv_integer(calc_count) is
      when 0 =>
        case conv_integer(count_data) is
          when 45 =>
            address_loop   <= '1';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            enable_acc     <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
            data_valid_d   <= '1';
          when 18 =>
            address_loop   <= '1';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            enable_acc     <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
            data_valid_d   <= '1';
          when 12 =>
            address_loop   <= '0';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            enable_acc     <= '0';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
            data_valid_d   <= '0';
          when 13 | 14 | 15 | 16 | 31 | 33 | 34 | 35 |
               36 | 37 | 38 | 39 | 40 | 41 | 42 =>
            address_loop   <= '0';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            enable_acc     <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
            data_valid_d   <= '1';
          when 32 =>
            address_loop   <= '0';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            enable_acc     <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
            data_valid_d   <= '1';
          when 58 | 60 | 61 | 62 | 63 | 64 | 65 | 66 =>
            address_loop   <= '0';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            enable_acc     <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '1';
            data_valid_d   <= '1';
          when 59 =>
            address_loop   <= '0';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            enable_acc     <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '1';
            data_valid_d   <= '1';
          when 11 =>
            address_loop   <= '0';
            address_incr   <= '0';
            load_coeff     <= '1';
            en_add_reg_o   <= '0';
            enable_acc     <= '0';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
            data_valid_d   <= '0';
          when 9 =>
            address_loop   <= '0';
            address_incr   <= '0';
            load_coeff     <= '0';
            en_add_reg_o   <= '0';
            enable_acc     <= '0';
            data_needed    <= '1';
            shift_pipeline <= data_valid_i;
            en_count_data  <= data_valid_i;
            my_data_ready  <= '1';
            data_valid_d   <= '0';
          when 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 10 =>
            address_loop   <= '0';
            address_incr   <= '0';
            load_coeff     <= '0';
            en_add_reg_o   <= '0';
            enable_acc     <= '0';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
            data_valid_d   <= '0';
          when others =>  -- 17 | 19 | 20 | 21 | 22 | 23 | 24 | 
                          -- 25 | 26 | 27 | 28 | 29 | 30 |
                          -- 43 | 44 | 46 | 47 | 48 | 49 | 50 | 51 | 
                          -- 52 | 53 | 54 | 55 | 56 | 57
            address_loop   <= '1';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            enable_acc     <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
            data_valid_d   <= '1';
        end case;
        chanwien_cs_n_d   <= '0';
        data_sel          <= 0;
        load_acc          <= '0';
        start_of_symbol_d <= '0';
        start_of_burst_d  <= '0';
        
      when 1 =>
        case conv_integer(count_data) is
          when 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 =>
            address_loop   <= '0';
            address_incr   <= '0';
            load_coeff     <= '0';
            en_add_reg_o   <= '0';
            load_acc       <= '0';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
          when 10 =>
            address_loop   <= '0';
            address_incr   <= data_valid_i;
            load_coeff     <= '0';
            en_add_reg_o   <= '0';
            load_acc       <= '0';
            data_needed    <= '1';
            shift_pipeline <= data_valid_i;
            en_count_data  <= data_valid_i;
            my_data_ready  <= '1';
          when 11 =>
            address_loop   <= '0';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '0';
            load_acc       <= '0';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
          when 12 | 13 | 14 | 15 | 16 | 31 | 32 | 33 |
               34 | 35 | 36 | 37 | 38 | 39 | 40 | 41 | 42 =>
            address_loop   <= '0';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            load_acc       <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
          when 58 | 59 | 60 | 61 | 62 | 63 | 64 | 65 | 66 =>
            address_loop   <= '0';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            load_acc       <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '1';
          when others =>
            -- 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 
            -- 25 | 26 | 27 | 28 | 29 | 30 |
            -- 43 | 44 | 45 | 46 | 47 | 48 | 49 | 50 | 
            -- 51 | 52 | 53 | 54 | 55 | 56 | 57
            address_loop   <= '1';
            address_incr   <= '1';
            load_coeff     <= '1';
            en_add_reg_o   <= '1';
            load_acc       <= '1';
            data_needed    <= '0';
            shift_pipeline <= '0';
            en_count_data  <= '0';
            my_data_ready  <= '0';
        end case;
        chanwien_cs_n_d   <= '0';
        data_sel          <= 1;
        enable_acc        <= '0';
        data_valid_d      <= '0';
        start_of_symbol_d <= '0';
        start_of_burst_d  <= '0';
        
      when 2 =>
        case conv_integer(count_data) is
          when 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 =>
            address_loop    <= '0';
            chanwien_cs_n_d <= '1';
            load_coeff      <= '0';
            data_sel        <= 2;
            en_add_reg_o    <= '0';
            load_acc        <= '0';
            data_valid_d    <= '0';
            address_incr    <= '0';
            enable_acc      <= '0';
            data_needed     <= '1';     -- count_data below 8 means data is
                                        -- always required
            if data_valid_i = '1' then
              shift_pipeline <= '1';
              en_count_data  <= '1';
            else
              shift_pipeline <= '0';
              en_count_data  <= '0';
            end if;
            my_data_ready     <= '1';
            start_of_symbol_d <= '0';
            start_of_burst_d  <= '0';
          when 9 | 10 =>
            address_loop      <= '0';
            chanwien_cs_n_d   <= '0';
            load_coeff        <= '0';
            data_sel          <= 2;
            en_add_reg_o      <= '0';
            start_of_symbol_d <= '0';
            start_of_burst_d  <= '0';
            my_data_ready     <= '1';
            if data_valid_i = '1' then
              en_count_data <= '1';
            else
              en_count_data <= '0';
            end if;
            address_incr   <= '0';
            enable_acc     <= '0';
            data_needed    <= '1';
            shift_pipeline <= data_valid_i;
            load_acc       <= '0';
            data_valid_d   <= '0';
          when 11 =>
            address_loop      <= '0';
            chanwien_cs_n_d   <= '0';
            load_coeff        <= data_valid_i;
            data_sel          <= 2;
            en_add_reg_o      <= '0';
            start_of_symbol_d <= '0';
            start_of_burst_d  <= '0';
            my_data_ready     <= '1';
            if data_valid_i = '1' then
              en_count_data <= '1';
            else
              en_count_data <= '0';
            end if;
            address_incr   <= data_valid_i;
            enable_acc     <= '0';
            data_needed    <= '1';
            shift_pipeline <= data_valid_i;
            load_acc       <= '0';
            data_valid_d   <= '0';
          when 30 | 31 | 32 | 33 | 34 | 35 | 36 | 37 | 
               38 | 39 | 40 | 41 | 42 | 57 =>
            address_loop      <= '0';
            chanwien_cs_n_d   <= '0';
            load_coeff        <= data_valid_i;
            data_sel          <= 2;
            en_add_reg_o      <= '1';
            start_of_symbol_d <= '0';
            start_of_burst_d  <= '0';
            my_data_ready     <= '1';
            if data_valid_i = '1' then
              en_count_data <= '1';
            else
              en_count_data <= '0';
            end if;
            address_incr   <= '1';
            enable_acc     <= '1';
            data_needed    <= '1';
            shift_pipeline <= data_valid_i;
            load_acc       <= '0';
            data_valid_d   <= '0';
          when 12 =>
            address_loop      <= '0';
            chanwien_cs_n_d   <= '0';
            load_coeff        <= '1';
            data_sel          <= 2;
            en_add_reg_o      <= '1';
            start_of_symbol_d <= '1';
            start_of_burst_d  <= '1';
            my_data_ready     <= '0';
            en_count_data     <= '1';
            address_incr      <= '1';
            enable_acc        <= '1';
            data_needed       <= '0';
            shift_pipeline    <= '0';
            load_acc          <= '0';
            data_valid_d      <= '0';
          when 13 | 14 | 15 | 16 =>
            address_loop      <= '0';
            chanwien_cs_n_d   <= '0';
            load_coeff        <= '1';
            data_sel          <= 2;
            en_add_reg_o      <= '1';
            start_of_symbol_d <= '0';
            start_of_burst_d  <= '0';
            my_data_ready     <= '0';
            en_count_data     <= '1';
            address_incr      <= '1';
            enable_acc        <= '1';
            data_needed       <= '0';
            shift_pipeline    <= '0';
            load_acc          <= '0';
            data_valid_d      <= '0';
          when 58 | 59 | 60 | 61 | 62 | 63 | 64 | 65 | 66 =>
            address_loop      <= '0';
            chanwien_cs_n_d   <= '0';
            load_coeff        <= '1';
            data_sel          <= 2;
            en_add_reg_o      <= '1';
            start_of_symbol_d <= '0';
            start_of_burst_d  <= '0';
            my_data_ready     <= '1';
            en_count_data     <= '1';
            address_incr      <= '1';
            enable_acc        <= '1';
            data_needed       <= '0';
            shift_pipeline    <= '0';
            load_acc          <= '0';
            data_valid_d      <= '0';
          when others =>  -- 17 | 18 | 19 | 20 | 21 | 22 | 
                          -- 23 | 24 | 25 | 26 | 27 | 28 | 29 |
                          -- 43 | 44 | 45 | 46 | 47 | 48 | 49 | 
                          -- 50 | 51 | 52 | 53 | 54 | 55 | 56
            address_loop      <= '1';
            chanwien_cs_n_d   <= '0';
            load_coeff        <= data_valid_i;
            data_sel          <= 2;
            en_add_reg_o      <= '1';
            start_of_symbol_d <= '0';
            start_of_burst_d  <= '0';
            my_data_ready     <= '1';
            if data_valid_i = '1' then
              en_count_data <= '1';
            else
              en_count_data <= '0';
            end if;
            address_incr   <= '1';
            enable_acc     <= '1';
            data_needed    <= '1';
            shift_pipeline <= data_valid_i;
            load_acc       <= '0';
            data_valid_d   <= '0';
            
        end case;

      when others =>                    -- 3
        address_loop      <= '0';
        address_incr      <= '0';
        chanwien_cs_n_d   <= '1';
        load_coeff        <= '0';
        data_sel          <= 2;
        en_add_reg_o      <= '0';
        load_acc          <= '0';
        enable_acc        <= '0';
        data_valid_d      <= '0';
        data_needed       <= '0';
        shift_pipeline    <= '0';
        my_data_ready     <= '1';
        en_count_data     <= '0';
        start_of_symbol_d <= '0';
        start_of_burst_d  <= '0';
    end case;
  end process gen_ctrl_p;

  --------------------------------------------
  -- Output coefficients
  --------------------------------------------
  ctrl_reg_p : process (clk, reset_n)
    variable i  : integer;
  begin
    if reset_n = '0' then                 -- asynchronous reset (active low)
      count_data     <= (others => '0');
      chanwien_c0_o  <= (others => '0');
      chanwien_c1_o  <= (others => '0');
      chanwien_c2_o  <= (others => '0');
      chanwien_c3_o  <= (others => '0');
      chanwien_cs_no <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (sync_reset_n = '0') or (start_of_burst_i = '1') then
        count_data     <= (others => '0');
        chanwien_c0_o  <= (others => '0');
        chanwien_c1_o  <= (others => '0');
        chanwien_c2_o  <= (others => '0');
        chanwien_c3_o  <= (others => '0');
        chanwien_cs_no <= '1';
      elsif module_enable = '1' then
        chanwien_cs_no <= chanwien_cs_n_d;
        if load_coeff = '1' then
          for i in (WIENER_COEFF_WIDTH_CT-1) downto 0 loop
            chanwien_c0_o(i) <= chanwien_do_i(i);
            chanwien_c1_o(i) <= chanwien_do_i(WIENER_COEFF_WIDTH_CT+i);
            chanwien_c2_o(i) <= chanwien_do_i((2*WIENER_COEFF_WIDTH_CT)+i);
            chanwien_c3_o(i) <= chanwien_do_i((3*WIENER_COEFF_WIDTH_CT)+i);
          end loop;
        end if;

        if en_count_data = '1' then
          if count_data = conv_std_logic_vector(64, count_data'length) then
            count_data <= (others => '0');
          else
            count_data <= count_data + 1;
          end if;
        end if;
        
      end if;
    end if;
  end process ctrl_reg_p;


  --------------------------------------------
  -- calc_count generation
  --------------------------------------------
  calcul_cnt_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      calc_count         <= "11";
      predata_valid      <= '0';
      data_valid         <= '0';
      prestart_of_symbol <= '0';
      start_of_symbol    <= '0';
      prestart_of_burst  <= '0';
      start_of_burst     <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        calc_count         <= "11";
        predata_valid      <= '0';
        data_valid         <= '0';
        prestart_of_symbol <= '0';
        start_of_symbol    <= '0';
        prestart_of_burst  <= '0';
        start_of_burst     <= '0';
      elsif start_of_burst_i = '1' then
        calc_count         <= "10";
        predata_valid      <= '0';
        data_valid         <= '0';
        prestart_of_symbol <= '0';
        start_of_symbol    <= '0';
        prestart_of_burst  <= '0';
        start_of_burst     <= '0';
      elsif module_enable = '1' then
        predata_valid      <= data_valid_d;
        data_valid         <= predata_valid;
        prestart_of_symbol <= start_of_symbol_d;
        start_of_symbol    <= prestart_of_symbol;
        prestart_of_burst  <= start_of_burst_d;
        start_of_burst     <= prestart_of_burst;
        case conv_integer(count_data) is
          when 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 =>
            --calc_count <= calc_count;
          when 64 =>
            calc_count <= calc_count + 1;
          when 12 | 13 | 14 | 15 | 16 | 58 | 59 | 60 | 61 | 62 | 63 =>
            if calc_count = "10" then
              calc_count <= "00";
            else
              calc_count <= calc_count + 1;
            end if;
          when others =>
            if calc_count = "10" then
              if data_valid_i = '1' then
                calc_count <= "00";
              end if;
            else
              calc_count <= calc_count + 1;
            end if;
        end case;
      elsif data_ready_i = '1' then
        ---------------------------------------------------------------------
        -- module_enable can go to 0 because there is no more incoming data.
        -- In this case we want to acknowledge incoming data_ready_i=1 by
        -- removing data that is ready to leave this module even though the
        -- rest of the module is blocked waiting for new input data.
        ---------------------------------------------------------------------
        data_valid      <= '0';
        start_of_symbol <= '0';
        start_of_burst  <= '0';
      end if;
    end if;
  end process calcul_cnt_p;

  --------------------------------------------
  -- Computes the data to feed the multadd
  --------------------------------------------
  data_comb_p : process (i_pipeline, q_pipeline, data_sel,
                         i_add1_i, q_add1_i, i_add2_i, q_add2_i,
                         i_acc, q_acc)
                                           
    variable i_add3_v       : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
    variable q_add3_v       : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
    variable i_acc_plus9_v  : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
    variable q_acc_plus9_v  : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
    variable i_acc_scaled_v : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
    variable q_acc_scaled_v : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
    variable i_acc_lim_v    : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    variable q_acc_lim_v    : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    variable i_result_v     : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
    variable q_result_v     : std_logic_vector(WIENER_FIRSTADD_WIDTH_CT+2 downto 0);
  begin

    i_add3_v  := SXT(i_add1_i, i_add3'length) + SXT(i_add2_i, i_add3'length);
    q_add3_v  := SXT(q_add1_i, q_add3'length) + SXT(q_add2_i, q_add3'length);
    --
    i_add3      <= i_add3_v;
    q_add3      <= q_add3_v;
    -- 
    i_acc_plus9_v   := SXT(i_acc, i_acc_plus9_v'length) + 
                       conv_std_logic_vector(9, i_acc_plus9_v'length);
    q_acc_plus9_v   := SXT(q_acc, q_acc_plus9_v'length) + 
                       conv_std_logic_vector(9, i_acc_plus9_v'length);

    i_acc_scaled_v := SSHR(i_acc_plus9_v,conv_std_logic_vector(3, 2));
    q_acc_scaled_v := SSHR(q_acc_plus9_v,conv_std_logic_vector(3, 2));

    -- saturate (remove 5 bits to have a FFT_WIDTH_CT width vector)
    i_acc_lim_v := sat_signed_slv(i_acc_scaled_v, 
                                  i_acc_scaled_v'length-FFT_WIDTH_CT);
    q_acc_lim_v := sat_signed_slv(q_acc_scaled_v, 
                                  q_acc_scaled_v'length-FFT_WIDTH_CT);
    --
    i_acc_lim   <= i_acc_lim_v;
    q_acc_lim   <= q_acc_lim_v;
    
    --
    i_result_v := SXT(i_add3_v, i_result_v'length) + 
                  SXT(i_acc, i_result_v'length);
    q_result_v := SXT(q_add3_v, q_result_v'length) + 
                  SXT(q_acc, q_result_v'length);
    -- 
    i_result       <= i_result_v;
    q_result       <= q_result_v;
    -- 
    case data_sel is
      when 0 =>
        i_data1_o <= i_pipeline(0);
        q_data1_o <= q_pipeline(0);
        i_data2_o <= i_pipeline(1);
        q_data2_o <= q_pipeline(1);
        i_data3_o <= i_pipeline(2);
        q_data3_o <= q_pipeline(2);
        i_data4_o <= i_pipeline(3);
        q_data4_o <= q_pipeline(3);
      when 1 =>
        i_data1_o <= i_pipeline(4);
        q_data1_o <= q_pipeline(4);
        i_data2_o <= i_pipeline(5);
        q_data2_o <= q_pipeline(5);
        i_data3_o <= i_pipeline(6);
        q_data3_o <= q_pipeline(6);
        i_data4_o <= i_pipeline(7);
        q_data4_o <= q_pipeline(7);
      when others =>                    -- 2
        i_data1_o <= i_pipeline(8);
        q_data1_o <= q_pipeline(8);
        i_data2_o <= i_pipeline(9);
        q_data2_o <= q_pipeline(9);
        i_data3_o <= i_pipeline(10);
        q_data3_o <= q_pipeline(10);
        i_data4_o <= i_pipeline(11);
        q_data4_o <= q_pipeline(11);
    end case;
  end process data_comb_p;


  --------------------------------------------
  -- Registered data
  --------------------------------------------
  data_reg_p : process (clk, reset_n)
    variable tmpi_v : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    variable tmpq_v : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    variable i      : integer;
  begin
    if reset_n = '0' then                 -- asynchronous reset (active low)
      for i in 0 to 11 loop
        i_pipeline(i) <= (others => '0');
        q_pipeline(i) <= (others => '0');
      end loop;
      i_acc <= (others => '0');
      q_acc <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if module_enable = '1' then
        if shift_pipeline = '1' then
          for i in 0 to 10 loop
            i_pipeline(i) <= i_pipeline(i+1);
            q_pipeline(i) <= q_pipeline(i+1);
          end loop;
          tmpi_v := i_i;
          tmpq_v := q_i;
          case conv_integer(count_data) is
            when 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 =>
              if DEMOD_CT(conv_integer(count_data)) = '0' then
                tmpi_v := not(tmpi_v) + '1';
                tmpq_v := not(tmpq_v) + '1';
              end if;
            when 31 =>
              ---------------------------------------------------------------
              -- Because count_data increments by 5 while no new data is
              -- accepted (to perform calculations), count_data=31 is
              -- equivalent to the 26th sub-carrier (sub-carrier0).
              ---------------------------------------------------------------
              tmpi_v := (others => '0');
              tmpq_v := (others => '0');
            when 12 | 13 | 14 | 15 | 16 | 58 | 59 | 60 | 61 | 62 | 63 | 64 | 65 | 66 =>
              if DEMOD_CT(52) = '0' then
                tmpi_v := not(tmpi_v) + '1';
                tmpq_v := not(tmpq_v) + '1';
              end if;
            when others =>
              if DEMOD_CT(conv_integer(count_data)-5) = '0' then
                tmpi_v := not(tmpi_v) + '1';
                tmpq_v := not(tmpq_v) + '1';
              end if;
          end case;
          i_pipeline(11) <= tmpi_v;
          q_pipeline(11) <= tmpq_v;
        end if;
        if enable_acc = '1' then
          i_acc <= i_result;
          q_acc <= q_result;
        elsif load_acc = '1' then
          i_acc <= i_add3;
          q_acc <= q_add3;
        end if;
      end if;
    end if;
  end process data_reg_p;

  --------------------------------------------
  -- Computes the address to select the right coefficient.
  --------------------------------------------
  address_rom_p : process (clk, reset_n)
  begin
    if reset_n = '0' then                 -- asynchronous reset (active low)
      chanwien_a <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        chanwien_a <= (others => '0');
      elsif start_of_burst_i = '1' then
        case wf_window_i is
          when "00" =>
            -----------------------------------------------------------------
            -- "000000000"
            -----------------------------------------------------------------
            chanwien_a <= (others => '0');
          when "01" =>
            -----------------------------------------------------------------
            -- "001001000"
            -----------------------------------------------------------------
            chanwien_a <= conv_std_logic_vector(72, WIENER_ADDR_WIDTH_CT);
          when "10" =>
            -----------------------------------------------------------------
            -- "010010000"
            -----------------------------------------------------------------
            chanwien_a <= conv_std_logic_vector(144, WIENER_ADDR_WIDTH_CT);
          when others =>              -- "11"
            -----------------------------------------------------------------
            -- "011011000"
            -----------------------------------------------------------------
            chanwien_a <= conv_std_logic_vector(216, WIENER_ADDR_WIDTH_CT);
        end case;
      elsif module_enable = '1' then
        if address_incr = '1' then
          if address_loop = '1' then
            -----------------------------------------------------------------
            -- need to increment cyclically when the Wiener coefficients are
            -- static (because 3 cycles are needed for one calculation).
            -----------------------------------------------------------------
            case conv_integer(unsigned(chanwien_a)) is
              when 17 =>
                chanwien_a <= conv_std_logic_vector(15, 9);
              when 56 =>
                chanwien_a <= conv_std_logic_vector(54, 9);
              when 89 =>
                chanwien_a <= conv_std_logic_vector(87, 9);
              when 128 =>
                chanwien_a <= conv_std_logic_vector(126, 9);
              when 161 =>
                chanwien_a <= conv_std_logic_vector(159, 9);
              when 200 =>
                chanwien_a <= conv_std_logic_vector(198, 9);
              when 233 =>
                chanwien_a <= conv_std_logic_vector(231, 9);
              when 272 =>
                chanwien_a <= conv_std_logic_vector(270, 9);
              when others =>
                chanwien_a <= conv_std_logic_vector(
                              (conv_integer(unsigned(chanwien_a)) + 1), 9);
            end case;
          else
            chanwien_a <= conv_std_logic_vector(
                             (conv_integer(unsigned(chanwien_a)) + 1), 9);
          end if;
        end if;
      end if;

    end if;
  end process address_rom_p;
  
end rtl;
