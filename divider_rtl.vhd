
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Divider
--    ,' GoodLuck ,'      RCSfile: divider.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Divider.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/divider/vhdl/rtl/divider.vhd,v  
--  Log: divider.vhd,v  
-- Revision 1.2  2003/06/10 13:55:43  Dr.F
-- cleaned and debugged rounding problems.
--
-- Revision 1.1  2003/03/27 07:38:08  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library divider_rtl;
library work;
--use divider_rtl.divider_pkg.all;
use work.divider_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity divider is

  generic (nbit_input_g       : integer := 25;
           nbit_quotient_g    : integer := 12;
           nintbit_quotient_g : integer := 1);

  port(clk         : in  std_logic;
       reset_n     : in  std_logic;
       start       : in  std_logic;  -- start division on pulse
       dividend    : in  std_logic_vector(nbit_input_g-1 downto 0);
       divisor     : in  std_logic_vector(nbit_input_g-1 downto 0);
       quotient    : out std_logic_vector(nbit_quotient_g-1 downto 0);
       value_ready : out std_logic); -- quotient is available on pulse




end divider;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of divider is

  constant NBIT_INPUT_SRT_CT    : integer := nbit_input_g+1;
  constant NBIT_QUOTIENT_SRT_CT : integer := nbit_quotient_g + nintbit_quotient_g+1;
  
  constant ZEROS_CT             : std_logic_vector(nbit_input_g -3 downto 0) := (others => '0');
  constant INPUT_MIN_CT         : std_logic_vector(nbit_input_g-1 downto 0)  := '1' & ZEROS_CT & '0';
  constant INPUT_CLIP_CT        : std_logic_vector(nbit_input_g-1 downto 0)  := '1' & ZEROS_CT & '1';

  signal srt_start       : std_logic;
  signal srt_dividend    : std_logic_vector(NBIT_INPUT_SRT_CT-1 downto 0);
  signal srt_divisor     : std_logic_vector(NBIT_INPUT_SRT_CT-1 downto 0);
  signal srt_quotient    : std_logic_vector(NBIT_QUOTIENT_SRT_CT-1 downto 0);
  signal srt_value_ready : std_logic;

  signal dividend_abs : std_logic_vector(nbit_input_g -1 downto 0);
  signal divisor_abs  : std_logic_vector(nbit_input_g -1 downto 0);
  signal sign_bit     : std_logic;

  signal shift_avail : std_logic;
  signal abs_avail   : std_logic;
  signal norm_avail  : std_logic;

  signal div_value_ready : std_logic;

  signal shift_divisor_index : integer range 0 to nbit_input_g;
  signal shift_dividend      : integer range 0 to 1;

