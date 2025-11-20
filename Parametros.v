`ifndef PARAM
 `define PARAM

/* Operacoes da ULA */
parameter
   ZERO     = 32'd0,	 
	OPAND		= 5'd0,
	OPOR		= 5'd1,
	OPXOR		= 5'd2,
	OPADD		= 5'd3,
	OPSUB		= 5'd4,
	OPSLT		= 5'd5,
	OPSLTU	= 5'd6,
	OPSLL		= 5'd7,
	OPSRL		= 5'd8,
	OPSRA		= 5'd9,
	OPLUI		= 5'd10,
	OPMUL		= 5'd11,
	OPMULH	= 5'd12,
	OPMULHU	= 5'd13,
	OPMULHSU	= 5'd14,
	OPDIV		= 5'd15,
	OPDIVU	= 5'd16,
	OPREM		= 5'd17,
	OPREMU	= 5'd18,
	OPNULL	= 5'd31, // saída ZERO
	
	/*OpCodes */
	OPC_LOAD       	= 7'b0000011,
	OPC_OPIMM     		= 7'b0010011,
	OPC_STORE      	= 7'b0100011,
	OPC_RTYPE    		= 7'b0110011,
	OPC_BRANCH     	= 7'b1100011,
	OPC_JALR       	= 7'b1100111,
	OPC_JAL        	= 7'b1101111,
	OPC_LUI				= 7'b0110111,
	
	/* Funct 7 */
	FUNCT7_ADD			 = 7'b0000000,
   FUNCT7_SUB         = 7'b0100000,
	FUNCT7_SLT			 = 7'b0000000,
	FUNCT7_OR			 = 7'b0000000,
	FUNCT7_AND			 = 7'b0000000,
	
	/* Funct 3 */
	FUNCT3_LW			= 3'b010,
	FUNCT3_SW			= 3'b010,	
	FUNCT3_ADD			= 3'b000,
	FUNCT3_SUB			= 3'b000,
	FUNCT3_SLT			= 3'b010,
	FUNCT3_OR			= 3'b110,
	FUNCT3_AND			= 3'b111,	
	FUNCT3_BEQ			= 3'b000,
	FUNCT3_JALR			= 3'b000,
	FUNCT3_ADDI			= 3'b000,	
	
	
	/* Endereços */
	TEXT_ADDRESS = 32'h0040_0000,
	DATA_ADDRESS = 32'h1001_0000,
	STACK_ADDRESS = 32'h1001_03FC,
	GP = DATA_ADDRESS,
	
	/*	Estados	*/
	ST_FETCH = 4'b0000,
	ST_FETCH1 = 4'b0001,
	ST_DECODE = 4'b0010,
	ST_LWSW = 4'b0011,
	ST_LW = 4'b0100,
	ST_LW1 = 4'b0101,
	ST_LW2 = 4'b0110,
	ST_SW = 4'b0111,
	ST_SW1 = 4'b1000,
	ST_RTYPE = 4'b1001,
	ST_ULAREGWRITE = 4'b1010,
	ST_BRANCH = 4'b1011,
	ST_JAL = 4'b1100,
	ST_ADDI = 4'b1101,
	ST_JALR = 4'b1110,
	ST_LUI = 4'b1111;
	
`endif
