library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cpu_control is
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- input to controller from IR
        IR_2_C : in std_logic_vector(31 downto 26);
        IR_15_downto_0 : in std_logic_vector(15 downto 0);

        -- control signals in std logic (enables)
        PCWriteCond, PcWrite,Memread, MemWrite, IRWrite,
        RegWrite, IsSigned, JumpAndLink : out std_logic;

        -- control sgnals in std_logic vector (mux selects)
        RegDst, ALUSrcA, MemToReg, IorD : out std_logic_vector( 0 downto 0);
        ALUsrcB, PCSource  : out std_logic_vector(1 downto 0);

        -- signal to alu controller
        ALUOp : out std_logic_vector(5 downto 0)
    );
end cpu_control;

architecture two_proc of cpu_control is

    -- define states
    type state_type is (r_t, r_store, I_t, I_store, branch_a, b, 
    b_delay,j_c, jl_c,jr_a, jr_c, fetch, decode, mem, lw_s, lw_delay, sw_s,
     sw_delay, lw_done, HALT );
     signal state, next_state : state_type;

    -- define constants

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


begin

    process(clk, rst) -- 2 proccess model
    begin
        if(rst = '1') then
            state <= fetch;
        elsif(rising_edge(clk)) then
            state <= next_state;
        end if;
    end process;

    process(IR_2_C, state)
    begin
        -- set defaults
        next_state <= state;
        ALUOp <= "111110";
        memRead <= '1';
        IRWrite <= '0';
		PCWriteCond <= '0';
		PCWrite <= '0';
		MemWrite <= '0';
        JumpAndLink <= '0';
		IsSigned <= '0';
        RegWrite <= '0';
		PCSource <= (others => '0');
		ALUSrcB <= (others => '0');
		ALUSrcA <= (others => '0');
        MemToReg <= (others => '0');
        IorD  <= (others => '0');
        RegDst <= (others => '0');

        case state is
        when fetch =>

            IRWrite <='1';
            MemRead <= '1';
            PCWrite <= '1';
            ALUSrcB <= "01";

            next_state <= decode;

        when decode =>

            ALUOp <= IR_2_C;

            if(IR_2_C = r) then -- if r type
                next_state <= r_t;
                if(IR_15_downto_0(5 downto 0) = jr) then 
                    next_state <= jr_a;
                end if;
                -- if branch
            elsif((IR_2_C = BEQ) or (IR_2_C = BNE) or (IR_2_C = BLEZ) or (IR_2_C = BGTZ) or (IR_2_C = BLTZ)) then
                next_state <= branch_a;
                -- if mem access
            elsif((IR_2_C = lw) or (IR_2_C = sw)) then
                next_state <= mem;
            elsif(IR_2_C <= j) then
                PCSource <= "10";
                PCWrite <= '1';
                next_state <= j_c;
            elsif(IR_2_C <= jl) then
                jumpandlink <= '1';
                regWrite <= '1';
                PCSource <= "10";
                PCWrite <= '1';
                next_state <= jl_c;
            else
                next_state <= I_t;
            end if;

    -- r type instructions
        when r_t =>
            ALUSrcA(0) <= '1';
            ALUSrcB <= "00";
            ALUOp <= IR_2_C;
            next_state <= R_store;

            if((IR_15_downto_0(5 downto 0) = mflo) or (IR_15_downto_0(5 downto 0) = mfhi)) then
                RegDST(0) <= '1';
                RegWrite <= '1';
                next_state <= fetch;
            end if;

        when r_store =>
            RegDst(0) <= '1';
            RegWrite <= '1';
            next_state <= Fetch;

    -- I type instructions
        when I_t =>
            ALUSrcA(0) <= '1';
            ALUSrcB <= "10";
            ALUOp <= IR_2_C;
                if (IR_2_C = sltsi) then
                    isSigned <= '1';
                end if;
            next_state <= I_store;
        when I_store =>
            RegWrite <= '1';
            next_state <= fetch;

        -- LW/Sw
        
        when mem =>
            ALUSrcA(0) <= '1';
            ALUSrcB <= "10";
            ALUOp <= IR_2_C;
            if(IR_2_C = lw) then
                next_state <= lw_s;
            elsif(IR_2_C = sw) then
                next_state <= sw_s;
            end if;

    -- load word

        when lw_s =>
            ALUOp <= IR_2_C;
            IorD(0) <= '1';
            memRead <= '1';

            if(IR_15_downto_0 = x"FFF8" OR IR_15_downto_0 = x"FFFC") then
                next_state <= lw_done;
            else
                next_state <= lw_delay;
            end if;

        when lw_delay =>
            next_state <= lw_done;
        when lw_done => 
            RegWrite <= '1';
            MemtoReg(0) <= '1';
            next_state <= fetch;


    -- store word
        when sw_s =>
            memWrite <= '1';
            memRead <= '0';
            IorD(0) <= '1';
            next_state <= SW_delay;
        when sw_delay =>
            next_state <= fetch;

    -- Branching
        when branch_a =>
                ALUSrcB <= "11";
                next_state <= b;

        when b =>
                ALUOp <= IR_2_C;
                pcWriteCond <= '1';
                ALUSrcA(0) <= '1';
                PCSource <= "01";
                next_state <= b_delay;
        when b_delay =>
                next_state <= fetch;
    
    -- jump instruction
        when jr_a =>
            ALUSrcA(0) <= '1';
            ALUOp <= IR_2_C;
            next_state <= jr_c;
        when jr_c =>
            IorD(0) <= '1';
            ALUOp <= IR_2_C;
            next_state <= fetch;
        when j_c =>
            next_state <= fetch;
        when jl_c =>
            next_state <= fetch;
        when others => null;
    end case; 
    end process;
    end two_proc;





