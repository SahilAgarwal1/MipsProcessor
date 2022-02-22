library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
    port(
        clk => in std_logic;
        rst => in std_logic;
        led0,led1,led2,led3,led4,led5: out std_logic_vector(6 downto 0);
        inport_switches : in std_logic_vector(9 downto 0)
    );
end toplevel;

architecture top of toplevel is
    signal output(31 downto 0);
begin

    cpu_: entity work.cpu
        port map(
            clk => clk,
            rst => rst,
            switches => inport_switches,
            LEDs => output
        );
    led0_ : entity work.decoder7seg
        port map(
            input => output(3 downto 0),
            output -> led0(6 downto 0)
        );
    led1_ : entity work.decoder7seg
        port map(
            input => output(7 downto 4),
            output -> led1(6 downto 0)
        );
    led2_ : entity work.decoder7seg
        port map(
            input => output(11 downto 8),
            output -> led2(6 downto 0)
        );
    led3_ : entity work.decoder7seg
        port map(
            input => output(15 downto 12),
            output -> led3(6 downto 0)
        );
    led4_ : entity work.decoder7seg
        port map(
            input => output(19 downto 16),
            output -> led4(6 downto 0)
        );
    led5_ : entity work.decoder7seg
        port map(
            input => output(23 downto 20),
            output -> led5(6 downto 0)
        );

end top;