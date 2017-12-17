
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_intgen_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.4  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for bup2_intgen.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_intgen/vhdl/rtl/bup2_intgen_pkg.vhd,v  
--  Log: bup2_intgen_pkg.vhd,v  
-- Revision 1.4  2005/10/21 13:23:39  Dr.A
-- #BugId:1246#
-- Added absolute count timers
--
-- Revision 1.3  2005/01/10 12:51:09  Dr.A
-- #BugId:912#
-- Removed enable_bup
--
-- Revision 1.2  2004/12/20 12:51:44  Dr.A
-- #BugId:702#
-- Added ACK time-out interrupt
--
-- Revision 1.1  2003/11/19 16:24:20  Dr.F
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
package bup2_intgen_pkg is

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: bup2_intgen.vhd
----------------------
  component bup2_intgen
  generic (
    num_abstimer_g : integer := 16
  );
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n         : in  std_logic; -- Reset.
    clk             : in  std_logic; -- Clock.

    --------------------------------------------
    -- BuP registers inputs
    --------------------------------------------
    -- BuPtime register.
    reg_buptime     : in  std_logic_vector(25 downto 0); -- BuP timer.
    -- BuPintack register: acknowledge of the following interrupts
    reg_genirq_ack  : in  std_logic; -- Software interrupt.
    reg_timewrap_ack: in  std_logic; -- Wrapping around of buptime.
    reg_ccabusy_ack : in  std_logic; -- Ccabusy.
    reg_ccaidle_ack : in  std_logic; -- Ccaidle.
    reg_rxstart_ack : in  std_logic; -- Rx packet start.
    reg_rxend_ack   : in  std_logic; -- Rx packet end.
    reg_txend_ack   : in  std_logic; -- Tx packet end.
    reg_txstartirq_ack : in  std_logic; -- Tx packet start.
    reg_txstartfiq_ack : in  std_logic; -- Tx packet start (fast interrupt).
    reg_ackto_ack   : in  std_logic; -- ACK packet time-out.
    -- BuPAbscntintack register: acknowledge of the absolute count interrupts
    reg_abscnt_ack  : in  std_logic_vector(num_abstimer_g-1 downto 0);
    -- BuPintmask register: enable/disable interrupts on the following events.
    reg_timewrap_en : in  std_logic; -- Wrapping around of int_buptime.
    reg_ccabusy_en  : in  std_logic; -- Ccabusy.
    reg_ccaidle_en  : in  std_logic; -- Ccaidle.
    reg_rxstart_en  : in  std_logic; -- Rx packet start.
    reg_rxend_en    : in  std_logic; -- Rx packet end.
    reg_txend_en    : in  std_logic; -- Tx packet end.
    reg_txstartirq_en  : in  std_logic; -- Tx packet start.
    reg_txstartfiq_en  : in  std_logic; -- Tx packet start (fast interrupt).
    reg_ackto_en    : in  std_logic; -- ACK packet time-out.
    -- BuPAbscntintmask register: enable/disable interrupts on absolute count
    reg_abscnt_en      : in  std_logic_vector(num_abstimer_g-1 downto 0);
    -- IRQ/FIQ select for absolute counter interrupts
    reg_abscnt_irqsel  : in  std_logic_vector(num_abstimer_g-1 downto 0);

    --------------------------------------------
    -- Interrupt inputs
    --------------------------------------------
    sw_irq          : in  std_logic; -- Software interrupt (pulse).
    -- From BuP timers
    timewrap        : in  std_logic; -- Wrapping around of BuP timer.
    -- Absolute count interrupts
    abscount_it     : in  std_logic_vector(num_abstimer_g-1 downto 0);
    -- From BuP state machines
    txstart_it      : in  std_logic; -- TXSTART command executed.
    ccabusy_it      : in  std_logic; -- CCA busy.
    ccaidle_it      : in  std_logic; -- CCA idle.
    rxstart_it      : in  std_logic; -- Valid packet header detected.
    rxend_it        : in  std_logic; -- End of packet and no auto resp needed.
    txend_it        : in  std_logic; -- End of transmit packet.
    ackto_it        : in  std_logic; -- ACK packet time-out.
  
    --------------------------------------------
    -- Interrupt outputs
    --------------------------------------------
    bup_irq         : out std_logic; -- BuP normal interrupt line.
    bup_fiq         : out std_logic; -- BuP fast interrupt line.
    -- BuPintstat register. Interrupt source is:
    reg_genirq_src  : out std_logic; -- software interrupt.
    reg_timewrap_src: out std_logic; -- wrapping around of buptime.
    reg_ccabusy_src : out std_logic; -- ccabusy.
    reg_ccaidle_src : out std_logic; -- ccaidle.
    reg_rxstart_src : out std_logic; -- rx packet start.
    reg_rxend_src   : out std_logic; -- rx packet end.
    reg_txend_src   : out std_logic; -- tx packet end.
    reg_txstartirq_src : out std_logic; -- tx packet start.
    reg_txstartfiq_src : out std_logic; -- tx packet start (fast interrupt).
    reg_ackto_src   : out std_logic; -- ACK time-out (fast interrupt).
    -- Absolute count interrupt sources
    reg_abscntirq_src : out std_logic;
    reg_abscntfiq_src : out std_logic;
    reg_abscnt_src    : out std_logic_vector(num_abstimer_g-1 downto 0);
    -- BuPinttime register.
    reg_inttime     : out std_logic_vector(25 downto 0)  -- interrupt time tag.
  );

  end component;



 
end bup2_intgen_pkg;
