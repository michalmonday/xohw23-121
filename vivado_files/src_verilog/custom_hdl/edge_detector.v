`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.08.2022 01:26:15
// Design Name: 
// Module Name: edge_detector
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


module edge_detector(
    input clk,
    input sig,
    output neg_edge,
    output pos_edge
    );
    
    reg r_neg = 0;
    reg r_pos = 0;
    reg last_sig = 0;
    
    assign neg_edge = r_neg;
    assign pos_edge = r_pos;
    
    always @(posedge clk) 
    begin
        last_sig <= sig;
        if (r_neg) begin
            r_neg <= 0;
        end else begin
            if (sig != last_sig && ~sig) begin
                r_neg <= 1;
            end 
        end
        
        if (r_pos) begin 
            r_pos <= 0;
        end else begin
            if (sig != last_sig && sig) begin
                r_pos <= 1;
            end 
        end
    end
endmodule
