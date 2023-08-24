module ROM(
	input      [32 - 1: 0] Address, 
	output reg [32 - 1: 0] Instruction
);
    parameter ROM_SIZE = 32768;
    integer i;
    reg [31: 0] rom [ROM_SIZE - 1: 0];
	initial begin
        for(i = 0; i < ROM_SIZE; i = i + 1) begin
            rom[i] = 0;
        end
        $readmemh("Dijkstra.mem", rom);
    end
	always @(*) begin
        Instruction <= rom[Address[9: 2]];
    end
endmodule