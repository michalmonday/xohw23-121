`timescale 1ns / 1ps

module mux_select_to_gpio #(
    parameter TO_SUBTRACT = 'h10
) (
    input [4:0] muxaddr_out,
    output wire gpio_0,
    output wire gpio_1,
    output wire gpio_2,
    output wire gpio_3
    );
    wire [4:0]muxaddr_subtracted = muxaddr_out - TO_SUBTRACT;
    
    assign gpio_0 = muxaddr_subtracted[0];
    assign gpio_1 = muxaddr_subtracted[1];
    assign gpio_2 = muxaddr_subtracted[2];
    assign gpio_3 = muxaddr_subtracted[3];
endmodule
