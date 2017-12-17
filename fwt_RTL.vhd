
--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of adder4 is

begin
  output0_real <= input0_real + input1_real;
  output0_imag <= input0_imag + input1_imag;

  output1_real <= input0_imag + input1_real;
  output1_imag <= input1_imag - input0_real;

  output2_real <= input1_real - input0_real;
  output2_imag <= input1_imag - input0_imag;

  output3_real <= input1_real - input0_imag;
  output3_imag <= input0_real + input1_imag;
end rtl;
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : FWT
--    ,' GoodLuck ,'      RCSfile: fwt.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Fast Walsh Transform
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/fwt/vhdl/rtl/fwt.vhd,v  
--  Log: fwt.vhd,v  
-- Revision 1.7  2004/04/30 15:01:37  arisse
-- Added reset of data between two packets :
-- Added input cck_demod_enable for that.
--
-- Revision 1.6  2002/09/20 07:28:55  elama
-- Variables storeX_X reseted in main process.
--
-- Revision 1.5  2002/06/05 07:25:59  elama
-- Fixed bug in the sign.
--
-- Revision 1.4  2002/05/31 12:21:15  elama
-- Incremented the size of the generic in adder4.
--
-- Revision 1.3  2002/05/30 14:45:58  elama
-- Generic size changed.
--
-- Revision 1.2  2002/03/14 17:24:48  elama
-- Reduced the number of data ouput ports and added the data_valid flag.
--
-- Revision 1.1  2002/01/29 09:31:43  elama
-- Initial revision
--
--
--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.STD_LOGIC_UNSIGNED.ALL; 

--library fwt_rtl; 
library work;
--use fwt_rtl.fwt_pkg.ALL; 
use work.fwt_pkg.ALL; 

entity fwt is
generic (
  data_length : integer := 6            -- Number of bits for data Input ports.
                                        -- 3 more bits for data output ports.
);
port (
  reset_n     : in  std_logic;          -- System reset. Active LOW.
  clk         : in  std_logic;          -- System clock.
  cck_demod_enable : in std_logic;
  start_fwt   : in  std_logic;          -- Start the fwt.
  end_fwt     : out std_logic;          -- Flag indicating fwt is finished.
  data_valid  : out std_logic;          -- Flag indicating output data valid.
--
  input0_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in0
  input0_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in0.
  input1_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in1
  input1_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in1.
  input2_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in2
  input2_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in2.
  input3_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in3
  input3_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in3.
  input4_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in4
  input4_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in4.
  input5_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in5
  input5_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in5.
  input6_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in6
  input6_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in6.
  input7_re   : in  std_logic_vector (data_length-1 downto 0);--Real part of in7
  input7_im   : in  std_logic_vector (data_length-1 downto 0);--Im part of in7.
--
  output0_re  : out std_logic_vector (data_length+2 downto 0);--R part of out0.
  output0_im  : out std_logic_vector (data_length+2 downto 0);--Im part of out0.
  output1_re  : out std_logic_vector (data_length+2 downto 0);--R part of out1.
  output1_im  : out std_logic_vector (data_length+2 downto 0);--Im part of out1.
  output2_re  : out std_logic_vector (data_length+2 downto 0);--R part of out2.
  output2_im  : out std_logic_vector (data_length+2 downto 0);--Im part of out2.
  output3_re  : out std_logic_vector (data_length+2 downto 0);--R part of out3.
  output3_im  : out std_logic_vector (data_length+2 downto 0) --Im part of out3.
);
end fwt;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of fwt is

