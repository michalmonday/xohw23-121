
#include <TFT_eSPI.h> // Hardware-specific library (requires "User_Setup.h" to be replaced with the one for specific display)
#include <SPI.h>
#include <WiFi.h>
#include <map>
#include <cJSON.h>

// #include "drawing.h"
#include <colours.h>
#include <line_plot.h>
#include <gui_cms.h>
#include <gui_graph.h>
#include <gui_button.h>
#include <gui_label.h>
#include <rpc.h>
#include "gui_state_main.h"
#include "gui_state_select_option.h"
#include "gui_state_explore_objdump.h"
#include "gui_cms_states.h"
#include "watchpoint.h"

#include <display_config.h> // resolution
#define DISPLAY_BRIGHTNESS 0.2

#include <touch.h>
Touch touch;

#include <communication_queues.h>


// Wifi credentials file contains 2 lines:
// #ifndef MICHAL_WIFI_CREDENTIALS_H
// #define MICHAL_WIFI_CREDENTIALS_H
//    #define ACCESS_POINT_SSID "my_ssid"
//    #define ACCESS_POINT_PASSWORD "my_password"
// #endif
//
// It is added to .gitignore file, this way it's not shared
#include <michal_wifi_credentials.h>


// Serial is temporarily added to this file until I get 2nd display that
// will be dedicated to getting data from RISC-V program and displaying it.
// Until then, this display will show ECG data, and also use as controller/displayer
// of the continuous monitoring system.
#include <HardwareSerial.h>
HardwareSerial serial_riscv(2);  // UART2 (GPIO17=TX, GPIO16=RX)

// Thread used for drawing will be on separate thread from receiving/parsing data from tcp server
TaskHandle_t drawing_thread;

const IPAddress server_ip(192, 168, 0, 110);
const uint16_t server_port = 9093;
const String server_ip_str = "192.168.0.110:" + String(server_port); // just for displaying status
WiFiClient client;


#define SEVEN_INCH_DISPLAY_BOARD

#ifdef SEVEN_INCH_DISPLAY_BOARD
    #define TOUCH_SDA  19
    #define TOUCH_SCL  20
    #define TOUCH_INT -1
    #define TOUCH_RST 38
    #define TOUCH_WIDTH  800
    #define TOUCH_HEIGHT 480
    #define TOUCH_ROTATION ROTATION_INVERTED
    #include <graphics_arduino_gfx.h>
    Graphics *gfx = new Graphics_Arduino_GFX();
#else 
    #define TOUCH_SDA  33
    #define TOUCH_SCL  32
    #define TOUCH_INT 36
    #define TOUCH_RST 25
    #define TOUCH_WIDTH  480
    #define TOUCH_HEIGHT 320
    #define TOUCH_ROTATION ROTATION_LEFT
    // display object
    #include <graphics_tft_espi.h>
    Graphics *gfx = new Graphics_TFT_ESPI();
#endif



// status display is a GUI component that covers bottom of the screen and can display status messages like "Connecting to WiFi"
// StatusDisplay status_display(gfx, RESOLUTION_X, (int)(0.1 * RESOLUTION_Y), 0, (0.9*RESOLUTION_Y), WHITE, BLACK);

int current_colour_id = 0;
double current_top_margin = 0.0;

// graph without parameters will have default values (to cover most of the screen with space for status display)
// see graph.cpp to see or change default values
// GUI_Graph graph(gfx); 

GUI_CMS *gui;
GUI_State_Main *gui_main_state;

double xlo = 0;
// double xhi = 25; // this is pretty much setting how many values we want to display in the graph at once
// double xhi = 100; // this is pretty much setting how many values we want to display in the graph at once
double xhi = 30;//RESOLUTION_X*0.2; // this is pretty much setting how many values we want to display in the graph at once
double ylo = 0; // line plot lower value bound
double yhi = 1; // line plot upper value bound
// int max_number_of_items = min((int)(xhi - xlo), (int)graph.get_width());
int max_number_of_items = xhi - xlo;

