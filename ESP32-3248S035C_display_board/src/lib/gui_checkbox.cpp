#include <gui_checkbox.h>

// -------------------------------
// ---------- GUI_Checkbox ----------
GUI_Checkbox::GUI_Checkbox(Graphics *gfx, bool initial_is_checked, int x, int y, int w, int h, unsigned int font_size, unsigned int colour, unsigned int background_colour, 
                           std::function<void()> on_checked, std::function<void()> on_unchecked) :
    GUI_Element(gfx, x, y, w, h, background_colour, [](){}, [](){}), is_checked_(initial_is_checked), font_size(font_size), colour(colour), original_background_colour(background_colour), on_checked(on_checked), on_unchecked(on_unchecked)
{
}

void GUI_Checkbox::draw_checkmark(unsigned int clr) {
    // draw lines that resemle a tick

    int start_x = x + w / 4;
    int start_y = y + h / 2;
    int intermediate_x = x + w / 2.3;
    int intermediate_y = y + h * 0.75;
    int end_x = x + w * 0.75;
    int end_y = y + h * 0.25;
    gfx->drawLine(start_x, start_y, intermediate_x, intermediate_y, clr);
    gfx->drawLine(intermediate_x, intermediate_y, end_x, end_y, clr);
}

void GUI_Checkbox::draw() {
    GUI_Element::draw();

    // border
    gfx->drawRect(x, y, w, h, WHITE);  
    // gfx->setTextDatum(MC_DATUM);
    // gfx->setTextColor(colour);
    // gfx->setTextSize(font_size);
    // draw lines that resemle a tick
    if (is_checked()) {
        draw_checkmark(colour);
    }
        // gfx->drawString("✓", x + w / 2, y + h / 2);
}

void GUI_Checkbox::undraw() {
    gfx->drawRect(x, y, w, h, background_colour);  
    // paint over the label with the background colour
    // gfx->setTextDatum(MC_DATUM);
    // gfx->setTextColor(background_colour);
    // gfx->setTextSize(font_size);
    draw_checkmark(background_colour);
    // gfx->drawString("✓", x + w / 2, y + h / 2);
}

void GUI_Checkbox::on_release() {
    GUI_Element::on_release();
    background_colour = original_background_colour;
    // Serial.println("Checkbox '" + text + "' touched");
    is_checked_ = !is_checked_; 
    if (is_checked())
        on_checked();
    else
        on_unchecked();
    needs_redraw = true;
}

void GUI_Checkbox::on_press() {
    GUI_Element::on_press();
    background_colour = WHITE;
    needs_redraw = true;
}

void GUI_Checkbox::set_is_checked(bool state) {
    undraw();
    is_checked_ = state;
    needs_redraw = true;
}