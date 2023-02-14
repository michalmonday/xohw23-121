// This file is based on:
// https://github.com/Byteahalf/riscv_online_debug/blob/master/RISCV/fifo.v

// It was modified to enable writing and reading from empty fifo. 
// Doing the same with full fifo is not supported (at least for now).

// IMPORTANT: DATA_DEPTH must be a power of 2, otherwise wr_ptr and rd_ptr will overflow and begin overwriting other items (unless I'm mistaken).

`timescale 1ns/10ps

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
    output reg [DATA_WIDTH - 1:0] rd_data,
    output full,
    output empty,
    output half,
    output reg [$clog2(DATA_DEPTH):0] counter
);
    reg [DATA_WIDTH - 1:0] data [0:DATA_DEPTH - 1];
    reg [$clog2(DATA_DEPTH) - 1:0] wr_ptr;
    reg [$clog2(DATA_DEPTH) - 1:0] rd_ptr;

    assign full = (counter == DATA_DEPTH);
    assign empty = (counter == 0 );
    assign half = (counter <= (DATA_DEPTH / 2));
    // assign rd_data = data[rd_ptr];
    
    initial begin
        counter <= 0;
        wr_ptr <= 0;
        rd_ptr <= 0;
    end

    // always @(posedge clk) begin
    //     if(!rst_n) begin
    //     end
    //     else if(wr_en) begin
    //         if (!full) begin
    //             data[wr_ptr] <= wr_data;
    //             wr_ptr <= wr_ptr + 1;
    //         end
    //     end
    // end

    // always @(posedge clk) begin
    //     if(!rst_n) begin
    //        wr_ptr <= 0; 
    //        rd_ptr <= 0; 
    //     end
    //     else begin
    //         if(rd_en) begin
    //             if (!empty) begin
    //                 rd_data <= data[rd_ptr];
    //                 rd_ptr <= rd_ptr + 1;
    //             end
    //             else if (wr_en) begin
    //                 rd_data <= wr_data;
    //             end
    //         end

    //         if (wr_en) begin
    //             if (!full) begin
    //                 data[wr_ptr] <= wr_data;
    //                 wr_ptr <= wr_ptr + 1;
    //             end
    //             else if (rd_en) begin
    //                 data[rd_ptr] <= wr_data;
    //                 rd_ptr <= rd_ptr + 1;
    //             end
    //         end
    //     end
    // end

    always @(posedge clk) begin
        if(!rst_n) begin
            counter <= 0;
            rd_ptr <= 0;
            wr_ptr <= 0;
        end
        else begin
            case({rd_en, wr_en})
            2'b00: begin
                counter <= counter;
                rd_data <= rd_data;
            end
            2'b11: begin
                if (empty) begin
                    counter <= counter;
                    rd_data <= wr_data;
                end
                else if (full) begin
                    counter <= counter - 1;
                    rd_data <= data[rd_ptr];
                    rd_ptr <= rd_ptr + 1;
                end
                else begin
                    counter <= counter;
                    rd_data <= data[rd_ptr];
                    data[wr_ptr] <= wr_data;
                    wr_ptr <= wr_ptr + 1;
                    rd_ptr <= rd_ptr + 1;

                end
            end
            2'b01: begin
                if(!full) begin
                    counter <= counter + 1;
                    data[wr_ptr] <= wr_data;
                    wr_ptr <= wr_ptr + 1;
                end
            end
            2'b10: begin
                if(!empty) begin
                    counter <= counter - 1;
                    rd_data <= data[rd_ptr];
                    rd_ptr <= rd_ptr + 1;
                end
            end
            endcase
        end
    end
endmodule