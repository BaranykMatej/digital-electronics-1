library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity counter is
  port (
    clk                     : in  std_logic;       
    rst                     : in  std_logic;  
    en                      : in  std_logic;
    -- inputs
    timer_limit_12bit       : in std_logic_vector(11 downto 0) := (others => '0');
    pause_limit_12bit       : in std_logic_vector(11 downto 0) := (others => '0');
    round_limit_4bit        : in std_logic_vector(3 downto 0) := (others => '0');
    -- outputs
    timer_12bit             : out std_logic_vector(11 downto 0); 
    pause_12bit             : out std_logic_vector(11 downto 0);
    round_4bit              : out std_logic_vector(3 downto 0)   





  );
end entity counter;

architecture behavioral of counter is
-- signal declarations

-- clock enable variable output signal
signal sig_clk   : std_logic := '0';

-- timer enable signals
signal sig_timer_en       : std_logic := '1';
signal sig_pause_en       : std_logic := '0';

-- timer reset signals
signal sig_timer_rst      : std_logic := '0';
signal sig_pause_rst      : std_logic := '0';

-- round counter signal
signal sig_timer_12bit     : std_logic_vector (11 downto 0) := (others => '0');
signal sig_pause_12bit     : std_logic_vector (11 downto 0) := (others => '0');
signal sig_round_4bit      : unsigned (3 downto 0)  := (others => '0');


type t_state is (
    COUNTER,
    PAUSE
);

-- enum used for pause/timer switching
signal sig_state : t_state;

begin

-- entity used to convert base clock frequency to seconds
-- g_MAX EDIT FOR SECONDS!!!
clk_en1 : entity work.clock_enable
    generic map (
      -- 100000000
      g_MAX => 100000000   
    )
    port map (
      -- input clock signal
      clk => clk, 
      rst => '0',  
      -- output clock signal (1 second)
      ce  => sig_clk 
    );
    
-- timer counter
cnt_timer : entity work.cnt_up_down
  generic map (
    g_CNT_WIDTH => 12   
  )
  port map (
    clk    => sig_clk,
    rst    => sig_timer_rst,              
    en     => sig_timer_en,
    cnt_up => '1',              
    cnt    => sig_timer_12bit 
  );
  
-- pause counter
cnt_pause : entity work.cnt_up_down
  generic map (
   g_CNT_WIDTH => 12    
  )
  port map (
    clk    => sig_clk,        
    rst    => sig_pause_rst,              
    en     => sig_pause_en,       
    cnt_up => '1',              
    cnt    => sig_pause_12bit    
  );
  
p_coumter_cycle : process (sig_clk) is
begin
  if (rising_edge(sig_clk)) then
  -- reset whole entity
    if (rst = '1') then
      sig_state             <= COUNTER;
      sig_timer_rst         <= '1';
      sig_pause_rst         <= '1';
      sig_round_4bit        <= (others => '0');
      sig_timer_en          <= '1';
      sig_pause_en          <= '1';
    else
      -- if rst not set, keep counting
      -- in case timer or pause needs to be reset to put them back in action
      sig_timer_rst <= '0';
      sig_pause_rst <= '0';
      -- if round limit is not yet reached
      if (not(std_logic_vector(sig_round_4bit) = round_limit_4bit)) then
        case sig_state is
          when COUNTER =>
            -- timer - continue counting
            sig_timer_en <= '1';
            sig_pause_en <= '0';
            -- if timer limit is reached, switch to pause
            if (sig_timer_12bit = timer_limit_12bit) then
              sig_state       <= PAUSE;
              sig_round_4bit  <= sig_round_4bit + 1;
              sig_timer_rst   <= '1';
            end if;
          when PAUSE =>
            -- pause - continue counting
            sig_timer_en <= '0';
            sig_pause_en <= '1';
            -- if pause limit is reached, switch to counter
            if (sig_pause_12bit = pause_limit_12bit) then
              sig_state       <= COUNTER;
              sig_pause_rst   <= '1';
            end if;
        end case;
      -- if round limit reached
      -- disable both timers, wait for rst
      else
        sig_timer_en <= '0';
        sig_pause_en <= '0';
      end if;

    end if; -- rst
    
  -- output working signals
  timer_12bit <= sig_timer_12bit;
  pause_12bit <= sig_pause_12bit;
  round_4bit  <= std_logic_vector(sig_round_4bit);
  
  end if; -- rising edge
  
end process p_coumter_cycle;

end architecture Behavioral;
