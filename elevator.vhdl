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
           o_MOTOR_DIR : out  STD_LOGIC;--- := '1'; --Richtungsangabe 1 -> hoch 0 -> runter
           o_MOTOR_EN : out  STD_LOGIC; --:= '0'; --Motor an/aus
           o_DOOR_DIR : out  STD_LOGIC;--- := '1'; --Tür richtung 1 -> schließen , 0 -> öffnen
           o_DOOR_EN : out  STD_LOGIC);--- := '0'); --Tür öffnen/schließen
end TOP;

architecture Behavioral of TOP is


--SPIModue
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

--Watchdogtimer
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
signal DOOR, NEXT_DOOR: STATE_DOOR;


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
	process(CLK,i_RST)
	begin
	
		if(i_RST = '1') then
			STATE <= stay;
			DOOR <= door_shut;
			RELOAD <= '1';
		elsif rising_edge(CLK) then
			
			REQUEST <= i_REQ_EXT or i_REQ_INT; --Auf ein "SIGNAL" bringen !
			STATE <= NEXT_ST;
			DOOR <= NEXT_DOOR;
		
		end if;
		
	end process;
end block init;
	

Takt_teilung: block

signal SR : std_logic_vector(31 downto 0) := x"FFFF0000"; -- "11111111111111110000000000000000";
begin
	process(CLK)
	begin
		if rising_edge(CLK) then

			SR <= SR(SR'left-1 downto 0) & SR(SR'left);
			CLK_DOG <= SR(31);				
		
		
		end if;
	end process;
end block Takt_teilung;







zustandsautomat: block

begin
Drive: process(i_POS,STATE,REQUEST,CLK)
begin

	if rising_edge(CLK) then
		
	
	case STATE is
		
		
		when drive_up => if(REQUEST > i_POS) then NEXT_ST <= drive_up;  
				elsif((REQUEST and i_POS) = i_POS) then NEXT_ST <= stay;
				elsif(REQUEST = "0000") then NEXT_ST <= stay;--vom hochfahren in den Stillstand
				
		end if; --weiter hoch fahren beim hoch fahren
 		
		when drive_down => if(REQUEST < i_POS) then NEXT_ST <= drive_down;  --weiter runter fahren beim runter fahren
			elsif((REQUEST and i_POS) = i_POS) then NEXT_ST <= stay; 
			
				elsif(REQUEST = "0000") then NEXT_ST <= stay;
		end if;
			
		when stay => if ((REQUEST and i_POS) = i_POS) then NEXT_ST <= stay; --stehen bleiben beim stehen bleiben
						  elsif(REQUEST < i_POS) then NEXT_ST <= drive_down; 
						  elsif(REQUEST > i_POS) then NEXT_ST <= drive_up;--von stehen bleiben zu hoch fahren	
							
				elsif(REQUEST = "0000") then NEXT_ST <= stay;
		end if;
	
	
	end case;
	end if;
end process;

dooring: process(i_DOOR_STAT, i_POS, DOOR,CLK) --jedesmal wenn der STATE sich ändert hier rein gehen

--DOOR_STAT ANPASSEN
begin
		if rising_edge(CLK) then
	
		
	--if(STAY_TRUE = '1') then --Wenn Fahrstuhl im zustand STILLSTEHEND
			case DOOR is
		   
				
				when door_opening => if(i_DOOR_STAT = "01") then NEXT_DOOR <= door_open; --Offen erreicht
											elsif(i_DOOR_STAT = "00") then NEXT_DOOR <= door_opening;
				
				end if;
				
				when door_open		=> if(((REQUEST and i_POS) /= i_POS) and DOG_OUT = '1') then NEXT_DOOR <= door_closing;
											elsif((REQUEST and i_POS) = i_POS) then NEXT_DOOR <= door_opening;
											else NEXT_DOOR <= door_open;
				
				end if;
				
				when door_closing => if(i_DOOR_STAT = "10") then NEXT_DOOR <= door_shut;
											elsif(i_DOOR_STAT = "00") then NEXT_DOOR <= door_closing;
				end if;
	
				--hier fehlt: zu door closing zu gehen!
				when door_shut => if((REQUEST and i_POS) = i_POS) then NEXT_DOOR <= door_opening;
										elsif(((REQUEST and i_POS) /= i_POS) and DOG_OUT = '1') then NEXT_DOOR <= door_closing;
										else NEXT_DOOR <= door_shut;
				end if;
	
	
			end case;

	--	end if;
		end if;
end process;


--MOTORSTEUERUNG AUFZUG
DRIVE_RES: process(STATE,CLK)
begin
	if rising_edge(CLK) then
	case STATE is
				when stay => o_MOTOR_EN <= '0';  --Motor aus
				when drive_up => o_MOTOR_DIR <= '1'; o_MOTOR_EN <= '1';--Motor hoch; Motor an;
				when drive_down => o_MOTOR_DIR <= '0'; o_MOTOR_EN <= '1'; --Motor runter; Motor an;
		end case;
	end if;
end process;


DRIVE_DOOR: process(DOOR,CLK)


begin

	if rising_edge(CLK) then
	case DOOR is
		when door_shut => o_DOOR_EN <= '0'; RELOAD <= '1';--Türmotor aus
		when door_open => o_DOOR_EN <= '0'; RELOAD <= '0';--Türmotor aus
		when door_opening => o_DOOR_DIR <= '0'; o_DOOR_EN <= '1'; --Tür öffnen; --Türmotor anmachen
		when door_closing => o_DOOR_DIR <= '1'; o_DOOR_EN <= '1'; --Tür öffnen; --Türmotor anmachen
		end case;
	end if;
end process;
end block zustandsautomat;




end Behavioral;

