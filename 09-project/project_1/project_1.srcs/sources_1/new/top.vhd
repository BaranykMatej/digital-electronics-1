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
    hex                     : in std_logic_vector(3 downto 0);   
    sig_pause_12bit_O       : out std_logic_vector(11 downto 0);
    sig_clk_1ns_O           : out std_logic;
    CA                      : out STD_LOGIC; 
    CB                      : out STD_LOGIC;
    CC                      : out std_logic;
    CD                      : out STD_LOGIC;
    CE                      : out STD_LOGIC;
    CF                      : out STD_LOGIC;
    CG                      : out std_logic
    );
end entity top;

-- Architecture body for top level
architecture behavioral of top is

  -- Signal declarations
  signal sig_pause_12bit : std_logic_vector(11 downto 0);
  signal sig_rounds_6bit : unsigned(5 downto 0) := (others => '0');
  signal sig_timer_12bit : std_logic_vector(11 downto 0);
  signal sig_timer_en : std_logic := '1';
  signal sig_pause_en : std_logic := '0';

  signal sig_clk_1ns : std_logic;
  
type t_state is (
    COUNTER,
    PAUSE
);

  signal sig_state : t_state;
  
begin

    hex2seg : entity work.hex_7seg
        port map (
            blank  => BTNC,
            hex    => hex,
            seg(6) => CA,
            seg(5) => CB,
            seg(4) => CC,
            seg(3) => CD,
            seg(2) => CE,
            seg(1) => CF,
            seg(0) => CG
          );
           
  -- Instance of clock_enable entity
  clk_en1 : entity work.clock_enable
    generic map (
      g_MAX => 2      
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
      rst    => BTNC,              
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
      rst    => BTNC,              
      en     => sig_pause_en,       
      cnt_up => '1',              
      cnt    => sig_pause_12bit    
    );


p_pause_cycle : process (sig_clk_1ns) is
begin
  if (rising_edge(sig_clk_1ns)) then
    if (BTNC = '1') then                   
      sig_state             <= COUNTER;              
      sig_rounds_6bit       <= "000000";         
    elsif (SW = '1') then
      case sig_state is
        when COUNTER =>
          sig_timer_en <= '1';
          sig_pause_en <= '0';
          if (sig_timer_12bit = "111111111111") then
            sig_state <= PAUSE;
            sig_rounds_6bit <= sig_rounds_6bit + 1;
          end if;
        when PAUSE =>
          sig_timer_en <= '0';
          sig_pause_en <= '1';
          if (sig_pause_12bit = "111111111111") then
            sig_state <= COUNTER;
            end if;
      end case;
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
end process p_out;
    
    
end architecture behavioral;
