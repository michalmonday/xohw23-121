#include <gui_label.h>


// -------------------------------
// ---------- GUI_Label ----------
GUI_Label::GUI_Label(TFT_eSPI *tft, String text, int x, int y, int font_size, int datum, unsigned int text_colour, unsigned int background_colour, std::function<void()> on_press_callback, std::function<void()> on_release_callback, double padding_x, double padding_y) :
    GUI_Element(tft, x, y, tft->textWidth(text), tft->fontHeight(font_size), background_colour, on_press_callback, on_release_callback), datum(datum), text_color(text_colour), font_size(font_size), padding_x(padding_x), padding_y(padding_y)
{
    if (datum == TL_DATUM || datum == ML_DATUM || datum == BL_DATUM) {
        left_x = this->x;
    } else if (datum == TC_DATUM || datum == MC_DATUM || datum == BC_DATUM) {
        left_x = this->x - w/2;
    } else if (datum == TR_DATUM || datum == MR_DATUM || datum == BR_DATUM) {
        left_x = this->x - w;
    }

    if (datum == TL_DATUM || datum == TC_DATUM || datum == TR_DATUM) {
        top_y = this->y;
    } else if (datum == ML_DATUM || datum == MC_DATUM || datum == MR_DATUM) {
        top_y = this->y - h/2;
    } else if (datum == BL_DATUM || datum == BC_DATUM || datum == BR_DATUM) {
        top_y = this->y - h;
    }
    update_touch_area();
    set_text(text);
}

void GUI_Label::update_touch_area() {
    touch_left_x = left_x - padding_x * w;
    touch_right_x = left_x + w + padding_x * w;
    touch_top_y = top_y - padding_y * h;
    touch_bottom_y = top_y + h + padding_y * h;
}

void GUI_Label::draw(unsigned int clr_override) {
    if (background_enabled)
        tft->fillRect(left_x, top_y, w, h, background_colour);
        // tft->fillRect(left_x, top_y, w, h, DKRED);

    // draw touch area
    tft->fillRect(touch_left_x, touch_top_y, touch_right_x - touch_left_x, touch_bottom_y - touch_top_y, DKRED);

    tft->setTextSize(font_size);
    tft->setTextDatum(datum);
    tft->setTextColor(clr_override);
    tft->drawString(text, x, y);
    needs_redraw = false;
}

void GUI_Label::draw() {
    draw(text_color);
}

void GUI_Label::undraw() {
    // GUI_Element::undraw();
    // paint over the label with the background colour
    Serial.printf("Undrawing label '%s' at (%d, %d) with size (%d, %d)\n", text.c_str(), x, y, w, h);
    tft->setTextSize(font_size);
    tft->setTextDatum(datum);
    tft->setTextColor(background_colour);
    // tft->setTextColor(RED);
    tft->drawString(text, x, y);
    // tft->fillRect(x - w/2, y - h/2, w, h, background_colour);
}

void GUI_Label::set_y(int y) { undraw(); GUI_Element::set_y(y); update_touch_area(); }
void GUI_Label::set_x(int x) { undraw(); GUI_Element::set_x(x); update_touch_area(); }
void GUI_Label::set_w(int w) { undraw(); GUI_Element::set_w(w); update_touch_area(); }
void GUI_Label::set_h(int h) { undraw(); GUI_Element::set_h(h); update_touch_area(); }

void GUI_Label::set_font_size(int font_size) {
    undraw();
    this->font_size = font_size;
    tft->setTextSize(font_size);
    w = tft->textWidth(text);
    h = tft->fontHeight(font_size);
    update_touch_area();
    needs_redraw = true;
}

void GUI_Label::set_text(String text) {
    undraw();
    this->text = text;
    tft->setTextSize(font_size);
    w = tft->textWidth(text);
    h = tft->fontHeight(font_size);
    update_touch_area();
    needs_redraw = true;
}

void GUI_Label::on_release() {
    GUI_Element::on_release();
    needs_redraw = true;
    // background_colour = DKGREY;
    // Serial.println("Label '" + text + "' touched");
    // needs_redraw = true;
}

void GUI_Label::on_press() {
    GUI_Element::on_press();
    draw(YELLOW);
    // background_colour = WHITE;
    // needs_redraw = true;
}

bool GUI_Label::contains_point(int point_x, int point_y) {
    return  point_x >= touch_left_x &&
            point_x <= touch_right_x &&
            point_y >= touch_top_y &&
            point_y <= touch_bottom_y;
}

void GUI_Label::set_padding_x(double padding_x) {
    this->padding_x = padding_x;
    update_touch_area();
}
void GUI_Label::set_padding_y(double padding_y) {
    this->padding_y = padding_y;
    update_touch_area();
}