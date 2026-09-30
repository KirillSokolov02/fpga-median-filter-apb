`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/27/2021 07:25:48 PM
// Design Name:
// Module Name: apb_wrapper_rsa
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


module apb_wrapper_Median_Filter#(
    parameter BUS_WIDTH = 32,
    parameter ADDR_OFFSET= 'h00000000

)

(
    input clk,
    input rst,
    // Interface to APB bridge
    input S_PSEL,
    input S_PENABLE,
    input [31:0] S_PADDR,
    input S_PWRITE,
    input [31:0] S_PWDATA,
    output reg  S_PREADY,
    output reg  S_PSLVERR,
    output reg [31:0] S_PRDATA
    );


    wire apb_write;
    wire apb_read;
    wire [2:0] addr_index;
    wire [31:0] output_data;
    wire [3:0] mid;

    reg [3:0] mid_reg;
    reg [31:0] input_data;
    reg [31:0] output_data_reg;

    assign apb_write = S_PSEL & S_PENABLE & S_PWRITE;
    assign apb_read = S_PSEL & ~S_PWRITE;
    assign addr_index = S_PADDR[2:0]; //hmmm

MedianFilter #(.NUM_VALS(8), .SIZE(4)) Filter (.clk(clk), .input_data(input_data), .output_data(output_data), .mid(mid));

    always @( posedge clk )
	begin
	  if ( !rst )
	    begin
	      mid_reg <= 0;
	      output_data_reg <= 0;
	    end
	  else
	    begin
	      mid_reg <= {28'h0, mid};
	      output_data_reg <= output_data;
	    end
	end


    always@(posedge clk)
    begin
        if (!rst) begin
            S_PREADY  <= 1;
            S_PSLVERR <= 0;
            S_PRDATA  <= 0;
            input_data    <= 0;
        end
        else begin
        S_PREADY  <= 1;
        S_PSLVERR <= 0;

            if (apb_write) begin
            case (addr_index)
                3'h00: input_data    <= S_PWDATA;
            endcase
            end
            else if (apb_read) begin
            case (addr_index)
                3'h00: S_PRDATA <= input_data;
                3'h04: S_PRDATA <= output_data_reg;
                3'h08: S_PRDATA <= mid_reg;
            endcase
            end else
                S_PRDATA  <= 0;
        end
    end
endmodule
