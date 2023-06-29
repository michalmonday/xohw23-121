/* 
This module delays the input signal by one clock cycle.
*/
`timescale 1ns / 1ps

module delayer(clk, rst_n, sig, delayed_sig);
    input clk;
    input rst_n;
    input sig;
    output delayed_sig;
    
    reg reg_sig;
    
    assign delayed_sig = reg_sig;
    
    always@(posedge clk) 
    begin
        reg_sig = sig;
    end
endmodule
