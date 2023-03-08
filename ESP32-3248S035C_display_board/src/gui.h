#ifndef GUI_ESP32_H
#define GUI_ESP32_H

#include <map>
#include <vector>
#include <Arduino.h>
#include <TFT_eSPI.h>
#include "gui_state.h"
#include "gui_element.h"
#include "touch.h"

class GUI_State;

class GUI {
public:
    GUI(TFT_eSPI &tft, Touch *touch);
    void update();
    void draw();
    void set_state(int state);
    void revert_state();
    int get_current_state_id() { return current_state_id; }
    void add_element(GUI_Element *element);
    void add_element(GUI_Element *element, int state);
    void notify(String text, int timeout=0);
    GUI_State *get_state(int state) { return states[state]; }
private:
    std::map<int, GUI_State*> states;
    GUI_State *current_state;
    int current_state_id, previous_state_id;
    TFT_eSPI &tft;
    Touch *touch;
};

#endif