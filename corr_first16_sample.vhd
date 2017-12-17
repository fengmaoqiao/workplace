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
--/ Description      : Correlator first 16 samples
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/AGC/ofdm_corr/vhdl/rtl/corr_first16_sample.vhd $
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

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
  entity corr_first16_sample is
  port(
    ----------------------------------
    -- Inputs Declaration
    ----------------------------------
    clk            :  in std_logic;                     -- Clock
    reset_n        :  in std_logic;                     -- Reset (active LOW)
    agc_ca_en      :  in std_logic_vector( 1 downto 0); -- Enable from AGC FSM
    en_20m_i       :  in std_logic;                     -- 20MHz enable
    
    ----------------------------------
    -- Outputs Declaration
    ----------------------------------
    first16_sample : out std_logic;                     -- First 16 samples 
    first17_sample : out std_logic;                     -- First 17 samples
    zero1_samples  : out std_logic;                     -- First 16/32 samples 
    zero2_samples  : out std_logic                      -- First 17/33 samples
  );
  end entity corr_first16_sample;

---------------------------------------------------
-- Architecture
---------------------------------------------------
  architecture RTL of corr_first16_sample is

  ---------------- Constants Declaration ---------------------------
  constant num16_ct    : std_logic_vector(5 downto 0) := "010000";
  constant num17_ct    : std_logic_vector(5 downto 0) := "010001";
  constant num32_ct    : std_logic_vector(5 downto 0) := "100000";
  constant num33_ct    : std_logic_vector(5 downto 0) := "100001";

  ---------------- Signal Declaration ---------------------
  signal sample_cnt    : std_logic_vector(5 downto 0);
  signal cnt_limit     : std_logic_vector(5 downto 0);

  ------------------------------------
  -- Architecture Body
  ------------------------------------
  begin

    cnt_limit <= num33_ct when (agc_ca_en > "01") else
                 num17_ct;
  
    sample_cnt_p : process(reset_n, clk)
    begin
      if (reset_n = '0') then
        sample_cnt <= (others => '0');
      elsif (clk'event and clk = '1') then
        if (agc_ca_en /= "00") then
          if (en_20m_i = '1') then
            if (sample_cnt < cnt_limit) then
              sample_cnt <= sample_cnt + 1;
            else
              sample_cnt <= cnt_limit;
            end if;
          end if;
        else
          sample_cnt <= (others => '0');
        end if;
      end if;
    end process sample_cnt_p;


    -- First 16 samples enable
    first16_sample  <= '1' when (sample_cnt < num16_ct) else
                       '0';

    first17_sample  <= '1' when (sample_cnt < num17_ct) else
                       '0';

    zero1_samples    <= '1' when ((agc_ca_en = "01" and sample_cnt < num16_ct) or
                                (agc_ca_en > "01" and sample_cnt < num32_ct)) else
                        '0';

    zero2_samples    <= '1' when ((agc_ca_en = "01" and sample_cnt < num17_ct) or
                                (agc_ca_en > "01" and sample_cnt < num33_ct)) else
                        '0';
  
  end architecture RTL;

--------------------------------------------------------
-- End of file
--------------------------------------------------------
