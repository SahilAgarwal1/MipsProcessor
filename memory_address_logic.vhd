library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_address_logic is
	port(
		memWrite	: in std_logic;
		address		: in std_logic_vector(31 downto 0);
		write_en    : out std_logic;
		outport_en  : out std_logic;
		Rd_data_sel	: out std_logic_vector(1 downto 0)
		);
		
end memory_address_logic;

architecture bhv of memory_address_logic is
begin
    process(memWrite, address) -- any input changes
    begin
		write_en <= '0';
		outport_en <= '0';
		Rd_data_sel <= "00";

		if(address <= x"000003FF") then -- can make the memory addressable from multiple locations depending on bits
			if(memWrite = '1') then
				write_en <= '1';
			end if;
		elsif(address = x"0000FFF8") then -- input port0
			Rd_data_sel <= "01";
		elsif(address = x"0000FFFC") then -- inport1 and outport0
			if (memWrite = '1') then -- output port
				outport_en <= '1';
			else
				Rd_data_sel <= "10";
			end if;
		end if;
	end process;
end bhv;
				