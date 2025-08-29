library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity out_reg_tb is
	-- Generic declarations of the tested unit
	generic(
		n : integer := 4 );
end out_reg_tb;

architecture tb_architecture of out_reg_tb is
	
	-- Stimulus signals
	signal clk : std_logic := '0';
	signal enable : std_logic := '0';
	signal rst_bar : std_logic := '0';
	signal d : std_logic_vector(n-1 downto 0);
	-- Observed signals 
	signal q : std_logic_vector(n-1 downto 0);
	
	-- system clock period
	constant clk_period : time := 125 ns;
	-- boolean signal to stop system clock
	signal END_SIM : boolean := false;
	
begin
	-- Unit Under Test port map
	UUT : entity out_reg
	generic map (
		n => n
		)
	port map (
		clk => clk,
		enable => enable,
		rst_bar => rst_bar,
		d => d,
		q => q
		);
	
	-- System Clock Process
	clock_gen : process
	begin
		clk <= '0';
		wait for clk_period/2;
		loop	-- inifinite loop
			clk <= not clk;
			wait for clk_period/2;
			exit when END_SIM = true;
		end loop;
		std.env.finish;
	end process;
	
	-- Reset Signal
	rst_bar <= '0', '1' after 2.5 * clk_period;
	
	stim: process
	begin
		wait for  2.5 * clk_period;
		for i in 0 to 2**n - 1 loop
			wait until rising_edge(clk);
			d <= std_logic_vector(to_unsigned(i, n));
			enable <= '1';
			wait until rising_edge(clk);
			enable <= '0';
		end loop;
		END_SIM <= true;
		std.env.finish;
	end process;
end tb_architecture;


