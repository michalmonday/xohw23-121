#ifndef GUI_ESP32_H
#define GUI_ESP32_H

#include <map>
#include <vector>
#include <Arduino.h>
#include <TFT_eSPI.h>
#include "gui_element.h"
#include "touch.h"

#define GUI_STATE_MAIN 0
#define GUI_STATE_SECOND 1

class GUI_State {
public:
    GUI_State(TFT_eSPI *tft, Touch *touch);
    void update(); 
    void draw();
    void reset();
    void add_element(GUI_Element *element);
private:
    std::vector<GUI_Element*> elements;
    TFT_eSPI *tft;
    Touch *touch;
};

class GUI {
public:
    GUI(TFT_eSPI &tft, Touch *touch);
    void update();
    void draw();
    void set_state(int state);
    int get_current_state_id() { return current_state_id; }
    void add_element(GUI_Element *element);
    void add_element(GUI_Element *element, int state);
private:
    std::map<int, GUI_State*> states;
    GUI_State *current_state;
    int current_state_id;
    TFT_eSPI &tft;
    Touch *touch;
};

#endif