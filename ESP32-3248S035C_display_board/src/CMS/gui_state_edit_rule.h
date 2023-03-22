#ifndef GUI_STATE_EDIT_RULE_H
#define GUI_STATE_EDIT_RULE_H

#include <Arduino.h>
#include <vector>

#include <gui_state.h>
#include <gui_label.h>
#include <gui_graph.h>
#include <gui_checkbox.h>
#include <gui_button.h>
#include <gui_state_select_number.h>
#include <gui_cms_states.h>

#include <rule.h>

class GUI_CMS;

// Attribute struct below groups together graphical objects when displaying current selection of attributes for a rule.
// Graphical objects like a checkbox and a label, maybe a button will be added for PC to select from a list of functions (from objdump).
struct Attribute {
    String name;
    long long value;
    GUI_Label *label;
    GUI_Checkbox *checkbox_is_active;
    const static int font_size = 2;
    GUI_CMS *gui;

    Attribute(TFT_eSPI *tft, GUI_CMS* gui, String name, long long value, int x, int y) : name(name), value(value), gui(gui) {
        int font_height = tft->fontHeight(font_size);
        checkbox_is_active = new GUI_Checkbox(tft, false, x, y, font_height, font_height, 1, GREEN, BLACK, [](){}, [](){});
        // convert long to hex string using ltoa
        label = new GUI_Label(tft, "-", x + font_height * 1.2, y+font_height/2, font_size, ML_DATUM, WHITE, BLACK);
        label->set_padding_y(0.2);
        // convert this->test to std::function<void()> and pass it to set_on_release_callback, and resolve the problem with invalid use of incomplete type 'class GUI_CMS'
        label->set_on_release_callback(std::bind(&Attribute::edit_attribute, this));
        // label->set_on_release_callback([gui, this](){
        //     // this should activate attribute editing mode and allow to set numeric value
        //     // the state may be generic and be called something like "numeric value selection state" 
        //     Serial.println("Attribute label released");
        //     this->gui->push_state(GUI_STATE_SELECT_NUMBER);
        //     this->gui->get_state_select_number()->set_on_number_selected_callback([gui, this](long long value){
        //         set_value(value);
        //         gui->pop_state();
        //     });
        // });
        set_value(value);
    }
    void edit_attribute();

    // void test() {
    //     Serial.println("Attribute label released");
    //     this->gui->push_state(GUI_STATE_SELECT_NUMBER);
    //     this->gui->get_state_select_number()->set_on_number_selected_callback([this](long long value){
    //         set_value(value);
    //         gui->pop_state();
    //     });
    // }
    void set_value(long long value) {
        this->value = value;
        char hex_str[30];
        lltoa(llabs(value), hex_str, 16);
        String prefix = "0x";
        if (value < 0)
            prefix = "-0x";
        label->set_text(name + ": " + prefix + String(hex_str));
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
    void set_attribute(String name, long long value);
private:
    // create vector of pairs of attribute name and attribute value
    static std::vector<std::pair<String, long long>> default_attributes; 
    Rule *rule;
    std::map<String, Attribute*> attributes;
    GUI_Button *btn_ok;
    GUI_Button *btn_objdump;

    void latch_attribute_values_to_rule();
    void set_default_values();
};

#endif