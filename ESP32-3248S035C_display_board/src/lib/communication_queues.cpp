#include <communication_queues.h>

QueueHandle_t queue_received = NULL;
QueueHandle_t queue_to_send = NULL;

void communication_queues_init() {
    // producer (loop) allocates the string, consumer (drawing_thread_func) dealocates it
    // queue = xQueueCreate(1000, sizeof(String*));
    queue_received = xQueueCreate(5, sizeof(String*));
    queue_to_send = xQueueCreate(100, sizeof(String*));
}

bool add_string_to_queue(QueueHandle_t &queue, String *str, bool blocking) {
    if (blocking) {
        while (xQueueSend(queue, &str, 0) == errQUEUE_FULL) {
            // Serial.println("Queue is full, waiting...");
            vTaskDelay(100 / portTICK_PERIOD_MS);
        }
        return true;
    }
    return xQueueSendToBack(queue, &str, 0) != errQUEUE_FULL;
}