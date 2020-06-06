----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2020 11:54:25 AM
-- Design Name: 
-- Module Name: pc - Behavioral
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

entity pc is
  Port ( clkIn    : in    std_logic;
         rstin    : in    std_logic;
         pcWrEnIn : in    std_logic;
         pcCtrlIn : in    std_logic_vector(1  downto 0);
         busIn    : in    std_logic_vector(15 downto 0);
         pcAltIn  : in    std_logic_vector(15 downto 0);
         pcOut    :   out std_logic_vector(15 downto 0));
end pc;

architecture Behavioral of pc is

  signal pcR    : std_logic_vector(15 downto 0);
  signal pcData : std_logic_vector(15 downto 0);
  signal pcInc  : std_logic_vector(15 downto 0);

begin

  pcInc <= std_logic_vector(unsigned(pcR) + 1);

  pcData <= pcInc   when pcCtrlIn = "00" else
            pcAltIn when pcCtrlIn = "01" else
            busIn;

  process (clkIn, rstIn)
  begin
    if (rstIn = '1') then
      pcR <= (others => '0');
    elsif (rising_edge(clkIn)) then
      if (pcWrEnIn = '1') then
        pcR <= pcData;
      end if;
    end if;
  end process;

  pcOut <= pcR;

end Behavioral;
