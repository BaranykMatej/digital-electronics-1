library ieee;
use ieee.std_logic_1164.all;

-- Entity declaration for top-level design
entity top is
  port (
    CLK100MHZ               : in  std_logic;          -- Main clock input
    SW                      : in  std_logic;          -- Counter(s) direction control input
    BTNC                    : in  std_logic;          -- Synchronous reset input
    sig_cnt_12bit           : out std_logic_vector(11 downto 0); -- 12-bit Timer output
    sig_cnt_6bit            : out std_logic_vector(5 downto 0);   -- 6-bit Rounds output
    sig_cnt_max_round_6bit  : out std_logic_vector(5 downto 0);
    sig_cnt_pause_12bit     : out std_logic_vector(11 downto 0);
    sig_clk_1ns_O           : out std_logic
  );
end entity top;

-- Architecture body for top level
architecture behavioral of top is

  -- Signal declarations
  signal sig_clk_round : std_logic;                         -- Signal for Rounds clock
  signal sig_local_cnt_12bit : std_logic_vector(11 downto 0); -- Internal 12-bit counter for Rounds
  signal sig_local_cnt_max_round_6bit : std_logic_vector(5 downto 0);
  signal sig_local_cnt_max_timer_12bit : std_logic_vector(11 downto 0)  := "111111111111";
  signal sig_local_cnt_pause_12bit : std_logic_vector(11 downto 0);
  signal sig_local_cnt_max_pause_12bit : std_logic_vector(11 downto 0)  := "111111111111";
  signal sig_local_enable_timer : std_logic := '1';
  signal sig_local_enable_pause : std_logic := '0';

  -- Clock enable signal for timer
  signal sig_clk_1ns : std_logic;
  
type t_state is (
    COUNTER,
    PAUSE
);

-- Define the signal that uses different states
  signal sig_state : t_state;
  
begin

  -- Instance of clock_enable entity
  clk_en1 : entity work.clock_enable
    generic map (
      g_MAX => 2      -- Maximum count value for the clock enable (modify for the actual board)
    )
    port map (
      clk => CLK100MHZ,   -- Main clock input
      rst => '0',        -- Reset input
      ce  => sig_clk_1ns -- Clock enable output
    );

  -- Instance of cnt_up_down entity for Timer
  cnt_timer : entity work.cnt_up_down
    generic map (
      g_CNT_WIDTH => 12    -- Counter width (12 bits)
    )
    port map (
      clk    => sig_clk_1ns,        -- Main clock input
      rst    => BTNC,               -- Reset input
      en     => sig_local_enable_timer,-- Enable input
      cnt_up => '1',                -- Count up control signal (always count up)
      cnt    => sig_local_cnt_12bit  -- Internal 8-bit counter output
    );
    
    -- Instance of cnt_up_down entity for Timer
  cnt_pause_time : entity work.cnt_up_down
    generic map (
      g_CNT_WIDTH => 12    -- Counter width (12 bits)
    )
    port map (
      clk    => sig_clk_1ns,        -- Main clock input
      rst    => BTNC,               -- Reset input
      en     => sig_local_enable_pause,-- Enable input
      cnt_up => '1',                -- Count up control signal (always count up)
      cnt    => sig_local_cnt_pause_12bit  -- Internal 8-bit counter output
    );

  -- Process to increment Rounds counter and update output signals
  p_round_up : process(sig_local_cnt_12bit) is
    begin
      sig_cnt_12bit <= sig_local_cnt_12bit; -- Update the Timer output signal

      -- Check if the 12-bit counter has reached its maximum value

    end process p_round_up;
    
    
p_pause_change : process(sig_local_cnt_pause_12bit) is
    begin
    sig_cnt_pause_12bit <= sig_local_cnt_pause_12bit;
    
      
end process p_pause_change;

  p_clk_out : process(sig_clk_1ns) is
    begin
      sig_clk_1ns_O <= sig_clk_1ns; 
    end process p_clk_out;
    
  p_pause_cycle : process (sig_clk_1ns) is
  begin

    if (rising_edge(sig_clk_1ns)) then
      if (BTNC = '1') then                    -- Synchronous reset
        sig_state <= COUNTER;                 -- Init state
        sig_cnt_6bit   <= (others => '0');         -- Clear delay counter
      elsif (SW = '1') then
        case sig_state is

     when COUNTER =>
              sig_local_enable_timer <= '0';
              sig_local_enable_pause <= '1';
      if(sig_local_cnt_12bit = sig_local_cnt_max_timer_12bit) then
        sig_clk_round <= '1'; -- Increment the Rounds counter
      else
        sig_clk_round <= '0'; -- Keep the Rounds counter unchanged
      end if;

          when PAUSE =>
              sig_local_enable_timer <= '1';
              sig_local_enable_pause <= '0';


          when others =>
            -- It is a good programming practice to use the
            -- OTHERS clause, even if all CASE choices have
            -- been made.
            sig_state <= COUNTER;
            sig_cnt_6bit   <= (others => '0');

        end case;

      end if; -- Synchronous reset
    end if; -- Rising edge
  end process p_pause_cycle;
    
    
    
end architecture behavioral;
