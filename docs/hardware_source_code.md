As shown in the [vivado_block_design.md](./vivado_block_design.md) document, Xilinx IP modules contitute a large part of the project. This document lists the modules written by us to facilitate the project, and the modules that were provided by Xilinx.

### Contents of the `vivado_files/src_verilog` directory:
|  |  |
| ----------- | ----------- |
| continuous_monitoring_system_src | Source code of the continuous monitoring system module. |
| custom_hdl | Other hadrware modules source code. |
| RV64ACDFIMSUxCHERI | Source code of the RISC-V processor in it's compiled form (original source code is written in Bluespec Verilog). These files were not created by us. |
| src_bsc_lib_RTL | Source code provided from the Bluespec compiler (used by the RISC-V processor). These files were not created by us. |

### Key source files from the `vivado_files/src_verilog/custom_hdl` directory:
|  |  |
| ----------- | ----------- |
| axi_dma_receive_transfer_tap.v | Module acting like a proxy between AXI Lite source/destination, recognizing the "dma_receive_channel.transfer()" request and the requested size. |
| console_io_dma.v | This module is responsible for intermediate storage and interfacing between RISC-V console input/output and the Python script (using AXI DMA). |
| console_io.v | This module is currently unused, it did the same as console_io_dma.v but uses AXI GPIO instead which was much slower. |
| digital_input_sequencer.v | Module responsible for driving external shift register to get 16 digital sensors inputs. |
| extension_bram.v | Module responsible for intermediate storage of analog and digital sensor values. The values it holds are updated periodically and can be read from RISC-V programs at any time (in other words this module is memory mapped). |
| utils_rom.v | Module that implements counters and random number generator, accessible from RISC-V programs. |

### Key source files from the `vivado_files/src_verilog/continuous_monitoring_system_src` directory:

|  |  |
| ----------- | ----------- |
| advanced_trace_filter.sv | Watchpoint-based trace filtering implementation. |
| cms_ip_wrapper.v | Verilog wrapper for the continuous_monitoring_system.sv SystemVerilog module (because Vivado doesn't allow SystemVerilog modules to be included directly into block design). |
| continuous_monitoring_system.sv | The top-level module (aside of the cms_ip_wrapper.v). |
| continuous_monitoring_system_pkg.sv | Commonly used declarations. |
| data_to_axi_stream.v | This module reads the tready signal and outputs tdata, tlast and tvalid signals used by the AXI protocol (it is useful when for sending data to AXI DMA module). |
| performance_event_counters.sv | Module that counts how many times performance events occured. |
| pos_bit_count.sv | Module that counts how many positive bits there are in a binary value (it was useful for the implementation of the watchpoint-based trace filtering).  |
| shadow_general_purpose_registers_file.sv | Storage of general purpose registers (GPR) given the write port of original GPR write port signals (data, address, write enable). |
| trace_filter.sv | Basic trace filter (collecting data on jumps, branches and returns). |

