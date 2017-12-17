
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: wie_mem.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Wiener coeffs table.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/wie_mem/vhdl/rtl/wie_mem.vhd,v  
--  Log: wie_mem.vhd,v  
-- Revision 1.6  2005/03/09 12:10:57  Dr.C
-- #BugId:1123#
-- Reset control signals.
--
-- Revision 1.5  2003/05/12 13:47:21  Dr.F
-- delayed data_valid_o.
--
-- Revision 1.4  2003/04/04 07:46:48  Dr.F
-- use pilot_ready to compute data_valid_o.
--
-- Revision 1.3  2003/03/31 06:37:49  Dr.F
-- pilot_ready appears only once per burst.
--
-- Revision 1.2  2003/03/28 15:43:49  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.1  2003/03/25 13:02:12  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity wie_mem is

  port (
    clk                : in  std_logic;  -- ofdm clock (80 MHz)
    reset_n            : in  std_logic;  -- asynchronous negative reset
    sync_reset_n       : in  std_logic;  -- synchronous negative reset
    i_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- I input data
    q_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- Q input data
    data_valid_i       : in  std_logic;  -- '1': input data valid
    data_ready_i       : in  std_logic;  -- '0': do not output more data
    start_of_burst_i   : in  std_logic;  -- '1': the next valid data input 
                                         -- belongs to the next burst
    start_of_symbol_i  : in  std_logic;  -- '1': the next valid data input 
                                         -- belongs to the next symbol
    --
    i_o                : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- I output data
    q_o                : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- Q output data
    data_ready_o       : out std_logic;  -- '0': do not input more data
    data_valid_o       : out std_logic;  -- '1': output data valid
    start_of_burst_o   : out std_logic;  -- '1': the next valid data output 
                                         -- belongs to the next burst 
    start_of_symbol_o  : out std_logic;  -- '1': the next valid data output 
                                         -- belongs to the next symbol
    -- pilots coeffs
    pilot_ready_o      : out std_logic;
    eq_p21_i_o         : out std_logic_vector(11 downto 0);
    eq_p21_q_o         : out std_logic_vector(11 downto 0);
    eq_p7_i_o          : out std_logic_vector(11 downto 0);
    eq_p7_q_o          : out std_logic_vector(11 downto 0);
    eq_m21_i_o         : out std_logic_vector(11 downto 0);
    eq_m21_q_o         : out std_logic_vector(11 downto 0);
    eq_m7_i_o          : out std_logic_vector(11 downto 0);
    eq_m7_q_o          : out std_logic_vector(11 downto 0)
  );

end wie_mem;


--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of wie_mem is

  signal wie_coeff_data_valid      : std_logic;
  signal wie_coeff_data_ready      : std_logic;
  signal wie_coeff_rd_ptr          : std_logic_vector(5 downto 0);
  signal wie_coeff_wr_ptr          : std_logic_vector(5 downto 0);
  signal wie_coeff_wr_ptr_enable   : std_logic;
  signal i_wie_coeff_table         : WIE_COEFF_ARRAY_T;
  signal q_wie_coeff_table         : WIE_COEFF_ARRAY_T;
  signal pilot_ready_flag          : std_logic;
  signal start_of_symbol_flag      : std_logic;
  signal pilot_ready_o_s           : std_logic;
