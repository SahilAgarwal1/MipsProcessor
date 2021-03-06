library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_controller_tb is
end alu_controller_tb;

architecture TB of alu_controller_tb is

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

    component alu_controller
        port(
            IR_5_downto_0 : in std_logic_vector(5 downto 0);
            IR_20_downto_16 : in std_logic_vector(4 downto 0); -- 20 downto 16 is needed for branch instruction destinction
            ALUOp : in std_logic_vector(5 downto 0);
            OPselect : out std_logic_vector(5 downto 0);
            ALU_LO_HI : out std_logic_vector(1 downto 0);
            HI_en : out std_logic;
            LO_en : out std_logic
        );
    end component; 

        -- define constants from alu
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
    constant j : std_logic_vector(5 downto 0) := "000010";
    constant jl : std_logic_vector(5 downto 0) := "000011";
    constant f : std_logic_vector(5 downto 0) := "111110";
    constant r : std_logic_vector(5 downto 0) := "000000";

    -- define I op codes
    constant addi : std_logic_vector(5 downto 0) := "001001";
    constant subi : std_logic_vector(5 downto 0) := "010000";
    constant andi : std_logic_vector(5 downto 0) := "001100";
    constant ori : std_logic_vector(5 downto 0) := "001101";
    constant xori : std_logic_vector(5 downto 0) := "001110";
    constant sltsi : std_logic_vector(5 downto 0) := "001010";
    constant sltui : std_logic_vector(5 downto 0) := "001011";
    constant lw : std_logic_vector(5 downto 0) := "100011";
    constant sw : std_logic_vector(5 downto 0) := "101011";


    -- define signals to be used

    -- alu signals
    constant WIDTH  : positive                           := 32;
    signal input1   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal input2   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal shift : std_logic_vector(4 downto 0) := (others => '0'); -- IR [10:6]
    signal OPSelect : std_logic_vector(5 downto 0) := (others => '0') ;
    signal Branch_Taken : std_logic := '0';
    signal Result : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal Result_Hi : std_logic_vector(WIDTH-1 downto 0) := (others => '0');

    -- alu controller signals

    signal IR_5_downto_0 : std_logic_vector(5 downto 0);
    signal IR_20_downto_16 : std_logic_vector(4 downto 0);
    signal ALUOp : std_logic_vector(5 downto 0);
    signal ALU_LO_HI : std_logic_vector(1 downto 0);
    signal HI_en : std_logic;
    signal LO_en : std_logic;
begin

    alu_l : alu
    generic map (WIDTH => WIDTH)
    port map (
        inp1   => input1,
        inp2   => input2,
        shift      => shift,
        OPSelect => OPSelect,
        Branch_Taken => Branch_Taken,
        Result => Result,
        Result_Hi => Result_Hi);

    alu_c : alu_controller
    port map(
        IR_5_downto_0 => IR_5_downto_0, -- function code
        IR_20_downto_16 => IR_20_downto_16, -- check for branch
        ALUOp => ALUop, -- opCode
        OPselect => OPSelect,
        ALU_LO_HI => ALU_LO_Hi,
        HI_en => HI_en,
        LO_en => LO_en
    );

    process
    begin
        -- set defaults
        input1 <= (0 => '1', others => '0');
        input2 <= (0 => '1', 1 => '1',  others => '0');
        shift <= (0 => '1', others => '0');
        IR_5_downto_0 <= (others => '0');
        IR_20_downto_16 <= (others => '0');

        -- check each instruction;

        -- start with R type instructions
        wait for 40 ns;
        -- add unsigned
        ALUOp <= r; -- r instructions
        IR_5_downto_0 <= ADD; --add
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(4, Result'length))) Report "error test 1";

        wait for 40 ns;
        IR_5_downto_0 <= SUB; -- sub
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(-2, Result'length))) Report "error test 2";
        
        wait for 40 ns;
        IR_5_downto_0 <= multu; -- multiply unsigned
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(3, Result'length))) Report "error test 3";

        wait for 40 ns;
        IR_5_downto_0 <= mult; -- multiply signed
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(3, Result'length))) Report "error test 4";

        wait for 40 ns;
        IR_5_downto_0 <= AND_c; -- 
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 5";

        wait for 40 ns;
        IR_5_downto_0 <= OR_c;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(3, Result'length))) Report "error test 6";

        wait for 40 ns;
        IR_5_downto_0 <= XOR_c;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(2, Result'length))) Report "error test 7";

        wait for 40 ns;
        IR_5_downto_0 <= lsr;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 8";

        wait for 40 ns;
        IR_5_downto_0 <= lsl;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(6, Result'length))) Report "error test 9";

        wait for 40 ns;
        IR_5_downto_0 <= asr;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 10";

        wait for 40 ns;
        IR_5_downto_0 <= solts;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 11";

        wait for 40 ns;
        IR_5_downto_0 <= soltu;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 12";

        wait for 40 ns;
        IR_5_downto_0 <= mflo;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(0, Result'length))) Report "error test 13";

        wait for 40 ns;
        IR_5_downto_0 <= mfhi;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(0, Result'length))) Report "error test 14";

        wait for 40 ns;
        IR_5_downto_0 <= jr;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 15";
        wait for 40 ns;

        report " ALL R TYPE INSTRUCTIONS COMPLETE";

        -- start to test the immediate instructions

        wait for 40 ns;
        AlUop <= addi;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(4, Result'length))) Report "error test 16";

        wait for 40 ns;
        ALUop <= subi;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(-2, Result'length))) Report "error test 17";

        wait for 40 ns;
        ALUop <= andi;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 18";

        wait for 40 ns;
        ALUop <= ori;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(3, Result'length))) Report "error test 19";

        wait for 40 ns;
        ALUop <= xori;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(2, Result'length))) Report "error test 20";

        wait for 40 ns;
        ALUop <= sltsi;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 21";

        wait for 40 ns;
        ALUop <= sltui;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 22";

        wait for 40 ns;
        ALUop <= sltsi;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(1, Result'length))) Report "error test 23";

        wait for 40 ns;
        ALUop <= lw;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(4, Result'length))) Report "error test 24";

        wait for 40 ns;
        ALUop <= sw;
        wait for 10 ns;
        assert(Result = std_logic_vector(to_signed(4, Result'length))) Report "error test 25";

        wait for 40 ns;
        ALUop <= BEQ;
        wait for 10 ns;
        assert(Branch_Taken = '0') Report "error test 26";

        wait for 40 ns;
        ALUop <= BNE;
        wait for 10 ns;
        assert(Branch_Taken = '1') Report "error test 27";

        wait for 40 ns;
        ALUop <= BLEZ;
        wait for 10 ns;
        assert(Branch_Taken = '0') Report "error test 28";

        wait for 40 ns;
        ALUop <= BGTZ;
        wait for 10 ns;
        assert(Branch_Taken = '1') Report "error test 29";

        wait for 40 ns;
        ALUop <= BLTZ;
        wait for 10 ns;
        assert(Branch_Taken = '0') Report "error test 30";

        wait for 40 ns;
        ALUop <= BLTZ;
        IR_20_downto_16 <= "00001";
        wait for 10 ns;
        assert(Branch_Taken = '1') Report "error test 31";

        wait for 40 ns;

        report "Finished testing all I instrictions";

        
        wait;
    end process;
end TB;


        



        




