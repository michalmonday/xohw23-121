
#ifndef LINE_PLOT_H
#define LINE_PLOT_H

#include <TFT_eSPI.h>

// forward declaration (to avoid circular dependency)
class Graph;

class LinePlot {
public:
    // max number of items should probably be equal to the width of the graph in pixels or be half/quarter of it
    LinePlot(TFT_eSPI &tft, double xlo, double xhi, double ylo, double yhi, int color, int max_number_of_items);
    ~LinePlot();
    void draw();
    void draw(unsigned int color_override);
    void add_point(double value);
    void print_all_values();
    int get_current_number_of_items();
    int get_max_number_of_items();
    int get_min_value();
    int get_max_value();
    unsigned int get_color();
    void set_graph(Graph *graph);
private:
    TFT_eSPI &tft;
    int current_number_of_items, max_number_of_items;
    int max_value, min_value;
    int graph_x, graph_y, graph_w, graph_h;
    double xlo, xhi, ylo, yhi;
    unsigned int color;

    // ------- dynamically allocated arrays ------- //
    // raw values to plot
    double *values;            
    // screen vertical position (computed based on: values, ylo, yhi, graph_y, graph_h), this array is used to avoid unnecessary calculations when moving the plot to the left when new value arrives
    int *values_screen_pos; 
    // screen horizontal position (computed based on: xlo, xhi, graph_x, graph_w), this array is used to avoid unnecessary calculations when moving the plot to the left when new value arrives
    int *x_screen_pos; 

    Graph *graph;

    void update_min_max_values();
    int calculate_screen_xpos(int index);
    int calculate_screen_ypos(double value);

};




#endif