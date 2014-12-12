----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:07:44 12/09/2014 
-- Design Name: 
-- Module Name:    TOP - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
    Port ( CLK_A : in  STD_LOGIC;
           CLK_B : in  STD_LOGIC;
           i_LVAL : in  STD_LOGIC;
           i_DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           i_GAIN : in  STD_LOGIC_VECTOR (7 downto 0);
           i_RST : in  STD_LOGIC;
           o_LVAL : out  STD_LOGIC;
           o_DATA : out  STD_LOGIC_VECTOR (15 downto 0));
end TOP;

architecture Behavioral of TOP is

COMPONENT MAL
  PORT (
    clk : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    p : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) --geht da s?
  );
END COMPONENT;


COMPONENT FIFO
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC
  );
END COMPONENT;




signal DATA_BUS:std_logic_vector (15 downto 0); 
signal OVERFLOW: STD_LOGIC;
signal MULT_SP:std_logic_vector(7 downto 0);
signal semaphor: STD_LOGIC := '0';
begin


MULTIPLIER : MAL
  PORT MAP (
    clk => CLK_A, 
    a => i_DATA,
    b => i_GAIN,
    p => out_MULT
  );



FIRST_IN_FIRST_OUT : FIFO
  PORT MAP (
    rst => i_RST,
    wr_clk => wr_clk,
    rd_clk => rd_clk,
    din => din,
    wr_en => wr_en,
    rd_en => rd_en,
    dout => dout,
    full => full,
    empty => empty,
    almost_empty => almost_empty,
    prog_full => prog_full
 );

--SORGT DAFÜR DASS KEIN OVERFLOW GESCHIEHT BEI DER MULT.PLIKATION
MULTIPLIZIERER: process(CLK_A,i_LVAL)
begin

	if rising_edge(CLK_A) then
		if(i_LVAL = '1') then --nur bei validen Daten
		
		
			if ((i_DATA(7) = '1' and i_GAIN /= "00000000") or (i_DATA(6) = '1' and i_GAIN > "00000010")
				or (i_DATA(5) = '1' and i_GAIN > "00000100") or (i_DATA(4) = '1' and i_GAIN > "00001000")
				or (i_DATA(3) = '1' and i_GAIN > "00010000") or (i_DATA(2) = '1' and i_GAIN > "00100000")
				or (i_DATA(1) = '1' and i_GAIN > "0100000") or (i_DATA(0) = '1' and i_GAIN > "10000000"))
			then
				p <= x"0FFF"; --Ausgang des Multiplizieres auf den Maximalwert stellen
			end if;
	
			--ZUSAMMENFASSEN VON 2 mal 8-BIT -> zu einem 16 Bit vektor
			if(semaphor = '0') then
				MULT_SP <= p;
				semaphor <= '1';
			else
				DATA_BUS(15 downto 8) <= MULT_SP(11 downto 4);
				DATA_BUS(7 downto 0) <= p(11 downto 4);
				semaphor <= '0';
			end if;



	end if;
	
	
	
	
	
	
	
	
	end if;
end process MULTIPLIZIERER;






end Behavioral;

