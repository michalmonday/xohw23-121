// The code responsible for drawing a graph is based on Graph_2 example from TFT_eSPI library. 
// It was rewritten, simplified and now uses the commonly used coordinate system (y increases towards bottom).
//
// The original file has the following comment at the top of the file:
// 
//     This program provides cartesian type graph function.
//
//     Revisions
//     rev     date        author      description
//     1       12-24-2015  kasprzak    initial creation
//
//     Updated by Bodmer to be an example for the library here:
//     https://github.com/Bodmer/TFT_eSPI

#include <Arduino.h>
#include <TFT_eSPI.h>

#include "graph.h"
#include "line_plot.h"
#include "colours.h"
#include "display_config.h"

const int default_graph_x = (int)(RESOLUTION_X * 0.1);
const int default_graph_y = (int)(RESOLUTION_Y * 0.1); 
// const int default_graph_w = (int)(RESOLUTION_X * 0.7); 
const int default_graph_w = (int)(RESOLUTION_X * 0.2); 
const int default_graph_h = (int)(RESOLUTION_Y * 0.7); 
int default_grid_x_segments = 1;
int default_grid_y_segments = 4;

Graph::Graph(TFT_eSPI &tft) 
    : tft(tft), graph_x(default_graph_x), graph_y(default_graph_y), graph_w(default_graph_w), graph_h(default_graph_h), grid_x_segments(default_grid_x_segments), grid_y_segments(default_grid_y_segments)
{
}

Graph::Graph(TFT_eSPI &tft, int graph_x, int graph_y, int graph_w, int graph_h, int grid_x_segments, int grid_y_segments)
    : tft(tft), graph_x(graph_x), graph_y(graph_y), graph_w(graph_w), graph_h(graph_h), grid_x_segments(grid_x_segments), grid_y_segments(grid_y_segments)
{
}

Graph::~Graph() {
    remove_all();
}

void Graph::remove_all() {
    // delete all plots from line_plots map
    for (auto it = line_plots.begin(); it != line_plots.end(); ++it) {
        delete it->second;
    }
    line_plots.clear();
}

LinePlot* Graph::add_plot(String name, LinePlot* line_plot) {
    if (line_plots.find(name) != line_plots.end()) {
        Serial.printf("Plot with name %s already exists\n", name);
        return nullptr;
    }
    line_plots[name] = line_plot;
    Serial.printf("Added plot with name %s\n", name);
    line_plot->set_graph(this);
    draw_legend(DKGREY);
    return line_plot;
}

void Graph::list_all() {
    Serial.println("Listing all plots:");
    for (auto const &x : line_plots) {
        Serial.printf("- %s\n", x.first);
    }
}

void Graph::remove_plot(String name) {
    if (line_plots.find(name) == line_plots.end()) {
        Serial.printf("Plot with name %s does not exist\n", name);
        return;
    }
    delete line_plots[name];
    line_plots.erase(name);
    Serial.printf("Removed plot with name %s\n", name);
}

LinePlot* Graph::get_plot(String name) {
    if (line_plots.find(name) == line_plots.end()) {
        Serial.printf("Plot with name %s does not exist\n", name);
        return nullptr;
    }
    return line_plots[name];
}

void Graph::draw_plots() {
    for (auto it = line_plots.begin(); it != line_plots.end(); ++it) 
        it->second->draw();
}

void Graph::draw_plots(unsigned int color_override) {
    for (auto it = line_plots.begin(); it != line_plots.end(); ++it) 
        it->second->draw(color_override);
}

void Graph::draw_legend(unsigned int background_color) {
    const int legend_w = (int)(RESOLUTION_X * 0.15);
    int legend_x = graph_x + graph_w + 5;
    tft.fillRect(legend_x, graph_y + 1, legend_w, graph_h - 1, background_color);
    
    int legend_y = graph_y + 7;
    int offset_y = 0;
    for (auto it = line_plots.begin(); it != line_plots.end(); ++it) {
        unsigned int line_color = it->second->get_color();
        tft.setTextColor(line_color, background_color);
        tft.drawString(it->first, legend_x + 5, legend_y + offset_y, 1);
        offset_y += 15;
    }
}

int Graph::get_x() { return graph_x; }
int Graph::get_y() { return graph_y; }
int Graph::get_width() { return graph_w; }
int Graph::get_height() { return graph_h; }

void Graph::draw(byte decimal_precision,
                 double xlo, double xhi,
                 double ylo, double yhi,
                 char *title, char *xlabel, char *ylabel,
                 unsigned int grid_color, unsigned int axis_color,
                 unsigned int text_color, unsigned int background_color)
{
    // peserve old settings
    unsigned int old_text_color = tft.textcolor;
    int old_text_size = tft.textsize;
    uint8_t old_datum = tft.getTextDatum();

    tft.setTextDatum(MR_DATUM);

    double x_inc = (xhi - xlo) / (double)grid_x_segments;
    double y_dec = (yhi - ylo) / (double)grid_y_segments;
    double x_val = xlo;
    double y_val = yhi;
    // draw horizontal lines
    for (int i = 0; i <= grid_y_segments; i++) {
        int current_y = graph_y + (i * graph_h / grid_y_segments);
        // horizontal grid line
        tft.drawLine(graph_x, current_y, graph_x + graph_w, current_y, grid_color);
        Serial.printf("Drawing horizontal line at %d\n", current_y);
        // horizontal line label
        tft.setTextColor(text_color, background_color);
        // precision is default Arduino--this could really use some format control
        tft.drawFloat(y_val, decimal_precision, graph_x - 4, current_y, 1);
        y_val -= y_dec;
    }

    // draw vertical lines
    for (int i = 0; i <= grid_x_segments; i++) {
        int current_x = graph_x + (i * graph_w / grid_x_segments);
        // vertical grid line
        tft.drawLine(current_x, graph_y, current_x, graph_y + graph_h, grid_color);
        // vertical line label
        tft.setTextColor(text_color, background_color);
        // precision is default Arduino--this could really use some format control
        tft.drawFloat(x_val, decimal_precision, current_x, graph_y + graph_h + 7, 1);
        x_val += x_inc;
    }

    // vertical axis line
    tft.drawLine(graph_x, graph_y, graph_x, graph_y + graph_h, axis_color);

    // horizontal axis line (depends if y range contains 0)
    int bottom = graph_y + graph_h;
    if (ylo >= 0 && yhi <= 0) {
        // draw line at 0
        int zero_y = graph_y + (yhi / (yhi - ylo)) * graph_h;
        tft.drawLine(graph_x, zero_y, graph_x + graph_w, zero_y, axis_color);
    } else {
        // draw line at bottom
        tft.drawLine(graph_x, bottom, graph_x + graph_w, bottom, axis_color);
    }

    tft.setTextColor(text_color, background_color);
    tft.drawString(title, graph_x + graph_w / 2, graph_y - 10, 2);

    // restore old settings
    tft.setTextColor(old_text_color);
    tft.setTextSize(old_text_size);
    tft.setTextDatum(old_datum);
}

