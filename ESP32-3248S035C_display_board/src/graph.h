#ifndef GRAPH_ESP32_DISPLAY_H
#define GRAPH_ESP32_DISPLAY_H

#include <map>

// forward declaration (to avoid circular dependency)
class LinePlot;

// This could be a Graph class
// Btw the graph could have its size and position
// Then each plot could have its own "xlo, xhi, ylo, yhi", but with many of these, drawing ticks would be a problem
class Graph {
public:
    Graph(TFT_eSPI &tft);
    Graph(TFT_eSPI &tft, int graph_x, int graph_y, int graph_w, int graph_h, int grid_x_segments, int grid_y_segments);
    ~Graph();
    // LinePlot* add_plot(char *name, TFT_eSPI &tft, int graph_x, int graph_y, int graph_w, int graph_h, double xlo, double xhi, double ylo, double yhi, int color, int max_number_of_items);
    LinePlot* add_plot(String name, LinePlot *plot);
    void remove_plot(String name);
    void remove_all();
    void list_all();
    LinePlot* get_plot(String name);
    void draw_plots();
    void draw_plots(unsigned int color_override);

    void draw(byte decimal_precision,
              double xlo, double xhi,
              double ylo, double yhi,
              char *title, char *xlabel, char *ylabel,
              unsigned int grid_color, unsigned int axis_color,
              unsigned int text_color, unsigned int background_color);

    void draw_legend(unsigned int background_color);

    int get_x();
    int get_y();
    int get_width();
    int get_height();

private:
    TFT_eSPI &tft;
    int graph_x, graph_y, graph_w, graph_h;
    int grid_x_segments, grid_y_segments;
    std::map<String, LinePlot *> line_plots;
};

#endif