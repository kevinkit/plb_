----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:27:42 11/05/2014 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--
entity TOP is
    Port ( DUTCYC : in  STD_LOGIC_VECTOR (7 downto 0);
           EN : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           PWM_OUT : out  STD_LOGIC);
end TOP;

architecture Behavioral of TOP is


signal DUTCYC_SAVE: unsigned(7 downto 0) := "00000000";
signal CNT: unsigned(7 downto 0):= "00000000";
signal TMP: std_logic;

begin
DUTCYC_SAVE <= "00000001" when DUTCYC = "00000000" else unsigned(DUTCYC);
PWM_process : process (CLK)
begin
if rising_edge(CLK) then
		if CNT = 0 then
			TMP <= EN;
		end if;

		if cnt = DUTCYC_SAVE then
			TMP <= '0';
		end if;


		if EN = '0' then
			TMP <= '0';
		elsif cnt = x"C7" then
			cnt <= "00000000";
			TMP <= '0';
		else
			cnt <= cnt +1;
		end if;
end if;
end process PWM_process;
PWM_OUT <= TMP;
end Behavioral;

