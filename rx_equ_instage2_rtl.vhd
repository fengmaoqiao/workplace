
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_equ_instage2.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.5  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Equalizer input stage 1.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_equ/vhdl/rtl/rx_equ_instage2.vhd,v  
--  Log: rx_equ_instage2.vhd,v  
-- Revision 1.5  2004/07/20 16:04:07  Dr.C
-- Changed SSHR to SHR for hpowman_shifted_v.
--
-- Revision 1.4  2003/05/13 11:52:45  Dr.F
-- debugged secondexp_v : replaced SXT by EXT !
--
-- Revision 1.3  2003/03/28 15:53:31  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.2  2003/03/17 17:06:55  Dr.F
-- removed debug signals.
--
-- Revision 1.1  2003/03/17 10:01:31  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

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
entity rx_equ_instage2 is
  port (
    clk                : in  std_logic; -- Clock input
    reset_n            : in  std_logic; -- Asynchronous negative reset
    module_enable_i    : in  std_logic; --'1': Internal enable
    sync_reset_n       : in  std_logic; -- Synchronous negative reset

    current_symb_i     : in  std_logic_vector (1 downto 0);
    data_valid_i       : in  std_logic;

    hpowman_i          : in  std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0);
    cormanr_i          : in  std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    cormani_i          : in  std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);

    hpowexp_i          : in  std_logic_vector(HPOWEXP_WIDTH_CT-1 downto 0);
    histexpz_signal_i  : in  std_logic_vector(HISTEXPZ_WIDTH_CT-1 downto 0);
    histexpz_data_i    : in  std_logic_vector(HISTEXPZ_WIDTH_CT-1 downto 0);

    histoffset_54_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_48_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0);
    histoffset_36_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_24_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_18_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_12_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_09_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 
    histoffset_06_i    : in  std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0); 

    burst_rate_i       : in  std_logic_vector(BURST_RATE_WIDTH_CT-1 downto 0);
    start_of_symbol_i  : in  std_logic;
    start_of_burst_i   : in  std_logic;

    hpowman_o          : out std_logic_vector(MANTLEN_CT-1 downto 0);
    cormanr_o          : out std_logic_vector(MANTLEN_CT  downto 0);
    cormani_o          : out std_logic_vector(MANTLEN_CT  downto 0);
    secondexp_o        : out std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);
    

    qam_mode_o         : out std_logic_vector(QAM_MODE_WIDTH_CT-1 downto 0);
    data_valid_o       : out std_logic;
    start_of_symbol_o  : out std_logic;
    start_of_burst_o   : out std_logic
  );

end rx_equ_instage2;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_equ_instage2 is

  signal cormanr_d   : std_logic_vector(MANTLEN_CT            downto 0);
  signal cormani_d   : std_logic_vector(MANTLEN_CT            downto 0);
  signal hpowman_d   : std_logic_vector(MANTLEN_CT-1          downto 0);
  signal secondexp_d : std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);

