----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2020 02:28:15 PM
-- Design Name: 
-- Module Name: control - Behavioral
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

entity control is
  Port ( clkIn          : in    std_logic;
         rstIn          : in    std_logic;
         irIn           : in    std_logic_vector(15 downto 0);
         negIn          : in    std_logic;
         zeroIn         : in    std_logic;
         posIn          : in    std_logic;
         aluFuncOut     :   out std_logic_vector(1 downto 0);
         aluCtrlOut     :   out std_logic;
         pcCtrlOut      :   out std_logic_vector(1 downto 0);
         addr1CtrlOut   :   out std_logic;
         addr2CtrlOut   :   out std_logic_vector(1 downto 0);
         memAddrCtrlOut :   out std_logic;
         mdrCtrlOut     :   out std_logic;
         regRdAddrAOut  :   out std_logic_vector(2 downto 0);
         regRdAddrBOut  :   out std_logic_vector(2 downto 0);
         regWrAddrOut   :   out std_logic_vector(2 downto 0);
         regFileWrEnOut :   out std_logic;
         pcWrEnOut      :   out std_logic;
         irWrEnOut      :   out std_logic;
         nzpWrEnOut     :   out std_logic;
         marWrEnOut     :   out std_logic;
         mdrWrEnOut     :   out std_logic;
         memWrEnOut     :   out std_logic;
         aluBusEnOut    :   out std_logic;
         pcBusEnOut     :   out std_logic;
         marBusEnOut    :   out std_logic;
         mdrBusEnOut    :   out std_logic);
end control;

architecture Behavioral of control is

  -- types
  type controlFSM is (FETCH_1, FETCH_2, FETCH_3, DECODE_1, DECODE_2, INSTR_LD_ST_1, INSTR_LD_ST_2, INSTR_LD_ST_3, INSTR_LD_ST_4);
  
  -- signals
  signal controlFSMR  : controlFSM;
  signal opcode       : std_logic_vector(3 downto 0);
  signal srcReg1      : std_logic_vector(2 downto 0);
  signal srcReg2      : std_logic_vector(2 downto 0);
  signal dstReg       : std_logic_vector(2 downto 0);
  signal srcRegSt     : std_logic_vector(2 downto 0);
  signal srcRegBase   : std_logic_vector(2 downto 0);
  
  signal aluFuncR     : std_logic_vector(1 downto 0);
  signal nzp          : std_logic_vector(2 downto 0);
  signal neg          : std_logic;
  signal zero         : std_logic;
  signal pos          : std_logic;
  
  signal pcBusEnR     : std_logic;
  signal marWrEnR     : std_logic;
  signal mdrWrEnR     : std_logic;
  signal mdrBusEnR    : std_logic;
  signal irWrEnR      : std_logic;
  signal pcWrEnR      : std_logic;
  signal aluBusEnR    : std_logic;
  signal regFileWrEnR : std_logic;
  signal nzpWrEnR     : std_logic;
  signal marBusEnR    : std_logic;
  signal memWrEnR     : std_logic;
  
  signal mdrCtrlR     : std_logic;
  signal aluCtrlR     : std_logic;
  signal pcCtrlR      : std_logic_vector(1 downto 0);
  signal addr1CtrlR   : std_logic;
  signal addr2CtrlR   : std_logic_vector(1 downto 0);
  signal memAddrCtrlR : std_logic;
  
  signal regRdAddrAR  : std_logic_vector(2 downto 0);
  signal regRdAddrBR  : std_logic_vector(2 downto 0);
  signal regWrAddrR   : std_logic_vector(2 downto 0);

