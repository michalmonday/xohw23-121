#include <gui_label.h>

#include <TFT_eSPI.h>


// -------------------------------
// ---------- GUI_Label ----------
GUI_Label::GUI_Label(Graphics *gfx, String text, int x, int y, int font_size, int datum, unsigned int text_colour, unsigned int background_colour, std::function<void()> on_press_callback, std::function<void()> on_release_callback, double padding_x, double padding_y) :
    GUI_Element(gfx, x, y, gfx->textWidth(text), gfx->fontHeight(), background_colour, on_press_callback, on_release_callback), datum(datum), text_color(text_colour), font_size(font_size), padding_x(padding_x), padding_y(padding_y)
{
    update_touch_area();
    set_text(text);
}

void GUI_Label::update_touch_area() {
    // gfx->setTextSize(font_size);
    // w = gfx->textWidth(text);
    // h = gfx->fontHeight();
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
    touch_left_x = left_x - padding_x * w;
    touch_right_x = left_x + w + padding_x * w;
    touch_top_y = top_y - padding_y * h;
    touch_bottom_y = top_y + h + padding_y * h;
    // above is correct for datum = TL_DATUM (top left)
}

void GUI_Label::draw(unsigned int clr_override, unsigned int background_clr_override) {
    if (background_enabled)
        gfx->fillRect(touch_left_x, touch_top_y, touch_right_x - touch_left_x, touch_bottom_y - touch_top_y, background_clr_override);

    // draw touch area
    // gfx->fillRect(touch_left_x, touch_top_y, touch_right_x - touch_left_x, touch_bottom_y - touch_top_y, DKRED);

    gfx->setTextSize(font_size);
    gfx->setTextDatum(datum);
    gfx->setTextColor(clr_override);
    gfx->drawString(text, x, y);
    needs_redraw = false;
}

void GUI_Label::draw() {
    draw(text_color, background_colour);
}

void GUI_Label::undraw() {
    // GUI_Element::undraw();
    // paint over the label with the background colour
    // Serial.printf("Undrawing label '%s' at (%d, %d) with size (%d, %d)\n", text.c_str(), x, y, w, h);
    draw(background_colour, background_colour);
    // gfx->setTextSize(font_size);
    // gfx->setTextDatum(datum);
    // gfx->setTextColor(background_colour);
    // gfx->drawString(text, x, y);
}

void GUI_Label::set_y(int y) { undraw(); GUI_Element::set_y(y); update_touch_area(); }
void GUI_Label::set_x(int x) { undraw(); GUI_Element::set_x(x); update_touch_area(); }
void GUI_Label::set_w(int w) { undraw(); GUI_Element::set_w(w); update_touch_area(); }
void GUI_Label::set_h(int h) { undraw(); GUI_Element::set_h(h); update_touch_area(); }

void GUI_Label::set_font_size(int font_size) {
    undraw();
    this->font_size = font_size;
    gfx->setTextSize(font_size);
    w = gfx->textWidth(text);
    h = gfx->fontHeight();
    update_touch_area();
    needs_redraw = true;
}

void GUI_Label::set_text(String text) {
    undraw();
    this->text = text;
    gfx->setTextSize(font_size);
    w = gfx->textWidth(text);
    h = gfx->fontHeight();
    update_touch_area();
    needs_redraw = true;
}

void GUI_Label::on_release() {
    // background_colour = DKGREY;
    // Serial.println("Label '" + text + "' touched");
    // needs_redraw = true;
    needs_redraw = true;
    GUI_Element::on_release();
    // no members should be modified here to allow on_release_callback to destroy the object itself if needed
}

void GUI_Label::on_press() {
    draw(background_colour, text_color);
    // background_colour = WHITE;
    // needs_redraw = true;
    GUI_Element::on_press();
    // no members should be modified here to allow on_press_callback to destroy the object itself if needed
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

void GUI_Label::set_on_release_callback(std::function<void()> on_release_callback) {
    GUI_Element::set_on_release_callback(on_release_callback);
}