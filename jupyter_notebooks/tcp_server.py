import socket
import threading
import time
import queue
import random
import json
from pathlib import Path

SEND_TO_ALL = -1


# Each directory within PROGRAMS_DIR will contain a group of programs
# each group of programs will have a baseline program and a set of variations
# that are anomalous in some way. 
PROGRAMS_DIR = Path('/home/xilinx/programs')

def get_my_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    ip = s.getsockname()[0]
    s.close()
    return ip

#Client class, new instance created for each connected client
#Each instance has the socket and address that is associated with items
#Along with an assigned ID and a name chosen by the client
class Client(threading.Thread):
    def __init__(self, socket, address, id_, tcp_server_received_queue, tcp_server_connections_lock, tcp_server_connections):
        threading.Thread.__init__(self)
        self.socket = socket
        self.address = address
        self.id = id_
        self.tcp_server_received_queue = tcp_server_received_queue
        self.tcp_server_connections_lock = tcp_server_connections_lock
        self.tcp_server_connections = tcp_server_connections
    
    def __str__(self):
        return str(self.id) + " " + str(self.address)
    
    #Attempt to get data from client
    #If unable to, assume client has disconnected and remove him from server data
    #If able to and we get data back, print it in the server and send it back to every
    #client aside from the client that has sent it
    #.decode is used to convert the byte data into a printable string
    def run(self):
        while True:
            try:
                data = self.socket.recv(4096)
                # 2 lines below are just for testing
                msgs = [msg for msg in data.decode("utf-8").splitlines() if msg]
                # to_send_queue.put((self.id, data_str))
                for msg in msgs:
                    self.tcp_server_received_queue.put((self.id, msg))
            except:
                print("Client " + str(self.address) + " has disconnected")
                self.signal = False
                with self.tcp_server_connections_lock:
                    del self.tcp_server_connections[self.id]
                break

            # if data != "":
            #     print("ID " + str(self.id) + ": " + str(data.decode("utf-8")))
            #     # echo
            #     self.socket.send('test\n'.encode('utf-8'))

                # for client in connections:
                #     if client.id != self.id:
                #         # client.socket.sendall(data)
                #         print("Sending to " + str(client))
                #         client.socket.sendall('test\n'.encode('utf-8'))
                #         print("Sent to " + str(client))

