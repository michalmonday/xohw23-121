#ifndef GUI_STATE_EXPLORE_OBJDUMP_H
#define GUI_STATE_EXPLORE_OBJDUMP_H

#include <map>
#include <gui_state.h>
#include <gui_label.h>
#include <gui_button.h>
#include <cJSON.h>

#include "graphics.h"


class GUI_CMS;

struct Objdump_Item {
    String address;     // program counter where it happens
    String type;        // "entry", "function", "branch", "exit"
    String instr_name;   // e.g. "J", "BNEZ"
    String destination; // e.g. "main+0x4", "function_a" (or empty string if it's "entry" or "exit" type)
    Objdump_Item(String address, String type, String instr_name, String destination) : address(address), type(type), instr_name(instr_name), destination(destination) {}
};

class GUI_State_Explore_Objdump : public GUI_State {
public:
    GUI_State_Explore_Objdump(Graphics *gfx, GUI_CMS *gui, Touch *touch);
    virtual void update() override;
    virtual void draw() override;
    virtual void on_state_enter() override;
    virtual void on_state_exit() override;
    // void set_objdump(std::map<String, std::vector<Objdump_Item*>> objdump);
    bool set_objdump(cJSON *objdump);
    // void add_objdump_entry(String name, std::vector<Objdump_Item*> objdump);
    void push_function(String name);
    void pop_function();
    bool contains_function(String name);
    void clean();
    void clean_objudmp();
    void set_on_address_selected(std::function<void((long long))> on_address_selected) { this->on_address_selected = on_address_selected; }

    const static int font_size = 2;
private:
    // key = function name, value = vector of Objdump_Items (one for each branch/call/entry/exit)
    std::map<String, std::vector<Objdump_Item*>> objdump;
    String current_function;
    std::vector<String> function_stack;

    // labels and buttons are created/destroyed dynamically as needed when changing currently selected function
    std::vector<GUI_Label*> labels;
    std::vector<GUI_Button*> buttons_select;

    GUI_Label *label_current_function;
    GUI_Button *btn_back;

    long long selected_address;

    std::function<void(long long)> on_address_selected;

    void set_current_function(String name);
};

#endif