begin

  data_ready_o  <= '1';
  pilot_ready_o <= pilot_ready_o_s;
  
  --------------------------------------------
  -- This process stores the 52 wiener filter coeffs.
  -- The coeffs are indexed from 0 to 51 for carriers
  -- -26 to 26 (DC is not provided).
  --
  -- -26  -21       -7    -1 1     7      21   26
  --  |----|--------|-----|--|-----|------|----|
  --  0    5        19    25 26   32      46   51
  --
  -- There are 48 data coeffs and 4 pilots coeffs.
  --------------------------------------------
  store_wiener_coeff_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      wie_coeff_wr_ptr        <= (others => '0');
      i_wie_coeff_table       <= (others => (others => '0'));
      q_wie_coeff_table       <= (others => (others => '0'));
      wie_coeff_wr_ptr_enable <= '0';
      pilot_ready_o_s         <= '0';
      start_of_symbol_o       <= '0';
      pilot_ready_flag        <= '0';
    elsif (clk'event and clk = '1') then
      if sync_reset_n = '0' then
        wie_coeff_wr_ptr_enable <= '0';
        pilot_ready_o_s         <= '0';
        start_of_symbol_o       <= '0';
        pilot_ready_flag        <= '0';
      else
        pilot_ready_o_s   <= '0';
        start_of_symbol_o <= '0';
        if (start_of_burst_i = '1') then
          pilot_ready_flag <= '0';
        end if;
        -- enable address counter on start symbol
        if (start_of_symbol_i = '1') then
          start_of_symbol_o       <= '1';
          wie_coeff_wr_ptr        <= (others => '0');
          if pilot_ready_flag = '0' then
            wie_coeff_wr_ptr_enable <= '1';
          end if;
        end if;
        if (wie_coeff_wr_ptr_enable = '1') and (data_valid_i = '1') then
          -- store coeffs
          i_wie_coeff_table(conv_integer(wie_coeff_wr_ptr)) <= i_i;
          q_wie_coeff_table(conv_integer(wie_coeff_wr_ptr)) <= q_i;
          -- increment write pointer
          wie_coeff_wr_ptr <= wie_coeff_wr_ptr + '1';
          -- stop address counter when the 48 + 4 coeffs have been stored
          if (wie_coeff_wr_ptr = conv_std_logic_vector(51,6)) then
            wie_coeff_wr_ptr_enable <= '0';
            wie_coeff_wr_ptr        <= (others => '0');
          end if;
          -- when last pilot coeff has been written (carrier 21),
          -- the pilot_tracking is triggered
          -- This is only performed for the first symbol of a burst,
          -- i.e. for the signal field.
          if (wie_coeff_wr_ptr = conv_std_logic_vector(46,6)) and
             (pilot_ready_flag = '0') then
            pilot_ready_o_s  <= '1';
            pilot_ready_flag <= '1';
          end if;
        end if;
      end if;
    end if;
  end process store_wiener_coeff_p;
  
  --------------------------------------------
  -- This process send the wiener coeffs to the
  -- equalizer.
  --------------------------------------------
  read_wiener_coeff_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      wie_coeff_rd_ptr     <= (others => '0');
      i_o                  <= (others => '0');
      q_o                  <= (others => '0');
      data_valid_o         <= '0';
      wie_coeff_data_valid <= '0';
      start_of_symbol_flag <= '0';
    elsif (clk'event and clk = '1') then
      if sync_reset_n = '0' then
        wie_coeff_rd_ptr     <= (others => '0');
        data_valid_o         <= '0';
        wie_coeff_data_valid <= '0';
        start_of_symbol_flag <= '0';
      else
        
        data_valid_o <= wie_coeff_data_valid;

        if ((start_of_symbol_flag = '1') and (wie_coeff_data_valid = '0') and
           (pilot_ready_flag = '1')) or (pilot_ready_o_s = '1')then
          wie_coeff_rd_ptr     <= conv_std_logic_vector(0, 6);
          wie_coeff_data_valid <= '1';
          start_of_symbol_flag <= '0';
        end if;
        if (start_of_symbol_i = '1') then
          start_of_symbol_flag <= '1';
        end if;
        if (data_ready_i = '1') and (wie_coeff_data_valid = '1') and
           (pilot_ready_flag = '1') then
          i_o      <= i_wie_coeff_table(conv_integer(wie_coeff_rd_ptr));
          q_o      <= q_wie_coeff_table(conv_integer(wie_coeff_rd_ptr));
        
          case conv_integer(wie_coeff_rd_ptr) is
            -- skip pilot -21
            when 4 =>
              wie_coeff_rd_ptr     <= conv_std_logic_vector(6, 6);
            -- skip pilot -7
            when 18 =>
              wie_coeff_rd_ptr     <= conv_std_logic_vector(20, 6);
            -- skip pilot 7
            when 31 =>
              wie_coeff_rd_ptr     <= conv_std_logic_vector(33, 6);
            -- skip pilot 21
            when 45 =>
              wie_coeff_rd_ptr     <= conv_std_logic_vector(47, 6);
            -- last coeff
            when 51 =>
              wie_coeff_rd_ptr     <= conv_std_logic_vector(0, 6);
              wie_coeff_data_valid <= '0';
            when others =>
              if (wie_coeff_data_valid <= '1') then
                wie_coeff_rd_ptr     <= wie_coeff_rd_ptr + '1';
              end if;
          end case;
        end if;
      end if;
    end if;
  end process read_wiener_coeff_p;

  --data_valid_o <= wie_coeff_data_valid;

  eq_m21_i_o        <= i_wie_coeff_table(5); 
  eq_m21_q_o        <= q_wie_coeff_table(5); 
  eq_m7_i_o         <= i_wie_coeff_table(19); 
  eq_m7_q_o         <= q_wie_coeff_table(19); 
  eq_p7_i_o         <= i_wie_coeff_table(32); 
  eq_p7_q_o         <= q_wie_coeff_table(32); 
  eq_p21_i_o        <= i_wie_coeff_table(46); 
  eq_p21_q_o        <= q_wie_coeff_table(46); 

end rtl;
