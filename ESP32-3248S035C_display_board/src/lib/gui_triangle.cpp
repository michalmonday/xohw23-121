#include <gui_triangle.h>

GUI_Triangle::GUI_Triangle(TFT_eSPI *tft, int rotation, int x, int y, int w, int h, int datum, unsigned int border_colour, unsigned int fill_colour, unsigned int background_colour, std::function<void()> on_release_callback)
    : GUI_Element(tft, x, y, w, h, background_colour, [](){}, on_release_callback), datum(datum), border_colour(border_colour), fill_colour(fill_colour), rotation(rotation)
{
    update_location_points();
}

void GUI_Triangle::draw() {
    draw(fill_colour, border_colour);
}

void GUI_Triangle::draw(unsigned int fill_clr_override, unsigned int border_clr_override) {
    tft->fillTriangle(x1, y1, x2, y2, x3, y3, fill_clr_override);
    tft->drawTriangle(x1, y1, x2, y2, x3, y3, border_clr_override);
    needs_redraw = false;
}

void GUI_Triangle::undraw() {
    draw(background_colour, background_colour);
}

void GUI_Triangle::set_rotation(int rotation) {
    this->rotation = rotation;
    update_location_points();
}

void GUI_Triangle::set_datum(int datum) {
    this->datum = datum;
    update_location_points();
}

void GUI_Triangle::update_location_points() {
    switch (rotation) {
        case GUI_TRIANGLE_ROTATION_UP:
            x1 = x;
            y1 = y + h;
            x2 = x + w;
            y2 = y + h;
            x3 = x + w / 2;
            y3 = y;
            break;
        case GUI_TRIANGLE_ROTATION_RIGHT:
            x1 = x;
            y1 = y;
            x2 = x;
            y2 = y + h;
            x3 = x + w;
            y3 = y + h / 2;
            break;
        case GUI_TRIANGLE_ROTATION_DOWN:
            x1 = x;
            y1 = y;
            x2 = x + w;
            y2 = y;
            x3 = x + w / 2;
            y3 = y + h;
            break;
        case GUI_TRIANGLE_ROTATION_LEFT:
            x1 = x + w;
            y1 = y;
            x2 = x + w;
            y2 = y + h;
            x3 = x;
            y3 = y + h / 2;
            break;
    }

// TL_DATUM = 0 = Top left
// TC_DATUM = 1 = Top centre
// TR_DATUM = 2 = Top right
// ML_DATUM = 3 = Middle left
// MC_DATUM = 4 = Middle centre
// MR_DATUM = 5 = Middle right
// BL_DATUM = 6 = Bottom left
// BC_DATUM = 7 = Bottom centre
// BR_DATUM = 8 = Bottom right

    if (datum == TL_DATUM || datum == ML_DATUM || datum == BL_DATUM) {
        // no change because this is the default for x
    } else if (datum == TR_DATUM || datum == MR_DATUM || datum == BR_DATUM) {
        x1 -= w;
        x2 -= w;
        x3 -= w;
    } else if (datum == TC_DATUM || datum == MC_DATUM || datum == BC_DATUM) {
        x1 -= w / 2;
        x2 -= w / 2;
        x3 -= w / 2;
    }

    if (datum == TL_DATUM || datum == TC_DATUM || datum == TR_DATUM) {
        // no change because this is the default for y
    } else if (datum == BL_DATUM || datum == BC_DATUM || datum == BR_DATUM) {
        y1 -= h;
        y2 -= h;
        y3 -= h;
    } else if (datum == ML_DATUM || datum == MC_DATUM || datum == MR_DATUM) {
        y1 -= h / 2;
        y2 -= h / 2;
        y3 -= h / 2;
    }
}

bool GUI_Triangle::contains_point(int x, int y) {
    // check if the point is inside rectangle
    int x_min = min(x1, min(x2, x3));
    int x_max = max(x1, max(x2, x3));
    int y_min = min(y1, min(y2, y3));
    int y_max = max(y1, max(y2, y3));
    return !(x < x_min || x > x_max || y < y_min || y > y_max);
}