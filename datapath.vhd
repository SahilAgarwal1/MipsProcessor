library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port(
        clk : in std_logic;
        rst : in std_logic;

        --signals from controller
        pc_en, MemRead,MemWrite,IRWrite,
        JumpAndLink, IsSigned, RegWrite : in std_logic;

        ALUOp : in std_logic_vector(5 downto 0);

        -- mux selects
        RegDst,ALUSrcA,IorD,MemToReg : in std_logic_vector(0 downto 0);
        ALUSrcB, PCSource : in std_logic_vector(1 downto 0);

        -- signals to controller
        IR_2_c : out std_logic_vector(31 downto 26);
        Branch_taken : out std_logic;
        IR_15_downto_0 : out std_logic_vector(15 downto 0);

        -- toplevel signals
        switch : in std_logic_vector(9 downto 0);
        LED : out std_logic_vector(31 downto 0)

    );
end datapath;

architecture struc of datapath is
    -- the inbetween signals are declared here

    -- Program Counter
    signal pc_out : std_logic_vector(31 downto 0); -- goes into the memory address mux
    signal pc_in : std_logic_vector(31 downto 0); -- goes from pc mux to pc register
    -- memory
    signal mem_in : std_logic_vector(31 downto 0); -- input from memory mux to memory
    signal mem_out : std_logic_vector(31 downto 0); -- output from memory
    signal MEMORY_DATA_REGISTER_out : std_logic_vector(31 downto 0); -- output from memory data reg
    -- IR
    signal IR_out : std_logic_vector(31 downto 0);
    signal IR_2_PC : std_logic_vector(31 downto 0);
    -- Registers
    signal IR_2_RF_mux_1, IR_2_RF_mux_2 : std_logic_vector(31 downto 0);
    signal write_reg : std_logic_vector(4 downto 0);
    signal write_reg_32 : std_logic_vector(31 downto 0);
    signal write_data : std_logic_vector(31 downto 0);
    signal regA_in,regB_in,regA_out,regB_out : std_logic_vector(31 downto 0);
    --AlU
    signal ALUinp1,ALUinp2,result,result_hi,ALU_OUT, LO, HI, ALU_MUX_OUT: std_logic_vector(31 downto 0);
    -- ALU CONTROLLER
    signal OPselect : std_logic_vector(5 downto 0);
    signal ALU_LO_HI : std_logic_vector(1 downto 0);
    signal HI_en : std_logic;
    signal LO_en : std_logic;
    -- sign extender
    signal IR_ext, IR_left : std_logic_vector(31 downto 0);

