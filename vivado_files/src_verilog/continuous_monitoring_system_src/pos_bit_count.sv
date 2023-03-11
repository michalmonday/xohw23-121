`timescale 1ns/10ps

/*
    Module that counts positive bits in a bit vector.
*/

import continuous_monitoring_system_pkg::*;

module pos_bit_count #(
    parameter DATA_WIDTH = 1024,
    parameter DATA_WIDTH_LOG2 = 10 //$clog2(DATA_WIDTH), but Vivado generates 1 bit for some reason when clog2 is used
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH_LOG2:0] pos_bit_count = 0
);
    reg [DATA_WIDTH_LOG2:0] temp = 0;
    always @(posedge clk) begin
        if(!rst_n) begin
            pos_bit_count <= 0;
        end
        else begin
            temp = 0;
            for (integer i = 0; i < DATA_WIDTH; i=i+1) begin
                temp = temp + data_in[i];
            end
            pos_bit_count <= temp;
        end
    end
endmodule