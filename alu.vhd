library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
  Port ( aIn       : in    signed(15 downto 0);
         bIn       : in    signed(15 downto 0);
         funcIn    : in    std_logic_vector(1 downto 0);
         resultOut :   out signed(15 downto 0));
end alu;

architecture Behavioral of alu is

begin

  resultOut <= aIn + bIn   when funcIn = "00" else
               aIn and bIn when funcIn = "01" else
               not aIn     when funcIn = "10" else
               aIn;

end Behavioral;
