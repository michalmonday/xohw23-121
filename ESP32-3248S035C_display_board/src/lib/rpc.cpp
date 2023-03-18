#include <rpc.h>
#include <communication_queues.h>
#include <cJSON.h>

void rpc_no_args(String function_name) { 
    // function name is a function from PYNQ, like "rpc_list_programs"
    cJSON *root = cJSON_CreateObject();
    cJSON *rpc_obj = cJSON_CreateObject();
    cJSON_AddItemToObject(root, "RPC", rpc_obj);
    cJSON_AddStringToObject(rpc_obj, "function_name", function_name.c_str());
    char *json_str = cJSON_PrintUnformatted(root);
    Serial.print("Sending: '");
    Serial.println(json_str);
    add_string_to_queue(queue_to_send, new String(json_str), true);
    free(json_str);
}




