----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:11:34 11/18/2014 
-- Design Name: 
-- Module Name:    SLAVE_TOP - Behavioral 
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

entity SLAVE_TOP is
    Port ( SPI_CS : in  STD_LOGIC;
           SPI_CLK : in  STD_LOGIC;
           SPI_DIN : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           o_DATA : out  STD_LOGIC_VECTOR (7 downto 0);
           o_STRB : out  STD_LOGIC;
           o_ERR : out  STD_LOGIC);
end SLAVE_TOP;

architecture Behavioral of SLAVE_TOP is
signal SR: std_logic_vector(1 downto 0) := "00";
signal PRF: unsigned(3 downto 0) := "0000";

signal loc_DATA: std_logic_vector(7 downto 0);
begin


--TAKTFLANKEN ÜBERPRÜFEN
SLAVE: process(CLK, SPI_CLK)

variable STRB: STD_LOGIC := '0';
variable ERR: STD_LOGIC := '0';
variable ERROR: STD_LOGIC := '0';

begin

if rising_edge(CLK) then

	--INIT
	o_STRB <= '0';
	ERROR := '0';
	o_ERR <= ERROR;
	SR <= SR(0) & SPI_CLK; --Schieberegister
	
	--fallende Flanke
	--DATEN SAMMELN
	if(SR(0) = '0' and SR(1) = '1' and SPI_CS = '0') then 
		PRF <= PRF + 1;
		loc_DATA <= loc_DATA(6 downto 0) & SPI_DIN;
		STRB := '1';
		ERR := '0'; --Freigeben vom Errorfall für die überprüfung auf steigende Flanke
	
	end if; --datensammeln ende
	
	--steigende Flanke  
	if(SR(0) = '1' and SR(1) = '0' and SPI_CS = '1') then
		
		--ERROR-Fall prüfen
		if(ERR = '0') then
			ERROR := '1';
			o_ERR <= ERROR;		
			ERR := '1'; --sperren für weitere steigende Flanken
			--o_STRB <= '0'; --TO-DO: STROBE AUF NULL SETZEN WENN ERROR FALL KOMMT 
		else
			ERROR := '0';
		
			o_ERR <= ERROR;	
		end if; --END ERROR
		
		
		if( PRF = "1000") then --Checksumme prüfen
			o_DATA <= loc_DATA;
			ERROR := '0';
			o_ERR <= ERROR; --keinen Fehler gefunden	
		end if;		
		
		--STROBE SETZEN
		if(STRB = '1') then
			o_STRB <= not ERROR;
			STRB := '0'; --sperren für weitere Flanken
		end if;
			
		
		PRF <= "0000"; --Zähler rücksetzen
		
		
		
end if; --ende steigende Flanke

end if; --rising-edge ende
end process SLAVE;
end Behavioral;

