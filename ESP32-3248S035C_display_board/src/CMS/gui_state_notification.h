#ifndef GUI_STATE_NOTIFICATION_H
#define GUI_STATE_NOTIFICATION_H

#include <Arduino.h>

#include <gui_state.h>
#include <gui_label.h>

#include "graphics.h"

class GUI;

class GUI_State_Notification : public GUI_State {
public:
    GUI_State_Notification(Graphics *gfx, GUI *gui, Touch *touch, int timeout=0);
    void set_text(String text);
    void set_font_size(int font_size) { label->set_font_size(font_size);}
    virtual void update() override;
    virtual void on_state_enter() override;
    virtual void on_state_exit() override;
    void set_timeout(int timeout) { this->timeout = timeout; }
    GUI_Label *get_label() { return label; }
    void update_start_time(unsigned long start_time) { switch_time = start_time; }
private:
    GUI_Label *label;
    int timeout;
    unsigned long switch_time;
};

#endif