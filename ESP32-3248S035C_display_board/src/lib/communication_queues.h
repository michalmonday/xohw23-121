#ifndef COMMUNICATION_QUEUES_H
#define COMMUNICATION_QUEUES_H

#include <Arduino.h>

extern void communication_queues_init();
extern bool add_string_to_queue(QueueHandle_t &queue, String *str, bool blocking=false);

extern QueueHandle_t queue_received;
extern QueueHandle_t queue_to_send;

#endif