--------------------------------------------------------------- Type declaration
type STATE_TYPE is (add0_state, add1_state, add2_state, add3_state,
                    add4_state, add5_state, add6_state, add7_state,
                    add8_state, add9_state, add10_state, add11_state,
                    add12_state, add13_state, add14_state, add15_state,
                    add16_state, add17_state, add18_state, add19_state,
                    add20_state, add21_state, add22_state, add23_state,
                    add24_state, add25_state, add26_state, add27_state);
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------- Signal declaration
signal fwt_state       : STATE_TYPE;    -- State in the main state machine.
signal int_end_fwt     : std_logic;     -- Internal 'end_fwt';
-- Internal input lines:
signal int_input0_re   : std_logic_vector (data_length+2 downto 0);
signal int_input0_im   : std_logic_vector (data_length+2 downto 0);
signal int_input1_re   : std_logic_vector (data_length+2 downto 0);
signal int_input1_im   : std_logic_vector (data_length+2 downto 0);
signal int_input2_re   : std_logic_vector (data_length+2 downto 0);
signal int_input2_im   : std_logic_vector (data_length+2 downto 0);
signal int_input3_re   : std_logic_vector (data_length+2 downto 0);
signal int_input3_im   : std_logic_vector (data_length+2 downto 0);
signal int_input4_re   : std_logic_vector (data_length+2 downto 0);
signal int_input4_im   : std_logic_vector (data_length+2 downto 0);
signal int_input5_re   : std_logic_vector (data_length+2 downto 0);
signal int_input5_im   : std_logic_vector (data_length+2 downto 0);
signal int_input6_re   : std_logic_vector (data_length+2 downto 0);
signal int_input6_im   : std_logic_vector (data_length+2 downto 0);
signal int_input7_re   : std_logic_vector (data_length+2 downto 0);
signal int_input7_im   : std_logic_vector (data_length+2 downto 0);
-- Complement A2 for input lines 3 and 6:
signal ca2_input3_re   : std_logic_vector (data_length+2 downto 0);
signal ca2_input3_im   : std_logic_vector (data_length+2 downto 0);
signal ca2_input6_re   : std_logic_vector (data_length+2 downto 0);
signal ca2_input6_im   : std_logic_vector (data_length+2 downto 0);
-- Signals for the ADDER4 block:
signal add_input0_real : std_logic_vector (data_length+2 downto 0);
signal add_input0_imag : std_logic_vector (data_length+2 downto 0);
signal add_input1_real : std_logic_vector (data_length+2 downto 0);
signal add_input1_imag : std_logic_vector (data_length+2 downto 0);
signal add_output0_real: std_logic_vector (data_length+2 downto 0);
signal add_output0_imag: std_logic_vector (data_length+2 downto 0);
signal add_output1_real: std_logic_vector (data_length+2 downto 0);
signal add_output1_imag: std_logic_vector (data_length+2 downto 0);
signal add_output2_real: std_logic_vector (data_length+2 downto 0);
signal add_output2_imag: std_logic_vector (data_length+2 downto 0);
signal add_output3_real: std_logic_vector (data_length+2 downto 0);
signal add_output3_imag: std_logic_vector (data_length+2 downto 0);
-- Store registers:
signal store0_0re      : std_logic_vector (data_length+2 downto 0); -- Stores
                   -- the real part of the first output line in the first adder.
signal store0_0im      : std_logic_vector (data_length+2 downto 0); -- Stores
                   -- the imag part of the first output line in the first adder.
signal store0_1re      : std_logic_vector (data_length+2 downto 0); -- Stores
                   -- the real part of the second output line in the first adder
signal store0_1im      : std_logic_vector (data_length+2 downto 0);
signal store0_2re      : std_logic_vector (data_length+2 downto 0); 
signal store0_2im      : std_logic_vector (data_length+2 downto 0);
signal store0_3re      : std_logic_vector (data_length+2 downto 0); 
signal store0_3im      : std_logic_vector (data_length+2 downto 0);

