#ifndef GUI_STATE_SELECT_NUMBER_H
#define GUI_STATE_SELECT_NUMBER_H

#include <TFT_eSPI.h>
#include <vector>

#include <gui_state.h>
#include <gui_label.h>
#include <gui_button.h>


class GUI_State_Select_Number : public GUI_State {
public:
    GUI_State_Select_Number(TFT_eSPI *tft, GUI *gui, Touch *touch);
    virtual void update() override;
    virtual void reset() override;
    virtual void draw() override;
    virtual void on_state_enter() override;
    virtual void on_state_exit() override;
    void set_number(long long number);
    long long get_number(); 
    void set_on_number_selected_callback(std::function <void(long long)> callback) { on_number_selected_callback = callback; }

    const static int font_size = 3;
private:
    GUI_Label* label_polarity;
    GUI_Label* label_0;
    GUI_Label* label_x;
    std::vector<char> digits;
    std::vector<GUI_Label*> labels;
    std::function <void(long long)> on_number_selected_callback;
    GUI_Button* btn_ok;
};

#endif