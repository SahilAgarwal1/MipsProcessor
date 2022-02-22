library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_controller is
    port(
        IR_5_downto_0 : in std_logic_vector(5 downto 0);
        IR_20_downto_16 : in std_logic_vector(4 downto 0); -- 20 downto 16 is needed for branch instruction destinction
        ALUOp : in std_logic_vector(5 downto 0);
        OPselect : out std_logic_vector(5 downto 0);
        ALU_LO_HI : out std_logic_vector(1 downto 0);
        HI_en : out std_logic;
        LO_en : out std_logic
    );
end alu_controller;

architecture bhv of alu_controller is
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

    

    -- define op codes for branch instructions;

    begin
        process(IR_5_downto_0, IR_20_downto_16, ALUOp)
        begin
            -- set the defaults;
            HI_en <= '0';
            LO_en <= '0';
            ALU_LO_HI <= "00";
            OPSelect <= Add;


            if((ALUOp = f) or (ALUOp = lw) or (ALUOp = sw)) then -- if we are fetching a new instruction
                OPSelect <= Add;


            elsif(ALUOp = addi) then
                OPSelect <= Add;
            elsif(ALUOp = subi) then
                OPSelect <= sub;
            elsif(AlUop = andi) then
                OpSelect <= AND_c;
            elsif (ALUop = ori) then
                OpSelect <= OR_c;
            elsif (ALUop = xori) then
                OpSelect <= XOR_c;
            elsif (ALUop = sltsi) then
                OpSelect <= solts;
            elsif (ALUop = sltui) then
                OpSelect <= soltu;


            elsif ((ALUop = BEQ) or (ALUop = BNE) or (ALUop = BLEZ) or (ALUop = BGTZ)) then -- branch instructions
                OPSelect <= ALUop;
            elsif(ALUop = BLTZ) then -- since BLTZ and BGEZ have the same opCode, we check IR20 downto 16
                if (IR_20_downto_16 = "00000") then
                    OPSelect <= BLTZ;
                else
                    OPSelect <= BGEZ;
                end if;


            elsif(ALUop = "000010") then
                OPSelect <= j;
            elsif (ALUop = "000011") then
                OPSelect <= jl;
            elsif (ALUop = "001000") then
                OPSelect <= jr;


            elsif(ALUop = r) then -- if the instruction is a r instruction
                OPSelect <= IR_5_downto_0;
                if((IR_5_downto_0 = mult) or IR_5_downto_0 = multu) then
                    Hi_en <= '1';
                    LO_en <= '1';
                end if;

                if(IR_5_downto_0 = mflo) then
                    ALU_LO_HI <= "01";
                elsif(IR_5_downto_0 = mfhi) then
                    ALU_LO_HI <= "10";
                end if;

            end if;
        end process;
    end bhv;


