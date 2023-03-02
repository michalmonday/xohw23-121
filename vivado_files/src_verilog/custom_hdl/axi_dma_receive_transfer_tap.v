`timescale 1ns/10ps

module axi_dma_receive_transfer_tap (
    input wire clk,

    // axi lite slave interface signals
    input wire [9:0] axilite_tap_awaddr,
    input wire [31:0]axilite_tap_wdata,
    input wire axilite_tap_wready,
    input wire axilite_tap_wvalid,

    // // axi lite slave interface signals
    // input wire [9:0]s_axi_lite_araddr,
    // output wire s_axi_lite_arready,
    // input wire s_axi_lite_arvalid,
    // input wire [9:0] s_axi_lite_awaddr,
    // output wire s_axi_lite_awready,
    // input wire s_axi_lite_awvalid,
    // input wire s_axi_lite_bready,
    // output wire [1:0]s_axi_lite_bresp,
    // output wire s_axi_lite_bvalid,
    // output wire [31:0]s_axi_lite_rdata,
    // input wire s_axi_lite_rready,
    // output wire [1:0]s_axi_lite_rresp,
    // output wire s_axi_lite_rvalid,
    // input wire [31:0]s_axi_lite_wdata,
    // output wire s_axi_lite_wready,
    // input wire s_axi_lite_wvalid,

    // // axi lite master interface signals
    // output wire [9:0]m_axi_lite_araddr,
    // input wire m_axi_lite_arready,
    // output wire m_axi_lite_arvalid,
    // output wire [9:0] m_axi_lite_awaddr,
    // input wire m_axi_lite_awready,
    // output wire m_axi_lite_awvalid,
    // output wire m_axi_lite_bready,
    // input wire [1:0]m_axi_lite_bresp,
    // input wire m_axi_lite_bvalid,
    // input wire [31:0]m_axi_lite_rdata,
    // output wire m_axi_lite_rready,
    // input wire [1:0]m_axi_lite_rresp,
    // input wire m_axi_lite_rvalid,
    // output wire [31:0]m_axi_lite_wdata,
    // input wire m_axi_lite_wready,
    // output wire m_axi_lite_wvalid,

    // main purpose of this module signals
    output reg receive_transfer_request,
    output reg requested_length = 0
);

    // // connect all outputs to inputs
    // assign m_axi_lite_araddr = s_axi_lite_araddr;
    // assign s_axi_lite_arready = m_axi_lite_arready;
    // assign m_axi_lite_arvalid = s_axi_lite_arvalid;
    // assign m_axi_lite_awaddr = s_axi_lite_awaddr;
    // assign s_axi_lite_awready = m_axi_lite_awready;
    // assign m_axi_lite_awvalid = s_axi_lite_awvalid;
    // assign m_axi_lite_bready = s_axi_lite_bready;
    // assign s_axi_lite_bresp = m_axi_lite_bresp;
    // assign s_axi_lite_bvalid = m_axi_lite_bvalid;
    // assign s_axi_lite_rdata = m_axi_lite_rdata;
    // assign m_axi_lite_rready = s_axi_lite_rready;
    // assign s_axi_lite_rresp = m_axi_lite_rresp;
    // assign s_axi_lite_rvalid = m_axi_lite_rvalid;
    // assign m_axi_lite_wdata = s_axi_lite_wdata;
    // assign s_axi_lite_wready = m_axi_lite_wready;
    // assign m_axi_lite_wvalid = s_axi_lite_wvalid;

    // always @(posedge clk) begin
    //     if (s_axi_lite_awvalid && 
    //         s_axi_lite_awready &&
    //         s_axi_lite_awaddr == 'h58 && 
    //         s_axi_lite_wdata != 0 && 
    //         s_axi_lite_wready &&
    //         s_axi_lite_wvalid) 
    //     begin
    //         receive_transfer_request <= 1'b1;
    //     end
    //     else begin
    //         receive_transfer_request <= 1'b0;
    //     end
    // end

    always @(posedge clk) begin
        if (axilite_tap_awaddr == 'h58 && 
            axilite_tap_wdata != 0 && 
            axilite_tap_wready &&
            axilite_tap_wvalid) 
        begin
            receive_transfer_request <= 1'b1;
            requested_length <= axilite_tap_wdata;
        end
        else begin
            receive_transfer_request <= 1'b0;
        end
    end

endmodule