#include "gui_state_explore_objdump.h"
#include "display_config.h"
#include "gui_cms.h"
#include <gui_state.h>
#include "gui_cms_states.h"

GUI_State_Explore_Objdump::GUI_State_Explore_Objdump(TFT_eSPI *tft, GUI_CMS *gui, Touch *touch) 
    : GUI_State(tft, gui, touch), selected_address(0) 
{
    label_current_function = new GUI_Label(tft, "-", RESOLUTION_X/2, RESOLUTION_Y * 0.01, 2, TC_DATUM, WHITE, BLACK);
    if (label_current_function == NULL) {
        Serial.println("label_current_function is NULL");
    }
    add_element(label_current_function);
    tft->setTextSize(GUI_State_Explore_Objdump::font_size);
    int font_height = tft->fontHeight();
    const int btn_w = tft->textWidth("Back") + font_height * DEFAULT_BTN_PADDING_X*2;
    const int btn_h = font_height + font_height * DEFAULT_BTN_PADDING_Y*2;
    btn_back = new GUI_Button(tft, "Back", RESOLUTION_X - btn_w, RESOLUTION_Y * 0.01, btn_w, btn_h, 2, WHITE, BLACK, [](){}, [this](){
        pop_function();
    });
    if (btn_back == NULL) {
        Serial.println("btn_back is NULL");
    }
    btn_back->hide();
    add_element(btn_back);
}

void GUI_State_Explore_Objdump::update() {
    GUI_State::update();
}

void GUI_State_Explore_Objdump::draw() {
    GUI_State::draw();
}

// void GUI_State_Explore_Objdump::set_objdump(std::map<String, std::vector<Objdump_Item*>> objdump) {
//     this->objdump = objdump;
// }

//  The resulting json should have the following structure:
//  {'_start': {'80000000': {'destination': '',
//                           'instr': 'F14022F3',
//                           'instr_name': 'CSRR',
//                           'type': 'entry'},
//              '80000004': {'destination': 'park',
//                           'instr': '02029063',
//                           'instr_name': 'BNEZ',
//                           'type': 'branch'},
//              '80000010': {'destination': 'main',
//                           'instr': '0280006F',
//                           'instr_name': 'J',
//                           'type': 'branch'},
//              '80000020': {'destination': 'park',
//                           'instr': '0040006F',
//                           'instr_name': 'J',
//                           'type': 'branch'}},
//   'atoi': {'80000600': {'destination': '',
//                         'instr': 'FD010113',
//                         'instr_name': 'ADDI',
//                         'type': 'entry'},
//            '80000634': {'destination': 'atoi+0x8c',
//                         'instr': '04F71C63',
//                         'instr_name': 'BNE',
//                         'type': 'branch'},
//            '8000064C': {'destination': 'atoi+0x8c',
//                         'instr': '0400006F',
//                         'instr_name': 'J',
//                         'type': 'branch'},
//            '80000694': {'destination': 'atoi+0x50',
//                         'instr': 'FA079EE3',
//                         'instr_name': 'BNEZ',
//                         'type': 'branch'},
//            '800006B8': {'destination': '',
//                         'instr': '00008067',
//                         'instr_name': 'RET',                        'type': 'branch'}}
// }


bool GUI_State_Explore_Objdump::set_objdump(cJSON *objdump_obj) {
    clean_objudmp();
    // Serial.printf("objdump_obj = %s\n", cJSON_Print(objdump_obj));
    // parse cJSON object and set the objdump
    cJSON *objdump_entry_obj = objdump_obj->child;
    if (objdump_entry_obj == NULL) {
        Serial.println("objdump_obj is empty");
        return false;
    }
    while (objdump_entry_obj != NULL) {
        // printf("objdump_entry->string: %s", objdump_entry->string);
        std::vector<Objdump_Item*> objdump_items;
        cJSON *objdump_item_obj = objdump_entry_obj->child;

        String function_name = objdump_entry_obj->string;
        String address;
        while (objdump_item_obj != NULL) {
            address = objdump_item_obj->string;
            // printf("objdump_item->string: %s", objdump_item->string);
            cJSON *type = cJSON_GetObjectItem(objdump_item_obj, "type");
            cJSON *instr_name = cJSON_GetObjectItem(objdump_item_obj, "instr_name");
            cJSON *destination = cJSON_GetObjectItem(objdump_item_obj, "destination");
            if (type == NULL || instr_name == NULL || destination == NULL) {
                Serial.println("Failed to parse objdump_item");
                return false;
            }
            Objdump_Item * objdump_item = new Objdump_Item(address, type->valuestring, instr_name->valuestring, destination->valuestring);
            if (objdump_item == NULL) {
                Serial.println("Failed to allocate memory for objdump_item");
                return false;
            }
            objdump_items.push_back(objdump_item);
            objdump_item_obj = objdump_item_obj->next;
        }
        this->objdump[function_name] = objdump_items;
        objdump_entry_obj = objdump_entry_obj->next;
    }
    // for (auto const &x : this->objdump) {
    //     // printf("x.first: %s", x.first.c_str());
    //     
    //     for (const std::vector<Objdump_Item*> &y : x.second) {
    //         // printf("y->address: %s", y->address.c_str());
    //         // printf("y->type: %s", y->type.c_str());
    //         // printf("y->inst_name: %s", y->inst_name.c_str());
    //         // printf("y->destination: %s", y->destination.c_str());

    //     }
    // }
    return true;
}

