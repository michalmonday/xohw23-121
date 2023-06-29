/*
This module outputs "neg_edge" and "pos_edge" signals that are set to 1 for
one clock cycle when the input signal changes from 0 to 1 and from 1 to 0 respectively.
*/
`timescale 1ns / 1ps

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
