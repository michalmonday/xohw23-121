#ifndef GRAPH_ESP32_DISPLAY_H
#define GRAPH_ESP32_DISPLAY_H

#include <Arduino.h>
#include <map>

#include <gui_element.h>
#include <gui_label.h>
#include <display_config.h>

#include "graphics.h"

// forward declaration (to avoid circular dependency)
class LinePlot;

// This could be a Graph class
// Btw the graph could have its size and position
// Then each plot could have its own "xlo, xhi, ylo, yhi", but with many of these, drawing ticks would be a problem
class GUI_Graph : public GUI_Element {
public:
    GUI_Graph(Graphics *gfx);
    GUI_Graph(Graphics *gfx, int graph_x, int graph_y, int graph_w, int graph_h, int grid_x_segments, int grid_y_segments, 
          byte decimal_precision=2, double xlo=0, double xhi=RESOLUTION_X*0.2, double ylo=0, double yhi=1, String title="test", String xlabel="x", String ylabel="y", unsigned int grid_color=DKBLUE, unsigned int axis_color=RED, unsigned int text_color=WHITE, unsigned int background_color=BLACK); 
    ~GUI_Graph();
    // LinePlot* add_plot(char *name, Graphics &gfx, int graph_x, int graph_y, int graph_w, int graph_h, double xlo, double xhi, double ylo, double yhi, int color, int max_number_of_items);
    LinePlot* add_plot(String name, LinePlot *plot);
    void remove_plot(String name);
    void remove_all();
    void list_all();
    LinePlot* get_plot(String name);
    void draw_plots();
    // void draw_plots(unsigned int color_override);

    void draw() override;
    // void draw(byte decimal_precision,
    //           double xlo, double xhi,
    //           double ylo, double yhi,
    //           char *title, char *xlabel, char *ylabel,
    //           unsigned int grid_color, unsigned int axis_color,
    //           unsigned int text_color, unsigned int background_color);

    void draw_legend(unsigned int clr);
    void hide_legend() { legend_enabled = false; needs_redraw = true; }
    void show_legend() { legend_enabled = true;  needs_redraw = true; }
    void hide_grid()   { grid_enabled = false;   needs_redraw = true; }
    void show_grid()   { grid_enabled = true;    needs_redraw = true; }
    void hide_axes()   { axes_enabled = false;   needs_redraw = true; }
    void show_axes()   { axes_enabled = true;    needs_redraw = true; }
    void hide_axis_labels() { axis_labels_enabled = false; needs_redraw = true; }
    void show_axis_labels() { axis_labels_enabled = true;  needs_redraw = true; }
    void show_current_value_display() { current_value_display_enabled = true; needs_redraw = true; }
    void hide_current_value_display() { current_value_display_enabled = false; needs_redraw = true; }

    void draw_grid();

    unsigned int get_background_color() { return background_color; }
    void set_title_font_size(int font_size) { title_font_size = font_size; needs_redraw = true; }
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
    bool legend_enabled;
    bool grid_enabled;
    bool axes_enabled;
    bool axis_labels_enabled;
    bool current_value_display_enabled;

    int current_value_display_width;
    int current_value_diplay_font_size;
    int legend_font_size;
    int title_font_size;
    std::map<LinePlot *, GUI_Label *> current_value_labels;
    void draw_current_values();
};

#endif