#ifndef GUI_ESP32_H
#define GUI_ESP32_H

#include <map>
#include <vector>
#include <Arduino.h>
#include <TFT_eSPI.h>
#include <gui_state.h>
#include <gui_state_main.h>
#include <gui_element.h>
#include <touch.h>

class GUI_State;

class GUI {
public:
    GUI(TFT_eSPI &tft, Touch *touch);
    virtual void update();
    virtual void draw();
    virtual void push_state(int state);
    virtual void pop_state();
    virtual int get_current_state_id() { return current_state_id; }
    virtual void add_element(GUI_Element *element);
    virtual void add_element(GUI_Element *element, int state);
    GUI_State *get_state(int state) { return states[state]; }
    void schedule_redraw_current_state() { current_state->schedule_redraw(); }
protected:
    std::map<int, GUI_State*> states;
    std::vector<int> state_stack;
    GUI_State *current_state;
    int current_state_id;
    TFT_eSPI &tft;
    Touch *touch;
    void set_state(int state);
};

#endif