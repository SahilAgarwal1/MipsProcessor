library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    port(
        rst : in std_logic;
        memWrite : in std_logic;
        clk : in std_logic;
        pc_alu_mux_in : in std_logic_vector(31 downto 0);
        inport0and1_en: in std_logic;
        inport : in std_logic_vector(8 downto 0);
        outport : out std_logic_vector(31 downto 0);
        output : out std_logic_vector(31 downto 0);
        data : in std_logic_vector(31 downto 0)
    );
end memory;

architecture struc of memory is
    signal inport0_en, inport1_en : std_logic;
    signal extended_input : std_logic_vector(31 downto 0);
    signal inport0_out, inport1_out : std_logic_vector(31 downto 0);
    signal ram_out : std_logic_vector(31 downto 0);
    signal write_en, outport_en : std_logic;
    signal Rd_data_sel : std_logic_vector(1 downto 0);
    signal Rd_data_sel_delayed : std_logic_vector(1 downto 0);
begin
    -- extend the input, and set up the enables
    extended_input <= std_logic_vector(resize(unsigned(inport), 32)); -- extend to 32 bits
    inport0_en <= not (inport0and1_en);
    inport1_en <= inport0and1_en;

    -- assign the structural components of the memory

    address_logic : entity work.memory_address_logic
        port map(
            memWrite => memWrite,
            address => pc_alu_mux_in,
            write_en => write_en,
            outport_en => outport_en,
            Rd_data_sel => Rd_data_sel
        );
    
    inport0 : entity work.reg
        generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => '0',
            load => inport0_en,
            input => extended_input,
            output => inport0_out
        );

    inport1 : entity work.reg
    generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => '0',
            load => inport1_en,
            input => extended_input,
            output => inport1_out
        );
    
    outport0 : entity work.reg
    generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => rst,
            load => outport_en,
            input => data,
            output => outport
        );

    ram: entity work.ram
        port map(
            address => pc_alu_mux_in(9 downto 2),
            clock => clk,
            data => data,
            wren => write_en,
            q => ram_out
        );

    delay_reg: entity work.reg
    generic map(WIDTH => 2)
    port map(
        clk => clk,
        rst => '0',
        load => '1',
        input => Rd_data_sel,
        output => Rd_data_sel_delayed
    );

    readData_mux : entity work.mux
    generic map(PORTS => 3)
    port map(
        inputs(0) => ram_out,
        inputs(1) => inport0_out,
        inputs(2) => inport1_out,
        sel => Rd_data_sel,
        output => output
    );
end struc; 


