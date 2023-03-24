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

    const int triangle_w = x_offset;
    const int triangle_h = triangle_w * 1.5;
    const int triangle_offset = RESOLUTION_Y * 0.1;
    const unsigned int triangle_fill_colour = BLACK;
    const unsigned int triangle_border_colour = WHITE;

    // --------------------------------
    // -------- polarity --------------
    label_polarity = new GUI_Label(tft, "+", x_start, y_pos, font_size, MC_DATUM, WHITE, BLACK);  
    triangle_up_polarity = new GUI_Triangle(tft, GUI_TRIANGLE_ROTATION_UP, x_pos, y_pos - triangle_offset, triangle_w, triangle_h, BC_DATUM, triangle_border_colour, triangle_fill_colour, BLACK, [this]() { toggle_polarity(); });
    triangle_down_polarity = new GUI_Triangle(tft, GUI_TRIANGLE_ROTATION_DOWN, x_pos, y_pos + triangle_offset, triangle_w, triangle_h, TC_DATUM, triangle_border_colour, triangle_fill_colour, BLACK, [this]() { toggle_polarity(); });
    add_element(triangle_up_polarity);
    add_element(triangle_down_polarity);
    add_element(label_polarity);
    x_pos += x_offset;
    
    // --------------------------------
    // -------- 0x --------------------
    label_0 = new GUI_Label(tft, "0", x_pos, y_pos, font_size, MC_DATUM, WHITE, BLACK);           x_pos += x_offset;
    label_x = new GUI_Label(tft, "x", x_pos, y_pos, font_size, MC_DATUM, WHITE, BLACK);           x_pos += x_offset;
    add_element(label_0);
    add_element(label_x);

    if (label_polarity == NULL || triangle_up_polarity == NULL || triangle_down_polarity == NULL || label_0 == NULL || label_x == NULL) {
        Serial.println("Failed to allocate memory for GUI_State_Select_Number");
    }

    // --------------------------------
    // -------- 16 digits -------------
    for (int i = 0; i < 16; i++) {
        // digit labels
        GUI_Label *label = new GUI_Label(tft, "-", x_pos, y_pos, font_size, MC_DATUM, WHITE, BLACK);
        labels.push_back(label);
        add_element(label);

        // triangles
        GUI_Triangle *triangle_up = new GUI_Triangle(tft, GUI_TRIANGLE_ROTATION_UP, x_pos, y_pos - triangle_offset, triangle_w, triangle_h, BC_DATUM, triangle_border_colour, triangle_fill_colour, BLACK, 
            [this, i]() {
                digit_up(i);
            }
        );

        GUI_Triangle *triangle_down = new GUI_Triangle(tft, GUI_TRIANGLE_ROTATION_DOWN, x_pos, y_pos + triangle_offset, triangle_w, triangle_h, TC_DATUM, triangle_border_colour, triangle_fill_colour, BLACK, 
            [this, i]() {
                digit_down(i);
            }
        );
        if (label == NULL || triangle_up == NULL || triangle_down == NULL) {
            Serial.println("Failed to allocate memory for GUI_State_Select_Number");
        }
        add_element(triangle_up);
        add_element(triangle_down);

        x_pos += x_offset;
    }
    set_number(0x123456789ABCDEF);

    // --------------------------------
    // --------- OK button ------------
    const int btn_ok_font_size = 2;
    tft->setTextSize(btn_ok_font_size);
    int btn_ok_font_height = tft->fontHeight();

    int btn_ok_h = btn_ok_font_height + btn_ok_font_height * DEFAULT_BTN_PADDING_Y*2;
    const int btn_ok_w = tft->textWidth("OK") + btn_ok_font_height * DEFAULT_BTN_PADDING_X*2;
    btn_ok = new GUI_Button(tft, "OK", RESOLUTION_X - btn_ok_w*1.2, RESOLUTION_Y - btn_ok_h*1.2, btn_ok_w, btn_ok_h, btn_ok_font_size, WHITE, BLACK, 
        [](){},
        [gui, this]() { 
            on_number_selected_callback(get_number());
        }
    );
    if (btn_ok == NULL) {
        Serial.println("Failed to allocate memory for GUI_State_Select_Number");
    }
    add_element(btn_ok);
}

void GUI_State_Select_Number::update_label_colour(int index) {
    if (digits[index] == 0)
        labels[index]->set_text_colour(DKGREY);
    else
        labels[index]->set_text_colour(WHITE);
}

void GUI_State_Select_Number::update_labels_colour() {
    bool non_zero_found = false;
    for (int i = 0; i < 16; i++) {
        if (digits[i] != 0 && !non_zero_found)
            non_zero_found = true;
        if (non_zero_found)
            labels[i]->set_text_colour(WHITE); 
        else
            labels[i]->set_text_colour(DKGREY);
    }
}

void GUI_State_Select_Number::digit_up(int index) {
    int old_digit = digits[index];
    digits[index] = (digits[index]+1) % 16;
    String digit_str = String(digits[index], HEX);
    digit_str.toUpperCase();
    labels[index]->set_text(digit_str);
    if (old_digit == 0 || digits[index] == 0)
        update_labels_colour();
}

void GUI_State_Select_Number::digit_down(int index) {
    int old_digit = digits[index];
    if (digits[index] == 0)
        digits[index] = 15;
    else
        digits[index]--;
    String digit_str = String(digits[index], HEX);
    digit_str.toUpperCase();
    labels[index]->set_text(digit_str);
    if (old_digit == 0 || digits[index] == 0)
        update_labels_colour();
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
    for (int i = 0; i < 16; i++)
        digits.push_back(0);

    int i = 0;
    bool is_negative = number < 0;
    if (is_negative){
        label_polarity->set_text("-");
        number = -number;
    } else {
        label_polarity->set_text("+");
    }

    for (auto label : labels)
        label->set_text("0");
    while (number > 0) {
        char digit = number % 16;
        digits[15-i] = digit;
        String digit_str = String(digit, HEX);
        digit_str.toUpperCase();
        labels[15-i]->set_text(digit_str);
        number /= 16L;
        i++;
    }

    update_labels_colour();
}

long long GUI_State_Select_Number::get_number() {
    long long n = 0;
    for (int i = 0; i < 16; i++) {
        n *= 16;
        n += digits[i];
        Serial.printf("get_number: %lld\n", n);
    }
    if (label_polarity->get_text() == "-")
        n = -n;
    Serial.printf("get_number: %lld\n", n);
    return n;
}

void GUI_State_Select_Number::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("GUI_State_Select_Number on_state_enter");
}

void GUI_State_Select_Number::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("GUI_State_Select_Number on_state_exit");
}

void GUI_State_Select_Number::toggle_polarity() {
    if (label_polarity->get_text() == "-")
        label_polarity->set_text("+");
    else
        label_polarity->set_text("-");
}