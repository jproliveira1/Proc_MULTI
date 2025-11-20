`ifndef PARAM
    `include "Parametros.v"
`endif

// *
// *	Bloco de Controle MULTICICLO
// *

module Control_MULTI (
    input            iCLK, iRST,
    input  [6:0]  Opcode,
     output            oEscreveIR,
     output            oEscrevePC,
     output            oEscrevePCCond,
     output            oEscrevePCBack,
     output [1:0]    oOrigAULA,
     output [1:0]    oOrigBULA,
     output [1:0]    oMem2Reg,
     output            oOrigPC,
     output            oIouD,
     output            oRegWrite,
     output            oMemWrite,
     output            oMemRead,
     output [1:0]    oALUOp,
     output [3:0]    oState
);


reg   [3:0]    pr_state;    //Estado atual
wire    [3:0]    nx_state;    //Próximo estado

assign    oState = pr_state;


initial
    begin
        pr_state <= ST_FETCH;
    end

always@(posedge iCLK or posedge iRST)
    begin
        if(iRST)
            pr_state <= ST_FETCH;
        else
            pr_state <= nx_state;
    end

always @(*)
		case(pr_state)
		
			ST_FETCH:
				begin
					oEscreveIR		<= 1'b1;
					oEscrevePC		<= 1'b1;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b1;
					oOrigAULA		<= 2'b10;
					oOrigBULA		<= 2'b01;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b1;
					oALUOp			<=	2'b00;
					nx_state			<= ST_FETCH1;
				end
					
			ST_FETCH1:
				begin
					oEscreveIR		<= 1'b1;
					oEscrevePC		<= 1'b1;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b1;
					oOrigAULA		<= 2'b10;
					oOrigBULA		<= 2'b01;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b1;
					oALUOp			<=	2'b00;
					nx_state			<= ST_DECODE;
				end
				
			ST_DECODE:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b10;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b00;
					
					case(Opcode)
						OPC_LOAD,
						OPC_STORE:	nx_state			<= ST_LWSW;
						OPC_RTYPE:	nx_state			<= ST_RTYPE;
						OPC_BRANCH:	nx_state			<= ST_BRANCH;
						OPC_JAL:		nx_state			<= ST_JAL;
						OPC_OPIMM:	nx_state			<= ST_ADDI;
						OPC_JALR:	nx_state			<= ST_JALR;
						OPC_LUI:		nx_state			<= ST_LUI;
						default:		nx_state			<= ST_FETCH;
					endcase
				end
				
			ST_LWSW:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b01;
					oOrigBULA		<= 2'b10;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b00;
					case(Opcode)
						OPC_LOAD:	nx_state			<= ST_LW;
						OPC_STORE:	nx_state			<= ST_SW;
						default:		nx_state			<= ST_FETCH;
				end
					
			ST_LW:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b1;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b1;
					oALUOp			<=	2'b00;
					nx_state			<= ST_LW1;
				end

			ST_LW1:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b1;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b1;
					oALUOp			<=	2'b00;
					nx_state			<= ST_LW2;
				end				

			ST_LW2:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b10;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b1;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b00;
					nx_state			<= ST_FETCH;
				end		
				
			ST_SW:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b1;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b1;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b00;
					nx_state			<= ST_SW1;
				end
	 
			ST_SW1:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b1;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b1;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b00;
					nx_state			<= ST_FETCH;
				end
				
			ST_RTYPE:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b01;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b10;
					nx_state			<= ST_ULAREGWRITE;
				end
	 
			ST_ULAREGWRITE:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b1;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b00;
					nx_state			<= ST_FETCH;
				end
				
			ST_BRANCH:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b1;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b01;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b1;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b01;
					nx_state			<= ST_FETCH;
				end

			ST_JAL:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b1;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b01;
					oOrigPC			<= 1'b1;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b1;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b00;
					nx_state			<= ST_FETCH;
				end

				ST_ADDI:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b01;
					oOrigBULA		<= 2'b10;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b10;
					nx_state			<= ST_ULAREGWRITE;
				end
					
					ST_JALR:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b1;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b01;
					oOrigBULA		<= 2'b10;
					oMem2Reg			<= 2'b01;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b1;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b00;
					nx_state			<= ST_FETCH;
				end
					
					ST_LUI:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b10;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b11;
					nx_state			<= ST_ULAREGWRITE;
				end
				
			default:
				begin
					oEscreveIR		<= 1'b0;
					oEscrevePC		<= 1'b0;
					oEscrevePCCond	<= 1'b0;
					oEscrevePCBack <= 1'b0;
					oOrigAULA		<= 2'b00;
					oOrigBULA		<= 2'b00;
					oMem2Reg			<= 2'b00;
					oOrigPC			<= 1'b0;
					oIouD				<= 1'b0;
					oRegWrite		<= 1'b0;
					oMemWrite		<= 1'b0;
					oMemRead			<= 1'b0;
					oALUOp			<=	2'b00;
					nx_state			<= ST_FETCH;
				end
				
			endcase
			
endmodule




