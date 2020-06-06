----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2020 10:29:42 PM
-- Design Name: 
-- Module Name: lc3_tb - Behavioral
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

entity lc3_tb is
end lc3_tb;

architecture Behavioral of lc3_tb is

  type memArray is array (0 to 65535) of std_logic_vector(15 downto 0);

  signal clk, rst : std_logic;
  signal memDataI : std_logic_vector(15 downto 0);
  signal memWrEn  : std_logic;
  signal memAddr  : std_logic_vector(15 downto 0);
  signal memDataO : std_logic_vector(15 downto 0);
  signal memR     : memArray := (0  => x"9" & "111" & "001" & "111111",
                                 1  => x"1" & "001" & "001" & "1" & "01000",
                                 2  => x"1" & "001" & "001" & "0" & "00" & "000",
                                 3  => x"1" & "111" & "111" & "1" & "00011",
                                 4  => x"5" & "101" & "001" & "1" & "01010",
                                 5  => x"5" & "101" & "101" & "0" & "00" & "111",
                                 6  => x"1" & "110" & "101" & "1" & "11111",
                                 7  => x"9" & "100" & "110" & "111111",
                                 --stores
                                 --8  => x"3" & "000" & "001010100", -- st 9+84 = 93<-2
                                 --9  => x"B" & "001" & "001010011", -- sti 10+83 = 93 2<-aab4
                                 --10 => x"7" & "111" & "000" & "111111", -- str  2-1 = 1<-5558
                                 --loads
                                 8 => x"2" & "010" & "111111011", -- ld 12-5  reg2<-[7]
                                 9 => x"A" & "011" & "001010000", -- ldi 13+80=93<-2 reg3<-[2]
                                 10 => x"6" & "100" & "000" & "000110", -- ldr 2+6 -> reg4<-[8]
                                 11 => x"E" & "111" & "001010101", -- lea 15+85  reg5<-100
                                 -- jumps
                                 --15 => x"0" & "100" & "111110000", -- br (pass through) 
                                 --15 => x"0" & "001" & "111110000", -- br goto 0
                                 --12 => x"C" & "000" & "000" & "000000", -- jmp goto 2
                                 --12 => x"C" & "000" & "111" & "000000", -- ret goto x5558
                                 --12 => x"4" & "1" & "00000000101", -- jsr goto 18
                                 12 => x"4" & "000" & "000" & "000000", -- jsrr goto 2
                                 others => x"0000");

begin

  rst <= '1', '0' after 100 ns;

  clkProc : process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process clkProc;

  dut : entity work.LC3
    port map (clkIn      => clk,
              rstIn      => rst,
              memDataIn  => memDataI,
              memWrEnOut => memWrEn,
              memAddrOut => memAddr,
              memDataOut => memDataO);

  memProc : process (clk, rst)
  begin
    if (rst = '1') then
    elsif (rising_edge(clk)) then
      if (memWrEn = '1') then
        memR(to_integer(unsigned(memAddr))) <= memDataO;
      end if;
    end if;
  end process memProc;

  memDataI <= memR(to_integer(unsigned(memAddr)));

end Behavioral;