begin

  --------------------------------------------
  -- SRT divider
  --------------------------------------------
  srt_i1 : srt_div
    generic map (nbit_input_g    => NBIT_INPUT_SRT_CT,
                 nbit_quotient_g => NBIT_QUOTIENT_SRT_CT)
    port map (clk                => clk,
              reset_n            => reset_n,
              start              => srt_start,
              dividend           => srt_dividend,
              divisor            => srt_divisor,
              quotient           => srt_quotient,
              value_ready        => srt_value_ready);


  --------------------------------------------
  -- Sign preprocessing. This process converts the
  -- dividend and divisor to positive values
  -- and catches if they have different sign.
  --------------------------------------------
  sign_pre_p : process (clk, reset_n)
    variable divisor_tmp  : std_logic_vector(nbit_input_g-1 downto 0);
    variable dividend_tmp : std_logic_vector(nbit_input_g-1 downto 0);

  begin
    if reset_n = '0' then
      sign_bit     <= '0';
      dividend_abs <= (others => '0');
      divisor_abs  <= (others => '0');
      abs_avail    <= '0';
    elsif clk'event and clk='1' then
      
      if start = '1' then
        -- clip divisor and dividend to +- 2^(Nbit_input-1) -1
        -- for 10 Bit input this means +- 511
        if divisor = INPUT_MIN_CT then
          divisor_tmp  := INPUT_CLIP_CT;
        else
          divisor_tmp  := divisor;
        end if;
        if dividend = INPUT_MIN_CT then
          dividend_tmp := INPUT_CLIP_CT;
        else
          dividend_tmp := dividend;
        end if;
        -- SRT can only handle positive inputs
        dividend_abs <= abs(signed(dividend_tmp));
        divisor_abs  <= abs(signed(divisor_tmp));
        -- generate sign bit for postprocessing
        if (dividend(dividend'high) /= divisor(divisor'high)) then
          sign_bit <= '1';
        else
          sign_bit <= '0';
        end if;

        -- triggers the preproc_p process to tell that 
        -- absolute values are available.
        abs_avail <= '1';
      else
        abs_avail <= '0';
      end if;

    end if;

  end process sign_pre_p;


  --------------------------------------------
  -- Preprocessing. This process bound the divisor
  -- between 0.5 and 1, and the dividend between 0 and 0.5,
  -- as required by the SRT algorithm.
  --------------------------------------------
  preproc_p : process (clk, reset_n)
    variable shift_divisor_index_v : integer range 0 to nbit_input_g;
    variable one_detect_v          : integer range 0 to 1;
    variable i                     : integer;
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      srt_dividend          <= (others => '0');
      srt_divisor           <= (others => '0');
      shift_divisor_index_v := 0;
      shift_avail           <= '0';
      one_detect_v          := 0;
      srt_start             <= '0';
      shift_divisor_index_v := 0;
      shift_divisor_index   <= 0;
      one_detect_v          := 0;
      shift_dividend        <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge

      if div_value_ready = '1' then
        shift_divisor_index_v := 0;
      end if;

      -- if absolute values are available (from sign_pre_p process)
      if (abs_avail = '1') then
        -- compute the number of shift operations to bound the
        -- divisor input to the SRT to 0.5 < divisor < 1
        for i in nbit_input_g-2 downto 0 loop
          if one_detect_v = 0 then
            if divisor_abs(i) = '0' then
              shift_divisor_index_v := shift_divisor_index_v + 1;
            else
              one_detect_v          := 1;
            end if;
          end if;
        end loop;

        shift_avail <= '1';
      else
        shift_avail <= '0';
        one_detect_v := 0;
      end if;

      if shift_avail = '1' then
        if dividend_abs(dividend_abs'high-1) = '1' then
          -- dividend has to be between 0 and 0.5
          srt_dividend   <= '0' & dividend_abs;
          shift_dividend <= 1;
        else
          srt_dividend   <= dividend_abs & '0';
          shift_dividend <= 0;
        end if;
        -- bound divisor to  0.5 < divisor < 1
        srt_divisor      <= SHL(divisor_abs, conv_std_logic_vector(shift_divisor_index_v, nbit_input_g)) & '0';
        srt_start        <= '1';
      else
        srt_start        <= '0';
      end if;

      shift_divisor_index <= shift_divisor_index_v;

    end if;
  end process preproc_p;


  --------------------------------------------
  -- Postprocessing. Bound the quotient in the right
  -- sign and range.
  --------------------------------------------
  postproc_p : process (clk, reset_n)
    variable quotient_buf_v      : std_logic_vector(2*nbit_input_g + NBIT_QUOTIENT_SRT_CT -1 downto 0);
    variable quotient_v          : std_logic_vector(nbit_quotient_g downto 0);
    variable neg_quotient_buf_v  : std_logic_vector(2*nbit_input_g+NBIT_QUOTIENT_SRT_CT -1 downto 0);
    variable shift_quotient_v    : integer range -nbit_input_g to nbit_input_g+1;
    variable lsb_quotient_v      : integer range 0 to 2*nbit_input_g + NBIT_QUOTIENT_SRT_CT -1;
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      quotient_buf_v    := (others => '0');
      div_value_ready   <= '0';
      quotient          <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- if SRT divider processing is over
      if srt_value_ready = '1' then
        -- put the srt_quotient in the middle of a bigger vector.
        quotient_buf_v := (others => '0');
        quotient_buf_v(NBIT_QUOTIENT_SRT_CT+nbit_input_g-1 downto nbit_input_g)
                       := srt_quotient;
        -- quotient shift smount to get the correct weighted output.
        -- can be positive or negative
        shift_quotient_v := nintbit_quotient_g - shift_divisor_index -
                          shift_dividend;
        -- lsb of the quotient
        lsb_quotient_v := nbit_input_g+nintbit_quotient_g+shift_quotient_v;

        neg_quotient_buf_v := not(quotient_buf_v) + '1';
        quotient_buf_v := SHR(quotient_buf_v, conv_std_logic_vector(lsb_quotient_v, nbit_input_g));
        neg_quotient_buf_v := std_logic_vector(SHR(signed(neg_quotient_buf_v), conv_unsigned(lsb_quotient_v, nbit_input_g)));

        if sign_bit = '1' then -- apply sign bit
          -- extract the quotient with appropriate shifting and rounding
          quotient_v := neg_quotient_buf_v(nbit_quotient_g downto 0) + '1';
          quotient   <= quotient_v(nbit_quotient_g downto 1);
        else
          -- extract the quotient with appropriate shifting and rounding
          quotient_v := quotient_buf_v(nbit_quotient_g downto 0) + '1';
          quotient   <= quotient_v(nbit_quotient_g downto 1);

        end if;

        -- The quotient of the division is available
        div_value_ready <= '1';
      else
        div_value_ready <= '0';
      end if;
    end if;
  end process postproc_p;


  value_ready <= div_value_ready;

end rtl;
