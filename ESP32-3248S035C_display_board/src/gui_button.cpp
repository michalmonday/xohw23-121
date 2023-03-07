#include "gui_button.h"

// -------------------------------
// ---------- GUI_Button ----------
GUI_Button::GUI_Button(TFT_eSPI *tft, String text, int x, int y, int w, int h, unsigned int background_colour, std::function<void()> on_press_callback, std::function<void()> on_release_callback) :
    GUI_Element(tft, x, y, w, h, background_colour, on_press_callback, on_release_callback), text(text)
{
}

void GUI_Button::draw() {
    GUI_Element::draw();
    tft->drawCentreString(text, x + w / 2, y + h / 2, 2);
}

void GUI_Button::on_release() {
    GUI_Element::on_release();
    Serial.println("Button '" + text + "' touched");
}