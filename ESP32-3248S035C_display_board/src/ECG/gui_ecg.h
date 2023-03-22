#ifndef GUI_CMS_ESP32_H
#define GUI_CMS_ESP32_H

#include <Arduino.h>
#include <TFT_eSPI.h>
#include <gui_state.h>
#include <gui_state_main.h>
#include <gui_element.h>
#include <touch.h>
#include <gui.h>

class GUI_State;
class GUI;

class GUI_ECG : public GUI {
public:
    GUI_ECG(TFT_eSPI &tft, Touch *touch);
    // void notify(String text, int timeout=0);
    GUI_State_Main *get_state_main();
    // GUI_State_Select_Option *get_state_select_option(); 
};

#endif