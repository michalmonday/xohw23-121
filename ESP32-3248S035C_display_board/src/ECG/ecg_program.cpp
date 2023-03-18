
#include <TFT_eSPI.h> // Hardware-specific library (requires "User_Setup.h" to be replaced with the one for specific display)
#include <SPI.h>
#include <WiFi.h>
#include <map>
#include <cJSON.h>

// #include "drawing.h"
#include <colours.h>
#include <line_plot.h>
#include <gui.h>
#include <gui_graph.h>
#include <gui_button.h>
#include <gui_label.h>
#include <rpc.h>
#include "gui_ecg.h"
#include "gui_state_main.h"
#include "gui_ecg_states.h"
#include <communication_queues.h>

#include <display_config.h> // resolution

#include <touch.h>
Touch touch;

// Serial is temporarily added to this file until I get 2nd display that
// will be dedicated to getting data from RISC-V program and displaying it.
// Until then, this display will show ECG data, and also use as controller/displayer
// of the continuous monitoring system.
#include <HardwareSerial.h>
HardwareSerial serial_riscv(2);  // UART2 (GPIO17=TX, GPIO16=RX)

// Thread used for drawing will be on separate thread from receiving/parsing data from tcp server
TaskHandle_t drawing_thread;

// display object
TFT_eSPI tft = TFT_eSPI(); 

int current_colour_id = 0;

GUI_ECG *gui;
GUI_State_Main *gui_main_state;

double xlo = 0;
// double xhi = 25; // this is pretty much setting how many values we want to display in the graph at once
// double xhi = 100; // this is pretty much setting how many values we want to display in the graph at once
double xhi = RESOLUTION_X*0.2; // this is pretty much setting how many values we want to display in the graph at once
double ylo = 0; // line plot lower value bound
double yhi = 1; // line plot upper value bound
// int max_number_of_items = min((int)(xhi - xlo), (int)graph.get_width());
int max_number_of_items = xhi - xlo;

void handle_gui() {
    // status_display.update();
    gui->update();
    gui->draw();
}

void parse_tcp_message(String line);

LinePlot* create_new_line_plot(int clr=-1) {
    if (clr == -1) {
        clr = colours[current_colour_id];
        current_colour_id = (current_colour_id + 1) % (sizeof(colours) / sizeof(colours[0]));
        Serial.printf("current_colour_id=%d\n", current_colour_id);
    }
    return new LinePlot(tft, xlo, xhi, ylo, yhi, clr, max_number_of_items);
}

void drawing_thread_func(void *parameter) {
    gui->schedule_redraw_current_state(); // TODO: investigate why it's needed (otherwise main state is not fully drawn at the beginning, only status labels at the bottom are drawn)
    while (true) {
        String* line;
        // Serial.printf("Queue size: %d, free space: %d, max size: %d\n", uxQueueMessagesWaiting(queue), uxQueueSpacesAvailable(queue), uxQueueMessagesWaiting(queue) + uxQueueSpacesAvailable(queue));
        while (uxQueueMessagesWaiting(queue_received) == 0) {
            delay(1);
            handle_gui();
        }
        if ( xQueueReceive(queue_received, &line, portMAX_DELAY) ) {
            // Serial.printf("Drawing thread: received '%s'\n", (*line).c_str());
            // check_protocol(*line);
            parse_tcp_message(*line);
            delete line;
        }
        handle_gui();
    }
}

void init_display() {
    tft.begin();
    tft.fillScreen(BLACK);
    // tft.setRotation(1); // landscape
    tft.setRotation(3); // landscape, upside downh
}

void setup() {
    Serial.begin(115200);
    Serial.println();

    communication_queues_init();

    gui = new GUI_ECG(tft, &touch);
    gui_main_state = static_cast<GUI_State_Main*>(gui->get_state(GUI_STATE_MAIN));
    // gui->add_element(&ecg_graph, GUI_STATE_MAIN);
    // gui->add_element(label_ap_conn_status, GUI_STATE_MAIN);
    // gui->add_element(label_tcp_conn_status, GUI_STATE_MAIN);

    delay(100);

    serial_riscv.begin(115200);
    init_display();

    delay(1000);

    
    // ecg_graph.draw(
    //     2,                // decimal point precision for axis tick labels
    //     xlo,              // lower bound of axis x  (used to set x axis tick labels)
    //     xhi,              // upper bound of axis x  (used to set x axis tick labels)
    //     ylo,              // lower bound of axis y  (used to set y axis tick labels)
    //     yhi,              // upper bound of axis y  (used to set y axis tick labels)
    //     "title",          // title
    //     "x label",        // x label
    //     "y label",        // y label
    //     DKBLUE,           // grid color
    //     RED,              // axis color
    //     WHITE,            // text color
    //     BLACK             // background color
    //     );

	xTaskCreatePinnedToCore(
			drawing_thread_func, /* Function to implement the task */
			"drawing_thread", /* Name of the task */
			20000, /* Stack size in words */
			NULL, /* Task input parameter */
			0, /* Priority of the task */
			&drawing_thread, /* Task handle. */
			(xPortGetCoreID() & 1) ^ 1); /* Core where the task should run, Esp32 has 2 cores, using XOR the chosen core is the opposite of the current one. */

    // GUI_Button *btn = new GUI_Button(&tft, "Hello", RESOLUTION_X*0.5, RESOLUTION_Y*0.1, RESOLUTION_X * 0.3, RESOLUTION_Y * 0.7, BLACK,
    //      [](){Serial.println("Hello button was pressed");},
    //      [](){Serial.println("Hello button was released");}
    // );
    // gui->add_element(btn, GUI_STATE_MAIN);

    // GUI_Button *btn2 = new GUI_Button(&tft, "Second", RESOLUTION_X*0.1, RESOLUTION_Y*0.1, RESOLUTION_X * 0.8, RESOLUTION_Y * 0.8);
    // gui->add_element(btn2, GUI_STATE_SECOND);
}

