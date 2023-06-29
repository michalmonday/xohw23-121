/*
This module is responsible for intermediate storage and interfacing between RISC-V console input/output and the Python script (using AXI GPIO).
As of 29/06/2023, this module is not used in the project (it was replaced by console_io_dma.v which is must faster thanks to using AXI DMA instead of AXI GPIO)
*/
`timescale 1ns/10ps

module console_io(
    input clk,
    input rst_n,

    input [31:0] AXI_GPIO_input,
    output reg [31:0] AXI_GPIO_output = 0,

    // input fifo signals
    input rst_n_input_fifo,
    input cpu_reset_completed,
    input RDY_put_from_console_put,
    output wire [7:0] put_from_console_put,
    output reg EN_put_from_console_put = 0,
    output wire [10:0] input_fifo_counter,

    // output fifo signals
    input rst_n_output_fifo,
    input [7:0] get_to_console_get,
    input RDY_get_to_console_get,
    output wire [10:0] output_fifo_counter
);
    wire input_fifo_wr_en; 
    wire input_fifo_empty;
    wire input_fifo_rd_en = (rst_n & cpu_reset_completed & RDY_put_from_console_put & ~input_fifo_empty);

    wire output_fifo_wr_en;
    wire output_fifo_rd_en;
    wire output_fifo_empty;
    wire [7:0] output_fifo_rd_data;

    // detects that RDY_put_from_console_put has gone from 1 to 0 and the char can't be sent
    // (char is outputted by fifo after 1 clock cycle of enabling read, and at that point the RDY_put_from_console_put may be already 0)
    reg RDY_put_from_console_put_was_off = 0;

    // output fifo isn't expected to be read at such high speed (it's read by AXI GPIO)
    // so such mechanism is not needed (at least for now)

    edge_detector input_fifo_wr_en_edge_detector(
        .clk(clk),
        .sig(AXI_GPIO_input[8]),
        .pos_edge(input_fifo_wr_en)
    );

    sync_fifo #(
        .DATA_DEPTH(1000),
        .DATA_WIDTH(8)
    ) input_fifo (
        .clk(clk),
        .rst_n(rst_n_input_fifo),
        .rd_en(input_fifo_rd_en),
        .wr_en(input_fifo_wr_en),
        .wr_data(AXI_GPIO_input[7:0]),
        .rd_data(put_from_console_put),
        .full(),
        .empty(input_fifo_empty),
        .half(),
        .counter(input_fifo_counter)
    );

    always @(posedge clk) begin
        AXI_GPIO_output <= {output_fifo_empty, output_fifo_rd_data};
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            EN_put_from_console_put <= 0;
        end
        else begin
            if (~RDY_put_from_console_put) begin
                if (input_fifo_rd_en) begin
                    RDY_put_from_console_put_was_off <= 1;
                end
                EN_put_from_console_put <= 0;
            end
            else if (RDY_put_from_console_put_was_off) begin
                // if the last char couldn't be sent and the RDY_put_from_console_put has gone from 0 to 1, then send the char
                RDY_put_from_console_put_was_off <= 0;
                EN_put_from_console_put <= 1;
            end
            else begin
                EN_put_from_console_put <= input_fifo_rd_en;
            end
        end
    end


    edge_detector output_fifo_rd_en_edge_detector(
        .clk(clk),
        .sig(AXI_GPIO_input[9]),
        .pos_edge(output_fifo_rd_en)
    );
    sync_fifo  #(
        .DATA_DEPTH(1000),
        .DATA_WIDTH(8)
    ) output_fifo (
        .clk(clk),
        .rst_n(rst_n_output_fifo),
        .rd_en(output_fifo_rd_en),
        .wr_en(RDY_get_to_console_get),
        .wr_data(get_to_console_get),
        .rd_data(output_fifo_rd_data),
        .full(),
        .empty(output_fifo_empty),
        .half(),
        .counter(output_fifo_counter)
    );

endmodule


