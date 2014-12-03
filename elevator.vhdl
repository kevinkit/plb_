----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:47:43 11/25/2014 
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

-- __FRAGEN SIND MIT ZWEI UNDERSCORES gekennzeichnet
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

entity TOP is
    Port ( i_SPI_CS : in  STD_LOGIC; --Chip Select 
           i_SPI_CLK : in  STD_LOGIC; --Übertragungstakt 100 khZ
           i_SPI_DIN : in  STD_LOGIC; --Serielle Datenübertragung
           i_REQ_EXT : in  STD_LOGIC_VECTOR (3 downto 0); --Ruftasten außerhalb, jede Bitstelle für ein Stockwerk, 
           i_REQ_INT : in  STD_LOGIC_VECTOR (3 downto 0); --Bedientasten innerhalb
           i_POS : in  STD_LOGIC_VECTOR (3 downto 0); --Aktuelle Position
           i_DOOR_STAT : in  STD_LOGIC_VECTOR (1 downto 0); --TürStatus "00" -> In bewegung, "10" geschlossen, "01" offen
           i_RST : in  STD_LOGIC; --Resetsignal - beim einschalten kurzzeiteig auf 1 __WIESO?
           CLK : in  STD_LOGIC; -- Systemtakt: 1MHz
           o_MOTOR_DIR : out  STD_LOGIC; --Richtungsangabe 1 -> hoch 0 -> runter
           o_MOTOR_EN : out  STD_LOGIC; --Motor an/aus
           o_DOOR_DIR : out  STD_LOGIC; --Tür richtung 1 -> schließen , 0 -> öffnen
           o_DOOR_EN : out  STD_LOGIC); --Tür öffnen/schließen
end TOP;

architecture Behavioral of TOP is



COMPONENT SLAVE_TOP
PORT(
     CLK     : IN  std_logic;
      SPI_CS  : IN  std_logic;
      SPI_CLK : IN  std_logic;
      SPI_DIN : IN  std_logic;
      o_DATA  : OUT std_logic_vector(7 downto 0);
      o_STRB  : OUT std_logic;
      o_ERR   : OUT std_logic );
    END COMPONENT;


COMPONENT Watchthedogtop is
    Port ( VALUE : in  STD_LOGIC_VECTOR (7 downto 0);
           LOAD : in  STD_LOGIC;
           CNT_CLK : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           o_RESET : out  STD_LOGIC);
END COMPONENT;


signal DATA_BUS : std_logic_vector(7 downto 0);
signal REQUEST: std_logic_vector(3 downto 0);
signal CLK_DOG : STD_LOGIC;
signal DOG_OUT : STD_LOGIC;
signal RELOAD : STD_LOGIC;
signal STRB: STD_LOGIC;


type STATE_TYPE is(drive_up, drive_down, stay);
signal STATE, NEXT_ST: STATE_TYPE;

type STATE_DOOR is(door_opening, door_closing, door_open, door_shut);
signal DOOR,NEXT_DOOR: STATE_DOOR;


begin
SLAVE1: SLAVE_TOP
port map(
				CLK => CLK,
				SPI_CS => i_SPI_CS,
				SPI_CLK => i_SPI_CLK,
				SPI_DIN => i_SPI_DIN,
				o_DATA => DATA_BUS,
				o_STRB => STRB,
				o_ERR => open
				);

Dog: Watchthedogtop
port map(
				CLK => CLK,
				o_RESET => DOG_OUT,
				CNT_CLK => CLK_DOG,
				LOAD => RELOAD,
				VALUE => DATA_BUS

			);


--INIT-- EINMALIGES LADEN DES 


init: block
begin
	process(CLK)
	begin
		REQUEST <= i_REQ_EXT or i_REQ_INT; --Auf ein "SIGNAL" bringen !
	
		--TO-DO: RICHTIGES LADEN DER VALUE
		--if(i_RST  <= '1' and STRB = '1') then    --RESET IST AN HIER IST ZEIT UM DIE VALUES ZU LADEN (HOFFENTLICH!)
			--		DATA_BUS <= o_DATA; --__WERDEN DIE DATEN VON ALLEINE GELADEN in o_DATA durch die Verdahrunt oder muss das 
					--selber getan werden? 
		--end if;
	end process;
end block init;
	

Takt_teilung: block

signal SR : std_logic_vector(5 downto 0);

begin
	process(CLK)
	begin
		if rising_edge(CLK) then

----------------------TEILUNG DES TAKTES UM 32
			SR <= SR(4 downto 0) & CLK; --Clk nachschieben
			
			if(SR(4) = '1' and SR(5) = '0') then --die 1 kommt, daher steigend
				CLK_DOG <= '1';
			end if;
		
			if(SR(4) = '0' and SR(5) = '1') then
				CLK_DOG <= '0';
			end if;
		
		end if;
	end process;
end block Takt_teilung;


zustandsautomat: block

