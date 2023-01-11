// This module checks if instruction is not a branch/jump/return.
// If that's the case, then "drop_instr" is set to 1.
// Optional functionality of sending a second instruction proceeding a branch/jump/return.

`timescale 1ns/10ps

import continuous_monitoring_system_pkg::*;

module trace_filter #(
    parameter SEND_INSTRUCTION_AFTER_BRANCH = 1,
    parameter SEND_INSTRUCTION_AFTER_JUMP = 1,
    parameter SEND_INSTRUCTION_AFTER_WFI = 1,

    
    parameter SEND_INSTRUCTION_AFTER_TRAP = 1,
    parameter SEND_INSTRUCTION_AFTER_INTERRUPT = 1
) 
(
    input   logic                                                   clk, 
    input   logic                                                   rst_n,
    input   logic                                                   pc_valid,

    input   logic   [PERFORMANCE_EVENT_MOD_COUNTER_WIDTH - 1 : 0]   trap_counter, // HPM Counter 2 (original index), 0 (new index, when 39 counters are used instead of all 115)
    input   logic   [PERFORMANCE_EVENT_MOD_COUNTER_WIDTH - 1 : 0]   interrupt_counter, // HPM Counter 30 (original index), 13 (new index, when 39 counters are used instead of all 115)

    input   logic   [RISC_V_INSTRUCTION_WIDTH - 1 : 0]              next_instr,
    output  logic                                                   drop_instr
);

    logic branch;
    logic jump;
    logic wfi;

    reg queue_instruction = 1'b0;
    reg send_next_instruction = 1'b0;

    reg     previous_trap_counter = 0;
    reg     previous_interrupt_counter = 0;
    reg     trap_counter_incremented = 1'b0;
    reg     interrupt_counter_incremented = 1'b0;
    reg     send_next_instruction_after_trap = 1'b0;
    reg     send_next_instruction_after_interrupt = 1'b0;
    
    // assign branch = (next_instr[6:0] == BRANCH_OPCODE) ||
    //                 (next_instr[1:0] == C_BRANCH_OPCODE && next_instr[15:14] == C_BRANCH_FUNCT3_2_MSB);


    // assign jump =   (next_instr[6:0] == JAL_OPCODE) || 
    //                 (next_instr[6:0] == JALR_OPCODE) ||
    //                 (next_instr[1:0] == C_JAL_OPCODE && next_instr[15:13] == C_JAL_FUNCT3_3_MSB) ||
    //                 (next_instr[1:0] == C_JALR_OPCODE && next_instr[15:13] == C_JALR_FUNCT4_3_MSB);

    // assign wfi =    (next_instr == WFI_INSTRUCTION);


    always_ff @(posedge clk) begin // Sends the instruction proceeding a branch/jump/return if the corresponding parameter is set.
        if (rst_n == 0) begin
            queue_instruction <= 1'b0;
            send_next_instruction <= 1'b0;
            branch <= 0;
            jump <= 0;
            wfi <= 0;
        end else if (pc_valid) begin
            // // Instruction opcodes
            // parameter BRANCH_OPCODE = 7'b1100011;
            // parameter JAL_OPCODE = 7'b1101111;
            // parameter JALR_OPCODE = 7'b1100111;

            // // Compressed Instruction opcodes
            // parameter C_BRANCH_OPCODE = 2'b10;
            // parameter C_JAL_OPCODE = 2'b01;
            // parameter C_JALR_OPCODE = 2'b00;
            // parameter C_BRANCH_FUNCT3_2_MSB = 2'b11;
            // parameter C_JAL_FUNCT3_3_MSB = 3'b101;
            // parameter C_JALR_FUNCT4_3_MSB = 3'b100;
            branch <= (next_instr[6:0] == BRANCH_OPCODE) ||
                     (next_instr[1:0] == C_BRANCH_OPCODE && next_instr[15:14] == C_BRANCH_FUNCT3_2_MSB);
            jump <=  (next_instr[6:0] == JAL_OPCODE) || 
                     (next_instr[6:0] == JALR_OPCODE) ||
                     (next_instr[1:0] == C_JAL_OPCODE && next_instr[15:13] == C_JAL_FUNCT3_3_MSB) ||
                     (next_instr[1:0] == C_JALR_OPCODE && next_instr[15:13] == C_JALR_FUNCT4_3_MSB);


            wfi <= (next_instr == WFI_INSTRUCTION);


            // queue_instruction <= (branch && SEND_INSTRUCTION_AFTER_BRANCH) || (jump && SEND_INSTRUCTION_AFTER_JUMP) || (wfi && SEND_INSTRUCTION_AFTER_WFI);
            // send_next_instruction <= queue_instruction;
            send_next_instruction <= (branch && SEND_INSTRUCTION_AFTER_BRANCH) || (jump && SEND_INSTRUCTION_AFTER_JUMP) || (wfi && SEND_INSTRUCTION_AFTER_WFI);
        end
    end


    always_ff @(posedge clk) begin // Keeps track of when the HPM counters are incremented
        if (rst_n == 0) begin
            previous_trap_counter <= 0;
            previous_interrupt_counter <= 0;
        end else begin
            previous_trap_counter <= trap_counter;
            previous_interrupt_counter <= interrupt_counter;
        end
    end


    always_ff @(posedge clk) begin // If a trap or interrupt happens, then send the next valid instruction.
        if (rst_n == 0) begin
            trap_counter_incremented <= 1'b0;
            interrupt_counter_incremented <= 1'b0;
            send_next_instruction_after_trap <= 1'b0;    
            send_next_instruction_after_interrupt <= 1'b0;
        end else begin

            if (previous_trap_counter < trap_counter) begin
                trap_counter_incremented <= 1'b1;
            end

            if (previous_interrupt_counter < interrupt_counter) begin
                interrupt_counter_incremented <= 1'b1;
            end
            
            send_next_instruction_after_trap        <= pc_valid && trap_counter_incremented && SEND_INSTRUCTION_AFTER_TRAP;
            send_next_instruction_after_interrupt   <= pc_valid && interrupt_counter_incremented && SEND_INSTRUCTION_AFTER_INTERRUPT;

            if (send_next_instruction_after_trap) begin 
                trap_counter_incremented <= 1'b0;
                send_next_instruction_after_trap <= 1'b0;
            end

            if (send_next_instruction_after_interrupt) begin
                interrupt_counter_incremented <= 1'b0;
                send_next_instruction_after_interrupt <= 1'b0;
            end

        end
    end
        

    assign drop_instr = ~(  branch || 
                            jump || 
                            wfi || 
                            send_next_instruction || 
                            send_next_instruction_after_trap ||
                            send_next_instruction_after_interrupt);
        
    
endmodule