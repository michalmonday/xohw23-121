#ifndef GUI_STATE_MAIN_H
#define GUI_STATE_MAIN_H

#include <Arduino.h>
#include "gui_state.h"
#include "gui_label.h"
#include "gui_graph.h"

class GUI;

class GUI_State_Main : public GUI_State {
public:
    GUI_State_Main(TFT_eSPI *tft, GUI *gui, Touch *touch);
    virtual void update() override;
    virtual void on_state_enter() override;
    virtual void on_state_exit() override;
    void set_ap_conn_status(String text);
    void set_tcp_conn_status(String text);
    GUI_Graph *get_ecg_graph() { return ecg_graph; }
    GUI_Graph *get_pynq_graph() { return pynq_graph; }
    GUI_Label *get_label_ap_conn_status() { return label_ap_conn_status; }
    GUI_Label *get_label_tcp_conn_status() { return label_tcp_conn_status; }
private:
    GUI_Graph *ecg_graph;
    GUI_Graph *pynq_graph;
    GUI_Label *label_ap_conn_status;
    GUI_Label *label_tcp_conn_status;
};

#endif