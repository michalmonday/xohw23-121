def console_send(s, end_byte=None):
    ''' Uses AXI GPIO and hardware FIFOs. '''
    console_input = base.PYNQ_wrapper_blocks.axi_gpio_3.channel1[0:8]
    console_write_enable = base.PYNQ_wrapper_blocks.axi_gpio_3.channel1[8] # using "edge_detector" to avoid continuous writing
    console_write_enable.off()
    for c in s:
        console_input.write(ord(c))
        console_write_enable.on()
        console_write_enable.off()
    if end_byte is not None:
        console_input.write(end_byte)
        console_write_enable.on()
        console_write_enable.off()
    
def console_data_available():
    console_output_empty = base.PYNQ_wrapper_blocks.axi_gpio_3.channel2[8]
    return console_output_empty.read() == 0

def console_read(blocking=False):
    ''' Uses AXI GPIO and hardware FIFOs. '''
    s = ''
    console_output = base.PYNQ_wrapper_blocks.axi_gpio_3.channel2[0:8]
    console_read_enable = base.PYNQ_wrapper_blocks.axi_gpio_3.channel1[9] # using "edge_detector" to avoid continuous reading
    if blocking:
        while not console_data_available():
            time.sleep(0.001)
    while console_data_available():
        console_read_enable.off()
        console_read_enable.on()
        s += chr(console_output.read())
    return s