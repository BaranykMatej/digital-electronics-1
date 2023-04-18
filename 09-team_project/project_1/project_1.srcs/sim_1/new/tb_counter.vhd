library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_counter is
--  Port ( );
end tb_counter;

architecture Behavioral of tb_counter is

    constant c_CLK_100MHZ_PERIOD : time := 10ns;
    
    signal sig_clk                     : std_logic := '1';       
    signal sig_rst                     : std_logic := '0';  
    signal sig_en                      : std_logic := '1';
    -- inputs
    signal sig_timer_limit_12bit       : std_logic_vector(11 downto 0) := "100000000000";
    signal sig_pause_limit_12bit       : std_logic_vector(11 downto 0) := "110000000000";
    signal sig_round_limit_4bit        : std_logic_vector(3 downto 0) := "1000";
    -- outputs
    signal sig_timer_12bit             : std_logic_vector(11 downto 0); 
    signal sig_pause_12bit             : std_logic_vector(11 downto 0);
    signal sig_round_4bit              : std_logic_vector(3 downto 0);  
begin

  uut_counter : entity work.counter
    port map (
      clk => sig_clk,    
      rst => sig_rst,
      en  => sig_en,
      -- inputs
      timer_limit_12bit => sig_timer_limit_12bit,
      pause_limit_12bit => sig_pause_limit_12bit,
      round_limit_4bit  => sig_round_limit_4bit,
      -- outputs
      timer_12bit => sig_timer_12bit,
      pause_12bit => sig_pause_12bit,
      round_4bit  => sig_round_4bit
    );
    
  --------------------------------------------------------
  -- Clock generation process
  --------------------------------------------------------
  p_clk_gen : process is
  begin

    while now < 200 us loop

      sig_clk <= '0';
      wait for c_CLK_100MHZ_PERIOD / 2;
      sig_clk <= '1';
      wait for c_CLK_100MHZ_PERIOD / 2;

    end loop;

    wait;

  end process p_clk_gen;

end Behavioral;
