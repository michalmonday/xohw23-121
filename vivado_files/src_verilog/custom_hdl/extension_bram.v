`timescale 1ns/10ps

module extension_bram #(
    ITEM_SIZE = 64,
    DEPTH = 1024
) (
    input wire clk,

    // port a (e.g. risc-v read/write)
    input wire [$clog2(DEPTH):0] port_a_addr, 
    input wire [ITEM_SIZE-1:0] port_a_din, 
    output wire [ITEM_SIZE-1:0] port_a_dout, 
    input wire port_a_we,

    // port b (e.g. analog sensor input from XADC wizard, using mutliplexer)
    input wire [$clog2(DEPTH):0] port_b_addr, 
    input wire [ITEM_SIZE-1:0] port_b_din, 
    output wire [ITEM_SIZE-1:0] port_b_dout, 
    input wire port_b_we,

    // port c (e.g. digital input through GPIO, using parrallel-in serial-out SN74HC165 shift register)
    input wire [$clog2(DEPTH):0] port_c_addr, 
    input wire [ITEM_SIZE-1:0] port_c_din, 
    output wire [ITEM_SIZE-1:0] port_c_dout, 
    input wire port_c_we

    // more ports could be added for other purposes (e.g. digital output, possibly using SN74HC595 shift register)
);
    reg [ITEM_SIZE-1:0] mem [DEPTH-1:0];

    assign port_a_dout = mem[port_a_addr];
    assign port_b_dout = mem[port_b_addr];
    assign port_c_dout = mem[port_c_addr];

    always @(posedge clk) begin
        case ({port_c_we, port_b_we, port_a_we})
            3'b000: begin
            end
            3'b001: begin
                // port a write
                mem[port_a_addr] <= port_a_din;
            end
            3'b010: begin
                // port b write
                mem[port_b_addr] <= port_b_din;
            end
            3'b100: begin
                // port c write
                mem[port_c_addr] <= port_c_din;
            end
            3'b011: begin
                // port a and port b write
                if (port_a_addr == port_b_addr) begin
                    mem[port_a_addr] <= port_a_din;
                end else begin
                    mem[port_a_addr] <= port_a_din;
                    mem[port_b_addr] <= port_b_din;
                end 
            end
            3'b101: begin
                // port a and port c write
                if (port_a_addr == port_c_addr) begin
                    mem[port_a_addr] <= port_a_din;
                end else begin
                    mem[port_a_addr] <= port_a_din;
                    mem[port_c_addr] <= port_c_din;
                end
            end
            3'b110: begin
                // port b and port c write
                if (port_b_addr == port_c_addr) begin
                    mem[port_b_addr] <= port_b_din;
                end else begin
                    mem[port_b_addr] <= port_b_din;
                    mem[port_c_addr] <= port_c_din;
                end
            end
            3'b111: begin
                // port a, port b and port c write
                if (port_a_addr == port_b_addr) begin
                    if (port_a_addr == port_c_addr) begin
                        mem[port_a_addr] <= port_a_din;
                    end else begin
                        mem[port_a_addr] <= port_a_din;
                        mem[port_c_addr] <= port_c_din;
                    end
                end else begin
                    if (port_a_addr == port_c_addr) begin
                        if (port_b_addr == port_c_addr) begin
                            mem[port_a_addr] <= port_a_din;
                        end else begin
                            mem[port_a_addr] <= port_a_din;
                            mem[port_b_addr] <= port_b_din;
                        end
                    end else begin
                        if (port_b_addr == port_c_addr) begin
                            mem[port_a_addr] <= port_a_din;
                            mem[port_b_addr] <= port_b_din;
                        end else begin
                            mem[port_a_addr] <= port_a_din;
                            mem[port_b_addr] <= port_b_din;
                            mem[port_c_addr] <= port_c_din;
                        end
                    end
                end
            end
        endcase

        if (port_a_we) begin
            mem[port_a_addr] <= port_a_din;
        end
        if (port_b_we && (!port_a_we || (port_a_addr != port_b_addr))) begin
            mem[port_b_addr] <= port_b_din;
        end
        if (port_c_we) begin
            mem[port_c_addr] <= port_c_din;
        end
    end

endmodule

