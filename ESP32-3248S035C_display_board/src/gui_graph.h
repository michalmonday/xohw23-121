#ifndef GRAPH_ESP32_DISPLAY_H
#define GRAPH_ESP32_DISPLAY_H

#include <Arduino.h>
#include <TFT_eSPI.h>
#include <map>

#include "gui_element.h"
#include "display_config.h"

// forward declaration (to avoid circular dependency)
class LinePlot;

// This could be a Graph class
// Btw the graph could have its size and position
// Then each plot could have its own "xlo, xhi, ylo, yhi", but with many of these, drawing ticks would be a problem
class GUI_Graph : public GUI_Element {
public:
    GUI_Graph(TFT_eSPI *tft);
    GUI_Graph(TFT_eSPI *tft, int graph_x, int graph_y, int graph_w, int graph_h, int grid_x_segments, int grid_y_segments, 
          byte decimal_precision=2, double xlo=0, double xhi=RESOLUTION_X*0.2, double ylo=0, double yhi=1, String title="test", String xlabel="x", String ylabel="y", unsigned int grid_color=DKBLUE, unsigned int axis_color=RED, unsigned int text_color=WHITE, unsigned int background_color=BLACK); 
    ~GUI_Graph();
    // LinePlot* add_plot(char *name, TFT_eSPI &tft, int graph_x, int graph_y, int graph_w, int graph_h, double xlo, double xhi, double ylo, double yhi, int color, int max_number_of_items);
    LinePlot* add_plot(String name, LinePlot *plot);
    void remove_plot(String name);
    void remove_all();
    void list_all();
    LinePlot* get_plot(String name);
    void draw_plots();
    void draw_plots(unsigned int color_override);

    void draw() override;
    // void draw(byte decimal_precision,
    //           double xlo, double xhi,
    //           double ylo, double yhi,
    //           char *title, char *xlabel, char *ylabel,
    //           unsigned int grid_color, unsigned int axis_color,
    //           unsigned int text_color, unsigned int background_color);

    void draw_legend(unsigned int background_color);

private:
    int grid_x_segments, grid_y_segments;
    std::map<String, LinePlot *> line_plots;

    byte decimal_precision;
    double xlo;
    double xhi;
    double ylo;
    double yhi;
    String title;
    String xlabel;
    String ylabel;
    unsigned int grid_color;
    unsigned int axis_color;
    unsigned int text_color;
    unsigned int background_color;
};

#endif