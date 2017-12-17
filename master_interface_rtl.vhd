
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : AHB master interface
--    ,' GoodLuck ,'      RCSfile: master_interface.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.13   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Interface for an AHB bus master
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/PROC_SYSTEM/master_interface/vhdl/rtl/master_interface.vhd,v  
--  Log: master_interface.vhd,v  
-- Revision 1.13  2004/02/17 17:41:58  wdoyle
-- Fixed address state to hold htrans and haddr active when 2nd req on bus and hready is low.
--
-- Revision 1.12  2004/01/21 10:46:29  Dr.A
-- Added condition to release hbusreq (to avoid bus locked by BuP, this condition was already verified in the Stream Processor where all bursts are incremental).
--
-- Revision 1.11  2003/09/30 13:30:08  Dr.A
-- Release hbusreq after error state.
--
-- Revision 1.10  2002/11/27 17:27:45  Dr.B
-- set hbusreq to 0 when degranted and no busreq.
--
-- Revision 1.9  2002/11/15 13:44:40  Dr.B
-- set at least 1 time hbusreq even if already granted.
--
-- Revision 1.8  2002/04/03 08:42:30  Dr.C
-- Corrected condition to degranted state
--
-- Revision 1.7  2002/03/06 10:02:46  Dr.C
-- Changed to a generic one useful for all blocks
-- Added generic gotoaddr_g
--
-- Revision 1.6  2002/01/30 07:41:38  Dr.C
-- Debugged transition from address to last data
--
-- Revision 1.5  2001/12/03 14:01:23  Dr.C
-- Added busy state and debugged signals
--
-- Revision 1.4  2001/11/06 13:56:20  Dr.C
-- new library ahb_config_pkg
--
-- Revision 1.3  2001/07/27 12:25:49  Dr.B
-- degranted state after last_address state suppressed (error correction)
--
-- Revision 1.2  2001/07/24 09:09:58  Dr.B
-- pipeline mode added.
--
-- Revision 1.1  2001/07/19 12:49:41  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all;


--library ahb_config_pkg;
library work;
--use ahb_config_pkg.ahb_config_pkg.all;
use work.ahb_config_pkg.all;





--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity master_interface is
  generic 
      (
      gotoaddr_g         : integer := 0;
      burstlinkcapable_g : integer := 1
      ) ;

  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hclk            : in  std_logic;
    hreset_n        : in  std_logic;
    
    --------------------------------------
    -- Signal to/from logic part of master
    --------------------------------------
    --write           : in  std_logic;
    burst           : in  std_logic_vector(2 downto 0);
    busreq          : in  std_logic;
    unspeclength    : in  std_logic;
    busy            : in  std_logic;
    buserror        : out std_logic;     
    inc_addr        : out std_logic;    
    valid_data      : out std_logic;
    decr_addr       : out std_logic;    
    grant_lost      : out std_logic;
    end_add         : out std_logic;
    end_data        : out std_logic;
    free            : out std_logic;
   
    --------------------------------------
    -- AHB control signals
    --------------------------------------
    hready          : in  std_logic;
    hresp           : in  std_logic_vector(1 downto 0);
    hgrant          : in  std_logic;
    htrans          : out std_logic_vector(1 downto 0);
    hbusreq         : out std_logic

  );

end master_interface;


--------------------------------------------------------------------------------
--                             Port description
--
--    --------------------------------------------
--    -- Generic
--    --------------------------------------------
--    gotoaddr_g: gives the possiblity to choose the transition for incrementing
--                bursts between the data state and last data or last addr state
--
--    burstlinkcapable_g : indicates if the master is allowed or not
--                        or make consecutive accesses on bus
--                        0 means not capable
--
--
--    --------------------------------------------
--    -- Signal to/from logic part of master
--    --------------------------------------------
--
--    Signal name    Type    Description
--
--    burst          in      type of transfer
--    busreq         in      bus request
--    unspeclength   in      indicates the end of a burst with unspecified length
--    busy           in      indicates the master is unable to continue the transfer
--                           immediatly
--    buserror       out     signals an error on the bus
--    retry          out     signals a retry on the bus
--    inc_addr       out     the master can write the next address on the bus
--    valid_data     out     the data is valid on the bus 
--                              - the master can store it for a read transfer
--                              - the slave has stored it for a write transfer
--    decr_addr      out     in case of a retry response the next 
--                             address has already been sampled and the master 
--                             must decrement the address
--    grant_lost     out     the master lost bus ownership
--    free           out     no transfer is actually proceeded
--    end_add        out     indicates the last address of the transfer
--    end_data       out     indicates the last data of the transfer
--
--------------------------------------------------------------------------------







