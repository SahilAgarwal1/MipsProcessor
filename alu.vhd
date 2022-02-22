library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is 
    generic (
        WIDTH : positive := 32
    );
    port(
        inp1 : in std_logic_vector(WIDTH-1 downto 0);
        inp2 : in std_logic_vector(WIDTH-1 downto 0);
        shift : in std_logic_vector(4 downto 0); -- IR [10:6]
        OPSelect : in std_logic_vector(5 downto 0);
        Branch_Taken : out std_logic;
        Result : out std_logic_vector(WIDTH-1 downto 0);
        Result_Hi : out std_logic_vector(WIDTH-1 downto 0)
    );
end alu; 

architecture bhv of alu is
    -- define the operations
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

    -- signals 
    signal Input1 : unsigned(WIDTH-1 downto 0);
    signal Input2 : unsigned(WIDTH-1 downto 0);
    signal SHIFT_AMOUNT : natural;
    signal mult_out : unsigned((WIDTH*2)-1 downto 0);
    signal output : unsigned(WIDTH-1 downto 0);

begin
    SHIFT_AMOUNT <= (to_integer(unsigned(shift)));
    Input1 <= unsigned(inp1);
    Input2 <= unsigned(inp2);

    process(Input1, Input2, OPSelect, SHIFT_AMOUNT, inp1, inp2, mult_out)
    begin
        mult_out <= (others => '0');
        Branch_Taken <= '0';
        output <=(others => '0');

        case OPSelect is
            when Add =>
                output <= Input1 + Input2;
            when Sub =>
                output <= Input1 - Input2;
            when Mult =>
                mult_out <= unsigned((signed(Input1) * signed(Input2)));
                output <= mult_out(WIDTH-1 downto 0);
            when Multu =>
                mult_out <= Input1 * Input2;
                output <= mult_out(WIDTH-1 downto 0);
            when AND_c =>
                output <= Input1 and Input2;
            when OR_c =>
                output <= Input1 or Input2;
            when XOR_c =>
                output <= Input1 xor Input2;
            when lsr =>
                output <= SHIFT_RIGHT(Input2, SHIFT_AMOUNT);
            when lsl =>
                output <= SHIFT_LEFT(Input2, SHIFT_AMOUNT);
            when asr =>
                output <= unsigned(SHIFT_RIGHT((signed(Input2)), SHIFT_AMOUNT));
            when solts =>
                if(signed(Input1) < signed(Input2)) then
                    output <= (0 => '1', others => '0');
                else
                    output <= (others => '0');
                end if;
            when soltu =>
                if(Input1 < Input2) then
                    output <= (0 => '1', others => '0');
                else
                    output <= (others => '0');
                end if;
            when mfhi =>
                output <= (others => '0');
            when mflo =>
                output <= (others => '0');
            when BEQ =>
                if(Input1 = Input2) then
                    Branch_Taken <= '1';
                end if;
            when BNE =>
                if(Input1 /= Input2) then
                    Branch_Taken <= '1';
                end if;
            when BLEZ =>
                if(signed(Input1) <= 0) then
                    Branch_Taken <= '1';
                end if;
            when BGTZ =>
                if(signed(Input1) > 0) then
                    Branch_Taken <= '1';
                end if;
            when BLTZ => 
                if(signed(Input1) < 0) then
                    Branch_Taken <= '1';
                end if;
            when BGEZ =>
                if (signed(Input1) >= 0) then
                    Branch_Taken <= '1';
                end if;
            when jr =>
                output <= Input1;
            when others => null;
        end case;
    end process;

    Result <= std_logic_vector(output(WIDTH-1 downto 0));
    Result_Hi <= std_logic_vector(mult_out((WIDTH*2)-1 downto WIDTH));

    

end bhv; --alu