signal STAY_TRUE: STD_LOGIC := '1'; --Initialisiert darauf, dass der Fahrstuhl am Anfang im Stilltstand ist
begin

--ZUSTANDSAUTOMAT  --muss noch definiert werden wann er überhaupt in das ding reinp
--springen kann, also den init

--I_POS setzt immer nur ein Bit!
Drive: process(REQUEST)
begin

	case STATE is
		
		
								  --würde gehen, wenn es nur einmalige Anforderung gebe!
		when drive_up => if(REQUEST > i_POS) then NEXT_ST <= drive_up; 
				elsif((REQUEST and i_POS) = i_POS) then NEXT_ST <= stay; 
				
				STAY_TRUE <= '1'; --vom hochfahren in den Stillstand
				
		end if; --weiter hoch fahren beim hoch fahren
 		
		when drive_down => if(REQUEST < i_POS) then NEXT_ST <= drive_down;  --weiter runter fahren beim runter fahren
			elsif((REQUEST and i_POS) = i_POS) then NEXT_ST <= stay; 
		end if;
			
		--WAS IST WENN EINE ANFRAGE VON UNTEN/OBEN KOMMT ABER GLEICHZEITIG SOLL WEITERHIN NOCH OFFEN BLEIBEN
		when stay => if ((REQUEST and i_POS) = i_POS) then NEXT_ST <= stay; --stehen bleiben beim stehen bleiben
						  elsif(REQUEST < i_POS) then NEXT_ST <= drive_up; --von stehen bleiben zu hoch fahren
							elsif(REQUEST < i_POS) then NEXT_ST <= drive_down; --von stehen bleiben zu runter fahren
		
		end if;
	
	
	end case;
end process;


--Zustandsautomat 2 für die Tür

--type STATE_DOOR is(door_openening, door_closing, door_open);
--signal DOOR,NEXT_DOOR: STATE_DOOR;

door: process(STAY_TRUE) --jedesmal wenn der STATE sich ändert hier rein gehen

begin
		if(STAY_TRUE = '1') then --Wenn Fahrstuhl im zustand STILLSTEHEND
			case DOOR is
			
				when door_shut => if((REQUEST and i_POS) = i_POS) then NEXT_DOOR <= door_opening;
										else NEXT_DOOR <= door_shut;
				end if;
				
				when door_opening => if(i_DOOR_STAT = "00") then NEXT_DOOR <= door_open;
											else NEXT_DOOR <= door_open;
				
				end if;
				when door_open		=> if(((REQUEST and i_POS) /= i_POS) and DOG_OUT = '1') then NEXT_DOOR <= door_closing;
											elsif((REQUEST and i_POS) = i_POS) then NEXT_DOOR <= door_opening;
				
				end if;
				when door_closing => if(i_DOOR_STAT = "00") then NEXT_DOOR <= door_shut;
											else NEXT_DOOR <= door_closing;
				end if;
	
			end case;

		end if;
		
end process;




-- o_MOTOR_DIR : out  STD_LOGIC; --Richtungsangabe 1 -> hoch 0 -> runter
-- o_MOTOR_EN : in  STD_LOGIC; --Motor an/aus




--MOTORSTEUERUNG AUFZUG
DRIVE_RES: process(STATE)
begin
	case STATE is
				when stay => o_MOTOR_EN <= '0';
				when drive_up => o_MOTOR_DIR <= '1'; o_MOTOR_EN <= '1';
				when drive_down => o_MOTOR_DIR <= '0'; o_MOTOR_EN <= '0';
		end case;
end process;


--MOTORSTEUERUNG TÜR
--type STATE_DOOR is(door_openening, door_closing, door_open, door_shut);
-- o_DOOR_DIR : in  STD_LOGIC; --Tür richtung 1 -> schließen , 0 -> öffnen
-- o_DOOR_EN : in  STD_LOGIC); --Tür öffnen/schließen



DRIVE_DOOR: process(DOOR)


begin
	case DOOR is
		when door_shut => o_DOOR_EN <= '0';
		when door_open => o_DOOR_EN <= '0';
		when door_opening => o_DOOR_DIR <= '1'; o_DOOR_EN <= '1';
		when door_closing => o_DOOR_DIR <= '0'; o_DOOR_EN <= '1';
		end case;
end process;
end block zustandsautomat;



--Kümmert sich um den zeitlichen Ablauf
Tuer: block
	
begin
	process(CLK)
	begin
-----------------------TÜR ZU/AUF MACHEN
		
--TÜR SCHLIESSEN NACH BESTIMMTER ZEIT
		if(i_DOOR_STAT = "00") then --wenn Tür offe
				RELOAD <= '1'; --Neuladen des Watchdogtimers
				
				if(DOG_OUT = '1') then --Watchdogtimer abgelaufen
					o_DOOR_DIR <= '0'; --Tür schließene
					o_DOOR_EN <= '0';
				end if;
			
		end if;

	end process;
end block Tuer;




end Behavioral;