begin
   
  ---------------------------------------------------------------------
  -----                    Input stage 1 (reduce arguments)
  ---------------------------------------------------------------------

  ------------------------------------------------------
  -- Reduce products arguments to mantissa width (barrel shifter)
  ------------------------------------------------------
  reduce_arguments_p: process (hpowman_i, cormanr_i, cormani_i, hpowexp_i)
    variable cormanr_shifted_v : std_logic_vector(cormanr_i'range);
    variable cormani_shifted_v : std_logic_vector(cormani_i'range);
    variable hpowman_shifted_v : std_logic_vector(hpowman_i'range);
    variable count_v           : std_logic_vector(HPOWEXP_WIDTH_CT-1 downto 0);
  begin
    count_v              := (others => '0');
    cormanr_shifted_v    := cormanr_i;
    cormani_shifted_v    := cormani_i;
    hpowman_shifted_v    := hpowman_i;
    if (hpowexp_i > 0) then
      count_v := hpowexp_i - '1';
      -- shift and add 1 for next shift round
      cormanr_shifted_v := SSHR(cormanr_shifted_v, count_v) + '1';
      cormani_shifted_v := SSHR(cormani_shifted_v, count_v) + '1';
      hpowman_shifted_v := SHR(hpowman_shifted_v, count_v) + '1';
      -- last shift
      cormanr_shifted_v := SSHR(cormanr_shifted_v, "1");
      cormani_shifted_v := SSHR(cormani_shifted_v, "1");
      hpowman_shifted_v := SHR(hpowman_shifted_v, "1");
    end if;
  
    -- reduce to sign + mantlen_c bits and saturate if it is the case 
    -- cormanr_o
    cormanr_d <= sat_signed_slv(cormanr_shifted_v, 9);
    
    -- cormani_o
    -- check overflow
    cormani_d <= sat_signed_slv(cormani_shifted_v, 9);

    -- hpowman_o : always positive
    -- reduce to mantlen_c bits and saturate if it is the case 
    hpowman_d <= sat_unsigned_slv(hpowman_shifted_v, 9);
         
  end process reduce_arguments_p;


  --------------------------------------------
  -- Evaluate secondexp
  --------------------------------------------
  secondexp_p : process (histexpz_signal_i, histexpz_data_i, hpowexp_i, 
                         burst_rate_i, current_symb_i,
                         histoffset_06_i, histoffset_09_i, histoffset_12_i,
                         histoffset_18_i, histoffset_24_i, histoffset_36_i,
                         histoffset_48_i, histoffset_54_i                 )
    variable histoffset_v  : std_logic_vector(HISTOFFSET_WIDTH_CT-1 downto 0);
    variable histexpz_tmp_v: std_logic_vector(HISTEXPZ_WIDTH_CT-1 downto 0);
    -- min_secondexp_c: histexpz_tmp=0, hpowexp_i=max, histoffset = max
    -- min_secondexp_c = -MAX_HPOWEXP_CT - 4 - MAX_HISTOFFSET_CT = -16 
    -- max_secondexp_c: histexpz_tmp=max, hpowexp_i=0, histoffset = 0
    -- max_secondexp_c = MAX_HISTEXPZ_CT - 4 = 14
    -- secondexp_v range from -16 to 14. So 5 bits are necessary.
    variable secondexp_v   : std_logic_vector(4 downto 0);

  begin
    histoffset_v := histoffset_06_i; --default :signal field
    if (current_symb_i = DATA_FIELD_CT) then    --data_field
      case burst_rate_i is
        when RATE_9_CT  => 
          histoffset_v := histoffset_09_i;
        when RATE_12_CT => 
          histoffset_v := histoffset_12_i;
        when RATE_18_CT => 
          histoffset_v := histoffset_18_i;
        when RATE_24_CT => 
          histoffset_v := histoffset_24_i;
        when RATE_36_CT => 
          histoffset_v := histoffset_36_i;
        when RATE_48_CT => 
          histoffset_v := histoffset_48_i;
        when RATE_54_CT => 
          histoffset_v := histoffset_54_i;
        when others    => 
          null ; -- keep the default
      end case;
    end if;

    -- saturate histoffset
    if histoffset_v = "11" then -- histoffset "11" not allowed
      histoffset_v := MAX_HISTOFFSET_CT; -- "10"
    end if;

    histexpz_tmp_v := histexpz_signal_i;         -- default: signal field
    if (current_symb_i = DATA_FIELD_CT) then    -- data field
      histexpz_tmp_v := histexpz_data_i;
    end if;

    --secondexp_v := histexpz_tmp_v - hpowexp_i - histoffset_v - 4;
    secondexp_v := (EXT(histexpz_tmp_v, secondexp_v'length) + 
                    conv_std_logic_vector(-4, secondexp_v'length)) -
                   (EXT(hpowexp_i, secondexp_v'length) + 
                    EXT(histoffset_v, secondexp_v'length));
    --saturate secondexp_v
    if secondexp_v(secondexp_v'high) = '1' then -- if neg
      secondexp_v := (others => '0');
    elsif secondexp_v > MAX_SHIFT_SOFT_CT then -- if > 8
      secondexp_v := conv_std_logic_vector(MAX_SHIFT_SOFT_CT, SHIFT_SOFT_WIDTH_CT+1);
    end if;
         
    secondexp_d <= secondexp_v(SHIFT_SOFT_WIDTH_CT-1 downto 0);
    
  end process secondexp_p;

  ------------------------------------------
  -- Sequential part stage reduction
  ------------------------------------------
  reduct_seq_p: process( reset_n, clk )
  begin
    if reset_n = '0' then
      cormanr_o         <= (others =>'0');
      cormani_o         <= (others =>'0');
      hpowman_o         <= (others =>'0');
      secondexp_o       <= (others =>'0');
      data_valid_o      <= '0';
      qam_mode_o        <= BPSK_CT;
      start_of_symbol_o <= '0';
      start_of_burst_o  <= '0';

    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then 
        data_valid_o       <= '0';
        start_of_symbol_o  <= '0';
        start_of_burst_o   <= '0';
        qam_mode_o         <= BPSK_CT;
      elsif module_enable_i = '1' then 
        if data_valid_i = '1' then
          cormanr_o    <= cormanr_d;
          cormani_o    <= cormani_d;
          hpowman_o    <= hpowman_d;
          secondexp_o  <= secondexp_d;
          data_valid_o <= '1';
          qam_mode_o   <= burst_rate_i(QAM_LEFT_BOUND_CT downto QAM_RIGHT_BOUND_CT);
        else
          data_valid_o  <= '0';
        end if;

        if start_of_symbol_i = '1' then
          start_of_symbol_o <= '1';
        else
          start_of_symbol_o <= '0';
        end if;
      
        if start_of_burst_i = '1' then
          start_of_burst_o <= '1';
        else
          start_of_burst_o <= '0';
        end if;

      end if;
    end if;
  end process reduct_seq_p;

end rtl;
