
# Using pynq 2.7.0 version, it is possible to set specific number of bytes to be sent when
# calling "dma.sendchannel.transfer" method. However, it isn't possible to set the number 
# of bytes to be received, because that is determined by the tlast (recvchannel.transfer method
# has "nbytes" parameter, but as mentioned in AXI DMA documentation, setting it below the number 
# of bytes received until "tlast" is asserted will result in undefined behaviour, and error 
# occurs if that happens).

# Documentation link: https://docs.xilinx.com/r/en-US/pg021_axi_dma/AXI-DMA-Register-Address-Map
# Section: S2MM_LENGTH (S2MM DMA Buffer Length Register – Offset 58h)
# Quote: "This value must be greater than or equal to the largest expected packet to be received
#         on S2MM AXI4-Stream. Values smaller than the received packet result in undefined behavior."

# For that reason the hardware implementation includes module that monitors AXI Lite interface responsible
# for controlling DMA (e.g. initiating transfers), and when it detects that a receive transfer is requested,
# it tells the console_io module to include a special "0xFF" byte in output buffer and set tlast HIGH as it is sent.
# This way we limit the number of sent characters to the ones that are currently in the buffer.
# As a resulting side-effect of this implementation, we can initiate transfer to check if any data is available.

from pynq import allocate
import numpy as np
import time

class Console_IO:
    """ This class controls AXI DMA to read and write data to buffers in FPGA.
    These buffers outside of the processor itself and are part of the PYNQ_wrapper_blocks.
    Currently these buffers are set to 1000 bytes each, so the contiguous buffers allocated with
    PYNQ, should have at least the same capacity (+1 for the special byte used for "tlast" setting). """
    def __init__(self, axi_dma, recv_buffer_capacity=1004, send_buffer_capacity=1004):
        self.axi_dma = axi_dma
        self.recvchannel = axi_dma.recvchannel
        self.sendchannel = axi_dma.sendchannel
        self.recv_buffer = allocate(shape=(recv_buffer_capacity,), dtype='u1')
        self.send_buffer = allocate(shape=(send_buffer_capacity,), dtype='u1')
        self.recv_str = ''
        self.send_buffer_capacity = send_buffer_capacity

    # deallocate buffers when this object is deleted
    def __delete__(self):
        del self.recv_buffer
        del self.send_buffer

    #####################################################################################
    # public methods

    def data_available(self):
        self.receive_transfer()
        return bool(self.recv_str)

    def read(self, blocking=False):
        if blocking:
            while not self.data_available():
                time.sleep(0.01)
            # else can be used because data_available called receive_transfer already
        else:
            self.receive_transfer()
        return_str = str(self.recv_str)
        self.recv_str = ''
        return return_str
    
    def send(self, string, wait=False, end_byte=None):
        # "encode" + "frombuffer" way is significantly slower (when tested on PYNQ with actual contiguous buffer)
        #self.send_buffer[:len(string)] = np.frombuffer(string.encode('utf-8'), dtype='u1')
        if end_byte is not None:
            string += chr(end_byte)
        if len(string) > self.send_buffer_capacity:
            raise Exception(f'string suppled to Console_IO.send method exceeds send_buffer_size ({len(string)} > {self.send_buffer_size})')
        for i, c in enumerate(string):
            self.send_buffer[i] = ord(c)
        self.sendchannel.transfer(self.send_buffer, nbytes=len(string))
        if wait:
            self.sendchannel.wait()

    # def send_bytes(self, bytes, wait=False):

    #####################################################################################
    # internal/private methods not to be really used outside of this class implementation

    def receive_transfer(self):
        ''' Always waiting by default because it is the wait() function that
        sets the "transferred" attribute indicating how many items were received. '''
        self.recvchannel.transfer(self.recv_buffer)
        self.recvchannel.wait()
        # 1 element is always the "0xFF" special used to set tlast after last item when transfer is requested
        if self.recvchannel.transferred > 1:
            self.recv_str += self.recv_buffer[:self.recvchannel.transferred-1].tobytes().decode('utf-8')
        
    
