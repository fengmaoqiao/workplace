
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

 --------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: ana_int_ctrl.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Analog interface controller
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/radioctrl/vhdl/rtl/ana_int_ctrl.vhd,v  
--  Log: ana_int_ctrl.vhd,v  
-- Revision 1.4  2003/11/27 10:25:30  Dr.B
-- no accend when rf_mode = 0.
--
-- Revision 1.3  2003/11/21 17:59:24  Dr.B
-- nothing should happen when hiss selected.
--
-- Revision 1.2  2003/09/23 13:11:03  Dr.C
-- Changed interface with req handler
--
-- Revision 1.1  2003/07/15 08:40:51  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity ana_int_ctrl is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n : in std_logic;
    clk     : in std_logic;
    clk_n   : in std_logic;
    
    --------------------------------------
    -- Registers
    --------------------------------------
    rfmode     : in  std_logic;
    edgemode   : in  std_logic;         -- Single or dual edge mode
    
    --------------------------------------
    -- Request handler
    --------------------------------------
    startacc     : in  std_logic;       -- Start access on 3w bus
    rf_addr      : in  std_logic_vector(5 downto 0);  -- Reg. address
    rf_wrdata    : in  std_logic_vector(15 downto 0);  -- Write data
    writeacc     : in  std_logic;       -- Access type
    read_timeout : in  std_logic;       -- Time out on read access
    accend       : out std_logic;       -- Access finished
    ana_rddata   : out std_logic_vector(15 downto 0);  -- Read data

    --------------------------------------
    -- 3w interface
    --------------------------------------
    rf_3wdatain  : in std_logic;
    rf_3wenablein: in std_logic;
    
    rf_3wclk       : out std_logic;
    rf_3wdataout   : out std_logic;
    rf_3wdataen    : out std_logic;
    rf_3wenableout : out std_logic;
    rf_3wenableen  : out std_logic;

    --------------------------------------
    -- Diag port
    --------------------------------------
    diag_port : out std_logic_vector(1 downto 0)

    );

