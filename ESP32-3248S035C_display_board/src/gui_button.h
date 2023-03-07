#ifndef GUI_BUTTON_ESP32_H
#define GUI_BUTTON_ESP32_H

#include <TFT_eSPI.h>
#include "gui_element.h"

#include <functional>

class GUI_Button : public GUI_Element {
public:
    GUI_Button(TFT_eSPI *tft, String text, int x, int y, int w, int h, unsigned int background_colour = BLACK, 
        std::function<void()> on_press_callback = [](){},
        std::function<void()> on_release = [](){}
        );
    void draw();
    virtual void on_release() override;
private:
    String text;
};

#endif