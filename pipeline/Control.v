module Control(
	input  [6 - 1: 0] OpCode  ,
	input  [6 - 1: 0] Funct   ,
	output [3 - 1: 0] Branch  ,
	output RegWrite           ,
	output [2 - 1: 0] RegDst  ,
	output MemRead            ,
	output MemWrite           ,
	output [2 - 1: 0] MemtoReg,
	output ALUSrc1            ,
	output ALUSrc2            ,
	output ExtOp              ,
	output LuOp               ,
    output JSrc               ,
    output JRSrc              ,
	output [4 - 1: 0] ALUOp
);
	
    assign Branch = (OpCode == 6'h04) ? 3'b001:
    (OpCode == 6'h05) ? 3'b010: (OpCode == 6'h06) ? 3'b011:
    (OpCode == 6'h07) ? 3'b100: (OpCode == 6'h01) ? 3'b101 : 3'b000;

    assign RegWrite = 
        (OpCode == 6'h2b || OpCode == 6'h04 || OpCode == 6'h02
        || (Funct == 6'h08 && OpCode == 6'h00) || OpCode == 6'h05 ||
        OpCode == 6'h06 || OpCode == 6'h07 || OpCode == 6'h01) ? 0 : 1;
    
    assign RegDst = (OpCode == 6'h03 || (Funct == 6'h09 &&
        OpCode == 6'h00)) ? 2'b10:
        (OpCode == 6'h23 || OpCode == 6'h0f || OpCode == 6'h08 ||
        OpCode == 6'h09 || OpCode == 6'h0c || OpCode == 6'h0a
        || OpCode == 6'h0b || OpCode == 6'h0d) ? 2'b00 : 2'b01;
    
    assign MemRead = (OpCode == 6'h23) ? 1 : 0;

    assign MemWrite = (OpCode == 6'h2b) ? 1 : 0;

    assign MemtoReg = (OpCode == 6'h03 || (Funct == 6'h09 &&
    OpCode == 6'h00)) ? 2'b10: (OpCode == 6'h23) ? 2'b01 : 2'b00;

    assign ALUSrc1 = ((Funct == 6'h02 || Funct == 6'h03
    || Funct == 6'h00) && OpCode == 6'h00) ? 1 : 0;

    assign ALUSrc2 = (OpCode == 6'h23 || OpCode == 6'h2b ||
    OpCode == 6'h0f || OpCode == 6'h08 || OpCode == 6'h09 ||
    OpCode == 6'h0c || OpCode == 6'h0a || OpCode == 6'h0b ||
    OpCode == 6'h06 || OpCode == 6'h07 || OpCode == 6'h01 ||
    OpCode == 6'h0d) ? 1 : 0;

    assign ExtOp = (OpCode == 6'h0c || OpCode == 6'h0d) ? 0 : 1;

    assign LuOp = (OpCode == 6'h0f) ? 1 : 0;

    assign JSrc = (OpCode == 6'h02 || OpCode == 6'h03) ? 1 : 0;

    assign JRSrc = ((Funct == 6'h08 || Funct == 6'h09) && OpCode == 6'h00) ? 1 : 0;

	// set ALUOp
	assign ALUOp[2:0] = 
		(OpCode == 6'h00)? 3'b010: 
		(OpCode == 6'h04 || OpCode == 6'h05)? 3'b001: 
		(OpCode == 6'h0c)? 3'b100: 
		(OpCode == 6'h0a || OpCode == 6'h0b)? 3'b101: 
		(OpCode == 6'h0d)? 3'b110:
        3'b000;
		
	assign ALUOp[3] = OpCode[0];    
endmodule