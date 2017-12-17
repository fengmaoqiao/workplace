

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of deintpun is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal enable_write : std_logic; -- writing phase of deint
  signal enable_read  : std_logic; -- reading phase of deint

  signal write_addr : CARR_T;
  -- no of actual carrier to be written
  
  signal read_carr_x : CARR_T;
  signal read_carr_y : CARR_T;
  signal read_soft_x : SOFT_T;
  signal read_soft_y : SOFT_T;
  signal read_punc_x : PUNC_T;
  signal read_punc_y : PUNC_T;
  -- addr of softbits to be output and decision for depuncturing

  signal soft_x0 : std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
  signal soft_x1 : std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
  signal soft_x2 : std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
  signal soft_y0 : std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
  signal soft_y1 : std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
  signal soft_y2 : std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  --------------------------------------
  -- Delay soft inputs process
  --------------------------------------
  delay_soft_inputs_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      soft_x0  <= (others => '0');
      soft_x1  <= (others => '0');
      soft_x2  <= (others => '0');
      soft_y0  <= (others => '0');
      soft_y1  <= (others => '0');
      soft_y2  <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (enable_i = '1' and data_valid_i = '1') then
        soft_x0  <= soft_x0_i;
        soft_x1  <= soft_x1_i;
        soft_x2  <= soft_x2_i;
        soft_y0  <= soft_y0_i;
        soft_y1  <= soft_y1_i;
        soft_y2  <= soft_y2_i;
      end if;    
    end if;
  end process delay_soft_inputs_p;


  --------------------------------------
  -- DEINTPUN CONTROL BLOCK
  --------------------------------------
  deintpun_control_1 : deintpun_control
  port map (
    reset_n        => reset_n,
    clk            => clk,
    sync_reset_n   => sync_reset_n,

    enable_i       => enable_i,
    data_valid_i   => data_valid_i,
    data_valid_o   => data_valid_o,
    data_ready_o   => data_ready_o,
    
    start_field_i  => start_field_i, 
    field_length_i => field_length_i,
    
    qam_mode_i     => qam_mode_i,
    pun_mode_i     => pun_mode_i,

    enable_write_o => enable_write,
    enable_read_o  => enable_read,

    write_addr_o   => write_addr,
    read_carr_x_o  => read_carr_x,
    read_carr_y_o  => read_carr_y,
    read_soft_x_o  => read_soft_x,
    read_soft_y_o  => read_soft_y,
    read_punc_x_o  => read_punc_x,
    read_punc_y_o  => read_punc_y
    );


  --------------------------------------
  -- DEINTPUN DATAPATH BLOCK
  --------------------------------------
  deintpun_datapath_1 : deintpun_datapath
  port map (
    reset_n        => reset_n,
    clk            => clk,

    enable_write_i => enable_write,
    enable_read_i  => enable_read,

    soft_x0_i      => soft_x0,
    soft_x1_i      => soft_x1,
    soft_x2_i      => soft_x2,
    soft_y0_i      => soft_y0,
    soft_y1_i      => soft_y1,
    soft_y2_i      => soft_y2,

    soft_x_o       => soft_x_o,
    soft_y_o       => soft_y_o,
    
    write_addr_i   => write_addr,
    read_carr_x_i  => read_carr_x,
    read_carr_y_i  => read_carr_y,
    read_soft_x_i  => read_soft_x,
    read_soft_y_i  => read_soft_y,
    read_punc_x_i  => read_punc_x,
    read_punc_y_i  => read_punc_y

  );

end RTL;
