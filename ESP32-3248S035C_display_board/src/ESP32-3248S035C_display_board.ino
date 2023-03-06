
#include <TFT_eSPI.h> // Hardware-specific library (requires "User_Setup.h" to be replaced with the one for specific display)
#include <SPI.h>
#include <WiFi.h>
#include <map>
#include <cJSON.h>
#include <TAMC_GT911.h>

// #include "drawing.h"
#include "colours.h"
#include "line_plot.h"
#include "graph.h"
#include "status_display.h"

#include "display_config.h" // resolution

// Wifi credentials file contains 2 lines:
// #ifndef MICHAL_WIFI_CREDENTIALS_H
// #define MICHAL_WIFI_CREDENTIALS_H
//    #define ACCESS_POINT_SSID "my_ssid"
//    #define ACCESS_POINT_PASSWORD "my_password"
// #endif
//
// It is added to .gitignore file, this way it's not shared
#include "michal_wifi_credentials.h"


// Serial is temporarily added to this file until I get 2nd display that
// will be dedicated to getting data from RISC-V program and displaying it.
// Until then, this display will show ECG data, and also use as controller/displayer
// of the continuous monitoring system.
#include <HardwareSerial.h>
HardwareSerial serial_riscv(2);  // UART2 (GPIO17=TX, GPIO16=RX)

// Thread used for drawing will be on separate thread from receiving/parsing data from tcp server
TaskHandle_t drawing_thread;
QueueHandle_t queue = NULL;

const IPAddress server_ip(192, 168, 0, 104);
const uint16_t server_port = 9093;
const String server_ip_str = "192.168.0.104:" + String(server_port); // just for displaying status
WiFiClient client;

// display object
TFT_eSPI tft = TFT_eSPI(); 

#define TOUCH_SDA  33
#define TOUCH_SCL  32
#define TOUCH_INT 36
#define TOUCH_RST 25
#define TOUCH_WIDTH  480
#define TOUCH_HEIGHT 320
TAMC_GT911 *touch; 

// status display is a GUI component that covers bottom of the screen and can display status messages like "Connecting to WiFi"
StatusDisplay status_display(tft, RESOLUTION_X, (int)(0.1 * RESOLUTION_Y), 0, (0.9*RESOLUTION_Y), TFT_WHITE, TFT_BLACK);

int current_colour_id = 0;

// graph without parameters will have default values (to cover most of the screen with space for status display)
// see graph.cpp to see or change default values
Graph graph(tft); 
// Graph graph(graph_x, graph_y, graph_w, graph_h);

double xlo = 0;
// double xhi = 25; // this is pretty much setting how many values we want to display in the graph at once
double xhi = 100; // this is pretty much setting how many values we want to display in the graph at once

double ylo = 0; // line plot lower value bound
double yhi = 1; // line plot upper value bound
int max_number_of_items = min((int)(xhi - xlo), (int)graph.get_width());

void init_wifi() {
    tft.setTextColor(WHITE);
    //tft.setTextSize(2);
    status_display.set_status("ap_connection_status", "Connecting to '" + String(ACCESS_POINT_SSID) + "' WiFi access point...");
    status_display.set_status("tcp_connection_status", "ZYNQ TCP server address is set to: " + server_ip_str);

    WiFi.mode(WIFI_STA);
    WiFi.setSleep(false);
    WiFi.begin(ACCESS_POINT_SSID, ACCESS_POINT_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
        status_display.set_status("ap_connection_status", "Retrying connection...");
    }

    Serial.println("Connected");
    Serial.print("IP Address:");
    Serial.println(WiFi.localIP());
    status_display.set_status("ap_connection_status", "Connected to '" + String(ACCESS_POINT_SSID) + "' WiFi access point (assigned IP: " + WiFi.localIP().toString() + ")");
}

// LinePlot* create_new_line_plot() {
//     unsigned int clr = colours[current_colour_id];
//     current_colour_id = (current_colour_id + 1) % (sizeof(colours) / sizeof(colours[0]));
//     Serial.printf("current_colour_id=%d\n", current_colour_id);
//     return new LinePlot(tft, xlo, xhi, ylo, yhi, clr, max_number_of_items);
// }



