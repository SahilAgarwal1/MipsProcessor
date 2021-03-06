library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Sign_Extend_tb is
end Sign_Extend_tb;

architecture tb of Sign_Extend_tb is
    signal isSigned : std_logic;
    signal input : std_logic_vector(7 downto 0);
    signal output : std_logic_vector(15 downto 0);
begin
    UUT: entity work.Sign_Extend
        generic map(
            input_length => 8,
            output_length => 16
        )
        port map(
            isSigned => isSigned,
            input => input,
            output => output
        );

    process
    begin
        isSigned <= '1';
        input <= "11111111";
        wait for 40 ns;

        isSigned <= '0';
        wait for 40 ns;
        wait; 
    end process;
end tb;