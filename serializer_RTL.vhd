
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: serializer.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.8   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Wild Modem Serializer  1 byte => 2 bits serialized
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/serializer/vhdl/rtl/serializer.vhd,v  
--  Log: serializer.vhd,v  
-- Revision 1.8  2005/01/12 14:40:35  arisse
-- #BugId:596#
-- Txv_immstop was not into the sensitivity list of
-- seria_next_state_p process.
--
-- Revision 1.7  2004/12/20 16:13:07  arisse
-- #BugId:596#
-- Integrated txv_immstop for BT Co-existence.
-- Removed last version correction which was wrong.
--
-- Revision 1.6  2004/12/14 16:48:29  arisse
-- #BugId:908#
-- When seria_cur_state = shift_op we were waitting for
-- (trans_count = 000 and shift_per_count = 0000
-- and shift_pulse = 1) to considere seria_activate signal. This is corrected.
--
-- Revision 1.5  2002/04/30 12:17:05  Dr.B
-- enable => activate. phy_data_req/conf => (switched signals).
--
-- Revision 1.4  2002/03/06 13:57:43  Dr.B
-- add constants.
--
-- Revision 1.3  2002/02/26 15:50:30  Dr.B
-- psk_mod bug corrected.
--
-- Revision 1.2  2002/01/29 16:19:40  Dr.B
-- state_machines + signals for other blocks added.
--
-- Revision 1.1  2001/12/20 09:29:57  Dr.B
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
entity serializer is
  port (
    -- clock and reset
    clk             : in  std_logic;                    
    resetn          : in  std_logic;                   
     
    -- inputs
    seria_in       : in  std_logic_vector ( 7 downto 0);
    --               byte from the buffer 
    phy_data_req   : in  std_logic;
    --               the BuP send a Tx octet to the Modem (on switched signal)
    psk_mode       : in  std_logic;
    --               BPSK = 0 - QPSK = 1
    seria_activate : in  std_logic;
    --               activate the seria. when disabled the serializer finishes
    --               its last byte.
    shift_period   : in  std_logic_vector (3 downto 0);
    --               nb of (per-1) between 2 shifts(if clk=11MHz,1MHz is 10)
    shift_pulse    : in  std_logic;
    --               reduce shift ferquency.
    txv_prtype     : in  std_logic; 
    --               def the type of preamble (short or long)
    txv_immstop    : in std_logic;
    --               for BT co-existence, stop tx immediately if high.

    -- outputs
    seria_out      : out std_logic_vector (1 downto 0); 
    --               2-bits outputs 
    phy_data_conf  : out std_logic;
    --               The modem ind. that the Tx path has read the new octet.
    --               A new one should be presented as soon as possible.
    scramb_reg     : out std_logic;
    --               Indicate to the scrambler that it can register the
    --               last data. (pulse)
    shift_mapping  : out std_logic;
    --               ask of performing a new mapping op. (every dibits sent)
    map_first_val  : out std_logic;
    --               indicate the the mapping that the first data arrives.
    fol_bl_activate: out std_logic;
    --               manage the acti. of the following blocks to finish byte.
    cck_disact     : out std_logic
    --               keep high during bytes transfer.
    --               when high, the cck block does not see phy_data_req     
  
  );

