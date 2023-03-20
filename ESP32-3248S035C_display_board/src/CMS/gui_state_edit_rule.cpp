#include <gui_state_edit_rule.h>
#include <display_config.h>
#include <gui_cms.h>
#include <gui_button.h>
#include <communication_queues.h>

#include <cJSON.h>

std::vector<std::pair<String, long long>> GUI_State_Edit_Rule::default_attributes = {
        {"A3", 0},
        {"A2", 0},
        {"A1", 0},
        {"A0", 0},
        {"S2", 0},
        {"S1", 0},
        {"FP", 0}, // frame pointer
        {"T1", 0},
        {"T0", 0},
        {"TP", 0}, // thread pointer
        {"GP", 0}, // global pointer
        {"SP", 0}, // stack pointer
        {"RA", 0}, // return address
        {"HPCs", 0}, // hardware performance counters, to be more specific it's their event indicating bits (39 bits, 1 per each event)
        {"Instr", 0}, // (32 bits)
        {"PC", 0x80000000LL} // program counter
    };


GUI_State_Edit_Rule::GUI_State_Edit_Rule(TFT_eSPI *tft, GUI_CMS *gui, Touch *touch) : 
    GUI_State(tft, gui, touch), rule(nullptr)
{

    // Attribues can be any values from the atf_pkt_deterministic_structure in continouos_monitoring_system_controller.py
    // atf_pkt_deterministic_structure = {
    // 'S2': 64,
    // 'A3': 64,
    // 'A2': 64,
    // 'A1': 64,
    // 'A0': 64,
    // 'S1': 64,
    // 'S0 / Frame pointer': 64,
    // 'T1': 64,
    // 'T0': 64,
    // 'Thread pointer': 64,
    // 'Global pointer': 64,
    // 'Stack pointer': 64,
    // 'Return address': 64,
    // 'performance_events' : 39,
    // 'instr': 32,
    // 'pc': 64
    // }
    // 
    // So the attributes can be assigned like:
    // rule->set_attribute("pc", 0x8000007A0);

    // // all values are 64 bits, except the ones where specified in comments
    // attributes = {
    //     {"A3", new Attribute("A3", 0, new GUI_Label())},
    //     {"A2", 0},
    //     {"A1", 0},
    //     {"A0", 0},
    //     {"S2", 0},
    //     {"S1", 0},
    //     {"FP", 0}, // frame pointer
    //     {"T1", 0},
    //     {"T0", 0},
    //     {"TP", 0}, // thread pointer
    //     {"GP", 0}, // global pointer
    //     {"SP", 0}, // stack pointer
    //     {"RA", 0}, // return address
    //     {"HPCs", 0}, // hardware performance counters, to be more specific it's their event indicating bits (39 bits, 1 per each event)
    //     {"instr", 0}, // (32 bits)
    //     {"PC", 0x80000000} // program counter
    // };

    const int attribute_w = RESOLUTION_X * 0.3;
    const int attribute_y_start = RESOLUTION_Y*0.05;

    tft->setTextSize(Attribute::font_size);
    const int attribute_height = tft->fontHeight(Attribute::font_size) * 1.2;
    int attribute_x = RESOLUTION_X*0.05;
    int attribute_y = attribute_y_start;

    for (auto entry : default_attributes) {
        String name = entry.first;
        long long value = entry.second;
        Serial.println("Adding attribute: " + name + " with value: " + value);
        Attribute *attr = new Attribute(tft, name, 0, attribute_x, attribute_y);
        attributes[name] = attr;
        attribute_y += attribute_height;
        if (attribute_y > RESOLUTION_Y*0.95) {
            attribute_y = attribute_y_start;
            attribute_x += attribute_w *1.2;
        }

        add_element(attr->label);
        add_element(attr->checkbox_is_active);
    }
    set_default_values();
    
    // ------------------------------------------------
    // ---------------- OK button ---------------------
    const int btn_ok_font_size = 2;
    tft->setTextSize(btn_ok_font_size);
    int btn_ok_font_height = tft->fontHeight(btn_ok_font_size);
    int btn_ok_h = btn_ok_font_height*1.2;
    const int btn_ok_w = tft->textWidth("OK") * 2;
    btn_ok = new GUI_Button(tft, "OK", RESOLUTION_X - btn_ok_w*1.2, RESOLUTION_Y - btn_ok_h*1.2, btn_ok_w, btn_ok_h, btn_ok_font_size, WHITE, BLACK, 
        [](){},
        [gui, this]() { 
            this->latch_attribute_values_to_rule();
            gui->pop_state();
            // TODO send rule to CMS (rpc)
            Serial.println("Rule should be saved, main state should be updated, and CMS rpc shoudl be called");
        }
    );
    add_element(btn_ok);
}

void GUI_State_Edit_Rule::set_default_values() {
    // set default values
    for (auto entry : default_attributes) {
        String name = entry.first;
        long long value = entry.second;
        Attribute *attr = attributes[name];
        attr->set_value(value);
        attr->set_is_active(false);
    }
}

void GUI_State_Edit_Rule::update() {
    GUI_State::update();
}

void GUI_State_Edit_Rule::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("Edit rule state entered");
}

void GUI_State_Edit_Rule::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("Edit rule state exited");
    // destroy_and_clear_elements();
}

void GUI_State_Edit_Rule::set_rule_to_edit(Rule *rule) {
    this->rule = rule;
    set_default_values();

    for (auto entry : rule->get_attributes()) {
        if (attributes.find(entry.first) != attributes.end()) {
            attributes[entry.first]->set_value(entry.second);
            attributes[entry.first]->set_is_active(true);
        } else {
            Serial.println("Attribute " + entry.first + " not found in attributes map");
        }
    }
}

void GUI_State_Edit_Rule::latch_attribute_values_to_rule() {
    for (auto entry : attributes) {
        Attribute *attr = entry.second;

        String name = entry.first;
        long long value = attr->value;
        bool is_active = attr->is_active();
        if (is_active) {
            rule->set_attribute(name, value);
        } else {
            rule->remove_attribute(name);
        }
    }
}