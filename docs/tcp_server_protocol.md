PYNQ runs a tcp server, allowing a client (e.g. ESP32 with a display) to connect and act as a controller of the PYNQ wrapper. It also acts as a way to display what PYNQ wrapper is doing, e.g. notify that abnormal behaviour is being detected.

Server and clients are connected through a socket, allowing unrestricted bidirectional communication, by unrestricted it is meant that both of them can send data at any time, without the need to request it first from one side first.

All messages between both sides are JSON strings, which are parsed and interpreted by the other side.

# Protocol requirements
Requirements below are formulated to help with the protocol implementation and to help with GUI design. Communication between the client and server is based mainly on remote procedure calls (RPC) from the client to the server.

### Client requirements
The client (Esp32) should be able to:
* send a RPC request to the server with function name and arguments
* request list of available programs from the server
* request to load a program into memory
* run, halt and resume a program
* set operational mode (enable/disable training and testing, allowing both to be disabled and enabled at the same time)
* reset anomaly detection model/dataset
* request status update upon restart of the Esp32 board (to restore GUI state)

<!-- * configure CMS, this includes:
    * enabling/disabling and setting the trace start address
    * enabling/disabling and setting the trace end address
    * enabling/disabling and setting the lower address boundary
    * enabling/disabling and setting the upper address boundary
    * enabling/disabling CPU halting (when internal trace storage is full) -->

<!-- :idea: The client may request objdump output of each file (or data based on it) to display it in the GUI. The user could select address range based on functions addresses. -->


### Server requirements
The server (PYNQ) should be able to:
* respond to RPC requests the name of the function and its return
* notify client of collected program metrics like:
    * number of collected datapoints
    * ratio of anomalous datapoints to normal datapoints
    * performance rate (allowing to see if and to what extent the program was slowed down due to full internal trace storage)
* notify client of tcp server being reseted


# Client to server - eample RPCs

### Client gets list of available programs from the server:
```json
{
    "RPC" : {
        "function_name": "rpc_list_programs"
    }
}
```
Servers response:
```json
{
    "RPC_return" : {
        "function_name": "rpc_list_programs",
        "return_value": {
            "ECG" : ["ecg_baseline.bin", "ecg_info_leak.bin"],
            "ANOTHER_CATEGORY" : ["another_program_baseline.bin", "another_program_anomalous_version.bin"]
        }, 
        "return_status": "success" // alternative would be "error"
    }
}
```

### Client requests to load a program into memory
```json
{
    "RPC" : {
        "function_name": "rpc_load_program",
        "function_args": ["ecg_baseline.bin"]
    }
}
```

Servers response:
```json
{
    "RPC_return" : {
        "function_name": "rpc_load_program",
        "return_value": "",
        "return_status": "success",
        "function_args": ["ecg_baseline.bin"]
    } 
}
```

# Client to server - list of RPCs
The client can call the following methods defined in pynq_wrapper.ipynb notebook file:
* rpc_list_programs()
* rpc_list_objdumps()
* rpc_get_objdump_data(category, objdump_fname)
* rpc_load_program(name)
* rpc_run()
* rpc_halt()
* rpc_enable_training()
* rpc_disable_training()
* rpc_enable_testing()
* rpc_disable_testing()
* rpc_reset_dataset()
* rpc_update_status()
* rpc_set_atf_watchpoint(index, is_active, json_str_attributes_dict)
* rpc_atf_watchpoint_set_active(index, state)

# Server to client
The server can update the client without being requested to do so. Currently it sends:
* current dataset size
* performance rate (1 if working as usual, lowered if CPU needs to halt due to full internal trace storage)
* average similarity of collected data to previously trained dataset
* the number of items collected
"add_points" directly inserts values into the Metrics graph shown on the display.

The following code is responsible for sending the update:

```python
    tcp_server.send_to_all(
        json.dumps({
            'status_update' : {
                'dataset_size' : anomaly_detection.get_dataset_size()
            }, 
            'add_points' : {
                'Perf' : [performance_rate],
                #'Anomaly ratio' : [number_of_anomalies / (items_since_last_send or 1)],
                'Avg sim' : [avg_sim],
                'Avg sim bot-1%' : [avg_sim_bot_1],
                'Items collected' : [items_since_last_send]
            }
        })
```

# Security considerations
The client shouldn't be able to execute any function on the server, the server needs to check if the requested RPC starts with "rpc" and only allow those to be executed.

