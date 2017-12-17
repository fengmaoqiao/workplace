--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 2717 $
--/ $Date: 2010-05-25 15:16:31 +0200 (Tue, 25 May 2010) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      :  OFDM Auto Correlator 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/AGC/ofdm_corr/vhdl/rtl/ofdm_auto_corr.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
  library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;

  library std;
  use std.textio.all;

  library commonlib;
  use work.mdm_math_func_pkg.all;

  library ofdm_corr_rtl;
  use work.ofdm_corr_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
  entity ofdm_auto_corr is
  generic (
  data_in_g  : integer := 10;
  num_ct_g   : integer := 4;
  data_out_g : integer := 14
  );
  port(
    ----------------------------------
    -- Inputs Declaration
    ----------------------------------
    clk            :  in std_logic;                              -- Clock
    reset_n        :  in std_logic;                              -- Reset (Active LOW)
    agc_ca_en      :  in std_logic_vector( 1 downto 0);          -- Enable from AGC FSM
    en_20m_i       :  in std_logic;                              -- 20MHz enable
    zero1_samples  :  in std_logic;                              -- First 16/32 samples 
    zero2_samples  :  in std_logic;                              -- First 17/33 samples
    i_inbd         :  in std_logic_vector(data_in_g-1 downto 0); -- Current i sample
    q_inbd         :  in std_logic_vector(data_in_g-1 downto 0); -- Current q sample
    i_inbd_ff16    :  in std_logic_vector(data_in_g-1 downto 0); -- 16D i sample
    q_inbd_ff16    :  in std_logic_vector(data_in_g-1 downto 0); -- 16D q sample
    i_inbd_ff32    :  in std_logic_vector(data_in_g-1 downto 0); -- 32D i sample
    q_inbd_ff32    :  in std_logic_vector(data_in_g-1 downto 0); -- 32D q sample
    i_inbd_ff64    :  in std_logic_vector(data_in_g-1 downto 0); -- 64D i sample
    q_inbd_ff64    :  in std_logic_vector(data_in_g-1 downto 0); -- 64D q sample

    ----------------------------------
    -- Outputs Declaration
    ----------------------------------
    ca_ac          : out std_logic_vector(data_out_g-1 downto 0) -- Auto correlator output
  );
  end entity ofdm_auto_corr;

