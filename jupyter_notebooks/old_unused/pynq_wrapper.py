from IPython.core.debugger import set_trace
import os, subprocess, sys, re, time
from pathlib import Path
from pynq import Overlay
#from pynq import GPIO
from pynq import allocate
import math
import pandas as pd
import inspect
import logging
import random
import json
logger = logging.getLogger()
#logger.setLevel(logging.INFO)
logger.setLevel(logging.DEBUG)

from threading import Thread
import matplotlib.pyplot as plt

# BENCHMARK_TOOL_DIR = Path('/home/xilinx/benchmark_files/scripts/')
# sys.path.append(str(BENCHMARK_TOOL_DIR))
# import compare_classification_methods_2 as benchmark_ccm

PROGRAMS_DIR = Path('/home/xilinx/programs')
BASE_DIR = Path('/home/xilinx/design_files')
OUTPUT_DIR = Path('/home/xilinx/output_files')
if not os.path.exists(OUTPUT_DIR):
    os.mkdir(OUTPUT_DIR)

from dma_receiver import DmaReceiver
from bram_loader import Bram_Loader
from continuous_monitoring_system_controller import ContinuousMonitoringSystemController, ATF_MODE
from riscv_instruction_decoder import get_riscv_instruction_name
from tcp_server import TCP_Server, get_my_ip
from console_io import Console_IO
import advanced_trace_filter
from anomaly_detection import Anomaly_Detection

PERFORMANCE_EVENTS_FNAME = 'performance_event_names_selected.csv'
with open(PERFORMANCE_EVENTS_FNAME) as f:    
    PERFORMANCE_EVENTS_COUNT = len(f.readlines()) - 1
print(PERFORMANCE_EVENTS_COUNT)
PERFORMANCE_COUNTER_WIDTH = 7
PERFORMANCE_COUNTERS_OVERFLOW_MAP_WIDTH = PERFORMANCE_EVENTS_COUNT
PC_WIDTH = 64
INSTR_WIDTH = 32
CLK_COUNTER_WIDTH = 64
FIFO_FULL_TICKS_COUNT_WIDTH = 64
GP_REGISTER_WIDTH = 128
AXI_DATA_WIDTH = 1024
USED_AXI_BITS = 39*7+39+64+64+32+4*64
CLK_SPEED = 50_000_000

INPUT_BUFFER_DTYPE_SIZE_IN_BYTES = 8
#FIFO_SIZE = 32768
# +4 because DMA seems to have it's own buffer it fills before dma.recvchannel.transfer is even called
#buffer_length = min( base.PYNQ_wrapper_blocks.continuous_monitoring_system_blocks.axi_dma_0.buffer_max_size // ITEM_BYTE_SIZE, FIFO_SIZE)# + 4) 
#buffer_length = 4_000_000 // 8 # 4MB in total
#buffer_length = 16_000_000 // 8 # 16MB in total
#buffer_length = 10240*10 // 8 

# input buffer has "u8" dtype which has 8 bytes per element
# 16 elements are needed to store a single 1024-bit item from FIFO
# variable below can be used to know location of the end of transferred data in the input buffer
# so we can copy it and initiate another transfer
INPUT_BUFFER_LOCATIONS_PER_ITEM = AXI_DATA_WIDTH / 8 / INPUT_BUFFER_DTYPE_SIZE_IN_BYTES

# theoretically with 16MB allocated and 1024-bit items we could set TLAST_INTERVAL to 125000
#TLAST_INTERVAL = BUFFER_ITEM_CAPACITY - 5000
TLAST_INTERVAL = 0 # axilite_tap based tlast (setting tlast when receive transfer is requested)

TCP_SERVER_PORT = 9093
# tcp server for communicating with display (e.g. ESP3248S035C, but really any TCP client that connects)
tcp_server = TCP_Server(host_ip='0.0.0.0', port=TCP_SERVER_PORT)

base = Overlay(str(BASE_DIR / 'imported_design.bit'))

bram_loader = Bram_Loader(base.PYNQ_wrapper_blocks.bram_loader.axi_gpio_2)
console_io = Console_IO(
    base.PYNQ_wrapper_blocks.console_io.axi_dma_console_io,
    recv_buffer_capacity=10000,
    send_buffer_capacity=10000
    )

# the long name is because of using hierarchy in Vivado block design
cms_ctrl_axi_gpio = base.PYNQ_wrapper_blocks.continuous_monitoring_system_blocks.axi_gpio_to_cms_ctrl_interface.axi_gpio_cms_ctrl.channel1    
cms_ctrl = ContinuousMonitoringSystemController(cms_ctrl_axi_gpio)

