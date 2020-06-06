----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2020 04:06:50 PM
-- Design Name: 
-- Module Name: sysMem - Behavioral
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

entity sysMem is
  Port ( clkIn      : in    std_logic;
         rstIn      : in    std_logic;
         memDataIn  : in    std_logic_vector(15 downto 0);
         memAddrIn  : in    std_logic_vector(15 downto 0);
         memWrEnIn  : in    std_logic;
         memDataOut :   out std_logic_vector(15 downto 0));
end sysMem;

architecture Behavioral of sysMem is

  type memArray is array (0 to 1023) of std_logic_vector(15 downto 0);

  signal memR : memArray := (0  => x"5020", -- fibonacci program
                             1  => x"5260",
                             2  => x"1261",
                             3  => x"320D",
                             4  => x"300E",
                             5  => x"220B",
                             6  => x"1001",
                             7  => x"300A",
                             8  => x"3207",
                             9  => x"3007",
                             10 => x"2005",
                             11 => x"2203",
                             12 => x"1201",
                             13 => x"09F6",
                             14 => x"0FF1",
                             15 => x"8001",
                             16 => x"0000",
                             17 => x"0001",
                             18 => x"0000",
                             19 => x"0000",
                             others => x"0000");
  
begin
--  --memR(22)(0) <= dispIntIn;
--  dispIntProc : process(clkIn, rstIn)
--  begin
--    if (rstIn = '1') then
--    elsif (rising_edge(clkIn)) then
--      memR(24)(0) <= dispIntIn;
--    end if;
--  end process dispIntProc;

  memProc : process (clkIn, rstIn)
  begin
    if (rstIn = '1') then
    elsif (rising_edge(clkIn)) then
      if (memWrEnIn = '1') then
        memR(to_integer(unsigned(memAddrIn))) <= memDataIn;
      end if;
    end if;
  end process memProc;

  memDataOut <= memR(to_integer(unsigned(memAddrIn)));

end Behavioral;