end serializer;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of serializer is


  ------------------------------------------------------------------------------
  -- Type
  ------------------------------------------------------------------------------
  type SERIA_STATE is  ( idle,          -- idle phase
                         wait_req,      -- wait for a phy_data_req
                         memo,          -- memorization data for byte transfer
                         shift_op       -- shift operations
                         );    
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant TRANS_VAL_BPSK_CT : std_logic_vector(2 downto 0):= "111";
  -- in bpsk there are 8 shifts to perform
  constant TRANS_VAL_QPSK_CT : std_logic_vector(2 downto 0):= "011";
  -- in qpsk there are 4 shifts to perform

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal seria_int          : std_logic_vector (7 downto 0);
  --                          register of the serializer
  signal phy_data_conf_int  : std_logic;
  --                          internal signal of phy-data_conf
  signal trans_count        : std_logic_vector (2 downto 0);
  --                          count the number of shift operation to execute
  signal trans_c_init_val   : std_logic_vector (2 downto 0);
  --                          nb of shift op to perform 
  --                          BPSK => "111" (8) - QPSK => "11"(4)
  signal shift_per_count    : std_logic_vector (3 downto 0);
  --                          counter that reduces shift frequency
  signal shift_period_reg   : std_logic_vector (3 downto 0);
  --                          registered shift_period
  signal psk_mode_reg       : std_logic;
  --                          registered psk_mode
  signal memo_phy_data_req  : std_logic;
  --                          memorize the state of phy_data_req
  signal seria_cur_state    : SERIA_STATE;
  signal seria_next_state   : SERIA_STATE;

  signal counters_zero      : std_logic;
  --                          high when the counter are low. used for shift_map


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------

