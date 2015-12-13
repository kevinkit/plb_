----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:23:46 12/07/2015 
-- Design Name: 
-- Module Name:    SPI_RX - Behavioral 
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
use IEEE.math_real."ceil";
use IEEE.math_real."log2";
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_RX is
	generic( WIDTH: POSITIVE := 8);
    Port ( SPI_CS : in  STD_LOGIC;
           SPI_CLK : in  STD_LOGIC;
           SPI_DIN : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           o_DATA : out  STD_LOGIC_VECTOR (WIDTH -1 downto 0);
           o_STRB : out  STD_LOGIC;
           o_ERR : out  STD_LOGIC);
end SPI_RX;

architecture Behavioral of SPI_RX is
signal SPI_CLK_s: std_logic;
signal SPI_CS_s: std_logic;
signal BUFF: std_logic_vector(WIDTH -1 downto 0) := (others => '0'); 

signal cnt: unsigned(integer(ceil(log2(real(WIDTH)))) downto 0) := (others => '0');
begin
SLAVE: process(CLK)
begin
if rising_edge(CLK) then
 SPI_CLK_s <= SPI_CLK;
 SPI_CS_s <= SPI_CS;
 o_ERR <= '0';
 o_STRB <= '0';
 if SPI_CS = '0' then
  if SPI_CLK_s = '0' and SPI_CLK = '1' then
   BUFF <= BUFF(BUFF'left -1 downto 0) & SPI_DIN;
   if cnt /= WIDTH +1 then --Problem wenn WIDTH = 8 , würde bei 16,24 etc. auch erfolg ausgeben!
	 cnt <= cnt +1;
	end if;
  end if;
 elsif SPI_CS_s = '0' then --fallende Flanke
	if cnt = WIDTH then
	 o_DATA <= BUFF;
	 o_STRB <= '1';
	else
	 o_ERR <= '1';
	end if;
 else
  cnt <= (others => '0'); --Solange nichts gesendet wird counter auf 0 halten
 end if;
end if; --risinge edge end
end process SLAVE;
end Behavioral;
