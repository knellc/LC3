----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2020 12:09:45 PM
-- Design Name: 
-- Module Name: ir - Behavioral
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

entity ir is
  Port ( clkIn        : in    std_logic;
         rstIn        : in    std_logic;
         wrEnIn       : in    std_logic;
         busIn        : in    std_logic_vector(15 downto 0);
         irAluOut     :   out std_logic_vector(15 downto 0);
         irMemAddrOut :   out std_logic_vector(15 downto 0);
         irPc11Out    :   out std_logic_vector(15 downto 0);
         irPc9Out     :   out std_logic_vector(15 downto 0);
         irPc6Out     :   out std_logic_vector(15 downto 0);
         irOut        :   out std_logic_vector(15 downto 0));
end ir;

architecture Behavioral of ir is

  signal irR : std_logic_vector(15 downto 0);

begin

  process (clkIn, rstIn)
  begin
    if (rstIn = '1') then
      irR <= (others => '0');
    elsif (rising_edge(clkIn)) then
      if (wrEnIn = '1') then
        irR <= busIn;
      end if;
    end if;
  end process;

  irOut        <= irR;
  irAluOut     <= std_logic_vector(resize(  signed(irR(4  downto 0)), irAluOut'length));
  irMemAddrOut <= std_logic_vector(resize(unsigned(irR(7  downto 0)), irMemAddrOut'length));
  irPc11Out    <= std_logic_vector(resize(  signed(irR(10 downto 0)), irPc11Out'length));
  irPc9Out     <= std_logic_vector(resize(  signed(irR(8  downto 0)), irPc9Out'length));
  irPc6Out     <= std_logic_vector(resize(  signed(irR(5  downto 0)), irPc6Out'length));

end Behavioral;
