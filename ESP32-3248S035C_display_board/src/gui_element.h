#ifndef GUI_ELEMENT_ESP32_H
#define GUI_ELEMENT_ESP32_H

#include <TFT_eSPI.h>
#include "colours.h"

class GUI_Element {
public:
    GUI_Element(TFT_eSPI *tft, int x, int y, int w, int h, unsigned int background_colour = BLACK, 
        std::function<void()> on_press_callback = [](){},
        std::function<void()> on_release_callback = [](){}
        );
    virtual void draw();
    virtual bool contains_point(int point_x, int point_y) { return (point_x > x && point_x < x + w && point_y > y && point_y < y + h); }
    virtual void on_press();
    virtual void on_release();

    int get_x() { return x; }
    int get_y() { return y; }
    int get_w() { return w; }
    int get_h() { return h; }

    bool needs_redraw;

    std::function<void()> on_press_callback;
    std::function<void()> on_release_callback;
protected:
    int x,y,w,h;
    TFT_eSPI *tft;
    unsigned int background_colour;
};

#endif