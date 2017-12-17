--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 4930 $
--/ $Date: 2010-08-11 14:35:34 +0200 (Wed, 11 Aug 2010) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/AGC/agc/vhdl/rtl/plat_search.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Libraries
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--library commonlib;
use work.mdm_math_func_pkg.all;

--------------------------------------------------------------------------------
-- Entity       
--------------------------------------------------------------------------------

entity plat_search is
  generic (
    del_samp_plat_g : natural:=12; -- Sample input enable delay in clock cycles                   
    tim_w_g         : natural:=6;  -- Sample timer width
    ind_g           : natural:=1;  -- DL Pant to compute difference with dl_pant(0)
    ndl_g           : natural:=5;  -- Pant delay line length
    pant_w_g        : natural:=10  -- Pant_dbm bit width
  );
  port ( 
    reset_n          : in std_logic; --  Asynchronous reset                                              
    clk              : in std_logic; --  60 MHz
    en_20m           : in std_logic; --  20MHz enable (CA data timing reference)
    plat_en          : in std_logic; --  Plateau search enable
    sat_found        : in std_logic; --  Saturation found
    ca_det           : in std_logic; --  OFDM detected
    --  Pant sample valid info
    dl_pvalid        : in std_logic_vector(ndl_g-1 downto 0);          
    --  Pant delay line output (all DL taps)
    dl_pant          : in std_logic_vector(ndl_g*pant_w_g-1 downto 0);
    --  Plateau search time in 20MHz steps
    reg_del_plat     : in std_logic_vector(6 downto 0);    
    --  Plateau search time in 20MHz steps if saturation has been found 
    reg_del_plat_sat : in std_logic_vector(6 downto 0); 
    --  Pant difference register value
    reg_dp_plat      : in std_logic_vector(3 downto 0); 
    --  Plateau threshold register value 
    reg_thr_plat_cor : in std_logic_vector(7 downto 0); 
      
    plat_found       : out std_logic  -- Plateau found
  );
end plat_search;


--------------------------------------------------------------------------------
-- Architecture 
--------------------------------------------------------------------------------

architecture rtl of plat_search is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------


  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type dl_mem_t is array (0 to ndl_g-1) of std_logic_vector(pant_w_g-1 downto 0);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal dl_pant_i        : dl_mem_t; -- 
  -- Pant difference result
  signal pant_diff_i      : std_logic_vector(pant_w_g downto 0);

  -- Plateau counter 
  signal plat_cnt_d        : std_logic_vector(6 downto 0); -- (DFF in)
  signal plat_cnt_q        : std_logic_vector(6 downto 0); -- (DFF out)
  signal plat_cnt_expire_i : std_logic; -- Plateau timer reached its maximum

  -- Plateau found
  signal plat_found_d : std_logic; -- (DFF in)
  signal plat_found_q : std_logic; -- (DFF out)

  -- Comparator: dl_pant(0) < 4*reg_thr_plat_cor
  signal pant0_lt_plat_thr_d : std_logic; -- (DFF in)
  signal pant0_lt_plat_thr_q : std_logic; -- (DFF out)

  -- Comparator: dl_pant(0)-dl_pant(ind_g) < reg_dp_plat
  signal diff_pant_lt_dp_plat_d : std_logic; -- (DFF in)
  signal diff_pant_lt_dp_plat_q : std_logic; -- (DFF out)

  -- Sample timer
  signal tim_d : std_logic_vector(tim_w_g-1 downto 0); -- (DFF in)
  signal tim_q : std_logic_vector(tim_w_g-1 downto 0); -- (DFF out)
  signal smpl_en_i : std_logic;

begin

  ----
  -- All DFF
  dff_p:
  process(reset_n, clk)
  begin
    if (reset_n = '0') then
      plat_found_q            <= '0';
      pant0_lt_plat_thr_q     <= '0';
      diff_pant_lt_dp_plat_q  <= '0';
      plat_cnt_q              <= (others => '0');
      tim_q                   <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (plat_en='0') then -- Clear
        plat_found_q            <= '0';
        pant0_lt_plat_thr_q     <= '0';
        diff_pant_lt_dp_plat_q  <= '0';
        plat_cnt_q              <= (others => '0');
        tim_q                   <= (others => '0');
      else
        plat_found_q            <= plat_found_d;
        pant0_lt_plat_thr_q     <= pant0_lt_plat_thr_d;
        diff_pant_lt_dp_plat_q  <= diff_pant_lt_dp_plat_d;
        plat_cnt_q              <= plat_cnt_d;
        tim_q                   <= tim_d;
      end if;
    end if;
  end process dff_p;
