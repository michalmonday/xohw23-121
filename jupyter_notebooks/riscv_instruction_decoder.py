# This file was written mostly by GitHub Copilot

def decode_riscv_instruction(instruction):
    opcode = instruction & 0x7F
    rd = (instruction >> 7) & 0x1F
    funct3 = (instruction >> 12) & 0x7
    funct7 = (instruction >> 25) & 0x7F
    return opcode, rd, funct3, funct7

def get_riscv_instruction_name(instruction):
    if instruction == 0x10500073:
        return 'WFI'
    opcode, rd, funct3, funct7 = decode_riscv_instruction(instruction)
    if opcode == 0x33:
        if funct3 == 0x0:
            if funct7 == 0x0:
                return 'ADD'
            elif funct7 == 0x20:
                return 'SUB'
        elif funct3 == 0x1:
            return 'SLL'
        elif funct3 == 0x2:
            return 'SLT'
        elif funct3 == 0x3:
            return 'SLTU'
        elif funct3 == 0x4:
            return 'XOR'
        elif funct3 == 0x5:
            if funct7 == 0x0:
                return 'SRL'
            elif funct7 == 0x20:
                return 'SRA'
        elif funct3 == 0x6:
            return 'OR'
        elif funct3 == 0x7:
            return 'AND'
    elif opcode == 0x13:
        if funct3 == 0x0:
            return 'ADDI'
        elif funct3 == 0x1:
            return 'SLLI'
        elif funct3 == 0x2:
            return 'SLTI'
        elif funct3 == 0x3:
            return 'SLTIU'
        elif funct3 == 0x4:
            return 'XORI'
        elif funct3 == 0x5:
            if funct7 == 0x0:
                return 'SRLI'
            elif funct7 == 0x20:
                return 'SRAI'
        elif funct3 == 0x6:
            return 'ORI'
        elif funct3 == 0x7:
            return 'ANDI'
    elif opcode == 0x3:
        if funct3 == 0x0:
            return 'LB'
        elif funct3 == 0x1:
            return 'LH'
        elif funct3 == 0x2:
            return 'LW'
        elif funct3 == 0x4:
            return 'LBU'
        elif funct3 == 0x5:
            return 'LHU'
    elif opcode == 0x23:
        if funct3 == 0x0:
            return 'SB'
        elif funct3 == 0x1:
            return 'SH'
        elif funct3 == 0x2:
            return 'SW'
    elif opcode == 0x37:
        return 'LUI'
    elif opcode == 0x17:
        return 'AUIPC'
    elif opcode == 0x6F:
        if rd == 0x0:
            return 'J'
        return 'JAL'
    elif opcode == 0x67:
        return 'JALR'
    elif opcode == 0x63:
        if funct3 == 0x0:
            return 'BEQ'
        elif funct3 == 0x1:
            return 'BNE'
        elif funct3 == 0x4:
            return 'BLT'
        elif funct3 == 0x5:
            return 'BGE'
        elif funct3 == 0x6:
            return 'BLTU'
        elif funct3 == 0x7:
            return 'BGEU'
    elif opcode == 0x73:
        if funct3 == 0x0:
            if funct7 == 0x0:
                return 'ECALL'
            elif funct7 == 0x1:
                return 'EBREAK'
        elif funct3 == 0x1:
            if funct7 == 0x0:
                return 'CSRRW'
            elif funct7 == 0x1:
                return 'CSRRS'
            elif funct7 == 0x2:
                return 'CSRRC'
            elif funct7 == 0x5:
                return 'CSRRWI'
            elif funct7 == 0x6:
                return 'CSRRCI'
    return 'UNKNOWN'