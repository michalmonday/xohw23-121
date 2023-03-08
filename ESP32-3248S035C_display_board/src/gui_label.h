#ifndef GUI_LABEL_ESP32_H
#define GUI_LABEL_ESP32_H

#include <TFT_eSPI.h>
#include "gui_element.h"

#include <functional>

class GUI_Label : public GUI_Element {
public:
    GUI_Label(TFT_eSPI *tft, String text, int x, int y, int font_size, int datum, unsigned int text_color = WHITE, unsigned int background_colour = BLACK, 
        std::function<void()> on_press_callback = [](){},
        std::function<void()> on_release = [](){}
        );
    void draw();
    void undraw();
    void set_text(String text); 
    virtual void on_release() override;
    virtual void on_press() override;
    void set_font_size(int font_size) { this->font_size = font_size; needs_redraw = true; }
    String get_text() { return text; }
private:
    String text;
    int datum;
    unsigned int text_color;
    int font_size;
};

#endif