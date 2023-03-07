#include "gui.h"


// -------------------------------
// ---------- GUI_State ----------

GUI_State::GUI_State(TFT_eSPI *tft, Touch *touch) : tft(tft), touch(touch) {
}

void GUI_State::update() {
    touch->update();
    bool was_pressed = touch->was_pressed();
    bool was_released = touch->was_released();
    
    if (was_pressed || was_released) {
        int touch_x = touch->get_x();
        int touch_y = touch->get_y();

        for (GUI_Element *element : elements) {
            if (element->contains_point(touch_x, touch_y)) {
                if (was_pressed) 
                    element->on_press();
                if (was_released) 
                    element->on_release();
            }
        }

        if (was_pressed) 
            touch->reset_last_press();
        if (was_released) 
            touch->reset_last_release();
    }
}

void GUI_State::draw() {
    for (GUI_Element *element : elements) {
        if (element->needs_redraw)
            element->draw();        
    }
}

void GUI_State::reset() {
    elements.clear();
}

void GUI_State::add_element(GUI_Element* element) {
    elements.push_back(element);
}

// -------------------------------
// ----------    GUI    ----------

GUI::GUI(TFT_eSPI &tft, Touch *touch) : tft(tft), touch(touch) {
    touch->init();
    states[GUI_STATE_MAIN] = new GUI_State(&tft, touch);
    states[GUI_STATE_SECOND] = new GUI_State(&tft, touch);
    set_state(GUI_STATE_MAIN);
}

void GUI::update() {
    current_state->update();
}

void GUI::draw() {
    current_state->draw();
}

void GUI::set_state(int state_id) {
    // current_state->reset();
    tft.fillScreen(TFT_BLACK);
    current_state = states[state_id];
    current_state_id = state_id;
    update();
    draw();
}

void GUI::add_element(GUI_Element* element) {
    current_state->add_element(element);
}

void GUI::add_element(GUI_Element* element, int state) {
    if (states.find(state) == states.end()) {
        states[state] = new GUI_State(&tft, touch);
    }
    states[state]->add_element(element);
}
