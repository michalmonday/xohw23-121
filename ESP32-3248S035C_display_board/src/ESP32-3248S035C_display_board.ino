/*

  This program provides cartesian type graph function

  Revisions
  rev     date        author      description
  1       12-24-2015  kasprzak    initial creation

  Updated by Bodmer to be an example for the library here:
  https://github.com/Bodmer/TFT_eSPI

*/

#include <TFT_eSPI.h> // Hardware-specific library (requires "User_Setup.h" to be replaced with the one for specific display)
#include <SPI.h>
#include <WiFi.h>
#include <map>

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

// Thread used for drawing will be on separate thread from receiving/parsing data from tcp server
TaskHandle_t drawing_thread;
QueueHandle_t queue = NULL;

const IPAddress server_ip(192, 168, 0, 105);
uint16_t server_port = 9092;
const String server_ip_str = "192.168.0.105:" + String(server_port); // just for displaying status

WiFiClient client;

TFT_eSPI tft = TFT_eSPI(); // Invoke custom library with default width and height

StatusDisplay status_display(tft, RESOLUTION_X, (int)(0.1 * RESOLUTION_Y), 0, (0.9*RESOLUTION_Y), TFT_WHITE, TFT_BLACK);

int current_colour_id = 0;

// Plot defaults
// int margin_y = 0.1 * tft.height();
int grid_x_segments = 5;
int grid_y_segments = 4;
int graph_x = (int)(RESOLUTION_X * 0.1);
int graph_y = (int)(RESOLUTION_Y * 0.8); // it should be inverted, but it's not (it specifies bottom of the graph, not the top)
int graph_w = (int)(RESOLUTION_X * 0.65); 
int graph_h = (int)(RESOLUTION_Y * 0.65); // 260
double xlo = 0;
// double xhi = 60; // this is pretty much setting how many values we want to display in the graph at once
double xhi = 25; // this is pretty much setting how many values we want to display in the graph at once
double ylo = 0; //-1;
double yhi = 1;
int max_number_of_items = min((int)(xhi - xlo), (int)graph_w);

Graph graph(graph_x, graph_y, graph_w, graph_h);

void init_wifi() {
    tft.setTextColor(WHITE);
    //tft.setTextSize(2);
    char buf[100];
    sprintf(buf, "Connecting to '%s' WiFi access point...", ACCESS_POINT_SSID);
    status_display.set_status("ap_connection_status", buf);
    status_display.set_status("tcp_connection_status", "ZYNQ TCP server address is set to: " + server_ip_str);
    // tft.drawString(buf, (int)(RESOLUTION_X * 0.1), (int)(RESOLUTION_Y * 0.9));



    WiFi.mode(WIFI_STA);
    WiFi.setSleep(false);
    WiFi.begin(ACCESS_POINT_SSID, ACCESS_POINT_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
        // tft.drawString("Retrying...", (int)(RESOLUTION_X * 0.1), (int)(RESOLUTION_Y * 0.9));
        status_display.set_status("ap_connection_status", "Retrying connection...");
    }
    // tft.drawString(buf, (int)(RESOLUTION_X * 0.1), (int)(RESOLUTION_Y * 0.9));

    Serial.println("Connected");
    Serial.print("IP Address:");
    Serial.println(WiFi.localIP());
    sprintf(buf, "Connected to '%s' access point (assigned IP: %s)", ACCESS_POINT_SSID, WiFi.localIP().toString().c_str());
    status_display.set_status("ap_connection_status", buf);
}

LinePlot* create_new_line_plot() {
    unsigned int clr = colours[current_colour_id];
    current_colour_id = (current_colour_id + 1) % (sizeof(colours) / sizeof(colours[0]));
    Serial.printf("current_colour_id=%d\n", current_colour_id);
    return new LinePlot(tft, xlo, xhi, ylo, yhi, clr, max_number_of_items);
}


void check_protocol(String line) {
    // line is a string received from the ZC706 tcp server (currently using PYNQ)

    if (line.startsWith("create_plot")) {
        char plot_name[20];
        sscanf(line.c_str(), "create_plot:%s", plot_name);
        LinePlot *line_plot = new LinePlot(tft, xlo, xhi, ylo, yhi, CYAN, max_number_of_items);
        if (graph.add_plot(String(plot_name), line_plot)) {
            client.write("OK");
        } else {
            client.write("ERROR: Plot already exists.");
        }
    }

    if (line.startsWith("add_point")) {
        char plot_name[20];
        double value;
        sscanf(line.c_str(), "add_point:%[^,],%lf", plot_name, &value);
        LinePlot* line_plot = graph.get_plot(plot_name);
        if (!line_plot) {
            Serial.printf("add_point was used but plot %s does not exist. Creating it now.\n", plot_name);
            line_plot = graph.add_plot(String(plot_name), create_new_line_plot());

        }
        line_plot->draw(BLACK);
        line_plot->add_point(value);
        line_plot->draw();
    }
}

