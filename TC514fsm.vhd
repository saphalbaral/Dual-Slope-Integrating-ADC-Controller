-------------------------------------------------------------------------------
--
-- Title       : TC514fsm
-- Design      : tc514cntrl
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/saphalbaral/Documents/My_Designs/Lab 11/TC514_controller/tc514cntrl/src/TC514fsm.vhd
-- Generated   : Tue May  6 18:15:13 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Implements a counter, frequency divider, out register, FSM, and structural
-- entity to construct a TC514 control 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {TC514fsm} architecture {structural}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity binary_cntr is
	generic (n : integer := 16); -- default is 16; 4 is used for simulation
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

-------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity freq_div is
	port(
		clk : in STD_LOGIC; -- system clock
		rst_bar : in STD_LOGIC; -- synchronous reset
		divisor : in STD_LOGIC_VECTOR(3 downto 0); -- divider
		clk_dvd : out STD_LOGIC -- output
	);
end freq_div;

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

-------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity out_reg is
	generic (n : integer := 16); -- default is 16; value of 4 is used for simulation.
	port(
		clk : in STD_LOGIC; -- system clock
		enable : in STD_LOGIC; -- parallel load enable
		rst_bar : in STD_LOGIC; -- synchronous reset
		d : in STD_LOGIC_VECTOR (n-1 downto 0); -- data in
		q : out STD_LOGIC_VECTOR (n-1 downto 0) -- data out
	);
end out_reg;

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

-------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity TC514fsm is
	port(
		soc : in STD_LOGIC;				-- start conversion control input
		cmptr : in STD_LOGIC;			-- TC514 comparator status input
		max_cnt : in STD_LOGIC;			-- maximum count status input
		clk : in STD_LOGIC;				-- system clock
		clk_dvd : in STD_LOGIC;			-- clock divided down
		rst_bar : in STD_LOGIC;			-- synchronous reset
		a : out STD_LOGIC;				-- conversion phase control
		b : out STD_LOGIC;				-- conversion phase control
		busy_bar : out STD_LOGIC;		-- active low busy status
		cnt_en : out STD_LOGIC;			-- counter enable control to counter
		clr_cntr_bar : out STD_LOGIC;	-- signal to clear counter
		load_result : out STD_LOGIC		-- load enable
	);
end TC514fsm;

--}} End of automatically maintained section

architecture three_process_fsm of TC514fsm is
	-- direct instantiation used (all states listed)
	constant auto_zero : STD_LOGIC_VECTOR(5 downto 0) := "011001";
	constant idle : STD_LOGIC_VECTOR(5 downto 0) := "000101";
	constant input_signal_integration : STD_LOGIC_VECTOR(5 downto 0) := "011010";
	constant count_clear : STD_LOGIC_VECTOR(5 downto 0) := "000010";
	constant reference_de_integration : STD_LOGIC_VECTOR(5 downto 0) := "011011";
	constant integrator_output_zero : STD_LOGIC_VECTOR(5 downto 0) := "110000";
	constant all_zeroes : STD_LOGIC_VECTOR(5 downto 0) := "000000";
	signal present_state, next_state : STD_LOGIC_VECTOR(5 downto 0);
	signal output_vector : STD_LOGIC_VECTOR(5 downto 0);	-- storing the output
	
	-- first process for FSM
	begin
		state_reg : process(clk)
		begin
			if rising_edge(clk) then
				if rst_bar = '0' then
					present_state <= auto_zero; -- when resetting goes to auto_zero state
				else
					present_state <= next_state; -- or else goes the next state
				end if;
			end if;
		end process;
		
	-- second process for FSM, Moore so outputs only depends on present state
	outputs : process(present_state)
	begin
		(load_result, clr_cntr_bar, cnt_en, busy_bar, a, b) <= present_state; -- linking to corresponding input ports
	end process;
	
	-- third process for FSM
	nxt_state : process(present_state, soc, cmptr, max_cnt)
	begin
		case present_state is
			when auto_zero =>
			if max_cnt = '1' then
				next_state <= idle; -- whenever the max clocks count has been reached, we go to idle
			else
				next_state <= auto_zero; -- else go to auto_zero, the same state
			end if;
			
			when idle =>
			if soc = '1' then
				next_state <= input_signal_integration; -- go to integrate state whenever soc is enabled
			else
				next_state <= idle; -- else go to idle
			end if;
			
			when input_signal_integration =>
			if max_cnt = '1' then
				next_state <= reference_de_integration;
			else
				next_state <= input_signal_integration; -- else go to integrate state
			end if;
			
			--when count_clear =>
			--if max_cnt = '0' then
				--next_state <= reference_de_integration; -- if max count cleared, go to deintegrate
			--else
				--next_state <= count_clear; -- else clear count
			--end if;
			
			when reference_de_integration =>
			if falling_edge(cmptr) then
				next_state <= integrator_output_zero; -- falling edge, go to integrator output zero state
			else
				next_state <= reference_de_integration; -- else go to deintegrate
			end if;
			
			when integrator_output_zero =>
			if rising_edge(cmptr) then
				next_state <= all_zeroes; -- rising edge, go to auto zero
			else
				next_state <= integrator_output_zero; -- else go to integrate output zero
			end if;
			
			when all_zeroes =>
			next_state <= auto_zero;
			
			when others =>
			next_state <= auto_zero; -- default state
			
		end case;
	end process;
end three_process_fsm;

-------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity tc514cntrl is
	generic (n : integer := 8); -- bit width
	port(
		soc : in std_logic; -- start conversion control input
		rst_bar : in std_logic; -- synchronous reset
		clk : in std_logic; -- system clock
		cmptr : in std_logic; -- TC514 comparator status input
		a : out std_logic; -- conversion phase control
		b : out std_logic; -- conversion phase control
		dout : out std_logic_vector(n-1 downto 0); -- converter result
		busy_bar : out std_logic -- converter busy indicator
	);
end tc514cntrl;

architecture structural of tc514cntrl is
	signal clk_dvd_local : std_logic; -- output of clk_dvd from frequency divider
	signal clr_cntr_bar_local : std_logic; -- port from TC514FSM
	signal max_cnt_local : std_logic; -- output from u1
	signal q_local : std_logic_vector(n-1 downto 0); -- output q from u1 
	signal cnt_en_local : std_logic; -- output from u2
	signal load_result_local : std_logic; -- output from u2 load_result
begin
	-- mapping all ports
	u0 : entity binary_cntr generic map (n => n) port map(
		clk => clk,
		rst_bar => rst_bar,
		cnten1 => cnt_en_local,
		cnten2 => clk_dvd_local,
		clr_bar => clr_cntr_bar_local,
		max_cnt => max_cnt_local,
		up => '1',
		q => q_local
		);
	
	-- mapping all ports
	u1 : entity freq_div port map(
		clk => clk,
		rst_bar => rst_bar,
		clk_dvd => clk_dvd_local,
		divisor => "0100" -- refers to the 2MHz divisior
		);
	
	-- mapping all ports
	u2 : entity out_reg generic map (n => n) port map(
		clk => clk,
		d => q_local,
		rst_bar => rst_bar,
		q => dout,
		enable => load_result_local
	);
	
	-- mapping all ports
	u3 : entity TC514fsm port map(
		soc => soc,
		cmptr => cmptr,
		max_cnt => max_cnt_local,
		clk => clk,
		clk_dvd => clk_dvd_local,
		rst_bar => rst_bar,
		a => a,
		b => b,
		busy_bar => busy_bar,
		cnt_en => cnt_en_local,
		clr_cntr_bar => clr_cntr_bar_local,
		load_result => load_result_local
		);
end structural;