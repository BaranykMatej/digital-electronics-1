library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all; -- Definition of "to_unsigned"

----------------------------------------------------------
-- Entity declaration for testbench
----------------------------------------------------------

entity tb_top is
  -- Entity of testbench is always empty
end entity tb_top;

----------------------------------------------------------
-- Architecture body for testbench
----------------------------------------------------------

architecture testbench of tb_top is

  constant c_CLK_100MHZ_PERIOD : time := 10 ns;

  -- Testbench local signals
  signal sig_sw                  : std_logic := '0';
  signal sig_btnc                : std_logic := '0';
  signal sig_clk                 : std_logic := '0';
  signal sig_timer_12bit_O       : std_logic_vector(11 downto 0); 
  signal sig_rounds_6bit_O       : std_logic_vector(5 downto 0);   
  signal sig_pause_12bit_O       : std_logic_vector(11 downto 0);
  signal sig_clk_1ns_O           : std_logic;
  signal sig_minutes_tens        : std_logic_vector(3 downto 0);
  signal sig_minutes_ones        : std_logic_vector(3 downto 0);
  signal sig_seconds_tens        : std_logic_vector(3 downto 0);
  signal sig_seconds_ones        : std_logic_vector(3 downto 0);
  signal sig_pause_tens          : std_logic_vector(3 downto 0);
  signal sig_pause_ones          : std_logic_vector(3 downto 0);
  signal sig_sw0                 : std_logic := '0';
  signal sig_sw1                 : std_logic := '0';
  signal sig_sw2                 : std_logic := '0';
  signal sig_sw3                 : std_logic := '0';
  signal sig_sw4                 : std_logic := '0';
  signal sig_sw5                 : std_logic := '0';
  signal sig_sw6                 : std_logic := '0';
  signal sig_sw7                 : std_logic := '0';
  signal sig_sw8                 : std_logic := '0';
  signal sig_sw9                 : std_logic := '0';
  signal sig_sw10                 : std_logic := '0';
  signal sig_sw11                 : std_logic := '0';
  signal sig_sw12                 : std_logic := '0';
  signal sig_sw13                 : std_logic := '0';
  signal sig_sw14                 : std_logic := '0';
  signal sig_sw15                 : std_logic := '0';
  signal sig_seg                  : std_logic_vector(6 downto 0);
  

  
begin

  -- Connecting testbench signals with top entity
  -- (Unit Under Test)

  uut_top : entity work.top
    port map (
      SW         => sig_sw,
      clk100mhz  => sig_clk,
      BTNC       => sig_btnc,
      sig_rounds_6bit_O => sig_rounds_6bit_O,
      sig_timer_12bit_O => sig_timer_12bit_O,
      sig_clk_1ns_O => sig_clk_1ns_O,
      sig_pause_12bit_O => sig_pause_12bit_O,
      sig_minutes_tens => sig_minutes_tens,
      sig_minutes_ones => sig_minutes_ones,
      sig_seconds_tens => sig_seconds_tens,
      sig_seconds_ones => sig_seconds_ones,
      sig_pause_tens => sig_pause_tens,
      sig_pause_ones => sig_pause_ones,
      SW0 => sig_sw0,
      SW1 => sig_sw1,
      SW2 => sig_sw2,
      SW3 => sig_sw3,
      SW4 => sig_sw4,
      SW5 => sig_sw5,
      SW6 => sig_sw6,
      SW7 => sig_sw7,
      SW8 => sig_sw8,
      SW9 => sig_sw9,
      SW10 => sig_sw10,
      SW11=> sig_sw11,
      SW12 => sig_sw12,
      SW13 => sig_sw13,
      SW14 => sig_sw14,
      SW15 => sig_sw15,
      sig_digit_seg => sig_seg
    );

  --------------------------------------------------------
  -- Input generation process
  --------------------------------------------------------
  p_input_gen : process is
  begin

    report "Stimulus process started";

    sig_btnc <= '0';    -- Normal operation
    wait for 25 ns;

    -- Loop for all switch values
    sig_sw <= '1';
    
    report "Stimulus process finished";
    wait;

  end process p_input_gen;
  
  --------------------------------------------------------
  -- Clock generation process
  --------------------------------------------------------
  p_clk_gen : process is
  begin

    while now < 40 ms loop 

      sig_clk <= '0';
      wait for c_CLK_100MHZ_PERIOD / 2;
      sig_clk <= '1';
      wait for c_CLK_100MHZ_PERIOD / 2;

    end loop;
    wait;

  end process p_clk_gen;
  
  p_test_case_2 : process is
begin
  report "Test case 2: Pause limit set to 5, Round duration set to 30";

  sig_sw0 <= '0';
  sig_sw1 <= '0';
  sig_sw2 <= '0';
  sig_sw3 <= '1';
  -- pause
  sig_sw4 <= '0';
  sig_sw5 <= '0';
  sig_sw6 <= '0';
  sig_sw7 <= '0';
  sig_sw8 <= '1';
  sig_sw9 <= '1';
  -- timer
  sig_sw10 <= '0';
  sig_sw11 <= '0';
  sig_sw12 <= '1';
  sig_sw13 <= '1';
  sig_sw14 <= '1';
  sig_sw15 <= '1';

  wait for 5 ms;
end process p_test_case_2;

end architecture testbench;
