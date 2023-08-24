module top(
    input reset ,
    input clk   ,
    input readEn,
    output [11: 0] Device_Read_Data
);
    wire [31: 0] DeviceData;
    wire [31: 0] Address;
    wire writeEn;
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
endmodule