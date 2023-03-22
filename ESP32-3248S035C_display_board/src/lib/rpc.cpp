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
    String *msg = new String(json_str);
    if (msg == nullptr) {
        Serial.println("Failed to allocate memory for RPC message");
    }
    add_string_to_queue(queue_to_send, msg, true);
    free(json_str);
    cJSON_Delete(root);
}

// rpc with variable number of arguments, arguments must be char *
void rpc(String function_name, const char * format, ...) {
    va_list args;
    va_start(args, format);
    cJSON *root = cJSON_CreateObject();
    cJSON *rpc_obj = cJSON_CreateObject();
    cJSON_AddItemToObject(root, "RPC", rpc_obj);
    cJSON_AddStringToObject(rpc_obj, "function_name", function_name.c_str());
    cJSON *args_obj = cJSON_CreateArray();
    // parse char * arguments only
    // bool any_argument_was_added = false;
    // while (true) {
    //     char *arg = va_arg(args, char *);
    //     if (arg == NULL) {
    //         break;
    //     }
    //     any_argument_was_added = true;
    //     cJSON_AddStringToObject(args_obj, "arg", arg);
    // }
    // parse any type of arguments depending on format string (just like printf)
    // parse format string
    int i = 0;
    while (format[i] != '\0') {
        if (format[i] == '%') {
            i++;
            continue;
        }
        if (format[i] == 's') {
            char *arg = va_arg(args, char *);
            cJSON_AddStringToObject(args_obj, "arg", arg);
        } else if (format[i] == 'd') {
            int arg = va_arg(args, int);
            cJSON_AddNumberToObject(args_obj, "arg", arg);
        } else if (format[i] == 'f') {
            float arg = va_arg(args, double);
            cJSON_AddNumberToObject(args_obj, "arg", arg);
        } else if (format[i] == 'l') {
            long long arg = va_arg(args, long long);
            cJSON_AddNumberToObject(args_obj, "arg", arg);
        } else if (format[i] == 'c') {
            char arg = va_arg(args, int);
            cJSON_AddNumberToObject(args_obj, "arg", arg);
        } else if (format[i] == 'b') {
            bool arg = va_arg(args, int);
            cJSON_AddBoolToObject(args_obj, "arg", arg);
        } else {
            Serial.printf("rpc: unknown format specifier: %c\n", format[i]);
        }
        i++;
    }
    va_end(args);
    cJSON_AddItemToObject(rpc_obj, "function_args", args_obj);
    // if (any_argument_was_added) {
    //     cJSON_AddItemToObject(rpc_obj, "args", args_obj);
    // } else {
    //   cJSON_Delete(args_obj);
    // }
    char *json_str = cJSON_PrintUnformatted(root);
    Serial.print("Sending: '");
    Serial.println(json_str);
    String *msg = new String(json_str);
    if (msg == nullptr) {
        Serial.println("Failed to allocate memory for RPC message");
    }
    add_string_to_queue(queue_to_send, msg, true);
    free(json_str);
    cJSON_Delete(root);
}




