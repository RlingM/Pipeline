module test_cpu();
	reg reset ;
	reg clk   ;
    wire writeEn;
    wire readEn;

	wire [31: 0] DeviceData;
    wire [31: 0] Address;
    wire [11: 0] Device_Read_Data;
	
	CPU cpu1(  
		.reset        (reset     ),
		.clk          (clk       ),
        .Address      (Address   ),
        .DeviceData   (DeviceData),
        .writeEn      (writeEn   )
	);
	
    Device device1(
        .clk                (clk             ),
        .reset              (reset           ),
        .readEn             (readEn          ),
        .writeEn            (writeEn         ),
        .writeData          (DeviceData      ),
        .Address            (Address         ),
        .Device_Read_Data   (Device_Read_Data)
    );

	assign readEn = 1;

	initial begin
		reset  = 1;
		clk    = 1;
		#100 reset = 0;
	end
	
	always #50 clk = ~clk;
		
endmodule
