----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:13:00 11/15/2015 
-- Design Name: 
-- Module Name:    counter - Behavioral 
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

entity counter is
    Port ( CLK : in  STD_LOGIC;
           o_CLKDIV2 : out  STD_LOGIC;
           o_CLKDIV5 : out  STD_LOGIC;
           o_CLKDIV10 : out  STD_LOGIC);
end counter;

architecture Behavioral of counter is
signal CLK2: std_logic := '0';
signal SR_5: std_logic_vector(9 downto 0) := "1111100000";
signal tmp_sr5: std_logic := '0';
signal tmp_sr10: std_logic := '0';
begin

SR16: process(CLK)
begin
if rising_edge(CLK) then
	
	--Verzögerung für CLk2 --> Duty Cycle 50% --> 1 Flip Flop reicht
	if CLK2 = '0' then
		CLK2 <= '1';
	else
		CLK2 <= '0';
	end if;

	SR_5 <= SR_5(SR_5'left-1 downto 0) & SR_5(9);
	tmp_sr5 <= SR_5(9); 	 --tmpsr5 ist um einen Takt verzögert

	if tmp_sr5 = '0' and SR_5(9) = '1' then 	--rising edge
		if tmp_sr10 = '0' then
			tmp_sr10 <= '1';
		else
			tmp_sr10 <= '0';
		end if;
	end if;
	
end if;
end process SR16;
o_CLKDIV2 <= CLK2;
o_CLKDIV5 <= SR_5(9) or tmp_SR5;
o_CLKDIV10 <= tmp_sr10;
end Behavioral;

