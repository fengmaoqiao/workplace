
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: ofdm_preamble_detector.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : OFDM Preamble Presence Detector
--               This block increments a counter when a .11a short training 
--               symbols is detected without a subsequent valid Signal field.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/ofdm_preamble_detector/vhdl/rtl/ofdm_preamble_detector.vhd,v  
--  Log: ofdm_preamble_detector.vhd,v  
-- Revision 1.1  2005/01/12 16:21:11  Dr.J
-- #BugId:727#
-- initial release
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_unsigned.ALL; 
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity ofdm_preamble_detector is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n      : in  std_logic;
    clk          : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    reg_rstoecnt   : in  std_logic;
    a_b_mode       : in  std_logic;
    cp2_detected   : in  std_logic;
    rxe_errorstat  : in  std_logic_vector(1 downto 0);
    phy_cca_ind    : in  std_logic;
    ofdmcoex       : out std_logic_vector(7 downto 0)
  );

end ofdm_preamble_detector;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of ofdm_preamble_detector is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal phy_cca_ind_ff1         : std_logic;
  signal cp2_detected_saved      : std_logic;
  signal ofdmcoex_int            : std_logic_vector(7 downto 0);
  
  signal cp2_detected_ff1_resync : std_logic;
  signal cp2_detected_ff2_resync : std_logic;
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin


  detection_p : process (clk,reset_n)
  begin
    if reset_n = '0' then
      phy_cca_ind_ff1         <= '0';
      cp2_detected_saved      <= '0';
      cp2_detected_ff1_resync <= '0';
      cp2_detected_ff2_resync <= '0';
      ofdmcoex_int            <= (others => '0');
    elsif clk'event and clk ='1' then
      phy_cca_ind_ff1 <= phy_cca_ind;
      cp2_detected_ff1_resync <= cp2_detected;
      cp2_detected_ff2_resync <= cp2_detected_ff1_resync;
      
      if cp2_detected_ff2_resync = '1' and cp2_detected_saved = '0' then
        cp2_detected_saved <= '1';
      end if;  

      if phy_cca_ind_ff1 = '1' and phy_cca_ind = '0' then
        if a_b_mode = '0' and (cp2_detected_saved = '0' or rxe_errorstat = "01") then
          if ofdmcoex_int /= "11111111" then
            ofdmcoex_int <= ofdmcoex_int + '1'; 
          end if;
        end if;
        cp2_detected_saved <= '0';
      end if;
        
      if reg_rstoecnt = '1' then  
        ofdmcoex_int    <= (others => '0');
      end if;

    end if;
  end process detection_p;
  
  ofdmcoex <= ofdmcoex_int;

end RTL;


--阈值相乘
ca_rl_ac_mult_i <= rnd_unsigned_slv((unsigned(ca_rl) * unsigned(thr_ac_i)), 5);
--比较判决
if (en_20m = '1' and (unsigned(ext(ca_ac, ca_rl_ac_mult_i'length)) > unsigned(ca_rl_ac_mult_i))) then 
    ac_det_d <= '1';
else
    ac_det_d <= '0';
end if;


if (en_20m = '1' and (unsigned(ext(ca_cc, ca_rl_cc_mult_i'length)) > unsigned(ca_rl_cc_mult_i))) then
        cc_det_d  <= '1';
    else
        cc_det_d  <= '0';
    end if;
    
     mod_approx_1 : mod_approx
    generic map (
      data_size_g => 16,
      num_ct_g    => 4
    )
    port map (
      data_in_i => add_out_i,
      data_in_q => add_out_q,
      --
      data_out  => ca_cc_int
    );

    -- Mux output
    ca_cc_mux <= (others => '0') when (first16_sample = '1') else
                 ca_cc_int;