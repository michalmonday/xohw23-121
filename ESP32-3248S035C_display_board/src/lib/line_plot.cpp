
#include <SPI.h>

#include <line_plot.h>
#include <gui_graph.h>

LinePlot::LinePlot(TFT_eSPI &tft, double xlo, double xhi, double ylo, double yhi, int color, int max_number_of_items) : 
tft(tft), xlo(xlo), xhi(xhi), ylo(ylo), yhi(yhi), color(color), current_number_of_items(0), max_number_of_items(max_number_of_items), graph(nullptr),
max_value(INT_MIN), min_value(INT_MAX), dropped_value_screen_pos(-1)
{
    values = new double[max_number_of_items];
    values_screen_pos = new int[max_number_of_items];
    x_screen_pos = new int[max_number_of_items];
}

LinePlot::~LinePlot() {
    delete values;
    delete values_screen_pos;
    delete x_screen_pos;
}

void LinePlot::draw() {
    draw(color);
}

void LinePlot::draw(unsigned int color_override) {
    if (current_number_of_items < 2) 
        return;
    for (int i = 0; i < current_number_of_items - 1; i++) {
        // int x1 = (int)( graph_x + graph_w * i / max_number_of_items);
        // int y1 = (int)( (values[i] - ylo) * (-graph_h) / (yhi - ylo) + graph_y );
        // int x2 = (int)( graph_x + graph_w * (i+1) / max_number_of_items);
        // int y2 = (int)( (values[i+1] - ylo) * (-graph_h) / (yhi - ylo) + graph_y );
        int x1 = x_screen_pos[i];
        int y1 = values_screen_pos[i];
        int x2 = x_screen_pos[i+1];
        int y2 = values_screen_pos[i+1];

        if (dropped_value_screen_pos != -1) {
            // undraw the previous line
            if (i == 0)
                tft.drawLine(x1, dropped_value_screen_pos, x2, y1, TFT_BLACK);
            else
                tft.drawLine(x1, values_screen_pos[i-1], x2, y1, TFT_BLACK);
        }

        // Serial.printf("x1: %d, y1: %d, x2: %d, y2: %d\n", x1, y1, x2, y2);
        // Serial.printf("values[i]: %f, values[i+1]: %f\n", values[i], values[i+1]);
        // Serial.printf("ylo: %f, yhi: %f\n", ylo, yhi);
        // Serial.printf("graph_y: %d, graph_h: %d\n", graph_y, graph_h);
        tft.drawLine(x1, y1, x2, y2, color_override);
    }
}

void LinePlot::update_min_max_values() {
    for (int i = 0; i < current_number_of_items; i++) {
        if (values[i] > max_value)
            max_value = values[i];
        if (values[i] < min_value)
            min_value = values[i];
    }
}

int LinePlot::calculate_screen_ypos(double value) {
    // return (int)( (value - ylo) * (-graph->get_height()) / (yhi - ylo) + graph->get_y() );
    return (int)( graph->get_y() + graph->get_h() * (yhi - value) / (yhi - ylo));
}

int LinePlot::calculate_screen_xpos(int index) {
    return (int)( graph->get_x() + graph->get_w() * index / max_number_of_items) + 1;
}


void LinePlot::add_point(double value) {
    // man mix values update
    if (value > max_value)
        max_value = value;
    if (value < min_value)
        min_value = value;

    // if the line plot is not full, just add the value to the end
    if (current_number_of_items < max_number_of_items) {
        values[current_number_of_items] = value;
        values_screen_pos[current_number_of_items] = calculate_screen_ypos(value);
        x_screen_pos[current_number_of_items] = calculate_screen_xpos(current_number_of_items);
        current_number_of_items++;
        return;
    }
    dropped_value_screen_pos = values_screen_pos[0];

    // if the line plot is full, shift values to the left and add new value to the end
    // if the oldest value was min or max, then we need to update min or max after shifting
    bool need_update_min_max = (values[0] <= min_value || values[0] >= max_value);
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