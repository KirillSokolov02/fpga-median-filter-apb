`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2023 06:01:14 PM
// Design Name: 
// Module Name: MedianFilter_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MedianFilter_tb;
    parameter period = 5; // Clock period
    parameter num_vals = 8;
    parameter size = 4;
    
    //---Inputs----
    reg                     clk;
    reg [num_vals*size-1:0] input_data;
    
    //---Outputs---
    wire [num_vals*size-1:0] output_data;
    wire [size-1:0]          mid;
    
    //module instantiation
    MedianFilter UUT(
        .clk(clk),
	    .input_data(input_data),
	 	.output_data(output_data),
	    .mid(mid)
    );

    always #(period) clk = !clk;

    
    initial begin
    
        clk     <= 0;
        #period;

        input_data  <= 32'h4c966f04;
        // Expected output
        // output data = fc966440
        // mid = 6
        #(period*20);
    end

endmodule
