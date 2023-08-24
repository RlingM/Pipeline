module CPU(
	input  reset, 
	input  clk,
    output [31: 0] Address,
    output [31: 0] DeviceData,
    output writeEn
);
	// Interstage Registers
    //// IF/ID Regs
    reg [31: 0] IF_ID_PC_plus_4;
    reg [31: 0] IF_ID_Instruction;

    //// ID/EX Regs
    reg [1: 0]  ID_EX_RegDst;
    reg         ID_EX_RegWrite;
    reg         ID_EX_MemRead;
    reg         ID_EX_MemWrite;
    reg         ID_EX_ALUSrc1;
    reg         ID_EX_ALUSrc2;
    reg [1: 0]  ID_EX_MemtoReg;
    reg [2: 0]  ID_EX_Branch;
    reg [3: 0]  ID_EX_ALUOp;
    reg [31: 0] ID_EX_PC_plus_4;

    reg [31: 0] ID_EX_RsData1;
    reg [31: 0] ID_EX_RtData2;
    reg [4: 0]  ID_EX_Rs;
    reg [4: 0]  ID_EX_Rt;
    reg [4: 0]  ID_EX_Rd;
    reg [4: 0]  ID_EX_Shamt;
    reg [5: 0]  ID_EX_Funct;
    reg [31: 0] ID_EX_Imm;

    //// EX/MEM Regs
    reg         EX_MEM_MemWrite;
    reg         EX_MEM_MemRead;
    reg [1: 0]  EX_MEM_MemtoReg;
    reg         EX_MEM_RegWrite;
    reg [31: 0] EX_MEM_ALUOut;
    reg [4: 0]  EX_MEM_WriteAddress;

    reg [31: 0] EX_MEM_PC_plus_4;
    reg [31: 0] EX_MEM_BOut;

    //// MEM/WB Regs
    reg [1: 0]  MEM_WB_MemtoReg;
    reg         MEM_WB_RegWrite;
    reg [31: 0] MEM_WB_PC_plus_4;
    reg [31: 0] MEM_WB_RAMData;
    reg [31: 0] MEM_WB_ALUOut;
    reg [4: 0]  MEM_WB_WriteAddress;

    // IF
	//// PC register
	reg  [31: 0] PC;
	wire [31: 0] PC_next;
	wire [31: 0] PC_plus_4;
	assign PC_plus_4 = PC + 32'd4;
	
	//// ROM
	wire [31: 0] Instruction;
	ROM rom1(
		.Address        (PC         ), 
		.Instruction    (Instruction)
	);

    // ID
    //// Control 
	wire [1: 0] RegDst;
	wire [2: 0] Branch;
	wire MemRead;
	wire MemWrite;
	wire [1: 0] MemtoReg;
	wire ALUSrc1;
	wire ALUSrc2;
	wire [4 -1: 0] ALUOp;
	wire ExtOp;
	wire LuOp;
    wire JSrc;
    wire JRSrc;
	wire RegWrite;
	Control control1(
		.OpCode     (IF_ID_Instruction[31: 26]),
		.Funct      (IF_ID_Instruction[5: 0]  ),
		.Branch     (Branch                   ),
		.RegWrite   (RegWrite                 ),
		.RegDst     (RegDst                   ),
		.MemRead    (MemRead                  ),
		.MemWrite   (MemWrite                 ),
		.MemtoReg   (MemtoReg                 ),
		.ALUSrc1    (ALUSrc1                  ),
		.ALUSrc2    (ALUSrc2                  ),
		.ExtOp      (ExtOp                    ),
		.LuOp       (LuOp                     ),
        .JSrc       (JSrc                     ),
        .JRSrc      (JRSrc                    ),
		.ALUOp      (ALUOp                    )
	);

    //// Register File
    wire [31: 0] Rs;
    wire [31: 0] Rt;
    wire [31: 0] RFWriteData;
	RegisterFile register_file1(
		.reset          (reset                    ),
		.clk            (clk                      ),
		.RegWrite       (MEM_WB_RegWrite          ),
		.Read_register1 (IF_ID_Instruction[25: 21]),
		.Read_register2 (IF_ID_Instruction[20: 16]),
		.Write_register (MEM_WB_WriteAddress      ),
		.Write_data     (RFWriteData              ),
		.Read_data1     (Rs                       ),
		.Read_data2     (Rt                       )
	);
	
	//// Extend	
	wire [32 - 1: 0] ExtOut;
	assign ExtOut = {ExtOp? {16{IF_ID_Instruction[15]}}: 16'h0000, IF_ID_Instruction[15: 0]};
	
    wire [32 - 1: 0] LUOut;
	assign LUOut = LuOp? {IF_ID_Instruction[15: 0], 16'h0000}: ExtOut;

    // EX
    //// ALU Control
	wire [5 - 1: 0] ALUCtl;
	wire Sign; 
	ALUControl alu_control1(
		.ALUOp  (ID_EX_ALUOp),
		.Funct  (ID_EX_Funct),
		.ALUCtl (ALUCtl     ),
		.Sign   (Sign       )
	);
		
	//// ALU
	wire [32 - 1: 0] ALU_in1;
	wire [32 - 1: 0] ALU_in2;
	wire [32 - 1: 0] ALUOut ;

    wire [1: 0] AForward;
    wire [1: 0] BForward;
    wire [31: 0] AOut;
    wire [31: 0] BOut;
    wire BranchSrc;

    assign AForward = ((ID_EX_Rs == EX_MEM_WriteAddress) && (EX_MEM_RegWrite && EX_MEM_WriteAddress != 0))? 2'b10:
        ((ID_EX_Rs == MEM_WB_WriteAddress) && MEM_WB_RegWrite && MEM_WB_WriteAddress != 0 &&
        (EX_MEM_WriteAddress != ID_EX_Rs || !EX_MEM_RegWrite))? 2'b01: 2'b00;
    assign BForward = ((ID_EX_Rt == EX_MEM_WriteAddress) && (EX_MEM_RegWrite && EX_MEM_WriteAddress != 0))? 2'b10:
        ((ID_EX_Rt == MEM_WB_WriteAddress) && (MEM_WB_RegWrite && MEM_WB_WriteAddress != 0) &&
        (EX_MEM_WriteAddress != ID_EX_Rt || !EX_MEM_RegWrite))? 2'b01: 2'b00;
    
	assign AOut = (AForward == 2'b00)? ID_EX_RsData1: (AForward == 2'b01)?
        RFWriteData: EX_MEM_ALUOut;
    assign BOut = (BForward == 2'b00)? ID_EX_RtData2: (BForward == 2'b01)?
        RFWriteData: EX_MEM_ALUOut;
    assign ALU_in1 = ID_EX_ALUSrc1? ID_EX_Shamt: AOut;
	assign ALU_in2 = ID_EX_ALUSrc2? ID_EX_Imm: BOut;

    assign BranchSrc = ((ID_EX_Branch == 3'b001 && AOut == BOut) ||
        (ID_EX_Branch == 3'b010 && AOut != BOut) ||
        (ID_EX_Branch == 3'b011 && (AOut[31] || AOut == 32'h00000000)) ||
        (ID_EX_Branch == 3'b100 && !AOut[31] && AOut != 32'h00000000) ||
        (ID_EX_Branch == 3'b101 && AOut[31]))? 1: 0;

	ALU alu1(
		.in1    (ALU_in1), 
		.in2    (ALU_in2), 
		.ALUCtl (ALUCtl ), 
		.Sign   (Sign   ), 
		.out    (ALUOut )
	);
		
    // MEM
    //// RAM
	wire [32 - 1: 0] RAMData;
    assign Address = EX_MEM_ALUOut;
    assign DeviceData = EX_MEM_BOut;
    assign writeEn = EX_MEM_MemWrite;
	RAM ram1(
		.reset      (reset          ),
		.clk        (clk            ),
		.Address    (EX_MEM_ALUOut  ),
		.Write_data (EX_MEM_BOut    ),
		.Read_data  (RAMData        ),
		.MemRead    (EX_MEM_MemRead ),
		.MemWrite   (EX_MEM_MemWrite)
	);

    //// PCSrc
    assign PC_next = (JSrc && !BranchSrc)? {IF_ID_PC_plus_4[31: 28], IF_ID_Instruction[25: 0], 2'b00}:
        (JRSrc && !BranchSrc)? Rs: BranchSrc? ID_EX_PC_plus_4 + {ID_EX_Imm[29: 0], 2'b00}: PC_plus_4;

    // WB
	assign RFWriteData = (MEM_WB_MemtoReg == 2'b10)? MEM_WB_PC_plus_4:
        (MEM_WB_MemtoReg == 2'b01)? MEM_WB_RAMData: MEM_WB_ALUOut;

	always @(posedge reset or posedge clk)
		if (reset) begin
			PC <= 32'h00000000;
            IF_ID_Instruction <= 0;
            IF_ID_PC_plus_4 <= 0;

            ID_EX_RegDst <= 0;
            ID_EX_RegWrite <= 0;
            ID_EX_MemRead <= 0;
            ID_EX_MemWrite <= 0;
            ID_EX_MemtoReg <= 0;
            ID_EX_ALUSrc1 <= 0;
            ID_EX_ALUSrc2 <= 0;
            ID_EX_Branch <= 0;
            ID_EX_ALUOp <= 0;
            ID_EX_PC_plus_4 <= 0;

            ID_EX_RsData1 <= 0;
            ID_EX_RtData2 <= 0;
            ID_EX_Rs <= 0;
            ID_EX_Rt <= 0;
            ID_EX_Rd <= 0;
            ID_EX_Shamt <= 0;
            ID_EX_Funct <= 0;
            ID_EX_Imm <= 0;

            //// EX/MEM Regs
            EX_MEM_MemWrite <= 0;
            EX_MEM_MemRead <= 0;
            EX_MEM_MemtoReg <= 0;
            EX_MEM_RegWrite <= 0;
            EX_MEM_ALUOut <= 0;
            EX_MEM_WriteAddress <= 0;

            EX_MEM_PC_plus_4 <= 0;
            EX_MEM_BOut <= 0;

            //// MEM/WB Regs
            MEM_WB_MemtoReg <= 0;
            MEM_WB_RegWrite <= 0;
            MEM_WB_PC_plus_4 <= 0;
            MEM_WB_RAMData <= 0;
            MEM_WB_ALUOut <= 0;
            MEM_WB_WriteAddress <= 0;
        end
		else begin
            // Load-use Hazard
            if(ID_EX_MemRead && ((ID_EX_Rt == IF_ID_Instruction[25: 21]) ||
            ID_EX_Rt == IF_ID_Instruction[20: 16])) begin
                // IF
                PC <= PC;
                IF_ID_PC_plus_4 <= IF_ID_PC_plus_4;
                IF_ID_Instruction <= IF_ID_Instruction;

                // ID
                ID_EX_Branch <= 0;
                ID_EX_ALUOp <= 0;
                ID_EX_Imm <= 0;
                ID_EX_MemRead <= 0;
                ID_EX_MemtoReg <= 0;
                ID_EX_MemWrite <= 0;
                ID_EX_ALUSrc1 <= 0;
                ID_EX_ALUSrc2 <= 0;
                ID_EX_RegDst <= 0;
                ID_EX_RegWrite <= 0;

                ID_EX_PC_plus_4 <= 0;
                ID_EX_RsData1 <= 0;
                ID_EX_RtData2 <= 0;
                ID_EX_Rs <= 0;
                ID_EX_Rt <= 0;
                ID_EX_Rd <= 0;
                ID_EX_Shamt <= 0;
                ID_EX_Funct <= 0;

                // EX
                EX_MEM_MemtoReg <= ID_EX_MemtoReg;
                EX_MEM_RegWrite <= ID_EX_RegWrite;
                EX_MEM_MemWrite <= ID_EX_MemWrite;
                EX_MEM_MemRead <= ID_EX_MemRead;

                EX_MEM_BOut <= BOut;
                EX_MEM_PC_plus_4 <= ID_EX_PC_plus_4;
                EX_MEM_WriteAddress <= (ID_EX_RegDst == 2'b00)? ID_EX_Rt: 
                    (ID_EX_RegDst == 2'b01)? ID_EX_Rd: 5'b11111;
                EX_MEM_ALUOut <= ALUOut;
            end
            // J-Type Instruction
            else if(JSrc) begin
                // IF
                PC <= PC_next;
                IF_ID_Instruction <= 0;
                IF_ID_PC_plus_4 <= 0;

                // ID
                ID_EX_Branch <= Branch;
                ID_EX_ALUOp <= ALUOp;
                ID_EX_Imm <= LUOut;
                ID_EX_MemRead <= MemRead;
                ID_EX_MemtoReg <= MemtoReg;
                ID_EX_MemWrite <= MemWrite;
                ID_EX_ALUSrc1 <= ALUSrc1;
                ID_EX_ALUSrc2 <= ALUSrc2;
                ID_EX_RegDst <= RegDst;
                ID_EX_RegWrite <= RegWrite;

                ID_EX_PC_plus_4 <= IF_ID_PC_plus_4;
                ID_EX_RsData1 <= Rs;
                ID_EX_RtData2 <= Rt;
                ID_EX_Rs <= IF_ID_Instruction[25: 21];
                ID_EX_Rt <= IF_ID_Instruction[20: 16];
                ID_EX_Rd <= IF_ID_Instruction[15: 11];
                ID_EX_Shamt <= IF_ID_Instruction[10: 6];
                ID_EX_Funct <= IF_ID_Instruction[5: 0];

                // EX
                EX_MEM_MemtoReg <= ID_EX_MemtoReg;
                EX_MEM_RegWrite <= ID_EX_RegWrite;
                EX_MEM_MemWrite <= ID_EX_MemWrite;
                EX_MEM_MemRead <= ID_EX_MemRead;

                EX_MEM_BOut <= BOut;
                EX_MEM_PC_plus_4 <= ID_EX_PC_plus_4;
                EX_MEM_WriteAddress <= (ID_EX_RegDst == 2'b00)? ID_EX_Rt: 
                    (ID_EX_RegDst == 2'b01)? ID_EX_Rd: 5'b11111;
                EX_MEM_ALUOut <= ALUOut;
            end

            // Jr
            else if(JRSrc) begin
                // IF
                PC <= PC_next;
                IF_ID_Instruction <= 0;
                IF_ID_PC_plus_4 <= 0;

                // ID
                ID_EX_Branch <= 0;
                ID_EX_ALUOp <= 0;
                ID_EX_Imm <= 0;
                ID_EX_MemRead <= 0;
                ID_EX_MemtoReg <= 0;
                ID_EX_MemWrite <= 0;
                ID_EX_ALUSrc1 <= 0;
                ID_EX_ALUSrc2 <= 0;
                ID_EX_RegDst <= 0;
                ID_EX_RegWrite <= 0;

                ID_EX_PC_plus_4 <= 0;
                ID_EX_RsData1 <= 0;
                ID_EX_RtData2 <= 0;
                ID_EX_Rs <= 0;
                ID_EX_Rt <= 0;
                ID_EX_Rd <= 0;
                ID_EX_Shamt <= 0;
                ID_EX_Funct <= 0;

                // EX
                EX_MEM_MemtoReg <= ID_EX_MemtoReg;
                EX_MEM_RegWrite <= ID_EX_RegWrite;
                EX_MEM_MemWrite <= ID_EX_MemWrite;
                EX_MEM_MemRead <= ID_EX_MemRead;

                EX_MEM_BOut <= BOut;
                EX_MEM_PC_plus_4 <= ID_EX_PC_plus_4;
                EX_MEM_WriteAddress <= (ID_EX_RegDst == 2'b00)? ID_EX_Rt: 
                    (ID_EX_RegDst == 2'b01)? ID_EX_Rd: 5'b11111;
                EX_MEM_ALUOut <= ALUOut;
            end

            // Branch Instruction
            else if(BranchSrc) begin
                // IF
                PC <= PC_next;
                IF_ID_Instruction <= 0;
                IF_ID_PC_plus_4 <= 0;

                // ID
                ID_EX_Branch <= 0;
                ID_EX_ALUOp <= 0;
                ID_EX_Imm <= 0;
                ID_EX_MemRead <= 0;
                ID_EX_MemtoReg <= 0;
                ID_EX_MemWrite <= 0;
                ID_EX_ALUSrc1 <= 0;
                ID_EX_ALUSrc2 <= 0;
                ID_EX_RegDst <= 0;
                ID_EX_RegWrite <= 0;

                ID_EX_PC_plus_4 <= 0;
                ID_EX_RsData1 <= 0;
                ID_EX_RtData2 <= 0;
                ID_EX_Rs <= 0;
                ID_EX_Rt <= 0;
                ID_EX_Rd <= 0;
                ID_EX_Shamt <= 0;
                ID_EX_Funct <= 0;

                // EX
                EX_MEM_MemtoReg <= 0;
                EX_MEM_RegWrite <= 0;
                EX_MEM_MemWrite <= 0;
                EX_MEM_MemRead <= 0;

                EX_MEM_BOut <= 0;
                EX_MEM_PC_plus_4 <= 0;
                EX_MEM_WriteAddress <= 0;
                EX_MEM_ALUOut <= 0;
            end
            // Normal Pipeline
            else begin
                IF_ID_PC_plus_4 <= PC_plus_4;
                IF_ID_Instruction <= Instruction;
                PC <= PC_next;

                // ID
                ID_EX_Branch <= Branch;
                ID_EX_ALUOp <= ALUOp;
                ID_EX_Imm <= LUOut;
                ID_EX_MemRead <= MemRead;
                ID_EX_MemtoReg <= MemtoReg;
                ID_EX_MemWrite <= MemWrite;
                ID_EX_ALUSrc1 <= ALUSrc1;
                ID_EX_ALUSrc2 <= ALUSrc2;
                ID_EX_RegDst <= RegDst;
                ID_EX_RegWrite <= RegWrite;

                ID_EX_PC_plus_4 <= IF_ID_PC_plus_4;
                ID_EX_RsData1 <= Rs;
                ID_EX_RtData2 <= Rt;
                ID_EX_Rs <= IF_ID_Instruction[25: 21];
                ID_EX_Rt <= IF_ID_Instruction[20: 16];
                ID_EX_Rd <= IF_ID_Instruction[15: 11];
                ID_EX_Shamt <= IF_ID_Instruction[10: 6];
                ID_EX_Funct <= IF_ID_Instruction[5: 0];

                // EX
                EX_MEM_MemtoReg <= ID_EX_MemtoReg;
                EX_MEM_RegWrite <= ID_EX_RegWrite;
                EX_MEM_MemWrite <= ID_EX_MemWrite;
                EX_MEM_MemRead <= ID_EX_MemRead;

                EX_MEM_BOut <= BOut;
                EX_MEM_PC_plus_4 <= ID_EX_PC_plus_4;
                EX_MEM_WriteAddress <= (ID_EX_RegDst == 2'b00)? ID_EX_Rt: 
                    (ID_EX_RegDst == 2'b01)? ID_EX_Rd: 5'b11111;
                EX_MEM_ALUOut <= ALUOut;
            end

            // MEM
            MEM_WB_ALUOut <= EX_MEM_ALUOut;
            MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_RAMData <= RAMData;
            MEM_WB_WriteAddress <= EX_MEM_WriteAddress;
            MEM_WB_PC_plus_4 <= EX_MEM_PC_plus_4;
        end
endmodule