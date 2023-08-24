module Device(
	input  reset  ,
	input  clk    ,
	input  readEn ,
    input  writeEn,
    input  [31: 0] Address,
	input  [31: 0] writeData,
	output [11: 0] Device_Read_Data
);
	reg [11: 0] dataToShow;

    assign Device_Read_Data = readEn ? dataToShow: 0;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            dataToShow <= 0;
        end
        else begin
            if(writeEn && Address == 32'h40000010) begin
                dataToShow <= writeData[11: 0];
            end
        end
    end
endmodule