void parse_tcp_message(String line);

void init_wifi() {
    gfx->setTextColor(WHITE);
    gui_main_state->set_ap_conn_status("Connecting to '" + String(ACCESS_POINT_SSID) + "' WiFi access point...");
    gui_main_state->set_tcp_conn_status("ZYNQ TCP server address is set to: " + server_ip_str);
    gui->update();
    gui->draw();

    Serial.println("Connecting to WiFi access point... "); 

    WiFi.mode(WIFI_STA);

    Serial.println("Set sleep..."); 
    WiFi.setSleep(false);
    Serial.println("Wifi.begin"); 
    WiFi.begin(ACCESS_POINT_SSID, ACCESS_POINT_PASSWORD); 
    Serial.println("Wifi.status"); 
    Serial.println("WTF"); 
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
        gui_main_state->set_ap_conn_status("Retrying connection...");
    }

    Serial.println("Connected");
    Serial.print("IP Address:");
    Serial.println(WiFi.localIP());

    gui_main_state->set_ap_conn_status("Connected to '" + String(ACCESS_POINT_SSID) + "' WiFi access point (assigned IP: " + WiFi.localIP().toString() + ")");
}

void handle_gui() {
    // status_display.update();
    gui->update();
    gui->draw();
}

LinePlot* create_new_line_plot(int clr=-1) {
    if (clr == -1) {
        clr = colours[current_colour_id];
        current_colour_id = (current_colour_id + 1) % (sizeof(colours) / sizeof(colours[0]));
        Serial.printf("current_colour_id=%d\n", current_colour_id);
    }
    LinePlot* line_plot = new LinePlot(gfx, xlo, xhi, ylo, yhi, clr, max_number_of_items);
    if (line_plot == NULL) {
        Serial.println("ERROR: could not allocate memory for line plot");
        return nullptr;
    }
    line_plot->set_top_margin(current_top_margin);
    current_top_margin += 0.15;  // top margin is used to separate line plots from each other (so they don't overlap)
    return line_plot;
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


void setup() {
    Serial.begin(115200);
    Serial.println();

    communication_queues_init();



    
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


    gfx->init();


    touch.init(TOUCH_SDA, TOUCH_SCL, TOUCH_INT, TOUCH_RST, TOUCH_WIDTH, TOUCH_HEIGHT, TOUCH_ROTATION);


    gui = new GUI_CMS(gfx, &touch);
    if (gui == NULL) {
        Serial.println("ERROR: could not allocate memory for GUI");
        return;
    }

    gui_main_state = static_cast<GUI_State_Main*>(gui->get_state(GUI_STATE_MAIN));
    // gui->add_element(&ecg_graph, GUI_STATE_MAIN);
    // gui->add_element(label_ap_conn_status, GUI_STATE_MAIN);
    // gui->add_element(label_tcp_conn_status, GUI_STATE_MAIN);

    delay(300);


    init_wifi();

    // serial_riscv.begin(115200);
    // init_display(gfx, DISPLAY_BRIGHTNESS);

    delay(300);

	xTaskCreatePinnedToCore(
			drawing_thread_func, /* Function to implement the task */
			"drawing_thread", /* Name of the task */
			20000, /* Stack size in words */
			NULL, /* Task input parameter */
			0, /* Priority of the task */
			&drawing_thread, /* Task handle. */
			(xPortGetCoreID() & 1) ^ 1); /* Core where the task should run, Esp32 has 2 cores, using XOR the chosen core is the opposite of the current one. */


    // GUI_Button *btn = new GUI_Button(&gfx, "Hello", RESOLUTION_X*0.5, RESOLUTION_Y*0.1, RESOLUTION_X * 0.3, RESOLUTION_Y * 0.7, BLACK,
    //      [](){Serial.println("Hello button was pressed");},
    //      [](){Serial.println("Hello button was released");}
    // );
    // gui->add_element(btn, GUI_STATE_MAIN);


    // GUI_Button *btn2 = new GUI_Button(&gfx, "Second", RESOLUTION_X*0.1, RESOLUTION_Y*0.1, RESOLUTION_X * 0.8, RESOLUTION_Y * 0.8);
    // gui->add_element(btn2, GUI_STATE_SECOND);
    delay(1000);
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

// void handle_riscv_serial() {
//     // print free memory
//     if (serial_riscv.available()) {
//         // Serial.println("Received something from riscv");
//         String line = serial_riscv.readStringUntil('\n');
//         // Serial.print("Received from riscv: '");
//         // Serial.print(line);
//         // Serial.println("'");
// 
//         if (!contains_digits_only(line)) {
//             if (line.equals("Leads off")) {
//                 // Serial.printf("Free memory: %d\n", ESP.getFreeHeap());
//                 // random float between 0.2 and 0.3
//                 float random_value = 0.2 + (0.3 - 0.2) * ((float) rand() / (float) RAND_MAX);
//                 // String *formatted_msg = new String("add_point:Leads off," + String(random_value));
// 
//                 // String *formatted_msg = new String("{\"add_points_risc_v\": {\"Leads off\": [" + String(random_value) + "]}}");
//                 // if (!add_string_to_queue(queue_received, formatted_msg)) {
//                 //     delete formatted_msg;
//                 // }
//                 // continue;
//                 return;
//             }
//             Serial.println(line);
//             Serial.println("Not a number");
//             // line may be: "Leads off"
//             // continue;
//             return;
//         }
// 
//         float ecg_value = atof(line.c_str()) / 60000.0f;
//         // Serial.print("ecg_value=");
//         // Serial.println(ecg_value);
// 
//         if (ecg_value < 0.0 || ecg_value > 1.0) {
//             Serial.println(line);
//             Serial.print("ecg_value=");
//             Serial.println(ecg_value);
//             // continue;
//             return;
//         } 
// 
//         // String *formatted_msg = new String("add_point:ECG," + String(ecg_value));
//         // this needs to be a JSON string just like data received from server
//         String *formatted_msg = new String("{\"add_points_risc_v\": {\"ECG\": [" + String(ecg_value) + "]}}");
//     // 
//     // {
//     //    add_points: {
//     //      "ECG": [0.1, 0.2, 0.1], 
//     //      "ANOTHER": [0.7, 0.6, 0.9]
//     //    },
//     // }
//         if (!add_string_to_queue(queue_received, formatted_msg)) {
//             delete formatted_msg;
//         }
//     }
// }

// void check_protocol(String line) {
//     // line is a string received from the ZC706 tcp server (currently using PYNQ)
// 
// //    if (line.startsWith("create_plot")) {
// //        char plot_name[20];
// //        sscanf(line.c_str(), "create_plot:%s", plot_name);
// //        LinePlot *line_plot = new LinePlot(gfx, xlo, xhi, ylo, yhi, CYAN, max_number_of_items);
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

void update_mode(int mode) {
    if (mode & 0b1) {
        gui->get_state_main()->set_training_status("Training");
    } else {
        gui->get_state_main()->set_training_status("-");
    }
    if (mode & 0b10) {
        gui->get_state_main()->set_testing_status("Testing");
    } else {
        gui->get_state_main()->set_testing_status("-");
    }
}

void parse_tcp_message(String line) {
    cJSON *root = cJSON_Parse(line.c_str());
    if (root == NULL) {
        Serial.println("Failed to parse json. Line:");
        Serial.println(line);
        return;
    }

    // // Parse string with the following json:
    // // '{
    // //    programs: {
    // //      "ECG": ["ecg_info_leak.bin", "ecg_baseline.bin"], 
    // //      "ANOTHER": ["another0.bin", "another1.bin"]
    // //    },
    // // }'
    // if (cJSON_HasObjectItem(root, "programs")) {
    //     cJSON *programs_obj = cJSON_GetObjectItem(root, "programs");
    //     cJSON *program_category_obj = programs_obj->child;
    //     while(program_category_obj) {
    //         Serial.println(program_category_obj->string);
    //         for (int i=0; i<cJSON_GetArraySize(program_category_obj); i++) {
    //             cJSON *program_name_obj = cJSON_GetArrayItem(program_category_obj, i);
    //             String program_name = program_name_obj->valuestring;
    //             Serial.print("Program: ");
    //             Serial.println(program_name);
    //         }
    //         program_category_obj = program_category_obj->next;
    //     }
    // }

    // // Parse string with the following json:
    // // { "status_update": "OK: Running program: ecg_info_leak.bin" }
    // if (cJSON_HasObjectItem(root, "status_update")) {
    //     cJSON *status_update_obj = cJSON_GetObjectItem(root, "status_update");
    //     // Print response
    //     Serial.print("Status update: ");
    //     Serial.println(status_update_obj->valuestring);
    // }

    // Parse string with the following json:
    // {
    //    add_points: {
    //      "ECG": [0.1, 0.2, 0.1], 
    //      "ANOTHER": [0.7, 0.6, 0.9]
    //    },
    // }

    // adding points to pynq plot
    if (cJSON_HasObjectItem(root, "add_points")) {
        cJSON *add_points_obj = cJSON_GetObjectItem(root, "add_points");
        cJSON *plot_name_obj = add_points_obj->child;

        GUI_Graph *pynq_graph = gui_main_state->get_pynq_graph();
        while(plot_name_obj) {
            // Serial.println('add_points for ' + plot_name_obj->string);

            for (int i=0; i<cJSON_GetArraySize(plot_name_obj); i++) {
                cJSON *plot_value = cJSON_GetArrayItem(plot_name_obj, i);
                // Do something with new plot value

                String plot_name = plot_name_obj->string;
                double value = plot_value->valuedouble;
                // LinePlot* line_plot = ecg_graph.get_plot(plot_name);
                LinePlot* line_plot = pynq_graph->get_plot(plot_name);
                if (!line_plot) {
                    Serial.printf("add_point was used but plot %s does not exist. Creating it now.\n", plot_name.c_str());
                    line_plot = pynq_graph->add_plot(plot_name, create_new_line_plot());
                }

                line_plot->add_point(value);

                // if (gui->get_current_state_id() == GUI_STATE_MAIN) {
                //     line_plot->draw(BLACK);
                //     line_plot->add_point(value);
                //     line_plot->draw();
                // } else {
                //     line_plot->add_point(value);
                // }
            }
            plot_name_obj = plot_name_obj->next;
        }

        if (gui->get_current_state_id() == GUI_STATE_MAIN) 
            pynq_graph->draw_plots();
    }

    // // copy for the risc-v plot (ecg)
    // if (cJSON_HasObjectItem(root, "add_points_risc_v")) {
    //     cJSON *add_points_obj = cJSON_GetObjectItem(root, "add_points_risc_v");
    //     cJSON *plot_name_obj = add_points_obj->child;
    //     while(plot_name_obj) {
    //         Serial.println(plot_name_obj->string);

    //         for (int i=0; i<cJSON_GetArraySize(plot_name_obj); i++) {
    //             cJSON *plot_value = cJSON_GetArrayItem(plot_name_obj, i);
    //             // Do something with new plot value

    //             String plot_name = plot_name_obj->string;
    //             double value = plot_value->valuedouble;
    //             // LinePlot* line_plot = ecg_graph.get_plot(plot_name);
    //             GUI_Graph *ecg_graph = gui_main_state->get_ecg_graph();
    //             LinePlot* line_plot = ecg_graph->get_plot(plot_name);
    //             if (!line_plot) {
    //                 Serial.printf("add_point was used but plot %s does not exist. Creating it now.\n", plot_name.c_str());
    //                 line_plot = ecg_graph->add_plot(plot_name, create_new_line_plot(GREEN));
    //             }

    //             if (gui->get_current_state_id() == GUI_STATE_MAIN) {
    //                 line_plot->draw(BLACK);
    //                 line_plot->add_point(value);
    //                 line_plot->draw();
    //             } else {
    //                 line_plot->add_point(value);
    //             }
    //         }
    //         plot_name_obj = plot_name_obj->next;
    //     }
    // }

    // // Parse string with the following json:
    // {
    //     "status_update" : {
    //         "program_finished": "ecg_baseline.bin",
    //         "pynq_restarted" : true
    //     }
    // }
    if (cJSON_HasObjectItem(root, "status_update")) {
        cJSON *status_update_obj = cJSON_GetObjectItem(root, "status_update");
        if (cJSON_HasObjectItem(status_update_obj, "program_finished")) {
            cJSON *program_finished_obj = cJSON_GetObjectItem(status_update_obj, "program_finished");
            String program = program_finished_obj->valuestring;
            Serial.print("Program finished: ");
            Serial.println(program);
            gui->get_state_main()->set_run_status("Finished");
        }

        if (cJSON_HasObjectItem(status_update_obj, "pynq_restarted")) {
            cJSON *pynq_restarted_obj = cJSON_GetObjectItem(status_update_obj, "pynq_restarted");
            bool pynq_restarted = pynq_restarted_obj->valueint;
            Serial.print("Pynq restarted: ");
            Serial.println(pynq_restarted);
            // gui->get_state_main()->set_run_status("Pynq restarted");
            gui->get_state_main()->reset();

            rpc_no_args("rpc_update_status");
        }

        if (cJSON_HasObjectItem(status_update_obj, "mode")) {
            cJSON *mode_obj = cJSON_GetObjectItem(status_update_obj, "mode");
            int mode = mode_obj->valueint;
            Serial.print("Mode: ");
            Serial.println(mode);
            update_mode(mode);
            // gui->get_state_main()->set_run_status("Pynq restarted");
        }

        if (cJSON_HasObjectItem(status_update_obj, "dataset_size")) {
            cJSON *dataset_size_obj = cJSON_GetObjectItem(status_update_obj, "dataset_size");
            int size = dataset_size_obj->valueint;
            // Serial.print("Dataset size: ");
            // Serial.println(size);
            gui->get_state_main()->set_dataset_size(size);
            
            // gui->get_state_main()->set_run_status("Pynq restarted");
        }

    }

// {
//     "RPC_return" : {
//         "function_name": "rpc_list_programs",
//         "return_value": {
//             "ECG" : ["ecg_baseline.bin", "ecg_info_leak.bin"],
//             "ANOTHER_CATEGORY" : ["another_program_baseline.bin", "another_program_anomalous_version.bin"]
//         }, 
//         "return_status": "success" // alternative would be "error"
//     }
// }
    // Parse string with the json above
    if (cJSON_HasObjectItem(root, "RPC_return")) {

        // gui->notify(line, 1500);

        if (!cJSON_HasObjectItem(root, "RPC_return")) { Serial.println("Failed to parse RPC_return"); return; } 
        cJSON *rpc_return_obj = cJSON_GetObjectItem(root, "RPC_return");
        if (!cJSON_HasObjectItem(rpc_return_obj, "function_name")) { Serial.println("Failed to parse function_name"); return; }
        if (!cJSON_HasObjectItem(rpc_return_obj, "return_value"))  { Serial.println("Failed to parse return_value");  return; }
        if (!cJSON_HasObjectItem(rpc_return_obj, "return_status")) { Serial.println("Failed to parse return_status"); return; }
        if (!cJSON_HasObjectItem(rpc_return_obj, "function_args")) { Serial.println("Failed to parse function_args"); return; }
        cJSON *function_name_obj = cJSON_GetObjectItem(rpc_return_obj, "function_name");
        cJSON *return_value_obj = cJSON_GetObjectItem(rpc_return_obj, "return_value");
        cJSON *return_status_obj = cJSON_GetObjectItem(rpc_return_obj, "return_status");
        cJSON *function_args_obj = cJSON_GetObjectItem(rpc_return_obj, "function_args");
        String function_name = function_name_obj->valuestring;
        String return_status = return_status_obj->valuestring;
        // Print response
        Serial.print("RPC_return, function_name: ");
        Serial.print(function_name);
        Serial.print(", status: ");
        Serial.print(return_status);
        Serial.println(" return_value:");

        if (!return_status.equals("success")) {
            Serial.println("RPC call failed");
            return;
        }

        if (function_name.equals("rpc_load_program")) {
            String loaded_program = cJSON_GetArrayItem(function_args_obj, 0)->valuestring;
            Serial.printf("rpc_load_program, loaded_program: %s\n", loaded_program.c_str());
            gui->get_state_main()->set_loaded_program(loaded_program);
        }

        if (function_name.equals("rpc_list_programs") || function_name.equals("rpc_list_objdumps")) {
            cJSON *program_category_obj = return_value_obj->child;
            while(program_category_obj) {
                String category = program_category_obj->string;
                std::vector<String> programs;
                Serial.println(category);
                for (int i=0; i<cJSON_GetArraySize(program_category_obj); i++) {
                    cJSON *program_name_obj = cJSON_GetArrayItem(program_category_obj, i);
                    String program_name = program_name_obj->valuestring;
                    Serial.print("Program: ");
                    Serial.println(program_name);
                    programs.push_back(program_name);

                    // make a button or something, maybe change gui state into program selection?
                }
                program_category_obj = program_category_obj->next;
                gui->get_state_select_option()->add_options(category, programs);
            }
        }

        if (function_name.equals("rpc_run")) {
            String return_value = return_value_obj->valuestring;
            gui->get_state_main()->set_run_status("Running");
        }
        if (function_name.equals("rpc_halt")) {
            String return_value = return_value_obj->valuestring;
            gui->get_state_main()->set_run_status("Halted");
        }

        if (function_name.equals("rpc_enable_training") || function_name.equals("rpc_disable_training") || function_name.equals("rpc_enable_testing") || function_name.equals("rpc_disable_testing")) {
            int mode = 0;
            if (function_name.equals("rpc_enable_training"))  mode = return_value_obj->valueint;
            if (function_name.equals("rpc_disable_training")) mode = return_value_obj->valueint;
            if (function_name.equals("rpc_enable_testing"))   mode = return_value_obj->valueint;
            if (function_name.equals("rpc_disable_testing"))  mode = return_value_obj->valueint;
            update_mode(mode);
        }

        if (function_name.equals("rpc_update_status")) {
            if (cJSON_HasObjectItem(return_value_obj, "loaded_program")) {
                cJSON *loaded_program_obj = cJSON_GetObjectItem(return_value_obj, "loaded_program");
                String loaded_program = loaded_program_obj->valuestring;
                gui->get_state_main()->set_loaded_program(loaded_program);
            }
            // 'dataset_size' : anomaly_detection.get_dataset_size(),
            // 'mode' : mode,
            // 'is_halted' : is_arbitrary_halt_active,
            // 'loaded_program' : loaded_program},
            // 'is_running' : is_running,
            if (cJSON_HasObjectItem(return_value_obj, "dataset_size")) {
                cJSON *dataset_size_obj = cJSON_GetObjectItem(return_value_obj, "dataset_size");
                int dataset_size = dataset_size_obj->valueint;
                // gui->get_state_main()->set_dataset_size(dataset_size);
            }
            if (cJSON_HasObjectItem(return_value_obj, "mode")) {
                cJSON *mode_obj = cJSON_GetObjectItem(return_value_obj, "mode");
                int mode = mode_obj->valueint;
                if (mode & 0b1) {
                    gui->get_state_main()->set_training_status("Training");
                } else {
                    gui->get_state_main()->set_training_status("-");
                }
                if (mode & 0b10) {
                    gui->get_state_main()->set_testing_status("Testing");
                } else {
                    gui->get_state_main()->set_testing_status("-");
                }
            }
            
            bool is_running = false;
            int is_halted = false;
            if (cJSON_HasObjectItem(return_value_obj, "is_running")) {
                cJSON *is_running_obj = cJSON_GetObjectItem(return_value_obj, "is_running");
                is_running = is_running_obj->valueint;
            }
            if (cJSON_HasObjectItem(return_value_obj, "is_halted")) {
                cJSON *is_halted_obj = cJSON_GetObjectItem(return_value_obj, "is_halted");
                bool is_halted = is_halted_obj->valueint;
            }
            if (!is_running && !is_halted) {
                gui->get_state_main()->set_run_status("-");
            } else if (is_running) {
                gui->get_state_main()->set_run_status("Running");
            } else {
                gui->get_state_main()->set_run_status("Halted");
            }

// {"atf_watchpoints": {"-1": {"active": false, "attributes": {}}, "0": {"active": true, "attributes": {"PC": 2147485676}}, "1": {"active": false, "attributes": {}}, "2": {"active": false, "attributes": {}}}
            if (cJSON_HasObjectItem(return_value_obj, "atf_watchpoints")) {
                // clear old watchpoints
                gui->get_state_main()->clear_atf_watchpoints();
                cJSON *atf_watchpoints_obj = cJSON_GetObjectItem(return_value_obj, "atf_watchpoints");
                for (int i=0; i<cJSON_GetArraySize(atf_watchpoints_obj); i++) {
                    cJSON *watchpoint_obj = cJSON_GetArrayItem(atf_watchpoints_obj, i);
                    // Do something with new plot value

                    int watchpoint_id = atoi(watchpoint_obj->string);
                    Serial.print("Watchpoint id: ");
                    Serial.println(watchpoint_id);

                    Watchpoint *watchpoint = gui_main_state->add_atf_watchpoint();

                    cJSON *active_obj = cJSON_GetObjectItem(watchpoint_obj, "active");
                    bool active = active_obj->valueint;
                    Serial.print("Active: ");
                    Serial.println(active);

                    cJSON *attributes_obj = cJSON_GetObjectItem(watchpoint_obj, "attributes");
                    if (attributes_obj) {
                        for (int j=0; j<cJSON_GetArraySize(attributes_obj); j++) {
                            cJSON *attribute_obj = cJSON_GetArrayItem(attributes_obj, j);
                            // Do something with new plot value

                            String attribute_name = attribute_obj->string;
                            Serial.print("Attribute name: ");
                            Serial.println(attribute_name);

                            // cJSON does not support 64-bit values so strings are used instead 
                            // Serial.printf("Converting %s to 64-bit value\n", attribute_obj->valuestring);
                            long long attribute_value = strtoll(attribute_obj->valuestring, NULL, 16);
                            Serial.print("Attribute value: ");
                            Serial.println(attribute_value);

                            watchpoint->set_attribute(attribute_name, attribute_value);
                        }
                    }
                    watchpoint->set_active(active);
                }
            }
        }

        if (function_name.equals("rpc_reset_dataset")) {
            gui->get_state_main()->set_dataset_size(0);
        }

            // rpc_get_objdump_data
        if (function_name.equals("rpc_get_objdump_data")) {
            // if (cJSON_HasObjectItem(return_value_obj, "objdump_data")) {
                // cJSON *objdump_data_obj = cJSON_GetObjectItem(return_value_obj, "objdump_data");
                // String objdump_data = objdump_data_obj->valuestring;
                // set function/basic-block selection state and fill it with received data
                GUI_State_Explore_Objdump *state_explore_objdump = gui->get_state_explore_objdump();
                bool success = state_explore_objdump->set_objdump(return_value_obj);
                if (success) {
                    state_explore_objdump->push_function("_start");
                    state_explore_objdump->set_on_address_selected([](long long address) {
                        gui->get_state_edit_watchpoint()->set_attribute("PC", address);
                    });
                    gui->push_state(GUI_STATE_EXPLORE_OBJDUMP);
                } else {
                    Serial.println("Failed to set objdump data");
                }
            // }
        }
    }

//    if (line.startsWith("add_point")) {
//        char plot_name[20];
//        double value;
//        sscanf(line.c_str(), "add_point:%[^,],%lf", plot_name, &value);
//        LinePlot* line_plot = ecg_graph.get_plot(plot_name);
//        if (!line_plot) {
//            Serial.printf("add_point was used but plot %s does not exist. Creating it now.\n", plot_name);
//            line_plot = ecg_graph.add_plot(String(plot_name), create_new_line_plot());
//        }
//        line_plot->draw(BLACK);
//        line_plot->add_point(value);
//        line_plot->draw();
//    }

    cJSON_Delete(root);
}


void loop(void) {
    // handle_riscv_serial();
    // return;

    Serial.println("Attempt to access server...");
    // status_display.set_status("tcp_connection_status", "Connecting to ZC706 TCP server (" + server_ip_str + ")");
    if (!client.connect(server_ip, server_port)) {
        Serial.println("Access failed.");
        client.stop();
        for (int i=5; i>0; i--) {
            // handle_riscv_serial();
            // status_display.set_status("tcp_connection_status", "Retrying ZC706 TCP server (" + server_ip_str + ") connection in " + String(i) + " seconds...");
            delay(1000);
        }
        return;
    }
    // status_display.set_status("tcp_connection_status", "Connected to ZC706 TCP server ("+  server_ip_str + ")");

    Serial.println("Access successful.");


    rpc_no_args("rpc_update_status");





// // {
// //     "RPC" : {
// //         "function_name": "rpc_run_program",
// //         "function_args": ["ecg_baseline.bin"]
// //     }
// // }
//     //Construct json string as JSON above
//     cJSON *root = cJSON_CreateObject();
//     cJSON *rpc_obj = cJSON_CreateObject();
//     cJSON_AddItemToObject(root, "RPC", rpc_obj);
//     cJSON_AddStringToObject(rpc_obj, "function_name", "rpc_run_program");
//     // string array 
//     const char *string_array[1] = {"ecg_baseline.bin"};
//     cJSON *function_args_obj = cJSON_CreateStringArray(string_array, 1);
//     cJSON_AddItemToObject(rpc_obj, "function_args", function_args_obj);
//     char *json_str = cJSON_PrintUnformatted(root);
//     Serial.print("Sending: '");
//     Serial.print(json_str);
//     client.println(json_str);
//     free(json_str);

    // client.println("run_program,ecg_baseline.bin");

    // client.print("run_program:ecg_baseline.bin");
    while (client.connected() || client.available()) {
        // handle_riscv_serial();

        String *line;
        if ( xQueueReceive(queue_to_send, &line, 0) != errQUEUE_EMPTY ) {
            client.println(*line);
            delete line;
        }

        if (client.available()) {
            // String *line = new String(client.readStringUntil('\n'));
            String *line = new String(client.readStringUntil('\n'));
            if (line == NULL) {
                Serial.println("Failed to allocate memory for received string");
                continue;
            }
            // String line = client.readString(); // readString has a timeout that would make it inefficient (readStringUntil does not have it when using '\n')
            // Serial.print("Received: '");
            // Serial.print(*line);
            // Serial.println("'");
            // // print free memory 
            // Serial.printf("Free memory: %d\n", ESP.getFreeHeap());
            // Serial.println("This task watermark: " + String(uxTaskGetStackHighWaterMark(drawing_thread)) + " bytes");
            add_string_to_queue(queue_received, line, true);
        }
    }
    Serial.println("Closing connection.");
    client.stop();
}