class TCP_Server:
    ''' TCP Server that can be used to send/receive data from multiple clients.
        It spawns 3 threads:
         - listen_worker: listens for new connections and creates a new Client object for each one
         - send_worker: sends data to clients (from the to_send_queue)
         - respond_worker: receives data from clients and responds to them '''
    def __init__(self, host_ip='0.0.0.0', port=9092):
        self.host_ip = host_ip
        self.port = port
        self.connections = {} # key=client_id, value=Client object
        self.connections_lock = threading.Lock()
        # received information may be used to set/configure the CMS, or trigger any actions
        # normally done by the jupyter notebook script (e.g. load program, run, set training mode,
        # set testing/detection mode)
        # Maybe it will be able to get a list of available programs (all files in dir) and select one.
        self.received_queue = queue.Queue()
        self.to_send_queue = queue.Queue()
        self.end_queue = queue.Queue()
        self.total_connections = 0

        #Create new server socket
        listen_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        listen_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        listen_sock.bind((host_ip, port))
        listen_sock.listen(2)
        self.listen_thread = threading.Thread(target=self.listen_worker, args=(listen_sock,), daemon=True)
        self.send_thread = threading.Thread(target=self.send_worker, daemon=True)

        self.protocol = {} # key = received_message, value = function to call that returns a string response message and/or does some action
        self.rpcs = {} # key=func name, value=func
        # respond_thread checks if received messages match protocol and responds accordingly
        self.respond_thread = threading.Thread(target=self.respond_worker, daemon=True)
        
    def start(self):
        self.respond_thread.start()
        self.send_thread.start()
        self.listen_thread.start()


    def register_protocol_message(self, received_message, response_function, received_message_format=''):
        '''Registering a protocol message means that when the server receives specified message,
        it will call the response_function (which must return a string response message). Response 
        message should probably be a json string to make parsing easier. Registered functions
        must take care of locking/unlocking data structures that are used in other threads. '''
        if not isinstance(received_message, str):
            raise Exception('received_message must be a string')
        if not callable(response_function):
            raise Exception('response_function must be a function')
        if received_message in self.protocol:
            print(f'received_message ("{received_message}") was already registered, overwriting it.')
        self.protocol[received_message] = response_function
    
    def register_rpcs(self, rpcs):
        for rpc in rpcs:
            if rpc.__name__ in self.rpcs:
                print(f'rpc name ("{rpc.__name__}") was already registered, overwriting it.')
            self.rpcs[rpc.__name__] = rpc

    def data_available(self):
        return not self.received_queue.empty()

    def read_data(self):
        ''' returns a list of tuples, where each tuple is (client_id, data_str) '''
        if self.received_queue.empty():
            return []
        received_data_list = []
        while not self.received_queue.empty():
            received_data_list.append(self.received_queue.get())
        return received_data_list

    def send_to_all(self, data):
        if not data.endswith('\n'):
            data += '\n'
        self.to_send_queue.put({'client_id': SEND_TO_ALL, 'data': data})

    def send_to_client(self, client_id, data):
        if not data.endswith('\n'):
            data += '\n'
        self.to_send_queue.put({'client_id': client_id, 'data': data})

    def send(self, data):
        self.send_to_all(data)

    def send_worker(self):
        while True:
            if not self.to_send_queue.empty():
                d = self.to_send_queue.get()
                client_id = d['client_id']
                data = d['data'].encode('utf-8')
                with self.connections_lock: 
                    if client_id == SEND_TO_ALL:
                        for client in self.connections.values():
                            client.socket.send(data)
                    else:
                        self.connections[client_id].socket.send(data)
            time.sleep(0.01)

    #Wait for new connections
    def listen_worker(self, listen_socket):
        total_connections = 0
        while True:
            client_sock, address = listen_socket.accept()
            client = Client(
                client_sock,
                address,
                id_=total_connections,
                tcp_server_received_queue=self.received_queue,
                tcp_server_connections_lock=self.connections_lock,
                tcp_server_connections=self.connections
                )
            print("New connection at ID " + str(client))
            with self.connections_lock:
                self.connections[total_connections] = client
            client.start()
            total_connections += 1

    def is_request_rpc(self, data):
        return 'RPC' in data and "function_name" in data['RPC']
    

    def respond_worker(self):
        while True:
            if not self.data_available():
                time.sleep(0.01)
                continue
            for client_id, data_str in self.read_data(): 
                print(f'client_id={client_id}, data_str={data_str}')
                try:
                    data = json.loads(data_str)
                except Exception as e:
                    print(f'Error parsing json: {e}')
                    continue
                
                if self.is_request_rpc(data):
                    func_name = data['RPC']['function_name']
                    if func_name not in self.rpcs:
                        print(f'Error: RPC function_name "{func_name}" was not registered')
                        continue
                    args = [] if 'function_args' not in data['RPC'] else data['RPC']['function_args']
                    print(f'Calling {func_name} with args={args}')
                    try:
                        rpc_ret = self.rpcs[func_name](*args)
                        return_status = 'success'
                    except Exception as e:
                        rpc_ret = ''
                        return_status = 'error'
                        print(f'Error calling {func_name}: {e}')
                        continue
                    response = json.dumps({
                        'RPC_return': {
                            'function_name': func_name,
                            'return_value': (rpc_ret if rpc_ret else ''),
                            'return_status': return_status
                            }
                        })
                    self.send_to_client(client_id, response)

                # if any(data_str.startswith(s) for s in self.protocol):
                #     tokens = data_str.split(',')
                #     func = self.protocol[tokens[0]]
                #     protocol_entry = tokens[0]
                #     print(f'Calling {func} for the "{protocol_entry}" with args={tokens[1:]}')
                #     response = self.protocol[protocol_entry](*tokens[1:])
                #     print(f'response={response}')
                #     self.send_to_client(client_id, response)
    
    def end(self):
        self.end_queue.put(True)

if __name__ == '__main__':
    tcp_server = TCP_Server(host_ip='192.168.0.105', port=9092)

    while True:
        # if tcp_server.data_available():
        #     for client_id, data_str in tcp_server.read_data():
        #         print(f'client_id={client_id}, data_str={data_str}')
        #         # random float between 0 and 1
        #         tcp_server.send_to_client(client_id, f'add_point:test,{random.uniform(0,1)}\n')
        # time.sleep(0.01)

        tcp_server.send_to_all(f'add_point:test,{random.uniform(0.7,0.9)}\n' + f'add_point:test2,{random.uniform(0.2,0.4)}\n')
        # tcp_server.send_to_all(f'add_point:test2,{random.uniform(0.2,0.4)}\n')
        time.sleep(0.3)

    