// continuous monitoring system module will allow the user to do the following:
// 1. Supply information like program counter, instruction, etc. to the module (which will be stored in a FIFO)
// 2. Supply trace start/end addresses (and enable both optionally).
// 3. Supply monitored address range (lower bound + higher bound + enable both optionally).

`timescale 1ns/10ps

import continuous_monitoring_system_pkg::*;

module continuous_monitoring_system #(
    parameter CTRL_WRITE_ENABLE_POSEDGE_TRIGGERED = 1 // 1 = write enable is pos edge triggered, 0 = write enable is level triggered
    //parameter CTRL_ADDR_WIDTH = 4 // internal addressing (each of 16 addresses can result in a different action upon writing/reading)
) (
    input   logic   clk,
    input   logic   rst_n,
    input   logic   cpu_rst_n,

    // data pkt signals (to be stored in FIFO)
    input   logic   [RISC_V_INSTRUCTION_WIDTH - 1 : 0]  instr,
    input   logic   [XLEN - 1 : 0]                      pc,
    // input   logic                                       pc_valid, // determines whether the current instruction/pc is executed now

    // axi signals (interfacing with FIFO)
    output  logic                               M_AXIS_tvalid,
    input   logic                               M_AXIS_tready,
    output  logic   [AXI_DATA_WIDTH - 1 : 0]    M_AXIS_tdata,
    output  logic                               M_AXIS_tlast,
    // input   logic   [31 : 0]                    tlast_interval, // number of items in FIFO after which tlast is asserted

    // control signals (determining operational mode of the continuous_monitoring_system)
    input   ctrl_addr_t                         ctrl_addr,
    input   logic   [CTRL_DATA_WIDTH - 1 : 0]   ctrl_wdata,
    input   logic                               ctrl_write_enable,

    // enable the module (if disabled, the module will not send any data to the FIFO)
    // this may be connected to the GPIO rst_n (the same one used to reset the processor)
    
    input   logic                                       en,
    input   logic   [NO_OF_PERFORMANCE_EVENTS - 1 : 0]  performance_events,
    // CPU is halted when fifo is full, we can use this to count ticks while halted and later calculate performance penalty due to CMS usage
    input fifo_full, 
    // input   logic   [GENERAL_PURPOSE_REGISTERS_WIDTH - 1 : 0] general_purpose_registers,

    input wire [REGISTER_WIDTH-1:0] gpr_value,
    input wire [4:0] gpr_address,
    input wire gpr_write_enable,

    input wire receive_transfer_request,

    output logic halt_cpu,

    output logic pc_valid_new_probe,

    output wire branch_event_probe1,
    output wire jal_event_probe1,
    output wire auipc_event_probe1,
    output wire [PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] branch_counter_probe1,
    output wire [PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] jal_counter_probe1,
    output wire [PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] auipc_counter_probe1,

    output wire [RISC_V_INSTRUCTION_WIDTH:0] data_pkt_instr_probe,
    output wire [XLEN-1:0] data_pkt_pc_probe,
    output wire [PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] data_pkt_branch_counter_probe,
    output wire [PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] data_pkt_jal_counter_probe,
    output wire [PERFORMANCE_EVENT_MOD_COUNTER_WIDTH-1:0] data_pkt_auipc_counter_probe,

    output wire performance_counters_rst_n_probe,
    output wire [63:0] item_counter_probe,

    output wire [ATF_POS_BITS_BOUNDS_WIDTH-1:0] atf_result_bit_counts_0_probe,
    output wire [ATF_POS_BITS_BOUNDS_WIDTH-1:0] atf_lower_bound_0_0_probe,
    output wire [ATF_POS_BITS_BOUNDS_WIDTH-1:0] atf_upper_bound_0_0_probe,

    output wire [63:0] shadow_general_purpose_register_A0_probe,
    output wire [63:0] shadow_general_purpose_register_A1_probe,
    output wire [63:0] shadow_general_purpose_register_A2_probe,
    output wire [63:0] shadow_general_purpose_register_A3_probe
);

    // ATF = advanced trace filter
    reg [DETERMINISTIC_DATA_WIDTH-1:0] atf_seed_input = 0;
    reg [DETERMINISTIC_DATA_WIDTH-1:0] atf_seed_mask_input = 0;
    reg [ATF_SEED_ADDR_WIDTH-1:0] atf_seed_address = 0;
    reg atf_seed_write_enable = 0;
    reg [ATF_POS_BITS_BOUNDS_WIDTH-1:0] atf_lower_bound_input = 0;
    reg [ATF_POS_BITS_BOUNDS_WIDTH-1:0] atf_upper_bound_input = 0;
    reg [ATF_RANGE_ADDR_WIDTH:0] atf_range_address = 0;
    reg atf_range_write_enable = 0;
    wire atf_drop_pkt;
    wire atf_keep_pkt;
    reg atf_active = 0;
    wire [ATF_POS_BITS_BOUNDS_WIDTH-1:0] atf_bit_counts [ATF_NUM_OF_SEEDS-1:0];
    reg [4:0]atf_mode = ATF_MODE_PATTERN_COLLECTION;

    logic drop_instr;
    wire [REGISTER_WIDTH-1:0]shadow_general_purpose_registers[31:0];

    assign shadow_general_purpose_register_A0_probe = shadow_general_purpose_registers[10][63:0];
    assign shadow_general_purpose_register_A1_probe = shadow_general_purpose_registers[11][63:0];
    assign shadow_general_purpose_register_A2_probe = shadow_general_purpose_registers[12][63:0];
    assign shadow_general_purpose_register_A3_probe = shadow_general_purpose_registers[13][63:0];

    // At the end of a program, a "wfi" (wait for interrupt) instruction is executed 
    // which stops the program from running. This is a good time to stop sending trace
    // to the FIFO.
    reg [7 : 0] wfi_stop = 0; // it is 2 bits to use it as a counter and control write enable only based on MSB (to delay disabling write by 1 cycle)
    localparam WFI_STOP_THRESHOLD = 255;

    wire pc_valid_new = ((last_pc[0] != last_pc[1] & (last_instr[1] != WFI_INSTRUCTION)) || (wfi_stop == WFI_STOP_THRESHOLD - 1)) 
                        & (last_pc[1] != 0) 
                        & rst_n;

    assign pc_valid_new_probe = pc_valid_new;

    // monitored address range
    reg monitored_address_range_lower_bound_enabled = 0;
    reg monitored_address_range_upper_bound_enabled = 0;
    reg [XLEN - 1 : 0] monitored_address_range_lower_bound = 0;
    reg [XLEN - 1 : 0] monitored_address_range_upper_bound = -1;
    // wire is_pc_in_range = (pc >= monitored_address_range_lower_bound) & (pc <= monitored_address_range_upper_bound);

    reg trigger_trace_start_address_enabled = 0;
    reg trigger_trace_end_address_enabled = 0;
    reg [XLEN - 1 : 0] trigger_trace_start_address = 0;
    reg [XLEN - 1 : 0] trigger_trace_end_address = -1;
    reg trigger_trace_start_reached = 0;
    reg trigger_trace_end_reached = 0;

    reg     [CLK_COUNTER_WIDTH - 1 : 0] clk_counter = 0;
    reg     [CLK_COUNTER_WIDTH - 1 : 0] last_write_timestamp = 0;

    logic [PERFORMANCE_EVENT_MOD_COUNTER_WIDTH - 1 : 0] performance_event_counters[NO_OF_PERFORMANCE_EVENTS - 1:0];
    assign branch_counter_probe1 = performance_event_counters[BRANCH_INDEX];
    assign branch_event_probe1 = performance_events[BRANCH_INDEX];
    assign jal_counter_probe1 = performance_event_counters[JAL_INDEX];
    assign jal_event_probe1 = performance_events[JAL_INDEX];
    assign auipc_counter_probe1 = performance_event_counters[AUIPC_INDEX];
    assign auipc_event_probe1 = performance_events[AUIPC_INDEX];

    reg [RISC_V_INSTRUCTION_WIDTH - 1: 0] last_instr [1:0];
    reg [XLEN - 1 : 0] last_pc [1:0];

    reg [63:0] fifo_full_ticks_count = 0;

    reg [63:0] tlast_interval = 0;
    reg halting_on_full_fifo_enabled = 1; // enabled by default
    reg arbitrary_halt = 0;
    assign halt_cpu = (halting_on_full_fifo_enabled & fifo_full) || arbitrary_halt;

    reg receive_transfer_requested = 0;


    shadow_general_purpose_registers_file #(
        .REGISTER_WIDTH(REGISTER_WIDTH) 
    ) shadow_general_purpose_registers_file_inst (
        .clk(clk),
        .rst_n(rst_n),
        .write_address(gpr_address), // 5-bit address for 32 locations
        .write_data(gpr_value),
        .write_enable(gpr_write_enable),

        .registers_output(shadow_general_purpose_registers)
    );

    // reg [63:0] program_start_address = 'h1000;
    // reg reset_clk_count_on_program_start_enabled = 0;

    // edge detector allows to detect pos/neg edges of a write enable signal
    // this is useful when this module is controlled by AXI GPIO from Python
    // it can be disabled by setting CTRL_WRITE_ENABLE_POSEDGE_TRIGGERED to 0
    edge_detector edge_detector_write_enable(
        .clk(clk),
        .sig(ctrl_write_enable),
        .neg_edge(),
        .pos_edge(ctrl_write_enable_pos_edge)
    );

    trace_filter #(
        .SEND_INSTRUCTION_AFTER_BRANCH(1),
        .SEND_INSTRUCTION_AFTER_JUMP(1),
        .SEND_INSTRUCTION_AFTER_WFI(0),
        .SEND_INSTRUCTION_AFTER_TRAP(0),
        .SEND_INSTRUCTION_AFTER_INTERRUPT(0)
    ) trace_filter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pc_valid(pc_valid_new),
        .trap_counter(performance_event_counters[0]), // Core__TRAP
        .interrupt_counter(performance_event_counters[13]), // Core__INTERRUPT
        .next_instr(last_instr[0]),
        .drop_instr(drop_instr)
    );

    // locations in data_pkt
    localparam PERFORMANCE_COUNTERS_LOCATION = 0;
    localparam PERFORMANCE_COUNTERS_OVERFLOW_MAP_LOCATION = NO_OF_PERFORMANCE_EVENTS * PERFORMANCE_EVENT_MOD_COUNTER_WIDTH;
    localparam PC_LOCATION = PERFORMANCE_COUNTERS_OVERFLOW_MAP_LOCATION + NO_OF_PERFORMANCE_EVENTS;
    localparam CLK_COUNTER_DELTA_LOCATION = PC_LOCATION + XLEN;
    localparam INSTR_LOCATION = CLK_COUNTER_DELTA_LOCATION + CLK_COUNTER_WIDTH;

    // Original data_pkt contained:
    // 1. performance counters
    // 2. performance counters overflow map
    // 3. pc
    // 4. clk_counter_delta
    // 5. instruction
    // 6. fifo_full_ticks_count
    // 7. shadow_general_purpose_registers
    // 
    // These values allowed to reconstruct the program flow after collecting them.
    // These would be good for debugging, but strictly for anomaly detection not so much.
    // PC and instructions are too repetitive and would have to be collected so often that 
    // anomaly detection couldn't be done in real time in software. With advanced trace
    // filter (ATF) we can collect values around 2000 times less often, in such case we can't
    // reconstruct the program flow from collected data, but we can detect anomalies in real 
    // time (in software). 
    // 
    // That is why the original data_pkt was replaced with the data_pkt_deterministic.
    // "deterministic" in this context means that it is time-independent, it contains data based
    // only on the current state of the processor (it does not include counters of any kind like HPCs or clk_counter).
    //
    // data_pkt_deterministic purpose is to recognize infrequent patterns in processor states and use them to 
    // collect data at the right time (slow anough to allow anomaly detection in software in real time). It is 
    // used by the ATF. ATF measures its binary similarity to an arbitrary random value of the same size called "seed", 
    // which is done by counting positive bits in result of XNOR operation. Multiple seeds can be used, with multiple ranges
    // of similarity that can be set to trigger data collection.
    //
    // data_pkt_counters will contain the main data used for anomaly detection. It contains:
    // 1. performance counters
    // 2. performance counters overflow map
    // 3. other counters (not sure what these can be, but we can count anything, like the number of "addi" instructions executed,
    //                    or we can count CHERI events based on general purpose registers/capabilities metadata values like object type, 
    //                    bounds, etc.)
    // (this list will be extended after initial tests with performance counters)

    wire [AXI_DATA_WIDTH - 1 : 0] data_pkt = {
        shadow_general_purpose_registers[13][63:0],
        shadow_general_purpose_registers[12][63:0],
        shadow_general_purpose_registers[11][63:0],
        shadow_general_purpose_registers[10][63:0],
        fifo_full_ticks_count,
        last_instr[1],
        clk_counter - last_write_timestamp,  
        last_pc[1],
        performance_counters_overflow_map,
        // {<<PERFORMANCE_EVENT_MOD_COUNTER_WIDTH{performance_event_counters}} // "reverse elements of a byte array and pack them into an int"
        // {>>{performance_event_counters}}
        performance_event_counters[38], performance_event_counters[37], 
        performance_event_counters[36], performance_event_counters[35], performance_event_counters[34], performance_event_counters[33],
        performance_event_counters[32], performance_event_counters[31], performance_event_counters[30], performance_event_counters[29],
        performance_event_counters[28], performance_event_counters[27], performance_event_counters[26], performance_event_counters[25],
        performance_event_counters[24], performance_event_counters[23], performance_event_counters[22], performance_event_counters[21],
        performance_event_counters[20], performance_event_counters[19], performance_event_counters[18], performance_event_counters[17],
        performance_event_counters[16], performance_event_counters[15], performance_event_counters[14], performance_event_counters[13],
        performance_event_counters[12], performance_event_counters[11], performance_event_counters[10], performance_event_counters[9],
        performance_event_counters[8], performance_event_counters[7], performance_event_counters[6], performance_event_counters[5],
        performance_event_counters[4], performance_event_counters[3], performance_event_counters[2], performance_event_counters[1],
        performance_event_counters[0]
        };
    

    // wire [AXI_DATA_WIDTH-1:0] data_pkt_counters  = {
    //     shadow_general_purpose_registers[13][63:0],
    //     shadow_general_purpose_registers[12][63:0],
    //     shadow_general_purpose_registers[11][63:0],
    //     shadow_general_purpose_registers[10][63:0],
    //     fifo_full_ticks_count,
    //     last_instr[1],
    //     clk_counter - last_write_timestamp,  
    //     last_pc[1],
    //     performance_counters_overflow_map,
    //     performance_event_counters[38], performance_event_counters[37], 
    //     performance_event_counters[36], performance_event_counters[35], performance_event_counters[34], performance_event_counters[33],
    //     performance_event_counters[32], performance_event_counters[31], performance_event_counters[30], performance_event_counters[29],
    //     performance_event_counters[28], performance_event_counters[27], performance_event_counters[26], performance_event_counters[25],
    //     performance_event_counters[24], performance_event_counters[23], performance_event_counters[22], performance_event_counters[21],
    //     performance_event_counters[20], performance_event_counters[19], performance_event_counters[18], performance_event_counters[17],
    //     performance_event_counters[16], performance_event_counters[15], performance_event_counters[14], performance_event_counters[13],
    //     performance_event_counters[12], performance_event_counters[11], performance_event_counters[10], performance_event_counters[9],
    //     performance_event_counters[8], performance_event_counters[7], performance_event_counters[6], performance_event_counters[5],
    //     performance_event_counters[4], performance_event_counters[3], performance_event_counters[2], performance_event_counters[1],
    //     performance_event_counters[0]
    // };

    // "atf_data_pkt_deterministic" is pretty much a data_pkt without data that depends on previous state of the processor.
    // That is to ensure that the decision to store data is the same regardless of when monitoring begins.
    // Keeping this decision time-agnostic allows to avoid issues with issues arising from periodical data collection, 
    // because the same issues occur to some extent when decision is based on counts of events that happened in the past.
    // The DETERMINISTIC_DATA_WIDTH must be updated manually if the content of this packet changes.
    wire [DETERMINISTIC_DATA_WIDTH-1:0] atf_data_pkt_deterministic = {
        // shadow_general_purpose_registers[31][63:0], // 64 bits T6
        // shadow_general_purpose_registers[30][63:0], // 64 bits T5
        // shadow_general_purpose_registers[29][63:0], // 64 bits T4
        // shadow_general_purpose_registers[28][63:0], // 64 bits T3
        // shadow_general_purpose_registers[27][63:0], // 64 bits S11
        // shadow_general_purpose_registers[26][63:0], // 64 bits S10
        // shadow_general_purpose_registers[25][63:0], // 64 bits S9
        // shadow_general_purpose_registers[24][63:0], // 64 bits S8
        // shadow_general_purpose_registers[23][63:0], // 64 bits S7
        // shadow_general_purpose_registers[22][63:0], // 64 bits S6
        // shadow_general_purpose_registers[21][63:0], // 64 bits S5
        // shadow_general_purpose_registers[20][63:0], // 64 bits S4
        // shadow_general_purpose_registers[19][63:0], // 64 bits S3
        shadow_general_purpose_registers[18][63:0], // 64 bits S2
        // shadow_general_purpose_registers[17][63:0],    // 64 bits A7
        // shadow_general_purpose_registers[16][63:0],    // 64 bits A6
        // shadow_general_purpose_registers[15][63:0],    // 64 bits A5
        // shadow_general_purpose_registers[14][63:0],    // 64 bits A4
        shadow_general_purpose_registers[13][63:0],    // 64 bits A3
        shadow_general_purpose_registers[12][63:0],    // 64 bits A2
        shadow_general_purpose_registers[11][63:0],    // 64 bits A1
        shadow_general_purpose_registers[10][63:0],    // 64 bits A0
        shadow_general_purpose_registers[9][63:0],     // 64 bits S1
        shadow_general_purpose_registers[8][63:0],     // 64 bits S0 / Frame pointer
        // shadow_general_purpose_registers[7][63:0],     // 64 bits T2
        shadow_general_purpose_registers[6][63:0],     // 64 bits T1
        shadow_general_purpose_registers[5][63:0],     // 64 bits T0
        shadow_general_purpose_registers[4][63:0],     // 64 bits Thread pointer
        shadow_general_purpose_registers[3][63:0],     // 64 bits Global pointer

        shadow_general_purpose_registers[2][63:0],     // 64 bits Stack pointer
        shadow_general_purpose_registers[1][63:0],     // 64 bits Return address

        performance_events,                            // 39 bits, each for currently indicated event (these are not counters, as counters depend on previous state)
        last_instr[1],                                 // 32 bits
        last_pc[1]                                     // 64 bits
    };

    wire [AXI_DATA_WIDTH - 1: 0] data_to_axi_data_pkt = (atf_active & atf_mode == ATF_MODE_PATTERN_COLLECTION) ? atf_data_pkt_deterministic : data_pkt;

    assign data_pkt_instr_probe = data_pkt[INSTR_LOCATION + RISC_V_INSTRUCTION_WIDTH - 1 : INSTR_LOCATION];
    assign data_pkt_pc_probe = data_pkt[PC_LOCATION + XLEN - 1 : PC_LOCATION];
    localparam BRANCH_INDEX = 1;
    localparam JAL_INDEX = 2;
    localparam AUIPC_INDEX = 4;
    assign data_pkt_jal_counter_probe = data_pkt[PERFORMANCE_COUNTERS_LOCATION + PERFORMANCE_EVENT_MOD_COUNTER_WIDTH*(JAL_INDEX+1) - 1 : PERFORMANCE_COUNTERS_LOCATION+PERFORMANCE_EVENT_MOD_COUNTER_WIDTH*JAL_INDEX];
    assign data_pkt_branch_counter_probe = data_pkt[PERFORMANCE_COUNTERS_LOCATION + PERFORMANCE_EVENT_MOD_COUNTER_WIDTH*(BRANCH_INDEX+1) - 1 : PERFORMANCE_COUNTERS_LOCATION+PERFORMANCE_EVENT_MOD_COUNTER_WIDTH*BRANCH_INDEX];
    assign data_pkt_auipc_counter_probe = data_pkt[PERFORMANCE_COUNTERS_LOCATION + PERFORMANCE_EVENT_MOD_COUNTER_WIDTH*(AUIPC_INDEX+1) - 1 : PERFORMANCE_COUNTERS_LOCATION+PERFORMANCE_EVENT_MOD_COUNTER_WIDTH*AUIPC_INDEX];

    // wire data_to_axi_write_enable = en &
    //                                 pc_valid_new &
    //                                 (~drop_instr | atf_active) & 
    //                                 (atf_keep_pkt | ~atf_active) &
    //                                 (wfi_stop < WFI_STOP_THRESHOLD) & 
    //                                 (trigger_trace_start_reached | ~trigger_trace_start_address_enabled) &
    //                                 (~trigger_trace_end_reached | ~trigger_trace_end_address_enabled) &
    //                                 (last_pc[1] >= monitored_address_range_lower_bound | ~monitored_address_range_lower_bound_enabled) &
    //                                 (last_pc[1] <= monitored_address_range_upper_bound | ~monitored_address_range_upper_bound_enabled)
    //                                 ;
    
    
    wire basic_trace_filter_keep_item = en &
                                        pc_valid_new &
                                        ~drop_instr & 
                                        (wfi_stop < WFI_STOP_THRESHOLD) & 
                                        (trigger_trace_start_reached | ~trigger_trace_start_address_enabled) &
                                        (~trigger_trace_end_reached | ~trigger_trace_end_address_enabled) &
                                        (last_pc[1] >= monitored_address_range_lower_bound | ~monitored_address_range_lower_bound_enabled) &
                                        (last_pc[1] <= monitored_address_range_upper_bound | ~monitored_address_range_upper_bound_enabled)
                                        ;
    // wire atf_enable = basic_trace_filter_keep_item;
    wire atf_enable =   en &
                        pc_valid_new &
                        // ~drop_instr &  
                        (trigger_trace_start_reached | ~trigger_trace_start_address_enabled) &
                        (~trigger_trace_end_reached | ~trigger_trace_end_address_enabled) &
                        (last_pc[1] >= monitored_address_range_lower_bound | ~monitored_address_range_lower_bound_enabled) &
                        (last_pc[1] <= monitored_address_range_upper_bound | ~monitored_address_range_upper_bound_enabled);

    wire data_to_axi_write_enable = (basic_trace_filter_keep_item & (~atf_active || atf_mode == ATF_MODE_PATTERN_COLLECTION)) || // trace filter based
                                    (atf_keep_pkt & atf_active);  // advanced trace filter based

    wire performance_counters_rst_n = ~data_to_axi_write_enable & rst_n; // reset upon write to FIFO
    assign performance_counters_rst_n_probe = performance_counters_rst_n;
    wire [NO_OF_PERFORMANCE_EVENTS-1:0] performance_counters_overflow_map;

    performance_event_counters #(
        .INPUT_EVENT_BITMAP_WIDTH(NO_OF_PERFORMANCE_EVENTS),
        .COUNTER_WIDTH(PERFORMANCE_EVENT_MOD_COUNTER_WIDTH)
    ) performance_event_counters_inst (
        .clk(clk),
        .rst_n(performance_counters_rst_n),
        .performance_events(performance_events), // input bitmap (each bit is indicating if the corresponding performance event happens now)
        .counters(performance_event_counters),  // output counters
        .overflow_map(performance_counters_overflow_map) // output bitmap (each bit is indicating if the corresponding performance counter overflowed)
    );

    data_to_axi_stream #(
        .DATA_WIDTH(AXI_DATA_WIDTH) // pc + instr sizes
    ) data_to_axi_stream_inst (
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(data_to_axi_write_enable || receive_transfer_requested),
        // data_pkt is all 1s when receive_transfer_requested is set and if write enable would be LOW if it wasn't set
        .data_pkt((receive_transfer_requested & ~data_to_axi_write_enable) ? '{default:'1} : data_to_axi_data_pkt), 
        .tlast_interval(tlast_interval),
        .tlast(last_instr[1] == WFI_INSTRUCTION || receive_transfer_requested),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .M_AXIS_tready(M_AXIS_tready),
        .M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tlast(M_AXIS_tlast),

        .item_counter_probe(item_counter_probe)
    );

    advanced_trace_filter # (
        .DETERMINISTIC_DATA_WIDTH(DETERMINISTIC_DATA_WIDTH),
        .NUM_OF_SEEDS(ATF_NUM_OF_SEEDS),
        .RANGES_PER_SEED(ATF_RANGES_PER_SEED),
        .SEEDS_ADDR_WIDTH(ATF_SEED_ADDR_WIDTH),
        .RANGES_ADDR_WIDTH(ATF_RANGE_ADDR_WIDTH),
        .BIT_COUNTS_WIDTH(ATF_POS_BITS_BOUNDS_WIDTH)
    ) atf (
        .clk(clk),
        .rst_n(rst_n),
        .en(atf_enable),
        .data_pkt_deterministic(atf_data_pkt_deterministic),

        .seed_input(atf_seed_input),
        .seed_mask_input(atf_seed_mask_input),
        .seed_address(atf_seed_address),
        .seed_write_enable(atf_seed_write_enable),

        .lower_bound_input(atf_lower_bound_input),
        .upper_bound_input(atf_upper_bound_input),
        .range_address(atf_range_address),
        .range_write_enable(atf_range_write_enable),

        .drop_pkt(atf_drop_pkt),
        .keep_pkt(atf_keep_pkt),
        .result_bit_counts_0_probe(atf_result_bit_counts_0_probe),
        .lower_bound_0_0_probe(atf_lower_bound_0_0_probe),
        .upper_bound_0_0_probe(atf_upper_bound_0_0_probe),

        .bit_counts(atf_bit_counts) 
    );

    // control registers setting
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 0) begin
            // whole module status is reset (even if it was previously set through "ctrl_addr" and "ctrl_data")
            wfi_stop <= 0;

            monitored_address_range_lower_bound_enabled <= 0;
            monitored_address_range_upper_bound_enabled <= 0;
            monitored_address_range_lower_bound <= 0;
            monitored_address_range_upper_bound <= -1;

            trigger_trace_start_address_enabled <= 0;
            trigger_trace_end_address_enabled <= 0;
            trigger_trace_start_address <= 0;
            trigger_trace_end_address <= -1;
            trigger_trace_start_reached <= 0;
            trigger_trace_end_reached <= 0;

            clk_counter <= 0;
            last_write_timestamp <= 0;

            for (int i = 0; i < 2; i = i + 1) begin
                last_pc[i] <= 0;
                last_instr[i] <= 0;
            end

            fifo_full_ticks_count <= 0;
            // program_start_address <= 0;
            // reset_clk_count_on_program_start_enabled <= 0;

            atf_seed_write_enable <= 0;
            atf_range_write_enable <= 0;

            receive_transfer_requested <= 0;
        end
        else begin
            if (receive_transfer_request) begin
                receive_transfer_requested <= 1;
            end else begin
                receive_transfer_requested <= 0;
            end



            if (data_to_axi_write_enable || ~rst_n) begin
                fifo_full_ticks_count <= fifo_full ? 1 : 0; 
            end
            else if (fifo_full && en) begin
                fifo_full_ticks_count <= fifo_full_ticks_count + 1;
            end


            if (data_to_axi_write_enable) begin
                last_write_timestamp <= clk_counter;
            end 

            last_pc[1] <= last_pc[0];
            last_instr[1] <= last_instr[0];

            last_pc[0] <= pc;
            last_instr[0] <= instr;


            // if write enable is active (posedge/level triggered mode can be selected by CTRL_WRITE_ENABLE_POSEDGE_TRIGGERED)
            if ((CTRL_WRITE_ENABLE_POSEDGE_TRIGGERED & ctrl_write_enable_pos_edge) || (~CTRL_WRITE_ENABLE_POSEDGE_TRIGGERED & ctrl_write_enable)) begin
                case(ctrl_addr)
                    // -------------------------------------------------------------------
                    // trace trigger enables and addresses (must match the current PC exactly to trigger)
                    // -------------------------------------------------------------------
                    TRIGGER_TRACE_START_ADDRESS_ENABLED: begin
                        trigger_trace_start_address_enabled <= ctrl_wdata;
                    end 
                    TRIGGER_TRACE_END_ADDRESS_ENABLED: begin
                        trigger_trace_end_address_enabled <= ctrl_wdata;
                    end
                    TRIGGER_TRACE_START_ADDRESS: begin
                        trigger_trace_start_address <= ctrl_wdata;
                    end
                    TRIGGER_TRACE_END_ADDRESS: begin
                        trigger_trace_end_address <= ctrl_wdata;
                    end

                    // -------------------------------------------------------------------
                    // monitored address range (must be within the range to collect trace)
                    // -------------------------------------------------------------------
                    MONITORED_ADDRESS_RANGE_LOWER_BOUND_ENABLED: begin
                        monitored_address_range_lower_bound_enabled <= ctrl_wdata;
                    end
                    MONITORED_ADDRESS_RANGE_UPPER_BOUND_ENABLED: begin
                        monitored_address_range_upper_bound_enabled <= ctrl_wdata;
                    end
                    MONITORED_ADDRESS_RANGE_LOWER_BOUND: begin
                        monitored_address_range_lower_bound <= ctrl_wdata;
                    end
                    MONITORED_ADDRESS_RANGE_UPPER_BOUND: begin
                        monitored_address_range_upper_bound <= ctrl_wdata;
                    end

                    // WFI reached can be used to reset (it is reset anyway after loading Overlay again)
                    WFI_STOPPED: begin
                        wfi_stop <= ctrl_wdata;
                    end
                    CLK_COUNTER: begin
                        clk_counter <= ctrl_wdata;
                    end
                    LAST_WRITE_TIMESTAMP: begin
                        last_write_timestamp <= ctrl_wdata;
                    end
                    TLAST_INTERVAL: begin
                        tlast_interval <= ctrl_wdata;
                    end
                    HALTING_ON_FULL_FIFO_ENABLED: begin
                        halting_on_full_fifo_enabled <= ctrl_wdata;
                    end 
                    ARBITRARY_HALT: begin
                        arbitrary_halt <= ctrl_wdata;
                    end

                    // -------------------------------------------------------------------
                    // ------------   Advanced trace filter (ATF) control ----------------
                    // -------------------------------------------------------------------
                    ATF_SEED_INPUT: begin
                        // The seed value may be very long (e.g. 512 bits), the ctrl_wdata is only 64 bits wide,
                        // for that reason it must be supplied by writing multiple times to this address.
                        atf_seed_input <= (atf_seed_input << 64) | ctrl_wdata;
                    end
                    ATF_SEED_MASK_INPUT: begin
                        // allows to focus on specific values of deterministic_data_pkt, when seed portions are set 
                        // to identical values that deterministic_data_pkt_has, we can use seed mask and bit counts to 
                        // check if deterministic_data_pkt_has contains exact value (specified in seed) by checking if the number of 
                        // positive bits is equal to the number of positive bits in seed mask

                        // this provides convenient means to check if variable portions of deterministic_data_pkt equal specific values
                        // which allows for example to check when specific function was called with specific arguments
                        // and other more complex conditions like:
                        // - if function "a" was called with parameter 0xFF and stack pointer was equal to 0x800000F0 and register s1 was equal to 0x12345678
                        atf_seed_mask_input <= (atf_seed_mask_input << 64) | ctrl_wdata;
                    end 
                    ATF_SEED_ADDRESS: begin
                        atf_seed_address <= ctrl_wdata;
                    end
                    ATF_SEED_WRITE_ENABLE: begin
                        // TODO: RESET ON ANY CLOCK CYCLE WHERE CONTROL IS NOT CALLED
                        atf_seed_write_enable <= ctrl_wdata;
                    end
                    ATF_LOWER_BOUND_INPUT: begin
                        atf_lower_bound_input <= ctrl_wdata;
                    end
                    ATF_UPPER_BOUND_INPUT: begin
                        atf_upper_bound_input <= ctrl_wdata;
                    end
                    ATF_RANGE_ADDRESS: begin
                        atf_range_address <= ctrl_wdata;
                    end
                    ATF_RANGE_WRITE_ENABLE: begin
                        atf_range_write_enable <= ctrl_wdata;
                    end
                    ATF_ACTIVE: begin
                        atf_active <= ctrl_wdata;
                    end
                    ATF_MODE : begin
                        atf_mode <= ctrl_wdata;
                    end

                    // PROGRAM_START_ADDRESS: begin
                    //     program_start_address <= ctrl_wdata;
                    // end
                    // RESET_CLK_COUNT_ON_PROGRAM_START_ENABLED: begin
                    //     reset_clk_count_on_program_start_enabled <= ctrl_wdata;
                    // end

                    default: begin
                        // do nothing
                        atf_seed_write_enable <= 0;
                        atf_range_write_enable <= 0;
                    end
                endcase
            end
            else begin
                // signals that are also set by CMS control interface must be set here
                // to avoid setting them twice 
                atf_seed_write_enable <= 0;
                atf_range_write_enable <= 0;

                if (~cpu_rst_n) begin 
                    clk_counter <= 0;
                end 
                else begin
                    clk_counter <= clk_counter + 1;
                end

                if (last_instr[1] == WFI_INSTRUCTION && wfi_stop < WFI_STOP_THRESHOLD && en) begin
                    wfi_stop <= wfi_stop + 1;
                end 
                else if (last_instr[1] != WFI_INSTRUCTION) begin
                    wfi_stop <= 0;
                end

                if (trigger_trace_start_address_enabled && (pc == trigger_trace_start_address)) begin
                    trigger_trace_start_reached <= 1;
                    trigger_trace_end_reached <= 0;
                    $display("trigger_trace_start_address (%H) reached", trigger_trace_start_address);
                end
                if (trigger_trace_end_address_enabled && (pc == trigger_trace_end_address)) begin
                    trigger_trace_end_reached <= 1;
                    trigger_trace_start_reached <= 0;
                    $display("trigger_trace_end_address (%H) reached", trigger_trace_end_address);
                end
            end
        end
    end
endmodule