begin

  opcode     <= irIn(15 downto 12);
  srcReg1    <= irIn(8  downto  6);
  srcReg2    <= irIn(2  downto  0);
  dstReg     <= irIn(11 downto  9);
  srcRegSt   <= irIn(11 downto  9); -- Source Reg for Store instructions
  srcRegBase <= irIn(8  downto  6); -- Base Reg
  
  neg        <= irIn(11) and negIn;
  zero       <= irIn(10) and zeroIn;
  pos        <= irIn(9)  and posIn;

  -- could also use decoder for microinstructions instead
  -- all instructions except for trap and rti have been implemented
  process (clkIn, rstIn)
  begin
    if (rstIn = '1') then
      controlFSMR <= FETCH_1;
      pcBusEnR               <= '0';
      marWrEnR               <= '0';
      mdrWrEnR               <= '0';
      mdrCtrlR               <= '0';
      mdrBusEnR              <= '0';
      irWrEnR                <= '0';
      pcWrEnR                <= '0';
      aluBusEnR              <= '0';
      regFileWrEnR           <= '0';
      regRdAddrAR            <= (others => '0');
      regRdAddrBR            <= (others => '0');
      regWrAddrR             <= (others => '0');
      aluCtrlR               <= '0';
      aluFuncR               <= (others => '0');
      pcCtrlR                <= (others => '0');
      nzpWrEnR               <= '0';
      addr1CtrlR             <= '0';
      addr2CtrlR             <= (others => '0');
      memAddrCtrlR           <= '0';
      marBusEnR              <= '0';
      memWrEnR               <= '0';
    elsif (rising_edge(clkIn)) then
      pcBusEnR               <= '0';
      marWrEnR               <= '0';
      mdrWrEnR               <= '0';
      mdrBusEnR              <= '0';
      irWrEnR                <= '0';
      pcWrEnR                <= '0';
      aluBusEnR              <= '0';
      regFileWrEnR           <= '0';
      nzpWrEnR               <= '0';
      marBusEnR              <= '0';
      memWrEnR               <= '0';
      case controlFSMR is
        when FETCH_1 =>
          pcCtrlR            <= "00";
          pcBusEnR           <= '1';
          marWrEnR           <= '1';
          mdrCtrlR           <= '1';
          controlFSMR        <= FETCH_2;
        when FETCH_2 =>
          mdrWrEnR           <= '1';
          controlFSMR        <= FETCH_3;
        when FETCH_3 =>
          mdrBusEnR          <= '1';
          irWrEnR            <= '1';
          pcWrEnR            <= '1';
          controlFSMR        <= DECODE_1;
        when DECODE_1 =>
          -- wait for opcode to register
          controlFSMR        <= DECODE_2;
        when DECODE_2 =>
          if (opcode(1 downto 0) = "00") then -- jumps and branches
            if (opcode(3 downto 2) = "00") then -- br
              if (neg = '1' or zero = '1' or pos = '1') then
                addr1CtrlR   <= '0'; -- load pc with offset
                addr2CtrlR   <= "10";
                pcCtrlR      <= "01";
                pcWrEnR      <= '1';
              end if;
              controlFSMR    <= FETCH_1;
            elsif (opcode(3 downto 2) = "11" or opcode(3 downto 2) = "01") then -- jmp or ret or jsr or jsrr
              regRdAddrAR    <= srcRegBase; -- load pc with base reg
              addr1CtrlR     <= '1';
              addr2CtrlR     <= "00";
              pcCtrlR        <= "01";
              pcWrEnR        <= '1';
              if (opcode(3 downto 2) = "01") then -- jsr or jsrr
                pcBusEnR     <= '1';
                regFileWrEnR <= '1';
                regWrAddrR   <= "111"; -- store pc in r7
                if (irIn(11) = '1') then
                  addr1CtrlR <= '0'; -- load pc with offset
                  addr2CtrlR <= "11";
                end if;
              end if;
              controlFSMR    <= FETCH_1;
            end if;
          elsif (opcode(1 downto 0) = "01") then -- do some math
            aluFuncR         <= opcode(3 downto 2);
            regRdAddrAR      <= srcReg1;
            if (irIn(5) = '0') then -- use src2
              regRdAddrBR <= srcReg2;
              aluCtrlR       <= '0'; -- set alu input port b to src2
            else
              aluCtrlR       <= '1'; -- set alu input port b to ir imm
            end if;
            regWrAddrR       <= dstReg;
            aluBusEnR        <= '1';
            regFileWrEnR     <= '1';
            nzpWrEnR         <= '1';
            controlFSMR      <= FETCH_1;
          elsif ((opcode(1 downto 0) = "11" or opcode(1 downto 0) = "10") and opcode /= x"F") then -- Store stuff or Load stuff
            aluFuncR         <= opcode(1 downto 0); -- pass through src1
            regWrAddrR       <= dstReg;
            memAddrCtrlR     <= '0';
            mdrCtrlR         <= '1';
            marBusEnR        <= '1';
            marWrEnR         <= '1';
            addr1CtrlR       <= '0';
            addr2CtrlR       <= "10";
            if (opcode(3 downto 2) = "00" or opcode(3 downto 2) = "01") then -- st or str or ld or ldr
              controlFSMR    <= INSTR_LD_ST_3;
              if (opcode(3 downto 2) = "01") then -- str or ldr
                regRdAddrAR  <= srcRegBase;
                addr1CtrlR   <= '1';
                addr2CtrlR   <= "01";
              end if;
            elsif (opcode(3 downto 2) = "11") then -- lea
              regFileWrEnR   <= '1';
              nzpWrEnR       <= '1';
              controlFSMR    <= FETCH_1;
            else -- sti or ldi
              controlFSMR    <= INSTR_LD_ST_1;
            end if;
          else -- invalid instruction, update to show
            controlFSMR      <= FETCH_1;
          end if;          
        when INSTR_LD_ST_1 =>
          mdrWrEnR           <= '1';
          controlFSMR        <= INSTR_LD_ST_2;         
        when INSTR_LD_ST_2 =>
          mdrBusEnR          <= '1';
          marWrEnR           <= '1';
          controlFSMR        <= INSTR_LD_ST_3;
        when INSTR_LD_ST_3 =>
          mdrCtrlR           <= '1'; -- Load
          mdrWrEnR           <= '1';
          if (opcode(1 downto 0) = "11") then -- Store
            mdrCtrlR         <= '0';
            regRdAddrAR      <= srcRegSt;
            aluBusEnR        <= '1';
          end if;
          controlFSMR        <= INSTR_LD_ST_4;
        when INSTR_LD_ST_4 =>
          if (opcode(1 downto 0) = "11") then -- Store
            memWrEnR         <= '1';
          else -- Load
            mdrBusEnR        <= '1';
            regFileWrEnR     <= '1';
            nzpWrEnR         <= '1';
          end if;
          controlFSMR        <= FETCH_1;
        when others =>
          controlFSMR        <= FETCH_1;
      end case;
    end if;
  end process;

  pcBusEnOut     <= pcBusEnR;
  marWrEnOut     <= marWrEnR;
  mdrWrEnOut     <= mdrWrEnR;
  mdrCtrlOut     <= mdrCtrlR;
  mdrBusEnOut    <= mdrBusEnR;
  irWrEnOut      <= irWrEnR;
  pcWrEnOut      <= pcWrEnR;
  aluBusEnOut    <= aluBusEnR;
  regFileWrEnOut <= regFileWrEnR;
  regRdAddrAOut  <= regRdAddrAR;
  regRdAddrBOut  <= regRdAddrBR;
  regWrAddrOut   <= regWrAddrR;
  aluCtrlOut     <= aluCtrlR;
  aluFuncOut     <= aluFuncR;
  pcCtrlOut      <= pcCtrlR;
  nzpWrEnOut     <= nzpWrEnR;
  addr1CtrlOut   <= addr1CtrlR;
  addr2CtrlOut   <= addr2CtrlR;
  memAddrCtrlOut <= memAddrCtrlR;
  marBusEnOut    <= marBusEnR;
  memWrEnOut     <= memWrEnR;

end Behavioral;
