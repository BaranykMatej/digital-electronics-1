library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity interval_timer_tb is
end entity interval_timer_tb;

architecture sim of interval_timer_tb is
    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';
    signal start      : std_logic := '0';
    signal round_time : unsigned(23 downto 0) := (others => '0');
    signal pause_time : unsigned(23 downto 0) := (others => '0');
    signal num_rounds : unsigned(7 downto 0) := (others => '0');
    signal done       : std_logic;
    signal status     : std_logic_vector(1 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    component interval_timer is
        port(
            clk        : in std_logic;
            reset      : in std_logic;
            start      : in std_logic;
            round_time : in unsigned(23 downto 0);
            pause_time : in unsigned(23 downto 0);
            num_rounds : in unsigned(7 downto 0);
            done       : out std_logic;
            status     : out std_logic_vector(1 downto 0)
        );
    end component interval_timer;

begin
    uut: interval_timer
        port map(
            clk        => clk,
            reset      => reset,
            start      => start,
            round_time => round_time,
            pause_time => pause_time,
            num_rounds => num_rounds,
            done       => done,
            status     => status
        );

    clk_process: process
    begin
        clk <= not clk;
        wait for CLK_PERIOD / 2;
    end process clk_process;

    stimulus_process: process
    begin
        -- Test reset
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';


        num_rounds <= "00000011";
        round_time <= to_unsigned (500, round_time'length); -- 500 ms
        pause_time <= to_unsigned (300, pause_time'length); -- 300 ms


        wait for CLK_PERIOD * 10;
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';


        wait for CLK_PERIOD * 1000 * (to_integer(num_rounds) * (TO_INTEGER(round_time) + to_integer(pause_time)) + 10);


        assert false
            report "Simulation finished!"
            severity failure;
    end process stimulus_process;
end architecture sim;