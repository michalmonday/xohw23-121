#include <gui_state_notification.h>
#include <display_config.h>
#include <gui.h>
#include "graphics.h"

GUI_State_Notification::GUI_State_Notification(Graphics *gfx, GUI *gui, Touch *touch, int timeout) : 
    GUI_State(gfx, gui, touch), timeout(timeout) {
    label = new GUI_Label(gfx, "Notification", RESOLUTION_X/2, RESOLUTION_Y/2, 3, MC_DATUM, WHITE, BLACK);
    if (label == NULL) {
        Serial.println("Failed to allocate memory for label");
    }
    add_element(label);
}

void GUI_State_Notification::update() {
    GUI_State::update();
    if (timeout > 0 && millis() - switch_time > timeout) {
        // gui->revert_state();
        gui->pop_state();
    }
}

void GUI_State_Notification::set_text(String text) {
    label->set_text(text);
    label->needs_redraw = true;
}


void GUI_State_Notification::on_state_enter() {
    GUI_State::on_state_enter();
    switch_time = millis();
    Serial.println("Notification state entered");
}

void GUI_State_Notification::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("Notification state exited");
}
