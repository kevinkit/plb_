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
signal SR_5: std_logic_vector(4 downto 0) := "11100";
signal tmp_sr5: std_logic := '0';
signal tmp_sr10: std_logic := '0';
begin

SR16: process(CLK)
begin
if rising_edge(CLK) then
	CLK2 <= not CLK2; --eine einfache Invertierung tuts auch!

	SR_5 <= SR_5(SR_5'left-1 downto 0) & SR_5(SR_5'left);
	if tmp_sr5 = '0' and SR_5(SR_5'left) = '1' then 	--rising edge
		tmp_sr10 <= not tmp_sr10;
	end if;

	tmp_sr5 <= SR_5(SR_5'left); 	 --tmpsr5 ist um einen Takt verzögert, kann dann später vorodert werden!
end if;
end process SR16;
o_CLKDIV2 <= CLK2;
o_CLKDIV5 <= tmp_sr5;
o_CLKDIV10 <= tmp_sr10;
end Behavioral;

