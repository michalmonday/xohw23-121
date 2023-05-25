#ifndef GUI_STATE_SELECT_IP_H
#define GUI_STATE_SELECT_IP_H

#include <vector>

#include <gui_state.h>
#include <gui_label.h>
#include <gui_button.h>
#include <gui_triangle.h>

#include "graphics.h"


class GUI_State_Select_IP : public GUI_State {
public:
    GUI_State_Select_IP(Graphics *gfx, GUI *gui, Touch *touch);
    virtual void update() override;
    virtual void reset() override;
    virtual void draw() override;
    virtual void on_state_enter() override;
    virtual void on_state_exit() override;
    void set_ip(IPAddress ip);
    IPAddress get_ip(); 
    void set_on_ip_selected_callback(std::function <void(IPAddress)> callback) { on_ip_selected_callback = callback; }

    const static int font_size = 3;
private:
    std::vector<GUI_Label*> labels;
    std::vector<GUI_Label*> labels_dots;
    std::function <void(IPAddress)> on_ip_selected_callback;
    GUI_Button* btn_ok;
    std::vector<GUI_Triangle*> triangles_up;
    std::vector<GUI_Triangle*> triangles_down;

    void digit_up(int index);
    void digit_down(int index);
    void update_label_colour(int index);
    void update_labels_colour();
};

#endif