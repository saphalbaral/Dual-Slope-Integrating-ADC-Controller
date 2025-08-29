-------------------------------------------------------------------------------
--
-- Title       : freq_div
-- Design      : FrequencyDivider
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/saphalbaral/Documents/My_Designs/Lab 11/FrequencyDivider/FrequencyDivider/src/freq_div.vhd
-- Generated   : Mon Apr 28 17:35:57 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Constructed a frequency dividier which is a counter that generates a pulse
-- every n cycles of its input clock. Uses a clock, synchronous reset, and divisor. Uses behavioral
-- architecture style.
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {freq_div} architecture {behavioral}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity freq_div is
	port(
		clk : in STD_LOGIC; -- system clock
		rst_bar : in STD_LOGIC; -- synchronous reset
		divisor : in STD_LOGIC_VECTOR(3 downto 0); -- divider
		clk_dvd : out STD_LOGIC -- output
	);
end freq_div;

--}} End of automatically maintained section

architecture behavioral of freq_div is
	signal count : unsigned(3 downto 0); -- holds count of + edges
begin
	process(clk)
	begin
		if rising_edge(clk) then -- sensitive to positive edge
			if rst_bar = '0' then
				count <= (others => '0'); 			 -- reset count to 0
				clk_dvd <= '0'; 		  			 -- output is low
			elsif divisor = "0000" then   			 -- avoiding dividing by 0
				count <= (others => '0'); 			 -- count is 0
				clk_dvd <= '0';			  			 -- output is low
			elsif count = unsigned(divisor) - 1 then -- one-clock pulse
				count <= (others => '0');			 -- count is 0
				clk_dvd <= '1';						 -- output is high
			else
				count <= count + 1;					 -- increment count on + edge
				clk_dvd <= '0';						 -- output is low
			end if;
		end if;
	end process;
end behavioral;