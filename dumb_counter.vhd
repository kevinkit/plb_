----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:04:42 01/07/2016 
-- Design Name: 
-- Module Name:    dumb_counter - Behavioral 
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

--counter counts depending on the input 
--00 --> no change
--01 --> 3 2 1 0 1 (repeeat from 1)
--10 --> 3 2 1 0 2 (repeat from 2)
--11 --> 3 2 1 0 3 (repeat from 3)

entity dumb_counter is
    Port ( E1E0 : in  STD_LOGIC_VECTOR (1 downto 0);
           A1A0 : out  STD_LOGIC_VECTOR (1 downto 0);
			  CLK: in std_logic
			 );
		     
end dumb_counter;

architecture Behavioral of dumb_counter is
type STATE_TYPE is (Z0,Z1,Z2,Z3);
signal STATE, NEXT_ST: STATE_TYPE;
begin
count: process(CLK)
begin
if rising_edge(CLK) then
	STATE <= NEXT_ST;
	case STATE is
		when Z0 => if ( E1E0 = "01") then NEXT_ST <= Z1;
					elsif ( E1E0 = "10" ) then NEXT_ST <= Z2;
					elsif ( E1E0 = "11" ) then NEXT_ST <= Z3;
					end if;
					A1A0 <= "00";
		when Z1 => if ( E1E0 /= "00") then NEXT_ST <= Z0; end if; A1A0 <= "01";
		when Z2 => if ( E1E0 /= "00") then NEXT_ST <= Z1; end if; A1A0 <= "10";
		when Z3 => if ( E1E0 /= "00") then NEXT_ST <= Z2; end if; A1A0 <= "11";
	end case;
end if;
end process count;
end Behavioral;

