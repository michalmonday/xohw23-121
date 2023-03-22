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

#include <map>
#include <vector>

#include <gui_graph.h>
#include <line_plot.h>
#include <colours.h>
#include <display_config.h>


const int default_graph_x = (int)(RESOLUTION_X * 0.1);
const int default_graph_y = (int)(RESOLUTION_Y * 0.1); 
const int default_graph_w = (int)(RESOLUTION_X * 0.2); 
const int default_graph_h = (int)(RESOLUTION_Y * 0.7); 
const int default_grid_x_segments = 1;
const int default_grid_y_segments = 4;
const int default_decimal_precision = 2;
const int default_xlo = 0;
const int default_xhi = 100;
const int default_ylo = 0;
const int default_yhi = 1;
const String default_title = "";
const String default_xlabel = "";
const String default_ylabel = "";
const unsigned int default_grid_color = BLUE;
const unsigned int default_axis_color = RED;
const unsigned int default_text_color = WHITE;
const unsigned int default_background_color = BLACK;

GUI_Graph::GUI_Graph(TFT_eSPI *tft) 
    : GUI_Element(tft, default_graph_x, default_graph_y, default_graph_w, default_graph_h), grid_x_segments(default_grid_x_segments), grid_y_segments(default_grid_y_segments),
        decimal_precision(default_decimal_precision), xlo(default_xlo), xhi(default_xhi), ylo(default_ylo), yhi(default_yhi), title(default_title), xlabel(default_xlabel), 
        ylabel(default_ylabel), grid_color(default_grid_color), axis_color(default_axis_color), text_color(default_text_color), background_color(default_background_color),
        legend_enabled(true), grid_enabled(true), axes_enabled(true), axis_labels_enabled(true), current_value_display_enabled(false), current_value_display_width(RESOLUTION_X*0.07), current_value_diplay_font_size(1)
{
}

GUI_Graph::GUI_Graph(TFT_eSPI *tft, int graph_x, int graph_y, int graph_w, int graph_h, int grid_x_segments, int grid_y_segments,
             byte decimal_precision, double xlo, double xhi, double ylo, double yhi, String title, String xlabel, String ylabel, unsigned int grid_color, unsigned int axis_color, unsigned int text_color, unsigned int background_color)
    : GUI_Element(tft, graph_x, graph_y, graph_w, graph_h), grid_x_segments(grid_x_segments), grid_y_segments(grid_y_segments),
      decimal_precision(decimal_precision), xlo(xlo), xhi(xhi), ylo(ylo), yhi(yhi), title(title), xlabel(xlabel),
      ylabel(ylabel), grid_color(grid_color), axis_color(axis_color), text_color(text_color), background_color(background_color), 
      legend_enabled(true), grid_enabled(true), axes_enabled(true), axis_labels_enabled(true), current_value_display_enabled(false), current_value_display_width(RESOLUTION_X*0.07), current_value_diplay_font_size(1)
{
}

GUI_Graph::~GUI_Graph() {
    remove_all();

    // need to delete current_value_labels if destructor is ever to be used
}

void GUI_Graph::remove_all() {
    // delete all plots from line_plots map
    for (auto it = line_plots.begin(); it != line_plots.end(); ++it) {
        delete it->second;
    }
    line_plots.clear();
}

LinePlot* GUI_Graph::add_plot(String name, LinePlot* line_plot) {
    if (line_plots.find(name) != line_plots.end()) {
        Serial.printf("Plot with name %s already exists\n", name.c_str());
        return nullptr;
    }
    line_plots[name] = line_plot;
    Serial.printf("Added plot with name %s\n", name.c_str());
    line_plot->set_graph(this);
    if (legend_enabled)
        draw_legend(background_color);
    
    current_value_labels[line_plot] = new GUI_Label(tft, "-", x + w + 5, line_plot->get_newest_y_screen_pos(), current_value_diplay_font_size, ML_DATUM, line_plot->get_color(), background_color);
    current_value_labels[line_plot]->disable_background();
    add_child_element(current_value_labels[line_plot]);
    return line_plot;
}

void GUI_Graph::list_all() {
    Serial.println("Listing all plots:");
    for (auto const &x : line_plots) {
        Serial.printf("- %s\n", x.first);
    }
}

void GUI_Graph::remove_plot(String name) {
    if (line_plots.find(name) == line_plots.end()) {
        Serial.printf("Plot with name %s does not exist\n", name.c_str());
        return;
    }
    delete line_plots[name];
    line_plots.erase(name);
    Serial.printf("Removed plot with name %s\n", name);
}

