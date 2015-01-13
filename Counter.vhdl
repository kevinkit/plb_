----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niat Ogbe, Kevin Höfle
-- 
-- Create Date:    14:14:38 01/13/2015 
-- Design Name: 
-- Module Name:    TOP - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- -- -- -- Counter, counts in the specific way given by Zaehlrichtung. Reset resets the circuit. 

-- Zahelrichtung 0 -> Vorwärts zählen, Zahelrichtung 1-> Rückwärts zählen. 
-- Wenn RS -> 1 und Zhlrichtung -> 0 -> Mit 0 init, , wenn RS -> 1 und Zhlrichtung 0 -> bei Maximalem Wert (Wird über generic definiert) gegeben
-- If the counter comes to the maximum value it starts from the beginning
-- RS is asynchron


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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
    generic(WIDTH : POSITIVE := 8);
	 Port ( RS : in  STD_LOGIC;
           ZR : in  STD_LOGIC;
			  CLK: in STD_LOGIC;
           Ausgang : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end TOP;

architecture Behavioral of TOP is

signal intern_counter:  signed(WIDTH-1 downto 0);

begin




COUNTER: process(clk,RS)
begin
	--Asynchron daher außerhalb der risign_edge
	if (RS = '1') then
		case ZR is
			when '0' => intern_counter <= (others => '0');
			when others => intern_counter <= (others => '1');
		end case;
	end if;
	
	if rising_edge(clk) then
				if ( ZR = '0') then
					intern_counter <= intern_counter + 1;
				else
					intern_counter <= intern_counter - 1;
				end if;
	end if;

end process COUNTER;

Ausgang <= std_logic_vector(intern_counter);

end Behavioral;

