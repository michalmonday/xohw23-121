#ifndef GUI_STATE_SELECT_OPTION_H
#define GUI_STATE_SELECT_OPTION_H

#include <Arduino.h>
#include <vector>

#include <gui_state.h>
#include <gui_label.h>
#include <gui_graph.h>

#include "graphics.h"

class GUI;

class GUI_State_Select_Option : public GUI_State {
public:
    GUI_State_Select_Option(Graphics *gfx, GUI *gui, Touch *touch);
    virtual void update() override;
    virtual void on_state_enter() override;
    virtual void on_state_exit() override;
    void add_options(String category, std::vector<String> options);
    String get_selected_option() { return selected_option; }
    String get_selected_category() { return selected_category; }
    void set_on_option_selected_callback(std::function<void(String, String)> callback) { on_option_selected_callback = callback; }
private:
    String selected_option;
    String selected_category;
    std::vector<String> categories;
    int columns_taken;
    std::function<void(String, String)> on_option_selected_callback;
};



#endif