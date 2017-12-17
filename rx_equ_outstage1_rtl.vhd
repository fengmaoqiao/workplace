
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_equ_outstage1.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.4  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Equalizer output stage 1.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_equ/vhdl/rtl/rx_equ_outstage1.vhd,v  
--  Log: rx_equ_outstage1.vhd,v  
-- Revision 1.4  2003/10/06 09:26:54  Dr.C
-- Debugged SXT operation for hpowman_ext to EXT operation. This signal is unsigned.
--
-- Revision 1.3  2003/03/28 15:53:35  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.2  2003/03/17 17:07:10  Dr.F
-- removed debug signals.
--
-- Revision 1.1  2003/03/17 10:01:35  Dr.F
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

--library rx_equ_rtl;
library work;
--use rx_equ_rtl.rx_equ_pkg.all;
use work.rx_equ_pkg.all;


--------------------------------------------
-- Entity
--------------------------------------------
entity rx_equ_outstage1 is
  port (
    clk                : in  std_logic; --Clock input
    reset_n            : in  std_logic; --Asynchronous negative reset
    module_enable_i    : in  std_logic; --'1': Internal enable for clock gating
    sync_reset_n       : in  std_logic; --'0': The control state of the module will be reset

    data_valid_i       : in  std_logic; 

    hpowman_i          : in  std_logic_vector(MANTLEN_CT -1 downto 0);
    cormanr_i          : in  std_logic_vector(MANTLEN_CT downto 0);
    cormani_i          : in  std_logic_vector(MANTLEN_CT downto 0);
    secondexp_i        : in  std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);
   
    soft_x0_i          : in  std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); 
    soft_y0_i          : in  std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    qam_mode_i         : in  std_logic_vector(QAM_MODE_WIDTH_CT-1 downto 0);
    start_of_symbol_i  : in  std_logic;
    start_of_burst_i   : in  std_logic;

    hpowman_o          : out std_logic_vector(MANTLEN_CT-1 downto 0);
    cormanr_o          : out std_logic_vector(MANTLEN_CT  downto 0);
    cormani_o          : out std_logic_vector(MANTLEN_CT  downto 0);
    secondexp_o        : out std_logic_vector(SHIFT_SOFT_WIDTH_CT-1 downto 0);
    
    soft_x0_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y0_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    soft_x1_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y1_o          : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);

    qam_mode_o         : out std_logic_vector(QAM_MODE_WIDTH_CT-1 downto 0);
    data_valid_o       : out std_logic; 
    start_of_symbol_o  : out std_logic;
    start_of_burst_o   : out std_logic;
    reducerasures_i    : in  std_logic_vector(1 downto 0)
  );

end rx_equ_outstage1;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_equ_outstage1 is

  constant MAX_INTERNAL_CT  : integer  := MAX_SOFTBIT_CT * 4 - 1; --59
  -- one more bit to be able to contain -(-512)
  -- a second more bit to be able to do one SHL
  constant INT_LENGTH_CT    : integer  := MANTLEN_CT + 2; 
                                                         

  signal cormanr_d     : std_logic_vector(MANTLEN_CT            downto 0);
  signal cormani_d     : std_logic_vector(MANTLEN_CT            downto 0);
  signal soft_x1_d     : std_logic_vector(SOFTBIT_WIDTH_CT-1    downto 0);
  signal soft_x1_tmp   : std_logic_vector(SOFTBIT_WIDTH_CT-1    downto 0);
  signal soft_y1_d     : std_logic_vector(SOFTBIT_WIDTH_CT-1    downto 0);
  signal soft_y1_tmp   : std_logic_vector(SOFTBIT_WIDTH_CT-1    downto 0);

