--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 2712 $
--/ $Date: 2010-05-25 14:43:52 +0200 (Tue, 25 May 2010) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : Phase Computation
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/IPs/WLAN/HW/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/postprocessing/vhdl/rtl/phase_computation.vhd $
--/
--////////////////////////////////////////////////////////////////////////////

-- From the position of the peak (0->F) determined by the peak search block :
-- * find the 3 previous B peaks and calculate angle 
-- * find the next peak CP1 and calculate angle
-- * Store the results inside xp_buffer .
-- When cp2_detected_i, then CP1 angle replace the last B calculated (if it has
-- already been calculated)


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library cordic_vect_rtl;

library postprocessing_rtl;
use work.postprocessing_pkg.all;
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity phase_computation is
  generic (
    xb_size_g      : integer := 10);-- size of xb
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk              : in  std_logic;
    reset_n          : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i           : in  std_logic;   -- initialize registers
    -- Peak Position
    peak_position_i  : in  std_logic_vector (3 downto 0);  -- position of peak mod 16
    f_position_i     : in  std_logic;   -- start to get the prev peaks
    -- Memory Interface
    mem_wr_ptr_i     : in  std_logic_vector (6 downto 0);  -- wr_ptr of shared fifo
    mem_wr_enable_i  : in  std_logic;
    --xb短训练互相关
    xb_from_mem_re_i : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb stored in mem 
    xb_from_mem_im_i : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb stored in mem
    -- CP2 info
    cp2_detected_i   : in  std_logic; -- high (and remain high when cp2 is detected
    -- xc1 calculated
    xc1_data_valid_i : in  std_logic;
    --cp1互相关
    xc1_re_i         : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb dir calculated
    xc1_im_i         : in  std_logic_vector (xb_size_g-1 downto 0);  -- xb dir calculated
    --
    -- XP Buffer
    xp_valid_o       : out std_logic;
    xp_buf0_o        : out std_logic_vector (xb_size_g+2 downto 0);  
    xp_buf1_o        : out std_logic_vector (xb_size_g+2 downto 0);  
    xp_buf2_o        : out std_logic_vector (xb_size_g+2 downto 0);   
    xp_buf3_o        : out std_logic_vector (xb_size_g+2 downto 0);
    nb_xp_to_take_o  : out std_logic; -- '0' for 3 and '1' for 4
    -- Memory Rd Pointer
    read_enable_o    : out std_logic;
    mem_rd_ptr_o      : out std_logic_vector (6 downto 0)  -- rd_ptr of shared fifo
    
  );