void swap(char &a, char &b) {
    char t = a;
    a = b;
    b = t;
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
    // print free memory
    if (serial_riscv.available()) {
        // Serial.println("Received something from riscv");
        String line = serial_riscv.readStringUntil('\n');
        // Serial.print("Received from riscv: '");
        // Serial.print(line);
        // Serial.println("'");

        if (!contains_digits_only(line)) {
            if (line.equals("Leads off")) {
                gui_main_state->set_electrodes_status(false);
                return;
            }
            Serial.println(line);
            Serial.println("Not a number");
            return;
        }

        float ecg_value = atof(line.c_str()) / 60000.0f;

        if (ecg_value < 0.0 || ecg_value > 1.0) {
            Serial.println(line);
            Serial.print("ecg_value=");
            Serial.println(ecg_value);
            return;
        } 
        gui_main_state->set_electrodes_status(true);

        String *formatted_msg = new String("{\"add_points_risc_v\": {\"ECG\": [" + String(ecg_value) + "]}}");

        if (!add_string_to_queue(queue_received, formatted_msg)) {
            delete formatted_msg;
        }
    }
}

// void check_protocol(String line) {
//     // line is a string received from the ZC706 tcp server (currently using PYNQ)
// 
// //    if (line.startsWith("create_plot")) {
// //        char plot_name[20];
// //        sscanf(line.c_str(), "create_plot:%s", plot_name);
// //        LinePlot *line_plot = new LinePlot(tft, xlo, xhi, ylo, yhi, CYAN, max_number_of_items);
// //        if (ecg_graph.add_plot(String(plot_name), line_plot)) {
// //            client.write("OK");
// //        } else {
// //            client.write("ERROR: Plot already exists.");
// //        }
// //    }
// 
//    if (line.startsWith("add_point")) {
//        char plot_name[20];
//        double value;
//        sscanf(line.c_str(), "add_point:%[^,],%lf", plot_name, &value);
//        LinePlot* line_plot = ecg_graph.get_plot(plot_name);
//         
//        if (!line_plot) {
//            Serial.printf("add_point was used but plot %s does not exist. Creating it now.\n", plot_name);
//            line_plot = ecg_graph.add_plot(String(plot_name), create_new_line_plot());
//        }
//        line_plot->draw(BLACK);
//        line_plot->add_point(value);
//        line_plot->draw();
//    }
// }

void parse_tcp_message(String line) {
    cJSON *root = cJSON_Parse(line.c_str());
    if (root == NULL) {
        Serial.println("Failed to parse json");
        return;
    }

    // copy for the risc-v plot (ecg)
    if (cJSON_HasObjectItem(root, "add_points_risc_v")) {
        cJSON *add_points_obj = cJSON_GetObjectItem(root, "add_points_risc_v");
        cJSON *plot_name_obj = add_points_obj->child;
        while(plot_name_obj) {
            Serial.println(plot_name_obj->string);

            for (int i=0; i<cJSON_GetArraySize(plot_name_obj); i++) {
                cJSON *plot_value = cJSON_GetArrayItem(plot_name_obj, i);
                // Do something with new plot value

                String plot_name = plot_name_obj->string;
                double value = plot_value->valuedouble;
                // LinePlot* line_plot = ecg_graph.get_plot(plot_name);
                GUI_Graph *ecg_graph = gui_main_state->get_ecg_graph();
                LinePlot* line_plot = ecg_graph->get_plot(plot_name);
                if (!line_plot) {
                    Serial.printf("add_point was used but plot %s does not exist. Creating it now.\n", plot_name.c_str());
                    line_plot = ecg_graph->add_plot(plot_name, create_new_line_plot(GREEN));
                }

                if (gui->get_current_state_id() == GUI_STATE_MAIN) {
                    line_plot->draw(BLACK);
                    line_plot->add_point(value);
                    line_plot->draw();
                } else {
                    line_plot->add_point(value);
                }
            }
            plot_name_obj = plot_name_obj->next;
        }
    }
    cJSON_Delete(root);
}


void loop(void) {
    handle_riscv_serial();
}
