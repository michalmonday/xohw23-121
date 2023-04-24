#include <gui.h>
#include "gui_cms.h"
#include "gui_state_notification.h"
#include "gui_state_main.h"
#include "gui_state_select_option.h"
#include "gui_cms_states.h"
#include "gui_state_edit_watchpoint.h"
#include <gui_state_select_number.h>
#include <gui_state_explore_objdump.h>

#include "graphics.h"

// -------------------------------
// ----------    GUI    ----------

GUI_CMS::GUI_CMS(Graphics *gfx, Touch *touch) : 
    GUI(gfx, touch) 
{
    current_state_id = GUI_STATE_MAIN;
    current_state = nullptr;
    touch->init();
    states[GUI_STATE_MAIN] = new GUI_State_Main(gfx, this, touch);
    states[GUI_STATE_NOTIFICATION] = new GUI_State_Notification(gfx, this, touch);
    states[GUI_STATE_SELECT_OPTION] = new GUI_State_Select_Option(gfx, this, touch);
    states[GUI_STATE_EDIT_WATCHPOINT] = new GUI_State_Edit_Watchpoint(gfx, this, touch);
    states[GUI_STATE_SELECT_NUMBER] = new GUI_State_Select_Number(gfx, this, touch);
    states[GUI_STATE_EXPLORE_OBJDUMP] = new GUI_State_Explore_Objdump(gfx, this, touch);

    if (states[GUI_STATE_MAIN] == nullptr) Serial.println("GUI_CMS: states[GUI_STATE_MAIN] is null");
    if (states[GUI_STATE_NOTIFICATION] == nullptr) Serial.println("GUI_CMS: states[GUI_STATE_NOTIFICATION] is null");
    if (states[GUI_STATE_SELECT_OPTION] == nullptr) Serial.println("GUI_CMS: states[GUI_STATE_SELECT_OPTION] is null");
    if (states[GUI_STATE_EDIT_WATCHPOINT] == nullptr) Serial.println("GUI_CMS: states[GUI_STATE_EDIT_WATCHPOINT] is null");
    if (states[GUI_STATE_SELECT_NUMBER] == nullptr) Serial.println("GUI_CMS: states[GUI_STATE_SELECT_NUMBER] is null");
    if (states[GUI_STATE_EXPLORE_OBJDUMP] == nullptr) Serial.println("GUI_CMS: states[GUI_STATE_EXPLORE_OBJDUMP] is null");

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
GUI_State_Edit_Watchpoint* GUI_CMS::get_state_edit_watchpoint() { return static_cast<GUI_State_Edit_Watchpoint*>(states[GUI_STATE_EDIT_WATCHPOINT]); }
GUI_State_Select_Number* GUI_CMS::get_state_select_number() { return static_cast<GUI_State_Select_Number*>(states[GUI_STATE_SELECT_NUMBER]); }
GUI_State_Explore_Objdump* GUI_CMS::get_state_explore_objdump() { return static_cast<GUI_State_Explore_Objdump*>(states[GUI_STATE_EXPLORE_OBJDUMP]); }