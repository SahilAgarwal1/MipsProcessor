library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end cpu_tb;

architecture tb of cpu_tb is

	signal clk : std_logic := '0';
	signal rst	: std_logic := '0';
	signal switches : std_logic_vector(9 downto 0) := (others => '0');
	signal outport	: std_logic_vector(31 downto 0);
	
	
begin
	CPU : entity work.cpu
		port map (
			clk => clk,
			rst => rst,
			switches => switches,
			LEDs => outport);
	
	clk <= not clk after 5 ns;
	
	process
	begin
		
		rst <= '1';
		switches(9) <='1';
		switches(8 downto 0) <= "000001111";
		wait for 20 ns;
		switches(9) <='0';
		switches(8 downto 0) <= "000000011";
		wait for 20 ns;
		rst <= '0';
		wait;
	end process;
	


end tb;