#ifndef RPC_ESP32_H
#define RPC_ESP32_H

#include <Arduino.h>

extern void rpc_no_args(String name);
extern void rpc(String function_name, const char * format, ...);

#endif