/* 
This wrapper was created because there is no way to use SystemVerilog as a module
in Vivado, it is also not possible to use IP where the top level module is written
in SystemVerilog. This is just a workaround.
*/
`define CTRL_ADDR_WIDTH 8 // internal addressing (each of 256 addresses can result in a different action upon writing/reading)
`define CTRL_DATA_WIDTH 64 // control data width, the functionality of the module is controlled by writing to address+data ports
`define NO_OF_PERFORMANCE_EVENTS 39
`define PERFORMANCE_EVENT_MOD_COUNTER_WIDTH 7
`define XLEN 64
`define AXI_DATA_WIDTH 1024
`define RISC_V_INSTRUCTION_WIDTH 32

// 32 regs * (64 each + 64 of CHERI meta data)
// `define GENERAL_PURPOSE_REGISTERS_WIDTH 4096

`define REGISTER_WIDTH 128


module cms_ip_wrapper #(
    parameter CTRL_WRITE_ENABLE_POSEDGE_TRIGGERED = 1 // 1 = write enable is pos edge triggered, 0 = write enable is level triggered
    //parameter CTRL_ADDR_WIDTH = 4 // internal addressing (each of 16 addresses can result in a different action upon writing/reading)
) (
    input clk, rst_n, 
    // cpu_rst_n will allow to reset clk_counter, as a result it will allow to measure time since CPU reset
    // and the first collected item (later allowing to subtract it from overall data collection time when 
    // calculating throughput of data extraction)
    input cpu_rst_n,

    // data pkt signals (to be stored in FIFO)
    input [31:0] instr,
    input [`XLEN-1:0] pc,
    // input pc_valid, // determines whether the current instruction/pc is executed now

    // axi signals (interfacing with FIFO)
    output wire M_AXIS_tvalid,
    input M_AXIS_tready,
    output wire [`AXI_DATA_WIDTH - 1 : 0] M_AXIS_tdata,
    output wire M_AXIS_tlast,
    // number of items in FIFO after which tlast is asserted (it may be reasonable to set it by AXI GPIO from PYNQ to a value that 
    // is equal to the number of items that fit in the allocated buffer)
    // input [31:0] tlast_interval, 

    // control signals (determining operational mode of the continuous_monitoring_system)
    input [`CTRL_ADDR_WIDTH-1:0] ctrl_addr,
    input [`CTRL_DATA_WIDTH-1:0] ctrl_wdata,
    input ctrl_write_enable,

    // enable the module (if disabled, the module will not send any data to the FIFO)
    // this may be connected to the GPIO rst_n (the same one used to reset the processor)
    input en,
    input [`NO_OF_PERFORMANCE_EVENTS-1:0]performance_events,
    input fifo_full, // CPU is halted when fifo is full, we can use this to count ticks while halted and later calculate performance penalty due to CMS usage
    // input [`GENERAL_PURPOSE_REGISTERS_WIDTH-1:0] general_purpose_registers,
    input wire [`REGISTER_WIDTH-1:0] gpr_value,
    input wire [4:0] gpr_address,
    input wire gpr_write_enable,

    output wire halt_cpu,

    output wire branch_event_probe1,
    output wire jal_event_probe1,
    output wire auipc_event_probe1,
    output wire [`PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] branch_counter_probe1,
    output wire [`PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] jal_counter_probe1,
    output wire [`PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] auipc_counter_probe1,

    output wire [`RISC_V_INSTRUCTION_WIDTH:0] data_pkt_instr_probe,
    output wire [`XLEN-1:0] data_pkt_pc_probe,
    output wire [`PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] data_pkt_branch_counter_probe,
    output wire [`PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] data_pkt_jal_counter_probe,
    output wire [`PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] data_pkt_auipc_counter_probe,

    output wire performance_counters_rst_n_probe,
    output wire [63:0] item_counter_probe
);

continuous_monitoring_system #(
    .CTRL_WRITE_ENABLE_POSEDGE_TRIGGERED(1) 
) cms (
    .clk(clk), .rst_n(rst_n), 
    .cpu_rst_n(cpu_rst_n),

    // data pkt signals (to be stored in FIFO)
    .instr(instr),
    .pc(pc),
    // .pc_valid(pc_valid), // determines whether the current instruction/pc is executed now


    // axi signals (interfacing with FIFO)
    .M_AXIS_tvalid(M_AXIS_tvalid),
    .M_AXIS_tready(M_AXIS_tready),
    .M_AXIS_tdata(M_AXIS_tdata),
    .M_AXIS_tlast(M_AXIS_tlast),
    // .tlast_interval(tlast_interval), // number of items in FIFO after which tlast is asserted

    // control signals (determining operational mode of the continuous_monitoring_system)
    .ctrl_addr(ctrl_addr),
    .ctrl_wdata(ctrl_wdata),
    .ctrl_write_enable(ctrl_write_enable),

    // enable the module (if disabled, the module will not send any data to the FIFO)
    // this may be connected to the GPIO rst_n (the same one used to reset the processor)
    .en(en),
    .performance_events(performance_events),

    // CPU is halted when fifo is full, we can use this to count ticks while halted and later calculate performance penalty due to CMS usage
    .fifo_full(fifo_full), 
    // .general_purpose_registers(general_purpose_registers),

    .gpr_value(gpr_value),
    .gpr_address(gpr_address),
    .gpr_write_enable(gpr_write_enable),

    .halt_cpu(halt_cpu),

    .branch_event_probe1(branch_event_probe1),
    .jal_event_probe1(jal_event_probe1),
    .auipc_event_probe1(auipc_event_probe1),
    .branch_counter_probe1(branch_counter_probe1),
    .jal_counter_probe1(jal_counter_probe1),
    .auipc_counter_probe1(auipc_counter_probe1),

    .data_pkt_instr_probe(data_pkt_instr_probe),
    .data_pkt_pc_probe(data_pkt_pc_probe),
    .data_pkt_branch_counter_probe(data_pkt_branch_counter_probe),
    .data_pkt_jal_counter_probe(data_pkt_jal_counter_probe),
    .data_pkt_auipc_counter_probe(data_pkt_auipc_counter_probe),

    .performance_counters_rst_n_probe(performance_counters_rst_n_probe),
    .item_counter_probe(item_counter_probe)
);

endmodule
