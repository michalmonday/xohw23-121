#ifndef GUI_BUTTON_ESP32_H
#define GUI_BUTTON_ESP32_H

#include <gui_element.h>

#include <functional>

#include "graphics.h"

// 0.4 of height
#define DEFAULT_BTN_PADDING_X 0.6 
#define DEFAULT_BTN_PADDING_Y 0.2

class GUI_Button : public GUI_Element {
public:
    GUI_Button(Graphics *gfx, String text, int x, int y, int w, int h, unsigned int font_size, unsigned int text_colour, unsigned int background_colour = BLACK, 
        std::function<void()> on_press_callback = [](){},
        std::function<void()> on_release = [](){}
        );
    void draw();
    void set_text(String text); 
    virtual void on_release() override;
    virtual void on_press() override;
    String get_text() { return text; }
    void undraw();
private:
    String text;
    unsigned int text_colour;
    unsigned int original_background_colour;
    unsigned int original_text_colour;
    unsigned int font_size;
};

#endif