---------------------------------------------------
-- Architecture
---------------------------------------------------
  architecture RTL of ofdm_auto_corr is

  ---------------- Constants Declaration ---------------------------
  constant zeros_ct   : std_logic_vector(31 downto 0) := (others => '0');
  constant ones_ct    : std_logic_vector(31 downto 0) := (others => '1');

  ----------------- Signals Declaration ------------------------------
  signal en_20m_ff0          : std_logic;
  signal en_20m_ff1          : std_logic;
  signal en_20m_ff2          : std_logic;
  signal i_ff_sel            : std_logic_vector(data_in_g-1 downto 0);
  signal q_ff_sel            : std_logic_vector(data_in_g-1 downto 0);
  signal i_ff_data           : std_logic_vector(data_in_g-1 downto 0);
  signal q_ff_data           : std_logic_vector(data_in_g-1 downto 0);
  signal i_ff_data_sextd     : std_logic_vector(data_in_g+1 downto 0);
  signal q_ff_data_sextd     : std_logic_vector(data_in_g+1 downto 0);
  signal i_inbd_sextd        : std_logic_vector(data_in_g+1 downto 0);
  signal q_inbd_sextd        : std_logic_vector(data_in_g+1 downto 0);
  signal iq_add              : std_logic_vector(data_in_g+1 downto 0);
  signal iq_add_int          : std_logic_vector(data_in_g+1 downto 0);
  signal iq_sub              : std_logic_vector(data_in_g+1 downto 0);
  signal iq_sub_int          : std_logic_vector(data_in_g+1 downto 0);
  signal iq_add_comp         : std_logic_vector(data_in_g+1 downto 0);
  signal iq_sub_comp         : std_logic_vector(data_in_g+1 downto 0);
  signal iq_ff_add           : std_logic_vector(data_in_g+1 downto 0);
  signal iq_ff_add_int       : std_logic_vector(data_in_g+1 downto 0);
  signal iq_ff_sub           : std_logic_vector(data_in_g+1 downto 0);
  signal iq_ff_sub_int       : std_logic_vector(data_in_g+1 downto 0);
  signal iq_ff_add_comp      : std_logic_vector(data_in_g+1 downto 0);
  signal iq_ff_sub_comp      : std_logic_vector(data_in_g+1 downto 0);
  signal iq_ff_mux_sel       : std_logic_vector( 1 downto 0);
  signal iq_mux_sel          : std_logic_vector( 1 downto 0);
  signal i_add_in1_int       : std_logic_vector(data_in_g+1 downto 0);
  signal q_add_in1_int       : std_logic_vector(data_in_g+1 downto 0);
  signal i_add_in1           : std_logic_vector(data_in_g+1 downto 0);
  signal q_add_in1           : std_logic_vector(data_in_g+1 downto 0);
  signal i_add_in2           : std_logic_vector(data_in_g+1 downto 0);
  signal q_add_in2           : std_logic_vector(data_in_g+1 downto 0);
  signal i_add_in1_sextd     : std_logic_vector(data_out_g+1 downto 0);
  signal q_add_in1_sextd     : std_logic_vector(data_out_g+1 downto 0);
  signal i_add_in2_sextd     : std_logic_vector(data_out_g+1 downto 0);
  signal q_add_in2_sextd     : std_logic_vector(data_out_g+1 downto 0);
  signal i_add_out           : std_logic_vector(data_out_g+1 downto 0);
  signal q_add_out           : std_logic_vector(data_out_g+1 downto 0);
  signal i_add_out_ff        : std_logic_vector(data_out_g downto 0);
  signal q_add_out_ff        : std_logic_vector(data_out_g downto 0);
  --signal data_mod_approx     : std_logic_vector(data_out_g+num_ct_g downto 0);
  signal ca_ac_int           : std_logic_vector(data_out_g+1 downto 0);
  signal ca_ac_mux           : std_logic_vector(data_out_g+1 downto 0);
  signal ca_ac_i             : std_logic_vector(data_out_g-1 downto 0);

  ------------------------------------
  -- Architecture Body
  ------------------------------------
  begin

    -- en_20m_i delay line
    en_20m_ff_p: process (reset_n, clk)
    begin
      if (reset_n = '0') then
        en_20m_ff0 <= '0';
        en_20m_ff1 <= '0';
        en_20m_ff2 <= '0';
      elsif clk'event and clk = '1' then
        en_20m_ff0 <= en_20m_i;
        en_20m_ff1 <= en_20m_ff0;
        en_20m_ff2 <= en_20m_ff1; 
      end if;
    end process en_20m_ff_p;

    mux_sel_p: process (agc_ca_en, i_inbd_ff64, q_inbd_ff64, i_inbd_ff32, 
                        q_inbd_ff32, i_inbd_ff16, q_inbd_ff16)
      variable i_ff_sel_v  : std_logic_vector(data_in_g-1 downto 0);
      variable q_ff_sel_v  : std_logic_vector(data_in_g-1 downto 0);
      variable i_ff_data_v : std_logic_vector(data_in_g-1 downto 0);
      variable q_ff_data_v : std_logic_vector(data_in_g-1 downto 0);
    begin
      i_ff_sel_v  := (others => '0');
      q_ff_sel_v  := (others => '0');
      i_ff_data_v := (others => '0');
      q_ff_data_v := (others => '0');

      case agc_ca_en is
        when "00" =>
          i_ff_sel_v  := (others => '0');
          q_ff_sel_v  := (others => '0');
          i_ff_data_v := (others => '0');
          q_ff_data_v := (others => '0');
        when "01" =>
          i_ff_sel_v  := i_inbd_ff32;
          q_ff_sel_v  := q_inbd_ff32;
          i_ff_data_v := i_inbd_ff16;
          q_ff_data_v := q_inbd_ff16;
        when others =>
          i_ff_sel_v  := i_inbd_ff64;
          q_ff_sel_v  := q_inbd_ff64;
          i_ff_data_v := i_inbd_ff32;
          q_ff_data_v := q_inbd_ff32;
      end case; 
      i_ff_sel  <= i_ff_sel_v;
      q_ff_sel  <= q_ff_sel_v;
      i_ff_data <= i_ff_data_v;
      q_ff_data <= q_ff_data_v;
    end process mux_sel_p;

    ---------------- Adder operand selection ----------------
    i_ff_data_sextd <= sxt(i_ff_data,iq_ff_add'high+1);
    q_ff_data_sextd <= sxt(q_ff_data,iq_ff_add'high+1);
    i_inbd_sextd    <= sxt(i_inbd,iq_add'high+1);
    q_inbd_sextd    <= sxt(q_inbd,iq_add'high+1);

    --IQ加减组合
    iq_ff_add      <= signed(i_ff_data_sextd) + signed(q_ff_data_sextd);
    iq_ff_add_int  <= "100000000001" when (iq_ff_add = "100000000000") else
                      iq_ff_add; 
    iq_ff_add_comp <= "000000000000" - iq_ff_add_int;
    iq_ff_sub      <= signed(i_ff_data_sextd) - signed(q_ff_data_sextd);
    iq_ff_sub_int  <= "100000000001" when (iq_ff_sub = "100000000000") else
                      iq_ff_sub;
    iq_ff_sub_comp <= "000000000000" - iq_ff_sub_int;

    -- iq_add = i + q
    iq_add      <= signed(i_inbd_sextd) + signed(q_inbd_sextd);
    iq_add_int  <= "100000000001" when (iq_add = "100000000000") else
                   iq_add;
    iq_add_comp <= "000000000000" - iq_add_int;
    -- iq_sub = i - q
    iq_sub      <= signed(i_inbd_sextd) - signed(q_inbd_sextd);
    iq_sub_int  <= "100000000001" when (iq_sub = "100000000000") else
                   iq_sub;
    iq_sub_comp <= "000000000000" - iq_sub_int;
    
    --取符号位量化
    iq_ff_mux_sel <= i_ff_sel(i_ff_sel'high) & q_ff_sel(q_ff_sel'high);
    --取符号位量化
    iq_mux_sel    <= i_ff_data(i_ff_data'high) & q_ff_data(q_ff_data'high);

    add_in1_mux_p: process (iq_ff_mux_sel,iq_ff_add,iq_ff_add_comp,iq_ff_sub,iq_ff_sub_comp)
    begin
      i_add_in1_int <= (others => '0');
      q_add_in1_int <= (others => '0');
      case iq_ff_mux_sel is
        --根据符号位选择加减组合合成IQ
        when "00" =>                                            
          i_add_in1_int <= iq_ff_add;               --new R = i+q
          q_add_in1_int <= iq_ff_sub_comp;          --new I = -i+q
        when "01" => 
          i_add_in1_int <= iq_ff_sub;               --new R = i-q
          q_add_in1_int <= iq_ff_add;               --new I = i+q
        when "10" => 
          i_add_in1_int <= iq_ff_sub_comp;          --new R = -i+q
          q_add_in1_int <= iq_ff_add_comp;          --new I = -i-q
        when others => 
          i_add_in1_int <= iq_ff_add_comp;          --new R = -i-q
          q_add_in1_int <= iq_ff_sub;               --new I = i-q
      end case;
    end process add_in1_mux_p;

    add_in2_mux_p: process (iq_mux_sel,iq_add,iq_add_comp,iq_sub,iq_sub_comp)
    begin
      i_add_in2 <= (others => '0');
      q_add_in2 <= (others => '0');
      case iq_mux_sel is
        when "00" =>
          i_add_in2 <= iq_add;
          q_add_in2 <= iq_sub_comp;
        when "01" => 
          i_add_in2 <= iq_sub;
          q_add_in2 <= iq_add;
        when "10" => 
          i_add_in2 <= iq_sub_comp;
          q_add_in2 <= iq_add_comp;
        when others => 
          i_add_in2 <= iq_add_comp;
          q_add_in2 <= iq_sub;
      end case;
    end process add_in2_mux_p;

    i_add_in1      <= (others => '0') when (zero1_samples = '1') else
                      i_add_in1_int;

    q_add_in1      <= (others => '0') when (zero1_samples = '1') else
                      q_add_in1_int; 

    ---------- Sign Extension ----------
    i_add_in1_sextd <= sxt(i_add_in1,i_add_out'high+1);
    q_add_in1_sextd <= sxt(q_add_in1,q_add_out'high+1);
    i_add_in2_sextd <= sxt(i_add_in2,i_add_out'high+1);
    q_add_in2_sextd <= sxt(q_add_in2,q_add_out'high+1);

    ----------- Compensation ------------
    --i_add_out   <= (signed(i_add_in2_sextd) - signed(i_add_in1_sextd)) + signed(i_add_out_ff);
    --q_add_out   <= (signed(q_add_in2_sextd) - signed(q_add_in1_sextd)) + signed(q_add_out_ff);

    ----------- Delayed adder input --------
    add_out_p: process (reset_n, clk)
    begin
     if (reset_n = '0') then
       i_add_out <= (others => '0');
       q_add_out <= (others => '0');
     elsif (clk'event and clk = '1') then
       if (agc_ca_en /= "00") then
         if (en_20m_i = '1') then
           i_add_out <= (signed(i_add_in2_sextd) - signed(i_add_in1_sextd)) + signed(i_add_out);
           q_add_out <= (signed(q_add_in2_sextd) - signed(q_add_in1_sextd)) + signed(q_add_out);
           --i_add_out_ff <= i_add_out;
           --q_add_out_ff <= q_add_out;
         end if;
       else
         i_add_out <= (others => '0');
         q_add_out <= (others => '0');
       end if;
     end if; 
    end process add_out_p;

    --------- Mod Approx -----------------
    mod_approx_1 : mod_approx
    generic map (
      data_size_g => 16,
      num_ct_g => 4
    )
    port map(
      data_in_i => i_add_out,
      data_in_q => q_add_out,
      --
      data_out  => ca_ac_int
    );

    -- Mux output
    ca_ac_mux <= (others => '0') when (zero2_samples = '1') else
                 ca_ac_int;

    -- Saturation
    ca_ac_p: process (reset_n, clk)
    begin
      if (reset_n = '0') then
        ca_ac_i <= (others => '0');
      elsif (clk'event and clk = '1') then
        if (agc_ca_en /= "00") then
          if (en_20m_ff2 = '1') then
            ca_ac_i <= sat_unsigned_slv(ca_ac_mux,2);
          end if;
        else
          ca_ac_i <= (others => '0');
        end if;
      end if;
    end process ca_ac_p;

    -- OFDM auto correlator output
    ca_ac <= ca_ac_i;

  end architecture RTL;

--------------------------------------------------------
-- End of file
--------------------------------------------------------