void drawing_thread_func(void *parameter) {
    while (true) {
        String* line;
        // Serial.printf("Queue size: %d, free space: %d, max size: %d\n", uxQueueMessagesWaiting(queue), uxQueueSpacesAvailable(queue), uxQueueMessagesWaiting(queue) + uxQueueSpacesAvailable(queue));
        while (uxQueueMessagesWaiting(queue) == 0) {
            delay(1);
        }
        if ( xQueueReceive(queue, &line, portMAX_DELAY) ) {
            // Serial.printf("Drawing thread: received '%s'\n", (*line).c_str());
            check_protocol(*line);
            delete line;
        }
    }
}

void init_display() {
    tft.begin();
    tft.fillScreen(BLACK);
    // tft.setRotation(1); // landscape
    tft.setRotation(3); // landscape, upside downh
}

void setup() {
    touch = new TAMC_GT911(TOUCH_SDA, TOUCH_SCL, TOUCH_INT, TOUCH_RST, TOUCH_WIDTH, TOUCH_HEIGHT);
    touch->reset();
    touch->begin();
    touch->setRotation(ROTATION_LEFT);
    delay(100);

    Serial.begin(115200);
    Serial.println();
    serial_riscv.begin(115200);
    init_display();
    init_wifi();

    static bool redraw_on_first_call_only_graph = true;
    delay(1000);

    graph.draw(
        2,                // decimal point precision for axis tick labels
        xlo,              // lower bound of axis x  (used to set x axis tick labels)
        xhi,              // upper bound of axis x  (used to set x axis tick labels)
        ylo,              // lower bound of axis y  (used to set y axis tick labels)
        yhi,              // upper bound of axis y  (used to set y axis tick labels)
        "title",          // title
        "x label",        // x label
        "y label",        // y label
        DKBLUE,           // grid color
        RED,              // axis color
        WHITE,            // text color
        BLACK             // background color
        );

    // producer (loop) allocates the string, consumer (drawing_thread_func) dealocates it
    // queue = xQueueCreate(1000, sizeof(String*));
    queue = xQueueCreate(5, sizeof(String*));
	xTaskCreatePinnedToCore(
			drawing_thread_func, /* Function to implement the task */
			"drawing_thread", /* Name of the task */
			10000, /* Stack size in words */
			NULL, /* Task input parameter */
			0, /* Priority of the task */
			&drawing_thread, /* Task handle. */
			(xPortGetCoreID() & 1) ^ 1); /* Core where the task should run, Esp32 has 2 cores, using XOR the chosen core is the opposite of the current one. */
}

void swap(char &a, char &b) {
    char t = a;
    a = b;
    b = t;
}

bool add_string_to_queue(String *str) {
    if (xQueueSendToBack(queue, &str, 0) == errQUEUE_FULL) {
        // Serial.println("Queue is full, ignoring...");
        return false;
    }
    // while (xQueueSend(queue, &str, 0) == errQUEUE_FULL) {
    //     Serial.println("Queue is full, waiting...");
    //     vTaskDelay(1000 / portTICK_PERIOD_MS);
    // }
    return true;
}

bool contains_digits_only(String str) {
    for (int i = 0; i < str.length(); i++) {
        if (!isdigit(str[i])) {
            return false;
        }
    }
    return true;
}

void handle_riscv_serial() {
    while (serial_riscv.available()) {
        // Serial.println("Received something from riscv");
        String line = serial_riscv.readStringUntil('\n');
        // Serial.print("Received from riscv: '");
        // Serial.print(line);
        // Serial.println("'");

        if (!contains_digits_only(line)) {
            Serial.println(line);
            Serial.println("Not a number");
            continue;
        }

        float ecg_value = atof(line.c_str()) / 60000.0f;
        // Serial.print("ecg_value=");
        // Serial.println(ecg_value);

        if (ecg_value < 0.0 || ecg_value > 1.0) {
            Serial.println(line);
            Serial.print("ecg_value=");
            Serial.println(ecg_value);
            continue;
        } 

        String *formatted_msg = new String("add_point:ECG," + String(ecg_value));
        // Serial.print("Sending to drawing thread: '");
        // Serial.println(*formatted_msg);
        if (!add_string_to_queue(formatted_msg)) {
            delete formatted_msg;
        }
    }
}