----

  ----
  -- Sample enable timer (combinational)
  tim_cmb_p:
  process(tim_q)
  begin
    if (conv_integer(unsigned(tim_q)) = del_samp_plat_g-1) then
      smpl_en_i <= '1';
      tim_d     <= (others => '0');
    else
      smpl_en_i <= '0';
      tim_d     <= unsigned(tim_q) + 1;
    end if;
  end process tim_cmb_p;
----

  ----
  -- Assign dl_pant to array for better handling
  dl_pant_gen:
  for i in 0 to ndl_g-1 generate
    dl_pant_i(i) <= dl_pant((i+1)*pant_w_g-1 downto pant_w_g*i);
  end generate dl_pant_gen;

  ----
  -- Plateau counter (combinational)
  plat_cnt_cmb_p:
  process(en_20m, sat_found, plat_found_q, plat_cnt_q,
    reg_del_plat_sat, reg_del_plat)
  begin
    -- Defaults
    plat_cnt_d        <= plat_cnt_q;
    plat_cnt_expire_i <= '0';

    if (unsigned(plat_cnt_q)=unsigned(reg_del_plat) and sat_found='0') then
      plat_cnt_d        <= plat_cnt_q;
      plat_cnt_expire_i <= '1'; 
    elsif (unsigned(plat_cnt_q)=unsigned(reg_del_plat_sat) and sat_found='1') then
      plat_cnt_d        <= plat_cnt_q;
      plat_cnt_expire_i <= '1'; 
    elsif (en_20m='1' and plat_found_q='0') then
      plat_cnt_d        <= unsigned(plat_cnt_q) + 1;
      plat_cnt_expire_i <= '0'; 
    else
      plat_cnt_d        <= plat_cnt_q;
      plat_cnt_expire_i <= '0'; 
    end if;
  end process plat_cnt_cmb_p;
----

  ----
  -- comparator dl_pant_0 < 4*reg_thr_plat_cor
  comp_pant0_thr_plat_cor_cmb_p:
  process(smpl_en_i, dl_pant_i, dl_pvalid, reg_thr_plat_cor,
    pant0_lt_plat_thr_q)
    variable reg_thr_plat_cor_4_v : std_logic_vector(9 downto 0);
  begin
    reg_thr_plat_cor_4_v :=reg_thr_plat_cor & "00";
     
    if (smpl_en_i='1') then
      if (dl_pvalid(0)='1' and ( 
          signed(dl_pant_i(0)) <= signed(reg_thr_plat_cor_4_v))) then
        pant0_lt_plat_thr_d <= '1';
      else
        pant0_lt_plat_thr_d <= '0';
      end if;
    else
      pant0_lt_plat_thr_d <= pant0_lt_plat_thr_q;
    end if;
  end process comp_pant0_thr_plat_cor_cmb_p; 
----
    
  ----
  -- dl_pant(0) - dl_pant(ind_g)
  pant_diff_i <= signed(sxt(dl_pant_i(0), pant_w_g+1)) - 
                 signed(sxt(dl_pant_i(ind_g), pant_w_g+1));

  ----
  -- comparator pant_diff_i < reg_dp_plat
  comp_pant_diff_dp_plat_cmb_p:
  process(smpl_en_i, pant_diff_i, dl_pvalid, reg_dp_plat, 
    diff_pant_lt_dp_plat_q)
  begin
    if (smpl_en_i='1') then
      if (signed(pant_diff_i) < unsigned(ext(reg_dp_plat, pant_diff_i'length)) and
          dl_pvalid(0)='1' and dl_pvalid(ind_g)='1') then
        diff_pant_lt_dp_plat_d <= '1';
      else
        diff_pant_lt_dp_plat_d <= '0';
      end if;
    else
      diff_pant_lt_dp_plat_d <= diff_pant_lt_dp_plat_q;
    end if;
  end process comp_pant_diff_dp_plat_cmb_p;
----

  ----
  -- Plateau found (combinational)
  plat_found_cmb_p:
  process(ca_det, sat_found, plat_cnt_expire_i, diff_pant_lt_dp_plat_q,
    pant0_lt_plat_thr_q)
  begin
    if (sat_found='1') then
      if (plat_cnt_expire_i='1' or ca_det='1') then
        plat_found_d <= '1';
      else
        plat_found_d <= '0';
      end if;
    else  -- sat_found='0'
      if (plat_cnt_expire_i='1' or 
          ((ca_det='1' or pant0_lt_plat_thr_q='1') 
          and diff_pant_lt_dp_plat_q='1')) then
        plat_found_d <= '1';
      else
        plat_found_d <= '0';
      end if;
    end if;
  end process plat_found_cmb_p;
----

  ----
  -- Output assignement
  plat_found <= plat_found_q;

end rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

