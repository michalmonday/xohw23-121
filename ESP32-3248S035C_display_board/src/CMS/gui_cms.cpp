#include <gui.h>
#include "gui_cms.h"
#include "gui_state_notification.h"
#include "gui_state_main.h"
#include "gui_state_select_option.h"
#include "gui_cms_states.h"
#include "gui_state_edit_rule.h"
#include <gui_state_select_number.h>
#include <gui_state_explore_objdump.h>

// -------------------------------
// ----------    GUI    ----------

GUI_CMS::GUI_CMS(TFT_eSPI &tft, Touch *touch) : 
    GUI(tft, touch) 
{
    current_state_id = GUI_STATE_MAIN;
    current_state = nullptr;
    touch->init();
    states[GUI_STATE_MAIN] = new GUI_State_Main(&tft, this, touch);
    states[GUI_STATE_NOTIFICATION] = new GUI_State_Notification(&tft, this, touch);
    states[GUI_STATE_SELECT_OPTION] = new GUI_State_Select_Option(&tft, this, touch);
    states[GUI_STATE_EDIT_RULE] = new GUI_State_Edit_Rule(&tft, this, touch);
    states[GUI_STATE_SELECT_NUMBER] = new GUI_State_Select_Number(&tft, this, touch);
    states[GUI_STATE_EXPLORE_OBJDUMP] = new GUI_State_Explore_Objdump(&tft, this, touch);

    Serial.println("GUI_CMS initialized");
    push_state(GUI_STATE_MAIN);
}

void GUI_CMS::notify(String text, int timeout) {
    // Serial.println("Notifying: " + text + " current_state_id: " + String(current_state_id) + " previous_state_id: " + String(previous_state_id));
    GUI_State_Notification *notification_state = static_cast<GUI_State_Notification*>(states[GUI_STATE_NOTIFICATION]);
    notification_state->set_timeout(timeout);
    if (current_state_id == GUI_STATE_NOTIFICATION) {
        notification_state->update_start_time(millis());
        String old_text = notification_state->get_label()->get_text();
        notification_state->set_text(old_text + "\n" + text);
    } else {
        notification_state->set_text(text);
        push_state(GUI_STATE_NOTIFICATION);
    }
}

GUI_State_Main* GUI_CMS::get_state_main() { return static_cast<GUI_State_Main*>(states[GUI_STATE_MAIN]); }
GUI_State_Select_Option* GUI_CMS::get_state_select_option() { return static_cast<GUI_State_Select_Option*>(states[GUI_STATE_SELECT_OPTION]); }
GUI_State_Edit_Rule* GUI_CMS::get_state_edit_rule() { return static_cast<GUI_State_Edit_Rule*>(states[GUI_STATE_EDIT_RULE]); }
GUI_State_Select_Number* GUI_CMS::get_state_select_number() { return static_cast<GUI_State_Select_Number*>(states[GUI_STATE_SELECT_NUMBER]); }
GUI_State_Explore_Objdump* GUI_CMS::get_state_explore_objdump() { return static_cast<GUI_State_Explore_Objdump*>(states[GUI_STATE_EXPLORE_OBJDUMP]); }