''' Usage example:
from pynq import Overlay
from pynq import allocate
from continuous_monitoring_system_controller import ContinuousMonitoringSystemController
BASE_DIR = Path('/home/xilinx/design_files')
PATH = BASE_DIR 
base = Overlay(str(BASE_DIR / 'imported_design.bit'))
cms_ctrl = ContinuousMonitoringSystemController(base.axi_gpio_cms_ctrl)

# Triggerring (exact address must match to start/stop trace)
cms_ctrl.set_trigger_trace_start_address(0x80000000)
cms_ctrl.set_trigger_trace_end_address(0x800000C)
cms_ctrl.set_trigger_trace_start_address_enabled(True)
cms_ctrl.set_trigger_trace_end_address_enabled(True)

# Filtering (in example below any address between 0x80000000 and 0x8FFFFFFF will be collected)
cms_ctrl.set_monitored_address_range_lower_bound(0x80000000)
cms_ctrl.set_monitored_address_range_upper_bound(0x8FFFFFFF)
cms_ctrl.set_monitored_address_range_lower_bound_enabled(True)
cms_ctrl.set_monitored_address_range_upper_bound_enabled(True)
'''

# from advanced_trace_filter import create_seed_mask_and_range_for_values, calculate_atf_pkt_deterministic_offset, ATF_Mode, atf_pkt_deterministic_structure, bits_in_int
import advanced_trace_filter as atf

# print( create_seed_mask_and_range_for_values({'A0': 0x80000000, 'A1': 0x80000000, 'A2': 0x80000000, 'A3': 0x80000000}) )
# exit()

