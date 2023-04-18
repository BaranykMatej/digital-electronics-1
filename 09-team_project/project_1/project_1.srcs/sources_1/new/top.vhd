library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity top is
  port (
    -- onboard clock
    CLK100MHZ   : in  std_logic;       
    -- segmented display cathodes
    CA          : out std_logic;
    CB          : out std_logic;
    CC          : out std_logic;
    CD          : out std_logic;
    CE          : out std_logic;
    CF          : out std_logic;
    CG          : out std_logic;
    -- segmented display anodes
    AN          : out std_logic_vector (7 downto 0);
    -- reset button
    BTNC        : in std_logic;
    -- switches used to set the counter
    SW          : in std_logic_vector(15 downto 0);
    -- debug timer output
    debug_timer : out std_logic_vector(11 downto 0) := (others => '0')
  );
end entity top;

-- Architecture body for top level
architecture behavioral of top is
  -- digit driver input signals
  signal sig_digit_minutes_tens        : std_logic_vector(3 downto 0);
  signal sig_digit_minutes_ones        : std_logic_vector(3 downto 0);
  signal sig_digit_seconds_tens        : std_logic_vector(3 downto 0);
  signal sig_digit_seconds_ones        : std_logic_vector(3 downto 0);
  signal sig_digit_round_tens          : std_logic_vector(3 downto 0);
  signal sig_digit_round_ones          : std_logic_vector(3 downto 0);
  -- hex signal
  signal sig_hex                       : std_logic_vector(3 downto 0);
  -- counter limit signals (set by switches)
  signal sig_round_limit_from_switches : unsigned(3 downto 0)  := (others => '0');
  signal sig_pause_limit_from_switches : unsigned(11 downto 0) := (others => '0');
  signal sig_timer_limit_from_switches : unsigned(11 downto 0) := (others => '0');
  -- counter signals
  signal sig_timer_12bit               : std_logic_vector(11 downto 0); 
  signal sig_pause_12bit               : std_logic_vector(11 downto 0);
  signal sig_round_4bit                : std_logic_vector(3 downto 0); 
  -- reset signal
  signal sig_res                       : std_logic := '0';
  
begin

  -- the counter entity
  counter : entity work.counter
    port map (
      clk => CLK100MHZ,    
      rst => sig_res,
      en  => '1',
      -- inputs
      timer_limit_12bit => std_logic_vector(sig_timer_limit_from_switches),
      pause_limit_12bit => std_logic_vector(sig_pause_limit_from_switches),
      round_limit_4bit  => std_logic_vector(sig_round_limit_from_switches),
      -- outputs
      timer_12bit => sig_timer_12bit,
      pause_12bit => sig_pause_12bit,
      round_4bit  => sig_round_4bit
    );
  
  -- ASYNC!
  -- entity used to convert hex to segments
  hex_to_seg : entity work.hex_7seg
    port map (
      blank    => '0',
      -- variable input
      hex      => sig_hex,
      -- cathodes output
      seg(6)   => CA,
      seg(5)   => CB,
      seg(4)   => CC,
      seg(3)   => CD,
      seg(2)   => CE,
      seg(1)   => CF,
      seg(0)   => CG
    );

-- ASYNC!
-- converts switches to limits
p_counter_sw_to_lim : process (SW (15 downto 0))
begin

-- round limit
if SW(3 downto 0) < "0001" then
  sig_round_limit_from_switches <= "0001";
else
  sig_round_limit_from_switches <= unsigned(SW (3 downto 0));
end if;

-- timer limit
if SW (9 downto 3) > "111100" then
  sig_timer_limit_from_switches <= to_unsigned(3600, 12);
elsif SW (9 downto 3) < "000001" then
  sig_timer_limit_from_switches <= to_unsigned(60, 12);
else
  sig_timer_limit_from_switches <= to_unsigned(to_integer(unsigned(SW (9 downto 3))) * 60, 12);
end if;

-- pause limit
if SW (9 downto 3) > "111100" then
  sig_pause_limit_from_switches <= to_unsigned(3600, 12);
elsif SW (9 downto 3) < "000001" then
  sig_pause_limit_from_switches <= to_unsigned(60, 12);
else
  sig_pause_limit_from_switches <= to_unsigned(to_integer(unsigned(SW (15 downto 9))) * 60, 12);
end if;

-- settings modified, reset the counter
sig_res <= '1';

end process p_counter_sw_to_lim;

-- used to reset counter when BTNC is pressed and unreset
p_counter_reset : process (CLK100MHZ)
begin

debug_timer <= sig_timer_12bit;

if (sig_res <= '1' and BTNC = '0') then
  sig_res <= '0';
end if;

if (BTNC = '1') then
  sig_res <= '1';
end if;

end process p_counter_reset;


-- converts round/pause/timer value to digits
p_extract_digits : process (sig_timer_12bit, sig_pause_12bit, sig_round_4bit)
  variable sig_minutes, sig_seconds, sig_round: integer;
begin
  -- if timer is going up, display timer or the other way
  if (sig_timer_12bit > sig_pause_12bit) then
      sig_minutes := to_integer(unsigned(sig_timer_12bit)) / 60;
      sig_seconds := to_integer(unsigned(sig_timer_12bit)) mod 60;
  else
      sig_minutes := to_integer(unsigned(sig_pause_12bit)) / 60;
      sig_seconds := to_integer(unsigned(sig_pause_12bit)) mod 60;
  end if;
  
  sig_round  := to_integer(unsigned(sig_round_4bit));
  
  sig_digit_round_tens <= std_logic_vector(to_unsigned(sig_round / 10, 4));
  sig_digit_round_ones <= std_logic_vector(to_unsigned(sig_round mod 10, 4));
  
  sig_digit_minutes_tens <= std_logic_vector(to_unsigned(sig_minutes / 10, 4));
  sig_digit_minutes_ones <= std_logic_vector(to_unsigned(sig_minutes mod 10, 4));
  
  sig_digit_seconds_tens <= std_logic_vector(to_unsigned(sig_seconds / 10, 4));
  sig_digit_seconds_ones <= std_logic_vector(to_unsigned(sig_seconds mod 10, 4));
  
end process p_extract_digits;


-- drives the 7-segment displays
p_drive_7seg : process (CLK100MHZ)
    variable iterator : integer := 0;
  begin
    if rising_edge(CLK100MHZ) then
      iterator := iterator + 1;
        case iterator is
              -- display seconds
              when 10000 =>
                an  <= "11111110";
                sig_hex <= sig_digit_seconds_ones;
              when 20000 =>
                an  <= "11111101";
                sig_hex <= sig_digit_seconds_tens;
              -- display minutes
              when 30000 =>
                an  <= "11111011";
                sig_hex <= sig_digit_minutes_ones;
              when 40000 =>
                an  <= "11110111";
                sig_hex <= sig_digit_minutes_tens;
              -- keep 5th display blank
              when 50000 =>
                an  <= "11111111";
                sig_hex <= "1111";
              -- display rounds
              when 60000 =>
                an  <= "10111111";
                sig_hex <= sig_digit_round_ones;
              when 70000 =>
                an  <= "01111111";
                sig_hex <= sig_digit_round_tens;
                iterator := 0;
              when others =>
              -- do nothing
       end case;
    end if;
  end process p_drive_7seg;

end architecture behavioral;