begin


  -------------------------------------------------------------------
  ---                    STAGE 1 
  -------------------------------------------------------------------
  --------------------------------------
  -- CorMan calculation
  --------------------------------------
  corman_p : process (cormanr_i, cormani_i, hpowman_i, qam_mode_i)
    variable scaling1_v   : std_logic_vector(7 downto 0);
    variable hpowman_ext  : std_logic_vector(hpowman_i'high+8 downto 0);
    variable mult_v       : std_logic_vector(hpowman_i'range);
    variable mult_temp1_v : std_logic_vector(hpowman_i'high+8 downto 0);
    variable mult_temp2_v : std_logic_vector(hpowman_i'high+1 downto 0);
    -- cormani and cormanr extended length
    variable cormani_v    : std_logic_vector(MANTLEN_CT + 1 downto 0);
    variable cormanr_v    : std_logic_vector(MANTLEN_CT + 1 downto 0);
  begin
    scaling1_v := conv_std_logic_vector(S1_QAM16_CT,8);    -- default
    if qam_mode_i = QAM64_CT then
      scaling1_v := conv_std_logic_vector(S1_QAM64_CT,8);
    end if;
    -- zero extention
    hpowman_ext := EXT(hpowman_i, hpowman_ext'length);
    -- mult_v := conv_unsigned(SHR ( (SHR ( (hpowman_int * conv_unsigned(scaling1_v,8)) ,"111")  +1), "01"),hpowman_int'high + 1) ;
    -- hpowman_i is multiplied by a scaling factor which is S1_QAM64_CT(158)
    -- when in QAM64 mode, else S1_QAM16_CT(162).
    -- 158 = 128+16+8+4+2
    -- 162 = 128+32+2
    -- The multiplication is decomposed in shifts and adds.
    -- we start with hpowman_i * (128+2)
    mult_temp1_v := (hpowman_ext(hpowman_ext'high-1 downto 0) & '0') +
                    (hpowman_ext(hpowman_ext'high-7 downto 0) & "0000000");
    -- then depending on the qam mode, we perform the corresponding 
    -- remaining additions.
    if (qam_mode_i = QAM64_CT) then
      mult_temp1_v := ((hpowman_ext(hpowman_ext'high-3 downto 0) & "000") +
                       (hpowman_ext(hpowman_ext'high-4 downto 0) & "0000")) +
                      (mult_temp1_v +
                       (hpowman_ext(hpowman_ext'high-2 downto 0) & "00"));
    else
      mult_temp1_v := mult_temp1_v +
                      (hpowman_ext(hpowman_ext'high-5 downto 0) & "00000");
    end if;
    
    -- divide by 128 and add 1
    mult_temp2_v := mult_temp1_v(mult_temp1_v'high downto 7) + '1';
    -- divide by 2
    mult_v := mult_temp2_v(mult_temp2_v'high downto 1);
    
    if ((qam_mode_i = QAM64_CT) or (qam_mode_i= QAM16_CT)) then
      -- if positive, convert to negative
      if (cormani_i(cormani_i'high)) = '0' then
        cormani_v := not(SXT(cormani_i, cormani_v'length)) + '1';
      else
        cormani_v := SXT(cormani_i, cormani_v'length);
      end if;
      -- if positive, convert to negative
      if (cormanr_i(cormanr_i'high)) = '0' then
        cormanr_v := not(SXT(cormanr_i, cormanr_v'length)) + '1';
      else
        cormanr_v := SXT(cormanr_i, cormanr_v'length);
      end if;
      -- cormani_v = mult_v - abs(cormani_i)
      cormani_v := SXT(mult_v,cormani_v'length) + cormani_v;
      -- cormanr_v = mult_v - abs(cormanr_i)
      cormanr_v := SXT(mult_v,cormanr_v'length) + cormanr_v;
    else
      cormani_v := (others => '0');
      cormanr_v := (others => '0');
    end if;

    -- check overflow
    -- if cormani_v > 1023 we saturate to 1023
    if (cormani_v(11 downto 10) = "01") then
       cormani_d  <= conv_std_logic_vector(MAX_MANTISSE_CT, MANTLEN_CT + 1);
    -- if cormani_v < -1024 we saturate to -1024
    elsif (cormani_v(11 downto 10) = "10") then
       cormani_d  <= conv_std_logic_vector(MIN_MANTISSE_CT, MANTLEN_CT + 1);
    else --regular case, just skip the useless msb's
       cormani_d <= cormani_v(MANTLEN_CT downto 0);
    end if;

    -- check overflow
    -- if cormanr_v > 1023 we saturate to 1023
    if (cormanr_v(11 downto 10) = "01") then
       cormanr_d  <= conv_std_logic_vector(MAX_MANTISSE_CT, MANTLEN_CT + 1);
    -- if cormanr_v < -1024 we saturate to -1024
    elsif (cormanr_v(11 downto 10) = "10") then
       cormanr_d  <= conv_std_logic_vector(MIN_MANTISSE_CT, MANTLEN_CT + 1);
    else --regular case, just skip the useless msb
       cormanr_d <= cormanr_v(MANTLEN_CT downto 0);
    end if;
  end process corman_p;

  ---------------------------------------------
  -- Forward parameters value to the next state
  ---------------------------------------------
           
  --------------------------------------
  -- SoftX1 compression (barrel shifter)
  --------------------------------------
  soft_x1_p: process (cormanr_d, cormani_d, secondexp_i, reducerasures_i)
    variable abs_soft_x_shift_v : std_logic_vector(INT_LENGTH_CT downto 0);
    variable abs_soft_y_shift_v : std_logic_vector(INT_LENGTH_CT downto 0);
    variable sign_x_v           : std_logic; 
    variable sign_y_v           : std_logic; 
    variable count_v            : std_logic_vector(SHIFT_SOFT_WIDTH_CT -1 downto 0);
  
  begin
    sign_x_v := cormanr_d(MANTLEN_CT) ;
    sign_y_v := cormani_d(MANTLEN_CT) ;

    -- get absolute value
    abs_soft_x_shift_v := SXT(cormanr_d,abs_soft_x_shift_v'length);
    abs_soft_y_shift_v := SXT(cormani_d,abs_soft_y_shift_v'length);
    if sign_x_v ='1' then
      abs_soft_x_shift_v := not(abs_soft_x_shift_v) + '1';
    end if;
    if sign_y_v ='1' then
      abs_soft_y_shift_v := not(abs_soft_y_shift_v) + '1';
    end if;

    count_v            := secondexp_i;
    abs_soft_x_shift_v := SHR(SHL(abs_soft_x_shift_v, "1"), count_v);
    abs_soft_y_shift_v := SHR(SHL(abs_soft_y_shift_v, "1"), count_v);
    
    -- saturate to MANTLEN_CT
    if abs_soft_x_shift_v > MAX_INTERNAL_CT  then
      abs_soft_x_shift_v := conv_std_logic_vector(MAX_INTERNAL_CT,abs_soft_x_shift_v'length);
    end if;
    if abs_soft_y_shift_v > MAX_INTERNAL_CT then
      abs_soft_y_shift_v := conv_std_logic_vector(MAX_INTERNAL_CT,abs_soft_y_shift_v'length);
    end if;

    -- last shift and round 
    abs_soft_x_shift_v := abs_soft_x_shift_v + reducerasures_i + '1';
    abs_soft_y_shift_v := abs_soft_y_shift_v + reducerasures_i + '1';
    abs_soft_x_shift_v := SHR(abs_soft_x_shift_v, "10");
    abs_soft_y_shift_v := SHR(abs_soft_y_shift_v, "10");

    -- come back to the original sign
    if sign_x_v = '1' then -- negative
      abs_soft_x_shift_v := not(abs_soft_x_shift_v) + '1';
    end if;
    if sign_y_v = '1' then -- negative
      abs_soft_y_shift_v := not(abs_soft_y_shift_v) + '1';
    end if;

    soft_x1_d <= abs_soft_x_shift_v(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y1_d <= abs_soft_y_shift_v(SOFTBIT_WIDTH_CT-1 downto 0);
    
  end process soft_x1_p;


  ------------------------------------------
  -- Sequential part stage 1
  ------------------------------------------
  seq_p: process( reset_n, clk )
  begin
    if reset_n = '0' then
      cormanr_o         <= (others =>'0');
      cormani_o         <= (others =>'0');
      hpowman_o         <= (others =>'0');
      secondexp_o       <= (others =>'0');

      soft_x0_o         <= (others =>'0');
      soft_y0_o         <= (others =>'0');

      soft_y1_tmp       <= (others =>'0');
      soft_x1_tmp       <= (others =>'0');

      data_valid_o      <= '0';
      start_of_symbol_o <= '0';
      start_of_burst_o  <= '0';
      qam_mode_o        <= BPSK_CT;
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
          hpowman_o    <= hpowman_i;
          secondexp_o  <= secondexp_i;
          soft_x0_o    <= soft_x0_i;
          soft_y0_o    <= soft_y0_i;
          soft_x1_tmp  <= soft_x1_d;
          soft_y1_tmp  <= soft_y1_d;
          data_valid_o <= '1';
          qam_mode_o   <= qam_mode_i;
        else
          data_valid_o <= '0';
        end if;

        if start_of_symbol_i = '1' then
          start_of_symbol_o <='1';
        else
          start_of_symbol_o <='0';
        end if;

        if start_of_burst_i = '1' then
          start_of_burst_o <='1';
        else
          start_of_burst_o <='0';
        end if;

      end if;
    end if;
  end process seq_p;

  -- dummy assignment
  soft_x1_o  <= soft_x1_tmp;
  soft_y1_o  <= soft_y1_tmp;
  
end rtl;