class ContinuousMonitoringSystemController:
    # Addresses match "continuous_monitoring_system.v" file. 
    ADDR_TRIGGER_TRACE_START_ADDRESS_ENABLED = 0
    ADDR_TRIGGER_TRACE_END_ADDRESS_ENABLED = 1
    ADDR_TRIGGER_TRACE_START_ADDRESS = 2
    ADDR_TRIGGER_TRACE_END_ADDRESS = 3
    ADDR_MONITORED_ADDRESS_RANGE_LOWER_BOUND_ENABLED = 4
    ADDR_MONITORED_ADDRESS_RANGE_UPPER_BOUND_ENABLED = 5
    ADDR_MONITORED_ADDRESS_RANGE_LOWER_BOUND = 6
    ADDR_MONITORED_ADDRESS_RANGE_UPPER_BOUND = 7
    ADDR_WFI_REACHED = 8
    ADDR_CLK_COUNTER = 9
    ADDR_LAST_WRITE_TIMESTAMP = 10
    ADDR_TLAST_INTERVAL = 11
    ADDR_HALTING_ON_FULL_FIFO_ENABLED = 12
    ADDR_ARBITRARY_HALT = 13
    ATF_SEED_INPUT = 14
    ATF_SEED_MASK_INPUT = 15
    ATF_SEED_ADDRESS = 16
    ATF_SEED_WRITE_ENABLE = 17
    ATF_LOWER_BOUND_INPUT = 18
    ATF_UPPER_BOUND_INPUT = 19
    ATF_RANGE_ADDRESS = 20
    ATF_RANGE_WRITE_ENABLE = 21
    ATF_ACTIVE = 22
    ATF_MODE = 23

    def __init__(self, axi_gpio):
        # self.axi_gpio = axi_gpio
        self.sr_data_input = axi_gpio[0:16]
        self.sr_shift_signal = axi_gpio[16]
        self.ctrl_addr = axi_gpio[17:25]
        self.ctrl_write_enable = axi_gpio[25]

    def set_ctrl_wdata(self, value):
        for i in reversed(range(4)):
            # shift bits signal = low
            self.sr_shift_signal.write(0)
            # write LSB first
            self.sr_data_input.write((value >> (i * 16)) & 0xFFFF)
            # shift signal = high (posedge activated)
            self.sr_shift_signal.write(1)

    def send_data_to_cms(self, data, address):
        ''' Single AXI GPIO block is used to interact with control inputs ("ctrl") of CMS module having 73 bits.
            For that reason a shift register is used. It has 16 bit data input and 1 shift signal (posedge activated), 
            and outputs 64 bits to "ctrl_wdata" of the CMS module. The AXI GPIO maps to:
                0-15  : shift register input bits (16 bits)
                16    : shift register shift signal
                17-24 : "ctrl_addr" of CMS module (8 bits)
                25    : "ctrl_write_enable" of CMS module
        '''
        # write enable = low
        self.ctrl_write_enable.write(0)
        # write address
        self.ctrl_addr.write(address)
        # send ctrl_wdata (64-bits) through shift register (16 bits at a time)
        # (send 4 * 16 bits, resulting in 64bit ctrl_wdata input of CMS module)
        self.set_ctrl_wdata(data)
        self.ctrl_write_enable.write(1)
        self.ctrl_write_enable.write(0)
    
    ###############################################
    # Trigger control functions (start/stop trace when certain program counter value is executed)
    def set_trigger_trace_start_address_enabled(self, enable=True):
        self.send_data_to_cms(enable, __class__.ADDR_TRIGGER_TRACE_START_ADDRESS_ENABLED)

    def set_trigger_trace_end_address_enabled(self, enable=True):
        self.send_data_to_cms(enable, __class__.ADDR_TRIGGER_TRACE_END_ADDRESS_ENABLED)

    def set_trigger_trace_start_address(self, value):
        self.send_data_to_cms(value, __class__.ADDR_TRIGGER_TRACE_START_ADDRESS)

    def set_trigger_trace_end_address(self, value):
        self.send_data_to_cms(value, __class__.ADDR_TRIGGER_TRACE_END_ADDRESS)

    ###############################################
    # Monitored address range functions (collect data only when program counter is in certain range)
    def set_monitored_address_range_lower_bound_enabled(self, enable=True):
        self.send_data_to_cms(enable, __class__.ADDR_MONITORED_ADDRESS_RANGE_LOWER_BOUND_ENABLED)

    def set_monitored_address_range_upper_bound_enabled(self, enable=True):
        self.send_data_to_cms(enable, __class__.ADDR_MONITORED_ADDRESS_RANGE_UPPER_BOUND_ENABLED)

    def set_monitored_address_range_lower_bound(self, value):
        self.send_data_to_cms(value, __class__.ADDR_MONITORED_ADDRESS_RANGE_LOWER_BOUND)

    def set_monitored_address_range_upper_bound(self, value):
        self.send_data_to_cms(value, __class__.ADDR_MONITORED_ADDRESS_RANGE_UPPER_BOUND)

    ###############################################
    # tlast interval 
    def set_tlast_interval(self, value):
        """Sets the number of extracted items after which the tlast will be asserted.
        Tlast ends AXI/DMA transfer. It should be set to the number of items that fit 
        into allocated contiguous memory (pynq.allocate). 
        
        Setting it to 0 will disable it. """
        self.send_data_to_cms(value, __class__.ADDR_TLAST_INTERVAL)

    ###############################################
    # if a program has "wait for interrupt" (wfi) instruction at the end, 
    # the cms will stop the trace. if we decide to run/trace another program
    # we may want to use this function, otherwise trace will not start.
    # (btw another way to reset the wfi wait is to load the overlay 'bit/hwh' again)
    def reset_wfi_wait(self):
        self.send_data_to_cms(0, __class__.ADDR_WFI_REACHED)

    def reset_clk_counter(self):
        self.send_data_to_cms(0, __class__.ADDR_CLK_COUNTER)
    
    def reset_last_write_timestamp(self):
        self.send_data_to_cms(0, __class__.ADDR_LAST_WRITE_TIMESTAMP)

    ###############################################
    # halting cpu when fifo (internal trace storage) is full 
    def enable_halting_cpu(self):
        self.send_data_to_cms(1, __class__.ADDR_HALTING_ON_FULL_FIFO_ENABLED)

    def disable_halting_cpu(self):
        ''' Disabling may be useful for checking that program works well in general
        by interacting with it through console I/O. This wouldn't be possible with 
        halting enabled unless we extract data very fast.'''
        self.send_data_to_cms(0, __class__.ADDR_HALTING_ON_FULL_FIFO_ENABLED)
    
    ###############################################
    # arbitrary halt
    def activate_arbitrary_halt(self):
        self.send_data_to_cms(1, __class__.ADDR_ARBITRARY_HALT)
    
    def deactivate_arbitrary_halt(self):
        ''' If halting cpu on full data storage is enabled, the CPU will
        remain halted if the storage is full. That's why it's called "deactivate" instead of "resume_cpu" '''
        self.send_data_to_cms(0, __class__.ADDR_ARBITRARY_HALT)

    ###############################################
    # Advanced trace filter (ATF) configuration

    # Main functions to be used as public
    def set_atf_mode(self, mode):
        ''' ATF_MODE.PATTERN_COLLECTION: atf_data_pkt_deterministic collection mode
                  (for recognizing infrequent patterns/events based on binary similarity to seed values)
                  (this is done for the sake of slowing down data collection to a reasonable rate that will
                   allow detecting anomalies in software and displaying collected metrics in real time on a display)
            ATF_MODE.ANOMALY_DETECTION: data_pkt collection mode
                  (for anomaly detection)
                  
        A typical workflow for using ATF modes:
        - set gpio_rst_n to 0 to set processor in inactive state
        - enable_aft()
        - setting pattern collection mode to collect data_pkt_deterministic values
        - calculate similarities to seed values and plot them with matplotlib
        - examine the plot and decide which similarity value ranges to use
        - set seeds and ranges using methods:
                set_atf_seed_input,
                set_atf_seed_address,
                set_atf_seed_trigger_write_enable,
                set_atf_lower_bound_input,
                set_atf_upper_bound_input,
                set_atf_range_address,
                set_atf_range_trigger_write_enable
        - set anomaly detection mode to collect data_pkt values
        - data for anomaly detection (counter values) should arrive in fifo at reasonable rates
        '''
        self.send_data_to_cms(mode, __class__.ATF_MODE)

    def set_atf_match_watchpoint(self, seed_address, values_dict):
        ''' takes one seed, the range is a number of positive bits in the mask 
        this way it results in direct match of values specified in values_dict. 

        Example use:
            values_dict = {'pc': 0x80000000, 'A0': 0x80000000, 'A1': 0x80000000, 'A2': 0x80000000, 'A3': 0x80000000}
            cms_ctrl.set_atf_match_watchpoint(seed_address=0, values_dict)
         '''
        seed, mask, range_ = atf.create_seed_mask_and_range_for_values(values_dict)
        self.set_atf_seed(seed, seed_address, mask=mask)
        self.set_atf_range(seed_address, range_address=0, lower_bound=range_, upper_bound=range_)
    
    def reset_atf_match_watchpoint(self, seed_address, num_of_ranges=8):
        self.set_atf_seed(0, seed_address, seed_bit_width=1024)
        for i in range(num_of_ranges):
            self.set_atf_range(seed_address, range_address=i, lower_bound=1023, upper_bound=0)

    def reset_atf(self, num_of_seeds=16, num_of_ranges=8):
        # makes all seeds and ranges inactive
        for i in range(num_of_seeds):
            self.set_atf_seed(0, i, seed_bit_width=1024)
            for j in range(num_of_ranges):
                self.set_atf_range(seed_address=i, range_address=j, lower_bound=1023, upper_bound=0)

    def set_atf_seed(self, seed_value, address, mask=None, seed_bit_width=1024):
        self.set_atf_seed_address(address)
        self.set_atf_seed_input(seed_value, mask=mask, seed_bit_width=seed_bit_width)
        self.set_atf_seed_trigger_write_enable()

    def set_atf_range(self, seed_address, range_address, lower_bound, upper_bound):
        self.set_atf_seed_address(seed_address)
        self.set_atf_lower_bound_input(lower_bound)
        self.set_atf_upper_bound_input(upper_bound)
        self.set_atf_range_address(range_address)
        self.set_atf_range_trigger_write_enable()

    def enable_atf(self):
        ''' advanced trace filter is disabled by default '''
        self.send_data_to_cms(1, __class__.ATF_ACTIVE)
    
    def disable_atf(self):
        self.send_data_to_cms(0, __class__.ATF_ACTIVE)

    # Internal functions
    def set_atf_seed_input(self, seed_value, mask=None, seed_bit_width=1024):
        ''' The seed value may be very long (e.g. 512 bits), the ctrl_wdata is only 64 bits wide,
        for that reason it must be supplied by writing multiple times to this address.  '''
        assert type(seed_value) != str, "Seed value must be an integer, not a string."
        assert seed_bit_width % 64 == 0, "Seed bit width must be a multiple of 64."
        # mask full of ones (full seed being used)
        if mask is None:
            mask = (1 << seed_bit_width) - 1
        # send MSB first
        first_i = None
        for i in reversed(range(0, seed_bit_width, 64)):
            if first_i is None: 
                first_i = i
            # send the MSB 64 bits of the seed value
            self.send_data_to_cms(seed_value >> first_i, __class__.ATF_SEED_INPUT)
            self.send_data_to_cms(mask >> first_i, __class__.ATF_SEED_MASK_INPUT)
            seed_value <<= 64
            mask <<= 64

    def set_atf_seed_address(self, address):
        ''' Address range depends on the number of maximum seeds allowed by ATF.
        It is a generic parameter of the ATF module (and possibly will be generic parameter
        of the cms_wrapper_ip). '''
        self.send_data_to_cms(address, __class__.ATF_SEED_ADDRESS)

    def set_atf_seed_trigger_write_enable(self):
        ''' The write enable signal gets automatically cleared on the next clock cycle
        after this function action is applied.  '''
        self.send_data_to_cms(1, __class__.ATF_SEED_WRITE_ENABLE)

    def set_atf_lower_bound_input(self, lower_bound):
        self.send_data_to_cms(lower_bound, __class__.ATF_LOWER_BOUND_INPUT)
    
    def set_atf_upper_bound_input(self, upper_bound):
        self.send_data_to_cms(upper_bound, __class__.ATF_UPPER_BOUND_INPUT)
    
    def set_atf_range_address(self, address):
        ''' A single seed may be associated with multiple address ranges. '''
        self.send_data_to_cms(address, __class__.ATF_RANGE_ADDRESS)

    def set_atf_range_trigger_write_enable(self):
        ''' The write enable signal gets automatically cleared on the next clock cycle
        after this function action is applied.  '''
        self.send_data_to_cms(1, __class__.ATF_RANGE_WRITE_ENABLE)
