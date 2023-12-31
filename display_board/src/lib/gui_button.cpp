#include <gui_button.h>
#include <TFT_eSPI.h>


// -------------------------------
// ---------- GUI_Button ----------
GUI_Button::GUI_Button(Graphics *gfx, String text, int x, int y, int w, int h, unsigned int font_size, unsigned int text_colour, unsigned int background_colour, std::function<void()> on_press_callback, std::function<void()> on_release_callback) :
    GUI_Element(gfx, x, y, w, h, background_colour, on_press_callback, on_release_callback), text(text), font_size(font_size), text_colour(text_colour), original_background_colour(background_colour), original_text_colour(text_colour)
{
}

void GUI_Button::draw() {
    GUI_Element::draw();

    // border
    gfx->drawRect(x, y, w, h, TFT_WHITE);  

    gfx->setTextDatum(MC_DATUM);
    // TL_DATUM = 0 = Top left
    // TC_DATUM = 1 = Top centre
    // TR_DATUM = 2 = Top right
    // ML_DATUM = 3 = Middle left
    // MC_DATUM = 4 = Middle centre
    // MR_DATUM = 5 = Middle right
    // BL_DATUM = 6 = Bottom left
    // BC_DATUM = 7 = Bottom centre
    // BR_DATUM = 8 = Bottom right
    // L_BASELINE =  9 = Left character baseline (Line the 'A' character would sit on)
    // C_BASELINE = 10 = Centre character baseline
    // R_BASELINE = 11 = Right character baseline
    // tft->drawCentreString(text, x + w / 2, y + h / 2 , 2);
    gfx->setTextColor(text_colour);
    gfx->setTextSize(font_size);
    gfx->drawString(text, x + w / 2, y + h / 2);
// - gfx->fontHeight()/
}



void GUI_Button::undraw() {
    // paint over the label with the background colour
    gfx->setTextDatum(MC_DATUM);
    gfx->setTextColor(background_colour);
    gfx->setTextSize(font_size);
    gfx->drawString(text, x + w / 2, y + h / 2);
}

void GUI_Button::set_text(String text) {
    undraw();
    this->text = text;
    needs_redraw = true;
}

void GUI_Button::on_release() {
    background_colour = original_background_colour;
    text_colour = original_text_colour;
    // Serial.println("Button '" + text + "' touched");
    needs_redraw = true;
    GUI_Element::on_release();
    // no members should be modified here to allow on_release_callback to destroy the object itself if needed
}

void GUI_Button::on_press() {
    background_colour = text_colour;
    text_colour = original_background_colour;
    needs_redraw = true;
    GUI_Element::on_press();
    // no members should be modified here to allow on_press_callback to destroy the object itself if needed
}