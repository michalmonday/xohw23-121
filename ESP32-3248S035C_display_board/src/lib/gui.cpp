#include <gui.h>
#include <gui_state_main.h>

// -------------------------------
// ----------    GUI    ----------

GUI::GUI(Graphics *gfx, Touch *touch) : 
    gfx(gfx), touch(touch)
{
    touch->init();
    Serial.println("GUI initialized");
}

void GUI::update() {
    current_state->update();
}

void GUI::draw() {
    current_state->draw();
}

void GUI::set_state(int state_id) {
    Serial.println("Setting state to " + String(state_id));
    gfx->fillScreen(BLACK);
    if (current_state) {
        current_state->on_state_exit();
    } else {
    }
    current_state = states[state_id];
    current_state_id = state_id;
    current_state->on_state_enter();
    update();
    draw();
}

void GUI::push_state(int state_id) {
    Serial.println("Pushing state " + String(state_id));
    state_stack.push_back(state_id);
    set_state(state_id);
}

void GUI::pop_state() {
    if (state_stack.size() > 0) {
        state_stack.pop_back();
        int state_id = state_stack.back();
        Serial.println("Popping state, current_state_id: " + String(state_id));
        set_state(state_id);
    } else {
        Serial.println("State stack is empty, setting state 0");
        set_state(0);
    }
}

void GUI::add_element(GUI_Element* element) {
    current_state->add_element(element);
}

void GUI::add_element(GUI_Element* element, int state) {
    if (states.find(state) == states.end()) {
        states[state] = new GUI_State(gfx, this, touch);
    }
    states[state]->add_element(element);
}
