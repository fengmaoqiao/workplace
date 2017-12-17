
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: deintpun_datapath.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.3  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Deinterleaver & depuncturer datapath block.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/deintpun/vhdl/rtl/deintpun_datapath.vhd,v  
--  Log: deintpun_datapath.vhd,v  
-- Revision 1.3  2004/07/22 13:31:33  Dr.C
-- Added FFs on outputs.
--
-- Revision 1.2  2003/03/28 15:33:41  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.1  2003/03/18 14:29:10  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--library deintpun_rtl;
library work;
--use deintpun_rtl.deintpun_pkg.all;
use work.deintpun_pkg.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity deintpun_datapath is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic;  -- Async Reset
    clk            : in  std_logic;  -- Clock

    --------------------------------------
    -- Interface Synchronization
    --------------------------------------
    enable_write_i : in  std_logic;  -- Enable signal for write phase
    enable_read_i  : in  std_logic;  -- Enable signal for read phase

    --------------------------------------
    -- Datapath interface
    --------------------------------------
    soft_x0_i      : in  std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_x1_i      : in  std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_x2_i      : in  std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y0_i      : in  std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y1_i      : in  std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y2_i      : in  std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
                                       -- Softbits from equalizer_softbit

    soft_x_o       : out std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y_o       : out std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
                                       -- Softbits to Viterbi

    write_addr_i   : in  CARR_T;   

    read_carr_x_i  : in  CARR_T;
    read_carr_y_i  : in  CARR_T;
    read_soft_x_i  : in  SOFT_T;
    read_soft_y_i  : in  SOFT_T;
    read_punc_x_i  : in  PUNC_T;   -- give out dontcare on soft_x_o
    read_punc_y_i  : in  PUNC_T    -- give out dontcare on soft_y_o
  );

end deintpun_datapath;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of deintpun_datapath is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  subtype SOFT_BIT_T is std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
  type SUB_CARRIER_T is array ( 5 downto 0) of SOFT_BIT_T;
  type OFDM_SYMBOL_T is array (47 downto 0) of SUB_CARRIER_T;

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal ofdm_symbol       : OFDM_SYMBOL_T;

  signal input_carrier     : SUB_CARRIER_T;
  signal output_carrier_x  : SUB_CARRIER_T;
  signal output_carrier_y  : SUB_CARRIER_T;

  signal soft_x_cond_value : std_logic;
  signal soft_y_cond_value : std_logic;
  signal soft_x_cond       : std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
  signal soft_y_cond       : std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);

  signal soft_x            : std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
  signal soft_y            : std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  input_carrier(0) <= soft_x0_i;
  input_carrier(1) <= soft_x1_i;
  input_carrier(2) <= soft_x2_i;
  input_carrier(3) <= soft_y0_i;
  input_carrier(4) <= soft_y1_i;
  input_carrier(5) <= soft_y2_i;

  -----------------------------------------------------------------------------
  -- write_input_carrier has to be implemented with nested for if construct to
  -- enable correct clock gating
  -----------------------------------------------------------------------------

  --------------------------------------
  -- Write input carrier process
  --------------------------------------
  write_input_carrier_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
        ofdm_symbol <= (others => (others => (others => '0')));
    elsif clk'event and clk = '1' then  -- rising clock edge
      if enable_write_i = '1' then
        for i in 0 to 47 loop           -- for loop necessary for clock gating
          if i = write_addr_i then
            ofdm_symbol(i) <= input_carrier;
          end if;
        end loop;  -- i
      end if;
    end if;
  end process write_input_carrier_p;


  output_carrier_x  <= ofdm_symbol(read_carr_x_i);
  soft_x_cond_value <= '0' when read_punc_x_i = 1 or enable_read_i = '0'
                  else '1';
  soft_x_cond       <= (others => soft_x_cond_value);
  soft_x            <= output_carrier_x(read_soft_x_i) and soft_x_cond;


  output_carrier_y  <= ofdm_symbol(read_carr_y_i);
  soft_y_cond_value <= '0' when read_punc_y_i = 1 or enable_read_i = '0'
                  else '1';
  soft_y_cond       <= (others => soft_y_cond_value);
  soft_y            <= output_carrier_y(read_soft_y_i) and soft_y_cond;

  --------------------------------------
  -- Soft bits output sequential process
  --------------------------------------
  softbits_sequential_p : process (clk, reset_n)
  begin
    if reset_n = '0' then              -- asynchronous reset (active low)
      soft_x_o <= (others => '0');
      soft_y_o <= (others => '0');
    elsif clk = '1' and clk'event then -- rising clock edge
      soft_x_o <= soft_x;
      soft_y_o <= soft_y;
    end if;
  end process softbits_sequential_p;


end RTL;
