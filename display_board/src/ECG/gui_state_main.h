#ifndef GUI_STATE_MAIN_H
#define GUI_STATE_MAIN_H

#include <Arduino.h>

#include <gui_state.h>
#include <gui_label.h>
#include <gui_graph.h>
#include <gui_button.h>

class GUI;
class GUI_Button;

class GUI_State_Main : public GUI_State {
public:
    GUI_State_Main(TFT_eSPI *tft, GUI *gui, Touch *touch);
    virtual void update() override;
    virtual void reset() override;
    virtual void draw() override;
    virtual void on_state_enter() override;
    virtual void on_state_exit() override;
    GUI_Graph *get_ecg_graph() { return ecg_graph; }
    void set_electrodes_status(bool connected);
private:
    GUI_Graph *ecg_graph;
    GUI_Label *label_electrodes_status;
    // GUI_Button *btn_for_something;
    bool electrodes_connected;
};

#endif