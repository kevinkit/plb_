----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:25:33 01/03/2016 
-- Design Name: 
-- Module Name:    PWMmOD - Behavioral 
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

entity PWMmOD is
    Port ( LOAD : in  STD_LOGIC;
           VALUE : in  STD_LOGIC_VECTOR (7 downto 0);
           CNT_CLK : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           o_RESET : out  STD_LOGIC);
end PWMmOD;

architecture Behavioral of PWMmOD is

signal V: unsigned(7 downto 0) := "00000000";
signal CNT_CLK_old: std_logic;
signal T1: std_logic;
begin
WATCH: process(CLK,LOAD) --muss VALUE hier auch in die empfindlichkeitsliste? 
begin
if LOAD = '1' then
	V <= unsigned(VALUE);
	T1 <= not LOAD;
elsif rising_edge(CLK) then
	CNT_CLK_old <= CNT_CLK;
	if CNT_CLK_old = '0' and CNT_CLK = '1' then --rising edge
		if V = 0 then
			T1 <= not LOAD;
		else
			V <= V - 1;
		end if;
	end if;
end if;
end process WATCH;
o_RESET <= T1;
end Behavioral;