//void check_protocol(String line) {
//    // line is a string received from the ZC706 tcp server (currently using PYNQ)
//    if (line.startsWith("create_plot")) {
//        char plot_name[20];
//        sscanf(line.c_str(), "create_plot:%s", plot_name);
//        LinePlot *line_plot = new LinePlot(tft, xlo, xhi, ylo, yhi, CYAN, max_number_of_items);
//        if (graph.add_plot(String(plot_name), line_plot)) {
//            client.write("OK");
//        } else {
//            client.write("ERROR: Plot already exists.");
//        }
//    }
//
//    if (line.startsWith("add_point")) {
//        char plot_name[20];
//        double value;
//        sscanf(line.c_str(), "add_point:%[^,],%lf", plot_name, &value);
//        LinePlot* line_plot = graph.get_plot(plot_name);
//        if (!line_plot) {
//            Serial.printf("add_point was used but plot %s does not exist. Creating it now.\n", plot_name);
//            line_plot = graph.add_plot(String(plot_name), create_new_line_plot());
//
//        }
//        line_plot->draw(BLACK);
//        line_plot->add_point(value);
//        line_plot->draw();
//    }
//}

void check_protocol(String line) {
    cJSON *root = cJSON_Parse(line.c_str());
    // Parse the following json string:
    // '{"ECG": ["ecg_info_leak.bin", "ecg_baseline.bin"], "ANOTHER": ["another0.bin", "another1.bin"]}'
    if (root == NULL) {
        Serial.println("Failed to parse json");
        return;
    }
    // check if ECG is present

    if (cJSON_HasObjectItem(root, "programs")) {
        cJSON *programs = cJSON_GetObjectItem(root, "programs");
        cJSON *program_category = programs->child;
        while(program_category) {
            Serial.println(program_category->string);
            for (int i=0; i<cJSON_GetArraySize(program_category); i++) {
                cJSON *program = cJSON_GetArrayItem(program_category, i);
                Serial.print("Program: ");
                Serial.println(program->valuestring);
            }
            program_category = program_category->next;
        }
    }

    if (cJSON_HasObjectItem(root, "status_update")) {
        cJSON *status_update = cJSON_GetObjectItem(root, "status_update");
        // Print response
        Serial.print("Status update: ");
        Serial.println(status_update->valuestring);
    }

    cJSON_Delete(root);
}

void handle_touch() {
    touch->read();
    if (touch->isTouched){
        Serial.printf("Touch: x=%d, y=%d\n", touch->points[0].x, touch->points[0].y);
        // for (int i=0; i<touch->touches; i++){
        //     Serial.print("Touch ");Serial.print(i+1);Serial.print(": ");;
        //     Serial.print("  x: ");Serial.print(touch->points[i].x);
        //     Serial.print("  y: ");Serial.print(touch->points[i].y);
        //     Serial.print("  size: ");Serial.println(touch->points[i].size);
        //     Serial.println(' ');
        // }
    }
}

void loop(void) {
    handle_riscv_serial();
    handle_touch();
    static bool redraw_on_first_call_only_trace4 = true;

    Serial.println("Attempt to access server...");
    // status_display.set_status("tcp_connection_status", "Connecting to ZC706 TCP server (" + server_ip_str + ")");
    if (!client.connect(server_ip, server_port)) {
        Serial.println("Access failed.");
        client.stop();
        for (int i=5; i>0; i--) {
            handle_riscv_serial();
            handle_touch();
            // status_display.set_status("tcp_connection_status", "Retrying ZC706 TCP server (" + server_ip_str + ") connection in " + String(i) + " seconds...");
            delay(1000);
        }
        return;
    }
    // status_display.set_status("tcp_connection_status", "Connected to ZC706 TCP server ("+  server_ip_str + ")");

    Serial.println("Access successful.");
    client.println("list_programs");
    client.println("run_program,ecg_baseline.bin");

    // client.print("run_program:ecg_baseline.bin");
    while (client.connected() || client.available()) {
        handle_riscv_serial();
        handle_touch();

        while (client.available()) {
            // String *line = new String(client.readStringUntil('\n'));
            String line = client.readStringUntil('\n');
            // String line = client.readString(); // readString has a timeout that would make it inefficient (readStringUntil does not have it when using '\n')
            Serial.print("Received: '");
            Serial.print(line);
            Serial.println("'");
            check_protocol(line);
        }
    }
    Serial.println("Closing connection.");
    client.stop();
}
