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
--/ Description      : OFDM preamble detector 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/AGC/agc/vhdl/rtl/ofdm_det.vhd $
--/
--////////////////////////////////////////////////////////////////////////////



-------------------------------------------------------------------------------
-- Libraries
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


library commonlib;
use work.mdm_math_func_pkg.all;

--------------------------------------------------------------------------------
-- Entity       
--------------------------------------------------------------------------------

entity ofdm_det is
  generic (
    ca_ac_w_g : natural := 14;
    ca_cc_w_g : natural := 14;
    ca_rl_w_g : natural := 14
  );
  port ( 
    reset_n          : in std_logic;  -- Asynchronous reset                    
    clk              : in std_logic;  -- 60 MHz
    en_20m           : in std_logic;  -- 20MHz enable (data timing reference)
    ca_en            : in std_logic_vector(1 downto 0);  -- OFDM detector enable
    ca_ac            : in std_logic_vector(ca_ac_w_g-1 downto 0);  -- OFDM autocorrelation
    ca_cc            : in std_logic_vector(ca_cc_w_g-1 downto 0);  -- OFDM cross-correlation
    ca_rl            : in std_logic_vector(ca_rl_w_g-1 downto 0);  -- OFDM reference level
    reg_thr_ac_plat  : in std_logic_vector(5 downto 0);  -- AC threshold in Plateau search
    reg_thr_cc_plat  : in std_logic_vector(5 downto 0);  -- CC threshold in Plateau search
    reg_mix_acc_plat : in std_logic;  -- Detection selection in Plateau search
    reg_thr_ac_cs2   : in std_logic_vector(5 downto 0);  -- AC threshold in CS2
    reg_thr_cc_cs2   : in std_logic_vector(5 downto 0);  -- CC threshold in CS2
    reg_cc_peak_cs2  : in std_logic_vector(1 downto 0);  -- Peak number in CS2
    reg_mix_acc_cs2  : in std_logic;  -- Detection selection in CS 2

    ca_det           : out std_logic; -- OFDM detected
    ca_rlw           : out std_logic_vector(ca_ac_w_g+1 downto 0);  -- OFDM reference level
    ca_ac_out        : out std_logic_vector(ca_ac_w_g-1 downto 0)   -- OFDM autocorrelation
  );
end ofdm_det;
 

--------------------------------------------------------------------------------
-- Architecture 
--------------------------------------------------------------------------------

architecture rtl of ofdm_det is


  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant FAST_MODE : std_logic_vector(1 downto 0):="11";


  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type dl_rslt_t is array (0 to 15) of std_logic_vector(1 downto 0);
  
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal en_20m_q        : std_logic; -- (DFF OUT)
  -- Register value Multiplexer 
  -- thr_cc
  signal thr_cc_i        : std_logic_vector(5 downto 0); -- (combinational)
  -- thr_ac
  signal thr_ac_i        : std_logic_vector(5 downto 0); -- (combinational)
    -- Detection mixing selection
  signal det_mix_i       : std_logic; -- (combinational)

  -- RND(CA_RL*thr_ac_i)
  signal ca_rl_ac_mult_i : std_logic_vector(ca_ac_w_g+1 downto 0); -- (combinational)
  -- RND(CA_RL*thr_cc_i)
  signal ca_rl_cc_mult_i : std_logic_vector(ca_ac_w_g+1 downto 0); -- (combinational)

  -- Detection result
  signal det_i           : std_logic; -- (combinational)

  -- ac_ac_p1_q > ca_rlw_p1_q comparator
  signal ac_det_d        : std_logic; -- (DFF in)
  signal ac_det_q        : std_logic; -- (DFF out)
  -- ca_ac_p1_q > ca_rlw_cc_p1_q comparator
  signal cc_det_d        : std_logic; -- (DFF in)
  signal cc_det_q        : std_logic; -- (DFF out)
 
  -- CA_AC z-1 delay
  signal ca_ac_d         : std_logic_vector(ca_ac_w_g-1 downto 0); -- (DFF in)
  signal ca_ac_q         : std_logic_vector(ca_ac_w_g-1 downto 0); -- (DFF out)

  -- CA_RLW z-1 delay
  signal ca_rlw_d        : std_logic_vector(ca_ac_w_g+1 downto 0); -- (DFF in)
  signal ca_rlw_q        : std_logic_vector(ca_ac_w_g+1 downto 0); -- (DFF out)

  -- CA_DET z-1 delay
  signal ca_det_d        : std_logic; -- (DFF in)
  signal ca_det_q        : std_logic; -- (DFF out)

  -- Number of CC peaks
  signal nb_cc_peak_i    : std_logic_vector(1 downto 0); -- (combinational)
  -- CC peak detection
  signal cc_peak_i       : std_logic; -- (combinational)

  -- Result delay line
  signal dl_rslt_d       : dl_rslt_t; -- (DFF in)
  signal dl_rslt_q       : dl_rslt_t; -- (DFF out)

  -- Outputs
  signal ca_det_out_d    : std_logic; -- (DFF in)
  signal ca_ac_out_d     : std_logic_vector(ca_ac_w_g-1 downto 0); -- (DFF in)
  signal ca_rlw_out_d    : std_logic_vector(ca_ac_w_g+1 downto 0); -- (DFF in)

