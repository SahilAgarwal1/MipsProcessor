library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture TB of alu_tb is

    component alu

        generic (
            WIDTH : positive := 32
            );
        port (
            inp1 : in std_logic_vector(WIDTH-1 downto 0);
            inp2 : in std_logic_vector(WIDTH-1 downto 0);
            shift : in std_logic_vector(4 downto 0); -- IR [10:6]
            OPSelect : in std_logic_vector(5 downto 0);
            Branch_Taken : out std_logic;
            Result : out std_logic_vector(WIDTH-1 downto 0);
            Result_Hi : out std_logic_vector(WIDTH-1 downto 0)
            );

    end component;

    constant WIDTH  : positive                           := 32;
    signal input1   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal input2   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal shift : std_logic_vector(4 downto 0) := (others => '0'); -- IR [10:6]
    signal OPSelect : std_logic_vector(5 downto 0) := (others => '0') ;
    signal Branch_Taken : std_logic := '0';
    signal Result : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal Result_Hi : std_logic_vector(WIDTH-1 downto 0) := (others => '0');

    constant Add : std_logic_vector(5 downto 0) := "100001";
    constant Sub : std_logic_vector(5 downto 0) := "100011";
    constant Mult : std_logic_vector(5 downto 0) := "011000";
    constant Multu : std_logic_vector(5 downto 0) := "011001";
    constant AND_c : std_logic_vector(5 downto 0) := "100100";
    constant OR_c : std_logic_vector( 5 downto 0) := "100101";
    constant XOR_c : std_logic_vector( 5 downto 0) := "100110";
    constant lsr : std_logic_vector(5 downto 0) := "000010";
    constant lsl : std_logic_vector(5 downto 0) := "000000";
    constant asr : std_logic_vector(5 downto 0) := "000011";
    constant solts : std_logic_vector(5 downto 0) := "101010";
    constant soltu : std_logic_vector(5 downto 0) := "101011";
    constant mfhi : std_logic_vector(5 downto 0) := "010000";
    constant mflo : std_logic_vector(5 downto 0) := "010010";
    constant BEQ : std_logic_vector(5 downto 0) := "000100";
    constant BNE : std_logic_vector(5 downto 0) := "000101";
    constant BLEZ : std_logic_vector(5 downto 0) := "000110";
    constant BGTZ : std_logic_vector(5 downto 0) := "000111";
    constant BLTZ : std_logic_vector(5 downto 0) := "000001";
    constant BGEZ : std_logic_vector(5 downto 0) := "100000";
    constant jr : std_logic_vector(5 downto 0) := "001000";


begin  -- TB

    UUT : alu
        generic map (WIDTH => WIDTH)
        port map (
            inp1   => input1,
            inp2   => input2,
            shift      => shift,
            OPSelect => OPSelect,
            Branch_Taken => Branch_Taken,
            Result => Result,
            Result_Hi => Result_Hi);

    process
    begin
        input1 <= (others => '0');
        input2 <= (others => '0');
        shift <= (others => '0');

        -- test 10+25 
        OPSelect    <= Add;
        input1 <= std_logic_vector(to_unsigned(10, input1'length));
        input2 <= std_logic_vector(to_unsigned(15, input2'length));
        wait for 40 ns;

        -- test 25-10
        OPSelect    <= Sub;
        input1 <= std_logic_vector(to_unsigned(25, input1'length));
        input2 <= std_logic_vector(to_unsigned(10, input2'length));
        wait for 40 ns;
        -- test 10 * -4
        OPSelect    <=  Mult;
        input1 <= std_logic_vector(to_unsigned(10, input1'length));
        input2 <= std_logic_vector(to_signed(-4, input2'length));
        wait for 40 ns;
        -- test 65536*131072
        OPSelect    <= Multu;
        input1 <= std_logic_vector(to_unsigned(65536, input1'length));
        input2 <= std_logic_vector(to_unsigned(131072, input2'length));
        wait for 40 ns;

        OPSelect    <= AND_c;
        input1 <= std_logic_vector(to_unsigned(16#FFFF#, input1'length));
        input2 <= std_logic_vector(to_signed(16#FFFF1234#, input2'length));
        wait for 40 ns;

        OPSelect <= lsr;
        input2 <= std_logic_vector(to_unsigned(16#F#, input2'length));
        shift <= std_logic_vector(to_unsigned(4, shift'length));
        input1 <= std_logic_vector(to_unsigned(0, input1'length)); -- doesn't matter
        wait for 40 ns;
        
        OPSelect <= asr;
        input2 <= std_logic_vector(to_signed(16#F0000008#, input2'length));
        shift <= std_logic_vector(to_unsigned(1, shift'length));
        input1 <= std_logic_vector(to_unsigned(0, input1'length)); -- doesnt matter;
        wait for 40 ns;

        OPSelect <= asr;
        input2 <= std_logic_vector(to_signed(16#0000008#, input2'length));
        shift <= std_logic_vector(to_unsigned(1, shift'length));
        input1 <= std_logic_vector(to_unsigned(0, input1'length)); -- doesnt matter;
        wait for 40 ns;

        OPSelect <= soltu;
        input2 <= std_logic_vector(to_unsigned(15, input2'length));
        shift <= std_logic_vector(to_unsigned(1, shift'length));
        input1 <= std_logic_vector(to_unsigned(10, input1'length)); -- doesnt matter;
        wait for 40 ns;

        OPSelect <= soltu;
        input2 <= std_logic_vector(to_unsigned(10, input2'length));
        shift <= std_logic_vector(to_unsigned(1, shift'length));
        input1 <= std_logic_vector(to_unsigned(15, input1'length)); -- doesnt matter;
        wait for 40 ns;

        OPSelect <= BLEZ;
        input2 <= std_logic_vector(to_unsigned(15, input2'length));
        shift <= std_logic_vector(to_unsigned(1, shift'length));
        input1 <= std_logic_vector(to_unsigned(5, input1'length)); -- doesnt matter;
        wait for 40 ns;

        OPSelect <= BGTZ;
        input2 <= std_logic_vector(to_unsigned(15, input2'length));
        shift <= std_logic_vector(to_unsigned(1, shift'length));
        input1 <= std_logic_vector(to_unsigned(5, input1'length)); -- doesnt matter;
        wait for 40 ns;






	report "ALL tests completed";
        wait;

    end process;



end TB;
