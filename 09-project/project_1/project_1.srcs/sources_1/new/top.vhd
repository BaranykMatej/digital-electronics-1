library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top is
  port (
    CLK100MHZ               : in  std_logic;      
    SW                      : in  std_logic;   
    BTNC                    : in  std_logic;  
    sig_timer_12bit_O       : out std_logic_vector(11 downto 0); 
    sig_rounds_6bit_O       : out std_logic_vector(5 downto 0);   
    sig_pause_12bit_O       : out std_logic_vector(11 downto 0);
    sig_clk_1ns_O           : out std_logic;
    sig_minutes             : buffer std_logic_vector(7 downto 0);
    sig_seconds             : buffer std_logic_vector(11 downto 0);
    sig_rounds              : out std_logic_vector(5 downto 0);   
    sig_pause               : out std_logic_vector(11 downto 0);
    sig_minutes_tens        : inout std_logic_vector(3 downto 0);
    sig_minutes_ones        : inout std_logic_vector(3 downto 0);
    sig_seconds_tens        : inout std_logic_vector(3 downto 0);
    sig_seconds_ones        : inout std_logic_vector(3 downto 0);
    sig_pause_tens          : inout std_logic_vector(3 downto 0);
    sig_pause_ones          : inout std_logic_vector(3 downto 0);
    an                      : out std_logic_vector(3 downto 0); -- anodes for the 7-segment displays
    seg                     : out std_logic_vector(6 downto 0); -- segments for the 7-segment displays
    sig_digit_seg           : out std_logic_vector(6 downto 0);

    --switches
    SW0 : in std_logic;
    SW1 : in std_logic;
    SW2 : in std_logic;
    SW3 : in std_logic;
    SW4 : in std_logic;
    SW5 : in std_logic;
    SW6 : in std_logic;
    SW7 : in std_logic;
    SW8 : in std_logic;
    SW9 : in std_logic;
    SW10 : in std_logic;
    SW11 : in std_logic;
    SW12 : in std_logic;
    SW13 : in std_logic;
    SW14 : in std_logic;
    SW15 : in std_logic

    
  );
end entity top;

-- Architecture body for top level
architecture behavioral of top is

  -- Signal declarations
  signal sig_pause_12bit    : std_logic_vector(11 downto 0);
  signal sig_rounds_6bit    : unsigned(5 downto 0) := (others => '0');
  signal sig_timer_12bit    : std_logic_vector(11 downto 0);
  signal sig_timer_en       : std_logic := '1';
  signal sig_pause_en       : std_logic := '0';
  signal sig_clk_1ns        : std_logic;
  signal round_limit_from_switches   : unsigned(3 downto 0) := (others => '0');
  signal pause_limit_from_switches   : unsigned(11 downto 0) := (others => '0');
  signal counter_limit_from_switches : unsigned(11 downto 0) := (others => '0');
  signal sig_timer_rst      : std_logic := '0';
  signal sig_pause_rst      : std_logic := '0';
  signal sig_hex            : std_logic_vector(3 downto 0);
  

type t_state is (
    COUNTER,
    PAUSE
);

  signal sig_state : t_state;
  
begin

  -- Instance of clock_enable entity
  clk_en1 : entity work.clock_enable
    generic map (
      g_MAX => 10      
    )
    port map (
      clk => CLK100MHZ, 
      rst => '0',     
      ce  => sig_clk_1ns 
    );

  -- Instance of cnt_up_down entity for Timer
  cnt_timer : entity work.cnt_up_down
    generic map (
      g_CNT_WIDTH => 12   
    )
    port map (
      clk    => sig_clk_1ns,       -- Main clock input
      rst    => sig_timer_rst,              
      en     => sig_timer_en,
      cnt_up => '1',              
      cnt    => sig_timer_12bit 
    );
    
    -- Instance of cnt_up_down entity for Timer
  cnt_pause : entity work.cnt_up_down
    generic map (
      g_CNT_WIDTH => 12    -- Counter width (12 bits)
    )
    port map (
      clk    => sig_clk_1ns,        
      rst    => sig_pause_rst,              
      en     => sig_pause_en,       
      cnt_up => '1',              
      cnt    => sig_pause_12bit    
    );
    
  -- Instance of hex_7seg entity for minutes tens
  hex_7seg_0 : entity work.hex_7seg
    port map (
      blank => '0',
      hex   => sig_hex,
      seg   => sig_digit_seg
    );

  -- Instance of hex_7seg entity for minutes ones
  hex_7seg_1 : entity work.hex_7seg
    port map (
      blank => '0',
      hex   => sig_hex,
      seg   => sig_digit_seg
    );

  -- Instance of hex_7seg entity for seconds tens
  hex_7seg_2 : entity work.hex_7seg
    port map (
      blank => '0',
      hex   => sig_hex,
      seg   => sig_digit_seg
    );

  -- Instance of hex_7seg entity for seconds ones
  hex_7seg_3 : entity work.hex_7seg
    port map (
      blank => '0',
      hex   => sig_hex,
      seg   => sig_digit_seg
    );
  

p_round_limit_switches : process (SW0, SW1, SW2, SW3) is
variable round_limit_switches_vector: std_logic_vector(3 downto 0);
begin
round_limit_switches_vector := (SW0 & SW1 & SW2 & SW3);
if (round_limit_switches_vector = "0000") then
    round_limit_from_switches <= "0001";
  else
    round_limit_from_switches <= (SW3 & SW2 & SW1 & SW0);
end if;
end process p_round_limit_switches;

p_pause_limit_switches : process (SW4, SW5, SW6, SW7, SW8, SW9) is
  variable pause_limit_switches_int: integer;
  variable pause_limit_switches_vector: std_logic_vector(5 downto 0);