begin
  ------------------------------------------------------------------------------
  -- State Machine
  ------------------------------------------------------------------------------
  seria_next_state_p : process (memo_phy_data_req, phy_data_req,
                                seria_activate, seria_cur_state,
                                shift_per_count, shift_pulse, trans_count, 
                                txv_immstop)
  begin
    case seria_cur_state is

      -- idle State: the seria is disabled
      when idle => 
        if seria_activate = '1' and txv_immstop = '0' then
          seria_next_state  <= wait_req;   
        else
          seria_next_state  <= idle;
        end if;

      -- wait_req State: wait for phy_data_req
      when wait_req =>        
        if seria_activate = '0'  or txv_immstop = '1' then
          seria_next_state  <= idle;   
        elsif phy_data_req /= memo_phy_data_req  then
          seria_next_state  <= memo;   
        else
          seria_next_state  <= wait_req;
        end if;

      -- memo State: memorization of the 8bit data + info
      when memo =>
        if txv_immstop = '1' then
          seria_next_state <= idle;
        else
          seria_next_state  <= shift_op;
          -- if the block is disabled, it finishes the last byte. 
        end if; 
 
      -- shift_op State: perform the shift op
      when shift_op =>
        if txv_immstop = '1' then
          seria_next_state <= idle;
        elsif trans_count = "000" and shift_per_count = "0000" 
                                  and shift_pulse = '1' then
          if seria_activate = '1' then
            if memo_phy_data_req /= phy_data_req then  --new transfer ask 
              seria_next_state  <= memo;   
            else
              seria_next_state  <= wait_req;
            end if;
          else
            seria_next_state   <= idle; -- seria disabled - no other transfer
          end if;
        else
          seria_next_state  <= shift_op;
          -- if the block is disabled, it finishes the last byte.  
        end if;

      when others =>
        seria_next_state   <= idle;
    end case;
  end process seria_next_state_p;
  ------------------------------------------------------------------------------
  state_p : process (clk, resetn)
  begin
    if (resetn = '0') then
      seria_cur_state <= idle;
    elsif clk'event and clk = '1' then
      seria_cur_state <= seria_next_state;
    end if;
  end process state_p;

  ------------------------------------------------------------------------------
  -- Serialization process
  ------------------------------------------------------------------------------
  seria_proc : process (clk, resetn)
  begin
    if resetn = '0' then
      seria_int         <= (others => '0');  -- reset registers
      phy_data_conf_int <= '0';
      memo_phy_data_req <= '0';
      scramb_reg        <= '0';
      map_first_val     <= '0';
      fol_bl_activate   <= '0';
      cck_disact        <= '0';

      
    elsif (clk'event and clk = '1') then
      scramb_reg      <= '0';
      map_first_val   <= '0';
      fol_bl_activate <= '1';

      case seria_next_state is

        when idle =>
          -- following blocks are activated when the serializer works 
          --   (+1 per to finish sending data) 
          fol_bl_activate   <= '0';
          phy_data_conf_int <= '0';
          cck_disact        <= '0';

        when wait_req =>
          cck_disact    <= '1';
          map_first_val <= '1';
          if seria_cur_state = idle then
            -- In case of short prble, 15(odd) bytes  before the first PSDU byte.
            -- which can be with a 0-> 1 phy_data_conf. => 1-> 0
            -- In case of short prbl, 24(even) bytes  before the first PSDU byte.
            -- which can be with a 0-> 1 phy_data_conf. => 0-> 1
            if txv_prtype = '1' then
              phy_data_conf_int <= '0';  -- start with 0 -> 1
              memo_phy_data_req <= '0';
            else
              phy_data_conf_int <= '1';  -- start with 1 -> 0
              memo_phy_data_req <= '1';
            end if;
          end if;
          
          
        when memo =>
          phy_data_conf_int <= not phy_data_conf_int;
          scramb_reg        <= '1';
          seria_int         <= seria_in;  -- store the new data
          memo_phy_data_req <= phy_data_req;

        when shift_op =>

          -- shift registers :
          if shift_per_count = "0000" and shift_pulse = '1' then
            -- ask of saved data before each new output data.

            if psk_mode_reg = '0' then  -- BPSK mode 1 bit / 1 bit
              seria_int (7)          <= '0';
              seria_int (6 downto 0) <= seria_int(7 downto 1);
            else                        -- QPSK mode 2bits/ 2bits
              seria_int (7 downto 6) <= "00";
              seria_int (5 downto 4) <= seria_int(7 downto 6);
              seria_int (3 downto 2) <= seria_int(5 downto 4);
              seria_int (1 downto 0) <= seria_int(3 downto 2);
            end if;
          end if;
          if trans_count = "000" and shift_per_count = "0000" 
            and seria_activate = '0' then
            -- cck can be re-enabled as the seria will finish.
            cck_disact <= '0';
            -- does not work when shift_pulse always one.
          end if;
        when others => null;
      end case;

    end if;
  end process;

  phy_data_conf <= phy_data_conf_int;
  ------------------------------------------------------------------------------
  -- Counters process
  ------------------------------------------------------------------------------
  -- shift_per_count : counter that reduces shift frequency
  -- trans_count   : count the number of shift operation to execute for 1 byte
  counters_proc:process (clk, resetn)
  begin
    if resetn ='0' then
      trans_count         <= (others => '0');
      shift_per_count     <= (others => '0');
      shift_period_reg    <= (others => '0');
      psk_mode_reg        <= '0';

    elsif (clk'event and clk = '1') then   
       
      if seria_next_state = memo then
        trans_count    <= trans_c_init_val;                            
        shift_per_count  <= shift_period;     
        shift_period_reg <= shift_period;
        -- memorize shift period duration during all the byte transfer
        psk_mode_reg     <= psk_mode;  
        -- memorize psk mode during all the byte transfer
      elsif seria_next_state = shift_op and shift_pulse = '1' then  
        shift_per_count <= shift_per_count - '1';
        if shift_per_count = "0000" then   
          trans_count <= trans_count - '1';
          shift_per_count <= shift_period_reg;
        end if;                                                              
      end if;
    end if;
  end process;

  trans_c_init_val <= TRANS_VAL_BPSK_CT when psk_mode = '0' 
             else TRANS_VAL_QPSK_CT;
  -- number of shift op to perform : BPSK => "111" (8) - QPSK => "11"(4)
    
  ------------------------------------------------------------------------------
  -- wiring....
  ------------------------------------------------------------------------------
  -- data output :
  seria_out(0) <= seria_int(0); 
  seria_out(1) <= seria_int(0) when psk_mode_reg='0' else seria_int(1);
  -- copy of the same data in BPSK mode, 2nd data in QPSK mode 

  -- ask of saved data before each new output data.
  shift_mapping <= '1' when shift_per_count = "0000" and shift_pulse = '1' and 
                      (seria_cur_state = shift_op or seria_cur_state = memo) 
    else '0';
  -- (also memo because of the case when shift_period = 0)
  -- shift_mapping is only used on synchronous processes.
end RTL;
