
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : FWT
--    ,' GoodLuck ,'      RCSfile: adder4.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Group of 4 adders to use in the FWT
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/fwt/vhdl/rtl/adder4.vhd,v  
--  Log: adder4.vhd,v  
-- Revision 1.1  2002/01/29 09:32:07  elama
-- Initial revision
--
--
--------------------------------------------------------------------------------
-- The structure of the block is as follows:
--
--             __                 ___
--     a,b ___|+1|_______________|   |
--          | |__|  a,b      ____| + |___ e,f
--          |               |    |___|
--          |  __           |     ___
--          |_|-j|__________|____|   |
--          | |__|  b,-a    |____| + |___ g,h
--          |               |    |___|
--          |  __           |     ___
--          |_|-1|__________|____|   |
--          | |__|  -a,-b   |____| + |___ i,j
--          |               |    |___|
--          |  __           |     ___
--          |_|+j|__________|____|   |
--            |__|  -b,a    |____| + |___ k,l
--     c,d _________________|    |___|
--
--
-- where: a = input0_real,
--        b = input0_imag,
--        c = input1_real,
--        d = input1_imag,
--        e = output0_real,
--        f = output0_imag,
--        g = output1_real,
--        h = output1_imag,
--        i = output2_real,
--        j = output2_imag,
--        k = output3_real,
--        l = output3_imag,
--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.STD_LOGIC_UNSIGNED.ALL;
  use IEEE.STD_LOGIC_ARITH.ALL;

entity adder4 is
generic (
  data_length : integer := 6            -- Number of bits for data I/O ports.
);
port (
  input0_real : in  std_logic_vector (data_length-1 downto 0);--Real part of in1
  input0_imag : in  std_logic_vector (data_length-1 downto 0);--Im part of in1.
  input1_real : in  std_logic_vector (data_length-1 downto 0);--Real part of in2
  input1_imag : in  std_logic_vector (data_length-1 downto 0);--Im part of in2.
  output0_real: out std_logic_vector (data_length-1 downto 0);--Re part of out1.
  output0_imag: out std_logic_vector (data_length-1 downto 0);--Im part of out1.
  output1_real: out std_logic_vector (data_length-1 downto 0);--Re part of out2.
  output1_imag: out std_logic_vector (data_length-1 downto 0);--Im part of out2.
  output2_real: out std_logic_vector (data_length-1 downto 0);--Re part of out3.
  output2_imag: out std_logic_vector (data_length-1 downto 0);--Im part of out3.
  output3_real: out std_logic_vector (data_length-1 downto 0);--Re part of out4.
  output3_imag: out std_logic_vector (data_length-1 downto 0) --Im part of out4.
);
end adder4;
