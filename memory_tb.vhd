library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_tb is
end memory_tb;

architecture tb of memory_tb is
    component memory

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
    end component;

    signal rst : std_logic := '1';
    signal memWrite : std_logic;
    signal clk : std_logic := '0';
    signal pc_alu_mux_in : std_logic_vector(31 downto 0);
    signal inport0and1_en: std_logic;
    signal inport : std_logic_vector(8 downto 0);
    signal outport : std_logic_vector(31 downto 0);
    signal output : std_logic_vector(31 downto 0);
    signal data :  std_logic_vector(31 downto 0);
    

begin

    UUT : memory
    port map(
        rst => rst,
        memWrite => memWrite,
        clk => clk,
        pc_alu_mux_in => pc_alu_mux_in,
        inport0and1_en => inport0and1_en,
        inport => inport,
        outport => outport,
        output => output,
        data => data
    );

    clk <= not clk after 10 ns;
    
    process
    begin
        wait for 40 ns;
        rst <= '0';
        memWrite <= '1'; 
        data <= x"0A0A0A0A";
        pc_alu_mux_in <= x"00000000";
        wait for 40 ns;
        data <= x"0F0F0F0F";
        pc_alu_mux_in <= x"00000004";
        wait for 40 ns;
        memWrite <= '0';
        pc_alu_mux_in <= x"00000000";
        wait for 40 ns;
        pc_alu_mux_in <= x"00000001";
        wait for 40 ns;
        pc_alu_mux_in <= x"00000004";
        wait for 40 ns;
        pc_alu_mux_in <= x"00000005";
        wait for 40 ns;
        pc_alu_mux_in <= x"0000FFFC";
        memWrite <='1';
        data <= x"00001111";
        wait for 40 ns;
        memWrite <='0';
        pc_alu_mux_in <= x"0000FFF8";
        inport <= "100000000";
        inport0and1_en <= '0';
        wait for 40 ns;
        pc_alu_mux_in <= x"0000FFFC";
        inport <= "000000001";
        inport0and1_en <= '1';
        wait for 40 ns;
        wait;
    end process;
end tb;
