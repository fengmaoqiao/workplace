
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Divider
--    ,' GoodLuck ,'      RCSfile: srt_div.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Divider.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/divider/vhdl/rtl/srt_div.vhd,v  
--  Log: srt_div.vhd,v  
-- Revision 1.4  2003/06/10 13:56:36  Dr.F
-- code cleaning.
--
-- Revision 1.3  2003/05/20 08:17:35  Dr.F
-- removed "others" on partial_quotien assignment due to synopsys limitation.
--
-- Revision 1.2  2003/05/14 09:30:03  rrich
-- Fixed spurious value_ready after asynch reset
--
-- Revision 1.1  2003/03/27 07:38:11  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


--------------------------------------------
-- Entity
--------------------------------------------
entity srt_div is

  generic (nbit_input_g    : integer := 10;
           nbit_quotient_g : integer := 10);

  port(clk         : in  std_logic;
       reset_n     : in  std_logic;
       start       : in  std_logic;  -- start division on pulse
       dividend    : in  std_logic_vector(nbit_input_g-1 downto 0);
       divisor     : in  std_logic_vector(nbit_input_g-1 downto 0);
       quotient    : out std_logic_vector(nbit_quotient_g-1 downto 0);
       value_ready : out std_logic); -- quotient is available on pulse

end srt_div;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of srt_div is


  constant NULL_CT : std_logic_vector(nbit_quotient_g-1 downto 0) := 
              (others => '0');
  
  signal step            : integer range nbit_quotient_g+3 downto 0;

begin

  --------------------------------------------
  -- This process counts the processing steps of
  -- the SRT algorithm
  --------------------------------------------
  step_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      step   <= nbit_quotient_g+3;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if start = '1'   then
        step <= 0;
      end if;
      if step <= nbit_quotient_g+2 then
        step  <= step + 1;
      end if;
    end if;
  end process step_p;

  --------------------------------------------
  -- SRT algorithm
  --------------------------------------------
  srt_p : process (clk, reset_n)
    variable p_remind         : std_logic_vector(nbit_input_g-1 downto 0);  -- partial remainder at j
    variable partial_quotient : std_logic_vector(nbit_quotient_g downto 0);
    variable quotient_buf     : std_logic_vector(nbit_quotient_g downto 0);
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      p_remind         := (others => '0');
      quotient_buf     := (others => '0');
      partial_quotient := (others => '0');
      quotient         <= (others => '0');
      value_ready      <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      value_ready      <= '0';
      if step = 0 then                  -- initial step
        p_remind                                     := dividend;
        quotient_buf                                 := (others => '0');
        partial_quotient(nbit_quotient_g)            := '1';
        partial_quotient(nbit_quotient_g-1 downto 0) := NULL_CT;
      elsif step <= (nbit_quotient_g+1) then
        -- compute next quotient digit
        if p_remind(p_remind'high downto p_remind'high-1) = "01" then  -- pr >= 0.5
          -- compute next partial remainder
          p_remind := p_remind - divisor;
          p_remind := SHL(p_remind, "01");
          -- compute quotient
          quotient_buf:= quotient_buf + partial_quotient;
        elsif p_remind(p_remind'high downto p_remind'high-1) = "10" then -- pr < -0.5
          -- compute next partial remainder
          p_remind := p_remind + divisor;
          p_remind := SHL(p_remind, "01");
          -- compute quotient
          quotient_buf:= quotient_buf - partial_quotient;
        else
          -- compute next partial remainder
          p_remind   := SHL(p_remind, "01");
        end if;

        -- shift partial quotient
        partial_quotient := SHR(partial_quotient, "01");

      end if;
      if step = nbit_quotient_g+1 then
        if p_remind(p_remind'high) = '1' then -- final reminder is < 0
          quotient_buf := quotient_buf - '1';
          quotient     <= quotient_buf(quotient_buf'high downto 1);
        else
          quotient     <= quotient_buf(quotient_buf'high downto 1);
        end if;
        
        -- SRT quotient is available
        value_ready <= '1';
      end if;
    end if;
  end process srt_p;

end rtl;
