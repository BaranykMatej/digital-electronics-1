----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2023 11:46:09 AM
-- Design Name: 
-- Module Name: top - Behavioral
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


library ieee;
  use ieee.std_logic_1164.all;

----------------------------------------------------------
-- Entity declaration for top level
----------------------------------------------------------

entity top is
  port (
    CLK100MHZ : in    std_logic; --! Main clock
    LED16_R   : out   std_logic; --! South: Red
    LED16_G   : out   std_logic; --! South: Green
    LED16_B   : out   std_logic; --! South: Blue
    LED17_R   : out   std_logic; --! West: Red
    LED17_G   : out   std_logic; --! West: Green
    LED17_B   : out   std_logic; --! West: Blue
    BTNC      : in    std_logic --! Synchronous reset
  );
end entity top;

----------------------------------------------------------
-- Architecture body for top level
----------------------------------------------------------

architecture behavioral of top is

begin
  --------------------------------------------------------
  -- Instance (copy) of tlc entity
  --------------------------------------------------------
  tlc : entity work.tlc
    port map (
      clk      => CLK100MHZ,
      south(2) => LED16_R,
      -- MAP OTHER RGB LEDS (SOUTH and WEST) HERE
      south(1) => LED16_G,
      south(0) => LED16_B,
      west(2)  => LED17_R,
      west(1)  => LED17_G,
      west(0)  => LED17_B,
      rst      => BTNC
    );

end architecture behavioral;