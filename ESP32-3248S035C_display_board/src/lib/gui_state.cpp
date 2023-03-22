#include <gui_state.h>
// #include "gui.h"

// -------------------------------
// ---------- GUI_State ----------

GUI_State::GUI_State(TFT_eSPI *tft, GUI *gui, Touch *touch) : tft(tft), gui(gui), touch(touch), last_state_enter_time(0), last_touch_release_time(0) {
}

void GUI_State::update() {
    touch->update();
    if (millis() - last_state_enter_time < 400 || millis() - last_touch_release_time < 100) {
        touch->reset_last_press();
        touch->reset_last_release();
        return;
    }
    bool was_pressed = touch->was_pressed();
    bool was_released = touch->was_released();
    
    if (!was_pressed && !was_released)
        return;
    
    int touch_x = touch->get_x();
    int touch_y = touch->get_y();

    for (GUI_Element *element : elements) {
        GUI_Element* child_element = element->get_child_element_containing_point(touch_x, touch_y);
        if (child_element) {
            if (was_pressed) 
                child_element->on_press();
            if (was_released) 
                child_element->on_release();
            
            // if the child element happens to cause deletion of other objects then this break may prevent some issues
            break;
        }
        if (!element->contains_point(touch_x, touch_y)) 
            continue;

        if (was_pressed) 
            element->on_press();
        if (was_released) 
            element->on_release();
        break;
    }

    if (was_pressed) 
        touch->reset_last_press();
    if (was_released) {
        touch->reset_last_release();
        last_touch_release_time = millis();
    }
}

void GUI_State::draw() {
    for (GUI_Element *element : elements) {
        if (element->needs_redraw)
            element->draw();

        for (auto child_element : element->get_child_elements()) {
            if (child_element->needs_redraw)
                child_element->draw();
        }
    }
}

void GUI_State::reset() {
    // elements.clear();
    schedule_redraw();
}

void GUI_State::add_element(GUI_Element* element) {
    elements.push_back(element);
    element->needs_redraw = true;
}

void GUI_State::remove_element(GUI_Element* element) {
    elements.erase(std::remove(elements.begin(), elements.end(), element), elements.end());
}

void GUI_State::on_state_enter() {
    last_state_enter_time = millis();
    Serial.println("State entered");
    for (GUI_Element *element : elements) {
        // Serial.println("Redrawing element");
        element->needs_redraw = true;
        for (auto child_element : element->get_child_elements()) {
            child_element->needs_redraw = true;
        }
    }
}

void GUI_State::on_state_exit() {
}

void GUI_State::destroy_and_clear_elements() {
    for (GUI_Element *element : elements) {
        delete element;
    }
    elements.clear();
}

void GUI_State::schedule_redraw() {
    for (GUI_Element *element : elements) {
        element->needs_redraw = true;
        for (auto child_element : element->get_child_elements()) {
            child_element->needs_redraw = true;
        }
    }
}