--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture rtl of master_interface is





  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant TRUE_CT  : integer := 1;

  ------------------------------------------------------------------------------
  -- Type
  ------------------------------------------------------------------------------
  type MASTER_STATE is ( idle,              -- idle phase
                         busrequest,        -- bus request phase
                         address,           -- address cycle
                         data,              -- data cycle
                         last_addr,         -- last address phase
                         last_data,         -- last data phase
                         degranted,         -- grant lost
                         error_state,       -- error sent by slave
                         retry_state ,      -- retry sent by slave
                         busy_state ,       -- master busy
                         last_data_new_add  -- when a new burst is asked finish 
                                            -- the last data and start the 
                                            -- new address
                         );    


  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal current_state : MASTER_STATE;
  signal next_state    : MASTER_STATE;
  signal end_of_burst  : std_logic;
  signal burstcounter  : std_logic_vector(3 downto 0);
  signal en_valid_data : std_logic;
  signal en_inc_addr   : std_logic;
  signal inc_addr_i    : std_logic;
  signal busy_int      : std_logic;
  signal busy_s        : std_logic;
  signal busy_old      : std_logic;
  signal retry         : std_logic;
  signal busy_ff1      : std_logic;
  signal en_decr_addr  : std_logic;
  signal en_grant_lost : std_logic;

--------------------------------------------------------------------------------
-- Architecture body
--------------------------------------------------------------------------------
 
