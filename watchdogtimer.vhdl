----------------------------------------------------------------------------------
-- Company: 
-- Engineer:Niat ogbe & kevin Höfle
-- 
-- Create Date:    15:45:07 11/13/2014 
-- Design Name: 
-- Module Name:    Watchthedogtop - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Watchdog Timer. Increments a value in CNT_CLKS steps, o_RESET is LOW when everything is good otherwise HIGH. 
--ENABLE LOAD to initialze VALUE as the value which will be incremented
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

entity Watchthedogtop is
    Port ( VALUE : in  STD_LOGIC_VECTOR (7 downto 0);
           LOAD : in  STD_LOGIC;
           CNT_CLK : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           o_RESET : out  STD_LOGIC);
end Watchthedogtop;

architecture Behavioral of Watchthedogtop is

signal cnt_value: unsigned(7 downto 0);
signal SR: std_logic_vector(1 downto 0) := "00";
begin


WATCH: process(CLK)
begin

	if(LOAD = '1') then
	cnt_value <= unsigned(VALUE);
	else
	cnt_value <= cnt_value;
	end if;
	

	if rising_edge(CLK) then
	SR <= SR(SR'left-1) & CNT_CLK;
	
	 if(LOAD = '0' and cnt_value /= "00000000") then 
		if(SR(0) = '0' and SR(1) = '1') then
			cnt_value <= cnt_value - 1;
		end if;
		
	 end if;
	
	
	
	
	end if;

end process watch;

o_RESET <= '1' when cnt_value = "00000000" else '0';

end Behavioral;

