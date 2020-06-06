----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2020 12:31:49 PM
-- Design Name: 
-- Module Name: flagReg - Behavioral
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

entity flagReg is
  Port ( clkIn   : in    std_logic;
         rstIn   : in    std_logic;
         wrEnIn  : in    std_logic;
         aluIn   : in    std_logic_vector(15 downto 0);
         negOut  :   out std_logic;
         zeroOut :   out std_logic;
         posOut  :   out std_logic);
end flagReg;

architecture Behavioral of flagReg is

  signal neg   : std_logic;
  signal zero  : std_logic;
  signal pos   : std_logic;
  signal negR  : std_logic;
  signal zeroR : std_logic;
  signal posR  : std_logic;

begin

  neg  <= '1' when aluIn(15) = '1'                else '0';
  zero <= '1' when aluIn = x"0000"                else '0';
  pos  <= '1' when aluIn(15) = '0' and zero = '0' else '0';

  process (clkIn, rstIn)
  begin
    if (rstIn = '1') then
      negR  <= '0';
      zeroR <= '0';
      posR  <= '0';
    elsif (rising_edge(clkIn)) then
      if (wrEnIn = '1') then
        negR  <= neg;
        zeroR <= zero;
        posR  <= pos;
      end if;
    end if;
  end process;

  negOut  <= negR;
  zeroOut <= zeroR;
  posOut  <= posR;

end Behavioral;
