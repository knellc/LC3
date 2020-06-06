library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LC3 is
    Port ( clkIn      : in    std_logic;
           rstIn      : in    std_logic;
           memDataIn  : in    std_logic_vector(15 downto 0);
           memWrEnOut :   out std_logic;
           --memRdEnOut :   out std_logic;
           memAddrOut :   out std_logic_vector(15 downto 0);
           memDataOut :   out std_logic_vector(15 downto 0));
end LC3;

architecture Behavioral of LC3 is

  -- CONSTANTS
  
  -- TYPES
  
  -- SIGNALS
  -- bus
  signal sysBus      : std_logic_vector(15 downto 0);
  signal aluBusEn    : std_logic;
  signal pcBusEn     : std_logic;
  signal marBusEn    : std_logic;
  signal mdrBusEn    : std_logic;
  -- regFile
  signal regFileWrEn : std_logic;
  signal wrAddr      : std_logic_vector(2  downto 0);
  signal rdAddrA     : std_logic_vector(2  downto 0);
  signal rdAddrB     : std_logic_vector(2  downto 0);
  signal rdDataA     : std_logic_vector(15 downto 0);
  signal rdDataB     : std_logic_vector(15 downto 0);
  -- alu
  signal aluFunc     : std_logic_vector(1  downto 0);
  signal aluResult   : signed(15 downto 0);
  signal aluB        : signed(15 downto 0);
  -- pc
  signal pcWrEn      : std_logic;
  --signal pcAlt       : std_logic_vector(15 downto 0);
  signal pcVal       : std_logic_vector(15 downto 0);
  -- ir
  signal irVal       : std_logic_vector(15 downto 0);
  signal irWrEn      : std_logic;
  signal irAlu       : std_logic_vector(15 downto 0);
  signal irMemAddr   : std_logic_vector(15 downto 0);
  signal irPc11      : std_logic_vector(15 downto 0);
  signal irPc9       : std_logic_vector(15 downto 0);
  signal irPc6       : std_logic_vector(15 downto 0);
  -- nzp
  signal nzpWrEn     : std_logic;
  signal flagNeg     : std_logic;
  signal flagZero    : std_logic;
  signal flagPos     : std_logic;
  -- control
  signal aluCtrl     : std_logic;
  signal pcCtrl      : std_logic_vector(1  downto 0);
  signal addr1Ctrl   : std_logic;
  signal addr2Ctrl   : std_logic_vector(1  downto 0);
  signal memAddrCtrl : std_logic;
  signal mdrCtrl     : std_logic;
  -- memory
  signal memDataR    : std_logic_vector(15 downto 0);
  signal memAddr     : std_logic_vector(15 downto 0);
  signal mdrMux      : std_logic_vector(15 downto 0);
  signal marWrEn     : std_logic;
  signal mdrWrEn     : std_logic;  
  -- misc
  signal addr1Mux    : std_logic_vector(15 downto 0);
  signal addr2Mux    : std_logic_vector(15 downto 0);
  signal addrNew     : std_logic_vector(15 downto 0);