void drawing_thread_func(void *parameter) {
    while (true) {
        String* line;
        // Serial.printf("Queue size: %d, free space: %d, max size: %d\n", uxQueueMessagesWaiting(queue), uxQueueSpacesAvailable(queue), uxQueueMessagesWaiting(queue) + uxQueueSpacesAvailable(queue));
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
    tft.fillScreen(BLACK);
}

void setup() {
    Serial.begin(115200);
    Serial.println();
    init_display();
    init_wifi();


    static bool redraw_on_first_call_only_graph = true;
    delay(1000);

    graph.draw(tft, 
        2,                // decimal point precision for axis tick labels
        xlo,              // lower bound of axis x  (used to set x axis tick labels)
        xhi,              // upper bound of axis x  (used to set x axis tick labels)
        grid_x_segments,  // number of grid segments in x direction
        ylo,              // lower bound of axis y  (used to set y axis tick labels)
        yhi,              // upper bound of axis y  (used to set y axis tick labels)
        grid_y_segments,  // number of grid segments in y direction
        "title",          // title
        "x label",        // x label
        "y label",        // y label
        DKBLUE,           // grid color
        RED,              // axis color
        WHITE,            // text color
        BLACK             // background color
        );

    // Graph_func(tft,
    //       0,                               // x data point
    //       0,                               // y data point
    //       2,                               // decimal point precision for axis tick labels
    //       graph_x,                         // gx graph location (left)
    //       graph_y,                         // gy graph location (bottom)
    //       graph_w,                         // width
    //       graph_h,                         // height
    //       xlo,                             // lower bound of axis x
    //       xhi,                             // upper bound of axis x
    //       x_inc,                           // x axis increment (grid split like)
    //       ylo,                             // lower bound of axis y
    //       yhi,                             // upper bound of axis y
    //       y_inc,                           // y axis increment (grid split like)
    //       "",                              // title
    //       "x label",                       // x label
    //       "y label",                       // y label
    //       redraw_on_first_call_only_graph, // flag to redraw graph on first call only
    //       YELLOW);                         // plotted trace colour

    // LinePlot* line_plot = create_new_line_plot();
    // line_plots.add_plot("Test plot", line_plot);
    // for (double x = 1.0; x <= 10.0; x += 10.0 / graph_w / 2.0) {
    //     // instead of repainting the whole screen black together with the new graph we can redraw the line with the colour of the background (BLACK in this case)
    //     line_plot->draw(BLACK);
    //     redraw_on_first_call_only_graph = true;
    //     double y = log10(x);
    //     line_plot->add_point((double)y);
    //     line_plot->draw();
    // }

    queue = xQueueCreate(1000, sizeof(String*));
	xTaskCreatePinnedToCore(
			drawing_thread_func, /* Function to implement the task */
			"drawing_thread", /* Name of the task */
			10000, /* Stack size in words */
			NULL, /* Task input parameter */
			0, /* Priority of the task */
			&drawing_thread, /* Task handle. */
			(xPortGetCoreID() & 1) ^ 1); /* Core where the task should run */
}

void loop(void) {
    static bool redraw_on_first_call_only_trace4 = true;

    Serial.println("Attempt to access server...");
    status_display.set_status("tcp_connection_status", "Connecting to ZC706 TCP server (" + server_ip_str + ")");
    if (!client.connect(server_ip, server_port)) {
        status_display.set_status("tcp_connection_status", "Failed to connect to ZC706 TCP server (" + server_ip_str + "). Retrying in 5 seconds...");
        Serial.println("Access failed.");
        client.stop();
        delay(5000);
        return;
    }
    status_display.set_status("tcp_connection_status", "Connected to ZC706 TCP server ("+  server_ip_str + ")");

    Serial.println("Access successful.");
    client.print("Hello world!");
    while (client.connected() || client.available()) {
        if (client.available()) {
            // Serial.println("Attempting to read received string.");
            String *line = new String(client.readStringUntil('\n'));
            // String line = client.readString();
            Serial.print("Received: '");
            Serial.print(*line);
            Serial.println("'");

            // check_protocol(line);
            while (xQueueSend(queue, &line, 0) == errQUEUE_FULL) {
                Serial.println("Queue is full, waiting...");
                vTaskDelay(1000 / portTICK_PERIOD_MS);
            }



            //Trace(tft, random(60) / 10.0, (10 - random(20)) / 10.0, 1, 60, 290, 390, 260, 0, 6.5, 1, -1, 1, .25, "Sin(x) + Cos(x) + Tan(x) + new", " x", "fn(x)", redraw_on_first_call_only_trace4, GREEN);
        }
    }
    Serial.println("Closing connection.");
    client.stop();
}
