#ifndef GUI_STATE_ESP32_H
#define GUI_STATE_ESP32_H

#include <TFT_eSPI.h>
#include <vector>

#include "touch.h"
#include "gui_element.h"

#define GUI_STATE_MAIN 0
#define GUI_STATE_NOTIFICATION 1

class GUI;

class GUI_State {
public:
    GUI_State(TFT_eSPI *tft, GUI *gui, Touch *touch);
    virtual void update(); 
    virtual void draw();
    void reset();
    void add_element(GUI_Element *element);
    virtual void on_state_enter();
    virtual void on_state_exit();
    GUI_State *get_state(int state_id);
protected:
    std::vector<GUI_Element*> elements;
    TFT_eSPI *tft;
    Touch *touch;
    GUI *gui;
};

#endif