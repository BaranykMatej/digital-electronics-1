library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------
-- Entity declaration for testbench
------------------------------------------------------------
entity tb_mux_3bit_4to1 is
    -- Entity of testbench is always empty
end entity tb_mux_3bit_4to1;

------------------------------------------------------------
-- Architecture body for testbench
------------------------------------------------------------
architecture testbench of mux_3bit_4to1 is

    -- Local signals
    signal s_a           : std_logic_vector(2 downto 0);
    signal s_b           : std_logic_vector(2 downto 0);
    signal s_c           : std_logic_vector(2 downto 0);
    signal s_d           : std_logic_vector(2 downto 0);
    signal s_sel_i        : std_logic_vector(1 downto 0);
    signal s_B_less_A    : std_logic;
    -- todo: each input needs a signal - signal is just for the testbench, was it for implementing it for the bord, we would not need them... :)

begin
    -- Connecting testbench signals with comparator_2bit
    -- entity (Unit Under Test)
    uut_mux_3bit_4to1 : entity work.mux_3bit_4to1
        port map(
            sel => "00",
            a           => s_a,
            b           => s_b,
--            B_greater_A_o => s_B_greater_A,
--            B_equals_A_o  => s_B_equals_A,
            B_less_A_o    => s_B_less_A
        );

    --------------------------------------------------------
    -- Data generation process
    --------------------------------------------------------
    p_stimulus : process
    begin
        -- Report a note at the beginning of stimulus process
        report "Stimulus process started";
        report "Stimulus process finished";
        wait; -- Data generation process is suspended forever
    end process p_stimulus;

end architecture testbench;