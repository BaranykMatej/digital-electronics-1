library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

entity interval_timer is
    port(
    clk     :   in std_logic;
    reset   :   in std_logic;
    start   :   in std_logic;
    round_time : in unsigned(23 downto 0);
    pause_time : in unsigned(23 downto 0);
    num_rounds : in unsigned (7 downto 0);
    done       : out std_logic;
    status     : out std_logic_vector (1 downto 0)
   );
 end entity interval_timer;
 
 architecture behavior of interval_timer is
    signal current_time : unsigned (23 downto 0) := (others => '0');
    signal current_round : unsigned (7 downto 0) := (others => '0');
    signal timer_state  : std_logic_vector(1 downto 0) := "00";
    
 begin
    process (clk, reset)
    begin
        if reset = '1' then
        current_time <= (others => '0');
        current_round <= (others => '0');
        timer_state <= "00";
        
       elsif rising_edge (clk) then 
       if start = '1' then
        timer_state <= "01";
       end if;  

        case timer_state is
        when "00" => 
            current_time <= (others => '0');
            current_round <= (others => '0');
        when "01" =>
            if current_time < round_time then
             current_time <= current_time +1;
         else
            current_time <= (others => '0');
            current_round <= current_round +1;
            if current_round < num_rounds then 
            timer_state <= "01";
         else
            timer_state <= "00";
         end if;
         end if;
                when others =>
                timer_state <= "00";
           end case;
        end if;
end process;

done <= '1' when current_round = num_rounds else '0';
status <= timer_state;
end architecture behavior;