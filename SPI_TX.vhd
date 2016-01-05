----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:17:06 01/03/2016 
-- Design Name: 
-- Module Name:    SPI_TX - Behavioral 
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

entity SPI_TX is
    Port ( i_DATA : in  STD_LOGIC_VECTOR(7 downto 0);
           i_STRB : in  STD_LOGIC;
           i_ADDR : in  STD_LOGIC_VECTOR (1 downto 0);
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           o_SPI_CS : out  STD_LOGIC_VECTOR (3 downto 0);
           o_SPI_DOUT : out  STD_LOGIC;
           o_SPI_CLK : out  STD_LOGIC;
           o_BUSY : out  STD_LOGIC);
end SPI_TX;

architecture Behavioral of SPI_TX is

signal DATA_TMP: std_logic;
signal o_SPI_CS_TMP: std_logic_vector(3 downto 0) := "1111";
signal cnt: unsigned(6 downto 0) := "0000000"; --used for clk div 64
signal o_SPI_CLK_TMP: std_logic := '0'; 
signal DATA: std_logic_vector(7 downto 0) := "00000000"; --holds the data
signal BUSY_TMP: std_logic := '0';
signal DATA_SAVE: std_logic_vector(7 downto 0) := "00000000";
signal LOCK: std_logic := '0';
begin
SPI_RX: process(CLK)
begin
if rising_edge(CLK) then
	
	if RST = '1' then
		o_SPI_CS_TMP <= "1111";
		BUSY_TMP <= '0';
		LOCK <= '0';
	else
		cnt <= cnt + 1; --counterfor Clk Divider
		o_SPI_CLK_TMP <= cnt(6); 
		
		
		if BUSY_TMP = '1' then
			if LOCK = '0' then
				DATA <= DATA_SAVE;
				DATA_SAVE <= "00000000";
				LOCK <= not LOCK; --lock the part
			end if;
			if o_SPI_CLK_TMP = '1' and cnt(6) = '0' then
				DATA <= DATA(DATA'left -1 downto 0) & '0'; --shift out the data
				DATA_TMP <= DATA(DATA'left);
				if DATA = "00000000" and DATA_SAVE = "00000000" then
					BUSY_TMP <= '0';
					LOCK <= not LOCK; --free the part if no data is in the buffer anymore and
											--and no data was recieved during the send
				elsif DATA = "00000000" and DATA_SAVE /= "00000000" then
					LOCK <= not LOCK;
				end if;
			end if;
		
			if i_STRB = '1' then --data may come in during send
				DATA_SAVE <= i_DATA;
			end if;
		end if;
		
		
		
		if i_STRB = '1' and BUSY_TMP = '0' then
			o_SPI_CS_TMP(3) <= not i_ADDR(0) or not i_ADDR(1);
			o_SPI_CS_TMP(2) <=  i_ADDR(0) or not i_ADDR(1);
			o_SPI_CS_TMP(1) <=  not i_ADDR(0) or i_ADDR(1);
			o_SPI_CS_TMP(0) <= i_ADDR(0) or i_ADDR(1);
			DATA_SAVE <= i_DATA;
			BUSY_TMP <= '1'; --nachdem die Daten angekommen sind, ist es busy!			
		end if;
		
		
		
	end if;
end if;
end process SPI_RX;
	o_BUSY     <= BUSY_TMP;
	o_SPI_CS   <= o_SPI_CS_TMP; 
	o_SPI_CLK  <= o_SPI_CLK_TMP;
	o_SPI_DOUT <= DATA_TMP;
end Behavioral;

