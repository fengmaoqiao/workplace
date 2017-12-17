
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild modem
--    ,' GoodLuck ,'      RCSfile: logarithm.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Compute logarithm
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/agc_cca/vhdl/rtl/logarithm.vhd,v  
--  Log: logarithm.vhd,v  
-- Revision 1.3  2003/01/09 15:31:10  Dr.C
-- Changed constants to registers
--
-- Revision 1.2  2002/11/07 16:24:35  Dr.C
-- Added accoup input
--
-- Revision 1.1  2002/10/25 17:02:39  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;



--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity logarithm is
  generic (
    p_size_g : integer := 4);           -- size of power estimation
  port (
    -----------------------
    -- clock and reset
    -----------------------
    clk     : in std_logic;             -- System clock
    reset_n : in std_logic;
    
    -----------------------
    -- Registers
    -----------------------
    accoup  : in  std_logic_vector(4 downto 0);
    kilp    : in  std_logic_vector(3 downto 0);
    
    -----------------------
    -- Control
    -----------------------
    lna         : in  std_logic_vector(7 downto 0);  -- LNA value
    pgc         : in  std_logic_vector(7 downto 0);  -- PGC value
    logstart    : in  std_logic;                     -- Triggers the logarithm
    power_estim : in  std_logic_vector(p_size_g-1 downto 0);
                                                     -- power estimation
    icinput     : out std_logic_vector(7 downto 0)
    );

end logarithm;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of logarithm is

  ------------------------------------------------------------------------------
  -- Constant
  ------------------------------------------------------------------------------
  constant NULL_CT        : std_logic_vector(31 downto 0) := (others => '0');
                                        -- Null constant
  constant INTTIME_CT     : std_logic_vector(13 downto 0) := "11110010000111"; --"11101111100111";--
  -- "00010000011001";"00001101111001";
  -- Integration constant  10*log(9/(4*11)) -7
  constant THREE_CT       : std_logic_vector(10 downto 0) := "11000000101";  -- 3.0
  constant RESCALE_ADC_CT : std_logic_vector(13 downto 0) := "11011011111001" ;--
  -- "00100100000111" ;

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal logstart_ff1      : std_logic;  -- logstart one c.c delayed
  signal maxindex          : std_logic_vector(4 downto 0);
  -- Index of highest one in the vector in power_estim
  signal power_estim_resc  : std_logic_vector(p_size_g-1 downto 0);
                                         -- Rescaled power estimation
  signal squared_value     : std_logic_vector(p_size_g-1 downto 0);
                                         -- Value after squarer
  signal logresult         : std_logic_vector(5 downto 0);
                                         -- Result of log computation
  signal icinput_int       : std_logic_vector(13 downto 0);
  signal iteration_counter : std_logic_vector(2 downto 0);
  -- Number of interation to compute the logarithm
  signal maxindex_int      : std_logic_vector(15 downto 0);
  signal logresult_int     : std_logic_vector(16 downto 0);
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- The logarithm operation will be computed for a value x0 in the range [1,2[
  -- power_estim = 2^maxindex * x0  where maxindex is the highest bit number
  -- which is not null.
  -- log(power_estim) = maxindex + log(x0)  in base 2

  -- Power estimation is rescaled in the range [1,2[
  rescale_p : process (clk, reset_n)
    variable maxindex_v : integer;      -- Index of highest one in the vector
  begin
    if reset_n = '0' then
      maxindex         <= (others => '0');
      power_estim_resc <= (others => '0');
      maxindex_v       := 0;
    elsif clk'event and clk = '1' then
      maxindex_v := 0;
      -- Max index
      for i in 0 to p_size_g -1 loop
        if power_estim(i) = '1' then
          maxindex_v := i;
        end if;
      end loop;

      if logstart = '1' then
        maxindex <= conv_std_logic_vector(maxindex_v, 5);
        for i in 0 to p_size_g-1 loop
          if i <= maxindex_v then
            power_estim_resc(p_size_g-1 -i) <= power_estim(maxindex_v -i);
          else
            power_estim_resc(p_size_g-1 -i) <= '0';
          end if;
        end loop;  -- i
      end if;
    end if;
  end process rescale_p;

  squarer_p : process (clk, reset_n)
    variable squared_value_v : std_logic_vector(2*p_size_g-1 downto 0);
  begin
    if reset_n = '0' then
      squared_value     <= (others => '0');
      squared_value_v   := (others => '0');
      logstart_ff1      <= '0';
      iteration_counter <= (others => '0');
      logresult         <= (others => '0');
    elsif clk'event and clk = '1' then

      logstart_ff1 <= logstart;
      if logstart = '1' then
        iteration_counter <= (others => '0');
      elsif logstart_ff1 = '1' then
        -- Power estimation is the squarer source
        squared_value_v   := power_estim_resc * power_estim_resc;
        iteration_counter <= iteration_counter + '1';
      elsif iteration_counter < "110" then        
        -- The last value computed is reused
        squared_value_v   := squared_value * squared_value;
        iteration_counter <= iteration_counter + '1';
      end if;

      if squared_value_v(2*p_size_g-1) = '1' then
        -- X^2 = X^2/2
        squared_value <=
          squared_value_v(2*p_size_g-1 downto p_size_g);
      else
        squared_value <=
          squared_value_v(2*p_size_g-2 downto p_size_g-1);
      end if;

      -- Log(x0)
      if iteration_counter < "110" then
        logresult <= logresult(4 downto 0) &
                     squared_value_v(2*p_size_g-1);
        
      end if;
      
    end if;
  end process squarer_p;

  -- Estpower = 10*log2*(logresult + maxindex) + constant(integration time)
  -- Icinput = estpower -lna - pgc;
  -- Result is first computed on 10 bits with the fractional part
  -- 6 bits for precision
  maxindex_int  <= maxindex*THREE_CT;
  logresult_int <= THREE_CT*logresult;
  icinput_int   <= (NULL_CT(10 downto 6) & logresult_int(16 downto 9)) +
                 maxindex_int(15 downto 3) + 
                 RESCALE_ADC_CT +
                 INTTIME_CT +
                 (sxt(accoup,8) & NULL_CT(3 downto 0)) +
                 (sxt(kilp,9) & NULL_CT(4 downto 0));
  
  
  icinput <= icinput_int(13 downto 6) - lna - pgc ;


 
end RTL;
