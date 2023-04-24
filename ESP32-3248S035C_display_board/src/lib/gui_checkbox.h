#ifndef GUI_CHECKBOX_ESP32_H
#define GUI_CHECKBOX_ESP32_H

#include <gui_element.h>

#include <functional>
#include "graphics.h"

class GUI_Checkbox : public GUI_Element {
public:
    GUI_Checkbox(Graphics *gfx, bool initial_is_checked, int x, int y, int w, int h, unsigned int font_size, unsigned int colour, unsigned int background_colour = BLACK, 
        std::function<void()> on_checked = [](){},
        std::function<void()> on_unchecked = [](){}
        );
    void draw();
    void set_text(String text); 
    virtual void on_release() override;
    virtual void on_press() override;
    void undraw();
    void set_is_checked(bool is_checked);
    void set_on_checked_callback(std::function<void()> on_checked) { this->on_checked = on_checked; }
    void set_on_unchecked_callback(std::function<void()> on_unchecked) { this->on_unchecked = on_unchecked; }
    bool is_checked() { return is_checked_; }
private:
    bool is_checked_;
    unsigned int colour;
    unsigned int original_background_colour;
    unsigned int font_size;

    std::function<void()> on_checked;
    std::function<void()> on_unchecked;

    void draw_checkmark(unsigned int clr);
};

#endif