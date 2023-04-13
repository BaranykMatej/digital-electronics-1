----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2023 12:38:51 PM
-- Design Name: 
-- Module Name: input - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input is
    Port ( num_round : in STD_LOGIC_VECTOR (5 downto 0);
           pause : in STD_LOGIC_VECTOR (4 downto 0);
           timer : in STD_LOGIC_VECTOR (4 downto 0);
           out_round : out STD_LOGIC_VECTOR (5 downto 0);
           out_pause : out STD_LOGIC_VECTOR (4 downto 0);
           out_timer : out STD_LOGIC_VECTOR (4 downto 0));
end input;

architecture Behavioral of input is

begin


end Behavioral;
