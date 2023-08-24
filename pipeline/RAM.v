module RAM(
	input  reset    , 
	input  clk      ,  
	input  MemRead  ,
	input  MemWrite ,
	input  [32 - 1: 0] Address   ,
	input  [32 - 1: 0] Write_data,
	output [32 - 1: 0] Read_data
);
	// RAM size is 128 = 2 ^ 7 words, each word is 32 bits, valid address is 7 bits
	parameter RAM_SIZE      = 128;
	parameter RAM_SIZE_BIT  = 7;
	
	// RAM_data is an array of 128 32-bit registers
	reg [31: 0] RAM_data [RAM_SIZE - 1: 0];

	// Read data from RAM_data as Read_data
	assign Read_data = MemRead ? RAM_data[Address[RAM_SIZE_BIT + 1: 2]]: 32'h00000000;
    
	// Write Write_data to RAM_data at clock posedge
	integer i;
	always @(posedge reset or posedge clk)
		if (reset) begin
            RAM_data[RAM_SIZE - 2] <= 32'h3F;
            RAM_data[RAM_SIZE - 3] <= 32'h06;
            RAM_data[RAM_SIZE - 4] <= 32'h5B;
            RAM_data[RAM_SIZE - 5] <= 32'h4F;
            RAM_data[RAM_SIZE - 6] <= 32'h66;
            RAM_data[RAM_SIZE - 7] <= 32'h6D;
            RAM_data[RAM_SIZE - 8] <= 32'h7D;
            RAM_data[RAM_SIZE - 9] <= 32'h07;
            RAM_data[RAM_SIZE - 10] <= 32'h7F;
            RAM_data[RAM_SIZE - 11] <= 32'h6F;
            RAM_data[RAM_SIZE - 12] <= 32'h77;
            RAM_data[RAM_SIZE - 13] <= 32'h7C;
            RAM_data[RAM_SIZE - 14] <= 32'h39;
            RAM_data[RAM_SIZE - 15] <= 32'h5E;
            RAM_data[RAM_SIZE - 16] <= 32'h79;
            RAM_data[RAM_SIZE - 17] <= 32'h71;
			for (i = 0; i < RAM_SIZE - 16; i = i + 1) begin
				RAM_data[i] <= 32'h00000000;
            end
        end
		else if (MemWrite && Address != 32'h40000010) begin
			RAM_data[Address[RAM_SIZE_BIT + 1: 2]] <= Write_data;
        end
endmodule