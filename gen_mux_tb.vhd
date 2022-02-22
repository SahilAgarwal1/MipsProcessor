library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_mux_tb is  
end gen_mux_tb;

architecture tb of gen_mux_tb is
    signal input1, input2, input3, output : std_logic_vector(31 downto 0);
    signal sel : std_logic_vector(1 downto 0);
begin
    UUT : entity work.mux
        generic map(
            PORTS => 3
        )
        port map(
            inputs(0) => input1,
            inputs(1) => input2,
            inputs(2) => input3,
            sel => sel,
            output => output
        );
    
    input1 <= (0 => '1' , others => '0');
    input2 <= (1 => '1' , others => '0');
    input3 <= (2 => '1' , others => '0');
    process
    begin
        for i in 0 to 2 loop
            sel <= std_logic_vector(to_unsigned(i,2));
            wait for 40 ns;
        end loop;
    end process;
    end tb;