begin

  ----
  -- All DFF
  dff_p:
  process(reset_n, clk)
  begin
    if (reset_n = '0') then
      en_20m_q  <= '0';
      ac_det_q  <= '0'; 
      cc_det_q  <= '0';
      ca_det_q  <= '0';
      ca_ac_q   <= (others => '0');
      ca_rlw_q  <= (others => '0'); 
      dl_rslt_q <= (others => (others =>'0')); 
      -- Outputs
      ca_det    <= '0';
      ca_ac_out <= (others => '0');  
      ca_rlw    <= (others => '0');  
    elsif (clk'event and clk = '1') then
      if (ca_en = "00") then
        ac_det_q  <= '0'; 
        cc_det_q  <= '0'; 
        ca_det_q  <= '0';
        ca_ac_q   <= (others => '0');
        ca_rlw_q  <= (others => '0'); 
        dl_rslt_q <= (others => (others =>'0')); 
        -- Outputs
        ca_det    <= '0';
        ca_ac_out <= (others => '0');  
        ca_rlw    <= (others => '0');  
      else
        ac_det_q  <= ac_det_d;
        cc_det_q  <= cc_det_d;
        ca_det_q  <= ca_det_d;
        ca_ac_q   <= ca_ac_d;
        ca_rlw_q  <= ca_rlw_d;
        dl_rslt_q <= dl_rslt_d;
        -- Outputs
        ca_det    <= ca_det_out_d;
        ca_ac_out <= ca_ac_out_d;  
        ca_rlw    <= ca_rlw_out_d;  
      end if;
      en_20m_q    <= en_20m;
    end if;
  end process dff_p;
----
  
  -- AC threshold selection
  thr_ac_i <= reg_thr_ac_cs2 when ca_en=FAST_MODE else
              reg_thr_ac_plat;

  -- CC threshold selection
  thr_cc_i <= reg_thr_cc_cs2 when ca_en=FAST_MODE else
              reg_thr_cc_plat;

  -- det_mix selection
  -- 检测模式选择
  det_mix_i <= reg_mix_acc_cs2 when ca_en=FAST_MODE else
               reg_mix_acc_plat;

  -- Number cc peak selection
  -- 峰值检测个数
  nb_cc_peak_i <= reg_cc_peak_cs2 when ca_en=FAST_MODE else
                  "01";

----
  -- Threshold multiplication and rounding
  --
  -- 16u       =  RND((ca_rl/14u * thr_cc_q/6u)/20u, 5)/15u
  -- cc阈值乘以当前功率值
  ca_rl_cc_mult_i <= rnd_unsigned_slv((unsigned(ca_rl) * unsigned(thr_cc_i)), 5);
  -- ac阈值乘以当前功率值  
  -- 16u       =  RND((ca_rl/14u * thr_ac_q/6u)/20u, 5)/15u
  ca_rl_ac_mult_i <= rnd_unsigned_slv((unsigned(ca_rl) * unsigned(thr_ac_i)), 5);


  -- CA_RLW (combinational)
  --
  -- Store ca_rl_ac_mult if there is not detection
  ca_rlw_d     <= ca_rlw_q when (det_i='0' and ca_det_d='1') -- Hold value
                  else ca_rl_ac_mult_i; -- Store
    

  -- CA_AC (combinational)          
  -- Store ca_ac if there is not detection
  ca_ac_d      <= ca_ac_q when (det_i='0' and ca_det_d='1') -- Hold value
                  else ca_ac; -- Store new ca_ac

  -- CA_DET (combinational)
  -- Store OR between registered and new value
  ca_det_d <= ca_det_q or det_i;



  -- CA_DET Output (combinational)
  ca_det_out_d  <= ca_det_q when (ca_en=FAST_MODE) else
                   det_i;
  -- CA_AC Output (combinational)
  ca_ac_out_d  <= ca_ac_q when (ca_en=FAST_MODE) else
                  ca_ac;
  -- CA_RLW Output (combinational)
  ca_rlw_out_d <= ca_rlw_q when (ca_en=FAST_MODE) else
                  ca_rl_ac_mult_i; 


  ----
  -- OFDM detection calculation (combinational)
  ofdm_det_calc_cmb_p:
  process(en_20m, en_20m_q, ca_en, ca_ac, ca_cc,
    ca_rl_ac_mult_i, ca_rl_cc_mult_i, ac_det_q, cc_det_q,
    dl_rslt_q
  )
    variable ext_cmp_v : std_logic_vector(2 downto 0);
  begin
    -- Defaults
    ext_cmp_v := (others => '0');
    ac_det_d  <= ac_det_q;
    cc_det_d  <= cc_det_q;
    dl_rslt_d <= dl_rslt_q;
    
    -- 延迟相关检测结果
    if (en_20m = '1' and (unsigned(ext(ca_ac, ca_rl_ac_mult_i'length)) > unsigned(ca_rl_ac_mult_i))) then 
        ac_det_d <= '1';
    else
        ac_det_d <= '0';
    end if;
    
    -- 互相关检测结果
    if (en_20m = '1' and (unsigned(ext(ca_cc, ca_rl_cc_mult_i'length)) > unsigned(ca_rl_cc_mult_i))) then
        cc_det_d  <= '1';
    else
        cc_det_d  <= '0';
    end if;
 
    if (en_20m_q = '1') then
      -- Result delay line for CA_CC > CA_RLW_CC comparison
      if (ca_en = FAST_MODE) then 
        --  SAT(cc_det_q/2u + dl_rslt_q(15)/2u, 1)/2u
        ext_cmp_v := "00" & cc_det_q;
        dl_rslt_d(0) <= sat_unsigned_slv(
                          unsigned(ext_cmp_v) + unsigned(dl_rslt_q(15)), 1);
      else
        dl_rslt_d(0) <= '0' & cc_det_q;
      end if;
      -- Shift results in delay line
      dl_rslt_d(1 to 15) <= dl_rslt_q(0 to 14);
    end if;

  end process ofdm_det_calc_cmb_p;
----

  ----
  -- CC Peak detection (combinational)
  cc_peak_det_cmb_p:
  process(dl_rslt_q, nb_cc_peak_i)
  begin
    -- Default
    cc_peak_i <= '0';
    -- Evaluate Result delay line
    -- Find at least one Peak number
    for i in 0 to 15 loop
      if (unsigned(dl_rslt_q(i)) >= unsigned(nb_cc_peak_i)) then
        cc_peak_i <= '1';
      end if;
    end loop;
  end process cc_peak_det_cmb_p;
----

  ----
  -- Detection generation (combinational)
  det_cmb_p:
  process(det_mix_i, cc_peak_i, ac_det_q)
  begin
    -- OFDM Detection output mixing setting
    -- OFDM 检测模式选择，根据寄存器选择只用延迟相关算法还是混合算法 
    if (det_mix_i = '0') then
      if (ac_det_q='1' or cc_peak_i='1') then -- Detection
        det_i <= '1';
      else
        det_i <= '0';
      end if;
    else
      if (ac_det_q='1' and cc_peak_i='1') then -- Detection
        det_i <= '1';
      else
        det_i <= '0';
      end if;
    end if;
  end process det_cmb_p;
----

end rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

