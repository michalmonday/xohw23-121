#ifndef GUI_CMS_ESP32_H
#define GUI_CMS_ESP32_H

#include <map>
#include <vector>
#include <Arduino.h>
#include <TFT_eSPI.h>
#include <gui_state.h>
#include <gui_state_main.h>
#include <gui_state_select_option.h>
#include <gui_state_select_number.h>
#include <gui_state_explore_objdump.h>
#include <gui_state_edit_watchpoint.h>
#include <gui_element.h>
#include <touch.h>
#include <gui.h>

class GUI_State;
class GUI;

class GUI_CMS : public GUI {
public:
    GUI_CMS(TFT_eSPI &tft, Touch *touch);
    void notify(String text, int timeout=0);
    GUI_State_Main *get_state_main();
    GUI_State_Select_Option *get_state_select_option(); 
    GUI_State_Edit_Watchpoint *get_state_edit_watchpoint();
    GUI_State_Select_Number *get_state_select_number();
    GUI_State_Explore_Objdump* get_state_explore_objdump();
};

#endif