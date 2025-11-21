// alu_control.v
// Controlador da ULA para processador uniciclo RISC-V (versão mínima)

 `ifndef PARAM
	`include "Parametros.v"
`endif

module alu_control (
    input  wire [1:0] ALUOp,     // vindo do controle principal
    input  wire [2:0] funct3,    // bits [14:12]
    input  wire [6:0] funct7,    // bits [31:25]
    output reg  [4:0] ALUCtrl    // código para a ULA
);



    always @(*) begin
        case (ALUOp)
            2'b00: ALUCtrl = OPADD;  // lw, sw
            2'b01: ALUCtrl = OPSUB;  // beq
            2'b10: begin               // R-type
                case (funct3)
                    3'b000: begin
                        if (funct7[5]) // funct7 = 0100000 → SUB
                            ALUCtrl = OPSUB;
                        else
                            ALUCtrl = OPADD;
                    end
                    3'b111: ALUCtrl = OPAND;
                    3'b110: ALUCtrl = OPOR;
                    3'b010: ALUCtrl = OPSLT;
                    default: ALUCtrl = OPADD;
                endcase
				end
				2'b11: ALUCtrl = OPLUI;
        endcase
    end
endmodule
	
