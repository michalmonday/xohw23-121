#!py -3

'''
After using Vivado block design, creating a HDL wrapper for it,
and generating bitstream, this script can be used to move the 
"_wrapper.bit" and ".hwh" files to pynq.

Tested on Windows only.
'''
import shutil
import sys
import argparse
import os

# pynq_ip = '192.168.3.1'
pynq_ip = '192.168.2.99'

parser = argparse.ArgumentParser(description='Copies Vivado generated .bit and .hwh into pynq.')
parser.add_argument(
    'name',
    metavar='file_name_without_wrapper_and_bit',
    type=str,
    help='Name of the file to copy (without "_wrapper.bit").'
    )
parser.add_argument(
    '--ip',
    help='Pynq board IP',
    default=pynq_ip,
    required=False,
    type=str
    )
args = parser.parse_args()

name = args.name
pynq_dir = f"\\\\{args.ip}\\xilinx\\design_files\\"
dir_ = os.path.dirname(os.path.realpath(__file__))
dir_name = os.path.basename(dir_)

src_bit = os.path.join(dir_, f'{dir_name}.runs', 'impl_1', f'{name}_wrapper.bit')
src_hwh = os.path.join(dir_, f'{dir_name}.srcs', 'sources_1', 'bd', name, 'hw_handoff', f'{name}.hwh')

# copy to board
shutil.copyfile(
    src_bit,
    pynq_dir + f'{name}.bit'
    )
shutil.copyfile(
    src_hwh,
    pynq_dir + f'{name}.hwh'
    )

# copy to local dir
shutil.copyfile(
    src_bit,
    f'./{name}.bit'
    )
shutil.copyfile(
    src_hwh, 
    f'./{name}.hwh'
    )

