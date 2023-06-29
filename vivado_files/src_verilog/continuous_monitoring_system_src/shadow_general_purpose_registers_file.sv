/*
    To avoid unnecessary modifications of the RegFile module in Flute processor (that is used not only 
    for the general purpose registers), we create a "shadow" register file that will keep track of registers
    values based only on the following 3 signals leading to the original register file:
    - write address
    - write data
    - write enable
*/

`timescale 1ns/10ps

module shadow_general_purpose_registers_file #(
    parameter REGISTER_WIDTH = 128
) (
    input wire clk,
    input wire rst_n,
    input wire [4:0]write_address, // 5-bit address for 32 locations
    input wire [REGISTER_WIDTH-1:0]write_data,
    input wire write_enable,

    output wire [REGISTER_WIDTH-1:0]registers_output [31:0]
);
    reg [REGISTER_WIDTH-1:0] registers [31:0] = '{32{0}};
    assign registers_output = registers;

    always @(posedge clk) begin
        if (!rst_n) begin
            registers <= '{32{0}};
        end else begin
            if (write_enable) begin
                registers[write_address] <= write_data;
            end
        end
    end


endmodule