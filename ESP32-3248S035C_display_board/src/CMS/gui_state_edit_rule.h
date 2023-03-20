#ifndef GUI_STATE_EDIT_RULE_H
#define GUI_STATE_EDIT_RULE_H

#include <Arduino.h>
#include <vector>

#include <gui_state.h>
#include <gui_label.h>
#include <gui_graph.h>
#include <gui_checkbox.h>
#include <gui_button.h>

#include <rule.h>

class GUI_CMS;

// Attribute struct below groups together graphical objects when displaying current selection of attributes for a rule.
// Graphical objects like a checkbox and a label, maybe a button will be added for PC to select from a list of functions (from objdump).
struct Attribute {
    String name;
    long value;
    GUI_Label *label;
    GUI_Checkbox *checkbox_is_active;
    const static int font_size = 2;

    Attribute(TFT_eSPI *tft, String name, long long value, int x, int y) : name(name), value(value) {
        int font_height = tft->fontHeight(font_size);
        checkbox_is_active = new GUI_Checkbox(tft, false, x, y, font_height, font_height, 1, GREEN, BLACK, [](){}, [](){});
        // convert long to hex string using ltoa
        label = new GUI_Label(tft, "-", x + font_height * 1.2, y+font_height/2, font_size, ML_DATUM, WHITE, BLACK);
        label->set_on_release_callback([](){
            // this should activate attribute editing mode and allow to set numeric value
            // the state may be generic and be called something like "numeric value selection state" 
            Serial.println("Attribute label released");
        });
        set_value(value);
    }
    void set_value(long long value) {
        this->value = value;
        char hex_str[30];
        lltoa(value, hex_str, 16);
        label->set_text(name + ": 0x" + String(hex_str));
    }
    bool is_active() {
        return checkbox_is_active->is_checked();
    }
    void set_is_active(bool state) {
        checkbox_is_active->set_is_checked(state);
    }
};

class GUI_State_Edit_Rule : public GUI_State {
public:
    GUI_State_Edit_Rule(TFT_eSPI *tft, GUI_CMS *gui, Touch *touch);
    virtual void update() override;
    virtual void on_state_enter() override;
    virtual void on_state_exit() override;
    void set_rule_to_edit(Rule* rule);
private:
    // create vector of pairs of attribute name and attribute value
    static std::vector<std::pair<String, long long>> default_attributes; 
    Rule *rule;
    std::map<String, Attribute*> attributes;
    GUI_Button *btn_ok;

    void latch_attribute_values_to_rule();
    void set_default_values();
};

#endif