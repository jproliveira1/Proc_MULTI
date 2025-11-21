`ifndef PARAM
	`include "Parametros.v"
`endif

module Multiciclo (
	input  logic clockCPU, clockMem,
	input  logic reset,
	output logic [31:0] PC,
	output logic [31:0] Instr,
	input  logic [4:0]  regin,
	output logic [31:0] regout,
	output logic [3:0]  estado,
	output logic [31:0] saida1,
	output logic [31:0] saida2
);

	// ====================================================================
	// 1. Fios de Controle (Vindos da FSM) e Dados
	// ====================================================================
	wire       wEscreveIR;
	wire       wEscrevePC;
	wire       wEscrevePCCond;
	wire       wEscrevePCBack;
	wire [1:0] wOrigAULA;
	wire [1:0] wOrigBULA;
	wire [1:0] wMem2Reg;
	wire       wOrigPC;
	wire       wIouD;
	wire       wRegWrite;
	wire       wMemWrite;
	wire       wMemRead;
	wire [1:0] wALUOp;
	wire [3:0] wState;
	
	// Fios de Dados Internos
	wire [31:0] wReadData1, wReadData2; // Saídas do Banco de Regs
	wire [31:0] wImediato;              // Saída do ImmGen
	wire [31:0] wSaidaULA;              // Saída Combinacional da ULA
	wire        wZero;                  // Flag Zero da ULA
	wire [31:0] wMemData, wRmem;        // Saídas da Memória
	wire [31:0] wIouD_Addr;             // Endereço Efetivo da Memória
	wire [4:0]  wALUControl;            // Sinal de controle para a ULA

	// Conecta estado para depuração externa
	assign estado = wState;

	// ====================================================================
	// 2. Registradores (Elementos de Estado)
	// ====================================================================
	
	reg [31:0] PCBack; // Salva PC antigo
	reg [31:0] IR;     // Instruction Register
	reg [31:0] MDR;    // Memory Data Register
	
	reg [31:0] A;      // Buffer de Saída 1 do Banco
	reg [31:0] B;      // Buffer de Saída 2 do Banco
	reg [31:0] ALUOut; // Registrador de Saída da ULA

	// Saída Instr para o TopLevel (Depuração) e uso interno
	assign Instr = IR;

	// ====================================================================
	// 3. Multiplexadores (Lógica Combinacional)
	// ====================================================================
	
	reg  [31:0] wMuxOrigA;
	reg  [31:0] wMuxOrigB;
	reg  [31:0] wMuxMem2Reg;
	wire [31:0] wMuxOrigPC;

	// MUX A da ULA
	always @(*) begin
		case (wOrigAULA)
			2'b00: wMuxOrigA = PCBack;
			2'b01: wMuxOrigA = A;
			2'b10: wMuxOrigA = PC;
			default: wMuxOrigA = 32'b0;
		endcase
	end

	// MUX B da ULA
	always @(*) begin
		case (wOrigBULA)
			2'b00: wMuxOrigB = B;
			2'b01: wMuxOrigB = 32'd4;
			2'b10: wMuxOrigB = wImediato;
			default: wMuxOrigB = 32'b0;
		endcase
	end

	// MUX Mem2Reg (Escrita no Banco)
	always @(*) begin
		case (wMem2Reg)
			2'b00: wMuxMem2Reg = ALUOut;
			2'b01: wMuxMem2Reg = PC; // Salva PC (PC+4 do Fetch) no JAL/JALR
			2'b10: wMuxMem2Reg = MDR;
			default: wMuxMem2Reg = 32'b0;
		endcase
	end

	// MUX Origem PC
	assign wMuxOrigPC = wOrigPC ? ALUOut : wSaidaULA;



	// ====================================================================
	// 4. Lógica Sequencial (Updates no Clock)
	// ====================================================================

	// PC e PCBack
	always @(posedge clockCPU or posedge reset) begin
		if (reset) begin
			PC     <= TEXT_ADDRESS; // Definido no Parametros.v
			PCBack <= TEXT_ADDRESS;
		end
		else begin
			// Escreve no PC se for incondicional OU (condicional E zero)
			if (wEscrevePC || (wEscrevePCCond && wZero))
				PC <= wMuxOrigPC;
			
			if (wEscrevePCBack)
				PCBack <= PC;
		end
	end

	// IR (Instruction Register)
	always @(posedge clockCPU) begin
		if (wEscreveIR)
			IR <= wRmem;
	end

	// MDR (Memory Data Register)
	always @(posedge clockCPU) begin
		MDR <= wRmem;
	end

	// A, B e ALUOut
	always @(posedge clockCPU) begin
		A      <= wReadData1;
		B      <= wReadData2;
		ALUOut <= wSaidaULA;
	end

		// MUX IouD (Endereço da Memória)
	assign wIouD_Addr = wIouD ? ALUOut : PC;

	// ====================================================================
	// 5. Instanciação dos Módulos
	// ====================================================================

	Control_MULTI CtrlUnit (
		.iCLK(clockCPU),
		.iRST(reset),
		.Opcode(IR[6:0]),
		.oEscreveIR(wEscreveIR),
		.oEscrevePC(wEscrevePC),
		.oEscrevePCCond(wEscrevePCCond),
		.oEscrevePCBack(wEscrevePCBack),
		.oOrigAULA(wOrigAULA),
		.oOrigBULA(wOrigBULA),
		.oMem2Reg(wMem2Reg),
		.oOrigPC(wOrigPC),
		.oIouD(wIouD),
		.oRegWrite(wRegWrite),
		.oMemWrite(wMemWrite),
		.oMemRead(wMemRead),
		.oALUOp(wALUOp),
		.oState(wState)
	);

	Registers REG_FILE (
		.iCLK(clockCPU),
		.iRST(reset),
		.iRegWrite(wRegWrite),
		.iReadRegister1(IR[19:15]),
		.iReadRegister2(IR[24:20]),
		.iWriteRegister(IR[11:7]),
		.iWriteData(wMuxMem2Reg),
		.oReadData1(wReadData1),
		.oReadData2(wReadData2),
		.iRegDispSelect(regin),
		.oRegDisp(regout)
	);

	ImmGen IMM_GEN (
		.iInstrucao(IR),
		.oImm(wImediato)
	);

	// --- NOVO: Decodificador da ULA Modularizado ---
	alu_control ALU_CTRL (
		.ALUOp(wALUOp),
		.funct3(IR[14:12]),
		.funct7(IR[31:25]),
		.ALUCtrl(wALUControl)
	);

	ALU ULA (
		.iControl(wALUControl),
		.iA(wMuxOrigA),
		.iB(wMuxOrigB),
		.oResult(wSaidaULA),
		.Zero(wZero)
	);

	// ====================================================================
	// 6. Memória Unificada (Texto e Dados)
	// ====================================================================
	
	// ramI e ramD são módulos gerados pelo Quartus (IP Catalog)
	// A seleção é feita pelo bit 28 do endereço (Mapa de Memória)
	
	// *CORREÇÃO DE LIGAÇÃO DA MEMÓRIA*:
	// Como temos duas memórias físicas (ramI e ramD) simulando uma unificada,
	// precisamos de fios separados para as saídas delas antes do Mux final.
	
	wire [31:0] wQ_Instr;
	wire [31:0] wQ_Data;

	ramI MemInst (
		.address(wIouD_Addr[11:2]), 
		.clock(clockMem), 
		.data(B), 
		.wren(wMemWrite & ~wIouD_Addr[28]), 
		.q(wQ_Instr)
	);

	ramD MemData (
		.address(wIouD_Addr[11:2]), 
		.clock(clockMem), 
		.data(B), 
		.wren(wMemWrite & wIouD_Addr[28]), 
		.q(wQ_Data)
	);

	// Mux de Saída da Memória Unificada
	assign wRmem = wIouD_Addr[28] ? wQ_Data : wQ_Instr;
	
	assign saida1 = wIouD_Addr;
	assign saida2 = wRmem;

endmodule