end phase_computation;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of phase_computation is
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant PEAK_INTERVAL_CT : std_logic_vector(4 downto 0) := "10000"; -- 16
  constant CORDIC_MAX_CT    : integer:= 2 ** (xb_size_g-1)-1; 
  constant CORDIC_MIN_CT    : integer:= -(2 ** (xb_size_g-1));
  constant PI_CT            : std_logic_vector (xb_size_g+2 downto 0) := "1000000000000";
  
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  -- SM
  type GET_CORDIC_TYPE  is (idle,            -- wait for a f_position
                           calc_cp1_cordic,  -- calculate cordic for CP1
                           calc_b_cordic,    -- calculate cordic for B
                           wait_for_init);   -- wait for new reception
  -- For XP Buffer array
  type ARRAY4OFSLV_TYPE is array (0 to 2) of std_logic_vector(xb_size_g+3-1 downto 0);
  -- Angle Type
  type ANGLE_TYPE       is (bet_pi2_mpi2,           -- between pi/2 and -pi/2
                            bet_mpi2_pi2);          -- between -pi/2 and pi/2
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Count Peak SM
  signal nb_b_count_max        : std_logic_vector(1 downto 0);  -- store nb of peak to calc
  -- Get Cordic SM
  signal get_cordic_cur_state  : GET_CORDIC_TYPE;
  signal get_cordic_next_state : GET_CORDIC_TYPE;
  signal nb_b_count            : std_logic_vector(1 downto 0);  -- nb of peak already calc
  signal nb_b_count_plus1      : std_logic_vector(2 downto 0);  -- nb of peak already calc
  signal max_nb_reached        : std_logic;
  -- Memory access prev peak
  signal mem_ptr_prev_peak     : std_logic_vector (6 downto 0);
  -- Cordic Control
  signal cordic_re_in          : std_logic_vector(xb_size_g-1 downto 0);  -- cordic in
  signal cordic_im_in          : std_logic_vector(xb_size_g-1 downto 0);  -- cordic in
  signal cordic_re_in_const    : std_logic_vector(xb_size_g-1 downto 0);  -- cordic in(bet -pi/2 , pi/2)
  signal cordic_im_in_const    : std_logic_vector(xb_size_g-1 downto 0);  -- cordic in(bet -pi/2 , pi/2)
  signal cordic_load           : std_logic;  -- load value for cordic calc
  signal res_angle             : std_logic_vector(xb_size_g+2-1 downto 0);
  signal res_angle_large       : std_logic_vector(xb_size_g+3-1 downto 0);
  signal cordic_ready          : std_logic;  -- cordic indicate that the res is valid
  signal cp1_angle_reg         : std_logic_vector(xb_size_g+3-1 downto 0);
  signal cordic_angle_type     : ANGLE_TYPE;  -- type of angle loaded in design
  -- XP Buffer
  signal xp_buffer             : ARRAY4OFSLV_TYPE;
  -- Memorized xc1
  signal xc1_re_reg            : std_logic_vector (xb_size_g-1 downto 0);  -- xb dir calculated
  signal xc1_im_reg            : std_logic_vector (xb_size_g-1 downto 0);  -- xb dir calculated

  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- Get Cordic SM
  -----------------------------------------------------------------------------
  get_cordic_sm_p: process (cordic_ready, cp2_detected_i, f_position_i,
                            get_cordic_cur_state, nb_b_count, nb_b_count_max)
  begin  -- process get_cordic_sm_p
    case get_cordic_cur_state is
      when idle =>
        if cp2_detected_i = '1' then
          -- cp2 has been detected (and cp1 already calc)
          get_cordic_next_state <= wait_for_init;  
        --如果峰值检测有效，检测cp1相位
        elsif f_position_i = '1' then
          get_cordic_next_state <= calc_cp1_cordic;
        else
          get_cordic_next_state <= idle;
        end if;
        
      --cp1相位检测
      when calc_cp1_cordic =>
        if cordic_ready = '1' then -- CP1 calc is done
          -- time to calc B
          if nb_b_count_max = "00" then -- first time - no B to calc
            get_cordic_next_state <= idle;
          else
            get_cordic_next_state <= calc_b_cordic;
          end if;
        else
          get_cordic_next_state <= calc_cp1_cordic;
        end if;
      --xb相位检测
      when calc_b_cordic =>
        if cordic_ready = '1' and nb_b_count = "01" then
          if cp2_detected_i = '1' then
            -- cp2 has been detected and all B are calculated
            get_cordic_next_state <= wait_for_init;
          else
            get_cordic_next_state <= idle;
          end if;
        else
          get_cordic_next_state <= calc_b_cordic;
        end if;
        
      when wait_for_init =>
        get_cordic_next_state <= wait_for_init;
      
      when others => 
        get_cordic_next_state <= idle;
    end case;
  end process get_cordic_sm_p;

  -- Sequential Part
  get_cordic_sm_seq_p: process (clk, reset_n)
  begin  -- process get_cordic_sm_seq_p
    if reset_n = '0' then               
      get_cordic_cur_state <= idle;
    elsif clk'event and clk = '1' then  
      if init_i = '1' then
        get_cordic_cur_state <= idle;
      else
        get_cordic_cur_state <= get_cordic_next_state;
      end if;
    end if;
  end process get_cordic_sm_seq_p;

  -----------------------------------------------------------------------------
  -- Address of the prev peak calculation
  -----------------------------------------------------------------------------
  address_calc_p: process (clk, reset_n)
  begin  -- process address_calc_p
    if reset_n = '0' then               
      mem_ptr_prev_peak <= (others => '0');
    elsif clk'event and clk = '1' then  
      if  (cordic_load = '1' and get_cordic_cur_state = calc_cp1_cordic) then
        -- store 1st addr  (start with the oldest B)
        mem_ptr_prev_peak <= (mem_wr_ptr_i(6 downto 4) & peak_position_i)
                             - (((nb_b_count_plus1)&"0000"));
      elsif (cordic_load = '1' and get_cordic_cur_state = calc_b_cordic) then
        -- next add
        mem_ptr_prev_peak <= mem_ptr_prev_peak + "10000";
      end if;
    end if;
  end process address_calc_p;

  mem_rd_ptr_o <= mem_ptr_prev_peak;
  nb_b_count_plus1 <= ('0' & nb_b_count) + '1';

  -----------------------------------------------------------------------------
  -- Read Enable Generation
  -----------------------------------------------------------------------------
  -- The read_enable should remain high until the end of the calc_b_cordic state
  -- (when old XBs are searched).
  read_enable_p: process (clk, reset_n)
  begin  -- process read_enable_p
    if reset_n = '0' then               
      read_enable_o <= '0';
    elsif clk'event and clk = '1' then  
      if get_cordic_next_state = calc_b_cordic then
        read_enable_o <= '1';
      else
        read_enable_o <= '0';
      end if;
    end if;
  end process read_enable_p;        
  
  -----------------------------------------------------------------------------
  --  Counters
  -----------------------------------------------------------------------------
  -- nb_b_count_max is defined by the number of B already calc (first time is 0,
  -- then 1,2,3, and then the value is fixed to 3) = That will be the nb of B to
  -- calc.
  pc_counter_p: process (clk, reset_n)
   begin  -- process pc_counter_p
     if reset_n = '0' then             
       nb_b_count_max <= (others => '0');
       nb_b_count     <= (others => '0');
       max_nb_reached <= '0';
     elsif clk'event and clk = '1' then  
       -- *** nb_b_count_max counter ***
       if init_i = '1' then
         max_nb_reached <= '0';
         nb_b_count_max <= "00"; -- 0 B to calc on first time (only CP1)
       elsif (get_cordic_cur_state  = calc_b_cordic or get_cordic_cur_state  = calc_cp1_cordic)
         and (get_cordic_next_state = idle or get_cordic_next_state = wait_for_init) then
         if nb_b_count_max /= "11" then
           -- new turn => increment nb_b_count_max (except when it has reached
           -- the max value)
           nb_b_count_max <= nb_b_count_max + '1';
         else
           max_nb_reached <= '1'; -- there are 4 XP available 
         end if;
       end if;
       
       -- *** nb_b_count counter ***
       if get_cordic_next_state = idle then
         nb_b_count     <= (others => '0');
       elsif f_position_i = '1' then
         nb_b_count <= nb_b_count_max;   -- get max value
       elsif  cordic_ready = '1' and get_cordic_cur_state = calc_b_cordic then
         nb_b_count <= nb_b_count - '1'; -- the decrement
       end if;
     end if;
   end process pc_counter_p;

   -- Set the nb to take by the coarse freq estim, +1 for the CP1 alway calculated
   -- but -1 because of the automatic update.
   -- Only 2 values are possible = 3 or 4 ...  => '0' for 3 and '1' for 4
   nb_xp_to_take_o <= '0' when  max_nb_reached = '0' -- 3
                      else '1'; -- 4
     
  -----------------------------------------------------------------------------
  -- Peak Cordic Instantiation
  -----------------------------------------------------------------------------
  -- memorize xc1 when it comes
  memo_c1_p: process (clk, reset_n)
  begin  -- process memo_c1_p
    if reset_n = '0' then              
      xc1_re_reg <= (others => '0');
      xc1_im_reg <= (others => '0');
    elsif clk'event and clk = '1' then  
      if xc1_data_valid_i = '1' then
        xc1_re_reg <= xc1_re_i;
        xc1_im_reg <= xc1_im_i;
      end if;
    end if;
  end process memo_c1_p;

  
  -- Select the input according to what you want to calc :CP1 or B
  with get_cordic_cur_state select
    cordic_re_in <=
    xc1_re_reg      when calc_cp1_cordic,
    xb_from_mem_re_i when others;

  with get_cordic_cur_state select
    cordic_im_in <=
    xc1_im_reg       when calc_cp1_cordic,
    xb_from_mem_im_i when others;

  -------------------------------
   -- Control Signals
  -------------------------------
   cordic_ctrl_p: process (clk, reset_n)
   begin  -- process cordic_ctrl_p
     if reset_n = '0' then              
       cordic_load <= '0';
     elsif clk'event and clk = '1' then  
       cordic_load <= '0';       
       if (cordic_ready = '1' and get_cordic_next_state /= wait_for_init
                              and get_cordic_next_state /= idle)
       or (get_cordic_cur_state = idle and get_cordic_next_state = calc_cp1_cordic) then
         -- new cordic calc = when the prev is finished or when start (but no
         -- need further calc when calc are finished (wait_for_init state)
         cordic_load <= '1';
       end if;
     end if;
   end process cordic_ctrl_p;

  -------------------------------
  -- Cordic calculate only between -Pi/2 and Pi/2
  -- move inputs inside this half-circle
  -------------------------------

  -- If Re < 0 => -Re , -Im
  -- As inversing CORDIC_MIN_CT is impossible (then set the max CORDIC_MAX_CT,
  -- which is (-CORDIC_MIN_CT - 1))
  cordic_re_in_const <= std_logic_vector(conv_signed(CORDIC_MAX_CT,xb_size_g))
                          when signed(cordic_re_in) = CORDIC_MIN_CT else
                      - signed(cordic_re_in)  when cordic_re_in(cordic_re_in'high) = '1'  
                 else
                      cordic_re_in;

   
  cordic_im_in_const <= std_logic_vector(conv_signed(CORDIC_MAX_CT,xb_size_g))
                          when signed(cordic_im_in) = CORDIC_MIN_CT
                               and cordic_re_in(cordic_re_in'high) = '1' else
                      - signed(cordic_im_in)  when cordic_re_in(cordic_re_in'high) = '1' 
                 else
                      cordic_im_in;
   
  
  cordic_vect_1: cordic_vect
    generic map (
      datasize_g  => xb_size_g,    -- 10
      errorsize_g => xb_size_g+2,  -- 12 
      scaling_g   => 1) -- scaling is needed (-pi/2,pi/2) =^= (1000...,011111)
    port map (
      clk          => clk,
      reset_n      => reset_n,
      load         => cordic_load,
      x_in         => cordic_re_in_const,
      y_in         => cordic_im_in_const,
      angle_out    => res_angle,
      cordic_ready => cordic_ready);


  -------------------------------   
  -- Memorize and Recover real angle if it has been modified before the CORDIC
  -------------------------------
  -- Memorize angle type
  update_angle_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      cordic_angle_type <= bet_mpi2_pi2;
    elsif clk'event and clk = '1' then
      if cordic_load = '1' then
        if cordic_re_in(cordic_re_in'high) = '1' then
          -- between pi/2 and 3pi/2
          cordic_angle_type <= bet_pi2_mpi2;          
        else
          -- between 3pi/2 and pi/2 : no change needed
          cordic_angle_type <= bet_mpi2_pi2;
        end if;
      end if;
    end if;
  end process update_angle_p;

  -- Recover angle type
  with cordic_angle_type select
    res_angle_large <= 
      sxt(res_angle,xb_size_g+3) + PI_CT when bet_pi2_mpi2,
      sxt(res_angle,xb_size_g+3) when others; --bet_3pi2_pi2

  ----------------------------------------------------------------------------
  -- Memory Storage
  ----------------------------------------------------------------------------
  -- Register the calculated angles.
  --  ______     ______     ______      ______      ______          
  -- |      |   |      |   |      |    |  B1  |    |  B2  |
  -- |      |   |      |   |  B1  |    |  B2  |    |  B3  |
  -- |_____ |   |__B1__|   |__B2__|    |__B3__|    |__B4__|
  --                                               
  -- nb_b = 0   nb_b = 1   nb_b = 2    nb_b = 3    nb_b = 3
  --
  -- First the buffer is shift (during calc_cp1_cordic), then data
  -- are written at the right place

  -- At any time, a tdone can cp2_detected can happen, which mean that the last
  -- cp1 calculated is the good one . If calc not finished, then wait for finishing.
  --      ______      ______          
  --     |  B2  |    |  B2  |
  --     |  B3  |    |  B3  |
  --     |__B4_ |    |  B4  |
  --              => |__CP1_| 
  
  mem_store_p : process (clk, reset_n)
  begin  -- process mem_store_p
    if reset_n = '0' then               
      xp_buffer       <= (others => (others => '0'));
      xp_valid_o      <= '0';
      cp1_angle_reg   <= (others => '0');
    elsif clk'event and clk = '1' then 
      xp_valid_o      <= '0';
      if init_i = '1' then
        xp_buffer <= (others => (others => '0'));
      else

        -- *** Store cp1_reg ***
        if get_cordic_cur_state = calc_cp1_cordic and cordic_ready = '1' then
          cp1_angle_reg <= res_angle_large;
        end if;

        -- *** all XB are calculated => XP = ready ***
        if get_cordic_next_state = wait_for_init
          and get_cordic_cur_state /= wait_for_init then
          xp_valid_o <= '1';
        end if;

        if get_cordic_cur_state = calc_b_cordic and cordic_ready = '1' then
          -- store angle result of XB
          xp_buffer(0) <= res_angle_large;
          for i in 0 to 1 loop          -- shift the older Bs
            xp_buffer(i+1) <= xp_buffer(i);
          end loop;  -- i          
        end if;
      end if;
    end if;
  end process mem_store_p;

  -----------------------------------------------------------------------------
  -- XP_Buffer output linking
  -----------------------------------------------------------------------------
  xp_buf0_o <= cp1_angle_reg;  -- CP1
  xp_buf1_o <= xp_buffer(0);   -- B3
  xp_buf2_o <= xp_buffer(1);   -- B2
  xp_buf3_o <= xp_buffer(2);   -- B1 

  
end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

