
#include <TFT_eSPI.h> // Hardware-specific library (requires "User_Setup.h" to be replaced with the one for specific display)
#include <SPI.h>

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


unsigned long last_eletrodes_off_time = 0;

void handle_gui() {
    // status_display.update();
    gui->update();
    gui->draw();
}

void parse_riscv_message(String line);

LinePlot* create_new_line_plot(int clr=-1) {
    if (clr == -1) {
        clr = colours[current_colour_id];
        current_colour_id = (current_colour_id + 1) % (sizeof(colours) / sizeof(colours[0]));
        Serial.printf("current_colour_id=%d\n", current_colour_id);
    }
    LinePlot* line_plot = new LinePlot(tft, xlo, xhi, ylo, yhi, clr, max_number_of_items);
    if (line_plot == NULL) {
        Serial.println("Failed to allocate memory for line_plot");
    }
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
            parse_riscv_message(*line);
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
    if (gui == NULL) {
        Serial.println("Failed to allocate memory for gui");
    }
    gui_main_state = static_cast<GUI_State_Main*>(gui->get_state(GUI_STATE_MAIN));
    delay(100);
    serial_riscv.begin(115200);
    init_display();
    delay(1000);
	xTaskCreatePinnedToCore(
			drawing_thread_func, /* Function to implement the task */
			"drawing_thread", /* Name of the task */
			20000, /* Stack size in words */
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

bool contains_digits_only(String str) {
    for (int i = 0; i < str.length(); i++) {
        if (!isdigit(str[i])) {
            return false;
        }
    }
    return true;
}


void parse_riscv_message(String line) {
    if (millis() - last_eletrodes_off_time < 100) {
        // If electrodes were turned off recently (last 100ms), ignore the reading. 
        // It stops "Electrodes off" disappearing immediately after it appears.
        // This is equivalent to debouncing a button, but in this case it's debouncing electrodes.
        return;
    }
    if (!contains_digits_only(line)) {
        if (line.equals("Leads off")) {
            gui_main_state->set_electrodes_status(false);
            last_eletrodes_off_time = millis();
            return;
        }
        // ignore message if it contains non-digits
        Serial.printf("Message with non-digits received: '%s'. Ignoring it.\n", line.c_str());
        return;
    }

    // range of analog sensors raw readings is around 60000
    float ecg_value = atof(line.c_str()) / 60000.0f;

    if (ecg_value < 0.05 || ecg_value > 0.95) {
        Serial.printf("Unusual ecg_value was received: %f. Ignoring it.\n", ecg_value);
        Serial.printf("line='%s'\n", line.c_str());
        return;
    } 
    Serial.println("time since last electrodes off: " + String(millis() - last_eletrodes_off_time) + "ms");
    gui_main_state->set_electrodes_status(true);

    GUI_Graph *ecg_graph = gui_main_state->get_ecg_graph();
    LinePlot* line_plot = ecg_graph->get_plot("ECG");
    if (!line_plot) {
        Serial.printf("ECG plot does not exist. Creating it now.\n");
        line_plot = ecg_graph->add_plot("ECG", create_new_line_plot(GREEN));
    }

    line_plot->add_point(ecg_value); 
    if (gui->get_current_state_id() == GUI_STATE_MAIN) {
        // line_plot->draw(BLACK);
        // line_plot->add_point(ecg_value);
        // line_plot->draw();

        // instead of undrawing it whole at once (by drawing it with black), we can undraw and draw one point at the time
        // for each new/moved line/point we can draw old one with black and new one with green,
        // this way the effect will be much smoother, and no visible flickering will be seen (without much performance penalty if any)
        line_plot->draw();
    }
}


void loop(void) {
    if (serial_riscv.available()) {
        String line = serial_riscv.readStringUntil('\n');
        // Serial.print("Received from riscv: '");
        // Serial.print(line);
        // Serial.println("'");
        // String *formatted_msg = new String("{\"add_points_risc_v\": {\"ECG\": [" + String(ecg_value) + "]}}");
        String *msg = new String(line);
        if (msg == NULL) {
            Serial.println("Failed to allocate memory for msg");
            return;
        }
        if (!add_string_to_queue(queue_received, msg)) {
            delete msg;
        }
    }
}
