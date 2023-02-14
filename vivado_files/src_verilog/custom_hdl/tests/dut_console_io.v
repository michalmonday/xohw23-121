`timescale 1ns/10ps


module dut_console_io ();

    reg clk = 0;
    reg rst_n = 0;

    reg [31:0] AXI_GPIO_input = 0;
    wire [31:0] AXI_GPIO_output;
    reg cpu_reset_completed = 1;
    reg RDY_put_from_console_put = 1;
    wire [7:0] put_from_console_put;
    wire EN_put_from_console_put;

    reg [7:0] get_to_console_get = 0;
    reg RDY_get_to_console_get = 0;


    console_io u0 (
        .clk(clk),
        .rst_n(rst_n),
        .AXI_GPIO_input(AXI_GPIO_input),
        .AXI_GPIO_output(AXI_GPIO_output),
        .cpu_reset_completed(cpu_reset_completed),
        .RDY_put_from_console_put(RDY_put_from_console_put),
        .put_from_console_put(put_from_console_put),
        .EN_put_from_console_put(EN_put_from_console_put),
        .input_fifo_counter(),
        .get_to_console_get(get_to_console_get),
        .RDY_get_to_console_get(RDY_get_to_console_get),
        .output_fifo_counter()
    );

    always 
    begin
        #5 clk = ~clk;
    end

    initial
    begin
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk); @(posedge clk); @(posedge clk); @(posedge clk);

        AXI_GPIO_input[7:0] = 'hFF; AXI_GPIO_input[8] = 1; @(posedge clk); AXI_GPIO_input[8] = 0; @(posedge clk);
        AXI_GPIO_input[7:0] = 'hFE; AXI_GPIO_input[8] = 1; @(posedge clk); AXI_GPIO_input[8] = 0; @(posedge clk);
        AXI_GPIO_input[7:0] = 'hFD; AXI_GPIO_input[8] = 1; @(posedge clk); AXI_GPIO_input[8] = 0; @(posedge clk);
        AXI_GPIO_input[7:0] = 'hFC; AXI_GPIO_input[8] = 1; @(posedge clk); AXI_GPIO_input[8] = 0; @(posedge clk);

        RDY_put_from_console_put = 0; 
        AXI_GPIO_input[7:0] = 'hFB; AXI_GPIO_input[8] = 1; @(posedge clk); AXI_GPIO_input[8] = 0; @(posedge clk);

        RDY_put_from_console_put = 1; 
        AXI_GPIO_input[7:0] = 'hFA; AXI_GPIO_input[8] = 1; @(posedge clk); AXI_GPIO_input[8] = 0; @(posedge clk);

        #50;
        @(posedge clk);
        // append 3 chars to console output (pretending to be from the CPU)
        get_to_console_get = 'hAA; RDY_get_to_console_get = 1; @(posedge clk); RDY_get_to_console_get = 0; @(posedge clk);
        get_to_console_get = 'hAB; RDY_get_to_console_get = 1; @(posedge clk); RDY_get_to_console_get = 0; @(posedge clk);
        get_to_console_get = 'hAC; RDY_get_to_console_get = 1; @(posedge clk); RDY_get_to_console_get = 0; @(posedge clk);

        // wait 3 clock cycles
        @(posedge clk); @(posedge clk); @(posedge clk); 

        // get 3 chars from console output
        AXI_GPIO_input[9] = 1; @(posedge clk); AXI_GPIO_input[9] = 0; @(posedge clk);
        AXI_GPIO_input[9] = 1; @(posedge clk); AXI_GPIO_input[9] = 0; @(posedge clk);
        AXI_GPIO_input[9] = 1; @(posedge clk); AXI_GPIO_input[9] = 0; @(posedge clk);

        // wait 3 clock cycles
        @(posedge clk); @(posedge clk); @(posedge clk); 

        // append 1 more char to console output (pretending to be from the CPU)
        // and check if "fifo empty" bit changes in GPIO output
        get_to_console_get = 'hAD; RDY_get_to_console_get = 1; @(posedge clk); RDY_get_to_console_get = 0; @(posedge clk);
    end

endmodule