buffer_length = 50_000_000 // INPUT_BUFFER_DTYPE_SIZE_IN_BYTES # 50MB in total
print('buffer_length =', buffer_length)
# how many items from AXI can be stored in PYNQ allocated buffer
BUFFER_ITEM_CAPACITY = buffer_length // AXI_DATA_WIDTH * 8 # bytes / bits * bits_per_byte

input_buffer = allocate(shape=(buffer_length,), dtype='u8')
# input_buffer_2 = allocate(shape=(buffer_length,), dtype='u8')

dma_rec = base.PYNQ_wrapper_blocks.continuous_monitoring_system_blocks.axi_dma_0.recvchannel

# https://pynq.readthedocs.io/en/v2.7.0/_modules/pynq/lib/axigpio.html
gpio_rst_n_out = base.PYNQ_wrapper_blocks.axi_gpio_0.channel1[0]
gpio_rst_n_console_input = base.PYNQ_wrapper_blocks.axi_gpio_0.channel1[1]
gpio_rst_n_console_output = base.PYNQ_wrapper_blocks.axi_gpio_0.channel1[2]
#gpio_en_cpu_reset_server_request_put_out = base.axi_gpio_0.channel1[1]
#gpio_pc_stream_m_axis_tlast_interval = base.axi_gpio_1.channel1

gpio_fifo_wr_count = base.PYNQ_wrapper_blocks.axi_gpio_0.channel2[0:16]
gpio_fifo_rd_count = base.PYNQ_wrapper_blocks.axi_gpio_0.channel2[16:32]

def print_dma_channel_status(channel):
    print('dma.running =', channel.running)
    print('dma.idle =', channel.idle)
    print('dma.error =', channel.error)
    print('status =', hex(channel._mmio.read(channel._offset + 4)))
    
def reset_cpu(delay=0.001):
    ''' AXI GPIO controlled reset, active-low. '''
    #gpio_en_cpu_reset_server_request_put_out.write(0)
    gpio_rst_n_out.write(0)
    time.sleep(delay)
    gpio_rst_n_out.write(1)
    time.sleep(delay)
    #gpio_en_cpu_reset_server_request_put_out.write(1)
    #time.sleep(delay)
    #gpio_en_cpu_reset_server_request_put_out.write(0)
    #time.sleep(delay)
    
def print_fifo_data_counts():
    print('gpio_fifo_wr_count =', gpio_fifo_wr_count.read())
    print('gpio_fifo_rd_count =', gpio_fifo_rd_count.read())
    
def instr_to_strings(instructions_integers):
    ''' Requires riscv-python-model installed.
    If network connection is available, "python3 -m pip install riscv-model.
    If not, then on separate machine with internet:
        python3 -m pip download riscv-model -d .  
    Then copy the downloaded .whl file to pynq and install with:
        python3 -m pip install <file.whl> -f ./ --no-index   
    Usage:
        instr_to_string([0xB60006F, 0xFE0791E3])
        '''
    instructions_string = ' 0x'.join(f'{ii:08X}' for ii in instructions_integers)
    return os.popen(f'riscv-machinsn-decode hexstring {instructions_string}').read().strip().split('\n')


####################################################################
# 

def read_performance_event_names(f_name):
    ''' Reads events names from file, these were collected from CHERI-Flute source code by using this script:
    https://github.com/michalmonday/Flute/blob/continuous_monitoring/builds/RV64ACDFIMSUxCHERI_Flute_verilator/vcd/read_vcd.py
    '''
    with open(f_name) as f:
        return [line.strip().split(',')[2] for line in f.readlines()[1:]]

def pop_n_bits_value(val, n):
    ''' pop_n_bits_value(0xFFFF, 4) returns tuple like: (0xFFF, 0xF) '''
    bits_value = val & ((1<<n)-1)
    return val >> n, bits_value

