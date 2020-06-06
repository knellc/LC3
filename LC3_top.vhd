----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2020 03:59:58 PM
-- Design Name: 
-- Module Name: LC3_top - Behavioral
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

entity LC3_top is
  Port ( sysClkIn    : in    std_logic;
         sysRstIn    : in    std_logic;
         seg7CathOut :   out std_logic_vector(7 downto 0);
         anOut       :   out std_logic_vector(7 downto 0)
         );
end LC3_top;

architecture Behavioral of LC3_top is

  -- constants
  constant DISPLAY_OUT_ADDRESS : std_logic_vector(15 downto 0) := x"0013";
  constant MAX_DISPLAY_TIMER   : unsigned(26 downto 0)         := "000" & x"0BEBC2"; -- Pulse every second  "101" & x"F5E100"

  -- signals
  signal memDataRd        : std_logic_vector(15 downto 0);
  signal memDataWr        : std_logic_vector(15 downto 0);
  signal memAddr          : std_logic_vector(15 downto 0);
  signal memWrEn          : std_logic;
  signal displayValR      : std_logic_vector(15 downto 0);
  signal onesVal          : std_logic_vector(3 downto 0);
  signal tensVal          : std_logic_vector(3 downto 0);
  signal hundredsVal      : std_logic_vector(3 downto 0);
  signal thousandsVal     : std_logic_vector(3 downto 0);
  signal tenThousandsVal  : std_logic_vector(3 downto 0);
  signal displayTimerDone : std_logic;
  signal slowClk          : std_logic;

begin

  LC3_core : entity work.LC3
    port map (clkIn      => slowClk,
              rstIn      => sysRstIn,
              memDataIn  => memDataRd,
              memWrEnOut => memWrEn,
              memAddrOut => memAddr,
              memDataOut => memDataWr);

  System_Memory : entity work.sysMem
    port map(clkIn      => sysClkIn,
             rstIn      => sysRstIn,
             memDataIn  => memDataWr,
             memAddrIn  => memAddr,
             memWrEnIn  => memWrEn,
             memDataOut => memDataRd);

  DisplayTimer : entity work.pulseGen
    port map (clkIn    => sysClkIn,
              rstIn    => sysRstIn,
              maxCntIn => MAX_DISPLAY_TIMER,
              pulseOut => displayTimerDone);
  
  process (sysClkIn, sysRstIn)
  begin
    if (sysRstIn = '1') then
      slowClk <= '0';
    elsif (rising_edge(sysClkIn)) then
      if (displayTimerDone = '1') then
        slowClk <= not slowClk;
      end if;
    end if;
  end process;

  DisplayOutReg : process (sysClkIn, sysRstIn)
  begin
    if (sysRstIn = '1') then
      displayValR <= (others => '0');
    elsif (rising_edge(sysClkIn)) then
      if (memWrEn = '1' and memAddr = DISPLAY_OUT_ADDRESS) then
        displayValR <= memDataWr;
      end if;
    end if;
  end process DisplayOutReg;

  onesVal         <= std_logic_vector(to_signed( to_integer(signed(displayValR))        mod 10, 4));
  tensVal         <= std_logic_vector(to_signed((to_integer(signed(displayValR))/10)    mod 10, 4));
  hundredsVal     <= std_logic_vector(to_signed((to_integer(signed(displayValR))/100)   mod 10, 4));
  thousandsVal    <= std_logic_vector(to_signed((to_integer(signed(displayValR))/1000)  mod 10, 4));
  tenThousandsVal <= std_logic_vector(to_signed((to_integer(signed(displayValR))/10000) mod 10, 4));
  
  
  

  seven_Seg : entity work.sevSegController
    port map ( clkIn   => sysClkIn,
               rstIn   => sysRstIn,
               char0In => onesVal,
               char1In => tensVal,
               char2In => hundredsVal,
               char3In => thousandsVal,
               char4In => tenThousandsVal,
               char5In => x"0",
               char6In => x"0",
               char7In => x"0",
               anOut   => anOut,
               charOut => seg7CathOut);

end Behavioral;
