

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of tx_path_core is
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for scrambling8_8
  signal scr_activate        : std_logic;
  signal scr_out             : std_logic_vector (7 downto 0);
  signal scramb_reg          : std_logic;
  signal scramb_reg_ser      : std_logic;
  signal scramb_reg_cck      : std_logic;

  -- Signals for serializer
  signal seria_activate      : std_logic;
  signal seria_out           : std_logic_vector (1 downto 0);
  signal phy_data_conf_ser   : std_logic;
  signal shift_mapping_ser   : std_logic;
  signal fol_bl_activate_ser : std_logic;
  signal cck_disact          : std_logic;

  -- Signals for mapping
  signal map_activate        : std_logic;
  signal map_first_val       : std_logic;
  signal map_in              : std_logic_vector (1 downto 0);
  signal map_data            : std_logic_vector (1 downto 0);
  signal phi_map             : std_logic_vector (1 downto 0);
  signal shift_mapping       : std_logic;

  -- Signals for spreading
  signal spread_activate     : std_logic;
  signal spread_init         : std_logic;
  signal phi_out_spread      : std_logic_vector (1 downto 0);

  -- Signals for cck_form
  signal cck_form_activate   : std_logic;
  signal cck_form_out        : std_logic_vector (7 downto 0);
  signal phy_data_conf_cck   : std_logic;
  signal new_data            : std_logic;
  signal first_data          : std_logic;
  signal shift_mapping_cck   : std_logic;
  signal fol_bl_activate_cck : std_logic;

  -- Signals for cck_mod
  signal cck_mod_in          : std_logic_vector (7 downto 2);
  signal cck_mod_activate    : std_logic;
  signal phi_out_cck         : std_logic_vector (1 downto 0);
  signal cck_mod_new_data    : std_logic;
  signal first_cck_remod     : std_logic;
  signal remod_data_switch   : std_logic;
  
  -- others
  signal phy_data_conf_i     : std_logic;
  --                           phy_data_conf out. to be observable by scrambler
  signal phy_data_req_cck    : std_logic;
  --                           phy_data_req seen by cck 
  signal phi_out_en_cck      : std_logic;
  --                           output angle from cck path  
  signal phi_out_en_ser      : std_logic;
  --                           output angle from dsss path
  -- counter between 2 shifts.
  signal shift_count         : std_logic_vector (2 downto 0);
  signal shift_pulse         : std_logic;
  signal cck_mod_first_data  : std_logic;

  signal remod_data_req_sync : std_logic;
  signal remod_data_req_sync2: std_logic;

  -- signals for generating tx_activated
  signal fir_acti            : std_logic;
  signal fir_phi_out_tog     : std_logic;
  signal last_fir_activate   : std_logic;
  signal tx_activate_dly     : std_logic;
  signal activate_counter    : std_logic_vector(4 downto 0); 

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  --------------------------------------------
  -- enable blocks
  --------------------------------------------
  -- scrambler works in low and high data rate transmission
  scr_activate      <= '1' when (low_r_flow_activate='1' or cck_flow_activate='1')
                else '0';
  
  -- low data rate flow :
  seria_activate    <= '1' when low_r_flow_activate='1' 
                else '0';
  map_activate      <= '1' when (fol_bl_activate_ser='1' or fol_bl_activate_cck='1')
                else '0';

  -- activated when fol_bl_activate_ser is high or when the PBCC remodulation is
  -- enabled
  spread_activate   <= '1' when (fol_bl_activate_ser='1') or
                                ((remod_enable and not remod_type)='1')
                else '0';
  -- cck flow :
  cck_form_activate <= '1' when cck_flow_activate='1' 
                else '0';

  -- activated when fol_bl_activate_cck is high or when the cck remodulation is 
  -- enabled
  cck_mod_activate  <= '1' when fol_bl_activate_cck='1' or
                                ((remod_enable and remod_type)='1')
                else '0';
    

  ------------------------------------------------------------------------------
  -- Port map
  ------------------------------------------------------------------------------

  --------------------------------------------
  -- Scrambling
  --------------------------------------------
  scrambling8_8_1: scrambling8_8
  port map (
      clk                 => clk,
      resetn              => reset_n,
      scr_in              => bup_txdata,
      scr_activate        => scr_activate,
      scramb_reg          => scramb_reg,
      txv_prtype          => txv_prtype,
      scrambling_disb     => scrambling_disb,
      txv_immstop         => txv_immstop,
      scr_out             => scr_out
      );

  scramb_reg  <=scramb_reg_cck or scramb_reg_ser;

  --------------------------------------------
  -- Serializer
  --------------------------------------------
  serializer_1: serializer
  port map (
      clk                 => clk,
      resetn              => reset_n,
      seria_in            => scr_out,
      phy_data_req        => phy_data_req,
      psk_mode            => psk_mode,
      seria_activate      => seria_activate,
      shift_period        => shift_period,
      shift_pulse         => shift_pulse,
      txv_prtype          => txv_prtype,
      txv_immstop         => txv_immstop,
      seria_out           => seria_out,
      phy_data_conf       => phy_data_conf_ser,
      scramb_reg          => scramb_reg_ser, 
      shift_mapping       => shift_mapping_ser,
      map_first_val       => map_first_val,
      fol_bl_activate     => fol_bl_activate_ser,
      cck_disact          => cck_disact
      );
  -- serializer input is scrambler output.    
      
  --------------------------------------------
  -- Mapping
  --------------------------------------------
  mapping_1: mapping
  port map (
      clk                 => clk,
      resetn              => reset_n,
      map_activate        => map_activate,
      map_first_val       => map_first_val,
      map_in              => map_in,
      shift_mapping       => shift_mapping,
      phi_map             => map_data
      );
       
  map_in <= seria_out when fol_bl_activate_ser='1'                -- from seria
       else cck_form_out(1 downto 0);                           -- from cck_mod
  
  shift_mapping <= shift_mapping_ser when fol_bl_activate_ser='1' -- from seria
            else shift_mapping_cck;                             -- from cck_mod

  --------------------------------------------
  -- Spreading
  --------------------------------------------
  spreading_1: spreading
  port map (
      clk                 => clk,
      resetn              => reset_n,
      spread_activate     => spread_activate,
      spread_init         => spread_init,
      phi_map             => phi_map,
      spread_disb         => spread_disb,
      shift_pulse         => shift_pulse,
      phi_out             => phi_out_spread
      );

  --------------------------------------------
  -- CCK Modulator
  --------------------------------------------
  cck_form_1: cck_form
  port map (
      clk                 => clk,
      resetn              => reset_n,
      cck_form_in         => scr_out,
      phy_data_req        => phy_data_req_cck,
      cck_speed           => cck_speed,
      cck_form_activate   => cck_form_activate,
      shift_pulse         => shift_pulse,
      txv_immstop         => txv_immstop,
      cck_form_out        => cck_form_out,
      phy_data_conf       => phy_data_conf_cck,
      scramb_reg          => scramb_reg_cck,
      shift_mapping       => shift_mapping_cck,
      first_data          => first_data,
      new_data            => new_data,
      fol_bl_activate     => fol_bl_activate_cck
      );
  -- cck_form input is scrambler output.

  cck_mod_1: cck_mod
  port map (
      clk                 => clk,
      resetn              => reset_n,
      cck_mod_in          => cck_mod_in,
      cck_mod_activate    => cck_mod_activate,
      first_data          => cck_mod_first_data,
      new_data            => cck_mod_new_data,
      phi_map             => phi_map,
      shift_pulse         => shift_pulse,
      phi_out             => phi_out_cck
      );


  ------------------------------------------
  -- Multiplexors used for the remodulation
  -- of the data from the RX path.
  ------------------------------------------
  cck_mod_first_data <= first_data when remod_enable='0' else '1';

  cck_mod_new_data <= new_data when remod_enable='0' else remod_data_req_sync2;
  
  -- cck_mod receive the 5 higher bits from cck_form.
  -- the 2 low bits are already transformed by mapping.     
  cck_mod_in <= cck_form_out(7 downto 2) when remod_enable='0' else
                demod_data(7 downto 2);

  phi_map <= map_data  when remod_enable='0' else
             demod_data(1 downto 0);
             
  remod_data <= phi_out_spread when remod_data_switch='0' else 
                phi_out_cck;
                
  
  -- This process delays the signal remod_data to switch the output of DSSS and CCK
  -- modulator (delay due the modulation).
  remod_data_switch_p : process (reset_n, clk)
  variable remod_type_ff1 : std_logic;
  variable remod_type_ff2 : std_logic;
  begin
    if reset_n='0' then
      remod_type_ff1 := '0';
      remod_type_ff2 := '0';
      remod_data_switch <= '0';
    elsif clk'event and clk='1' then
      remod_data_switch <= remod_type_ff2;
      remod_type_ff2 := remod_type_ff1;
      remod_type_ff1 := remod_type;
    end if;
  end process remod_data_switch_p;  

  
  spread_init <= map_first_val when remod_enable='0' else
                 remod_data_req_sync;

  
  remod_type_p : process (reset_n, clk)
  begin
    if reset_n='0' then
      remod_data_req_sync <= '0';
      remod_data_req_sync2 <= '0';
    elsif clk'event and clk='1' then
      remod_data_req_sync  <= remod_data_req;
      remod_data_req_sync2 <= remod_data_req_sync;
    end if;  
  end process remod_type_p;  

  --------------------------------------------
  -- FIR Filter controls
  --------------------------------------------
  -- fir_activate occurs 1 period later to have time to finish and to not start
  -- before the 1st data of spreading. (-1 are sent to the fir at the beg.)
  -- Initialization of the fir is also 1 period after init of the other blocks.
  fir_activate_p: process (clk, reset_n)
  begin  -- process fir_activate_p
    if reset_n = '0' then                
      fir_acti <= '0';
      init_fir <= '0';
    elsif clk'event and clk = '1' then 
      fir_acti <= fol_bl_activate_cck or fol_bl_activate_ser;
      init_fir <= map_first_val;
    end if;
  end process fir_activate_p;

  fir_activate <= fir_acti;
      
  --------------------------------------------
  -- common signals with the Bup 
  --------------------------------------------
  -- cck_form receives phy_data_req only when the low data
  -- rate flow has finished. ( but 1 period before the last phi) 
  phy_data_req_cck <= phy_data_req when 
         (cck_disact='0' and cck_flow_activate='1') else '0';
  
  phy_data_conf_i  <= phy_data_conf_cck or phy_data_conf_ser;
  phy_data_conf    <= phy_data_conf_i;

  
  --------------------------------------------
  -- Counter proc ( for reducing speed)
  --------------------------------------------
  shift_count_p : process (clk, reset_n)
  begin
    if reset_n = '0' then                -- reset reg.
      shift_count <= (others => '0');

    elsif (clk'event and clk = '1') then
      if low_r_flow_activate = '1' or cck_flow_activate = '1'
        or fol_bl_activate_ser = '1' or fol_bl_activate_cck = '1' 
        or remod_enable= '1' then
        shift_count <= shift_count + 1;
        if shift_count = (dec_freq_g -1)
          or map_first_val = '1' then
          shift_count <= (others => '0');
        end if;
      end if;
      if remod_data_req = '1'
        and remod_enable= '1' then
        shift_count <= "011";
      end if;
    end if;
  end process;

  shift_pulse <= '1' when shift_count = (dec_freq_g -1)
         and (low_r_flow_activate = '1' or cck_flow_activate = '1'
         or fol_bl_activate_ser = '1' or fol_bl_activate_cck = '1' or remod_enable= '1' ) else '0';

  --------------------------------------------
  -- outputs 
  --------------------------------------------
  -- delay fol_bl_activate to to take into account the end of valid data
  -- from spreading and cck.
  fol_bl_activate_p: process (clk,reset_n)
  begin
    if reset_n ='0' then
      phi_out_en_cck   <= '0';
      phi_out_en_ser   <= '0';
    elsif clk'event and clk='1' then
      if phy_data_conf_ser = '1' and fol_bl_activate_ser = '1' then
        -- first valid data next period
        phi_out_en_ser <= '1';
      elsif fol_bl_activate_ser = '0' then
        -- last valid data next period
        phi_out_en_ser <= '0';
      end if;
      
      if phy_data_conf_cck = '1' and fol_bl_activate_cck = '1' then
        -- first valid data next period
        phi_out_en_cck <= '1';
      elsif fol_bl_activate_cck = '0' then
        -- last valid data next period
        phi_out_en_cck <= '0';
      end if;
    end if;
  end process;
  
  fir_phi_out <= phi_out_spread when phi_out_en_ser = '1'
            else phi_out_cck    when phi_out_en_cck ='1'
            else "11";

  -----------------------------------------------------------------------------
  -- tx_activated determination
  -----------------------------------------------------------------------------
  -- The delay is performed inside the modem_sm_b

  tx_activated <= fir_acti;

  -----------------------------------------------------------------------------
  -- Generate a data_valid_toggle when new phi_out arrives
  -----------------------------------------------------------------------------
  phi_out_tog_p: process (clk, reset_n)
  begin  -- process phi_out_tog_p
    if reset_n = '0' then               
      fir_phi_out_tog <= '0';
    elsif clk'event and clk = '1' then  
      if fir_acti = '1' then
        if shift_count = "00" then
          fir_phi_out_tog <= not fir_phi_out_tog;
        end if;
      else
        fir_phi_out_tog <= '0'; -- reinit for next time
      end if;
      
    end if;
  end process phi_out_tog_p;

  fir_phi_out_tog_o <= fir_phi_out_tog;

  -----------------------------------------------------------------------------
  -- Globals declaration.
  -----------------------------------------------------------------------------

  -- ambit synthesis off
  -- synopsys translate_off
  -- synthesis translate_off 
--  scr_out_gbl <= scr_out;   
--  fir_phi_out_tog_o_gbl <= fir_phi_out_tog;
--  fir_phi_out_gbl <= phi_out_spread when phi_out_en_ser = '1'
--            else phi_out_cck    when phi_out_en_cck ='1'
--            else "11";             
--  clk_44_gbl <= clk;
--  scr_in_gbl <= bup_txdata;
--  scr_activate_gbl <= scr_activate;
--  scramb_reg_gbl <= scramb_reg;
  -- ambit synthesis on
  -- synopsys translate_on
  -- synthesis translate_on
end rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : FWT
--    ,' GoodLuck ,'      RCSfile: fwt_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for fwt.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/fwt/vhdl/rtl/fwt_pkg.vhd,v  
--  Log: fwt_pkg.vhd,v  
-- Revision 1.4  2004/04/30 15:05:07  arisse
-- Added input cck_demod_enable.
--
-- Revision 1.3  2002/05/30 14:46:08  elama
-- Generic size changed.
--
-- Revision 1.2  2002/03/14 17:25:46  elama
-- Reduced the number of data output ports and added the data_valid flag.
--
-- Revision 1.1  2002/01/30 16:19:27  elama
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--library CommonLib;
library work;
--    use CommonLib.slv_pkg.all;
use work.slv_pkg.all;


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package fwt_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: adder4.vhd
----------------------
  component adder4
generic (
  data_length : integer := 6            -- Number of bits for data I/O ports.
);
port (
  input0_real : in  std_logic_vector (data_length-1 downto 0);--Real part of in1
  input0_imag : in  std_logic_vector (data_length-1 downto 0);--Im part of in1.
  input1_real : in  std_logic_vector (data_length-1 downto 0);--Real part of in2
  input1_imag : in  std_logic_vector (data_length-1 downto 0);--Im part of in2.
  output0_real: out std_logic_vector (data_length-1 downto 0);--Re part of out1.
  output0_imag: out std_logic_vector (data_length-1 downto 0);--Im part of out1.
  output1_real: out std_logic_vector (data_length-1 downto 0);--Re part of out2.
  output1_imag: out std_logic_vector (data_length-1 downto 0);--Im part of out2.
  output2_real: out std_logic_vector (data_length-1 downto 0);--Re part of out3.
  output2_imag: out std_logic_vector (data_length-1 downto 0);--Im part of out3.
  output3_real: out std_logic_vector (data_length-1 downto 0);--Re part of out4.
  output3_imag: out std_logic_vector (data_length-1 downto 0) --Im part of out4.
);
  end component;


----------------------
-- File: fwt.vhd
----------------------
  component fwt
generic (
  data_length : integer := 6            -- Number of bits for data Input ports.
                                        -- 3 more bits for data output ports.
);
port (
  reset_n     : in  std_logic;          -- System reset. Active LOW.
  clk         : in  std_logic;          -- System clock.
  cck_demod_enable : in std_logic;
  start_fwt   : in  std_logic;          -- Start the fwt.
  end_fwt     : out std_logic;          -- Flag indicating fwt is finished.
  data_valid  : out std_logic;          -- Flag indicating output data valid.
--
  input0_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in0
  input0_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in0.
  input1_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in1
  input1_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in1.
  input2_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in2
  input2_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in2.
  input3_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in3
  input3_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in3.
  input4_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in4
  input4_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in4.
  input5_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in5
  input5_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in5.
  input6_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in6
  input6_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in6.
  input7_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in7
  input7_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in7.
--
  output0_re  : out std_logic_vector (data_length+2 downto 0);--R part of out0.
  output0_im  : out std_logic_vector (data_length+2 downto 0);--Im part of out0.
  output1_re  : out std_logic_vector (data_length+2 downto 0);--R part of out1.
  output1_im  : out std_logic_vector (data_length+2 downto 0);--Im part of out1.
  output2_re  : out std_logic_vector (data_length+2 downto 0);--R part of out2.
  output2_im  : out std_logic_vector (data_length+2 downto 0);--Im part of out2.
  output3_re  : out std_logic_vector (data_length+2 downto 0);--R part of out3.
  output3_im  : out std_logic_vector (data_length+2 downto 0) --Im part of out3.
);
  end component;



 
end fwt_pkg;
