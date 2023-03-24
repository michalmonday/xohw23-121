#include "watchpoint.h"
#include <cJSON.h>
#include <rpc.h>
#include <display_config.h>

Watchpoint::Watchpoint(TFT_eSPI *tft, int index, int x, int y, int font_size, unsigned int colour, std::function<void()> on_checked, std::function<void()> on_unchecked, std::function<void()> on_label_released)
    : GUI_Element(tft, x, y, 10, 10), colour(colour), index(index), font_size(font_size)
{
    tft->setTextSize(font_size);
    h = tft->fontHeight() * 1.3;
    
    int checkbox_w = h;
    int checkbox_h = h;
    int x_space = h*0.5;
    Serial.printf("Watchpoint::Watchpoint() - h: %d, checkbox_w: %d, checkbox_h: %d, x_space: %d\n", h, checkbox_w, checkbox_h, x_space);
    w = tft->textWidth("wp_0") + checkbox_w + x_space;
    checkbox_is_active = new GUI_Checkbox(tft, false, x, y, checkbox_w, checkbox_h, font_size, GREEN, BLACK, on_checked, on_unchecked);
    if (checkbox_is_active == nullptr) {
        Serial.println("ERROR: Watchpoint::Watchpoint() - checkbox_is_active is nullptr");
    }

    // int button_x = x + checkbox_w + x_space;
    // int button_w = tft->textWidth("Edit") * 1.4;
    // button_edit = new GUI_Button(tft, "Edit", button_x, y, button_w, h, 1, WHITE, BLACK);
    // button_edit->set_on_release_callback([](){
    //     Serial.println("Edit button pressed");        
    // });

    // int label_x = button_x + button_w + x_space;
    int label_x = x + checkbox_w + x_space;
    label = new GUI_Label(tft, "wp_" + String(index), label_x, y + h/2, font_size, ML_DATUM, WHITE, BLACK);
    if (label == nullptr) {
        Serial.println("ERROR: Watchpoint::Watchpoint() - label is nullptr");
    }
    // label->set_padding_y(1.0); // 1.0 means it will occupy 3x the previous height (100% will be added from each side)
    label->set_on_release_callback(on_label_released);

    add_child_element(checkbox_is_active);
    // add_child_element(button_edit);
    add_child_element(label);
}

void Watchpoint::draw() {
    GUI_Element::draw();
    // tft->fillRect(x, y, w, h, colour);
}

void Watchpoint::undraw() {
    GUI_Element::undraw();
}

void Watchpoint::set_attribute(String attribute, long long value) {
    attributes[attribute] = value;
}

void Watchpoint::remove_attribute(String attribute) {
    if (has_attribute(attribute)) 
        attributes.erase(attribute);
}

// Caller must deallocate the returned string
char * Watchpoint::get_attributes_as_JSON_string() {
    // cJSON does not support 64-bit values so hex strings are used instead
    cJSON *root = cJSON_CreateObject();
    for (auto &attr : attributes) {
        // cJSON_AddNumberToObject(root, attr.first.c_str(), attr.second);
        cJSON_AddStringToObject(root, attr.first.c_str(), String(attr.second, HEX).c_str());
    }
    char *json_string = cJSON_PrintUnformatted(root);
    cJSON_Delete(root);
    return json_string;
}

void Watchpoint::push_to_pynq() {
    // rpc_set_atf_watchpoint(index, is_active, json_str_attributes_dict)
    // Serial.println("Pushing watchpoint to PYNQ");
    char * attr_dict = get_attributes_as_JSON_string();
    rpc("rpc_set_atf_watchpoint", "%d%b%s", index, is_active(), attr_dict);
    free(attr_dict);
}