begin


    PC: entity work.reg
        generic map(width => 32)
        port map(
            clk => clk,
            rst => rst,
            load => pc_en,
            input => pc_in,
            output => pc_out
        );

    PC_MUX: entity work.mux
        generic map(PORTS => 2)
        port map (
            inputs(0) => pc_out,
            inputs(1) => ALU_OUT,
            sel => IorD,
            output => mem_in
        );
    -- MEMORY 
    MEM : entity work.memory
        port map(
            rst => rst,
            memWrite => memWrite,
            clk => clk, 
            pc_alu_mux_in => mem_in,
            inport0and1_en => switch(9),
            inport => switch(8 downto 0),
            outport => LED,
            output  => mem_out,
            data => regB_out
        );

    MDR : entity work.reg
        generic map(width => 32)
        port map(
            clk => clk,
            rst => rst,
            load => '1',
            input => mem_out,
            output => MEMORY_DATA_REGISTER_out
        );

    
    
    IR : entity work.reg
        generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => rst,
            load => IRWrite,
            input => mem_out,
            output => IR_out
        );

    Reg_in_MUX : entity work.mux
        generic map (PORTS => 2)
        port map(
            inputs(0) => IR_2_RF_mux_1,
            inputs(1) => IR_2_RF_mux_2,
            output => write_reg_32,
            sel => RegDst
        );
    
    M : entity work.mux
        generic map(PORTS => 2)
        port map(
            inputs(0) => ALU_MUX_OUT,
            inputs(1) => MEMORY_DATA_REGISTER_out,
            output => write_data,
            sel => MemToReg
        );
    -- REgisters

    RF : entity work.registers
        port map(
            clk => clk,
            rst => rst,
            write_reg => write_Reg,
            write_data => write_data,
            write_en => regWrite,
            read_reg1 => IR_out(25 downto 21),
            read_reg2 => IR_out(20 downto 16),
            read_data1 => regA_in,
            read_data2 => regB_in,
            jl => jumpAndLink
        );

    regA : entity work.reg
        generic map(width => 32)
        port map(
            clk => clk,
            rst => rst,
            load => '1',
            input => regA_in,
            output => regA_out
        );

    regB : entity work.reg
        generic map(width => 32)
        port map(
            clk => clk,
            rst => rst,
            load => '1',
            input => regB_in,
            output => regB_out
        );    
    
    MUX_A : entity work.mux
        generic map(PORTS => 2)
        port map(
            inputs(0) => pc_out,
            inputs(1) => regA_out,
            output => ALUinp1,
            sel => ALUSrcA
        );

    MUX_B : entity work.mux
        generic map(PORTS => 4)
        port map(
            inputs(0) => regB_out,
            inputs(1) => x"00000004",
            inputs(2) => IR_ext,
            inputs(3) => IR_left,
            output => ALUinp2,
            sel => ALUSrcB
        );

    -- ALU
    ALU : entity work.alu
        port map(
            inp1 => ALUinp1,
            inp2 => ALUinp2,
            shift => IR_out(10 downto 6),
            OPSelect => OPSelect,
            Branch_Taken => Branch_Taken,
            result => result,
            result_HI => result_hi
            
        );

    ALU_OUT_reg : entity work.reg
        generic map(width => 32)
        port map(
            clk => clk,
            rst => rst,
            input => Result,
            output => ALU_OUT,
            load => '1'
        );

    HI_reg : entity work.reg
        generic map(width => 32)
        port map(
            clk => clk,
            rst => rst,
            input => result_hi,
            output => HI,
            load => Hi_en
        );

    LO_reg : entity work.reg
        generic map(width => 32)
        port map(
            clk => clk,
            rst => rst,
            input => result,
            output => LO,
            load => LO_en
        );

    ALU_C : entity work.ALU_CONTROLLER
        port map(
            IR_5_downto_0 => IR_out(5 downto 0),
            IR_20_downto_16 => IR_out(20 downto 16),
            ALUOp => ALUOp,
            OPSelect => OpSelect,
            ALU_LO_HI => ALU_LO_HI,
            HI_en => HI_en,
            Lo_en => LO_en
        );

    ALU_MUX : entity work.mux
        generic map (ports => 3)
        port map(
            inputs(0) => ALU_OUT,
            inputs(1) => LO,
            inputs(2) => HI,
            output => ALU_MUX_OUT,
            sel => ALU_LO_HI

        );

    SE : entity work.SIGN_EXTEND
        generic map(
            input_length => 16,
            output_length => 32
        )
        port map(
            input => IR_out(15 downto 0),
            output => IR_ext,
            isSigned => isSigned
        );
    
    MUX_to_PC : entity work.mux 
        generic map(PORTS => 3)
        port map(
            inputs(0) => result,
            inputs(1) => ALU_OUT,
            inputs(2) => IR_2_PC,
            output => pc_in,
            sel => PCsource
        );


    IR_left <= IR_ext(29 downto 0) & "00";
    IR_2_PC <= pc_out(31 downto 28) & IR_out(25 downto 0) & "00";
    write_reg <= write_reg_32(4 downto 0);
    IR_2_RF_mux_1 <=  x"000000" & "000" & IR_out(20 downto 16);
    IR_2_RF_mux_2 <=  x"000000" & "000" & IR_out(15 downto 11);
    Ir_2_c <= IR_out(31 downto 26);
    IR_15_downto_0 <= Ir_out(15 downto 0);
end struc;

    
    
    
    
    