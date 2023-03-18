#ifndef GUI_STATE_ESP32_H
#define GUI_STATE_ESP32_H

#include <TFT_eSPI.h>
#include <vector>

#include <touch.h>
#include <gui_element.h>

class GUI;

class GUI_State {
public:
    GUI_State(TFT_eSPI *tft, GUI *gui, Touch *touch);
    virtual void update(); 
    virtual void draw();
    virtual void reset();
    void add_element(GUI_Element *element);
    virtual void on_state_enter();
    virtual void on_state_exit();
    GUI_State *get_state(int state_id);
    void schedule_redraw();
protected:
    std::vector<GUI_Element*> elements;
    TFT_eSPI *tft;
    Touch *touch;
    GUI *gui;

    void destroy_and_clear_elements();
};

#endif