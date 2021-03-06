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
-- Description:     VERSION WITH SIGNALS
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
signal STRB: STD_LOGIC := '0';
signal ERR: STD_LOGIC := '0';
signal ERROR: STD_LOGIC := '0';
signal loc_DATA: std_logic_vector(7 downto 0);
signal UP_ERR: STD_LOGIC := '0';
begin


--TAKTFLANKEN ÜBERPRÜFEN
SLAVE: process(CLK, SPI_CLK)

begin

if rising_edge(CLK) then

	--INIT
	o_STRB <= '0';
	ERROR <= '0';
	o_ERR <= ERROR;
	SR <= SR(0) & SPI_CLK; --Schieberegister
	
	--fallende Flanke
	--DATEN SAMMELN
	if(SR(0) = '0' and SR(1) = '1' and SPI_CS = '0') then 
		PRF <= PRF + 1;
		
		loc_DATA <= loc_DATA(6 downto 0) & SPI_DIN; --DATEN einlesen
		STRB <= '1';
		ERR <= '0'; --Freigeben vom Errorfall für die überprüfung auf steigende Flanke
	
			--Error ausgeben wenn '8' überschritten wird beim hochzählen!
		if(PRF = "1001" and UP_ERR = '0') then
			o_ERR <= '1'; 
			UP_ERR <= '1';
			loc_DATA <= "00000000"; --Data clearen
		else
			o_ERR <= '0';
		end if;
	
	
	end if; --datensammeln ende
	
	--steigende Flanke  
	if(SR(0) = '1' and SR(1) = '0' and SPI_CS = '1') then
		
		--ERROR-Fall prüfen
		if(ERR = '0') then
			ERROR <= '1';
			o_ERR <= ERROR;		
			ERR <= '1'; 
			o_STRB <= '0';
		else
			ERROR <= '0';
			o_ERR <= ERROR;	
			
			if(STRB = '1' and PRF = "1000") then
				o_STRB <= '1';
				STRB <= '0';
			else
				o_STRB <= '0';
			end if;
		end if; --END ERROR
		
		if( PRF = "1000") then --Checksumme prüfen
			o_DATA <= loc_DATA;
			ERROR <= '0';
			o_ERR <= '0'; --keinen Fehler gefunden	
		end if;		
		

		
		PRF <= "0000"; --Zähler rücksetzen
				
end if; --ende steigende Flanke




end if; --rising-edge ende
end process SLAVE;
end Behavioral;

