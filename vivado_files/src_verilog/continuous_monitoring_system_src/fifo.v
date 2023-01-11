// File copied from:
// https://github.com/Byteahalf/riscv_online_debug/blob/master/RISCV/fifo.v

`timescale 1ns/10ps

module async_fifo
#(
    parameter DATA_DEPTH = 8,
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rst_n,
    input rd_en,
    input wr_en,
    input [DATA_WIDTH - 1:0] wr_data,
    output [DATA_WIDTH - 1:0] rd_data,
    output full,
    output empty,
    output half
);
    reg [$clog2(DATA_DEPTH):0] counter;
    reg [DATA_WIDTH - 1:0] data [0:DATA_DEPTH - 1];
    reg [$clog2(DATA_DEPTH) - 1:0] wr_ptr;
    reg [$clog2(DATA_DEPTH) - 1:0] rd_ptr;

    assign full = (counter == DATA_DEPTH);
    assign empty = (counter == 0);
    assign half = (counter <= (DATA_DEPTH / 2));
    assign rd_data = data[rd_ptr];
    
    initial begin
        counter <= 0;
        wr_ptr <= 0;
        rd_ptr <= 0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
           wr_ptr <= 0; 
        end
        else if(!full & wr_en) begin
            wr_ptr <= wr_ptr + 1;
            data[wr_ptr] <= wr_data;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
           rd_ptr <= 0; 
        end
        else if(!empty & rd_en) begin
            rd_ptr <= rd_ptr + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            counter <= 0;
        end
        else begin
            case({rd_en, wr_en})
            2'b00: counter <= counter;
            2'b11: begin
                if(empty) begin
                    counter <= counter + 1;
                end
            end
            2'b01: begin
                if(!full) begin
                    counter <= counter + 1;
                end
            end
            2'b10: begin
                if(!empty) begin
                    counter <= counter - 1;
                end
            end
            endcase
        end
    end
endmodule







module async_fifo_comparator
#(
    parameter DATA_DEPTH = 8,
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rst_n,
    input rd_en,
    input wr_en,
    input [DATA_WIDTH - 1:0] wr_data,
    output [DATA_WIDTH - 1:0] rd_data,
    output full,
    output empty,
    output half,

    input [4:0] i_rs1,
    input [4:0] i_rs2,
    input i_rs1en,
    input i_rs2en,
    output o_result
);
    reg [$clog2(DATA_DEPTH):0] counter;
    reg [DATA_WIDTH - 1:0] data [0:DATA_DEPTH - 1];
    reg [$clog2(DATA_DEPTH) - 1:0] wr_ptr;
    reg [$clog2(DATA_DEPTH) - 1:0] rd_ptr;
    reg rd_valid [DATA_DEPTH - 1:0];
    reg wr_valid [DATA_DEPTH - 1:0];
    wire [DATA_DEPTH - 1:0] valid;
    wire [DATA_DEPTH - 1:0] rs1_valid;
    wire [DATA_DEPTH - 1:0] rs2_valid;

    assign full = (counter == DATA_DEPTH);
    assign empty = (counter == 0);
    assign half = (counter <= (DATA_DEPTH / 2));
    assign rd_data = data[rd_ptr];
    assign o_result = (|{rs1_valid} & i_rs1en & (i_rs1 != 0)) | (|{rs2_valid} & i_rs2en & (i_rs2 != 0));

    genvar i;
    generate for(i = 0; i < DATA_DEPTH; i = i + 1) begin
        assign valid[i] = rd_valid[i] ^ wr_valid[i];
        assign rs1_valid[i] = (i_rs1 == data[i]) & valid[i];
        assign rs2_valid[i] = (i_rs2 == data[i]) & valid[i];
    end     
    endgenerate
        
    integer j;
    initial begin
        counter <= 0;
        wr_ptr <= 0;
        rd_ptr <= 0;
        for(j = 0; j <= DATA_DEPTH; j = j + 1) begin: label0
            data[j] <= 0;
            rd_valid[j] <= 0;
            wr_valid[j] <= 0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wr_ptr <= 0;
            for(j = 0; j <= DATA_DEPTH; j = j + 1) begin
                wr_valid[j] <= 0;
            end
        end
        else if(!full&  & wr_en) begin
            wr_ptr <= wr_ptr + 1;
            data[wr_ptr] <= wr_data;
            wr_valid[wr_ptr] <= ~wr_valid[wr_ptr];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
           rd_ptr <= 0; 
            for(j = 0; j <= DATA_DEPTH; j = j + 1) begin
                rd_valid[j] <= 0;
            end
        end
        else if(!empty & rd_en) begin
            rd_ptr <= rd_ptr + 1;
            rd_valid[rd_ptr] <= ~rd_valid[rd_ptr];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            counter <= 0;
        end
        else begin
            case({rd_en, wr_en})
            2'b00, 2'b11: counter <= counter;
            2'b01: begin
                if(!full) begin
                    counter <= counter + 1;
                end
            end
            2'b10: begin
                if(!empty) begin
                    counter <= counter - 1;
                end
            end
            endcase
        end
    end
endmodule






module sync_fifo2
#(
    parameter DATA_DEPTH = 8,
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rst_n,
    input rd_en,
    input wr_en,
    input [DATA_WIDTH - 1:0] wr_data,
    output [DATA_WIDTH - 1:0] rd_data,
    output full,
    output empty,
    output half,
    output reg [$clog2(DATA_DEPTH):0] counter
);
    reg [DATA_WIDTH - 1:0] data [0:DATA_DEPTH - 1];
    reg [$clog2(DATA_DEPTH) - 1:0] wr_ptr;
    reg [$clog2(DATA_DEPTH) - 1:0] rd_ptr;

    assign full = (counter == DATA_DEPTH);
    assign empty = (counter == 0);
    assign half = (counter <= (DATA_DEPTH / 2));
    assign rd_data = data[rd_ptr];
    
    initial begin
        counter <= 0;
        wr_ptr <= 0;
        rd_ptr <= 0;
    end

    always @(posedge clk) begin
        if(!rst_n) begin
           wr_ptr <= 0; 
        end
        else if(!full & wr_en) begin
            wr_ptr <= wr_ptr + 1;
            data[wr_ptr] <= wr_data;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
           rd_ptr <= 0; 
        end
        else if(!empty & rd_en) begin
            rd_ptr <= rd_ptr + 1;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            counter <= 0;
        end
        else begin
            case({rd_en, wr_en})
            2'b00: counter <= counter;
            2'b11: begin
                if(empty) begin
                    counter <= counter + 1;
                end
            end
            2'b01: begin
                if(!full) begin
                    counter <= counter + 1;
                end
            end
            2'b10: begin
                if(!empty) begin
                    counter <= counter - 1;
                end
            end
            endcase
        end
    end
endmodule