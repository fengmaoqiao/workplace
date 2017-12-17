

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: biggest_picker.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block selects the input where max(max(|re|,|im|)) has been
--             found among 64 inputs. In fact, only 4 inputs are given at the
--             same time. Thus, the processing is performed 16 times serialy.
--             At the end, the right input is selected among the 16*4 provided.
--             The index corresponding to this input is also provided.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/biggest_picker/vhdl/rtl/biggest_picker.vhd,v  
--  Log: biggest_picker.vhd,v  
-- Revision 1.4  2002/11/08 13:17:54  Dr.F
-- biggest_picker_4 port map changed.
--
-- Revision 1.3  2002/09/18 15:26:48  Dr.J
-- CCK 5.5 debugged
--
-- Revision 1.2  2002/06/14 06:19:01  Dr.F
-- added support of CCK 5.5Mb/s rate.
--
-- Revision 1.1  2002/06/10 09:18:56  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

--library biggest_picker_rtl;
library work;
--use biggest_picker_rtl.biggest_picker_pkg.all;
use work.biggest_picker_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity biggest_picker is
  generic (
    data_length_g : integer := 16            -- Number of bits for data I/O ports.
  );
  port (
          reset_n     : in  std_logic;
          clk         : in  std_logic;
          start_picker: in  std_logic;
          cck_rate    : in  std_logic; -- CCK rate. 0: 5.5Mb/s ; 1: 11Mb/s
          input0_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input0_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input1_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input1_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input2_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input2_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input3_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input3_im   : in  std_logic_vector (data_length_g-1 downto 0);

          output_re   : out std_logic_vector (data_length_g-1 downto 0);--R part of out.
          output_im   : out std_logic_vector (data_length_g-1 downto 0);--Im part of out.
          index       : out std_logic_vector (5 downto 0);
          valid_symbol: out std_logic
  );        
end biggest_picker;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of biggest_picker is

  --------------------------------------------
  -- Signals
  --------------------------------------------

  -- absolute values of each input
