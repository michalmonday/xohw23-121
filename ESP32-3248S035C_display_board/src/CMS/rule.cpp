#include "rule.h"
#include <cJSON.h>
#include <rpc.h>

Rule::Rule(TFT_eSPI *tft, int index, int x, int y, int w, int h, unsigned int colour, std::function<void()> on_checked, std::function<void()> on_unchecked, std::function<void()> on_label_released)
    : GUI_Element(tft, x, y, w, h), colour(colour), index(index)
{
    int checkbox_w = h;
    int checkbox_h = h;
    int space = h*0.2;
    checkbox_is_active = new GUI_Checkbox(tft, false, x, y, checkbox_w, checkbox_h, 1, GREEN, BLACK, on_checked, on_unchecked);

    // int button_x = x + checkbox_w + space;
    // int button_w = tft->textWidth("Edit") * 1.4;
    // button_edit = new GUI_Button(tft, "Edit", button_x, y, button_w, h, 1, WHITE, BLACK);
    // button_edit->set_on_release_callback([](){
    //     Serial.println("Edit button pressed");        
    // });

    // int label_x = button_x + button_w + space;
    int label_x = x + checkbox_w + space;
    label = new GUI_Label(tft, "rule_0", label_x, y + h/2, 1, ML_DATUM, WHITE, BLACK);
    label->set_padding_y(1.0); // 1.0 means it will occupy 3x the previous height (100% will be added from each side)
    label->set_on_release_callback(on_label_released);

    add_child_element(checkbox_is_active);
    // add_child_element(button_edit);
    add_child_element(label);
}

void Rule::draw() {
    GUI_Element::draw();
    // tft->fillRect(x, y, w, h, colour);
}

void Rule::undraw() {
    GUI_Element::undraw();
}

void Rule::set_attribute(String attribute, long long value) {
    attributes[attribute] = value;
}

void Rule::remove_attribute(String attribute) {
    if (has_attribute(attribute)) 
        attributes.erase(attribute);
}

// Caller must deallocate the returned string
char * Rule::get_attributes_as_JSON_string() {
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

void Rule::push_to_pynq() {
    // rpc_set_atf_rule(index, is_active, json_str_attributes_dict)
    char * attr_dict = get_attributes_as_JSON_string();
    rpc("rpc_set_atf_rule", "%d%b%s", index, is_active(), attr_dict);
    free(attr_dict);
}