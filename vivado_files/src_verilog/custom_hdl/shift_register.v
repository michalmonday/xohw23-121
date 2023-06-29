`timescale 1ns / 1ps

module shift_register 
#(
    parameter DATA_INPUT_WIDTH = 16,
    parameter DATA_WIDTH = 256,
    parameter ADDRESS_WIDTH = 32
)(
    input [DATA_INPUT_WIDTH-1:0] in,
    input shift,
    input select_data, // 1 = data is shifted, 0 = addr is shifted
    output [DATA_WIDTH-1:0] data,
    output [ADDRESS_WIDTH-1:0] addr
    );
    reg [DATA_WIDTH-1:0] r_data = 0;
    reg [ADDRESS_WIDTH-1:0] r_addr = 0;
    assign data = r_data;
    assign addr = r_addr; 
    always @(posedge shift)
    begin
        if (select_data)
        begin
            r_data <= (r_data << DATA_INPUT_WIDTH) | in;
        end else 
        begin
            r_addr <= (r_addr << DATA_INPUT_WIDTH) | in;
        end
    end
endmodule