LinePlot* GUI_Graph::get_plot(String name) {
    if (line_plots.find(name) == line_plots.end()) {
        Serial.printf("Plot with name %s does not exist\n", name.c_str());
        return nullptr;
    }
    return line_plots[name];
}

void GUI_Graph::draw_plots() {
    if (grid_enabled)
        draw_grid();
    // for (auto it = line_plots.begin(); it != line_plots.end(); ++it) 
    //     it->second->draw();

    // for (int i = ((int)xhi) - 2; i >= 0; i--) {
    for (int i = 0; i < (int)xhi; i++) {
        // Serial.printf("Drawing line %d\n", i);
        int j = 0;
        for (auto it = line_plots.begin(); it != line_plots.end(); ++it) {
            it->second->undraw_line(i); 
            j++;
        }
        j = 0;
        for (auto it = line_plots.begin(); it != line_plots.end(); ++it) {
            it->second->draw_line(i); 
            j++;
        }
    }

    for(auto it = line_plots.begin(); it != line_plots.end(); ++it) {
        it->second->record_last_painted_screen_positions();
    }

    if (current_value_display_enabled)
        draw_current_values();
}

// void GUI_Graph::draw_plots(unsigned int color_override) {
//     if (grid_enabled)
//         draw_grid();
//     for (auto it = line_plots.begin(); it != line_plots.end(); ++it) 
//         it->second->draw(color_override);
// }

void GUI_Graph::draw_legend(unsigned int background_color) {
    tft->setTextDatum(TL_DATUM);
    tft->setTextSize(1);
    const int legend_w = (int)(RESOLUTION_X * 0.15);
    int legend_x = x + w + 5;

    if (current_value_display_enabled)
        legend_x += current_value_display_width;

    tft->fillRect(legend_x, y + 1, legend_w, h - 1, background_color);
    
    int legend_y = y + 7;
    int offset_y = 0;
    for (auto it = line_plots.begin(); it != line_plots.end(); ++it) {
        unsigned int line_color = it->second->get_color();
        tft->setTextColor(line_color, background_color);
        tft->drawString(it->first, legend_x + 5, legend_y + offset_y, 1);
        offset_y += 15;
    }
}

void GUI_Graph::draw_current_values() {
    // Draws numeric values next to the latest values of each plot

    // map is sorted by keys

    // Serial.println("Y positions:");
    std::multimap<int, LinePlot*> y_positions;
    for (auto it = line_plots.begin(); it != line_plots.end(); ++it) {
        y_positions.insert(std::make_pair(it->second->get_newest_y_screen_pos(), it->second));
        // Serial.printf("y_pos: %d\n", it->second->get_newest_y_screen_pos());
    }
    
    // middle vertically, left horizontally
    tft->setTextDatum(ML_DATUM);
    tft->setTextSize(current_value_diplay_font_size);

    int font_height = tft->fontHeight(current_value_diplay_font_size);

    int prev_pos = -1;
    int i = 0;
    for (auto it = y_positions.begin(); it != y_positions.end(); ++it) {
        // Serial.printf("i: %d y_pos=%d\n", i, it->first);
        i++; 
        int y_pos = it->first;
        // to avoid overlapping
        if (prev_pos != -1) {
            if (y_pos - font_height < prev_pos) {
                // Serial.printf("Overlapping! y_pos: %d, prev_pos: %d, font_height: %d\n", y_pos, prev_pos, font_height);
                y_pos += prev_pos - (y_pos - font_height);
                // Serial.printf("New y_pos: %d\n", y_pos);
            }
        }
        LinePlot* line_plot = it->second;
        tft->setTextColor(line_plot->get_color());
        String value = String(line_plot->get_newest_value());
        if (value.endsWith(".00")) {
            value = value.substring(0, value.length() - 3);
        } 
        // tft->drawString(value, x + w + 5, y_pos);
        GUI_Label *label = current_value_labels[line_plot];
        if (label->get_text() != value) 
            label->set_text(value);
        if (label->get_y() != y_pos) 
            label->set_y(y_pos);
        prev_pos = y_pos;
    }

    for (auto it = current_value_labels.begin(); it != current_value_labels.end(); ++it) {
        it->second->draw();
    }
}

