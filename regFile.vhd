library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity regFile is
  Port ( clkIn      : in    std_logic;
         rstIn      : in    std_logic;
         wrEnIn     : in    std_logic;
         wrDataIn   : in    std_logic_vector(15 downto 0);
         wrAddrIn   : in    std_logic_vector(2  downto 0);
         rdAddrAIn  : in    std_logic_vector(2  downto 0);
         rdAddrBIn  : in    std_logic_vector(2  downto 0);
         rdDataAOut :   out std_logic_vector(15 downto 0);
         rdDataBOut :   out std_logic_vector(15 downto 0));
end regFile;

architecture Behavioral of regFile is

  -- types
  type regFile is array (0 to 7) of std_logic_vector(15 downto 0);
  
  -- signals
  signal regsDataR : regFile;

begin

  process (clkIn, rstIn)
  begin
    if (rstIn = '1') then
      regsDataR <= (0 => x"0002",
                    1 => x"AAAA",
                    others => x"0000");
    elsif (rising_edge(clkIn)) then
      if (wrEnIn = '1') then
        regsDataR(to_integer(unsigned(wrAddrIn))) <= wrDataIn;
      end if;
    end if;
  end process;

  rdDataAOut <= regsDataR(to_integer(unsigned(rdAddrAIn)));
  rdDataBOut <= regsDataR(to_integer(unsigned(rdAddrBIn)));

end Behavioral;
