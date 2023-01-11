// This file is a modified version of a "pc_stream.v" file from:
// https://github.com/Byteahalf/riscv_online_debug/blob/master/RISCV/component/pc_stream.v
// Originally created by Jiacheng Zhu

`timescale 1ns/10ps


module data_to_axi_stream #(
    parameter DATA_WIDTH = 1024
) (
    input clk,
    input rst_n,
    input write_enable,
    input [DATA_WIDTH-1:0]data_pkt,
    // number of items passed through until tlast is set high
    input [31:0] tlast_interval, 
    // force_tlast sets tlast = 1 for the currently added item regardless of tlast_interval and resets tlast_interval counter
    // input force_tlast,
    input tlast,
    // allows to use 2 different outputs independently
    // 0 = M_AXIS_tvalid_2 is never HIGH
    // 1 = M_AXIS_tvalid is never HIGH
    // input M_AXIS_select,
    output reg M_AXIS_tvalid=0,
    input M_AXIS_tready,
    output reg [DATA_WIDTH-1:0] M_AXIS_tdata=0,
    output reg M_AXIS_tlast=0

    // output reg M_AXIS_tvalid_2,
    // input M_AXIS_tready_2,
    // output reg [DATA_WIDTH-1:0] M_AXIS_tdata_2,
    // output reg M_AXIS_tlast_2
);
    //wire [DATA_WIDTH-1:0]pkt = {i_pc, i_instr, i_evt_mem_cap_load, i_evt_mem_cap_store, i_evt_mem_cap_load_tag_set, i_evt_mem_cap_store_tag_set, i_tgc_evt_write, i_tgc_evt_write_miss, i_tgc_evt_read, i_tgc_evt_read_miss, i_tgc_evt_evict, i_tgc_evt_set_tag_write, i_tgc_evt_set_tag_read};
    reg fifo_rden = 0;
    wire [DATA_WIDTH:0] fifo_dout; // +1 for tlast
    wire fifo_empty;
    reg axis_stage = 0;
    reg [31:0] item_counter = 0;

    always @(posedge clk) begin
        if(!rst_n) begin
            item_counter <= 0;
            M_AXIS_tvalid <= 0;
            M_AXIS_tdata <= 0;
            // M_AXIS_tvalid_2 <= 0;
            // M_AXIS_tdata_2 <= 0;
        end
        else begin
            case(axis_stage)
            0: begin
                if(~fifo_empty) begin
                    axis_stage <= 1;
                    // M_AXIS_tvalid <= ~M_AXIS_select;
                    M_AXIS_tvalid <= 1;
                    M_AXIS_tdata <= fifo_dout[DATA_WIDTH-1:0];
                    M_AXIS_tlast <= fifo_dout[DATA_WIDTH];
                    // M_AXIS_tvalid_2 <= M_AXIS_select;
                    // M_AXIS_tdata_2 <= fifo_dout;
                    fifo_rden <= 1;
                    //if (item_counter == tlast_interval || force_tlast) begin
                    //    item_counter <= 0;
                    //    // M_AXIS_tlast <= ~M_AXIS_select;
                    //    M_AXIS_tlast <= 1;
                    //    // M_AXIS_tlast_2 <= M_AXIS_select; 
                    //end
                    //else begin
                    //    M_AXIS_tlast <= 0;
                    //    // M_AXIS_tlast_2 <= 0; 
                    //end
                end
            end
            1: begin
                fifo_rden <= 0;
                // if((~M_AXIS_select && M_AXIS_tready) || (M_AXIS_select && M_AXIS_tready_2)) begin
                 if (M_AXIS_tready) begin
                    axis_stage <= 0;
                    M_AXIS_tvalid <= 0;
                    // M_AXIS_tvalid_2 <= 0;
                    item_counter <= item_counter + 1;
                    M_AXIS_tlast <= 0;
                end
            end
            endcase 
        end
    end
    
//  wire     fifo_full;  
//  wire     fifo_threshold;  
//  wire     fifo_overflow;  
//  wire     fifo_underflow;  
//  // 7. DUT Instantiation
// // fpga4student.com: FPga projects, Verilog projects, VHDL projects  
//  fifo_mem tb (/*AUTOARG*/  
//    // Outputs  
//    fifo_dout, fifo_full, fifo_empty, fifo_threshold, fifo_overflow,   
//    fifo_underflow,   
//    // Inputs  
//    clk, rst_n, write_enable, fifo_rden, data_pkt  
// //    );

    sync_fifo2#(
        .DATA_DEPTH   (32),
        .DATA_WIDTH   (DATA_WIDTH + 1) // +1 for tlast
    ) fifo (
        .clk      (clk),
        .rst_n    (rst_n),
        .rd_en    (fifo_rden),
        .wr_en    (write_enable),
        .wr_data  ({tlast, data_pkt}),
        .rd_data  (fifo_dout),
        .empty    (fifo_empty)
    );

endmodule