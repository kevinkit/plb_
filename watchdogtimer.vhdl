----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:32:47 11/15/2015 
-- Design Name: 
-- Module Name:    watchdog - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity watchdog is
    Port ( VALUE : in  STD_LOGIC_VECTOR (7 downto 0);
           LOAD : in  STD_LOGIC;
           CNT_CLK : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           o_RESET : out  STD_LOGIC);
end watchdog;

architecture Behavioral of watchdog is
signal V: unsigned(7 downto 0):= "11111111";
signal clk_tmp: std_logic := '0';
begin
count: process(CLK,LOAD)
begin
if LOAD = '1' then
	V <= unsigned(VALUE);
elsif rising_edge(CLK) then
	if clk_tmp = '0' and CNT_CLK = '1' then --rising edge
		if V /= "00000000" then
			V <= V -1; 
		end if;
	end if;
	clk_tmp <= CNT_CLK;
end if;
end process count;
o_RESET <= not std_logic(((V(7) or V(6)) or (V(5) or V(4))) or ((V(3) or V(2))or (V(1) or V(0))));
end Behavioral;

