#include <gui_state_edit_watchpoint.h>
#include <gui_state_select_number.h>
#include <display_config.h>
#include <gui_cms.h>
#include <gui_button.h>
#include <communication_queues.h>
#include <rpc.h>

#include <graphics.h>

#include <cJSON.h>

void Attribute::edit_attribute() {
    Serial.println("Attribute label released");
    gui->get_state_select_number()->set_number(value);
    gui->push_state(GUI_STATE_SELECT_NUMBER);
    gui->get_state_select_number()->set_on_number_selected_callback([this](long long value){
        set_value(value);
        gui->pop_state();
    });
}

std::vector<std::pair<String, long long>> GUI_State_Edit_Watchpoint::default_attributes = {
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


GUI_State_Edit_Watchpoint::GUI_State_Edit_Watchpoint(Graphics *gfx, GUI_CMS *gui, Touch *touch) : 
    GUI_State(gfx, gui, touch), watchpoint(nullptr)
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
    // watchpoint->set_attribute("pc", 0x8000007A0);

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
    const int attribute_y_start = RESOLUTION_Y*0.025;

    gfx->setTextSize(Attribute::font_size);
    const int ATTRIBUTES_PER_COLUMN = 8;
    const int attribute_h = (RESOLUTION_Y - attribute_y_start*2) / ATTRIBUTES_PER_COLUMN;// gfx->fontHeight();
    const int attribute_offset_y = attribute_h;
    int attribute_x = RESOLUTION_X*0.01;
    int attribute_y = attribute_y_start;

    for (auto entry : default_attributes) {
        String name = entry.first;
        long long value = entry.second;
        Serial.println("Adding attribute: " + name + " with value: " + value);
        Attribute *attr = new Attribute(gfx, gui, name, 0, attribute_x, attribute_y, attribute_h);
        if (attr == nullptr) {
            Serial.println("Failed to allocate memory for attribute: " + name);
            continue;
        }
        attributes[name] = attr;
        attribute_y += attribute_offset_y;
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
    // const int attributes_per_column = RESOLUTION_Y * 0.9 / attribute_offset_y;
    gfx->setTextSize(btn_ok_font_size);
    int font_height = gfx->fontHeight();
    // int btn_ok_font_height = gfx->fontHeight(btn_ok_font_size);
    const int btn_ok_h = font_height + font_height * DEFAULT_BTN_PADDING_Y*2;
    const int btn_ok_w = gfx->textWidth("OK") + font_height * DEFAULT_BTN_PADDING_X*2;
    const int btn_ok_y = RESOLUTION_Y - attribute_y_start - btn_ok_h; // RESOLUTION_Y - btn_ok_h;
    const int btn_ok_x = RESOLUTION_X*0.99 - btn_ok_w ;
    btn_ok = new GUI_Button(gfx, "OK", btn_ok_x, btn_ok_y, btn_ok_w, btn_ok_h, btn_ok_font_size, WHITE, BLACK, 
        [](){},
        [gui, this]() { 
            this->latch_attribute_values_to_watchpoint();
            gui->pop_state();
            // TODO send watchpoint to CMS (rpc)
            Serial.println("Watchpoint should be saved, main state should be updated, and CMS rpc should be called");
            if (watchpoint != nullptr) {
                watchpoint->push_to_pynq();
            } else {
                Serial.println("Watchpoint is null");
            }
        }
    );
    if (btn_ok == nullptr) {
        Serial.println("Failed to allocate memory for OK button");
    }
    add_element(btn_ok);

    // -----------------------------------------------
    // ------------- objdump button ------------------
    const int btn_objdump_h = btn_ok_h;
    const int btn_objdump_w = gfx->textWidth("OBJDUMP") + font_height * DEFAULT_BTN_PADDING_X*3;
    const int btn_objdump_x = RESOLUTION_X*0.99 - btn_objdump_w;
    const int btn_objdump_y = attribute_y_start; //RESOLUTION_Y - btn_objdump_h - attribute_offset_y;
    btn_objdump = new GUI_Button(gfx, "OBJDUMP", btn_objdump_x, btn_objdump_y, btn_objdump_w, btn_objdump_h, btn_ok_font_size, WHITE, BLACK, 
        [](){},
        [gui, this]() { 
            // select objdump file (reuse state select program, maybe rename it to select file) 
            // then enter function/basic-block selection state
            // once selected, set the PC to chosen value
            gui->get_state_select_option()->set_on_option_selected_callback([gui](String category, String f_name){
                rpc("rpc_get_objdump_data", "%s%s", category.c_str(), f_name.c_str());
                // cJSON *root = cJSON_CreateObject();
                // cJSON *rpc_obj = cJSON_CreateObject();
                // cJSON_AddItemToObject(root, "RPC", rpc_obj);
                // cJSON_AddStringToObject(rpc_obj, "function_name", "rpc_get_objdump_data");
                // const char *string_array[1] = {f_name.c_str()}; 
                // cJSON *function_args_obj = cJSON_CreateStringArray(string_array, 1);
                // cJSON_AddItemToObject(rpc_obj, "function_args", function_args_obj);
                // char *json_str = cJSON_PrintUnformatted(root);
                // Serial.print("Sending: '");
                // Serial.println(json_str);
                // add_string_to_queue(queue_to_send, new String(json_str), true);
                // free(json_str);
                // cJSON_Delete(root);
                gui->pop_state();
            });
            rpc_no_args("rpc_list_objdumps");
            gui->push_state(GUI_STATE_SELECT_OPTION);
        }
    );
    if (btn_objdump == nullptr) {
        Serial.println("Failed to allocate memory for OBJDUMP button");
    }
    add_element(btn_objdump);
}

void GUI_State_Edit_Watchpoint::set_attribute(String name, long long value) {
    if (attributes.find(name) == attributes.end()) {
        Serial.println("Attribute " + name + " not found");
        return;
    }
    Attribute *attr = attributes[name];
    attr->set_value(value);
    // attr->set_is_active(true);
}

void GUI_State_Edit_Watchpoint::set_default_values() {
    // set default values
    for (auto entry : default_attributes) {
        String name = entry.first;
        long long value = entry.second;
        Attribute *attr = attributes[name];
        attr->set_value(value);
        attr->set_is_active(false);
    }
}

void GUI_State_Edit_Watchpoint::update() {
    GUI_State::update();
}

void GUI_State_Edit_Watchpoint::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("Edit watchpoint state entered");
}

void GUI_State_Edit_Watchpoint::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("Edit watchpoint state exited");
    // destroy_and_clear_elements();
}

void GUI_State_Edit_Watchpoint::set_watchpoint_to_edit(Watchpoint *watchpoint) {
    this->watchpoint = watchpoint;
    set_default_values();

    for (auto entry : watchpoint->get_attributes()) {
        if (attributes.find(entry.first) != attributes.end()) {
            attributes[entry.first]->set_value(entry.second);
            attributes[entry.first]->set_is_active(true);
        } else {
            Serial.println("Attribute " + entry.first + " not found in attributes map");
        }
    }
}

void GUI_State_Edit_Watchpoint::latch_attribute_values_to_watchpoint() {
    for (auto entry : attributes) {
        Attribute *attr = entry.second;

        String name = entry.first;
        long long value = attr->value;
        bool is_active = attr->is_active();
        if (is_active) {
            watchpoint->set_attribute(name, value);
        } else {
            watchpoint->remove_attribute(name);
        }
    }
}