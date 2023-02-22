
#include <Arduino.h>
#include <TFT_eSPI.h>

#include "graph.h"
#include "line_plot.h"
#include "colours.h"

Graph::Graph(int graph_x, int graph_y, int graph_w, int graph_h)
    : graph_x(graph_x), graph_y(graph_y), graph_w(graph_w), graph_h(graph_h)
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

int Graph::get_x() {
    return graph_x;
}

int Graph::get_y() {
    return graph_y;
}

int Graph::get_width() {
    return graph_w;
}

int Graph::get_height() {
    return graph_h;
}

void Graph::draw(TFT_eSPI &tft, byte decimal_precision,
                 double xlo, double xhi, int grid_x_segments,
                 double ylo, double yhi, int grid_y_segments,
                 char *title, char *xlabel, char *ylabel,
                 unsigned int grid_color, unsigned int axis_color,
                 unsigned int text_color, unsigned int background_color)
{

    double ydiv, xdiv;
    double i;
    double temp;
    int rot, newrot;

    double x_inc = (xhi - xlo) / (double)grid_x_segments;
    double y_inc = (yhi - ylo) / (double)grid_y_segments;

    tft.setTextDatum(MR_DATUM);
    // draw y scale
    for (i = ylo; i <= yhi; i += y_inc) {
        // compute the transform
        temp = (i - ylo) * (-graph_h) / (yhi - ylo) + graph_y;
        if (i == 0) {
            tft.drawLine(graph_x, temp, graph_x + graph_w, temp, axis_color);
            tft.setTextColor(axis_color, background_color);
            tft.drawString(xlabel, (int)(graph_x + graph_w), (int)temp, 2);
        }
        else {
            tft.drawLine(graph_x, temp, graph_x + graph_w, temp, grid_color);
        }
        // draw the axis labels
        tft.setTextColor(text_color, background_color);
        // precision is default Arduino--this could really use some format control
        tft.drawFloat(i, decimal_precision, graph_x - 4, temp, 1);
    }

    // draw x scale
    for (i = xlo; i <= xhi; i += x_inc) {
        // compute the transform
        temp = (i - xlo) * graph_w / (xhi - xlo) + graph_x;
        if (i == 0) {
            tft.drawLine(temp, graph_y, temp, graph_y - graph_h, axis_color);
            tft.setTextColor(axis_color, background_color);
            tft.setTextDatum(BC_DATUM);
            tft.drawString(ylabel, (int)temp, (int)(graph_y - graph_h - 8), 2);
        } else {
            tft.drawLine(temp, graph_y, temp, graph_y - graph_h, grid_color);
        }
        // draw the axis labels
        tft.setTextColor(text_color, background_color);
        tft.setTextDatum(TC_DATUM);
        // precision is default Arduino--this could really use some format control
        tft.drawFloat(i, decimal_precision, temp, graph_y + 7, 1);
    }
    // now draw the graph labels
    tft.setTextColor(text_color, background_color);
    tft.drawString(title, (int)(graph_x + graph_w / 2), (int)(graph_y - graph_h - 30), 4);
}

