# the following lines were executed in the jupyter notebook after allocating the buffer
# (to compare the speed of looping over each character vs using numpy.frombuffer)
import numpy as np
def speed_test_1(string, n):
    for i in range(n):
        input_buffer_console_send[:len(string)] = np.frombuffer(string.encode('utf-8'), dtype='u1')

def speed_test_2(string, n):
    for i in range(n):
        for j, c in enumerate(string):
            input_buffer_console_send[j] = c

string = 'ab'*1000
n = 1000

start_time = time.time()
speed_test_1(string, n)
print(f'{time.time() - start_time}s')

start_time = time.time()
speed_test_1(string, n)
print(f'{time.time() - start_time}s')