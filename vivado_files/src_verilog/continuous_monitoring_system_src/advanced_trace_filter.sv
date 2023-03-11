`timescale 1ns/10ps

/* 
    This module will allow to greatly reduce the amount of extracted data.

    About the data:
        The data that will be extracted will not allow to reconstruct execution path.
        The data will include counts of events (HPCs, but not only) with the goal
        of creating a program profile, and later checking if the execution behaviour
        adheres to that profile. Tracing is anomaly detection oriented in this sense.

    About the filtering:
        The filtering involves performing XOR operation between the temporally deterministic  
        values from the current data_pkt and a random "seed" value of the same width. 
        The number of HIGH bits in the result of the XOR operation will be used for keeping/dropping
        the current data_pkt. The data packet will be kept if the number of HIGH bits falls into predefined
        range (or one of multiple ranges) 

        We may set the range (or ranges) by CMS configuration mechanism. Right now (10/03/23) results
        of the XOR operation in training data are examined manually (with matplotlib) and based on that the range is set.
        TODO: Automate the range setting process, by filtering out too frequent events (currently done), and by 
              picking events with high average distance between them. To penalize events that are too close too far from each other
              we may use the following method:

              optimal_dist = total_time / num_of_events
              dist = abs(optimal_dist - dist_between_two_events)
              how_bad_event_type_is = sum(all_events_dists)

              Not sure how this would work in practice. A more sophisticated method may be needed, because
              some it's too frequent events that we want to filter out, rare events are always good to keep.


        Multiple seeds values may be used (pseudocode: 'if val in range(one_seed) and val in range(another_seed)' ) 
        if a single seed value does not result in a good frequency distribution of the 
        number of HIGH bits in the result of the XOR operation.
*/


import continuous_monitoring_system_pkg::*;

module advanced_trace_filter #(
    // AXI_DATA_WIDTH = 1024,
    DETERMINISTIC_DATA_WIDTH = 1024,// not all data_pkt values are deterministic in time 
                                    // (any counts are probably not deterministic) so this width should not be equal to AXI TDATA (data_pkt) width
    NUM_OF_SEEDS = 1, // should be a power of 2
    RANGES_PER_SEED = 1
) (
    input wire clk,
    input wire rst_n,

    // if en is 0, the module will drop packets
    input wire en,

    // input wire [AXI_DATA_WIDTH-1:0] data_pkt,
    input wire [DETERMINISTIC_DATA_WIDTH-1:0] data_pkt_deterministic,

    input wire [DETERMINISTIC_DATA_WIDTH-1:0] seed_input,
    input wire [ATF_SEED_ADDR_WIDTH-1:0] seed_input_address,
    input wire seed_write_enable,

    input wire [ATF_POS_BITS_BOUNDS_WIDTH-1:0] lower_bound_input,
    input wire [ATF_POS_BITS_BOUNDS_WIDTH-1:0] upper_bound_input,
    input wire [ATF_SEED_ADDR_WIDTH-1:0] range_input_seed_address,
    input wire [ATF_RANGE_ADDR_WIDTH-1:0] range_input_range_address,
    input wire range_write_enable,

    output reg drop_pkt = 1,
    output reg keep_pkt = 0,

    output wire [ATF_POS_BITS_BOUNDS_WIDTH-1:0] result_bit_counts_0_probe,
    output wire [ATF_POS_BITS_BOUNDS_WIDTH-1:0] lower_bound_0_0_probe,
    output wire [ATF_POS_BITS_BOUNDS_WIDTH-1:0] upper_bound_0_0_probe,
    output wire [ATF_POS_BITS_BOUNDS_WIDTH:0] bit_counts [NUM_OF_SEEDS-1:0]
);
    reg [DETERMINISTIC_DATA_WIDTH-1:0] seeds [NUM_OF_SEEDS-1:0] = '{ default: '0 };
    reg [ATF_POS_BITS_BOUNDS_WIDTH-1:0] lower_bounds [NUM_OF_SEEDS-1:0] [RANGES_PER_SEED-1:0] = '{ default: '0 };
    reg [ATF_POS_BITS_BOUNDS_WIDTH-1:0] upper_bounds [NUM_OF_SEEDS-1:0] [RANGES_PER_SEED-1:0] = '{ default: '1 };

    // wire [DETERMINISTIC_DATA_WIDTH-1:0] data_pkt_deterministic = { data_pkt } ;
    wire [ATF_POS_BITS_BOUNDS_WIDTH:0] result_bit_counts [NUM_OF_SEEDS-1:0];// = '{ default: '0 };
    assign bit_counts = result_bit_counts;

    assign result_bit_counts_0_probe = result_bit_counts[0];
    assign lower_bound_0_0_probe = lower_bounds[0][0];
    assign upper_bound_0_0_probe = upper_bounds[0][0];

    // instantiate pos_bit_count module for each seed and assign the result to the corresponding result_bit_counts element
    for (genvar i = 0; i < NUM_OF_SEEDS; i++) begin
        pos_bit_count #(
            .DATA_WIDTH(DETERMINISTIC_DATA_WIDTH)
        ) pos_bit_count_inst (
            .clk(clk),
            .rst_n(rst_n),
            .data_in(~(data_pkt_deterministic ^ seeds[i])), // XNOR operation (outputs true if all inputs are the same, regardless if all are false or true)
                                                            // the count of HIGH bits in the result indicates binary similarity of 2 values
            .pos_bit_count(result_bit_counts[i])
        );
    end

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            // for (int i = 0; i < NUM_OF_SEEDS; i++) begin
            //     seeds[i] <= 1'b0;
            // end
            seeds <= '{ default: '0 };
        end else begin
            if (seed_write_enable) begin
                seeds[seed_input_address] <= seed_input;
            end
        end

    end

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            lower_bounds <= '{ default: '0 };
            upper_bounds <= '{ default: '1 };
            // for (int i = 0; i < NUM_OF_SEEDS; i++) begin
            //     for (int j = 0; j < RANGES_PER_SEED; j++) begin
            //         lower_bounds[i][j] <= 1'b0;
            //         upper_bounds[i][j] <= 1'b1;
            //     end
            // end
        end else begin
            if (range_write_enable) begin
                lower_bounds[range_input_seed_address][range_input_range_address] <= lower_bound_input;
                upper_bounds[range_input_seed_address][range_input_range_address] <= upper_bound_input;
            end
        end
    end

    reg temp_keep = 1'b0;
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            drop_pkt <= 1'b1;
            keep_pkt <= 1'b0;
        end else begin
            if (~en) begin
                drop_pkt <= 1'b1;
                keep_pkt <= 1'b0;
            end else begin
                temp_keep = 1;
                for (int i = 0; i < NUM_OF_SEEDS; i++) begin
                    for (int j = 0; j < RANGES_PER_SEED; j++) begin
                        if (result_bit_counts[i] < lower_bounds[i][j] || result_bit_counts[i] > upper_bounds[i][j]) begin
                            temp_keep = 0;
                        end
                    end
                end
                keep_pkt <= temp_keep;
                drop_pkt <= ~temp_keep;
            end
        end
    end





endmodule