signal store1_0re      : std_logic_vector (data_length+2 downto 0);-- 2nd adder.
signal store1_0im      : std_logic_vector (data_length+2 downto 0);
signal store1_1re      : std_logic_vector (data_length+2 downto 0);
signal store1_1im      : std_logic_vector (data_length+2 downto 0);
signal store1_2re      : std_logic_vector (data_length+2 downto 0);
signal store1_2im      : std_logic_vector (data_length+2 downto 0);
signal store1_3re      : std_logic_vector (data_length+2 downto 0);
signal store1_3im      : std_logic_vector (data_length+2 downto 0);

signal store2_0re      : std_logic_vector (data_length+2 downto 0);-- 3rd adder.
signal store2_0im      : std_logic_vector (data_length+2 downto 0);
signal store2_1re      : std_logic_vector (data_length+2 downto 0);
signal store2_1im      : std_logic_vector (data_length+2 downto 0);
signal store2_2re      : std_logic_vector (data_length+2 downto 0);
signal store2_2im      : std_logic_vector (data_length+2 downto 0);
signal store2_3re      : std_logic_vector (data_length+2 downto 0);
signal store2_3im      : std_logic_vector (data_length+2 downto 0);

signal store3_0re      : std_logic_vector (data_length+2 downto 0);-- 4th adder.
signal store3_0im      : std_logic_vector (data_length+2 downto 0);
signal store3_1re      : std_logic_vector (data_length+2 downto 0);
signal store3_1im      : std_logic_vector (data_length+2 downto 0);
signal store3_2re      : std_logic_vector (data_length+2 downto 0);
signal store3_2im      : std_logic_vector (data_length+2 downto 0);
signal store3_3re      : std_logic_vector (data_length+2 downto 0);
signal store3_3im      : std_logic_vector (data_length+2 downto 0);

signal store4_0re      : std_logic_vector (data_length+2 downto 0);
signal store4_0im      : std_logic_vector (data_length+2 downto 0);
signal store4_1re      : std_logic_vector (data_length+2 downto 0);
signal store4_1im      : std_logic_vector (data_length+2 downto 0);
signal store4_2re      : std_logic_vector (data_length+2 downto 0);
signal store4_2im      : std_logic_vector (data_length+2 downto 0);
signal store4_3re      : std_logic_vector (data_length+2 downto 0);
signal store4_3im      : std_logic_vector (data_length+2 downto 0);

--signal store5_0re      : std_logic_vector (data_length-1 downto 0);
--signal store5_0im      : std_logic_vector (data_length-1 downto 0);
signal store5_1re      : std_logic_vector (data_length+2 downto 0);
signal store5_1im      : std_logic_vector (data_length+2 downto 0);
signal store5_2re      : std_logic_vector (data_length+2 downto 0);
signal store5_2im      : std_logic_vector (data_length+2 downto 0);
signal store5_3re      : std_logic_vector (data_length+2 downto 0);
signal store5_3im      : std_logic_vector (data_length+2 downto 0);
------------------------------------------------------ End of Signal declaration

