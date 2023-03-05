`timescale 1ns/10ps

// This module controls the 2 chained SN74HC165 shift registers, these 
// can be used to read 16 digital inputs from the extension board.

module digital_input_sequencer #(
    parameter SR_CLK_DIVIDER = 1000,
    parameter OUTPUT_ADDRESS_START = 16,
    parameter NUMBER_OF_INPUTS = 16
) (
    input wire clk,
    input wire rst_n,

    output reg sr_clock = 0,
    output reg sr_latch = 1,

    output wire [5:0] address, 
    output reg write_enable = 0
);

    // counter just for the main clock division
    reg [63:0] counter = 0;
    always @(posedge clk) begin
        if (!rst_n) begin
        end
        else begin
            if (counter == SR_CLK_DIVIDER/2) begin
                counter <= 0;
                sr_clock <= ~sr_clock;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end 

    // counter for shift register clock
    assign address = sr_clk_counter - 1 + OUTPUT_ADDRESS_START;
    reg [4:0] sr_clk_counter = 0;
    always @(posedge sr_clock) begin
        if (!rst_n) begin
            sr_clk_counter <= 0;
        end
        else begin
            if (sr_clk_counter == NUMBER_OF_INPUTS) begin
                sr_clk_counter <= 0;
                // load values (active low)
                sr_latch <= 0;
                write_enable <= 0;
            end
            else begin
                if (sr_clk_counter == 0) begin
                    // stop loading values
                    sr_latch <= 1;
                    write_enable <= 1;
                end 
                sr_clk_counter <= sr_clk_counter + 1;
            end
        end
    end 

endmodule