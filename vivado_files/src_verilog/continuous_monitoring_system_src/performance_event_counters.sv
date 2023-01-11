
`timescale 1ns/10ps

module performance_event_counters #(
    parameter INPUT_EVENT_BITMAP_WIDTH = 115,
    parameter COUNTER_WIDTH = 7 // 7 * 115 = 805 (leaving 219 bits for other data, AXI DMA can't use more than 1024 bits data width)
) (
    input clk, 
    input rst_n,
    input [INPUT_EVENT_BITMAP_WIDTH-1:0] performance_events, // bitmap
    output wire [COUNTER_WIDTH-1:0] counters[INPUT_EVENT_BITMAP_WIDTH-1:0],
    output wire [INPUT_EVENT_BITMAP_WIDTH-1:0] overflow_map
);
    reg [COUNTER_WIDTH-1:0] r_counters[INPUT_EVENT_BITMAP_WIDTH-1:0] = '{INPUT_EVENT_BITMAP_WIDTH{0}};
    reg [INPUT_EVENT_BITMAP_WIDTH-1:0] r_overflow_map = 0;
    assign counters = r_counters;
    assign overflow_map = r_overflow_map;

    integer i;

	always @(posedge clk) begin
        if (~rst_n) begin
            for (i = 0; i < INPUT_EVENT_BITMAP_WIDTH; i=i+1) begin
                r_counters[i] <= performance_events[i];
                // r_counters[i] <= 0;
            end
            r_overflow_map <= 0;
        end else begin
            // increase counter based on corresponding input bit
            for (i = 0; i < INPUT_EVENT_BITMAP_WIDTH; i=i+1) begin
                r_counters[i] <= r_counters[i] + performance_events[i];

                // if a counter has a maximum value and is about to be increased by 1, set overflow bit
                if (r_counters[i] == {COUNTER_WIDTH{1'b1}} && performance_events[i] == 1'b1) begin
                    r_overflow_map[i] <= 1;
                end
            end
        end
	end
endmodule

