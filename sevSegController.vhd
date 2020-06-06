----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2020 04:39:20 PM
-- Design Name: 
-- Module Name: sevSegController - Behavioral
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

entity sevSegController is
    Port ( clkIn   : in    STD_LOGIC;
           rstIn   : in    STD_LOGIC;
           char0In : in    STD_LOGIC_VECTOR (3 downto 0);
           char1In : in    STD_LOGIC_VECTOR (3 downto 0);
           char2In : in    STD_LOGIC_VECTOR (3 downto 0);
           char3In : in    STD_LOGIC_VECTOR (3 downto 0);
           char4In : in    STD_LOGIC_VECTOR (3 downto 0);
           char5In : in    STD_LOGIC_VECTOR (3 downto 0);
           char6In : in    STD_LOGIC_VECTOR (3 downto 0);
           char7In : in    STD_LOGIC_VECTOR (3 downto 0);
           anOut   :   out STD_LOGIC_VECTOR (7 downto 0);
           charOut :   out STD_LOGIC_VECTOR (7 downto 0));
end sevSegController;

architecture Behavioral of sevSegController is
  signal pulse1KHz : std_logic;
  signal muxSel    : unsigned(2 downto 0);
  signal digit     : std_logic_vector(3 downto 0);
begin

  -- 1 KHz Pulse Generator
  PulseGen_1KHz : entity work.pulseGen
    port map (
      clkIn => clkIn,
      rstIn => rstIn,
      maxCntIn => "000" & x"0186A0", -- 100,000 counts for 1KHz "000" & x"0186A0"
      pulseOut => pulse1KHz);

  -- Seven Segment Decoder
  with digit select
    charOut <= 
      "11000000" when x"0",
      "11111001" when x"1",
      "10100100" when x"2",
      "10110000" when x"3",
      "10011001" when x"4",
      "10010010" when x"5",
      "10000010" when x"6",
      "11111000" when x"7",
      "10000000" when x"8",
      "10010000" when x"9",
      "10001000" when x"A",
      "10000011" when x"B",
      "11000110" when x"C",
      "10100001" when x"D",
      "10000110" when x"E",
      "10001110" when others;

  -- A counter that calculates the current Anode with its associated character
  -- uses pulse1KHz as the enable for the counter
  charSelect : process (clkIn, rstIn)
  begin
    if (rstIn = '1') then
      muxSel <= (others => '0');
    elsif (rising_edge(clkIn)) then
      if (pulse1KHz = '1') then
        muxSel <= muxSel + 1;
      end if;
    end if;
  end process;

  -- Character Selection Mux
  with muxSel select
    digit <= char0In when "000",
             char1In when "001",
             char2In when "010",
             char3In when "011",
             char4In when "100",
             char5In when "101",
             char6In when "110",
             char7In when others;
           
  -- Anode Decoder
  with muxSel select
    anOut <= "11111110" when "000",
             "11111101" when "001",
             "11111011" when "010",
             "11110111" when "011",
             "11101111" when "100",
             "11011111" when "101",
             "10111111" when "110",
             "01111111" when others;
           
end Behavioral;
