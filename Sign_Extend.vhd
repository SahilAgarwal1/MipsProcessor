library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Sign_Extend is
    generic(
        input_length : positive;
        output_length : positive
    );
    port(
        isSigned : in std_logic;
        input   : in std_logic_vector(input_length - 1 downto 0);
        output : out std_logic_vector(output_length - 1 downto 0)
    );
end Sign_Extend;

architecture BHV of Sign_Extend is
begin
    process(input, isSigned)
    begin
    if (isSigned = '1') then
        output <= std_logic_vector(resize(signed(input), output'length));
    else
         output <= std_logic_vector(resize(unsigned(input) , output'length));
    end if;
        end process;
end BHV ; --Sign_Extend