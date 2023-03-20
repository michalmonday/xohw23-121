#ifndef RULE_ESP32_H
#define RULE_ESP32_H
#include <gui_element.h>
#include <gui_checkbox.h>
#include <gui_label.h>
#include <Arduino.h>
#include <map>
#include <gui_button.h>


class Rule : public GUI_Element {
public:
    Rule(TFT_eSPI *tft, int x, int y, int w, int h, unsigned int colour, std::function<void()> on_checked = [](){}, std::function<void()> on_unchecked = [](){}, std::function<void()> on_label_released = [](){});
    virtual void draw() override;
    virtual void undraw() override;

    void set_attribute(String attribute, long long value);
    void remove_attribute(String attribute);
    std::map<String, long long> get_attributes() { return attributes; }
    long get_attribute(String attribute) { return attributes[attribute]; }
    String get_attribute_as_hex_string(String attribute) { return "0x" + String(attributes[attribute], HEX); }
    bool has_attribute(String attribute) { return attributes.find(attribute) != attributes.end(); }
    // String get_attributes_as_JSON_string();

    void set_text(String text) { label->set_text(text); }

    void set_on_label_released_callback(std::function<void()> func) { label->set_on_release_callback(func); }
    void set_on_checked_callback(std::function<void()> func) { checkbox_is_active->set_on_checked_callback(func); }
    void set_on_unchecked_callback(std::function<void()> func) { checkbox_is_active->set_on_unchecked_callback(func); }

private:
    std::map<String, long long> attributes;
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

    GUI_Checkbox *checkbox_is_active;
    // GUI_Button *button_edit;
    GUI_Label *label;
    unsigned int colour;
};


#endif