begin
 
  
  
  ------------------------------------------------------------------------------
  -- Master state machine: the state machine defines the timing for the
  -- AHB access.
  -- The different states are: idle,busrequest, address,data,last_addr,
  -- last_data,degranted, error_state and retry
  ------------------------------------------------------------------------------
   
  
  next_state_p : process (current_state, busreq, hgrant, hready, end_of_burst,
                            unspeclength, burst, hresp, busy_s,busy_old,
                            busy_ff1)
  begin
    case current_state is
     
      -------------------------------------------
      -- Idle State: no transfer is asked. 
      -- The master is waiting for the next transfer
      -- signaled by busreq.
      -------------------------------------------
      when idle => 
        if busreq = '1' and hgrant = '1' and hready = '1' and busy_ff1 = '0'
        then
          -- go directly to address because the master 
          -- is already granting the bus
          next_state  <= address;   
        elsif  busreq = '1' and busy_old = '0' then
          next_state  <= busrequest;
        else
          next_state  <= idle;
        end if;

      -------------------------------------------
      -- Bus Request State: The m_i asks for a
      -- bus request until it gets the grant from
      -- the arbiter and hready ='1'.
      -------------------------------------------
      when busrequest =>
        if hgrant = '1' and hready = '1' then
          next_state  <= address;
        else
          next_state  <= busrequest;
        end if;

      -------------------------------------------
      -- Adress State : The First Address is sent
      -------------------------------------------
      when address =>
        if(hready = '0') then
          next_state  <= address;
        else
          if hgrant = '0' then
            -- go back to busreq. No need to warn the master as no data
            -- has been sent.
            next_state <= last_data;
          elsif (busreq = '1' and hgrant = '1' and burst = SINGLE_CT
                 and burstlinkcapable_g = TRUE_CT) then
            -- if an other SINGLE transfer is asked and the master is still granting the bus
            -- go directly in last_data_new_add without asking the bus request.
            next_state <= last_data_new_add;
          elsif (burst = SINGLE_CT) then
            -- after putting address, the last data (and the only one) must be put. 
            next_state <= last_data;
          elsif (end_of_burst = '1') then
            next_state <= last_addr;
          elsif (unspeclength = '1' and burst = INCR_CT) then
            -- single burst if unspeclength already high
            next_state <= last_data;
          elsif (busy_ff1 = '1' or busy_s = '1')  then
            next_state <= busy_state;
          else
            next_state <= data;
          end if;
        end if;

      -------------------------------------------
      -- Data State : Data and Address are exchanged
      -- one after the other before the last address is sent.
      -- Rque: This state is only reached in burst case.
      -------------------------------------------
      when data =>
        if hgrant = '0' and hready = '1' then
          -- the current masterstill owns the bus during one bus cycle
          -- after it losts the bus grant
          next_state <= degranted;
        elsif hresp = RETRY_CT then
          next_state <= retry_state;
        elsif hresp = ERROR_CT then
          next_state <= error_state;
        elsif busy_s = '1' and hready = '1' and unspeclength = '0' then
          next_state <= busy_state;
        elsif (end_of_burst = '1'  and hready =  '1' ) 
          or (unspeclength = '1' and hready ='1' and burst= INCR_CT and
              gotoaddr_g = 1) then
          next_state <= last_addr;
        elsif unspeclength = '1' and hready ='1' and burst= INCR_CT then
          next_state <= last_data;
        else
          next_state <= data;
        end if;
      
      -------------------------------------------
      -- Last Address State: The last address is put.
      -- The incrementation of adress stops. It is the time
      -- for checking if the master wish a new transfer
      -------------------------------------------
      when last_addr =>
        if hresp = RETRY_CT then
          next_state  <= retry_state;       
        elsif hresp = ERROR_CT then
          next_state  <= error_state;
        elsif (hready = '1' and busreq='1' and hgrant='1' and 
          burstlinkcapable_g = TRUE_CT)  then 
          -- if another burst is asked
          next_state  <= last_data_new_add;
        elsif hready='1' then
          next_state  <= last_data;
        else
          next_state  <= last_addr;
        end if;
 
      -------------------------------------------
      -- Last Data State: No new transfer has been asked. 
      -- The m_i cares about the last data transfer
      -- before going on idle state
      -------------------------------------------
      when last_data =>
        if hresp = RETRY_CT then
          next_state  <= retry_state;
        elsif hresp = ERROR_CT then
          next_state  <= error_state;
        elsif hready =  '1' then
          next_state  <= idle;
        else
          next_state  <= last_data;
        end if;

      -------------------------------------------
      -- Last Data New Address State: 
      -- The m_i cares about the last data transfer
      -- and prepare the next transfer by putting the 
      -- new address.
      -------------------------------------------
      when last_data_new_add =>
        if hresp = RETRY_CT then
          next_state  <= retry_state;
        elsif hresp = ERROR_CT then
          next_state  <= error_state;
        elsif (hready = '1' and busreq='1' and hgrant='1' and burst=SINGLE_CT) then
        -- if an other SINGLE transfer is asked and the master is still granting the bus
          next_state  <= last_data_new_add;
        elsif (hready = '1' and burst=SINGLE_CT) then
        -- if no other SINGLE transfer is asked
          next_state  <= last_data;
        elsif hready =  '1' then
          next_state  <= data;
        else
          next_state  <= last_data_new_add;
         end if;
 
      -------------------------------------------
      -- Degranted State: The arbiter has degranted 
      -- the master. The m_i has to wait for a new grant
      -- and warns the master.
      -------------------------------------------
      when degranted => 
        if hready='1' then 
          next_state   <= idle;
        else
          next_state   <= degranted;
        end if;
             
      -------------------------------------------
      -- Error State: The slave has generated a error state
      -- The m_i has to wait for a new grant
      -- and warns the master.
      -------------------------------------------
      when error_state =>        
        next_state   <= idle;
      
      -------------------------------------------
      -- Retry State: The slave has generated a retry state
      -------------------------------------------
      when retry_state =>
        next_state   <= idle;
      
      --------------------------------------------
      -- Busy state:
      -- The master can not provide the next data
      --------------------------------------------

      when busy_state =>
        if hresp = RETRY_CT then
          next_state  <= retry_state;
        elsif hresp = ERROR_CT then
          next_state  <= error_state;
        elsif hgrant = '0' and hready = '1' then
          next_state <= degranted;
        elsif busy_s = '0' and hready = '1' then
          next_state <= data;
        else
          next_state <= busy_state;
        end if;
        
      
      when others =>
        next_state   <= idle;
        
    end case;
  end process next_state_p;

  state_p : process (hreset_n, hclk)
  begin
    if (hreset_n = '0') then
      current_state <= idle;
    elsif hclk'event and hclk = '1' then
      current_state <= next_state;
    end if;
  end process state_p;
  
  
  ------------------------------------------------------------------------------
  -- Control signals generation for the AHB bus and the master
  ------------------------------------------------------------------------------
  
  control_p : process (hreset_n, hclk)
  begin
    if hreset_n = '0' then
       htrans        <= IDLE_CT;
       en_inc_addr   <= '0';
       en_valid_data <= '0';
       buserror      <= '0';
       en_grant_lost <= '0';
       en_decr_addr  <= '0';
       retry         <= '0';
       free          <= '1';

  
    elsif hclk'event and hclk = '1' then

      case next_state is

        -------------------------------------------
        -- Idle
        -------------------------------------------
        when idle =>
          htrans        <= IDLE_CT;
          en_inc_addr   <= '0';
          en_valid_data <= '0';
          buserror      <= '0';
          en_grant_lost <= '0';
          en_decr_addr  <= '0';
          free          <= '1';


        -------------------------------------------
        -- Bus request
        -------------------------------------------
        when busrequest =>
          htrans        <= IDLE_CT;
          en_decr_addr  <= '0';
          en_inc_addr   <= '0';
          en_valid_data <= '0';
          buserror      <= '0';
          en_grant_lost <= '0';
          free          <= '0';

          if (current_state = address or current_state =  last_data_new_add) then
            -- case of a degrant.
            en_decr_addr <='1';
          else
            en_decr_addr <='0';
          end if;



        -------------------------------------------
        -- Address phase
        -------------------------------------------                
        when address => 
          en_decr_addr <= '0';
          free         <= '0';
          en_inc_addr  <= '1';
          htrans       <= NONSEQ_CT;


        -------------------------------------------
        -- Data phase
        -------------------------------------------
        when data =>
          if current_state = busy_state then
            en_valid_data <= '0';
          elsif retry = '0' then
            en_valid_data <= '1';
          end if;
          retry        <= '0';
          en_inc_addr  <= '1';
          en_decr_addr <= '0';
          htrans       <= SEQ_CT;


        -------------------------------------------
        -- Last address on bus
        -------------------------------------------
          when last_addr =>
            htrans        <= SEQ_CT;
            en_inc_addr   <= '1';


        -------------------------------------------
        -- Last data on bus
        -------------------------------------------
          when last_data =>
            en_valid_data <= '1';
            retry         <= '0';
            en_inc_addr   <= '0';
            htrans        <= IDLE_CT;


        -------------------------------------------
        -- Master degranted
        -------------------------------------------
        when degranted =>         
          if current_state /= busy_state then
            en_valid_data <= '1';
          else
            -- in this case there is already no data on bus
            en_valid_data <= '0';
          end if;
          en_grant_lost <= '1';        
          en_inc_addr   <= '0';
          htrans        <= IDLE_CT;


        -------------------------------------------
        -- Error response
        -------------------------------------------
        when error_state =>
          if current_state /= address then
            en_decr_addr  <= '1';
          end if;          
          en_inc_addr   <= '0';
          en_valid_data <= '0';
          htrans        <= IDLE_CT;
          buserror      <= '1';


        -------------------------------------------
        -- Retry response
        -------------------------------------------
        when retry_state =>
          en_inc_addr   <= '0';
          en_valid_data <= '0';
          retry         <= '1';
          en_decr_addr  <= '1';
          htrans        <= IDLE_CT;


        -------------------------------------------
        -- Transition to a new burst
        -------------------------------------------
        when last_data_new_add =>
           if burst /= SINGLE_CT  and burst /= INCR_CT then
            en_inc_addr <= '1';
          end if; 
          en_valid_data <= '1';
          htrans        <= NONSEQ_CT;


        -------------------------------------------
        -- Master busy
        -------------------------------------------      
        when busy_state =>
          htrans        <= BUSY_CT;
          en_inc_addr   <= '0';

          if current_state /= next_state then
            -- first time in busy state
            en_valid_data <= '1';

          elsif hready = '1' then
            -- no data on bus
            en_valid_data <= '0';
          end if;


        -------------------------------------------
        -- Others
        -------------------------------------------    
        when others =>
  
      end case;
    end if;
   
  end process control_p;
  


  ------------------------------------------------------------------------------
  -- Burst counter: indicates the current bus access number
  ------------------------------------------------------------------------------

  burstcounter_p: process (hreset_n, hclk)
  begin
    if (hreset_n = '0') then
      burstcounter     <= "0001";
    elsif hclk'event and hclk = '1' then
     
      if next_state = address or next_state = last_data_new_add then
        case burst is
          when SINGLE_CT =>
            burstcounter <= "0001";     -- single transfer
          when INCR_CT =>
            burstcounter <= "0000";     -- incrementing burst with unspecified length
          when WRAP4_CT =>
            burstcounter <= "0011";     -- 4-beat wrapping burst
          when INCR4_CT => 
            burstcounter <= "0011";     -- 4-beat incrementing burst
          when WRAP8_CT => 
            burstcounter <= "0111";     -- 8-beat wrapping burst
          when INCR8_CT =>  
            burstcounter <= "0111";     -- 8-beat incrementing burst
          when WRAP16_CT =>   
            burstcounter <= "1111";     -- 16-beat wrapping burst
          when others =>
            burstcounter <= "1111";     -- 16-beat incrementing burst
        end case;
        
      elsif inc_addr_i ='1' and burst /= INCR_CT then
        -- the burstcounter is not used in the case of an unspecified length burst and single burst
        burstcounter <= burstcounter - conv_std_logic_vector(1,4);        
      end if;
    end if;
    
  end process burstcounter_p;

  -- the end_of_burst signal indicates the end of a current burst
  -- machine
  end_of_burst <= '1' when burstcounter = 1 else '0';



  busreq_p: process (hreset_n, hclk)
  begin
    if hreset_n = '0' then
      hbusreq <= '0';
    elsif hclk'event and hclk = '1' then
      if current_state = retry_state  then -- or en_grant_lost = '1' 
        hbusreq <= '1';
      elsif busreq = '1' then
        hbusreq <= '1';
      elsif (hgrant = '1' and hready = '1' and burst /= INCR_CT  and next_state /= idle) or
          (burst = INCR_CT  and next_state = last_data and gotoaddr_g = 0)
      or  (burst = INCR_CT  and next_state = last_addr and gotoaddr_g = 1)
      or  (burst = INCR_CT  and next_state = degranted)        
      or  (current_state = error_state) or (next_state = last_data)       
      then
        hbusreq <= '0';
      end if;
    end if;
  end process busreq_p;

  
  --------------------------------------------
  -- Busy control
  --------------------------------------------
  busy_p: process (hreset_n, hclk)
  begin
    if hreset_n = '0' then
      busy_int <= '0';
      busy_old <= '0';
      busy_ff1 <= '0';
    elsif hclk'event and hclk = '1' then
      busy_old <= busy_s;
      busy_ff1 <= busy;
      if busy = '1' and hready = '0' then
        busy_int <= '1';
      elsif hready = '1' then
        busy_int <= '0';
      end if;
    end if;
  end process busy_p;

  busy_s <= busy_int or busy;

  ------------------------------------------------------------------------------
  -- Last Address and Last Data sent indication for the master 
  ------------------------------------------------------------------------------

  -- end_add is sent for each last address sent.
  end_add <= '1' when (current_state = last_addr and hready='1' 
    and burst /= SINGLE_CT)
    or  (burst=SINGLE_CT and 
    (current_state = address or current_state = last_data_new_add) and hready='1')
      else '0' ;

  -- end_data is sent for each last data sent.
  end_data <= '1' when (current_state = last_data or 
    current_state = last_data_new_add) and hready='1'
     else '0' ;

     -- the master increments its address and data each AHB bus cycle
  valid_data <= (en_valid_data and hready);
  inc_addr_i <= en_inc_addr and hready;
  inc_addr   <= inc_addr_i;
  decr_addr  <= en_decr_addr and hready;
  grant_lost <= en_grant_lost and hready;

end rtl;
