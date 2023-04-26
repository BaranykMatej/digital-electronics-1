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
    SW          : in std_logic_vector(15 downto 0)
    -- debug timer output
    --debug_timer : out std_logic_vector(11 downto 0) := (others => '0')
  );
end entity top;

-- Architecture body for top level
architecture behavioral of top is
  type t_state is (
    SETTINGS,
    COUNT_STARTED,
    COUNT_FINISHED
  );
  -- initial counter state
  signal sig_state                     : t_state := SETTINGS;
  -- signal to remember last btnc state
  signal sig_btnc_last_state                : std_logic := '0';
  -- digit driver process input signals
  signal sig_digit_minutes_tens        : std_logic_vector(3 downto 0);
  signal sig_digit_minutes_ones        : std_logic_vector(3 downto 0);
  signal sig_digit_seconds_tens        : std_logic_vector(3 downto 0);
  signal sig_digit_seconds_ones        : std_logic_vector(3 downto 0);
  signal sig_digit_round_tens          : std_logic_vector(3 downto 0);
  signal sig_digit_round_ones          : std_logic_vector(3 downto 0);
  -- hex signal
  signal sig_hex                       : std_logic_vector(3 downto 0);
  -- counter limit signals (set by switches)                   -- default values
  signal sig_round_limit_from_switches : unsigned(3 downto 0)  := to_unsigned(12, 4);
  signal sig_pause_limit_from_switches : unsigned(11 downto 0) := to_unsigned(60, 12);
  signal sig_timer_limit_from_switches : unsigned(11 downto 0) := to_unsigned(60, 12);
  -- counter limit signals (set by switches)
  signal sig_round_limit_from_switches_TEMP : unsigned(3 downto 0)  := (others => '0');
  signal sig_pause_limit_from_switches_TEMP : unsigned(11 downto 0) := (others => '0');
  signal sig_timer_limit_from_switches_TEMP : unsigned(11 downto 0) := (others => '0');
  -- counter signals
  signal sig_timer_12bit               : std_logic_vector(11 downto 0); 
  signal sig_pause_12bit               : std_logic_vector(11 downto 0);
  signal sig_round_4bit                : std_logic_vector(3 downto 0); 
  -- reset signal
  signal sig_res                       : std_logic := '0';
  -- enable signal
  signal sig_en                        : std_logic := '0';
  
