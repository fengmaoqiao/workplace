--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 19119 $
--/ $Date: 2011-12-06 11:48:21 +0100 (Tue, 06 Dec 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : SerialIF programs the registers in radio through 3 wire 
--/                    serial interface.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/radioctrl_maxair/vhdl/rtl/serialif.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------
-- -----------Library -------------
--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--------------------------------------------------
-- Entity
--------------------------------------------------

entity serialif is
  port (
    -------------------------------------------
    -- General
    -------------------------------------------
    nhrdrst                 : in std_logic;   -- hard reset synchronized to bbclk
    clk                     : in std_logic;   -- 60 MHz clock

    --------------------------------------------
    -- input declaration 
    --------------------------------------------

    cntrlwd                 : in std_logic_vector(31 downto 0);   --  data and reg address
    
    numcbits                : in std_logic_vector(5 downto 0);   
    ratio                   : in std_logic_vector(11 downto 0);   --  clk60 to serialclk ratio
    rfconfig                : in std_logic;   -- Radio config: 0->maxim;1->airoha
    rfinit_en               : in std_logic;   -- Radio init enable
    pgmchanp                : in std_logic;   
    channum                 : in std_logic_vector(7 downto 0);   
    modeg                   : in std_logic;   
    shutdownstate           : in std_logic;   -- radio's shutdown state
    pgmregp                 : in std_logic;
    calibregp               : in std_logic;   -- pulse io initiate calibration register programming

    --------------------------------------------
    -- output declaration 
    --------------------------------------------
    calibon                 : out std_logic;   -- indicates calibration is on or off

    serialclk               : out std_logic;   
    serialdata              : out std_logic;   
    le                      : out std_logic;   
    wrdonep                 : out std_logic;   
    pgmon                   : out std_logic;   
    chanpgmdonep            : out std_logic
    );
    
end serialif;

----------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------

architecture RTL of serialif is

   -----------------------------------------------
   -- Constants declaration for Maxim RF
   -----------------------------------------------
   constant  DEF_CNT_MAXIM         :  std_logic_vector(4 downto 0) := "10000"; -- 16 registers in Maxim
   constant  DEF_CHAN_CNT_MAXIM    :  std_logic_vector(1 downto 0) := "10";

   -- 11g mode
   constant  DEF_VAL0_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000000111010000000000";
   constant  DEF_VAL1_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000010001100110100001";
   -- writing d9 bit of a3:a0=0001 to 0
   constant  DEF_VAL2_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000010000000000110010";
   constant  DEF_VAL3_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000000000011110010011";
   -- integer divider register
   constant  DEF_VAL4_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000110110011001100100";
   -- fractional divider register
   constant  DEF_VAL5_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000000000101001000101";
   -- band select and pll register
   constant  DEF_VAL6_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000000000011000000110";
   constant  DEF_VAL7_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000010000001000100111";
   constant  DEF_VAL8_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000100000001000011000";
   constant  DEF_VAL9_MAXIM        :  std_logic_vector(31 downto 0) := "00000000000000000011101101011001";
   constant  DEF_VAL10_MAXIM       :  std_logic_vector(31 downto 0) := "00000000000000011101101001001010";
   constant  DEF_VAL11_MAXIM       :  std_logic_vector(31 downto 0) := "00000000000000000000011111111011";
   constant  DEF_VAL12_MAXIM       :  std_logic_vector(31 downto 0) := "00000000000000000001010000001100";
   constant  DEF_VAL13_MAXIM       :  std_logic_vector(31 downto 0) := "00000000000000001110100100101101";
   constant  DEF_VAL14_MAXIM       :  std_logic_vector(31 downto 0) := "00000000000000000011001110111110";
   constant  DEF_VAL15_MAXIM       :  std_logic_vector(31 downto 0) := "00000000000000001101010001011111";
   
   -----------------------------------------------
   -- Constants declaration for Airoha RF
   -----------------------------------------------
   constant  DEF_CNT_AIROHA        :  std_logic_vector(4 downto 0) := "01111"; -- 15 registers in Airoha
   constant  DEF_CHAN_CNT_AIROHA   :  std_logic_vector(1 downto 0) := "10";
   constant  DEF_CALIB_CNT_AIROHA  :  std_logic_vector(1 downto 0) := "11";    -- calibration count
    
   -- default register settings for rfvcc voltage 2.8v +/-0.1v for ref osc 40 mhz
   -- integer divider register 
   constant  DEF_VAL0_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000000111111011110010000";
   -- fractional divider register  
   constant  DEF_VAL1_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000000110011001100110001";
   constant  DEF_VAL2_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000000001011100000000010";
   constant  DEF_VAL3_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000000001110011111110011"; 
   constant  DEF_VAL4_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000010010000010110100100";
   constant  DEF_VAL5_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000011110100110111000101";
   constant  DEF_VAL6_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000010000000010110110110";
   constant  DEF_VAL7_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000000010001011011000111";
   constant  DEF_VAL8_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000001011011011010001000";
   constant  DEF_VAL9_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000001010100001110111001";
   constant  DEF_VAL10_AIROHA      :  std_logic_vector(31 downto 0) := "00000000000000000001101110111010";
   constant  DEF_VAL11_AIROHA      :  std_logic_vector(31 downto 0) := "00000000000000000000111110011011";
   constant  DEF_VAL12_AIROHA      :  std_logic_vector(31 downto 0) := "00000000000000111000110110001100";
   constant  DEF_VAL13_AIROHA      :  std_logic_vector(31 downto 0) := "00000000000010000000000000001101";
   constant  DEF_VAL14_AIROHA      :  std_logic_vector(31 downto 0) := "00000000000000000101100001111111";

   -- calibration register values
   constant  CAL_VAL1_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000000001101100001111111";
   constant  CAL_VAL2_AIROHA       :  std_logic_vector(31 downto 0) := "00000000000000000111100001111111";

   -----------------------------------------------
   -- fsm 
   -----------------------------------------------
   constant  IDLE                  :  std_logic_vector(1 downto 0) := "00";    
   constant  WRITE                 :  std_logic_vector(1 downto 0) := "01";    
   constant  TRANS_OVER            :  std_logic_vector(1 downto 0) := "10";    
   constant  WAIT_FOR_INACTIVE     :  std_logic_vector(1 downto 0) := "11";    

   -----------------------------------------------
   -- Signal declaration
   -----------------------------------------------
   signal serialifcs               :  std_logic_vector(1 downto 0);   
   signal serialifns               :  std_logic_vector(1 downto 0);   
   signal clkcnt                   :  std_logic_vector(11 downto 0);   
   signal bitcnt                   :  std_logic_vector(5 downto 0);   
   signal intcnt                   :  std_logic_vector(1 downto 0);   
   signal chancnt                  :  std_logic_vector(1 downto 0);   
   signal newwrpreg                :  std_logic;   
   signal calwrpreg                :  std_logic;    
   signal wrintp                   :  std_logic;   
   signal lereg                    :  std_logic;   
   signal leset                    :  std_logic;   
   signal enableserialclk          :  std_logic;   
   signal regpgmdonep              :  std_logic;   
   signal radiodefcnt              :  std_logic_vector(4 downto 0);   
   signal radiocalcnt              :  std_logic_vector(1 downto 0);
   signal cntrlwdreg               :  std_logic_vector(31 downto 0);   
   signal defwrp                   :  std_logic;   
   signal calwrp                   :  std_logic;  
   signal rstoccured               :  std_logic_vector(2 downto 0);   
   signal pgmchanreg               :  std_logic;   
   signal chanpgmp                 :  std_logic;   
   signal channumreg               :  std_logic_vector(7 downto 0);   
   signal pgmchanintpreg           :  std_logic;   
   signal modegd1                  :  std_logic;   
   signal modegd2                  :  std_logic;   
   signal modegp                   :  std_logic;   
   signal shutdownstated           :  std_logic;   
   signal pgmchanintp              :  std_logic;   
   signal inactiveedge             :  std_logic;   
   signal modegpint                :  std_logic;   
   signal inactivedge              :  std_logic;   
   signal shutdownstatep           :  std_logic;   
   signal serialclk_xhdl1          :  std_logic;
   signal serialdata_xhdl2         :  std_logic;
   signal le_xhdl3                 :  std_logic;
   signal wrdonep_xhdl4            :  std_logic;
   signal pgmon_xhdl5              :  std_logic;
   signal calibon_xhdl5            :  std_logic;   
   signal chanpgmdonep_xhdl6       :  std_logic;
   signal temp1                    :  std_logic;
   signal temp2                    :  std_logic;
   signal temp3                    :  std_logic;
   signal temp4                    :  std_logic;
   signal temp5                    :  std_logic;
   signal temp6                    :  std_logic;
   signal temp7                    :  std_logic;
   signal temp8                    :  std_logic;
   signal temp9                    :  std_logic;
   signal temp10                   :  std_logic;
   signal temp11                   :  std_logic;
   signal temp12                   :  std_logic;
   signal temp13                   :  std_logic;
   signal temp14                   :  std_logic;
   signal temp15                   :  std_logic;
   signal temp16                   :  std_logic;
   signal temp17                   :  std_logic;
   signal temp18                   :  std_logic;
   signal temp19                   :  std_logic;
   signal temp20                   :  std_logic;
   signal temp21                   :  std_logic;   
   signal temp22                   :  std_logic;    

  -- function to convert to integer from std_logic
  function to_integer(arg: std_logic_vector; size: integer) return integer is
 
        variable temp : std_logic_vector (size-1 downto 0);
        variable result : integer := 0;
        --signal i : integer;
  begin
        temp := arg;
        for i in 0 to size-1 loop
                if (temp(i)) = '1' then
                        result := result + (1*(2**i));
                else
                        result := result + (0*(2**i));
                end if;
        end loop;
        return result;
  end;

  ------------------------------------------------------------------------------
  -- architecture body
  ------------------------------------------------------------------------------

  begin
  
   serialclk    <= serialclk_xhdl1 or lereg;
   serialdata   <= serialdata_xhdl2;
   le           <= le_xhdl3;
   wrdonep      <= wrdonep_xhdl4;
   pgmon        <= pgmon_xhdl5;
   chanpgmdonep <= chanpgmdonep_xhdl6;
   calibon      <= calibon_xhdl5;      -- indicates whether calibration is on or off 

   -----------------------------------------------
   -- shutdown statep 
   -----------------------------------------------
   pshutdowndelayseq : process (clk, nhrdrst)
   begin
      if (nhrdrst = '0') then
         shutdownstated <= '0';    
      elsif (clk'event and clk = '1') then
         shutdownstated <= shutdownstate;    
      end if;
   end process pshutdowndelayseq;
   shutdownstatep <= '1' when ((shutdownstate = '1') and (shutdownstated = '0')) else '0' ;

   -----------------------------------------------
   -- temp signals
   -----------------------------------------------
   temp1 <= '1' when (chancnt > "01") else '0';
   temp2 <= '1' when (chancnt /= "00") else '0';
   temp3 <= '1' when (radiodefcnt = "00000") else '0';
   temp4 <= '1' when (chancnt = "00") else '0';
   temp5 <= '1' when (clkcnt = "000000000000") else '0';
   temp6 <= '1' when (intcnt = "00") else '0';
   temp7 <= '1' when (bitcnt = (numcbits - "000001")) else '0';
   temp8 <= '1' when (serialifcs = IDLE) else '0';
   temp9 <= '1' when (serialifcs /= WAIT_FOR_INACTIVE) else '0';
   temp10 <= '1' when (serialifcs = WRITE) else '0';
   temp11 <= '1' when (serialifcs = TRANS_OVER) else '0';
   temp12 <= '1' when (serialifcs /= TRANS_OVER) else '0';
   temp13 <= '1' when (serialifcs = WAIT_FOR_INACTIVE) else '0';
   temp14 <= '1' when (serialifcs /= IDLE) else '0';
   temp15 <= '1' when (radiodefcnt /= "00000") else '0';
   temp16 <= '1' when (intcnt /= "00") else '0';
   temp17 <= '1' when (chancnt = "01") else '0';
   temp18 <= '1' when (clkcnt(11 downto 0) = ratio - "000000000001") else '0';
   temp19 <= '1' when (clkcnt(10 downto 0) = ratio(11 downto 1) - "00000000001") else '0';
   temp20 <= '1' when (clkcnt(10 downto 0) = ratio(11 downto 1)) else '0';
   temp21 <= '1' when (radiocalcnt /= "00" ) else '0';   
   temp22 <= '1' when (radiocalcnt = "00" ) else '0';    

   -----------------------------------------------
   -- wrintp generation 
   -----------------------------------------------
   -- generating newwrpreg and wrintp
   -- whenever the state machine is in idle state
   -- newwrpreg registers value of newwrp
   -- this is to avoid wrong behavior if a write is already going on and one
   -- more newwrp is generated by radiocntrl register.
   -- this happens if mac writes into rcwrdata register without reading 
   -- the status of register in radiocntrl register.
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         newwrpreg <= '0';    
         wrintp <= '0';    
      elsif (clk'event and clk = '1') then
        if ((temp8 and temp3 and temp4 and ((not rfconfig) or (rfconfig and temp22))) = '1') then
          newwrpreg <= pgmregp;    
          if ((newwrpreg and not pgmregp) = '1') then
            wrintp <= '1';    
          else
            wrintp <= '0';    
          end if;
        else
          newwrpreg <= '0';    
          wrintp <= '0';    
        end if;
      end if;
   end process;

   -----------------------------------------------
   -- serialif ns 
   -----------------------------------------------
   process (serialifcs, wrintp, calwrp, defwrp, chanpgmp, inactiveedge, temp7,
   modegp, rfconfig)
      variable serialifns_xhdl7  : std_logic_vector(1 downto 0);
   begin
      case serialifcs is
        
         when IDLE =>
                  if ((wrintp or defwrp or chanpgmp or modegp or (calwrp and rfconfig)) = '1') then
                     serialifns_xhdl7 := WAIT_FOR_INACTIVE; 
                  else
                     serialifns_xhdl7 := IDLE;    
                  end if;
         
         when WAIT_FOR_INACTIVE =>
                  if (inactiveedge = '1') then
                     serialifns_xhdl7 := WRITE;    
                  else
                     serialifns_xhdl7 := WAIT_FOR_INACTIVE; 
                  end if;
         
         when WRITE =>
                  if ((inactiveedge and temp7) = '1') 
                  then
                     serialifns_xhdl7 := TRANS_OVER; 
                  else
                     serialifns_xhdl7 := WRITE;    
                  end if;
        
         when TRANS_OVER =>
                  if (inactiveedge = '1') then
                     serialifns_xhdl7 := IDLE;    
                  else
                     serialifns_xhdl7 := TRANS_OVER; 
                  end if;
        
         when others  =>
                  serialifns_xhdl7 := IDLE;    
         
      end case;
      serialifns <= serialifns_xhdl7;
   end process;

   -----------------------------------------------
   -- serialifcs 
   -----------------------------------------------
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         serialifcs <= IDLE;    
      elsif (clk'event and clk = '1') then
         serialifcs <= serialifns;    
      end if;
   end process;

   -----------------------------------------------
   -- bitcnt 
   -----------------------------------------------
   -- this is to keep a record of number bits clocked out
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         bitcnt <= "000000";    
      elsif (clk'event and clk = '1') then
         if (not lereg = '1') then
            if ((inactiveedge and temp9) = '1') then 
               bitcnt <= bitcnt + "000001";    
            else
               bitcnt <= bitcnt;    
            end if;
         else
            bitcnt <= "000000";    
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- channumreg 
   -----------------------------------------------
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         channumreg <= "00101000";    
      elsif (clk'event and clk = '1') then
         if ((pgmchanp and temp4) = '1') then
            channumreg <= channum;    
         else
            channumreg <= channumreg;    
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- cntrlwdreg 
   -----------------------------------------------
   -- whenever a new write by radiocntrl register or default write after hard reset is issued
   -- cntrlwd registers the new value to be written in the radio register
   -- it keeps shifting left when the write procedure is going on
   -- priorities of wrintp, defwrp and chanpgmp
   -- the highest priority is given to defwrp, such 8 pulses would be generated
   -- after hard reset. the next priority goes to calwrp. 3 calwrp would be
   -- generated to complete the power on calibration procedure for airoha radio.
   -- the next priority goes to chanpgmp. 2 chanpgmp would be
   -- generated for each channel programmed. the lowest priority is given to wrintp
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         cntrlwdreg <= (others => '0');
      elsif (clk'event and clk = '1') then
         if ((defwrp and modeg) = '1') then
            if rfconfig = '1' then
              case radiodefcnt is
                 when "01111" =>
                          cntrlwdreg <= DEF_VAL0_AIROHA;
                 when "01110" =>
                          cntrlwdreg <= DEF_VAL1_AIROHA;
                 when "01101" =>
                          cntrlwdreg <= DEF_VAL2_AIROHA;
                 when "01100" =>
                          cntrlwdreg <= DEF_VAL3_AIROHA;
                 when "01011" =>
                          cntrlwdreg <= DEF_VAL4_AIROHA;
                 when "01010" =>
                          cntrlwdreg <= DEF_VAL5_AIROHA;
                 when "01001" =>
                          cntrlwdreg <= DEF_VAL6_AIROHA;
                 when "01000" =>
                          cntrlwdreg <= DEF_VAL7_AIROHA;
                 when "00111" =>
                          cntrlwdreg <= DEF_VAL8_AIROHA;
                 when "00110" =>
                          cntrlwdreg <= DEF_VAL9_AIROHA;
                 when "00101" =>
                          cntrlwdreg <= DEF_VAL10_AIROHA;
                 when "00100" =>
                          cntrlwdreg <= DEF_VAL11_AIROHA;
                 when "00011" =>
                          cntrlwdreg <= DEF_VAL12_AIROHA;
                 when "00010" =>
                          cntrlwdreg <= DEF_VAL13_AIROHA;
                 when "00001" =>
                          cntrlwdreg <= DEF_VAL14_AIROHA;
                 when others  =>
                          cntrlwdreg <= DEF_VAL0_AIROHA;
              end case;
            else
              case radiodefcnt is
                 when "10000" =>
                          cntrlwdreg <= DEF_VAL0_MAXIM;
                 when "01111" =>
                          cntrlwdreg <= DEF_VAL1_MAXIM;
                 when "01110" =>
                          cntrlwdreg <= DEF_VAL2_MAXIM;
                 when "01101" =>
                          cntrlwdreg <= DEF_VAL3_MAXIM;
                 when "01100" =>
                          cntrlwdreg <= DEF_VAL4_MAXIM;
                 when "01011" =>
                          cntrlwdreg <= DEF_VAL5_MAXIM;
                 when "01010" =>
                          cntrlwdreg <= DEF_VAL6_MAXIM;
                 when "01001" =>
                          cntrlwdreg <= DEF_VAL7_MAXIM;
                 when "01000" =>
                          cntrlwdreg <= DEF_VAL8_MAXIM;
                 when "00111" =>
                          cntrlwdreg <= DEF_VAL9_MAXIM;
                 when "00110" =>
                          cntrlwdreg <= DEF_VAL10_MAXIM;
                 when "00101" =>
                          cntrlwdreg <= DEF_VAL11_MAXIM;
                 when "00100" =>
                          cntrlwdreg <= DEF_VAL12_MAXIM;
                 when "00011" =>
                          cntrlwdreg <= DEF_VAL13_MAXIM;
                 when "00010" =>
                          cntrlwdreg <= DEF_VAL14_MAXIM;
                 when "00001" =>
                          cntrlwdreg <= DEF_VAL15_MAXIM;
                 when others  =>
                          cntrlwdreg <= DEF_VAL0_MAXIM;
              end case;
            end if;
         elsif (calwrp  = '1' and rfconfig = '1') then -- power on calibration
           case radiocalcnt is
              when "11" =>
                       cntrlwdreg <= CAL_VAL1_AIROHA;
              when "10" =>
                       cntrlwdreg <= CAL_VAL2_AIROHA;
              when "01" =>
                       cntrlwdreg <= DEF_VAL14_AIROHA;
              when others  =>
                       cntrlwdreg <= DEF_VAL0_AIROHA;
           end case;
         elsif ((chanpgmp and modeg) = '1') then
           -- Airoha
           if rfconfig = '1' then
             case channum is
                  -- synopsys full_case parallel_case
                  -- channel register setting for 40 mhz osc

               when "00000001" =>                                          -- 4'h0 is integer divider register
                        if (chancnt = "10") then                           -- 4'h1 is fractional divider register
                           cntrlwdreg <= ("0000000000000011111101111001" & "0000");         -- Data - 14'h3F79
                        else                                                          
                           cntrlwdreg <= ("0000000000000011001100110011" & "0001");         -- Data - 14'h3333
                        end if;
               when "00000010" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111101111001" & "0000");         -- Data - 14'h3F79
                        else
                           cntrlwdreg <= ("0000000000001011001100110011" & "0001");         -- Data - 14'hB333
                        end if;
               when "00000011" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111001111001" & "0000");         -- Data - 14'h3E79
                        else
                           cntrlwdreg <= ("0000000000000011001100110011" & "0001");         -- Data - 14'h3333
                        end if;
               when "00000100" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111001111001" & "0000");         -- Data - 14'h3E79
                        else
                           cntrlwdreg <= ("0000000000001011001100110011" & "0001");         -- Data - 14'hB333
                        end if;
               when "00000101" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111101111010" & "0000");         -- Data - 14'h3F7A
                        else
                           cntrlwdreg <= ("0000000000000011001100110011" & "0001");         -- Data - 14'h3333
                        end if;
               when "00000110" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111101111010" & "0000");         -- Data - 14'h3F7A
                        else
                           cntrlwdreg <= ("0000000000001011001100110011" & "0001");         -- Data - 14'hB333
                        end if;
               when "00000111" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111001111010" & "0000");         -- Data - 14'h3E7A
                        else
                           cntrlwdreg <= ("0000000000000011001100110011" & "0001");         -- Data - 14'h3333
                        end if;                                                                             
               when "00001000" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111001111010" & "0000");         -- Data - 14'h3E7A
                        else
                           cntrlwdreg <= ("0000000000001011001100110011" & "0001");         -- Data - 14'hB333
                        end if;
               when "00001001" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111101111011" & "0000");         -- Data - 14'h3F7B
                        else
                           cntrlwdreg <= ("0000000000000011001100110011" & "0001");         -- Data - 14'h3333
                        end if;
               when "00001010" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111101111011" & "0000");         -- Data - 14'h3F7B
                        else
                           cntrlwdreg <= ("0000000000001011001100110011" & "0001");         -- Data - 14'hB333
                        end if;
               when "00001011" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111001111011" & "0000");         -- Data - 14'h3E7B
                        else
                           cntrlwdreg <= ("0000000000000011001100110011" & "0001");         -- Data - 14'h3333
                        end if;
               when "00001100" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111001111011" & "0000");         -- Data - 14'h3E7B
                        else
                           cntrlwdreg <= ("0000000000001011001100110011" & "0001");         -- Data - 14'hB333
                        end if;
               when "00001101" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111101111100" & "0000");         -- Data - 14'h3F7C
                        else
                           cntrlwdreg <= ("0000000000000011001100110011" & "0001");         -- Data - 14'h3333
                        end if;
               when "00001110" =>
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011111001111100" & "0000");         -- Data - 14'h3F7C
                        else
                           cntrlwdreg <= ("0000000000000110011001100110" & "0001");         -- Data - 14'h6666
                        end if;
               when others =>
                        null;
               end case;
           else
           -- Maxim
             case channum is
                  -- synopsys full_case parallel_case
                  
               when "00000001" =>                                          -- 4'h3 is integer divider register
                        if (chancnt = "10") then                           -- 4'h4 is fractional divider register
                           cntrlwdreg <= ("0000000000000001101001111000" & "0011");         -- Data - 14'h1A78 
                        else                                                                
                           cntrlwdreg <= ("0000000000000010011001100110" & "0100");         -- Data - 14'h2666
                        end if;                                                             
               when "00000010" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111000" & "0011");         -- Data - 14'h1A78
                        else                                                                
                           cntrlwdreg <= ("0000000000000011011001100110" & "0100");         -- Data - 14'h3666
                        end if;                                                             
               when "00000011" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111001" & "0011");         -- Data - 14'h1A79
                        else                                                                
                           cntrlwdreg <= ("0000000000000000011001100110" & "0100");         -- Data - 14'h0666
                        end if;                                                             
               when "00000100" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111001" & "0011");         -- Data - 14'h1A79
                        else                                                                
                           cntrlwdreg <= ("0000000000000001011001100110" & "0100");         -- Data - 14'h1666
                        end if;                                                             
               when "00000101" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111001" & "0011");         -- Data - 14'h1A79
                        else                                                                
                           cntrlwdreg <= ("0000000000000010011001100110" & "0100");         -- Data - 14'h2666
                        end if;                                                             
               when "00000110" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111001" & "0011");         -- Data - 14'h1A79
                        else                                                                
                           cntrlwdreg <= ("0000000000000011011001100110" & "0100");         -- Data - 14'h3666
                        end if;                                                             
               when "00000111" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111010" & "0011");         -- Data - 14'h1A7A
                        else                                                                
                           cntrlwdreg <= ("0000000000000000011001100110" & "0100");         -- Data - 14'h0666
                        end if;                                                             
               when "00001000" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111010" & "0011");         -- Data - 14'h1A7A
                        else                                                                
                           cntrlwdreg <= ("0000000000000001011001100110" & "0100");         -- Data - 14'h1666
                        end if;                                                             
               when "00001001" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111010" & "0011");         -- Data - 14'h1A7A
                        else                                                                
                           cntrlwdreg <= ("0000000000000010011001100110" & "0100");         -- Data - 14'h2666
                        end if;                                                             
               when "00001010" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111010" & "0011");         -- Data - 14'h1A7A
                        else                                                                
                           cntrlwdreg <= ("0000000000000011011001100110" & "0100");         -- Data - 14'h3666
                        end if;                                                             
               when "00001011" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111011" & "0011");         -- Data - 14'h1A7B
                        else                                                                
                           cntrlwdreg <= ("0000000000000000011001100110" & "0100");         -- Data - 14'h0666
                        end if;                                                             
               when "00001100" =>                                                           
                        if (chancnt = "10") then                                            
                           cntrlwdreg <= ("0000000000000001101001111011" & "0011");         -- Data - 14'h1A7B
                        else                                                                
                           cntrlwdreg <= ("0000000000000001011001100110" & "0100");         -- Data - 14'h1666
                        end if;                                                            
               when "00001101" =>                                                          
                        if (chancnt = "10") then                                           
                           cntrlwdreg <= ("0000000000000001101001111011" & "0011");         -- Data - 14'h1A7B
                        else                                                                
                           cntrlwdreg <= ("0000000000000010011001100110" & "0100");         -- Data - 14'h2666
                        end if;                                                             
               when "00001110" =>                                                           
                        if (chancnt = "10") then
                           cntrlwdreg <= ("0000000000000011001101111100" & "0011");         -- Data - 14'h337C
                        else                                                                
                           cntrlwdreg <= ("0000000000000000110011001100" & "0100");         -- Data - 14'h0CCC
                        end if;
               when others =>
                        null;
               
             end case;
           end if;
         elsif (wrintp = '1') then
           cntrlwdreg <= cntrlwd;
         elsif ((temp10 and inactiveedge) = '1') then
           cntrlwdreg(31 downto 1) <= cntrlwdreg(30 downto  0);
           cntrlwdreg(0) <= '0';    
         else
           cntrlwdreg <= cntrlwdreg;    
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- enable serialclk 
   -----------------------------------------------
   -- whenever this signal is low, serialclk is activated
   -- when a new write transaction is to be done, as indicated by
   -- wrintp and defwrp, enableserialclk goes low. it goes high
   -- when the transaction is complete, i.e. when state machine resumes
   -- idle state
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         enableserialclk <= '1';    
      elsif (clk'event and clk = '1') then
         if ((wrintp or defwrp or chanpgmp or (modegp and not rfconfig) or
           (calwrp and rfconfig)) = '1') then
            enableserialclk <= '0';    
         else
            if (serialifcs = IDLE) then
               enableserialclk <= '1';    
            else
               enableserialclk <= enableserialclk;    
            end if;
         end if;
      end if;
   end process;

   -- maximum frequency of serialclk mentioned in datasheet is 50 MHz
   -- as the sysclk itself is 80mhz, we can support maximum of 20 MHz
   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
       clkcnt <= "000000000000";    
     elsif (clk'event and clk = '1') then
       if rfinit_en = '1' then
         if (clkcnt = ratio - "000000000001") then
            clkcnt <= "000000000000";    
         else
            clkcnt <= clkcnt + "000000000001";    
         end if;
       end if;
     end if;
   end process;

   inactivedge <= ((not enableserialclk) and (serialclk_xhdl1)) and temp19;  
   inactiveedge<= (not enableserialclk and inactivedge) when ((serialclk_xhdl1) and temp19) = '1'
                  else (not enableserialclk and temp18) when ((serialclk_xhdl1) and temp18) = '1'
                  else '0' ;

   -----------------------------------------------
   -- radiodef cnt 
   -----------------------------------------------
   -- on hard reset, all the radio registers are written with some default values.
   -- For Maxim, total of 16 registers are written.
   -- For Airoha, total of 15 registers are written.
   -- radiodefcnt keeps track of how many registers are still to be written
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         radiodefcnt <= DEF_CNT_MAXIM;    
      elsif (clk'event and clk = '1') then
         if (shutdownstate = '1') then
           if rfconfig = '1' then
             radiodefcnt <= DEF_CNT_AIROHA;
           else
             radiodefcnt <= DEF_CNT_MAXIM;
            end if;
         else
            if (modegp = '1' and rfconfig = '0') then
               radiodefcnt <= DEF_CNT_MAXIM;    
            else
               if ((temp15  and inactiveedge  and temp11) = '1') then
                  radiodefcnt <= radiodefcnt - "00001";    
               else
                  radiodefcnt <= radiodefcnt;    
               end if;
            end if;
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- radiocalcnt 
   -----------------------------------------------
   -- after the  registers are written with default values power 
   -- on calibration has to done by sending calibration register values 
   -- 3 times, radiocalcnt keeps track of how many calibration register 
   -- values still to be written
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         radiocalcnt <= DEF_CALIB_CNT_AIROHA;
      elsif (clk'event and clk = '1') then
         if (rfconfig = '1') then
           if (shutdownstate = '1') then
              radiocalcnt <= DEF_CALIB_CNT_AIROHA;
           else
              if ((temp3  and inactiveedge  and temp11 and temp21) = '1') then
                  radiocalcnt <= radiocalcnt - "01";
              else
                  radiocalcnt <= radiocalcnt;
              end if;
            end if;
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- rstoccured and defwrp
   -----------------------------------------------
   -- after hard reset the radio is programmed for default values
   -- for that we need a signal called rstoccured
   -- defwrp is a pulse to generate new writes on hard reset till all
   -- the radio registers are written with default values
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         defwrp <= '0';    
         rstoccured <= "001";    
      elsif (clk'event and clk = '1') then
         if (shutdownstate = '1' or rfinit_en = '0') then
            defwrp <= '0';    
            rstoccured <= "001";    
         else
            if (modegp = '1' and rfconfig = '0') then
               defwrp <= '0';    
               rstoccured <= "001";    
            else
               rstoccured(2 downto 1) <= rstoccured(1 downto 0);    
               rstoccured(0) <= '0';    
               if (rstoccured(0) = '1') then
                  defwrp <= '1';    
               else
                  if ((temp15  and regpgmdonep and temp6) = '1') then
                     defwrp <= '1';    
                  else
                     defwrp <= '0';    
                  end if;
               end if;
            end if;
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- generating calwrp
   -----------------------------------------------
   -- whenever the state machine is in idle state and txrxcntrl enters 
   -- the calib_radio state calwrp is generated from calibregp pulse. 
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         calwrpreg <= '0';
         calwrp <= '0';
      elsif (clk'event and clk = '1') then
            if (temp8  = '1') then
               calwrpreg <= calibregp;
               if ((calwrpreg and not calibregp) = '1') then
                  calwrp <= '1';
               else
                  calwrp <= '0';
               end if;
            else
               calwrpreg <= '0';
               calwrp <= '0';
            end if;
      end if;
   end process;

   -----------------------------------------------
   -- regpgmdonep 
   -----------------------------------------------
   -- this is a pulse of width 80mhz
   -- is issued when current write operation is completed
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         intcnt <= "00";    
         regpgmdonep <= '0';    
      elsif (clk'event and clk = '1') then
         if (serialifcs = TRANS_OVER) then
            intcnt <= "11";    
         else
            if (intcnt /= "00") then
               intcnt <= intcnt - "01";    
               regpgmdonep <= '1';    
            else
               intcnt <= "00";    
               regpgmdonep <= '0';    
            end if;
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- chanpgmdonep 
   -----------------------------------------------
   -- logic for chanpgmdonep is the same as of regpgmdonep
   -- except for the fact that this pulse is given when both
   -- n and r registers are programmed, which is checked thro'
   -- chancnt == 1
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         chanpgmdonep_xhdl6 <= '0';    
      elsif (clk'event and clk = '1') then
         if ((temp12 and temp16 and temp17) = '1') then
            chanpgmdonep_xhdl6 <= '1';    
         else
            chanpgmdonep_xhdl6 <= '0';    
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- lereg 
   -----------------------------------------------
   le_xhdl3 <= leset ;

   -- lereg
   -- this is latch enable signal to radio
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         lereg <= '1';    
      elsif (clk'event and clk = '1') then
         if ((temp13 and inactiveedge) = '1') then
            lereg <= '0';    
         else
            if ((temp10 and temp7  and inactiveedge) = '1') then
               lereg <= '1';    
            else
               lereg <= lereg;    
            end if;
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- leset 
   -----------------------------------------------
   -- this is latch enable signal to radio
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         leset <= '1';    
      elsif (clk'event and clk = '1') then
         if ((temp13 and inactiveedge) = '1') then
            leset <= '0';    
         else
            if (serialifcs = TRANS_OVER) then
               leset <= '1';    
            else
               leset <= leset;    
            end if;
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- serialclk 
   -----------------------------------------------
      -- clock on which the radio samples the serial data
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         serialclk_xhdl1 <= '0';    
      elsif (clk'event and clk = '1') then
         if (not ratio(0) = '1') then
            if ((clkcnt(10 downto 0) = ratio(11 downto 1) - "00000000001") or (clkcnt = ratio - "000000000001")) 
            then
               serialclk_xhdl1 <= not serialclk_xhdl1;    
            else
               serialclk_xhdl1 <= serialclk_xhdl1;    
            end if;
         else
            if ((clkcnt(10 downto 0) = ratio(11 downto 1)) or (clkcnt = ratio - "000000000001")) 
            then
               serialclk_xhdl1 <= not serialclk_xhdl1;    
            else
               serialclk_xhdl1 <= serialclk_xhdl1;    
            end if;
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- serialdata 
   -----------------------------------------------
   serialdata_xhdl2 <= cntrlwdreg(to_integer(numcbits - "000001",6)) ;

   -----------------------------------------------
   -- wrdonep 
   -----------------------------------------------
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         wrdonep_xhdl4 <= '0';    
      elsif (clk'event and clk = '1') then
         if (radiodefcnt = "00000" and chancnt = "00" and 
            (rfconfig = '0' or (rfconfig = '1' and radiocalcnt = "00"))) then
            wrdonep_xhdl4 <= regpgmdonep;    
         else
            wrdonep_xhdl4 <= '0';    
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- pgmon 
   -----------------------------------------------
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         pgmon_xhdl5 <= '1';    
      elsif (clk'event and clk = '1') then
         if (radiodefcnt /= "00000") then
            pgmon_xhdl5 <= '1';    
         else
            if (serialifcs /= IDLE) then
               pgmon_xhdl5 <= '1';    
            else
               pgmon_xhdl5 <= '0';    
            end if;
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- calibon
   -----------------------------------------------
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         calibon_xhdl5 <= '0';
      elsif (clk'event and clk = '1') then
         if (radiocalcnt /= "00" and radiodefcnt = "00000" and rfconfig = '1') then
            calibon_xhdl5 <= '1';
         else
            calibon_xhdl5 <= '0';
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- channel programming  
   -----------------------------------------------
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         pgmchanreg <= '0';    
      elsif (clk'event and clk = '1') then
         pgmchanreg <= pgmchanp;    
      end if;
   end process;
   
   pgmchanintp <= (pgmchanreg and not pgmchanp) and not pgmon_xhdl5 ;

   -- logic for programming channel 
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         chanpgmp       <= '0';    
         chancnt        <= "00";    
         pgmchanintpreg <= '0';    
      elsif (clk'event and clk = '1') then
         if (pgmchanintp = '1') then
            pgmchanintpreg <= '1';    
         else
            if ((pgmchanintpreg and temp3 and temp4 and temp5 and
               ((not rfconfig) or (rfconfig and temp22))) = '1') then
               pgmchanintpreg <= '0';    
            else
               pgmchanintpreg <= pgmchanintpreg;    
            end if;
         end if;
         if ((pgmchanintpreg and temp3 and temp4 and temp5 and
               ((not rfconfig) or (rfconfig and temp22))) = '1') then
            chanpgmp <= '1';
            if rfconfig = '1' then
              chancnt <= DEF_CHAN_CNT_AIROHA;
            else
              chancnt <= DEF_CHAN_CNT_MAXIM;
            end if;
         else
            if (chancnt /= "00") then
               if ((temp2 and regpgmdonep and temp6) = '1') then
                  chancnt <= chancnt - "01";    
               else
                  chancnt <= chancnt;    
               end if;
               if ((temp1 and regpgmdonep and temp6) = '1') then
                  chanpgmp <= '1';    
               else
                  chanpgmp <= '0';    
               end if;
            else
               chancnt  <= chancnt;    
               chanpgmp <= '0';    
            end if;
         end if;
      end if;
   end process;

   -----------------------------------------------
   -- modegp
   -----------------------------------------------
   -- logic to generate modegp to indicate that radio mode has been changed
   -- from 11a to 11g. this will initiate radio register writes to program
   -- radio to the programed mode.
   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         modegd1 <= '1';    
         modegd2 <= '1';    
      elsif (clk'event and clk = '1') then
         modegd1 <= modeg;    
         modegd2 <= modegd1;    
      end if;
   end process;
   modegpint <= '1' when (modegd1 /= modegd2) else '0' ;

   process (clk, nhrdrst)
   begin
      if (not nhrdrst = '1') then
         modegp <= '0';    
      elsif (clk'event and clk = '1') then
         modegp <= modegpint;    
      end if;
   end process;

end RTL;
   
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
