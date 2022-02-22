library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.gen_mux_package;

entity mux is
    generic(
        PORTS: natural
    );
    port(
        inputs : in gen_mux_package.mux_array(PORTS-1 downto 0);
        sel : in  std_logic_vector(integer(ceil(log2(real(PORTS)))) - 1 downto 0);
        output : out std_logic_vector(31 downto 0)
    );
end entity;

architecture bhv of mux is
begin
    output <= inputs(to_integer(unsigned(sel)));
end bhv;