end ana_int_ctrl;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of ana_int_ctrl is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type ANA_INT_STATE_TYPE is (idle_state,       -- Idle state
                             write_state,      -- Register write
                             read_addr_state,  -- Register read: address phase
                             read_data_state); -- Register read: data phase
  ------------------------------------------------------------------------------
  -- Constant
  ------------------------------------------------------------------------------
  -- Address of "quick" access registers
  constant RFRXGAIN_ADDR_CT : std_logic_vector(5 downto 0) := "000000";
  constant RFRSSI_ADDR_CT   : std_logic_vector(5 downto 0) := "000001";
  constant RFCHAN_ADDR_CT   : std_logic_vector(5 downto 0) := "000010";
  constant RFTXGAIN_ADDR_CT : std_logic_vector(5 downto 0) := "000011";
  constant RFCNTL_ADDR_CT   : std_logic_vector(5 downto 0) := "000110";

  constant NULL_CT : std_logic_vector(19 downto 0) := (others => '0');
  
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal ana_int_state      : ANA_INT_STATE_TYPE;  -- ana interface state
  signal ana_int_next_state : ANA_INT_STATE_TYPE;  -- ana interface state
  signal accend_o           : std_logic;
  signal trans_counter      : std_logic_vector(4 downto 0);  -- Counts up the bits to transmit
  signal rf_3wclk_dual      : std_logic;           -- Dual edge clock
  signal rf_3wclk_single_en : std_logic;           -- Single edge clock enable
  signal rf_3wclk_dual_en   : std_logic;           -- Dual edge clock enable
  signal rddata             : std_logic_vector(15 downto 0);  -- Read data
  signal rf_3wenablein_ff1  : std_logic;           -- 3wenable one cc delayed
  signal bitsnb     : std_logic_vector(4 downto 0);
  signal trans_data : std_logic_vector(21 downto 0);  -- Data to transmit
 
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- State machine
  -----------------------------------------------------------------------------
  ana_int_next_state_p: process (accend_o, ana_int_state, read_timeout,
                                 rf_3wenablein, rf_3wenablein_ff1, startacc,
                                 writeacc)
  begin
    case ana_int_state is
      ---------------------------------------
      -- Idle state
      ---------------------------------------
      when idle_state =>
        if startacc = '1'  then
          if writeacc = '1' then
            ana_int_next_state <= write_state;
          else
            ana_int_next_state <= read_addr_state;
          end if;
        else
          ana_int_next_state <= idle_state;
        end if;
        
      ---------------------------------------
      -- Write state
      ---------------------------------------
      when write_state =>
        if accend_o = '1' then
          ana_int_next_state <= idle_state;
        else
          ana_int_next_state <= write_state;         
        end if;
        
      ---------------------------------------
      -- Read access, address phase
      ---------------------------------------
     when read_addr_state =>
        if rf_3wenablein = '1' and rf_3wenablein_ff1 = '0' then
          ana_int_next_state <= read_data_state;
        else
          ana_int_next_state <= read_addr_state;             
        end if;
        
      ---------------------------------------
      -- Read access, data phase
      ---------------------------------------
       when read_data_state =>
       if accend_o = '1' or read_timeout = '1' then
          ana_int_next_state <= idle_state;
        else
          ana_int_next_state <= read_data_state;         
        end if;
          
      when others => null;
    end case;
    
  end process ana_int_next_state_p;

  ana_int_state_p: process (clk, reset_n)
  begin  
    if reset_n = '0' then          
      ana_int_state <= idle_state;
    elsif clk'event and clk = '1' then
      if rfmode = '0' then
        ana_int_state <= idle_state;
      else
        ana_int_state <= ana_int_next_state;
      end if;
    end if;
  end process ana_int_state_p;


  -----------------------------------------------------------------------------
  -- Data and control
  -----------------------------------------------------------------------------

  -- Computes data to be shifted out according to register address
  transmit_data_p: process (rf_addr, rf_wrdata, writeacc)
  begin
    if writeacc = '0' then
      -- 2 cases in read accesses
      if rf_addr = RFRSSI_ADDR_CT then
        trans_data <= "01"& NULL_CT(19 downto 0);
        bitsnb     <= conv_std_logic_vector(1,5);
      else
        trans_data <= rf_addr & "0111" & NULL_CT(11 downto 0);
        bitsnb     <= conv_std_logic_vector(9,5); 
      end if;
    else
      case rf_addr is
        when RFRXGAIN_ADDR_CT =>
          trans_data <= rf_wrdata(7 downto 0) & "00" &  NULL_CT(11 downto 0);
          bitsnb     <= conv_std_logic_vector(9,5);
        when RFCHAN_ADDR_CT | RFTXGAIN_ADDR_CT | RFCNTL_ADDR_CT =>
          trans_data <= rf_wrdata & rf_addr(3 downto 0) & "00";
          bitsnb     <= conv_std_logic_vector(19,5);
        when others =>
          trans_data <= rf_wrdata & rf_addr;
          bitsnb     <= conv_std_logic_vector(21,5);        
      end case;
    end if;
  end process transmit_data_p;
  



  -- Data is shifted out on the clk rising edge
  trans_data_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then          
      rf_3wdataout <= '0';
      rf_3wdataen  <= '0';
    elsif clk'event and clk = '1' then
      if startacc = '1' and rfmode = '1' then
        rf_3wdataout <= trans_data(21);
        rf_3wdataen  <= '1';
      elsif (ana_int_state = write_state or ana_int_state = read_addr_state)
            and trans_counter < bitsnb  then
        rf_3wdataout <= trans_data(21-conv_integer(trans_counter)-1);
      elsif  trans_counter = bitsnb then
        rf_3wdataen  <= '0';
      end if;
    end if;
  end process trans_data_p;

  -- Enable for access end
  rf_3w_enable_p: process (clk, reset_n)
  begin
    if reset_n = '0' then          
      rf_3wenableout <= '0';
      rf_3wenableen  <= '0';
      rf_3wenablein_ff1 <= '0';
    elsif clk'event and clk = '1' then
      rf_3wenablein_ff1 <= rf_3wenablein;
      
      if startacc = '1' and rfmode = '1' then
        -- To start an access 3wenable is driven low
        rf_3wenableen    <= '1';
        rf_3wenableout   <= '0';
      elsif accend_o = '1' or read_timeout = '1' then
        -- Bus is released at access end
        rf_3wenableout <= '0';
        rf_3wenableen  <= '0';        
      elsif ((ana_int_state = write_state or ana_int_state = read_addr_state) and
            trans_counter = bitsnb) or
             (ana_int_state = read_data_state and rf_3wenablein = '1' and
              rf_3wenablein_ff1 = '0')then
        -- End of address phase is indicated with 3wenable high
        rf_3wenableen   <= '1';
        rf_3wenableout  <= '1';    
      elsif rf_3wenablein = '1' and rfmode = '1' then
        -- In any other case, if 3wenable has been sampled high, the bus
        -- is released
        rf_3wenableen   <= '0';          
        rf_3wenableout  <= '0';              
      end if;
    end if;
  end process rf_3w_enable_p;


  -- Read data
  rddata_p: process (clk, reset_n)
  begin
    if reset_n = '0' then       
      rddata <= (others => '0');
    elsif clk'event and clk = '1' then 
      if ana_int_state = read_data_state and rf_3wenablein = '0' then
        rddata(0) <= rf_3wdatain;
        rddata(15 downto 1) <= rddata(14 downto 0);
      end if;
    end if;
  end process rddata_p;

  ana_rddata <= rddata;

  -- Indicates access end 
  accend_p: process (clk, reset_n)
  begin
    if reset_n = '0' then     
      accend_o <= '0';
    elsif clk'event and clk = '1' then 
      if read_timeout = '0' and
        ((trans_counter = bitsnb and ana_int_state = write_state)or
         (rf_3wenablein = '1' and rf_3wenablein_ff1 = '0'and
                                    ana_int_state = read_data_state)) then
        accend_o <= '1';
      else
        accend_o <= '0';
      end if;
    end if;
  end process accend_p;

  accend <= accend_o or (read_timeout and rfmode);
  
  
  -- Counter used to determine the number of bits to transmit
  trans_counter_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then    
      trans_counter <= (others => '0');
    elsif clk'event and clk = '1' then
      if rfmode = '1' and (startacc = '1'
        or trans_counter = bitsnb or read_timeout = '1')  then
        trans_counter <= (others => '0');
      elsif  ana_int_state = write_state or ana_int_state = read_addr_state then
        trans_counter <= trans_counter + '1';
      end if;
    end if;
  end process trans_counter_p;

  -----------------------------------------------------------------------------
  -- 3w clock
  -----------------------------------------------------------------------------

  -- Clock rising edge
  rf_3wclk_p: process (clk, reset_n)
  begin 
    if reset_n = '0' then
      rf_3wclk_dual_en <= '0';  
    elsif clk'event and clk = '1' then
      if edgemode = '1' then
        if startacc = '1' and rfmode = '1' then
          rf_3wclk_dual_en <= '1';
        elsif accend_o = '1' or read_timeout = '1' then
          rf_3wclk_dual_en <= '0';
        end if;
      end if;

    end if;      
  end process rf_3wclk_p;

    
  -- Clock falling edge
  -- The dual edge clock is generated on the clock falling edge
  rf_3wclk_n_p : process (clk_n, reset_n)
  begin
    if reset_n = '0' then
      rf_3wclk_dual      <= '0';
      rf_3wclk_single_en <= '0';
      
    elsif clk_n'event and clk_n = '1' then
      -- Dual edge clock
      if edgemode = '0' then
        rf_3wclk_dual <= '0';

        -- Clock enable 
        if startacc = '1' and rfmode = '1' then
          rf_3wclk_single_en <= '1';
        elsif accend_o = '1' or read_timeout = '1' then
          rf_3wclk_single_en <= '0';
        end if;
      else
        rf_3wclk_single_en <= '0';
        if read_timeout = '1' then
          rf_3wclk_dual <= '0';
        elsif ana_int_state /= idle_state then
          rf_3wclk_dual <= not rf_3wclk_dual;
        else
          rf_3wclk_dual <= '0';          
        end if;
      end if;      
    end if;
  end process rf_3wclk_n_p;
    
  rf_3wclk <= (rf_3wclk_dual and rf_3wclk_dual_en) or
              (clk and rf_3wclk_single_en);

  -----------------------------------------------------------------------------
  -- Diagnostic port
  -----------------------------------------------------------------------------
  with ana_int_state select
    diag_port <=
    "00" when idle_state,
    "01" when write_state,
    "10" when read_addr_state,
    "11" when read_data_state;
 
              
end RTL;
