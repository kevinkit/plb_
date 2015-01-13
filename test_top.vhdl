--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:48:06 01/13/2015
-- Design Name:   
-- Module Name:   C:/Users/Labor/Klausurvorbereitung/test_top.vhd
-- Project Name:  Klausurvorbereitung
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_top IS
END test_top;
 
ARCHITECTURE behavior OF test_top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP
    PORT(
         RS : IN  std_logic;
         ZR : IN  std_logic;
         CLK : IN  std_logic;
         Ausgang : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal RS : std_logic := '0';
   signal ZR : std_logic := '0';
   signal CLK : std_logic := '0';

 	--Outputs
   signal Ausgang : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP PORT MAP (
          RS => RS,
          ZR => ZR,
          CLK => CLK,
          Ausgang => Ausgang
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      --wait for 100 ns;	
		RS <= '1';
		ZR <= '0';
      wait for CLK_period*10;
		RS <= '0';
		ZR <= '0';
		wait for CLK_period*100;
		RS <= '0';
		ZR <= '1';
		wait for CLK_period*100;
		RS <= '1';
		ZR <= '0';
		wait for CLK_period*100;
		RS <= '1';
		ZR <= '1';
		wait for CLK_period*100;
		RS <= '1';
		ZR <= '1';
		wait for CLK_period*256;
		RS <= '0';
		ZR <= '0';
		wait for CLK_period*256;

      wait;
   end process;

END;
