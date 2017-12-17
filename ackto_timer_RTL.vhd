--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity ackto_timer is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n             : in  std_logic; -- Reset.
    clk                 : in  std_logic; -- Clock.
    enable_1mhz         : in  std_logic; -- Enable at 1 MHz.
    mode32k             : in  std_logic; -- High in low-power mode.

    --------------------------------------
    -- Controls
    --------------------------------------
    txstart_it          : in  std_logic; -- Start of transmission pulse
    txend_it            : in  std_logic; -- End of transmission pulse
    rxstart_it          : in  std_logic; -- Start of reception pulse
    -- Control fields from tx packet control structure:
    ackto_count         : in  std_logic_vector(8 downto 0); -- Time-out value
    -- Enable ACK time-out generation
    ackto_en            : in  std_logic; -- From TX control struture
    reg_ackto_en        : in  std_logic; -- From registers
    --
    ackto_it            : out std_logic; -- Time-out pulse
    ackto_timer_on      : out std_logic  -- High while timer is running.
    
  );

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of ackto_timer is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal ackto_it_int       : std_logic; -- Internal signal for ACK time-out it.
  signal ackto_timer_on_int : std_logic; -- High while timer is counting.
  signal end_count          : std_logic; -- High when timer times out.
  signal ackto_timer        : std_logic_vector(8 downto 0); -- Timer.
  signal ackto_enable       : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- ACKTO must be enabled in the TX control struture at TX start (ackto_en) and in
  -- the BuP registers (reg_ackto_en). If it is disabled in the BuP registers, it
  -- remains disabled till next TX start. Disable form the registers has priority
  -- over enable from the control structure.
  ackto_enable_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      ackto_enable <= '0';
    elsif clk'event and clk = '1' then
      if txstart_it = '1' then
        ackto_enable <= ackto_en;
      end if;
      if reg_ackto_en = '0' then
        ackto_enable <= '0';
      end if;
    end if;
  end process ackto_enable_p;
  
  -- Assign output port.
  ackto_timer_on <= ackto_timer_on_int;
  
  -- When time-out value is zero, ackto and txend interrupt coincide.
  -- ackto_it will be registered in the bup2_intgen block.
  with ackto_count select
    ackto_it <=
      (txend_it and ackto_enable)  when "000000000",
      ackto_it_int                 when others;
      
  -- Timer is on from TX end interrupt to RX start interrupt, when enabled by 
  -- ackto_enable. It is disabled in low-power mode.
  txend_store_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      ackto_timer_on_int <= '0';
    elsif clk'event and clk = '1' then
      -- Timer enabled.
      if ackto_enable = '1' and mode32k = '0' then
        -- Start counting on TX end interrupt.
        if txend_it = '1' then
          ackto_timer_on_int <= '1';
        -- Stop counting on RX start interrupt.
        elsif (rxstart_it = '1') or (end_count = '1') then
          ackto_timer_on_int <= '0';
        end if;
      -- Timer disabled.
      else
        ackto_timer_on_int <= '0';
      end if;
    end if;
  end process txend_store_p;
  
  end_count <= '1' when ackto_timer = ackto_count else '0';
  
  -- ACK time-out timer.
  ackto_timer_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      ackto_timer <= (others => '0');
    elsif clk'event and clk = '1' then
      -- Timer counting.
      if ackto_timer_on_int = '1' then
        -- Count on a us basis.
        if enable_1mhz = '1' then
          ackto_timer <= ackto_timer + 1;
        end if;
      else
        ackto_timer <= (others => '0');
      end if;
    end if;
  end process ackto_timer_p;
  

  -- ACK time-out interrupt.
  ackto_it_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      ackto_it_int <= '0';
    elsif clk'event and clk = '1' then
      ackto_it_int <= '0'; -- Reset pulse.
      -- Interrupt when timer reaches time-out value.
      if end_count = '1' and ackto_timer_on_int = '1' then
        ackto_it_int <= '1';
      end if;
    end if;
  end process ackto_it_p;
  
    

end RTL;