--   signal input0_re_abs   : std_logic_vector(data_length_g-1 downto 0);
--   signal input0_im_abs   : std_logic_vector(data_length_g-1 downto 0);
--   signal input1_re_abs   : std_logic_vector(data_length_g-1 downto 0);
--   signal input1_im_abs   : std_logic_vector(data_length_g-1 downto 0);
--   signal input2_re_abs   : std_logic_vector(data_length_g-1 downto 0);
--   signal input2_im_abs   : std_logic_vector(data_length_g-1 downto 0);
--   signal input3_re_abs   : std_logic_vector(data_length_g-1 downto 0);
--   signal input3_im_abs   : std_logic_vector(data_length_g-1 downto 0);
  
  -- inputs of the biggest_picker_4
  signal input0_re_big4  : std_logic_vector(data_length_g-1 downto 0);
  signal input0_im_big4  : std_logic_vector(data_length_g-1 downto 0);
  signal input1_re_big4  : std_logic_vector(data_length_g-1 downto 0);
  signal input1_im_big4  : std_logic_vector(data_length_g-1 downto 0);
  signal input2_re_big4  : std_logic_vector(data_length_g-1 downto 0);
  signal input2_im_big4  : std_logic_vector(data_length_g-1 downto 0);
  signal input3_re_big4  : std_logic_vector(data_length_g-1 downto 0);
  signal input3_im_big4  : std_logic_vector(data_length_g-1 downto 0);
  
  -- outputs of the biggest_picker_4
  signal output_re_big4  : std_logic_vector(data_length_g-1 downto 0);
  signal output_im_big4  : std_logic_vector(data_length_g-1 downto 0);
  signal index_big4      : std_logic_vector(1 downto 0);

  -- intermediate store of complex values
  signal store0_0_re     : std_logic_vector(data_length_g-1 downto 0);
  signal store0_0_im     : std_logic_vector(data_length_g-1 downto 0);
  signal store1_0_re     : std_logic_vector(data_length_g-1 downto 0);
  signal store1_0_im     : std_logic_vector(data_length_g-1 downto 0);
  signal store2_0_re     : std_logic_vector(data_length_g-1 downto 0);
  signal store2_0_im     : std_logic_vector(data_length_g-1 downto 0);
  signal store3_0_re     : std_logic_vector(data_length_g-1 downto 0);
  signal store3_0_im     : std_logic_vector(data_length_g-1 downto 0);
  signal store0_1_re     : std_logic_vector(data_length_g-1 downto 0);
  signal store0_1_im     : std_logic_vector(data_length_g-1 downto 0);
  signal store1_1_re     : std_logic_vector(data_length_g-1 downto 0);
  signal store1_1_im     : std_logic_vector(data_length_g-1 downto 0);
  signal store2_1_re     : std_logic_vector(data_length_g-1 downto 0);
  signal store2_1_im     : std_logic_vector(data_length_g-1 downto 0);
  signal store3_1_re     : std_logic_vector(data_length_g-1 downto 0);
  signal store3_1_im     : std_logic_vector(data_length_g-1 downto 0);

  -- intermediate store of indexes
  signal index0_s0       : std_logic_vector(1 downto 0); 
  signal index1_s0       : std_logic_vector(1 downto 0); 
  signal index2_s0       : std_logic_vector(1 downto 0); 
  signal index3_s0       : std_logic_vector(1 downto 0); 
  signal index0_s1       : std_logic_vector(3 downto 0); 
  signal index1_s1       : std_logic_vector(3 downto 0); 
  signal index2_s1       : std_logic_vector(3 downto 0); 
  signal index3_s1       : std_logic_vector(3 downto 0); 
    
  -- counter to sequence the state machine
  signal count_sm        : std_logic_vector(4 downto 0);
  signal count_sm_start  : std_logic;
  signal count_sm_enable : std_logic;
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  --------------------------------------------
  -- Counter that will sequence the state machine
  --------------------------------------------
  count_sm_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      count_sm <= (others => '0');
      count_sm_enable <= '0';
      count_sm_start  <= '0';
    elsif (clk'event and clk = '1') then
      if (start_picker = '1') then
        count_sm_start <= '1';
      end if;
      if (count_sm_start = '1') then
        count_sm_enable <= '1';
        count_sm_start <= '0';
      end if;
      if (count_sm_enable = '1') then
        count_sm <= count_sm + '1';
      end if;
      if (count_sm = 29) then
        count_sm_enable <= '0';
        count_sm        <= (others => '0');
      end if;
    end if;
  end process count_sm_p;
  
  
  --------------------------------------------
  -- Instanciation of biggest_picker_4 that selects
  -- the max between its 4 complex inputs.
  --------------------------------------------
  biggest_picker_4_i : biggest_picker_4
    generic map (data_length_g => data_length_g)
    port map (   
      input0_re   => input0_re_big4,           
      input0_im   => input0_im_big4,           
      input1_re   => input1_re_big4,           
      input1_im   => input1_im_big4,           
      input2_re   => input2_re_big4,           
      input2_im   => input2_im_big4,           
      input3_re   => input3_re_big4,           
      input3_im   => input3_im_big4,           

      output_re   => output_re_big4,           
      output_im   => output_im_big4,           
      index       => index_big4                
    );
              
  
  --------------------------------------------
  -- Mux of the biggest_picker_4 inputs
  --------------------------------------------
  biggest_picker_4_mux : process( count_sm, cck_rate,
                         input0_re, input0_im,
                         input1_re, input1_im,
                         input2_re, input2_im,
                         input3_re, input3_im,
                         store0_0_re, store0_0_im,
                         store1_0_re, store1_0_im,
                         store2_0_re, store2_0_im,
                         store3_0_re, store3_0_im,
                         store0_1_re, store0_1_im,
                         store1_1_re, store1_1_im,
                         store2_1_re, store2_1_im,
                         store3_1_re, store3_1_im)
  begin
    if (cck_rate = '1') then -- 11Mb/s
      case count_sm is
        when "01010" | -- 10
             "10000" | -- 16
             "10110" | -- 22
             "11100"   => -- 28
          input0_re_big4 <= store0_0_re;
          input0_im_big4 <= store0_0_im;
          input1_re_big4 <= store1_0_re;
          input1_im_big4 <= store1_0_im;
          input2_re_big4 <= store2_0_re;
          input2_im_big4 <= store2_0_im;
          input3_re_big4 <= store3_0_re;
          input3_im_big4 <= store3_0_im;
          
        when "11101" => -- 29
          input0_re_big4 <= store0_1_re;
          input0_im_big4 <= store0_1_im;
          input1_re_big4 <= store1_1_re;
          input1_im_big4 <= store1_1_im;
          input2_re_big4 <= store2_1_re;
          input2_im_big4 <= store2_1_im;
          input3_re_big4 <= store3_1_re;
          input3_im_big4 <= store3_1_im;
          
        when others =>
          input0_re_big4 <= input0_re;
          input0_im_big4 <= input0_im;
          input1_re_big4 <= input1_re;
          input1_im_big4 <= input1_im;
          input2_re_big4 <= input2_re;
          input2_im_big4 <= input2_im;
          input3_re_big4 <= input3_re;
          input3_im_big4 <= input3_im;
      end case;
    else           -- 5.5Mb/s
      input0_re_big4 <= store0_0_re;     
      input0_im_big4 <= store0_0_im;     
      input1_re_big4 <= store1_0_re;     
      input1_im_big4 <= store1_0_im;     
      input2_re_big4 <= store2_0_re;     
      input2_im_big4 <= store2_0_im;     
      input3_re_big4 <= store3_0_re;     
      input3_im_big4 <= store3_0_im;     
    end if;  
  end process biggest_picker_4_mux;
  
  
  --------------------------------------------
  -- Main state machine.
  -- As soon as 4 data are available, the biggest
  -- and its index are stored.
  --------------------------------------------
  main_sm_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      index        <= (others => '0');
      output_re    <= (others => '0');
      output_im    <= (others => '0');
      valid_symbol <= '0';
      store0_0_re  <= (others => '0');
      store0_0_im  <= (others => '0');
      store1_0_re  <= (others => '0');
      store1_0_im  <= (others => '0');
      store2_0_re  <= (others => '0');
      store2_0_im  <= (others => '0');
      store3_0_re  <= (others => '0');
      store3_0_im  <= (others => '0');
      store0_1_re  <= (others => '0');
      store0_1_im  <= (others => '0');
      store1_1_re  <= (others => '0');
      store1_1_im  <= (others => '0');
      store2_1_re  <= (others => '0');
      store2_1_im  <= (others => '0');
      store3_1_re  <= (others => '0');
      store3_1_im  <= (others => '0');
      index0_s0    <= (others => '0'); 
      index1_s0    <= (others => '0'); 
      index2_s0    <= (others => '0'); 
      index3_s0    <= (others => '0'); 
      index0_s1    <= (others => '0'); 
      index1_s1    <= (others => '0'); 
      index2_s1    <= (others => '0'); 
      index3_s1    <= (others => '0'); 
    elsif (clk'event and clk = '1') then
      valid_symbol <= '0';
      if (cck_rate = '1') then -- 11Mb/s
        case count_sm is
          when "00110" | "01100" | "10010" | "11000" => -- 6 12 18 24
            store0_0_re <= output_re_big4;
            store0_0_im <= output_im_big4;
            index0_s0    <= index_big4;
          when "00111" | "01101" | "10011" | "11001" => -- 7 13 19 25
            store1_0_re <= output_re_big4;
            store1_0_im <= output_im_big4;
            index1_s0    <= index_big4;
          when "01000" | "01110" | "10100" | "11010" => -- 8 14 20 26
            store2_0_re <= output_re_big4;
            store2_0_im <= output_im_big4;
            index2_s0    <= index_big4;
          when "01001" | "01111" | "10101" | "11011" => -- 9 15 21 27
            store3_0_re <= output_re_big4;
            store3_0_im <= output_im_big4;
            index3_s0    <= index_big4;
            
          when "01010" => -- 10
            store0_1_re <= output_re_big4;
            store0_1_im <= output_im_big4;
            index0_s1(3 downto 2) <= index_big4;
            case index_big4 is
              when "00" =>
                index0_s1(1 downto 0) <= index0_s0;
              when "01" =>
                index0_s1(1 downto 0) <= index1_s0;
              when "10" =>
                index0_s1(1 downto 0) <= index2_s0;
              when "11" =>
                index0_s1(1 downto 0) <= index3_s0;
              when others =>
                null;
            end case;
            
          when "10000" => -- 16
            store1_1_re <= output_re_big4;
            store1_1_im <= output_im_big4;
            index1_s1(3 downto 2) <= index_big4;
            case index_big4 is
              when "00" =>
                index1_s1(1 downto 0) <= index0_s0;
              when "01" =>
                index1_s1(1 downto 0) <= index1_s0;
              when "10" =>
                index1_s1(1 downto 0) <= index2_s0;
              when "11" =>
                index1_s1(1 downto 0) <= index3_s0;
              when others =>
                null;
            end case;
            
          when "10110" => -- 22
            store2_1_re <= output_re_big4;
            store2_1_im <= output_im_big4;
            index2_s1(3 downto 2) <= index_big4;
            case index_big4 is
              when "00" =>
                index2_s1(1 downto 0) <= index0_s0;
              when "01" =>
                index2_s1(1 downto 0) <= index1_s0;
              when "10" =>
                index2_s1(1 downto 0) <= index2_s0;
              when "11" =>
                index2_s1(1 downto 0) <= index3_s0;
              when others =>
                null;
            end case;

          when "11100" => -- 28
            store3_1_re <= output_re_big4;
            store3_1_im <= output_im_big4;
            index3_s1(3 downto 2) <= index_big4;
            case index_big4 is
              when "00" =>
                index3_s1(1 downto 0) <= index0_s0;
              when "01" =>
                index3_s1(1 downto 0) <= index1_s0;
              when "10" =>
                index3_s1(1 downto 0) <= index2_s0;
              when "11" =>
                index3_s1(1 downto 0) <= index3_s0;
              when others =>
                null;
            end case;
            
          when "11101" => -- 29
            output_re <= output_re_big4;
            output_im <= output_im_big4;
            index(5 downto 4) <= index_big4;
            valid_symbol <= '1';
            case index_big4 is
              when "00" =>
                index(3 downto 0) <= index0_s1;
              when "01" =>
                index(3 downto 0) <= index1_s1;
              when "10" =>
                index(3 downto 0) <= index2_s1;
              when "11" =>
                index(3 downto 0) <= index3_s1;
              when others =>
                null;
            end case;
          when others =>
            null;
        end case;
      else             -- 5.5Mb/s
        if (count_sm = 12) then
          store0_0_re <= input0_re;
          store0_0_im <= input0_im;
          store1_0_re <= input2_re;
          store1_0_im <= input2_im;
        elsif (count_sm = 24) then
          store2_0_re <= input0_re;
          store2_0_im <= input0_im;
          store3_0_re <= input2_re;
          store3_0_im <= input2_im;
        elsif (count_sm = 29) then
          output_re <= output_re_big4;
          output_im <= output_im_big4;
          -- index coding :
          --   index_big4     index
          --       00         010000  (16)
          --       01         010010  (18)
          --       10         110000  (48)
          --       11         110010  (50)
          index <= index_big4(1) & "100" & index_big4(0) & '0';
          valid_symbol <= '1';
        end if;
      end if;
    end if;
  end process main_sm_p;
  
end rtl;