begin

  pause_limit_switches_vector := (SW4 & SW5 & SW6 & SW7 & SW8 & SW9);
  pause_limit_switches_int := TO_INTEGER(unsigned(pause_limit_switches_vector));
  
  if (pause_limit_switches_int <= 60 and pause_limit_switches_int >= 1) then
    pause_limit_from_switches <= TO_UNSIGNED (pause_limit_switches_int * 60, 12);
  end if;
  if (pause_limit_switches_int < 1) then
    pause_limit_from_switches <= TO_UNSIGNED (60, 12);
  end if;
  if (pause_limit_switches_int > 60) then
    pause_limit_from_switches <= TO_UNSIGNED(3600, 12);
  end if;
end process p_pause_limit_switches;

p_counter_limit_switches : process (SW10, SW11, SW12, SW13, SW14, SW15) is
  variable counter_limit_switches_int: integer;
  variable counter_limit_switches_vector: std_logic_vector(5 downto 0);
begin
  counter_limit_switches_vector := (SW10 & SW11 & SW12 & SW13 & SW14 & SW15);
  counter_limit_switches_int := TO_INTEGER(unsigned(counter_limit_switches_vector));

  if (counter_limit_switches_int <= 60 and counter_limit_switches_int >= 1) then
    counter_limit_from_switches <= TO_UNSIGNED (counter_limit_switches_int * 60, 12);
  end if;
  if (counter_limit_switches_int < 1) then
    counter_limit_from_switches <= TO_UNSIGNED (60, 12);
  end if;
  if (counter_limit_switches_int > 60) then
    counter_limit_from_switches <= TO_UNSIGNED(3600, 12);
  end if;
end process p_counter_limit_switches;

p_pause_cycle : process (sig_clk_1ns) is
begin
  if (rising_edge(sig_clk_1ns)) then
  sig_timer_rst <= '0';
  sig_pause_rst <= '0';
    if (BTNC = '1') then
      sig_state             <= COUNTER;
      sig_rounds_6bit       <= "000000";
    elsif (SW = '1') then
      if (sig_rounds_6bit < round_limit_from_switches) then
        case sig_state is
          when COUNTER =>
            sig_timer_en <= '1';
            sig_pause_en <= '0';
            if (unsigned(sig_timer_12bit) = to_unsigned(to_integer((counter_limit_from_switches) - 1), 12)) then
              sig_state <= PAUSE;
              sig_rounds_6bit <= sig_rounds_6bit + 1;
              sig_timer_rst       <= '1';
            end if;
          when PAUSE =>
            sig_timer_en <= '0';
            sig_pause_en <= '1';
            if (unsigned(sig_pause_12bit) = to_unsigned(to_integer((pause_limit_from_switches) - 1), 12)) then
              sig_pause_rst       <= '1';
              sig_state <= COUNTER;
            end if;
        end case;
      else
        sig_timer_en <= '0';
        sig_pause_en <= '0';
      end if;
    end if;
  end if; 
end process p_pause_cycle;



p_out : process (sig_clk_1ns) is
begin
sig_timer_12bit_O   <= sig_timer_12bit;
  -- Output must be retyped from "unsigned" to "std_logic_vector"
sig_rounds_6bit_O   <= std_logic_vector(sig_rounds_6bit);
sig_pause_12bit_O   <= sig_pause_12bit;
sig_clk_1ns_O       <= sig_clk_1ns;
sig_rounds   <= std_logic_vector(sig_rounds_6bit);
sig_pause    <= sig_pause_12bit;
end process p_out;
    
p_extract_min_sec_pause : process (sig_timer_12bit)
  variable sig_minutes, sig_seconds: integer;
begin
  sig_minutes := to_integer(unsigned(sig_timer_12bit)) / 60;
  sig_seconds := to_integer(unsigned(sig_timer_12bit)) mod 60;
  
  sig_minutes_tens <= std_logic_vector(to_unsigned(sig_minutes / 10, 4));
  sig_minutes_ones <= std_logic_vector(to_unsigned(sig_minutes mod 10, 4));
  
  sig_seconds_tens <= std_logic_vector(to_unsigned(sig_seconds / 10, 4));
  sig_seconds_ones <= std_logic_vector(to_unsigned(sig_seconds mod 10, 4));
  
end process p_extract_min_sec_pause;

p_extract_pause : process (sig_pause_12bit)
  variable sig_pause_tens_val, sig_pause_ones_val, sig_pause_seconds: integer;
begin
  sig_pause_seconds := to_integer(unsigned(sig_pause_12bit(11 downto 0))) mod 60;

  sig_pause_tens_val := sig_pause_seconds / 10;
  sig_pause_ones_val := sig_pause_seconds mod 10;

  sig_pause_tens <= std_logic_vector(to_unsigned(sig_pause_tens_val, 4));
  sig_pause_ones <= std_logic_vector(to_unsigned(sig_pause_ones_val, 4));

end process p_extract_pause;


-- Process for driving the 7-segment displays
p_drive_7seg : process (CLK100MHZ)
    variable counter : integer := 0;
  begin
    if rising_edge(CLK100MHZ) then
      counter := counter + 1;
      
      case counter is
        when 1 =>
          an  <= "1110";
          sig_hex <= sig_seconds_ones;
        when 2 =>
          an  <= "1101";
          sig_hex <= sig_seconds_tens;
        when 3 =>
          an  <= "1011";
          sig_hex <= sig_minutes_ones;
        when 4 =>
          an  <= "0111";
          sig_hex <= sig_minutes_tens;
        when 5 =>
          counter := 0;
        when others =>
      end case;
    end if;
  end process p_drive_7seg;

end architecture behavioral;