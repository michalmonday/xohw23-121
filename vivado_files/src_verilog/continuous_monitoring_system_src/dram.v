/*
As of 29/06/2023 this file is not used in the project.
*/
`timescale 1ns/10ps

module dram #(
    parameter WORD_SIZE = 64,
    parameter ADDR_SIZE = 8,
    parameter WORD_CAPACITY = 2**ADDR_SIZE
) (
    input clk,
	input write_enable_1,
    input write_enable_2, 
	input [WORD_SIZE-1:0] data_in_1, 
    input [WORD_SIZE-1:0] data_in_2,
	input [ADDR_SIZE-1:0] address_1, 
    input [ADDR_SIZE-1:0] address_2,
	output reg [WORD_SIZE-1:0] output_1, 
    output reg [WORD_SIZE-1:0] output_2
);
	reg [WORD_SIZE:0] memory[WORD_CAPACITY-1:0];
	always @(posedge clk) begin
		if (write_enable_1) begin
			memory[address_1] <= data_in_1;
			output_1 <= data_in_1;
		end
		else begin
			output_1 <= memory[address_1];
		end
	end
	always @ (posedge clk) begin
		if (write_enable_2) begin
			memory[address_2] <= data_in_2;
			output_2 <= data_in_2;
		end
		else begin
			output_2 <= memory[address_2];
		end
	end
endmodule
