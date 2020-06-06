----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2020 04:58:14 PM
-- Design Name: 
-- Module Name: LC3_top_tb - Behavioral
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

entity LC3_top_tb is
end LC3_top_tb;

architecture Behavioral of LC3_top_tb is

  signal clk, rst     : std_logic;
  signal seg7Cath, an : std_logic_vector(7 downto 0);

begin

  rst <= '1', '0' after 100 ns;

  clkProc : process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process clkProc;

  dut : entity work.LC3_top
    port map (sysClkIn    => clk,
              sysRstIn    => rst,
              seg7CathOut => seg7Cath,
              anOut       => an);

end Behavioral;
