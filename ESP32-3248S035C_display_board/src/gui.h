#ifndef GUI_ESP32_H
#define GUI_ESP32_H

#include <map>
#include <vector>
#include <Arduino.h>
#include <TFT_eSPI.h>
#include "gui_state.h"
#include "gui_state_main.h"
#include "gui_state_select_program.h"
#include "gui_element.h"
#include "touch.h"

class GUI_State;

class GUI {
public:
    GUI(TFT_eSPI &tft, Touch *touch);
    void update();
    void draw();
    void push_state(int state);
    void pop_state();
    // void revert_state();
    int get_current_state_id() { return current_state_id; }
    void add_element(GUI_Element *element);
    void add_element(GUI_Element *element, int state);
    void notify(String text, int timeout=0);
    GUI_State *get_state(int state) { return states[state]; }
    GUI_State_Main *get_state_main() { return static_cast<GUI_State_Main*>(states[GUI_STATE_MAIN]); }
    GUI_State_Select_Program *get_state_select_program() { return static_cast<GUI_State_Select_Program*>(states[GUI_STATE_SELECT_PROGRAM]); }
    void schedule_redraw_current_state() { current_state->schedule_redraw(); }
private:
    std::map<int, GUI_State*> states;
    std::vector<int> state_stack;
    GUI_State *current_state;
    int current_state_id;//, previous_state_id;
    TFT_eSPI &tft;
    Touch *touch;
    void set_state(int state);
};

#endif