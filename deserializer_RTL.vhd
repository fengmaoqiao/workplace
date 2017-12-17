
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: deserializer.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Deserializer Block . deserialize data from diff_decoder
--               and cck_demod acccording to the mode (DSSS 1/2 Mbs - 
--               CCK 5.5/11 Mbs) and send the phy_data_ind to the Bup.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/deserializer/vhdl/rtl/deserializer.vhd,v  
--  Log: deserializer.vhd,v  
-- Revision 1.2  2002/09/17 07:15:34  Dr.B
-- in 11 Mb/s, rec_mode checked directely.
--
-- Revision 1.1  2002/07/03 08:49:45  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all;
 
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity deserializer is
  port (
    -- clock and reset
    clk             : in  std_logic;                   
    reset_n         : in  std_logic;                  
     
    -- inputs
    d_from_diff_dec : in std_logic_vector (1 downto 0); 
    --               2-bits input from differential decoder (PSK)
    d_from_cck_dem  : in std_logic_vector (5 downto 0); 
    --               6-bits input from cck_demod (CCK)
    rec_mode        : in  std_logic_vector (1 downto 0);
    --               reception mode : BPSK QPSK CCK5.5 or CCK11
    symbol_sync     : in  std_logic;
    --               new chip available


    packet_sync    : in  std_logic;
    --               resynchronize (start a new byte)
    deseria_activate : in  std_logic;
    --               activate the deserializer. Beware to disable the deseria.
    --               when no transfer is performed to not get any 
    --               phy_data_ind pulse. 
    
    -- outputs
    deseria_out   : out std_logic_vector (7 downto 0);
    --              byte for the Bup
    byte_sync     : out std_logic;
    --              synchronisation for the descrambler (1 per bef phy_data_ind)
    --              as there should be glitches on transition of trans_count
    --              byte_sync must be used only to generate clocked signals !
    phy_data_ind  : out std_logic
    --              The modem indicates that a new byte is received.
  );

end deserializer;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of deserializer is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant TRANS_VAL_BPSK_CT  : std_logic_vector(2 downto 0):= "111";
  -- in bpsk there are 8 shifts to perform
  constant TRANS_VAL_QPSK_CT  : std_logic_vector(2 downto 0):= "011";
  -- in qpsk there are 4 shifts to perform
  constant TRANS_VAL_CCK55_CT  : std_logic_vector(2 downto 0):= "001";
  -- in cck 5.5there are 2 shifts to perform
  constant TRANS_VAL_CCK11_CT  : std_logic_vector(2 downto 0):= "000";
  -- in cck 11 there are 1 shifts to perform

  -- mode indication (for rec_mode)
  constant BPSK_MODE_CT       : std_logic_vector (1 downto 0) := "00";
  constant QPSK_MODE_CT       : std_logic_vector (1 downto 0) := "01";
  constant CCK55_MODE_CT      : std_logic_vector (1 downto 0) := "10";
  constant CCK11_MODE_CT      : std_logic_vector (1 downto 0) := "11";
  

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal deseria_reg        : std_logic_vector (6 downto 0);
  --                          deseria register
  signal rec_mode_reg       : std_logic_vector (1 downto 0);
  --                          rec_mode register
  signal trans_count        : std_logic_vector (2 downto 0);
  --                          count the number of shift operation to execute  
  signal trans_c_init_val   : std_logic_vector (2 downto 0);
  --                          nb of shift op to perform
  signal last_deseria_activate : std_logic;
  --                          used to know the first act of the block

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  ------------------------------------------------------------------------------
  -- Deserialization process
  ------------------------------------------------------------------------------
  deseria_proc:process (clk, reset_n)
  begin
    if reset_n ='0' then
      deseria_reg      <= (others => '0');     -- reset register
    
    elsif (clk'event and clk = '1') then
      if deseria_activate = '1' and symbol_sync = '1' then          
        -- shift op
        case rec_mode_reg is

          ---------------------------------------------------------------------
          -- BPSK Mode
          ---------------------------------------------------------------------
          when BPSK_MODE_CT  =>
            deseria_reg(6)          <= d_from_diff_dec(0);
            deseria_reg(5 downto 0) <= deseria_reg(6 downto 1);
            
          ---------------------------------------------------------------------
          -- QPSK Mode
          ---------------------------------------------------------------------
          when QPSK_MODE_CT  =>
            deseria_reg(5 downto 4) <=  d_from_diff_dec;
            deseria_reg(3 downto 2) <= deseria_reg(5 downto 4);
            deseria_reg(1 downto 0) <= deseria_reg(3 downto 2);

          ---------------------------------------------------------------------
          -- CCK55 Mode
          ---------------------------------------------------------------------   
          when CCK55_MODE_CT =>
            deseria_reg(3 downto 0) <= d_from_cck_dem(4) & d_from_cck_dem(0)
                                      & d_from_diff_dec;
          ---------------------------------------------------------------------
          -- CCK11 Mode
          ---------------------------------------------------------------------
          when others => null;
        end case;
      end if;
    end if;
  end process;
  
  ------------------------------------------------------------------------------
  -- Counter process
  ------------------------------------------------------------------------------
  counter_proc : process (clk, reset_n)
  begin
    if reset_n = '0' then
      trans_count           <= (others => '1');
      phy_data_ind          <= '0';
      last_deseria_activate <= '0';
      rec_mode_reg          <= (others => '0');

    elsif (clk'event and clk = '1') then
      phy_data_ind          <= '0';
      last_deseria_activate <= deseria_activate;

      if deseria_activate = '1' then
        if symbol_sync = '1' then
          trans_count <= trans_count - '1';

          if trans_count = "000" or packet_sync ='1'
            or (last_deseria_activate = '0' and deseria_activate = '1') then
            -- last byte finished - initialyze counter
            trans_count <= trans_c_init_val;
            rec_mode_reg <= rec_mode;
          elsif trans_count = "001" then
            -- last bit of the byte arrives - inform the Bup
            phy_data_ind <= '1';
          end if;

          -- in CCK 11 MHz, 1 byte per chip sync.
          if rec_mode = CCK11_MODE_CT then
            phy_data_ind <= '1';
          end if;
        end if;
      else
        trans_count   <= (others => '1');
        rec_mode_reg  <= (others => '0');
      end if;
    end if;
  end process;

  -- initial value of the counter (checked directely on rec_mode)
  with rec_mode select
    trans_c_init_val <=
    TRANS_VAL_BPSK_CT  when BPSK_MODE_CT,
    TRANS_VAL_QPSK_CT  when QPSK_MODE_CT,
    TRANS_VAL_CCK55_CT when CCK55_MODE_CT,
    TRANS_VAL_CCK11_CT when others;  -- CCK11_MODE_CT

  byte_sync <= '1' when symbol_sync = '1' and
               (trans_count = "000" or rec_mode_reg =CCK11_MODE_CT)
               else '0';
  -- as there should be glitches on transition of trans_count
  -- byte_sync must be used only to generate clocked signals !
               
 

  ------------------------------------------------------------------------------
  -- wiring....
  ------------------------------------------------------------------------------
  -- number of shift op to perform

  with rec_mode_reg select
    deseria_out <=
    d_from_diff_dec(0) & deseria_reg                when BPSK_MODE_CT,
    d_from_diff_dec & deseria_reg (5 downto 0)      when QPSK_MODE_CT,
    d_from_cck_dem(4) & d_from_cck_dem(0) & d_from_diff_dec
                      & deseria_reg(3 downto 0)     when CCK55_MODE_CT,
    d_from_cck_dem & d_from_diff_dec                when others;--CCK11_MODE_CT;

end RTL;
