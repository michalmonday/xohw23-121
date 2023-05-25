#ifndef GUI_ELEMENT_ESP32_H
#define GUI_ELEMENT_ESP32_H

#include <colours.h>
#include <vector>

#include "graphics.h"

class GUI_Element {
public:
    GUI_Element(Graphics *gfx, int x, int y, int w, int h, unsigned int background_colour = BLACK, 
        std::function<void()> on_press_callback = [](){},
        std::function<void()> on_release_callback = [](){}
        );
    ~GUI_Element();
    virtual void draw();
    virtual void undraw();
    virtual bool contains_point(int point_x, int point_y) { return (point_x > x && point_x < x + w && point_y > y && point_y < y + h); }
    virtual GUI_Element* get_child_element_containing_point(int point_x, int point_y);
    virtual void on_press();
    virtual void on_release();

    int get_x() { return x; }
    int get_y() { return y; }
    int get_w() { return w; }
    int get_h() { return h; }

    virtual void set_x(int x) { this->x = x; needs_redraw = true; }
    virtual void set_y(int y) { this->y = y; needs_redraw = true; }
    virtual void set_w(int w) { this->w = w; needs_redraw = true; }
    virtual void set_h(int h) { this->h = h; needs_redraw = true; }

    virtual void show() { is_visible = true; needs_redraw = true; }
    virtual void hide() { is_visible = false; needs_redraw = true; }

    virtual void set_on_press_callback(std::function<void()> on_press_callback) { this->on_press_callback = on_press_callback; }
    virtual void set_on_release_callback(std::function<void()> on_release_callback) { this->on_release_callback = on_release_callback; }


    void disable_background() { background_enabled = false; needs_redraw = true; }
    void enable_background() { background_enabled = true; needs_redraw = true; }

    bool needs_redraw;

    std::function<void()> on_press_callback;
    std::function<void()> on_release_callback;

    std::vector<GUI_Element *> &get_child_elements() { return child_elements; }

    void set_highlight_colour(unsigned int highlight_colour) { this->highlight_colour = highlight_colour; }
protected:
    int x,y,w,h;
    Graphics *gfx;
    unsigned int background_colour;
    unsigned int highlight_colour;
    bool background_enabled;
    bool is_visible;


    std::vector<GUI_Element *> child_elements;
    void add_child_element(GUI_Element *child_element);
};

#endif