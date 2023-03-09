#ifndef GUI_STATE_SELECT_PROGRAM_H
#define GUI_STATE_SELECT_PROGRAM_H

#include <Arduino.h>
#include <vector>
#include "gui_state.h"
#include "gui_label.h"
#include "gui_graph.h"

class GUI;

class GUI_State_Select_Program : public GUI_State {
public:
    GUI_State_Select_Program(TFT_eSPI *tft, GUI *gui, Touch *touch);
    virtual void update() override;
    virtual void on_state_enter() override;
    virtual void on_state_exit() override;
    void add_programs(String category, std::vector<String> programs);
    String get_selected_program() { return selected_program; }
    String get_selected_category() { return selected_category; }
private:
    String selected_program;
    String selected_category;
    std::vector<String> categories;
    int columns_taken;
};



#endif