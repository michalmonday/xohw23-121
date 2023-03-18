#include <gui_label.h>


// -------------------------------
// ---------- GUI_Label ----------
GUI_Label::GUI_Label(TFT_eSPI *tft, String text, int x, int y, int font_size, int datum, unsigned int text_colour, unsigned int background_colour, std::function<void()> on_press_callback, std::function<void()> on_release_callback) :
    GUI_Element(tft, x, y, tft->textWidth(text, font_size), tft->fontHeight(font_size), background_colour, on_press_callback, on_release_callback), text(text), datum(datum), text_color(text_colour), font_size(font_size)
{
}

void GUI_Label::draw() {
    GUI_Element::draw();
    tft->setTextSize(font_size);
    tft->setTextDatum(datum);
    tft->setTextColor(text_color);
    tft->drawString(text, x, y);
}

void GUI_Label::undraw() {
    // paint over the label with the background colour
    Serial.printf("Undrawing label '%s' at (%d, %d) with size (%d, %d)\n", text.c_str(), x, y, w, h);
    tft->setTextSize(font_size);
    tft->setTextDatum(datum);
    tft->setTextColor(background_colour);
    // tft->setTextColor(RED);
    tft->drawString(text, x, y);
    // tft->fillRect(x - w/2, y - h/2, w, h, background_colour);
}

void GUI_Label::set_text(String text) {
    undraw();
    this->text = text;
    w = tft->textWidth(text, font_size);
    h = tft->fontHeight(font_size);
    needs_redraw = true;
}

void GUI_Label::on_release() {
    GUI_Element::on_release();
    // background_colour = DKGREY;
    // Serial.println("Label '" + text + "' touched");
    // needs_redraw = true;
}

void GUI_Label::on_press() {
    GUI_Element::on_press();
    // background_colour = WHITE;
    // needs_redraw = true;
}