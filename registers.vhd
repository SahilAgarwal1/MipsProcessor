library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is
	port(
		clk : in std_logic;
        rst :in std_logic;
		write_reg :in std_logic_vector(4 downto 0); 
		write_data :in std_logic_vector(31 downto 0);
		write_en :in std_logic;
		read_reg1 : in std_logic_vector(4 downto 0); 
        read_reg2 	:in std_logic_vector(4 downto 0); 
		read_data1 : out std_logic_vector(31 downto 0); 
        read_data2 	:out std_logic_vector(31 downto 0);
		JL:in std_logic 
        ); 
		
end registers;

architecture bhv of registers is
    type register_type is array(31 downto 0) of std_logic_vector(31 downto 0);
    signal reg_array : register_type;
begin
    process(clk, rst)
    begin
        if(rst = '1') then
            for k in reg_array'range loop
                reg_array(k) <= (others => '0');
            end loop;
        elsif(rising_edge(clk)) then
            if(write_en = '1') then
                if(JL = '1') then
                    reg_array(31) <= write_data;
                elsif(write_reg /= "00000") then 
                    reg_array(to_integer(unsigned(write_reg))) <= write_data;
                end if;
            end if;
        end if;
    end process;
    
    read_data1 <= reg_array(to_integer(unsigned(read_reg1)));
    read_data2 <= reg_array(to_integer(unsigned(read_reg2)));

    end bhv;