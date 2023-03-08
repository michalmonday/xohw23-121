#include "gui.h"
#include "gui_state_notification.h"

// -------------------------------
// ----------    GUI    ----------

GUI::GUI(TFT_eSPI &tft, Touch *touch) : 
    tft(tft), touch(touch), current_state_id(GUI_STATE_MAIN), previous_state_id(GUI_STATE_MAIN), current_state(nullptr)
{
    touch->init();
    states[GUI_STATE_MAIN] = new GUI_State(&tft, this, touch);
    states[GUI_STATE_NOTIFICATION] = new GUI_State_Notification(&tft, this, touch);
    Serial.println("GUI initialized");
    set_state(GUI_STATE_MAIN);
}

void GUI::update() {
    current_state->update();
}

void GUI::draw() {
    current_state->draw();
}

void GUI::set_state(int state_id) {
    Serial.println("Setting state to " + String(state_id));
    tft.fillScreen(TFT_BLACK);
    if (current_state) {
        current_state->on_state_exit();
        previous_state_id = current_state_id;
    } else {
        previous_state_id = state_id;
    }
    current_state = states[state_id];
    current_state_id = state_id;
    current_state->on_state_enter();
    update();
    draw();
}

void GUI::revert_state() {
    Serial.println("Reverting state to " + String(previous_state_id));
    set_state(previous_state_id);

}

void GUI::add_element(GUI_Element* element) {
    current_state->add_element(element);
}

void GUI::add_element(GUI_Element* element, int state) {
    if (states.find(state) == states.end()) {
        states[state] = new GUI_State(&tft, this, touch);
    }
    states[state]->add_element(element);
}

void GUI::notify(String text, int timeout) {
    Serial.println("Notifying: " + text + " current_state_id: " + String(current_state_id) + " previous_state_id: " + String(previous_state_id));
    GUI_State_Notification *notification_state = static_cast<GUI_State_Notification*>(states[GUI_STATE_NOTIFICATION]);
    notification_state->set_timeout(timeout);
    if (current_state_id == GUI_STATE_NOTIFICATION) {
        notification_state->update_start_time(millis());
        String old_text = notification_state->get_label()->get_text();
        notification_state->set_text(old_text + "\n" + text);
    } else {
        notification_state->set_text(text);
        set_state(GUI_STATE_NOTIFICATION);
    }
}
