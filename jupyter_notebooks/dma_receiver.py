from queue import Queue
from threading import Thread, Lock
import re
import time
from pynq import allocate


class DmaReceiver:
    delays = 0.0001
    def __init__(self, dma, items_limit=10000, buffer_count=2, allocate_args=[], allocate_kwargs={'shape':(16,), 'dtype':'u8'}):
        ''' Dma receiver will not read more data while items_limit is reached. 
            items_limit limits the self.out_data. '''
        self.dma = dma
        self.buffer_count = buffer_count
        
        # item_size = the number of bytes in a single FIFO item
        self.item_size = int( re.search('\d+$', allocate_kwargs.get('dtype') ).group(0) ) 
        
        # input buffers
        self.ibs = [allocate(*allocate_args, **allocate_kwargs) for _ in range(buffer_count)]

        # Non-empty queue indicate that particular input buffer transferred data which 
        # wasn't copied yet. Queues are used because they're thread safe and provide blocking "get" method
        self.ib_queues = [Queue() for _ in range(buffer_count)]
        
        self.rec_len_queue = Queue()
        self.recv_thread = Thread(target=self.recv_thread, daemon=True)
        self.copying_thread = Thread(target=self.copying_thread, daemon=True)
        
        self.items_limit = items_limit
        self.out_data_lock = Lock()
        self.out_data = []
    
        self.recv_thread.start()
        self.copying_thread.start()

    def recv_thread(self):
        dma_rec = self.dma.recvchannel
        active_ib = 0
        while True:
            ib = self.ibs[active_ib]
            ib_queue = self.ib_queues[active_ib]
            active_ib += 1
            active_ib %= self.buffer_count
            
            # if input buffer was used previously and received data wasn't copied to "self.out_data"
            # then wait until that happens before issuing another transfer
            while not ib_queue.empty():
                time.sleep(delays)
            self.wait_until_under_storage_limit()
            dma_rec.transfer(ib)
            dma_rec.wait()
            bytes_count = self.get_last_recv_length()
            ib_queue.put(1) # make queue non-empty, indicating the data it received wasn't copied yet
            self.rec_len_queue.put(bytes_count)
    
    def copying_thread(self):
        active_ib = 0
        while True:
            ib = self.ibs[active_ib]
            ib_queue = self.ib_queues[active_ib]
            active_ib += 1
            active_ib %= self.buffer_count
            bytes_count = self.rec_len_queue.get(block=True) # blocking until recv_thread receives data 
            items_count = bytes_count // self.item_size
            # print(f'bytes_count={bytes_count}')
            data = list(ib[0:items_count]) # make a copy of data
            # with self.out_data_lock:
            #     self.out_data.extend(ib[:bytes_count].tolist())
            #print('ib slice type is =',type(ib[:2]))
            ib_queue.get(block=True) # allow another transfer for the same input buffer
            with self.out_data_lock:
                self.out_data.extend(data)                      
                # if len(self.out_data) >= self.items_limit:
                #     print(f'Storage limit reached (out_data length={len(self.out_data)})')

        
    def get_last_recv_length(self):
        # dma = base.axi_dma_0
        # 0x58 is the address of S2MM_length as shown in the table from:
        # https://docs.xilinx.com/r/en-US/pg021_axi_dma/AXI-DMA-Register-Address-Map
        # return self.dma.mmio.read(0x58) // self.item_size
        return self.dma.recvchannel.transferred
    
    def available(self):
        with self.out_data_lock:
            return len(self.out_data) != 0
        
    def get(self, wait_until_available=True):
        if wait_until_available:
            while not self.available():
                time.sleep(delays)
        with self.out_data_lock:
            data = list(self.out_data)
            self.out_data = []
            return data

    def storage_limit_reached(self):
        with self.out_data_lock:
            out_data_len = len(self.out_data)
        return out_data_len >= self.items_limit

    def wait_until_under_storage_limit(self):
        while self.storage_limit_reached():
            time.sleep(delays) # this delay allows other threads to use the lock to update self.out_data








