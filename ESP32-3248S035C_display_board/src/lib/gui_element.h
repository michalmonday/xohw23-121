#ifndef GUI_ELEMENT_ESP32_H
#define GUI_ELEMENT_ESP32_H

#include <TFT_eSPI.h>
#include <colours.h>
#include <vector>

class GUI_Element {
public:
    GUI_Element(TFT_eSPI *tft, int x, int y, int w, int h, unsigned int background_colour = BLACK, 
        std::function<void()> on_press_callback = [](){},
        std::function<void()> on_release_callback = [](){}
        );
    ~GUI_Element();
    virtual void draw();
    virtual void undraw();
    virtual bool contains_point(int point_x, int point_y) { return (point_x > x && point_x < x + w && point_y > y && point_y < y + h); }
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

    void set_on_press_callback(std::function<void()> on_press_callback) { this->on_press_callback = on_press_callback; }
    void set_on_release_callback(std::function<void()> on_release_callback) { this->on_release_callback = on_release_callback; }


    void disable_background() { background_enabled = false; needs_redraw = true; }
    void enable_background() { background_enabled = true; needs_redraw = true; }

    bool needs_redraw;

    std::function<void()> on_press_callback;
    std::function<void()> on_release_callback;
protected:
    int x,y,w,h;
    TFT_eSPI *tft;
    unsigned int background_colour;
    bool background_enabled;

    // child_elements are not clickable (becuase they are not added to GUI_State which handles touch)
    // but can be used to create some additional visual elements to items without the need to couple GUI_State into GUI_Element class
    // which would be required if we wanted to add child_elements to GUI_State 
    std::vector<GUI_Element *> child_elements;
    void add_child_element(GUI_Element *child_element);
};

#endif