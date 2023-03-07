#include "gui_element.h"

// -------------------------------
// ---------- GUI_Element ----------
GUI_Element::GUI_Element(TFT_eSPI *tft, int x, int y, int w, int h, unsigned int background_colour,std::function<void()> on_press_callback, std::function<void()> on_release_callback) : 
    tft(tft), x(x), y(y), w(w), h(h), background_colour(background_colour), needs_redraw(true), on_release_callback(on_release_callback), on_press_callback(on_press_callback)
{
}

void GUI_Element::draw() {
    tft->fillRect(x, y, w, h, background_colour);
    tft->drawRect(x, y, w, h, TFT_WHITE); 
    needs_redraw = false;
}

void GUI_Element::on_press() {
    on_press_callback();
}

void GUI_Element::on_release() {
    on_release_callback();
}
