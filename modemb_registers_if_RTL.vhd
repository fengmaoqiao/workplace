

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of modemb_registers_if is

  signal reg_tlockdisb_ff1_resync    : std_logic;
  signal reg_tlockdisb_ff2_resync    : std_logic;
  signal reg_rxc2disb_ff1_resync     : std_logic;
  signal reg_rxc2disb_ff2_resync     : std_logic;
  signal reg_interpdisb_ff1_resync   : std_logic;
  signal reg_interpdisb_ff2_resync   : std_logic;
  signal reg_iqmmdisb_ff1_resync     : std_logic;
  signal reg_iqmmdisb_ff2_resync     : std_logic;
  signal reg_gaindisb_ff1_resync     : std_logic;
  signal reg_gaindisb_ff2_resync     : std_logic;
  signal reg_precompdisb_ff1_resync  : std_logic;
  signal reg_precompdisb_ff2_resync  : std_logic;
  signal reg_dcoffdisb_ff1_resync    : std_logic;
  signal reg_dcoffdisb_ff2_resync    : std_logic;
  signal reg_compdisb_ff1_resync     : std_logic;
  signal reg_compdisb_ff2_resync     : std_logic;
  signal reg_eqdisb_ff1_resync       : std_logic;
  signal reg_eqdisb_ff2_resync       : std_logic;
  signal reg_firdisb_ff1_resync      : std_logic;
  signal reg_firdisb_ff2_resync      : std_logic;
  signal reg_spreaddisb_ff1_resync   : std_logic;
  signal reg_spreaddisb_ff2_resync   : std_logic;
  signal reg_scrambdisb_ff1_resync   : std_logic;
  signal reg_scrambdisb_ff2_resync   : std_logic;
  signal reg_interfildisb_ff1_resync : std_logic;
  signal reg_interfildisb_ff2_resync : std_logic;
  signal reg_txc2disb_ff1_resync     : std_logic;
  signal reg_txc2disb_ff2_resync     : std_logic;
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  resync_p: process (hclk, reset_n)
  begin
    if reset_n = '0' then
      reg_tlockdisb_ff1_resync    <= '0';
      reg_tlockdisb_ff2_resync    <= '0';
      reg_rxc2disb_ff1_resync     <= '0';
      reg_rxc2disb_ff2_resync     <= '0';
      reg_interpdisb_ff1_resync   <= '0';
      reg_interpdisb_ff2_resync   <= '0';
      reg_iqmmdisb_ff1_resync     <= '0';
      reg_iqmmdisb_ff2_resync     <= '0';
      reg_gaindisb_ff1_resync     <= '0';
      reg_gaindisb_ff2_resync     <= '0';
      reg_precompdisb_ff1_resync  <= '0';
      reg_precompdisb_ff2_resync  <= '0';
      reg_dcoffdisb_ff1_resync    <= '0';
      reg_dcoffdisb_ff2_resync    <= '0';
      reg_compdisb_ff1_resync     <= '0';
      reg_compdisb_ff2_resync     <= '0';
      reg_eqdisb_ff1_resync       <= '0';
      reg_eqdisb_ff2_resync       <= '0';
      reg_firdisb_ff1_resync      <= '0';
      reg_firdisb_ff2_resync      <= '0';
      reg_spreaddisb_ff1_resync   <= '0';
      reg_spreaddisb_ff2_resync   <= '0';
      reg_scrambdisb_ff1_resync   <= '0';
      reg_scrambdisb_ff2_resync   <= '0';
      reg_interfildisb_ff1_resync <= '0';
      reg_interfildisb_ff2_resync <= '0';
      reg_txc2disb_ff1_resync     <= '0';
      reg_txc2disb_ff2_resync     <= '0';
    elsif hclk'event and hclk = '1' then
      reg_tlockdisb_ff1_resync    <= reg_tlockdisb;
      reg_tlockdisb_ff2_resync    <= reg_tlockdisb_ff1_resync;
      reg_rxc2disb_ff1_resync     <= reg_rxc2disb;
      reg_rxc2disb_ff2_resync     <= reg_rxc2disb_ff1_resync;
      reg_interpdisb_ff1_resync   <= reg_interpdisb;
      reg_interpdisb_ff2_resync   <= reg_interpdisb_ff1_resync;
      reg_iqmmdisb_ff1_resync     <= reg_iqmmdisb;
      reg_iqmmdisb_ff2_resync     <= reg_iqmmdisb_ff1_resync;
      reg_gaindisb_ff1_resync     <= reg_gaindisb;
      reg_gaindisb_ff2_resync     <= reg_gaindisb_ff1_resync;
      reg_precompdisb_ff1_resync  <= reg_precompdisb;
      reg_precompdisb_ff2_resync  <= reg_precompdisb_ff1_resync;
      reg_dcoffdisb_ff1_resync    <= reg_dcoffdisb;
      reg_dcoffdisb_ff2_resync    <= reg_dcoffdisb_ff1_resync;
      reg_compdisb_ff1_resync     <= reg_compdisb;
      reg_compdisb_ff2_resync     <= reg_compdisb_ff1_resync;
      reg_eqdisb_ff1_resync       <= reg_eqdisb;
      reg_eqdisb_ff2_resync       <= reg_eqdisb_ff1_resync;
      reg_firdisb_ff1_resync      <= reg_firdisb;
      reg_firdisb_ff2_resync      <= reg_firdisb_ff1_resync;
      reg_spreaddisb_ff1_resync   <= reg_spreaddisb;
      reg_spreaddisb_ff2_resync   <= reg_spreaddisb_ff1_resync;
      reg_scrambdisb_ff1_resync   <= reg_scrambdisb;
      reg_scrambdisb_ff2_resync   <= reg_scrambdisb_ff1_resync;
      reg_interfildisb_ff1_resync <= reg_interfildisb;
      reg_interfildisb_ff2_resync <= reg_interfildisb_ff1_resync;
      reg_txc2disb_ff1_resync     <= reg_txc2disb;
      reg_txc2disb_ff2_resync     <= reg_txc2disb_ff1_resync;
    end if;
  end process resync_p;
  
    reg_tlockdisb_sync    <= reg_tlockdisb_ff2_resync;
    reg_rxc2disb_sync     <= reg_rxc2disb_ff2_resync;
    reg_interpdisb_sync   <= reg_interpdisb_ff2_resync;
    reg_iqmmdisb_sync     <= reg_iqmmdisb_ff2_resync;
    reg_gaindisb_sync     <= reg_gaindisb_ff2_resync;
    reg_precompdisb_sync  <= reg_precompdisb_ff2_resync;
    reg_dcoffdisb_sync    <= reg_dcoffdisb_ff2_resync;
    reg_compdisb_sync     <= reg_compdisb_ff2_resync;
    reg_eqdisb_sync       <= reg_eqdisb_ff2_resync;
    reg_firdisb_sync      <= reg_firdisb_ff2_resync;
    reg_spreaddisb_sync   <= reg_spreaddisb_ff2_resync;
    reg_scrambdisb_sync   <= reg_scrambdisb_ff2_resync;
    reg_interfildisb_sync <= reg_interfildisb_ff2_resync;
    reg_txc2disb_sync     <= reg_txc2disb_ff2_resync;
end RTL;
