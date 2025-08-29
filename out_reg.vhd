-------------------------------------------------------------------------------
--
-- Title       : out_reg
-- Design      : out_reg
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/saphalbaral/Documents/My_Designs/Lab 11/OutputRegister/out_reg/src/out_reg.vhd
-- Generated   : Tue Apr 29 17:53:38 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Output register designed to hold the result after the conversion ends.
-- This is intended to be a 16-bit parallel-in parallel-out register.
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {out_reg} architecture {behavioral}}

library IEEE;
use IEEE.std_logic_1164.all;

entity out_reg is
	generic (n : integer := 4); -- default is 16; value of 4 is used for simulation.
	port(
		clk : in STD_LOGIC; -- system clock
		enable : in STD_LOGIC; -- parallel load enable
		rst_bar : in STD_LOGIC; -- synchronous reset
		d : in STD_LOGIC_VECTOR (n-1 downto 0); -- data in
		q : out STD_LOGIC_VECTOR (n-1 downto 0) -- data out
	);
end out_reg;

--}} End of automatically maintained section

architecture behavioral of out_reg is
begin
	process(clk)
	begin
		if rising_edge(clk) then -- sensitive to positive clock edge
			if rst_bar = '0' then
				q <= (others => '0'); -- if reset is asserted, all bits of q output are 0
			elsif enable = '1' then
				q <= d; -- if load enable is asserted, q output copies d input
			end if;
		end if;
	end process;
end behavioral;