#ifndef GUI_STATE_ESP32_H
#define GUI_STATE_ESP32_H

#include <vector>

#include <touch.h>
#include <gui_element.h>

#include "graphics.h"

class GUI;

class GUI_State {
public:
    GUI_State(Graphics *gfx, GUI *gui, Touch *touch);
    virtual void update(); 
    virtual void draw();
    virtual void reset();
    void add_element(GUI_Element *element);
    void remove_element(GUI_Element *element);
    bool has_element(GUI_Element *element);
    virtual void on_state_enter();
    virtual void on_state_exit();
    GUI_State *get_state(int state_id);
    void schedule_redraw();
protected:
    unsigned long last_state_enter_time;
    unsigned long last_touch_release_time;
    std::vector<GUI_Element*> elements;
    Graphics *gfx;
    Touch *touch;
    GUI *gui;

    void destroy_and_clear_elements();
};

#endif