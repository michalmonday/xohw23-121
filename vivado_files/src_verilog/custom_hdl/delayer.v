`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2022 00:50:03
// Design Name: 
// Module Name: delayer
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