def parse_fifo_item(fifo_item):
    ''' Parses a single fifo item (e.g. 1024 bits) numerical value. 
        Single fifo item = {59bits padding, performance_counters805(7bits*115counters), instr32, clk_counter_delta64, pc64}
        Padding is used because only power of 2s can be used as size in fifo generator block (or axi in general?)'''
    perf_counters = []
    for i in range(PERFORMANCE_EVENTS_COUNT):
        fifo_item, perf_counter = pop_n_bits_value(fifo_item, PERFORMANCE_COUNTER_WIDTH)
        perf_counters.append(perf_counter)
    fifo_item, perf_counters_overflow_map = pop_n_bits_value(fifo_item, PERFORMANCE_COUNTERS_OVERFLOW_MAP_WIDTH)
    fifo_item, pc = pop_n_bits_value(fifo_item, PC_WIDTH)
    fifo_item, clk_counter = pop_n_bits_value(fifo_item, CLK_COUNTER_WIDTH)
    fifo_item, instr = pop_n_bits_value(fifo_item, INSTR_WIDTH)
    fifo_item, fifo_full_ticks_count = pop_n_bits_value(fifo_item, FIFO_FULL_TICKS_COUNT_WIDTH)
    fifo_item, gp_reg_A0 = pop_n_bits_value(fifo_item, 64)
    fifo_item, gp_reg_A1 = pop_n_bits_value(fifo_item, 64)
    fifo_item, gp_reg_A2 = pop_n_bits_value(fifo_item, 64)
    fifo_item, gp_reg_A3 = pop_n_bits_value(fifo_item, 64)
    gp_regs = {'A0':gp_reg_A0, 'A1':gp_reg_A1, 'A2':gp_reg_A2, 'A3':gp_reg_A3}
    
    return perf_counters, perf_counters_overflow_map, pc, clk_counter, instr, fifo_full_ticks_count, gp_regs

def get_dma_transfer(input_buffer, dma_rec=dma_rec, dont_wait=False):
    ''' Returns the number of transferred items, each having 512 bits. '''
    dma_rec.transfer(input_buffer)
    if dont_wait:
        return
    dma_rec.wait() # depends on tlast
    items_transferred = math.floor(dma_rec.transferred * 64 / AXI_DATA_WIDTH / 8)
    return items_transferred

def parse_input_buffer(input_buffer, items_transferred, dont_decode=False):
    pcs = []
    instrs = []
    instr_names = []
    clk_counters = []
    events = []
    events_overflows = []
    fifo_full_ticks_counts = []
    all_gp_regs = {}
    chunks_per_item = math.ceil(AXI_DATA_WIDTH/64)
    start = 0
    end = chunks_per_item
    time_checkpoint = time.time()
    for i in range(items_transferred):
        if i != 0:
            start += chunks_per_item
            end += chunks_per_item
        time_checkpoint = time.time()
        fifo_item = int.from_bytes(bytes(input_buffer[start:end]), byteorder='little')
        print(f'{time.time() - time_checkpoint}s')
        perf_counters, perf_counters_overflow_map, pc, clk_counter, instr, fifo_full_ticks_count, gp_regs = parse_fifo_item(fifo_item)
        events.append(perf_counters)
        events_overflows.append(perf_counters_overflow_map)
        pcs.append(pc)
        clk_counters.append(clk_counter)
        instrs.append(instr)
        fifo_full_ticks_counts.append(fifo_full_ticks_count)
        
        if not all_gp_regs:
            all_gp_regs = {key:[] for key in gp_regs.keys()}

        for key, reg_list in gp_regs.items():
            all_gp_regs[key].append( reg_list )
        
        instr_names.append( get_riscv_instruction_name(instr) )
    if dont_decode:
        instr_strings = ['-'] * len(instrs)
    else:
        instr_strings = instr_to_strings(instrs)
    return events, events_overflows, pcs, clk_counters, instrs, instr_names, instr_strings, fifo_full_ticks_counts, all_gp_regs

