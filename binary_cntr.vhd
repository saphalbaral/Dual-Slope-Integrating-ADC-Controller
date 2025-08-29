-------------------------------------------------------------------------------
--
-- Title       : binary_cntr
-- Design      : binary_cntr
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/saphalbaral/Documents/My_Designs/Lab 11/BinaryCounter/binary_cntr/src/binary_cntr.vhd
-- Generated   : Mon Apr 28 19:34:42 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Binary counter used to time the auto zero period, integrate period, and
-- and the deintegrate period. At the end of the deintegrate period, the counter hodls the result of
-- the ADC conversion.
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {binary_cntr} architecture {behavioral}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity binary_cntr is
	generic (n : integer := 4); -- default is 16; 4 is used for simulation
	port(
		clk : in STD_LOGIC; -- system clock
		cnten1 : in STD_LOGIC; -- active high count enable
		cnten2 : in STD_LOGIC; -- active high count enable
		up : in STD_LOGIC; 	   -- count direction
		clr_bar : in STD_LOGIC; -- synchrounous counter clear
		rst_bar : in STD_LOGIC; -- synchronous reset
		q : out STD_LOGIC_VECTOR (n-1 downto 0); -- count
		max_cnt : out STD_LOGIC -- maximum count indication
	);
end binary_cntr;

--}} End of automatically maintained section

architecture unsigned_variable of binary_cntr is
begin
	process(clk)
	variable count_uv : unsigned(n-1 downto 0); -- variable to hold count
	begin
		if rising_edge(clk) then -- sensitive to positive edge
			if rst_bar = '0' then
				count_uv := (others => '0'); -- if reset enabled, count is reset to 0
			elsif clr_bar = '0' then
				count_uv := (others => '0'); -- if reset enabled, count is reset to 0
			elsif (cnten1 = '1' and cnten2 = '1') then -- both enable signals must be asserted for the counter to count
				if up = '1' then
					count_uv := count_uv + 1; -- count direction is up (in our case, always '1'/up)
				else
					count_uv := count_uv - 1; -- count direction is down
				end if;
			end if;
			q <= STD_LOGIC_VECTOR(count_uv); -- drive output from vraiable
			if count_uv = to_unsigned(2**n - 1, n) then -- when counter reaches maximum count (all 1s); Parameters: to_unsigned(integer value being converted, SIZE)
				max_cnt <= '1'; -- max count reached
			else
				max_cnt <= '0'; -- max count not reached
			end if;
		end if;
	end process;
end unsigned_variable;