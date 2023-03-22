#!/usr/bin/python3
import argparse
import re
import json
import os
from pprint import pprint
import sys

# The resulting json should have the following structure:
# {'_start': {'80000000': {'destination': '',
#                          'instr': 'F14022F3',
#                          'instr_name': 'CSRR',
#                          'type': 'entry'},
#             '80000004': {'destination': 'park',
#                          'instr': '02029063',
#                          'instr_name': 'BNEZ',
#                          'type': 'branch'},
#             '80000010': {'destination': 'main',
#                          'instr': '0280006F',
#                          'instr_name': 'J',
#                          'type': 'branch'},
#             '80000020': {'destination': 'park',
#                          'instr': '0040006F',
#                          'instr_name': 'J',
#                          'type': 'branch'}},
#  'atoi': {'80000600': {'destination': '',
#                        'instr': 'FD010113',
#                        'instr_name': 'ADDI',
#                        'type': 'entry'},
#           '80000634': {'destination': 'atoi+0x8c',
#                        'instr': '04F71C63',
#                        'instr_name': 'BNE',
#                        'type': 'branch'},
#           '8000064C': {'destination': 'atoi+0x8c',
#                        'instr': '0400006F',
#                        'instr_name': 'J',
#                        'type': 'branch'},
#           '80000694': {'destination': 'atoi+0x50',
#                        'instr': 'FA079EE3',
#                        'instr_name': 'BNEZ',
#                        'type': 'branch'},
#           '800006B8': {'destination': '',
#                        'instr': '00008067',
#                        'instr_name': 'RET',                        'type': 'branch'}},

branch_pseudoinstructions = [
    "beqz", # (branch if equal to zero)
    "bnez", # (branch if not equal to zero)
    "blez", # (branch if less than or equal to zero)
    "bgez", # (branch if greater than or equal to zero)
    "bltz", # (branch if less than zero)
    "bgtz", # (branch if greater than zero)
    "beq", # (branch if equal)
    "bne", # (branch if not equal)
    "ble", # (branch if less than or equal)
    "bge", # (branch if greater than or equal)
    "blt", # (branch if less than)
    "bgt", # (branch if greater than)
    "j", # (unconditional jump)
    "jr", # (jump register)
    "beqzu", "bneu", "bleu", "bgeu", "bltu", "bgtu", "beql", "bnel", "blel", "bgel", "bltl", "bgtl", "beqzal", "bnezal"
    ]

def bold(text): 
    return "\033[1m" + text + "\033[0m"

def parse_line(line):
    tokens = line.strip().split()
    assert len(tokens) > 2, 'Invalid line: ' + line
    pc = tokens[0].split(':')[0]
    instr = tokens[1]
    instr_name = tokens[2]
    is_function = False
    func_destination_name = ''
    is_branch = False
    branch_destination = ''
    if instr_name.lower() == 'jal' and re.match('^<([^>]+)>$', tokens[-1]):
        is_function = True
        func_destination_name = tokens[-1].strip('<>')
    elif instr_name.lower() in branch_pseudoinstructions:
        is_branch = True
        branch_destination = tokens[-1].strip('<>')
    return pc.upper(), instr.upper(), instr_name.upper(), is_function, func_destination_name, is_branch, branch_destination


def parse_objdump(f_name):
    with open(f_name) as f:
        data = f.read()

    text_section = re.search(
            r'Disassembly of section \.text:(.+?\n)Disassembly of section', 
            data, 
            re.MULTILINE | re.DOTALL
            ).group(1)

    funcs_sections = re.findall(
            r'[0-9a-fA-F]+\s<([^>]+)>:(.+?)\n\n', 
            text_section, 
            re.MULTILINE | re.DOTALL
            )
        
    funcs = {}

    ranges = {}
    ranges['total'] = [999999999999999, -1] # min, max starting values
    for name, body in funcs_sections:
        funcs[name] = {}
        # addresses = re.findall(r'\n\s+([0-9a-fA-F]+)', body, re.MULTILINE | re.DOTALL)

        ##re.findall(r'\n\s+([0-9a-fA-F]+):\s+([0-9a-fA-F]+)\s+([a-z.]+)([^\n<]+)?<?([^\n>]+)?', body, re.MULTILINE | re.DOTALL)
        # if not addresses: 
        #     print(sys.argv[0], f'didn\'t find any addresses for {name} function')
        #     continue

        lines = body.splitlines()[1:]
        for i, line in enumerate(lines):
            pc, instr, instr_name, is_function, func_destination_name, is_branch, branch_destination = parse_line(line.strip())
            if i != 0 and i != len(lines) - 1 and not is_function and not is_branch:
                continue
            funcs[name][pc] = {
                    'type' : '',
                    'instr_name' : instr_name,
                    'destination': '',
                    'instr': instr
                    }

            if i == 0:
                funcs[name][pc]['type'] = 'entry'
            elif i == len(lines) - 1:
                funcs[name][pc]['type'] = 'exit'

            if is_function:
                funcs[name][pc]['type'] = 'function'
                funcs[name][pc]['destination'] = func_destination_name
            elif is_branch:
                funcs[name][pc]['type'] = 'branch'
                funcs[name][pc]['destination'] = branch_destination
        # start = int(addresses[0], 16)
        # end = int(addresses[-1], 16)

        # while name in ranges:
        #     name = name + '_'
        # ranges[name] = [start, end]
        
        # if start < ranges['total'][0]: 
        #     ranges['total'][0] = start
        # if end > ranges['total'][1]: 
        #     ranges['total'][1] = end
    return funcs
    


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=(
        'Extracts memory locations of functions as '
        'outputted by "llvm-objdump -sSD binary_file_name".\n'
        'Output is stored in a json file, it can be used '
        'when plotting program counter traces obtained '
        'with: qtrace -u exec ./program'
        ))
    parser.add_argument(
            'file_name',
            type=argparse.FileType('r'),
            help='File containing output of llvm-objdump.'
            )
    parser.add_argument(
            '-o',
            type=str,
            required=False,
            metavar='',
            help='Output json file name.'
            )
    parser.add_argument(
            '--output-to-stdout',
            required=False,
            action='store_true',
            help='Outputs to stdout as well as the file.'
            )

    args = parser.parse_args()

    ranges = parse_objdump(args.file_name.name)

    if args.output_to_stdout:
        pprint(ranges)

    if args.o:
        out_fname = args.o if args.o.endswith('.json') else args.o + '.json'
    else:
        out_fname = os.path.basename(args.file_name.name).split('.')[0] + '_ranges.json'
    with open(out_fname, 'w') as f:
        json.dump(ranges, f, indent=4)

    print(sys.argv[0], 'outputted function ranges json to:', bold(out_fname))

