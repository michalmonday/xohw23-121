[pynq_wrapper.ipynb](../juptyer_notebooks/pynq_wrapper.ipynb) is the main file that controls the PYNQ board and communicates with the display board. It is long, and may be hart to read, this document describes its structure, main parts and functions.

The pynq_wrapper.ipynb notebook file is divided into 4 main parts with the following headings:
* Initialization and some auxiliary functions
* Configuration of CMS
* TCP server setup
* Main operation

These sections are described below.

## Initialization and some auxiliary functions
This part of the code is quite long. In summary, it loads the Overlay and initializes objects like:
* Bram_Loader - which contains `load('program.bin')` method
* Console_IO - which contains `send(string)` and `read()` methods
* ContinuousMonitoringSystemController - which contains various methods (e.g. to enable trace start/stop address or set traced address range)
* TCP_Server - which contains `.register_rpcs(rpc_functions)` method which sets functions that can be called by the display board (which controls CMS and displays its status)

The most relevant auxiliary functions are: 
* `reset_cpu()`
* `run_and_collect(stdin)`
* `get_dma_transfer(input_buffer)`
* `parse_input_buffer(input_buffer)`
* `parse_fifo_item(fifo_item)`
* `print_dma_channel_status(channel)`
* `print_fifo_data_counts()`

This section loads the CPU with the [ecg.bin](../programs/ECG/) program and sets the processor to inactive state:
```python
# set processor into reset state
gpio_rst_n_out.write(0)

# load the default program
bram_loader.load(PROGRAMS_DIR / 'ECG/ecg.bin')

print('Initialization done')
```

## Configuration of CMS
```python 
def setup_cms(cms_ctrl):
    # Triggerring (exact address must match to start/stop trace)
    cms_ctrl.set_trigger_trace_start_address(0x1000)
    cms_ctrl.set_trigger_trace_end_address(0x80000106)  
    cms_ctrl.set_trigger_trace_start_address_enabled(False)
    cms_ctrl.set_trigger_trace_end_address_enabled(False)

    # Filtering (any address between lower bound and upper bound will be collected)
    cms_ctrl.set_monitored_address_range_lower_bound(0x0FFF)     #(0x80000000)
    cms_ctrl.set_monitored_address_range_upper_bound(0x800000FF)
    cms_ctrl.set_monitored_address_range_lower_bound_enabled(False)
    cms_ctrl.set_monitored_address_range_upper_bound_enabled(False)
    
    # Allow further trace collection if last traced program used "wfi"
    # (wait for interrupt) instruction which stops the trace.
    cms_ctrl.reset_wfi_wait()
    cms_ctrl.set_tlast_interval(TLAST_INTERVAL)
    
    cms_ctrl.enable_halting_cpu()
    
    # Advanced trace filter (ATF) configuration
    cms_ctrl.reset_atf()
    
    # DIRECT MATCH ATF WATCHPOINTS (determining when data is collected):
    #cms_ctrl.set_atf_match_watchpoint(0, {'pc':0x8000076c})
    #cms_ctrl.set_atf_match_watchpoint(0, {'pc':0x80000760}) # ecg_baseline wait_ms
    #cms_ctrl.set_atf_match_watchpoint(0, {'pc':0x800008B0}) # ecg_baseline wait_ms_2
    cms_ctrl.set_atf_mode(ATF_MODE.ANOMALY_DETECTION) # alternative: ATF_MODE.PATTERN_COLLECTION
    cms_ctrl.enable_atf()
    
setup_cms(cms_ctrl)
```

## TCP server setup
This part defines remote procedure calls (rpc) that can be called by the display board (the control screen). All rpc functions start with "rpc_" prefix, currently these are:
* `rpc_list_programs()`
* `rpc_list_objdumps()`
* `rpc_get_objdump_data(category, name)`
* `rpc_load_program(name)`
* `rpc_run()`
* `rpc_halt()`
* `rpc_enable_training()`
* `rpc_disable_training()`
* `rpc_enable_testing()`
* `rpc_disable_testing()`
* `rpc_reset_dataset()`
* `rpc_set_atf_watchpoint(index, is_active, json_str_attributes_dict)`
* `rpc_atf_watchpoint_set_active(index, state)`

RPC calls are implemented using JSON based protocol, see [cms_program.cpp](../display_board/src/CMS/cms_program.cpp) (client) and [TCP_Server.py](../jupyter_notebooks/tcp_server.py) (server) for more details.

## Main operation
This part of the code starts a thread which allows the display board to control the PYNQ board to do things like:
* load a program
* run/halt a program
* set or toggle a trace filter watchpoint condition
* start/stop training
* start/stop testing
* receive data about the currently running program, data like:
    * performance (which decreases if the program is halted due to full internal trace buffer in programmable logic)
    * number of collected data items since receiving last update (it depends on how many times watchpoint condition was met)
    * average similarity to previously collected metrics (indicating whether or not the program behaviour is normal)

This also the part of the code where the `get_dma_transfer(input_buffer, dma_rec_channel)` is called to get the trace data from the RISC-V processor. The data is then parsed:  
```python
perf_counters, perf_counters_overflow_map, pc, clk_counter, instr, fifo_full_ticks_count, gp_regs = parse_fifo_item(fifo_item)
```

Depending on training enable state, the performance counters are supplied to the anomaly detection model:
```python
if mode & MODE.TRAINING:
    anomaly_detection.update_dataset(useful_perf_counters)
```

Depending on testing enable state, the maximum cosine similarity to previously collected data items may be stored (before being sent as an update to the display board):
```python
if mode & MODE.TESTING:
    similarity = anomaly_detection.get_max_cosine_similarity(useful_perf_counters)
    similarities.append(similarity)
```