begin

  -- MAR
  marProc : process (clkIn, rstIn)
  begin
    if (rstIn = '1') then
      memAddrOut <= (others => '0');
    elsif (rising_edge(clkIn)) then
      if (marWrEn = '1') then
        memAddrOut <= sysBus;
      end if;
    end if;
  end process marProc;

  --MDR Input Mux
  mdrMux <= memDataIn when mdrCtrl = '1' else sysBus;
 
  -- MDR 
  mdrProc : process (clkIn, rstIn)
  begin
    if (rstIn = '1') then
      memDataR <= (others => '0');
    elsif (rising_edge(clkIn)) then
      if (mdrWrEn = '1') then
        memDataR <= mdrMux;
      end if;
    end if;
  end process mdrProc;
  
  memDataOut <= memDataR;
  
  -- Bus Tri-States
  sysBus <= std_logic_vector(aluResult) when aluBusEn = '1' else
            pcVal                       when pcBusEn  = '1' else
            memAddr                     when marBusEn = '1' else
            memDataR                    when mdrBusEn = '1' else
            (others => '0');
  
  -- ALU Port B Input
  aluB <= signed(rdDataB) when aluCtrl = '0' else signed(irAlu);
  
  -- Addr1 Mux
  addr1Mux <= rdDataA when addr1Ctrl = '1' else pcVal;
  
  -- Addr2 Mux
  addr2Mux <= irPc11 when addr2Ctrl = "11" else
              irPc9  when addr2Ctrl = "10" else
              irPc6  when addr2Ctrl = "01" else
              (others => '0');
  
  -- Compute New Address
  addrNew <= std_logic_vector(to_unsigned(to_integer(unsigned(addr1Mux)) + to_integer(signed(addr2Mux)), 16));
  
  -- MemAddr Mux
  memAddr <= irMemAddr when memAddrCtrl = '1' else addrNew;
  
  -- Register File (8x16)
  regFile : entity work.regFile
    port map (clkIn      => clkIn,
              rstIn      => rstIn,
              wrEnIn     => regFileWrEn,
              wrDataIn   => sysBus,
              wrAddrIn   => wrAddr,
              rdAddrAIn  => rdAddrA,
              rdAddrBIn  => rdAddrB,
              rdDataAOut => rdDataA,
              rdDataBOut => rdDataB);
  
  -- ALU
  ALU : entity work.alu
    port map (aIn       => signed(rdDataA),
              bIn       => aluB,
              funcIn    => aluFunc,
              resultOut => aluResult);
  
  -- PC
  PC : entity work.pc
    port map (clkIn    => clkIn,
              rstIn    => rstIn,
              pcWrEnIn => pcWrEn,
              pcCtrlIn => pcCtrl,
              busIn    => sysBus,
              pcAltIn  => addrNew,
              pcOut    => pcVal);
  
  -- IR
  IR : entity work.ir
  port map (clkIn        => clkIn,
            rstIn        => rstIn,
            wrEnIn       => irWrEn,
            busIn        => sysBus,
            irAluOut     => irAlu,
            irMemAddrOut => irMemAddr,
            irPc11Out    => irPc11,
            irPc9Out     => irPc9,
            irPc6Out     => irPc6,
            irOut        => irVal);
  
  -- NZP
  NZP : entity work.flagReg
    port map (clkIn   => clkIn,
              rstIn   => rstIn,
              wrEnIn  => nzpWrEn,
              aluIn   => sysBus,
              negOut  => flagNeg,
              zeroOut => flagZero,
              posOut  => flagPos);
  
  -- Control
  Control : entity work.control
    port map (clkIn          => clkIn,
              rstIn          => rstIn,
              irIn           => irVal,
              negIn          => flagNeg,
              zeroIn         => flagZero,
              posIn          => flagPos,
              aluFuncOut     => aluFunc,
              aluCtrlOut     => aluCtrl,
              pcCtrlOut      => pcCtrl,
              addr1CtrlOut   => addr1Ctrl,
              addr2CtrlOut   => addr2Ctrl,
              memAddrCtrlOut => memAddrCtrl,
              mdrCtrlOut     => mdrCtrl,
              regRdAddrAOut  => rdAddrA,
              regRdAddrBOut  => rdAddrB,
              regWrAddrOut   => wrAddr,
              regFileWrEnOut => regFileWrEn,
              pcWrEnOut      => pcWrEn,
              irWrEnOut      => irWrEn,
              nzpWrEnOut     => nzpWrEn,
              marWrEnOut     => marWrEn,
              mdrWrEnOut     => mdrWrEn,
              memWrEnOut     => memWrEnOut,
              aluBusEnOut    => aluBusEn,
              pcBusEnOut     => pcBusEn,
              marBusEnOut    => marBusEn,
              mdrBusEnOut    => mdrBusEn);

end Behavioral;
