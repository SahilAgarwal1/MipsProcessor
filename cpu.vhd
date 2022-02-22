library ieee;
use ieee.std_logic_1164.all;

entity cpu is
	port(
		clk : in std_logic;
		rst  : in std_logic;
		switches : in std_logic_vector(9 downto 0);
		LEDs	 : out std_logic_vector(31 downto 0));
end cpu;

architecture struc of cpu is

	-- signals between controller and datapath
	signal PCWriteCond, PcWrite,Memread, MemWrite, IRWrite,
	RegWrite, IsSigned, JumpAndLink, PC_en : std_logic;

	signal RegDst, ALUSrcA, MemToReg, IorD : std_logic_vector( 0 downto 0);
	signal ALUsrcB, PCSource  : std_logic_vector(1 downto 0);

	signal ALUOp				:  std_logic_vector(5 downto 0); 

	signal IR_2_c		:  std_logic_vector(31 downto 26);
	signal Branch_taken			:  std_logic;
	signal IR_15_downto_0				:  std_logic_vector(15 downto 0);
	
begin 

PC_en <= (PCWriteCond and Branch_taken) or PCWrite;

DATAPATH : entity work.datapath
	port map (
		clk		 			=> clk,
		rst 				=> rst,
		PC_en				=> PC_en,
		MemRead			 	=> MemRead,
		MemWrite			=> MemWrite,
		RegDst 				=> RegDst,
		ALUSrcA				=> ALUSrcA,
		ALUSrcB				=> ALUSrcB,
		PCSource			=> PCSource,
		MemToReg 			=> MemToReg,
		IorD 				=> IorD,
		IR_2_C	=> IR_2_c,
		IRWrite 			=> IRWrite,
		RegWrite			=> RegWrite,
		ALUOp				=> ALUOp,
		IsSigned			=> IsSigned,
		JumpAndLink			=> JumpAndLink,
		Branch_taken 		=> Branch_taken,
		IR_15_downto_0			=> IR_15_downto_0,
		switch 			=> switches,
		LED	 			=> LEDs

	);

CONTROLLER: entity work.cpu_control
	port map (
		clk	=> clk,
		rst => rst,
		PCWrite	=> PCWrite,
		PCWriteCond	=> PCWriteCond,
		ALUOp => ALUOp,
		IsSigned => IsSigned,
		JumpAndLink	=> JumpAndLink,
		RegDst => RegDst,
		ALUSrcA	=> ALUSrcA,
		ALUSrcB	=> ALUSrcB,
		PCSource => PCSource,
		MemToReg => MemToReg,
		IorD => IorD,
		MemRead	=> MemRead,
		MemWrite => MemWrite,
		IRWrite => IRWrite,
		RegWrite => RegWrite,
		IR_2_C => IR_2_c,
		IR_15_downto_0 => IR_15_downto_0
		);




end struc;