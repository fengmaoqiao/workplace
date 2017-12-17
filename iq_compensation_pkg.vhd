

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

    
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: iq_compensation_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.6  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for iq_compensation.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/iq_compensation/vhdl/rtl/iq_compensation_pkg.vhd,v  
--  Log: iq_compensation_pkg.vhd,v  
-- Revision 1.6  2004/05/13 14:46:00  Dr.C
-- Added use_sync_reset_g generic.
--
-- Revision 1.5  2004/05/11 16:05:59  Dr.C
-- Updated path for eucl_divider.
--
-- Revision 1.4  2003/08/29 16:05:56  Dr.B
-- tx_rx_iq_comp added.
--
-- Revision 1.3  2003/04/30 09:02:49  Dr.A
-- Added data_valid.
--
-- Revision 1.2  2003/04/24 12:00:27  Dr.A
-- DC offset ports and generics removed.
--
-- Revision 1.1  2003/03/27 14:09:27  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package iq_compensation_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- Source: Good
----------------------
  component eucl_divider_top
  generic (
    nb_stage_g : integer := 2;  -- Pipeline stages in the divider (0 to 3).
    dsize_g    : integer := 7;  -- Number of bits for d_in.
    zsize_g    : integer := 12; -- Number of bits for z_in.
    -- q_out integer part is q_out(qsize_g-1 downto qsize_g-zsize_g)
    -- Warning! qsize_g must be >= zsize_g!!
    qsize_g    : integer := 12; -- Number of bits for q_out.
    -- The *_neg_g generics indicates if the corresponding input is positive
    -- (*_neg_g=0) or in 2's complement code (*_neg_g=1).
    -- Warning! The configuration z_neg_g = 0 and d_neg_g = 1 is not allowed!!
    d_neg_g    : integer := 0;  -- 1 if d is in 2's complement code.
    z_neg_g    : integer := 1   -- 1 if z is in 2's complement code.
    );
  port (
    reset_n    : in  std_logic; -- Asynchronous reset.
    clk        : in  std_logic; -- System clock.
    --
    z_in       : in  std_logic_vector(zsize_g-1 downto 0); -- Dividend.
    d_in       : in  std_logic_vector(dsize_g-1 downto 0); -- Divisor.
    --
    q_out      : out std_logic_vector(qsize_g-1 downto 0)  -- Quotient.
  );

  end component;


----------------------
-- File: iq_compensation.vhd
----------------------
  component iq_compensation
  generic ( 
    iq_i_width_g     : integer := 9; -- IQ inputs width.
    iq_o_width_g     : integer := 9; -- IQ outputs width.
    phase_width_g    : integer := 6; -- Phase parameter width.
    ampl_width_g     : integer := 9; -- Amplitude parameter width.
    toggle_in_g      : integer := 0; -- when 1 the data_valid_i toggles
    toggle_out_g     : integer := 0; -- when 1 the data_valid_o toggles
    --
--    use_sync_reset_g : integer := 1  -- when 1 sync_reset_n input is used
    use_sync_reset_g : integer := 1  -- when 1 sync_reset_n input is used
  );                                 -- else the reset_n input must be separately
  port (                             -- controlled by the reset controller
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic; -- Module clock. 60 MHz
    reset_n      : in  std_logic; -- Asynchronous reset.
    sync_reset_n : in  std_logic; -- Block enable.
    --------------------------------------
    -- Controls
    --------------------------------------
    -- Phase compensation control.
    phase_i      : in  std_logic_vector(phase_width_g-1 downto 0);
    -- Amplitude compensation control.
    ampl_i       : in  std_logic_vector(ampl_width_g-1 downto 0);
    data_valid_i : in  std_logic; -- high when a new data is available
    --
    data_valid_o : out std_logic; -- high/toggle when a new data is available
    --------------------------------------
    -- Data
    --------------------------------------
    i_in         : in  std_logic_vector(iq_i_width_g-1 downto 0);
    q_in         : in  std_logic_vector(iq_i_width_g-1 downto 0);
    --
    i_out        : out std_logic_vector(iq_o_width_g-1 downto 0);
    q_out        : out std_logic_vector(iq_o_width_g-1 downto 0)
    
  );

  end component;


----------------------
-- File: tx_rx_iq_comp.vhd
----------------------
  component tx_rx_iq_comp
  generic ( 
    iq_i_width_g   : integer := 9; -- IQ inputs width.
    iq_o_width_g   : integer := 9; -- IQ outputs width.
    phase_width_g  : integer := 6; -- Phase parameter width.
    ampl_width_g   : integer := 9; -- Amplitude parameter width.
    toggle_in_g    : integer := 0; -- when 1 the data_valid_i toggles
    toggle_out_g   : integer := 0  -- when 1 the data_valid_o toggles
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk             : in  std_logic;    -- Module clock. 60 MHz
    reset_n         : in  std_logic;    -- Asynchronous reset.
    sync_reset_n    : in  std_logic;    -- Block enable.
    --------------------------------------
    -- Controls
    --------------------------------------
    tx_rxn_select   : in  std_logic;    -- '1' tx selected, '0' rx selected
    --------------------------------------
    -- Rx Controls
    --------------------------------------
    -- Phase compensation control.
    rx_phase_i      : in  std_logic_vector(phase_width_g-1 downto 0);
    -- Amplitude compensation control.
    rx_ampl_i       : in  std_logic_vector(ampl_width_g-1 downto 0);
    rx_data_valid_i : in  std_logic;    -- high when a new data is available
    --
    rx_data_valid_o : out std_logic;  -- high/toggle when a new data is available
    --------------------------------------
    -- Rx Data
    --------------------------------------
    rx_i_in         : in  std_logic_vector(iq_i_width_g-1 downto 0);
    rx_q_in         : in  std_logic_vector(iq_i_width_g-1 downto 0);
    --
    rx_i_out        : out std_logic_vector(iq_o_width_g-1 downto 0);
    rx_q_out        : out std_logic_vector(iq_o_width_g-1 downto 0);
    --------------------------------------
    -- Tx Controls
    --------------------------------------
    -- Phase compensation control.
    tx_phase_i      : in  std_logic_vector(phase_width_g-1 downto 0);
    -- Amplitude compensation control.
    tx_ampl_i       : in  std_logic_vector(ampl_width_g-1 downto 0);
    --------------------------------------
    -- Tx Data
    --------------------------------------
    tx_i_in         : in  std_logic_vector(iq_i_width_g-4 downto 0);
    tx_q_in         : in  std_logic_vector(iq_i_width_g-4 downto 0);
    --
    tx_i_out        : out std_logic_vector(iq_o_width_g-4 downto 0);
    tx_q_out        : out std_logic_vector(iq_o_width_g-4 downto 0)

    
  );

  end component;



 
end iq_compensation_pkg;
