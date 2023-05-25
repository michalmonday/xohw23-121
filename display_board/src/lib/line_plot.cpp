
#include <SPI.h>

#include <line_plot.h>
#include <gui_graph.h>

LinePlot::LinePlot(Graphics *gfx, double xlo, double xhi, double ylo, double yhi, int color, int max_number_of_items) : 
gfx(gfx), xlo(xlo), xhi(xhi), ylo(ylo), yhi(yhi), color(color), current_number_of_items(0), max_number_of_items(max_number_of_items), graph(nullptr),
max_value(INT_MIN), min_value(INT_MAX), dropped_value_screen_pos(-1), static_ylo(0), static_yhi(1), static_yhi_used(false), static_ylo_used(true), top_margin(0.0)
{
    values = new double[max_number_of_items];
    values_screen_pos = new int[max_number_of_items];
    x_screen_pos = new int[max_number_of_items];
    last_painted_values_screen_pos = new int[max_number_of_items];
    was_line_drawn = new bool[max_number_of_items];
    for (int i = 0; i < max_number_of_items; i++) {
        values[i] = 0;
        values_screen_pos[i] = 0;
        x_screen_pos[i] = 0;
        last_painted_values_screen_pos[i] = 0;
        was_line_drawn[i] = false;
    }
}

LinePlot::~LinePlot() {
    delete values;
    delete values_screen_pos;
    delete x_screen_pos;
    delete last_painted_values_screen_pos;
    delete was_line_drawn;
}

void LinePlot::draw() {
    draw(color);
}

void LinePlot::draw(unsigned int color_override) {
    if (current_number_of_items < 2) 
        return;
    for (int i = current_number_of_items-2; i >= 0; i--) {
        undraw_line(i);
        draw_line(i);
    }
}

void LinePlot::draw_line(int i) {
    if (i < 0 || i >= current_number_of_items - 1)
        return;
    was_line_drawn[i] = true;
    gfx->drawLine(x_screen_pos[i], values_screen_pos[i], x_screen_pos[i+1], values_screen_pos[i+1], color);
}

void LinePlot::undraw_line(int i) {
    if (i < 0 || i >= current_number_of_items - 1 || !was_line_drawn[i])
        return;
    gfx->drawLine(x_screen_pos[i], last_painted_values_screen_pos[i], x_screen_pos[i+1], last_painted_values_screen_pos[i+1], graph->get_background_color());
}

void LinePlot::update_min_max_values() {
    if (!static_yhi_used && !static_ylo_used) return;
    for (int i = 0; i < current_number_of_items; i++) {
        if (values[i] > yhi && !static_yhi_used)
            yhi = values[i];
        if (values[i] < ylo && !static_ylo_used)
            ylo = values[i];
    }
}

void LinePlot::record_last_painted_screen_positions() {
    for (int i = 0; i < current_number_of_items; i++)
        last_painted_values_screen_pos[i] = values_screen_pos[i];
}

int LinePlot::calculate_screen_ypos(double value) {
    // return (int)( (value - ylo) * (-graph->get_height()) / (yhi - ylo) + graph->get_y() );
    double effective_yhi = yhi + top_margin * (yhi - ylo);
    if (effective_yhi == 0)
        effective_yhi = 1;
    
    // this will cap value if it's outside of static_yhi or static_ylo 
    // (to avoid drawing outside of the graph even if the value is out of range which it shouln't be)
    if (value > yhi)
        value = yhi;
    if (value < ylo)
        value = ylo;

    return (int)( graph->get_y() + graph->get_h() * (effective_yhi - value) / (effective_yhi - ylo));
}

int LinePlot::calculate_screen_xpos(int index) {
    return (int)( graph->get_x() + graph->get_w() * index / (max_number_of_items-1)) + 1;
}

void LinePlot::rescale() {
    for (int i = 0; i < current_number_of_items; i++) 
        values_screen_pos[i] = calculate_screen_ypos(values[i]);
}


void LinePlot::add_point(double value) {
    // man mix values update
    bool scale_changed = false;
    if (value > yhi || value < ylo) {
        scale_changed = true;
        if (value > yhi && !static_yhi_used)
            yhi = value;
        if (value < ylo && !static_ylo_used)
            ylo = value;
    }


    // if the line plot is not full, just add the value to the end
    if (current_number_of_items < max_number_of_items) {
        values[current_number_of_items] = value;
        values_screen_pos[current_number_of_items] = calculate_screen_ypos(value);
        x_screen_pos[current_number_of_items] = calculate_screen_xpos(current_number_of_items);
        current_number_of_items++;
        if (scale_changed)
            rescale();
        return;
    }
    dropped_value_screen_pos = values_screen_pos[0];

    // if the line plot is full, shift values to the left and add new value to the end
    // if the oldest value was min or max, then we need to update min or max after shifting
    bool need_update_min_max = (values[0] <= ylo || values[0] >= yhi && (static_ylo_used || static_yhi_used));
    if (need_update_min_max) {
        // assign yhi o minimum double value
        yhi = static_yhi_used ? static_yhi : std::numeric_limits<double>::min();
        ylo = static_ylo_used ? static_ylo : std::numeric_limits<double>::max();
        for (int i = 1; i < max_number_of_items; i++) {
            if (values[i] > yhi && !static_yhi_used)
                yhi = values[i];
            if (values[i] < ylo && !static_ylo_used)
                ylo = values[i];
        }
        if (value > yhi && !static_yhi_used)
            yhi = value;
        if (value < ylo && !static_ylo_used)
            ylo = value;
        scale_changed = true;
    }

    if (scale_changed)
        rescale();

    for (int i = 0; i < max_number_of_items - 1; i++) {
        values[i] = values[i + 1];
        values_screen_pos[i] = values_screen_pos[i + 1];
        // x_screen_pos[i] = x_screen_pos[i + 1];
    }
    int i = max_number_of_items - 1; 
    values[i] = value;
    values_screen_pos[i] = calculate_screen_ypos(value);
    // x_screen_pos[i] = calculate_screen_xpos(current_number_of_items);
    update_min_max_values();
}

void LinePlot::print_all_values() {
    for (int i = 0; i < current_number_of_items; i++) {
        Serial.print(values[i]);
        Serial.print(", ");
    }
    Serial.println();
}

int LinePlot::get_current_number_of_items() { return current_number_of_items; }
int LinePlot::get_max_number_of_items() { return max_number_of_items; }
void LinePlot::set_graph(GUI_Graph *graph) { this->graph = graph; }
unsigned int LinePlot::get_color() { return color; }
int LinePlot::get_newest_y_screen_pos() { 
    if (current_number_of_items == 0)
        return -1;
    return values_screen_pos[current_number_of_items - 1]; 
}
double LinePlot::get_newest_value() {
    if (current_number_of_items == 0)
        return -1;
    return values[current_number_of_items - 1]; 
}

void LinePlot::set_top_margin(double tm) {
    top_margin = tm; 
}