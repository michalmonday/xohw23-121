#include "gui_state.h"  
// #include "gui.h"

// -------------------------------
// ---------- GUI_State ----------

GUI_State::GUI_State(TFT_eSPI *tft, GUI *gui, Touch *touch) : tft(tft), gui(gui), touch(touch) {
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
    element->needs_redraw = true;
}

void GUI_State::on_state_enter() {
    Serial.println("State entered");
    for (GUI_Element *element : elements) {
        Serial.println("Redrawing element");
        element->needs_redraw = true;
    }
}

void GUI_State::on_state_exit() {
}