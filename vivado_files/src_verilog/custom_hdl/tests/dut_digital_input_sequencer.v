`timescale 1ns/10ps

module dut_digital_input_sequencer();
    reg clk = 0;
    digital_input_sequencer #(
        .SR_CLK_DIVIDER(1)
    ) digital_input_sequencer_inst  (
        .clk(clk),
        .rst_n(1),
        .sr_clock(),
        .sr_latch(),
        .address(), 
        .write_enable()
    );

    always #5 clk = ~clk;
endmodule