void GUI_State_Explore_Objdump::push_function(String current_function) {
    if (!contains_function(current_function)) {
        Serial.printf("Function %s not found in objdump. Can't push it.\n", current_function.c_str());
        return;
    }
    function_stack.push_back(current_function);
    if (function_stack.size() > 1) {
        btn_back->show();
    }
    set_current_function(current_function);
}

void GUI_State_Explore_Objdump::pop_function() {
    if (function_stack.size() < 2) {
        Serial.println("Can't pop function. Function stack is empty.");
        return;
    }
    function_stack.pop_back();
    if (function_stack.back() == "_start") {
        btn_back->hide();
    }
    set_current_function(function_stack.back());
}

bool GUI_State_Explore_Objdump::contains_function(String function) {
    return this->objdump.find(function) != this->objdump.end();
}

void GUI_State_Explore_Objdump::set_current_function(String current_function) {
    clean();
    if (!contains_function(current_function)) {
        Serial.printf("Function %s not found in objdump. Can't set it as current function.\n", current_function.c_str());
        return;
    }
    tft->setTextSize(GUI_State_Explore_Objdump::font_size);
    const int y_offset = tft->fontHeight() * 1.2;
    const int y_start = RESOLUTION_Y * 0.05 + y_offset;
    int y = y_start;
    const int x = RESOLUTION_X * 0.02;
    const int btn_w = tft->textWidth("Select")*1.1;
    this->current_function = current_function;
    for (Objdump_Item *item : this->objdump[current_function]) {
        GUI_Button *btn = new GUI_Button(tft, "Select", x, y, btn_w, y_offset, GUI_State_Explore_Objdump::font_size, WHITE, BLACK, [](){}, [this, item](){
            selected_address = strtoll(item->address.c_str(), NULL, 16);
            on_address_selected(selected_address);
            gui->pop_state();
        });
        if (btn == NULL) {
            Serial.println("Failed to allocate memory for GUI_Button in GUI_State_Explore_Objdump::set_current_function");
        }
        GUI_Label *label = new GUI_Label(tft, "-", x + btn_w * 1.2, y+y_offset/2, GUI_State_Explore_Objdump::font_size, ML_DATUM, WHITE, BLACK, [](){}, [](){}, 0.0, 0.2);//0.2);
        if (label == NULL) {
            Serial.println("Failed to allocate memory for GUI_Label in GUI_State_Explore_Objdump::set_current_function");
        }

        String label_text = item->address + " " + item->instr_name;
        if (contains_function(item->destination) && item->destination != current_function) {
            label->set_on_release_callback([this, item](){
                push_function(item->destination);
            });
            label->set_text_colour(WHITE);
        } else if (item->instr_name == "RET") {
            label->set_on_release_callback([this, item](){
                pop_function();
            });
        } else {
            label->set_text_colour(DKGREY);
        }

        if (item->type == "entry" || item->type == "exit") {
            label->set_text_colour(YELLOW);
            if (item->type == "entry") {
                label_text += " (ENTRY)";
            }
        }
        if (item->type == "branch" || item->type == "function") {
            label_text += " -> " + item->destination;
        }
        label->set_text(label_text);
        y += y_offset;

        labels.push_back(label);
        buttons_select.push_back(btn);
        add_element(btn);
        add_element(label);
    }
    label_current_function->set_text(current_function);
}

// should be called only when the new objdump is set and old one is no longer needed
void GUI_State_Explore_Objdump::clean_objudmp() {
    for (auto const &x : this->objdump) {
        for (Objdump_Item *objdump_item : x.second) {
            delete objdump_item;
        }
    }
    this->objdump.clear();
    function_stack.clear();
    clean();
}

// Should be called while traversing the objdump
void GUI_State_Explore_Objdump::clean() {
    for (GUI_Label *label : this->labels) { 
        if (!has_element(label)) {
            Serial.println("Label not found in GUI_State_Explore_Objdump::clean");
            continue;
        }
        remove_element(label); 
        delete label; 
    }
    for (GUI_Button *btn : this->buttons_select) {
        if (!has_element(btn)) {
            Serial.println("Button not found in GUI_State_Explore_Objdump::clean");
            continue;
        }
        remove_element(btn);
        delete btn; 
    }
    this->labels.clear();
    this->buttons_select.clear();
    tft->fillScreen(BLACK);
    btn_back->needs_redraw = true;
    label_current_function->needs_redraw = true;
}

void GUI_State_Explore_Objdump::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("GUI_State_Explore_Objdump::on_state_enter");
}

void GUI_State_Explore_Objdump::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("GUI_State_Explore_Objdump::on_state_exit");
}