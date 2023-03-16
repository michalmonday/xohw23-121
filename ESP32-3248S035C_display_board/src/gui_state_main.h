#ifndef GUI_STATE_MAIN_H
#define GUI_STATE_MAIN_H

#include <Arduino.h>
#include "gui_state.h"
#include "gui_label.h"
#include "gui_graph.h"
#include "gui_button.h"

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
    void set_ap_conn_status(String text);
    void set_tcp_conn_status(String text);
    void set_loaded_program(String text);
    void set_run_status(String text);
    void set_training_status(String text);
    void set_testing_status(String text);
    void set_dataset_size(int size);
    GUI_Graph *get_ecg_graph() { return ecg_graph; }
    GUI_Graph *get_pynq_graph() { return pynq_graph; }
    GUI_Label *get_label_ap_conn_status() { return label_ap_conn_status; }
    GUI_Label *get_label_tcp_conn_status() { return label_tcp_conn_status; }
    int get_dataset_size() { return dataset_size; }
private:
    int dataset_size;
    GUI_Graph *ecg_graph;
    GUI_Graph *pynq_graph;
    GUI_Label *label_ap_conn_status;
    GUI_Label *label_tcp_conn_status;

    GUI_Label *label_loaded_program;
    GUI_Label *label_run_status;
    GUI_Label *label_training_status;
    GUI_Label *label_testing_status;
    GUI_Label *label_dataset_size;

    GUI_Button *btn_load_program;
    GUI_Button *btn_run_status;
    GUI_Button *btn_train;
    GUI_Button *btn_test;
    GUI_Button *btn_reset_dataset;

};

#endif