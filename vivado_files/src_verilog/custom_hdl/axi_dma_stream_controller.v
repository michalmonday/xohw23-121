`timescale 1ns/10ps

/*
    This module recognizes that receive transfer was requested, and based on how many bytes were requested,
    sets the tlast signal to HIGH.
*/

module axi_dma_stream_controller #(
    parameter TDATA_WIDTH = 128
) (
    input wire clk,
    input wire rst_n,
    input wire [9:0] axilite_tap_awaddr,
    input wire [31:0]axilite_tap_wdata,
    input wire axilite_tap_wready,
    input wire axilite_tap_wvalid,

    input wire m_axis_tready,
    output reg m_axis_tvalid,
    output wire [TDATA_WIDTH-1:0] m_axis_tdata,
    output reg m_axis_tlast
);

    wire receive_transfer_request;
    wire [63:0] requested_length;
    reg [63:0] items_sent = 0;

    reg sending = 0; 

    axi_dma_receive_transfer_tap axi_dma_receive_transfer_tap_inst (
        .clk(clk),
        .axilite_tap_awaddr(axilite_tap_awaddr),
        .axilite_tap_wdata(axilite_tap_wdata),
        .axilite_tap_wready(axilite_tap_wready),
        .axilite_tap_wvalid(axilite_tap_wvalid),
        .receive_transfer_request(receive_transfer_request),
        .requested_length(requested_length)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            items_sent <= 0;
        end else
        if (receive_transfer_request) begin
            sending <= 1;
        end

        if (sending) begin
            items_sent <= items_sent + 1;
        end
    end
endmodule