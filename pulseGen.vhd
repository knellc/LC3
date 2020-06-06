----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2020 04:38:04 PM
-- Design Name: 
-- Module Name: pulseGen - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity pulseGen is
    Port ( clkIn    : in    std_logic;
           rstIn    : in    std_logic;
           maxCntIn : in    unsigned(26 downto 0);
           pulseOut :   out std_logic);
end pulseGen;

architecture Behavioral of pulseGen is
  signal pulseCnt : unsigned(26 downto 0);
  signal clear : std_logic;
begin
  --Pulse Generator
  process(clkIn, rstIn)
  begin
    if(rstIn = '1') then
      pulseCnt <= (others=>'0');
    elsif(rising_edge(clkIn)) then
      if (clear = '1') then
        pulseCnt <= (others=>'0');
      else
        pulseCnt <= pulseCnt + 1;
      end if;
    end if;
  end process;

  clear <= '1' when (pulseCnt = maxCntIn) else '0';
  pulseOut <= clear;
end Behavioral;