begin

  end_fwt <= int_end_fwt;

  --------------------------------------------------------- Internal input lines
  int_input0_re <= input0_re (data_length-1) & input0_re (data_length-1) &
                   input0_re (data_length-1) & input0_re;
  int_input0_im <= input0_im (data_length-1) & input0_im (data_length-1) &
                   input0_im (data_length-1) & input0_im;
  int_input1_re <= input1_re (data_length-1) & input1_re (data_length-1) &
                   input1_re (data_length-1) & input1_re;
  int_input1_im <= input1_im (data_length-1) & input1_im (data_length-1) &
                   input1_im (data_length-1) & input1_im;
  int_input2_re <= input2_re (data_length-1) & input2_re (data_length-1) &
                   input2_re (data_length-1) & input2_re;
  int_input2_im <= input2_im (data_length-1) & input2_im (data_length-1) &
                   input2_im (data_length-1) & input2_im;
  int_input3_re <= input3_re (data_length-1) & input3_re (data_length-1) &
                   input3_re (data_length-1) & input3_re;
  int_input3_im <= input3_im (data_length-1) & input3_im (data_length-1) &
                   input3_im (data_length-1) & input3_im;
  int_input4_re <= input4_re (data_length-1) & input4_re (data_length-1) &
                   input4_re (data_length-1) & input4_re;
  int_input4_im <= input4_im (data_length-1) & input4_im (data_length-1) &
                   input4_im (data_length-1) & input4_im;
  int_input5_re <= input5_re (data_length-1) & input5_re (data_length-1) &
                   input5_re (data_length-1) & input5_re;
  int_input5_im <= input5_im (data_length-1) & input5_im (data_length-1) &
                   input5_im (data_length-1) & input5_im;
  int_input6_re <= input6_re (data_length-1) & input6_re (data_length-1) &
                   input6_re (data_length-1) & input6_re;
  int_input6_im <= input6_im (data_length-1) & input6_im (data_length-1) &
                   input6_im (data_length-1) & input6_im;
  int_input7_re <= input7_re (data_length-1) & input7_re (data_length-1) &
                   input7_re (data_length-1) & input7_re;
  int_input7_im <= input7_im (data_length-1) & input7_im (data_length-1) &
                   input7_im (data_length-1) & input7_im;
  -------------------------------------------------- End of Internal input lines

  -------------------------------------------- Complement A-2 for inputs 3 and 6
  ca2_input3_re <= not (int_input3_re) + 1;
  ca2_input3_im <= not (int_input3_im) + 1;
  ca2_input6_re <= not (int_input6_re) + 1;
  ca2_input6_im <= not (int_input6_im) + 1;
  ------------------------------------- End of Complement A-2 for inputs 3 and 6

  ----------------------------------------------------------- Main State Machine
  -- This is the state machine of the Fast Walsh Transform. It is composed of
  -- 28 different states each performing a group of four additions. The
  -- structure of the block is best seen in the design specifications.
  -- The store registers are named storeX_Yre and storeX_Yim where X designs
  -- the number of the adder4 and Y the output number. X takes values from
  -- 0 to 5 and Y takes values from 0 to 3. The suffix _re and _im design
  -- the real and imaginary part of the output respectively.
  main: process (reset_n, clk)
  begin
    if reset_n = '0' then
      output0_re <= (others => '0');
      output0_im <= (others => '0');
      output1_re <= (others => '0');
      output1_im <= (others => '0');
      output2_re <= (others => '0');
      output2_im <= (others => '0');
      output3_re <= (others => '0');
      output3_im <= (others => '0');
      store0_0re <= (others => '0');
      store0_0im <= (others => '0');
      store0_1re <= (others => '0');
      store0_1im <= (others => '0');
      store0_2re <= (others => '0');
      store0_2im <= (others => '0');
      store0_3re <= (others => '0');
      store0_3im <= (others => '0');
      store1_0re <= (others => '0');
      store1_0im <= (others => '0');
      store1_1re <= (others => '0');
      store1_1im <= (others => '0');
      store1_2re <= (others => '0');
      store1_2im <= (others => '0');
      store1_3re <= (others => '0');
      store1_3im <= (others => '0');
      store2_0re <= (others => '0');
      store2_0im <= (others => '0');
      store2_1re <= (others => '0');
      store2_1im <= (others => '0');
      store2_2re <= (others => '0');
      store2_2im <= (others => '0');
      store2_3re <= (others => '0');
      store2_3im <= (others => '0');
      store3_0re <= (others => '0');
      store3_0im <= (others => '0');
      store3_1re <= (others => '0');
      store3_1im <= (others => '0');
      store3_2re <= (others => '0');
      store3_2im <= (others => '0');
      store3_3re <= (others => '0');
      store3_3im <= (others => '0');
      store4_0re <= (others => '0');
      store4_0im <= (others => '0');
      store4_1re <= (others => '0');
      store4_1im <= (others => '0');
      store4_2re <= (others => '0');
      store4_2im <= (others => '0');
      store4_3re <= (others => '0');
      store4_3im <= (others => '0');
      store5_1re <= (others => '0');
      store5_1im <= (others => '0');
      store5_2re <= (others => '0');
      store5_2im <= (others => '0');
      store5_3re <= (others => '0');
      store5_3im <= (others => '0');
      add_input0_real <= (others => '0');
      add_input0_imag <= (others => '0');
      add_input1_real <= (others => '0');
      add_input1_imag <= (others => '0');
      fwt_state <= add0_state;
      int_end_fwt <= '1';
    elsif (clk'event and clk = '1') then
        if (cck_demod_enable = '0') then
      output0_re <= (others => '0');
      output0_im <= (others => '0');
      output1_re <= (others => '0');
      output1_im <= (others => '0');
      output2_re <= (others => '0');
      output2_im <= (others => '0');
      output3_re <= (others => '0');
      output3_im <= (others => '0');
      store0_0re <= (others => '0');
      store0_0im <= (others => '0');
      store0_1re <= (others => '0');
      store0_1im <= (others => '0');
      store0_2re <= (others => '0');
      store0_2im <= (others => '0');
      store0_3re <= (others => '0');
      store0_3im <= (others => '0');
      store1_0re <= (others => '0');
      store1_0im <= (others => '0');
      store1_1re <= (others => '0');
      store1_1im <= (others => '0');
      store1_2re <= (others => '0');
      store1_2im <= (others => '0');
      store1_3re <= (others => '0');
      store1_3im <= (others => '0');
      store2_0re <= (others => '0');
      store2_0im <= (others => '0');
      store2_1re <= (others => '0');
      store2_1im <= (others => '0');
      store2_2re <= (others => '0');
      store2_2im <= (others => '0');
      store2_3re <= (others => '0');
      store2_3im <= (others => '0');
      store3_0re <= (others => '0');
      store3_0im <= (others => '0');
      store3_1re <= (others => '0');
      store3_1im <= (others => '0');
      store3_2re <= (others => '0');
      store3_2im <= (others => '0');
      store3_3re <= (others => '0');
      store3_3im <= (others => '0');
      store4_0re <= (others => '0');
      store4_0im <= (others => '0');
      store4_1re <= (others => '0');
      store4_1im <= (others => '0');
      store4_2re <= (others => '0');
      store4_2im <= (others => '0');
      store4_3re <= (others => '0');
      store4_3im <= (others => '0');
      store5_1re <= (others => '0');
      store5_1im <= (others => '0');
      store5_2re <= (others => '0');
      store5_2im <= (others => '0');
      store5_3re <= (others => '0');
      store5_3im <= (others => '0');
      add_input0_real <= (others => '0');
      add_input0_imag <= (others => '0');
      add_input1_real <= (others => '0');
      add_input1_imag <= (others => '0');
      fwt_state <= add0_state;
      int_end_fwt <= '1';
        else
      case fwt_state is
        when add0_state =>
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
           if start_fwt = '1' then
            fwt_state       <= add1_state;
            int_end_fwt     <= '0';
            -- Start first addition.
            add_input0_real <= int_input0_re;
            add_input0_imag <= int_input0_im;
            add_input1_real <= int_input1_re;
            add_input1_imag <= int_input1_im;
          else
            int_end_fwt     <= '1';
            fwt_state       <= add0_state;
          end if;

        when add1_state =>
          fwt_state         <= add2_state;
          -- Store the result of previous addition.
          store0_0re        <= add_output0_real;
          store0_0im        <= add_output0_imag;
          store0_1re        <= add_output1_real;
          store0_1im        <= add_output1_imag;
          store0_2re        <= add_output2_real;
          store0_2im        <= add_output2_imag;
          store0_3re        <= add_output3_real;
          store0_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= int_input2_re;
          add_input0_imag   <= int_input2_im;
          add_input1_real   <= ca2_input3_re;
          add_input1_imag   <= ca2_input3_im;

        when add2_state =>
          fwt_state         <= add3_state;
          -- Store the result of previous addition.
          store1_0re        <= add_output0_real;
          store1_0im        <= add_output0_imag;
          store1_1re        <= add_output1_real;
          store1_1im        <= add_output1_imag;
          store1_2re        <= add_output2_real;
          store1_2im        <= add_output2_imag;
          store1_3re        <= add_output3_real;
          store1_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= int_input4_re;
          add_input0_imag   <= int_input4_im;
          add_input1_real   <= int_input5_re;
          add_input1_imag   <= int_input5_im;

        when add3_state =>
          fwt_state         <= add4_state;
          -- Store the result of previous addition.
          store2_0re        <= add_output0_real;
          store2_0im        <= add_output0_imag;
          store2_1re        <= add_output1_real;
          store2_1im        <= add_output1_imag;
          store2_2re        <= add_output2_real;
          store2_2im        <= add_output2_imag;
          store2_3re        <= add_output3_real;
          store2_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= ca2_input6_re;
          add_input0_imag   <= ca2_input6_im;
          add_input1_real   <= int_input7_re;
          add_input1_imag   <= int_input7_im;

        when add4_state =>
          fwt_state         <= add5_state;
          -- Store the result of previous addition.
          store3_0re        <= add_output0_real;
          store3_0im        <= add_output0_imag;
          store3_1re        <= add_output1_real;
          store3_1im        <= add_output1_imag;
          store3_2re        <= add_output2_real;
          store3_2im        <= add_output2_imag;
          store3_3re        <= add_output3_real;
          store3_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store0_0re;
          add_input0_imag   <= store0_0im;
          add_input1_real   <= store1_0re;
          add_input1_imag   <= store1_0im;

        when add5_state =>
          fwt_state         <= add6_state;
          -- Store the result of previous addition.
          store4_0re        <= add_output0_real;
          store4_0im        <= add_output0_imag;
          store4_1re        <= add_output1_real;
          store4_1im        <= add_output1_imag;
          store4_2re        <= add_output2_real;
          store4_2im        <= add_output2_imag;
          store4_3re        <= add_output3_real;
          store4_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store2_0re;
          add_input0_imag   <= store2_0im;
          add_input1_real   <= store3_0re;
          add_input1_imag   <= store3_0im;

        when add6_state =>
          fwt_state         <= add7_state;
          -- Store the result of previous addition.
          --store5_0re        <= add_output0_real;
          --store5_0im        <= add_output0_imag;
          store5_1re        <= add_output1_real;
          store5_1im        <= add_output1_imag;
          store5_2re        <= add_output2_real;
          store5_2im        <= add_output2_imag;
          store5_3re        <= add_output3_real;
          store5_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_0re;
          add_input0_imag   <= store4_0im;
          add_input1_real   <= add_output0_real;
          add_input1_imag   <= add_output0_imag;

        when add7_state =>
          fwt_state    <= add8_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_1re;
          add_input0_imag   <= store4_1im;
          add_input1_real   <= store5_1re;
          add_input1_imag   <= store5_1im;

        when add8_state =>
          fwt_state         <= add9_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_2re;
          add_input0_imag   <= store4_2im;
          add_input1_real   <= store5_2re;
          add_input1_imag   <= store5_2im;

        when add9_state =>
          fwt_state         <= add10_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_3re;
          add_input0_imag   <= store4_3im;
          add_input1_real   <= store5_3re;
          add_input1_imag   <= store5_3im;

        when add10_state =>
          fwt_state         <= add11_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store0_1re;
          add_input0_imag   <= store0_1im;
          add_input1_real   <= store1_1re;
          add_input1_imag   <= store1_1im;

        when add11_state =>
          fwt_state         <= add12_state;
          -- Store the result of previous addition.
          store4_0re        <= add_output0_real;
          store4_0im        <= add_output0_imag;
          store4_1re        <= add_output1_real;
          store4_1im        <= add_output1_imag;
          store4_2re        <= add_output2_real;
          store4_2im        <= add_output2_imag;
          store4_3re        <= add_output3_real;
          store4_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store2_1re;
          add_input0_imag   <= store2_1im;
          add_input1_real   <= store3_1re;
          add_input1_imag   <= store3_1im;

        when add12_state =>
          fwt_state         <= add13_state;
          -- Store the result of previous addition.
          --store5_0re        <= add_output0_real;
          --store5_0im        <= add_output0_imag;
          store5_1re        <= add_output1_real;
          store5_1im        <= add_output1_imag;
          store5_2re        <= add_output2_real;
          store5_2im        <= add_output2_imag;
          store5_3re        <= add_output3_real;
          store5_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_0re;
          add_input0_imag   <= store4_0im;
          add_input1_real   <= add_output0_real;
          add_input1_imag   <= add_output0_imag;

        when add13_state =>
          fwt_state         <= add14_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_1re;
          add_input0_imag   <= store4_1im;
          add_input1_real   <= store5_1re;
          add_input1_imag   <= store5_1im;

        when add14_state =>
          fwt_state         <= add15_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_2re;
          add_input0_imag   <= store4_2im;
          add_input1_real   <= store5_2re;
          add_input1_imag   <= store5_2im;

        when add15_state =>
          fwt_state         <= add16_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_3re;
          add_input0_imag   <= store4_3im;
          add_input1_real   <= store5_3re;
          add_input1_imag   <= store5_3im;

        when add16_state =>
          fwt_state         <= add17_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store0_2re;
          add_input0_imag   <= store0_2im;
          add_input1_real   <= store1_2re;
          add_input1_imag   <= store1_2im;

        when add17_state =>
          fwt_state         <= add18_state;
          -- Store the result of previous addition.
          store4_0re        <= add_output0_real;
          store4_0im        <= add_output0_imag;
          store4_1re        <= add_output1_real;
          store4_1im        <= add_output1_imag;
          store4_2re        <= add_output2_real;
          store4_2im        <= add_output2_imag;
          store4_3re        <= add_output3_real;
          store4_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store2_2re;
          add_input0_imag   <= store2_2im;
          add_input1_real   <= store3_2re;
          add_input1_imag   <= store3_2im;

        when add18_state =>
          fwt_state         <= add19_state;
          -- Store the result of previous addition.
          --store5_0re        <= add_output0_real;
          --store5_0im        <= add_output0_imag;
          store5_1re        <= add_output1_real;
          store5_1im        <= add_output1_imag;
          store5_2re        <= add_output2_real;
          store5_2im        <= add_output2_imag;
          store5_3re        <= add_output3_real;
          store5_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_0re;
          add_input0_imag   <= store4_0im;
          add_input1_real   <= add_output0_real;
          add_input1_imag   <= add_output0_imag;

        when add19_state =>
          fwt_state         <= add20_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_1re;
          add_input0_imag   <= store4_1im;
          add_input1_real   <= store5_1re;
          add_input1_imag   <= store5_1im;

        when add20_state =>
          fwt_state         <= add21_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_2re;
          add_input0_imag   <= store4_2im;
          add_input1_real   <= store5_2re;
          add_input1_imag   <= store5_2im;

        when add21_state =>
          fwt_state         <= add22_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_3re;
          add_input0_imag   <= store4_3im;
          add_input1_real   <= store5_3re;
          add_input1_imag   <= store5_3im;

        when add22_state =>
          fwt_state         <= add23_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store0_3re;
          add_input0_imag   <= store0_3im;
          add_input1_real   <= store1_3re;
          add_input1_imag   <= store1_3im;

        when add23_state =>
          fwt_state         <= add24_state;
          -- Store the result of previous addition.
          store4_0re        <= add_output0_real;
          store4_0im        <= add_output0_imag;
          store4_1re        <= add_output1_real;
          store4_1im        <= add_output1_imag;
          store4_2re        <= add_output2_real;
          store4_2im        <= add_output2_imag;
          store4_3re        <= add_output3_real;
          store4_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store2_3re;
          add_input0_imag   <= store2_3im;
          add_input1_real   <= store3_3re;
          add_input1_imag   <= store3_3im;

        when add24_state =>
          fwt_state         <= add25_state;
          -- Store the result of previous addition.
          --store5_0re        <= add_output0_real;
          --store5_0im        <= add_output0_imag;
          store5_1re        <= add_output1_real;
          store5_1im        <= add_output1_imag;
          store5_2re        <= add_output2_real;
          store5_2im        <= add_output2_imag;
          store5_3re        <= add_output3_real;
          store5_3im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_0re;
          add_input0_imag   <= store4_0im;
          add_input1_real   <= add_output0_real;
          add_input1_imag   <= add_output0_imag;

        when add25_state =>
          fwt_state         <= add26_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_1re;
          add_input0_imag   <= store4_1im;
          add_input1_real   <= store5_1re;
          add_input1_imag   <= store5_1im;

        when add26_state =>
          fwt_state         <= add27_state;
          -- Store the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_2re;
          add_input0_imag   <= store4_2im;
          add_input1_real   <= store5_2re;
          add_input1_imag   <= store5_2im;

        when add27_state =>
          fwt_state         <= add0_state;
          -- Output the result of previous addition.
          output0_re        <= add_output0_real;
          output0_im        <= add_output0_imag;
          output1_re        <= add_output1_real;
          output1_im        <= add_output1_imag;
          output2_re        <= add_output2_real;
          output2_im        <= add_output2_imag;
          output3_re        <= add_output3_real;
          output3_im        <= add_output3_imag;
          -- Load the new values to the adder.
          add_input0_real   <= store4_3re;
          add_input0_imag   <= store4_3im;
          add_input1_real   <= store5_3re;
          add_input1_imag   <= store5_3im;

        when others =>
          fwt_state    <= add0_state;

      end case;
        end if;
    end if;
  end process main;
  ---------------------------------------------------- End of Main State Machine

  ------------------------------------------------------ 'data_valid' Generation
  -- This process generates the 'data_valid' output lines which indicates
  -- when the data in the output lines can be taken into account.
  data_valid_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      data_valid <= '0';
    elsif (clk'event and clk = '1') then
      if (fwt_state =  add7_state or fwt_state =  add8_state or
          fwt_state =  add9_state or fwt_state = add10_state or
          fwt_state = add13_state or fwt_state = add14_state or
          fwt_state = add15_state or fwt_state = add16_state or
          fwt_state = add19_state or fwt_state = add20_state or
          fwt_state = add21_state or fwt_state = add22_state or
          fwt_state = add25_state or fwt_state = add26_state or
          fwt_state = add27_state or
         (fwt_state =  add0_state and int_end_fwt = '0')) then
        data_valid <= '1';
      else
        data_valid <= '0';
      end if;
    end if;
  end process data_valid_pr;
  ----------------------------------------------- End of 'data_valid' Generation

------------------------------------------------------------ Port map for Adder4
adder4_1: adder4
generic map(
  data_length  => (data_length +3)
)
port map(
  input0_real  => add_input0_real,
  input0_imag  => add_input0_imag,
  input1_real  => add_input1_real,
  input1_imag  => add_input1_imag,
  output0_real => add_output0_real,
  output0_imag => add_output0_imag,
  output1_real => add_output1_real,
  output1_imag => add_output1_imag,
  output2_real => add_output2_real,
  output2_imag => add_output2_imag,
  output3_real => add_output3_real,
  output3_imag => add_output3_imag
);
----------------------------------------------------- End of Port map for Adder4

end RTL;
