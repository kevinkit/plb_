----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:38:28 12/16/2014 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TOP is
    Port ( i_CLK_OSC : in  STD_LOGIC;
           i_SENCLK_LVDS_p : in  STD_LOGIC;
           i_SENCLK_LVDS_n : in  STD_LOGIC;
           i_RST : in  STD_LOGIC;
           o_CLK_31 : out  STD_LOGIC;
           o_SENCLK_31 : out  STD_LOGIC;
           o_SENCLK_LVDS_p : out  STD_LOGIC;
           o_SENCLK_LVDS_n : out  STD_LOGIC);
end TOP;



architecture Behavioral of TOP is



	COMPONENT Part2
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKDV_OUT : OUT std_logic;
		CLKFX_OUT : OUT std_logic;
		CLKFX180_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic
		);
	END COMPONENT;
	
	
	
	COMPONENT Part3
	PORT(
		CLKIN_N_IN : IN std_logic;
		CLKIN_P_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKDV_OUT : OUT std_logic;
		CLKFX_OUT : OUT std_logic;
		CLKFX180_OUT : OUT std_logic;
		CLKIN_IBUFGDS_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic
		);
	END COMPONENT;







signal osz: STD_LOGIC;

signal half_osz: STD_LOGIC := '1';
signal half_osz_CLK: STD_LOGIC;
signal quarter_osz: STD_LOGIC := '0';


signal CLK_31: STD_LOGIC;
signal CLK_LVDS_p: STD_LOGIC;
signal CLK_LVDS_n: STD_LOGIC;

signal CLK_INTERN_156: STD_LOGIC;
signal CLK_INTERN_125: STD_LOGIC;
signal CLK_INTERN_31: STD_LOGIC;


signal intern_LVDS_p: STD_LOGIC;
signal intern_LVDS_n: STD_LOGIC;

begin

U_intern :IBUFG
port map(I=>i_SENCLK_LVDS_p, O=> intern_LVDS_p);

U_intern_2 :IBUFG
port map(I=>i_SENCLK_LVDS_n, O=> intern_LVDS_n);

U_IBUFG :IBUFG
port map(I=>i_CLK_OSC, O=>osz);

U_BUFG :BUFG
port map(I=>half_osz, O=>half_osz_CLK);

U_ODDR: ODDR port map(
	Q => o_CLK_31,
	C => quarter_osz,
	CE => '1',
	D1 => '1',
	D2 => '0',
	R => '0',
	S => '0');

---aufgabenteil II
thirty_one: ODDR port map(
	Q => o_SENCLK_31,
	C => CLK_31,
	CE => '1',
	D1 => '1',
	D2 => '0',
	R => '0',
	S => '0');
	
	
LVDS_p: ODDR port map(
	Q => o_SENCLK_LVDS_p,
	C => CLK_LVDS_p,
	CE => '1',
	D1 => '1',
	D2 => '0',
	R => '0',
	S => '0');

LVDS_n: ODDR port map(
	Q => o_SENCLK_LVDS_n,
	C => CLK_LVDS_n,
	CE => '1',
	D1 => '1',
	D2 => '0',
	R => '0',
	S => '0');


Inst_Part2: Part2 PORT MAP(
		CLKIN_IN => i_CLK_OSC,
		RST_IN => i_RST,
		CLKDV_OUT => CLK_31,
		CLKFX_OUT => CLK_LVDS_p,
		CLKFX180_OUT => CLK_LVDS_n,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,
		LOCKED_OUT => open
	);



---AUFGABENTEIL III


Inst_Part3: Part3 PORT MAP(
		CLKIN_N_IN => intern_LVDS_n,
		CLKIN_P_IN => intern_LVDS_p,
		RST_IN => i_RST,
		CLKDV_OUT => CLK_INTERN_31,
		CLKFX_OUT => CLK_INTERN_125,
		CLKFX180_OUT => open,
		CLKIN_IBUFGDS_OUT => open,
		CLK0_OUT => CLK_INTERN_156,
		LOCKED_OUT => open
	);
	
	




half_divide: process(osz)
begin
	if rising_edge(osz) then
		half_osz <= not half_osz;
	end if;
end process half_divide;


quarter_divide: process(half_osz_CLK)
begin
	if rising_edge(half_osz_CLK) then
		quarter_osz <= not quarter_osz;
	end if;
end process quarter_divide;

end Behavioral;