input_buffer_all_transfers_copied = []
def collect_program_data(input_buffer, dont_decode=False, dont_wait=False, dont_parse=False, copy_collected=False, execution_time_limit=None):
    global dma_rec, input_buffer_all_transfers_copied, BUFFER_ITEM_CAPACITY
    
    if (execution_time_limit is not None) and dont_parse:
        raise Exception("Execution time can't be checked without parsing received data")
    
    all_events, all_events_overflows, all_pcs, all_clk_counters, all_instrs = [],[],[],[],[] 
    all_instr_names, all_instr_strings, all_fifo_full_ticks_counts = [],[],[]
    all_gp_regs = {}
    i = 0
    total_items = 0
    input_buffer_all_transfers_copied = []
    
    total_execution_clocks = 0
    while True:
        # transfer all collected data
        print(f'Initiating DMA transfer i={i}')
        items_transferred = get_dma_transfer(input_buffer, dma_rec)#, dont_wait=True)        
        i += 1
        
        total_items += items_transferred
        if dont_parse:
            print(f'Transfer {i} finished (not parsing), items_transferred={items_transferred}.')
            if copy_collected:
                print(f'Copying buffer to input_buffer_all_transfers_copied')
                
                input_buffer_all_transfers_copied.append( input_buffer[:int(BUFFER_ITEM_CAPACITY * INPUT_BUFFER_LOCATIONS_PER_ITEM+1)].copy() )
                print(f'Buffer was copied')
            
            # TODO: FIX, THIS IS GOING TO CAUSE PROBLEMS
            if (items_transferred) != TLAST_INTERVAL:
                print(f'All DMA transfers completed (no parsing), total_items={total_items}. It is assumed that all transfers completed because items_transferred ({items_transferred}) != TLAST_INTERVAL ({TLAST_INTERVAL}).')
                return None
            continue 
            
        print(f'Transfer {i} finished, items_transferred={items_transferred}, parsing...')
        # parse received data and turn it into pandas DataFrame
        events, events_overflows, pcs, clk_counters, instrs, instr_names, instr_strings, fifo_full_ticks_counts, gp_regs = parse_input_buffer(input_buffer, items_transferred, dont_decode=dont_decode)
        all_events.extend( events )
        all_events_overflows.extend( events_overflows )
        all_pcs.extend( pcs )
        all_clk_counters.extend( clk_counters )
        all_instrs.extend( instrs )
        all_instr_names.extend( instr_names )
        all_instr_strings.extend( instr_strings )
        all_fifo_full_ticks_counts.extend( fifo_full_ticks_counts )
        

        total_execution_clocks += sum(clk_counters[1:]) - sum(fifo_full_ticks_counts[1:])
        
        if not all_gp_regs:
            all_gp_regs = {key:[] for key in gp_regs.keys()}
            
        for key, reg_list in gp_regs.items():
            all_gp_regs[key].extend( reg_list )

        if instr_names[-1].lower() == 'wfi':
            break
            
        execution_time_ms = (total_execution_clocks / CLK_SPEED * 1000)
        if execution_time_limit < execution_time_ms:
            print(f'Execution time limit ({execution_time_limit}ms) was reached, tracing is stopped. (execution time={execution_time_ms}ms)')
            break
        print(f'execution_time_ms = {execution_time_ms}')
            
    print(f'All DMA transfers completed, total_items={total_items}, converting lists to dataframe...')
    df = pd.DataFrame(
        zip(all_pcs,all_clk_counters,all_instrs,all_instr_names,all_instr_strings,all_fifo_full_ticks_counts), 
        columns=['pc','clk_counter','instr', 'instr_names', 'instr_strings', 'fifo_full_ticks_counts']
    )    
    #set_trace()
    df = df.join( pd.DataFrame(all_gp_regs) )
    
    df['pc'] = df['pc'].apply(lambda x: f'{x:8X}')
    df['instr'] = df['instr'].apply(lambda x: f'{x:08X}')
    df_events = pd.DataFrame(all_events, columns=event_names)
    df = pd.concat([df, df_events], axis=1)
    print('Dataframe is ready')
    return df


def run_and_collect(stdin, input_buffer=input_buffer, dont_decode=False, dont_parse=False, copy_collected=False, execution_time_limit=None):
    ''' dont_decode=True saves time (otherwise instruction assembly string is created from hex instruction value) '''
    # set CPU into inactive state (active-low reset is set LOW)
    gpio_rst_n_out.write(0)
    # activate continous_monitoring_system in case if it's stopped by previously 
    # encountered "wait for interrupt" (WFI) instruction
    cms_ctrl.reset_wfi_wait()
    # send standard input into a buffer, this way it will be ready
    # immediately after CPU starts running the program
    console_io.send(stdin, end_byte=ord('\n')) # '\n' is hardcoded here specifically for "stack-mission.c" program
    reset_cpu()
    df = collect_program_data(input_buffer, dont_decode=dont_decode, dont_wait=False, dont_parse=dont_parse, copy_collected=copy_collected, execution_time_limit=execution_time_limit)
    stdout = console_io.read()
    return df, stdout
    
def get_performance_stats(df, clk_speed=50_000_000):
    halted_time = df['fifo_full_ticks_counts'][1:].sum() / clk_speed
    normal_run_time = df['clk_counter'][1:].sum() / clk_speed - halted_time
    performance_decrease = 100.0 - normal_run_time / (normal_run_time + halted_time) * 100
    return halted_time, normal_run_time, performance_decrease

def print_performance_stats(df):
    halted_time, normal_run_time, performance_decrease = get_performance_stats(df)
    print(f'normal_run_time = {normal_run_time}s')
    print(f'halted_time = {halted_time}s')
    print(f'performance_decrease = {performance_decrease}%')
    
def send_sensors_data_to_all_tcp_clients(df_sensors, sensors_to_send):
    msg_to_server = ''
    for i in range(df_sensors.shape[0]):
        for col in sensors_to_send: #df_sensors.columns:
            val = float(df_sensors[col].iloc[i]) / 60000.0
            msg_to_server += f'add_point:{col},{val}\n'
    #print(msg_to_server)
    tcp_server.send_to_all(msg_to_server) 
    
    