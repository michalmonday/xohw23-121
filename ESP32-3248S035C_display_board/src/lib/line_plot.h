
#ifndef LINE_PLOT_H
#define LINE_PLOT_H

#include <TFT_eSPI.h>

// forward declaration (to avoid circular dependency)
class GUI_Graph;

class LinePlot {
public:
    // max number of items should probably be equal to the width of the graph in pixels or be half/quarter of it
    LinePlot(TFT_eSPI &tft, double xlo, double xhi, double ylo, double yhi, int color, int max_number_of_items);
    ~LinePlot();
    void draw();
    void draw(unsigned int color_override);
    void draw_line(int i);
    void undraw_line(int i);
    void add_point(double value);
    int get_newest_y_screen_pos();
    double get_newest_value();
    void print_all_values();
    int get_current_number_of_items();
    int get_max_number_of_items();
    int get_min_value();
    int get_max_value();
    unsigned int get_color();
    void set_graph(GUI_Graph *graph);
    void set_top_margin(double top_margin);

    void set_static_upper_limit(double static_yhi) { this->static_yhi = static_yhi; static_yhi_used = true; }
    void set_static_lower_limit(double static_ylo) { this->static_ylo = static_ylo; static_ylo_used = true; }
    void enable_static_upper_limit() { static_yhi_used = true; }
    void enable_static_lower_limit() { static_ylo_used = true; }
    void disable_static_upper_limit() { static_ylo_used = false; }
    void disable_static_lower_limit() { static_ylo_used = false; }

    void record_last_painted_screen_positions();
private:
    TFT_eSPI &tft;
    int current_number_of_items, max_number_of_items;
    int max_value, min_value;
    int graph_x, graph_y, graph_w, graph_h;
    double xlo, xhi, ylo, yhi;
    unsigned int color;
    double static_ylo, static_yhi;
    bool static_ylo_used, static_yhi_used;

    // ------- dynamically allocated arrays ------- //
    // raw values to plot
    double *values;            
    // screen vertical position (computed based on: values, ylo, yhi, graph_y, graph_h), this array is used to avoid unnecessary calculations when moving the plot to the left when new value arrives
    int *values_screen_pos; 
    // screen horizontal position (computed based on: xlo, xhi, graph_x, graph_w), this array is used to avoid unnecessary calculations when moving the plot to the left when new value arrives
    int *x_screen_pos; 
    // stays the same regardless of new scaling allowing to undraw the last painted line
    int *last_painted_values_screen_pos; 
    bool *was_line_drawn;
    GUI_Graph *graph;
    int dropped_value_screen_pos;
    // top_margin determines how to scale the graph (will leave some space on top of the graph above the highest value)
    // if top_margin is 0.1 then 10% of the graph will be left empty above the highest value
    double top_margin;

    void update_min_max_values();
    int calculate_screen_xpos(int index);
    int calculate_screen_ypos(double value);


    void rescale();
};




#endif