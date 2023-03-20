#include <gui_state_select_number.h>
#include <display_config.h>
#include <colours.h>

GUI_State_Select_Number::GUI_State_Select_Number(TFT_eSPI *tft, GUI *gui, Touch *touch) 
    : GUI_State(tft, gui, touch), on_number_selected_callback([](long long l){})
{
    // 21 parts:
    // - 1 empty
    // - 1 for polarity (+/- sign)
    // - 2 for "0x"
    // - 16 digits
    // - 1 empty
    int x_offset = RESOLUTION_X / 21;
    const int x_start = x_offset * 1.5; // first drawn item position (middle of it)
    const int y_pos = RESOLUTION_Y / 2;
    int x_pos = x_start;
    label_polarity = new GUI_Label(tft, "+", x_start, y_pos, font_size, MC_DATUM, WHITE, BLACK);  x_pos += x_offset;
    label_0 = new GUI_Label(tft, "0", x_pos, y_pos, font_size, MC_DATUM, WHITE, BLACK);           x_pos += x_offset;
    label_x = new GUI_Label(tft, "x", x_pos, y_pos, font_size, MC_DATUM, WHITE, BLACK);           x_pos += x_offset;
    add_element(label_polarity);
    add_element(label_0);
    add_element(label_x);
    for (int i = 0; i < 16; i++) {
        GUI_Label *label = new GUI_Label(tft, "-", x_pos, y_pos, font_size, MC_DATUM, WHITE, BLACK);
        x_pos += x_offset;
        labels.push_back(label);
        add_element(label);
    }
    set_number(0x123456789ABCDEF);

    // ------------------------------------------------
    // ---------------- OK button ---------------------
    const int btn_ok_font_size = 2;
    tft->setTextSize(btn_ok_font_size);
    int btn_ok_font_height = tft->fontHeight(btn_ok_font_size);
    int btn_ok_h = btn_ok_font_height*1.2;
    const int btn_ok_w = tft->textWidth("OK") * 2;
    btn_ok = new GUI_Button(tft, "OK", RESOLUTION_X - btn_ok_w*1.2, RESOLUTION_Y - btn_ok_h*1.2, btn_ok_w, btn_ok_h, btn_ok_font_size, WHITE, BLACK, 
        [](){},
        [gui, this]() { 
            on_number_selected_callback(get_number());
        }
    );
    add_element(btn_ok);
}

void GUI_State_Select_Number::reset() {
    GUI_State::reset();
}

void GUI_State_Select_Number::update() {
    GUI_State::update();
}

void GUI_State_Select_Number::draw() {
    GUI_State::draw();
}

void GUI_State_Select_Number::set_number(long long number) {
    digits.clear();
    int i = 0;
    if (number < 0) {
        label_polarity->set_text("-");
        number = -number;
    } else {
        label_polarity->set_text("+");
    }

    for (auto label : labels)
        label->set_text("0");
    while (number > 0) {
        char digit = number % 16;
        digits.push_back(digit);
        String digit_str = String(digit, HEX);
        digit_str.toUpperCase();
        labels[15-i]->set_text(digit_str);
        number /= 16;
        i++;
    }
}

long long GUI_State_Select_Number::get_number() {
    long long number;
    for (int i = digits.size() - 1; i >= 0; i--) {
        number *= 16;
        number += digits[i];
    }
    if (label_polarity->get_text() == "-")
        number = -number;
    return number;
}

void GUI_State_Select_Number::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("GUI_State_Select_Number on_state_enter");
}

void GUI_State_Select_Number::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("GUI_State_Select_Number on_state_exit");
}