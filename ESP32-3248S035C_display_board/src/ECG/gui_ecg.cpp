#include <gui.h>
#include "gui_ecg.h"
#include "gui_state_main.h"
#include "gui_ecg_states.h"

// -------------------------------
// ----------    GUI    ----------

GUI_ECG::GUI_ECG(TFT_eSPI &tft, Touch *touch) : 
    GUI(tft, touch) 
{
    current_state_id = GUI_STATE_MAIN;
    current_state = nullptr;
    states[GUI_STATE_MAIN] = new GUI_State_Main(&tft, this, touch);
    Serial.println("GUI_ECG initialized");
    push_state(GUI_STATE_MAIN);
}

GUI_State_Main* GUI_ECG::get_state_main() { 
    return static_cast<GUI_State_Main*>(states[GUI_STATE_MAIN]); 
}
