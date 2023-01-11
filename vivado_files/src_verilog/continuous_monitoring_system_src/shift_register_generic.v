
module shift_register_generic
#(
    parameter DATA_INPUT_WIDTH = 16,
    parameter DATA_OUTPUT_WIDTH = 256
)(
    input [DATA_INPUT_WIDTH-1:0] data_in,
    input shift,
    output [DATA_OUTPUT_WIDTH-1:0] data_out
    );
    reg [DATA_OUTPUT_WIDTH-1:0] r_data_out = 0;
    assign data_out = r_data_out;
    always @(posedge shift)
    begin
        r_data_out <= (r_data_out << DATA_INPUT_WIDTH) | data_in;
    end
endmodule