// void GUI_Graph::draw() {
//     draw_plots();
//     draw_legend(DKGREY); 
// }

// void GUI_Graph::draw(byte decimal_precision,
//                  double xlo, double xhi,
//                  double ylo, double yhi,
//                  char *title, char *xlabel, char *ylabel,
//                  unsigned int grid_color, unsigned int axis_color,
//                  unsigned int text_color, unsigned int background_color)

void GUI_Graph::draw() {
    GUI_Element::draw();
    Serial.println("Drawing graph...");
    // peserve old settings
    unsigned int old_text_color = tft->textcolor;
    int old_text_size = tft->textsize;
    uint8_t old_datum = tft->getTextDatum();

    tft->setTextDatum(MR_DATUM);
    tft->setTextSize(1);


    double x_inc = (xhi - xlo) / (double)grid_x_segments;
    double y_dec = (yhi - ylo) / (double)grid_y_segments;
    double x_val = xlo;
    double y_val = yhi;
    // draw horizontal lines
    for (int i = 0; i <= grid_y_segments; i++) {
        int current_y = y + (i * h / grid_y_segments);
        // horizontal grid line
        if (grid_enabled)
            tft->drawLine(x, current_y, x + w, current_y, grid_color);

        if (axes_enabled && axis_labels_enabled) {
            Serial.printf("Drawing horizontal line at %d\n", current_y);
            // horizontal line label
            tft->setTextColor(text_color, background_color);
            // precision is default Arduino--this could really use some format control
            tft->drawFloat(y_val, decimal_precision, x - 4, current_y, 1);
        }
        y_val -= y_dec;
    }

    // draw vertical lines
    for (int i = 0; i <= grid_x_segments; i++) {
        int current_x = x + (i * w / grid_x_segments);
        // vertical grid line
        if (grid_enabled)
            tft->drawLine(current_x, y, current_x, y + h, grid_color);
        if (axes_enabled && axis_labels_enabled) {
            // vertical line label
            tft->setTextColor(text_color, background_color);
            // precision is default Arduino--this could really use some format control
            tft->drawFloat(x_val, decimal_precision, current_x, y + h + 7, 1);
        }
        x_val += x_inc;
    }

    if (axes_enabled) {
        // vertical axis line
        tft->drawLine(x, y, x, y + h, axis_color);

        // horizontal axis line (depends if y range contains 0)
        int bottom = y + h;
        if (ylo >= 0 && yhi <= 0) {
            // draw line at 0
            int zero_y = y + (yhi / (yhi - ylo)) * h;
            tft->drawLine(x, zero_y, x + w, zero_y, axis_color);
        } else {
            // draw line at bottom
            tft->drawLine(x, bottom+1, x + w, bottom+1, axis_color);
        }
    }


    tft->setTextColor(text_color, background_color);
    tft->setTextDatum(BC_DATUM);
    tft->setTextSize(1);
    tft->drawString(title, x + w / 2, y - tft->fontHeight(2) / 2);

    // restore old settings
    tft->setTextColor(old_text_color);
    tft->setTextSize(old_text_size);
    tft->setTextDatum(old_datum);

    draw_plots();

    if (legend_enabled)
        draw_legend(background_color);
}

void GUI_Graph::draw_grid() {
    double x_inc = (xhi - xlo) / (double)grid_x_segments;
    double y_dec = (yhi - ylo) / (double)grid_y_segments;
    double x_val = xlo;
    double y_val = yhi;
    // draw horizontal lines
    for (int i = 0; i <= grid_y_segments; i++) {
        int current_y = y + (i * h / grid_y_segments);
        // horizontal grid line
        tft->drawLine(x, current_y, x + w, current_y, grid_color);
    }

    // draw vertical lines
    for (int i = 0; i <= grid_x_segments; i++) {
        int current_x = x + (i * w / grid_x_segments);
        // vertical grid line
        tft->drawLine(current_x, y, current_x, y + h, grid_color);
    }

    // vertical axis line
    tft->drawLine(x, y, x, y + h, axis_color);

    // horizontal axis line (depends if y range contains 0)
    int bottom = y + h;
    if (ylo >= 0 && yhi <= 0) {
        // draw line at 0
        int zero_y = y + (yhi / (yhi - ylo)) * h;
        tft->drawLine(x, zero_y, x + w, zero_y, axis_color);
    } else {
        // draw line at bottom
        tft->drawLine(x, bottom, x + w, bottom, axis_color);
    }
}