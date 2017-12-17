--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 16901 $
--/ $Date: 2011-09-16 16:19:04 +0200 (Fri, 16 Sep 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : Set enables 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/AGC/agc/vhdl/rtl/set_enables.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Libraries
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library agc_rtl;
use agc_rtl.agc_pkg.all;

--------------------------------------------------------------------------------
-- Entity       
--------------------------------------------------------------------------------

entity set_enables is
  port (
    reset_n            : in std_logic;
    reset_sync         : in std_logic;
    clk                : in std_logic;
    en_20m             : in std_logic;
    set_enables_req    : in std_logic;
    clr_all_enables    : in std_logic;
    stop11b_corr       : in std_logic;
    stop11a_corr       : in std_logic;
    set11b_corr        : in std_logic;
    fcs_ok_re          : in std_logic; -- FCS_OK rising edge
    en_state           : in std_logic_vector(3 downto 0);

    reg_modeabg        : in std_logic_vector(1 downto 0);
    -- Registers - enable delays
    reg_del_dc_conv    : in std_logic_vector(3 downto 0);
    reg_del_fea_on     : in std_logic_vector(4 downto 0);
    reg_del_fea_conv   : in std_logic_vector(5 downto 0);
    reg_del_feb_on     : in std_logic_vector(5 downto 0);
    reg_del_feb_conv   : in std_logic_vector(6 downto 0);
    reg_del_pinbd_conv : in std_logic_vector(6 downto 0);
    reg_del_padc_conv  : in std_logic_vector(5 downto 0);
    reg_del_pradarinbd : in std_logic_vector(7 downto 0);

    -- Enables
    dc_en              : out std_logic;
    adc_pow_en         : out std_logic;
    fea_en             : out std_logic;
    inbd_pow_en        : out std_logic;
    ca_en              : out std_logic_vector(1 downto 0);
    feb_en             : out std_logic;
    cb_en              : out std_logic_vector(1 downto 0);
    det_en             : out std_logic;
    p_sat_en           : out std_logic;
    p_adc_en           : out std_logic;
    p_inbd_en          : out std_logic;
    plat_en            : out std_logic;
    y_valid            : out std_logic
  );
end set_enables;


--------------------------------------------------------------------------------
-- Architecture 
--------------------------------------------------------------------------------

architecture rtl of set_enables is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------

  -- Delay counters and ready signals
  signal dc_conv_rdy_i    : std_logic; -- (combinational)

  signal fea_on_rdy_i     : std_logic; -- (combinational)

  signal fea_conv_rdy_i   : std_logic; -- (combinational)

  signal feb_on_rdy_i     : std_logic; -- (combinational)

  signal tim_feb_conv_d   : std_logic_vector(6 downto 0); -- (DFF in)
  signal tim_feb_conv_q   : std_logic_vector(6 downto 0); -- (DFF out)
  signal feb_conv_rdy_i   : std_logic; -- (combinational)

  signal pinbd_conv_rdy_i : std_logic; -- (combinational)

  signal padc_conv_rdy_i  : std_logic; -- (combinational)

  signal pradarinbd_rdy_i : std_logic;

  signal tim_d            : std_logic_vector(7 downto 0); -- (DFF in)
  signal tim_q            : std_logic_vector(7 downto 0); -- (DFF out)

  signal set_enables_req_d : std_logic; -- (DFF in)
  signal set_enables_req_q : std_logic; -- (DFF out)

  -- Enables
  signal dc_en_d       : std_logic;  -- (DFF in)
  signal dc_en_q       : std_logic;  -- (DFF out)
  signal adc_pow_en_d  : std_logic;  -- (DFF in)
  signal adc_pow_en_q  : std_logic;  -- (DFF out)
  signal fea_en_d      : std_logic;  -- (DFF in)
  signal fea_en_q      : std_logic;  -- (DFF out)
  signal inbd_pow_en_d : std_logic;  -- (DFF in)
  signal inbd_pow_en_q : std_logic;  -- (DFF out)
  signal ca_en_d       : std_logic_vector(1 downto 0);  -- (DFF in)
  signal ca_en_q       : std_logic_vector(1 downto 0);  -- (DFF out)
  signal feb_en_d      : std_logic;  -- (DFF in)
  signal feb_en_q      : std_logic;  -- (DFF out)
  signal cb_en_d       : std_logic_vector(1 downto 0);  -- (DFF in)
  signal cb_en_q       : std_logic_vector(1 downto 0);  -- (DFF out)
  signal det_en_d      : std_logic;  -- (DFF in)
  signal det_en_q      : std_logic;  -- (DFF out)
  signal p_adc_en_d    : std_logic;  -- (DFF in)
  signal p_adc_en_q    : std_logic;  -- (DFF out)
  signal p_inbd_en_d   : std_logic;  -- (DFF in)
  signal p_inbd_en_q   : std_logic;  -- (DFF out)
  signal plat_en_d     : std_logic;  -- (DFF in)
  signal plat_en_q     : std_logic;  -- (DFF out)
  signal y_valid_d     : std_logic;  -- (DFF in)
  signal y_valid_q     : std_logic;  -- (DFF out)

begin

  ----
  -- All DFF
  dff_p:
  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      dc_en_q           <= '0';
      adc_pow_en_q      <= '0';
      fea_en_q          <= '0';
      inbd_pow_en_q     <= '0';
      ca_en_q           <= (others => '0');
      feb_en_q          <= '0';
      cb_en_q           <= (others => '0');
      det_en_q          <= '0';
      p_adc_en_q        <= '0';
      p_inbd_en_q       <= '0';
      plat_en_q         <= '0';
      y_valid_q         <= '0';
      set_enables_req_q <= '0';
      tim_feb_conv_q    <= (others => '0');
      tim_q             <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (reset_sync = '1') then
        dc_en_q           <= '0';
        adc_pow_en_q      <= '0';
        fea_en_q          <= '0';
        inbd_pow_en_q     <= '0';
        ca_en_q           <= (others => '0');
        feb_en_q          <= '0';
        cb_en_q           <= (others => '0');
        det_en_q          <= '0';
        p_adc_en_q        <= '0';
        p_inbd_en_q       <= '0';
        plat_en_q         <= '0';
        y_valid_q         <= '0';
        set_enables_req_q <= '0';
        tim_feb_conv_q    <= (others => '0');
        tim_q             <= (others => '0');
      else
        dc_en_q           <= dc_en_d;
        adc_pow_en_q      <= adc_pow_en_d;
        fea_en_q          <= fea_en_d;
        inbd_pow_en_q     <= inbd_pow_en_d;
        ca_en_q           <= ca_en_d;
        feb_en_q          <= feb_en_d;
        cb_en_q           <= cb_en_d;
        det_en_q          <= det_en_d;
        p_adc_en_q        <= p_adc_en_d;
        p_inbd_en_q       <= p_inbd_en_d;
        plat_en_q         <= plat_en_d;
        y_valid_q         <= y_valid_d;
        set_enables_req_q <= set_enables_req_d;
        tim_feb_conv_q    <= tim_feb_conv_d;
        tim_q             <= tim_d;
      end if;
    end if;
  end process dff_p;
----

  
  ----
  -- Main timer for all timers reset only by clr_all_enables
  -- (combinational)
  tim_cmb_p:
  process(clr_all_enables, en_20m, set_enables_req_q, tim_q)
  begin
    -- Defaults
    tim_d <= tim_q;

    -- Clear timer when clr_all_enables received
    if (clr_all_enables='1') then
      tim_d <= (others => '0');

    -- Count while request is set (i.e. until all ready received)
    elsif (set_enables_req_q='1') then
      if (en_20m='1') then
        tim_d <= unsigned(tim_q) + 1;
      end if;
    else
      tim_d <= (others => '0');
    end if;
  end process tim_cmb_p;
----
  
  ----
  -- DC conv delay -> adc_pow_en,p_sat_en (combinational)
  -- p_sat_en output takes the value of adc_pow_en_q.
  tim_dc_conv_cmb_p:
  process(adc_pow_en_q, clr_all_enables, reg_del_dc_conv, set_enables_req_q,
          tim_q)
  begin
    -- Defaults
    adc_pow_en_d  <= adc_pow_en_q;
    dc_conv_rdy_i <= '0';

    -- Reset enables on FSM request
    if (clr_all_enables='1') then
      adc_pow_en_d  <= '0';
      
    -- Set enables on FSM request and when counter has reached register value
    elsif (set_enables_req_q='1') then
      -- Use >= so that rdy signal stays high.
      if (tim_q >= ext(reg_del_dc_conv, tim_q'length)) then
        dc_conv_rdy_i <= '1'; -- DC conv delay ready
        adc_pow_en_d  <= '1'; -- Always '1'
      end if;
    end if;
  end process tim_dc_conv_cmb_p;
----

  ----
  -- Fea On delay -> fea_en (combinational)
  tim_fea_on_cmb_p:
  process(clr_all_enables, fea_en_q, reg_del_fea_on, set_enables_req_q, tim_q)
  begin
    -- Defaults
    fea_en_d     <= fea_en_q;
    fea_on_rdy_i <= '0';

    -- Reset enables on FSM request
    if (clr_all_enables='1') then
      fea_en_d     <= '0';

    -- Set enables on FSM request and when counter has reached register value
    elsif (set_enables_req_q='1') then
      -- Use >= so that rdy signal stays high.
      if (tim_q >= ext(reg_del_fea_on, tim_q'length)) then
        fea_on_rdy_i <= '1'; -- DC conv delay ready
        fea_en_d     <= '1';
      end if;
    end if;
  end process tim_fea_on_cmb_p;
----

  ----
  -- Fea conv delay -> inbd_pow_en (combinational)
  tim_fea_conv_inbd_pow_en_cmb_p:
  process(clr_all_enables, inbd_pow_en_q, reg_del_fea_conv, set_enables_req_q,
          tim_q)
  begin
    -- Defaults
    inbd_pow_en_d  <= inbd_pow_en_q;
    fea_conv_rdy_i <= '0';

    -- Reset enables on FSM request
    if (clr_all_enables='1') then
      inbd_pow_en_d  <= '0';

    -- Set enables on FSM request and when counter has reached register value
    elsif (set_enables_req_q='1') then
      -- Use >= so that rdy signal stays high.
      if (tim_q >= ext(reg_del_fea_conv, tim_q'length)) then
        fea_conv_rdy_i <= '1'; -- DC conv delay ready
        inbd_pow_en_d  <= '1';
      end if;

    end if;
  end process tim_fea_conv_inbd_pow_en_cmb_p;

  -- For ca_en, use same delay but different reset conditions.
  -- It is possible to use tim_q because timer is not reset by stop11a_corr.
  tim_fea_conv_ca_en_cmb_p:
  process(ca_en_q, clr_all_enables, en_state, reg_del_fea_conv,
          set_enables_req_q, stop11a_corr, tim_q)
  begin
    -- Defaults
    ca_en_d        <= ca_en_q;

    -- Reset enables on FSM request
    if (clr_all_enables='1' or stop11a_corr='1') then
      ca_en_d        <= (others => '0');

    -- Set enables on FSM request and when counter has reached register value
    elsif (set_enables_req_q='1') then
      -- For enable states where ca_en must be reset, do not wait for register delay
      if (en_state/="0100" and en_state/="0011" and en_state/="0010") then
        ca_en_d       <= (others => '0');
      
      -- States 2, 3, 4: ca_en takes its value after delay
      elsif (tim_q >= ext(reg_del_fea_conv, tim_q'length)) then

          -- ca_en_d value depends on enable state
          if (en_state="0100" or en_state="0011") then -- state 3,4
            ca_en_d       <= "11";
          elsif (en_state="0010") then -- state 2
            ca_en_d       <= "01";
          end if;

      -- ca_en always goes back to zero during delay before it is set
      else
        ca_en_d        <= (others => '0');
      end if;
    end if;
  end process tim_fea_conv_ca_en_cmb_p;

----

  ----
  -- feb On delay -> feb_en (combinational)
  tim_feb_on_cmb_p:
  process(clr_all_enables, en_state, feb_en_q, reg_del_feb_on, reg_modeabg,
          set_enables_req_q, tim_q)
  begin
    -- Defaults
    feb_en_d     <= feb_en_q;
    feb_on_rdy_i <= '0';

    -- Reset enables on FSM request
    if (clr_all_enables='1') then
      feb_en_d     <= '0';
    elsif (set_enables_req_q='1') then
      -- Reset enable immediately in enable state 8, 3, 2, 1 in A mode
      if (en_state="1000" or
          en_state="0011" or
          en_state="0010" or
          (en_state="0001" and reg_modeabg=MODE_11A_CT)
          ) then
        feb_en_d <= '0';

      -- Set enables after delay from register
      -- en_state 1 in B or B/G mode and all enable states not tested above
      elsif (tim_q >= ext(reg_del_feb_on, tim_q'length)) then
        feb_on_rdy_i <= '1'; -- DC conv delay ready
        feb_en_d     <= '1';

      end if;
    end if;
  end process tim_feb_on_cmb_p;
----

  ----
  -- Feb conv timer -> cb_en (combinational)
  -- Does not use tim_q because the timer must be reset by stop11b_corr
  tim_feb_conv_cmb_p:
  process(cb_en_q, clr_all_enables, en_20m, en_state, reg_del_feb_conv,
          reg_modeabg, set11b_corr, set_enables_req_q, stop11b_corr,
          tim_feb_conv_q)
  begin
    -- Defaults
    cb_en_d        <= cb_en_q;
    tim_feb_conv_d <= tim_feb_conv_q;
    feb_conv_rdy_i <= '0';

    -- Reset enables on FSM request
    if (clr_all_enables='1' or stop11b_corr='1') then
      -- Clear cb_en by AGC FSM or if fcs_ok rising edge is detected
      cb_en_d        <= (others => '0');
      tim_feb_conv_d <= (others => '0');
    elsif (set11b_corr='1') then
      -- Set cb_en to 01 again after FCS_OK rising edge clear
      -- or by set from AGC_FSM
      cb_en_d        <= "01";

    elsif (set_enables_req_q='1') then
      -- Reset enable immediately in enable state 8, 3, 2, 1 in A mode
      if (en_state="1000" or
          en_state="0011" or
          en_state="0010" or
          (en_state="0001" and reg_modeabg=MODE_11A_CT)
          ) then
          cb_en_d <= "00";
      
      -- Set enable after delay from register
      elsif (tim_feb_conv_q = reg_del_feb_conv) then
        feb_conv_rdy_i <= '1'; -- DC conv delay ready
        if (en_state="0111" or en_state="0001") then -- state 7, 1 in b or b/g mode
          cb_en_d <= "01";
        else
          cb_en_d <= "11";
        end if;

      -- Count delay from register
      else
        if (en_20m='1') then
          tim_feb_conv_d <= unsigned(tim_feb_conv_q) + 1;
        end if;
      end if;
    else
      tim_feb_conv_d <= (others => '0');
    end if;
  end process tim_feb_conv_cmb_p;
----

  ----
  -- Pinbd conv delay -> p_inbd_en (combinational)
  tim_pinbd_conv_cmb_p:
  process(clr_all_enables, en_state, p_inbd_en_q, reg_del_pinbd_conv,
          set_enables_req_q, tim_q)
  begin
    -- Defaults
    p_inbd_en_d      <= p_inbd_en_q;
    pinbd_conv_rdy_i <= '0';

    -- Reset enables on FSM request
    if (clr_all_enables='1') then
      p_inbd_en_d      <= '0';

    elsif (set_enables_req_q='1') then
      -- Reset enable immediately in enable state 8, 6
      if (en_state="1000" or en_state="0110") then -- state 8, 6
        p_inbd_en_d <= '0';
        
      -- Set enable after delay from register
      elsif (tim_q >= ext(reg_del_pinbd_conv, tim_q'length)) then
        pinbd_conv_rdy_i <= '1'; -- DC conv delay ready
        p_inbd_en_d      <= '1';

      end if;
    end if;
  end process tim_pinbd_conv_cmb_p;


  -- Pinbd conv delay -> det_en (combinational)
  -- Same ready, but different reset conditions for the enable
  tim_det_conv_cmb_p:
  process(clr_all_enables, det_en_q, en_state, reg_del_pinbd_conv,
          set_enables_req_q, tim_q)
  begin
    -- Defaults
    det_en_d         <= det_en_q;

    -- Reset enables on FSM request
    if (clr_all_enables='1') then
      det_en_d         <= '0';

    elsif (set_enables_req_q='1') then
      -- Reset enable immediately in enable state 8, 6, 2
      if (en_state="1000" or
          en_state="0110" or
          en_state="0010") then -- state 8, 6, 2
        det_en_d    <= '0';

      -- Set enable after delay from register
      elsif (tim_q >= ext(reg_del_pinbd_conv, tim_q'length)) then
        det_en_d    <= '1';
      end if;
    end if;
  end process tim_det_conv_cmb_p;
----

  ----
  -- Padc conv delay -> p_adc_en (combinational)
  tim_padc_conv_cmb_p:
  process(clr_all_enables, en_state, p_adc_en_q, reg_del_padc_conv,
          set_enables_req_q, tim_q)
  begin
    -- Defaults
    p_adc_en_d      <= p_adc_en_q;
    padc_conv_rdy_i <= '0';

    -- Reset enables on FSM request
    if (clr_all_enables='1') then
      p_adc_en_d      <= '0';

    elsif (set_enables_req_q='1') then
      -- Reset enable immediately in enable state 8, 6
      if (en_state="1000" or en_state="0110") then -- state 8,6
        p_adc_en_d <= '0';

      -- Set enable after delay from register
      elsif (tim_q >= ext(reg_del_padc_conv, tim_q'length)) then
        padc_conv_rdy_i <= '1'; -- DC conv delay ready
        p_adc_en_d      <= '1';
      end if;
    end if;
  end process tim_padc_conv_cmb_p;
----


  ----
  -- pradarinbd conv delay -> y_valid (combinational)
  tim_pradarinbd_conv_cmb_p:
  process(clr_all_enables, reg_del_pradarinbd, set_enables_req_q, tim_q,
          y_valid_q)
  begin
    -- Defaults
    y_valid_d        <= y_valid_q;
    pradarinbd_rdy_i <= '0';

    -- Reset enables on FSM request
    if (clr_all_enables='1') then
      y_valid_d <= '0';

    elsif (set_enables_req_q='1') then
      -- Set enable after delay from register
      if (tim_q >= reg_del_pradarinbd) then
        pradarinbd_rdy_i <= '1'; -- Set Ready
        y_valid_d        <= '1'; -- y_valid
      end if;
    end if;
  end process tim_pradarinbd_conv_cmb_p;
----

  -----
  -- Enables that are set immediately
  ----
  -- dc_en (combinational)
  dc_en_d <= '0' when clr_all_enables='1' else
             '1' when set_enables_req='1' else
             dc_en_q;

  ----
  -- plat_en (combinational)
  tim_plat_en_cmb_p:
  process(clr_all_enables, en_state, plat_en_q, set_enables_req_q)
  begin
    -- Defaults
    plat_en_d <= plat_en_q;

    -- Reset enables on FSM request
    if (clr_all_enables='1') then
      plat_en_d <= '0';

    elsif (set_enables_req_q='1') then
      -- Set enable immediately in enable state 2
      if (en_state="0010") then -- state 2
        plat_en_d <= '1';

      -- Clear enable immediately
      else 
        plat_en_d <= '0';
      end if;
    end if;
  end process tim_plat_en_cmb_p;


----

  ----
  -- Set enables request (combinational)
  set_enable_rdy_cmb_p:
  process(clr_all_enables, dc_conv_rdy_i, fea_conv_rdy_i, fea_on_rdy_i,
          feb_conv_rdy_i, feb_on_rdy_i, padc_conv_rdy_i, pinbd_conv_rdy_i,
          pradarinbd_rdy_i, set_enables_req, set_enables_req_q, reg_modeabg)
  begin
    if (clr_all_enables='1') then
       set_enables_req_d <= '0'; 
    elsif (set_enables_req='1') then -- Request from main FSM
       set_enables_req_d <= '1'; 
    elsif (dc_conv_rdy_i='1' and 
           fea_on_rdy_i='1' and fea_conv_rdy_i='1' and
         ((reg_modeabg=MODE_11A_CT) or
          (feb_on_rdy_i='1' and feb_conv_rdy_i='1')) and
           pinbd_conv_rdy_i='1' and
           padc_conv_rdy_i='1' and pradarinbd_rdy_i='1') then
      set_enables_req_d <= '0';
    else
      -- Keep until all enables are set (all ready at Hi)
      set_enables_req_d <= set_enables_req_q;
    end if;
  end process set_enable_rdy_cmb_p;
----

  ----
  -- Output assignemt
  dc_en           <=  dc_en_q;
  adc_pow_en      <=  adc_pow_en_q;
  fea_en          <=  fea_en_q;
  inbd_pow_en     <=  inbd_pow_en_q;
  ca_en           <=  ca_en_q;

  feb_en          <=  feb_en_q;
  cb_en           <=  cb_en_q when fcs_ok_re='0' else
                      (others => '0');
  det_en          <=  det_en_q;
  p_sat_en        <=  adc_pow_en_q; -- Exactly same behavior for both signals
  p_adc_en        <=  p_adc_en_q;
  p_inbd_en       <=  p_inbd_en_q;
  plat_en         <=  plat_en_q;
  y_valid         <=  y_valid_q;

end rtl;
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

