
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