begin

  -- the counter entity
  counter : entity work.counter
    port map (
      clk => CLK100MHZ,    
      rst => sig_res,
      en  => sig_en,
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
-- stores switch values into temp limit signals
p_counter_sw_to_lim : process (CLK100MHZ)
begin

-- round limit
if SW(3 downto 0) < "0001" then
  sig_round_limit_from_switches_TEMP <= "0001";
else
  sig_round_limit_from_switches_TEMP <= unsigned(SW (3 downto 0));
end if;

-- timer limit
if SW (9 downto 3) > "111100" then
  sig_timer_limit_from_switches_TEMP <= to_unsigned(3600, 12);
elsif SW (9 downto 3) < "000001" then
  sig_timer_limit_from_switches_TEMP <= to_unsigned(60, 12);
else
  sig_timer_limit_from_switches_TEMP <= to_unsigned(to_integer(unsigned(SW (9 downto 3))) * 60, 12);
end if;

-- pause limit
if SW (9 downto 3) > "111100" then
  sig_pause_limit_from_switches_TEMP <= to_unsigned(3600, 12);
elsif SW (9 downto 3) < "000001" then
  sig_pause_limit_from_switches_TEMP <= to_unsigned(60, 12);
else
  sig_pause_limit_from_switches_TEMP <= to_unsigned(to_integer(unsigned(SW (15 downto 9))) * 60, 12);
end if;

end process p_counter_sw_to_lim;

--p_debug_delete_later : process (CLK100MHZ)
--begin

--debug_timer <= sig_timer_12bit;

--end process p_debug_delete_later;

p_state_selector : process (CLK100MHZ)
begin
if rising_edge(CLK100MHZ) then
  case sig_state is
  
    -- display seconds
    when SETTINGS =>
      -- counter is reset, disabled
      sig_res   <= '1';
      sig_en    <= '0';
      -- if btnc state changed from not pressed to pressed
      if BTNC = '1' and sig_btnc_last_state = '0' then
        -- switch from settings to counting
        if sig_state = SETTINGS then
          -- set the limit signals with temp signal values
          sig_round_limit_from_switches <= sig_round_limit_from_switches_TEMP;
          sig_pause_limit_from_switches <= sig_pause_limit_from_switches_TEMP;
          sig_timer_limit_from_switches <= sig_timer_limit_from_switches_TEMP;
          -- start counting
          sig_state <= COUNT_STARTED;
        end if;
      end if;
      
    when COUNT_STARTED =>
    -- counter is set, enabled
      sig_res   <= '0';
      sig_en    <= '1';
      -- if btnc state changed from not pressed to pressed
      if BTNC = '1' and sig_btnc_last_state = '0' then
        sig_state <= SETTINGS;
      -- if round signal reached limit, switch state to finished
      elsif sig_round_4bit = std_logic_vector(sig_round_limit_from_switches) then
        sig_state <= COUNT_FINISHED;
      end if;
      
    when COUNT_FINISHED =>
      -- counter is reset, disabled
      sig_res   <= '1';
      sig_en    <= '0';
      -- if btnc state changed from not pressed to pressed
      if BTNC = '1' and sig_btnc_last_state = '0' then
        sig_state <= SETTINGS;
      end if;
      
  end case;
  
  -- store last btnc state to signal
  sig_btnc_last_state <= BTNC;
  
end if;
end process p_state_selector;

-- converts round/pause/timer value to digits
p_extract_digits : process (CLK100MHZ)
  variable sig_minutes, sig_seconds, sig_round: integer;
begin
  
  -- when in counter state, minutes to minutes, seconds to seconds
  if sig_state = COUNT_STARTED then
      -- if timer is going up, display timer or the other way
      if (sig_timer_12bit > sig_pause_12bit) then
          sig_minutes := to_integer(unsigned(sig_timer_12bit)) / 60;
          sig_seconds := to_integer(unsigned(sig_timer_12bit)) mod 60;
      else
          sig_minutes := to_integer(unsigned(sig_pause_12bit)) / 60;
          sig_seconds := to_integer(unsigned(sig_pause_12bit)) mod 60;
      end if;
      sig_round  := to_integer(unsigned(sig_round_4bit));
  -- when in settings, display only minutes PAUSE/TIMER side by side from temp limit signals
  else
      sig_minutes := to_integer(unsigned(sig_pause_limit_from_switches_TEMP)) / 60;
      sig_seconds := to_integer(unsigned(sig_timer_limit_from_switches_TEMP)) / 60;
      sig_round  := to_integer(unsigned(sig_round_limit_from_switches_TEMP));
  end if;
  
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
      -- counting state
      if sig_state = COUNT_STARTED or sig_state = SETTINGS then
        case iterator is
              -- display seconds
              when 10000=>
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
              -- display 5(S)/C according to state
              when 50000 =>
                an  <= "11101111";
                if sig_state = COUNT_STARTED then
                  -- when timer, display t
                  if (sig_timer_12bit > sig_pause_12bit) then
                    sig_hex <= "1100";
                  -- when pause, display p
                  else
                    sig_hex <= "1011";
                  end if;
                -- when settings, display s
                else
                  sig_hex <= "1010";
                end if;
              -- keep 6th display blank
              when 60000 =>
                an  <= "11111111";
                sig_hex <= "0000";
              -- display rounds
              when 70000 =>
                an  <= "10111111";
                sig_hex <= sig_digit_round_ones;
              when 80000 =>
                an  <= "01111111";
                sig_hex <= sig_digit_round_tens;
                iterator := 0;
              when others =>
              -- do nothing
         end case;
      -- counting finished state
      else
        case iterator is
           -- fill display with fs
           when 10000 =>
             an  <= "11111110";
             sig_hex <= "1111";
           when 20000 =>
             an  <= "11111101";
             sig_hex <= "1111";
           when 30000 =>
             an  <= "11111011";
             sig_hex <= "1111";
           when 40000 =>
             an  <= "11110111";
             sig_hex <= "1111";
           when 50000 =>
             an  <= "11101111";
             sig_hex <= "1111";
           when 60000 =>
             an  <= "11011111";
             sig_hex <= "1111";
           when 70000 =>
             an  <= "10111111";
             sig_hex <= "1111";
           when 80000 =>
             an  <= "01111111";
             sig_hex <= "1111";
             iterator := 0;
          when others =>
          -- do nothing
         end case;
       end if;
    end if;
  end process p_drive_7seg;

end architecture behavioral;